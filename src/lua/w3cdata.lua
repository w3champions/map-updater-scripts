--[[

Library to encode and decode schema-based event payloads for BlzSendSyncData.

This library is the low-level transport layer used by higher-level helpers such as
`W3CEvents`. It is responsible for schema registration, bit-packing payloads,
chunking oversized packets, generating checksum/schema-registry payloads, and
decoding received SyncData back into schema/value tuples.

Basic Usage:

- Initialize the library and register one or more schemas

W3CData.init()

W3CData:register_schema({
  version = 1,
  name = "PlayerState",
  fields = {
    { name = "gold", field_type = "int" },
    { name = "wood", field_type = "int" },
    { name = "upkeep", field_type = "byte" },
  },
})

- Create payloads to send. Each payload entry is `{ schema_name = ..., payload = { ... } }`
- and payload values are positional, in schema field order.

local payloads = W3CData:encode_payload({
  {
    schema_name = "PlayerState",
    payload = { 50, 100, 0 },
  },
}, 180)

---
To parse received payloads, use `W3CData:decode_payloads`.

- Decode data sent
local unpacked = W3CData:decode_payloads(payloads)
local parsed = W3CData:parse_unpacked(unpacked)

--------

Schemas are in the format:

{
  version:    integer,
  name:       string,
  include_defaults?: boolean,
  fields: [
    {
      name:        string,
      field_type:  "bool" | "byte" | "short" | "int" | "number" | "float" | "string",
      num_of_bits?: integer,
      unsigned?:   boolean,
      minimum?:    number,
      maximum?:    number,
    }
  ]
}

`num_of_bits` is only valid for `"int"` fields. For `"number"` fields, the schema
registry resolves the field to the smallest concrete integer type that satisfies the
provided `minimum`/`maximum` bounds.

Bit sizes are assigned automatically when registering a schema:

- bool:   1 bit
- byte:   8 bits
- short:  16 bits
- int:    32 bits by default, or `num_of_bits` if provided
- float:  32 bits, not overridable

String values are not bit-packed.

Floats use 4 bytes. 64-bit floats are converted to 32-bit floats, losing precision.
Strings have a 2-byte length prefix and are stored as raw bytes.

If `num_of_bits` is set on an `"int"` field, it overrides the default 32-bit width.

Signed integer fields are zigzag encoded. Unsigned integer fields are written directly.
**NOTE** If a field can hold negative values, do not mark it `unsigned = true`.

--------

Each packet has a 1-byte header that identifies whether the packet is:

0x01      - Event packet containing one or more packed events
0x02      - Checksum packet
0x80      - Chunked event packet

Chunked packets contain additional header data:

[0x80]|[chunk_id_hi]|[chunk_id_lo]|[chunk_count]|[chunk_index]|[payload...]

The chunk_id is a unique id shared by every chunk in the same payload.
The chunk count is the total number of chunks in that payload.
The chunk index is the zero-based index of this chunk.
The payload is raw packed event data for that chunk.

--------

NOTE: The below is not necessary to use unless you really want to minimize the amount of data being used.

Overriding bit sizes for schemas is possible by setting `field.num_of_bits` on `"int"` fields.
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

local json = require("lua.json")
require("lua.libDeflate")

local bitbuffer = require("lua.w3cbitbuffer")
local schema_module = require("lua.w3cschema")

---@alias FieldName string
---@alias SchemaId integer

---@alias PayloadFieldValue string | number | boolean
---@alias PayloadValue table<FieldName, PayloadFieldValue>

---@class Payload Payload entry to be packed into an event packet.
---@field schema_name string Name of the schema that the payload is for
---@field payload table Payload values in schema field order

---@class SharedSchemaConfig Config for W3CData shared schema
---@field enabled boolean Whether using the shared schema is enabled or not

---@class W3CDataConfig Config for W3CData
---@field shared_schema SharedSchemaConfig Config for shared schema

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
		SIGNED_LO = (-1 << 7),
		SIGNED_HI = (1 << 7) - 1,
		UNSIGNED = (1 << 8) - 1,
	},
	SHORT = {
		SIGNED_LO = (-1 << 15),
		SIGNED_HI = (1 << 15) - 1,
		UNSIGNED = (1 << 16) - 1,
	},
	INT = {
		SIGNED_LO = (-1 << 31),
		SIGNED_HI = (1 << 31) - 1,
		UNSIGNED = (1 << 32) - 1,
	},
}

--These need to match the indexes of the schemas.
local INTERNAL_SCHEMA_ID = {
	SCHEMA = 1,
	CHECKSUM = 2,
	SHARED = 3,
}

local INTERNAL_SCHEMA_NAMES = {
	SCHEMA_REGISTRY = "schema_registry",
	CHECKSUM = "checksum",
	SHARED = "shared",
}

---@class W3CData
---@field config W3CDataConfig
local W3CData = {
	config = { shared_schema = { enabled = true } },
}

local next_chunk_id = 1

-- Internal schema registry. IDs must match INTERNAL_SCHEMA_ID constants.
-- SCHEMA(1) and CHECKSUM(2) are registered normally; SHARED(3) starts with no fields
-- and is populated when the user calls register_schema({name="shared", ...}).
local registry = schema_module.Registry.new()

local function init_registry()
	registry = schema_module.Registry.new()

	registry:register({
		name = INTERNAL_SCHEMA_NAMES.SCHEMA_REGISTRY,
		version = 1,
		include_defaults = false,
		fields = { { name = "schemas_blob", field_type = "string" } },
	})
	registry:register({
		name = INTERNAL_SCHEMA_NAMES.CHECKSUM,
		version = 1,
		include_defaults = false,
		fields = { { name = "checksum", field_type = "string" } },
	})

	local _shared_placeholder = {
		id = INTERNAL_SCHEMA_ID.SHARED,
		name = INTERNAL_SCHEMA_NAMES.SHARED,
		version = 0,
		include_defaults = false,
		fields = {},
	}
	registry.by_id[INTERNAL_SCHEMA_ID.SHARED] = _shared_placeholder
	registry.by_name[INTERNAL_SCHEMA_NAMES.SHARED] = _shared_placeholder
	registry.next_id = 4
end

local bit_writer = bitbuffer.Writer.new()

LibDeflate.InitCompressor()

---@param config? W3CDataConfig
function W3CData.init(config)
	W3CData.config = config or { shared_schema = { enabled = true } }
	next_chunk_id = 1
	init_registry()
end

---@return integer
local function allocate_chunk_id()
	local chunk_id = next_chunk_id
	next_chunk_id = next_chunk_id + 1
	if next_chunk_id > 65535 then
		next_chunk_id = 1
	end
	return chunk_id
end

--- Register a schema to be used for compression and decompression.
--- Schemas with the name "shared" will be combined with all other schemas if `config.shared_schema.enabled = true` and
--- the `schema.include_defaults = true`
--- Including default fields is enabled by default for registered schemas.
---@param schema Schema Schema to be registered
---@return boolean success True if the schema could be registered, false if it failed
function W3CData:register_schema(schema)
	assert(schema.name, "Schemas require a name to be set")
	assert(schema.version, "Schemas require a version to be set")
	assert(schema.name ~= INTERNAL_SCHEMA_NAMES.CHECKSUM, "Setting schema for checksum is not allowed")
	assert(schema.name ~= INTERNAL_SCHEMA_NAMES.SCHEMA_REGISTRY, "Setting schema for schema_registry is not allowed")

	if schema.name:lower() == INTERNAL_SCHEMA_NAMES.SHARED then
		registry:update(schema)
		return true
	end

	if registry:get_by_name(schema.name) then
		return false
	end

	registry:register(schema)
	return true
end

--- Registers multiple schemas to be used for compression and decompression.
---@param schemas Schema[]
---@return table<string,boolean> result Table that contains the name of each schema and whether they were successfully registered or not
function W3CData:register_all_schemas(schemas)
	local result = {}
	for _, schema in ipairs(schemas) do
		if self:register_schema(schema) then
			result[schema.name] = true
		else
			result[schema.name] = false
		end
	end

	return result
end

--- Gets a schema id given a schema name.
---@param schema_name string Name of the schema to get an id for
---@return integer schema_id Id of the schema if it's been registered, otherwise nil
function W3CData:get_schema_id(schema_name)
	local s = registry:get_by_name(schema_name)
	return s and s.id
end

---Returns the total number of registered schemas.
---@return integer
function W3CData:schema_count()
	return registry.next_id - 1
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
	return registry:has(schema_name)
end

---Checks whether a schema should include the default fields
---@param schema_name string Name of the schema to check
---@return boolean should_include_defaults True if the schema should include the default fields, false if not
function W3CData:should_include_defaults(schema_name)
	if type(schema_name) == "string" and schema_name:lower() == INTERNAL_SCHEMA_NAMES.SHARED then
		return false
	end

	local schema = registry:get_by_name(schema_name)
	return (self.config.shared_schema.enabled and schema and schema.include_defaults) and true or false
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

--- Gets a schema by id. Includes shared fields when the shared schema feature is enabled
--- and the specific schema has `include_defaults = true`.
---@param schema_id integer Id of the schema to get
---@return Schema schema Schema including shared fields when applicable
function W3CData:get_schema_by_id(schema_id)
	local specific = registry:get(schema_id) or {}

	if not self.config.shared_schema.enabled or not specific.include_defaults then
		return specific
	end

	local shared = registry:get(INTERNAL_SCHEMA_ID.SHARED)

	local schema = {
		version = specific.version,
		name = specific.name,
		include_defaults = specific.include_defaults,
		id = specific.id,
		fields = {},
	}

	for _, field in ipairs(shared.fields) do
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

---@param field W3CField
---@return integer, integer
local function get_integer_limits(field)
	local bits = field.num_of_bits

	if field.field_type == "byte" then
		if field.unsigned then
			return 0, LIMITS.BYTE.UNSIGNED
		end
		return LIMITS.BYTE.SIGNED_LO, LIMITS.BYTE.SIGNED_HI
	elseif field.field_type == "short" then
		if field.unsigned then
			return 0, LIMITS.SHORT.UNSIGNED
		end
		return LIMITS.SHORT.SIGNED_LO, LIMITS.SHORT.SIGNED_HI
	elseif field.field_type == "int" then
		if field.unsigned then
			if bits >= 32 then
				return 0, LIMITS.INT.UNSIGNED
			end
			return 0, (1 << bits) - 1
		end

		if bits >= 32 then
			return LIMITS.INT.SIGNED_LO, LIMITS.INT.SIGNED_HI
		end

		local max = (1 << (bits - 1)) - 1
		return -1 - max, max
	end

	error("Unsupported integer field type: " .. tostring(field.field_type))
end

---@param field W3CField
local function validate_number_limits(value, field)
	local min_value, max_value = get_integer_limits(field)

	if field.field_type == "byte" then
		assert(
			math.type(value) == "integer",
			"Expected byte value for field " .. field.name .. " but received float value [" .. value .. "]"
		)

		assert(
			value >= min_value and value <= max_value,
			"Expected "
				.. (field.unsigned and "unsigned" or "signed")
				.. " byte ("
				.. min_value
				.. " - "
				.. max_value
				.. ") for value ["
				.. value
				.. "] for field "
				.. field.name
		)
	elseif field.field_type == "short" then
		assert(math.type(value) == "integer", "Expected short value for field " .. field.name .. " but received float.")

		assert(
			value >= min_value and value <= max_value,
			"Expected "
				.. (field.unsigned and "unsigned" or "signed")
				.. " short ("
				.. min_value
				.. " - "
				.. max_value
				.. ") for value ["
				.. value
				.. "] for field "
				.. field.name
		)
	elseif field.field_type == "int" then
		assert(math.type(value) == "integer", "Expected int value for field " .. field.name .. " but received float.")

		assert(
			value >= min_value and value <= max_value,
			"Expected "
				.. (field.unsigned and "unsigned" or "signed")
				.. " integer ("
				.. min_value
				.. " - "
				.. max_value
				.. ") for value ["
				.. value
				.. "] for field "
				.. field.name
		)
	end
end

---Validates that the value is within the correct size for the given type. Only validates if the field.type is set
---@param value string | number
---@param field W3CField
local function validate_value(value, field)
	if field.field_type == "string" then
		assert(type(value) == "string", "Expected string for field " .. field.name)
		return
	elseif field.field_type == "float" then
		assert(type(value) == "number", "Expected number (float) for field " .. field.name)
		return
	elseif field.field_type == "bool" then
		assert(type(value) == "boolean", "Expected boolean for field " .. field.name)
		return
	end

	-- Number values
	validate_value_min_max(value, field)
	validate_number_limits(value, field)
end

--- Packs a positional payload table into a raw bit-packed byte string for a schema id.
--- Asserts that the payload length matches the schema field count and that values match
--- the expected field types and bounds.
---
--- Strings are written with a 2-byte length prefix.
--- Floats are stored as 4 bytes (32-bit). Integers use zigzag encoding for signed values.
--- COBS encoding (null byte removal for safe BlzSendSyncData transmission) is applied later
--- by `encode_payload` and `generate_checksum_payload`, not here.
---@param schema_id integer Schema ID of the schema that the data is for
---@param data table Payload values in schema field order
---@return string packed Byte string with packed data
function W3CData:pack_bits(schema_id, data)
	bit_writer:reset()
	local schema = self:get_schema_by_id(schema_id)
	assert(
		#data == #schema.fields,
		"Mismatched field count for schema [" .. schema.name .. "], expected: " .. #schema.fields .. ", got: " .. #data
	)

	for i, field in ipairs(schema.fields) do
		local value = data[i]
		validate_value(value, field)

		if field.field_type == "string" then
			bit_writer:string(value)
		elseif field.field_type == "float" then
			bit_writer:float(value)
		elseif field.field_type == "bool" then
			bit_writer:bool(value)
		elseif field.unsigned then
			bit_writer:unsigned(value, field.num_of_bits)
		else
			bit_writer:signed(value, field.num_of_bits)
		end
	end

	return bit_writer:flush()
end

--- Packs multiple schema-id/payload pairs into a single byte string.
---@param batch_data table<SchemaId, table> Table of `{ schema_id, payload }` entries.
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

local REGISTRY_BLOB_MAGIC = "W3CSR"
local REGISTRY_BLOB_FORMAT = 1

local FIELD_TYPE_CODES = {
	bool = 1,
	byte = 2,
	short = 3,
	int = 4,
	float = 5,
	string = 6,
}

local FIELD_TYPES_BY_CODE = {}
for field_type, code in pairs(FIELD_TYPE_CODES) do
	FIELD_TYPES_BY_CODE[code] = field_type
end

local FIELD_FLAG_UNSIGNED = 1
local FIELD_FLAG_HAS_MINIMUM = 2
local FIELD_FLAG_HAS_MAXIMUM = 4

local function write_u8(buffer, value)
	assert(value >= 0 and value <= 255, "Value does not fit in u8: " .. tostring(value))
	buffer[#buffer + 1] = string.char(value)
end

local function write_u16(buffer, value)
	assert(value >= 0 and value <= 65535, "Value does not fit in u16: " .. tostring(value))
	buffer[#buffer + 1] = string.char((value >> 8) & 0xFF, value & 0xFF)
end

local function write_i32(buffer, value)
	assert(math.type(value) == "integer", "Registry min/max values must be integers")
	assert(value >= LIMITS.INT.SIGNED_LO and value <= LIMITS.INT.SIGNED_HI, "Value does not fit in i32")
	if value < 0 then
		value = (1 << 32) + value
	end
	buffer[#buffer + 1] = string.char((value >> 24) & 0xFF, (value >> 16) & 0xFF, (value >> 8) & 0xFF, value & 0xFF)
end

local function read_u8(data, index)
	return data:byte(index), index + 1
end

local function read_u16(data, index)
	local hi = data:byte(index)
	local lo = data:byte(index + 1)
	return (hi << 8) | lo, index + 2
end

local function read_i32(data, index)
	local b1 = data:byte(index)
	local b2 = data:byte(index + 1)
	local b3 = data:byte(index + 2)
	local b4 = data:byte(index + 3)
	local value = (b1 << 24) | (b2 << 16) | (b3 << 8) | b4
	if value >= (1 << 31) then
		value = value - (1 << 32)
	end
	return value, index + 4
end

local function write_string_u8(buffer, value)
	assert(#value <= 255, "Registry string is too long: " .. value)
	write_u8(buffer, #value)
	buffer[#buffer + 1] = value
end

local function read_string_u8(data, index)
	local length
	length, index = read_u8(data, index)
	local value = data:sub(index, index + length - 1)
	return value, index + length
end

local function registry_schemas(data)
	local schema_payload = {}
	local ids = {}
	for id in pairs(registry.by_id) do
		ids[#ids + 1] = id
	end
	table.sort(ids)
	assert(#ids <= 255, "Schema registry has more than 255 schemas")
	for _, id in ipairs(ids) do
		-- Apply shared schema merging via get_schema so the payload reflects what decoders will see
		schema_payload[#schema_payload + 1] = data:get_schema(registry.by_id[id].name)
	end
	return schema_payload
end

local function encode_registry_blob(schemas)
	local buffer = { REGISTRY_BLOB_MAGIC }
	write_u8(buffer, REGISTRY_BLOB_FORMAT)
	write_u8(buffer, #schemas)

	for _, schema in ipairs(schemas) do
		write_u8(buffer, schema.id)
		write_u16(buffer, schema.version)
		write_u8(buffer, schema.include_defaults and 1 or 0)
		write_string_u8(buffer, schema.name)
		write_u8(buffer, #schema.fields)

		for _, field in ipairs(schema.fields) do
			local flags = 0
			if field.unsigned then
				flags = flags | FIELD_FLAG_UNSIGNED
			end
			if field.minimum ~= nil then
				flags = flags | FIELD_FLAG_HAS_MINIMUM
			end
			if field.maximum ~= nil then
				flags = flags | FIELD_FLAG_HAS_MAXIMUM
			end

			write_u8(buffer, FIELD_TYPE_CODES[field.field_type])
			write_u8(buffer, field.num_of_bits or 0)
			write_u8(buffer, flags)
			write_string_u8(buffer, field.name)
			if field.minimum ~= nil then
				write_i32(buffer, field.minimum)
			end
			if field.maximum ~= nil then
				write_i32(buffer, field.maximum)
			end
		end
	end

	return table.concat(buffer)
end

local function decode_registry_blob(blob)
	assert(blob:sub(1, #REGISTRY_BLOB_MAGIC) == REGISTRY_BLOB_MAGIC, "Invalid registry blob")
	local index = #REGISTRY_BLOB_MAGIC + 1
	local format
	format, index = read_u8(blob, index)
	assert(format == REGISTRY_BLOB_FORMAT, "Unsupported registry blob format: " .. tostring(format))

	local schema_count
	schema_count, index = read_u8(blob, index)
	local schemas = {}

	for schema_index = 1, schema_count do
		local schema = { fields = {} }
		schema.id, index = read_u8(blob, index)
		schema.version, index = read_u16(blob, index)
		local include_defaults
		include_defaults, index = read_u8(blob, index)
		schema.include_defaults = include_defaults ~= 0
		schema.name, index = read_string_u8(blob, index)

		local field_count
		field_count, index = read_u8(blob, index)
		for field_index = 1, field_count do
			local type_code
			local flags
			local field = {}
			type_code, index = read_u8(blob, index)
			field.field_type = FIELD_TYPES_BY_CODE[type_code]
			field.num_of_bits, index = read_u8(blob, index)
			flags, index = read_u8(blob, index)
			field.unsigned = (flags & FIELD_FLAG_UNSIGNED) ~= 0
			field.name, index = read_string_u8(blob, index)
			if (flags & FIELD_FLAG_HAS_MINIMUM) ~= 0 then
				field.minimum, index = read_i32(blob, index)
			end
			if (flags & FIELD_FLAG_HAS_MAXIMUM) ~= 0 then
				field.maximum, index = read_i32(blob, index)
			end
			schema.fields[field_index] = field
		end

		schemas[schema_index] = schema
	end

	return schemas
end

--- Unpacks packed bits from using W3CData:pack_bits(). Does everything in reverse.
---@param schema_id SchemaId Schema ID for the data being unpacked. Used to correctly unpack the bits to fields
---@param data string Byte string containing packed data.
---@return table unpacked_data Table containing the unpacked data parsed using the schema
---@return Schema schema The schema that was used to parse the packed data.
function W3CData:unpack_bits(schema_id, data)
	local bit_reader = bitbuffer.Reader.new(data)
	local schema = self:get_schema_by_id(schema_id)
	local result = {}

	for _, field in ipairs(schema.fields) do
		if field.field_type == "string" then
			table.insert(result, bit_reader:string())
		elseif field.field_type == "float" then
			table.insert(result, bit_reader:float())
		elseif field.field_type == "bool" then
			table.insert(result, bit_reader:bool())
		else
			if field.unsigned then
				table.insert(result, bit_reader:unsigned(field.num_of_bits))
			else
				table.insert(result, bit_reader:signed(field.num_of_bits))
			end
		end
	end

	return result, schema
end

--- Unpacks a byte string containing one or more packed events.
--- For each event, the leading schema id byte is used to select the schema for `unpack_bits`.
---@param packed string The byte string with batched packed data.
---@return table<string, table> unpacked_data A table of `{ schema_name, positional_values }` tuples.
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
			if field.field_type == "string" then
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

--- Encodes one or more payload entries to SyncData-safe packet strings.
---
--- If the packed event data exceeds `max_size`, it is split into chunk packets.
---
---@see W3CData.chunk_payload
---@param events table<Payload> Table containing all payload events to encode with their associated schema names
---@param max_size integer Maximum size for a single data packet
---@return table<string> encoded_payload
---@return boolean is_chunked True when the packed event data was chunked into multiple packets
function W3CData:encode_payload(events, max_size)
	local result = {}
	local packed = self:pack_batch_with_name(events)

	if #packed <= max_size then
		table.insert(result, W3CData.cobs_encode(string.char(HEADER_VALUES.EVENT) .. packed))
		return result, false
	end

	local id = allocate_chunk_id()
	local chunks = self:chunk_payload(packed, max_size - 5, id)

	for _, chunk in ipairs(chunks) do
		local header =
			string.char(HEADER_VALUES.CHUNK, (chunk.id >> 8) & 0xFF, chunk.id & 0xFF, chunk.count, chunk.index)
		table.insert(result, W3CData.cobs_encode(header .. chunk.payload))
	end

	return result, true
end

--- Decodes one or more SyncData payload strings into unpacked event tuples.
--- Event packets return `{ schema_name, positional_values }` entries.
--- Checksum packets return the unpacked checksum payload values.
---@param payloads string[] SyncData payload strings, optionally including chunked packets
---@return table decoded Unpacked event tuples in receive order, with chunk groups appended once complete
function W3CData:decode_payloads(payloads)
	local result = {}

	local chunk_payloads = {}
	local chunk_order = {}

	for _, sync_data in ipairs(payloads) do
		sync_data = W3CData.cobs_decode(sync_data)
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

			if not chunk_payloads[chunk_id] then
				chunk_payloads[chunk_id] = {}
				chunk_order[#chunk_order + 1] = chunk_id
			end
			table.insert(chunk_payloads[chunk_id], {
				id = chunk_id,
				count = count,
				index = index,
				payload = payload,
			})
		end
	end

	for _, chunk_id in ipairs(chunk_order) do
		local chunk = chunk_payloads[chunk_id]
		local unchunked = self:unchunk_payload(chunk)
		for _, unpacked in ipairs(self:unpack_batch(unchunked)) do
			result[#result + 1] = unpacked
		end
	end

	return result
end

--- Converts unpacked positional payload tuples into keyed field tables.
--- Input entries are expected to be in the format `{ schema_name, positional_values }`.
--- Output entries are returned as `{ schema_name, { field_name = payload_value } }`.
---@param unpacked table The unpacked payload tuples to parse
---@return table parsed Parsed payload entries keyed by schema field name
function W3CData:parse_unpacked(unpacked)
	local result = {}
	for _, event in ipairs(unpacked) do
		local schema_name = event[1]
		local data = event[2]
		local schema = self:get_schema(schema_name)
		local field_data = {}
		for i, field in ipairs(schema.fields) do
			field_data[field.name] = data[i]
		end
		table.insert(result, { schema_name, field_data })
	end
	return result
end

--- Generates a checksum packet to be sent via BlzSendSyncData.
---@param crc string CRC byte string to be added to a checksum packet
---@return string payload COBS-encoded checksum packet
function W3CData:generate_checksum_payload(crc)
	local packed = self:pack_bits(INTERNAL_SCHEMA_ID.CHECKSUM, { crc })
	return W3CData.cobs_encode(string.char(HEADER_VALUES.CHECKSUM) .. packed)
end

--- Generates schema registry packets so receivers can reconstruct the schema set used by this encoder.
--- The generated registry includes internal schemas as well as any user-registered schemas, with shared
--- fields already merged into schemas that include defaults.
---@return table<string> payloads String payloads to send using BlzSendSyncData
function W3CData:generate_registry_payloads()
	local schema_payload = registry_schemas(self)
	local blob = encode_registry_blob(schema_payload)
	local compressed_blob = LibDeflate.CompressDeflate(blob)
	local event = {
		{
			schema_name = INTERNAL_SCHEMA_NAMES.SCHEMA_REGISTRY,
			payload = {
				compressed_blob,
			},
		},
	}
	local encoded, _ = self:encode_payload(event, 180)
	return encoded
end

--- Decodes schema registry packets generated by `generate_registry_payloads`.
---@param payloads string[] String payloads received through SyncData
---@return Schema[] schemas Decoded schema definitions
function W3CData:decode_registry_payloads(payloads)
	local decoded = self:decode_payloads(payloads)
	assert(#decoded == 1, "Expected exactly one schema registry payload")
	assert(decoded[1][1] == INTERNAL_SCHEMA_NAMES.SCHEMA_REGISTRY, "Expected schema registry payload")
	local compressed_blob = decoded[1][2][1]
	local blob = LibDeflate.DecompressDeflate(compressed_blob)
	assert(blob, "Failed to decompress schema registry payload")
	return decode_registry_blob(blob)
end

--- Returns byte-size stats for the current compact schema registry.
---@return table stats Registry size statistics
function W3CData:registry_payload_stats()
	local payloads = self:generate_registry_payloads()
	local total_bytes = 0
	local largest_packet_bytes = 0
	for _, payload in ipairs(payloads) do
		total_bytes = total_bytes + #payload
		if #payload > largest_packet_bytes then
			largest_packet_bytes = #payload
		end
	end

	local compact_blob = encode_registry_blob(registry_schemas(self))
	local compressed_blob = LibDeflate.CompressDeflate(compact_blob)
	local legacy_json = json.encode(registry_schemas(self))
	return {
		packet_count = #payloads,
		total_encoded_bytes = total_bytes,
		largest_packet_bytes = largest_packet_bytes,
		compact_blob_bytes = #compact_blob,
		compressed_blob_bytes = #compressed_blob,
		legacy_json_bytes = #legacy_json,
	}
end

return W3CData
