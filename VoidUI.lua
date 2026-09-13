local VoidUI = {}
VoidUI.Version = "5.0.0"

local cloneref = cloneref or clonereference or function(i) return i end
local RunService = cloneref(game:GetService("RunService"))
local TweenService = cloneref(game:GetService("TweenService"))
local UserInputService = cloneref(game:GetService("UserInputService"))
local Players = cloneref(game:GetService("Players"))
local CoreGui = cloneref(game:GetService("CoreGui"))
local HttpService = cloneref(game:GetService("HttpService"))

local ProtectGui = protectgui or (syn and syn.protect_gui) or function() end
local GUIParent = (gethui and gethui()) or CoreGui or Players.LocalPlayer:WaitForChild("PlayerGui")

local function GetEnum(category, member)
	local ok, value = pcall(function()
		return Enum[category][member]
	end)
	if ok then
		return value
	end
	return nil
end

local function ClampNumber(value, minValue, maxValue, fallback)
	value = tonumber(value)
	if not value then
		value = fallback or minValue
	end
	return math.clamp(value, minValue, maxValue)
end

local function CopyTable(source)
	local target = {}
	for key, value in pairs(source or {}) do
		if type(value) == "table" then
			target[key] = CopyTable(value)
		else
			target[key] = value
		end
	end
	return target
end

local function MergeTable(base, extra)
	local target = CopyTable(base)
	for key, value in pairs(extra or {}) do
		if type(value) == "table" and type(target[key]) == "table" then
			target[key] = MergeTable(target[key], value)
		else
			target[key] = value
		end
	end
	return target
end

local function Color(value, fallback)
	if typeof(value) == "Color3" then
		return value
	end
	if type(value) == "string" then
		local ok, parsed = pcall(Color3.fromHex, value)
		if ok then
			return parsed
		end
	end
	return fallback
end

local Forge = {
	Font = GetEnum("Font", "Gotham"),
	Theme = nil,
	Themes = {},
	ThemeFallbacks = {},
	Skins = {},
	ThemeHooks = {},
	Fonts = {},
	Tweens = {},
	Connections = {}
}

Forge.Defaults = {
	ScreenGui = {
		ResetOnSpawn = false,
		ZIndexBehavior = GetEnum("ZIndexBehavior", "Sibling"),
		IgnoreGuiInset = true
	},
	CanvasGroup = {
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.new(1, 1, 1)
	},
	Frame = {
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.new(1, 1, 1)
	},
	TextLabel = {
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderSizePixel = 0,
		Text = "",
		RichText = true,
		TextColor3 = Color3.new(1, 1, 1),
		TextSize = 14,
		FontFace = Font.fromEnum(GetEnum("Font", "Gotham"))
	},
	TextButton = {
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderSizePixel = 0,
		Text = "",
		AutoButtonColor = false,
		TextColor3 = Color3.new(1, 1, 1),
		TextSize = 14,
		FontFace = Font.fromEnum(GetEnum("Font", "Gotham"))
	},
	TextBox = {
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderColor3 = Color3.new(0, 0, 0),
		BorderSizePixel = 0,
		ClearTextOnFocus = false,
		Text = "",
		TextColor3 = Color3.new(0, 0, 0),
		TextSize = 14,
		FontFace = Font.fromEnum(GetEnum("Font", "Gotham"))
	},
	ImageLabel = {
		BackgroundTransparency = 1,
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderSizePixel = 0
	},
	ImageButton = {
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderSizePixel = 0,
		AutoButtonColor = false
	},
	UIListLayout = {
		SortOrder = GetEnum("SortOrder", "LayoutOrder")
	},
	UIPadding = {
		PaddingLeft = UDim.new(0, 0),
		PaddingRight = UDim.new(0, 0),
		PaddingTop = UDim.new(0, 0),
		PaddingBottom = UDim.new(0, 0)
	},
	UIStroke = {
		Thickness = 1
	},
	UICorner = {
		CornerRadius = UDim.new(0, 0)
	},
	ScrollingFrame = {
		ScrollBarImageTransparency = 0.55,
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.new(1, 1, 1),
		AutomaticCanvasSize = GetEnum("AutomaticCanvasSize", "Y"),
		ScrollingDirection = GetEnum("ScrollingDirection", "Y"),
		VerticalScrollBarInset = GetEnum("ScrollBarInset", "ScrollBar")
	},
	UIGradient = {}
}

function Forge.Guard(callback, ...)
	if type(callback) ~= "function" then
		return
	end
	local args = table.pack(...)
	local ok, err = xpcall(function()
		return callback(table.unpack(args, 1, args.n))
	end, debug.traceback)
	if not ok then
		warn("[VoidUI] Callback error:", err)
	end
end

function Forge.Make(name, properties, children)
	local object = Instance.new(name)
	for property, value in pairs(Forge.Defaults[name] or {}) do
		if value ~= nil then
			pcall(function()
				object[property] = value
			end)
		end
	end
	for property, value in pairs(properties or {}) do
		if property ~= "Skin" and value ~= nil then
			pcall(function()
				object[property] = value
			end)
		end
	end
	for _, child in ipairs(children or {}) do
		if child then
			child.Parent = object
		end
	end
	if properties and properties.Skin then
		Forge.Tag(object, properties.Skin)
	end
	if properties and properties.FontFace then
		Forge.TrackFont(object)
	end
	return object
end

function Forge.TrackFont(object)
	table.insert(Forge.Fonts, object)
end

function Forge.SetFont(fontEnum)
	if not fontEnum then
		return
	end
	Forge.Font = fontEnum
	for index = #Forge.Fonts, 1, -1 do
		local object = Forge.Fonts[index]
		if object and object.Parent then
			pcall(function()
				object.FontFace = Font.fromEnum(fontEnum)
			end)
		else
			table.remove(Forge.Fonts, index)
		end
	end
end

function Forge.Resolve(property, theme)
	local source = theme or Forge.Theme or {}
	local visited = {}
	local function resolveValue(value, current)
		if type(value) == "string" then
			if string.sub(value, 1, 1) == "#" then
				local ok, parsed = pcall(Color3.fromHex, value)
				if ok then
					return parsed
				end
				return nil
			end
			if visited[value] then
				return nil
			end
			visited[value] = true
			return resolveValue(current[value], current)
		end
		if type(value) == "function" then
			local ok, result = pcall(value, current)
			if ok then
				return result
			end
			return nil
		end
		if type(value) == "table" and value.Color and value.Transparency then
			return value
		end
		return value
	end
	local value = resolveValue(source[property], source)
	if value ~= nil then
		return value
	end
	local fallback = Forge.ThemeFallbacks[property]
	if fallback ~= nil then
		local fallbackValue = resolveValue(fallback, source)
		if fallbackValue ~= nil then
			return fallbackValue
		end
	end
	if Forge.Themes.Default then
		visited = {}
		value = resolveValue(Forge.Themes.Default[property], Forge.Themes.Default)
		if value ~= nil then
			return value
		end
	end
	return nil
end

function Forge.Tag(object, properties, skipUpdate)
	if not object then
		return object
	end
	if Forge.Skins[object] then
		for property, value in pairs(properties or {}) do
			Forge.Skins[object].Properties[property] = value
		end
	else
		Forge.Skins[object] = {
			Object = object,
			Properties = CopyTable(properties or {})
		}
	end
	if not skipUpdate then
		Forge.Refresh(object)
	end
	return object
end

function Forge.Refresh(object)
	local theme = Forge.Theme
	if not theme then
		return
	end
	local function refreshOne(data)
		if not data or not data.Object or not data.Object.Parent then
			return false
		end
		for property, value in pairs(data.Properties or {}) do
			local themeValue = Forge.Resolve(value, theme)
			if themeValue ~= nil then
				pcall(function()
					data.Object[property] = themeValue
				end)
			end
		end
		return true
	end
	if object then
		local data = Forge.Skins[object]
		if data then
			refreshOne(data)
		end
		return
	end
	for target, data in pairs(Forge.Skins) do
		if target and target.Parent then
			refreshOne(data)
		else
			Forge.Skins[target] = nil
		end
	end
end

function Forge.Apply(theme)
	local previous = Forge.Theme
	Forge.Theme = theme
	Forge.Refresh()
	for _, callback in ipairs(Forge.ThemeHooks) do
		Forge.Guard(callback, theme, previous)
	end
end

function Forge.OnTheme(callback)
	if type(callback) == "function" then
		table.insert(Forge.ThemeHooks, callback)
	end
end

function Forge.Tween(object, time, properties, easingStyle, easingDirection, repeatCount, reverses, delayTime)
	time = tonumber(time) or 0.2
	local info = TweenInfo.new(
		time,
		easingStyle or GetEnum("EasingStyle", "Quad"),
		easingDirection or GetEnum("EasingDirection", "Out"),
		repeatCount or 0,
		reverses or false,
		delayTime or 0
	)
	local tween = TweenService:Create(object, info, properties or {})
	table.insert(Forge.Tweens, tween)
	tween.Completed:Connect(function()
		for index = #Forge.Tweens, 1, -1 do
			if Forge.Tweens[index] == tween then
				table.remove(Forge.Tweens, index)
				break
			end
		end
	end)
	return tween
end

function Forge.Spring(object, property, target, options)
	options = options or {}
	local tween = Forge.Tween(
		object,
		options.Duration or 0.3,
		{[property] = target},
		options.EasingStyle or GetEnum("EasingStyle", "Quint"),
		options.EasingDirection or GetEnum("EasingDirection", "Out"),
		options.RepeatCount or 0,
		options.Reverses or false,
		options.DelayTime or 0
	)
	tween:Play()
	return tween
end

function Forge.Round(object, radius)
	return Forge.Make("UICorner", {
		CornerRadius = UDim.new(0, radius or 10)
	}, nil)
end

function Forge.Stroke(object, themeKey, transparency, thickness)
	local theme = Forge.Theme or {}
	return Forge.Make("UIStroke", {
		Color = Forge.Resolve(themeKey or "Border", theme) or theme.Border or Color3.new(0, 0, 0),
		Transparency = transparency or 0,
		Thickness = thickness or 1,
		Skin = {
			Color = themeKey or "Border"
		}
	})
end

local Palette = {
	Default = {
		Name = "Default",
		Accent = "#7C9CFF",
		AccentGlow = "#A6BAFF",
		Background = "#090C12",
		BackgroundElevated = "#0E131C",
		Surface = "#141A24",
		SurfaceHover = "#1B2432",
		SurfaceActive = "#202B3D",
		Border = "#273243",
		Text = "#F0F3F8",
		TextDim = "#939EAE",
		TextMuted = "#5F6A7A",
		Success = "#37D67A",
		Warning = "#FFB454",
		Danger = "#FF647C",
		Info = "#61B4FF",
		Overlay = "#000000",
		Scrollbar = "#344154",
		Radius = 12,
		RadiusSmall = 8,
		RadiusLarge = 20,
		HeaderHeight = 60,
		SidebarWidth = 214,
		WindowWidth = 760,
		WindowHeight = 500,
		Spacing = 8,
		ControlHeight = 34
	},
	Midnight = {
		Name = "Midnight",
		Accent = "#5B8DEF",
		AccentGlow = "#7AA5F5",
		Background = "#060911",
		BackgroundElevated = "#0B1120",
		Surface = "#101827",
		SurfaceHover = "#18243A",
		SurfaceActive = "#1E2D47",
		Border = "#21304A",
		Text = "#E8F0FC",
		TextDim = "#8090A8",
		TextMuted = "#526078",
		Success = "#3DDC97",
		Warning = "#F3C969",
		Danger = "#FF647A",
		Info = "#6AB7FF",
		Overlay = "#000000",
		Scrollbar = "#2A3A57",
		Radius = 12,
		RadiusSmall = 8,
		RadiusLarge = 20,
		HeaderHeight = 60,
		SidebarWidth = 214,
		WindowWidth = 760,
		WindowHeight = 500,
		Spacing = 8,
		ControlHeight = 34
	},
	Nebula = {
		Name = "Nebula",
		Accent = "#B77BFF",
		AccentGlow = "#D0A9FF",
		Background = "#0B0815",
		BackgroundElevated = "#140E22",
		Surface = "#1C1530",
		SurfaceHover = "#282046",
		SurfaceActive = "#302650",
		Border = "#342751",
		Text = "#F3ECFF",
		TextDim = "#998DB4",
		TextMuted = "#665A7D",
		Success = "#54E19B",
		Warning = "#F6C56A",
		Danger = "#FF718E",
		Info = "#7AAFFF",
		Overlay = "#05020A",
		Scrollbar = "#443366",
		Radius = 14,
		RadiusSmall = 9,
		RadiusLarge = 22,
		HeaderHeight = 62,
		SidebarWidth = 222,
		WindowWidth = 780,
		WindowHeight = 520,
		Spacing = 9,
		ControlHeight = 35
	},
	Crimson = {
		Name = "Crimson",
		Accent = "#FF5E79",
		AccentGlow = "#FF91A2",
		Background = "#13080D",
		BackgroundElevated = "#1D0E15",
		Surface = "#28131C",
		SurfaceHover = "#381C29",
		SurfaceActive = "#472234",
		Border = "#482536",
		Text = "#FFEAF0",
		TextDim = "#B98C9B",
		TextMuted = "#7A5362",
		Success = "#54D98D",
		Warning = "#F0BE67",
		Danger = "#FF5E79",
		Info = "#7AB7FF",
		Overlay = "#090205",
		Scrollbar = "#5B3043",
		Radius = 12,
		RadiusSmall = 8,
		RadiusLarge = 20,
		HeaderHeight = 60,
		SidebarWidth = 214,
		WindowWidth = 760,
		WindowHeight = 500,
		Spacing = 8,
		ControlHeight = 34
	},
	Emerald = {
		Name = "Emerald",
		Accent = "#36D39A",
		AccentGlow = "#73EABB",
		Background = "#06110D",
		BackgroundElevated = "#0B1B15",
		Surface = "#11271F",
		SurfaceHover = "#17382C",
		SurfaceActive = "#1D4537",
		Border = "#1D3C30",
		Text = "#E6FAF2",
		TextDim = "#83AB9A",
		TextMuted = "#4E6E61",
		Success = "#36D39A",
		Warning = "#EFC86E",
		Danger = "#FF6A7D",
		Info = "#68B6FF",
		Overlay = "#020906",
		Scrollbar = "#315446",
		Radius = 12,
		RadiusSmall = 8,
		RadiusLarge = 20,
		HeaderHeight = 60,
		SidebarWidth = 214,
		WindowWidth = 760,
		WindowHeight = 500,
		Spacing = 8,
		ControlHeight = 34
	},
	Amber = {
		Name = "Amber",
		Accent = "#FFB65C",
		AccentGlow = "#FFD38E",
		Background = "#120C05",
		BackgroundElevated = "#1D140A",
		Surface = "#291D10",
		SurfaceHover = "#392817",
		SurfaceActive = "#46331D",
		Border = "#46351F",
		Text = "#FFF3DE",
		TextDim = "#B9A487",
		TextMuted = "#77694F",
		Success = "#63D891",
		Warning = "#FFB65C",
		Danger = "#FF6B70",
		Info = "#6CB6FF",
		Overlay = "#080501",
		Scrollbar = "#594629",
		Radius = 12,
		RadiusSmall = 8,
		RadiusLarge = 20,
		HeaderHeight = 60,
		SidebarWidth = 214,
		WindowWidth = 760,
		WindowHeight = 500,
		Spacing = 8,
		ControlHeight = 34
	},
	Ocean = {
		Name = "Ocean",
		Accent = "#2DD4EE",
		AccentGlow = "#72EEFF",
		Background = "#041116",
		BackgroundElevated = "#09202A",
		Surface = "#0F2A35",
		SurfaceHover = "#153A48",
		SurfaceActive = "#1B4857",
		Border = "#1D3E4B",
		Text = "#E4FAFF",
		TextDim = "#80AEB8",
		TextMuted = "#4D737B",
		Success = "#48D7A4",
		Warning = "#F2CB71",
		Danger = "#FF6E80",
		Info = "#62B8FF",
		Overlay = "#010609",
		Scrollbar = "#315865",
		Radius = 12,
		RadiusSmall = 8,
		RadiusLarge = 20,
		HeaderHeight = 60,
		SidebarWidth = 214,
		WindowWidth = 760,
		WindowHeight = 500,
		Spacing = 8,
		ControlHeight = 34
	},
	Rose = {
		Name = "Rose",
		Accent = "#FA7188",
		AccentGlow = "#FDA8B7",
		Background = "#170A11",
		BackgroundElevated = "#23101A",
		Surface = "#321826",
		SurfaceHover = "#442238",
		SurfaceActive = "#522A43",
		Border = "#4E2A3D",
		Text = "#FFEAF1",
		TextDim = "#B38D9A",
		TextMuted = "#7A5664",
		Success = "#55D58E",
		Warning = "#F0C36E",
		Danger = "#FA7188",
		Info = "#70B4FF",
		Overlay = "#090206",
		Scrollbar = "#61364B",
		Radius = 14,
		RadiusSmall = 9,
		RadiusLarge = 22,
		HeaderHeight = 62,
		SidebarWidth = 222,
		WindowWidth = 780,
		WindowHeight = 520,
		Spacing = 9,
		ControlHeight = 35
	},
	Frost = {
		Name = "Frost",
		Accent = "#9CAAFB",
		AccentGlow = "#C8D0FF",
		Background = "#0A0D16",
		BackgroundElevated = "#111728",
		Surface = "#192239",
		SurfaceHover = "#223050",
		SurfaceActive = "#293B60",
		Border = "#2B3550",
		Text = "#EEF2FF",
		TextDim = "#909BB6",
		TextMuted = "#616B84",
		Success = "#62D99D",
		Warning = "#F0C674",
		Danger = "#FF778C",
		Info = "#74B9FF",
		Overlay = "#020307",
		Scrollbar = "#394867",
		Radius = 12,
		RadiusSmall = 8,
		RadiusLarge = 20,
		HeaderHeight = 60,
		SidebarWidth = 214,
		WindowWidth = 760,
		WindowHeight = 500,
		Spacing = 8,
		ControlHeight = 34
	},
	Mono = {
		Name = "Mono",
		Accent = "#F0F0F0",
		AccentGlow = "#FFFFFF",
		Background = "#090909",
		BackgroundElevated = "#121212",
		Surface = "#1B1B1B",
		SurfaceHover = "#262626",
		SurfaceActive = "#303030",
		Border = "#303030",
		Text = "#F8F8F8",
		TextDim = "#A4A4A4",
		TextMuted = "#6D6D6D",
		Success = "#B5E85E",
		Warning = "#FFD45C",
		Danger = "#FF7F88",
		Info = "#A6C8FF",
		Overlay = "#000000",
		Scrollbar = "#3A3A3A",
		Radius = 10,
		RadiusSmall = 6,
		RadiusLarge = 16,
		HeaderHeight = 58,
		SidebarWidth = 208,
		WindowWidth = 740,
		WindowHeight = 490,
		Spacing = 8,
		ControlHeight = 34
	},
	Slate = {
		Name = "Slate",
		Accent = "#8EA6C8",
		AccentGlow = "#B6C7DE",
		Background = "#0B0E13",
		BackgroundElevated = "#121720",
		Surface = "#1A212C",
		SurfaceHover = "#242F3F",
		SurfaceActive = "#2B3748",
		Border = "#2C3746",
		Text = "#EFF3F8",
		TextDim = "#8F9AAA",
		TextMuted = "#5F6977",
		Success = "#6BDBA2",
		Warning = "#EACB7D",
		Danger = "#FC7788",
		Info = "#79AEFF",
		Overlay = "#000000",
		Scrollbar = "#3B485A",
		Radius = 11,
		RadiusSmall = 7,
		RadiusLarge = 18,
		HeaderHeight = 59,
		SidebarWidth = 212,
		WindowWidth = 750,
		WindowHeight = 495,
		Spacing = 8,
		ControlHeight = 34
	},
	Violet = {
		Name = "Violet",
		Accent = "#8B7CFF",
		AccentGlow = "#B2A8FF",
		Background = "#0D0915",
		BackgroundElevated = "#171126",
		Surface = "#211838",
		SurfaceHover = "#2E2450",
		SurfaceActive = "#392C60",
		Border = "#392E52",
		Text = "#F6F1FF",
		TextDim = "#9F96B5",
		TextMuted = "#6F6482",
		Success = "#58D89A",
		Warning = "#F2CA70",
		Danger = "#FF758D",
		Info = "#74B3FF",
		Overlay = "#05020A",
		Scrollbar = "#4A3C66",
		Radius = 13,
		RadiusSmall = 8,
		RadiusLarge = 21,
		HeaderHeight = 61,
		SidebarWidth = 218,
		WindowWidth = 770,
		WindowHeight = 510,
		Spacing = 9,
		ControlHeight = 35
	},
	Magenta = {
		Name = "Magenta",
		Accent = "#F05ACB",
		AccentGlow = "#FF92E0",
		Background = "#140912",
		BackgroundElevated = "#210F1E",
		Surface = "#30172B",
		SurfaceHover = "#40203A",
		SurfaceActive = "#4A2744",
		Border = "#4B2944",
		Text = "#FFEAF8",
		TextDim = "#BA8FAF",
		TextMuted = "#7C5872",
		Success = "#65D89A",
		Warning = "#F0C96E",
		Danger = "#FF708A",
		Info = "#76B1FF",
		Overlay = "#080206",
		Scrollbar = "#613956",
		Radius = 13,
		RadiusSmall = 8,
		RadiusLarge = 21,
		HeaderHeight = 61,
		SidebarWidth = 218,
		WindowWidth = 770,
		WindowHeight = 510,
		Spacing = 9,
		ControlHeight = 35
	},
	Ruby = {
		Name = "Ruby",
		Accent = "#FF445F",
		AccentGlow = "#FF7C8E",
		Background = "#14070A",
		BackgroundElevated = "#1F0D12",
		Surface = "#2C141A",
		SurfaceHover = "#3E1C25",
		SurfaceActive = "#4B212B",
		Border = "#4C242E",
		Text = "#FFECEE",
		TextDim = "#BC8E95",
		TextMuted = "#7E555C",
		Success = "#5DDB9A",
		Warning = "#F0C66F",
		Danger = "#FF445F",
		Info = "#73B6FF",
		Overlay = "#090204",
		Scrollbar = "#60313B",
		Radius = 12,
		RadiusSmall = 8,
		RadiusLarge = 20,
		HeaderHeight = 60,
		SidebarWidth = 214,
		WindowWidth = 760,
		WindowHeight = 500,
		Spacing = 8,
		ControlHeight = 34
	},
	Terminal = {
		Name = "Terminal",
		Accent = "#00FF88",
		AccentGlow = "#72FFBC",
		Background = "#030706",
		BackgroundElevated = "#07100C",
		Surface = "#0B1912",
		SurfaceHover = "#10271B",
		SurfaceActive = "#143323",
		Border = "#173D29",
		Text = "#D9FFE9",
		TextDim = "#6EA88A",
		TextMuted = "#3F6A55",
		Success = "#00FF88",
		Warning = "#E4E25A",
		Danger = "#FF5D70",
		Info = "#66D7FF",
		Overlay = "#000000",
		Scrollbar = "#1A4A32",
		Radius = 8,
		RadiusSmall = 5,
		RadiusLarge = 14,
		HeaderHeight = 56,
		SidebarWidth = 205,
		WindowWidth = 735,
		WindowHeight = 485,
		Spacing = 7,
		ControlHeight = 32
	},
	Night = {
		Name = "Night",
		Accent = "#96A8C9",
		AccentGlow = "#C0CEE6",
		Background = "#05070A",
		BackgroundElevated = "#0B0E13",
		Surface = "#10151D",
		SurfaceHover = "#171E29",
		SurfaceActive = "#1C2633",
		Border = "#202A37",
		Text = "#EDF1F7",
		TextDim = "#7A8596",
		TextMuted = "#505A68",
		Success = "#5CD9A1",
		Warning = "#F2CA73",
		Danger = "#FF7284",
		Info = "#71B2FF",
		Overlay = "#000000",
		Scrollbar = "#2A3646",
		Radius = 11,
		RadiusSmall = 7,
		RadiusLarge = 18,
		HeaderHeight = 58,
		SidebarWidth = 210,
		WindowWidth = 745,
		WindowHeight = 495,
		Spacing = 8,
		ControlHeight = 33
	},
	Arctic = {
		Name = "Arctic",
		Accent = "#79C8FF",
		AccentGlow = "#A8E0FF",
		Background = "#081014",
		BackgroundElevated = "#0E1B22",
		Surface = "#14303A",
		SurfaceHover = "#1C414E",
		SurfaceActive = "#234D5B",
		Border = "#24505D",
		Text = "#EAFBFF",
		TextDim = "#86AFB8",
		TextMuted = "#53747B",
		Success = "#54DEB1",
		Warning = "#E7D17D",
		Danger = "#FF7382",
		Info = "#79C8FF",
		Overlay = "#020607",
		Scrollbar = "#355E69",
		Radius = 13,
		RadiusSmall = 8,
		RadiusLarge = 21,
		HeaderHeight = 61,
		SidebarWidth = 218,
		WindowWidth = 770,
		WindowHeight = 510,
		Spacing = 9,
		ControlHeight = 35
	},
	Forest = {
		Name = "Forest",
		Accent = "#7ED957",
		AccentGlow = "#A4EB79",
		Background = "#071008",
		BackgroundElevated = "#0D1B0F",
		Surface = "#142518",
		SurfaceHover = "#1C3621",
		SurfaceActive = "#23422A",
		Border = "#24432D",
		Text = "#ECFBEA",
		TextDim = "#88AB86",
		TextMuted = "#536E53",
		Success = "#7ED957",
		Warning = "#E7CE73",
		Danger = "#FF7181",
		Info = "#74B5FF",
		Overlay = "#010502",
		Scrollbar = "#355A3C",
		Radius = 12,
		RadiusSmall = 8,
		RadiusLarge = 20,
		HeaderHeight = 60,
		SidebarWidth = 214,
		WindowWidth = 760,
		WindowHeight = 500,
		Spacing = 8,
		ControlHeight = 34
	},
	Sunset = {
		Name = "Sunset",
		Accent = "#FF8C5A",
		AccentGlow = "#FFB98F",
		Background = "#140A06",
		BackgroundElevated = "#21110B",
		Surface = "#311A11",
		SurfaceHover = "#442419",
		SurfaceActive = "#512C1F",
		Border = "#4D2B20",
		Text = "#FFF0E7",
		TextDim = "#B99985",
		TextMuted = "#7E6254",
		Success = "#68D89A",
		Warning = "#FFC56B",
		Danger = "#FF6877",
		Info = "#71B4FF",
		Overlay = "#080301",
		Scrollbar = "#624133",
		Radius = 13,
		RadiusSmall = 8,
		RadiusLarge = 21,
		HeaderHeight = 61,
		SidebarWidth = 218,
		WindowWidth = 770,
		WindowHeight = 510,
		Spacing = 9,
		ControlHeight = 35
	},
	Cloud = {
		Name = "Cloud",
		Accent = "#7089FF",
		AccentGlow = "#9DAEFF",
		Background = "#0B0D14",
		BackgroundElevated = "#121624",
		Surface = "#1B2130",
		SurfaceHover = "#252D40",
		SurfaceActive = "#2D374D",
		Border = "#2C3547",
		Text = "#F3F5FA",
		TextDim = "#9CA5B8",
		TextMuted = "#626B7E",
		Success = "#63DBA1",
		Warning = "#F0CA75",
		Danger = "#FF7789",
		Info = "#74B5FF",
		Overlay = "#000000",
		Scrollbar = "#3B465A",
		Radius = 14,
		RadiusSmall = 9,
		RadiusLarge = 22,
		HeaderHeight = 62,
		SidebarWidth = 222,
		WindowWidth = 780,
		WindowHeight = 520,
		Spacing = 9,
		ControlHeight = 35
	},
	Carbon = {
		Name = "Carbon",
		Accent = "#B5BAC6",
		AccentGlow = "#E0E4EC",
		Background = "#060708",
		BackgroundElevated = "#0D0F11",
		Surface = "#151719",
		SurfaceHover = "#1E2023",
		SurfaceActive = "#282A2E",
		Border = "#292C31",
		Text = "#ECEDEF",
		TextDim = "#8A8F98",
		TextMuted = "#5A5E65",
		Success = "#9FE065",
		Warning = "#E6CB65",
		Danger = "#FF747F",
		Info = "#91B8FF",
		Overlay = "#000000",
		Scrollbar = "#373A40",
		Radius = 10,
		RadiusSmall = 6,
		RadiusLarge = 16,
		HeaderHeight = 58,
		SidebarWidth = 208,
		WindowWidth = 740,
		WindowHeight = 490,
		Spacing = 8,
		ControlHeight = 33
	},
}

local ThemeFallbacks = {
	AccentGlow = "Accent",
	BackgroundElevated = "Background",
	SurfaceHover = "Surface",
	SurfaceActive = "SurfaceHover",
	TextDim = "Text",
	TextMuted = "TextDim",
	Border = "Surface",
	Scrollbar = "Border",
	RadiusSmall = "Radius",
	RadiusLarge = "Radius",
	WindowWidth = 760,
	WindowHeight = 500,
	SidebarWidth = 214,
	HeaderHeight = 60,
	Spacing = 8,
	ControlHeight = 34
}

for _, theme in pairs(Palette) do
	for key, value in pairs(theme) do
		if type(value) == "string" and string.sub(value, 1, 1) == "#" then
			local ok, color = pcall(Color3.fromHex, value)
			if ok then theme[key] = color end
		end
	end
end

Forge.Themes = Palette
Forge.ThemeFallbacks = ThemeFallbacks
Forge.Theme = Palette.Default

local Icons = {}
Icons.__index = Icons

local Glyphs = {
	Home = "⌂", Settings = "⚙", Search = "⌕", Close = "×", Check = "✓", CheckCircle = "●",
	ChevronDown = "⌄", ChevronUp = "⌃", ChevronLeft = "‹", ChevronRight = "›",
	ArrowRight = "→", ArrowLeft = "←", ArrowUp = "↑", ArrowDown = "↓",
	Plus = "+", Minus = "−", Star = "★", Heart = "♥", Bell = "●", User = "●", Users = "••",
	Lock = "●", Unlock = "○", Eye = "◉", EyeOff = "◎", Trash = "⌫", Edit = "✎", Copy = "⧉",
	Download = "↓", Upload = "↑", Refresh = "↻", Play = "▶", Pause = "Ⅱ", Stop = "■",
	Volume = "◖", Mute = "◌", Info = "i", Warning = "!", Error = "×", Success = "✓", Danger = "×",
	Sword = "⚔", Shield = "⬢", Fire = "◆", Zap = "ϟ", Gear = "⚙", Folder = "▰", File = "▯",
	Image = "▧", Code = "</>", Terminal = ">_", Globe = "◎", Clock = "◷", Key = "⌘", Flag = "⚑",
	Bookmark = "▮", Tag = "#", Link = "↗", Mail = "@", Phone = "⌕", Camera = "□", Music = "♪",
	Video = "▷", Chart = "▥", Grid = "▦", List = "☰", Menu = "☰", Sun = "☀", Moon = "☾", Cloud = "☁",
	Bolt = "ϟ", Diamond = "◆", Circle = "●", Square = "■", Cross = "×", Void = "◇", Sparkles = "✦",
	Command = "⌘", Filter = "≡", Maximize = "□", Minimize = "_", Pin = "⌖", Wrench = "⌕", Hammer = "⌂",
	Rocket = "↗", Target = "◎", Compass = "⊕", Layers = "▤", Box = "▣", Package = "▱", Cpu = "▦",
	Database = "▥", Gauge = "◔", Activity = "◒", Wifi = "⌁", Battery = "▮", Power = "⏻", Logout = "↗",
	Login = "↙", Help = "?", Question = "?", Exclamation = "!", PlusCircle = "⊕", MinusCircle = "⊖",
	Dot = "•", Bullet = "•", Record = "●", Send = "➤", Paperclip = "⌇", Scissors = "✂", Printer = "▣",
	Calendar = "▦", Map = "⌖", Location = "⌾", Navigation = "➤", Book = "▤", Lightbulb = "✦",
	Droplet = "●", Wind = "≋", Snow = "❄", Leaf = "❧", Tree = "♣", Flower = "✿", Crown = "♛",
	Trophy = "♜", Medal = "◉", Gem = "◆", Coins = "$", Credit = "▣", Cart = "▰", Bag = "▣",
	Gift = "□", Smile = "☺", Meh = "•", Sad = "☹", Angry = "!", Cool = "◒", Ghost = "◊", Robot = "◈",
	Alien = "◇", Bug = "✣", Skull = "☠", Hand = "☝", Pointer = "☞", Grab = "✊", ThumbsUp = "✓",
	ThumbsDown = "×", Dashboard = "▦", ActivityCircle = "◔", Monitor = "▣", Sliders = "≡",
}

function Icons.Create(name, color, size)
	local glyph = Glyphs[name] or Glyphs.Void
	local textSize = size or 18
	return Forge.Make("TextLabel", {
		Name = "Icon",
		Text = glyph,
		TextSize = textSize,
		TextColor3 = color or (Forge.Resolve("Text", Forge.Theme) or Color3.new(1, 1, 1)),
		TextXAlignment = GetEnum("TextXAlignment", "Center"),
		TextYAlignment = GetEnum("TextYAlignment", "Center"),
		BackgroundTransparency = 1,
		Size = UDim2.fromOffset(textSize + 4, textSize + 4),
		FontFace = Font.fromEnum(Forge.Font or GetEnum("Font", "Gotham")),
		Skin = {TextColor3 = "Text"}
	})
end

function Icons.Has(name)
	return Glyphs[name] ~= nil
end

function Icons.Set(name, glyph)
	Glyphs[name] = tostring(glyph)
end

function Icons.Get(name)
	return Glyphs[name]
end

local function AddCorner(parent, radius)
	return Forge.Make("UICorner", {
		CornerRadius = UDim.new(0, radius or 10)
	}, nil)
end

local function AddStroke(parent, themeKey, transparency, thickness)
	local theme = Forge.Theme or Palette.Default
	return Forge.Make("UIStroke", {
		Color = Forge.Resolve(themeKey or "Border", theme) or theme.Border,
		Transparency = transparency == nil and 0.3 or transparency,
		Thickness = thickness or 1,
		Skin = {Color = themeKey or "Border"}
	}, nil)
end

local function AddPadding(left, right, top, bottom)
	return Forge.Make("UIPadding", {
		PaddingLeft = UDim.new(0, left or 0),
		PaddingRight = UDim.new(0, right or 0),
		PaddingTop = UDim.new(0, top or 0),
		PaddingBottom = UDim.new(0, bottom or 0)
	}, nil)
end

local function TweenPlay(object, time, properties, style, direction)
	local tween = Forge.Tween(object, time, properties, style, direction)
	tween:Play()
	return tween
end

local function PointIn(input, object)
	if not input or not object then
		return false
	end
	local position = input.Position
	local abs = object.AbsolutePosition
	local size = object.AbsoluteSize
	return position.X >= abs.X and position.X <= abs.X + size.X and position.Y >= abs.Y and position.Y <= abs.Y + size.Y
end

local function IsPress(input)
	return input.UserInputType == GetEnum("UserInputType", "MouseButton1") or input.UserInputType == GetEnum("UserInputType", "Touch")
end

local function IsMove(input)
	return input.UserInputType == GetEnum("UserInputType", "MouseMovement") or input.UserInputType == GetEnum("UserInputType", "Touch")
end

local function FormatNumber(value, decimals)
	if decimals and decimals > 0 then
		return string.format("%." .. tostring(decimals) .. "f", value)
	end
	if math.floor(value) == value then
		return tostring(math.floor(value))
	end
	return tostring(value)
end

local function ResolveAccentText(theme)
	local accent = Color(theme.Accent, Color3.new(1, 1, 1))
	local luminance = accent.R * 0.299 + accent.G * 0.587 + accent.B * 0.114
	return luminance > 0.66 and Color3.fromRGB(12, 14, 18) or Color3.new(1, 1, 1)
end

local Tab = {}
Tab.__index = Tab

function Tab.new(window, options)
	options = options or {}
	local self = setmetatable({}, Tab)
	self.Window = window
	self.Title = options.Title or options.Name or "Tab"
	self.Icon = options.Icon or "Circle"
	self.Description = options.Description or ""
	self.Selected = false
	self.Widgets = {}
	self.LayoutOrder = options.LayoutOrder or #window.Tabs + 1
	self.Disabled = options.Disabled or false

	local theme = window:GetTheme()

	local button = Forge.Make("TextButton", {
		Name = "TabButton_" .. tostring(self.LayoutOrder),
		Size = UDim2.new(1, -18, 0, 38),
		BackgroundColor3 = theme.Surface,
		BackgroundTransparency = 1,
		Text = "",
		LayoutOrder = self.LayoutOrder,
		AutoButtonColor = false,
		Parent = window.Sidebar,
		Skin = {
			BackgroundColor3 = "Surface"
		}
	}, {
		AddCorner(nil, theme.RadiusSmall or 8),
		Forge.Make("Frame", {
			Name = "Indicator",
			Size = UDim2.fromOffset(3, 22),
			Position = UDim2.new(0, 0, 0.5, 0),
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundColor3 = theme.Accent,
			BackgroundTransparency = 1,
			Skin = {BackgroundColor3 = "Accent"}
		}, {
			AddCorner(nil, 2)
		}),
		AddPadding(11, 9, 0, 0),
		Forge.Make("UIListLayout", {
			FillDirection = GetEnum("FillDirection", "Horizontal"),
			VerticalAlignment = GetEnum("VerticalAlignment", "Center"),
			Padding = UDim.new(0, 10),
			SortOrder = GetEnum("SortOrder", "LayoutOrder")
		}),
		Icons.Create(self.Icon, theme.TextDim, 17),
		Forge.Make("TextLabel", {
			Name = "Title",
			Text = self.Title,
			TextSize = 13,
			TextXAlignment = GetEnum("TextXAlignment", "Left"),
			TextColor3 = theme.TextDim,
			Size = UDim2.new(1, -34, 1, 0),
			FontFace = Font.fromEnum(Forge.Font),
			Skin = {TextColor3 = "TextDim"}
		})
	})

	local section = Forge.Make("ScrollingFrame", {
		Name = "TabContent",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 1, 0),
		CanvasSize = UDim2.new(),
		ScrollBarThickness = 3,
		ScrollBarImageTransparency = 0.4,
		ScrollBarImageColor3 = theme.Scrollbar,
		Visible = false,
		ClipsDescendants = true,
		Parent = window.Content,
		Skin = {ScrollBarImageColor3 = "Scrollbar"}
	}, {
		Forge.Make("UIListLayout", {
			FillDirection = GetEnum("FillDirection", "Vertical"),
			Padding = UDim.new(0, theme.Spacing or 8),
			SortOrder = GetEnum("SortOrder", "LayoutOrder")
		}),
		AddPadding(2, 4, 2, 8)
	})

	self.Button = button
	self.Section = section
	self.Indicator = button:FindFirstChild("Indicator")

	button.MouseButton1Click:Connect(function()
		if not self.Disabled then
			window:SelectTab(self)
		end
	end)

	button.MouseEnter:Connect(function()
		if not self.Selected and not self.Disabled then
			TweenPlay(button, 0.16, {BackgroundTransparency = 0.88, BackgroundColor3 = theme.SurfaceHover})
		end
	end)

	button.MouseLeave:Connect(function()
		if not self.Selected then
			TweenPlay(button, 0.16, {BackgroundTransparency = 1})
		end
	end)

	return self
end

function Tab:GetTheme()
	return self.Window:GetTheme()
end

function Tab:Select()
	self.Selected = true
	self.Section.Visible = true
	local theme = self:GetTheme()
	self.Button.BackgroundTransparency = 0.72
	self.Button.BackgroundColor3 = theme.SurfaceHover
	if self.Indicator then
		self.Indicator.BackgroundTransparency = 0
	end
	local title = self.Button:FindFirstChild("Title")
	if title then
		title.TextColor3 = theme.Text
	end
end

function Tab:Deselect()
	self.Selected = false
	self.Section.Visible = false
	self.Button.BackgroundTransparency = 1
	if self.Indicator then
		self.Indicator.BackgroundTransparency = 1
	end
	local title = self.Button:FindFirstChild("Title")
	local theme = self:GetTheme()
	if title then
		title.TextColor3 = theme.TextDim
	end
end

function Tab:SetTitle(title)
	self.Title = tostring(title)
	local label = self.Button:FindFirstChild("Title")
	if label then
		label.Text = self.Title
	end
	return self
end

function Tab:SetIcon(icon)
	self.Icon = icon
	local label = self.Button:FindFirstChild("Icon")
	if label then
		label.Text = Glyphs[icon] or Glyphs.Void
	end
	return self
end

function Tab:SetDisabled(disabled)
	self.Disabled = not not disabled
	self.Button.Active = not self.Disabled
	self.Button.AutoButtonColor = not self.Disabled
	self.Button.TextTransparency = self.Disabled and 0.4 or 0
	return self
end

function Tab:_Row(title, desc, height)
	local theme = self:GetTheme()
	local rowHeight = height or (desc and 70 or 46)
	local row = Forge.Make("Frame", {
		Name = "Row",
		Size = UDim2.new(1, 0, 0, rowHeight),
		BackgroundTransparency = 1,
		LayoutOrder = #self.Widgets + 1,
		Parent = self.Section
	}, {
		Forge.Make("UIListLayout", {
			FillDirection = GetEnum("FillDirection", "Vertical"),
			Padding = UDim.new(0, 3),
			SortOrder = GetEnum("SortOrder", "LayoutOrder")
		}),
		Forge.Make("TextLabel", {
			Name = "Title",
			Text = title or "",
			TextSize = 13,
			TextXAlignment = GetEnum("TextXAlignment", "Left"),
			TextColor3 = theme.Text,
			Size = UDim2.new(1, 0, 0, desc and 18 or 22),
			FontFace = Font.fromEnum(Forge.Font),
			Skin = {TextColor3 = "Text"}
		})
	})
	if desc then
		Forge.Make("TextLabel", {
			Name = "Description",
			Text = desc,
			TextSize = 11,
			TextXAlignment = GetEnum("TextXAlignment", "Left"),
			TextYAlignment = GetEnum("TextYAlignment", "Top"),
			TextColor3 = theme.TextDim,
			Size = UDim2.new(1, 0, 0, rowHeight - 24),
			TextWrapped = true,
			FontFace = Font.fromEnum(Forge.Font),
			Skin = {TextColor3 = "TextDim"},
			Parent = row
		})
	end
	table.insert(self.Widgets, row)
	return row
end

function Tab:_ControlSurface(parent, options)
	options = options or {}
	local theme = self:GetTheme()
	local surface = Forge.Make("Frame", {
		Name = options.Name or "Control",
		Size = options.Size or UDim2.new(0, options.Width or 180, 0, options.Height or theme.ControlHeight),
		BackgroundColor3 = options.BackgroundColor3 or theme.Surface,
		BackgroundTransparency = options.BackgroundTransparency or 0,
		BorderSizePixel = 0,
		Parent = parent,
		Skin = {BackgroundColor3 = options.ThemeKey or "Surface"}
	}, {
		AddCorner(nil, options.Radius or theme.RadiusSmall),
		AddStroke(nil, "Border", options.StrokeTransparency == nil and 0.6 or options.StrokeTransparency, 1)
	})
	return surface
end

function Tab:CreateSection(options)
	options = options or {}
	local theme = self:GetTheme()
	local container = Forge.Make("Frame", {
		Name = "SectionHeader",
		Size = UDim2.new(1, 0, 0, 28),
		BackgroundTransparency = 1,
		LayoutOrder = #self.Widgets + 1,
		Parent = self.Section
	}, {
		Forge.Make("UIListLayout", {
			FillDirection = GetEnum("FillDirection", "Horizontal"),
			VerticalAlignment = GetEnum("VerticalAlignment", "Center"),
			Padding = UDim.new(0, 8),
			SortOrder = GetEnum("SortOrder", "LayoutOrder")
		}),
		Forge.Make("Frame", {
			Size = UDim2.fromOffset(3, 14),
			BackgroundColor3 = theme.Accent,
			Skin = {BackgroundColor3 = "Accent"}
		}, {
			AddCorner(nil, 2)
		}),
		Forge.Make("TextLabel", {
			Name = "Title",
			Text = options.Title or "Section",
			TextSize = 11,
			TextXAlignment = GetEnum("TextXAlignment", "Left"),
			TextColor3 = theme.Accent,
			Size = UDim2.fromOffset(0, 24),
			AutomaticSize = GetEnum("AutomaticSize", "X"),
			FontFace = Font.fromEnum(Forge.Font),
			Skin = {TextColor3 = "Accent"}
		}),
		Forge.Make("Frame", {
			Name = "Line",
			Size = UDim2.new(1, -8, 0, 1),
			BackgroundColor3 = theme.Border,
			Skin = {BackgroundColor3 = "Border"}
		})
	})
	table.insert(self.Widgets, container)
	return container
end

function Tab:CreateDivider(options)
	options = options or {}
	local theme = self:GetTheme()
	local divider = Forge.Make("Frame", {
		Name = "Divider",
		Size = UDim2.new(1, 0, 0, options.Height or 1),
		BackgroundColor3 = theme.Border,
		BackgroundTransparency = options.Transparency or 0,
		LayoutOrder = #self.Widgets + 1,
		Parent = self.Section,
		Skin = {BackgroundColor3 = "Border"}
	})
	table.insert(self.Widgets, divider)
	return divider
end

function Tab:CreateSpacer(options)
	options = options or {}
	local spacer = Forge.Make("Frame", {
		Name = "Spacer",
		Size = UDim2.new(1, 0, 0, options.Size or options.Height or 8),
		BackgroundTransparency = 1,
		LayoutOrder = #self.Widgets + 1,
		Parent = self.Section
	})
	table.insert(self.Widgets, spacer)
	return spacer
end

function Tab:CreateLabel(options)
	options = options or {}
	local theme = self:GetTheme()
	local label = Forge.Make("TextLabel", {
		Name = "Label",
		Text = options.Title or options.Text or "",
		TextSize = options.TextSize or 13,
		TextXAlignment = options.Alignment or GetEnum("TextXAlignment", "Left"),
		TextYAlignment = GetEnum("TextYAlignment", "Center"),
		TextColor3 = options.Color or theme.Text,
		Size = UDim2.new(1, 0, 0, options.Height or 24),
		LayoutOrder = #self.Widgets + 1,
		FontFace = Font.fromEnum(Forge.Font),
		Parent = self.Section,
		Skin = {TextColor3 = options.ThemeColor or "Text"}
	})
	table.insert(self.Widgets, label)
	return label
end

function Tab:CreateParagraph(options)
	options = options or {}
	local theme = self:GetTheme()
	local content = tostring(options.Content or options.Text or "")
	local height = options.Height or math.max(72, 48 + math.ceil(#content / 70) * 14)
	local card = Forge.Make("Frame", {
		Name = "Paragraph",
		Size = UDim2.new(1, 0, 0, height),
		BackgroundColor3 = theme.Surface,
		LayoutOrder = #self.Widgets + 1,
		Parent = self.Section,
		Skin = {BackgroundColor3 = "Surface"}
	}, {
		AddCorner(nil, theme.RadiusSmall),
		AddStroke(nil, "Border", 0.55, 1),
		AddPadding(13, 13, 10, 10),
		Forge.Make("UIListLayout", {
			FillDirection = GetEnum("FillDirection", "Vertical"),
			Padding = UDim.new(0, 4),
			SortOrder = GetEnum("SortOrder", "LayoutOrder")
		}),
		Forge.Make("TextLabel", {
			Name = "Title",
			Text = options.Title or "",
			TextSize = 13,
			TextXAlignment = GetEnum("TextXAlignment", "Left"),
			TextColor3 = theme.Text,
			Size = UDim2.new(1, 0, 0, 18),
			Visible = options.Title ~= nil and options.Title ~= "",
			FontFace = Font.fromEnum(Forge.Font),
			Skin = {TextColor3 = "Text"}
		}),
		Forge.Make("TextLabel", {
			Name = "Content",
			Text = content,
			TextSize = options.TextSize or 12,
			TextXAlignment = GetEnum("TextXAlignment", "Left"),
			TextYAlignment = GetEnum("TextYAlignment", "Top"),
			TextColor3 = options.Color or theme.TextDim,
			Size = UDim2.new(1, 0, 1, -22),
			TextWrapped = true,
			FontFace = Font.fromEnum(Forge.Font),
			Skin = {TextColor3 = "TextDim"}
		})
	})
	table.insert(self.Widgets, card)
	return card
end

function Tab:CreateCard(options)
	options = options or {}
	local theme = self:GetTheme()
	local card = Forge.Make("Frame", {
		Name = options.Name or "Card",
		Size = options.Size or UDim2.new(1, 0, 0, options.Height or 80),
		BackgroundColor3 = options.Color or theme.Surface,
		BackgroundTransparency = options.Transparency or 0,
		LayoutOrder = #self.Widgets + 1,
		Parent = self.Section,
		Skin = {BackgroundColor3 = options.ThemeColor or "Surface"}
	}, {
		AddCorner(nil, options.Radius or theme.Radius),
		AddStroke(nil, "Border", 0.5, 1),
		AddPadding(options.Padding or 12, options.Padding or 12, options.Padding or 12, options.Padding or 12)
	})
	table.insert(self.Widgets, card)
	return card
end

function Tab:CreateHeader(options)
	options = options or {}
	local theme = self:GetTheme()
	local icon = options.Icon and Icons.Create(options.Icon, theme.Accent, options.IconSize or 20) or nil
	local header = Forge.Make("Frame", {
		Name = "Header",
		Size = UDim2.new(1, 0, 0, options.Height or 44),
		BackgroundTransparency = 1,
		LayoutOrder = #self.Widgets + 1,
		Parent = self.Section
	}, {
		AddPadding(2, 2, 0, 0),
		Forge.Make("UIListLayout", {
			FillDirection = GetEnum("FillDirection", "Horizontal"),
			Padding = UDim.new(0, 9),
			VerticalAlignment = GetEnum("VerticalAlignment", "Center"),
			SortOrder = GetEnum("SortOrder", "LayoutOrder")
		})
	})
	if icon then
		icon.LayoutOrder = 1
		icon.Parent = header
	end
	Forge.Make("TextLabel", {
		Name = "Title",
		Text = options.Title or "Header",
		TextSize = options.TextSize or 18,
		TextXAlignment = GetEnum("TextXAlignment", "Left"),
		TextColor3 = theme.Text,
		AutomaticSize = GetEnum("AutomaticSize", "X"),
		Size = UDim2.new(0, 0, 1, 0),
		FontFace = Font.fromEnum(Forge.Font),
		Skin = {TextColor3 = "Text"},
		Parent = header
	})
	if options.Subtitle then
		Forge.Make("TextLabel", {
			Name = "Subtitle",
			Text = options.Subtitle,
			TextSize = 11,
			TextXAlignment = GetEnum("TextXAlignment", "Left"),
			TextColor3 = theme.TextDim,
			AutomaticSize = GetEnum("AutomaticSize", "X"),
			Size = UDim2.new(0, 0, 1, 0),
			FontFace = Font.fromEnum(Forge.Font),
			Skin = {TextColor3 = "TextDim"},
			Parent = header
		})
	end
	table.insert(self.Widgets, header)
	return header
end

function Tab:CreateStatus(options)
	options = options or {}
	local theme = self:GetTheme()
	local state = options.State or options.Type or "Info"
	local stateColor = theme.Info
	if state == "Success" then stateColor = theme.Success end
	if state == "Warning" then stateColor = theme.Warning end
	if state == "Error" or state == "Danger" then stateColor = theme.Danger end
	local card = Forge.Make("Frame", {
		Name = "Status",
		Size = UDim2.new(1, 0, 0, options.Height or 46),
		BackgroundColor3 = theme.Surface,
		LayoutOrder = #self.Widgets + 1,
		Parent = self.Section,
		Skin = {BackgroundColor3 = "Surface"}
	}, {
		AddCorner(nil, theme.RadiusSmall),
		AddStroke(nil, "Border", 0.55, 1),
		AddPadding(10, 10, 7, 7),
		Forge.Make("Frame", {
			Name = "Dot",
			Size = UDim2.fromOffset(7, 7),
			BackgroundColor3 = stateColor,
			Skin = {BackgroundColor3 = state == "Success" and "Success" or state == "Warning" and "Warning" or state == "Error" and "Danger" or "Info"}
		}, {
			AddCorner(nil, 7)
		}),
		Forge.Make("UIListLayout", {
			FillDirection = GetEnum("FillDirection", "Horizontal"),
			VerticalAlignment = GetEnum("VerticalAlignment", "Center"),
			Padding = UDim.new(0, 8)
		}),
		Forge.Make("TextLabel", {
			Name = "Text",
			Text = options.Title or options.Text or "",
			TextSize = 12,
			TextXAlignment = GetEnum("TextXAlignment", "Left"),
			TextColor3 = options.TextColor or theme.TextDim,
			Size = UDim2.new(1, -18, 1, 0),
			FontFace = Font.fromEnum(Forge.Font),
			Skin = {TextColor3 = "TextDim"}
		})
	})
	table.insert(self.Widgets, card)
	return card
end

function Tab:CreateBadge(options)
	options = options or {}
	local theme = self:GetTheme()
	local state = options.Type or "Default"
	local background = state == "Success" and theme.Success or state == "Warning" and theme.Warning or state == "Danger" and theme.Danger or state == "Info" and theme.Info or theme.SurfaceHover
	local textColor = state == "Default" and theme.TextDim or ResolveAccentText({Accent = state == "Success" and theme.Success or state == "Warning" and theme.Warning or state == "Danger" and theme.Danger or state == "Info" and theme.Info or theme.SurfaceHover})
	local badge = Forge.Make("TextLabel", {
		Name = "Badge",
		Text = options.Text or options.Title or "Badge",
		TextSize = options.TextSize or 10,
		TextColor3 = textColor,
		BackgroundColor3 = background,
		AutomaticSize = GetEnum("AutomaticSize", "X"),
		Size = UDim2.fromOffset(0, options.Height or 22),
		LayoutOrder = #self.Widgets + 1,
		FontFace = Font.fromEnum(Forge.Font),
		Parent = self.Section
	}, {
		AddCorner(nil, 99),
		AddPadding(options.Padding or 9, options.Padding or 9, 0, 0)
	})
	table.insert(self.Widgets, badge)
	return badge
end

function Tab:CreateToggle(options)
	options = options or {}
	local theme = self:GetTheme()
	local value = options.Default ~= nil and not not options.Default or false
	local callback = options.Callback or function() end
	local row = self:_Row(options.Title, options.Description, options.Description and 70 or 46)
	local control = Forge.Make("Frame", {
		Name = "Control",
		Size = UDim2.new(1, 0, 0, 24),
		BackgroundTransparency = 1,
		Parent = row
	}, {
		Forge.Make("UIListLayout", {
			FillDirection = GetEnum("FillDirection", "Horizontal"),
			HorizontalAlignment = GetEnum("HorizontalAlignment", "Right"),
			VerticalAlignment = GetEnum("VerticalAlignment", "Center")
		})
	})
	local track = Forge.Make("TextButton", {
		Name = "Track",
		Size = UDim2.fromOffset(44, 24),
		BackgroundColor3 = value and theme.Accent or theme.SurfaceHover,
		Text = "",
		Parent = control,
		Skin = {BackgroundColor3 = value and "Accent" or "SurfaceHover"}
	}, {
		AddCorner(nil, 99),
		Forge.Make("Frame", {
			Name = "Knob",
			Size = UDim2.fromOffset(18, 18),
			Position = value and UDim2.new(1, -21, 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundColor3 = Color3.new(1, 1, 1)
		}, {
			AddCorner(nil, 99)
		})
	})
	local knob = track:FindFirstChild("Knob")
	local function setState(newValue, fire)
		value = not not newValue
		TweenPlay(track, 0.16, {
			BackgroundColor3 = value and theme.Accent or theme.SurfaceHover
		})
		TweenPlay(knob, 0.16, {
			Position = value and UDim2.new(1, -21, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)
		})
		if fire ~= false then
			Forge.Guard(callback, value)
		end
	end
	track.MouseButton1Click:Connect(function()
		setState(not value)
	end)
	local api = {
		Set = function(_, newValue, fire)
			setState(newValue, fire)
			return api
		end,
		Get = function()
			return value
		end,
		Toggle = function(_, fire)
			setState(not value, fire)
			return api
		end,
		Instance = row,
		Control = track
	}
	return api
end

function Tab:CreateCheckbox(options)
	options = options or {}
	options.Default = options.Default or false
	return self:CreateToggle(options)
end

function Tab:CreateSwitch(options)
	return self:CreateToggle(options)
end

function Tab:CreateSlider(options)
	options = options or {}
	local theme = self:GetTheme()
	local minValue = tonumber(options.Min) or 0
	local maxValue = tonumber(options.Max) or 100
	if maxValue <= minValue then
		maxValue = minValue + 1
	end
	local decimals = tonumber(options.Decimal) or 0
	local step = tonumber(options.Step)
	local suffix = options.Suffix or options.SuffixText or ""
	local value = ClampNumber(options.Default, minValue, maxValue, minValue)
	local callback = options.Callback or function() end
	local row = self:_Row(options.Title, options.Description, options.Description and 78 or 54)
	local control = Forge.Make("Frame", {
		Name = "Control",
		Size = UDim2.new(1, 0, 0, 30),
		BackgroundTransparency = 1,
		Parent = row
	})
	local valueLabel = Forge.Make("TextLabel", {
		Name = "Value",
		Text = FormatNumber(value, decimals) .. suffix,
		TextSize = 11,
		TextXAlignment = GetEnum("TextXAlignment", "Right"),
		TextColor3 = theme.TextDim,
		Size = UDim2.fromOffset(70, 30),
		Position = UDim2.new(1, -70, 0, 0),
		FontFace = Font.fromEnum(Forge.Font),
		Skin = {TextColor3 = "TextDim"},
		Parent = control
	})
	local bar = Forge.Make("Frame", {
		Name = "Bar",
		Size = UDim2.new(1, -82, 0, 7),
		Position = UDim2.new(0, 0, 0.5, 0),
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundColor3 = theme.SurfaceHover,
		Parent = control,
		Skin = {BackgroundColor3 = "SurfaceHover"}
	}, {
		AddCorner(nil, 99)
	})
	local fill = Forge.Make("Frame", {
		Name = "Fill",
		Size = UDim2.new(math.clamp((value - minValue) / (maxValue - minValue), 0, 1), 0, 1, 0),
		BackgroundColor3 = theme.Accent,
		Parent = bar,
		Skin = {BackgroundColor3 = "Accent"}
	}, {
		AddCorner(nil, 99)
	})
	local handle = Forge.Make("Frame", {
		Name = "Handle",
		Size = UDim2.fromOffset(12, 12),
		Position = UDim2.new(math.clamp((value - minValue) / (maxValue - minValue), 0, 1), -6, 0.5, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Color3.new(1, 1, 1),
		ZIndex = 3,
		Parent = bar
	}, {
		AddCorner(nil, 99)
	})
	local dragging = false
	local function normalize(raw)
		if step and step > 0 then
			raw = minValue + math.round((raw - minValue) / step) * step
		end
		if decimals > 0 then
			raw = math.floor(raw * (10 ^ decimals) + 0.5) / (10 ^ decimals)
		else
			raw = math.floor(raw + 0.5)
		end
		return math.clamp(raw, minValue, maxValue)
	end
	local function setValue(newValue, fire)
		value = normalize(tonumber(newValue) or minValue)
		local ratio = math.clamp((value - minValue) / (maxValue - minValue), 0, 1)
		fill.Size = UDim2.new(ratio, 0, 1, 0)
		handle.Position = UDim2.new(ratio, 0, 0.5, 0)
		valueLabel.Text = FormatNumber(value, decimals) .. suffix
		if fire ~= false then
			Forge.Guard(callback, value)
		end
	end
	local function fromInput(input)
		local x = UserInputService:GetMouseLocation().X
		local left = bar.AbsolutePosition.X
		local width = math.max(bar.AbsoluteSize.X, 1)
		local ratio = math.clamp((x - left) / width, 0, 1)
		setValue(minValue + ratio * (maxValue - minValue))
	end
	bar.InputBegan:Connect(function(input)
		if IsPress(input) then
			dragging = true
			fromInput(input)
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if dragging and IsMove(input) then
			fromInput(input)
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if IsPress(input) then
			dragging = false
		end
	end)
	local api = {
		Set = function(_, newValue, fire)
			setValue(newValue, fire)
			return api
		end,
		Get = function()
			return value
		end,
		Min = function()
			return minValue
		end,
		Max = function()
			return maxValue
		end,
		Instance = row,
		Bar = bar
	}
	return api
end

function Tab:CreateDropdown(options)
	options = options or {}
	local theme = self:GetTheme()
	local items = CopyTable(options.Options or options.Values or {})
	local multi = options.Multi or options.Multiple or false
	local callback = options.Callback or function() end
	local value
	if multi then
		value = type(options.Default) == "table" and CopyTable(options.Default) or {}
	else
		value = options.Default
		if value == nil then
			value = items[1]
		end
	end
	local row = self:_Row(options.Title, options.Description, options.Description and 86 or 58)
	local control = Forge.Make("TextButton", {
		Name = "Dropdown",
		Size = UDim2.new(1, 0, 0, 34),
		BackgroundColor3 = theme.Surface,
		Text = "",
		AutoButtonColor = false,
		Parent = row,
		Skin = {BackgroundColor3 = "Surface"}
	}, {
		AddCorner(nil, theme.RadiusSmall),
		AddStroke(nil, "Border", 0.55, 1),
		AddPadding(11, 10, 0, 0),
		Forge.Make("TextLabel", {
			Name = "Current",
			Text = "",
			TextSize = 12,
			TextXAlignment = GetEnum("TextXAlignment", "Left"),
			TextColor3 = theme.Text,
			Size = UDim2.new(1, -28, 1, 0),
			FontFace = Font.fromEnum(Forge.Font),
			Skin = {TextColor3 = "Text"}
		}),
		Icons.Create("ChevronDown", theme.TextDim, 14)
	})
	local current = control:FindFirstChild("Current")
	local popup = Forge.Make("Frame", {
		Name = "DropdownPopup",
		BackgroundColor3 = theme.BackgroundElevated,
		Visible = false,
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(260, 0),
		AutomaticSize = GetEnum("AutomaticSize", "Y"),
		ZIndex = 500,
		Skin = {BackgroundColor3 = "BackgroundElevated"}
	}, {
		AddCorner(nil, theme.RadiusSmall),
		AddStroke(nil, "Border", 0.2, 1),
		AddPadding(6, 6, 6, 6),
		Forge.Make("UIListLayout", {
			FillDirection = GetEnum("FillDirection", "Vertical"),
			Padding = UDim.new(0, 4),
			SortOrder = GetEnum("SortOrder", "LayoutOrder")
		})
	})
	popup.ZIndex = 500
	popup.Parent = self.Window.VoidUI.Overlays

	local search = nil
	if options.Search ~= false then
		search = Forge.Make("TextBox", {
			Name = "Search",
			Size = UDim2.new(1, 0, 0, 30),
			BackgroundColor3 = theme.Surface,
			Text = "",
			PlaceholderText = "Search...",
			TextSize = 11,
			TextColor3 = theme.Text,
			PlaceholderColor3 = theme.TextMuted,
			ClearTextOnFocus = false,
			ZIndex = 501,
			FontFace = Font.fromEnum(Forge.Font),
			Skin = {BackgroundColor3 = "Surface", TextColor3 = "Text"}
		}, {
			AddCorner(nil, 7),
			AddPadding(8, 8, 0, 0)
		})
		search.LayoutOrder = 1
		search.Parent = popup
	end

	local listContainer = Forge.Make("Frame", {
		Name = "List",
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = GetEnum("AutomaticSize", "Y"),
		BackgroundTransparency = 1,
		ZIndex = 501,
		LayoutOrder = 2,
		Parent = popup
	}, {
		Forge.Make("UIListLayout", {
			FillDirection = GetEnum("FillDirection", "Vertical"),
			Padding = UDim.new(0, 4),
			SortOrder = GetEnum("SortOrder", "LayoutOrder")
		})
	})

	local function displayValue()
		if multi then
			if #value == 0 then
				return options.Placeholder or "None selected"
			end
			return table.concat(value, options.Separator or ", ")
		end
		return tostring(value or options.Placeholder or "Select...")
	end

	local function isSelected(item)
		return multi and table.find(value, item) ~= nil or (not multi and value == item)
	end

	local function rebuild(filter)
		for _, child in ipairs(listContainer:GetChildren()) do
			if child:IsA("TextButton") then
				child:Destroy()
			end
		end
		filter = string.lower(filter or "")
		for index, item in ipairs(items) do
			local text = tostring(item)
			if filter == "" or string.find(string.lower(text), filter, 1, true) then
				local selected = isSelected(item)
				local button = Forge.Make("TextButton", {
					Name = "Option_" .. tostring(index),
					Size = UDim2.new(1, 0, 0, 30),
					BackgroundColor3 = selected and theme.SurfaceActive or theme.Surface,
					Text = (selected and "✓  " or "    ") .. text,
					TextSize = 11,
					TextXAlignment = GetEnum("TextXAlignment", "Left"),
					TextColor3 = selected and theme.Accent or theme.Text,
					AutoButtonColor = false,
					ZIndex = 502,
					FontFace = Font.fromEnum(Forge.Font),
					Skin = {
						BackgroundColor3 = selected and "SurfaceActive" or "Surface",
						TextColor3 = selected and "Accent" or "Text"
					}
				}, {
					AddCorner(nil, 6),
					AddPadding(8, 8, 0, 0)
				})
				button.Parent = listContainer
				button.MouseEnter:Connect(function()
					TweenPlay(button, 0.1, {BackgroundColor3 = theme.SurfaceHover})
				end)
				button.MouseLeave:Connect(function()
					TweenPlay(button, 0.1, {BackgroundColor3 = isSelected(item) and theme.SurfaceActive or theme.Surface})
				end)
				button.MouseButton1Click:Connect(function()
					if multi then
						local found = table.find(value, item)
						if found then
							table.remove(value, found)
						else
							table.insert(value, item)
						end
					else
						value = item
						popup.Visible = false
					end
					current.Text = displayValue()
					rebuild(search and search.Text or "")
					Forge.Guard(callback, value)
				end)
			end
		end
	end

	current.Text = displayValue()
	if search then
		search:GetPropertyChangedSignal("Text"):Connect(function()
			rebuild(search.Text)
		end)
	end
	control.MouseButton1Click:Connect(function()
		popup.Visible = not popup.Visible
		if popup.Visible then
			rebuild("")
			local position = control.AbsolutePosition
			local screen = self.Window.ScreenGui.AbsoluteSize
			local height = popup.AbsoluteSize.Y
			local x = position.X
			local y = position.Y + control.AbsoluteSize.Y + 5
			if y + height > screen.Y - 8 then
				y = math.max(8, position.Y - height - 5)
			end
			if x + control.AbsoluteSize.X > screen.X - 8 then
				x = math.max(8, screen.X - control.AbsoluteSize.X - 8)
			end
			popup.Position = UDim2.fromOffset(x, y)
		end
	end)

	local api
	api = {
		Set = function(_, newValue, fire)
			if multi then
				value = type(newValue) == "table" and CopyTable(newValue) or {}
			else
				value = newValue
			end
			current.Text = displayValue()
			rebuild(search and search.Text or "")
			if fire ~= false then
				Forge.Guard(callback, value)
			end
			return api
		end,
		Get = function()
			if multi then
				return CopyTable(value)
			end
			return value
		end,
		SetOptions = function(_, newOptions)
			items = CopyTable(newOptions or {})
			rebuild(search and search.Text or "")
			return api
		end,
		Open = function()
			popup.Visible = true
			rebuild("")
			return api
		end,
		Close = function()
			popup.Visible = false
			return api
		end,
		Toggle = function()
			popup.Visible = not popup.Visible
			if popup.Visible then
				rebuild("")
			end
			return api
		end,
		Instance = row,
		Control = control,
		Popup = popup
	}
	return api
end

function Tab:CreateMultiDropdown(options)
	options = options or {}
	options.Multi = true
	return self:CreateDropdown(options)
end

function Tab:CreateColorPicker(options)
	options = options or {}
	local theme = self:GetTheme()
	local value = Color(options.Default, Color3.fromRGB(255, 255, 255))
	local callback = options.Callback or function() end
	local row = self:_Row(options.Title, options.Description, options.Description and 78 or 54)
	local swatch = Forge.Make("TextButton", {
		Name = "Swatch",
		Size = UDim2.fromOffset(32, 32),
		BackgroundColor3 = value,
		Text = "",
		AutoButtonColor = false,
		Parent = row
	}, {
		AddCorner(nil, 8),
		AddStroke(nil, "Border", 0.35, 1)
	})
	local popup = Forge.Make("Frame", {
		Name = "ColorPopup",
		BackgroundColor3 = theme.BackgroundElevated,
		Visible = false,
		Size = UDim2.fromOffset(250, 260),
		ZIndex = 600,
		Skin = {BackgroundColor3 = "BackgroundElevated"}
	}, {
		AddCorner(nil, theme.Radius),
		AddStroke(nil, "Border", 0.15, 1),
		AddPadding(10, 10, 10, 10)
	})
	popup.Parent = self.Window.VoidUI.Overlays

	local satVal = Forge.Make("Frame", {
		Name = "SatVal",
		Size = UDim2.new(1, 0, 0, 150),
		BackgroundColor3 = Color3.fromRGB(255, 0, 0),
		ZIndex = 601
	}, {
		AddCorner(nil, 8)
	})
	satVal.Parent = popup

	local satWhite = Instance.new("UIGradient")
	satWhite.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
		ColorSequenceKeypoint.new(1, Color3.new(1, 1, 1))
	})
	satWhite.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(1, 1)
	})
	satWhite.Rotation = 0
	satWhite.Parent = satVal

	local satBlack = Instance.new("UIGradient")
	satBlack.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.new(0, 0, 0)),
		ColorSequenceKeypoint.new(1, Color3.new(0, 0, 0))
	})
	satBlack.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(1, 0)
	})
	satBlack.Rotation = 90
	satBlack.Parent = satVal

	local hue = Forge.Make("Frame", {
		Name = "Hue",
		Size = UDim2.new(1, 0, 0, 14),
		BackgroundColor3 = Color3.new(1, 1, 1),
		ZIndex = 601
	}, {
		AddCorner(nil, 99)
	})
	hue.Parent = popup

	local hueGradient = Instance.new("UIGradient")
	hueGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 1, 1)),
		ColorSequenceKeypoint.new(0.167, Color3.fromHSV(0.167, 1, 1)),
		ColorSequenceKeypoint.new(0.333, Color3.fromHSV(0.333, 1, 1)),
		ColorSequenceKeypoint.new(0.5, Color3.fromHSV(0.5, 1, 1)),
		ColorSequenceKeypoint.new(0.667, Color3.fromHSV(0.667, 1, 1)),
		ColorSequenceKeypoint.new(0.833, Color3.fromHSV(0.833, 1, 1)),
		ColorSequenceKeypoint.new(1, Color3.fromHSV(1, 1, 1))
	})
	hueGradient.Parent = hue

	local hex = Forge.Make("TextBox", {
		Name = "Hex",
		Size = UDim2.new(1, 0, 0, 32),
		BackgroundColor3 = theme.Surface,
		Text = "#" .. value:ToHex(),
		PlaceholderText = "#RRGGBB",
		TextSize = 12,
		TextColor3 = theme.Text,
		PlaceholderColor3 = theme.TextMuted,
		ClearTextOnFocus = false,
		ZIndex = 601,
		FontFace = Font.fromEnum(Forge.Font),
		Skin = {BackgroundColor3 = "Surface", TextColor3 = "Text"}
	}, {
		AddCorner(nil, 8),
		AddPadding(9, 9, 0, 0)
	})
	hex.Parent = popup

	local h, s, v = value:ToHSV()
	local draggingSV = false
	local draggingHue = false

	local function updateVisuals()
		satVal.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
		swatch.BackgroundColor3 = value
		hue.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
		hex.Text = "#" .. value:ToHex()
	end

	local function commit(fire)
		value = Color3.fromHSV(h, s, v)
		updateVisuals()
		if fire ~= false then
			Forge.Guard(callback, value)
		end
	end

	local function updateSV()
		local mouse = UserInputService:GetMouseLocation()
		local pos = satVal.AbsolutePosition
		local size = satVal.AbsoluteSize
		local x = math.clamp((mouse.X - pos.X) / math.max(size.X, 1), 0, 1)
		local y = math.clamp((mouse.Y - pos.Y) / math.max(size.Y, 1), 0, 1)
		s = x
		v = 1 - y
		commit(true)
	end

	local function updateHue()
		local mouse = UserInputService:GetMouseLocation()
		local pos = hue.AbsolutePosition
		local size = hue.AbsoluteSize
		h = math.clamp((mouse.X - pos.X) / math.max(size.X, 1), 0, 1)
		commit(true)
	end

	satVal.InputBegan:Connect(function(input)
		if IsPress(input) then
			draggingSV = true
			updateSV()
		end
	end)
	hue.InputBegan:Connect(function(input)
		if IsPress(input) then
			draggingHue = true
			updateHue()
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if draggingSV and IsMove(input) then
			updateSV()
		elseif draggingHue and IsMove(input) then
			updateHue()
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if IsPress(input) then
			draggingSV = false
			draggingHue = false
		end
	end)
	hex.FocusLost:Connect(function()
		local text = hex.Text:gsub("%s+", "")
		if string.sub(text, 1, 1) ~= "#" then
			text = "#" .. text
		end
		local ok, parsed = pcall(Color3.fromHex, text)
		if ok then
			value = parsed
			h, s, v = value:ToHSV()
			commit(true)
		else
			hex.Text = "#" .. value:ToHex()
		end
	end)
	swatch.MouseButton1Click:Connect(function()
		popup.Visible = not popup.Visible
		if popup.Visible then
			h, s, v = value:ToHSV()
			updateVisuals()
			local pos = swatch.AbsolutePosition
			local screen = self.Window.ScreenGui.AbsoluteSize
			local x = pos.X
			local y = pos.Y + swatch.AbsoluteSize.Y + 5
			if x + popup.AbsoluteSize.X > screen.X - 8 then
				x = math.max(8, screen.X - popup.AbsoluteSize.X - 8)
			end
			if y + popup.AbsoluteSize.Y > screen.Y - 8 then
				y = math.max(8, pos.Y - popup.AbsoluteSize.Y - 5)
			end
			popup.Position = UDim2.fromOffset(x, y)
		end
	end)

	local api
	api = {
		Set = function(_, newColor, fire)
			value = Color(newColor, value)
			h, s, v = value:ToHSV()
			commit(fire)
			return api
		end,
		Get = function()
			return value
		end,
		Open = function()
			popup.Visible = true
			local pos = swatch.AbsolutePosition
			popup.Position = UDim2.fromOffset(pos.X, pos.Y + swatch.AbsoluteSize.Y + 5)
			return api
		end,
		Close = function()
			popup.Visible = false
			return api
		end,
		Instance = row,
		Swatch = swatch,
		Popup = popup
	}
	updateVisuals()
	return api
end

function Tab:CreateKeybind(options)
	options = options or {}
	local theme = self:GetTheme()
	local value = options.Default or GetEnum("KeyCode", "RightShift")
	local callback = options.Callback or function() end
	local mode = options.Mode or "Toggle"
	local row = self:_Row(options.Title, options.Description, options.Description and 78 or 54)
	local button = Forge.Make("TextButton", {
		Name = "Keybind",
		Size = UDim2.fromOffset(options.Width or 135, 32),
		BackgroundColor3 = theme.Surface,
		Text = tostring(value):gsub("Enum.KeyCode.", ""),
		TextSize = 11,
		TextColor3 = theme.Text,
		Parent = row,
		AutoButtonColor = false,
		FontFace = Font.fromEnum(Forge.Font),
		Skin = {BackgroundColor3 = "Surface", TextColor3 = "Text"}
	}, {
		AddCorner(nil, 8),
		AddStroke(nil, "Border", 0.55, 1)
	})
	local listening = false
	local connection
	local function beginListening()
		listening = true
		button.Text = "Press a key..."
		if connection then
			connection:Disconnect()
		end
		connection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
			if gameProcessed then
				return
			end
			if input.UserInputType == GetEnum("UserInputType", "Keyboard") then
				value = input.KeyCode
				listening = false
				button.Text = tostring(value):gsub("Enum.KeyCode.", "")
				Forge.Guard(callback, value)
				if connection then
					connection:Disconnect()
					connection = nil
				end
			elseif input.UserInputType == GetEnum("UserInputType", "MouseButton1") and options.AllowMouse then
				value = input.UserInputType
				listening = false
				button.Text = tostring(value)
				Forge.Guard(callback, value)
				if connection then
					connection:Disconnect()
					connection = nil
				end
			end
		end)
	end
	button.MouseButton1Click:Connect(beginListening)
	local holdConnection
	local function handleRuntime(input, pressed)
		if listening then
			return
		end
		local key = value
		if input.KeyCode == key then
			Forge.Guard(callback, pressed, mode)
		end
	end
	holdConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if not gameProcessed then
			handleRuntime(input, true)
		end
	end)
	UserInputService.InputEnded:Connect(function(input, gameProcessed)
		if not gameProcessed and mode == "Hold" then
			handleRuntime(input, false)
		end
	end)
	local api
	api = {
		Set = function(_, key, fire)
			value = key
			button.Text = tostring(key):gsub("Enum.KeyCode.", "")
			if fire then
				Forge.Guard(callback, value)
			end
			return api
		end,
		Get = function()
			return value
		end,
		IsListening = function()
			return listening
		end,
		Instance = row,
		Button = button
	}
	return api
end

function Tab:CreateTextbox(options)
	options = options or {}
	local theme = self:GetTheme()
	local value = tostring(options.Default or "")
	local callback = options.Callback or function() end
	local row = self:_Row(options.Title, options.Description, options.Multiline and 92 or (options.Description and 78 or 54))
	local box = Forge.Make("TextBox", {
		Name = "Textbox",
		Size = UDim2.new(1, 0, 0, options.Height or (options.Multiline and 64 or 34)),
		BackgroundColor3 = theme.Surface,
		Text = value,
		PlaceholderText = options.Placeholder or "",
		TextSize = options.TextSize or 12,
		TextColor3 = theme.Text,
		PlaceholderColor3 = theme.TextMuted,
		ClearTextOnFocus = options.ClearTextOnFocus or false,
		MultiLine = options.Multiline or false,
		TextWrapped = options.Multiline or false,
		TextXAlignment = GetEnum("TextXAlignment", "Left"),
		TextYAlignment = options.Multiline and GetEnum("TextYAlignment", "Top") or GetEnum("TextYAlignment", "Center"),
		Parent = row,
		FontFace = Font.fromEnum(Forge.Font),
		Skin = {BackgroundColor3 = "Surface", TextColor3 = "Text"}
	}, {
		AddCorner(nil, 8),
		AddStroke(nil, "Border", 0.55, 1),
		AddPadding(10, 10, 0, 0)
	})
	box.FocusLost:Connect(function(enterPressed)
		value = box.Text
		Forge.Guard(callback, value, enterPressed)
	end)
	if options.OnChanged then
		box:GetPropertyChangedSignal("Text"):Connect(function()
			value = box.Text
			Forge.Guard(options.OnChanged, value)
		end)
	end
	local api
	api = {
		Set = function(_, text, fire)
			value = tostring(text or "")
			box.Text = value
			if fire then
				Forge.Guard(callback, value, false)
			end
			return api
		end,
		Get = function()
			return value
		end,
		Focus = function()
			box:CaptureFocus()
			return api
		end,
		Clear = function()
			value = ""
			box.Text = ""
			return api
		end,
		Instance = row,
		Box = box
	}
	return api
end

function Tab:CreateInput(options)
	return self:CreateTextbox(options)
end

function Tab:CreateButton(options)
	options = options or {}
	local theme = self:GetTheme()
	local callback = options.Callback or function() end
	local height = options.Height or 36
	local button = Forge.Make("TextButton", {
		Name = "Button",
		Size = UDim2.new(options.Fill == false and 0 or 1, options.Fill == false and (options.Width or 180) or 0, 0, height),
		BackgroundColor3 = options.Color or theme.Accent,
		Text = options.Title or options.Text or "Button",
		TextSize = options.TextSize or 12,
		TextColor3 = options.TextColor or ResolveAccentText({Accent = options.Color or theme.Accent}),
		AutoButtonColor = false,
		LayoutOrder = #self.Widgets + 1,
		Parent = self.Section,
		FontFace = Font.fromEnum(Forge.Font),
		Skin = {BackgroundColor3 = options.ThemeColor or "Accent"}
	}, {
		AddCorner(nil, options.Radius or theme.RadiusSmall)
	})
	local icon = options.Icon and Icons.Create(options.Icon, button.TextColor3, 14) or nil
	if icon then
		icon.Position = UDim2.new(0, 10, 0.5, 0)
		icon.AnchorPoint = Vector2.new(0, 0.5)
		icon.Parent = button
	end
	button.MouseEnter:Connect(function()
		TweenPlay(button, 0.14, {BackgroundColor3 = Color3.new(
			math.min(button.BackgroundColor3.R * 1.08, 1),
			math.min(button.BackgroundColor3.G * 1.08, 1),
			math.min(button.BackgroundColor3.B * 1.08, 1)
		)})
	end)
	button.MouseLeave:Connect(function()
		local target = options.Color or theme.Accent
		TweenPlay(button, 0.14, {BackgroundColor3 = target})
	end)
	button.MouseButton1Down:Connect(function()
		TweenPlay(button, 0.08, {Size = UDim2.new(options.Fill == false and 0 or 1, options.Fill == false and (options.Width or 176) or -4, 0, height - 2)})
	end)
	button.MouseButton1Up:Connect(function()
		TweenPlay(button, 0.1, {Size = UDim2.new(options.Fill == false and 0 or 1, options.Fill == false and (options.Width or 180) or 0, 0, height)})
	end)
	button.MouseButton1Click:Connect(function()
		Forge.Guard(callback)
	end)
	table.insert(self.Widgets, button)
	return {Instance = button, Click = function() Forge.Guard(callback) end}
end

function Tab:CreateIconButton(options)
	options = options or {}
	local theme = self:GetTheme()
	local callback = options.Callback or function() end
	local button = Forge.Make("TextButton", {
		Name = "IconButton",
		Size = UDim2.fromOffset(options.Size or 34, options.Size or 34),
		BackgroundColor3 = theme.Surface,
		Text = "",
		AutoButtonColor = false,
		LayoutOrder = #self.Widgets + 1,
		Parent = self.Section,
		Skin = {BackgroundColor3 = "Surface"}
	}, {
		AddCorner(nil, options.Radius or 8),
		AddStroke(nil, "Border", 0.55, 1),
		Icons.Create(options.Icon or "Circle", options.Color or theme.Text, options.IconSize or 15)
	})
	button.MouseButton1Click:Connect(function()
		Forge.Guard(callback)
	end)
	button.MouseEnter:Connect(function()
		TweenPlay(button, 0.12, {BackgroundColor3 = theme.SurfaceHover})
	end)
	button.MouseLeave:Connect(function()
		TweenPlay(button, 0.12, {BackgroundColor3 = theme.Surface})
	end)
	table.insert(self.Widgets, button)
	return {Instance = button}
end

function Tab:CreateProgressBar(options)
	options = options or {}
	local theme = self:GetTheme()
	local minValue = tonumber(options.Min) or 0
	local maxValue = tonumber(options.Max) or 100
	if maxValue <= minValue then
		maxValue = minValue + 1
	end
	local value = ClampNumber(options.Default, minValue, maxValue, minValue)
	local row = self:_Row(options.Title, options.Description, options.Description and 70 or 46)
	local bar = Forge.Make("Frame", {
		Name = "Progress",
		Size = UDim2.new(1, 0, 0, options.Height or 8),
		BackgroundColor3 = theme.SurfaceHover,
		Parent = row,
		Skin = {BackgroundColor3 = "SurfaceHover"}
	}, {
		AddCorner(nil, 99),
		Forge.Make("Frame", {
			Name = "Fill",
			Size = UDim2.new((value - minValue) / (maxValue - minValue), 0, 1, 0),
			BackgroundColor3 = options.Color or theme.Accent,
			Skin = {BackgroundColor3 = options.ThemeColor or "Accent"}
		}, {
			AddCorner(nil, 99)
		})
	})
	local fill = bar:FindFirstChild("Fill")
	local function setValue(newValue)
		value = ClampNumber(newValue, minValue, maxValue, minValue)
		TweenPlay(fill, 0.18, {Size = UDim2.new((value - minValue) / (maxValue - minValue), 0, 1, 0)})
		if options.Callback then
			Forge.Guard(options.Callback, value)
		end
	end
	local api
	api = {
		Set = function(_, newValue, fire)
			value = ClampNumber(newValue, minValue, maxValue, minValue)
			fill.Size = UDim2.new((value - minValue) / (maxValue - minValue), 0, 1, 0)
			if fire then
				Forge.Guard(options.Callback, value)
			end
			return api
		end,
		Get = function()
			return value
		end,
		Instance = row,
		Bar = bar
	}
	return api
end

function Tab:CreateRadio(options)
	options = options or {}
	local theme = self:GetTheme()
	local group = options.Group or {}
	local value = options.Default
	local callback = options.Callback or function() end
	local row = self:_Row(options.Title, options.Description, (options.Options and #options.Options or 1) * 34 + 38)
	for index, item in ipairs(options.Options or {}) do
		local button = Forge.Make("TextButton", {
			Name = "Radio_" .. tostring(index),
			Size = UDim2.new(1, 0, 0, 30),
			BackgroundColor3 = value == item and theme.SurfaceActive or theme.Surface,
			Text = "",
			AutoButtonColor = false,
			LayoutOrder = index,
			Parent = row,
			Skin = {BackgroundColor3 = value == item and "SurfaceActive" or "Surface"}
		}, {
			AddCorner(nil, 7),
			AddPadding(9, 9, 0, 0),
			Forge.Make("Frame", {
				Name = "DotOuter",
				Size = UDim2.fromOffset(14, 14),
				BackgroundColor3 = value == item and theme.Accent or theme.Border,
			}, {
				AddCorner(nil, 99),
				Forge.Make("Frame", {
					Name = "Dot",
					Size = UDim2.fromOffset(6, 6),
					Position = UDim2.new(0.5, 0, 0.5, 0),
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundColor3 = Color3.new(1, 1, 1),
					BackgroundTransparency = value == item and 0 or 1
				}, {
					AddCorner(nil, 99)
				})
			}),
			Forge.Make("TextLabel", {
				Text = tostring(item),
				TextSize = 11,
				TextXAlignment = GetEnum("TextXAlignment", "Left"),
				TextColor3 = theme.Text,
				Size = UDim2.new(1, -26, 1, 0),
				FontFace = Font.fromEnum(Forge.Font),
				Skin = {TextColor3 = "Text"}
			})
		})
		button.MouseButton1Click:Connect(function()
			value = item
			for _, child in ipairs(row:GetChildren()) do
				if child:IsA("TextButton") then
					local selected = child == button
					child.BackgroundColor3 = selected and theme.SurfaceActive or theme.Surface
					local outer = child:FindFirstChild("DotOuter")
					if outer then
						outer.BackgroundColor3 = selected and theme.Accent or theme.Border
						local dot = outer:FindFirstChild("Dot")
						if dot then
							dot.BackgroundTransparency = selected and 0 or 1
						end
					end
				end
			end
			Forge.Guard(callback, value)
		end)
	end
	local api
	api = {
		Set = function(_, item, fire)
			value = item
			if fire then
				Forge.Guard(callback, value)
			end
			return api
		end,
		Get = function()
			return value
		end,
		Instance = row
	}
	return api
end

function Tab:CreateSearch(options)
	options = options or {}
	local theme = self:GetTheme()
	local callback = options.Callback or function() end
	local box = Forge.Make("TextBox", {
		Name = "Search",
		Size = UDim2.new(1, 0, 0, options.Height or 34),
		BackgroundColor3 = theme.Surface,
		Text = "",
		PlaceholderText = options.Placeholder or "Search...",
		TextSize = 11,
		TextColor3 = theme.Text,
		PlaceholderColor3 = theme.TextMuted,
		ClearTextOnFocus = false,
		LayoutOrder = #self.Widgets + 1,
		Parent = self.Section,
		FontFace = Font.fromEnum(Forge.Font),
		Skin = {BackgroundColor3 = "Surface", TextColor3 = "Text"}
	}, {
		AddCorner(nil, 8),
		AddStroke(nil, "Border", 0.55, 1),
		AddPadding(10, 10, 0, 0),
		Icons.Create("Search", theme.TextDim, 14)
	})
	box:GetPropertyChangedSignal("Text"):Connect(function()
		Forge.Guard(callback, box.Text)
	end)
	local api
	api = {
		Set = function(_, text, fire)
			box.Text = tostring(text or "")
			if fire then
				Forge.Guard(callback, box.Text)
			end
			return api
		end,
		Get = function()
			return box.Text
		end,
		Clear = function()
			box.Text = ""
			return api
		end,
		Instance = box
	}
	table.insert(self.Widgets, box)
	return api
end

function Tab:CreateTable(options)
	options = options or {}
	local theme = self:GetTheme()
	local columns = options.Columns or {}
	local rows = options.Rows or {}
	local height = options.Height or math.min(320, 42 + #rows * (options.RowHeight or 30))
	local frame = Forge.Make("ScrollingFrame", {
		Name = "Table",
		Size = UDim2.new(1, 0, 0, height),
		BackgroundColor3 = theme.Surface,
		CanvasSize = UDim2.new(),
		ScrollBarThickness = 3,
		ScrollBarImageColor3 = theme.Scrollbar,
		LayoutOrder = #self.Widgets + 1,
		Parent = self.Section,
		Skin = {BackgroundColor3 = "Surface", ScrollBarImageColor3 = "Scrollbar"}
	}, {
		AddCorner(nil, theme.RadiusSmall),
		AddStroke(nil, "Border", 0.55, 1),
		AddPadding(8, 8, 8, 8),
		Forge.Make("UIListLayout", {
			FillDirection = GetEnum("FillDirection", "Vertical"),
			Padding = UDim.new(0, 4),
			SortOrder = GetEnum("SortOrder", "LayoutOrder")
		})
	})
	local header = Forge.Make("Frame", {
		Name = "Header",
		Size = UDim2.new(1, 0, 0, options.HeaderHeight or 30),
		BackgroundColor3 = theme.SurfaceHover,
		LayoutOrder = 1,
		Parent = frame
	}, {
		AddCorner(nil, 6),
		AddPadding(8, 8, 0, 0),
		Forge.Make("UIListLayout", {
			FillDirection = GetEnum("FillDirection", "Horizontal"),
			SortOrder = GetEnum("SortOrder", "LayoutOrder")
		})
	})
	for index, column in ipairs(columns) do
		local width = column.Width or (1 / math.max(#columns, 1))
		Forge.Make("TextLabel", {
			Text = tostring(column.Title or column.Name or column),
			TextSize = 10,
			TextXAlignment = column.Alignment or GetEnum("TextXAlignment", "Left"),
			TextColor3 = theme.TextDim,
			Size = UDim2.new(width, -4, 1, 0),
			LayoutOrder = index,
			FontFace = Font.fromEnum(Forge.Font),
			Skin = {TextColor3 = "TextDim"},
			Parent = header
		})
	end
	for rowIndex, rowData in ipairs(rows) do
		local row = Forge.Make("Frame", {
			Name = "Row_" .. tostring(rowIndex),
			Size = UDim2.new(1, 0, 0, options.RowHeight or 30),
			BackgroundColor3 = rowIndex % 2 == 0 and theme.SurfaceHover or theme.Surface,
			LayoutOrder = rowIndex + 1,
			Parent = frame,
			Skin = {BackgroundColor3 = rowIndex % 2 == 0 and "SurfaceHover" or "Surface"}
		}, {
			AddCorner(nil, 5),
			AddPadding(8, 8, 0, 0),
			Forge.Make("UIListLayout", {
				FillDirection = GetEnum("FillDirection", "Horizontal"),
				SortOrder = GetEnum("SortOrder", "LayoutOrder")
			})
		})
		for columnIndex, column in ipairs(columns) do
			local width = column.Width or (1 / math.max(#columns, 1))
			local key = column.Key or column.Name or column.Title or columnIndex
			local value = rowData[key]
			if value == nil then
				value = rowData[columnIndex]
			end
			Forge.Make("TextLabel", {
				Text = tostring(value or ""),
				TextSize = 10,
				TextXAlignment = column.Alignment or GetEnum("TextXAlignment", "Left"),
				TextColor3 = theme.Text,
				Size = UDim2.new(width, -4, 1, 0),
				LayoutOrder = columnIndex,
				FontFace = Font.fromEnum(Forge.Font),
				Skin = {TextColor3 = "Text"},
				Parent = row
			})
		end
	end
	table.insert(self.Widgets, frame)
	local api = {
		Instance = frame,
		Refresh = function(_, newRows)
			for _, child in ipairs(frame:GetChildren()) do
				if child:IsA("Frame") and child.Name ~= "Header" then
					child:Destroy()
				end
			end
			for rowIndex, rowData in ipairs(newRows or {}) do
				local row = Forge.Make("Frame", {
					Name = "Row_" .. tostring(rowIndex),
					Size = UDim2.new(1, 0, 0, options.RowHeight or 30),
					BackgroundColor3 = rowIndex % 2 == 0 and theme.SurfaceHover or theme.Surface,
					LayoutOrder = rowIndex + 1,
					Parent = frame,
					Skin = {BackgroundColor3 = rowIndex % 2 == 0 and "SurfaceHover" or "Surface"}
				}, {
					AddCorner(nil, 5),
					AddPadding(8, 8, 0, 0),
					Forge.Make("UIListLayout", {
						FillDirection = GetEnum("FillDirection", "Horizontal"),
						SortOrder = GetEnum("SortOrder", "LayoutOrder")
					})
				})
				for columnIndex, column in ipairs(columns) do
					local width = column.Width or (1 / math.max(#columns, 1))
					local key = column.Key or column.Name or column.Title or columnIndex
					local cellValue = rowData[key]
					if cellValue == nil then
						cellValue = rowData[columnIndex]
					end
					Forge.Make("TextLabel", {
						Text = tostring(cellValue or ""),
						TextSize = 10,
						TextXAlignment = column.Alignment or GetEnum("TextXAlignment", "Left"),
						TextColor3 = theme.Text,
						Size = UDim2.new(width, -4, 1, 0),
						LayoutOrder = columnIndex,
						FontFace = Font.fromEnum(Forge.Font),
						Skin = {TextColor3 = "Text"},
						Parent = row
					})
				end
			end
			return api
		end
	}
end

function Tab:CreateColorSwatch(options)
	return self:CreateColorPicker(options)
end

function Tab:CreateAction(options)
	return self:CreateButton(options)
end

function Tab:FindWidget(name)
	for _, widget in ipairs(self.Widgets) do
		if widget.Name == name then
			return widget
		end
		if widget:FindFirstChild(name) then
			return widget:FindFirstChild(name)
		end
	end
	return nil
end

local Window = {}
Window.__index = Window

function Window.new(voidUI, config)
	config = config or {}
	local self = setmetatable({}, Window)
	self.VoidUI = voidUI
	self.Title = config.Title or config.Name or "VoidUI"
	self.Icon = config.Icon or "Void"
	self.Subtitle = config.Subtitle or ""
	self.Size = config.Size or UDim2.fromOffset(760, 500)
	self.Position = config.Position or UDim2.fromScale(0.5, 0.5)
	self.Resizable = config.Resizable ~= false
	self.Draggable = config.Draggable ~= false
	self.Minimized = false
	self.Maximized = false
	self.Closed = false
	self.Visible = true
	self.Tabs = {}
	self.ActiveTab = nil
	self.Notifications = {}
	self.Connections = {}
	self.ZIndex = config.ZIndex or 100
	self.MinSize = config.MinSize or Vector2.new(420, 300)
	self.MaxSize = config.MaxSize or Vector2.new(1600, 1000)
	self.Scale = config.Scale or 1
	self._restoreSize = self.Size
	self._restorePosition = self.Position
	self._layoutMode = config.LayoutMode or "Sidebar"
	self:_Build()
	self:_BindGlobal()
	return self
end

function Window:GetTheme()
	return self.VoidUI.Themes[self.VoidUI.CurrentTheme] or self.VoidUI.Themes.Default
end

function Window:_Build()
	local theme = self:GetTheme()
	local windowsFolder = self.VoidUI.ScreenGui:FindFirstChild("Windows")
	local main = Forge.Make("Frame", {
		Name = "Window",
		BackgroundColor3 = theme.Background,
		Size = self.Size,
		Position = self.Position,
		AnchorPoint = Vector2.new(0.5, 0.5),
		ZIndex = self.ZIndex,
		ClipsDescendants = true,
		Parent = windowsFolder,
		Skin = {BackgroundColor3 = "Background"}
	}, {
		AddCorner(nil, theme.RadiusLarge),
		AddStroke(nil, "Border", 0.15, 1),
		Forge.Make("Frame", {
			Name = "TopGlow",
			Size = UDim2.new(1, 0, 0, 2),
			BackgroundColor3 = theme.Accent,
			ZIndex = self.ZIndex + 8,
			Skin = {BackgroundColor3 = "Accent"}
		})
	})
	local header = Forge.Make("Frame", {
		Name = "Header",
		BackgroundColor3 = theme.BackgroundElevated,
		Size = UDim2.new(1, 0, 0, theme.HeaderHeight),
		ZIndex = self.ZIndex + 1,
		Parent = main,
		Skin = {BackgroundColor3 = "BackgroundElevated"}
	}, {
		AddCorner(nil, theme.RadiusLarge)
	})
	local headerInner = Forge.Make("Frame", {
		Name = "HeaderInner",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		ZIndex = self.ZIndex + 2,
		Parent = header
	}, {
		AddPadding(16, 12, 0, 0),
		Forge.Make("UIListLayout", {
			FillDirection = GetEnum("FillDirection", "Horizontal"),
			VerticalAlignment = GetEnum("VerticalAlignment", "Center"),
			Padding = UDim.new(0, 12),
			SortOrder = GetEnum("SortOrder", "LayoutOrder")
		})
	})
	local iconFrame = Icons.Create(self.Icon, theme.Accent, 21)
	iconFrame.LayoutOrder = 1
	iconFrame.Parent = headerInner
	local titleBlock = Forge.Make("Frame", {
		Name = "TitleBlock",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -330, 1, 0),
		LayoutOrder = 2,
		ZIndex = self.ZIndex + 2,
		Parent = headerInner
	}, {
		Forge.Make("UIListLayout", {
			FillDirection = GetEnum("FillDirection", "Vertical"),
			VerticalAlignment = GetEnum("VerticalAlignment", "Center"),
			Padding = UDim.new(0, 0)
		})
	})
	Forge.Make("TextLabel", {
		Name = "Title",
		Text = self.Title,
		TextSize = 15,
		TextXAlignment = GetEnum("TextXAlignment", "Left"),
		TextColor3 = theme.Text,
		Size = UDim2.new(1, 0, 0, 20),
		FontFace = Font.fromEnum(Forge.Font),
		Skin = {TextColor3 = "Text"},
		Parent = titleBlock
	})
	Forge.Make("TextLabel", {
		Name = "Subtitle",
		Text = self.Subtitle,
		TextSize = 10,
		TextXAlignment = GetEnum("TextXAlignment", "Left"),
		TextColor3 = theme.TextDim,
		Visible = self.Subtitle ~= "",
		Size = UDim2.new(1, 0, 0, 14),
		FontFace = Font.fromEnum(Forge.Font),
		Skin = {TextColor3 = "TextDim"},
		Parent = titleBlock
	})
	local searchFrame = Forge.Make("Frame", {
		Name = "HeaderSearch",
		Size = UDim2.fromOffset(170, 32),
		BackgroundColor3 = theme.Surface,
		LayoutOrder = 3,
		ZIndex = self.ZIndex + 2,
		Parent = headerInner,
		Skin = {BackgroundColor3 = "Surface"}
	}, {
		AddCorner(nil, 8),
		AddStroke(nil, "Border", 0.6, 1),
		Icons.Create("Search", theme.TextDim, 13),
		AddPadding(30, 8, 0, 0)
	})
	local searchBox = Forge.Make("TextBox", {
		Name = "Search",
		Size = UDim2.new(1, -38, 1, 0),
		Position = UDim2.new(0, 34, 0, 0),
		BackgroundTransparency = 1,
		Text = "",
		PlaceholderText = "Search tabs...",
		TextSize = 10,
		TextColor3 = theme.Text,
		PlaceholderColor3 = theme.TextMuted,
		ClearTextOnFocus = false,
		FontFace = Font.fromEnum(Forge.Font),
		Skin = {TextColor3 = "Text"},
		Parent = searchFrame
	})
	local controls = Forge.Make("Frame", {
		Name = "Controls",
		BackgroundTransparency = 1,
		Size = UDim2.fromOffset(92, 40),
		LayoutOrder = 4,
		ZIndex = self.ZIndex + 3,
		Parent = headerInner
	}, {
		Forge.Make("UIListLayout", {
			FillDirection = GetEnum("FillDirection", "Horizontal"),
			Padding = UDim.new(0, 5),
			HorizontalAlignment = GetEnum("HorizontalAlignment", "Right"),
			VerticalAlignment = GetEnum("VerticalAlignment", "Center")
		})
	})
	self:_CreateControlButton(controls, "Minus", function() self:ToggleMinimize() end, theme.TextDim)
	self:_CreateControlButton(controls, "Square", function() self:ToggleMaximize() end, theme.TextDim)
	self:_CreateControlButton(controls, "Close", function() self:Close() end, theme.Danger)
	local body = Forge.Make("Frame", {
		Name = "Body",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, -theme.HeaderHeight),
		Position = UDim2.fromOffset(0, theme.HeaderHeight),
		ZIndex = self.ZIndex + 1,
		Parent = main
	})
	local sidebar = Forge.Make("Frame", {
		Name = "Sidebar",
		BackgroundColor3 = theme.Surface,
		Size = UDim2.new(0, theme.SidebarWidth, 1, 0),
		ZIndex = self.ZIndex + 2,
		Parent = body,
		Skin = {BackgroundColor3 = "Surface"}
	}, {
		AddStroke(nil, "Border", 0.75, 1),
		AddPadding(8, 8, 10, 10)
	})
	local sidebarList = Forge.Make("UIListLayout", {
		FillDirection = GetEnum("FillDirection", "Vertical"),
		Padding = UDim.new(0, 5),
		SortOrder = GetEnum("SortOrder", "LayoutOrder"),
		Parent = sidebar
	})
	local navTitle = Forge.Make("TextLabel", {
		Name = "NavLabel",
		Text = self._layoutMode == "Sidebar" and "Navigation" or "Tabs",
		TextSize = 9,
		TextXAlignment = GetEnum("TextXAlignment", "Left"),
		TextColor3 = theme.TextMuted,
		Size = UDim2.new(1, 0, 0, 24),
		LayoutOrder = 0,
		FontFace = Font.fromEnum(Forge.Font),
		Skin = {TextColor3 = "TextMuted"},
		Parent = sidebar
	})
	local content = Forge.Make("ScrollingFrame", {
		Name = "Content",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -theme.SidebarWidth, 1, 0),
		Position = UDim2.fromOffset(theme.SidebarWidth, 0),
		BorderSizePixel = 0,
		ZIndex = self.ZIndex + 2,
		ScrollBarThickness = 3,
		ScrollBarImageColor3 = theme.Scrollbar,
		CanvasSize = UDim2.new(),
		Parent = body,
		Skin = {ScrollBarImageColor3 = "Scrollbar"}
	})
	local overlay = Forge.Make("Frame", {
		Name = "InteractionOverlay",
		BackgroundTransparency = 1,
		Size = UDim2.fromOffset(20, 20),
		Position = UDim2.new(1, -20, 1, -20),
		AnchorPoint = Vector2.new(1, 1),
		ZIndex = self.ZIndex + 20,
		Parent = main,
		Visible = self.Resizable
	})
	local resizeHandle = Forge.Make("TextButton", {
		Name = "ResizeHandle",
		Size = UDim2.fromOffset(20, 20),
		BackgroundTransparency = 1,
		Text = "",
		AutoButtonColor = false,
		ZIndex = self.ZIndex + 20,
		Parent = overlay
	}, {
		Icons.Create("Maximize", theme.TextMuted, 12)
	})
	self.Main = main
	self.Header = header
	self.HeaderInner = headerInner
	self.TitleLabel = titleBlock:FindFirstChild("Title")
	self.SubtitleLabel = titleBlock:FindFirstChild("Subtitle")
	self.SearchBox = searchBox
	self.Body = body
	self.Sidebar = sidebar
	self.NavLabel = navTitle
	self.Content = content
	self.ResizeHandle = resizeHandle
	self.ScreenGui = self.VoidUI.ScreenGui
	self.NotifFolder = self.VoidUI.ScreenGui:FindFirstChild("Notifications")
	self.Overlays = self.VoidUI.Overlays
	self.CloseButton = nil
	self:_EnableDrag()
	self:_EnableResize()
	searchBox:GetPropertyChangedSignal("Text"):Connect(function()
		local query = string.lower(searchBox.Text)
		for _, tab in ipairs(self.Tabs) do
			local visible = query == "" or string.find(string.lower(tab.Title), query, 1, true) ~= nil
			tab.Button.Visible = visible or tab.Selected
		end
	end)
	main.InputBegan:Connect(function(input)
		if input.UserInputType == GetEnum("UserInputType", "MouseButton1") then
			self:BringToFront()
		end
	end)
end

function Window:_BindGlobal()
	local connection = UserInputService.InputBegan:Connect(function(input, processed)
		if processed then
			return
		end
		if self.Closed then
			return
		end
		if self._globalKey and input.KeyCode == self._globalKey then
			self:SetVisible(not self.Main.Visible)
		end
	end)
	table.insert(self.Connections, connection)
end

function Window:_CreateControlButton(parent, iconName, callback, color)
	local button = Forge.Make("TextButton", {
		Name = iconName,
		Size = UDim2.fromOffset(28, 28),
		BackgroundTransparency = 1,
		Text = "",
		AutoButtonColor = false,
		Parent = parent
	}, {
		AddCorner(nil, 7),
		Icons.Create(iconName, color, 14)
	})
	button.MouseButton1Click:Connect(function()
		Forge.Guard(callback)
	end)
	button.MouseEnter:Connect(function()
		TweenPlay(button, 0.1, {BackgroundTransparency = 0.86, BackgroundColor3 = color})
	end)
	button.MouseLeave:Connect(function()
		TweenPlay(button, 0.1, {BackgroundTransparency = 1})
	end)
	if iconName == "Close" then
		self.CloseButton = button
	end
	return button
end

function Window:_EnableDrag()
	if not self.Draggable then
		return
	end
	local dragging = false
	local dragStart
	local startPos
	self.Header.InputBegan:Connect(function(input)
		if not IsPress(input) then
			return
		end
		if self.SearchBox and PointIn(input, self.SearchBox) then
			return
		end
		dragging = true
		dragStart = input.Position
		startPos = self.Main.Position
	end)
	UserInputService.InputChanged:Connect(function(input)
		if not dragging or not IsMove(input) then
			return
		end
		local delta = input.Position - dragStart
		self.Main.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
	end)
	UserInputService.InputEnded:Connect(function(input)
		if IsPress(input) then
			dragging = false
		end
	end)
end

function Window:_EnableResize()
	if not self.Resizable then
		return
	end
	local resizing = false
	local startSize
	local startMouse
	self.ResizeHandle.InputBegan:Connect(function(input)
		if not IsPress(input) then
			return
		end
		resizing = true
		startSize = self.Main.AbsoluteSize
		startMouse = input.Position
	end)
	UserInputService.InputChanged:Connect(function(input)
		if not resizing or not IsMove(input) then
			return
		end
		local delta = input.Position - startMouse
		local width = math.clamp(startSize.X + delta.X, self.MinSize.X, self.MaxSize.X)
		local height = math.clamp(startSize.Y + delta.Y, self.MinSize.Y, self.MaxSize.Y)
		self.Main.Size = UDim2.fromOffset(width, height)
	end)
	UserInputService.InputEnded:Connect(function(input)
		if IsPress(input) then
			resizing = false
		end
	end)
end

function Window:BringToFront()
	self.ZIndex += 10
	self.Main.ZIndex = self.ZIndex
	for _, descendant in ipairs(self.Main:GetDescendants()) do
		if descendant:IsA("GuiObject") then
			descendant.ZIndex += 10
		end
	end
	return self
end

function Window:CreateTab(options)
	options = options or {}
	local tab = Tab.new(self, options)
	table.insert(self.Tabs, tab)
	if not self.ActiveTab then
		self:SelectTab(tab)
	end
	return tab
end

function Window:SelectTab(tab)
	if not tab or tab.Disabled then
		return self
	end
	if self.ActiveTab and self.ActiveTab ~= tab then
		self.ActiveTab:Deselect()
	end
	self.ActiveTab = tab
	tab:Select()
	return self
end

function Window:GetTab(name)
	for _, tab in ipairs(self.Tabs) do
		if tab.Title == name then
			return tab
		end
	end
	return nil
end

function Window:SetTitle(title)
	self.Title = tostring(title)
	if self.TitleLabel then
		self.TitleLabel.Text = self.Title
	end
	return self
end

function Window:SetSubtitle(subtitle)
	self.Subtitle = tostring(subtitle or "")
	if self.SubtitleLabel then
		self.SubtitleLabel.Text = self.Subtitle
		self.SubtitleLabel.Visible = self.Subtitle ~= ""
	end
	return self
end

function Window:SetIcon(icon)
	self.Icon = icon
	local iconLabel = self.HeaderInner and self.HeaderInner:FindFirstChild("Icon")
	if iconLabel then
		iconLabel.Text = Glyphs[icon] or Glyphs.Void
	end
	return self
end

function Window:SetVisible(visible)
	self.Visible = not not visible
	self.Main.Visible = self.Visible
	return self
end

function Window:Toggle()
	return self:SetVisible(not self.Main.Visible)
end

function Window:SetPosition(position)
	self.Main.Position = position
	self.Position = position
	return self
end

function Window:SetSize(size)
	self.Main.Size = size
	self.Size = size
	return self
end

function Window:ToggleMinimize()
	self.Minimized = not self.Minimized
	if self.Minimized then
		self._restoreSize = self.Main.Size
		self.Body.Visible = false
		self.Main.Size = UDim2.new(self.Main.Size.X.Scale, self.Main.Size.X.Offset, 0, self:GetTheme().HeaderHeight)
	else
		self.Body.Visible = true
		self.Main.Size = self._restoreSize or self.Size
	end
	return self
end

function Window:ToggleMaximize()
	self.Maximized = not self.Maximized
	if self.Maximized then
		self._restoreSize = self.Main.Size
		self._restorePosition = self.Main.Position
		self.Main.Position = UDim2.fromScale(0.5, 0.5)
		self.Main.Size = UDim2.new(1, -30, 1, -30)
	else
		self.Main.Size = self._restoreSize or self.Size
		self.Main.Position = self._restorePosition or self.Position
	end
	return self
end

function Window:Close()
	self.Closed = true
	TweenPlay(self.Main, 0.18, {
		BackgroundTransparency = 1,
		Size = UDim2.new(self.Main.Size.X.Scale, self.Main.Size.X.Offset - 12, self.Main.Size.Y.Scale, self.Main.Size.Y.Offset - 12)
	})
	task.delay(0.2, function()
		if self.Main then
			self.Main.Visible = false
			self.Main.BackgroundTransparency = 0
		end
	end)
	return self
end

function Window:Open()
	self.Closed = false
	self.Main.Visible = true
	return self
end

function Window:Destroy()
	self.Closed = true
	for _, connection in ipairs(self.Connections) do
		pcall(function()
			connection:Disconnect()
		end)
	end
	self.Connections = {}
	for _, notification in ipairs(self.Notifications) do
		pcall(function()
			notification:Destroy()
		end)
	end
	self.Notifications = {}
	local index = table.find(self.VoidUI.Windows, self)
	if index then
		table.remove(self.VoidUI.Windows, index)
	end
	if self.Main then
		self.Main:Destroy()
	end
	return nil
end

function Window:SetKeybind(key)
	self._globalKey = key
	return self
end

function Window:SetSearchPlaceholder(text)
	if self.SearchBox then
		self.SearchBox.PlaceholderText = tostring(text or "Search tabs...")
	end
	return self
end

function Window:SetSidebarVisible(visible)
	self.Sidebar.Visible = visible
	local theme = self:GetTheme()
	local width = visible and theme.SidebarWidth or 0
	self.Content.Position = UDim2.fromOffset(width, 0)
	self.Content.Size = UDim2.new(1, -width, 1, 0)
	return self
end

function Window:ApplyTheme(theme)
	if not theme then
		return self
	end
	self:GetTheme()
	pcall(function()
		self.Main.BackgroundColor3 = Forge.Resolve("Background", theme) or self.Main.BackgroundColor3
		self.Header.BackgroundColor3 = Forge.Resolve("BackgroundElevated", theme) or self.Header.BackgroundColor3
		self.Sidebar.BackgroundColor3 = Forge.Resolve("Surface", theme) or self.Sidebar.BackgroundColor3
		self.ResizeHandle.TextColor3 = Forge.Resolve("TextMuted", theme) or self.ResizeHandle.TextColor3
		self.Main:FindFirstChild("TopGlow").BackgroundColor3 = Forge.Resolve("Accent", theme) or self.Main:FindFirstChild("TopGlow").BackgroundColor3
	end)
	return self
end

function Window:RefreshTheme()
	return self:ApplyTheme(self:GetTheme())
end

function Window:Notify(options)
	options = options or {}
	local theme = self:GetTheme()
	local kind = options.Type or "Info"
	local accent = theme.Info
	local icon = options.Icon or "Info"
	if kind == "Success" then
		accent = theme.Success
		icon = options.Icon or "Check"
	elseif kind == "Warning" then
		accent = theme.Warning
		icon = options.Icon or "Warning"
	elseif kind == "Error" or kind == "Danger" then
		accent = theme.Danger
		icon = options.Icon or "Danger"
	end
	local duration = tonumber(options.Duration) or 4
	local width = tonumber(options.Width) or 320
	local height = tonumber(options.Height) or 76
	local notification = Forge.Make("Frame", {
		Name = "Notification",
		BackgroundColor3 = theme.BackgroundElevated,
		Size = UDim2.fromOffset(width, height),
		AnchorPoint = Vector2.new(1, 0),
		ZIndex = 1000,
		Parent = self.NotifFolder,
		Skin = {BackgroundColor3 = "BackgroundElevated"}
	}, {
		AddCorner(nil, theme.Radius),
		AddStroke(nil, "Border", 0.2, 1),
		Forge.Make("Frame", {
			Name = "Accent",
			Size = UDim2.fromOffset(3, height - 18),
			Position = UDim2.fromOffset(9, 9),
			BackgroundColor3 = accent,
			Skin = {BackgroundColor3 = kind == "Success" and "Success" or kind == "Warning" and "Warning" or kind == "Error" and "Danger" or "Info"}
		}, {
			AddCorner(nil, 99)
		}),
		Icons.Create(icon, accent, 16),
		Forge.Make("TextLabel", {
			Name = "Title",
			Text = options.Title or "Notification",
			TextSize = 12,
			TextXAlignment = GetEnum("TextXAlignment", "Left"),
			TextColor3 = theme.Text,
			Size = UDim2.new(1, -60, 0, 20),
			Position = UDim2.fromOffset(44, 10),
			FontFace = Font.fromEnum(Forge.Font),
			Skin = {TextColor3 = "Text"}
		}),
		Forge.Make("TextLabel", {
			Name = "Description",
			Text = options.Description or options.Content or "",
			TextSize = 10,
			TextXAlignment = GetEnum("TextXAlignment", "Left"),
			TextYAlignment = GetEnum("TextYAlignment", "Top"),
			TextColor3 = theme.TextDim,
			Size = UDim2.new(1, -58, 0, height - 36),
			Position = UDim2.fromOffset(44, 31),
			TextWrapped = true,
			FontFace = Font.fromEnum(Forge.Font),
			Skin = {TextColor3 = "TextDim"}
		})
	})
	notification:FindFirstChild("Icon").Position = UDim2.fromOffset(14, 13)
	table.insert(self.Notifications, notification)
	local function reposition()
		local y = 10
		for index = #self.Notifications, 1, -1 do
			local current = self.Notifications[index]
			if current and current.Parent then
				current.Position = UDim2.new(1, -12, 0, y)
				y += current.AbsoluteSize.Y + 8
			end
		end
	end
	notification.Position = UDim2.new(1, width + 24, 0, 10)
	reposition()
	TweenPlay(notification, 0.24, {Position = UDim2.new(1, -12, 0, 10), BackgroundTransparency = 0})
	if options.OnClick then
		local clicker = Forge.Make("TextButton", {
			Name = "ClickArea",
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			Text = "",
			ZIndex = 1002,
			Parent = notification
		})
		clicker.MouseButton1Click:Connect(function()
			Forge.Guard(options.OnClick)
			local index = table.find(self.Notifications, notification)
			if index then
				table.remove(self.Notifications, index)
			end
			TweenPlay(notification, 0.18, {Position = UDim2.new(1, width + 24, 0, notification.Position.Y.Offset), BackgroundTransparency = 1})
			task.delay(0.2, function()
				notification:Destroy()
				reposition()
			end)
		end)
	end
	task.delay(duration, function()
		if not notification.Parent then
			return
		end
		local index = table.find(self.Notifications, notification)
		if index then
			table.remove(self.Notifications, index)
		end
		TweenPlay(notification, 0.18, {Position = UDim2.new(1, width + 24, 0, notification.Position.Y.Offset), BackgroundTransparency = 1})
		task.delay(0.2, function()
			if notification then
				notification:Destroy()
			end
			reposition()
		end)
	end)
	return notification
end

function Window:SetScale(scale)
	scale = tonumber(scale) or 1
	self.Scale = math.clamp(scale, 0.65, 2)
	if not self._uiScale then
		self._uiScale = Forge.Make("UIScale", {Scale = self.Scale, Parent = self.Main})
	else
		self._uiScale.Scale = self.Scale
	end
	return self
end

local function RegisterBuiltinAliases()
	Palette.Purple = Palette.Violet
	Palette.Blue = Palette.Midnight
	Palette.Green = Palette.Emerald
	Palette.Red = Palette.Crimson
	Palette.Pink = Palette.Rose
	Palette.Black = Palette.Mono
	Palette.Cyan = Palette.Ocean
	Palette.Grey = Palette.Slate
	Palette.Gray = Palette.Slate
end

RegisterBuiltinAliases()

VoidUI.Forge = Forge
VoidUI.Themes = Palette
VoidUI.ThemeFallbacks = ThemeFallbacks
VoidUI.Icon = Icons
VoidUI.Icons = Icons
VoidUI.Windows = {}
VoidUI.CurrentTheme = "Default"
VoidUI.Accent = Color3.fromHex(Palette.Default.Accent)
VoidUI.ScreenGui = nil
VoidUI.UIScaleObj = nil
VoidUI.UIScale = 1
VoidUI.OnThemeChange = nil
VoidUI.Overlays = nil
VoidUI.Config = {}

function VoidUI.GenerateGUID()
	local ok, guid = pcall(function()
		return HttpService:GenerateGUID(false)
	end)
	if ok and guid then
		return guid
	end
	return tostring(os.clock()) .. "_" .. tostring(math.random(100000, 999999))
end

function VoidUI:RegisterTheme(name, theme, base)
	if type(name) ~= "string" or name == "" or type(theme) ~= "table" then
		return false
	end
	local baseTheme = type(base) == "string" and Palette[base] or Palette.Default
	Palette[name] = MergeTable(baseTheme, theme)
	Palette[name].Name = name
	Forge.Themes = Palette
	return true
end

function VoidUI:RemoveTheme(name)
	if not Palette[name] then
		return false
	end
	if name == "Default" then
		return false
	end
	Palette[name] = nil
	return true
end

function VoidUI:GetTheme(name)
	return Palette[name or VoidUI.CurrentTheme]
end

function VoidUI:GetThemes()
	local names = {}
	for name in pairs(Palette) do
		table.insert(names, name)
	end
	table.sort(names)
	return names
end

function VoidUI:SetTheme(name)
	if type(name) ~= "string" or not Palette[name] then
		warn("[VoidUI] Theme not found:", name)
		return false
	end
	VoidUI.CurrentTheme = name
	VoidUI.Accent = Color(Palette[name].Accent, VoidUI.Accent)
	Forge.Apply(Palette[name])
	if VoidUI.OnThemeChange then
		Forge.Guard(VoidUI.OnThemeChange, Palette[name], name)
	end
	for _, window in ipairs(VoidUI.Windows) do
		if window and not window.Closed then
			window:ApplyTheme(Palette[name])
		end
	end
	return true
end

function VoidUI:SetAccent(color)
	local parsed = Color(color, nil)
	if not parsed then
		return false
	end
	VoidUI.Accent = parsed
	local theme = Palette[VoidUI.CurrentTheme]
	theme.Accent = parsed
	theme.AccentGlow = parsed
	Forge.Apply(theme)
	for _, window in ipairs(VoidUI.Windows) do
		if window and not window.Closed then
			window:ApplyTheme(theme)
		end
	end
	return true
end

function VoidUI:CreateWindow(options)
	options = options or {}
	local theme = Palette[options.Theme or VoidUI.CurrentTheme] or Palette.Default
	local defaults = UDim2.fromOffset(theme.WindowWidth or 760, theme.WindowHeight or 500)
	if not options.Size then
		options.Size = defaults
	end
	local window = Window.new(VoidUI, options)
	table.insert(VoidUI.Windows, window)
	return window
end

function VoidUI:Notify(options)
	options = options or {}
	local window = options.Window
	if type(window) == "table" and window.Notify then
		return window:Notify(options)
	end
	local first = VoidUI.Windows[1]
	if first and first.Notify then
		return first:Notify(options)
	end
	warn("[VoidUI] Notify: no window created yet")
	return nil
end

function VoidUI:DestroyAll()
	for index = #VoidUI.Windows, 1, -1 do
		local window = VoidUI.Windows[index]
		if window then
			window:Destroy()
		end
	end
	VoidUI.Windows = {}
	return VoidUI
end

function VoidUI:SetUIScale(scale)
	scale = tonumber(scale) or 1
	VoidUI.UIScale = math.clamp(scale, 0.65, 2)
	if VoidUI.UIScaleObj then
		VoidUI.UIScaleObj.Scale = VoidUI.UIScale
	end
	return VoidUI
end

function VoidUI:SetFont(fontEnum)
	Forge.SetFont(fontEnum)
	return VoidUI
end

function VoidUI:GetStats()
	local alive = 0
	for _, window in ipairs(VoidUI.Windows) do
		if window and not window.Closed then
			alive += 1
		end
	end
	return {
		Windows = #VoidUI.Windows,
		AliveWindows = alive,
		Theme = VoidUI.CurrentTheme,
		Version = VoidUI.Version,
		Themes = #VoidUI:GetThemes()
	}
end

function VoidUI.new(options)
	options = options or {}
	if not VoidUI.ScreenGui then
		local screenGui = Forge.Make("ScreenGui", {
			Name = options.GuiName or "VoidUI",
			Parent = GUIParent,
			IgnoreGuiInset = true,
			ZIndexBehavior = GetEnum("ZIndexBehavior", "Sibling"),
			DisplayOrder = options.DisplayOrder or 1000,
			ResetOnSpawn = false
		}, {
			Forge.Make("UIScale", {
				Scale = VoidUI.UIScale
			}),
			Forge.Make("Folder", {
				Name = "Windows"
			}),
			Forge.Make("Folder", {
				Name = "Notifications"
			}),
			Forge.Make("Folder", {
				Name = "Overlays"
			})
		})
		VoidUI.ScreenGui = screenGui
		VoidUI.UIScaleObj = screenGui:FindFirstChildOfClass("UIScale")
		VoidUI.Overlays = screenGui:FindFirstChild("Overlays")
		ProtectGui(screenGui)
	end
	if options.UIScale then
		VoidUI:SetUIScale(options.UIScale)
	end
	if options.Font then
		VoidUI:SetFont(options.Font)
	end
	VoidUI.Config = options
	VoidUI:SetTheme(options.Theme or VoidUI.CurrentTheme or "Default")
	if options.Accent then
		VoidUI:SetAccent(options.Accent)
	end
	return VoidUI
end

return VoidUI
