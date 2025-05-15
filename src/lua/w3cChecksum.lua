local CRC32_POLY = 0xEDB88320
local CRC32_TABLE = {}

for i = 0, 255 do
	local crc = i
	for _ = 1, 8 do
		if (crc & 1) ~= 0 then
			crc = (crc >> 1) ~ CRC32_POLY
		else
			crc = crc >> 1
		end
	end
	CRC32_TABLE[i] = crc
end

local W3CChecksum = {}
W3CChecksum.__index = W3CChecksum

---Create new checksum table
function W3CChecksum.new()
	return setmetatable({ crc = 0xFFFFFFFF }, W3CChecksum)
end

---Update the checksum values based on byte string.
---@param data string Byte string that will be used to update the crc values
function W3CChecksum:update(data)
	for i = 1, #data do
		local byte = data:byte(i)
		local index = (self.crc ~ byte) & 0xFF
		self.crc = (self.crc >> 8) ~ CRC32_TABLE[index]
	end
end

---Get the current crc value.
---@return string crc The crc byte string
function W3CChecksum:finalize()
	local final_crc = ~self.crc & 0xFFFFFFFF
	return string.char((final_crc >> 24) & 0xFF, (final_crc >> 16) & 0xFF, (final_crc >> 8) & 0xFF, final_crc & 0xFF)
end

---Get the current CRC value has a hex encoded string
---@return string crc crc string formatted to hex
function W3CChecksum:hex()
	local final_crc = ~self.crc & 0xFFFFFFFF
	return string.format("%08X", final_crc)
end

return W3CChecksum
