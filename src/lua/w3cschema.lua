--[[

Utility for creating data schemas for use by W3CEvents.

Data schemas are used to define the fields for an event created by W3CEvents. These data schemas are used to allow
for efficient data compression of event data.

]]
--

---@alias FieldType "bool" | "byte" | "short" | "int" | "number" | "float" | "string"

local VALID_FIELD_TYPES = {
	bool = true,
	byte = true,
	short = true,
	int = true,
	number = true,
	float = true,
	string = true,
}

local LIMITS = {
	BYTE = { SIGNED_LO = -2 << 7, SIGNED_HI = (2 << 7) - 1, UNSIGNED = (1 << 8) - 1 },
	SHORT = { SIGNED_LO = -2 << 15, SIGNED_HI = (2 << 15) - 1, UNSIGNED = (1 << 16) - 1 },
	INT = { SIGNED_LO = -2 << 31, SIGNED_HI = (2 << 31) - 1, UNSIGNED = (1 << 32) - 1 },
}

---@class W3CField
---@field name string
---@field field_type FieldType
---@field num_of_bits? integer
---@field unsigned? boolean
---@field minimum? number
---@field maximum? number

---@class FieldOptions
---@field num_of_bits? integer
---@field unsigned? boolean
---@field minimum? number
---@field maximum? number

---@class SchemaDefinition
---@field version integer
---@field name string
---@field include_defaults? boolean
---@field fields W3CField[]

---@class Schema
---@field id? integer
---@field version integer
---@field name string
---@field include_defaults boolean
---@field fields W3CField[]

---@class SchemaOptions
---@field version integer
---@field include_defaults boolean

---@class Registry
---@field next_id integer
---@field by_id table<integer, Schema>
---@field by_name table<string, Schema>
local Registry = {}
Registry.__index = Registry

function Registry.new()
	return setmetatable({ next_id = 1, by_id = {}, by_name = {} }, Registry)
end

---Resolves a "number" field to the smallest concrete integer type that fits min/max.
---@param field W3CField
---@return FieldType, boolean unsigned
local function resolve_number_field(field)
	if field.maximum and field.minimum and field.maximum <= field.minimum then
		error(
			field.name
				.. ": maximum ["
				.. tostring(field.maximum)
				.. "] must be > minimum ["
				.. tostring(field.minimum)
				.. "]"
		)
	end

	local unsigned = field.minimum ~= nil and field.minimum >= 0

	if unsigned then
		if field.maximum and field.maximum <= LIMITS.BYTE.UNSIGNED then
			return "byte", true
		end
		if field.maximum and field.maximum <= LIMITS.SHORT.UNSIGNED then
			return "short", true
		end
		return "int", true
	else
		if
			field.minimum
			and field.minimum >= LIMITS.BYTE.SIGNED_LO
			and field.maximum
			and field.maximum <= LIMITS.BYTE.SIGNED_HI
		then
			return "byte", false
		end
		if
			field.minimum
			and field.minimum >= LIMITS.SHORT.SIGNED_LO
			and field.maximum
			and field.maximum <= LIMITS.SHORT.SIGNED_HI
		then
			return "short", false
		end
		return "int", false
	end
end

---Returns the number of bits for a given field type.
---@param field_type FieldType
---@param existing_bits? integer Existing override for "int" fields.
---@return integer
local function bits_for_type(field_type, existing_bits)
	if field_type == "bool" then
		return 1
	end
	if field_type == "byte" then
		return 8
	end
	if field_type == "short" then
		return 16
	end
	if field_type == "int" then
		return existing_bits or 32
	end
	if field_type == "float" then
		return 32
	end
	return 0 -- string
end

---Validates and normalises a raw fields list into a fully-configured field table.
---@param schema_name string Used in error messages.
---@param raw_fields W3CField[]
---@return W3CField[]
local function process_fields(schema_name, raw_fields)
	local fields = {}
	for index, field in ipairs(raw_fields) do
		assert(type(field.name) == "string", "Schema [" .. schema_name .. "] field [" .. index .. "] missing name")
		assert(
			VALID_FIELD_TYPES[field.field_type],
			"Schema ["
				.. schema_name
				.. "] field ["
				.. field.name
				.. "] invalid type ["
				.. tostring(field.field_type)
				.. "]"
		)

		local ft = field.field_type
		local unsigned = field.unsigned or false

		if field.num_of_bits ~= nil then
			assert(
				ft == "int",
				"Schema ["
					.. schema_name
					.. "] field ["
					.. field.name
					.. "] num_of_bits override is only allowed for type 'int'"
			)
			assert(
				math.type(field.num_of_bits) == "integer" and field.num_of_bits >= 1 and field.num_of_bits <= 32,
				"Schema ["
					.. schema_name
					.. "] field ["
					.. field.name
					.. "] num_of_bits must be an integer between 1 and 32"
			)
		end

		if ft == "number" then
			assert(
				field.minimum or field.maximum,
				"Schema [" .. schema_name .. "] field [" .. field.name .. "] type 'number' requires minimum or maximum"
			)
			ft, unsigned = resolve_number_field(field)
		else
			assert(
				field.minimum == nil and field.maximum == nil,
				"Schema ["
					.. schema_name
					.. "] field ["
					.. field.name
					.. "] type '"
					.. ft
					.. "' cannot have minimum or maximum"
			)
		end

		fields[index] = {
			name = field.name,
			field_type = ft,
			num_of_bits = bits_for_type(ft, field.num_of_bits),
			unsigned = unsigned,
			minimum = field.minimum,
			maximum = field.maximum,
		}
	end
	return fields
end

---@param registry Registry
---@param schema_definition SchemaDefinition
---@return integer id, Schema schema
local function _register(registry, schema_definition)
	local id = registry.next_id
	registry.next_id = registry.next_id + 1

	---@type Schema
	local schema = {
		id = id,
		name = schema_definition.name,
		version = schema_definition.version,
		include_defaults = schema_definition.include_defaults ~= false,
		fields = process_fields(schema_definition.name, schema_definition.fields),
	}

	registry.by_id[id] = schema
	registry.by_name[schema_definition.name] = schema

	return id, schema
end

---Registers a new schema, assigning it the next available integer ID.
---@param schema_definition SchemaDefinition
---@return integer id, Schema schema
function Registry:register(schema_definition)
	assert(
		type(schema_definition) == "table" and type(schema_definition.name) == "string",
		"Expected { name = string, version = integer, fields = table }"
	)
	assert(
		type(schema_definition.fields) == "table" and #schema_definition.fields > 0,
		"Schema [" .. schema_definition.name .. "] must have at least one field"
	)
	assert(not self.by_name[schema_definition.name], "Schema [" .. schema_definition.name .. "] already registered")
	return _register(self, schema_definition)
end

---Updates the fields and version of an already-registered schema (e.g. the shared schema).
---@param schema_definition SchemaDefinition
---@return integer id, Schema schema
function Registry:update(schema_definition)
	local existing = self.by_name[schema_definition.name]
	assert(existing, "Cannot update schema [" .. schema_definition.name .. "]: not registered")

	---@type Schema
	local schema = {
		id = existing.id,
		name = schema_definition.name,
		version = schema_definition.version,
		include_defaults = schema_definition.include_defaults ~= false,
		fields = process_fields(schema_definition.name, schema_definition.fields),
	}

	self.by_id[existing.id] = schema
	self.by_name[schema_definition.name] = schema

	return existing.id, schema
end

function Registry:get(id)
	return self.by_id[id]
end
function Registry:get_by_name(n)
	return self.by_name[n]
end
function Registry:has(key)
	return self.by_id[key] ~= nil or self.by_name[key] ~= nil
end

return { Registry = Registry }
