local Utilities = require(script.Parent.Parent.Core.Utilities)

local Tween = {}
Tween.__index = Tween

local EasingFunctions = {
	Linear = function(T) return T end,
	QuadIn = function(T) return T * T end,
	QuadOut = function(T) return 1 - (1 - T) * (1 - T) end,
	QuadInOut = function(T) return T < 0.5 and 2 * T * T or 1 - (-2 * T + 2) ^ 2 / 2 end,
	CubicIn = function(T) return T ^ 3 end,
	CubicOut = function(T) return 1 - (1 - T) ^ 3 end,
	CubicInOut = function(T) return T < 0.5 and 4 * T ^ 3 or 1 - (-2 * T + 2) ^ 3 / 2 end,
	QuartIn = function(T) return T ^ 4 end,
	QuartOut = function(T) return 1 - (1 - T) ^ 4 end,
	QuartInOut = function(T) return T < 0.5 and 8 * T ^ 4 or 1 - (-2 * T + 2) ^ 4 / 2 end,
	ExpoIn = function(T) return T == 0 and 0 or 2 ^ (10 * T - 10) end,
	ExpoOut = function(T) return T == 1 and 1 or 1 - 2 ^ (-10 * T) end,
	ExpoInOut = function(T)
		if T == 0 then return 0 end
		if T == 1 then return 1 end
		return T < 0.5 and 2 ^ (20 * T - 10) / 2 or (2 - 2 ^ (-20 * T + 10)) / 2
	end,
	CircIn = function(T) return 1 - math.sqrt(1 - T ^ 2) end,
	CircOut = function(T) return math.sqrt(1 - (T - 1) ^ 2) end,
	CircInOut = function(T)
		return T < 0.5 and (1 - math.sqrt(1 - (2 * T) ^ 2)) / 2 or (math.sqrt(1 - (-2 * T + 2) ^ 2) + 1) / 2
	end,
	BackIn = Utilities.EaseOutBack,
	BackOut = function(T) return 1 + 2.70158 * (T - 1) ^ 3 + 1.70158 * (T - 1) ^ 2 end,
	BackInOut = function(T)
		local C1 = 1.70158
		local C2 = C1 * 1.525
		return T < 0.5 and ((2 * T) ^ 2 * ((C2 + 1) * 2 * T - C2)) / 2 or ((2 * T - 2) ^ 2 * ((C2 + 1) * (T * 2 - 2) + C2) + 2) / 2
	end,
	ElasticIn = function(T)
		if T == 0 then return 0 end
		if T == 1 then return 1 end
		local C4 = (2 * math.pi) / 3
		return -(2 ^ (10 * T - 10)) * math.sin((T * 10 - 10.75) * C4)
	end,
	ElasticOut = Utilities.EaseOutElastic,
	ElasticInOut = function(T)
		if T == 0 then return 0 end
		if T == 1 then return 1 end
		local C5 = (2 * math.pi) / 4.5
		return T < 0.5 and -(2 ^ (20 * T - 10) * math.sin((20 * T - 11.125) * C5)) / 2 or (2 ^ (-20 * T + 10) * math.sin((20 * T - 11.125) * C5)) / 2 + 1
	end,
	BounceIn = function(T)
		return 1 - Utilities.EaseOutBounce(1 - T)
	end,
	BounceOut = Utilities.EaseOutBounce,
	BounceInOut = function(T)
		return T < 0.5 and (1 - Utilities.EaseOutBounce(1 - 2 * T)) / 2 or (1 + Utilities.EaseOutBounce(2 * T - 1)) / 2
	end,
	SineIn = function(T) return 1 - math.cos((T * math.pi) / 2) end,
	SineOut = Utilities.EaseInOutSine and function(T) return math.sin((T * math.pi) / 2) end,
	SineInOut = Utilities.EaseInOutSine,
}

EasingFunctions.SineOut = function(T) return math.sin((T * math.pi) / 2) end

function Tween.GetEasing(Name)
	return EasingFunctions[Name] or EasingFunctions.QuadOut
end

function Tween.new(Options)
	local self = setmetatable({}, Tween)
	self.Duration = Options.Duration or 0.4
	self.Easing = Tween.GetEasing(Options.Easing or "QuadOut")
	self.Delay = Options.Delay or 0
	self.OnUpdate = Options.OnUpdate
	self.OnComplete = Options.OnComplete
	self.OnStart = Options.OnStart
	self.Elapsed = 0
	self.Started = false
	self.Completed = false
	self.Paused = false
	self.Reversed = false
	self.Yoyo = Options.Yoyo or false
	self.RepeatCount = Options.RepeatCount or 0
	self.RepeatIndex = 0
	self.From = Options.From
	self.To = Options.To
	self.Value = Options.From
	self._Direction = 1
	return self
end

function Tween:Start()
	self.Started = true
	self.Elapsed = 0
	if self.OnStart then
		self.OnStart()
	end
	return self
end

function Tween:Play()
	return self:Start()
end

function Tween:Step(Delta)
	if not self.Started or self.Completed or self.Paused then
		return
	end
	if self.Delay > 0 then
		self.Delay = self.Delay - Delta
		if self.Delay > 0 then
			return
		end
		Delta = -self.Delay
		self.Delay = 0
	end
	self.Elapsed = self.Elapsed + Delta * self._Direction
	local Progress = Utilities.Clamp(self.Elapsed / self.Duration, 0, 1)
	local Eased = self.Easing(Progress)
	if self.From ~= nil and self.To ~= nil then
		self.Value = Utilities.Lerp(self.From, self.To, Eased)
	end
	if self.OnUpdate then
		self.OnUpdate(self.Value, Eased, Progress)
	end
	if Progress >= 1 then
		if self.Yoyo and self._Direction == 1 then
			self._Direction = -1
			self.Elapsed = self.Duration
		elseif self.RepeatCount > 0 or self.RepeatCount == -1 then
			self.RepeatIndex = self.RepeatIndex + 1
			if self.RepeatCount == -1 or self.RepeatIndex < self.RepeatCount then
				self.Elapsed = 0
				self._Direction = 1
			else
				self:Finish()
			end
		else
			self:Finish()
		end
	end
end

function Tween:Finish()
	self.Completed = true
	self.Value = self.To
	if self.OnComplete then
		self.OnComplete()
	end
end

function Tween:Pause()
	self.Paused = true
end

function Tween:Resume()
	self.Paused = false
end

function Tween:Cancel()
	self.Completed = true
end

function Tween:IsCompleted()
	return self.Completed
end

function Tween:IsActive()
	return self.Started and not self.Completed
end

local Timeline = {}
Timeline.__index = Timeline

function Timeline.new()
	local self = setmetatable({}, Timeline)
	self.Tracks = {}
	self.Tweens = {}
	self.Elapsed = 0
	self.Duration = 0
	self.Playing = false
	self.Completed = false
	self.OnComplete = nil
	return self
end

function Timeline:Add(Tween, Offset)
	Offset = Offset or 0
	Tween._Offset = Offset
	table.insert(self.Tweens, Tween)
	self.Duration = math.max(self.Duration, Offset + Tween.Duration)
	return self
end

function Timeline:Track(Name)
	local Track = Timeline.new()
	self.Tracks[Name] = Track
	return Track
end

function Timeline:Play()
	self.Playing = true
	self.Elapsed = 0
	self.Completed = false
	for _, Tween in ipairs(self.Tweens) do
		Tween:Start()
	end
	return self
end

function Timeline:Step(Delta)
	if not self.Playing or self.Completed then
		return
	end
	self.Elapsed = self.Elapsed + Delta
	local AllDone = true
	for _, Tween in ipairs(self.Tweens) do
		if self.Elapsed >= (Tween._Offset or 0) then
			Tween:Step(Delta)
		end
		if not Tween.Completed then
			AllDone = false
		end
	end
	if AllDone then
		self.Completed = true
		self.Playing = false
		if self.OnComplete then
			self.OnComplete()
		end
	end
end

function Timeline:Stop()
	self.Playing = false
end

Tween.Timeline = Timeline
Tween.Easings = EasingFunctions

return Tween
