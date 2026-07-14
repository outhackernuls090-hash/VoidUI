local Utilities = require(script.Parent.Parent.Core.Utilities)
local Base = require(script.Parent.Base)
local Icons = require(script.Parent.Parent.Assets.Icons)
local Events = require(script.Parent.Parent.Core.Events)

local Tabs = {}
Tabs.__index = setmetatable(Tabs, Base)

function Tabs.new(Window, Options)
	local self = setmetatable(Base.new(Window.Application, Window.ContentScroll, Options), Tabs)
	self.Window = Window
	self.Title = Options.Title or "Tab"
	self.Icon = Options.Icon
	self.Selected = false
	self.Widgets = {}
	self.Sections = {}
	self.Changed = Events.new()
	self:_Build()
	return self
end

function Tabs:_Build()
	local Theme = self.Theme
	local Button = Utilities.Create("TextButton", {
		Name = "TabButton",
		BackgroundColor3 = Theme.Color("Surface"),
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 40),
		AutoButtonColor = false,
		Text = "",
		Parent = self.Window.TabList,
	})
	local Corner = Utilities.Roundify(Button, Theme.Layout("RadiusSmall"))
	local Stroke = Utilities.AddStroke(Button, Theme.Color("Border"), 1)
	local Layout = Utilities.AddListLayout(Button, Enum.FillDirection.Horizontal, 10, Enum.HorizontalAlignment.Left)
	Layout.VerticalAlignment = Enum.VerticalAlignment.Center
	Layout.Padding = UDim.new(0, 12)

	local Indicator = Utilities.Create("Frame", {
		BackgroundColor3 = Theme.Color("Accent"),
		BorderSizePixel = 0,
		Size = UDim2.new(0, 3, 0.6, 0),
		Position = UDim2.new(0, 0, 0.2, 0),
		Parent = Button,
	})
	local IndicatorCorner = Utilities.Roundify(Indicator, 999)

	if self.Icon then
		local IconFrame = Icons.Create(self.Icon, Theme.Color("TextMuted"), 20)
		IconFrame.Parent = Button
		self.IconFrame = IconFrame
	end

	local Label = Utilities.Create("TextLabel", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, -40, 1, 0),
		Font = Theme.Typography("FontSemibold"),
		TextSize = Theme.Typography("BodySize"),
		TextColor3 = Theme.Color("TextMuted"),
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = self.Title,
		Parent = Button,
	})
	self.Button = Button
	self.Label = Label
	self.Indicator = Indicator
	self.Stroke = Stroke

	local Click = Button.MouseButton1Click:Connect(function()
		self.Window:SelectTab(self)
	end)
	self.Cleanup:AddConnection(Click)
	local Enter = Button.MouseEnter:Connect(function()
		if not self.Selected then
			self.Animation:Animate(Button, "BackgroundColor3", Theme.Color("SurfaceHover"), { Duration = 0.12 })
		end
	end)
	local Leave = Button.MouseLeave:Connect(function()
		if not self.Selected then
			self.Animation:Animate(Button, "BackgroundColor3", Theme.Color("Surface"), { Duration = 0.12 })
		end
	end)
	self.Cleanup:AddConnection(Enter)
	self.Cleanup:AddConnection(Leave)
end

function Tabs:Select()
	self.Selected = true
	local Theme = self.Theme
	self.Animation:Animate(self.Button, "BackgroundColor3", Theme.Color("SurfaceActive"), { Duration = 0.2 })
	self.Animation:Animate(self.Label, "TextColor3", Theme.Color("Text"), { Duration = 0.2 })
	self.Animation:Animate(self.Indicator, "Size", UDim2.new(0, 3, 0.6, 0), { Duration = 0.2 })
	self.Animation:Animate(self.Stroke, "Color", Theme.Color("Accent"), { Duration = 0.2 })
	if self.IconFrame then
		self.Animation:Animate(self.IconFrame, "ImageColor3", Theme.Color("Accent"), { Duration = 0.2 })
	end
	self.ContentFrame = self.Window.ContentScroll
end

function Tabs:Deselect()
	self.Selected = false
	local Theme = self.Theme
	self.Animation:Animate(self.Button, "BackgroundColor3", Theme.Color("Surface"), { Duration = 0.2 })
	self.Animation:Animate(self.Label, "TextColor3", Theme.Color("TextMuted"), { Duration = 0.2 })
	self.Animation:Animate(self.Indicator, "Size", UDim2.new(0, 3, 0, 0), { Duration = 0.2 })
	self.Animation:Animate(self.Stroke, "Color", Theme.Color("Border"), { Duration = 0.2 })
	if self.IconFrame then
		self.Animation:Animate(self.IconFrame, "ImageColor3", Theme.Color("TextMuted"), { Duration = 0.2 })
	end
end

function Tabs:_CreateWidget(WidgetModule, Options)
	Options = Options or {}
	local Widget = WidgetModule.new(self.Application, self.Window.ContentScroll, Options)
	table.insert(self.Widgets, Widget)
	return Widget
end

function Tabs:CreateButton(Options)
	return self:_CreateWidget(require(script.Parent.Button), Options)
end

function Tabs:CreateToggle(Options)
	return self:_CreateWidget(require(script.Parent.Toggle), Options)
end

function Tabs:CreateSlider(Options)
	return self:_CreateWidget(require(script.Parent.Slider), Options)
end

function Tabs:CreateTextbox(Options)
	return self:_CreateWidget(require(script.Parent.Textbox), Options)
end

function Tabs:CreateDropdown(Options)
	return self:_CreateWidget(require(script.Parent.Dropdown), Options)
end

function Tabs:CreateSearchDropdown(Options)
	return self:_CreateWidget(require(script.Parent.SearchDropdown), Options)
end

function Tabs:CreateKeybind(Options)
	return self:_CreateWidget(require(script.Parent.Keybind), Options)
end

function Tabs:CreateColorPicker(Options)
	return self:_CreateWidget(require(script.Parent.ColorPicker), Options)
end

function Tabs:CreateGradientPicker(Options)
	return self:_CreateWidget(require(script.Parent.GradientPicker), Options)
end

function Tabs:CreateLabel(Options)
	return self:_CreateWidget(require(script.Parent.Label), Options)
end

function Tabs:CreateParagraph(Options)
	return self:_CreateWidget(require(script.Parent.Paragraph), Options)
end

function Tabs:CreateSection(Options)
	Options = Options or {}
	local Section = require(script.Parent.Section).new(self.Application, self.Window.ContentScroll, Options)
	table.insert(self.Sections, Section)
	return Section
end

function Tabs:CreateDivider(Options)
	return self:_CreateWidget(require(script.Parent.Divider), Options)
end

function Tabs:CreateNotification(Options)
	return self:_CreateWidget(require(script.Parent.Notification), Options)
end

function Tabs:CreateProgress(Options)
	return self:_CreateWidget(require(script.Parent.Progress), Options)
end

function Tabs:CreateProgressRing(Options)
	return self:_CreateWidget(require(script.Parent.ProgressRing), Options)
end

function Tabs:CreateAccordion(Options)
	return self:_CreateWidget(require(script.Parent.Accordion), Options)
end

function Tabs:CreateTreeView(Options)
	return self:_CreateWidget(require(script.Parent.TreeView), Options)
end

function Tabs:CreateTable(Options)
	return self:_CreateWidget(require(script.Parent.Table), Options)
end

function Tabs:CreateConsole(Options)
	return self:_CreateWidget(require(script.Parent.Console), Options)
end

function Tabs:CreateTerminal(Options)
	return self:_CreateWidget(require(script.Parent.Terminal), Options)
end

function Tabs:CreateMarkdown(Options)
	return self:_CreateWidget(require(script.Parent.Markdown), Options)
end

function Tabs:CreateCodeEditor(Options)
	return self:_CreateWidget(require(script.Parent.CodeEditor), Options)
end

function Tabs:CreateGraph(Options)
	return self:_CreateWidget(require(script.Parent.Graph), Options)
end

function Tabs:CreateChart(Options)
	return self:_CreateWidget(require(script.Parent.Chart), Options)
end

function Tabs:CreateTimeline(Options)
	return self:_CreateWidget(require(script.Parent.Timeline), Options)
end

function Tabs:CreateImage(Options)
	return self:_CreateWidget(require(script.Parent.Image), Options)
end

function Tabs:CreateVideo(Options)
	return self:_CreateWidget(require(script.Parent.Video), Options)
end

function Tabs:CreateAudio(Options)
	return self:_CreateWidget(require(script.Parent.Audio), Options)
end

function Tabs:CreateFileExplorer(Options)
	return self:_CreateWidget(require(script.Parent.FileExplorer), Options)
end

function Tabs:CreateNestedTabs(Options)
	return self:_CreateWidget(require(script.Parent.NestedTabs), Options)
end

function Tabs:SetTitle(Title)
	self.Title = Title
	self.Label.Text = Title
end

function Tabs:SetIcon(Icon)
	self.Icon = Icon
end

function Tabs:Destroy()
	self.Cleanup:Destroy()
	if self.Button then
		self.Button:Destroy()
	end
	for _, Widget in ipairs(self.Widgets) do
		if Widget.Destroy then
			pcall(Widget.Destroy, Widget)
		end
	end
end

return Tabs
