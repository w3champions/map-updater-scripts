local W3CData = require("src.lua.w3cdata")
local W3CChecksum = require("src.lua.w3cChecksum")

local MAX_PAYLOAD_SIZE_BYTES = 180
local CHECKSUM_INTERVAL_SECS = 30
local PLAYER_INDEX_TO_FLUSH = 0

-- This needs to be "WC" for W3Champions to be able to automatically parse events.
-- Prefixes larger than 2 characters may cayse latency issues. See below post, although it's specific to the other
-- Sync<>, it would make sense that it works the same way for SyncData.
-- https://www.hiveworkshop.com/pastebin/1ce4fe042832e6bd7d06697a43055373.5801
local SYNC_DATA_PREFIX = "WC"

---@alias Event PayloadValue

---@class ChecksumConfig
---@field enabled boolean
---@field update_checksum? function
---@field get_checksum? function
---@field interval? integer

---@class EventBaseSchemaConfig
---@field enabled boolean
---@field set_base_event_data? function

---@class BooleanConfig
---@field enabled boolean

---@class W3CEventsConfig
---@field checksum ChecksumConfig
---@field base_schema EventBaseSchemaConfig
---@field logging BooleanConfig

---@class W3CEvents
---@field event_buffer table<Payload>
---@field trackers table<timer>
---@field config W3CEventsConfig
local W3CEvents = {
	event_buffer = {},
	trackers = {},
	config = {
		checksum = { enabled = true },
		base_schema = { enabled = true },
		logging = { enabled = false },
	},
}

local event_buffer_size = 0

---@type W3CChecksum
local checksum = nil

---@type Schema
local base_schema = {
	version = 1,
	name = "base",
	fields = {
		{ name = "player", bits = 5 }, -- Up to 32 player ids
		{ name = "time", bits = 13 }, -- Up to ~2 hours 16 minutes
	},
}

---Flushes the current `W3CEvents.event_buffer`, sending all events to `BlzSendSyncData` using the configured `W3CEvents.config.prefix`
---Events are only sent by a single player.
local function flush()
	-- Only want to send events from the first player to avoid spam. Checksums are used to detect if there's any
	-- manipulation of event data being sent.
	if GetLocalPlayer() == Player(PLAYER_INDEX_TO_FLUSH) then
		local payloads = W3CData:encode_payload(W3CEvents.event_buffer, MAX_PAYLOAD_SIZE_BYTES)
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
			end
		end)
	end

	W3CEvents.event_buffer = {}
end

-- Monotonic clock to get time since game started
---@type timer
local clock = nil

---@type timer
local checksum_clock = nil

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
		if field.type ~= "string" then
			event_size_bits = event_size_bits + field.bits
		else
			local string_value = event[field.name]
			event_size_bytes = event_buffer_size + #string_value
		end
	end

	event_size_bytes = event_size_bytes + (math.ceil(event_size_bits / 8))
	return event_size_bytes
end

--- Used to set base schema fields on events. Done like this to allow it to
--- be overridden in `W3CEvents.config.base_schema`
---@param event Event
local function add_base_schema_data(event)
	event["time"] = now()
	event["player"] = GetPlayerId(GetLocalPlayer())
end

---Sends a checksum payload using configured function to get the checksum value.
local function send_checksum()
	if W3CEvents.config.checksum.enabled then
		local checksum_value = W3CEvents.config.checksum.get_checksum()
		local payload = W3CData:generate_checksum_payload(checksum_value)
		BlzSendSyncData(SYNC_DATA_PREFIX, payload)
	end
end

--- Set and Update checksum functions used for checksum payloads. Done like this
--- to allow them to be overridden in `W3CEvents.config.checksum`
local function get_checksum()
	return checksum:finalize()
end

local function update_checksum(payload)
	W3CChecksum:update(payload)
end

---Setup monotonic clock to get game time and checksum clock to send checksum packets
---on a set interval
local function setup_timers()
	if not clock then
		clock = CreateTimer()
		TimerStart(clock, 1e9, false, nil)
	end

	if not checksum_clock and W3CEvents.config.checksum.enabled then
		checksum_clock = CreateTimer()
		TimerStart(checksum_clock, W3CEvents.config.checksum.interval, true, send_checksum)
	end
end

---Registers a base schema that will be included in all other events, if those events
---also have `use_base` enabled and `W3CEvents.config.base_schema.enabled = true`
---@param schema Schema Base schema to register.
---@param setter function Function used to set values on events for the base schema
function W3CEvents:register_base_schema(schema, setter)
	if schema.name:lower() ~= "base" then
		error("Base schemas need to have the name 'base'")
	end

	if type(setter) ~= "function" then
		error("Setter needs to be a function")
	end

	W3CData:register_schema(schema)
	self.set_base_event_data = setter
end

---Initializes W3CEvents. Call this before anything else.
---@param config W3CEventsConfig
function W3CEvents.init(config)
	W3CData.init()

	W3CEvents.config = config or W3CEvents.config

	if W3CEvents.config.base_schema.enabled then
		W3CEvents:register_base_schema(base_schema, add_base_schema_data)
	end

	if W3CEvents.config.checksum.enabled then
		checksum = W3CChecksum.new()

		W3CEvents.config.checksum.update_checksum = W3CEvents.config.checksum.update_checksum or update_checksum
		W3CEvents.config.checksum.get_checksum = W3CEvents.config.checksum.get_checksum or get_checksum
		W3CEvents.config.checksum.interval = W3CEvents.config.checksum.interval or CHECKSUM_INTERVAL_SECS
	end

	setup_timers()
end

---Creates events for `name` on a set interval, calling the `getter` to get the value used for the event.
---@param name string Name of the event. Must match the name of a schema that has been registered with `W3CEvents.register`
---@param getter function Getter function that provides the event data
---@param interval integer How frequently to create this event
---@return function stop_function Function that can be called to stop and clean up the tracking event. All events that were created
---before calling this function will still be created and sent.
function W3CEvents:track(name, getter, interval)
	local timer = CreateTimer()
	self.trackers[timer] = true

	TimerStart(timer, interval, true, function()
		local val = nil
		if type(getter) == "function" then
			val = getter()
		else
			return
		end
		self:event(name, val)
	end)

	return function()
		if not self.trackers[timer] then
			return
		end
		PauseTimer(timer)
		DestroyTimer(timer)
		self.trackers[timer] = nil
	end
end

---@param name string Name of the event. Must match the name of a schema that has been registered with `W3CEvents.register`
---@param event Event Event to create and send. Fields and their values must match the fields configured in the matching schema
function W3CEvents:event(name, event)
	if not W3CData:has_schema(name) then
		error("Schema [" .. name .. "] is not registered but an event is being created.")
	end

	if W3CData:should_use_base(name) and self.set_base_event_data then
		self.set_base_event_data(event)
	end

	-- Updates checksum with raw event data, not packed, as it doesn't really matter which we use and
	-- this avoids having to pack every event just to update the checksum
	checksum:update(table.concat(event))

	local size_estimate = estimate_event_size(name, event)
	if event_buffer_size + size_estimate > MAX_PAYLOAD_SIZE_BYTES then
		flush()
	else
		event_buffer_size = event_buffer_size + size_estimate
	end

	table.insert(self.event_buffer, { name, event })
end

---Register a schema to use when create events. A schema must be registered before creating events or errors will occur
---when attempting to call `W3CEvents.event` or `W3CEvents.track`
---@param schema Schema Schema to register.
function W3CEvents:register(schema)
	W3CData:register_schema(schema)
end

return W3CEvents
