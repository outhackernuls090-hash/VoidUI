local Utilities = require(script.Parent.Utilities)
local Events = require(script.Parent.Events)
local Cleanup = require(script.Parent.Cleanup)
local Icons = require(script.Parent.Parent.Assets.Icons)

local Window = {}
Window.__index = Window

function Window.new(Application, Options)
	local self = setmetatable({}, Window)
	self.Application = Application
	self.Theme = Application.Theme
	self.Renderer = Application.Renderer
	self.Animation = Application.Animation
	self.Title = Options.Title or "VoidUI"
	self.Icon = Options.Icon or "Void"
	self.Subtitle = Options.Subtitle or ""
	self.Size = UDim2.fromOffset(
		Options.Size and Options.Size.X or self.Theme.Layout("WindowWidth"),
		Options.Size and Options.Size.Y or self.Theme.Layout("WindowHeight")
	)
	self.Position = Options.Position or UDim2.fromOffset(120, 80)
	self.ZIndex = 100
	self.Minimized = false
	self.Maximized = false
	self.Closed = false
	self.Draggable = Options.Draggable ~= false
	self.Resizable = Options.Resizable ~= false
	self.Dockable = Options.Dockable ~= false
	self.Tabs = {}
	self.ActiveTab = nil
	self.Changed = Events.new()
	self.TabChanged = Events.new()
	self.ClosedEvent = Events.new()
	self.MinimizedEvent = Events.new()
	self.Cleanup = Cleanup.new()
	self._DragData = nil
	self._ResizeData = nil
	self:_Build()
	return self
end

function Window:_Build()
	local Theme = self.Theme
	local Layer = self.Renderer:GetLayer("Windows")

	local Shadow = Utilities.Create("ImageLabel", {
		Name = "WindowShadow",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 60, 1, 60),
		Position = UDim2.fromOffset(-30, -30),
		Image = "rbxassetid://0",
		ImageTransparency = 1,
		ZIndex = self.ZIndex - 1,
		Parent = Layer,
	})

	local Main = Utilities.Create("Frame", {
		Name = "Window",
		BackgroundColor3 = Theme.Color("Background"),
		BorderSizePixel = 0,
		Size = self.Size,
		Position = self.Position,
		ZIndex = self.ZIndex,
		ClipsDescendants = true,
		Parent = Layer,
	})
	local Corner = Utilities.Roundify(Main, Theme.Layout("RadiusLarge"))
	local Stroke = Utilities.AddStroke(Main, Theme.Color("Border"), Theme.Layout("BorderThickness"))
	self.Main = Main
	self.Shadow = Shadow

	local Gradient = Utilities.AddGradient(Main, Theme.Gradient("Background"), 90)
	Gradient.Transparency = NumberSequence.new(0.85)

	local GlowEffect = self.Animation:Glow(Main, {
		Color = Theme.Color("AccentGlow"),
		Intensity = 0.25,
	})

	local Header = Utilities.Create("Frame", {
		Name = "Header",
		BackgroundColor3 = Theme.Color("BackgroundElevated"),
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, Theme.Layout("HeaderHeight")),
		ZIndex = self.ZIndex + 1,
		Parent = Main,
	})
	local HeaderCorner = Utilities.Roundify(Header, Theme.Layout("RadiusLarge"))
	local HeaderClip = Utilities.Create("Frame", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, Theme.Layout("RadiusLarge")),
		ClipsDescendants = true,
		ZIndex = self.ZIndex + 1,
		Parent = Header,
	})
	local HeaderGradient = Utilities.AddGradient(Header, Theme.Gradient("Surface"), 90)
	HeaderGradient.Transparency = NumberSequence.new(0.7)

	local HeaderContent = Utilities.Create("Frame", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 1, 0),
		ZIndex = self.ZIndex + 2,
		Parent = Header,
	})
	local HeaderLayout = Utilities.AddListLayout(HeaderContent, Enum.FillDirection.Horizontal, 10, Enum.HorizontalAlignment.Left)
	HeaderLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	HeaderLayout.Padding = UDim.new(0, 14)

	local IconFrame = Icons.Create(self.Icon, Theme.Color("Accent"), 22)
	IconFrame.LayoutOrder = 1
	IconFrame.Parent = HeaderContent

	local TitleBlock = Utilities.Create("Frame", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, -200, 1, 0),
		ZIndex = self.ZIndex + 2,
		Parent = HeaderContent,
	})
	local TitleLayout = Utilities.AddListLayout(TitleBlock, Enum.FillDirection.Vertical, 0)
	local TitleLabel = Utilities.Create("TextLabel", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 20),
		Font = Theme.Typography("FontBold"),
		TextSize = Theme.Typography("TitleSize"),
		TextColor3 = Theme.Color("Text"),
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = self.Title,
		ZIndex = self.ZIndex + 2,
		Parent = TitleBlock,
	})
	local SubtitleLabel = Utilities.Create("TextLabel", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 12),
		Font = Theme.Typography("Font"),
		TextSize = Theme.Typography("SmallSize"),
		TextColor3 = Theme.Color("TextDim"),
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = self.Subtitle,
		Visible = #self.Subtitle > 0,
		ZIndex = self.ZIndex + 2,
		Parent = TitleBlock,
	})

	local Controls = Utilities.Create("Frame", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(0, 90, 1, 0),
		ZIndex = self.ZIndex + 2,
		Parent = HeaderContent,
	})
	local ControlsLayout = Utilities.AddListLayout(Controls, Enum.FillDirection.Horizontal, 4, Enum.HorizontalAlignment.Right)
	ControlsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	ControlsLayout.Padding = UDim.new(0, 6)

	self.MinimizeButton = self:_CreateControlButton("Minus", function()
		self:Minimize()
	end)
	self.MinimizeButton.Parent = Controls
	self.MaximizeButton = self:_CreateControlButton("Square", function()
		self:ToggleMaximize()
	end)
	self.MaximizeButton.Parent = Controls
	self.CloseButton = self:_CreateControlButton("Close", function()
		self:Close()
	end, Theme.Color("Danger"))
	self.CloseButton.Parent = Controls

	local Body = Utilities.Create("Frame", {
		Name = "Body",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 1, -Theme.Layout("HeaderHeight")),
		Position = UDim2.new(0, 0, 0, Theme.Layout("HeaderHeight")),
		ZIndex = self.ZIndex + 1,
		Parent = Main,
	})

	local Sidebar = Utilities.Create("Frame", {
		Name = "Sidebar",
		BackgroundColor3 = Theme.Color("Surface"),
		BorderSizePixel = 0,
		Size = UDim2.new(0, Theme.Layout("SidebarWidth"), 1, 0),
		ZIndex = self.ZIndex + 1,
		Parent = Body,
	})
	local SidebarCorner = Utilities.Roundify(Sidebar, Theme.Layout("Radius"))
	local SidebarGradient = Utilities.AddGradient(Sidebar, Theme.Gradient("Surface"), 90)
	SidebarGradient.Transparency = NumberSequence.new(0.6)

	local TabList = Utilities.Create("ScrollingFrame", {
		Name = "TabList",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 1, -20),
		Position = UDim2.new(0, 0, 0, 10),
		ScrollBarThickness = 4,
		ScrollBarImageColor3 = Theme.Color("Scrollbar"),
		ZIndex = self.ZIndex + 2,
		Parent = Sidebar,
	})
	local TabListLayout = Utilities.AddListLayout(TabList, Enum.FillDirection.Vertical, 6, Enum.HorizontalAlignment.Center)
	TabListLayout.Padding = UDim.new(0, 6)

	local Content = Utilities.Create("Frame", {
		Name = "Content",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, -Theme.Layout("SidebarWidth"), 1, 0),
		Position = UDim2.new(0, Theme.Layout("SidebarWidth"), 0, 0),
		ZIndex = self.ZIndex + 1,
		Parent = Body,
	})

	local ContentScroll = Utilities.Create("ScrollingFrame", {
		Name = "ContentScroll",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 1, 0),
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticCanvasSize.Y,
		ScrollBarThickness = 6,
		ScrollBarImageColor3 = Theme.Color("Scrollbar"),
		ZIndex = self.ZIndex + 2,
		Parent = Content,
	})
	local ContentLayout = Utilities.AddListLayout(ContentScroll, Enum.FillDirection.Vertical, 10, Enum.HorizontalAlignment.Center)
	ContentLayout.Padding = UDim.new(0, 14)
	local ContentPadding = Utilities.AddPadding(ContentScroll, 16)

	self.Header = Header
	self.Body = Body
	self.Sidebar = Sidebar
	self.TabList = TabList
	self.Content = Content
	self.ContentScroll = ContentScroll
	self.TitleLabel = TitleLabel
	self.SubtitleLabel = SubtitleLabel
	self.GlowEffect = GlowEffect

	self:_SetupDragging()
	self:_SetupResizing()
	self:_SetupHover()

	self.Application.WindowManager:Register(self)
end

function Window:_CreateControlButton(IconName, Callback, Color)
	local Theme = self.Theme
	local Button = Utilities.Create("TextButton", {
		BackgroundColor3 = Theme.Color("SurfaceHover"),
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(28, 28),
		AutoButtonColor = false,
		Text = "",
		ZIndex = self.ZIndex + 3,
	})
	local Corner = Utilities.Roundify(Button, Theme.Layout("RadiusSmall"))
	local Icon = Icons.Create(IconName, Color or Theme.Color("TextMuted"), 16)
	Icon.ZIndex = self.ZIndex + 4
	Icon.Parent = Button
	local HoverConnection = Button.MouseEnter:Connect(function()
		self.Animation:Animate(Button, "BackgroundColor3", Theme.Color("SurfaceActive"), { Duration = 0.15 })
		self.Animation:Animate(Icon, "ImageColor3", Color or Theme.Color("Text"), { Duration = 0.15 })
	end)
	local LeaveConnection = Button.MouseLeave:Connect(function()
		self.Animation:Animate(Button, "BackgroundColor3", Theme.Color("SurfaceHover"), { Duration = 0.15 })
		self.Animation:Animate(Icon, "ImageColor3", Color or Theme.Color("TextMuted"), { Duration = 0.15 })
	end)
	local ClickConnection = Button.MouseButton1Click:Connect(function()
		pcall(Callback)
	end)
	self.Cleanup:AddConnection(HoverConnection)
	self.Cleanup:AddConnection(LeaveConnection)
	self.Cleanup:AddConnection(ClickConnection)
	return Button
end

function Window:_SetupDragging()
	if not self.Draggable then
		return
	end
	local Dragging = false
	local StartPos
	local StartMouse
	local UserInputService = game:GetService("UserInputService")

	local Begin = self.Header.InputBegan:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 then
			Dragging = true
			StartPos = self.Main.Position
			StartMouse = Input.Position
			self.Application.WindowManager:Focus(self)
		end
	end)
	local End = UserInputService.InputEnded:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 then
			Dragging = false
		end
	end)
	local Move = UserInputService.InputChanged:Connect(function(Input)
		if Dragging and Input.UserInputType == Enum.UserInputType.MouseMovement then
			local Delta = Input.Position - StartMouse
			local NewPos = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + Delta.X, StartPos.Y.Scale, StartPos.Y.Offset + Delta.Y)
			NewPos = self.Application.WindowManager:Snap(self, NewPos)
			self.Main.Position = NewPos
			self.Shadow.Position = UDim2.new(0, NewPos.X.Offset - 30, 0, NewPos.Y.Offset - 30)
			self.Position = NewPos
		end
	end)
	self.Cleanup:AddConnection(Begin)
	self.Cleanup:AddConnection(End)
	self.Cleanup:AddConnection(Move)
end

function Window:_SetupResizing()
	if not self.Resizable then
		return
	end
	local UserInputService = game:GetService("UserInputService")
	local Edges = {
		Right = Vector2.new(1, 0),
		Bottom = Vector2.new(0, 1),
		BottomRight = Vector2.new(1, 1),
	}
	for EdgeName, Direction in pairs(Edges) do
		local Handle = Utilities.Create("Frame", {
			Name = "Resize_" .. EdgeName,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(Direction.X > 0 and 0 or 1, Direction.X > 0 and 8 or 0, Direction.Y > 0 and 0 or 1, Direction.Y > 0 and 8 or 0),
			Position = UDim2.new(Direction.X, Direction.X > 0 and -4 or 0, Direction.Y, Direction.Y > 0 and -4 or 0),
			ZIndex = self.ZIndex + 5,
			Parent = self.Main,
		})
		local Resizing = false
		local StartSize
		local StartMouse
		local Begin = Handle.InputBegan:Connect(function(Input)
			if Input.UserInputType == Enum.UserInputType.MouseButton1 then
				Resizing = true
				StartSize = self.Main.AbsoluteSize
				StartMouse = Input.Position
			end
		end)
		local End = UserInputService.InputEnded:Connect(function(Input)
			if Input.UserInputType == Enum.UserInputType.MouseButton1 then
				Resizing = false
			end
		end)
		local Move = UserInputService.InputChanged:Connect(function(Input)
			if Resizing and Input.UserInputType == Enum.UserInputType.MouseMovement then
				local Delta = Input.Position - StartMouse
				local NewX = math.max(360, StartSize.X + Delta.X * Direction.X)
				local NewY = math.max(260, StartSize.Y + Delta.Y * Direction.Y)
				self:SetSize(UDim2.fromOffset(NewX, NewY))
			end
		end)
		self.Cleanup:AddConnection(Begin)
		self.Cleanup:AddConnection(End)
		self.Cleanup:AddConnection(Move)
	end
end

function Window:_SetupHover()
	local HoverConnection = self.Main.MouseEnter:Connect(function()
		self.Renderer:ShowGlow(self.Main, 0.4)
	end)
	local LeaveConnection = self.Main.MouseLeave:Connect(function()
		self.Renderer:HideGlow(self.Main)
	end)
	self.Cleanup:AddConnection(HoverConnection)
	self.Cleanup:AddConnection(LeaveConnection)
end

function Window:CreateTab(Options)
	local Tab = self.Application.Widgets.Tabs.new(self, Options)
	table.insert(self.Tabs, Tab)
	if not self.ActiveTab then
		self:SelectTab(Tab)
	end
	return Tab
end

function Window:SelectTab(Tab)
	if self.ActiveTab == Tab then
		return
	end
	if self.ActiveTab then
		self.ActiveTab:Deselect()
	end
	self.ActiveTab = Tab
	Tab:Select()
	self.TabChanged:Fire(Tab)
end

function Window:GetActiveTab()
	return self.ActiveTab
end

function Window:SetTitle(Title)
	self.Title = Title
	self.TitleLabel.Text = Title
end

function Window:SetSubtitle(Subtitle)
	self.Subtitle = Subtitle
	self.SubtitleLabel.Text = Subtitle
	self.SubtitleLabel.Visible = #Subtitle > 0
end

function Window:SetIcon(Icon)
	self.Icon = Icon
end

function Window:SetPosition(Position)
	self.Position = Position
	self.Animation:Animate(self.Main, "Position", Position, { Duration = 0.3, Easing = "QuadOut" })
	self.Shadow.Position = UDim2.new(0, Position.X.Offset - 30, 0, Position.Y.Offset - 30)
end

function Window:SetSize(Size)
	self.Size = Size
	self.Main.Size = Size
	self.Shadow.Size = UDim2.new(1, 60, 1, 60)
end

function Window:SetZIndex(ZIndex)
	self.ZIndex = ZIndex
	self.Main.ZIndex = ZIndex
	self.Shadow.ZIndex = ZIndex - 1
end

function Window:Minimize()
	if self.Minimized then
		return
	end
	self.Minimized = true
	self.Animation:Tween({
		Duration = 0.3,
		Easing = "QuadIn",
		OnUpdate = function(_, _, Progress)
			self.Main.Size = UDim2.new(self.Size.X.Scale, self.Size.X.Offset, self.Size.Y.Scale, self.Size.Y.Offset * (1 - Progress))
			self.Main.BackgroundTransparency = Progress * 0.5
		end,
	})
	self.MinimizedEvent:Fire()
end

function Window:Restore()
	if not self.Minimized then
		return
	end
	self.Minimized = false
	self.Animation:Tween({
		Duration = 0.3,
		Easing = "QuadOut",
		OnUpdate = function(_, _, Progress)
			self.Main.Size = UDim2.new(self.Size.X.Scale, self.Size.X.Offset, self.Size.Y.Scale, self.Size.Y.Offset * Progress)
			self.Main.BackgroundTransparency = (1 - Progress) * 0.5
		end,
	})
end

function Window:ToggleMaximize()
	if self.Maximized then
		self:Restore()
		self.Maximized = false
	else
		self._PreMaximize = self.Main.Position
		self.Maximized = true
		local Viewport = Utilities.GetViewportSize()
		self.Animation:Animate(self.Main, "Size", UDim2.new(1, -20, 1, -20), { Duration = 0.35, Easing = "QuadOut" })
		self.Animation:Animate(self.Main, "Position", UDim2.fromOffset(10, 10), { Duration = 0.35, Easing = "QuadOut" })
	end
end

function Window:Unfold()
	self.Main.Size = UDim2.new(0, 0, 0, 0)
	self.Main.BackgroundTransparency = 1
	self.Animation:Tween({
		Duration = 0.6,
		Easing = "BackOut",
		OnUpdate = function(_, _, Progress)
			self.Main.Size = UDim2.new(self.Size.X.Scale * Progress, self.Size.X.Offset * Progress, self.Size.Y.Scale * Progress, self.Size.Y.Offset * Progress)
			self.Main.BackgroundTransparency = 1 - Progress
		end,
	})
end

function Window:Close()
	if self.Closed then
		return
	end
	self.Closed = true
	self.Animation:Tween({
		Duration = 0.3,
		Easing = "QuadIn",
		OnUpdate = function(_, _, Progress)
			self.Main.Size = UDim2.new(self.Size.X.Scale * (1 - Progress), self.Size.X.Offset * (1 - Progress), self.Size.Y.Scale * (1 - Progress), self.Size.Y.Offset * (1 - Progress))
			self.Main.BackgroundTransparency = Progress
		end,
		OnComplete = function()
			self.Main:Destroy()
			self.Shadow:Destroy()
			self.Application.WindowManager:Unregister(self)
			self.ClosedEvent:Fire()
			self.Cleanup:Destroy()
		end,
	})
end

function Window:IsClosed()
	return self.Closed
end

function Window:SubscribeChanged(Callback)
	return self.Changed:Connect(Callback)
end

function Window:SubscribeTabChanged(Callback)
	return self.TabChanged:Connect(Callback)
end

function Window:SubscribeClosed(Callback)
	return self.ClosedEvent:Connect(Callback)
end

function Window:Destroy()
	self:Close()
end

return Window
