--[[

`W3CEvents` provides a simple API for emitting structured game events.

Typical usage:

--------------------

W3CEvents.initialize()

W3CEvents.register_all_schemas({
  W3CEvents.schema("PlayerState", {
    W3CEvents.intField("gold"),
    W3CEvents.intField("wood"),
  }),
})

W3CEvents.event("PlayerState", {
  player = 0,
  gold = 500,
  wood = 120,
})

----------------------

`player` and `time` are added automatically to all events.

--]]

local W3CData = require("lua.w3cdata")
local W3CChecksum = require("lua.w3cChecksum")

local MAX_PAYLOAD_SIZE_BYTES = 180
local DEFAULT_FLUSH_INTERVAL_SECONDS = 15
local DEFAULT_FLUSH_PACKET_SPACING_SECONDS = 0.1
local CHECKSUM_EVENT_INTERVAL = 10

-- This needs to be "WC" for W3Champions to be able to automatically parse events.
-- Prefixes larger than 2 characters may cause latency issues. See below post, although it's specific to the other
-- Sync<>, it would make sense that it works the same way for SyncData.
-- https://www.hiveworkshop.com/pastebin/1ce4fe042832e6bd7d06697a43055373.5801
local SYNC_DATA_PREFIX = "WC"

local EVENTS = {
    SHARED = "shared",
    GAME_END = "W3CGameEnd",
}

local ERRORS = {
    NOT_INIT_ERROR = "W3CEvents has not been setup before use. Use W3CEvents.start()",
    GAME_ENDED_ERROR = "W3CEvents.end_game has been used, cannot create any more events",
    SCHEMA_REGISTERED_ERROR =
    "W3CEvents.register_all_schemas has not been used. Registering schemas is required before creating any events",
    TRACK_EVENT_EXISTS = "W3CEvents.track already contains the event: "
}

---@alias Event table<string, string | number | boolean>

---@class ChecksumConfig
---@field enabled boolean
---@field get_checksum? function Optional override used to generate checksum payload values.
---@field event_interval? integer Interval in number of events for periodic checksum packets.

---@class EventSharedSchemaConfig
---@field enabled boolean
---@field set_shared_event_data? function Optional override used to populate shared schema fields.

---@class BooleanConfig
---@field enabled boolean

---@class FlushConfig
---@field interval_seconds? number Timer interval used to flush buffered events.
---@field packet_spacing_seconds? number Delay between SyncData packets during a flush.

---@class W3CEventsConfig
---@field checksum ChecksumConfig
---@field shared_schema EventSharedSchemaConfig
---@field flush? FlushConfig
---@field logging BooleanConfig

---@class W3CEventsGameEndPlayer
---@field player integer
---@field won boolean

---@alias W3CEventsGameEnd table<W3CEventsGameEndPlayer>

---@class TrackCallback
---@field event_name string
---@field func function
---@field tick_interval integer

---@class W3CEvents
---@field event_buffer table<Payload>
---@field track_callbacks table<TrackCallback>
---@field config W3CEventsConfig
local W3CEvents = {
    event_buffer = {},
    track_callbacks = {},
    sending_player_ids = {},
    requested_sender_count = 1,
    config = {
        checksum = { enabled = true, event_interval = CHECKSUM_EVENT_INTERVAL },
        shared_schema = { enabled = true },
        flush = {
            interval_seconds = DEFAULT_FLUSH_INTERVAL_SECONDS,
            packet_spacing_seconds = DEFAULT_FLUSH_PACKET_SPACING_SECONDS,
        },
        logging = { enabled = false },
    },
}

local function merge_config(defaults, overrides)
    local merged = {}

    for key, value in pairs(defaults) do
        if type(value) == "table" then
            merged[key] = {}
            for nested_key, nested_value in pairs(value) do
                merged[key][nested_key] = nested_value
            end
        else
            merged[key] = value
        end
    end

    if not overrides then
        return merged
    end

    for key, value in pairs(overrides) do
        if type(value) == "table" and type(merged[key]) == "table" then
            for nested_key, nested_value in pairs(value) do
                merged[key][nested_key] = nested_value
            end
        else
            merged[key] = value
        end
    end

    return merged
end

local function create_integer_field(name, field_type, options)
    local field = {
        name = name,
        field_type = field_type,
    }
    options = options or {}

    field.num_of_bits = options.num_of_bits
    field.unsigned = options.unsigned
    field.minimum = options.minimum
    field.maximum = options.maximum

    return field
end

--- Creates a field definition for use in `W3CEvents.schema`.
--- This is the generic helper used by the typed field builders below.
---@param name string Field name
---@param field_type FieldType Field type understood by `W3CData`
---@param options? FieldOptions Optional field configuration
---@return Field field
function W3CEvents.field(name, field_type, options)
    if field_type == "byte" or field_type == "short" or field_type == "int" or field_type == "number" then
        return create_integer_field(name, field_type, options)
    end

    local field = {
        name = name,
        field_type = field_type,
    }
    options = options or {}

    field.num_of_bits = options.num_of_bits
    field.unsigned = options.unsigned
    field.minimum = options.minimum
    field.maximum = options.maximum

    return field
end

--- Creates a schema definition to be registered later with `register_all_schemas`.
---@param name string Schema name
---@param fields Field[] Schema fields
---@param options? SchemaOptions Schema options such as `version` and `include_defaults`
---@return Schema schema
function W3CEvents.schema(name, fields, options)
    options = options or {}
    return {
        version = options.version or 1,
        name = name,
        include_defaults = options.include_defaults,
        fields = fields,
    }
end

--- Convenience helper for a `bool` field.
---@param name string
---@return Field
function W3CEvents.boolField(name)
    return { name = name, field_type = "bool" }
end

--- Convenience helper for a `byte` field.
---@param name string
---@param options? IntegerFieldOptions
---@return Field
function W3CEvents.byteField(name, options)
    return create_integer_field(name, "byte", options)
end

--- Convenience helper for a `short` field.
---@param name string
---@param options? IntegerFieldOptions
---@return Field
function W3CEvents.shortField(name, options)
    return create_integer_field(name, "short", options)
end

--- Convenience helper for an `int` field.
---@param name string
---@param options? IntegerFieldOptions
---@return Field
function W3CEvents.intField(name, options)
    return create_integer_field(name, "int", options)
end

--- Convenience helper for a `float` field.
---@param name string
---@return Field
function W3CEvents.floatField(name)
    return { name = name, field_type = "float" }
end

--- Convenience helper for a `string` field.
---@param name string
---@return Field
function W3CEvents.stringField(name)
    return { name = name, field_type = "string" }
end

local event_buffer_size = 0

local game_ended = false
local ending_game = false
local initialized = false
local schemas_registered = false
local schema_registry_sending = false
local event_sequence = 0
local events_since_checksum = 0

---@type W3CChecksum
local checksum = nil

---@type Schema
local shared_schema = {
    version = 1,
    name = EVENTS.SHARED,
    include_defaults = false,
    fields = {
        { name = "player",   field_type = "int", num_of_bits = 5 }, -- Up to 32 player ids
        { name = "time",     field_type = "int", num_of_bits = 13 }, -- Up to ~2 hours 16 minutes
        { name = "sequence", field_type = "int" },
    },
}

---@type Schema
local game_end_schema = {
    version = 1,
    name = EVENTS.GAME_END,
    -- Not using shared as the shared schema has a function used to populate values that we don't want
    -- to use for game end.
    include_defaults = false,
    fields = {
        { name = "player",     field_type = "int", num_of_bits = 5 },
        { name = "time",       field_type = "int", num_of_bits = 13 },
        { name = "sequence",   field_type = "int" },
        { name = "player_won", field_type = "bool" },
    },
}

local function debug_log(message)
    if W3CEvents.config.logging and W3CEvents.config.logging.enabled then
        print("[W3CEvents] " .. message)
    end
end

local function debug_payload_headers(payloads)
    if not W3CEvents.config.logging or not W3CEvents.config.logging.enabled then
        return
    end

    for index, payload in ipairs(payloads) do
        local ok, decoded = pcall(W3CData.cobs_decode, payload)
        if ok and decoded and #decoded > 0 then
            debug_log(
                "payload "
                .. tostring(index)
                .. " header=0x"
                .. string.format("%02X", decoded:byte(1))
                .. " raw_bytes="
                .. tostring(#payload)
                .. " decoded_bytes="
                .. tostring(#decoded)
            )
        else
            debug_log("payload " .. tostring(index) .. " header decode failed: " .. tostring(decoded))
        end
    end
end

--- Returns the positional payload index for the `sequence` field on a schema, if present.
---@param schema_name string
---@return integer|nil
local function sequence_field_index(schema_name)
    local schema = W3CData:get_schema(schema_name)
    for index, field in ipairs(schema.fields) do
        if field.name == "sequence" then
            return index
        end
    end

    return nil
end

--- Creates a stable, sequence-sorted copy of buffered events before encoding.
--- Events without a `sequence` field retain their relative order and sort after
--- sequenced events.
---@param events table<Payload>
---@return table<Payload>
local function sorted_event_buffer(events)
    local indexed = {}

    for original_index, event in ipairs(events) do
        local sequence_index = sequence_field_index(event.schema_name)
        local sequence = sequence_index and event.payload[sequence_index] or nil
        indexed[#indexed + 1] = {
            event = event,
            original_index = original_index,
            sequence = sequence,
        }
    end

    table.sort(indexed, function(a, b)
        if a.sequence ~= nil and b.sequence ~= nil and a.sequence ~= b.sequence then
            return a.sequence < b.sequence
        end

        if a.sequence ~= nil and b.sequence == nil then
            return true
        end

        if a.sequence == nil and b.sequence ~= nil then
            return false
        end

        return a.original_index < b.original_index
    end)

    local sorted = {}
    for _, entry in ipairs(indexed) do
        sorted[#sorted + 1] = entry.event
    end

    return sorted
end

local function get_max_players()
    return bj_MAX_PLAYERS or GetBJMaxPlayers()
end

local function player_is_sender_candidate(player_id)
    local player = Player(player_id)

    if GetPlayerSlotState and GetPlayerSlotState(player) ~= PLAYER_SLOT_STATE_PLAYING then
        return false
    end

    if GetPlayerController and MAP_CONTROL_USER and GetPlayerController(player) ~= MAP_CONTROL_USER then
        return false
    end

    if IsPlayerObserver and IsPlayerObserver(player) then
        return false
    end

    return true
end

local function is_sending_player(player_id)
    for index = 1, #W3CEvents.sending_player_ids do
        local sender_id = W3CEvents.sending_player_ids[index]
        if sender_id == player_id then
            return true
        end
    end

    return false
end

local function normalize_sender_ids(player_ids)
    local normalized = {}
    local seen = {}

    if type(player_ids) == "number" then
        player_ids = { player_ids }
    end

    player_ids = player_ids or {}
    for index = 1, #player_ids do
        local player_id = player_ids[index]
        if type(player_id) == "number" and not seen[player_id] and player_is_sender_candidate(player_id) then
            normalized[#normalized + 1] = player_id
            seen[player_id] = true
        end
    end

    table.sort(normalized)
    return normalized
end

local function requested_sender_count(player_ids)
    if type(player_ids) == "number" then
        return 1
    end

    local count = 0
    local seen = {}
    player_ids = player_ids or {}
    for index = 1, #player_ids do
        local player_id = player_ids[index]
        if type(player_id) == "number" and not seen[player_id] then
            count = count + 1
            seen[player_id] = true
        end
    end

    return count
end

local function fill_sender_vacancies()
    local senders = normalize_sender_ids(W3CEvents.sending_player_ids)
    local seen = {}
    for index = 1, #senders do
        local sender_id = senders[index]
        seen[sender_id] = true
    end

    for player_id = 0, get_max_players() - 1 do
        if #senders >= W3CEvents.requested_sender_count then
            break
        end

        if not seen[player_id] and player_is_sender_candidate(player_id) then
            senders[#senders + 1] = player_id
            seen[player_id] = true
        end
    end

    W3CEvents.sending_player_ids = senders
end

local function send_payloads_paced(payloads, on_complete, wait_packet_count)
    local packet_spacing = W3CEvents.config.flush.packet_spacing_seconds or DEFAULT_FLUSH_PACKET_SPACING_SECONDS
    local expected_count = wait_packet_count or #payloads

    if expected_count <= 0 then
        if on_complete then
            on_complete()
        end
        return
    end

    local index = 1
    local timer = CreateTimer()
    local function send_next_packet()
        if index <= #payloads then
            BlzSendSyncData(SYNC_DATA_PREFIX, payloads[index])
        end

        index = index + 1
        if index > expected_count then
            PauseTimer(timer)
            DestroyTimer(timer)
            if on_complete then
                on_complete()
            end
        end
    end

    TimerStart(timer, packet_spacing, true, send_next_packet)
end

local send_checksum

--- Flushes the current event buffer by encoding it with `W3CData` and sending the
--- resulting payload packets through `BlzSendSyncData` over a paced timer.
---@param on_game_end? function Called once the paced game-end flush window completes.
---@param force_send? boolean When true, bypasses configured sender players.
local function flush(on_game_end, force_send)
    force_send = force_send or false
    local on_game_end_called = false

    local function run_game_end_callback_if_needed()
        if not (ending_game or game_ended) or not on_game_end or on_game_end_called then
            return
        end

        on_game_end_called = true
        on_game_end()
    end

    -- Don't flush if we've disabled events. Disabled in `W3CEvents.end_game()`
    if game_ended or #W3CEvents.event_buffer == 0 then
        if not game_ended then
            debug_log("flush skipped: empty buffer")
        end
        run_game_end_callback_if_needed()
        return
    end

    if schema_registry_sending then
        debug_log("flush skipped: schema registry is still sending")
        return
    end

    fill_sender_vacancies()
    local local_player_id = GetPlayerId(GetLocalPlayer())
    local should_send = force_send or is_sending_player(local_player_id)

    debug_log("flush send decision=" .. tostring(should_send))
    local payload_count = 0
    local payloads = {}

    if should_send then
        debug_log("encoding event buffer")
        local ok, encoded_payloads = pcall(
            W3CData.encode_payload,
            W3CData,
            sorted_event_buffer(W3CEvents.event_buffer),
            MAX_PAYLOAD_SIZE_BYTES
        )
        if not ok then
            debug_log("encode failed: " .. tostring(encoded_payloads))
            run_game_end_callback_if_needed()
            return
        end

        payloads = encoded_payloads
        payload_count = #payloads
        debug_log("encoded " .. tostring(#payloads) .. " payload packet(s)")
        debug_payload_headers(payloads)
    else
        debug_log("flush skipped on local player " .. tostring(local_player_id))
        local ok, encoded_payloads = pcall(
            W3CData.encode_payload,
            W3CData,
            sorted_event_buffer(W3CEvents.event_buffer),
            MAX_PAYLOAD_SIZE_BYTES
        )
        payload_count = ok and #encoded_payloads or 0
    end

    W3CEvents.event_buffer = {}
    event_buffer_size = 0
    send_payloads_paced(payloads, function()
        if should_send and not ending_game and not game_ended then
            send_checksum(false)
        end
        run_game_end_callback_if_needed()
    end, payload_count)
end

-- Monotonic clock to get time since game started
---@type timer
local clock = nil

---@type timer
local track_timer = nil
local track_timer_ticks = 0

---@type timer
local flush_timer = nil

---@type trigger
local sender_leave_trigger = nil

local function now()
    return math.floor(TimerGetElapsed(clock))
end

---Utility function that attempts to estimate the byte size of an event based on it's schema and values
---@param schema_name string
---@param event Event
local function estimate_event_size(schema_name, event)
    local schema = W3CData:get_schema(schema_name)
    local event_size_bytes = 0
    local event_size_bits = 0

    for _, field in ipairs(schema.fields) do
        if field.field_type ~= "string" then
            event_size_bits = event_size_bits + field.num_of_bits
        else
            local string_value = event[field.name]
            -- Pre compression string length as it's just an estimate and we don't want to
            -- compress strings ahead of time constantly
            event_size_bytes = event_buffer_size + #string_value
        end
    end

    event_size_bytes = event_size_bytes + (math.ceil(event_size_bits / 8))
    return event_size_bytes
end

--- Default shared-schema field setter. This populates `time` when that field
--- exists on the registered shared schema and is not already present.
---@param event Event
local function add_shared_schema_data(event)
    local schema = W3CData:get_schema(EVENTS.SHARED)
    -- Only set the event fields if they actually exist on the shared schema
    -- as the shared schema can be changed
    for _, field in ipairs(schema.fields) do
        if field.name == "time" and event["time"] == nil then
            event["time"] = now()
        end
    end
end

--- Adds a sequence value to any gameplay event schema that declares a sequence
--- field, including schemas that opt out of the shared time/player defaults.
---@param name string
---@param event Event
local function add_sequence_data(name, event)
    local schema = W3CData:get_schema(name)
    for _, field in ipairs(schema.fields) do
        if field.name == "sequence" and event["sequence"] == nil then
            event["sequence"] = event_sequence + 1
            return
        end
    end
end

--- Converts a keyed event table into the positional payload format required by `W3CData`.
---@param schema Schema
---@param event Event
---@return table payload
local function ordered_payload(schema, event)
    local payload = {}
    for _, field in ipairs(schema.fields) do
        local value = event[field.name]
        assert(value ~= nil, "Missing field [" .. field.name .. "] for schema [" .. schema.name .. "]")
        table.insert(payload, value)
    end
    return payload
end

--- Updates the checksum using a framed binary representation of the event.
--- This avoids collisions between different schemas or payload boundaries that
--- could occur when concatenating stringified values.
---@param schema_name string
---@param payload table
local function update_checksum_for_event(schema_name, payload)
    if not checksum then
        return
    end

    local schema_id = W3CData:get_schema_id(schema_name)
    assert(schema_id, "Schema [" .. schema_name .. "] is not registered for checksum updates.")

    local packed = W3CData:pack_bits(schema_id, payload)
    local framed = string.pack(">I2I2", schema_id, #packed) .. packed
    checksum:update(framed)
end

--- Sends a checksum payload using the configured checksum getter.
---@param force? boolean When true, emit the checksum even if the event interval has not been reached.
function send_checksum(force)
    if not W3CEvents.config.checksum.enabled then
        return
    end

    local interval = W3CEvents.config.checksum.event_interval or CHECKSUM_EVENT_INTERVAL
    if force or (interval > 0 and events_since_checksum >= interval) then
        local checksum_value = W3CEvents.config.checksum.get_checksum()
        local payload = W3CData:generate_checksum_payload(checksum_value)
        BlzSendSyncData(SYNC_DATA_PREFIX, payload)
        events_since_checksum = 0
    end
end

--- Default checksum getter used when no custom checksum getter is configured.
local function get_checksum()
    return checksum:finalize()
end

local function emit_tracks()
    track_timer_ticks = track_timer_ticks + 1
    for _, track_callback in pairs(W3CEvents.track_callbacks) do
        if track_timer_ticks % track_callback.tick_interval == 0 then
            local val = nil
            if type(track_callback.func) == "function" then
                val = track_callback.func()
            else
                return
            end

            if val == nil or (type(val) == "table" and next(val) == nil) then
                -- Empty tracker output should only skip this source. Other
                -- periodic sources may still have events to emit this tick.
            elseif type(val) == "table" and type(val[1]) == "table" then
                for _, payload in ipairs(val) do
                    W3CEvents.event(track_callback.event, payload)
                end
            else
                W3CEvents.event(track_callback.event, val)
            end
        end
    end
end

local function setup_sender_leave_trigger()
    if sender_leave_trigger then
        return
    end

    sender_leave_trigger = CreateTrigger()
    for player_id = 0, get_max_players() - 1 do
        local player = Player(player_id)
        if GetPlayerSlotState(player) == PLAYER_SLOT_STATE_PLAYING then
            TriggerRegisterPlayerEventLeave(sender_leave_trigger, player)
        end
    end

    TriggerAddAction(sender_leave_trigger, fill_sender_vacancies)
end

--- Creates and starts the timer used by this module for the monotonic game clock.
local function setup_timers()
    if not clock then
        clock = CreateTimer()
        TimerStart(clock, 1e9, false, nil)
    end

    if not track_timer then
        track_timer = CreateTimer()
        TimerStart(track_timer, 5, true, emit_tracks)
    end

    if not flush_timer then
        flush_timer = CreateTimer()
        TimerStart(
            flush_timer,
            W3CEvents.config.flush.interval_seconds or DEFAULT_FLUSH_INTERVAL_SECONDS,
            true,
            flush
        )
    end
end


--- Stops and destroys all timers managed by this module and prevents further events
--- from being accepted.
local function shutdown()
    if clock then
        PauseTimer(clock)
        DestroyTimer(clock)
    end

    if track_timer then
        PauseTimer(track_timer)
        DestroyTimer(track_timer)
    end

    if flush_timer then
        PauseTimer(flush_timer)
        DestroyTimer(flush_timer)
    end

    for func in pairs(W3CEvents.track_callbacks) do
        W3CEvents.track_callbacks[func] = nil
    end

    game_ended = true
end

--- Registers the shared/default schema used to populate common event fields.
--- This schema must be named `shared`.
---
--- When shared schema support is enabled, schemas with `include_defaults ~= false`
--- are decoded and packed with these shared fields prepended.
---@param schema Schema Shared schema to register.
---@param setter function Function used to set values on events for the shared schema
function W3CEvents.register_shared_schema(schema, setter)
    if schema.name:lower() ~= EVENTS.SHARED:lower() then
        error("Shared schemas need to have the name '" .. EVENTS.SHARED:lower() .. "'")
    end

    if type(setter) ~= "function" then
        error("Setter needs to be a function")
    end

    W3CData:register_schema(schema)
    W3CEvents.set_shared_event_data = setter
end

--- Configures which active player ids send event packets. Multiple senders each
--- send the full event stream. Vacancies are filled deterministically when a
--- sender leaves.
---@param player_ids integer|integer[]
function W3CEvents.set_sending_players(player_ids)
    W3CEvents.requested_sender_count = math.max(requested_sender_count(player_ids), 1)
    local normalized = normalize_sender_ids(player_ids)
    W3CEvents.sending_player_ids = normalized
    fill_sender_vacancies()
end

--- Initializes `W3CEvents` and its underlying `W3CData` instance.
---
--- This must be called before registering schemas, emitting events, or starting
--- trackers. Initialization is idempotent until `end_game()` is called.
---@param config? W3CEventsConfig
function W3CEvents.initialize(config)
    if initialized then
        return
    end

    if game_ended then
        error("Game has ended, cannot initialize again.")
    end

    W3CEvents.config = merge_config(W3CEvents.config, config)

    W3CData.init({
        shared_schema = {
            enabled = W3CEvents.config.shared_schema.enabled,
        },
    })

    if W3CEvents.config.shared_schema.enabled then
        W3CEvents.register_shared_schema(shared_schema, add_shared_schema_data)
    end

    if W3CEvents.config.checksum.enabled then
        checksum = W3CChecksum.new()

        W3CEvents.config.checksum.get_checksum = W3CEvents.config.checksum.get_checksum or get_checksum
        W3CEvents.config.checksum.event_interval = W3CEvents.config.checksum.event_interval or CHECKSUM_EVENT_INTERVAL
    end

    W3CData:register_schema(game_end_schema)

    fill_sender_vacancies()
    setup_sender_leave_trigger()
    setup_timers()
    initialized = true
end

--- Registers a timer-driven event source.
---
--- The getter may return:
--- - `nil` to emit nothing
--- - a single keyed payload table for one event
--- - an array of keyed payload tables to emit multiple events on the same tick
---
--- Returned events are still buffered and flushed according to the normal flush rules.
---@param name string Name of the event schema to emit
---@param getter function Getter function that provides event payload data
---@param tick_interval integer How frequently to sample the getter, in ticks. Each tick is 5 seconds by default
---@return function stop_function Function that stops the tracker. Already-buffered events remain queued.
function W3CEvents.track(name, getter, tick_interval)
    if not initialized then
        error(ERRORS.NOT_INIT_ERROR)
    end

    if not schemas_registered then
        error(ERRORS.SCHEMA_REGISTERED_ERROR)
    end

    if game_ended or ending_game then
        error(ERRORS.GAME_ENDED_ERROR)
    end

    if W3CEvents.track_callbacks[name] ~= nil then
       error("W3CEvents.track already contains an event [" .. name .. "]")
    end

    local key = name
    W3CEvents.track_callbacks[key] = { event = name, func = getter, tick_interval = tick_interval }
    debug_log("tracking " .. tostring(name) .. " every " .. tostring(tick_interval) .. " ticks")
    return function()
        W3CEvents.track_callbacks[key] = nil
    end
end

--- Queues a single event payload for later flush.
---
--- The event must match a registered schema. If shared schema defaults are enabled,
--- missing shared fields such as `player` and `time` are populated automatically.
--- The event is added to the checksum stream immediately, even if the payload itself
--- has not yet been flushed.
---@param name string Name of the event schema to emit
---@param event Event Keyed payload table matching the registered schema
function W3CEvents.event(name, event)
    if not initialized then
        error(ERRORS.NOT_INIT_ERROR)
    end

    if not schemas_registered then
        error(ERRORS.SCHEMA_REGISTERED_ERROR)
    end

    if game_ended or ending_game then
        error(ERRORS.GAME_ENDED_ERROR)
    end

    if not W3CData:has_schema(name) then
        error("Schema [" .. name .. "] is not registered but an event is being created.")
    end

    if W3CData:should_include_defaults(name) and W3CEvents.set_shared_event_data then
        W3CEvents.set_shared_event_data(event)
    end

    add_sequence_data(name, event)

    local schema = W3CData:get_schema(name)
    local payload = ordered_payload(schema, event)

    update_checksum_for_event(name, payload)
    event_buffer_size = event_buffer_size + estimate_event_size(name, event)

    table.insert(W3CEvents.event_buffer, { schema_name = name, payload = payload })
    event_sequence = event_sequence + 1
    events_since_checksum = events_since_checksum + 1
    debug_log(
        "queued event "
        .. tostring(name)
        .. "; buffer="
        .. tostring(#W3CEvents.event_buffer)
        .. "; bytes~"
        .. tostring(event_buffer_size)
    )

end

--- Emits one `W3CGameEnd` event per player result, flushes the final buffered
--- payloads over the normal paced sender path, sends a trailing checksum, shuts
--- the library down, and then invokes the optional callback.
---@param player_results W3CEventsGameEnd
---@param on_game_end? function
function W3CEvents.end_game(player_results, on_game_end)
    debug_log("Ending game")
    if not initialized then
        error(ERRORS.NOT_INIT_ERROR)
    end

    if not schemas_registered then
        error(ERRORS.SCHEMA_REGISTERED_ERROR)
    end

    if game_ended or ending_game then
        return
    end

    for _, player_result in ipairs(player_results) do
        W3CEvents.event(
            EVENTS.GAME_END,
            {
                time = now(),
                player = player_result.player,
                sequence = event_sequence + 1,
                player_won = player_result.won,
            }
        )
    end

    ending_game = true
    debug_log("Flushing events")
    flush(function()
        debug_log("Sending checksum")
        send_checksum(true)
        debug_log("Shutting down")
        shutdown()
        if type(on_game_end) == "function" then
            on_game_end()
        end
    end, true)
end

--- Returns the number of whole seconds elapsed since the game started, using the
--- same monotonic clock that populates the `time` field on all events.
---@return integer
function W3CEvents.now()
    return now()
end

--- Registers all event schemas and sends the schema registry payloads over a short paced window.
--- This can only be called once per game.
---@param schemas Schema[]
function W3CEvents.register_all_schemas(schemas)
    if not initialized then
        error(ERRORS.NOT_INIT_ERROR)
    end

    if schemas_registered then
        error("Schemas have already been registered. Schemas can only be registered once.")
    end

    if game_ended or ending_game then
        error(ERRORS.GAME_ENDED_ERROR)
    end

    W3CData:register_all_schemas(schemas)

    local payloads = W3CData:generate_registry_payloads()

    schema_registry_sending = true
    schemas_registered = true
    send_payloads_paced(payloads, function()
        schema_registry_sending = false
        flush()
    end)
    debug_log("registered schemas; sent " .. tostring(#payloads) .. " schema payload(s)")
end

return W3CEvents
