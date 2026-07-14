local Utilities = require(script.Parent.Parent.Core.Utilities)

local Spring = {}
Spring.__index = Spring

function Spring.new(Initial, Stiffness, Damping, Mass, Velocity)
	local self = setmetatable({}, Spring)
	self.Value = Initial or 0
	self.Target = Initial or 0
	self.Velocity = Velocity or 0
	self.Stiffness = Stiffness or 170
	self.Damping = Damping or 22
	self.Mass = Mass or 1
	self.Precision = 0.001
	self.Changed = nil
	return self
end

function Spring:SetTarget(Target)
	self.Target = Target
end

function Spring:Impulse(Velocity)
	self.Velocity = self.Velocity + Velocity
end

function Spring:SetValue(Value)
	self.Value = Value
	self.Velocity = 0
end

function Spring:Step(Delta)
	Delta = math.min(Delta, 1 / 30)
	local Force = -self.Stiffness * (self.Value - self.Target)
	local Damping = -self.Damping * self.Velocity
	local Acceleration = (Force + Damping) / self.Mass
	self.Velocity = self.Velocity + Acceleration * Delta
	self.Value = self.Value + self.Velocity * Delta
	if math.abs(self.Velocity) < self.Precision and math.abs(self.Value - self.Target) < self.Precision then
		self.Value = self.Target
		self.Velocity = 0
		return true
	end
	return false
end

function Spring:IsSettled()
	return self.Value == self.Target and self.Velocity == 0
end

function Spring:Snap()
	self.Value = self.Target
	self.Velocity = 0
end

local Spring2D = {}
Spring2D.__index = Spring2D

function Spring2D.new(InitialX, InitialY, Stiffness, Damping)
	local self = setmetatable({}, Spring2D)
	self.X = Spring.new(InitialX or 0, Stiffness, Damping)
	self.Y = Spring.new(InitialY or 0, Stiffness, Damping)
	return self
end

function Spring2D:SetTarget(X, Y)
	self.X:SetTarget(X)
	self.Y:SetTarget(Y)
end

function Spring2D:Step(Delta)
	local DoneX = self.X:Step(Delta)
	local DoneY = self.Y:Step(Delta)
	return DoneX and DoneY
end

function Spring2D:Get()
	return self.X.Value, self.Y.Value
end

local SpringColor = {}
SpringColor.__index = SpringColor

function SpringColor.new(Initial, Stiffness, Damping)
	local self = setmetatable({}, SpringColor)
	local R, G, B = Initial.R, Initial.G, Initial.B
	self.R = Spring.new(R, Stiffness, Damping)
	self.G = Spring.new(G, Stiffness, Damping)
	self.B = Spring.new(B, Stiffness, Damping)
	return self
end

function SpringColor:SetTarget(Color)
	self.R:SetTarget(Color.R)
	self.G:SetTarget(Color.G)
	self.B:SetTarget(Color.B)
end

function SpringColor:Step(Delta)
	self.R:Step(Delta)
	self.G:Step(Delta)
	self.B:Step(Delta)
end

function SpringColor:Get()
	return Color3.new(self.R.Value, self.G.Value, self.B.Value)
end

local SpringNumber = Spring

Spring.Spring2D = Spring2D
Spring.SpringColor = SpringColor
Spring.Number = SpringNumber

return Spring
