package.path = table.concat({
	"./?.lua",
	"./src/?.lua",
	package.path,
}, ";")

local sent_sync_packets = {}
local current_player_id = 1
local created_timers = {}
local created_triggers = {}
local player_slot_states = {}
local player_controllers = {}
local observer_players = {}

bj_MAX_PLAYERS = 6
PLAYER_SLOT_STATE_PLAYING = "playing"
PLAYER_SLOT_STATE_LEFT = "left"
MAP_CONTROL_USER = "user"
MAP_CONTROL_COMPUTER = "computer"

for i = 0, bj_MAX_PLAYERS - 1 do
	player_slot_states[i] = PLAYER_SLOT_STATE_LEFT
	player_controllers[i] = MAP_CONTROL_USER
	observer_players[i] = false
end
player_slot_states[1] = PLAYER_SLOT_STATE_PLAYING
player_slot_states[2] = PLAYER_SLOT_STATE_PLAYING
player_slot_states[3] = PLAYER_SLOT_STATE_PLAYING
player_slot_states[4] = PLAYER_SLOT_STATE_PLAYING

function Player(id)
	return { id = id }
end

function GetLocalPlayer()
	return Player(current_player_id)
end

function GetPlayerId(player)
	return player.id
end

function GetPlayerSlotState(player)
	return player_slot_states[player.id]
end

function GetPlayerController(player)
	return player_controllers[player.id]
end

function IsPlayerObserver(player)
	return observer_players[player.id]
end

function BlzSendSyncData(prefix, payload)
	sent_sync_packets[#sent_sync_packets + 1] = { prefix = prefix, payload = payload }
end

function CreateTimer()
	local timer = { elapsed = 0, paused = false, destroyed = false }
	created_timers[#created_timers + 1] = timer
	return timer
end

function TimerStart(timer, timeout, periodic, callback)
	timer.timeout = timeout
	timer.periodic = periodic
	timer.callback = callback
	timer.paused = false
end

function TimerGetElapsed(timer)
	return timer.elapsed or 0
end

function PauseTimer(timer)
	timer.paused = true
end

function DestroyTimer(timer)
	timer.destroyed = true
end

function CreateTrigger()
	local trigger = { actions = {}, leave_players = {} }
	created_triggers[#created_triggers + 1] = trigger
	return trigger
end

function TriggerRegisterPlayerEventLeave(trigger, player)
	trigger.leave_players[#trigger.leave_players + 1] = player.id
end

function TriggerAddAction(trigger, action)
	trigger.actions[#trigger.actions + 1] = action
end

local bootstrap = require("lua.test_bootstrap")
local W3CChecksum = bootstrap.W3CChecksum
local W3CData = bootstrap.W3CData
local W3CEvents = bootstrap.W3CEvents

local function active_timer_by_timeout(timeout)
	for _, timer in ipairs(created_timers) do
		if timer.timeout == timeout and not timer.destroyed then
			return timer
		end
	end
	return nil
end

local function tick_timer(timer, ticks)
	for _ = 1, ticks do
		assert(timer and timer.callback, "timer callback is required")
		timer.callback()
	end
end

local function drain_paced_timers()
	local progressed = true
	while progressed do
		progressed = false
		for _, timer in ipairs(created_timers) do
			if timer.timeout == 0.1 and not timer.destroyed and timer.callback then
				timer.callback()
				progressed = true
			end
		end
	end
end

local function packet_payloads(start_index)
	local payloads = {}
	for index = start_index or 1, #sent_sync_packets do
		payloads[#payloads + 1] = sent_sync_packets[index].payload
	end
	return payloads
end

local function parse_packet_events(start_index)
	return W3CData:parse_unpacked(W3CData:decode_payloads(packet_payloads(start_index)))
end

local function payload_header(payload)
	return W3CData.cobs_decode(payload):byte(1)
end

local function framed_event(schema_name, payload)
	local schema_id = W3CData:get_schema_id(schema_name)
	local packed = W3CData:pack_bits(schema_id, payload)
	return string.pack(">I2I2", schema_id, #packed) .. packed
end

local function checksum_for(events)
	local crc = W3CChecksum.new()
	for _, event in ipairs(events) do
		crc:update(framed_event(event.schema_name, event.payload))
	end
	return crc:finalize()
end

local function assert_equal(actual, expected, label)
	assert(actual == expected, label .. ": expected [" .. tostring(expected) .. "] got [" .. tostring(actual) .. "]")
end

local function assert_not_equal(actual, expected, label)
	assert(actual ~= expected, label .. ": values should differ")
end

local function assert_error(func, label)
	local ok = pcall(func)
	assert(not ok, label .. ": expected error")
end

local function unique_string(seed)
	local chars = {}
	for index = 1, 120 do
		local code = 33 + ((seed * 17 + index * 13) % 90)
		chars[#chars + 1] = string.char(code)
	end
	return table.concat(chars)
end

local function test_w3c_events()
	print("------")
	print("Testing W3CEvents timer flushing and final flush")

	W3CEvents.initialize({
		checksum = { enabled = true, event_interval = 99 },
		shared_schema = { enabled = true },
		flush = { interval_seconds = 15, packet_spacing_seconds = 0.1 },
	})

	assert_equal(W3CEvents.sending_player_ids[1], 1, "default sender should be first active user player")
	assert_equal(active_timer_by_timeout(15).periodic, true, "flush timer should be periodic")

	local registered_schemas = {
		W3CEvents.schema("SchemaA", {
			W3CEvents.byteField("value"),
		}),
		W3CEvents.schema("SchemaB", {
			W3CEvents.byteField("value"),
		}),
		W3CEvents.schema("Pair", {
			W3CEvents.byteField("left"),
			W3CEvents.byteField("right"),
		}),
		W3CEvents.schema("Large", {
			W3CEvents.stringField("value"),
		}),
		W3CEvents.schema("NoDefaults", {
			W3CEvents.byteField("player"),
			W3CEvents.intField("sequence"),
			W3CEvents.stringField("value"),
		}, { include_defaults = false }),
	}

	for index = 1, 160 do
		registered_schemas[#registered_schemas + 1] = W3CEvents.schema("ExtraSchema" .. tostring(index), {
			W3CEvents.stringField("repeatedFieldName"),
			W3CEvents.intField("repeatedTypeId"),
			W3CEvents.floatField("repeatedX"),
			W3CEvents.floatField("repeatedY"),
		})
	end

	W3CEvents.register_all_schemas(registered_schemas)
	local packets_after_register = #sent_sync_packets
	W3CEvents.event("SchemaA", { player = 1, value = 4 })
	tick_timer(active_timer_by_timeout(15), 1)
	assert_equal(#sent_sync_packets, packets_after_register, "event flush should wait for schema registry packets")
	tick_timer(active_timer_by_timeout(0.1), 1)
	tick_timer(active_timer_by_timeout(15), 1)
	assert_equal(payload_header(sent_sync_packets[#sent_sync_packets].payload), 0x80, "only schema registry chunk should send before registry completes")
	drain_paced_timers()

	local packets_after_registry = #sent_sync_packets
	local startup_events = parse_packet_events(packets_after_register + 1)
	local startup_schema_a = nil
	for _, event in ipairs(startup_events) do
		if event[1] == "SchemaA" then
			startup_schema_a = event
		end
	end
	assert(startup_schema_a ~= nil, "buffered startup event should send after schema registry")
	assert_equal(startup_schema_a[2].sequence, 1, "buffered startup event should keep first sequence")

	W3CEvents.event("SchemaA", { player = 1, value = 5 })
	W3CEvents.event("SchemaB", { player = 1, value = 5 })
	assert_equal(#sent_sync_packets, packets_after_registry, "events should not flush by count")

	local flush_timer = active_timer_by_timeout(15)
	tick_timer(flush_timer, 1)
	assert_equal(#sent_sync_packets, packets_after_registry, "flush timer should pace packets instead of sending immediately")
	drain_paced_timers()
	assert_equal(#sent_sync_packets, packets_after_registry + 1, "flush timer should send buffered events")

	local first_flush_events = parse_packet_events(packets_after_registry + 1)
	assert_equal(first_flush_events[1][2].player, 1, "first event should use payload player")
	assert_equal(first_flush_events[1][2].sequence, 2, "first flushed event should have the lowest sequence")
	assert_equal(first_flush_events[2][2].sequence, 3, "second flushed event should have the next sequence")
	assert_equal(
		W3CEvents.config.checksum.get_checksum(),
		checksum_for({
			{ schema_name = "SchemaA", payload = { 1, 0, 1, 4 } },
			{ schema_name = "SchemaA", payload = { 1, 0, 2, 5 } },
			{ schema_name = "SchemaB", payload = { 1, 0, 3, 5 } },
		}),
		"Checksum should use framed packed bytes"
	)

	assert_error(function()
		W3CEvents.event("SchemaA", { value = 5 })
	end, "event should require payload player when shared schema contains player")

	local stop_track = W3CEvents.track("SchemaA", function()
		return {
			{ player = 1, value = 9 },
			{ player = 2, value = 10 },
		}
	end, 1)
	local tracker_timer = active_timer_by_timeout(5)
	local packets_before_tracker = #sent_sync_packets
	tick_timer(tracker_timer, 1)
	tick_timer(flush_timer, 1)
	drain_paced_timers()
	assert_equal(#sent_sync_packets, packets_before_tracker + 1, "tracker event should flush on periodic timer")
	local tracker_flush_events = parse_packet_events(packets_before_tracker + 1)
	assert_equal(tracker_flush_events[1][2].player, 1, "tracker should emit the first payload player")
	assert_equal(tracker_flush_events[1][2].sequence, 4, "tracker flush should preserve sequence for first payload")
	assert_equal(tracker_flush_events[2][2].player, 2, "tracker should emit the second payload player")
	assert_equal(tracker_flush_events[2][2].sequence, 5, "tracker flush should preserve sequence for second payload")
	stop_track()

	local stop_empty_track = W3CEvents.track("SchemaA", function()
		return {}
	end, 1)
	local stop_later_track = W3CEvents.track("SchemaB", function()
		return { player = 1, value = 11 }
	end, 1)
	local original_pairs = pairs
	pairs = function(table_value)
		if table_value == W3CEvents.track_callbacks then
			local keys = { "SchemaA", "SchemaB" }
			local index = 0
			return function()
				index = index + 1
				local key = keys[index]
				if key then
					return key, table_value[key]
				end
			end
		end

		return original_pairs(table_value)
	end

	local packets_before_empty_tracker = #sent_sync_packets
	tick_timer(tracker_timer, 1)
	pairs = original_pairs
	tick_timer(flush_timer, 1)
	drain_paced_timers()
	local empty_tracker_events = parse_packet_events(packets_before_empty_tracker + 1)
	assert_equal(empty_tracker_events[1][1], "SchemaB", "empty tracker should not abort later tracker")
	assert_equal(empty_tracker_events[1][2].sequence, 6, "later tracker should emit after an empty tracker")
	stop_empty_track()
	stop_later_track()

	local packets_before_no_defaults = #sent_sync_packets
	W3CEvents.event("NoDefaults", { player = 1, value = "details" })
	tick_timer(flush_timer, 1)
	drain_paced_timers()
	local no_defaults_events = parse_packet_events(packets_before_no_defaults + 1)
	assert_equal(no_defaults_events[1][2].sequence, 7, "non-default gameplay events should still receive sequence")

	local packets_before_periodic_checksum = #sent_sync_packets
	W3CEvents.config.checksum.event_interval = 1
	W3CEvents.event("SchemaA", { player = 1, value = 12 })
	tick_timer(flush_timer, 1)
	drain_paced_timers()
	assert_equal(#sent_sync_packets, packets_before_periodic_checksum + 2, "flush should send periodic checksum after event payload")
	assert_equal(payload_header(sent_sync_packets[packets_before_periodic_checksum + 1].payload), 0x01, "periodic checksum should follow the event packet")
	assert_equal(payload_header(sent_sync_packets[packets_before_periodic_checksum + 2].payload), 0x02, "periodic checksum should use checksum payload header")
	local periodic_checksum = W3CData:decode_payloads({ sent_sync_packets[packets_before_periodic_checksum + 2].payload })[1][1]
	assert_not_equal(periodic_checksum, "", "periodic checksum should be present")
	W3CEvents.config.checksum.event_interval = 99

	W3CEvents.set_sending_players({ 2, 1 })
	assert_equal(#W3CEvents.sending_player_ids, 2, "multiple senders should be configurable")
	assert_equal(W3CEvents.sending_player_ids[1], 1, "configured senders should be normalized deterministically")
	assert_equal(W3CEvents.sending_player_ids[2], 2, "configured senders should be normalized deterministically")
	player_slot_states[1] = PLAYER_SLOT_STATE_LEFT
	for _, action in ipairs(created_triggers[1].actions) do
		action()
	end
	assert_equal(W3CEvents.sending_player_ids[1], 2, "leaving sender should be removed")
	assert_equal(W3CEvents.sending_player_ids[2], 3, "sender vacancy should be filled deterministically")

	current_player_id = 2
	local packets_before_large_flush = #sent_sync_packets
	local large_values = {}
	for index = 1, 6 do
		local large_value = unique_string(index)
		large_values[#large_values + 1] = large_value
		W3CEvents.event("Large", { player = 2, value = large_value })
	end
	tick_timer(flush_timer, 1)
	drain_paced_timers()
	local large_flush_payloads = packet_payloads(packets_before_large_flush + 1)
	assert(#large_flush_payloads > 1, "large buffered flush should send multiple paced payload packets")
	assert_equal(#W3CData:decode_payloads(large_flush_payloads), 6, "multi-packet flush should deliver the full buffered batch")

	local packets_before_end_game = #sent_sync_packets
	current_player_id = 4
	local callback_called = false
	W3CEvents.end_game({
		{ player = 1, won = false },
		{ player = 2, won = true },
	}, function()
		callback_called = true
	end)
	assert_equal(callback_called, false, "end_game callback should wait for paced final flush")
	drain_paced_timers()
	assert_equal(callback_called, true, "end_game callback should run after final flush")
	assert_equal(#sent_sync_packets, packets_before_end_game + 2, "end_game should force final event packet and checksum from any player")

	local final_events = W3CData:decode_payloads({ sent_sync_packets[#sent_sync_packets - 1].payload })
	assert_equal(final_events[#final_events - 1][1], "W3CGameEnd", "end_game should flush game end events before checksum")
	assert_equal(final_events[#final_events][1], "W3CGameEnd", "end_game should flush all game end events before checksum")
	local final_checksum = W3CData:decode_payloads({ sent_sync_packets[#sent_sync_packets].payload })[1][1]
	assert_not_equal(final_checksum, "", "final checksum should be present")

	print("W3CEvents timer flush test passed")
end

test_w3c_events()
