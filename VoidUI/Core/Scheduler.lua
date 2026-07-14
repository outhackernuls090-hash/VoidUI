local RunService = game:GetService("RunService")

local Scheduler = {}
Scheduler.__index = Scheduler

function Scheduler.new()
	local self = setmetatable({}, Scheduler)
	self.Tasks = {}
	self.HeartbeatTasks = {}
	self.RenderTasks = {}
	self.SteppedTasks = {}
	self.Timers = {}
	self.Active = true
	self.LastTick = tick()
	self:Initialize()
	return self
end

function Scheduler:Initialize()
	self.HeartbeatConnection = RunService.Heartbeat:Connect(function(Delta)
		if not self.Active then
			return
		end
		self:ProcessTimers(Delta)
		self:ProcessTasks(self.HeartbeatTasks, Delta)
	end)

	self.RenderConnection = RunService.RenderStepped:Connect(function(Delta)
		if not self.Active then
			return
		end
		self:ProcessTasks(self.RenderTasks, Delta)
	end)

	self.SteppedConnection = RunService.Stepped:Connect(function(_, Delta)
		if not self.Active then
			return
		end
		self:ProcessTasks(self.SteppedTasks, Delta)
	end)
end

function Scheduler:ProcessTasks(Tasks, Delta)
	for Index = #Tasks, 1, -1 do
		local Task = Tasks[Index]
		if Task.Paused then
			continue
		end
		local Success, ShouldRemove = pcall(Task.Function, Delta, tick())
		if not Success then
			warn("[VoidUI] Scheduler task error:", ShouldRemove)
			table.remove(Tasks, Index)
		elseif ShouldRemove == true then
			table.remove(Tasks, Index)
		end
	end
end

function Scheduler:ProcessTimers(Delta)
	for Index = #self.Timers, 1, -1 do
		local Timer = self.Timers[Index]
		if Timer.Paused then
			continue
		end
		Timer.Elapsed = Timer.Elapsed + Delta
		if Timer.Elapsed >= Timer.Duration then
			Timer.Elapsed = Timer.Elapsed - Timer.Duration
			local Success, Result = pcall(Timer.Callback)
			if not Success then
				warn("[VoidUI] Timer error:", Result)
			end
			if Timer.Repeat == false then
				table.remove(self.Timers, Index)
			end
		end
	end
end

function Scheduler:AddTask(Function, Mode)
	local Task = {
		Function = Function,
		Paused = false,
	}
	Mode = Mode or "Heartbeat"
	local List = self.HeartbeatTasks
	if Mode == "Render" then
		List = self.RenderTasks
	elseif Mode == "Stepped" then
		List = self.SteppedTasks
	end
	table.insert(List, Task)
	return {
		Pause = function()
			Task.Paused = true
		end,
		Resume = function()
			Task.Paused = false
		end,
		Cancel = function()
			Task.Function = function()
				return true
			end
		end,
	}
end

function Scheduler:Every(Duration, Callback, Repeat)
	local Timer = {
		Duration = Duration,
		Elapsed = 0,
		Callback = Callback,
		Repeat = Repeat ~= false,
		Paused = false,
	}
	table.insert(self.Timers, Timer)
	return {
		Pause = function()
			Timer.Paused = true
		end,
		Resume = function()
			Timer.Paused = false
		end,
		Cancel = function()
			Timer.Callback = function() end
			Timer.Repeat = false
		end,
	}
end

function Scheduler:After(Duration, Callback)
	return self:Every(Duration, Callback, false)
end

function Scheduler:Once(Function, Mode)
	return self:AddTask(function()
		Function()
		return true
	end, Mode)
end

function Scheduler:Delay(Duration, Callback)
	return self:After(Duration, Callback)
end

function Scheduler:Yield(Seconds)
	local Thread = coroutine.running()
	self:After(Seconds, function()
		task.spawn(Thread)
	end)
	return coroutine.yield()
end

function Scheduler:SetActive(Active)
	self.Active = Active
end

function Scheduler:Shutdown()
	self.Active = false
	if self.HeartbeatConnection then
		self.HeartbeatConnection:Disconnect()
	end
	if self.RenderConnection then
		self.RenderConnection:Disconnect()
	end
	if self.SteppedConnection then
		self.SteppedConnection:Disconnect()
	end
	self.Tasks = {}
	self.HeartbeatTasks = {}
	self.RenderTasks = {}
	self.SteppedTasks = {}
	self.Timers = {}
end

return Scheduler
