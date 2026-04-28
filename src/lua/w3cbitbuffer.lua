require("src.lua.libDeflate")

---@class Writer
---@field buffer table
---@field current integer
---@field num_of_bits integer
local Writer = {}
Writer.__index = Writer

---@class Reader
---@field data string
---@field index integer
---@field current integer
---@field num_of_bits integer
local Reader = {}
Reader.__index = Reader

local INT_MASK = 0xFFFFFFFF

-----------------------------
--- Writer ------------------
-----------------------------

function Writer.new()
	LibDeflate.InitCompressor()
	return setmetatable({ buffer = {}, current = 0, num_of_bits = 0 }, Writer)
end

function Writer:unsigned(value, num_of_bits)
	while num_of_bits > 0 do
		local room = 8 - self.num_of_bits
		local take = (num_of_bits < room) and num_of_bits or room
		local mask = (1 << take) - 1

		self.current = self.current | ((value & mask) << self.num_of_bits)
		self.num_of_bits = self.num_of_bits + take

		value = value >> take
		num_of_bits = num_of_bits - take

		if self.num_of_bits == 8 then
			self.buffer[#self.buffer + 1] = string.char(self.current)
			self.current, self.num_of_bits = 0, 0
		end
	end
end

function Writer:signed(value, num_of_bits)
	local zigzag = (value << 1) ~ (value >> (num_of_bits - 1))
	-- mask to prevent value wrapping as value << 1 on a negative will overflow
	self:unsigned(zigzag & INT_MASK, num_of_bits)
end

function Writer:bool(value)
	self:unsigned(value and 1 or 0, 1)
end

function Writer:float(value)
	if self.num_of_bits > 0 then
		self.buffer[#self.buffer + 1] = string.char(self.current)
		self.current, self.num_of_bits = 0, 0
	end

	self.buffer[#self.buffer + 1] = string.pack("f", value)
end

function Writer:string(value)
	if self.num_of_bits > 0 then
		self.buffer[#self.buffer + 1] = string.char(self.current)
		self.current, self.num_of_bits = 0, 0
	end

	local compressed = LibDeflate.CompressDeflate(value) or ""
	local length = #compressed

	self.buffer[#self.buffer + 1] = string.char((length >> 8) & 0xFF)
	self.buffer[#self.buffer + 1] = string.char(length & 0xFF)

	self.buffer[#self.buffer + 1] = compressed
end

function Writer:flush()
	if self.num_of_bits > 0 then
		self.buffer[#self.buffer + 1] = string.char(self.current)
	end

	local result = table.concat(self.buffer)
	self.buffer, self.current, self.num_of_bits = {}, 0, 0

	return result
end

-----------------------------
--- Reader ------------------
-----------------------------

function Reader.new(str)
	return setmetatable({ data = str, index = 1, current = 0, num_of_bits = 0 }, Reader)
end

function Reader:_next_byte()
	-- If mid bit stream, consume a fresh byte first
	if self.num_of_bits == 0 then
		local byte = self.data:byte(self.index)
		self.index = self.index + 1
		return byte
	else
		local byte = self:unsigned(8)
		return byte
	end
end

function Reader:unsigned(num_of_bits)
	local value, shift = 0, 0
	while num_of_bits > 0 do
		if self.num_of_bits == 0 then
			self.current = self.data:byte(self.index) or 0
			self.index = self.index + 1
			self.num_of_bits = 8
		end

		local take = (num_of_bits < self.num_of_bits) and num_of_bits or self.num_of_bits
		value = value | ((self.current & ((1 << take) - 1)) << shift)
		self.current = self.current >> take
		self.num_of_bits = self.num_of_bits - take
		num_of_bits, shift = num_of_bits - take, shift + take
	end

	return value
end

function Reader:signed(num_of_bits)
	local zigzag = self:unsigned(num_of_bits)
	local sign = zigzag & 1
	return (zigzag >> 1) ~ -sign
end

function Reader:bool()
	return self:unsigned(1) == 1
end

function Reader:float()
	self.num_of_bits = 0
	local value
	value, self.index = string.unpack("f", self.data, self.index)
	return value
end

function Reader:string()
	self.num_of_bits = 0

	local hi = self:_next_byte()
	local lo = self:_next_byte()
	local length = (hi << 8) | lo

	local compressed = self.data:sub(self.index, self.index + length - 1)
	self.index = self.index + length

	local ok, decoded = pcall(LibDeflate.DecompressDeflate, compressed)
	return ok and decoded or ""
end

return {
	Writer = Writer,
	Reader = Reader,
}
