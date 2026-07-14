local Utilities = require(script.Parent.Utilities)

local Events = {}
Events.__index = Events

function Events.new()
	local self = setmetatable({}, Events)
	self.Connections = {}
	self.ConnectionsByKey = {}
	return self
end

function Events:Connect(Callback)
	local Connection = {
		Callback = Callback,
		Connected = true,
		Disconnect = function()
			self:Disconnect(Connection)
		end,
	}
	table.insert(self.Connections, Connection)
	return Connection
end

function Events:ConnectOnce(Callback)
	local Connection
	Connection = self:Connect(function(...)
		Connection:Disconnect()
		Utilities.SafeCall(Callback, ...)
	end)
	return Connection
end

function Events:Disconnect(Connection)
	if Connection then
		Connection.Connected = false
		local Index = Utilities.TableFind(self.Connections, Connection)
		if Index then
			table.remove(self.Connections, Index)
		end
	end
end

function Events:DisconnectAll()
	for _, Connection in ipairs(self.Connections) do
		Connection.Connected = false
	end
	self.Connections = {}
end

function Events:Fire(...)
	for Index = #self.Connections, 1, -1 do
		local Connection = self.Connections[Index]
		if Connection.Connected then
			Utilities.SafeCall(Connection.Callback, ...)
		else
			table.remove(self.Connections, Index)
		end
	end
end

function Events:Wait()
	local Thread = coroutine.running()
	local Connection
	Connection = self:ConnectOnce(function(...)
		task.spawn(Thread, ...)
	end)
	return coroutine.yield()
end

function Events:GetConnectionCount()
	return #self.Connections
end

function Events:HasConnections()
	return #self.Connections > 0
end

local Signal = Events

local EventBus = {}
EventBus.__index = EventBus

function EventBus.new()
	local self = setmetatable({}, EventBus)
	self.Channels = {}
	return self
end

function EventBus:GetChannel(Name)
	if not self.Channels[Name] then
		self.Channels[Name] = Events.new()
	end
	return self.Channels[Name]
end

function EventBus:Emit(Name, ...)
	local Channel = self.Channels[Name]
	if Channel then
		Channel:Fire(...)
	end
end

function EventBus:Subscribe(Name, Callback)
	return self:GetChannel(Name):Connect(Callback)
end

function EventBus:Unsubscribe(Name, Connection)
	local Channel = self.Channels[Name]
	if Channel and Connection then
		Channel:Disconnect(Connection)
	end
end

function EventBus:Clear(Name)
	if Name then
		if self.Channels[Name] then
			self.Channels[Name]:DisconnectAll()
		end
	else
		for _, Channel in pairs(self.Channels) do
			Channel:DisconnectAll()
		end
	end
end

Events.Signal = Signal
Events.EventBus = EventBus
Events.Bus = EventBus.new()

return Events
