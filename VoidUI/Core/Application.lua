local Utilities = require(script.Parent.Utilities)
local Events = require(script.Parent.Events)
local Cleanup = require(script.Parent.Cleanup)
local Scheduler = require(script.Parent.Scheduler)
local State = require(script.Parent.State)
local Animation = require(script.Parent.Animation)
local Renderer = require(script.Parent.Renderer)
local Window = require(script.Parent.Window)
local ThemeManager = require(script.Parent.Parent.Themes.ThemeManager)
local ConfigManager = require(script.Parent.Parent.Managers.ConfigManager)
local PluginManager = require(script.Parent.Parent.Managers.PluginManager)
local NotificationManager = require(script.Parent.Parent.Managers.NotificationManager)
local InputManager = require(script.Parent.Parent.Managers.InputManager)
local WindowManager = require(script.Parent.Parent.Managers.WindowManager)
local AssetManager = require(script.Parent.Parent.Managers.AssetManager)
local LayoutManager = require(script.Parent.Parent.Managers.LayoutManager)
local Icons = require(script.Parent.Parent.Assets.Icons)
local Fonts = require(script.Parent.Parent.Assets.Fonts)
local Images = require(script.Parent.Parent.Assets.Images)
local Widgets = require(script.Parent.Parent.Widgets)

local Application = {}
Application.__index = Application

function Application.new(Options)
	Options = Options or {}
	local self = setmetatable({}, Application)
	self.Options = Options
	self.Version = "2.0.0"
	self.Name = Options.Name or "VoidUI"
	self.Started = false
	self.Ready = false
	self.Cleanup = Cleanup.new()
	self.Events = Events.new()
	self.State = State.new("Booting")
	self.Scheduler = Scheduler.new()
	self.Animation = Animation.new()
	self.ThemeManager = ThemeManager.new()
	self.ConfigManager = ConfigManager.new({ Name = Options.ConfigName or "VoidUI_Config" })
	self.PluginManager = PluginManager.new()
	self.InputManager = InputManager.new()
	self.WindowManager = WindowManager.new(nil)
	self.AssetManager = AssetManager.new()
	self.LayoutManager = LayoutManager.new()
	self.Renderer = Renderer.new(self.ThemeManager, self.Animation)
	self.WindowManager.Parent = self.Renderer:GetLayer("Windows")
	self.NotificationManager = NotificationManager.new(self.Renderer:GetLayer("Notifications"), self.ThemeManager)
	self.Widgets = Widgets
	self.Windows = {}
	self.Splash = nil
	self._Initialize()
	return self
end

function Application:_Initialize()
	local ThemeName = self.Options.Theme or "Default"
	self.ThemeManager:Set(ThemeName)
	self.Theme = self.ThemeManager
	self:_BindGlobalHotkeys()
end

function Application:_BindGlobalHotkeys()
	self.InputManager:BindHotkey("VoidUI_Hide", { Enum.KeyCode.RightShift }, function()
		self:ToggleVisibility()
	end, { Modifiers = {} })
end

function Application:ToggleVisibility()
	local Screen = self.Renderer.Screen
	Screen.Enabled = not Screen.Enabled
end

function Application:SetTheme(Name)
	self.ThemeManager:Set(Name)
	self:_ApplyThemeToWindows()
end

function Application:SetAccent(Color)
	self.ThemeManager:SetAccent(Color)
	self:_ApplyThemeToWindows()
end

function Application:_ApplyThemeToWindows()
	for _, Window in ipairs(self.Windows) do
		if Window._ApplyTheme then
			Window:_ApplyTheme()
		end
	end
end

function Application:CreateWindow(Options)
	local WindowInstance = Window.new(self, Options)
	table.insert(self.Windows, WindowInstance)
	self.WindowManager:Register(WindowInstance)
	return WindowInstance
end

function Application:GetWindow(Title)
	return self.WindowManager:FindByTitle(Title)
end

function Application:Notify(Options)
	return self.NotificationManager:Notify(Options)
end

function Application:RegisterPlugin(Plugin)
	return self.PluginManager:Register(Plugin)
end

function Application:LoadPlugin(Name, Context)
	return self.PluginManager:Load(Name, Context or self)
end

function Application:CreateConfig(Options)
	return ConfigManager.new(Options)
end

function Application:SaveConfig()
	return self.ConfigManager:Save()
end

function Application:LoadConfig()
	return self.ConfigManager:Load()
end

function Application:GetStats()
	return {
		Windows = #self.Windows,
		Theme = self.ThemeManager:GetName(),
		Accent = self.ThemeManager:GetAccent(),
		Assets = self.AssetManager:GetStats(),
		Plugins = self.PluginManager:Count(),
		FPS = math.round(1 / (game:GetService("RunService").RenderStepped:Wait() or 1 / 60)),
	}
end

function Application:RunStartupSequence(Callback)
	if self.Started then
		return
	end
	self.Started = true
	self.State:Set("Starting")
	self.Splash = self:_BuildSplash()
	self:_PlayStartup(function()
		self.Ready = true
		self.State:Set("Ready")
		self.Events:Fire("Ready")
		if Callback then
			pcall(Callback)
		end
	end)
end

function Application:_BuildSplash()
	local Theme = self.ThemeManager
	local Layer = self.Renderer:GetLayer("Splash")
	local Screen = Utilities.Create("Frame", {
		Name = "Splash",
		BackgroundColor3 = Theme.Color("Background"),
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 1, 0),
		ZIndex = 100,
		Parent = Layer,
	})
	local Gradient = Utilities.AddGradient(Screen, Theme.Gradient("Background"), 90)
	Gradient.Transparency = NumberSequence.new(0.6)

	local Center = Utilities.Create("Frame", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(400, 300),
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		ZIndex = 101,
		Parent = Screen,
	})

	local Core = Utilities.Create("Frame", {
		Name = "Core",
		BackgroundColor3 = Theme.Color("Accent"),
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(40, 40),
		Position = UDim2.fromScale(0.5, 0.4),
		AnchorPoint = Vector2.new(0.5, 0.5),
		ZIndex = 102,
		Parent = Center,
	})
	local CoreCorner = Utilities.Roundify(Core, 999)
	local CoreGlow = Utilities.AddStroke(Core, Theme.Color("AccentGlow"), 2)
	CoreGlow.Transparency = 0.4

	local ParticleContainer = Utilities.Create("Frame", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(300, 300),
		Position = UDim2.fromScale(0.5, 0.4),
		AnchorPoint = Vector2.new(0.5, 0.5),
		ZIndex = 101,
		Parent = Center,
	})
	local Particles = self.Animation:Particles(ParticleContainer)

	local Logo = Icons.Create("Void", Theme.Color("AccentLight"), 64)
	Logo.Position = UDim2.fromScale(0.5, 0.4)
	Logo.AnchorPoint = Vector2.new(0.5, 0.5)
	Logo.ZIndex = 103
	Logo.Parent = Center
	Logo.ImageTransparency = 1

	local Title = Utilities.Create("TextLabel", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 30),
		Position = UDim2.fromScale(0.5, 0.62),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Font = Theme.Typography("FontBold"),
		TextSize = 28,
		TextColor3 = Theme.Color("Text"),
		Text = "VoidUI",
		ZIndex = 103,
		Parent = Center,
	})
	Title.TextTransparency = 1

	local Status = Utilities.Create("TextLabel", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 20),
		Position = UDim2.fromScale(0.5, 0.72),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Font = Theme.Typography("Font"),
		TextSize = Theme.Typography("CaptionSize"),
		TextColor3 = Theme.Color("TextMuted"),
		Text = "Initializing VoidUI",
		ZIndex = 103,
		Parent = Center,
	})
	Status.TextTransparency = 1

	local ProgressBar = Utilities.Create("Frame", {
		BackgroundColor3 = Theme.Color("Surface"),
		BorderSizePixel = 0,
		Size = UDim2.new(0.6, 0, 0, 4),
		Position = UDim2.fromScale(0.5, 0.8),
		AnchorPoint = Vector2.new(0.5, 0.5),
		ZIndex = 103,
		Parent = Center,
	})
	local BarCorner = Utilities.Roundify(BarCorner, 999)
	local ProgressFill = Utilities.Create("Frame", {
		BackgroundColor3 = Theme.Color("Accent"),
		BorderSizePixel = 0,
		Size = UDim2.new(0, 0, 1, 0),
		ZIndex = 104,
		Parent = ProgressBar,
	})
	local FillCorner = Utilities.Roundify(ProgressFill, 999)
	local FillGradient = Utilities.AddGradient(ProgressFill, Theme.Gradient("Accent"), 90)

	return {
		Screen = Screen,
		Center = Center,
		Core = Core,
		Particles = Particles,
		Logo = Logo,
		Title = Title,
		Status = Status,
		ProgressBar = ProgressBar,
		ProgressFill = ProgressFill,
	}
end

function Application:_PlayStartup(Done)
	local Splash = self.Splash
	local Theme = self.ThemeManager
	local Steps = {
		"Initializing VoidUI",
		"Loading modules",
		"Loading renderer",
		"Loading themes",
		"Loading widgets",
		"Loading plugins",
		"Ready",
	}
	local Index = 1

	local function Next()
		if Index > #Steps then
			self:_FinishStartup(Done)
			return
		end
		local Step = Steps[Index]
		Splash.Status.Text = Step
		self.Animation:Animate(Splash.Status, "TextTransparency", 0, { Duration = 0.2 })
		local Progress = Index / #Steps
		self.Animation:Animate(Splash.ProgressFill, "Size", UDim2.new(Progress, 0, 1, 0), { Duration = 0.4, Easing = "QuadOut" })
		Index = Index + 1
		task.delay(0.45, Next)
	end

	self.Animation:Animate(Splash.Screen, "BackgroundTransparency", 0, { Duration = 0.4 })
	self.Animation:Animate(Splash.Core, "Size", UDim2.fromOffset(60, 60), { Duration = 0.5, Easing = "BackOut" })
	Splash.Particles:Orbit(Vector2.new(150, 120), 14, 90, Theme.Color("AccentGlow"))
	task.delay(0.4, function()
		self.Animation:Animate(Splash.Logo, "ImageTransparency", 0, { Duration = 0.4 })
		self.Animation:Animate(Splash.Title, "TextTransparency", 0, { Duration = 0.4 })
		self.Animation:Animate(Splash.Core, "Size", UDim2.fromOffset(50, 50), { Duration = 0.6, Easing = "QuadOut" })
		task.delay(0.3, Next)
	end)
end

function Application:_FinishStartup(Done)
	local Splash = self.Splash
	self.Animation:Animate(Splash.Screen, "BackgroundTransparency", 1, { Duration = 0.5, Easing = "QuadIn" })
	task.delay(0.5, function()
		Splash.Screen:Destroy()
		Splash.Particles:Destroy()
		self.Splash = nil
		pcall(Done)
	end)
end

function Application:ShowSplash()
	if not self.Splash then
		self.Splash = self:_BuildSplash()
	end
end

function Application:HideSplash()
	if self.Splash then
		self.Splash.Screen:Destroy()
		self.Splash = nil
	end
end

function Application:CreateCommandPalette()
	local Palette = self.Widgets.CommandPalette.new(self)
	return Palette
end

function Application:CreateContextMenu(Items)
	return self.Widgets.ContextMenu.new(self, Items)
end

function Application:CreateTooltip(Text)
	return self.Widgets.Tooltip.new(self, Text)
end

function Application:CreateModal(Options)
	return self.Widgets.Modal.new(self, Options)
end

function Application:CreateBreadcrumbs(Items)
	return self.Widgets.Breadcrumbs.new(self, Items)
end

function Application:SubscribeReady(Callback)
	return self.Events:Connect(function(Event)
		if Event == "Ready" then
			pcall(Callback)
		end
	end)
end

function Application:SubscribeThemeChanged(Callback)
	return self.ThemeManager:Subscribe(Callback)
end

function Application:SubscribeAccentChanged(Callback)
	return self.ThemeManager:SubscribeAccent(Callback)
end

function Application:Destroy()
	for _, Window in ipairs(self.Windows) do
		if Window.Destroy then
			pcall(Window.Destroy, Window)
		end
	end
	self.Windows = {}
	self.PluginManager:Destroy()
	self.InputManager:Destroy()
	self.NotificationManager:Destroy()
	self.WindowManager:Destroy()
	self.AssetManager:Destroy()
	self.LayoutManager:Destroy()
	self.ConfigManager:Destroy()
	self.Renderer:Destroy()
	self.Animation:Shutdown()
	self.Scheduler:Shutdown()
	self.Cleanup:Destroy()
	self.Started = false
	self.Ready = false
end

return Application
