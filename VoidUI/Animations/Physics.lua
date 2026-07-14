local Utilities = require(script.Parent.Parent.Core.Utilities)

local Physics = {}
Physics.__index = Physics

function Physics.new(Initial)
	local self = setmetatable({}, Physics)
	self.Position = Initial and Initial.Position or Vector2.new(0, 0)
	self.Velocity = Initial and Initial.Velocity or Vector2.new(0, 0)
	self.Acceleration = Initial and Initial.Acceleration or Vector2.new(0, 0)
	self.Drag = Initial and Initial.Drag or 0.1
	self.Mass = Initial and Initial.Mass or 1
	self.Gravity = Initial and Initial.Gravity or Vector2.new(0, 0)
	self.Bounds = Initial and Initial.Bounds
	self.Restitution = Initial and Initial.Restitution or 0.6
	self.Friction = Initial and Initial.Friction or 0.98
	return self
end

function Physics:ApplyForce(Force)
	self.Acceleration = self.Acceleration + Force / self.Mass
end

function Physics:ApplyImpulse(Impulse)
	self.Velocity = self.Velocity + Impulse / self.Mass
end

function Physics:SetBounds(Min, Max)
	self.Bounds = { Min = Min, Max = Max }
end

function Physics:Step(Delta)
	Delta = math.min(Delta, 1 / 30)
	self.Velocity = self.Velocity + (self.Acceleration + self.Gravity) * Delta
	self.Velocity = self.Velocity * (1 - self.Drag * Delta)
	self.Position = self.Position + self.Velocity * Delta
	if self.Bounds then
		local Min = self.Bounds.Min
		local Max = self.Bounds.Max
		if self.Position.X < Min.X then
			self.Position = Vector2.new(Min.X, self.Position.Y)
			self.Velocity = Vector2.new(-self.Velocity.X * self.Restitution, self.Velocity.Y * self.Friction)
		elseif self.Position.X > Max.X then
			self.Position = Vector2.new(Max.X, self.Position.Y)
			self.Velocity = Vector2.new(-self.Velocity.X * self.Restitution, self.Velocity.Y * self.Friction)
		end
		if self.Position.Y < Min.Y then
			self.Position = Vector2.new(self.Position.X, Min.Y)
			self.Velocity = Vector2.new(self.Velocity.X * self.Friction, -self.Velocity.Y * self.Restitution)
		elseif self.Position.Y > Max.Y then
			self.Position = Vector2.new(self.Position.X, Max.Y)
			self.Velocity = Vector2.new(self.Velocity.X * self.Friction, -self.Velocity.Y * self.Restitution)
		end
	end
	self.Acceleration = Vector2.new(0, 0)
end

function Physics:IsResting()
	return self.Velocity.Magnitude < 0.05
end

local Particle = {}
Particle.__index = Particle

function Particle.new(Properties)
	local self = setmetatable({}, Particle)
	self.Position = Properties.Position or Vector2.new(0, 0)
	self.Velocity = Properties.Velocity or Vector2.new(0, 0)
	self.Acceleration = Properties.Acceleration or Vector2.new(0, 0)
	self.Life = Properties.Life or 1
	self.MaxLife = Properties.Life or 1
	self.Size = Properties.Size or 4
	self.Color = Properties.Color or Color3.fromRGB(255, 255, 255)
	self.Alpha = Properties.Alpha or 1
	self.Rotation = Properties.Rotation or 0
	self.AngularVelocity = Properties.AngularVelocity or 0
	self.Shape = Properties.Shape or "Circle"
	self.Drag = Properties.Drag or 0.5
	self.Gravity = Properties.Gravity or Vector2.new(0, 0)
	self.Alive = true
	return self
end

function Particle:Step(Delta)
	self.Velocity = self.Velocity + (self.Acceleration + self.Gravity) * Delta
	self.Velocity = self.Velocity * (1 - self.Drag * Delta)
	self.Position = self.Position + self.Velocity * Delta
	self.Rotation = self.Rotation + self.AngularVelocity * Delta
	self.Life = self.Life - Delta
	if self.Life <= 0 then
		self.Alive = false
	end
end

function Particle:GetAlpha()
	return self.Alpha * Utilities.Clamp(self.Life / self.MaxLife, 0, 1)
end

Physics.Particle = Particle

local Field = {}
Field.__index = Field

function Field.new()
	local self = setmetatable({}, Field)
	self.Forces = {}
	self.Particles = {}
	return self
end

function Field:AddForce(Force)
	table.insert(self.Forces, Force)
end

function Field:AddParticle(Particle)
	table.insert(self.Particles, Particle)
end

function Field:Step(Delta)
	for Index = #self.Particles, 1, -1 do
		local P = self.Particles[Index]
		for _, Force in ipairs(self.Forces) do
			Force(P, Delta)
		end
		P:Step(Delta)
		if not P.Alive then
			table.remove(self.Particles, Index)
		end
	end
end

function Field:GetCount()
	return #self.Particles
end

function Field:Clear()
	self.Particles = {}
end

Physics.Field = Field

return Physics
