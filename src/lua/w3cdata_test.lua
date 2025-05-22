local W3CData = require("src.lua.w3cdata")
W3CData.init()

local W3CChecksum = require("src.lua.w3cChecksum")
local json = require("src.lua.json")

---@type table<integer, Schema>
local schemas = {
	{
		version = 1,
		name = "base",
		fields = {
			{ name = "player", type = "byte", unsigned = true },
			{ name = "time", type = "byte", unsigned = true },
		},
	},
	{
		version = 1,
		name = "UnitTrained",
		use_base = true,
		fields = {
			{ name = "unit_type_id", type = "byte", unsigned = true },
		},
	},
	{
		version = 1,
		name = "PlayerState",
		use_base = true,
		fields = {
			{ name = "gold", type = "short" },
			{ name = "wood", type = "short" },
			{ name = "upkeep", type = "byte", unsigned = true },
			{ name = "string_field", type = "string" },
			{ name = "food_cap", type = "byte", unsigned = true },
			{ name = "food_used", type = "byte", unsigned = true },
			{ name = "bool_test", type = "bool", unsigned = true },
			{ name = "float_test", type = "float" },
		},
	},
	{
		version = 1,
		name = "PlayerStateBitSize",
		use_base = true,
		fields = {
			{ name = "gold", type = "int", num_of_bits = 11 },
			{ name = "wood", type = "int", num_of_bits = 11 },
			{ name = "upkeep", type = "int", num_of_bits = 2, unsigned = true },
			{ name = "string_field", type = "string" },
			{ name = "food_used", type = "int", num_of_bits = 8, unsigned = true },
			{ name = "food_cap", type = "int", num_of_bits = 8, unsigned = true },
			{ name = "bool_field", type = "bool" },
			{ name = "float_test", type = "float" },
		},
	},
	{
		version = 1,
		name = "PlayerStateMinMax",
		use_base = true,
		fields = {
			{ name = "gold", type = "number", minimum = 0, maximum = 25000 },
			{ name = "food_cap", type = "number", minimum = 0, maximum = 100 },
			{ name = "test_num", type = "number", minimum = -200 },
		},
	},
	{
		version = 1,
		name = "PlayerConfig",
		use_base = true,
		fields = {
			{ name = "player_name", type = "string" },
			{ name = "bool_field", type = "bool" },
		},
	},
	{
		version = 1,
		name = "EventWithFloats",
		use_base = true,
		fields = {
			{ name = "float_value", type = "float" },
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
	if field.type ~= "float" then
		assert(
			input == value,
			"Event ["
				.. schema_name
				.. "], Field ["
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
		local float_value = string.pack("f", value)
		local float_input = string.pack("f", input)
		assert(
			float_input == float_value,
			"Event ["
				.. schema_name
				.. "], Field ["
				.. field.name
				.. "] was ["
				.. tostring(value)
				.. "] when it should be ["
				.. tostring(input)
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

			validate_field(event_schema_name, field, input, value)
		end
	end

	print("Chunk testing passed")
end

test_chunking("PlayerState", player_state_events, 20)
test_chunking("PlayerState", player_state_events, 3)
test_chunking("UnitTrained", unit_trained_events, 12)

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

	local parsed = W3CData:decode_payloads(schema_payload)[1][2]

	for _, schema_string in ipairs(parsed) do
		local schema_list = json.decode(schema_string)
		assert(#schema_list == #W3CData.schemas, "Schema count does not match")
		for _, schema in ipairs(schema_list) do
			local registered_schema = W3CData:get_schema(schema.name)

			assert(registered_schema, "Schema not found for name " .. schema.name)
			assert(schema.version == registered_schema.version, "Schema versions don't match")
			assert(
				schema.use_base == registered_schema.use_base,
				"Schema ["
					.. schema.name
					.. "] use_base does not match -- "
					.. tostring(schema.use_base)
					.. " : "
					.. tostring(registered_schema.use_base)
			)
			assert(schema.allow_override == registered_schema.allow_override, "Schema allow override does not match")

			for index, field in ipairs(schema.fields) do
				assert(field.name == registered_schema.fields[index].name, "Field name does not match")
				assert(field.type == registered_schema.fields[index].type, "Field type does not match")
				assert(
					field.num_of_bits == registered_schema.fields[index].num_of_bits,
					"Field number of bits do not match"
				)
				assert(field.unsigned == registered_schema.fields[index].unsigned, "Field unsigned does not match")
				assert(field.minimum == registered_schema.fields[index].minimum, "Field minimum does not match")
				assert(field.maximum == registered_schema.fields[index].maximum, "Field maximum does not match")
			end
		end
	end

	print("Schema registry test passed")
end

test_schema_payloads()
