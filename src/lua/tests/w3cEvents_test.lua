package.path = table.concat({
	"./?.lua",
	"./src/?.lua",
	package.path,
}, ";")

local bootstrap = require("lua.test_bootstrap")
local W3CChecksum = bootstrap.W3CChecksum
local W3CData = bootstrap.W3CData

local sent_sync_packets = {}
local current_player_id = 0
local created_timers = {}

function Player(id)
	return { id = id }
end

function GetLocalPlayer()
	return Player(current_player_id)
end

function GetPlayerId(player)
	return player.id
end

function BlzSendSyncData(prefix, payload)
	sent_sync_packets[#sent_sync_packets + 1] = { prefix = prefix, payload = payload }
end

function CreateTimer()
	local timer = { elapsed = 0 }
	created_timers[#created_timers + 1] = timer
	return timer
end

function TimerStart(timer, timeout, periodic, callback)
	timer.timeout = timeout
	timer.periodic = periodic
	timer.callback = callback
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

local W3CEvents = bootstrap.W3CEvents

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

local function unique_string(seed)
	local chars = {}
	for index = 1, 120 do
		local code = 33 + ((seed * 17 + index * 13) % 90)
		chars[#chars + 1] = string.char(code)
	end
	return table.concat(chars)
end

local function test_checksum_framing()
	print("------")
	print("Testing W3CEvents buffered flushing")

	W3CEvents.initialize({
		checksum = { enabled = true, event_interval = 99 },
		shared_schema = { enabled = true },
		flush = { event_count = 2 },
	})

	W3CEvents:register_all_schemas({
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
	})

	local schema_a_payload = { 0, 0, 1, 5 }
	local schema_b_payload = { 0, 0, 2, 5 }
	local pair_payload_a = { 0, 0, 3, 1, 23 }
	local pair_payload_b = { 0, 0, 4, 12, 3 }

	assert_not_equal(
		framed_event("SchemaA", schema_a_payload),
		framed_event("SchemaB", schema_b_payload),
		"Framed bytes should include schema identity"
	)

	assert_not_equal(
		framed_event("Pair", pair_payload_a),
		framed_event("Pair", pair_payload_b),
		"Framed bytes should preserve field boundaries"
	)

	local packets_after_registry = #sent_sync_packets
	assert_equal(#sent_sync_packets, packets_after_registry, "schema registration should not emit event payloads")

	W3CEvents:event("SchemaA", { value = 5 })
	assert_equal(#sent_sync_packets, packets_after_registry, "single event should remain buffered before threshold")
	assert_equal(
		W3CEvents.config.checksum.get_checksum(),
		checksum_for({
			{ schema_name = "SchemaA", payload = schema_a_payload },
		}),
		"Single event checksum should use framed packed bytes"
	)

	W3CEvents:event("SchemaB", { value = 5 })
	assert_equal(#sent_sync_packets, packets_after_registry + 1, "reaching threshold should flush buffered events")
	local first_flush_events = parse_packet_events(packets_after_registry + 1)
	assert_equal(first_flush_events[1][2].sequence, 1, "first flushed event should have the lowest sequence")
	assert_equal(first_flush_events[2][2].sequence, 2, "second flushed event should have the next sequence")
	assert_equal(
		W3CEvents.config.checksum.get_checksum(),
		checksum_for({
			{ schema_name = "SchemaA", payload = schema_a_payload },
			{ schema_name = "SchemaB", payload = schema_b_payload },
		}),
		"Checksum should distinguish equal payloads under different schemas"
	)

	W3CEvents:event("Pair", { left = 1, right = 23 })
	assert_equal(
		W3CEvents.config.checksum.get_checksum(),
		checksum_for({
			{ schema_name = "SchemaA", payload = schema_a_payload },
			{ schema_name = "SchemaB", payload = schema_b_payload },
			{ schema_name = "Pair", payload = pair_payload_a },
		}),
		"Checksum should include field boundaries for the packed payload"
	)

	W3CEvents:event("Pair", { left = 12, right = 3 })
	assert_equal(#sent_sync_packets, packets_after_registry + 2, "second threshold flush should send the next buffered batch")
	assert_equal(
		W3CEvents.config.checksum.get_checksum(),
		checksum_for({
			{ schema_name = "SchemaA", payload = schema_a_payload },
			{ schema_name = "SchemaB", payload = schema_b_payload },
			{ schema_name = "Pair", payload = pair_payload_a },
			{ schema_name = "Pair", payload = pair_payload_b },
		}),
		"Checksum should change for payloads that only differed by previous string concatenation ambiguity"
	)

	assert(#sent_sync_packets > 0, "Schema registration should emit sync payloads")
	print("W3CEvents threshold flush test passed")

	W3CEvents.track("SchemaA", function()
		return { value = 9 }
	end, 1)
	local tracker_timer = created_timers[#created_timers]
	local packets_before_tracker = #sent_sync_packets
	tracker_timer.callback()
	assert_equal(#sent_sync_packets, packets_before_tracker, "tracker event should buffer until threshold")
	tracker_timer.callback()
	assert_equal(#sent_sync_packets, packets_before_tracker + 1, "tracker events should flush through the same buffer threshold")
	local tracker_flush_events = parse_packet_events(packets_before_tracker + 1)
	assert_equal(tracker_flush_events[1][2].sequence, 5, "tracker flush should preserve ascending sequence for the first event")
	assert_equal(tracker_flush_events[2][2].sequence, 6, "tracker flush should preserve ascending sequence for the second event")
	W3CEvents.track_callbacks["SchemaA"] = nil

	W3CEvents.config.flush.event_count = 6
	local packets_before_large_flush = #sent_sync_packets
	local large_values = {}
	for index = 1, 6 do
		local large_value = unique_string(index)
		large_values[#large_values + 1] = large_value
		W3CEvents:event("Large", { value = large_value })
	end
	local large_flush_payloads = packet_payloads(packets_before_large_flush + 1)
	assert(#large_flush_payloads > 1, "large buffered flush should send multiple payload packets")
	assert_equal(#W3CData:decode_payloads(large_flush_payloads), 6, "multi-packet flush should deliver the full buffered batch")
	local large_flush_events = parse_packet_events(packets_before_large_flush + 1)
	for index, event in ipairs(large_flush_events) do
		assert_equal(
			event[2].sequence,
			index + 6,
			"large flush should emit events in ascending sequence order"
		)
	end

	local packets_before_end_game = #sent_sync_packets
	local end_game_events = {
		{ player = 0, won = true },
		{ player = 1, won = false },
	}

	W3CEvents:end_game(end_game_events)

	assert_equal(#sent_sync_packets, packets_before_end_game + 2, "end_game should immediately send final events and checksum")

	local final_checksum = W3CData:decode_payloads({ sent_sync_packets[#sent_sync_packets].payload })[1][1]
	assert_equal(
		final_checksum,
		checksum_for({
			{ schema_name = "SchemaA", payload = schema_a_payload },
			{ schema_name = "SchemaB", payload = schema_b_payload },
			{ schema_name = "Pair", payload = pair_payload_a },
			{ schema_name = "Pair", payload = pair_payload_b },
			{ schema_name = "SchemaA", payload = { 0, 0, 5, 9 } },
			{ schema_name = "SchemaA", payload = { 0, 0, 6, 9 } },
			{ schema_name = "Large", payload = { 0, 0, 7, large_values[1] } },
			{ schema_name = "Large", payload = { 0, 0, 8, large_values[2] } },
			{ schema_name = "Large", payload = { 0, 0, 9, large_values[3] } },
			{ schema_name = "Large", payload = { 0, 0, 10, large_values[4] } },
			{ schema_name = "Large", payload = { 0, 0, 11, large_values[5] } },
			{ schema_name = "Large", payload = { 0, 0, 12, large_values[6] } },
			{ schema_name = "W3CGameEnd", payload = { 0, 0, 13, true } },
			{ schema_name = "W3CGameEnd", payload = { 1, 0, 14, false } },
		}),
		"Final checksum should include W3CGameEnd events"
	)

	local final_events = W3CData:decode_payloads({ sent_sync_packets[#sent_sync_packets - 1].payload })
	assert_equal(final_events[#final_events - 1][1], "W3CGameEnd", "end_game should flush game end events before checksum")
	assert_equal(final_events[#final_events][1], "W3CGameEnd", "end_game should flush all game end events before checksum")
	print("W3CEvents final checksum test passed")
end

test_checksum_framing()
