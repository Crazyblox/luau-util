-- Allows a function to expect default values when a nil argument is sent
local function DefFunction(f, ...)
	local dArgs = {...}
	return setmetatable( {}, {
		__call = function(_, ...)
			local iArgs = {...}
			for i = 1, #iArgs do
				iArgs[i] = iArgs[i] or dArgs[i]
			end
			return f(table.unpack(iArgs))
		end
	})
end
local DefPrint = DefFunction( print, 23, 72, 81 )
DefPrint( nil, 1, nil, 38 )
