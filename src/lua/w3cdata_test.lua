local W3CData = require("src.lua.w3cdata")
local W3CChecksum = require("src.lua.w3cChecksum")
local json = require("dkjson")

---@type table<integer, Schema>
local schemas = {
	{
		version = 1,
		name = "base",
		fields = {
			{ name = "player", type = "byte" },
			{ name = "time", type = "byte" },
		},
	},
	{
		version = 1,
		name = "UnitTrained",
		fields = {
			{ name = "unit_type_id", type = "byte" },
		},
	},
	{
		version = 1,
		name = "PlayerState",
		fields = {
			{ name = "gold", type = "short", signed = true },
			{ name = "wood", type = "short", signed = true },
			{ name = "upkeep", type = "byte" },
			{ name = "string_field", type = "string" },
			{ name = "food_cap", type = "byte" },
			{ name = "food_used", type = "byte" },
			{ name = "bool_test", type = "bool" },
			{ name = "float_test", type = "float" },
		},
	},
	{
		version = 1,
		name = "PlayerStateBitSize",
		fields = {
			{ name = "gold", bits = 11, signed = true },
			{ name = "wood", bits = 11, signed = true },
			{ name = "upkeep", bits = 2 },
			{ name = "string_field", type = "string" },
			{ name = "food_used", bits = 8 },
			{ name = "food_cap", bits = 8 },
			{ name = "bool_field", type = "bool" },
			{ name = "float_test", type = "float" },
		},
	},
	{
		version = 1,
		name = "PlayerConfig",
		fields = {
			{ name = "player_name", type = "string" },
			{ name = "bool_field", type = "bool" },
		},
	},
	{
		version = 1,
		name = "EventWithFloats",
		fields = {
			{ name = "float_value", type = "float" },
		},
	},
}

local unit_trained_events = {
	{ 1, 10, 27 },
	{ 2, 10, 18 },
	{ 1, 28, 314 },
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

local player_config_events = {
	{ 1, 10, "PlayerName123", false },
	{ 2, 10, "私の名前", true },
}

local checksum = W3CChecksum.new()

for _, schema in ipairs(schemas) do
	W3CData:register_schema(schema)
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

	print("Input size: " .. #json.encode(event) .. ", Packed size: " .. #packed)
	print("Field : Input : Unpacked")
	for i, field in ipairs(schema.fields) do
		print(field.name .. " : " .. tostring(event[i]) .. " : " .. tostring(unpacked[i]))
	end
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

	print("batched table: " .. json.encode(batch))
	print("Batched table size: " .. #json.encode(batch))

	print("---")
	print("Testing batched events")
	local packed = W3CData:pack_batch(batch)

	local unpacked = W3CData:unpack_batch(packed)

	for i, entry in ipairs(unpacked) do
		local name, values = entry[1], entry[2]
		local schema_id = W3CData:get_schema_id(name)
		local schema = W3CData:get_schema_by_id(schema_id)

		print("[" .. i .. "] -- " .. name)
		for j, field in ipairs(schema.fields) do
			print("     " .. field.name .. ": " .. tostring(values[j]))
		end
	end
end

-- test_all_events_single("UnitTrained", unit_trained_events)
test_all_events_single("PlayerState", player_state_events)
-- test_all_events_single("PlayerConfig", player_config_events)

local batched = {
	UnitTrained = unit_trained_events,
	PlayerState = player_state_events,
	PlayerConfig = player_config_events,
}

-- test_batched_events(batched)

local function test_events_override_bit_size(schema_name, events)
	for _, event in ipairs(events) do
		test_event(schema_name, event)
	end
end

test_events_override_bit_size("PlayerStateBitSize", player_state_events_bitsize)
