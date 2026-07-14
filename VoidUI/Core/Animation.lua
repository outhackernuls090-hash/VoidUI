local Utilities = require(script.Parent.Utilities)
local Scheduler = require(script.Parent.Scheduler)
local Events = require(script.Parent.Events)
local Spring = require(script.Parent.Parent.Animations.Spring)
local Tween = require(script.Parent.Parent.Animations.Tween)
local Physics = require(script.Parent.Parent.Animations.Physics)
local Blur = require(script.Parent.Parent.Animations.Blur)
local Glow = require(script.Parent.Parent.Animations.Glow)
local Particles = require(script.Parent.Parent.Animations.Particles)

local Animation = {}
Animation.__index = Animation

function Animation.new()
	local self = setmetatable({}, Animation)
	self.Scheduler = Scheduler.new()
	self.Springs = {}
	self.Tweens = {}
	self.Timelines = {}
	self.Blurs = {}
	self.Glows = {}
	self.ParticleSystems = {}
	self.Updated = Events.new()
	self._Task = self.Scheduler:AddTask(function(Delta)
		self:Update(Delta)
	end, "Render")
	return self
end

function Animation:Update(Delta)
	for Index = #self.Springs, 1, -1 do
		local SpringItem = self.Springs[Index]
		local Settled = SpringItem.Spring:Step(Delta)
		if SpringItem.OnUpdate then
			SpringItem.OnUpdate(SpringItem.Spring.Value)
		end
		if Settled then
			if SpringItem.OnComplete then
				SpringItem.OnComplete(SpringItem.Spring.Value)
			end
			table.remove(self.Springs, Index)
		end
	end

	for Index = #self.Tweens, 1, -1 do
		local TweenItem = self.Tweens[Index]
		TweenItem:Step(Delta)
		if TweenItem.Completed then
			table.remove(self.Tweens, Index)
		end
	end

	for Index = #self.Timelines, 1, -1 do
		local Timeline = self.Timelines[Index]
		Timeline:Step(Delta)
		if Timeline.Completed then
			table.remove(self.Timelines, Index)
		end
	end

	for _, Blur in ipairs(self.Blurs) do
		Blur:Step(Delta)
	end

	for _, Glow in ipairs(self.Glows) do
		Glow:Step(Delta)
	end

	for _, ParticleSystem in ipairs(self.ParticleSystems) do
		ParticleSystem:Step(Delta)
	end

	self.Updated:Fire(Delta)
end

function Animation:Spring(Initial, Options)
	Options = Options or {}
	local SpringItem = Spring.new(
		Initial,
		Options.Stiffness,
		Options.Damping,
		Options.Mass,
		Options.Velocity
	)
	local Wrapper = {
		Spring = SpringItem,
		OnUpdate = Options.OnUpdate,
		OnComplete = Options.OnComplete,
	}
	table.insert(self.Springs, Wrapper)
	return SpringItem
end

function Animation:Tween(Options)
	local TweenItem = Tween.new(Options)
	TweenItem:Start()
	table.insert(self.Tweens, TweenItem)
	return TweenItem
end

function Animation:Timeline()
	local Timeline = Tween.Timeline.new()
	table.insert(self.Timelines, Timeline)
	return Timeline
end

function Animation:Blur()
	local BlurItem = Blur.new()
	table.insert(self.Blurs, BlurItem)
	return BlurItem
end

function Animation:Glow(Instance, Options)
	local GlowItem = Glow.new(Instance, Options)
	table.insert(self.Glows, GlowItem)
	return GlowItem
end

function Animation:Particles(Container)
	local ParticleSystem = Particles.new(Container)
	table.insert(self.ParticleSystems, ParticleSystem)
	return ParticleSystem
end

function Animation:TrackSpring(SpringItem, OnUpdate, OnComplete)
	local Wrapper = {
		Spring = SpringItem,
		OnUpdate = OnUpdate,
		OnComplete = OnComplete,
	}
	table.insert(self.Springs, Wrapper)
	return SpringItem
end

function Animation:Animate(Instance, Property, Goal, Options)
	Options = Options or {}
	local Current = Instance[Property]
	local IsColor = typeof(Current) == "Color3"
	local IsUDim2 = typeof(Current) == "UDim2"
	local IsNumber = type(Current) == "number"
	local IsVector2 = typeof(Current) == "Vector2"

	if Options.Spring then
		if IsColor then
			local SpringColor = Spring.SpringColor.new(Current, Options.Stiffness, Options.Damping)
			SpringColor:SetTarget(Goal)
			return self:TrackSpring(SpringColor, function(Color)
				Instance[Property] = Color
			end)
		elseif IsNumber then
			local S = self:Spring(Current, {
				Stiffness = Options.Stiffness,
				Damping = Options.Damping,
				OnUpdate = function(Value)
					Instance[Property] = Value
				end,
			})
			S:SetTarget(Goal)
			return S
		end
	else
		if IsColor then
			local From = Current
			return self:Tween({
				Duration = Options.Duration or 0.3,
				Easing = Options.Easing or "QuadOut",
				Delay = Options.Delay or 0,
				OnUpdate = function(_, _, Progress)
					Instance[Property] = Color3.new(
						Utilities.Lerp(From.R, Goal.R, Progress),
						Utilities.Lerp(From.G, Goal.G, Progress),
						Utilities.Lerp(From.B, Goal.B, Progress)
					)
				end,
			})
		elseif IsUDim2 then
			local From = Current
			return self:Tween({
				Duration = Options.Duration or 0.3,
				Easing = Options.Easing or "QuadOut",
				Delay = Options.Delay or 0,
				OnUpdate = function(_, _, Progress)
					Instance[Property] = UDim2.new(
						Utilities.Lerp(From.X.Scale, Goal.X.Scale, Progress),
						Utilities.Lerp(From.X.Offset, Goal.X.Offset, Progress),
						Utilities.Lerp(From.Y.Scale, Goal.Y.Scale, Progress),
						Utilities.Lerp(From.Y.Offset, Goal.Y.Offset, Progress)
					)
				end,
			})
		elseif IsNumber then
			local From = Current
			return self:Tween({
				Duration = Options.Duration or 0.3,
				Easing = Options.Easing or "QuadOut",
				Delay = Options.Delay or 0,
				OnUpdate = function(_, _, Progress)
					Instance[Property] = Utilities.Lerp(From, Goal, Progress)
				end,
			})
		elseif IsVector2 then
			local From = Current
			return self:Tween({
				Duration = Options.Duration or 0.3,
				Easing = Options.Easing or "QuadOut",
				Delay = Options.Delay or 0,
				OnUpdate = function(_, _, Progress)
					Instance[Property] = Vector2.new(
						Utilities.Lerp(From.X, Goal.X, Progress),
						Utilities.Lerp(From.Y, Goal.Y, Progress)
					)
				end,
			})
		end
	end
end

function Animation:Sequence(Steps)
	local Timeline = self:Timeline()
	local Offset = 0
	for _, Step in ipairs(Steps) do
		local TweenItem = Tween.new(Step)
		TweenItem:Start()
		Timeline:Add(TweenItem, Offset)
		Offset = Offset + (Step.Offset or Step.Duration or 0.3)
	end
	return Timeline
end

function Animation:Stagger(Items, AnimateFunction, Options)
	Options = Options or {}
	local Delay = Options.Delay or 0.05
	local Timeline = self:Timeline()
	for Index, Item in ipairs(Items) do
		local TweenItem = AnimateFunction(Item, Index)
		if TweenItem then
			Timeline:Add(TweenItem, (Index - 1) * Delay)
		end
	end
	return Timeline
end

function Animation:Wait(Seconds)
	return self.Scheduler:Yield(Seconds)
end

function Animation:SetSpeed(Speed)
	self.Scheduler.Active = Speed > 0
end

function Animation:Shutdown()
	self.Springs = {}
	self.Tweens = {}
	self.Timelines = {}
	for _, Blur in ipairs(self.Blurs) do
		Blur:Destroy()
	end
	self.Blurs = {}
	for _, Glow in ipairs(self.Glows) do
		Glow:Destroy()
	end
	self.Glows = {}
	for _, ParticleSystem in ipairs(self.ParticleSystems) do
		ParticleSystem:Destroy()
	end
	self.ParticleSystems = {}
	self.Scheduler:Shutdown()
end

Animation.Classes = {
	Spring = Spring,
	Tween = Tween,
	Physics = Physics,
	Blur = Blur,
	Glow = Glow,
	Particles = Particles,
}

return Animation
