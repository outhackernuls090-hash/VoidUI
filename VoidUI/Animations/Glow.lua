local Utilities = require(script.Parent.Parent.Core.Utilities)

local Glow = {}
Glow.__index = Glow

function Glow.new(Instance, Options)
	local self = setmetatable({}, Glow)
	self.Instance = Instance
	self.Color = Options and Options.Color or Color3.fromRGB(120, 170, 255)
	self.Intensity = Options and Options.Intensity or 0
	self.TargetIntensity = Options and Options.Intensity or 0
	self.Speed = Options and Options.Speed or 10
	self.PulseSpeed = Options and Options.PulseSpeed or 2
	self.PulseAmount = Options and Options.PulseAmount or 0
	self.Pulsing = false
	self.Stroke = nil
	self.Gradient = nil
	self._Time = 0
	self:Setup()
	return self
end

function Glow:Setup()
	local Stroke = Instance.new("UIStroke")
	Stroke.Color = self.Color
	Stroke.Thickness = 1
	Stroke.Transparency = 1 - self.Intensity
	Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	Stroke.Parent = self.Instance
	self.Stroke = Stroke
end

function Glow:SetColor(Color)
	self.Color = Color
	if self.Stroke then
		self.Stroke.Color = Color
	end
end

function Glow:SetIntensity(Intensity)
	self.TargetIntensity = Utilities.Clamp(Intensity, 0, 1)
end

function Glow:Show(Intensity)
	self.TargetIntensity = Utilities.Clamp(Intensity or 0.8, 0, 1)
end

function Glow:Hide()
	self.TargetIntensity = 0
end

function Glow:StartPulse(Amount, Speed)
	self.Pulsing = true
	self.PulseAmount = Amount or 0.2
	self.PulseSpeed = Speed or 2
end

function Glow:StopPulse()
	self.Pulsing = false
end

function Glow:Step(Delta)
	self._Time = self._Time + Delta
	local Target = self.TargetIntensity
	if self.Pulsing then
		Target = self.TargetIntensity + math.sin(self._Time * self.PulseSpeed) * self.PulseAmount
		Target = Utilities.Clamp(Target, 0, 1)
	end
	self.Intensity = Utilities.Damp(self.Intensity, Target, self.Speed, Delta)
	if self.Stroke then
		self.Stroke.Transparency = 1 - self.Intensity
		self.Stroke.Color = self.Color
	end
end

function Glow:Destroy()
	if self.Stroke then
		self.Stroke:Destroy()
		self.Stroke = nil
	end
end

local Bloom = {}
Bloom.__index = Bloom

function Bloom.new()
	local self = setmetatable({}, Bloom)
	self.Intensity = 0
	self.TargetIntensity = 0
	self.Speed = 8
	self.Instance = nil
	return self
end

function Bloom:Create(Parent)
	local Success, BloomEffect = pcall(function()
		return Instance.new("BloomEffect")
	end)
	if Success and BloomEffect then
		BloomEffect.Intensity = self.Intensity
		BloomEffect.Threshold = 0.7
		BloomEffect.Size = 24
		BloomEffect.Parent = Parent or game:GetService("Lighting")
		self.Instance = BloomEffect
	end
	return self.Instance
end

function Bloom:Set(Intensity)
	self.TargetIntensity = Intensity or 0
end

function Bloom:Step(Delta)
	self.Intensity = Utilities.Damp(self.Intensity, self.TargetIntensity, self.Speed, Delta)
	if self.Instance then
		self.Instance.Intensity = self.Intensity
	end
end

function Bloom:Destroy()
	if self.Instance then
		self.Instance:Destroy()
		self.Instance = nil
	end
end

Glow.Bloom = Bloom

return Glow
