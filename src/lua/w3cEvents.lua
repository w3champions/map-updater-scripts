--[[

`W3CEvents` provides a simple API for emitting structured game events.

Typical usage:

--------------------

W3CEvents.initialize()

W3CEvents:register_all_schemas({
  W3CEvents.schema("PlayerState", {
    W3CEvents.intField("gold"),
    W3CEvents.intField("wood"),
  }),
})

W3CEvents:event("PlayerState", {
  gold = 500,
  wood = 120,
})

----------------------

`player` and `time` are added automatically to all events.

--]]

local W3CData = require("lua.w3cdata")
local W3CChecksum = require("lua.w3cChecksum")

local MAX_PAYLOAD_SIZE_BYTES = 180
local CHECKSUM_INTERVAL_SECS = 30
local FLUSH_INTERVAL_SECS = 30
local PLAYER_INDEX_TO_FLUSH = 0

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
	SCHEMA_REGISTERED_ERROR = "W3CEvents.register_all_schemas has not been used. Registering schemas is required before creating any events",
}

---@alias Event table<string, string | number | boolean>

---@class ChecksumConfig
---@field enabled boolean
---@field get_checksum? function Optional override used to generate checksum payload values.
---@field interval? integer Interval in seconds for periodic checksum packets.

---@class EventSharedSchemaConfig
---@field enabled boolean
---@field set_shared_event_data? function Optional override used to populate shared schema fields.

---@class BooleanConfig
---@field enabled boolean

---@class FlushConfig
---@field interval? number

---@class W3CEventsConfig
---@field checksum ChecksumConfig
---@field shared_schema EventSharedSchemaConfig
---@field flush? FlushConfig
---@field logging BooleanConfig

---@class W3CEventsGameEndPlayer
---@field player integer
---@field won boolean

---@alias W3CEventsGameEnd table<W3CEventsGameEndPlayer>

---@class W3CEvents
---@field event_buffer table<Payload>
---@field trackers table<timer>
---@field config W3CEventsConfig
local W3CEvents = {
	event_buffer = {},
	trackers = {},
	config = {
		checksum = { enabled = true },
		shared_schema = { enabled = true },
		flush = { interval = FLUSH_INTERVAL_SECS },
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
local initialized = false
local schemas_registered = false

---@type W3CChecksum
local checksum = nil

---@type Schema
local shared_schema = {
	version = 1,
	name = EVENTS.SHARED,
	include_defaults = false,
	fields = {
		{ name = "player", field_type = "int", num_of_bits = 5 }, -- Up to 32 player ids
		{ name = "time",   field_type = "int", num_of_bits = 13 }, -- Up to ~2 hours 16 minutes
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
		{ name = "player",     field_type = "int",  num_of_bits = 5 },
		{ name = "time",       field_type = "int",  num_of_bits = 13 },
		{ name = "player_won", field_type = "bool" },
	},
}

local function debug_log(message)
	if W3CEvents.config.logging and W3CEvents.config.logging.enabled then
		print("[W3CEvents] " .. message)
	end
end

local function send_payloads(payloads, immediate)
	if immediate then
		for _, payload in ipairs(payloads) do
			BlzSendSyncData(SYNC_DATA_PREFIX, payload)
		end
		debug_log("sent " .. tostring(#payloads) .. " payload(s) immediately")
		return
	end

	local timer = CreateTimer()
	local index = 1

	-- Iterate through all payloads on a timer, sending every 0.2 seconds until
	-- all payloads are sent. To prevent us sending huge amounts of SyncData all at
	-- once causing latency issues
	-- 0.2 seconds results in sending a maximum of 1275 bytes/second, a little over 1kb, if
	-- all payloads use all 255 bytes possible
	-- WC3 has a max bandwidth of 4kb/s before having issues
	TimerStart(timer, 0.2, true, function()
		if index <= #payloads then
			local payload = payloads[index]
			index = index + 1
			BlzSendSyncData(SYNC_DATA_PREFIX, payload)
		else
			PauseTimer(timer)
			DestroyTimer(timer)
			debug_log("sent " .. tostring(#payloads) .. " payload(s) on timer")
		end
	end)
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

--- Flushes the current event buffer by encoding it with `W3CData` and sending the
--- resulting payload packets through `BlzSendSyncData`.
---
--- Normal event payloads are only emitted by the configured flush player
--- (`PLAYER_INDEX_TO_FLUSH`). Other players still update their local checksum state
--- and send checksum packets.
---@param immediate? boolean When true, send all payload packets immediately instead of spacing them over time
local function flush(immediate)
	-- Don't flush if we've disabled events. Disabled in `W3CEvents:end_game()`
	if game_ended or #W3CEvents.event_buffer == 0 then
		if not game_ended then
			debug_log("flush skipped: empty buffer")
		end
		return
	end

	-- Only want to send events from the first player to avoid spam. Checksums are used to detect if there's any
	-- manipulation of event data being sent.
	local local_player_id = GetPlayerId(GetLocalPlayer())

	local should_send = PLAYER_INDEX_TO_FLUSH == nil or local_player_id == PLAYER_INDEX_TO_FLUSH
	debug_log("flush send decision=" .. tostring(should_send))
	if should_send then
		debug_log("encoding event buffer")
		local ok, payloads = pcall(W3CData.encode_payload, W3CData, W3CEvents.event_buffer, MAX_PAYLOAD_SIZE_BYTES)
		if not ok then
			debug_log("encode failed: " .. tostring(payloads))
			return
		end
		debug_log("encoded " .. tostring(#payloads) .. " payload packet(s)")
		debug_payload_headers(payloads)
		send_payloads(payloads, immediate)
	else
		debug_log("flush skipped on local player " .. tostring(local_player_id))
	end

	W3CEvents.event_buffer = {}
	event_buffer_size = 0
end

-- Monotonic clock to get time since game started
---@type timer
local clock = nil

---@type timer
local checksum_clock = nil

---@type timer
local flush_clock = nil

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

--- Default shared-schema field setter. This populates `time` and `player` when those
--- fields exist on the registered shared schema and are not already present.
---@param event Event
local function add_shared_schema_data(event)
	local schema = W3CData:get_schema(EVENTS.SHARED)
	-- Only set the event fields if they actually exist on the shared schema
	-- as the shared schema can be changed
	for _, field in ipairs(schema.fields) do
		if field.name == "time" and event["time"] == nil then
			event["time"] = now()
		elseif field.name == "player" and event["player"] == nil then
			event["player"] = GetPlayerId(GetLocalPlayer())
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
local function send_checksum()
	if W3CEvents.config.checksum.enabled then
		local checksum_value = W3CEvents.config.checksum.get_checksum()
		local payload = W3CData:generate_checksum_payload(checksum_value)
		BlzSendSyncData(SYNC_DATA_PREFIX, payload)
	end
end

--- Default checksum getter used when no custom checksum getter is configured.
local function get_checksum()
	return checksum:finalize()
end

--- Creates and starts the timers used by this module:
--- the monotonic game clock, the periodic checksum timer, and the periodic flush timer.
local function setup_timers()
	if not clock then
		clock = CreateTimer()
		TimerStart(clock, 1e9, false, nil)
	end

	if not checksum_clock and W3CEvents.config.checksum.enabled then
		checksum_clock = CreateTimer()
		TimerStart(checksum_clock, W3CEvents.config.checksum.interval, true, send_checksum)
	end

	if not flush_clock and W3CEvents.config.flush and W3CEvents.config.flush.interval and W3CEvents.config.flush.interval > 0 then
		flush_clock = CreateTimer()
		TimerStart(flush_clock, W3CEvents.config.flush.interval, true, flush)
	end
end

--- Stops and destroys all timers managed by this module and prevents further events
--- from being accepted.
local function shutdown()
	if clock then
		PauseTimer(clock)
		DestroyTimer(clock)
	end

	if checksum_clock then
		PauseTimer(checksum_clock)
		DestroyTimer(checksum_clock)
	end

	if flush_clock then
		PauseTimer(flush_clock)
		DestroyTimer(flush_clock)
	end

	for timer in pairs(W3CEvents.trackers) do
		PauseTimer(timer)
		DestroyTimer(timer)
		W3CEvents.trackers[timer] = nil
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
function W3CEvents:register_shared_schema(schema, setter)
	if schema.name:lower() ~= EVENTS.SHARED:lower() then
		error("Shared schemas need to have the name '" .. EVENTS.SHARED:lower() .. "'")
	end

	if type(setter) ~= "function" then
		error("Setter needs to be a function")
	end

	W3CData:register_schema(schema)
	self.set_shared_event_data = setter
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
		W3CEvents:register_shared_schema(shared_schema, add_shared_schema_data)
	end

	if W3CEvents.config.checksum.enabled then
		checksum = W3CChecksum.new()

		W3CEvents.config.checksum.get_checksum = W3CEvents.config.checksum.get_checksum or get_checksum
		W3CEvents.config.checksum.interval = W3CEvents.config.checksum.interval or CHECKSUM_INTERVAL_SECS
	end

	W3CData:register_schema(game_end_schema)

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
---@param interval integer How frequently to sample the getter, in seconds
---@return function stop_function Function that stops the tracker. Already-buffered events remain queued.
function W3CEvents.track(self_or_name, maybe_name_or_getter, maybe_getter_or_interval, maybe_interval)
	local name = self_or_name
	local getter = maybe_name_or_getter
	local interval = maybe_getter_or_interval
	if self_or_name == W3CEvents then
		name = maybe_name_or_getter
		getter = maybe_getter_or_interval
		interval = maybe_interval
	end

	if not initialized then
		error(ERRORS.NOT_INIT_ERROR)
	end

	if not schemas_registered then
		error(ERRORS.SCHEMA_REGISTERED_ERROR)
	end

	if game_ended then
		error(ERRORS.GAME_ENDED_ERROR)
	end

	local timer = CreateTimer()
	W3CEvents.trackers[timer] = true
	debug_log("tracking " .. tostring(name) .. " every " .. tostring(interval) .. "s")

	TimerStart(timer, interval, true, function()
		local val = nil
		if type(getter) == "function" then
			val = getter()
		else
			return
		end

		if val == nil or (type(val) == "table" and next(val) == nil) then
			return
		elseif type(val) == "table" and type(val[1]) == "table" then
			for _, payload in ipairs(val) do
				W3CEvents.event(name, payload)
			end
		else
			W3CEvents.event(name, val)
		end
	end)

	return function()
		if not W3CEvents.trackers[timer] then
			return
		end
		PauseTimer(timer)
		DestroyTimer(timer)
		W3CEvents.trackers[timer] = nil
	end
end

--- Flushes the buffered event payloads, if any.
---@param immediate? boolean When true, send all payload packets immediately instead of staggering them on a timer
function W3CEvents.flush(self_or_immediate, maybe_immediate)
	local immediate = self_or_immediate
	if self_or_immediate == W3CEvents then
		immediate = maybe_immediate
	end

	flush(immediate)
end

--- Queues a single event payload for later flush.
---
--- The event must match a registered schema. If shared schema defaults are enabled,
--- missing shared fields such as `player` and `time` are populated automatically.
--- The event is added to the checksum stream immediately, even if the payload itself
--- has not yet been flushed.
---@param name string Name of the event schema to emit
---@param event Event Keyed payload table matching the registered schema
function W3CEvents.event(self_or_name, maybe_event, maybe_unused)
	local name = self_or_name
	local event = maybe_event
	if self_or_name == W3CEvents then
		name = maybe_event
		event = maybe_unused
	end

	if not initialized then
		error(ERRORS.NOT_INIT_ERROR)
	end

	if not schemas_registered then
		error(ERRORS.SCHEMA_REGISTERED_ERROR)
	end

	if game_ended then
		error(ERRORS.GAME_ENDED_ERROR)
	end

	if not W3CData:has_schema(name) then
		error("Schema [" .. name .. "] is not registered but an event is being created.")
	end

	if W3CData:should_include_defaults(name) and W3CEvents.set_shared_event_data then
		W3CEvents.set_shared_event_data(event)
	end

	local schema = W3CData:get_schema(name)
	local payload = ordered_payload(schema, event)

	update_checksum_for_event(name, payload)

	local size_estimate = estimate_event_size(name, event)
	if event_buffer_size + size_estimate > MAX_PAYLOAD_SIZE_BYTES then
		flush()
	end
	event_buffer_size = event_buffer_size + size_estimate

	table.insert(W3CEvents.event_buffer, { schema_name = name, payload = payload })
	debug_log("queued event " .. tostring(name) .. "; buffer=" .. tostring(#W3CEvents.event_buffer) .. "; bytes~" .. tostring(event_buffer_size))
end

--- Emits one `W3CGameEnd` event per player result, immediately flushes the final
--- buffered payloads, sends a trailing checksum, and shuts the library down.
---@param player_results W3CEventsGameEnd
function W3CEvents.end_game(self_or_player_results, maybe_player_results)
	local player_results = self_or_player_results
	if self_or_player_results == W3CEvents then
		player_results = maybe_player_results
	end

	if not initialized then
		error(ERRORS.NOT_INIT_ERROR)
	end

	if not schemas_registered then
		error(ERRORS.SCHEMA_REGISTERED_ERROR)
	end

	if game_ended then
		return
	end

	for _, player_result in ipairs(player_results) do
		W3CEvents.event(EVENTS.GAME_END, { time = now(), player = player_result.player, player_won = player_result.won })
	end

	flush(true)
	send_checksum()
	shutdown()
end

--- Registers all event schemas and sends the schema registry payloads immediately.
--- This can only be called once per game.
---@param schemas Schema[]
function W3CEvents.register_all_schemas(self_or_schemas, maybe_schemas)
	local schemas = self_or_schemas
	if self_or_schemas == W3CEvents then
		schemas = maybe_schemas
	end

	if not initialized then
		error(ERRORS.NOT_INIT_ERROR)
	end

	if schemas_registered then
		error("Schemas have already been registered. Schemas can only be registered once.")
	end

	if game_ended then
		error(ERRORS.GAME_ENDED_ERROR)
	end

	W3CData:register_all_schemas(schemas)

	local payloads = W3CData:generate_registry_payloads()
	for _, payload in ipairs(payloads) do
		BlzSendSyncData(SYNC_DATA_PREFIX, payload)
	end
	debug_log("registered schemas; sent " .. tostring(#payloads) .. " schema payload(s)")

	schemas_registered = true
end

return W3CEvents
