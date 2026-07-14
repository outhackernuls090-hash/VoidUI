local Utilities = require(script.Parent.Parent.Core.Utilities)
local Physics = require(script.Parent.Physics)
local Spring = require(script.Parent.Spring)

local Particles = {}
Particles.__index = Particles

function Particles.new(Container)
	local self = setmetatable({}, Particles)
	self.Container = Container
	self.Field = Physics.Field.new()
	self.Emitters = {}
	self.MaxParticles = 400
	self.RenderEnabled = true
	self._Pool = {}
	self._Active = {}
	return self
end

function Particles:CreateParticle(Properties)
	local Particle = Physics.Particle.new(Properties)
	local Frame = self:GetFromPool()
	Frame.Position = UDim2.fromOffset(Particle.Position.X, Particle.Position.Y)
	Frame.BackgroundColor3 = Particle.Color
	Frame.Size = UDim2.fromOffset(Particle.Size, Particle.Size)
	Frame.Visible = true
	Particle._Frame = Frame
	table.insert(self._Active, Particle)
	self.Field:AddParticle(Particle)
	return Particle
end

function Particles:GetFromPool()
	if #self._Pool > 0 then
		return table.remove(self._Pool)
	end
	local Frame = Utilities.Create("Frame", {
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0.5, 0.5),
		ZIndex = 50,
		Parent = self.Container,
	})
	local Corner = Utilities.Roundify(Frame, 999)
	return Frame
end

function Particles:ReturnToPool(Frame)
	Frame.Visible = false
	table.insert(self._Pool, Frame)
end

function Particles:Emit(Count, Config)
	Count = Count or 10
	Config = Config or {}
	local Center = Config.Position or Vector2.new(0, 0)
	local Spread = Config.Spread or 360
	local Speed = Config.Speed or 60
	local Life = Config.Life or 1
	local Size = Config.Size or 4
	local Color = Config.Color or Color3.fromRGB(140, 180, 255)
	local Shape = Config.Shape or "Circle"
	local Gravity = Config.Gravity or Vector2.new(0, 0)
	for _ = 1, Count do
		if #self._Active >= self.MaxParticles then
			break
		end
		local Angle = math.rad(math.random(0, 360))
		local Velocity = Vector2.new(math.cos(Angle), math.sin(Angle)) * (Speed * (0.5 + math.random() * 0.5))
		self:CreateParticle({
			Position = Center,
			Velocity = Velocity,
			Life = Life * (0.6 + math.random() * 0.6),
			Size = Size * (0.6 + math.random() * 0.8),
			Color = Color,
			Shape = Shape,
			Gravity = Gravity,
			Drag = Config.Drag or 0.6,
		})
	end
end

function Particles:Orbit(Center, Count, Radius, Color)
	Count = Count or 12
	for I = 1, Count do
		local Angle = (I / Count) * math.pi * 2
		local Position = Center + Vector2.new(math.cos(Angle), math.sin(Angle)) * Radius
		local Tangent = Vector2.new(-math.sin(Angle), math.cos(Angle)) * 40
		self:CreateParticle({
			Position = Position,
			Velocity = Tangent,
			Life = 999,
			Size = 3,
			Color = Color or Color3.fromRGB(150, 190, 255),
			Drag = 0,
			Gravity = Vector2.new(0, 0),
		})
	end
end

function Particles:Step(Delta)
	self.Field:Step(Delta)
	for Index = #self._Active, 1, -1 do
		local Particle = self._Active[Index]
		if not Particle.Alive then
			if Particle._Frame then
				self:ReturnToPool(Particle._Frame)
			end
			table.remove(self._Active, Index)
		else
			local Frame = Particle._Frame
			if Frame then
				Frame.Position = UDim2.fromOffset(Particle.Position.X, Particle.Position.Y)
				Frame.BackgroundColor3 = Particle.Color
				local Scale = Particle:GetAlpha()
				Frame.BackgroundTransparency = 1 - Scale
				Frame.Size = UDim2.fromOffset(Particle.Size * (0.5 + Scale * 0.5), Particle.Size * (0.5 + Scale * 0.5))
			end
		end
	end
end

function Particles:GetActiveCount()
	return #self._Active
end

function Particles:Clear()
	for _, Particle in ipairs(self._Active) do
		if Particle._Frame then
			self:ReturnToPool(Particle._Frame)
		end
	end
	self._Active = {}
	self.Field:Clear()
end

function Particles:Destroy()
	self:Clear()
	for _, Frame in ipairs(self._Pool) do
		Frame:Destroy()
	end
	self._Pool = {}
end

return Particles
