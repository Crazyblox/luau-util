--!strict
--!native

--[[

C-like integer helper:
Explicit helpers for emulating C-like fixed-width integer representation and arithmetic semantics using Luau numbers.

Luau's number type is f64. No other number types are available in Luau.

This module allows C-like behaviours in how 8, 16 and 32 bit integers (signed and unsigned)
are operated on, with their representation being entirely logical through Luau's number type.

- Require the module:
local n = require("./n")

- Casts input to logical bounds, regardless of unsigned/signedness:
z = n.u16(4294967295) -- Returns '65535'

- Module requires explicit use of cast/assignements to enforce integer width, signedness, range & wrapping
x = n.u8(123)
y = n.u8(456)
z = n.i8(x + y)

- Truncating towards zero is enforced with wrappers; enables C-like integer division.
z = n.u32(255 / 123)

- C's tmod is also present for use in place of Luau's modulo operator.
z = n.tmod(x, y)

- Bitwise: All bit ops return logical u32; wrap result to maintain intended number type:
z = n.u16(AND(x, y))

- Use 'ARSHIFT' over 'RSHIFT' when lhs input was casted i*().
z = n.i32(n.ARSHIFT(x, 2))

]]

-- Scratch buffer.
local b: buffer = buffer.create(4)

-- Logical bounds wrappers (Also enables truncate-to-zero when wrapping a division).
local function u8(x: number) buffer.writeu8(b, 0, x); return buffer.readu8(b, 0) end
local function u16(x: number) buffer.writeu16(b, 0, x); return buffer.readu16(b, 0) end
local function u32(x: number) buffer.writeu32(b, 0, x); return buffer.readu32(b, 0) end
local function i8(x: number) buffer.writei8(b, 0, x); return buffer.readi8(b, 0) end 
local function i16(x: number) buffer.writei16(b, 0, x); return buffer.readi16(b, 0) end
local function i32(x: number) buffer.writei32(b, 0, x); return buffer.readi32(b, 0) end

-- Complementary wrappers.
-- Returns number as reduced-precision 'float'. Helpful for code dependent on exact 'float' behaviour.
local function f32(x: number) buffer.writef32(b, 0, x); return buffer.readf32(b, 0) end
-- Purely semantic - Conveys that value remains purely a Luau number.
local function f64(x: number) return x end

-- Requires integer-valued x and y, matching C/C++ integer remainder behaviour.
-- The result sign infers from lhs (dividend, left operand).
local function tmod(x: number, y: number) return x - (math.modf(x / y)) * y end

-- API.
return table.freeze {
  -- Logical bounds wrappers.
  u8 = u8, u16 = u16, u32 = u32, i8 = i8, i16 = i16, i32 = i32, f32 = f32, f64 = f64,
  -- Arithmetic.
  tmod = tmod,
  -- bitwise: WRT bit32 library, logical u32/i32 is valid input. Outputs only logical u32.
  AND = bit32.band, OR = bit32.bor, XOR = bit32.bxor, NOT = bit32.bnot, LSHIFT = bit32.lshift, RSHIFT = bit32.rshift, ARSHIFT = bit32.arshift
}
