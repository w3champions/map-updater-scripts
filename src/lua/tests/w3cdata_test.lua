package.path = table.concat({
	"./?.lua",
	"./src/?.lua",
	package.path,
}, ";")

local bootstrap = require("lua.test_bootstrap")
local W3CData = bootstrap.W3CData
W3CData.init()

local W3CChecksum = bootstrap.W3CChecksum
local json = bootstrap.json

---@type table<integer, Schema>
local schemas = {
	{
		version = 1,
		name = "shared",
		fields = {
			{ name = "player", field_type = "byte", unsigned = true },
			{ name = "time", field_type = "byte", unsigned = true },
		},
	},
	{
		version = 1,
		name = "UnitTrained",
		include_defaults = true,
		fields = {
			{ name = "unit_type_id", field_type = "byte", unsigned = true },
		},
	},
	{
		version = 1,
		name = "PlayerState",
		include_defaults = true,
		fields = {
			{ name = "gold", field_type = "short" },
			{ name = "wood", field_type = "short" },
			{ name = "upkeep", field_type = "byte", unsigned = true },
			{ name = "string_field", field_type = "string" },
			{ name = "food_cap", field_type = "byte", unsigned = true },
			{ name = "food_used", field_type = "byte", unsigned = true },
			{ name = "bool_test", field_type = "bool", unsigned = true },
			{ name = "float_test", field_type = "float" },
		},
	},
	{
		version = 1,
		name = "PlayerStateBitSize",
		include_defaults = true,
		fields = {
			{ name = "gold",         field_type = "int", num_of_bits = 11 },
			{ name = "wood",         field_type = "int", num_of_bits = 11 },
			{ name = "upkeep",       field_type = "int", num_of_bits = 2, unsigned = true },
			{ name = "string_field", field_type = "string" },
			{ name = "food_used",    field_type = "int", num_of_bits = 8, unsigned = true },
			{ name = "food_cap",     field_type = "int", num_of_bits = 8, unsigned = true },
			{ name = "bool_field",   field_type = "bool" },
			{ name = "float_test",   field_type = "float" },
		},
	},
	{
		version = 1,
		name = "PlayerStateMinMax",
		include_defaults = true,
		fields = {
			{ name = "gold",     field_type = "number", minimum = 0,    maximum = 25000 },
			{ name = "food_cap", field_type = "number", minimum = 0,    maximum = 100   },
			{ name = "test_num", field_type = "number", minimum = -200                  },
		},
	},
	{
		version = 1,
		name = "PlayerConfig",
		include_defaults = true,
		fields = {
			{ name = "player_name", field_type = "string" },
			{ name = "bool_field",  field_type = "bool"   },
		},
	},
	{
		version = 1,
		name = "EventWithFloats",
		include_defaults = true,
		fields = {
			{ name = "float_value", field_type = "float" },
		},
	},
}

local unit_trained_events = {
	{ 1, 10, 27 },
	{ 2, 10, 18 },
	{ 1, 28, 255 },
	{ 2, 42, 125 },
}

local player_state_events = {
	{ 1, 10, 750, 600, 0, "test_string", 40, 28, true, 1.23 },
	{ 2, 10, -650, 885, 0, "テスト", 50, 37, false, 9.1231 },
	{ 1, 20, 480, -340, 0, "test", 50, 43, true, 41243.1341 },
	{ 2, 20, 325, 180, 0, "test", 70, 49, false, 13987.198233 },
}

local player_state_events_bitsize = {
	{ 1, 10, 750, 600, 0, "test_string", 40, 28, true, 1.23 },
	{ 2, 10, -650, 885, 0, "テスト", 50, 37, false, 9.1231 },
	{ 1, 20, 480, -340, 0, "test", 50, 43, true, 41243.1341 },
	{ 2, 20, 325, 180, 0, "test", 70, 49, false, 13987.198233 },
}

local player_state_min_max = {
	{ 1, 10, 70, 90, -100 },
	{ 2, 20, 25000, 100, -200 },
}

local player_config_events = {
	{ 1, 10, "PlayerName123", false },
	{ 2, 10, "私の名前", true },
}

local checksum = W3CChecksum.new()

W3CData:register_all_schemas(schemas)

local function validate_field(schema_name, field, value, input)
	if field.field_type ~= "float" then
		assert(
			input == value,
			"Event ["
				.. schema_name
				.. "], Number Field ["
				.. field.name
				.. "] was ["
				.. tostring(value)
				.. "] when it should be ["
				.. tostring(input)
				.. "]"
		)
	else
		-- We intentionally use 32 bit floats when packing so they will always be
		-- slightly different due to precision differences.
		local f32_input = string.unpack("f", string.pack("f", input))
		local f32_value = string.unpack("f", string.pack("f", value))
		assert(
			math.abs(f32_input - f32_value) <= 1e-6,
			"Event ["
				.. schema_name
				.. "], Float Field ["
				.. field.name
				.. "] was ["
				.. tostring(value)
				.. "] when it should be ["
				.. tostring(f32_input)
				.. "]"
		)
	end
end

local function test_event(schema_name, event)
	print("----")
	print("Testing [" .. schema_name .. "]")

	local schema_id = W3CData:get_schema_id(schema_name)
	local packed = W3CData:pack_bits(schema_id, event)

	-- print("Packed: ")
	-- for i = 1, #packed do
	-- 	io.write(string.format("%02X", packed:byte(i)) .. " ")
	-- end
	-- print()

	local unpacked, schema = W3CData:unpack_bits(schema_id, packed)

	--print("Input size: " .. #json.encode(event) .. ", Packed size: " .. #packed)
	--print("Field : Input : Unpacked")

	for i, field in ipairs(schema.fields) do
		-- print(schema.name .. " : " .. field.name .. " : " .. tostring(unpacked[i]) .. " : " .. tostring(event[i]))
		validate_field(schema.name, field, unpacked[i], event[i])
	end

	print("Test passed")
end

local function test_all_events_single(schema_name, events)
	for _, event in ipairs(events) do
		test_event(schema_name, event)
	end
end

local function test_batched_events(events)
	local batch = {}
	for k, v in pairs(events) do
		for _, event in ipairs(v) do
			local schema_id = W3CData:get_schema_id(k)
			batch[#batch + 1] = {
				schema_id,
				event,
			}
		end
	end

	print("----")
	print("Testing batched events")
	local packed = W3CData:pack_batch(batch)

	local unpacked = W3CData:unpack_batch(packed)

	for i, entry in ipairs(unpacked) do
		local name, values = entry[1], entry[2]
		local schema_id = W3CData:get_schema_id(name)
		local schema = W3CData:get_schema_by_id(schema_id)

		for j, field in ipairs(schema.fields) do
			validate_field(schema.name, field, values[j], batch[i][2][j])
		end
	end

	print("Batch Test passed")
end

test_all_events_single("UnitTrained", unit_trained_events)
test_all_events_single("PlayerState", player_state_events)
test_all_events_single("PlayerStateMinMax", player_state_min_max)
test_all_events_single("PlayerConfig", player_config_events)

local batched = {
	UnitTrained = unit_trained_events,
	PlayerState = player_state_events,
	PlayerStateBitSize = player_state_events_bitsize,
	PlayerConfig = player_config_events,
}

test_batched_events(batched)

local function test_events_override_bit_size(schema_name, events)
	for _, event in ipairs(events) do
		test_event(schema_name, event)
	end
end

test_events_override_bit_size("PlayerStateBitSize", player_state_events_bitsize)

local function test_chunking(schema_name, events, repetitions)
	local batch = {}
	for _, v in ipairs(events) do
		for _ = 1, repetitions do
			table.insert(batch, { schema_name = schema_name, payload = v })
		end
	end

	print("----")
	print("Testing chunking event [" .. schema_name .. "] with " .. #batch .. " events")

	local chunked, was_chunked = W3CData:encode_payload(batch, 200)

	local b = was_chunked and "" or " not"
	print("was" .. b .. " chunked with " .. #chunked .. " payloads with max size of 200 bytes")

	local result = W3CData:decode_payloads(chunked)
	print("Chunk had " .. #result .. " events")
	for i, event in ipairs(result) do
		local event_schema_name, values = event[1], event[2]
		local schema = W3CData:get_schema(event_schema_name)

		for j, field in ipairs(schema.fields) do
			local value = values[j]
			local input = batch[i].payload[j]

			validate_field(event_schema_name, field, value, input)
		end
	end

	print("Chunk testing passed")
end

test_chunking("PlayerState", player_state_events, 20)
test_chunking("PlayerState", player_state_events, 3)
test_chunking("UnitTrained", unit_trained_events, 12)

local function chunk_id_from_payload(payload)
	local decoded = W3CData.cobs_decode(payload)
	local id_hi = decoded:byte(2)
	local id_lo = decoded:byte(3)
	return (id_hi << 8) | id_lo
end

local function test_chunk_ids_are_deterministic()
	print("------")
	print("Testing deterministic chunk ids")

	local first_batch = {}
	local second_batch = {}
	for index = 1, 20 do
		first_batch[#first_batch + 1] = { schema_name = "PlayerState", payload = player_state_events[((index - 1) % #player_state_events) + 1] }
		second_batch[#second_batch + 1] = { schema_name = "PlayerState", payload = player_state_events[((index - 1) % #player_state_events) + 1] }
	end

	local first_payloads, first_chunked = W3CData:encode_payload(first_batch, 200)
	local second_payloads, second_chunked = W3CData:encode_payload(second_batch, 200)

	assert(first_chunked, "First batch should be chunked")
	assert(second_chunked, "Second batch should be chunked")
	local first_chunk_id = chunk_id_from_payload(first_payloads[1])
	local second_chunk_id = chunk_id_from_payload(second_payloads[1])
	local expected_second_chunk_id = (first_chunk_id % 65535) + 1
	assert(second_chunk_id == expected_second_chunk_id, "Chunk ids should increment deterministically")

	print("Deterministic chunk id test passed")
end

test_chunk_ids_are_deterministic()

local function test_chunk_group_order_is_deterministic()
	print("------")
	print("Testing deterministic chunk group ordering")

	local batch_a = {}
	local batch_b = {}
	for index = 1, 20 do
		batch_a[#batch_a + 1] = { schema_name = "PlayerState", payload = player_state_events[((index - 1) % #player_state_events) + 1] }
		batch_b[#batch_b + 1] = { schema_name = "PlayerConfig", payload = player_config_events[((index - 1) % #player_config_events) + 1] }
	end

	local payloads_a, chunked_a = W3CData:encode_payload(batch_a, 200)
	local payloads_b, chunked_b = W3CData:encode_payload(batch_b, 200)
	assert(chunked_a and chunked_b, "Both batches should be chunked")

	local mixed_payloads = {}
	local max_parts = math.max(#payloads_a, #payloads_b)
	for index = 1, max_parts do
		if payloads_a[index] then
			mixed_payloads[#mixed_payloads + 1] = payloads_a[index]
		end
		if payloads_b[index] then
			mixed_payloads[#mixed_payloads + 1] = payloads_b[index]
		end
	end

	local decoded = W3CData:decode_payloads(mixed_payloads)
	for index = 1, #batch_a do
		assert(decoded[index][1] == "PlayerState", "First decoded chunk group should preserve input order")
	end
	for index = #batch_a + 1, #decoded do
		assert(decoded[index][1] == "PlayerConfig", "Second decoded chunk group should preserve input order")
	end

	print("Deterministic chunk group ordering test passed")
end

test_chunk_group_order_is_deterministic()

local function test_checksum()
	for _, schema in ipairs(schemas) do
		checksum:update(json.encode(schema))
	end

	local crc = checksum:finalize()
	print("------")
	io.write("Testing checksum: ")
	for i = 1, #crc do
		io.write(string.format("%02X", crc:byte(i)) .. " ")
	end
	print()
	local checksum_payload = W3CData:generate_checksum_payload(crc)

	local parsed_checksum = W3CData:decode_payloads({ checksum_payload })[1][1]
	assert(crc == parsed_checksum)
	-- print("checksum: ")
	-- for i = 1, #parsed_checksum do
	-- 	io.write(string.format("%02X", parsed_checksum:sub(i)) .. " ")
	-- end
	-- print()

	print("Checksum test passed")
end

test_checksum()

local function test_schema_payloads()
	print("------")
	print("Testing schema registry")
	local schema_payload, _ = W3CData:generate_registry_payloads()
	print("Number of schemas: " .. #schemas .. ", Number of payloads: " .. #schema_payload)

	local schema_list = W3CData:decode_registry_payloads(schema_payload)
	assert(#schema_list == W3CData:schema_count(), "Schema count does not match")
	for _, schema in ipairs(schema_list) do
		local registered_schema = W3CData:get_schema(schema.name)

		assert(registered_schema, "Schema not found for name " .. schema.name)
		assert(schema.id == registered_schema.id, "Schema ids don't match")
		assert(schema.version == registered_schema.version, "Schema versions don't match")
		assert(
			schema.include_defaults == registered_schema.include_defaults,
			"Schema ["
				.. schema.name
				.. "] include_defaults does not match -- "
				.. tostring(schema.include_defaults)
				.. " : "
				.. tostring(registered_schema.include_defaults)
		)

		for index, field in ipairs(schema.fields) do
			assert(field.name == registered_schema.fields[index].name, "Field name does not match")
			assert(field.field_type == registered_schema.fields[index].field_type, "Field type does not match")
			assert(
				field.num_of_bits == registered_schema.fields[index].num_of_bits,
				"Field number of bits do not match"
			)
			assert(field.unsigned == registered_schema.fields[index].unsigned, "Field unsigned does not match")
			assert(field.minimum == registered_schema.fields[index].minimum, "Field minimum does not match")
			assert(field.maximum == registered_schema.fields[index].maximum, "Field maximum does not match")
		end
	end

	local stats = W3CData:registry_payload_stats()
	print(
		"Schema registry size: packets="
			.. tostring(stats.packet_count)
			.. ", total_bytes="
			.. tostring(stats.total_encoded_bytes)
			.. ", largest_packet="
			.. tostring(stats.largest_packet_bytes)
			.. ", compact_blob="
			.. tostring(stats.compact_blob_bytes)
			.. ", compressed_blob="
			.. tostring(stats.compressed_blob_bytes)
			.. ", legacy_json="
			.. tostring(stats.legacy_json_bytes)
	)
	assert(stats.packet_count < 22, "Compact schema registry should use fewer packets than legacy JSON")
	assert(stats.compressed_blob_bytes < stats.legacy_json_bytes, "Compact schema registry should be smaller than legacy JSON")

	print("Schema registry test passed")
end

test_schema_payloads()

local function test_has_schema()
	print("------")
	print("Testing has_schema")
	assert(W3CData:has_schema("PlayerState") == true, "PlayerState should exist")
	assert(W3CData:has_schema("UnitTrained") == true, "UnitTrained should exist")
	assert(W3CData:has_schema("shared") == true, "shared should exist")
	assert(W3CData:has_schema("NonExistent") == false, "NonExistent should not exist")
	assert(W3CData:has_schema("") == false, "empty string should not exist")
	print("has_schema test passed")
end

local function test_should_include_defaults()
	print("------")
	print("Testing should_include_defaults")
	assert(W3CData:should_include_defaults("PlayerState") == true, "PlayerState includes defaults")
	assert(W3CData:should_include_defaults("UnitTrained") == true, "UnitTrained includes defaults")
	assert(W3CData:should_include_defaults("shared") == false, "shared schema itself does not include defaults")
	assert(W3CData:should_include_defaults("EventWithFloats") == true, "EventWithFloats includes defaults")
	print("should_include_defaults test passed")
end

local function test_shared_schema_disabled()
	print("------")
	print("Testing shared_schema.enabled = false")
	W3CData.init({ shared_schema = { enabled = false } })

	local schema = W3CData:get_schema("PlayerState")
	for _, field in ipairs(schema.fields) do
		assert(
			field.name ~= "player" and field.name ~= "time",
			"Shared fields should not appear when shared_schema.enabled = false"
		)
	end

	W3CData.init({ shared_schema = { enabled = true } })
	print("shared_schema.enabled=false test passed")
end

local function test_cobs()
	print("------")
	print("Testing COBS encode/decode")

	local function roundtrip(s, label)
		local encoded = W3CData.cobs_encode(s)
		for i = 1, #encoded do
			assert(encoded:byte(i) ~= 0, "COBS output contains null byte at index " .. i .. " (" .. label .. ")")
		end
		local decoded = W3CData.cobs_decode(encoded)
		assert(decoded == s, "COBS round-trip failed for: " .. label)
	end

	roundtrip("hello world", "no nulls")
	roundtrip("\0", "single null")
	roundtrip("\0\0\0", "all nulls")
	roundtrip("ab\0cd", "null in middle")
	roundtrip("\0ab", "null at start")
	roundtrip("ab\0", "null at end")
	roundtrip("", "empty string")
	-- 0xFF boundary: 254 non-null bytes before a null forces a code byte at exactly 0xFF
	roundtrip(string.rep("A", 254) .. "\0" .. "B", "0xFF boundary")

	print("COBS test passed")
end

local function test_cobs_in_payload()
	print("------")
	print("Testing COBS applied through encode/decode payload")
	-- unit_type_id = 0 produces 0x00 bytes in the packed output; COBS must handle this transparently
	local events = { { schema_name = "UnitTrained", payload = { 1, 10, 0 } } }
	local encoded, _ = W3CData:encode_payload(events, 200)
	local decoded = W3CData:decode_payloads(encoded)
	assert(#decoded == 1, "Expected 1 decoded event")
	assert(decoded[1][1] == "UnitTrained", "Schema name mismatch")
	assert(decoded[1][2][3] == 0, "unit_type_id should be 0")
	print("COBS in payload test passed")
end

local function test_parse_unpacked()
	print("------")
	print("Testing parse_unpacked")
	local event = { 1, 10, 750, 600, 0, "hello", 40, 28, true, 1.5 }
	local encoded, _ = W3CData:encode_payload({ { schema_name = "PlayerState", payload = event } }, 200)
	local decoded = W3CData:decode_payloads(encoded)
	local parsed = W3CData:parse_unpacked(decoded)
	assert(#parsed == 1, "Expected 1 parsed event")
	local name, fields = parsed[1][1], parsed[1][2]
	assert(name == "PlayerState", "Schema name mismatch")
	assert(fields["player"] == 1, "player field mismatch")
	assert(fields["time"] == 10, "time field mismatch")
	assert(fields["gold"] == 750, "gold field mismatch")
	assert(fields["wood"] == 600, "wood field mismatch")
	assert(fields["string_field"] == "hello", "string_field mismatch")
	assert(fields["bool_test"] == true, "bool_test field mismatch")
	print("parse_unpacked test passed")
end

local function test_error_paths()
	print("------")
	print("Testing error/validation paths")

	local function expect_error(fn, label)
		local ok = pcall(fn)
		assert(not ok, "Expected error for: " .. label .. " but got none")
	end

	-- Reserved schema names
	expect_error(function()
		W3CData:register_schema({ name = "checksum", version = 1, fields = { { name = "x", field_type = "byte" } } })
	end, "register reserved name 'checksum'")

	expect_error(function()
		W3CData:register_schema({ name = "schema_registry", version = 1, fields = { { name = "x", field_type = "byte" } } })
	end, "register reserved name 'schema_registry'")

	-- Duplicate registration is a silent no-op (must NOT error)
	local ok = pcall(function()
		W3CData:register_schema({ name = "PlayerState", version = 1, fields = { { name = "x", field_type = "byte" } } })
	end)
	assert(ok, "Duplicate registration should be a silent no-op")

	-- Registry-level validation (tested via w3cschema directly)
	local w3cschema = bootstrap.W3CSchema

	expect_error(function()
		local reg = w3cschema.Registry.new()
		reg:register({ name = "Bad", version = 1, fields = { { name = "x", field_type = "invalid_type" } } })
	end, "invalid field_type")

	expect_error(function()
		local reg = w3cschema.Registry.new()
		reg:register({ name = "Empty", version = 1, fields = {} })
	end, "empty fields list")

	expect_error(function()
		local reg = w3cschema.Registry.new()
		reg:register({ name = "Bad", version = 1, fields = { { name = "x", field_type = "number" } } })
	end, "number field without min/max")

	expect_error(function()
		local reg = w3cschema.Registry.new()
		reg:register({ name = "Bad", version = 1, fields = { { name = "x", field_type = "byte", num_of_bits = 4 } } })
	end, "num_of_bits on non-int field")

	expect_error(function()
		local reg = w3cschema.Registry.new()
		reg:register({ name = "Bad", version = 1, fields = { { name = "x", field_type = "int", num_of_bits = 0 } } })
	end, "num_of_bits lower bound")

	expect_error(function()
		local reg = w3cschema.Registry.new()
		reg:register({ name = "Bad", version = 1, fields = { { name = "x", field_type = "int", num_of_bits = 33 } } })
	end, "num_of_bits upper bound")

	expect_error(function()
		local reg = w3cschema.Registry.new()
		reg:register({ name = "Bad", version = 1, fields = { { name = "x", field_type = "byte", minimum = 0 } } })
	end, "minimum on non-number field")

	expect_error(function()
		local reg = w3cschema.Registry.new()
		reg:register({ name = "A", version = 1, fields = { { name = "x", field_type = "byte" } } })
		reg:register({ name = "A", version = 1, fields = { { name = "x", field_type = "byte" } } })
	end, "duplicate registry registration")

	-- pack_bits field count mismatch
	expect_error(function()
		local schema_id = W3CData:get_schema_id("UnitTrained")
		W3CData:pack_bits(schema_id, { 1, 10 }) -- expects 3 fields (player, time, unit_type_id)
	end, "pack_bits field count mismatch")

	-- pack_bits wrong value type
	expect_error(function()
		local schema_id = W3CData:get_schema_id("UnitTrained")
		W3CData:pack_bits(schema_id, { "not_a_number", 10, 5 })
	end, "pack_bits wrong value type")

	-- pack_bits custom-width bounds
	expect_error(function()
		local schema_id = W3CData:get_schema_id("BoundaryTest")
		W3CData:pack_bits(schema_id, { 0, 0, 0, -1025 })
	end, "pack_bits signed custom-width underflow")

	expect_error(function()
		local schema_id = W3CData:get_schema_id("BoundaryTest")
		W3CData:pack_bits(schema_id, { 0, 0, 0, 1024 })
	end, "pack_bits signed custom-width overflow")

	print("Error path tests passed")
end

local function test_numeric_boundaries()
	print("------")
	print("Testing numeric boundary values")

	W3CData:register_schema({
		version = 1,
		name = "BoundaryTest",
		include_defaults = false,
		fields = {
			{ name = "signed_byte",   field_type = "byte"                    },
			{ name = "unsigned_byte", field_type = "byte", unsigned = true   },
			{ name = "signed_short",  field_type = "short"                   },
			{ name = "int_11bit",     field_type = "int",  num_of_bits = 11  },
		},
	})

	local cases = {
		{ -128, 0,     -32768, -1024 },
		{  127, 255,    32767,  1023 },
		{    0, 0,          0,     0 },
		{   -1, 1,         -1,    -1 },
	}

	for _, case in ipairs(cases) do
		test_event("BoundaryTest", case)
	end

	print("Numeric boundary tests passed")
end

test_has_schema()
test_should_include_defaults()
test_shared_schema_disabled()
test_cobs()
test_cobs_in_payload()
test_parse_unpacked()
test_numeric_boundaries()
test_error_paths()
