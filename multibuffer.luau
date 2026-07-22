--[[ multibuffer: Simple wrapper that allows indexing of multiple buffers through 1 userdata.
-- HOW TO USE:
  local multibuffer = require(`./multibuffer`)

-- Create multibuffer: Behaves similarly to buffer.create
  local b = multibuffer(64)

-- Read: Calling into the multibuffer with the index will return the appropriate buffer and the corrected index.
  buffer.readu8(b(i))

-- Write: Calling into the multibuffer with the index and value will return the appropriate buffer, the corrected index, and the tail which includes the value.
  buffer.writeu8(b(40, 33))

As this is a simple wrapper, ensure read/write of larger value types (u16/i16/u32/i32/f32/f64/string) do not go out of bounds of the individual buffer! 
]]

local maxBufferSize = 1024^3 -- Standard is 1024^3 [1GiB]; modify as necessary

-- Indexes the appropriate multibuffer
local function multibuffer_index<T...>(b: {[number]: buffer}, i: number, ...): (buffer, number, T...)
  return
    b[1 + (i // maxBufferSize)],
    i % maxBufferSize,
    ...
end

-- Creates frozen table of multiple buffers.
return function(size: number)
  local multibuffer = newproxy(true)
  local meta = getmetatable(multibuffer)
  local buffers = {}
  -- Configure metatable
  meta.__index = buffers
  meta.__newindex = function() error("cannot write to multibuffer") end
  meta.__call = multibuffer_index
  meta.__len = function() return #buffers end
  -- Configure 'buffers' (multibuffer internal)
  buffers.len = size
  repeat
    local thisSize = math.min(size, maxBufferSize)
    table.insert(buffers, buffer.create(thisSize))
    size -= thisSize
  until size <= 0
  table.freeze(buffers)
  -- Return multibuffer
  return multibuffer
end
