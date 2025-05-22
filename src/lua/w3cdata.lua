--[[

Library to handle compression and decompression of schema based data.

This library should generally not be used directly as this is intended to be used within libraries themselves so
they can encode and decode data for BlzSendSyncData.

Basic Usage:

- Register an event schema

W3CData.register_schema("PlayerState", { 
  { name: "gold", type: "int" },
  { name: "wood", type: "int" },
  { name: "upkeep", type: "byte" },
})

- Create a payload to send
local events = { 
    { "PlayerState", { 50, 100, 0 } } -- { schema_name, { gold, wood, upkeep } } 
} 
local payload = W3CData:encode_payload(events)

---
To parse a payload just use W3CData:decode_payload

- Decode data sent
local packed = W3CData:decode_payload(payload)

--------

Schemas are in the format:

{
  version:    integer,
  name:       string,
  use_base?:  boolean
  fields: [
    { 
      name:     string,
      type:     "bool" | "byte" | "short" | "int" | "float" | "string",
      bits?:    integer,
      signed?:  boolean,
    }
  ]
}

The fields.bits field is set automatically when registering a schema based on the type set.

- bool:   1 bit
- byte:   8 bits
- short:  16 bits
- int:    32 bits
- float:  32 bits, not able to overwrite

String does not use a bit size as they are not bit packed.

Floats use 4 bytes and are not compressed. 64-bit floats are converted to 32-bit floats, losing precision.
Strings have a 2 byte length before the string data. Strings are compressed using raw Deflate to handle utf-8 encoding easily.

If the fields.bits value is set, it overrides the value defined by the type.

Signed is used to indentify whether the field should use zigzag encoding to handle negative values or not.
**NOTE** If you use a negative value and DO NOT set `signed = true`, then the value will be parsed incorrectly as a large number.

--------

Each packet has a 1 byte header that identifies whether the packet is:

0x01      - Singular data packet
0x02      - Batched data packet
0x03      - Checksum packet       -- Use the W3CChecksum utility for updating and getting checksums
0x80      - Chunked packet         

Chunked packets contain additional header data:

[0x80]|[chunk_id_hi]|[chunk_id_lo]|[chunk_count]|[chunk_index]|[payload...]

The chunk_id is a unique id for all associated chunked used for matching.
The chunk count is the number of chunks for this specific set of chunks
The chunk index is this specific packets index in the chunks
The payload is the byte string packed data.

--------

NOTE: The below is not necessary to use unless you really want to minimize the amount of data being used.

Overriding bit sizes for schemas is possible by setting the `field.bits` instead of the `field.type`.
This can be useful for making more compressed payloads. As an example, `upkeep` is only ever 0, 1 or 2. We can
use 2 bits for this instead of the `byte` of 8 bits, allowing us to save 6 bits on every event using this field. 
Or a `player` field for player ids will only ever have values 0-32, so we can use 5 bits instead of the `byte`, saving 3 bits.

Below is a table showing bits and the numbers they allow up to 24 bits / 3 bytes.
  Bits      Number
  1         2
  2         4
  3         8
  4         16
  5         32
  6         64
  7         128
  8         256
  9         512
  10        1024
  11        2048
  12        4096
  13        8192
  14        16384
  15        32768
  16        65536
  17        131072
  18        262144
  19        524288
  20        1048576
  21        2097152
  22        4194304
  23        8388608
  24        16777216

--]]

-- TODO: Still need to update the event library to use this library and test that it all works inside WC3

require("src.lua.libDeflate")
local json = require("src.lua.json")

---@alias FieldType "bool" | "byte" | "short" | "int" | "number" | "float" | "string"
---@alias FieldName string
---@alias SchemaId integer

---@alias PayloadFieldValue string | number | boolean
---@alias PayloadValue table<FieldName, PayloadFieldValue>

---@class Field Field description for a schema.
---@field name string Name of the field.
---@field type FieldType Type of the field. Decimal numbers use `float`. `number` is used only when using `minimum` and `maxiumum`
---@field num_of_bits? integer Number of bits used by this field. Requires `type = "int"` if used. Only valid for integer types.
---@field unsigned? boolean Whether the field is unsigned or not. Only applies to `byte`, `short` and `int` types
---@field minimum? number Minimum number for a field, only used when `tyoe = "number"`
---@field maximum? number Maximum number for a field, only used when `type = "number"``

---@class Schema Schema used for an event
---@field version integer Version of the schema
---@field name string Name of the schema
---@field use_base? boolean Whether this schema should include the "base" schema fields or not. Defaults to `false`
---@field fields Field[] All fields for this schema

---@class Payload Payload that maps a schema name to a table when being packed.
---@field schema_name string Name of the schema that the payload is for
---@field payload table<PayloadValue> Table containing the payload values

---@class BaseSchemaConfig Config for W3CData base schema
---@field enabled boolean Whether using the base schema is enabled or not

---@class W3CDataConfig Config for W3CData
---@field base_schema BaseSchemaConfig Config for base schema

---@class Chunk Chunk of a payload, for when a single payload is too large to be sent at once
---@field id integer Unique ID for a payload. All chunks for a single payload will share the same id
---@field index integer Index of the chunk in the payload.
---@field count integer Count of all chunks in the payload
---@field payload string Payload for this chunk. Combine the payload from all chunks with the same id before decoding

-- Header byte values used in the payload to identify what the payload is
local HEADER_VALUES = {
	EVENT = 0x01,
	CHECKSUM = 0x02,

	CHUNK = 0x80,
}

-- Used to mask numbers to 32 bit integers as bit shifting can cause bits to go over 32 bits boundary
local INT_MASK = 0xFFFFFFFF

-- Limits for integers, used to validate values are within the exepcted number range
local LIMITS = {
	BYTE = {
		SIGNED_LO = (-2 << 7),
		SIGNED_HI = (2 << 7) - 1,
		UNSIGNED = (1 << 8) - 1,
	},
	SHORT = {
		SIGNED_LO = (-2 << 15),
		SIGNED_HI = (2 << 15) - 1,
		UNSIGNED = (1 << 16) - 1,
	},
	INT = {
		SIGNED_LO = (-2 << 31),
		SIGNED_HI = (2 << 31) - 1,
		UNSIGNED = (1 << 32) - 1,
	},
}

--These need to match the indexes of the schemas.
local INTERNAL_SCHEMA_ID = {
	SCHEMA = 1,
	CHECKSUM = 2,
	BASE = 3,
}

local INTERNAL_SCHEMA_NAMES = {
	SCHEMA_REGISTRY = "schema_registry",
	CHECKSUM = "checksum",
	BASE = "base",
}

---@class W3CData
---@field config W3CDataConfig
---@field schemas table<integer, Schema>
local W3CData = {
	config = { base_schema = { enabled = true } },
	-- Base schemas required for basic functionality. DO NOT REMOVE or things will break.
	-- The order needs to match the indexes specified in `INTERNAL_SCHEMA_ID`, as they're used as indexes to this table.
	schemas = {
		{
			-- Used to send all schemas after being registered so that they can be used in parsing
			version = 1,
			name = INTERNAL_SCHEMA_NAMES.SCHEMA_REGISTRY,
			fields = {
				-- Schemas don't support nested fields or types so we just send everything as json
				-- that will be parsed instead.
				{ name = "schemas_json", type = "string" },
			},
		},
		-- Used for sending checksums.
		{ version = 1, name = INTERNAL_SCHEMA_NAMES.CHECKSUM, fields = { { name = "checksum", type = "string" } } },
		-- Base empty schema as the library has specific handling that expects this to exist.
		{ version = 0, name = INTERNAL_SCHEMA_NAMES.BASE, fields = {} },
	},
}

-- Mapping of names to ids, used for lookup.
-- Schema IDs are used for compressed data as they're much smaller than the string names.
local schema_name_to_id_mapping = {
	schema_registry = INTERNAL_SCHEMA_ID.SCHEMA,
	checksum = INTERNAL_SCHEMA_ID.CHECKSUM,
	base = INTERNAL_SCHEMA_ID.BASE,
}

---Parses a "number" type field and ensures that the minimum and maximum values are valid if set.
---Sets the field.type to `byte`, `short` or `int` depending on the minimum and maximum values.
---Sets `field.unsigned` if the minimum is >= 0
---@param field Field
local function parse_number_field(field)
	if field.type ~= "number" then
		return
	end

	if field.maximum and field.minimum and field.maximum <= field.minimum then
		error(
			field.name
				.. " maximum value ["
				.. tostring(field.maximum)
				.. "] needs to be larger than the minimum value ["
				.. tostring(field.minimum)
				.. "]"
		)
	end

	if field.minimum and field.minimum >= 0 then
		field.unsigned = true
	end

	if field.unsigned then
		if field.maximum and field.maximum <= LIMITS.BYTE.UNSIGNED then
			field.type = "byte"
		elseif field.maximum and field.maximum <= LIMITS.SHORT.UNSIGNED then
			field.type = "short"
		else
			field.type = "int"
		end
	else
		if
			field.minimum
			and field.minimum >= LIMITS.BYTE.SIGNED_LO
			and field.maximum
			and field.maximum <= LIMITS.BYTE.SIGNED_HI
		then
			field.type = "byte"
		elseif
			field.minimum
			and field.minimum >= LIMITS.SHORT.SIGNED_LO
			and field.maximum
			and field.maximum <= LIMITS.SHORT.SIGNED_HI
		then
			field.type = "short"
		else
			field.type = "int"
		end
	end
end

--- Sets bit values for all types we support. Bit values are used in packing and unpacking
--- If `field.type = "int"` then we allow custom bit sizes, otherwise specific bit sizes are used for everything.
---@param schema Schema Schema to set bit values for
local function configure_schema_fields(schema)
	for _, field in ipairs(schema.fields) do
		assert(
			field.name,
			"Schema fields require a name to be set but a field for schema ["
				.. schema.name
				.. "] does not have a name."
		)
		assert(
			field.type,
			"Schema fields require a type to be set but field [" .. field.name .. "] does not have a type."
		)

		-- Convert number fields to other integer fields so we can set types.
		if field.type == "number" then
			assert(
				field.maximum or field.minimum,
				"Schema fields with a 'number' type require a minimum or maximum to be set but field ["
					.. field.name
					.. "] has neither."
			)
			parse_number_field(field)
		else
			assert(
				field.maximum == nil and field.minimum == nil,
				"Schema fields can only set a 'maximum' or 'minimum' when their type is 'number' but field ["
					.. field.name
					.. "] had one set while having type ["
					.. field.type
					.. "]"
			)
		end

		if field.type == "bool" then
			field.num_of_bits = 1
		elseif field.type == "byte" then
			field.num_of_bits = 8
		elseif field.type == "short" then
			field.num_of_bits = 16
		elseif field.type == "int" then
			field.num_of_bits = field.num_of_bits or 32
		elseif field.type == "float" then
			-- Lua floating numbers are 64 bit but we assume we can safely cast to 32 bit to compress and uncompress.
			-- It's unlikely we'll need to preserve double precision for anything
			field.num_of_bits = 32
		elseif field.type == "string" then
			-- not used but if not set it breaks parsing bit sizes due to nil field
			field.num_of_bits = -1
		end
	end
end

---@param config? W3CDataConfig
function W3CData.init(config)
	LibDeflate.InitCompressor()
	W3CData.config = config or { base_schema = { enabled = true } }
end

--- Register a schema to be used for compression and decompression.
--- Schemas with the name "base" will be combined with all other schemas if `config.base_schema.enabled = true` and
--- the `schema.use_base = true`
--- Using a base schema is disabled by default for registered schemas.
---@param schema Schema Schema to be registered
function W3CData:register_schema(schema)
	assert(schema.name, "Schemas require a name to be set")
	assert(schema.version, "Schemas require a version to be set")

	assert(schema.name ~= INTERNAL_SCHEMA_NAMES.CHECKSUM, "Setting schema for checksum is not allowed")
	assert(schema.name ~= INTERNAL_SCHEMA_NAMES.SCHEMA_REGISTRY, "Setting schema for schema_registry is not allowed")

	configure_schema_fields(schema)

	-- Base schema exists by default and is always first to prevent errors where
	-- users may enable using the base schema without actually registering one themselves.
	if schema.name:lower() == INTERNAL_SCHEMA_NAMES.BASE then
		self.schemas[INTERNAL_SCHEMA_ID.BASE] = schema
		return
	end

	if schema_name_to_id_mapping[schema.name] then
		-- If schema already exists just return. Schemas should only be registered once, we don't allow overriding
		return
	end

	local schema_id = #self.schemas + 1
	schema.use_base = schema.use_base or false

	self.schemas[schema_id] = schema
	schema_name_to_id_mapping[schema.name] = schema_id
end

--- Registers multiple schemas to be used for compression and decompression.
---@param schemas Schema[]
function W3CData:register_all_schemas(schemas)
	for _, schema in ipairs(schemas) do
		self:register_schema(schema)
	end
end

--- Gets a schema id given a schema name.
---@param schema_name string Name of the schema to get an id for
---@return integer schema_id Id of the schema if it's been registered, otherwise nil
function W3CData:get_schema_id(schema_name)
	return schema_name_to_id_mapping[schema_name]
end

---Get a registered schema given a schema name
---@param schema_name string Name of the schema
---@return Schema schema Schema that matches the name if it exists
function W3CData:get_schema(schema_name)
	local id = self:get_schema_id(schema_name)
	return self:get_schema_by_id(id)
end

---Checks whether a schema exists and has been registered.
---@param schema_name string Name of the schema to check
---@return boolean schema_exists True if the schema has been registered, false if not.
function W3CData:has_schema(schema_name)
	return self:get_schema(schema_name) and true or false
end

---Checks whether a schema should include the base schema
---@param schema_name string Name of the schema to check
---@return boolean should_use_base True if the schema should include the base schema, false if not
function W3CData:should_use_base(schema_name)
	local schema = self:get_schema(schema_name)

	return (self.config.base_schema.enabled and schema.use_base) and true or false
end

--- COBS encodes a string to remove null bytes so that it can be safely sent using BlzSendSyncData.
---@param input string Bytes to do COBS encoding on
---@return string output COBS encoded bytes
function W3CData.cobs_encode(input)
	local output = {}
	local distance = 1
	local code_index = 1

	local function encode_null()
		output[code_index] = string.char(distance)
		code_index = #output + 1
		output[code_index] = "\0" -- Placeholder for next byte
		distance = 1
	end

	output[code_index] = 0 -- Placeholder for first byte

	for i = 1, #input do
		local byte = input:byte(i)

		if byte == 0 then
			encode_null()
		else
			output[#output + 1] = string.char(byte)
			distance = distance + 1
			if distance == 0xFF then
				encode_null()
			end
		end
	end

	output[code_index] = string.char(distance)
	return table.concat(output)
end

--- COBS decodes a string back to it's normal value, used while unpacking data that has been COBS encoded.
---@param input string Bytes to do COBS decoding on
---@return string output COBS decoded bytes
function W3CData.cobs_decode(input)
	local output = {}
	local i = 1
	local len = #input

	while i <= len do
		local code = input:byte(i)
		i = i + 1

		local end_i = i + code - 2
		while i <= end_i and i <= len do
			output[#output + 1] = string.char(input:byte(i))
			i = i + 1
		end

		if code < 0xFF and i <= len then
			output[#output + 1] = "\0"
		end
	end

	return table.concat(output)
end

--- Gets a schema by id. Includes the base schema fields if configured.
---@param schema_id integer Id of the schema to get
---@return Schema Schema Schema including base schema fields if configured
function W3CData:get_schema_by_id(schema_id)
	if not self.config.base_schema.enabled then
		return self.schemas[schema_id] or {}
	end

	local specific = self.schemas[schema_id] or {}
	if not specific.use_base then
		return specific
	end

	local base = self.schemas[INTERNAL_SCHEMA_ID.BASE]

	local schema = {
		version = specific.version,
		name = specific.name,
		use_base = specific.use_base,
		fields = {},
	}

	for _, field in ipairs(base.fields) do
		table.insert(schema.fields, field)
	end
	for _, field in ipairs(specific.fields) do
		table.insert(schema.fields, field)
	end

	return schema
end

--- Maps negative integers to positive integers for bit packing. Only works for up to 32 bit integers
--- Generally more efficient than using two's complement
---@param int integer
---@return integer result
local function zigzag_encode(int)
	local unsigned = (int << 1) ~ (int >> 31)

	-- (int << 1) on a negative value will overflow the integer. Masking to handle that case
	return unsigned & INT_MASK
end

--- Maps positive integers to negative integers for bit unpacking. Only works for up to 32 bit integers.
--- Generally more efficient than using two's complement
---@param int integer
---@return integer result
local function zigzag_decode(int)
	return (int >> 1) ~ -(int & 1)
end

local function validate_value_min_max(value, field)
	if field.minimum then
		assert(
			value >= field.minimum,
			field.name
				.. " has a minimum value of ["
				.. tostring(field.minimum)
				.. "] but a value of ["
				.. tostring(value)
				.. "] was used"
		)
	end
	if field.maximum then
		assert(
			value <= field.maximum,
			field.name
				.. " has a maximum value of ["
				.. tostring(field.maximum)
				.. "] but a value of ["
				.. tostring(value)
				.. "] was used"
		)
	end
end

local function validate_number_limits(value, field)
	if field.type == "byte" then
		assert(
			math.type(value) == "integer",
			"Expected byte value for field " .. field.name .. " but received float value [" .. value .. "]"
		)

		if not field.unsigned then
			assert(
				value >= LIMITS.BYTE.SIGNED_LO and value <= LIMITS.BYTE.SIGNED_HI,
				"Expected signed byte ("
					.. LIMITS.BYTE.SIGNED_LO
					.. " - "
					.. LIMITS.BYTE.SIGNED_HI
					.. ") for value ["
					.. value
					.. "] for field "
					.. field.name
			)
		else
			assert(
				value >= 0 and value <= LIMITS.BYTE.UNSIGNED,
				"Expected byte (0 - "
					.. LIMITS.BYTE.UNSIGNED
					.. ") for value ["
					.. value
					.. "] for field "
					.. field.name
			)
		end
	elseif field.type == "short" then
		assert(math.type(value) == "integer", "Expected short value for field " .. field.name .. " but received float.")

		if not field.unsigned then
			assert(
				value >= LIMITS.SHORT.SIGNED_LO and value <= LIMITS.SHORT.SIGNED_HI,
				"Expected signed short ("
					.. LIMITS.SHORT.SIGNED_LO
					.. " - "
					.. LIMITS.SHORT.SIGNED_HI
					.. ") for value ["
					.. value
					.. "] for field "
					.. field.name
			)
		else
			assert(
				value >= 0 and value <= LIMITS.SHORT.UNSIGNED,
				"Expected short (0 - "
					.. LIMITS.SHORT.UNSIGNED
					.. ") for value ["
					.. value
					.. "] for field "
					.. field.name
			)
		end
	elseif field.type == "int" then
		assert(math.type(value) == "integer", "Expected int value for field " .. field.name .. " but received float.")

		if not field.unsigned then
			assert(
				value >= LIMITS.INT.SIGNED_LO and value <= LIMITS.INT.SIGNED_HI,
				"Expected signed integer ("
					.. LIMITS.INT.SIGNED_LO
					.. " - "
					.. LIMITS.INT.SIGNED_HI
					.. ") for value ["
					.. value
					.. "] for field "
					.. field.name
			)
		else
			assert(
				value >= 0 and value <= LIMITS.INT.UNSIGNED,
				"Expected integer (0 - " .. LIMITS.INT.UNSIGNED .. ") for value [" .. value .. "] field " .. field.name
			)
		end
	end
end

---Validates that the value is within the correct size for the given type. Only validates if the field.type is set
---@param value string | number
---@param field Field
local function validate_value(value, field)
	if field.type == "string" then
		assert(type(value) == "string", "Expected string for field " .. field.name)
		return
	elseif field.type == "float" then
		assert(type(value) == "number", "Expected number (float) for field " .. field.name)
		return
	elseif field.type == "bool" then
		assert(type(value) == "boolean", "Expected boolean for field " .. field.name)
		return
	end

	-- Number values
	validate_value_min_max(value, field)
	validate_number_limits(value, field)
end

--- Packs a table that matches a schema in to a single base255, bit packed byte string.
--- Asserts that the length of the data and schema match. Also asserts that data fields match the expected types as described in the schema.
---
--- Strings a compressed using Deflate compression. Each string has a 2 byte length added before the string byte data.
--- Floats are not compressed and are added directly as 4 bytes
--- Integers use zigzag encoding to map negative values to positives for packing.
--- String is Consistent Overhead Byte Stuffing (COBS) encoded to remove null bytes.
--- String is "base255" encoded, using character values for bytes directly, with null bytes removed due to COBS.
---@param schema_id integer Schema ID of the schema that the data is for
---@param data table Data to pack bits for
---@return string packed Byte string with packed data
function W3CData:pack_bits(schema_id, data)
	local schema = self:get_schema_by_id(schema_id)
	assert(
		#data == #schema.fields,
		"Mismatched field count for schema [" .. schema.name .. "], expected: " .. #schema.fields .. ", got: " .. #data
	)

	local result = {}
	local bit_buffer = 0 -- In progress bits for packing
	local bit_count = 0

	-- Writes remaining bit buffer and resets buffer and count.
	local function flush_bits()
		if bit_count > 0 then
			table.insert(result, bit_buffer & 0xFF)
			bit_buffer = 0
			bit_count = 0
		end
	end

	for i, field in ipairs(schema.fields) do
		local value = data[i]

		-- If the field has a type set, validate that the value is within the bit size.
		-- Don't currently check if the type is not set and the bit is set explicitly as I expect
		-- people doing that to know what values are valid and what are not.
		if field.type then
			validate_value(value, field)

			if field.type == "string" then
				-- Don't pack strings, just use LibDeflate to compress them
				-- Small strings will result in larger sizes, but it's easier than dealing with utf-8 variable lengths
				-- Need to flush leftover bits from bit packed fields as string are byte aligned, not bit packed.
				flush_bits()

				-- If we fail to compress for some reason just use an empty string to not break everything else
				local compressed = LibDeflate.CompressDeflate(value) or ""

				-- 2 byte length for strings. A single packet is 255 bytes but we support chunking so 1 byte is not enough
				local len = #compressed
				table.insert(result, (len >> 8) & 0xFF)
				table.insert(result, len & 0xFF)

				for x = 1, len do
					table.insert(result, compressed:byte(x))
				end
			elseif field.type == "float" then
				-- Need to flush leftover bits from bit packed fields as floats are byte aligned, not bit packed.
				flush_bits()

				-- Don't compress floats, not worth the effort or complexity. Just use 4 bytes for them
				local packed = string.pack("f", value)
				for f = 1, #packed do
					table.insert(result, packed:byte(f))
				end
			else
				-- All other values
				if field.type == "bool" then
					value = value and 1 or 0
				end

				-- For signed values we zigzag encode so that we can support both signed and unsigned.
				if not field.unsigned and field.type ~= "bool" then
					value = zigzag_encode(value)
				end

				-- add value and size to buffer and count so we can write until we have less than 1 byte in the buffer.
				bit_buffer = bit_buffer | (value << bit_count)
				bit_count = bit_count + field.num_of_bits

				-- Flush full bytes from bit buffer to output
				while bit_count >= 8 do
					table.insert(result, bit_buffer & 0xFF)

					bit_buffer = bit_buffer >> 8
					bit_count = bit_count - 8
				end
			end
		end
	end

	-- Flush any leftover bits left in the buffer
	if bit_count > 0 then
		table.insert(result, bit_buffer)
	end

	return string.char(table.unpack(result))
end

---Packs a table containing multiple events to be packed together. Uses pack_bits for each individual event in the batch data.
---@param batch_data table<SchemaId, table> Table containing a mapping of event data and schema_ids for that data.
---@return string packed_batch Packed string for all data.
function W3CData:pack_batch(batch_data)
	local result = {}

	for _, entry in ipairs(batch_data) do
		local schema_id = entry[1]
		local data = entry[2]

		local packed = self:pack_bits(schema_id, data)

		-- Schema ID is first byte
		table.insert(result, schema_id)

		-- Write the packed bytes directly
		for i = 1, #packed do
			table.insert(result, packed:byte(i))
		end
	end

	return string.char(table.unpack(result))
end

---@param batch_data table<Payload>
---@return string packed_batch
function W3CData:pack_batch_with_name(batch_data)
	local mapped = {}
	for _, entry in ipairs(batch_data) do
		local schema_id = self:get_schema_id(entry.schema_name)
		table.insert(mapped, { schema_id, entry.payload })
	end

	return self:pack_batch(mapped)
end

--- Unpacks packed bits from using W3CData:pack_bits(). Does everything in reverse.
---@param schema_id SchemaId Schema ID for the data being unpacked. Used to correctly unpack the bits to fields
---@param data string Byte string containing packed data.
---@return table unpacked_data Table containing the unpacked data parsed using the schema
---@return Schema schema The schema that was used to parse the packed data.
function W3CData:unpack_bits(schema_id, data)
	local schema = self:get_schema_by_id(schema_id)
	local result = {}
	local bit_buffer = 0 -- Holds leftover bits from the previous bytes
	local bit_count = 0
	local data_index = 1

	local function get_bits(bits)
		while bit_count < bits do
			-- Fill the buffer with bits
			local byte = data:byte(data_index)

			bit_buffer = bit_buffer | (byte << bit_count)
			bit_count = bit_count + 8
			data_index = data_index + 1
		end

		-- Extract the fields specific bits
		local mask = (1 << bits) - 1
		local value = bit_buffer & mask

		-- Remove extracted fields from the buffer
		bit_buffer = bit_buffer >> bits
		bit_count = bit_count - bits

		return value
	end

	for _, field in ipairs(schema.fields) do
		-- Handle strings by using LibDeflate
		if field.type == "string" then
			-- First 2 bytes are the length of the string
			local len_hi = data:byte(data_index)
			local len_lo = data:byte(data_index + 1)
			local length = (len_hi << 8) | len_lo

			data_index = data_index + 2

			-- Extract and decompress the string
			local string_data = data:sub(data_index, data_index + length - 1)
			local decompressed = LibDeflate.DecompressDeflate(string_data) or ""

			table.insert(result, decompressed)

			data_index = data_index + length
		elseif field.type == "float" then
			-- Floats aren't compressed for now
			-- Read 4 bytes and unpack as float
			local float_bytes = data:sub(data_index, data_index + 3)
			local value = string.unpack("f", float_bytes)

			table.insert(result, value)

			data_index = data_index + 4
		else
			-- All integer types
			local value

			if field.unsigned or field.type == "bool" then
				value = get_bits(field.num_of_bits)
			else
				value = zigzag_decode(get_bits(field.num_of_bits))
			end

			if field.type == "bool" then
				value = (value == 1)
			end

			table.insert(result, value)
		end
	end

	return result, schema
end

--- Unpacks a byte string containing batched packed data. For each event, uses W3CData:unpack_bits() using the schema associated with the event.
---@param packed string The byte string with batched packed data.
---@return table<string, table> unpacked_data A table containing the unpacked data mapped to the schema name used to parse the data.
function W3CData:unpack_batch(packed)
	local index = 1
	local len = #packed
	local result = {}

	while index <= len do
		-- Read first byte. This should be the schema id for the event being parsed
		local schema_id = packed:byte(index)
		index = index + 1

		local schema = self:get_schema_by_id(schema_id)

		local bit_count = 0
		local payload_length = 0
		local bit_buffer_bytes = 0
		local temp_index = index

		-- Calculate how many bytes for this full event
		for _, field in ipairs(schema.fields) do
			if field.type == "string" then
				-- For strings the length is the first 2 bytes of the data
				local len_hi = packed:byte(temp_index)
				local len_lo = packed:byte(temp_index + 1)
				local string_length = (len_hi << 8) | len_lo

				payload_length = payload_length + 2 + string_length

				temp_index = temp_index + 2 + string_length
			elseif field.num_of_bits then
				-- Update byte count of this event so we can update the temp_index correctly for when
				-- we need to get string lengths
				bit_count = bit_count + field.num_of_bits

				local field_bit_bytes = math.ceil(bit_count / 8)
				local bytes_to_add = field_bit_bytes - bit_buffer_bytes

				payload_length = payload_length + bytes_to_add
				temp_index = temp_index + bytes_to_add
				bit_buffer_bytes = field_bit_bytes
			else
				error("Field has no bits or known type: " .. tostring(field.name))
			end
		end

		local end_index = index + payload_length - 1
		assert(end_index <= len, "Truncated event: payload ends beyond packed data")

		local payload = packed:sub(index, end_index)
		local unpacked_values, _ = self:unpack_bits(schema_id, payload)

		table.insert(result, { schema.name, unpacked_values })

		index = end_index + 1
	end

	return result
end

---Splits a byte string in to multiple chunks of max size.
---Each chunk has:
---     chunk_id:     Unique id for matching chunks
---     count:        Total number of chunks for this byte string
---     chunk_index:  Chunk index for the chunk
---     payload:      Chunked byte string
---@param packed_string string Byte string to chunk
---@param max_size integer Maximum size for each chunk
---@param chunk_id integer Unique id for each chunk so they can be matched and unchunked
---@return table<Chunk> chunks Table of chunks for the byte string
function W3CData:chunk_payload(packed_string, max_size, chunk_id)
	local chunks = {}
	local total_length = #packed_string
	local chunk_count = math.ceil(total_length / max_size)

	for i = 0, chunk_count - 1 do
		local start_index = i * max_size + 1
		local end_index = math.min((i + 1) * max_size, total_length)
		local slice = packed_string:sub(start_index, end_index)

		table.insert(chunks, {
			id = chunk_id,
			index = i,
			count = chunk_count,
			payload = slice,
		})
	end

	return chunks
end

---Unchunks multiple chunks to return a single byte string containing packed data.
---@param chunks Chunk[] Chunks to be unchunked
function W3CData:unchunk_payload(chunks)
	assert(#chunks > 0, "No chunks to unchunk")
	table.sort(chunks, function(a, b)
		return a.index < b.index
	end)

	local expected_id = chunks[1].id
	local expected_count = chunks[1].count
	assert(#chunks == expected_count, "Incomplete chunk set")

	for _, chunk in ipairs(chunks) do
		assert(chunk.id == expected_id, "Mismatched chunk id")
	end

	local result = {}
	for _, chunk in ipairs(chunks) do
		table.insert(result, chunk.payload)
	end

	return table.concat(result)
end

---Encodes a table of `Payload`, containing `schema_name` and `event_data`, to a table of encoded strings
---that can be sent using BlzSendSyncData.
---
---Event data that is over the `mx_size` will be chunked to multiple payloads.
---
---@see W3CData.chunk_payload
---@param events table<Payload> Table containing all payload events to encode with their associated schema names
---@param max_size integer Maximum size for a single data packet
---@return table<string>, boolean encoded_payload
function W3CData:encode_payload(events, max_size)
	local result = {}
	local packed = self:pack_batch_with_name(events)

	if #packed <= max_size then
		table.insert(result, string.char(HEADER_VALUES.EVENT) .. packed)
		return result, false
	end

	local id = math.random(1, 65535)
	local chunks = self:chunk_payload(packed, max_size - 5, id)

	for _, chunk in ipairs(chunks) do
		local header =
			string.char(HEADER_VALUES.CHUNK, (chunk.id >> 8) & 0xFF, chunk.id & 0xFF, chunk.count, chunk.index)
		table.insert(result, header .. chunk.payload)
	end

	return result, true
end

---Decodes a byte string containing a header and packed or chunked data to return the parsed event data
function W3CData:decode_payloads(payloads)
	local result = {}

	local chunk_payloads = {}

	for _, sync_data in ipairs(payloads) do
		local first = sync_data:byte(1)
		if (first & HEADER_VALUES.EVENT) ~= 0 then
			local data = sync_data:sub(2)
			for _, unpacked in ipairs(self:unpack_batch(data)) do
				result[#result + 1] = unpacked
			end
		elseif (first & HEADER_VALUES.CHECKSUM) ~= 0 then
			-- Checksums aren't packed as they're just a character string
			local data = sync_data:sub(2)
			result[#result + 1] = self:unpack_bits(INTERNAL_SCHEMA_ID.CHECKSUM, data)
		else
			-- Chunked packet
			local id_hi = sync_data:byte(2)
			local id_lo = sync_data:byte(3)
			local count = sync_data:byte(4)
			local index = sync_data:byte(5)
			local chunk_id = (id_hi << 8) | id_lo
			local payload = sync_data:sub(6)

			chunk_payloads[chunk_id] = chunk_payloads[chunk_id] or {}
			table.insert(chunk_payloads[chunk_id], {
				id = chunk_id,
				count = count,
				index = index,
				payload = payload,
			})
		end
	end

	for _, chunk in pairs(chunk_payloads) do
		local unchunked = self:unchunk_payload(chunk)
		for _, unpacked in ipairs(self:unpack_batch(unchunked)) do
			result[#result + 1] = unpacked
		end
	end

	return result
end

---Parses an unpacked payload containing `{ schema_id, { schema_values }}`
---back to a parsed table in the format `{ schema_name, { schema_field_name = payload_value }}`
---@param unpacked table The payload to unpack and parse
function W3CData:parse_unpacked(unpacked)
	local result = {}
	for _, event in ipairs(unpacked) do
		local unpacked_event = {}

		local schema_id = unpacked_event[1]
		local data = event[2]
		local schema = self:get_schema_by_id(schema_id)
		table.insert(event, schema.name)
		local field_data = {}

		for i, field in ipairs(schema.fields) do
			field_data[field.name] = data[i]
		end
		table.insert(event, field_data)
		table.insert(result, event)
	end
	return result
end

---Generate a checksum packet to be sent.
---@param crc string CRC byte string to be added to a checksum packet
function W3CData:generate_checksum_payload(crc)
	local packed = self:pack_bits(INTERNAL_SCHEMA_ID.CHECKSUM, { crc })
	return string.char(HEADER_VALUES.CHECKSUM) .. packed
end

---Generate payloads containing schema registry. Used so that the schemas can be sent using BlzSendSyncData and
---used to decode and decompress payloads during parsing
---@return table<string> payloads String payloads to send using BlzSendSyncData
function W3CData:generate_registry_payloads()
	local schema_payload = {}
	for _, schema in ipairs(self.schemas) do
		-- Use function so it applies base schema if needed
		schema_payload[#schema_payload + 1] = self:get_schema(schema.name)
	end
	local event = {
		{
			schema_name = INTERNAL_SCHEMA_NAMES.SCHEMA_REGISTRY,
			payload = {
				json.encode(schema_payload),
			},
		},
	}
	local encoded, _ = self:encode_payload(event, 180)
	return encoded
end

return W3CData
