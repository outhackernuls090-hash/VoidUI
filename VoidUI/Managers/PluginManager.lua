local Utilities = require(script.Parent.Parent.Core.Utilities)
local Events = require(script.Parent.Parent.Core.Events)

local PluginManager = {}
PluginManager.__index = PluginManager

function PluginManager.new()
	local self = setmetatable({}, PluginManager)
	self.Plugins = {}
	self.Loaded = Events.new()
	self.Unloaded = Events.new()
	self.Enabled = Events.new()
	self.Disabled = Events.new()
	self.Hooks = {}
	self.Middlewares = {}
	return self
end

function PluginManager:Register(Plugin)
	if not Plugin or not Plugin.Name then
		warn("[VoidUI] Invalid plugin")
		return false
	end
	if self.Plugins[Plugin.Name] then
		warn("[VoidUI] Plugin already registered:", Plugin.Name)
		return false
	end
	Plugin.Enabled = false
	Plugin.Priority = Plugin.Priority or 100
	self.Plugins[Plugin.Name] = Plugin
	return true
end

function PluginManager:RegisterMany(Plugins)
	for _, Plugin in ipairs(Plugins) do
		self:Register(Plugin)
	end
end

function PluginManager:Get(Name)
	return self.Plugins[Name]
end

function PluginManager:List()
	return Utilities.TableValues(self.Plugins)
end

function PluginManager:Load(Name, Context)
	local Plugin = self.Plugins[Name]
	if not Plugin then
		return false
	end
	if Plugin.Enabled then
		return true
	end
	local Success, Error = pcall(function()
		if Plugin.Init then
			Plugin:Init(Context)
		end
		if Plugin.OnLoad then
			Plugin:OnLoad(Context)
		end
	end)
	if Success then
		Plugin.Enabled = true
		self.Loaded:Fire(Plugin, Context)
	else
		warn("[VoidUI] Plugin load failed:", Name, Error)
	end
	return Success
end

function PluginManager:Unload(Name)
	local Plugin = self.Plugins[Name]
	if not Plugin or not Plugin.Enabled then
		return false
	end
	pcall(function()
		if Plugin.OnUnload then
			Plugin:OnUnload()
		end
	end)
	Plugin.Enabled = false
	self.Unloaded:Fire(Plugin)
	return true
end

function PluginManager:Enable(Name)
	local Plugin = self.Plugins[Name]
	if Plugin and not Plugin.Enabled then
		Plugin.Enabled = true
		self.Enabled:Fire(Plugin)
	end
end

function PluginManager:Disable(Name)
	local Plugin = self.Plugins[Name]
	if Plugin and Plugin.Enabled then
		Plugin.Enabled = false
		self.Disabled:Fire(Plugin)
	end
end

function PluginManager:LoadAll(Context)
	local Sorted = self:List()
	table.sort(Sorted, function(A, B)
		return A.Priority < B.Priority
	end)
	for _, Plugin in ipairs(Sorted) do
		self:Load(Plugin.Name, Context)
	end
end

function PluginManager:UnloadAll()
	for _, Plugin in ipairs(self:List()) do
		self:Unload(Plugin.Name)
	end
end

function PluginManager:AddHook(EventName, Callback)
	if not self.Hooks[EventName] then
		self.Hooks[EventName] = {}
	end
	table.insert(self.Hooks[EventName], Callback)
end

function PluginManager:TriggerHook(EventName, ...)
	local Hooks = self.Hooks[EventName]
	if Hooks then
		for _, Callback in ipairs(Hooks) do
			pcall(Callback, ...)
		end
	end
end

function PluginManager:AddMiddleware(Middleware)
	table.insert(self.Middlewares, Middleware)
end

function PluginManager:RunMiddlewares(Context)
	for _, Middleware in ipairs(self.Middlewares) do
		pcall(Middleware, Context)
	end
end

function PluginManager:IsEnabled(Name)
	local Plugin = self.Plugins[Name]
	return Plugin and Plugin.Enabled or false
end

function PluginManager:Count()
	return Utilities.TableLength(self.Plugins)
end

function PluginManager:Destroy()
	self:UnloadAll()
	self.Plugins = {}
	self.Hooks = {}
	self.Middlewares = {}
	self.Loaded:DisconnectAll()
	self.Unloaded:DisconnectAll()
	self.Enabled:DisconnectAll()
	self.Disabled:DisconnectAll()
end

return PluginManager
