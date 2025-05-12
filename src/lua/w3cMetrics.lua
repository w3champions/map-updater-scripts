local debugUtils = require("lua/debugUtils")
local ingameConsole = require("lua/ingameConsole")
require("lua/libDeflate")
require("lua/syncedTable")
LibDeflate.InitCompressor()

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
w3cMetrics.byteBudget = 150
w3cMetrics.flushInterval = 2.0
w3cMetrics.events = {}
w3cMetrics.trackers = {}
w3cMetrics.flushTimer = nil

---@class Event
---@field name string The name of the event
---@field value table The value of the event.
---@field time integer The time of the event. This is set automatically when using w3cMetrics.event()
local Event = {}


local function now() return math.floor(TimerGetElapsed(w3cMetrics.clock)) end

local function eventPayloadString(event)
    local result = "{"

    for k, v in pairs(event) do
        if type(v) == "table" then 
            result = result .. "\"" .. k .. "\": " .. eventPayloadString(v) .. ","
        elseif type(v) ~= "function" then
            result = result .. "\"" .. k .. "\": \"" .. v .. "\","
        end
    end

    result = result .. "}"
    return result
end

--- Encodes Event data so that it can be sent using SyncData.
--- 
--- Each individual event is formatted to a string `time|name|value` and then deflate compressed and base64 encoded
--- using the LibDeflate library.
--- 
--- If the total number of events results in there being more than w3cMetrics.byteBudget bytes required to send the data, it is
--- split up in to multiple parts that can be sent.
---@param events table<Event> Events to encode
---@return table<string> parts Table containing encoded events to be sent with SyncData. 
---@see Event
local function encodePayload(events)
    --print("encoding events")
    if #events == 0 then return {} end

    local events = SyncedTable.create(events)

    local parts = {}
    local current, currentLength = {}, 0

    for i, e in ipairs(events) do
        print("pre encoding event payload: " .. eventPayloadString(e.value))
        print("time: " .. e.time)
        local event = string.format("%d|%s|%s", e.time, e.name, eventPayloadString(e.value))
        --print("encoding event " .. event)
        local compressed = LibDeflate.CompressDeflate(event)
        local encoded = Base64.encode(compressed)
        local len = #encoded

        --print("encoded to " .. encoded)

        if currentLength + len > w3cMetrics.byteBudget then
            parts[#parts + 1] = table.concat(current)
            current, currentLength = {}, 0
        end
        current[#current + 1] = encoded
        currentLength = currentLength + len
    end

    if currentLength > 0 then
        parts[#parts + 1] = table.concat(current)
    end

    return parts
end

--- Sends data using BlzSendSyncData and the configured prefix 
---@param tag string The 2 character prefix to indentify SyncData as being events
---@param payload string The compressed and encoded events to send.
local function send(tag, payload)
    if GetLocalPlayer() == Player(0) then
        BlzSendSyncData(tag, payload)
    end
end

---Flushes the currently pending events and sends them with SyncData.
---@return boolean success Returns true if data was sent, false if there were no events to send.
function w3cMetrics.flush()
    --print("flush called")
    if #w3cMetrics.events == 0 then return false end

    --print("encoding events")
    local eventPayloads = encodePayload(w3cMetrics.events)
    --print("encoded events: " .. tostring(eventPayloads))
    if eventPayloads then
        for _, payload in ipairs(eventPayloads) do 
            print("sending " .. w3cMetrics.prefix .. " with payload " .. tostring(payload))
            send(w3cMetrics.prefix, payload) 

            end
    end

    w3cMetrics.events = {}

    return true
end



--- Timer that will flush metrics periodically on the w3cMetrics.flushInterval
local function ensureAutoTimer()
    if w3cMetrics.flushTimer or w3cMetrics.flushInterval <= 0 then return end
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
    if type(opts) == "string" then opts = { prefix = opts } end
    opts = opts or {}

    --print("Init called")

    w3cMetrics.prefix = opts.prefix or w3cMetrics.prefix
    w3cMetrics.byteBudget = opts.byteBudget or w3cMetrics.byteBudget
    w3cMetrics.flushInterval = opts.flushInterval or w3cMetrics.flushInterval

    ensureAutoTimer()
    --print("calling flush manually")
    --w3cMetrics.flush()
end

--- Create an event.
---@param name string Name of the event.
---@param value string | number | table Value for the event
function w3cMetrics.event(name, value)
   w3cMetrics.events[#w3cMetrics.events + 1] = { time = now(), name = name, value = value }
   if #w3cMetrics.events >= 64 then w3cMetrics.flush() end
end

--- Create an event that will be sent on a timer
---@param name string Name of the event
---@param getter function Function used to get the value for the event.
---@param interval number Interval for how often to send this event data
---@return function stopFunction Function that can be called to stop sending the configured event.
function w3cMetrics.track(name, getter, interval)
    --print("Track called")
    interval = interval or 5.0
    local timer = CreateTimer()
    w3cMetrics.trackers[timer] = true
    TimerStart(timer, interval, true, function()
        --print("Getting value for " .. name)
        local val = nil
        if type(getter) == "function" then val = getter() else return end
        --print("emitting event for " .. name .. " with value " .. val)
        w3cMetrics.event(name, val)
    end)

    return function()
        if not w3cMetrics.trackers[timer] then return end
        PauseTimer(timer)
        DestroyTimer(timer)
        w3cMetrics.trackers[timer] = nil
    end
end

return w3cMetrics
