local Utilities = require(script.Parent.Utilities)

local Cleanup = {}
Cleanup.__index = Cleanup

function Cleanup.new()
	local self = setmetatable({}, Cleanup)
	self.Items = {}
	self.Connections = {}
	self.Tasks = {}
	self.Instances = {}
	self.Callbacks = {}
	self.Destroyed = false
	return self
end

function Cleanup:Add(Item)
	if Item == nil then
		return Item
	end
	if type(Item) == "function" then
		table.insert(self.Callbacks, Item)
	elseif typeof(Item) == "RBXScriptConnection" then
		table.insert(self.Connections, Item)
	elseif typeof(Item) == "Instance" then
		table.insert(self.Instances, Item)
	elseif type(Item) == "table" and Item.Disconnect then
		table.insert(self.Connections, Item)
	elseif type(Item) == "table" and Item.Cancel then
		table.insert(self.Tasks, Item)
	else
		table.insert(self.Items, Item)
	end
	return Item
end

function Cleanup:AddConnection(Connection)
	table.insert(self.Connections, Connection)
	return Connection
end

function Cleanup:AddInstance(Instance)
	table.insert(self.Instances, Instance)
	return Instance
end

function Cleanup:AddCallback(Callback)
	table.insert(self.Callbacks, Callback)
	return Callback
end

function Cleanup:AddTask(Task)
	table.insert(self.Tasks, Task)
	return Task
end

function Cleanup:Track(Object)
	return self:Add(Object)
end

function Cleanup:Untrack(Object)
	local Lists = { self.Connections, self.Instances, self.Tasks, self.Callbacks, self.Items }
	for _, List in ipairs(Lists) do
		local Index = Utilities.TableFind(List, Object)
		if Index then
			table.remove(List, Index)
			return true
		end
	end
	return false
end

function Cleanup:DisconnectConnections()
	for _, Connection in ipairs(self.Connections) do
		if Connection.Connected then
			Connection:Disconnect()
		end
	end
	self.Connections = {}
end

function Cleanup:DestroyInstances()
	for _, Instance in ipairs(self.Instances) do
		if Instance and Instance.Parent then
			pcall(function()
				Instance:Destroy()
			end)
		end
	end
	self.Instances = {}
end

function Cleanup:CancelTasks()
	for _, Task in ipairs(self.Tasks) do
		if Task.Cancel then
			pcall(Task.Cancel)
		end
	end
	self.Tasks = {}
end

function Cleanup:RunCallbacks()
	for _, Callback in ipairs(self.Callbacks) do
		pcall(Callback)
	end
	self.Callbacks = {}
end

function Cleanup:Destroy()
	if self.Destroyed then
		return
	end
	self.Destroyed = true
	self:DisconnectConnections()
	self:CancelTasks()
	self:DestroyInstances()
	self:RunCallbacks()
	self.Items = {}
end

function Cleanup:IsDestroyed()
	return self.Destroyed
end

local CleanupGroup = {}
CleanupGroup.__index = CleanupGroup

function CleanupGroup.new()
	local self = setmetatable({}, CleanupGroup)
	self.Groups = {}
	return self
end

function CleanupGroup:Create(Name)
	local Group = Cleanup.new()
	self.Groups[Name] = Group
	return Group
end

function CleanupGroup:Get(Name)
	return self.Groups[Name]
end

function CleanupGroup:Destroy(Name)
	if Name then
		local Group = self.Groups[Name]
		if Group then
			Group:Destroy()
			self.Groups[Name] = nil
		end
	else
		for _, Group in pairs(self.Groups) do
			Group:Destroy()
		end
		self.Groups = {}
	end
end

Cleanup.Group = CleanupGroup

return Cleanup
