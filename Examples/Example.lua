local VoidUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/outhackernuls090-hash/VoidUI/refs/heads/main/VoidUI.lua"))()

local UI = VoidUI.new({
	Name = "VoidUI Example",
	Theme = "Midnight",
	Accent = Color3.fromRGB(120, 180, 255),
})

local Window = UI:CreateWindow({
	Title = "VoidUI",
	Icon = "Home",
	Size = UDim2.fromOffset(560, 460),
	Position = UDim2.fromScale(0.5, 0.5),
})

local Combat = Window:CreateTab({
	Title = "Combat",
	Icon = "Sword",
})

Combat:CreateSection({ Title = "Aimbot" })

Combat:CreateToggle({
	Title = "Enable Aimbot",
	Description = "Locks onto the nearest target",
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

Combat:CreateKeybind({
	Title = "Toggle Menu",
	Default = Enum.KeyCode.RightShift,
	Callback = function(Key)
		print("Keybind:", Key)
	end,
})

local Visuals = Window:CreateTab({
	Title = "Visuals",
	Icon = "Eye",
})

Visuals:CreateSection({ Title = "Rendering" })

Visuals:CreateToggle({ Title = "ESP", Default = true })
Visuals:CreateSlider({ Title = "Brightness", Min = 0, Max = 100, Default = 50 })
Visuals:CreateTextbox({
	Title = "Watermark Text",
	Default = "VoidUI",
	Placeholder = "Type here...",
	Callback = function(Value)
		print("Text:", Value)
	end,
})

Visuals:CreateDivider()

Visuals:CreateLabel({ Title = "Status: running" })
Visuals:CreateParagraph({
	Title = "About",
	Content = "VoidUI is a restyled, executor-agnostic GUI framework built on a proven core.",
})

local Misc = Window:CreateTab({
	Title = "Misc",
	Icon = "Settings",
})

Misc:CreateButton({
	Title = "Destroy UI",
	Callback = function()
		Window:Close()
	end,
})

Misc:CreateDropdown({
	Title = "Multi Select",
	Options = { "A", "B", "C" },
	Default = { "A" },
	Multi = true,
	Callback = function(Value)
		print("Selected:", table.concat(Value, ", "))
	end,
})

UI:Notify({
	Title = "VoidUI Loaded",
	Description = "Welcome to the future.",
})
