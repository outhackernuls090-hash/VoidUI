local Forge = require(script.Parent.Forge)
local Icons = require(script.Parent.Parent.Assets.Icons)
local TabModule = require(script.Parent.Tab)

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
		Name = "Window",
		BackgroundColor3 = Theme.Background,
		BorderSizePixel = 0,
		Size = self.Size,
		Position = self.Position,
		AnchorPoint = Vector2.new(0.5, 0.5),
		ZIndex = self.ZIndex,
		ClipsDescendants = true,
		Parent = WindowsFolder,
		Skin = {
			BackgroundColor3 = "Background",
		},
	}, {
		Forge.Make("UICorner", { CornerRadius = UDim.new(0, Theme.RadiusLarge or 18) }),
		Forge.Make("UIStroke", {
			Color = Theme.Border,
			Thickness = 1,
			Transparency = 0.4,
			Skin = { Color = "Border" },
		}),
	})

	local Header = Forge.Make("Frame", {
		Name = "Header",
		BackgroundColor3 = Theme.BackgroundElevated,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, Theme.HeaderHeight or 52),
		ZIndex = self.ZIndex + 1,
		Parent = Main,
		Skin = { BackgroundColor3 = "BackgroundElevated" },
	}, {
		Forge.Make("UICorner", { CornerRadius = UDim.new(0, Theme.RadiusLarge or 18) }),
	})

	local HeaderClip = Forge.Make("Frame", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, Theme.RadiusLarge or 18),
		ClipsDescendants = true,
		ZIndex = self.ZIndex + 1,
		Parent = Header,
	})

	local HeaderContent = Forge.Make("Frame", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 1, 0),
		ZIndex = self.ZIndex + 2,
		Parent = Header,
	}, {
		Forge.Make("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			Padding = UDim.new(0, 12),
			VerticalAlignment = Enum.VerticalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
		Forge.Make("UIPadding", { PaddingLeft = UDim.new(0, 16), PaddingRight = UDim.new(0, 12) }),
	})

	local IconFrame = Icons.Create(self.Icon, Theme.Accent, 22)
	IconFrame.LayoutOrder = 1
	IconFrame.Parent = HeaderContent

	local TitleBlock = Forge.Make("Frame", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, -200, 1, 0),
		ZIndex = self.ZIndex + 2,
		Parent = HeaderContent,
	}, {
		Forge.Make("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			Padding = UDim.new(0, 0),
			VerticalAlignment = Enum.VerticalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
		Forge.Make("TextLabel", {
			Name = "Title",
			Text = self.Title,
			TextSize = 16,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextColor3 = Theme.Text,
			Size = UDim2.new(1, 0, 0, 18),
			FontFace = Font.fromEnum(Enum.Font.Gotham),
			Skin = { TextColor3 = "Text" },
		}),
		Forge.Make("TextLabel", {
			Name = "Subtitle",
			Text = self.Subtitle,
			TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextColor3 = Theme.TextDim,
			Size = UDim2.new(1, 0, 0, 14),
			Visible = #self.Subtitle > 0,
			Skin = { TextColor3 = "TextDim" },
		}),
	})

	local Controls = Forge.Make("Frame", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(0, 96, 1, 0),
		ZIndex = self.ZIndex + 2,
		Parent = HeaderContent,
	}, {
		Forge.Make("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			Padding = UDim.new(0, 6),
			VerticalAlignment = Enum.VerticalAlignment.Center,
			HorizontalAlignment = Enum.HorizontalAlignment.Right,
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
	})

	self:_CreateControlButton(Controls, "Minus", function()
		self:ToggleMinimize()
	end, Theme.TextDim)
	self:_CreateControlButton(Controls, "Square", function()
		self:ToggleMaximize()
	end, Theme.TextDim)
	self:_CreateControlButton(Controls, "Close", function()
		self:Close()
	end, Theme.Danger)

	local Body = Forge.Make("Frame", {
		Name = "Body",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 1, -(Theme.HeaderHeight or 52)),
		Position = UDim2.new(0, 0, 0, Theme.HeaderHeight or 52),
		ZIndex = self.ZIndex + 1,
		Parent = Main,
	})

	local Sidebar = Forge.Make("Frame", {
		Name = "Sidebar",
		BackgroundColor3 = Theme.Surface,
		BorderSizePixel = 0,
		Size = UDim2.new(0, Theme.SidebarWidth or 200, 1, 0),
		ZIndex = self.ZIndex + 1,
		Parent = Body,
		Skin = { BackgroundColor3 = "Surface" },
	}, {
		Forge.Make("UICorner", { CornerRadius = UDim.new(0, Theme.Radius or 12) }),
		Forge.Make("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			Padding = UDim.new(0, 6),
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
		Forge.Make("UIPadding", { PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10) }),
	})

	local Content = Forge.Make("ScrollingFrame", {
		Name = "Content",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, -(Theme.SidebarWidth or 200), 1, 0),
		Position = UDim2.new(0, Theme.SidebarWidth or 200, 0, 0),
		ZIndex = self.ZIndex + 1,
		ScrollBarThickness = 4,
		ScrollBarImageColor3 = Theme.Scrollbar,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		Parent = Body,
		Skin = { ScrollBarImageColor3 = "Scrollbar" },
	}, {
		Forge.Make("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			Padding = UDim.new(0, 8),
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
		Forge.Make("UIPadding", { PaddingLeft = UDim.new(0, 14), PaddingRight = UDim.new(0, 14), PaddingTop = UDim.new(0, 12), PaddingBottom = UDim.new(0, 12) }),
	})

	self.Main = Main
	self.Header = Header
	self.Body = Body
	self.Sidebar = Sidebar
	self.Content = Content
	self.NotifFolder = NotifFolder

	self:_EnableDrag()
end

function Window:_CreateControlButton(Parent, IconName, Callback, Color)
	local Button = Forge.Make("TextButton", {
		Size = UDim2.fromOffset(28, 28),
		BackgroundTransparency = 1,
		Text = "",
		Parent = Parent,
	}, {
		Icons.Create(IconName, Color, 16),
	})
	Button.MouseButton1Click:Connect(function()
		Forge.Guard(Callback)
	end)
	Button.MouseEnter:Connect(function()
		Forge.Guard(function()
			Button.BackgroundTransparency = 0.9
			Button.BackgroundColor3 = Color
		end)
	end)
	Button.MouseLeave:Connect(function()
		Forge.Guard(function()
			Button.BackgroundTransparency = 1
		end)
	end)
	return Button
end

function Window:_EnableDrag()
	if not self.Draggable then
		return
	end
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

function Window:CreateTab(Options)
	Options = Options or {}
	local Tab = TabModule.new(self, Options)
	table.insert(self.Tabs, Tab)
	if not self.ActiveTab then
		self:SelectTab(Tab)
	end
	return Tab
end

function Window:SelectTab(Tab)
	if self.ActiveTab and self.ActiveTab ~= Tab then
		self.ActiveTab:Deselect()
	end
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
	self.SubtitleLabel = self.Main:FindFirstChild("Header", true)
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
		Name = "Notification",
		BackgroundColor3 = Theme.BackgroundElevated,
		Size = UDim2.new(0, 300, 0, 64),
		AnchorPoint = Vector2.new(1, 0),
		ZIndex = 200,
		Parent = self.NotifFolder,
		Skin = { BackgroundColor3 = "BackgroundElevated" },
	}, {
		Forge.Make("UICorner", { CornerRadius = UDim.new(0, 10) }),
		Forge.Make("UIStroke", { Color = Theme.Border, Thickness = 1, Transparency = 0.4, Skin = { Color = "Border" } }),
		Forge.Make("TextLabel", {
			Text = Options.Title or "Notification",
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextColor3 = Color,
			Size = UDim2.new(1, -20, 0, 20),
			Position = UDim2.new(0, 12, 0, 10),
			FontFace = Font.fromEnum(Enum.Font.Gotham),
		}),
		Forge.Make("TextLabel", {
			Text = Options.Description or "",
			TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextColor3 = Theme.TextDim,
			Size = UDim2.new(1, -20, 0, 30),
			Position = UDim2.new(0, 12, 0, 32),
			TextWrapped = true,
			Skin = { TextColor3 = "TextDim" },
		}),
	})
	table.insert(self.Notifications, Notif)
	local Tween = Forge.Tween(Notif, 0.3, { BackgroundTransparency = 0 })
	Tween:Play()
	return Notif
end

return Window
