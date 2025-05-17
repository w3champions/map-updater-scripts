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

- Pack an event or batch of events

local schema_id = W3CData:get_schema_id("PlayerState")
local packed W3CData:pack_bits(schema_id, { 50, 50, 0 })       -- { gold, wood, upkeep }

local packed = W3CData:pack_batch({ schema_id, { 50, 50, 0 }, { schema_id, { 60, 60, 0 }} })

- Encode to be sent using BlzSendSyncData

local payload = W3CData:encode_payload(packed)

---
To parse a payload, do the above but in reverse

- Decode data sent
local packed = W3CData:decode_payload(payload)

- Unpack data

local unpacked, schema = W3CData:unpack_bits(packed)

-- For batch data, the events have the schema_id as part of each event, same as when send a batch
local unpacked = W3CData:unpack_batch(packed)

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

0x00      - Singular data packet
0x01      - Batched data packet
0x02      - Checksum packet       -- Use the W3CChecksum utility for updating and getting checksums
0x80      - Chunked packet         

Chunked packets contain additional header data:

[0x80]|[chunk_id_hi]|[chunk_id_lo]|[chunk_count]|[chunk_index]|[payload...]

The chunk_id is a unique id for all associated chunked used for matching.
The chunk count is the number of chunks for this specific set of chunks
The chunk index is this specific packets index in the chunks
The payload is the byte string packed data.

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

-- TODO: Still need to test chunked data
-- TODO: Still need to test overriding bit size values to have more efficient packing
-- TODO: Probably need to update the payload header to also be able to tell if the payload contains batched events or not
-- TODO: Still need to update the event library to use this library and test that it all works inside WC3

require("src.lua.libDeflate")
LibDeflate.InitCompressor()

---@alias FieldType "bool" | "byte" | "short" | "int" | "float" | "string"

---@alias SchemaId integer

---@class Field
---@field name string
---@field type? FieldType
---@field bits? integer
---@field signed? boolean

---@class Schema
---@field version integer
---@field name string
---@field use_base? boolean
---@field fields Field[]

---@class Payload
---@field schema_name string
---@field payload table

---@class SchemaType<string, SchemaId>: { [string]: SchemaId }

---@class BaseSchemaConfig
---@field enabled boolean

---@class W3CDataConfig
---@field base_schema BaseSchemaConfig

---@class Chunk
---@field id integer
---@field index integer
---@field count integer
---@field payload string

local HEADER_VALUES = {
	EVENT = 0x00,
	SCHEMA_REGISTER = 0x01,
	CHECKSUM = 0x02,

	CHUNK = 0x80,
}

local INT_MASK = 0xFFFFFFFF

---@class W3CData
---@field config W3CDataConfig
---@field schemas table<integer, Schema>
local W3CData = {
	config = { base_schema = { enabled = true } },
	schemas = {
		{ version = 0, name = "base", fields = {} },
	},
}

local schema_name_to_id_mapping = { base = 1 }

--- Sets bit values for all types we support. Bit values are used in packing and unpacking
--- If the field.bits field is already set, use that value instead of the default. This is to allow overriding bit sizes for fields
--- when the specific number of bits needed is known.
---@param schema Schema Schema to set bit values for
local function setup_bits_for_field_types(schema)
	for _, field in ipairs(schema.fields) do
		if field.type == "bool" then
			field.bits = field.bits or 1
		elseif field.type == "byte" then
			field.bits = field.bits or 8
		elseif field.type == "short" then
			field.bits = field.bits or 16
		elseif field.type == "int" then
			field.bits = field.bits or 32
		elseif field.type == "float" then
			-- Lua floating numbers are 64 bit but we assume we can safely cast to 32 bit to compress and uncompress.
			-- It's unlikely we'll need to preserve double precision for anything
			field.bits = field.bits or 32
		elseif field.type == "string" then
			-- not used but if not set it breaks parsing bit sizes due to nil field
			field.bits = -1
		end
	end
end

--- Register a schema to be used for compression and decompression.
--- Schemas with the name "base" will be combined with all other schemas if `config.base_schema.enabled = true` and
--- the `schema.use_base = true`
--- Using a base schema is enabled by default for registered schemas.
---@param schema Schema Schema to be registered
function W3CData:register_schema(schema)
	setup_bits_for_field_types(schema)

	-- Base schema is always first
	if schema.name:lower() == "base" then
		self.schemas[1] = schema
		return
	end

	if schema_name_to_id_mapping[schema.name] then
		-- Already exists. Give an error? Overwrite with latest value?
		-- Just return for now
		return
	end

	local schema_id = #self.schemas + 1
	schema.use_base = schema.use_base or true

	self.schemas[schema_id] = schema
	schema_name_to_id_mapping[schema.name] = schema_id
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

--- Combines a schema with a base schema, if the base schema config is enabled, a base schema exists and the target schema
--- has `use_base = true`
---@param schema_id integer id for the schema to combine with the base schema
---@return Schema Schema Combined base and target schema
function W3CData:get_schema_by_id(schema_id)
	if not self.config.base_schema.enabled then
		return self.schemas[schema_id] or {}
	end

	local specific = self.schemas[schema_id] or {}
	if not specific.use_base then
		return specific
	end

	local base = self.schemas[1]

	local schema = {
		version = specific.version,
		name = specific.name,
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
	assert(#data == #schema.fields, "Mismatched field count, expected: " .. #schema.fields .. ", got: " .. #data)

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

		if field.type == "string" then
			-- Don't pack strings, just use LibDeflate to compress them
			-- Small strings will result in larger sizes, but it's easier than dealing with utf-8 variable lengths
			assert(type(value) == "string", "Expected string for field " .. field.name)

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
			assert(type(value) == "number", "Expected number (float) for field " .. field.name)

			-- Need to flush leftover bits from bit packed fields as floats are byte aligned, not bit packed.
			flush_bits()

			-- Don't compress floats, not worth the effort or complexity. Just use 4 bytes for them
			local packed = string.pack("f", value)
			for f = 1, #packed do
				table.insert(result, packed:byte(f))
			end
		else
			local original_value = value
			-- All other integer values
			if field.type == "bool" then
				assert(type(value) == "boolean", "Expected boolean for field " .. field.name)
				value = value and 1 or 0
			else
				assert(type(value) == "number", "Expected number for field " .. field.name)
			end
			local bits = field.bits

			-- For signed values we zigzag encode so that we can support both signed and unsigned.
			-- Default is signed values as assume that negative values aren't that common for our use cases
			if field.signed and field.type ~= "bool" then
				value = zigzag_encode(value)
				-- Need to add an additional bit to handle negative
				bits = bits
			end

			-- add value and size to buffer and count so we can write until we have less than 1 byte in the buffer.
			bit_buffer = bit_buffer | (value << bit_count)
			bit_count = bit_count + bits

			-- Flush full bytes from bit buffer to output
			while bit_count >= 8 do
				table.insert(result, bit_buffer & 0xFF)

				bit_buffer = bit_buffer >> 8
				bit_count = bit_count - 8
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
		table.insert(mapped, { schema_id, entry[2] })
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

			if field.signed then
				value = zigzag_decode(get_bits(field.bits))
			else
				value = get_bits(field.bits)
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
			elseif field.bits then
				-- Update byte count of this event so we can update the temp_index correctly for when
				-- we need to get string lengths
				bit_count = bit_count + field.bits

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
	assert(#chunks == #expected_count, "Incomplete chunk set")

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
---@return string | table<string> encoded_payload
function W3CData:encode_payload(events, max_size)
	local packed = self:pack_batch_with_name(events)

	if #packed <= max_size then
		return string.char(HEADER_VALUES.EVENT) .. packed
	end

	local id = math.random(1, 65535)
	local chunks = self:chunk_payload(packed, max_size - 5, id)
	local result = {}

	for _, chunk in ipairs(chunks) do
		local header = string.char(HEADER_VALUES.CHUNK, (chunk.id >> 8) & 0xFF, chunk.count, chunk.index)
		table.insert(result, header .. chunk.payload)
	end

	return result
end

---Decodes a byte string containing a header and packed or chunked data to return the parsed event data
---@param sync_data string Byte string to decode
---@return string | Chunk, boolean Returns the packed data string if not chunked or a `Chunk` if it is chunked.
---Returns false if not chunked, true if chunked
function W3CData:decode_payload(sync_data)
	local first = sync_data:byte(1)
	if (first & 0x80) == 0 then
		-- Not chunked
		return sync_data:sub(2), false
	end

	-- Chunked packet
	local id_hi = sync_data:byte(2)
	local id_lo = sync_data:byte(3)
	local count = sync_data:byte(4)
	local index = sync_data:byte(5)
	local chunk_id = (id_hi << 8) | id_lo
	local payload = sync_data:sub(6)

	return {
		id = chunk_id,
		count = count,
		index = index,
		payload = payload,
	}, true
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
	return string.char(HEADER_VALUES.CHECKSUM) .. crc
end

return W3CData
