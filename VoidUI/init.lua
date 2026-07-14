local cloneref = (cloneref or clonereference or function(instance)
	return instance
end)

local HttpService = cloneref(game:GetService("HttpService"))
local Players = cloneref(game:GetService("Players"))
local CoreGui = cloneref(game:GetService("CoreGui"))
local RunService = cloneref(game:GetService("RunService"))
local UserInputService = cloneref(game:GetService("UserInputService"))

local Forge = require(script.Core.Forge)
local Themes, ThemeFallbacks = require(script.Themes.Themes)
local Icons = require(script.Assets.Icons)
local WindowModule = require(script.Core.Window)

local ProtectGui = protectgui or (syn and syn.protect_gui) or function() end

local GUIParent = (gethui and gethui()) or CoreGui or Players.LocalPlayer:WaitForChild("PlayerGui")

local VoidUI = {
	Version = "3.0.0",
	Forge = Forge,
	Themes = Themes,
	ThemeFallbacks = ThemeFallbacks,
	Icon = Icons,
	Windows = {},
	CurrentTheme = "Default",
	Accent = Color3.fromHex(Themes.Default.Accent),
	ScreenGui = nil,
	UIScaleObj = nil,
	UIScale = 1,
	OnThemeChange = nil,
}

Forge.Themes = Themes
Forge.ThemeFallbacks = ThemeFallbacks
Forge.Theme = Themes[VoidUI.CurrentTheme]

function VoidUI.GenerateGUID()
	return HttpService:GenerateGUID(false)
end

function VoidUI:SetTheme(Name)
	if not Themes[Name] then
		warn("[VoidUI] Theme not found:", Name)
		return false
	end
	VoidUI.CurrentTheme = Name
	Forge.Apply(Themes[Name])
	if VoidUI.OnThemeChange then
		Forge.Guard(VoidUI.OnThemeChange, Themes[Name], Name)
	end
	for _, Window in ipairs(VoidUI.Windows) do
		if Window.ApplyTheme then
			Window:ApplyTheme(Themes[Name])
		end
	end
	return true
end

function VoidUI:SetAccent(Color)
	VoidUI.Accent = Color
	Themes[VoidUI.CurrentTheme].Accent = Color
	Themes[VoidUI.CurrentTheme].AccentGlow = Color
	Forge.Apply(Themes[VoidUI.CurrentTheme])
	for _, Window in ipairs(VoidUI.Windows) do
		if Window.ApplyTheme then
			Window:ApplyTheme(Themes[VoidUI.CurrentTheme])
		end
	end
end

function VoidUI:CreateWindow(Options)
	Options = Options or {}
	local Window = WindowModule.new(VoidUI, Options)
	table.insert(VoidUI.Windows, Window)
	return Window
end

function VoidUI:Notify(Options)
	Options = Options or {}
	local Window = VoidUI.Windows[1]
	if Window and Window.Notify then
		return Window:Notify(Options)
	end
	warn("[VoidUI] Notify: no window created yet")
	return nil
end

function VoidUI:GetStats()
	return {
		Windows = #VoidUI.Windows,
		Theme = VoidUI.CurrentTheme,
		Version = VoidUI.Version,
	}
end

function VoidUI.new(Options)
	Options = Options or {}

	if not VoidUI.ScreenGui then
		local UIScaleObj = Forge.Make("UIScale", {
			Scale = VoidUI.UIScale,
		})
		VoidUI.UIScaleObj = UIScaleObj

		local ScreenGui = Forge.Make("ScreenGui", {
			Name = "VoidUI",
			Parent = GUIParent,
			IgnoreGuiInset = true,
			ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
			DisplayOrder = 1000,
			ResetOnSpawn = false,
		}, {
			UIScaleObj,
			Forge.Make("Folder", { Name = "Windows" }),
			Forge.Make("Folder", { Name = "Notifications" }),
			Forge.Make("Folder", { Name = "Overlays" }),
		})
		VoidUI.ScreenGui = ScreenGui
		ProtectGui(ScreenGui)
	end

	VoidUI:SetTheme(Options.Theme or "Default")
	if Options.Accent then
		VoidUI:SetAccent(Options.Accent)
	end

	return VoidUI
end

return VoidUI
