--!strict

--[[
This script reduces the effective RGB bits-per-channel by
applying quantization to Roblox's rendering pipeline.

The math is accurate, and the implementation is minimal:
	- game.Lighting
		- .ExposureCompensation
		- ColorCorrectionEffect
			- .Brightness
			- .Contrast

To use, require as a module and call with the desired bits-per-channel value [1..7]
Passing 8 or any other value outside of [1..7] will disable quantization.
Note that color accuracy WILL be affected as all post-processing effects
are run before Roblox transforms the linear content to sRGB color space.
]]

local Quantize: ColorCorrectionEffect = Instance.new("ColorCorrectionEffect")
Quantize.Name = "Quantize"
Quantize.Parent = game.Lighting

return function(n: number)
	--> Floor for sanity
	n //= 1
	if n ~= math.clamp(n, 1, 7) then
		--> Disable quantization
		game.Lighting.ExposureCompensation = 0
		Quantize.Brightness = 0
		Quantize.Contrast = 0
		Quantize.Enabled = false
		return
	end
	--> Invert --> 0-base --> Multiply for R/G/B effectiveness
	n = (7-n)*3
	--> Apply quantization
	local nPower = 2^n
	game.Lighting.ExposureCompensation = -(n+1)
	Quantize.Brightness = nPower*.5
	Quantize.Contrast = nPower
	Quantize.Enabled = true
end
