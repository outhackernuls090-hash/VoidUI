
local VoidUI = {}
VoidUI.Version = "4.0.0"

local cloneref = (cloneref or clonereference or function(i) return i end)

local RunService       = cloneref(game:GetService("RunService"))
local TweenService     = cloneref(game:GetService("TweenService"))
local UserInputService = cloneref(game:GetService("UserInputService"))
local Players          = cloneref(game:GetService("Players"))
local CoreGui         = cloneref(game:GetService("CoreGui"))

local ProtectGui = protectgui or (syn and syn.protect_gui) or function() end
local GUIParent  = (gethui and gethui()) or CoreGui or Players.LocalPlayer:WaitForChild("PlayerGui")

local RealEnum = Enum
local Enum = setmetatable({}, {
	__index = function(_, Category)
		local Cat = RealEnum[Category]
		if Cat == nil then
			return setmetatable({}, { __index = function() return nil end })
		end
		return setmetatable({}, { __index = function(_, Member)
			return Cat[Member]
		end })
	end,
})

local Forge = {
	Font = Enum.Font.Gotham,
	Theme = nil,
	Themes = nil,
	ThemeFallbacks = nil,
	Skins = {},
	ThemeHooks = {},
	Fonts = {},
}

Forge.Defaults = {
	ScreenGui = { ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling },
	CanvasGroup = { BorderSizePixel = 0, BackgroundColor3 = Color3.new(1, 1, 1) },
	Frame = { BorderSizePixel = 0, BackgroundColor3 = Color3.new(1, 1, 1) },
	TextLabel = {
		BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, Text = "",
		RichText = true, TextColor3 = Color3.new(1, 1, 1), TextSize = 14,
		FontFace = Font.fromEnum(Enum.Font.Gotham),
	},
	TextButton = {
		BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, Text = "",
		AutoButtonColor = false, TextColor3 = Color3.new(1, 1, 1), TextSize = 14,
		FontFace = Font.fromEnum(Enum.Font.Gotham),
	},
	TextBox = {
		BackgroundColor3 = Color3.new(1, 1, 1), BorderColor3 = Color3.new(0, 0, 0),
		ClearTextOnFocus = false, Text = "", TextColor3 = Color3.new(0, 0, 0),
		TextSize = 14, FontFace = Font.fromEnum(Enum.Font.Gotham),
	},
	ImageLabel = { BackgroundTransparency = 1, BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0 },
	ImageButton = { BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, AutoButtonColor = false },
	UIListLayout = { SortOrder = Enum.SortOrder.LayoutOrder },
	UIPadding = {
		PaddingLeft = UDim.new(0, 0), PaddingRight = UDim.new(0, 0),
		PaddingTop = UDim.new(0, 0), PaddingBottom = UDim.new(0, 0),
	},
	UIStroke = { Thickness = 1 },
	UICorner = { CornerRadius = UDim.new(0, 0) },
	ScrollingFrame = {
		ScrollBarImageTransparency = 1, BorderSizePixel = 0, BackgroundColor3 = Color3.new(1, 1, 1),
		AutomaticCanvasSize = Enum.AutomaticCanvasSize.Y, ScrollingDirection = Enum.ScrollingDirection.Y,
		VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Left,
	},
}

function Forge.Guard(Callback, ...)
	if type(Callback) ~= "function" then return end
	local ok, err = pcall(Callback, ...)
	if not ok then warn("[VoidUI] Callback error:", err) end
end

function Forge.Make(Name, Properties, Children)
	local Object = Instance.new(Name)

	for Property, Value in next, Forge.Defaults[Name] or {} do
		if Value ~= nil then Object[Property] = Value end
	end
	for Property, Value in next, Properties or {} do
		if Property ~= "Skin" and Value ~= nil then Object[Property] = Value end
	end
	for _, Child in next, Children or {} do
		if Child ~= nil then Child.Parent = Object end
	end

	if Properties and Properties.Skin then Forge.Tag(Object, Properties.Skin) end
	if Properties and Properties.FontFace then Forge.TrackFont(Object) end
	return Object
end

function Forge.TrackFont(Object)
	table.insert(Forge.Fonts, Object)
end

function Forge.SetFont(FontEnum)
	Forge.Font = FontEnum
	for _, Obj in next, Forge.Fonts do
		pcall(function() Obj.FontFace = Font.fromEnum(FontEnum) end)
	end
end

function Forge.Resolve(Property, Theme)
	local function read(prop, themeTable)
		local value = themeTable[prop]
		if value == nil then return nil end
		if type(value) == "string" and string.sub(value, 1, 1) == "#" then return Color3.fromHex(value) end
		if type(value) == "Color3" or type(value) == "number" then return value end
		if type(value) == "table" and value.Color and value.Transparency then return value end
		if type(value) == "function" then return value(themeTable) end
		return value
	end

	local value = read(Property, Theme)
	if value ~= nil then
		if type(value) == "string" and string.sub(value, 1, 1) ~= "#" then
			local referenced = Forge.Resolve(value, Theme)
			if referenced ~= nil then return referenced end
		else
			return value
		end
	end

	local fallback = Forge.ThemeFallbacks and Forge.ThemeFallbacks[Property]
	if fallback ~= nil then
		if type(fallback) == "string" and string.sub(fallback, 1, 1) ~= "#" then
			return Forge.Resolve(fallback, Theme)
		else
			return read(Property, { [Property] = fallback })
		end
	end

	value = read(Property, Forge.Themes and Forge.Themes["Default"] or {})
	if value ~= nil then
		if type(value) == "string" and string.sub(value, 1, 1) ~= "#" then
			local referenced = Forge.Resolve(value, Forge.Themes and Forge.Themes["Default"] or {})
			if referenced ~= nil then return referenced end
		else
			return value
		end
	end
	return nil
end

function Forge.Tag(Object, Properties, skipUpdate)
	if Forge.Skins[Object] then
		for prop, value in pairs(Properties) do Forge.Skins[Object].Properties[prop] = value end
	else
		Forge.Skins[Object] = { Object = Object, Properties = Properties }
	end
	if not skipUpdate then Forge.Refresh(Object, false) end
	return Object
end

function Forge.Refresh(Object, ThemeChanged)
	local Theme = Forge.Theme
	if not Theme then return end
	if Object then
		local data = Forge.Skins[Object]
		if not data then return end
		for prop, value in pairs(data.Properties) do
			local ThemeValue = Forge.Resolve(value, Theme)
			if ThemeValue ~= nil then
				pcall(function() Object[prop] = ThemeValue end)
			end
		end
		return
	end
	for _, data in pairs(Forge.Skins) do
		for prop, value in pairs(data.Properties) do
			local ThemeValue = Forge.Resolve(value, Theme)
			if ThemeValue ~= nil then
				pcall(function() data.Object[prop] = ThemeValue end)
			end
		end
	end
end

function Forge.Apply(Theme)
	local PreviousTheme = Forge.Theme
	Forge.Theme = Theme
	Forge.Refresh(nil, true)
	for _, Callback in next, Forge.ThemeHooks do Forge.Guard(Callback, Theme, PreviousTheme) end
end

function Forge.OnTheme(Callback)
	table.insert(Forge.ThemeHooks, Callback)
end

function Forge.Tween(Object, Time, Properties, ...)
	return TweenService:Create(Object, TweenInfo.new(Time, ...), Properties)
end

function Forge.Spring(Object, Property, Target, Options)
	Options = Options or {}
	local Tween = Forge.Tween(Object, Options.Duration or 0.3, { [Property] = Target }, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	Tween:Play()
	return Tween
end

local Themes = {
	Default = {
		Name = "Default", Accent = "#7CA2FF", AccentGlow = "#9DB8FF",
		Background = "#0E1116", BackgroundElevated = "#161B22", Surface = "#1C2230", SurfaceHover = "#232B3B",
		Border = "#2A3344", Text = "#E6EAF2", TextDim = "#8A93A6", TextMuted = "#5A6377",
		Success = "#3FB950", Warning = "#D29922", Danger = "#F85149", Scrollbar = "#2A3344",
		Radius = 12, RadiusSmall = 8, RadiusLarge = 18, HeaderHeight = 52, SidebarWidth = 200,
		WindowWidth = 620, WindowHeight = 440,
	},
	Midnight = {
		Name = "Midnight", Accent = "#5B8DEF", AccentGlow = "#7AA5F5",
		Background = "#070A12", BackgroundElevated = "#0D1320", Surface = "#121A2B", SurfaceHover = "#1A2540",
		Border = "#1E2A44", Text = "#DCE6F5", TextDim = "#7E8AA6", TextMuted = "#4A5572",
		Success = "#3FB950", Warning = "#D29922", Danger = "#F85149", Scrollbar = "#1E2A44",
		Radius = 12, RadiusSmall = 8, RadiusLarge = 18, HeaderHeight = 52, SidebarWidth = 200,
		WindowWidth = 620, WindowHeight = 440,
	},
	Nebula = {
		Name = "Nebula", Accent = "#B57CFF", AccentGlow = "#C99FFF",
		Background = "#0C0A16", BackgroundElevated = "#15122A", Surface = "#1E1A38", SurfaceHover = "#2A2450",
		Border = "#2E2850", Text = "#ECE6F7", TextDim = "#9085B0", TextMuted = "#5A5278",
		Success = "#3FB950", Warning = "#D29922", Danger = "#F85149", Scrollbar = "#2E2850",
		Radius = 14, RadiusSmall = 10, RadiusLarge = 20, HeaderHeight = 54, SidebarWidth = 210,
		WindowWidth = 640, WindowHeight = 460,
	},
	Crimson = {
		Name = "Crimson", Accent = "#FF5C7A", AccentGlow = "#FF85A0",
		Background = "#140A0E", BackgroundElevated = "#20121A", Surface = "#2A1620", SurfaceHover = "#3A1E2C",
		Border = "#3E2230", Text = "#F7E6EC", TextDim = "#B08A98", TextMuted = "#785060",
		Success = "#3FB950", Warning = "#D29922", Danger = "#FF5C7A", Scrollbar = "#3E2230",
		Radius = 12, RadiusSmall = 8, RadiusLarge = 18, HeaderHeight = 52, SidebarWidth = 200,
		WindowWidth = 620, WindowHeight = 440,
	},
	Emerald = {
		Name = "Emerald", Accent = "#34D399", AccentGlow = "#6EE7B7",
		Background = "#07120E", BackgroundElevated = "#0E201A", Surface = "#13291F", SurfaceHover = "#1B3A2C",
		Border = "#1E3A2C", Text = "#E2F5EC", TextDim = "#84A89A", TextMuted = "#4E6E60",
		Success = "#34D399", Warning = "#D29922", Danger = "#F85149", Scrollbar = "#1E3A2C",
		Radius = 12, RadiusSmall = 8, RadiusLarge = 18, HeaderHeight = 52, SidebarWidth = 200,
		WindowWidth = 620, WindowHeight = 440,
	},
	Amber = {
		Name = "Amber", Accent = "#FFB454", AccentGlow = "#FFD08A",
		Background = "#16110A", BackgroundElevated = "#221A10", Surface = "#2C2114", SurfaceHover = "#3A2C1A",
		Border = "#3E2F1C", Text = "#F7EEDF", TextDim = "#B0A088", TextMuted = "#786A52",
		Success = "#3FB950", Warning = "#FFB454", Danger = "#F85149", Scrollbar = "#3E2F1C",
		Radius = 12, RadiusSmall = 8, RadiusLarge = 18, HeaderHeight = 52, SidebarWidth = 200,
		WindowWidth = 620, WindowHeight = 440,
	},
	Ocean = {
		Name = "Ocean", Accent = "#22D3EE", AccentGlow = "#67E8F9",
		Background = "#06141A", BackgroundElevated = "#0C2029", Surface = "#102B36", SurfaceHover = "#163B49",
		Border = "#1A3D4A", Text = "#DDF3F8", TextDim = "#7FA8B2", TextMuted = "#4A6E78",
		Success = "#34D399", Warning = "#D29922", Danger = "#F85149", Scrollbar = "#1A3D4A",
		Radius = 12, RadiusSmall = 8, RadiusLarge = 18, HeaderHeight = 52, SidebarWidth = 200,
		WindowWidth = 620, WindowHeight = 440,
	},
	Rose = {
		Name = "Rose", Accent = "#FB7185", AccentGlow = "#FDA4AF",
		Background = "#1A0E14", BackgroundElevated = "#26141E", Surface = "#331A28", SurfaceHover = "#45243A",
		Border = "#4A2438", Text = "#FBE6EE", TextDim = "#B08A98", TextMuted = "#785060",
		Success = "#3FB950", Warning = "#D29922", Danger = "#FB7185", Scrollbar = "#4A2438",
		Radius = 14, RadiusSmall = 10, RadiusLarge = 20, HeaderHeight = 54, SidebarWidth = 210,
		WindowWidth = 640, WindowHeight = 460,
	},
	Frost = {
		Name = "Frost", Accent = "#A5B4FC", AccentGlow = "#C7D2FE",
		Background = "#0B0F1A", BackgroundElevated = "#121829", Surface = "#1A2238", SurfaceHover = "#24304E",
		Border = "#28324E", Text = "#E8ECF8", TextDim = "#8A93B2", TextMuted = "#5A6378",
		Success = "#3FB950", Warning = "#D29922", Danger = "#F85149", Scrollbar = "#28324E",
		Radius = 12, RadiusSmall = 8, RadiusLarge = 18, HeaderHeight = 52, SidebarWidth = 200,
		WindowWidth = 620, WindowHeight = 440,
	},
	Mono = {
		Name = "Mono", Accent = "#E6EAF2", AccentGlow = "#FFFFFF",
		Background = "#0A0A0A", BackgroundElevated = "#141414", Surface = "#1C1C1C", SurfaceHover = "#262626",
		Border = "#2E2E2E", Text = "#F5F5F5", TextDim = "#A3A3A3", TextMuted = "#6B6B6B",
		Success = "#A3E635", Warning = "#FACC15", Danger = "#F87171", Scrollbar = "#2E2E2E",
		Radius = 10, RadiusSmall = 6, RadiusLarge = 16, HeaderHeight = 50, SidebarWidth = 200,
		WindowWidth = 600, WindowHeight = 420,
	},
}

local ThemeFallbacks = {
	AccentGlow = "Accent",
	BackgroundElevated = "Background",
	SurfaceHover = "Surface",
	TextDim = "Text",
	TextMuted = "TextDim",
	Border = "Surface",
	Scrollbar = "Border",
	RadiusSmall = "Radius",
	RadiusLarge = "Radius",
}

Forge.Themes = Themes
Forge.ThemeFallbacks = ThemeFallbacks
Forge.Theme = Themes[VoidUI.CurrentTheme or "Default"]

local Icons = {}
Icons.__index = Icons

local Glyphs = {
	Home = "⌂", Settings = "⚙", Search = "⌕", Close = "✕", Check = "✓", CheckCircle = "✔",
	ChevronDown = "▾", ChevronUp = "▴", ChevronLeft = "◂", ChevronRight = "▸",
	ArrowRight = "→", ArrowLeft = "←", ArrowUp = "↑", ArrowDown = "↓",
	Plus = "＋", Minus = "－", Star = "★", Heart = "♥", Bell = "🔔", User = "👤", Users = "👥",
	Lock = "🔒", Unlock = "🔓", Eye = "👁", EyeOff = "🚫", Trash = "🗑", Edit = "✎", Copy = "⧉",
	Download = "⤓", Upload = "⤒", Refresh = "↻", Play = "▶", Pause = "⏸", Stop = "⏹",
	Volume = "🔊", Mute = "🔇", Info = "ℹ", Warning = "⚠", Error = "⛔", Success = "✅", Danger = "⛔",
	Sword = "⚔", Shield = "🛡", Fire = "🔥", Zap = "⚡", Gear = "⚙", Folder = "📁", File = "📄",
	Image = "🖼", Code = "⟨⟩", Terminal = "▷", Globe = "🌐", Clock = "🕘", Key = "🔑", Flag = "⚑",
	Bookmark = "🔖", Tag = "🏷", Link = "🔗", Mail = "✉", Phone = "☎", Camera = "📷", Music = "♪",
	Video = "🎬", Chart = "📊", Grid = "▦", List = "☰", Menu = "☰", Sun = "☀", Moon = "🌙", Cloud = "☁",
	Bolt = "⚡", Diamond = "◆", Circle = "●", Square = "■", Cross = "✕", Void = "◈", Sparkles = "✦",
	Command = "⌘", Filter = "⏷", Maximize = "▢", Minimize = "▁", Pin = "📌", Wrench = "🔧", Hammer = "🔨",
	Rocket = "🚀", Target = "◎", Compass = "🧭", Layers = "☰", Box = "▣", Package = "📦", Cpu = "🖥",
	Database = "🗄", Gauge = "📈", Activity = "📈", Wifi = "📶", Battery = "🔋", Power = "⏻", Logout = "⏻",
	Login = "⏻", Help = "？", Question = "？", Exclamation = "！", PlusCircle = "⊕", MinusCircle = "⊖",
	Dot = "•", Bullet = "•", Record = "⏺", Send = "➤", Paperclip = "📎", Scissors = "✂", Printer = "🖨",
	Calendar = "📅", Map = "🗺", Location = "📍", Navigation = "🧭", Book = "📖", Lightbulb = "💡",
	Droplet = "💧", Wind = "🌬", Snow = "❄", Leaf = "🍃", Tree = "🌳", Flower = "❀", Crown = "👑",
	Trophy = "🏆", Medal = "🏅", Gem = "💎", Coins = "🪙", Credit = "💳", Cart = "🛒", Bag = "👜",
	Gift = "🎁", Smile = "☺", Meh = "😐", Sad = "☹", Angry = "😠", Cool = "😎", Ghost = "👻", Robot = "🤖",
	Alien = "👽", Bug = "🐛", Skull = "💀", Hand = "✋", Pointer = "👆", Grab = "✊", ThumbsUp = "👍",
	ThumbsDown = "👎",
}

function Icons.Create(Name, Color, Size)
	local Glyph = Glyphs[Name] or Glyphs.Void
	return Forge.Make("TextLabel", {
		Text = Glyph,
		TextSize = Size or 18,
		TextColor3 = Color or Color3.fromHex("#E6EAF2"),
		TextXAlignment = Enum.TextXAlignment.Center,
		TextYAlignment = Enum.TextYAlignment.Center,
		BackgroundTransparency = 1,
		Size = UDim2.fromOffset(Size or 18, Size or 18),
		FontFace = Font.fromEnum(Enum.Font.Gotham),
		Skin = { TextColor3 = "Text" },
	})
end

function Icons.Has(Name) return Glyphs[Name] ~= nil end
function Icons.Set(Name, Glyph) Glyphs[Name] = Glyph end

local Tab = {}
Tab.__index = Tab

function Tab.new(Window, Options)
	Options = Options or {}
	local self = setmetatable({}, Tab)
	self.Window = Window
	self.Title = Options.Title or "Tab"
	self.Icon = Options.Icon or "Circle"
	self.Selected = false
	self.Widgets = {}

	local Theme = Window.VoidUI.Themes[Window.VoidUI.CurrentTheme]

	local Button = Forge.Make("TextButton", {
		Name = "TabButton",
		Size = UDim2.new(1, -16, 0, 36),
		BackgroundTransparency = 1,
		Text = "",
		Parent = Window.Sidebar,
	}, {
		Forge.Make("UICorner", { CornerRadius = UDim.new(0, 8) }),
		Forge.Make("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 10),
			VerticalAlignment = Enum.VerticalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder,
		}),
		Forge.Make("UIPadding", { PaddingLeft = UDim.new(0, 12) }),
		Icons.Create(self.Icon, Theme.TextDim, 18),
		Forge.Make("TextLabel", {
			Text = self.Title, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left,
			TextColor3 = Theme.TextDim, Size = UDim2.new(1, -40, 1, 0),
			FontFace = Font.fromEnum(Enum.Font.Gotham), Skin = { TextColor3 = "TextDim" },
		}),
	})
	Button.MouseButton1Click:Connect(function() Window:SelectTab(self) end)
	self.Button = Button

	local Section = Forge.Make("Frame", {
		Name = "TabContent", BackgroundTransparency = 1, BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
		Visible = false, Parent = Window.Content,
	}, {
		Forge.Make("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical, Padding = UDim.new(0, 8),
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
	})
	self.Section = Section
	return self
end

function Tab:Select()
	self.Selected = true
	self.Section.Visible = true
	local Theme = self.Window.VoidUI.Themes[self.Window.VoidUI.CurrentTheme]
	Forge.Guard(function()
		self.Button.BackgroundTransparency = 0.85
		self.Button.BackgroundColor3 = Theme.SurfaceHover
	end)
end

function Tab:Deselect()
	self.Selected = false
	self.Section.Visible = false
	Forge.Guard(function() self.Button.BackgroundTransparency = 1 end)
end

function Tab:_Row(Title, Desc)
	local Theme = self.Window.VoidUI.Themes[self.Window.VoidUI.CurrentTheme]
	local Row = Forge.Make("Frame", {
		Size = UDim2.new(1, 0, 0, Desc and 46 or 36), BackgroundTransparency = 1, Parent = self.Section,
	}, {
		Forge.Make("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical, Padding = UDim.new(0, 2),
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
		Forge.Make("TextLabel", {
			Text = Title or "", TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left,
			TextColor3 = Theme.Text, Size = UDim2.new(1, 0, 0, Desc and 18 or 36),
			FontFace = Font.fromEnum(Enum.Font.Gotham), Skin = { TextColor3 = "Text" },
		}),
	})
	if Desc then
		Forge.Make("TextLabel", {
			Text = Desc, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left,
			TextColor3 = Theme.TextDim, Size = UDim2.new(1, 0, 0, 16),
			FontFace = Font.fromEnum(Enum.Font.Gotham), Skin = { TextColor3 = "TextDim" }, Parent = Row,
		})
	end
	return Row
end

function Tab:CreateSection(Options)
	Options = Options or {}
	local Theme = self.Window.VoidUI.Themes[self.Window.VoidUI.CurrentTheme]
	return Forge.Make("Frame", {
		Size = UDim2.new(1, 0, 0, 30), BackgroundTransparency = 1, Parent = self.Section,
	}, {
		Forge.Make("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 8),
			VerticalAlignment = Enum.VerticalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder,
		}),
		Forge.Make("TextLabel", {
			Text = Options.Title or "Section", TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left,
			TextColor3 = Theme.Accent, Size = UDim2.new(0, 0, 1, 0),
			FontFace = Font.fromEnum(Enum.Font.Gotham), Skin = { TextColor3 = "Accent" },
		}),
		Forge.Make("Frame", {
			BackgroundColor3 = Theme.Border, Size = UDim2.new(1, -10, 0, 1),
			Skin = { BackgroundColor3 = "Border" },
		}),
	})
end

function Tab:CreateDivider(Options)
	Options = Options or {}
	local Theme = self.Window.VoidUI.Themes[self.Window.VoidUI.CurrentTheme]
	return Forge.Make("Frame", {
		Size = UDim2.new(1, 0, 0, 1), BackgroundColor3 = Theme.Border,
		Parent = self.Section, Skin = { BackgroundColor3 = "Border" },
	})
end

function Tab:CreateLabel(Options)
	Options = Options or {}
	local Theme = self.Window.VoidUI.Themes[self.Window.VoidUI.CurrentTheme]
	return Forge.Make("TextLabel", {
		Text = Options.Title or "", TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = Theme.Text, Size = UDim2.new(1, 0, 0, 24),
		FontFace = Font.fromEnum(Enum.Font.Gotham), Parent = self.Section, Skin = { TextColor3 = "Text" },
	})
end

function Tab:CreateParagraph(Options)
	Options = Options or {}
	local Theme = self.Window.VoidUI.Themes[self.Window.VoidUI.CurrentTheme]
	return Forge.Make("Frame", {
		Size = UDim2.new(1, 0, 0, 60), BackgroundColor3 = Theme.Surface, Parent = self.Section,
		Skin = { BackgroundColor3 = "Surface" },
	}, {
		Forge.Make("UICorner", { CornerRadius = UDim.new(0, 10) }),
		Forge.Make("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical, Padding = UDim.new(0, 4),
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
		Forge.Make("UIPadding", { PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12), PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10) }),
		Forge.Make("TextLabel", {
			Text = Options.Title or "", TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left,
			TextColor3 = Theme.Text, Size = UDim2.new(1, 0, 0, 18),
			FontFace = Font.fromEnum(Enum.Font.Gotham), Skin = { TextColor3 = "Text" },
		}),
		Forge.Make("TextLabel", {
			Text = Options.Content or "", TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left,
			TextColor3 = Theme.TextDim, Size = UDim2.new(1, 0, 0, 28), TextWrapped = true,
			FontFace = Font.fromEnum(Enum.Font.Gotham), Skin = { TextColor3 = "TextDim" },
		}),
	})
end

function Tab:CreateToggle(Options)
	Options = Options or {}
	local Theme = self.Window.VoidUI.Themes[self.Window.VoidUI.CurrentTheme]
	local Value = Options.Default or false
	local Callback = Options.Callback or function() end

	local Row = self:_Row(Options.Title, Options.Description)
	local Control = Forge.Make("Frame", {
		Size = UDim2.new(1, 0, 0, 24), BackgroundTransparency = 1, Parent = Row,
	}, {
		Forge.Make("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 0),
			VerticalAlignment = Enum.VerticalAlignment.Center, HorizontalAlignment = Enum.HorizontalAlignment.Right,
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
	})

	local Knob = Forge.Make("Frame", {
		Name = "Knob", Size = UDim2.fromOffset(16, 16), BackgroundColor3 = Color3.fromHex("#FFFFFF"),
		Position = Value and UDim2.new(1, -19, 0.5, 0) or UDim2.new(0, 3, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5),
	})
	local Track = Forge.Make("TextButton", {
		Size = UDim2.fromOffset(40, 22), BackgroundColor3 = Value and Theme.Accent or Theme.SurfaceHover,
		Text = "", Parent = Control, Skin = { BackgroundColor3 = Value and "Accent" or "SurfaceHover" },
	}, {
		Forge.Make("UICorner", { CornerRadius = UDim.new(1, 0) }), Knob,
	})

	local function SetState(newVal)
		Value = newVal
		Forge.Guard(function()
			Track.BackgroundColor3 = Value and Theme.Accent or Theme.SurfaceHover
			Knob.Position = Value and UDim2.new(1, -19, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)
		end)
		Forge.Guard(Callback, Value)
	end

	Track.MouseButton1Click:Connect(function() SetState(not Value) end)

	return { Set = function(_, v) SetState(v) end, Get = function() return Value end, Instance = Row }
end

function Tab:CreateSlider(Options)
	Options = Options or {}
	local Theme = self.Window.VoidUI.Themes[self.Window.VoidUI.CurrentTheme]
	local Min = Options.Min or 0
	local Max = Options.Max or 100
	local Value = Options.Default or Min
	local Callback = Options.Callback or function() end
	local Decimal = Options.Decimal or 0

	local Row = self:_Row(Options.Title, Options.Description)
	local Control = Forge.Make("Frame", {
		Size = UDim2.new(1, 0, 0, 26), BackgroundTransparency = 1, Parent = Row,
	}, {
		Forge.Make("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 10),
			VerticalAlignment = Enum.VerticalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder,
		}),
	})

	local Fill = Forge.Make("Frame", {
		Name = "Fill", Size = UDim2.new(math.clamp((Value - Min) / (Max - Min), 0, 1), 0, 1, 0),
		BackgroundColor3 = Theme.Accent, Skin = { BackgroundColor3 = "Accent" },
	}, { Forge.Make("UICorner", { CornerRadius = UDim.new(1, 0) }) })
	local Bar = Forge.Make("Frame", {
		Size = UDim2.new(1, -60, 0, 6), BackgroundColor3 = Theme.SurfaceHover, Parent = Control,
		Skin = { BackgroundColor3 = "SurfaceHover" },
	}, { Forge.Make("UICorner", { CornerRadius = UDim.new(1, 0) }), Fill })

	local ValueLabel = Forge.Make("TextLabel", {
		Text = tostring(Value), TextSize = 13, TextXAlignment = Enum.TextXAlignment.Right,
		TextColor3 = Theme.Text, Size = UDim2.new(0, 50, 1, 0),
		FontFace = Font.fromEnum(Enum.Font.Gotham), Skin = { TextColor3 = "Text" }, Parent = Control,
	})

	local function SetValue(newVal)
		newVal = math.clamp(newVal, Min, Max)
		if Decimal > 0 then
			newVal = math.floor(newVal * (10 ^ Decimal) + 0.5) / (10 ^ Decimal)
		else
			newVal = math.floor(newVal + 0.5)
		end
		Value = newVal
		Forge.Guard(function()
			Fill.Size = UDim2.new(math.clamp((Value - Min) / (Max - Min), 0, 1), 0, 1, 0)
			ValueLabel.Text = tostring(Value)
		end)
		Forge.Guard(Callback, Value)
	end

	local dragging
	Bar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
		end
	end)
	Bar.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local absPos = Bar.AbsolutePosition
			local absSize = Bar.AbsoluteSize
			local ratio = math.clamp((input.Position.X - absPos.X) / absSize.X, 0, 1)
			SetValue(Min + ratio * (Max - Min))
		end
	end)
	Bar.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)

	return { Set = function(_, v) SetValue(v) end, Get = function() return Value end, Instance = Row }
end

function Tab:CreateDropdown(Options)
	Options = Options or {}
	local Theme = self.Window.VoidUI.Themes[self.Window.VoidUI.CurrentTheme]
	local Items = Options.Options or {}
	local Multi = Options.Multi or false
	local Value
	if Multi then
		Value = (type(Options.Default) == "table") and Options.Default or {}
	else
		Value = Options.Default or Items[1] or nil
	end
	local Callback = Options.Callback or function() end

	local Row = self:_Row(Options.Title, Options.Description)
	local Control = Forge.Make("Frame", {
		Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = Theme.Surface, Parent = Row,
		Skin = { BackgroundColor3 = "Surface" },
	}, {
		Forge.Make("UICorner", { CornerRadius = UDim.new(0, 8) }),
		Forge.Make("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 8),
			VerticalAlignment = Enum.VerticalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder,
		}),
		Forge.Make("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10) }),
		Forge.Make("TextLabel", {
			Name = "Current", Text = Multi and (#Value > 0 and table.concat(Value, ", ") or "None") or tostring(Value or "None"),
			TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = Theme.Text,
			Size = UDim2.new(1, -24, 1, 0), FontFace = Font.fromEnum(Enum.Font.Gotham), Skin = { TextColor3 = "Text" },
		}),
		Icons.Create("ChevronDown", Theme.TextDim, 16),
	})


	local Popup = Forge.Make("Frame", {
		Name = "DropdownPopup", BackgroundColor3 = Theme.BackgroundElevated, Visible = false,
		AutomaticSize = Enum.AutomaticSize.Y, ZIndex = 500, Skin = { BackgroundColor3 = "BackgroundElevated" },
	}, {
		Forge.Make("UICorner", { CornerRadius = UDim.new(0, 8) }),
		Forge.Make("UIStroke", { Color = Theme.Border, Thickness = 1, Transparency = 0.4, Skin = { Color = "Border" } }),
		Forge.Make("UIListLayout", { FillDirection = Enum.FillDirection.Vertical, Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }),
		Forge.Make("UIPadding", { PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6), PaddingTop = UDim.new(0, 6), PaddingBottom = UDim.new(0, 6) }),
	})
	Popup.Parent = self.Window.VoidUI.Overlays

	local function RebuildPopup()
		for _, child in ipairs(Popup:GetChildren()) do
			if child:IsA("TextButton") then child:Destroy() end
		end
		for _, item in ipairs(Items) do
			local selected = Multi and table.find(Value, item) or (Value == item)
			local opt = Forge.Make("TextButton", {
				Size = UDim2.new(1, 0, 0, 28), Text = (selected and "✓ " or "") .. tostring(item),
				TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = selected and Theme.Accent or Theme.Text,
				BackgroundColor3 = selected and Theme.SurfaceHover or Theme.Surface, AutoButtonColor = false,
				FontFace = Font.fromEnum(Enum.Font.Gotham), ZIndex = 501,
				Skin = { TextColor3 = selected and "Accent" or "Text", BackgroundColor3 = selected and "SurfaceHover" or "Surface" },
			}, { Forge.Make("UICorner", { CornerRadius = UDim.new(0, 6) }),
				Forge.Make("UIPadding", { PaddingLeft = UDim.new(0, 8) }) })
			opt.MouseButton1Click:Connect(function()
				if Multi then
					if table.find(Value, item) then table.remove(Value, table.find(Value, item))
					else table.insert(Value, item) end
				else
					Value = item
					Popup.Visible = false
				end
				Forge.Guard(function()
					Control.Current.Text = Multi and (#Value > 0 and table.concat(Value, ", ") or "None") or tostring(Value or "None")
				end)
				RebuildPopup()
				Forge.Guard(Callback, Value)
			end)
		end
	end

	Control.MouseButton1Click:Connect(function()
		Popup.Visible = not Popup.Visible
		if Popup.Visible then
			RebuildPopup()
			Popup.Size = UDim2.new(0, Control.AbsoluteSize.X, 0, 0)
			local pos = Control.AbsolutePosition
			Popup.Position = UDim2.fromOffset(pos.X, pos.Y + Control.AbsoluteSize.Y + 4)
		end
	end)

	return { Set = function(_, v)
		Value = v
		Forge.Guard(function() Control.Current.Text = Multi and (#Value > 0 and table.concat(Value, ", ") or "None") or tostring(Value or "None") end)
		RebuildPopup()
	end, Get = function() return Value end, Instance = Row }
end

function Tab:CreateColorPicker(Options)
	Options = Options or {}
	local Theme = self.Window.VoidUI.Themes[self.Window.VoidUI.CurrentTheme]
	local Value = Options.Default or Color3.fromHex("#FFFFFF")
	local Callback = Options.Callback or function() end

	local Row = self:_Row(Options.Title, Options.Description)
	local Swatch = Forge.Make("TextButton", {
		Size = UDim2.fromOffset(28, 28), BackgroundColor3 = Value, Text = "", Parent = Row,
	}, { Forge.Make("UICorner", { CornerRadius = UDim.new(0, 6) }) })


	local Popup = Forge.Make("Frame", {
		Name = "ColorPopup", BackgroundColor3 = Theme.BackgroundElevated, Visible = false, ZIndex = 500,
		Size = UDim2.fromOffset(220, 200), Skin = { BackgroundColor3 = "BackgroundElevated" },
	}, {
		Forge.Make("UICorner", { CornerRadius = UDim.new(0, 10) }),
		Forge.Make("UIStroke", { Color = Theme.Border, Thickness = 1, Transparency = 0.4, Skin = { Color = "Border" } }),
		Forge.Make("UIListLayout", { FillDirection = Enum.FillDirection.Vertical, Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }),
		Forge.Make("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10), PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10) }),
	})
	Popup.Parent = self.Window.VoidUI.Overlays

	local SatVal = Forge.Make("Frame", {
		Size = UDim2.new(1, 0, 0, 120), BackgroundColor3 = Color3.fromHSV(0, 1, 1), ZIndex = 501,
	}, { Forge.Make("UICorner", { CornerRadius = UDim.new(0, 6) }) })
	local HueBar = Forge.Make("Frame", {
		Size = UDim2.new(1, 0, 0, 14), ZIndex = 501,
		BackgroundColor3 = Color3.fromHSV(0, 1, 1),
	}, { Forge.Make("UICorner", { CornerRadius = UDim.new(1, 0) }) })
	local HexLabel = Forge.Make("TextLabel", {
		Size = UDim2.new(1, 0, 0, 18), Text = "", TextSize = 12, TextColor3 = Theme.Text,
		FontFace = Font.fromEnum(Enum.Font.Gotham), BackgroundTransparency = 1, ZIndex = 501,
		Skin = { TextColor3 = "Text" },
	})
	SatVal.Parent = Popup; HueBar.Parent = Popup; HexLabel.Parent = Popup


	local svGradient = Instance.new("UIGradient")
	svGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
		ColorSequenceKeypoint.new(1, Color3.new(1, 1, 1)),
	})
	svGradient.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 0) })
	svGradient.Parent = SatVal

	local hueGradient = Instance.new("UIGradient")
	hueGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 1, 1)),
		ColorSequenceKeypoint.new(0.167, Color3.fromHSV(0.167, 1, 1)),
		ColorSequenceKeypoint.new(0.333, Color3.fromHSV(0.333, 1, 1)),
		ColorSequenceKeypoint.new(0.5, Color3.fromHSV(0.5, 1, 1)),
		ColorSequenceKeypoint.new(0.667, Color3.fromHSV(0.667, 1, 1)),
		ColorSequenceKeypoint.new(0.833, Color3.fromHSV(0.833, 1, 1)),
		ColorSequenceKeypoint.new(1, Color3.fromHSV(1, 1, 1)),
	})
	hueGradient.Parent = HueBar

	local h, s, v = Value:ToHSV()
	local svDragging, hueDragging

	local function UpdateFromSV()
		local absPos = SatVal.AbsolutePosition
		local absSize = SatVal.AbsoluteSize
		local relX = math.clamp((UserInputService:GetMouseLocation().X - absPos.X) / absSize.X, 0, 1)
		local relY = math.clamp((UserInputService:GetMouseLocation().Y - absPos.Y) / absSize.Y, 0, 1)
		s = relX; v = 1 - relY
		Value = Color3.fromHSV(h, s, v)
		Forge.Guard(function()
			Swatch.BackgroundColor3 = Value
			HueBar.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
			HexLabel.Text = "#" .. Value:ToHex()
		end)
		Forge.Guard(Callback, Value)
	end

	local function UpdateFromHue()
		local absPos = HueBar.AbsolutePosition
		local absSize = HueBar.AbsoluteSize
		h = math.clamp((UserInputService:GetMouseLocation().X - absPos.X) / absSize.X, 0, 1)
		Value = Color3.fromHSV(h, s, v)
		Forge.Guard(function()
			Swatch.BackgroundColor3 = Value
			SatVal.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
			HexLabel.Text = "#" .. Value:ToHex()
		end)
		Forge.Guard(Callback, Value)
	end

	SatVal.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			svDragging = true; UpdateFromSV()
		end
	end)
	SatVal.InputChanged:Connect(function(input)
		if svDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			UpdateFromSV()
		end
	end)
	SatVal.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			svDragging = false
		end
	end)
	HueBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			hueDragging = true; UpdateFromHue()
		end
	end)
	HueBar.InputChanged:Connect(function(input)
		if hueDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			UpdateFromHue()
		end
	end)
	HueBar.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			hueDragging = false
		end
	end)

	Swatch.MouseButton1Click:Connect(function()
		Popup.Visible = not Popup.Visible
		if Popup.Visible then
			h, s, v = Value:ToHSV()
			Forge.Guard(function()
				SatVal.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
				HueBar.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
				HexLabel.Text = "#" .. Value:ToHex()
				local pos = Swatch.AbsolutePosition
				Popup.Position = UDim2.fromOffset(pos.X, pos.Y + Swatch.AbsoluteSize.Y + 4)
			end)
		end
	end)

	return { Set = function(_, col)
		Value = col
		Forge.Guard(function() Swatch.BackgroundColor3 = col end)
	end, Get = function() return Value end, Instance = Row }
end

function Tab:CreateKeybind(Options)
	Options = Options or {}
	local Theme = self.Window.VoidUI.Themes[self.Window.VoidUI.CurrentTheme]
	local Value = Options.Default or Enum.KeyCode.RightShift
	local Callback = Options.Callback or function() end

	local Row = self:_Row(Options.Title, Options.Description)
	local Button = Forge.Make("TextButton", {
		Size = UDim2.fromOffset(120, 28), BackgroundColor3 = Theme.Surface, Text = tostring(Value),
		TextSize = 13, TextColor3 = Theme.Text, Parent = Row, FontFace = Font.fromEnum(Enum.Font.Gotham),
		Skin = { BackgroundColor3 = "Surface", TextColor3 = "Text" },
	}, { Forge.Make("UICorner", { CornerRadius = UDim.new(0, 6) }) })

	local listening = false
	Button.MouseButton1Click:Connect(function()
		listening = true
		Forge.Guard(function() Button.Text = "Press a key..." end)
		local conn
		conn = UserInputService.InputBegan:Connect(function(input, gp)
			if gp then return end
			if input.UserInputType == Enum.UserInputType.Keyboard then
				Value = input.KeyCode
				listening = false
				Forge.Guard(function() Button.Text = tostring(Value) end)
				Forge.Guard(Callback, Value)
				conn:Disconnect()
			end
		end)
	end)

	return { Set = function(_, key)
		Value = key
		Forge.Guard(function() Button.Text = tostring(key) end)
	end, Get = function() return Value end, Instance = Row }
end

function Tab:CreateTextbox(Options)
	Options = Options or {}
	local Theme = self.Window.VoidUI.Themes[self.Window.VoidUI.CurrentTheme]
	local Value = Options.Default or ""
	local Callback = Options.Callback or function() end

	local Row = self:_Row(Options.Title, Options.Description)
	local Box = Forge.Make("TextBox", {
		Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = Theme.Surface, Text = Value,
		PlaceholderText = Options.Placeholder or "", TextSize = 13, TextColor3 = Theme.Text,
		ClearTextOnFocus = false, Parent = Row, FontFace = Font.fromEnum(Enum.Font.Gotham),
		Skin = { BackgroundColor3 = "Surface", TextColor3 = "Text" },
	}, { Forge.Make("UICorner", { CornerRadius = UDim.new(0, 8) }),
		Forge.Make("UIPadding", { PaddingLeft = UDim.new(0, 10) }) })
	Box.FocusLost:Connect(function(enter)
		Value = Box.Text
		Forge.Guard(Callback, Value, enter)
	end)

	return { Set = function(_, txt) Value = txt; Forge.Guard(function() Box.Text = txt end) end, Get = function() return Value end, Instance = Row }
end

function Tab:CreateButton(Options)
	Options = Options or {}
	local Theme = self.Window.VoidUI.Themes[self.Window.VoidUI.CurrentTheme]
	local Callback = Options.Callback or function() end

	local Button = Forge.Make("TextButton", {
		Size = UDim2.new(1, 0, 0, 34), BackgroundColor3 = Theme.Accent, Text = Options.Title or "Button",
		TextSize = 14, TextColor3 = Color3.fromHex("#0E1116"), Parent = self.Section,
		FontFace = Font.fromEnum(Enum.Font.Gotham), Skin = { BackgroundColor3 = "Accent" },
	}, { Forge.Make("UICorner", { CornerRadius = UDim.new(0, 8) }) })
	Button.MouseButton1Click:Connect(function() Forge.Guard(Callback) end)

	return { Instance = Button }
end

local Window = {}
Window.__index = Window

function Window.new(VoidUI, Config)
	Config = Config or {}
	local self = setmetatable({}, Window)

	self.VoidUI = VoidUI
	self.Title = Config.Title or "VoidUI"
	self.Icon = Config.Icon or "Void"
	self.Subtitle = Config.Subtitle or ""
	self.Size = Config.Size or UDim2.fromOffset(620, 440)
	self.Position = Config.Position or UDim2.fromScale(0.5, 0.5)
	self.Resizable = Config.Resizable ~= false
	self.Draggable = Config.Draggable ~= false
	self.Minimized = false
	self.Maximized = false
	self.Closed = false
	self.Tabs = {}
	self.ActiveTab = nil
	self.Notifications = {}
	self.ZIndex = 100

	local WindowsFolder = VoidUI.ScreenGui:FindFirstChild("Windows")
	local NotifFolder = VoidUI.ScreenGui:FindFirstChild("Notifications")

	self:_Build(WindowsFolder, NotifFolder)
	return self
end

function Window:_Build(WindowsFolder, NotifFolder)
	local Theme = self.VoidUI.CurrentTheme and self.VoidUI.Themes[self.VoidUI.CurrentTheme] or self.VoidUI.Themes.Default

	local Main = Forge.Make("Frame", {
		Name = "Window", BackgroundColor3 = Theme.Background, BorderSizePixel = 0, Size = self.Size,
		Position = self.Position, AnchorPoint = Vector2.new(0.5, 0.5), ZIndex = self.ZIndex,
		ClipsDescendants = true, Parent = WindowsFolder, Skin = { BackgroundColor3 = "Background" },
	}, {
		Forge.Make("UICorner", { CornerRadius = UDim.new(0, Theme.RadiusLarge or 18) }),
		Forge.Make("UIStroke", { Color = Theme.Border, Thickness = 1, Transparency = 0.4, Skin = { Color = "Border" } }),
	})

	local Header = Forge.Make("Frame", {
		Name = "Header", BackgroundColor3 = Theme.BackgroundElevated, BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, Theme.HeaderHeight or 52), ZIndex = self.ZIndex + 1, Parent = Main,
		Skin = { BackgroundColor3 = "BackgroundElevated" },
	}, { Forge.Make("UICorner", { CornerRadius = UDim.new(0, Theme.RadiusLarge or 18) }) })

	local HeaderContent = Forge.Make("Frame", {
		BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.new(1, 0, 1, 0),
		ZIndex = self.ZIndex + 2, Parent = Header,
	}, {
		Forge.Make("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 12),
			VerticalAlignment = Enum.VerticalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder,
		}),
		Forge.Make("UIPadding", { PaddingLeft = UDim.new(0, 16), PaddingRight = UDim.new(0, 12) }),
	})

	local IconFrame = Icons.Create(self.Icon, Theme.Accent, 22)
	IconFrame.LayoutOrder = 1
	IconFrame.Parent = HeaderContent

	local TitleBlock = Forge.Make("Frame", {
		BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.new(1, -220, 1, 0),
		ZIndex = self.ZIndex + 2, Parent = HeaderContent,
	}, {
		Forge.Make("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical, Padding = UDim.new(0, 0),
			VerticalAlignment = Enum.VerticalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder,
		}),
		Forge.Make("TextLabel", {
			Name = "Title", Text = self.Title, TextSize = 16, TextXAlignment = Enum.TextXAlignment.Left,
			TextColor3 = Theme.Text, Size = UDim2.new(1, 0, 0, 18), FontFace = Font.fromEnum(Enum.Font.Gotham),
			Skin = { TextColor3 = "Text" },
		}),
		Forge.Make("TextLabel", {
			Name = "Subtitle", Text = self.Subtitle, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left,
			TextColor3 = Theme.TextDim, Size = UDim2.new(1, 0, 0, 14), Visible = #self.Subtitle > 0,
			Skin = { TextColor3 = "TextDim" },
		}),
	})


	local SearchBox = Forge.Make("TextBox", {
		Size = UDim2.new(0, 120, 0, 26), BackgroundColor3 = Theme.Surface, Text = "",
		PlaceholderText = "Search...", TextSize = 12, TextColor3 = Theme.Text,
		ClearTextOnFocus = false, ZIndex = self.ZIndex + 2, FontFace = Font.fromEnum(Enum.Font.Gotham),
		Skin = { BackgroundColor3 = "Surface", TextColor3 = "Text" },
	}, { Forge.Make("UICorner", { CornerRadius = UDim.new(0, 6) }),
		Forge.Make("UIPadding", { PaddingLeft = UDim.new(0, 8) }) })
	SearchBox.LayoutOrder = 2
	SearchBox.Parent = HeaderContent
	SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
		local q = string.lower(SearchBox.Text)
		for _, tab in ipairs(self.Tabs) do
			local match = q == "" or string.find(string.lower(tab.Title), q, 1, true)
			tab.Button.Visible = match
		end
	end)

	local Controls = Forge.Make("Frame", {
		BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.new(0, 96, 1, 0),
		ZIndex = self.ZIndex + 2, Parent = HeaderContent,
	}, {
		Forge.Make("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 6),
			VerticalAlignment = Enum.VerticalAlignment.Center, HorizontalAlignment = Enum.HorizontalAlignment.Right,
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
	})
	Controls.LayoutOrder = 3

	self:_CreateControlButton(Controls, "Minus", function() self:ToggleMinimize() end, Theme.TextDim)
	self:_CreateControlButton(Controls, "Square", function() self:ToggleMaximize() end, Theme.TextDim)
	self:_CreateControlButton(Controls, "Close", function() self:Close() end, Theme.Danger)

	local Body = Forge.Make("Frame", {
		Name = "Body", BackgroundTransparency = 1, BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 1, -(Theme.HeaderHeight or 52)), Position = UDim2.new(0, 0, 0, Theme.HeaderHeight or 52),
		ZIndex = self.ZIndex + 1, Parent = Main,
	})

	local Sidebar = Forge.Make("Frame", {
		Name = "Sidebar", BackgroundColor3 = Theme.Surface, BorderSizePixel = 0,
		Size = UDim2.new(0, Theme.SidebarWidth or 200, 1, 0), ZIndex = self.ZIndex + 1, Parent = Body,
		Skin = { BackgroundColor3 = "Surface" },
	}, {
		Forge.Make("UICorner", { CornerRadius = UDim.new(0, Theme.Radius or 12) }),
		Forge.Make("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical, Padding = UDim.new(0, 6),
			HorizontalAlignment = Enum.HorizontalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder,
		}),
		Forge.Make("UIPadding", { PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10) }),
	})

	local Content = Forge.Make("ScrollingFrame", {
		Name = "Content", BackgroundTransparency = 1, BorderSizePixel = 0,
		Size = UDim2.new(1, -(Theme.SidebarWidth or 200), 1, 0), Position = UDim2.new(0, Theme.SidebarWidth or 200, 0, 0),
		ZIndex = self.ZIndex + 1, ScrollBarThickness = 4, ScrollBarImageColor3 = Theme.Scrollbar,
		CanvasSize = UDim2.new(0, 0, 0, 0), Parent = Body, Skin = { ScrollBarImageColor3 = "Scrollbar" },
	}, {
		Forge.Make("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical, Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder,
		}),
		Forge.Make("UIPadding", { PaddingLeft = UDim.new(0, 14), PaddingRight = UDim.new(0, 14), PaddingTop = UDim.new(0, 12), PaddingBottom = UDim.new(0, 12) }),
	})


	local ResizeHandle = Forge.Make("Frame", {
		Name = "ResizeHandle", Size = UDim2.fromOffset(18, 18), BackgroundTransparency = 1,
		Position = UDim2.new(1, -18, 1, -18), AnchorPoint = Vector2.new(1, 1), ZIndex = self.ZIndex + 2,
		Parent = Main, Visible = self.Resizable,
	}, { Icons.Create("Maximize", Theme.TextMuted, 12) })

	self.Main = Main
	self.Header = Header
	self.Body = Body
	self.Sidebar = Sidebar
	self.Content = Content
	self.NotifFolder = NotifFolder
	self.ResizeHandle = ResizeHandle

	self:_EnableDrag()
	self:_EnableResize()
end

function Window:_CreateControlButton(Parent, IconName, Callback, Color)
	local Button = Forge.Make("TextButton", {
		Size = UDim2.fromOffset(28, 28), BackgroundTransparency = 1, Text = "", Parent = Parent,
	}, { Icons.Create(IconName, Color, 16) })
	Button.MouseButton1Click:Connect(function() Forge.Guard(Callback) end)
	Button.MouseEnter:Connect(function()
		Forge.Guard(function() Button.BackgroundTransparency = 0.9; Button.BackgroundColor3 = Color end)
	end)
	Button.MouseLeave:Connect(function() Forge.Guard(function() Button.BackgroundTransparency = 1 end) end)
	return Button
end

function Window:_EnableDrag()
	if not self.Draggable then return end
	local dragging, dragStart, startPos
	self.Header.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = self.Main.Position
		end
	end)
	self.Header.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			self.Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
	self.Header.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
end

function Window:_EnableResize()
	if not self.Resizable then return end
	local resizing
	self.ResizeHandle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			resizing = true
		end
	end)
	self.ResizeHandle.InputChanged:Connect(function(input)
		if resizing and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local mouse = UserInputService:GetMouseLocation()
			local absPos = self.Main.AbsolutePosition
			local newW = math.clamp(mouse.X - absPos.X, 360, 1200)
			local newH = math.clamp(mouse.Y - absPos.Y, 260, 800)
			self.Main.Size = UDim2.fromOffset(newW, newH)
		end
	end)
	self.ResizeHandle.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			resizing = false
		end
	end)
end

function Window:CreateTab(Options)
	Options = Options or {}
	local Tab = Tab.new(self, Options)
	table.insert(self.Tabs, Tab)
	if not self.ActiveTab then self:SelectTab(Tab) end
	return Tab
end

function Window:SelectTab(Tab)
	if self.ActiveTab and self.ActiveTab ~= Tab then self.ActiveTab:Deselect() end
	self.ActiveTab = Tab
	Tab:Select()
end

function Window:ToggleMinimize()
	self.Minimized = not self.Minimized
	self.Body.Visible = not self.Minimized
end

function Window:ToggleMaximize()
	self.Maximized = not self.Maximized
	if self.Maximized then
		self.Main.Size = UDim2.fromScale(0.95, 0.95)
	else
		self.Main.Size = self.Size
	end
end

function Window:Close()
	self.Closed = true
	self.Main.Visible = false
end

function Window:ApplyTheme(Theme)

end

function Window:Notify(Options)
	Options = Options or {}
	local Theme = self.VoidUI.Themes[self.VoidUI.CurrentTheme]
	local Color = Theme.Text
	if Options.Type == "Success" then Color = Theme.Success
	elseif Options.Type == "Warning" then Color = Theme.Warning
	elseif Options.Type == "Error" then Color = Theme.Danger
	elseif Options.Type == "Info" then Color = Theme.Accent end

	local Notif = Forge.Make("Frame", {
		Name = "Notification", BackgroundColor3 = Theme.BackgroundElevated, Size = UDim2.new(0, 300, 0, 64),
		AnchorPoint = Vector2.new(1, 0), ZIndex = 200, Parent = self.NotifFolder,
		Skin = { BackgroundColor3 = "BackgroundElevated" },
	}, {
		Forge.Make("UICorner", { CornerRadius = UDim.new(0, 10) }),
		Forge.Make("UIStroke", { Color = Theme.Border, Thickness = 1, Transparency = 0.4, Skin = { Color = "Border" } }),
		Forge.Make("TextLabel", {
			Text = Options.Title or "Notification", TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left,
			TextColor3 = Color, Size = UDim2.new(1, -20, 0, 20), Position = UDim2.new(0, 12, 0, 10),
			FontFace = Font.fromEnum(Enum.Font.Gotham),
		}),
		Forge.Make("TextLabel", {
			Text = Options.Description or "", TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left,
			TextColor3 = Theme.TextDim, Size = UDim2.new(1, -20, 0, 30), Position = UDim2.new(0, 12, 0, 32),
			TextWrapped = true, Skin = { TextColor3 = "TextDim" },
		}),
	})
	table.insert(self.Notifications, Notif)


	local yOffset = 12
	for i = #self.Notifications, 1, -1 do
		local n = self.Notifications[i]
		n.Position = UDim2.new(1, -12, 0, yOffset)
		yOffset = yOffset + n.AbsoluteSize.Y + 8
	end

	Notif.BackgroundTransparency = 1
	Forge.Tween(Notif, 0.3, { BackgroundTransparency = 0 }):Play()


	local duration = Options.Duration or 4
	task.delay(duration, function()
		Forge.Tween(Notif, 0.3, { BackgroundTransparency = 1 }):Play()
		task.delay(0.35, function()
			local idx = table.find(self.Notifications, Notif)
			if idx then table.remove(self.Notifications, idx) end
			Notif:Destroy()
		end)
	end)

	return Notif
end

VoidUI.Forge = Forge
VoidUI.Themes = Themes
VoidUI.ThemeFallbacks = ThemeFallbacks
VoidUI.Icon = Icons
VoidUI.Windows = {}
VoidUI.CurrentTheme = "Default"
VoidUI.Accent = Color3.fromHex(Themes.Default.Accent)
VoidUI.ScreenGui = nil
VoidUI.UIScaleObj = nil
VoidUI.UIScale = 1
VoidUI.OnThemeChange = nil
VoidUI.Overlays = nil

function VoidUI.GenerateGUID()
	local ok, hs = pcall(function() return cloneref(game:GetService("HttpService")) end)
	if ok and hs and hs.GenerateGUID then return hs:GenerateGUID(false) end
	return tostring(os.clock()) .. tostring(math.random())
end

function VoidUI:SetTheme(Name)
	if not Themes[Name] then
		warn("[VoidUI] Theme not found:", Name)
		return false
	end
	VoidUI.CurrentTheme = Name
	Forge.Apply(Themes[Name])
	if VoidUI.OnThemeChange then Forge.Guard(VoidUI.OnThemeChange, Themes[Name], Name) end
	for _, Window in ipairs(VoidUI.Windows) do
		if Window.ApplyTheme then Window:ApplyTheme(Themes[Name]) end
	end
	return true
end

function VoidUI:SetAccent(Color)
	VoidUI.Accent = Color
	Themes[VoidUI.CurrentTheme].Accent = Color
	Themes[VoidUI.CurrentTheme].AccentGlow = Color
	Forge.Apply(Themes[VoidUI.CurrentTheme])
	for _, Window in ipairs(VoidUI.Windows) do
		if Window.ApplyTheme then Window:ApplyTheme(Themes[VoidUI.CurrentTheme]) end
	end
end

function VoidUI:CreateWindow(Options)
	Options = Options or {}
	local Window = Window.new(VoidUI, Options)
	table.insert(VoidUI.Windows, Window)
	return Window
end

function VoidUI:Notify(Options)
	Options = Options or {}
	local Window = VoidUI.Windows[1]
	if Window and Window.Notify then return Window:Notify(Options) end
	warn("[VoidUI] Notify: no window created yet")
	return nil
end

function VoidUI:GetStats()
	return { Windows = #VoidUI.Windows, Theme = VoidUI.CurrentTheme, Version = VoidUI.Version }
end

function VoidUI.new(Options)
	Options = Options or {}

	if not VoidUI.ScreenGui then
		local UIScaleObj = Forge.Make("UIScale", { Scale = VoidUI.UIScale })
		VoidUI.UIScaleObj = UIScaleObj

		local ScreenGui = Forge.Make("ScreenGui", {
			Name = "VoidUI", Parent = GUIParent, IgnoreGuiInset = true,
			ZIndexBehavior = Enum.ZIndexBehavior.Sibling, DisplayOrder = 1000, ResetOnSpawn = false,
		}, {
			UIScaleObj,
			Forge.Make("Folder", { Name = "Windows" }),
			Forge.Make("Folder", { Name = "Notifications" }),
			Forge.Make("Folder", { Name = "Overlays" }),
		})
		VoidUI.ScreenGui = ScreenGui
		VoidUI.Overlays = ScreenGui:FindFirstChild("Overlays")
		ProtectGui(ScreenGui)
	end

	VoidUI:SetTheme(Options.Theme or "Default")
	if Options.Accent then VoidUI:SetAccent(Options.Accent) end

	return VoidUI
end

return VoidUI
