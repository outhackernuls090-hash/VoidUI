local Utilities = require(script.Parent.Parent.Core.Utilities)
local Events = require(script.Parent.Parent.Core.Events)

local AssetManager = {}
AssetManager.__index = AssetManager

function AssetManager.new()
	local self = setmetatable({}, AssetManager)
	self.Cache = {}
	self.Pools = {}
	self.References = {}
	self.Created = 0
	self.Reused = 0
	self.Evicted = 0
	self.Changed = Events.new()
	self.MaxCache = 500
	return self
end

function AssetManager:CacheAsset(Key, Asset)
	self.Cache[Key] = Asset
	self.References[Key] = (self.References[Key] or 0) + 1
	self.Created = self.Created + 1
	self:_EvictIfNeeded()
	self.Changed:Fire("Cache", Key)
end

function AssetManager:GetAsset(Key)
	local Asset = self.Cache[Key]
	if Asset then
		self.Reused = self.Reused + 1
		return Asset
	end
	return nil
end

function AssetManager:HasAsset(Key)
	return self.Cache[Key] ~= nil
end

function AssetManager:Release(Key)
	local Ref = self.References[Key] or 0
	if Ref > 1 then
		self.References[Key] = Ref - 1
	else
		self.References[Key] = nil
		self.Cache[Key] = nil
		self.Evicted = self.Evicted + 1
	end
	self.Changed:Fire("Release", Key)
end

function AssetManager:CreatePool(Name, Factory, Reset)
	self.Pools[Name] = {
		Factory = Factory,
		Reset = Reset,
		Available = {},
		InUse = {},
	}
end

function AssetManager:Acquire(Name, ...)
	local Pool = self.Pools[Name]
	if not Pool then
		return nil
	end
	local Item
	if #Pool.Available > 0 then
		Item = table.remove(Pool.Available)
		self.Reused = self.Reused + 1
	else
		Item = Pool.Factory(...)
		self.Created = self.Created + 1
	end
	Pool.InUse[Item] = true
	return Item
end

function AssetManager:ReleasePoolItem(Name, Item)
	local Pool = self.Pools[Name]
	if not Pool then
		return
	end
	if Pool.InUse[Item] then
		Pool.InUse[Item] = nil
		if Pool.Reset then
			pcall(Pool.Reset, Item)
		end
		table.insert(Pool.Available, Item)
	end
end

function AssetManager:GetPoolSize(Name)
	local Pool = self.Pools[Name]
	if not Pool then
		return 0
	end
	return #Pool.Available + Utilities.TableLength(Pool.InUse)
end

function AssetManager:Prewarm(Name, Count, ...)
	local Pool = self.Pools[Name]
	if not Pool then
		return
	end
	for _ = 1, Count do
		local Item = Pool.Factory(...)
		table.insert(Pool.Available, Item)
	end
end

function AssetManager:_EvictIfNeeded()
	if Utilities.TableLength(self.Cache) > self.MaxCache then
		local Oldest
		local OldestKey
		for Key, _ in pairs(self.Cache) do
			if not OldestKey then
				OldestKey = Key
			end
		end
		if OldestKey then
			self.Cache[OldestKey] = nil
			self.References[OldestKey] = nil
			self.Evicted = self.Evicted + 1
		end
	end
end

function AssetManager:GetStats()
	return {
		Created = self.Created,
		Reused = self.Reused,
		Evicted = self.Evicted,
		Cached = Utilities.TableLength(self.Cache),
	}
end

function AssetManager:Clear()
	for Key, _ in pairs(self.Cache) do
		self.Cache[Key] = nil
		self.References[Key] = nil
	end
	for Name, Pool in pairs(self.Pools) do
		Pool.Available = {}
		Pool.InUse = {}
	end
end

function AssetManager:Subscribe(Callback)
	return self.Changed:Connect(Callback)
end

function AssetManager:Destroy()
	self:Clear()
	self.Changed:DisconnectAll()
end

return AssetManager
