--!strict
--!optimize 2
--!native

-- FuncDiff:
-- Transparently benchmark a given array of pure functions.
-- Intended for quick drop-ins whilst optimizing your own code.
-- Crazyblox 2025

return function (
    Funcs: { [number]: (...any) -> (...any) },  -- Provide functions as an array
    ReturnIndex: number,                        -- Choose which function you want to return data from
    ...                                         -- Provided arguments for the function
): ( ...any )
    local FuncTimes: { [number]: number } = {}
    local FuncOuts: { [number]: { any } } = {}
    -- Process functions in given order
    for i: number, Func: (...any) -> (...any) in Funcs do
        local start = os.clock()
        FuncOuts[i] = table.pack( Func( ... ) )
        FuncTimes[i] = os.clock() - start
    end
    -- Output results of function array
    print( `Function Times:\n{ table.concat( FuncTimes, "\n" ) }`
    -- Return values from specified function
    return table.unpack( FuncOuts[ ReturnIndex ] )
end
