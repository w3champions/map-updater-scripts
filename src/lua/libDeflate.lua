if Debug and Debug.beginFile then Debug.beginFile('LibDeflate') end
--[[

Adaptation of LibDeflate v1.08

(C) ModdieMads @ https://www.hiveworkshop.com/members/moddiemads.310879/

This software is provided 'as-is', without any express or implied
warranty.  In no event will the authors be held liable for any damages
arising from the use of this software.

Permission is granted to anyone to use this software for any purpose,
including commercial applications, and to alter it and redistribute it
freely, subject to the following restrictions:

1. The origin of this software must not be misrepresented; you must not
   claim that you wrote the original software. If you use this software
   in a product, an acknowledgment in the product documentation would be
   appreciated but is not required.
2. Altered source versions must be plainly marked as such, and must not be
   misrepresented as being the original software.
3. This notice may not be removed or altered from any source distribution.

LibDeflate
Pure Lua compressor and decompressor with high compression ratio using
DEFLATE/zlib format.

(C) 2018-2021 Haoqian He

zlib License
This software is provided 'as-is', without any express or implied
warranty.  In no event will the authors be held liable for any damages
arising from the use of this software.

Permission is granted to anyone to use this software for any purpose,
including commercial applications, and to alter it and redistribute it
freely, subject to the following restrictions:

1. The origin of this software must not be misrepresented; you must not
   claim that you wrote the original software. If you use this software
   in a product, an acknowledgment in the product documentation would be
   appreciated but is not required.
2. Altered source versions must be plainly marked as such, and must not be
   misrepresented as being the original software.
3. This notice may not be removed or altered from any source distribution.

License History:
1. GNU General Public License Version 3 in v1.0.0 and earlier versions.
2. GNU Lesser General Public License Version 3 in v1.0.1
3. the zlib License since v1.0.2

]]

do
	LibDeflate = {}
	-- localize Lua api for faster access.
	-- this is highly unecessary, but here we go...
	local assert = assert
	local error = error
	local pairs = pairs

	local string_byte = string.byte
	local string_char = string.char

	local string_sub = string.sub
	local table_concat = table.concat
	local table_sort = table.sort
	
	local math_fmod = math.fmod;
	local fmod = function(v,mod) return (math_fmod(v,mod) + .5)//1 end;

	-- Converts i to 2^i
	-- This is used to implement bit left shift and bit right shift.
	-- "x << y" in C:	 "x*_pow2[y]" in Lua
	local _pow2 = {}

	-- Converts any byte to a character, (0<=byte<=255)
	local _byte_to_char = {}

	-- _reverseBitsTbl[len][val] stores the bit reverse of
	-- the number with bit length "len" and value "val"
	-- For example, decimal number 6 with bits length 5 is binary 00110
	-- It's reverse is binary 01100,
	-- which is decimal 12 and 12 == _reverseBitsTbl[5][6]
	-- 1<=len<=9, 0<=val<=2^len-1
	-- The reason for 1<=len<=9 is that the max of min bitlen of huffman code
	-- of a huffman alphabet is 9?
	local _reverse_bits_tbl = {}

	-- Convert a LZ77 length (3<=len<=258) to
	-- a deflate literal,LZ77_length code (257<=code<=285)
	local _length_to_deflate_code = {}

	-- convert a LZ77 length (3<=len<=258) to
	-- a deflate literal,LZ77_length code extra bits.
	local _length_to_deflate_extra_bits = {}

	-- Convert a LZ77 length (3<=len<=258) to
	-- a deflate literal,LZ77_length code extra bit length.
	local _length_to_deflate_extra_bitlen = {}

	-- Convert a small LZ77 distance (1<=dist<=256) to a deflate code.
	local _dist256_to_deflate_code = {}

	-- Convert a small LZ77 distance (1<=dist<=256) to
	-- a deflate distance code extra bits.
	local _dist256_to_deflate_extra_bits = {}

	-- Convert a small LZ77 distance (1<=dist<=256) to
	-- a deflate distance code extra bit length.
	local _dist256_to_deflate_extra_bitlen = {}

	-- Convert a literal,LZ77_length deflate code to LZ77 base length
	-- The key of the table is (code - 256), 257<=code<=285
	local _literal_deflate_code_to_base_len =
		{
			3, 4, 5, 6, 7, 8, 9, 10, 11, 13, 15, 17, 19, 23, 27, 31, 35, 43, 51, 59, 67,
			83, 99, 115, 131, 163, 195, 227, 258
		}

	-- Convert a literal,LZ77_length deflate code to base LZ77 length extra bits
	-- The key of the table is (code - 256), 257<=code<=285
	local _literal_deflate_code_to_extra_bitlen =
		{
			0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 4, 4, 4, 4, 5,
			5, 5, 5, 0
		}

	-- Convert a distance deflate code to base LZ77 distance. (0<=code<=29)
	local _dist_deflate_code_to_base_dist = {
		[0] = 1,
		2,
		3,
		4,
		5,
		7,
		9,
		13,
		17,
		25,
		33,
		49,
		65,
		97,
		129,
		193,
		257,
		385,
		513,
		769,
		1025,
		1537,
		2049,
		3073,
		4097,
		6145,
		8193,
		12289,
		16385,
		24577
	}

	-- Convert a distance deflate code to LZ77 bits length. (0<=code<=29)
	local _dist_deflate_code_to_extra_bitlen =
		{
			[0] = 0,
			0,
			0,
			0,
			1,
			1,
			2,
			2,
			3,
			3,
			4,
			4,
			5,
			5,
			6,
			6,
			7,
			7,
			8,
			8,
			9,
			9,
			10,
			10,
			11,
			11,
			12,
			12,
			13,
			13
		}

	-- The code order of the first huffman header in the dynamic deflate block.
	-- See the page 12 of RFC1951
	local _rle_codes_huffman_bitlen_order = {
		16, 17, 18, 0, 8, 7, 9, 6, 10, 5, 11, 4, 12, 3, 13, 2, 14, 1, 15
	}

	-- The following tables are used by fixed deflate block.
	-- The value of these tables are assigned at the bottom of the source.

	-- The huffman code of the literal,LZ77_length deflate codes,
	-- in fixed deflate block.
	local _fix_block_literal_huffman_code

	-- Convert huffman code of the literal,LZ77_length to deflate codes,
	-- in fixed deflate block.
	local _fix_block_literal_huffman_to_deflate_code

	-- The bit length of the huffman code of literal,LZ77_length deflate codes,
	-- in fixed deflate block.
	local _fix_block_literal_huffman_bitlen

	-- The count of each bit length of the literal,LZ77_length deflate codes,
	-- in fixed deflate block.
	local _fix_block_literal_huffman_bitlen_count

	-- The huffman code of the distance deflate codes,
	-- in fixed deflate block.
	local _fix_block_dist_huffman_code

	-- Convert huffman code of the distance to deflate codes,
	-- in fixed deflate block.
	local _fix_block_dist_huffman_to_deflate_code

	-- The bit length of the huffman code of the distance deflate codes,
	-- in fixed deflate block.
	local _fix_block_dist_huffman_bitlen

	-- The count of each bit length of the huffman code of
	-- the distance deflate codes,
	-- in fixed deflate block.
	local _fix_block_dist_huffman_bitlen_count

	--- Calculate the Adler-32 checksum of the string. <br>

	-- definition of Adler-32 checksum.
	-- @param str [string] the input string to calcuate its Adler-32 checksum.
	-- @return [integer] The Adler-32 checksum, which is greater or equal to 0,
	-- and less than 2^32 (4294967296).
	function LibDeflate.Adler32(str)
		-- This function is loop unrolled by better performance.
		--
		-- Here is the minimum code:

		local strlen = #str

		local i = 1
		local a = 1
		local b = 0
		while i <= strlen - 15 do
			local x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16 = string_byte(str, i, i + 15)
			b = fmod(b + 16 * a + 16 * x1 + 15 * x2 + 14 * x3 + 13 * x4 + 12 * x5 + 11 * x6 +
					10 * x7 + 9 * x8 + 8 * x9 + 7 * x10 + 6 * x11 + 5 * x12 + 4 * x13 + 3 *
					x14 + 2 * x15 + x16, 65521);
			a = fmod(a + x1 + x2 + x3 + x4 + x5 + x6 + x7 + x8 + x9 + x10 + x11 + x12 + x13 +
					x14 + x15 + x16, 65521);
			i = i + 16
		end
		while (i <= strlen) do
			local x = string_byte(str, i, i)
			a = fmod((a + x), 65521)
			b = fmod((b + a), 65521)
			i = i + 1
		end
		return fmod((b * 65536 + a), 4294967296)
	end

	-- Compare adler32 checksum.
	-- adler32 should be compared with a mod to avoid sign problem
	-- 4072834167 (unsigned) is the same adler32 as -222133129
	function LibDeflate.IsEqualAdler32(actual, expected)
		return fmod(actual, 4294967296) == fmod(expected, 4294967296)
	end

	local _compression_level_configs = {
		[0] = {false, nil, 0, 0, 0}, -- level 0, no compression
		[1] = {false, nil, 4, 8, 4}, -- level 1, similar to zlib level 1
		[2] = {false, nil, 5, 18, 8}, -- level 2, similar to zlib level 2
		[3] = {false, nil, 6, 32, 32}, -- level 3, similar to zlib level 3
		[4] = {true, 4, 4, 16, 16}, -- level 4, similar to zlib level 4
		[5] = {true, 8, 16, 32, 32}, -- level 5, similar to zlib level 5
		[6] = {true, 8, 16, 128, 128}, -- level 6, similar to zlib level 6
		[7] = {true, 8, 32, 128, 256}, -- (SLOW) level 7, similar to zlib level 7
		[8] = {true, 32, 128, 258, 1024}, -- (SLOW) level 8,similar to zlib level 8
		[9] = {true, 32, 258, 258, 4096}
		-- (VERY SLOW) level 9, similar to zlib level 9
	}
	-- partial flush to save memory
	local _FLUSH_MODE_MEMORY_CLEANUP = 0
	-- full flush with partial bytes
	local _FLUSH_MODE_OUTPUT = 1
	-- write bytes to get to byte boundary
	local _FLUSH_MODE_BYTE_BOUNDARY = 2
	-- no flush, just get num of bits written so far
	local _FLUSH_MODE_NO_FLUSH = 3

	--[[
		Create an empty writer to easily write stuffs as the unit of bits.
		Return values:
		1. WriteBits(code, bitlen):
		2. WriteString(str):
		3. Flush(mode):
	--]]
	local function CreateWriter()
		local buffer_size = 0
		local cache = 0
		local cache_bitlen = 0
		local total_bitlen = 0
		local buffer = {}
		-- When buffer is big enough, flush into result_buffer to save memory.
		local result_buffer = {}

		-- Write bits with value "value" and bit length of "bitlen" into writer.
		-- @param value: The value being written
		-- @param bitlen: The bit length of "value"
		-- @return nil
		local function WriteBits(value, bitlen)
			cache = cache + value * _pow2[cache_bitlen]

			cache_bitlen = cache_bitlen + bitlen
			total_bitlen = total_bitlen + bitlen
			-- Only bulk to buffer every 4 bytes. This is quicker.
			if cache_bitlen >= 16 then
				buffer_size = buffer_size + 1
				buffer[buffer_size] = _byte_to_char[cache&255] .. _byte_to_char[(((cache - (cache&255))) >> 8)&255]

				local rshift_mask = _pow2[16 - cache_bitlen + bitlen]

				cache = (value - (value&(rshift_mask-1))) >> (16 - cache_bitlen + bitlen)
				cache_bitlen = cache_bitlen - 16
			end
		end

		-- Write the entire string into the writer.
		-- @param str The string being written
		-- @return nil
		local function WriteString(str)
			for _ = 1, cache_bitlen, 8 do
				buffer_size = buffer_size + 1
				buffer[buffer_size] = string_char((cache&255))
				cache = (cache - (cache&255)) >> 8;
			end
			cache_bitlen = 0
			buffer_size = buffer_size + 1
			buffer[buffer_size] = str
			total_bitlen = total_bitlen + #str * 8
		end

		-- Flush current stuffs in the writer and return it.
		-- This operation will free most of the memory.
		-- @param mode See the descrtion of the constant and the source code.
		-- @return The total number of bits stored in the writer right now.
		-- for byte boundary mode, it includes the padding bits.
		-- for output mode, it does not include padding bits.
		-- @return Return the outputs if mode is output.
		local function FlushWriter(mode)
			if mode == _FLUSH_MODE_NO_FLUSH then return total_bitlen end

			if mode == _FLUSH_MODE_OUTPUT or mode == _FLUSH_MODE_BYTE_BOUNDARY then
				-- Full flush, also output cache.
				-- Need to pad some bits if cache_bitlen is not multiple of 8.
				local padding_bitlen = ((8 - (cache_bitlen&7))&7)

				if cache_bitlen > 0 then
					-- padding with all 1 bits, mainly because "\000" is not
					-- good to be tranmitted. I do this so "\000" is a little bit
					-- less frequent.
					cache = cache - _pow2[cache_bitlen] + _pow2[cache_bitlen + padding_bitlen]

					for _ = 1, cache_bitlen, 8 do
						buffer_size = buffer_size + 1
						buffer[buffer_size] = _byte_to_char[(cache&255)];
						cache = (cache - (cache&255)) >> 8;
					end

					cache = 0
					cache_bitlen = 0
				end

				if mode == _FLUSH_MODE_BYTE_BOUNDARY then
					total_bitlen = total_bitlen + padding_bitlen
					return total_bitlen
				end
			end

			local flushed = table_concat(buffer)
			buffer = {}
			buffer_size = 0
			result_buffer[#result_buffer + 1] = flushed

			if mode == _FLUSH_MODE_MEMORY_CLEANUP then
				return total_bitlen
			else
				return total_bitlen, table_concat(result_buffer)
			end
		end

		return WriteBits, WriteString, FlushWriter
	end

	-- Push an element into a max heap
	-- @param heap A max heap whose max element is at index 1.
	-- @param e The element to be pushed. Assume element "e" is a table
	--	and comparison is done via its first entry e[1]
	-- @param heap_size current number of elements in the heap.
	--	NOTE: There may be some garbage stored in
	--	heap[heap_size+1], heap[heap_size+2], etc..
	-- @return nil
	local function MinHeapPush(heap, e, heap_size)
		heap_size = heap_size + 1
		heap[heap_size] = e
		local value = e[1]
		local pos = heap_size
		local parent_pos = (pos - (pos&1)) >> 1

		while (parent_pos >= 1 and heap[parent_pos][1] > value) do
			local t = heap[parent_pos]
			heap[parent_pos] = e
			heap[pos] = t
			pos = parent_pos
			parent_pos = (parent_pos - (parent_pos&1)) >> 1
		end
	end

	-- Pop an element from a max heap
	-- @param heap A max heap whose max element is at index 1.
	-- @param heap_size current number of elements in the heap.
	-- @return the poped element
	-- Note: This function does not change table size of "heap" to save CPU time.
	local function MinHeapPop(heap, heap_size)
		local top = heap[1]
		local e = heap[heap_size]
		local value = e[1]
		heap[1] = e
		heap[heap_size] = top
		heap_size = heap_size - 1

		local pos = 1
		local left_child_pos = pos * 2
		local right_child_pos = left_child_pos + 1

		while (left_child_pos <= heap_size) do
			local left_child = heap[left_child_pos]
			if (right_child_pos <= heap_size and heap[right_child_pos][1] < left_child[1]) then
				local right_child = heap[right_child_pos]
				if right_child[1] < value then
					heap[right_child_pos] = e
					heap[pos] = right_child
					pos = right_child_pos
					left_child_pos = pos * 2
					right_child_pos = left_child_pos + 1
				else
					break
				end
			else
				if left_child[1] < value then
					heap[left_child_pos] = e
					heap[pos] = left_child
					pos = left_child_pos
					left_child_pos = pos * 2
					right_child_pos = left_child_pos + 1
				else
					break
				end
			end
		end

		return top
	end

	-- Deflate defines a special huffman tree, which is unique once the bit length
	-- of huffman code of all symbols are known.
	-- @param bitlen_count Number of symbols with a specific bitlen
	-- @param symbol_bitlen The bit length of a symbol
	-- @param max_symbol The max symbol among all symbols,
	--		which is (number of symbols - 1)
	-- @param max_bitlen The max huffman bit length among all symbols.
	-- @return The huffman code of all symbols.
	local function GetHuffmanCodeFromBitlen(bitlen_counts, symbol_bitlens, max_symbol, max_bitlen)
		local huffman_code = 0
		local next_codes = {}
		local symbol_huffman_codes = {}
		for bitlen = 1, max_bitlen do
			huffman_code = (huffman_code + (bitlen_counts[bitlen - 1] or 0)) * 2
			next_codes[bitlen] = huffman_code
		end
		for symbol = 0, max_symbol do
			local bitlen = symbol_bitlens[symbol]
			if bitlen then
				huffman_code = next_codes[bitlen]
				next_codes[bitlen] = huffman_code + 1

				-- Reverse the bits of huffman code,
				-- because most signifant bits of huffman code
				-- is stored first into the compressed data.
				-- @see RFC1951 Page5 Section 3.1.1
				if bitlen <= 9 then -- Have cached reverse for small bitlen.
					symbol_huffman_codes[symbol] = _reverse_bits_tbl[bitlen][huffman_code]
				else
					local reverse = 0
					for _ = 1, bitlen do
						reverse = reverse - (reverse&1) + ((((reverse&1) == 1) or ((huffman_code&1)) == 1) and 1 or 0)
						huffman_code = (huffman_code - (huffman_code&1)) >> 1
						reverse = reverse * 2
					end
					symbol_huffman_codes[symbol] = (reverse - (reverse&1)) >> 1
				end
			end
		end
		return symbol_huffman_codes
	end

	-- A helper function to sort heap elements
	-- a[1], b[1] is the huffman frequency
	-- a[2], b[2] is the symbol value.
	local function SortByFirstThenSecond(a, b)
		return a[1] < b[1] or (a[1] == b[1] and a[2] < b[2])
	end

	-- Calculate the huffman bit length and huffman code.
	-- @param symbol_count: A table whose table key is the symbol, and table value
	--		is the symbol frenquency (nil means 0 frequency).
	-- @param max_bitlen: See description of return value.
	-- @param max_symbol: The maximum symbol
	-- @return a table whose key is the symbol, and the value is the huffman bit
	--		bit length. We guarantee that all bit length <= max_bitlen.
	--		For 0<=symbol<=max_symbol, table value could be nil if the frequency
	--		of the symbol is 0 or nil.
	-- @return a table whose key is the symbol, and the value is the huffman code.
	-- @return a number indicating the maximum symbol whose bitlen is not 0.
	local function GetHuffmanBitlenAndCode(symbol_counts, max_bitlen, max_symbol)
		local heap_size
		local max_non_zero_bitlen_symbol = -1
		local leafs = {}
		local heap = {}
		local symbol_bitlens = {}
		local symbol_codes = {}
		local bitlen_counts = {}

		--[[
			tree[1]: weight, temporarily used as parent and bitLengths
			tree[2]: symbol
			tree[3]: left child
			tree[4]: right child
		--]]
		local number_unique_symbols = 0
		for symbol, count in pairs(symbol_counts) do
			number_unique_symbols = number_unique_symbols + 1
			leafs[number_unique_symbols] = {count, symbol}
		end

		if (number_unique_symbols == 0) then
			-- no code.
			return {}, {}, -1
		elseif (number_unique_symbols == 1) then
			-- Only one code. In this case, its huffman code
			-- needs to be assigned as 0, and bit length is 1.
			-- This is the only case that the return result
			-- represents an imcomplete huffman tree.
			local symbol = leafs[1][2]
			symbol_bitlens[symbol] = 1
			symbol_codes[symbol] = 0
			return symbol_bitlens, symbol_codes, symbol
		else
			table_sort(leafs, SortByFirstThenSecond)
			heap_size = number_unique_symbols
			for i = 1, heap_size do heap[i] = leafs[i] end

			while (heap_size > 1) do
				-- Note: pop does not change table size of heap
				local leftChild = MinHeapPop(heap, heap_size)
				heap_size = heap_size - 1
				local rightChild = MinHeapPop(heap, heap_size)
				heap_size = heap_size - 1
				local newNode = {leftChild[1] + rightChild[1], -1, leftChild, rightChild}
				MinHeapPush(heap, newNode, heap_size)
				heap_size = heap_size + 1
			end

			-- Number of leafs whose bit length is greater than max_len.
			local number_bitlen_overflow = 0

			-- Calculate bit length of all nodes
			local fifo = {heap[1], 0, 0, 0} -- preallocate some spaces.
			local fifo_size = 1
			local index = 1
			heap[1][1] = 0
			while (index <= fifo_size) do -- Breath first search
				local e = fifo[index]
				local bitlen = e[1]
				local symbol = e[2]
				local left_child = e[3]
				local right_child = e[4]
				if left_child then
					fifo_size = fifo_size + 1
					fifo[fifo_size] = left_child
					left_child[1] = bitlen + 1
				end
				if right_child then
					fifo_size = fifo_size + 1
					fifo[fifo_size] = right_child
					right_child[1] = bitlen + 1
				end
				index = index + 1

				if (bitlen > max_bitlen) then
					number_bitlen_overflow = number_bitlen_overflow + 1
					bitlen = max_bitlen
				end
				if symbol >= 0 then
					symbol_bitlens[symbol] = bitlen
					max_non_zero_bitlen_symbol = (symbol > max_non_zero_bitlen_symbol) and symbol or max_non_zero_bitlen_symbol
					bitlen_counts[bitlen] = (bitlen_counts[bitlen] or 0) + 1
				end
			end

			-- Resolve bit length overflow
			-- @see ZLib/trees.c:gen_bitlen(s, desc), for reference
			if (number_bitlen_overflow > 0) then
				repeat
					local bitlen = max_bitlen - 1
					while ((bitlen_counts[bitlen] or 0) == 0) do bitlen = bitlen - 1 end
					-- move one leaf down the tree
					bitlen_counts[bitlen] = bitlen_counts[bitlen] - 1
					-- move one overflow item as its brother
					bitlen_counts[bitlen + 1] = (bitlen_counts[bitlen + 1] or 0) + 2
					bitlen_counts[max_bitlen] = bitlen_counts[max_bitlen] - 1
					number_bitlen_overflow = number_bitlen_overflow - 2
				until (number_bitlen_overflow <= 0)

				index = 1
				for bitlen = max_bitlen, 1, -1 do
					local n = bitlen_counts[bitlen] or 0
					while (n > 0) do
						local symbol = leafs[index][2]
						symbol_bitlens[symbol] = bitlen
						n = n - 1
						index = index + 1
					end
				end
			end

			symbol_codes = GetHuffmanCodeFromBitlen(bitlen_counts, symbol_bitlens, max_symbol, max_bitlen)

			return symbol_bitlens, symbol_codes, max_non_zero_bitlen_symbol
		end
	end

	-- Calculate the first huffman header in the dynamic huffman block
	-- @see RFC1951 Page 12
	-- @param lcode_bitlen: The huffman bit length of literal,LZ77_length.
	-- @param max_non_zero_bitlen_lcode: The maximum literal,LZ77_length symbol
	--		whose huffman bit length is not zero.
	-- @param dcode_bitlen: The huffman bit length of LZ77 distance.
	-- @param max_non_zero_bitlen_dcode: The maximum LZ77 distance symbol
	--		whose huffman bit length is not zero.
	-- @return The run length encoded codes.
	-- @return The extra bits. One entry for each rle code that needs extra bits.
	--		(code == 16 or 17 or 18).
	-- @return The count of appearance of each rle codes.
	local function RunLengthEncodeHuffmanBitlen(lcode_bitlens, max_non_zero_bitlen_lcode, dcode_bitlens, max_non_zero_bitlen_dcode)
		local rle_code_tblsize = 0
		local rle_codes = {}
		local rle_code_counts = {}
		local rle_extra_bits_tblsize = 0
		local rle_extra_bits = {}
		local prev = nil
		local count = 0

		-- If there is no distance code, assume one distance code of bit length 0.
		-- RFC1951: One distance code of zero bits means that
		-- there are no distance codes used at all (the data is all literals).
		max_non_zero_bitlen_dcode = (max_non_zero_bitlen_dcode < 0) and 0 or max_non_zero_bitlen_dcode
		local max_code = max_non_zero_bitlen_lcode + max_non_zero_bitlen_dcode + 1

		for code = 0, max_code + 1 do
			local len = (code <= max_non_zero_bitlen_lcode) and
										(lcode_bitlens[code] or 0) or ((code <= max_code) and
										(dcode_bitlens[code - max_non_zero_bitlen_lcode - 1] or 0) or
										nil)
			if len == prev then
				count = count + 1
				if len ~= 0 and count == 6 then
					rle_code_tblsize = rle_code_tblsize + 1
					rle_codes[rle_code_tblsize] = 16
					rle_extra_bits_tblsize = rle_extra_bits_tblsize + 1
					rle_extra_bits[rle_extra_bits_tblsize] = 3
					rle_code_counts[16] = (rle_code_counts[16] or 0) + 1
					count = 0
				elseif len == 0 and count == 138 then
					rle_code_tblsize = rle_code_tblsize + 1
					rle_codes[rle_code_tblsize] = 18
					rle_extra_bits_tblsize = rle_extra_bits_tblsize + 1
					rle_extra_bits[rle_extra_bits_tblsize] = 127
					rle_code_counts[18] = (rle_code_counts[18] or 0) + 1
					count = 0
				end
			else
				if count == 1 then
					rle_code_tblsize = rle_code_tblsize + 1
					rle_codes[rle_code_tblsize] = prev
					rle_code_counts[prev] = (rle_code_counts[prev] or 0) + 1
				elseif count == 2 then
					rle_code_tblsize = rle_code_tblsize + 1
					rle_codes[rle_code_tblsize] = prev
					rle_code_tblsize = rle_code_tblsize + 1
					rle_codes[rle_code_tblsize] = prev
					rle_code_counts[prev] = (rle_code_counts[prev] or 0) + 2
				elseif count >= 3 then
					rle_code_tblsize = rle_code_tblsize + 1
					local rleCode = (prev ~= 0) and 16 or (count <= 10 and 17 or 18)
					rle_codes[rle_code_tblsize] = rleCode
					rle_code_counts[rleCode] = (rle_code_counts[rleCode] or 0) + 1
					rle_extra_bits_tblsize = rle_extra_bits_tblsize + 1
					rle_extra_bits[rle_extra_bits_tblsize] =
						(count <= 10) and (count - 3) or (count - 11)
				end

				prev = len
				if len and len ~= 0 then
					rle_code_tblsize = rle_code_tblsize + 1
					rle_codes[rle_code_tblsize] = len
					rle_code_counts[len] = (rle_code_counts[len] or 0) + 1
					count = 0
				else
					count = 1
				end
			end
		end

		return rle_codes, rle_extra_bits, rle_code_counts
	end

	-- Load the string into a table, in order to speed up LZ77.
	-- Loop unrolled 16 times to speed this function up.
	-- @param str The string to be loaded.
	-- @param t The load destination
	-- @param start str[index] will be the first character to be loaded.
	-- @param end str[index] will be the last character to be loaded
	-- @param offset str[index] will be loaded into t[index-offset]
	-- @return t
	local function LoadStringToTable(str, t, start, stop, offset)

		local i = start - offset

		while i <= stop - 15 - offset do
			t[i], t[i + 1], t[i + 2], t[i + 3], t[i + 4], t[i + 5], t[i + 6], t[i + 7], t[i + 8], t[i + 9], t[i + 10],
			t[i + 11], t[i + 12], t[i + 13], t[i + 14], t[i +15] = string_byte(str, i + offset, i + 15 + offset)
			i = i + 16
		end
		while (i <= stop - offset) do
			t[i] = string_byte(str, i + offset, i + offset)

			i = i + 1
		end
		return t
	end


-- Do LZ77 process. This function uses the majority of the CPU time.
-- @see zlib/deflate.c:deflate_fast(), zlib/deflate.c:deflate_slow()

-- This function uses the algorithms used above. You should read the
-- algorithm.txt above to understand what is the hash function and the
-- lazy evaluation.
--
-- The special optimization used here is hash functions used here.
-- The hash function is just the multiplication of the three consective
-- characters. So if the hash matches, it guarantees 3 characters are matched.
-- This optimization can be implemented because Lua table is a hash table.
--
-- @param level integer that describes compression level.
-- @param string_table table that stores the value of string to be compressed.
--			The index of this table starts from 1.
--			The caller needs to make sure all values needed by this function
--			are loaded.
--			Assume "str" is the origin input string into the compressor
--			str[block_start]..str[block_end+3] needs to be loaded into
--			string_table[block_start-offset]..string_table[block_end-offset]
--			If dictionary is presented, the last 258 bytes of the dictionary
--			needs to be loaded into sing_table[-257..0]
--			(See more in the description of offset.)
-- @param hash_tables. The table key is the hash value (0<=hash<=16777216=256^3)
--			The table value is an array0 that stores the indexes of the
--			input data string to be compressed, such that
--			hash == str[index]*str[index+1]*str[index+2]
--			Indexes are ordered in this array.
-- @param block_start The indexes of the input data string to be compressed.
--				that starts the LZ77 block.
-- @param block_end The indexes of the input data string to be compressed.
--				that stores the LZ77 block.
-- @param offset str[index] is stored in string_table[index-offset],
--			This offset is mainly an optimization to limit the index
--			of string_table, so lua can access this table quicker.
-- @param dictionary See LibDeflate:CreateDictionary
-- @return literal,LZ77_length deflate codes.
-- @return the extra bits of literal,LZ77_length deflate codes.
-- @return the count of each literal,LZ77 deflate code.
-- @return LZ77 distance deflate codes.
-- @return the extra bits of LZ77 distance deflate codes.
-- @return the count of each LZ77 distance deflate code.
	local function GetBlockLZ77Result(level, string_table, hash_tables, block_start, block_end, offset)--, dictionary)
		local config = _compression_level_configs[level]
		local config_use_lazy, config_good_prev_length, config_max_lazy_match,
					config_nice_length, config_max_hash_chain = config[1], config[2], config[3], config[4], config[5]

		local config_max_insert_length = (not config_use_lazy) and config_max_lazy_match or 2147483646
		local config_good_hash_chain = (config_max_hash_chain - ((config_max_hash_chain&3) >> 2))

		local hash

		local dict_hash_tables
		local dict_string_table

		local dict_string_len_plus3 = 3

		hash = (string_table[block_start - offset] or 0) * 256 + (string_table[block_start + 1 - offset] or 0)

		local lcodes = {}
		local lcode_tblsize = 0
		local lcodes_counts = {}
		local dcodes = {}
		local dcodes_tblsize = 0
		local dcodes_counts = {}

		local lextra_bits = {}
		local lextra_bits_tblsize = 0
		local dextra_bits = {}
		local dextra_bits_tblsize = 0

		local match_available = false
		local prev_len
		local prev_dist
		local cur_len = 0
		local cur_dist = 0

		local index = block_start
		local index_end = block_end + (config_use_lazy and 1 or 0)

		-- the zlib source code writes separate code for lazy evaluation and
		-- not lazy evaluation, which is easier to understand.
		-- I put them together, so it is a bit harder to understand.
		-- because I think this is easier for me to maintain it.
		while (index <= index_end) do
			local string_table_index = index - offset
			local offset_minus_three = offset - 3
			prev_len = cur_len
			prev_dist = cur_dist
			cur_len = 0

			hash = (hash * 256 + (string_table[string_table_index + 2] or 0)) & 16777215

			local chain_index
			local cur_chain
			local hash_chain = hash_tables[hash]
			local chain_old_size
			if not hash_chain then
				chain_old_size = 0
				hash_chain = {}
				hash_tables[hash] = hash_chain
				if dict_hash_tables then
					cur_chain = dict_hash_tables[hash]
					chain_index = cur_chain and #cur_chain or 0
				else
					chain_index = 0
				end
			else
				chain_old_size = #hash_chain
				cur_chain = hash_chain
				chain_index = chain_old_size
			end

			if index <= block_end then hash_chain[chain_old_size + 1] = index end

			if (chain_index > 0 and index + 2 <= block_end and (not config_use_lazy or prev_len < config_max_lazy_match)) then

				local depth = (config_use_lazy and prev_len >= config_good_prev_length) and config_good_hash_chain or config_max_hash_chain

				local max_len_minus_one = block_end - index
				max_len_minus_one = (max_len_minus_one >= 257) and 257 or max_len_minus_one

				max_len_minus_one = max_len_minus_one + string_table_index
				local string_table_index_plus_three = string_table_index + 3

				while chain_index >= 1 and depth > 0 do
					local prev = cur_chain[chain_index]

					if index - prev > 32768 then break end
					if prev < index then
						local sj = string_table_index_plus_three

						if prev >= -257 then
							local pj = prev - offset_minus_three
							while (sj <= max_len_minus_one and string_table[pj] == string_table[sj]) do
								sj = sj + 1
								pj = pj + 1
							end
						else
							local pj = dict_string_len_plus3 + prev
						end
						local j = sj - string_table_index
						if j > cur_len then
							cur_len = j
							cur_dist = index - prev
						end
						if cur_len >= config_nice_length then break end
					end

					chain_index = chain_index - 1
					depth = depth - 1
					if chain_index == 0 and prev > 0 and dict_hash_tables then
						cur_chain = dict_hash_tables[hash]
						chain_index = cur_chain and #cur_chain or 0
					end
				end
			end

			if not config_use_lazy then prev_len, prev_dist = cur_len, cur_dist end

			if ((not config_use_lazy or match_available) and (prev_len > 3 or (prev_len == 3 and prev_dist < 4096)) and cur_len <= prev_len) then

				local code = _length_to_deflate_code[prev_len]
				local length_extra_bits_bitlen = _length_to_deflate_extra_bitlen[prev_len]
				local dist_code, dist_extra_bits_bitlen, dist_extra_bits
				if prev_dist <= 256 then -- have cached code for small distance.
					dist_code = _dist256_to_deflate_code[prev_dist]
					dist_extra_bits = _dist256_to_deflate_extra_bits[prev_dist]
					dist_extra_bits_bitlen = _dist256_to_deflate_extra_bitlen[prev_dist]
				else
					dist_code = 16
					dist_extra_bits_bitlen = 7
					local a = 384
					local b = 512

					while true do
						if prev_dist <= a then
							dist_extra_bits = (prev_dist - (b >> 1) - 1) & ((b >> 2)-1)
							break
						elseif prev_dist <= b then
							dist_extra_bits = (prev_dist - (b >> 1) - 1) & ((b >> 2)-1)
							dist_code = dist_code + 1
							break
						else
							dist_code = dist_code + 2
							dist_extra_bits_bitlen = dist_extra_bits_bitlen + 1
							a = a * 2
							b = b * 2
						end
					end
				end
				lcode_tblsize = lcode_tblsize + 1
				lcodes[lcode_tblsize] = code
				lcodes_counts[code] = (lcodes_counts[code] or 0) + 1

				dcodes_tblsize = dcodes_tblsize + 1
				dcodes[dcodes_tblsize] = dist_code
				dcodes_counts[dist_code] = (dcodes_counts[dist_code] or 0) + 1

				if length_extra_bits_bitlen > 0 then
					local lenExtraBits = _length_to_deflate_extra_bits[prev_len]
					lextra_bits_tblsize = lextra_bits_tblsize + 1
					lextra_bits[lextra_bits_tblsize] = lenExtraBits
				end
				if dist_extra_bits_bitlen > 0 then
					dextra_bits_tblsize = dextra_bits_tblsize + 1
					dextra_bits[dextra_bits_tblsize] = dist_extra_bits
				end

				for i = index + 1, index + prev_len - (config_use_lazy and 2 or 1) do
					hash = (hash * 256 + (string_table[i - offset + 2] or 0)) & 16777215
					if prev_len <= config_max_insert_length then
						hash_chain = hash_tables[hash]
						if not hash_chain then
							hash_chain = {}
							hash_tables[hash] = hash_chain
						end
						hash_chain[#hash_chain + 1] = i
					end
				end
				index = index + prev_len - (config_use_lazy and 1 or 0)
				match_available = false
			elseif (not config_use_lazy) or match_available then

				local code = string_table[config_use_lazy and (string_table_index - 1) or string_table_index]

				lcode_tblsize = lcode_tblsize + 1
				lcodes[lcode_tblsize] = code
				lcodes_counts[code] = (lcodes_counts[code] or 0) + 1
				index = index + 1
			else
				match_available = true
				index = index + 1
			end
		end

		-- Write "end of block" symbol
		lcode_tblsize = lcode_tblsize + 1
		lcodes[lcode_tblsize] = 256
		lcodes_counts[256] = (lcodes_counts[256] or 0) + 1

		return lcodes, lextra_bits, lcodes_counts, dcodes, dextra_bits, dcodes_counts
	end


	-- Get the header data of dynamic block.
	-- @param lcodes_count The count of each literal,LZ77_length codes.
	-- @param dcodes_count The count of each Lz77 distance codes.
	-- @return a lots of stuffs.
	-- @see RFC1951 Page 12
	local function GetBlockDynamicHuffmanHeader(lcodes_counts, dcodes_counts)
		local lcodes_huffman_bitlens, lcodes_huffman_codes, max_non_zero_bitlen_lcode = GetHuffmanBitlenAndCode(lcodes_counts, 15, 285)
		local dcodes_huffman_bitlens, dcodes_huffman_codes, max_non_zero_bitlen_dcode = GetHuffmanBitlenAndCode(dcodes_counts, 15, 29)

		local rle_deflate_codes, rle_extra_bits, rle_codes_counts =
			RunLengthEncodeHuffmanBitlen(lcodes_huffman_bitlens,
																 max_non_zero_bitlen_lcode,
																 dcodes_huffman_bitlens,
																 max_non_zero_bitlen_dcode)

		local rle_codes_huffman_bitlens, rle_codes_huffman_codes = GetHuffmanBitlenAndCode(rle_codes_counts, 7, 18)

		local HCLEN = 0
		for i = 1, 19 do
			local symbol = _rle_codes_huffman_bitlen_order[i]
			local length = rle_codes_huffman_bitlens[symbol] or 0
			if length ~= 0 then HCLEN = i end
		end

		HCLEN = HCLEN - 4
		local HLIT = max_non_zero_bitlen_lcode + 1 - 257
		local HDIST = max_non_zero_bitlen_dcode + 1 - 1
		if HDIST < 0 then HDIST = 0 end

		return HLIT, HDIST, HCLEN, rle_codes_huffman_bitlens, rle_codes_huffman_codes,
					 rle_deflate_codes, rle_extra_bits, lcodes_huffman_bitlens,
					 lcodes_huffman_codes, dcodes_huffman_bitlens, dcodes_huffman_codes
	end

	-- Get the size of dynamic block without writing any bits into the writer.
	-- @param ... Read the source code of GetBlockDynamicHuffmanHeader()
	-- @return the bit length of the dynamic block
	local function GetDynamicHuffmanBlockSize(lcodes, dcodes, HCLEN,
																	rle_codes_huffman_bitlens,
																	rle_deflate_codes,
																	lcodes_huffman_bitlens,
																	dcodes_huffman_bitlens)

		local block_bitlen = 17 -- 1+2+5+5+4
		block_bitlen = block_bitlen + (HCLEN + 4) * 3

		for i = 1, #rle_deflate_codes do
			local code = rle_deflate_codes[i]
			block_bitlen = block_bitlen + rle_codes_huffman_bitlens[code]
			if code >= 16 then
				block_bitlen = block_bitlen + ((code == 16) and 2 or (code == 17 and 3 or 7))
			end
		end

		local length_code_count = 0
		for i = 1, #lcodes do
			local code = lcodes[i]
			local huffman_bitlen = lcodes_huffman_bitlens[code]
			block_bitlen = block_bitlen + huffman_bitlen
			if code > 256 then -- Length code
				length_code_count = length_code_count + 1
				if code > 264 and code < 285 then -- Length code with extra bits
					local extra_bits_bitlen = _literal_deflate_code_to_extra_bitlen[code - 256]
					block_bitlen = block_bitlen + extra_bits_bitlen
				end
				local dist_code = dcodes[length_code_count]
				local dist_huffman_bitlen = dcodes_huffman_bitlens[dist_code]
				block_bitlen = block_bitlen + dist_huffman_bitlen

				if dist_code > 3 then -- dist code with extra bits
					local dist_extra_bits_bitlen = ((dist_code - (dist_code&1)) >> 1) - 1
					block_bitlen = block_bitlen + dist_extra_bits_bitlen
				end
			end
		end
		return block_bitlen
	end

	-- Write dynamic block.
	-- @param ... Read the source code of GetBlockDynamicHuffmanHeader()
	local function CompressDynamicHuffmanBlock(WriteBits, is_last_block, lcodes,
																				 lextra_bits, dcodes, dextra_bits,
																				 HLIT, HDIST, HCLEN,
																				 rle_codes_huffman_bitlens,
																				 rle_codes_huffman_codes,
																				 rle_deflate_codes, rle_extra_bits,
																				 lcodes_huffman_bitlens,
																				 lcodes_huffman_codes,
																				 dcodes_huffman_bitlens,
																				 dcodes_huffman_codes)

		WriteBits(is_last_block and 1 or 0, 1) -- Last block identifier
		WriteBits(2, 2) -- Dynamic Huffman block identifier

		WriteBits(HLIT, 5)
		WriteBits(HDIST, 5)
		WriteBits(HCLEN, 4)

		for i = 1, HCLEN + 4 do
			local symbol = _rle_codes_huffman_bitlen_order[i]
			local length = rle_codes_huffman_bitlens[symbol] or 0
			WriteBits(length, 3)
		end

		local rleExtraBitsIndex = 1
		for i = 1, #rle_deflate_codes do
			local code = rle_deflate_codes[i]
			WriteBits(rle_codes_huffman_codes[code], rle_codes_huffman_bitlens[code])
			if code >= 16 then
				local extraBits = rle_extra_bits[rleExtraBitsIndex]
				WriteBits(extraBits, (code == 16) and 2 or (code == 17 and 3 or 7))
				rleExtraBitsIndex = rleExtraBitsIndex + 1
			end
		end

		local length_code_count = 0
		local length_code_with_extra_count = 0
		local dist_code_with_extra_count = 0

		for i = 1, #lcodes do
			local deflate_codee = lcodes[i]
			local huffman_code = lcodes_huffman_codes[deflate_codee]
			local huffman_bitlen = lcodes_huffman_bitlens[deflate_codee]
			WriteBits(huffman_code, huffman_bitlen)
			if deflate_codee > 256 then -- Length code
				length_code_count = length_code_count + 1
				if deflate_codee > 264 and deflate_codee < 285 then
					-- Length code with extra bits
					length_code_with_extra_count = length_code_with_extra_count + 1
					local extra_bits = lextra_bits[length_code_with_extra_count]
					local extra_bits_bitlen = _literal_deflate_code_to_extra_bitlen[deflate_codee - 256]
					WriteBits(extra_bits, extra_bits_bitlen)
				end
				-- Write distance code
				local dist_deflate_code = dcodes[length_code_count]
				local dist_huffman_code = dcodes_huffman_codes[dist_deflate_code]
				local dist_huffman_bitlen = dcodes_huffman_bitlens[dist_deflate_code]
				WriteBits(dist_huffman_code, dist_huffman_bitlen)

				if dist_deflate_code > 3 then -- dist code with extra bits
					dist_code_with_extra_count = dist_code_with_extra_count + 1
					local dist_extra_bits = dextra_bits[dist_code_with_extra_count]
					local dist_extra_bits_bitlen = ((dist_deflate_code - (dist_deflate_code&1)) >> 1) - 1
					WriteBits(dist_extra_bits, dist_extra_bits_bitlen)
				end
			end
		end
	end

	-- Get the size of fixed block without writing any bits into the writer.
	-- @param lcodes literal,LZ77_length deflate codes
	-- @param decodes LZ77 distance deflate codes
	-- @return the bit length of the fixed block
	local function GetFixedHuffmanBlockSize(lcodes, dcodes)
		local block_bitlen = 3
		local length_code_count = 0
		for i = 1, #lcodes do
			local code = lcodes[i]
			local huffman_bitlen = _fix_block_literal_huffman_bitlen[code]
			block_bitlen = block_bitlen + huffman_bitlen
			if code > 256 then -- Length code
				length_code_count = length_code_count + 1
				if code > 264 and code < 285 then -- Length code with extra bits
					local extra_bits_bitlen = _literal_deflate_code_to_extra_bitlen[code - 256]
					block_bitlen = block_bitlen + extra_bits_bitlen
				end
				local dist_code = dcodes[length_code_count]
				block_bitlen = block_bitlen + 5

				if dist_code > 3 then -- dist code with extra bits
					local dist_extra_bits_bitlen = ((dist_code - (dist_code&1)) >> 1) - 1
					block_bitlen = block_bitlen + dist_extra_bits_bitlen
				end
			end
		end
		return block_bitlen
	end

	-- Get the size of store block without writing any bits into the writer.
	-- @param block_start The start index of the origin input string
	-- @param block_end The end index of the origin input string
	-- @param Total bit lens had been written into the compressed result before,
	-- because store block needs to shift to byte boundary.
	-- @return the bit length of the fixed block
	local function GetStoreBlockSize(block_start, block_end, total_bitlen)
		assert(block_end - block_start + 1 <= 65535)
		local block_bitlen = 3
		total_bitlen = total_bitlen + 3
		local padding_bitlen = ((8 - (total_bitlen&7))&7)
		block_bitlen = block_bitlen + padding_bitlen
		block_bitlen = block_bitlen + 16
		block_bitlen = block_bitlen + (block_end - block_start + 1) * 8
		return block_bitlen
	end

	-- Do the deflate
	-- Currently using a simple way to determine the block size
	-- (This is why the compression ratio is little bit worse than zlib when
	-- the input size is very large
	-- The first block is 64KB, the following block is 32KB.
	-- After each block, there is a memory cleanup operation.
	-- This is not a fast operation, but it is needed to save memory usage, so
	-- the memory usage does not grow unboundly. If the data size is less than
	-- 64KB, then memory cleanup won't happen.
	-- This function determines whether to use store,fixed,dynamic blocks by
	-- calculating the block size of each block type and chooses the smallest one.

	local function Deflate( WriteBits, WriteString, FlushWriter, str)
		local string_table = {}
		local hash_tables = {}
		local is_last_block = nil
		local block_start
		local block_end
		local bitlen_written
		local total_bitlen = FlushWriter(_FLUSH_MODE_NO_FLUSH)
		local strlen = #str
		local offset

		local level = strlen < 2048 and 7 or 3;

		while not is_last_block do
			if not block_start then
				block_start = 1
				block_end = 32 * 1024 - 1
				offset = 0
			else
				block_start = block_end + 1
				block_end = block_end + 16 * 1024
				offset = block_start - 16 * 1024 - 1
			end

			if block_end >= strlen then
				block_end = strlen
				is_last_block = true
			else
				is_last_block = false
			end

			local lcodes, lextra_bits, lcodes_counts, dcodes, dextra_bits, dcodes_counts

			local HLIT, HDIST, HCLEN, rle_codes_huffman_bitlens,
						rle_codes_huffman_codes, rle_deflate_codes, rle_extra_bits,
						lcodes_huffman_bitlens, lcodes_huffman_codes, dcodes_huffman_bitlens,
						dcodes_huffman_codes

			local dynamic_block_bitlen
			local fixed_block_bitlen
			local store_block_bitlen

			if level ~= 0 then

				-- GetBlockLZ77 needs block_start to block_end+3 to be loaded.
				LoadStringToTable(str, string_table, block_start, block_end + 3, offset)

				lcodes, lextra_bits, lcodes_counts, dcodes, dextra_bits, dcodes_counts =
					GetBlockLZ77Result(level, string_table, hash_tables, block_start, block_end, offset)


				-- LuaFormatter off
				HLIT, HDIST, HCLEN, rle_codes_huffman_bitlens, rle_codes_huffman_codes, rle_deflate_codes,
					rle_extra_bits, lcodes_huffman_bitlens, lcodes_huffman_codes, dcodes_huffman_bitlens, dcodes_huffman_codes
						= GetBlockDynamicHuffmanHeader(lcodes_counts, dcodes_counts)

				dynamic_block_bitlen = GetDynamicHuffmanBlockSize(lcodes, dcodes, HCLEN,
																						rle_codes_huffman_bitlens,
																						rle_deflate_codes,
																						lcodes_huffman_bitlens,
																						dcodes_huffman_bitlens)
				fixed_block_bitlen = GetFixedHuffmanBlockSize(lcodes, dcodes)
			end

			store_block_bitlen = GetStoreBlockSize(block_start, block_end, total_bitlen)

			local min_bitlen = store_block_bitlen
			min_bitlen = (fixed_block_bitlen and fixed_block_bitlen < min_bitlen) and fixed_block_bitlen or min_bitlen
			min_bitlen = (dynamic_block_bitlen and dynamic_block_bitlen < min_bitlen) and dynamic_block_bitlen or min_bitlen

			CompressDynamicHuffmanBlock(WriteBits, is_last_block, lcodes, lextra_bits,
																	dcodes, dextra_bits, HLIT, HDIST, HCLEN,
																	rle_codes_huffman_bitlens,
																	rle_codes_huffman_codes, rle_deflate_codes,
																	rle_extra_bits, lcodes_huffman_bitlens,
																	lcodes_huffman_codes, dcodes_huffman_bitlens,
																	dcodes_huffman_codes);
			total_bitlen = total_bitlen + dynamic_block_bitlen;

			if is_last_block then
				bitlen_written = FlushWriter(_FLUSH_MODE_NO_FLUSH)
			else
				bitlen_written = FlushWriter(_FLUSH_MODE_MEMORY_CLEANUP)
			end

			assert(bitlen_written == total_bitlen)

			-- Memory clean up, so memory consumption does not always grow linearly,
			-- even if input string is > 64K.
			-- Not a very efficient operation, but this operation won't happen
			-- when the input data size is less than 64K.
			if not is_last_block then
				local j

				j = 1
				for i = block_end - 32767, block_end do
					string_table[j] = string_table[i - offset]
					j = j + 1
				end

				for k, t in pairs(hash_tables) do
					local tSize = #t
					if tSize > 0 and block_end + 1 - t[1] > 32768 then
						if tSize == 1 then
							hash_tables[k] = nil
						else
							local new = {}
							local newSize = 0
							for i = 2, tSize do
								j = t[i]
								if block_end + 1 - j <= 32768 then
									newSize = newSize + 1
									new[newSize] = j
								end
							end
							hash_tables[k] = new
						end
					end
				end
			end
		end
	end

	--[[ --------------------------------------------------------------------------
		Decompress code
	--]] --------------------------------------------------------------------------

	--[[
		Create a reader to easily reader stuffs as the unit of bits.
		Return values:
		1. ReadBits(bitlen)
		2. ReadBytes(bytelen, buffer, buffer_size)
		3. Decode(huffman_bitlen_count, huffman_symbol, min_bitlen)
		4. ReaderBitlenLeft()
		5. SkipToByteBoundary()
	--]]
	local function CreateReader(input_string)
		local input = input_string
		local input_strlen = #input_string
		local input_next_byte_pos = 1
		local cache_bitlen = 0
		local cache = 0

		-- Read some bits.
		-- To improve speed, this function does not
		-- check if the input has been exhausted.
		-- Use ReaderBitlenLeft() < 0 to check it.
		-- @param bitlen the number of bits to read
		-- @return the data is read.
		local function ReadBits(bitlen)
			local rshift_mask = _pow2[bitlen]
			local code = 0
			if bitlen <= cache_bitlen then
				code = (cache&(rshift_mask-1));

				cache = (cache - code) >> bitlen;

				cache_bitlen = cache_bitlen - bitlen;
			else -- Whether input has been exhausted is not checked.
				local lshift_mask = _pow2[cache_bitlen]

				local byte1, byte2 = string_byte(input, input_next_byte_pos, input_next_byte_pos + 1)

				cache = cache + ((byte1 or 0) + (byte2 or 0) * 256) * lshift_mask

				input_next_byte_pos = input_next_byte_pos + 2
				cache_bitlen = cache_bitlen + 16 - bitlen
				code = (cache&(rshift_mask-1))

				cache = (cache - code) >> bitlen

			end
			return code
		end

		-- Read some bytes from the reader.
		-- Assume reader is on the byte boundary.
		-- @param bytelen The number of bytes to be read.
		-- @param buffer The byte read will be stored into this buffer.
		-- @param buffer_size The buffer will be modified starting from
		--	buffer[buffer_size+1], ending at buffer[buffer_size+bytelen-1]
		-- @return the new buffer_size
		local function ReadBytes(bytelen, buffer, buffer_size)
			assert((cache_bitlen&7) == 0)

			local byte_from_cache = ((cache_bitlen >> 3) < bytelen) and (cache_bitlen >> 3) or bytelen

			for _ = 1, byte_from_cache do
				local byte = ((cache&255))
				buffer_size = buffer_size + 1
				buffer[buffer_size] = string_char(byte)
				cache = (cache - byte) >> 8
			end
			cache_bitlen = cache_bitlen - byte_from_cache * 8
			bytelen = bytelen - byte_from_cache
			if (input_strlen - input_next_byte_pos - bytelen + 1) * 8 + cache_bitlen < 0 then
				return -1 -- out of input
			end
			for i = input_next_byte_pos, input_next_byte_pos + bytelen - 1 do
				buffer_size = buffer_size + 1
				buffer[buffer_size] = string_sub(input, i, i)
			end

			input_next_byte_pos = input_next_byte_pos + bytelen
			return buffer_size
		end

		-- Decode huffman code
		-- To improve speed, this function does not check
		-- if the input has been exhausted.
		-- Use ReaderBitlenLeft() < 0 to check it.
		-- Credits for Mark Adler. This code is from puff:Decode()
		-- @see puff:Decode(...)
		-- @param huffman_bitlen_count
		-- @param huffman_symbol
		-- @param min_bitlen The minimum huffman bit length of all symbols
		-- @return The decoded deflate code.
		--	Negative value is returned if decoding fails.
		local function Decode(huffman_bitlen_counts, huffman_symbols, min_bitlen)
			local code = 0
			local first = 0
			local index = 0
			local count
			if min_bitlen > 0 then
				if cache_bitlen < 15 and input then
					local lshift_mask = _pow2[cache_bitlen]

					local byte1, byte2 = string_byte(input, input_next_byte_pos, input_next_byte_pos + 1)
					-- This requires lua number to be at least double ()

					cache = cache + ((byte1 or 0) + (byte2 or 0) * 256) * lshift_mask
					input_next_byte_pos = input_next_byte_pos + 2
					cache_bitlen = cache_bitlen + 16
				end

				local rshift_mask = _pow2[min_bitlen]
				cache_bitlen = cache_bitlen - min_bitlen
				code = (cache&(rshift_mask-1))
				cache = (cache - code) >> min_bitlen
				-- Reverse the bits
				code = _reverse_bits_tbl[min_bitlen][code]

				count = huffman_bitlen_counts[min_bitlen]
				if code < count then return huffman_symbols[code] end
				index = count
				first = count * 2
				code = code * 2
			end

			for bitlen = min_bitlen + 1, 15 do
				local bit

				bit = (cache&1)
				cache = (cache - bit) >> 1
				cache_bitlen = cache_bitlen - 1

				code = (bit == 1) and (code + 1 - (code&1)) or code
				count = huffman_bitlen_counts[bitlen] or 0
				local diff = code - first
				if diff < count then return huffman_symbols[index + diff] end
				index = index + count
				first = first + count
				first = first * 2
				code = code * 2
			end
			-- invalid literal,length or distance code
			-- in fixed or dynamic block (run out of code)
			return -10
		end

		local function ReaderBitlenLeft()
			return (input_strlen - input_next_byte_pos + 1) * 8 + cache_bitlen
		end

		local function SkipToByteBoundary()
			local skipped_bitlen = (cache_bitlen&7)
			local rshift_mask = _pow2[skipped_bitlen]
			cache_bitlen = cache_bitlen - skipped_bitlen
			cache = (cache - (cache&(rshift_mask-1))) >> skipped_bitlen
		end

		return ReadBits, ReadBytes, Decode, ReaderBitlenLeft, SkipToByteBoundary
	end

	-- Create a deflate state, so I can pass in less arguments to functions.
	-- @param str the whole string to be decompressed.
	-- @param dictionary The preset dictionary. nil if not provided.
	--		This dictionary should be produced by LibDeflate:CreateDictionary(str)
	-- @return The decomrpess state.
	local function CreateDecompressState(str)
		local ReadBits, ReadBytes, Decode, ReaderBitlenLeft, SkipToByteBoundary = CreateReader(str)
		local state = {
			ReadBits = ReadBits,
			ReadBytes = ReadBytes,
			Decode = Decode,
			ReaderBitlenLeft = ReaderBitlenLeft,
			SkipToByteBoundary = SkipToByteBoundary,
			buffer_size = 0,
			buffer = {},
			result_buffer = {},
		}
		return state
	end

	-- Get the stuffs needed to decode huffman codes
	-- @see puff.c:construct(...)
	-- @param huffman_bitlen The huffman bit length of the huffman codes.
	-- @param max_symbol The maximum symbol
	-- @param max_bitlen The min huffman bit length of all codes
	-- @return zero or positive for success, negative for failure.
	-- @return The count of each huffman bit length.
	-- @return A table to convert huffman codes to deflate codes.
	-- @return The minimum huffman bit length.
	local function GetHuffmanForDecode(huffman_bitlens, max_symbol, max_bitlen)
		local huffman_bitlen_counts = {}
		local min_bitlen = max_bitlen
		for symbol = 0, max_symbol do
			local bitlen = huffman_bitlens[symbol] or 0
			min_bitlen = (bitlen > 0 and bitlen < min_bitlen) and bitlen or min_bitlen
			huffman_bitlen_counts[bitlen] = (huffman_bitlen_counts[bitlen] or 0) + 1
		end

		if huffman_bitlen_counts[0] == max_symbol + 1 then -- No Codes
			return 0, huffman_bitlen_counts, {}, 0 -- Complete, but decode will fail
		end

		local left = 1
		for len = 1, max_bitlen do
			left = left * 2
			left = left - (huffman_bitlen_counts[len] or 0)
			if left < 0 then
				return left -- Over-subscribed, return negative
			end
		end

		-- Generate offsets info symbol table for each length for sorting
		local offsets = {}
		offsets[1] = 0
		for len = 1, max_bitlen - 1 do
			offsets[len + 1] = offsets[len] + (huffman_bitlen_counts[len] or 0)
		end

		local huffman_symbols = {}
		for symbol = 0, max_symbol do
			local bitlen = huffman_bitlens[symbol] or 0
			if bitlen ~= 0 then
				local offset = offsets[bitlen]
				huffman_symbols[offset] = symbol
				offsets[bitlen] = offsets[bitlen] + 1
			end
		end

		-- Return zero for complete set, positive for incomplete set.
		return left, huffman_bitlen_counts, huffman_symbols, min_bitlen
	end

	-- Decode a fixed or dynamic huffman blocks, excluding last block identifier
	-- and block type identifer.
	-- @see puff.c:codes()
	-- @param state decompression state that will be modified by this function.
	--	@see CreateDecompressState
	-- @param ... Read the source code
	-- @return 0 on success, other value on failure.
	local function DecodeUntilEndOfBlock(state, lcodes_huffman_bitlens,
																			 lcodes_huffman_symbols,
																			 lcodes_huffman_min_bitlen,
																			 dcodes_huffman_bitlens,
																			 dcodes_huffman_symbols,
																			 dcodes_huffman_min_bitlen)
		local buffer, buffer_size, ReadBits, Decode, ReaderBitlenLeft, result_buffer =
			state.buffer, state.buffer_size, state.ReadBits, state.Decode,
			state.ReaderBitlenLeft, state.result_buffer

		local dict_string_table
		local dict_strlen

		local buffer_end = 1

		repeat
			local symbol = Decode(lcodes_huffman_bitlens, lcodes_huffman_symbols,
														lcodes_huffman_min_bitlen)
			if symbol < 0 or symbol > 285 then
				-- invalid literal,length or distance code in fixed or dynamic block
				return -10
			elseif symbol < 256 then -- Literal
				buffer_size = buffer_size + 1
				buffer[buffer_size] = _byte_to_char[symbol]
			elseif symbol > 256 then -- Length code
				symbol = symbol - 256
				local bitlen = _literal_deflate_code_to_base_len[symbol]
				bitlen = (symbol >= 8) and (bitlen + ReadBits(_literal_deflate_code_to_extra_bitlen[symbol])) or bitlen

				symbol = Decode(dcodes_huffman_bitlens, dcodes_huffman_symbols, dcodes_huffman_min_bitlen)

				if symbol < 0 or symbol > 29 then
					-- invalid literal,length or distance code in fixed or dynamic block
					return -10
				end
				local dist = _dist_deflate_code_to_base_dist[symbol]

				dist = (dist > 4) and (dist + ReadBits(_dist_deflate_code_to_extra_bitlen[symbol])) or dist

				local char_buffer_index = buffer_size - dist + 1
				if char_buffer_index < buffer_end then
					-- distance is too far back in fixed or dynamic block
					return -11
				end
				if char_buffer_index >= -257 then
					for _ = 1, bitlen do
						buffer_size = buffer_size + 1
						buffer[buffer_size] = buffer[char_buffer_index]
						char_buffer_index = char_buffer_index + 1
					end
				else
					char_buffer_index = dict_strlen + char_buffer_index
					for _ = 1, bitlen do
						buffer_size = buffer_size + 1
						buffer[buffer_size] = _byte_to_char[dict_string_table[char_buffer_index]]
						char_buffer_index = char_buffer_index + 1
					end
				end
			end

			if ReaderBitlenLeft() < 0 then
				return 2 -- available inflate data did not terminate
			end

			if buffer_size >= 65536 then
				result_buffer[#result_buffer + 1] = table_concat(buffer, "", 1, 32768)
				for i = 32769, buffer_size do buffer[i - 32768] = buffer[i] end
				buffer_size = buffer_size - 32768
				buffer[buffer_size + 1] = nil
				-- NOTE: buffer[32769..end] and buffer[-257..0] are not cleared.
				-- This is why "buffer_size" variable is needed.
			end
		until symbol == 256

		state.buffer_size = buffer_size

		return 0
	end

	-- Decompress a store block
	-- @param state decompression state that will be modified by this function.
	-- @return 0 if succeeds, other value if fails.
	local function DecompressStoreBlock(state)
		local buffer, buffer_size, ReadBits, ReadBytes, ReaderBitlenLeft,
					SkipToByteBoundary, result_buffer = state.buffer, state.buffer_size,
																							state.ReadBits, state.ReadBytes,
																							state.ReaderBitlenLeft,
																							state.SkipToByteBoundary,
																							state.result_buffer

		SkipToByteBoundary()
		local bytelen = ReadBits(16)
		if ReaderBitlenLeft() < 0 then
			return 2 -- available inflate data did not terminate
		end
		local bytelenComp = ReadBits(16)
		if ReaderBitlenLeft() < 0 then
			return 2 -- available inflate data did not terminate
		end

		if (bytelen&255) + (bytelenComp&255) ~= 255 then
			return -2 -- Not one's complement
		end
		if ((bytelen - (bytelen&255)) >> 8) + ((bytelenComp - (bytelenComp&255)) >> 8) ~= 255 then
			return -2 -- Not one's complement
		end

		-- Note that ReadBytes will skip to the next byte boundary first.
		buffer_size = ReadBytes(bytelen, buffer, buffer_size)
		if buffer_size < 0 then
			return 2 -- available inflate data did not terminate
		end

		-- memory clean up when there are enough bytes in the buffer.
		if buffer_size >= 65536 then
			result_buffer[#result_buffer + 1] = table_concat(buffer, "", 1, 32768)
			for i = 32769, buffer_size do buffer[i - 32768] = buffer[i] end
			buffer_size = buffer_size - 32768
			buffer[buffer_size + 1] = nil
		end
		state.buffer_size = buffer_size
		return 0
	end

	-- Decompress a fixed block
	-- @param state decompression state that will be modified by this function.
	-- @return 0 if succeeds other value if fails.
	local function DecompressFixBlock(state)
		return DecodeUntilEndOfBlock(state, _fix_block_literal_huffman_bitlen_count,
																 _fix_block_literal_huffman_to_deflate_code, 7,
																 _fix_block_dist_huffman_bitlen_count,
																 _fix_block_dist_huffman_to_deflate_code, 5)
	end

	-- Decompress a dynamic block
	-- @param state decompression state that will be modified by this function.
	-- @return 0 if success, other value if fails.
	local function DecompressDynamicBlock(state)
		local ReadBits, Decode = state.ReadBits, state.Decode
		local nlen = ReadBits(5) + 257
		local ndist = ReadBits(5) + 1
		local ncode = ReadBits(4) + 4
		if nlen > 286 or ndist > 30 then
			-- dynamic block code description: too many length or distance codes
			return -3
		end

		local rle_codes_huffman_bitlens = {}

		for i = 1, ncode do
			rle_codes_huffman_bitlens[_rle_codes_huffman_bitlen_order[i]] = ReadBits(3)
		end

		local rle_codes_err, rle_codes_huffman_bitlen_counts, rle_codes_huffman_symbols, rle_codes_huffman_min_bitlen = GetHuffmanForDecode(rle_codes_huffman_bitlens, 18, 7)
		if rle_codes_err ~= 0 then -- Require complete code set here
			-- dynamic block code description: code lengths codes incomplete
			return -4
		end

		local lcodes_huffman_bitlens = {}
		local dcodes_huffman_bitlens = {}
		-- Read length,literal and distance code length tables
		local index = 0
		while index < nlen + ndist do
			local symbol -- Decoded value
			local bitlen -- Last length to repeat

			symbol = Decode(rle_codes_huffman_bitlen_counts, rle_codes_huffman_symbols, rle_codes_huffman_min_bitlen)

			if symbol < 0 then
				return symbol -- Invalid symbol
			elseif symbol < 16 then
				if index < nlen then
					lcodes_huffman_bitlens[index] = symbol
				else
					dcodes_huffman_bitlens[index - nlen] = symbol
				end
				index = index + 1
			else
				bitlen = 0
				if symbol == 16 then
					if index == 0 then
						-- dynamic block code description: repeat lengths
						-- with no first length
						return -5
					end
					if index - 1 < nlen then
						bitlen = lcodes_huffman_bitlens[index - 1]
					else
						bitlen = dcodes_huffman_bitlens[index - nlen - 1]
					end
					symbol = 3 + ReadBits(2)
				elseif symbol == 17 then -- Repeat zero 3..10 times
					symbol = 3 + ReadBits(3)
				else -- == 18, repeat zero 11.138 times
					symbol = 11 + ReadBits(7)
				end
				if index + symbol > nlen + ndist then
					-- dynamic block code description:
					-- repeat more than specified lengths
					return -6
				end
				while symbol > 0 do -- Repeat last or zero symbol times
					symbol = symbol - 1
					if index < nlen then
						lcodes_huffman_bitlens[index] = bitlen
					else
						dcodes_huffman_bitlens[index - nlen] = bitlen
					end
					index = index + 1
				end
			end
		end

		if (lcodes_huffman_bitlens[256] or 0) == 0 then
			-- dynamic block code description: missing end-of-block code
			return -9
		end

		local lcodes_err, lcodes_huffman_bitlen_counts, lcodes_huffman_symbols, lcodes_huffman_min_bitlen = GetHuffmanForDecode(lcodes_huffman_bitlens, nlen - 1, 15)
		-- dynamic block code description: invalid literal,length code lengths,
		-- Incomplete code ok only for single length 1 code
		if (lcodes_err ~= 0 and (lcodes_err < 0 or nlen ~= (lcodes_huffman_bitlen_counts[0] or 0) + (lcodes_huffman_bitlen_counts[1] or 0))) then
			return -7
		end

		local dcodes_err, dcodes_huffman_bitlen_counts, dcodes_huffman_symbols, dcodes_huffman_min_bitlen = GetHuffmanForDecode(dcodes_huffman_bitlens, ndist - 1, 15)
		-- dynamic block code description: invalid distance code lengths,
		-- Incomplete code ok only for single length 1 code
		if (dcodes_err ~= 0 and (dcodes_err < 0 or ndist ~= (dcodes_huffman_bitlen_counts[0] or 0) + (dcodes_huffman_bitlen_counts[1] or 0))) then
			return -8
		end

		-- Build buffman table for literal,length codes
		return DecodeUntilEndOfBlock(state, lcodes_huffman_bitlen_counts,
																 lcodes_huffman_symbols,
																 lcodes_huffman_min_bitlen,
																 dcodes_huffman_bitlen_counts,
																 dcodes_huffman_symbols, dcodes_huffman_min_bitlen)
	end

	-- Decompress a deflate stream
	-- @param state: a decompression state
	-- @return the decompressed string if succeeds. nil if fails.
	local function Inflate(state)
		local ReadBits = state.ReadBits

		local is_last_block
		while not is_last_block do
			is_last_block = (ReadBits(1) == 1)
			local block_type = ReadBits(2)

			local status
			if block_type == 0 then
				status = DecompressStoreBlock(state)
			elseif block_type == 1 then
				status = DecompressFixBlock(state)
			elseif block_type == 2 then
				status = DecompressDynamicBlock(state)
			else
				return nil, -1 -- invalid block type (type == 3)
			end
			if status ~= 0 then return nil, status end
		end

		state.result_buffer[#state.result_buffer + 1] = table_concat(state.buffer, "", 1, state.buffer_size)
		local result = table_concat(state.result_buffer)
		return result
	end

	function LibDeflate.DecompressDeflate(str)
		local state = CreateDecompressState(str)

		local result, status = Inflate(state)
		if not result then return nil, status end

		local bitlen_left = state.ReaderBitlenLeft()
		local bytelen_left = (bitlen_left - (bitlen_left&7)) >> 3
		return result, bytelen_left
	end


	function LibDeflate.CompressDeflate(str)
		local WriteBits, WriteString, FlushWriter = CreateWriter();

		Deflate(WriteBits, WriteString, FlushWriter, str);

		local total_bitlen, result = FlushWriter(_FLUSH_MODE_OUTPUT)
		local padding_bitlen = ((8 - (total_bitlen&7))&7);

		return result, padding_bitlen;
	end


	function LibDeflate.InitCompressor()
		for i = 0, 255 do _byte_to_char[i] = string_char(i) end

		local pow = 1
		for i = 0, 24 do
			_pow2[i] = pow
			pow = pow * 2
		end

		for i = 1, 9 do
			_reverse_bits_tbl[i] = {}
			for j = 0, _pow2[i + 1] - 1 do
				local reverse = 0
				local value = j
				for _ = 1, i do
					reverse = reverse - (reverse&1) + ((((reverse&1) == 1) or ((value&1)) == 1) and 1 or 0)
					value = (value - (value&1)) >> 1
					reverse = reverse << 1
				end
				_reverse_bits_tbl[i][j] = (reverse - (reverse&1)) >> 1
			end
		end

	-- The source code is written according to the pattern in the numbers
	-- in RFC1951 Page10.
		local a = 18
		local b = 16
		local c = 265
		local bitlen = 1
		for len = 3, 258 do
			if len <= 10 then
				_length_to_deflate_code[len] = len + 254
				_length_to_deflate_extra_bitlen[len] = 0
			elseif len == 258 then
				_length_to_deflate_code[len] = 285
				_length_to_deflate_extra_bitlen[len] = 0
			else
				if len > a then
					a = a + b
					b = b * 2
					c = c + 4
					bitlen = bitlen + 1
				end
				local t = len - a - 1 + (b >> 1)
				_length_to_deflate_code[len] = (t - (t&((b >> 3)-1))) // (b >> 3) + c
				_length_to_deflate_extra_bitlen[len] = bitlen
				_length_to_deflate_extra_bits[len] = (t&((b >> 3)-1))
			end
		end


	-- The source code is written according to the pattern in the numbers
	-- in RFC1951 Page11.
		_dist256_to_deflate_code[1] = 0
		_dist256_to_deflate_code[2] = 1
		_dist256_to_deflate_extra_bitlen[1] = 0
		_dist256_to_deflate_extra_bitlen[2] = 0

		local a = 3
		local b = 4
		local code = 2
		local bitlen = 0
		for dist = 3, 256 do
			if dist > b then
				a = a * 2
				b = b * 2
				code = code + 2
				bitlen = bitlen + 1
			end
			_dist256_to_deflate_code[dist] = (dist <= a) and code or (code + 1)
			_dist256_to_deflate_extra_bitlen[dist] = (bitlen < 0) and 0 or bitlen
			if b >= 8 then
				_dist256_to_deflate_extra_bits[dist] = ((dist - (b >> 1) - 1)&((b >> 2)-1))
			end
		end

		_fix_block_literal_huffman_bitlen = {}
		for sym = 0, 143 do _fix_block_literal_huffman_bitlen[sym] = 8 end
		for sym = 144, 255 do _fix_block_literal_huffman_bitlen[sym] = 9 end
		for sym = 256, 279 do _fix_block_literal_huffman_bitlen[sym] = 7 end
		for sym = 280, 287 do _fix_block_literal_huffman_bitlen[sym] = 8 end

		_fix_block_dist_huffman_bitlen = {}
		for dist = 0, 31 do _fix_block_dist_huffman_bitlen[dist] = 5 end
		local status
		status, _fix_block_literal_huffman_bitlen_count, _fix_block_literal_huffman_to_deflate_code = GetHuffmanForDecode(_fix_block_literal_huffman_bitlen, 287, 9)
		assert(status == 0)
		status, _fix_block_dist_huffman_bitlen_count, _fix_block_dist_huffman_to_deflate_code = GetHuffmanForDecode(_fix_block_dist_huffman_bitlen, 31, 5)
		assert(status == 0)

		_fix_block_literal_huffman_code = GetHuffmanCodeFromBitlen(_fix_block_literal_huffman_bitlen_count, _fix_block_literal_huffman_bitlen, 287, 9)
		_fix_block_dist_huffman_code = GetHuffmanCodeFromBitlen(_fix_block_dist_huffman_bitlen_count, _fix_block_dist_huffman_bitlen, 31, 5)
	end
end
if Debug and Debug.endFile then Debug.endFile() end