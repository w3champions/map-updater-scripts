require("lua/debugUtils")
require("lua/ingameConsole")
require("lua/libDeflate")
require("lua/syncedTable")

require("lua/base64")

---@class W3Metrics
---@field prefix string Prefix used when sending events. Used to identify syncdata packets as events. Should be 2 characters at most otherwise will cause latency issues
---@field byteBudget integer Maximum number of bytes to send in a single SyncData packet. There's a hard limit of 255, but more than 180 will likely cause lag and desync issues. Defaults to 150.
---@field flushInterval number How frequently to flush events in seconds. Defaults to 2.0 seconds.
---@field events table<Event> Events to send on the next flush
---@field trackers table<timer> Timers for periodic events. Events will be added to w3cMetrics.events when the timer triggers. Use w3cMetrics.track()
---@field clock timer Clock used to get current time since initializing.
local w3cMetrics = {}

w3cMetrics.prefix = "WC"
w3cMetrics.byteBudget = 180
w3cMetrics.flushInterval = 5.0
w3cMetrics.events = {}
w3cMetrics.trackers = {}
w3cMetrics.flushTimer = nil

local version = 1

---@class private Event
---@field name string The name of the event
---@field value table The value of the event.
---@field time integer The time of the event. This is set automatically when using w3cMetrics.event()
local event = {}

---comment
---@return integer
local function now()
	return math.floor(TimerGetElapsed(w3cMetrics.clock))
end

--[[
---comment
---@param parent any
---@param event table
---@return string
local function eventPayloadString(event, parent)
    -- So we can use pairs and not cause desyncs, although it might not matter for our use
    local event = SyncedTable.create(event)
    local result = ""
    local count = 0
    for k, v in pairs(event) do
        local key = k
        if parent and parent ~= "value" then key = parent .. "." .. k end

        if type(v) == "table" then
            result = result .. "&" .. eventPayloadString(v, key)
        elseif type(v) ~= "function" and v ~= nil then
            result = result .. key .. "=" .. v
        end

        count = count + 1
        if count < #event then
            result = result .. "&"
        end
    end

    return result
end--]]

---comment
---@param event table
---@param parent string?
---@return string
local function eventPayloadString(event, parent)
	local tbl = SyncedTable.create(event)
	local kvpairs = {}

	for k, v in pairs(tbl) do
		local key = tostring(k)
		if parent and parent ~= "value" then
			key = parent .. "." .. key
		end

		if type(v) == "table" then
			local nested = eventPayloadString(v, key)
			if nested ~= "" then
				table.insert(kvpairs, nested)
			end
		elseif type(v) ~= "function" and v ~= nil then
			if type(v) == "string" then
				table.insert(kvpairs, key .. '="' .. v:gsub('"', '\\"') .. '"')
			else
				table.insert(kvpairs, key .. "=" .. tostring(v))
			end
		end
	end

	return table.concat(kvpairs, "&")
end

---comment
---@param event Event
---@return string
local function formatEvent(event)
	local payload = eventPayloadString(event.value)
	return string.format("%d|%s|%s", event.time, event.name, payload)
end

--- Encodes Event data so that it can be sent using SyncData.
---
--- Each individual event is formatted to a string `time|name|value` and then deflate compressed and base64 encoded
--- using the LibDeflate library.
---
--- If the total number of events results in there being more than w3cMetrics.byteBudget bytes required to send the data, it is
--- split up in to multiple parts that can be sent.
---@param events table<Event> Events to encode
---@return table<string> encoded Table with strings containing encoded events to be sent with SyncData.
---@see Event
local function encodePayload(events)
	if #events == 0 then
		return {}
	end

	local parts = {}
	local current, currentLength = {}, 0

	for i, event in ipairs(events) do
		local event = formatEvent(event)
		local len = #event

		if currentLength + len > w3cMetrics.byteBudget then
			local joined = table.concat(current, "\0") .. "\0"
			local compressed = LibDeflate.CompressDeflate(joined)
			parts[#parts + 1] = Base64.encode(compressed)
			current, currentLength = {}, 0
		end

		current[#current + 1] = event
		currentLength = currentLength + len
	end

	if currentLength > 0 then
		local joined = table.concat(current, "\0") .. "\0"
		local compressed = LibDeflate.CompressDeflate(joined)
		parts[#parts + 1] = Base64.encode(compressed)
	end

	return parts
end

--- Sends data using BlzSendSyncData and the configured prefix
---@param tag string The 2 character prefix to indentify SyncData as being events
---@param payload string The compressed and encoded events to send.
local function send(tag, payload)
	print("sending data")
	BlzSendSyncData(tag, payload)
end

local function sendConfig()
	local event = { time = now(), name = "Init", value = { prefix = w3cMetrics.prefix, version = version } }
	local stringEvent = formatEvent(event)
	local compressed = LibDeflate.CompressDeflate(stringEvent)
	local encoded = Base64.encode(compressed)
	BlzSendSyncData("WC", encoded)
end

---Flushes the currently pending events and sends them with SyncData.
---@return boolean success Returns true if data was sent, false if there were no events to send.
function w3cMetrics.flush()
	print("sending events")
	if #w3cMetrics.events == 0 then
		print("no events")
		return false
	end

	local eventPayloads = encodePayload(w3cMetrics.events)
	if eventPayloads then
		for _, payload in ipairs(eventPayloads) do
			send(w3cMetrics.prefix, payload)
		end
	end

	w3cMetrics.events = {}
	return true
end

--- Timer that will flush metrics periodically on the w3cMetrics.flushInterval
local function ensureAutoTimer()
	if w3cMetrics.flushTimer or w3cMetrics.flushInterval <= 0 then
		return
	end
	--print("Creating clock timer")

	-- Timer used to get monotonic time since started
	w3cMetrics.clock = CreateTimer()
	TimerStart(w3cMetrics.clock, 1e9, false, nil)

	--print("Creating flush timer with " .. w3cMetrics.flushInterval .. " timeout")
	w3cMetrics.flushTimer = CreateTimer()
	TimerStart(w3cMetrics.flushTimer, w3cMetrics.flushInterval, true, w3cMetrics.flush)
end

---Initialize W3CMetrics.
---@param opts string | table Prefix used to identify event data or table containing prefix, byteBudget and/or flushInterval values
function w3cMetrics.init(opts)
	LibDeflate.InitCompressor()
	if type(opts) == "string" then
		opts = { prefix = opts }
	end
	opts = opts or {}

	w3cMetrics.prefix = opts.prefix or w3cMetrics.prefix
	w3cMetrics.byteBudget = opts.byteBudget or w3cMetrics.byteBudget
	w3cMetrics.flushInterval = opts.flushInterval or w3cMetrics.flushInterval

	ensureAutoTimer()
	sendConfig()
end

--- Create an event.
---@param name string Name of the event.
---@param value string | number | table Value for the event
function w3cMetrics.event(name, value)
	-- Don't add empty events
	print("add event called with value: " .. tostring(value))
	if value ~= nil then
		print("adding event")
		w3cMetrics.events[#w3cMetrics.events + 1] = { time = now(), name = name, value = value }
	end
	--if #w3cMetrics.events >= 64 then w3cMetrics.flush() end
end

--- Create an event that will be sent on a timer
---@param name string Name of the event
---@param getter function Function used to get the value for the event.
---@param interval number Interval for how often to send this event data
---@return function stopFunction Function that can be called to stop sending the configured event.
function w3cMetrics.track(name, getter, interval)
	print("tracking called")
	interval = interval or 5.0
	local timer = CreateTimer()
	w3cMetrics.trackers[timer] = true

	TimerStart(timer, interval, true, function()
		local val = nil
		if type(getter) == "function" then
			val = getter()
		else
			return
		end
		w3cMetrics.event(name, val)
	end)

	return function()
		if not w3cMetrics.trackers[timer] then
			return
		end
		PauseTimer(timer)
		DestroyTimer(timer)
		w3cMetrics.trackers[timer] = nil
	end
end

return w3cMetrics
