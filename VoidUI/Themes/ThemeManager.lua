local Utilities = require(script.Parent.Parent.Core.Utilities)
local Events = require(script.Parent.Parent.Core.Events)
local State = require(script.Parent.Parent.Core.State)

local ThemeManager = {}
ThemeManager.__index = ThemeManager

function ThemeManager.new()
	local self = setmetatable({}, ThemeManager)
	self.Themes = {}
	self.Current = nil
	self.CurrentName = "Default"
	self.Changed = Events.new()
	self.AccentChanged = Events.new()
	self.State = State.new("Default")
	self.CustomThemes = {}
	self.Accent = Color3.fromRGB(124, 162, 255)
	self._AccentPalette = Utilities.GenerateAccent(self.Accent)
	self:RegisterBuiltIns()
	return self
end

function ThemeManager:RegisterBuiltIns()
	local Default = require(script.Parent.Default)
	local Midnight = require(script.Parent.Midnight)
	local Nebula = require(script.Parent.Nebula)
	local Crimson = require(script.Parent.Crimson)
	local Emerald = require(script.Parent.Emerald)
	self:Register(Default)
	self:Register(Midnight)
	self:Register(Nebula)
	self:Register(Crimson)
	self:Register(Emerald)
end

function ThemeManager:Register(Theme)
	if not Theme or not Theme.Name then
		return
	end
	self.Themes[Theme.Name] = Utilities.DeepCopy(Theme)
end

function ThemeManager:RegisterCustom(Name, Theme)
	self.CustomThemes[Name] = Utilities.DeepCopy(Theme)
	self:Register(Theme)
end

function ThemeManager:GetNames()
	return Utilities.TableKeys(self.Themes)
end

function ThemeManager:Get(Name)
	return self.Themes[Name]
end

function ThemeManager:Exists(Name)
	return self.Themes[Name] ~= nil
end

function ThemeManager:Set(Name)
	if not self.Themes[Name] then
		warn("[VoidUI] Theme not found:", Name)
		return false
	end
	self.CurrentName = Name
	self.Current = Utilities.DeepCopy(self.Themes[Name])
	self.State:Set(Name)
	self:ApplyAccent(self.Accent)
	self.Changed:Fire(self.Current, Name)
	return true
end

function ThemeManager:GetCurrent()
	return self.Current
end

function ThemeManager:GetName()
	return self.CurrentName
end

function ThemeManager:Color(Key)
	if self.Current and self.Current.Colors then
		return self.Current.Colors[Key] or Color3.fromRGB(255, 0, 255)
	end
	return Color3.fromRGB(255, 0, 255)
end

function ThemeManager:Gradient(Key)
	if self.Current and self.Current.Gradients then
		return self.Current.Gradients[Key]
	end
	return ColorSequence.new(Color3.fromRGB(255, 0, 255))
end

function ThemeManager:Typography(Key)
	if self.Current and self.Current.Typography then
		return self.Current.Typography[Key]
	end
	return nil
end

function ThemeManager:Layout(Key)
	if self.Current and self.Current.Layout then
		return self.Current.Layout[Key]
	end
	return nil
end

function ThemeManager:Effect(Key)
	if self.Current and self.Current.Effects then
		return self.Current.Effects[Key]
	end
	return nil
end

function ThemeManager:Animation(Key)
	if self.Current and self.Current.Animation then
		return self.Current.Animation[Key]
	end
	return nil
end

function ThemeManager:SetAccent(Color)
	self:ApplyAccent(Color)
	self.AccentChanged:Fire(Color)
end

function ThemeManager:ApplyAccent(Color)
	self.Accent = Color
	self._AccentPalette = Utilities.GenerateAccent(Color)
	if self.Current then
		self.Current.Colors.Accent = Color
		self.Current.Colors.AccentLight = self._AccentPalette.Light
		self.Current.Colors.AccentDark = self._AccentPalette.Dark
		self.Current.Colors.AccentGlow = self._AccentPalette.Glow
		self.Current.Gradients.Accent = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color),
			ColorSequenceKeypoint.new(1, self._AccentPalette.Complement),
		})
		self.Current.Gradients.Glow = ColorSequence.new({
			ColorSequenceKeypoint.new(0, self._AccentPalette.Glow),
			ColorSequenceKeypoint.new(1, self._AccentPalette.Complement),
		})
	end
end

function ThemeManager:GetAccent()
	return self.Accent
end

function ThemeManager:GetAccentPalette()
	return self._AccentPalette
end

function ThemeManager:ContrastFor(Background)
	return Utilities.ContrastColor(Background)
end

function ThemeManager:SetProperty(Category, Key, Value)
	if not self.Current then
		return
	end
	if not self.Current[Category] then
		self.Current[Category] = {}
	end
	self.Current[Category][Key] = Value
	self.Changed:Fire(self.Current, self.CurrentName)
end

function ThemeManager:GetProperty(Category, Key)
	if self.Current and self.Current[Category] then
		return self.Current[Category][Key]
	end
	return nil
end

function ThemeManager:CloneCurrent(Name)
	local Clone = Utilities.DeepCopy(self.Current)
	Clone.Name = Name or (self.CurrentName .. "_Custom")
	self:Register(Clone)
	return Clone
end

function ThemeManager:Export(Name)
	local Theme = self.Themes[Name or self.CurrentName]
	if not Theme then
		return nil
	end
	return Utilities.EncodeJSON(Theme)
end

function ThemeManager:Import(JSON)
	local Success, Theme = pcall(function()
		return Utilities.DecodeJSON(JSON)
	end)
	if Success and Theme and Theme.Name then
		self:Register(Theme)
		return Theme.Name
	end
	return nil
end

function ThemeManager:Serialize()
	return {
		Name = self.CurrentName,
		Accent = Utilities.Color3ToHex(self.Accent),
		Custom = Utilities.DeepCopy(self.CustomThemes),
	}
end

function ThemeManager:Deserialize(Data)
	if not Data then
		return
	end
	if Data.Custom then
		for Name, Theme in pairs(Data.Custom) do
			self:RegisterCustom(Name, Theme)
		end
	end
	if Data.Accent then
		self:SetAccent(Utilities.HexToColor3(Data.Accent))
	end
	if Data.Name then
		self:Set(Data.Name)
	end
end

function ThemeManager:Subscribe(Callback)
	return self.Changed:Connect(Callback)
end

function ThemeManager:SubscribeAccent(Callback)
	return self.AccentChanged:Connect(Callback)
end

function ThemeManager:Destroy()
	self.Changed:DisconnectAll()
	self.AccentChanged:DisconnectAll()
	self.Themes = {}
	self.CustomThemes = {}
	self.Current = nil
end

return ThemeManager
