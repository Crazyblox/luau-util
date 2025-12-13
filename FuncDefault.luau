-- FuncDefault: Provides a given function with default values in place of nil arguments
local function Wrapper( t, ... )
    local args_out = table.clone( t[ 2 ] )
    local num = #args_out
    local args_in = { ... }
    for i = 1, #t[ 1 ] do
        args_out[ i + num ] = args_in[ i ] or t[ 1 ][ i ]
    end
    return t[0]( table.unpack( args_out ) )
end
-- Exposed function
return function(
    f,            -- Given function to wrap
    defVals,    -- Default values provided in place of nil arguments
    preArgs        -- Prefixed arguments which are always passed when the given function is called
)
    local t = {
        [0] = f,
        [1] = type( defVals ) == "table" and defVals or { defVals },
        [2] = type( preArgs ) == "table" and preArgs or { preArgs },
        __call = Wrapper
    }
    setmetatable(t,t)
    return table.freeze(t)
end
