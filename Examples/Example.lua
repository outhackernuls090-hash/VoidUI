-- Option 1: load from the local module tree (Studio / Rojo)
-- local VoidUI = require(script.Parent.VoidUI)

-- Option 2: load from a URL via loadstring (executors: Synapse X, Script-Ware, KRNL, Fluxus, ...)
local VoidUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/outhackernuls090-hash/VoidUI/refs/heads/main/VoidUI.lua"))()

local UI = VoidUI.new({
	Name = "VoidUI Example",
	Startup = true,
})

UI:SetTheme("Midnight")
UI:SetAccent(Color3.fromRGB(120, 180, 255))

local Window = UI:CreateWindow({
	Title = "VoidUI",
	Icon = "Home",
	Size = UDim2.fromOffset(560, 420),
	Position = UDim2.fromScale(0.5, 0.5),
})

local Combat = Window:CreateTab({
	Title = "Combat",
	Icon = "Sword",
})

Combat:CreateSection({ Title = "Aimbot" })

Combat:CreateToggle({
	Title = "Enable Aimbot",
	Default = false,
	Callback = function(Value)
		print("Aimbot:", Value)
	end,
})

Combat:CreateSlider({
	Title = "FOV",
	Min = 10,
	Max = 120,
	Default = 60,
	Callback = function(Value)
		print("FOV:", Value)
	end,
})

Combat:CreateDropdown({
	Title = "Target Priority",
	Options = { "Closest", "Lowest Health", "Crosshair" },
	Default = "Closest",
	Callback = function(Value)
		print("Priority:", Value)
	end,
})

Combat:CreateColorPicker({
	Title = "Highlight Color",
	Default = Color3.fromRGB(255, 80, 120),
	Callback = function(Color)
		print("Color:", Color)
	end,
})

local Visuals = Window:CreateTab({
	Title = "Visuals",
	Icon = "Eye",
})

Visuals:CreateToggle({ Title = "ESP", Default = true })
Visuals:CreateSlider({ Title = "Brightness", Min = 0, Max = 100, Default = 50 })
Visuals:CreateKeybind({ Title = "Toggle Menu", Default = Enum.KeyCode.RightShift })

UI:Notify({
	Title = "VoidUI Loaded",
	Description = "Welcome to the future.",
	Type = "Success",
})

UI:RunStartupSequence()
