package.path = table.concat({
	"./?.lua",
	"./src/?.lua",
	package.path,
}, ";")

local bootstrap = require("lua.test_bootstrap")
local W3CData = bootstrap.W3CData

local order_context_schemas = {
	{
		version = 1,
		name = "OrderContextUnit",
		fields = {
			{ name = "player", field_type = "int", num_of_bits = 5, unsigned = true },
			{ name = "time", field_type = "int", num_of_bits = 13, unsigned = true },
			{ name = "issuerTypeId", field_type = "int", num_of_bits = 32, unsigned = true },
			{ name = "issuerOwner", field_type = "int", num_of_bits = 5, unsigned = true },
			{ name = "orderId", field_type = "int", num_of_bits = 32, unsigned = true },
			{ name = "targetTypeId", field_type = "int", num_of_bits = 32, unsigned = true },
			{ name = "targetOwner", field_type = "int", num_of_bits = 5, unsigned = true },
			{ name = "targetIsHero", field_type = "bool" },
			{ name = "targetIsStructure", field_type = "bool" },
			{ name = "targetX", field_type = "short", unsigned = true },
			{ name = "targetY", field_type = "short", unsigned = true },
			{ name = "visible", field_type = "bool" },
			{ name = "fogged", field_type = "bool" },
			{ name = "masked", field_type = "bool" },
			{ name = "recentlySeenBucket", field_type = "int", num_of_bits = 3, unsigned = true },
			{ name = "revealSource", field_type = "int", num_of_bits = 3, unsigned = true },
		},
		include_defaults = false,
	},
	{
		version = 1,
		name = "OrderContextPoint",
		fields = {
			{ name = "player", field_type = "int", num_of_bits = 5, unsigned = true },
			{ name = "time", field_type = "int", num_of_bits = 13, unsigned = true },
			{ name = "issuerTypeId", field_type = "int", num_of_bits = 32, unsigned = true },
			{ name = "issuerOwner", field_type = "int", num_of_bits = 5, unsigned = true },
			{ name = "orderId", field_type = "int", num_of_bits = 32, unsigned = true },
			{ name = "pointX", field_type = "short", unsigned = true },
			{ name = "pointY", field_type = "short", unsigned = true },
			{ name = "nearHiddenEnemy", field_type = "bool" },
			{ name = "nearestHiddenEnemyType", field_type = "int", num_of_bits = 32, unsigned = true },
			{ name = "nearestHiddenEnemyOwner", field_type = "int", num_of_bits = 5, unsigned = true },
			{ name = "distanceBucket", field_type = "int", num_of_bits = 3, unsigned = true },
			{ name = "recentlySeenBucket", field_type = "int", num_of_bits = 3, unsigned = true },
			{ name = "revealSource", field_type = "int", num_of_bits = 3, unsigned = true },
		},
		include_defaults = false,
	},
}

local function assert_equal(actual, expected, label)
	assert(actual == expected, label .. ": expected [" .. tostring(expected) .. "] got [" .. tostring(actual) .. "]")
end

local function assert_decoded_event(schema_name, payload)
	local encoded, _ = W3CData:encode_payload({
		{ schema_name = schema_name, payload = payload },
	}, 200)

	local decoded = W3CData:decode_payloads(encoded)
	assert_equal(#decoded, 1, schema_name .. " packet count")
	assert_equal(#decoded[1], 2, schema_name .. " decoded tuple count")
	assert_equal(decoded[1][1], schema_name, schema_name .. " decoded schema name")

	local values = decoded[1][2]
	for index, expected in ipairs(payload) do
		assert_equal(values[index], expected, schema_name .. " field " .. tostring(index))
	end
end

local function test_order_context_schema_round_trip()
	print("------")
	print("Testing order context schema round trip")

	W3CData.init({
		shared_schema = { enabled = false },
	})
	W3CData:register_all_schemas(order_context_schemas)

	assert_decoded_event("OrderContextUnit", {
		3,
		122,
		1093677104,
		3,
		851983,
		1164333360,
		5,
		true,
		false,
		1536,
		2048,
		false,
		true,
		false,
		4,
		0,
	})

	assert_decoded_event("OrderContextPoint", {
		7,
		444,
		1332899950,
		7,
		851986,
		2816,
		3328,
		true,
		1212762693,
		10,
		2,
		6,
		1,
	})

	print("Order context schema round trip test passed")
end

test_order_context_schema_round_trip()
