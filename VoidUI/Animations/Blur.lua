local Utilities = require(script.Parent.Parent.Core.Utilities)

local Blur = {}
Blur.__index = Blur

function Blur.new()
	local self = setmetatable({}, Blur)
	self.Size = 0
	self.TargetSize = 0
	self.Speed = 12
	self.Enabled = false
	self.Instance = nil
	return self
end

function Blur:Create(Parent)
	local Success, BlurEffect = pcall(function()
		return Instance.new("BlurEffect")
	end)
	if Success and BlurEffect then
		BlurEffect.Size = self.Size
		BlurEffect.Parent = Parent or game:GetService("Lighting")
		self.Instance = BlurEffect
		self.Enabled = true
	end
	return self.Instance
end

function Blur:Set(Size)
	self.TargetSize = Size or 0
end

function Blur:Show(Size)
	self.TargetSize = Size or 24
end

function Blur:Hide()
	self.TargetSize = 0
end

function Blur:Step(Delta)
	self.Size = Utilities.Damp(self.Size, self.TargetSize, self.Speed, Delta)
	if self.Instance then
		self.Instance.Size = self.Size
	end
end

function Blur:IsVisible()
	return self.Size > 0.5
end

function Blur:Destroy()
	if self.Instance then
		self.Instance:Destroy()
		self.Instance = nil
	end
end

local BlurStack = {}
BlurStack.__index = BlurStack

function BlurStack.new()
	local self = setmetatable({}, BlurStack)
	self.Layers = {}
	return self
end

function BlurStack:Push(Size)
	local Layer = Blur.new()
	Layer:Create()
	Layer:Set(Size)
	table.insert(self.Layers, Layer)
	return Layer
end

function BlurStack:Pop()
	local Layer = table.remove(self.Layers)
	if Layer then
		Layer:Hide()
		task.delay(0.4, function()
			Layer:Destroy()
		end)
	end
end

function BlurStack:Step(Delta)
	for _, Layer in ipairs(self.Layers) do
		Layer:Step(Delta)
	end
end

function BlurStack:Clear()
	for _, Layer in ipairs(self.Layers) do
		Layer:Destroy()
	end
	self.Layers = {}
end

Blur.Stack = BlurStack

return Blur
