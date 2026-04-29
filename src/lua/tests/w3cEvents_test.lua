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
	return { elapsed = 0 }
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

local function test_checksum_framing()
	print("------")
	print("Testing W3CEvents checksum framing")

	W3CEvents.initialize({
		checksum = { enabled = true },
		shared_schema = { enabled = false },
		flush = { interval = 0 },
	})

	W3CEvents:register_all_schemas({
		W3CEvents.schema("SchemaA", {
			W3CEvents.byteField("value"),
		}, { include_defaults = false }),
		W3CEvents.schema("SchemaB", {
			W3CEvents.byteField("value"),
		}, { include_defaults = false }),
		W3CEvents.schema("Pair", {
			W3CEvents.byteField("left"),
			W3CEvents.byteField("right"),
		}, { include_defaults = false }),
	})

	local schema_a_payload = { 5 }
	local schema_b_payload = { 5 }
	local pair_payload_a = { 1, 23 }
	local pair_payload_b = { 12, 3 }

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

	W3CEvents:event("SchemaA", { value = 5 })
	assert_equal(
		W3CEvents.config.checksum.get_checksum(),
		checksum_for({
			{ schema_name = "SchemaA", payload = schema_a_payload },
		}),
		"Single event checksum should use framed packed bytes"
	)

	W3CEvents:event("SchemaB", { value = 5 })
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
	print("W3CEvents checksum framing test passed")

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
			{ schema_name = "W3CGameEnd", payload = { 0, 0, true } },
			{ schema_name = "W3CGameEnd", payload = { 1, 0, false } },
		}),
		"Final checksum should include W3CGameEnd events"
	)

	local final_events = W3CData:decode_payloads({ sent_sync_packets[#sent_sync_packets - 1].payload })
	assert_equal(final_events[#final_events - 1][1], "W3CGameEnd", "end_game should flush game end events before checksum")
	assert_equal(final_events[#final_events][1], "W3CGameEnd", "end_game should flush all game end events before checksum")
	print("W3CEvents final checksum test passed")
end

test_checksum_framing()
