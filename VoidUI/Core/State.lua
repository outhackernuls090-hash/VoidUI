local Utilities = require(script.Parent.Utilities)
local Events = require(script.Parent.Events)

local State = {}
State.__index = State

function State.new(Initial)
	local self = setmetatable({}, State)
	self.Value = Initial
	self.Changed = Events.new()
	self._Connections = {}
	return self
end

function State:Get()
	return self.Value
end

function State:Set(NewValue, Silent)
	if NewValue == self.Value then
		return
	end
	local OldValue = self.Value
	self.Value = NewValue
	if not Silent then
		self.Changed:Fire(NewValue, OldValue)
	end
end

function State:Update(Transform)
	self:Set(Transform(self.Value))
end

function State:Subscribe(Callback)
	return self.Changed:Connect(Callback)
end

function State:SubscribeOnce(Callback)
	return self.Changed:ConnectOnce(Callback)
end

function State:Map(Transform)
	local Derived = State.new(Transform(self.Value))
	self:Subscribe(function(Value)
		Derived:Set(Transform(Value))
	end)
	return Derived
end

function State:Combine(Other, Combine)
	local Derived = State.new(Combine(self.Value, Other:Get()))
	local function Update()
		Derived:Set(Combine(self.Value, Other:Get()))
	end
	self:Subscribe(Update)
	Other:Subscribe(Update)
	return Derived
end

function State:Destroy()
	self.Changed:DisconnectAll()
	self.Value = nil
end

local Store = {}
Store.__index = Store

function Store.new(Initial)
	local self = setmetatable({}, Store)
	self.State = {}
	self.Changed = Events.new()
	if Initial then
		for Key, Value in pairs(Initial) do
			self.State[Key] = State.new(Value)
		end
	end
	return self
end

function Store:Create(Key, Initial)
	self.State[Key] = State.new(Initial)
	return self.State[Key]
end

function Store:Get(Key)
	local S = self.State[Key]
	return S and S:Get()
end

function Store:Set(Key, Value)
	local S = self.State[Key]
	if S then
		S:Set(Value)
		self.Changed:Fire(Key, Value)
	end
end

function Store:Subscribe(Key, Callback)
	local S = self.State[Key]
	if S then
		return S:Subscribe(Callback)
	end
	return nil
end

function Store:SubscribeAll(Callback)
	return self.Changed:Connect(Callback)
end

function Store:Destroy()
	for _, S in pairs(self.State) do
		S:Destroy()
	end
	self.State = {}
	self.Changed:DisconnectAll()
end

State.Store = Store

return State
