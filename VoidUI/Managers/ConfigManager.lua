local Utilities = require(script.Parent.Parent.Core.Utilities)
local Events = require(script.Parent.Parent.Core.Events)
local State = require(script.Parent.Parent.Core.State)

local ConfigManager = {}
ConfigManager.__index = ConfigManager

local CURRENT_VERSION = "2.0.0"

function ConfigManager.new(Options)
	Options = Options or {}
	local self = setmetatable({}, ConfigManager)
	self.Name = Options.Name or "VoidUI_Config"
	self.AutoSave = Options.AutoSave ~= false
	self.AutoSaveInterval = Options.AutoSaveInterval or 30
	self.Version = CURRENT_VERSION
	self.Data = {}
	self.Profiles = {}
	self.CurrentProfile = "Default"
	self.Changed = Events.new()
	self.Loaded = Events.new()
	self.Saved = Events.new()
	self.State = State.new(self.Data)
	self._SaveTimer = nil
	self._Storage = Options.Storage or "Local"
	self:Initialize()
	return self
end

function ConfigManager:Initialize()
	self.Profiles["Default"] = {}
	if self.AutoSave then
		self._SaveTimer = self:CreateTimer(self.AutoSaveInterval, function()
			self:Save()
		end)
	end
end

function ConfigManager:CreateTimer(Interval, Callback)
	local Connection
	local Elapsed = 0
	Connection = game:GetService("RunService").Heartbeat:Connect(function(Delta)
		Elapsed = Elapsed + Delta
		if Elapsed >= Interval then
			Elapsed = 0
			pcall(Callback)
		end
	end)
	return Connection
end

function ConfigManager:Set(Key, Value)
	self.Data[Key] = Utilities.DeepCopy(Value)
	self.Changed:Fire(Key, Value)
	self.State:Set(self.Data)
end

function ConfigManager:Get(Key, Default)
	local Value = self.Data[Key]
	if Value == nil then
		return Default
	end
	return Utilities.DeepCopy(Value)
end

function ConfigManager:GetState(Key)
	return self.Data[Key]
end

function ConfigManager:Has(Key)
	return self.Data[Key] ~= nil
end

function ConfigManager:Remove(Key)
	self.Data[Key] = nil
	self.Changed:Fire(Key, nil)
end

function ConfigManager:Update(Key, Transform)
	local Current = self.Data[Key]
	self.Data[Key] = Transform(Current)
	self.Changed:Fire(Key, self.Data[Key])
end

function ConfigManager:Merge(Other)
	for Key, Value in pairs(Other) do
		self.Data[Key] = Utilities.DeepCopy(Value)
	end
	self.Changed:Fire("*", self.Data)
end

function ConfigManager:Serialize()
	return {
		Version = self.Version,
		Profile = self.CurrentProfile,
		Data = Utilities.DeepCopy(self.Data),
		Profiles = Utilities.DeepCopy(self.Profiles),
		SavedAt = os.time(),
	}
end

function ConfigManager:Deserialize(Payload)
	if not Payload then
		return false
	end
	local Migrated = self:Migrate(Payload)
	self.Data = Utilities.DeepCopy(Migrated.Data or {})
	self.Profiles = Utilities.DeepCopy(Migrated.Profiles or { Default = {} })
	self.CurrentProfile = Migrated.Profile or "Default"
	self.Changed:Fire("*", self.Data)
	self.Loaded:Fire(self.Data)
	return true
end

function ConfigManager:Migrate(Payload)
	local Version = Payload.Version or "1.0.0"
	if Utilities.VersionCompare(Version, self.Version) < 0 then
		Payload.Data = Payload.Data or {}
		Payload.MigratedFrom = Version
		Payload.Version = self.Version
	end
	return Payload
end

function ConfigManager:Save()
	local Payload = self:Serialize()
	local Encoded = Utilities.EncodeJSON(Payload)
	local Success = pcall(function()
		if self._Storage == "Local" then
			local Success2, DataStore = pcall(function()
				return game:GetService("DataStoreService"):GetDataStore(self.Name)
			end)
			if Success2 and DataStore then
				DataStore:SetAsync("Config", Encoded)
			end
		end
	end)
	self.Saved:Fire(Payload)
	return Encoded
end

function ConfigManager:Load()
	local Success, Encoded = pcall(function()
		local Success2, DataStore = pcall(function()
			return game:GetService("DataStoreService"):GetDataStore(self.Name)
		end)
		if Success2 and DataStore then
			return DataStore:GetAsync("Config")
		end
		return nil
	end)
	if Success and Encoded then
		local Payload = Utilities.DecodeJSON(Encoded)
		return self:Deserialize(Payload)
	end
	return false
end

function ConfigManager:Export()
	return Utilities.EncodeJSON(self:Serialize())
end

function ConfigManager:Import(JSON)
	local Payload = Utilities.DecodeJSON(JSON)
	return self:Deserialize(Payload)
end

function ConfigManager:CreateProfile(Name)
	self.Profiles[Name] = Utilities.DeepCopy(self.Data)
end

function ConfigManager:SwitchProfile(Name)
	if not self.Profiles[Name] then
		self.Profiles[Name] = {}
	end
	self:Save()
	self.Data = Utilities.DeepCopy(self.Profiles[Name])
	self.CurrentProfile = Name
	self.Changed:Fire("*", self.Data)
	self.Loaded:Fire(self.Data)
end

function ConfigManager:DeleteProfile(Name)
	if Name ~= "Default" then
		self.Profiles[Name] = nil
	end
end

function ConfigManager:GetProfiles()
	return Utilities.TableKeys(self.Profiles)
end

function ConfigManager:GetCurrentProfile()
	return self.CurrentProfile
end

function ConfigManager:Subscribe(Callback)
	return self.Changed:Connect(Callback)
end

function ConfigManager:SubscribeLoaded(Callback)
	return self.Loaded:Connect(Callback)
end

function ConfigManager:SubscribeSaved(Callback)
	return self.Saved:Connect(Callback)
end

function ConfigManager:Destroy()
	if self._SaveTimer then
		self._SaveTimer:Disconnect()
		self._SaveTimer = nil
	end
	self.Changed:DisconnectAll()
	self.Loaded:DisconnectAll()
	self.Saved:DisconnectAll()
	self.Data = {}
	self.Profiles = {}
end

return ConfigManager
