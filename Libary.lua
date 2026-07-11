local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local TextService = game:GetService("TextService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local Library = {}
local Windows = {}

local function ProtectGui(obj)
	if syn and syn.protect_gui then
		syn.protect_gui(obj)
		obj.Parent = game.CoreGui
	elseif gethui then
		obj.Parent = gethui()
	else
		obj.Parent = game.CoreGui
	end
end

local function Tween(obj, properties, duration, easingStyle, easingDirection)
	local tween = TweenService:Create(obj, TweenInfo.new(duration or 0.25, easingStyle or Enum.EasingStyle.Quint, easingDirection or Enum.EasingDirection.Out), properties)
	tween:Play()
	return tween
end

local function Create(instanceType, properties)
	local obj = Instance.new(instanceType)
	for k, v in pairs(properties) do
		obj[k] = v
	end
	return obj
end

local function MakeDraggable(topbarObject, object)
	local Dragging = false
	local DragInput = nil
	local DragStart = nil
	local StartPosition = nil

	local function Update(input)
		local Delta = input.Position - DragStart
		local newPosition = UDim2.new(StartPosition.X.Scale, StartPosition.X.Offset + Delta.X, StartPosition.Y.Scale, StartPosition.Y.Offset + Delta.Y)
		Tween(object, {Position = newPosition}, 0.15)
	end

	topbarObject.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			Dragging = true
			DragStart = input.Position
			StartPosition = object.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					Dragging = false
				end
			end)
		end
	end)

	topbarObject.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			DragInput = input
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if input == DragInput and Dragging then
			Update(input)
		end
	end)
end

local Theme = {
	Font = Enum.Font.Gotham,
	Background = Color3.fromRGB(35, 35, 40),
	Topbar = Color3.fromRGB(40, 40, 48),
	Sidebar = Color3.fromRGB(35, 35, 40),
	TabBackground = Color3.fromRGB(30, 30, 36),
	ElementBackground = Color3.fromRGB(45, 45, 52),
	ElementBackgroundHover = Color3.fromRGB(55, 55, 64),
	ElementStroke = Color3.fromRGB(65, 65, 75),
	Primary = Color3.fromRGB(88, 155, 255),
	PrimaryHover = Color3.fromRGB(110, 170, 255),
	Text = Color3.fromRGB(240, 240, 245),
	SubText = Color3.fromRGB(175, 175, 185),
	DarkText = Color3.fromRGB(120, 120, 130),
	Success = Color3.fromRGB(85, 215, 120),
	Error = Color3.fromRGB(255, 100, 100),
	Warning = Color3.fromRGB(255, 200, 100),
	Shadow = Color3.fromRGB(0, 0, 0),
	NotificationBackground = Color3.fromRGB(40, 40, 48)
}

function Library:CreateWindow(config)
	config = config or {}
	local Title = config.Title or "Window"
	local SubTitle = config.SubTitle or ""
	local Size = config.Size or UDim2.fromOffset(600, 450)
	local TabWidth = config.TabWidth or 160
	local MinimizeKey = config.MinimizeKey

	local ScreenGui = Create("ScreenGui", {
		Name = HttpService:GenerateGUID(false),
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	})
	ProtectGui(ScreenGui)

	local MainFrame = Create("Frame", {
		Name = "MainFrame",
		Parent = ScreenGui,
		BackgroundColor3 = Theme.Background,
		BorderSizePixel = 0,
		Size = Size,
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		ClipsDescendants = true
	})

	local UICorner = Create("UICorner", {
		CornerRadius = UDim.new(0, 8),
		Parent = MainFrame
	})

	local UIStroke = Create("UIStroke", {
		Color = Theme.ElementStroke,
		Thickness = 1,
		Transparency = 0.5,
		Parent = MainFrame
	})

	local Shadow = Create("ImageLabel", {
		Name = "Shadow",
		Parent = ScreenGui,
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.new(1, 40, 1, 40),
		ZIndex = -1,
		Image = "rbxassetid://5554236805",
		ImageColor3 = Color3.fromRGB(0, 0, 0),
		ImageTransparency = 0.6,
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(23, 23, 277, 277)
	})

	Tween(Shadow, {Size = UDim2.new(1, 60, 1, 60), ImageTransparency = 0.5}, 0.5)

	local Topbar = Create("Frame", {
		Name = "Topbar",
		Parent = MainFrame,
		BackgroundColor3 = Theme.Topbar,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 48)
	})

	local TopbarLine = Create("Frame", {
		Name = "Line",
		Parent = Topbar,
		BackgroundColor3 = Theme.ElementStroke,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 1),
		Position = UDim2.new(0, 0, 1, 0)
	})

	local TitleLabel = Create("TextLabel", {
		Name = "Title",
		Parent = Topbar,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 16, 0, 0),
		Size = UDim2.new(1, -100, 1, 0),
		Font = Theme.Font,
		Text = Title,
		TextColor3 = Theme.Text,
		TextSize = 16,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center
	})

	if SubTitle ~= "" then
		TitleLabel.Text = Title .. "  <font color='rgb(175,175,185)'>" .. SubTitle .. "</font>"
		TitleLabel.RichText = true
	end

	local CloseBtn = Create("TextButton", {
		Name = "Close",
		Parent = Topbar,
		BackgroundTransparency = 1,
		Position = UDim2.new(1, -36, 0, 8),
		Size = UDim2.fromOffset(28, 28),
		Font = Theme.Font,
		Text = "×",
		TextColor3 = Theme.SubText,
		TextSize = 24,
		AutoButtonColor = false
	})

	local MinimizeBtn = Create("TextButton", {
		Name = "Minimize",
		Parent = Topbar,
		BackgroundTransparency = 1,
		Position = UDim2.new(1, -68, 0, 8),
		Size = UDim2.fromOffset(28, 28),
		Font = Theme.Font,
		Text = "−",
		TextColor3 = Theme.SubText,
		TextSize = 24,
		AutoButtonColor = false
	})

	local Content = Create("Frame", {
		Name = "Content",
		Parent = MainFrame,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 0, 48),
		Size = UDim2.new(1, 0, 1, -48)
	})

	local Sidebar = Create("Frame", {
		Name = "Sidebar",
		Parent = Content,
		BackgroundColor3 = Theme.Sidebar,
		BorderSizePixel = 0,
		Size = UDim2.new(0, TabWidth, 1, 0)
	})

	local SidebarLine = Create("Frame", {
		Name = "Line",
		Parent = Sidebar,
		BackgroundColor3 = Theme.ElementStroke,
		BorderSizePixel = 0,
		Size = UDim2.new(0, 1, 1, 0),
		Position = UDim2.new(1, 0, 0, 0)
	})

	local TabContainer = Create("ScrollingFrame", {
		Name = "TabContainer",
		Parent = Sidebar,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 1, 0),
		ScrollBarThickness = 0,
		ScrollBarImageTransparency = 1,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y
	})

	local TabListLayout = Create("UIListLayout", {
		Parent = TabContainer,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 4)
	})

	local TabPadding = Create("UIPadding", {
		Parent = TabContainer,
		PaddingLeft = UDim.new(0, 8),
		PaddingRight = UDim.new(0, 8),
		PaddingTop = UDim.new(0, 8),
		PaddingBottom = UDim.new(0, 8)
	})

	local TabContent = Create("Frame", {
		Name = "TabContent",
		Parent = Content,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.new(0, TabWidth, 0, 0),
		Size = UDim2.new(1, -TabWidth, 1, 0)
	})

	local WindowObj = {
		ScreenGui = ScreenGui,
		MainFrame = MainFrame,
		Topbar = Topbar,
		TabContent = TabContent,
		TabContainer = TabContainer,
		Tabs = {},
		ActiveTab = nil,
		Minimized = false,
		TabCount = 0
	}

	MakeDraggable(Topbar, MainFrame)

	local function ToggleMinimize()
		WindowObj.Minimized = not WindowObj.Minimized
		if WindowObj.Minimized then
			Tween(MainFrame, {Size = UDim2.new(0, Size.X.Offset, 0, 48)}, 0.3)
			Content.Visible = false
			MinimizeBtn.Text = "+"
		else
			Tween(MainFrame, {Size = Size}, 0.3)
			Content.Visible = true
			MinimizeBtn.Text = "−"
		end
	end

	CloseBtn.MouseEnter:Connect(function()
		Tween(CloseBtn, {TextColor3 = Theme.Error}, 0.15)
	end)

	CloseBtn.MouseLeave:Connect(function()
		Tween(CloseBtn, {TextColor3 = Theme.SubText}, 0.15)
	end)

	CloseBtn.MouseButton1Click:Connect(function()
		Tween(MainFrame, {Size = UDim2.fromOffset(0, 0)}, 0.3)
		Tween(Shadow, {ImageTransparency = 1}, 0.3)
		task.wait(0.3)
		ScreenGui:Destroy()
	end)

	MinimizeBtn.MouseEnter:Connect(function()
		Tween(MinimizeBtn, {TextColor3 = Theme.Text}, 0.15)
	end)

	MinimizeBtn.MouseLeave:Connect(function()
		Tween(MinimizeBtn, {TextColor3 = Theme.SubText}, 0.15)
	end)

	MinimizeBtn.MouseButton1Click:Connect(ToggleMinimize)

	if MinimizeKey then
		UserInputService.InputBegan:Connect(function(input, gameProcessed)
			if not gameProcessed and input.KeyCode == MinimizeKey then
				ToggleMinimize()
			end
		end)
	end

	function WindowObj:AddTab(tabConfig)
		tabConfig = tabConfig or {}
		local TabName = tabConfig.Title or "Tab"
		local TabIcon = tabConfig.Icon

		self.TabCount = self.TabCount + 1

		local TabButton = Create("TextButton", {
			Name = TabName .. "Button",
			Parent = self.TabContainer,
			BackgroundColor3 = Theme.TabBackground,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 36),
			Font = Theme.Font,
			Text = "",
			AutoButtonColor = false,
			LayoutOrder = self.TabCount
		})

		local TabBtnCorner = Create("UICorner", {
			CornerRadius = UDim.new(0, 6),
			Parent = TabButton
		})

		local TabBtnPadding = Create("UIPadding", {
			Parent = TabButton,
			PaddingLeft = UDim.new(0, 10)
		})

		local TabIconLabel = nil
		if TabIcon then
			TabIconLabel = Create("ImageLabel", {
				Name = "Icon",
				Parent = TabButton,
				BackgroundTransparency = 1,
				Size = UDim2.fromOffset(18, 18),
				Position = UDim2.new(0, 0, 0.5, 0),
				AnchorPoint = Vector2.new(0, 0.5),
				Image = TabIcon,
				ImageColor3 = Theme.SubText
			})
		end

		local TabText = Create("TextLabel", {
			Name = "Title",
			Parent = TabButton,
			BackgroundTransparency = 1,
			Position = TabIcon and UDim2.new(0, 26, 0, 0) or UDim2.new(0, 0, 0, 0),
			Size = TabIcon and UDim2.new(1, -26, 1, 0) or UDim2.new(1, 0, 1, 0),
			Font = Theme.Font,
			Text = TabName,
			TextColor3 = Theme.SubText,
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Center
		})

		local TabFrame = Create("ScrollingFrame", {
			Name = TabName .. "Content",
			Parent = self.TabContent,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 1, 0),
			ScrollBarThickness = 2,
			ScrollBarImageColor3 = Theme.ElementStroke,
			CanvasSize = UDim2.new(0, 0, 0, 0),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			Visible = false
		})

		local TabContentPadding = Create("UIPadding", {
			Parent = TabFrame,
			PaddingLeft = UDim.new(0, 12),
			PaddingRight = UDim.new(0, 12),
			PaddingTop = UDim.new(0, 12),
			PaddingBottom = UDim.new(0, 12)
		})

		local TabContentList = Create("UIListLayout", {
			Parent = TabFrame,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 8)
		})

		local TabObj = {
			Button = TabButton,
			Frame = TabFrame,
			Name = TabName,
			Elements = {}
		}

		table.insert(self.Tabs, TabObj)

		if not self.ActiveTab then
			self.ActiveTab = TabObj
			TabFrame.Visible = true
			TabButton.BackgroundColor3 = Theme.ElementBackground
			TabText.TextColor3 = Theme.Text
			if TabIconLabel then
				TabIconLabel.ImageColor3 = Theme.Primary
			end

			local Indicator = Create("Frame", {
				Name = "Indicator",
				Parent = TabButton,
				BackgroundColor3 = Theme.Primary,
				BorderSizePixel = 0,
				Size = UDim2.new(0, 3, 0.6, 0),
				Position = UDim2.new(0, -10, 0.5, 0),
				AnchorPoint = Vector2.new(0, 0.5)
			})
			local IndicatorCorner = Create("UICorner", {
				CornerRadius = UDim.new(0, 2),
				Parent = Indicator
			})
			TabObj.Indicator = Indicator
		end

		TabButton.MouseButton1Click:Connect(function()
			if self.ActiveTab == TabObj then return end

			if self.ActiveTab then
				self.ActiveTab.Frame.Visible = false
				self.ActiveTab.Button.BackgroundColor3 = Theme.TabBackground
				self.ActiveTab.Button.Title.TextColor3 = Theme.SubText
				if self.ActiveTab.Button:FindFirstChild("Icon") then
					self.ActiveTab.Button.Icon.ImageColor3 = Theme.SubText
				end
				if self.ActiveTab.Indicator then
					self.ActiveTab.Indicator:Destroy()
					self.ActiveTab.Indicator = nil
				end
			end

			self.ActiveTab = TabObj
			TabFrame.Visible = true

			Tween(TabButton, {BackgroundColor3 = Theme.ElementBackground}, 0.2)
			TabText.TextColor3 = Theme.Text
			if TabIconLabel then
				Tween(TabIconLabel, {ImageColor3 = Theme.Primary}, 0.2)
			end

			local NewIndicator = Create("Frame", {
				Name = "Indicator",
				Parent = TabButton,
				BackgroundColor3 = Theme.Primary,
				BorderSizePixel = 0,
				Size = UDim2.new(0, 0, 0.6, 0),
				Position = UDim2.new(0, -10, 0.5, 0),
				AnchorPoint = Vector2.new(0, 0.5)
			})
			local NewIndicatorCorner = Create("UICorner", {
				CornerRadius = UDim.new(0, 2),
				Parent = NewIndicator
			})
			TabObj.Indicator = NewIndicator
			Tween(NewIndicator, {Size = UDim2.new(0, 3, 0.6, 0)}, 0.2)
		end)

		TabButton.MouseEnter:Connect(function()
			if self.ActiveTab ~= TabObj then
				Tween(TabButton, {BackgroundColor3 = Theme.ElementBackgroundHover}, 0.15)
			end
		end)

		TabButton.MouseLeave:Connect(function()
			if self.ActiveTab ~= TabObj then
				Tween(TabButton, {BackgroundColor3 = Theme.TabBackground}, 0.15)
			end
		end)

		function TabObj:AddButton(btnConfig)
			btnConfig = btnConfig or {}
			local Title = btnConfig.Title or "Button"
			local Description = btnConfig.Description
			local Callback = btnConfig.Callback or function() end

			local ButtonFrame = Create("Frame", {
				Name = Title,
				Parent = self.Frame,
				BackgroundColor3 = Theme.ElementBackground,
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 0, Description and 64 or 40)
			})

			local ButtonCorner = Create("UICorner", {
				CornerRadius = UDim.new(0, 6),
				Parent = ButtonFrame
			})

			local ButtonStroke = Create("UIStroke", {
				Color = Theme.ElementStroke,
				Thickness = 1,
				Transparency = 0.5,
				Parent = ButtonFrame
			})

			local TitleLabel = Create("TextLabel", {
				Name = "Title",
				Parent = ButtonFrame,
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 12, 0, 0),
				Size = UDim2.new(1, -24, 0, 40),
				Font = Theme.Font,
				Text = Title,
				TextColor3 = Theme.Text,
				TextSize = 14,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Center
			})

			if Description then
				TitleLabel.Size = UDim2.new(1, -24, 0, 24)
				TitleLabel.Position = UDim2.new(0, 12, 0, 8)

				local DescLabel = Create("TextLabel", {
					Name = "Description",
					Parent = ButtonFrame,
					BackgroundTransparency = 1,
					Position = UDim2.new(0, 12, 0, 32),
					Size = UDim2.new(1, -24, 0, 20),
					Font = Theme.Font,
					Text = Description,
					TextColor3 = Theme.SubText,
					TextSize = 12,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextYAlignment = Enum.TextYAlignment.Top
				})
				ButtonFrame.Size = UDim2.new(1, 0, 0, 60)
			end

			local ClickButton = Create("TextButton", {
				Name = "Click",
				Parent = ButtonFrame,
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 1, 0),
				Text = ""
			})

			ClickButton.MouseEnter:Connect(function()
				Tween(ButtonFrame, {BackgroundColor3 = Theme.ElementBackgroundHover}, 0.15)
				Tween(ButtonStroke, {Color = Theme.Primary}, 0.15)
			end)

			ClickButton.MouseLeave:Connect(function()
				Tween(ButtonFrame, {BackgroundColor3 = Theme.ElementBackground}, 0.15)
				Tween(ButtonStroke, {Color = Theme.ElementStroke}, 0.15)
			end)

			ClickButton.MouseButton1Down:Connect(function()
				Tween(ButtonFrame, {BackgroundColor3 = Theme.Primary}, 0.1)
			end)

			ClickButton.MouseButton1Up:Connect(function()
				Tween(ButtonFrame, {BackgroundColor3 = Theme.ElementBackgroundHover}, 0.1)
			end)

			ClickButton.MouseButton1Click:Connect(function()
				Callback()
			end)

			return ButtonFrame
		end

		function TabObj:AddToggle(toggleConfig)
			toggleConfig = toggleConfig or {}
			local Title = toggleConfig.Title or "Toggle"
			local Default = toggleConfig.Default or false
			local Callback = toggleConfig.Callback or function() end

			local ToggleFrame = Create("Frame", {
				Name = Title,
				Parent = self.Frame,
				BackgroundColor3 = Theme.ElementBackground,
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 0, 40)
			})

			local ToggleCorner = Create("UICorner", {
				CornerRadius = UDim.new(0, 6),
				Parent = ToggleFrame
			})

			local ToggleStroke = Create("UIStroke", {
				Color = Theme.ElementStroke,
				Thickness = 1,
				Transparency = 0.5,
				Parent = ToggleFrame
			})

			local TitleLabel = Create("TextLabel", {
				Name = "Title",
				Parent = ToggleFrame,
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 12, 0, 0),
				Size = UDim2.new(1, -70, 1, 0),
				Font = Theme.Font,
				Text = Title,
				TextColor3 = Theme.Text,
				TextSize = 14,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Center
			})

			local ToggleOuter = Create("Frame", {
				Name = "Outer",
				Parent = ToggleFrame,
				BackgroundColor3 = Theme.TabBackground,
				BorderSizePixel = 0,
				Position = UDim2.new(1, -48, 0.5, 0),
				AnchorPoint = Vector2.new(0, 0.5),
				Size = UDim2.fromOffset(40, 20)
			})

			local OuterCorner = Create("UICorner", {
				CornerRadius = UDim.new(1, 0),
				Parent = ToggleOuter
			})

			local ToggleInner = Create("Frame", {
				Name = "Inner",
				Parent = ToggleOuter,
				BackgroundColor3 = Theme.DarkText,
				BorderSizePixel = 0,
				Position = UDim2.new(0, 2, 0.5, 0),
				AnchorPoint = Vector2.new(0, 0.5),
				Size = UDim2.fromOffset(16, 16)
			})

			local InnerCorner = Create("UICorner", {
				CornerRadius = UDim.new(1, 0),
				Parent = ToggleInner
			})

			local ToggleBtn = Create("TextButton", {
				Name = "Click",
				Parent = ToggleFrame,
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 1, 0),
				Text = ""
			})

			local ToggleValue = Default

			local function UpdateToggle()
				if ToggleValue then
					Tween(ToggleOuter, {BackgroundColor3 = Theme.Primary}, 0.2)
					Tween(ToggleInner, {BackgroundColor3 = Theme.Text, Position = UDim2.new(1, -18, 0.5, 0)}, 0.2)
				else
					Tween(ToggleOuter, {BackgroundColor3 = Theme.TabBackground}, 0.2)
					Tween(ToggleInner, {BackgroundColor3 = Theme.DarkText, Position = UDim2.new(0, 2, 0.5, 0)}, 0.2)
				end
				Callback(ToggleValue)
			end

			if Default then
				ToggleOuter.BackgroundColor3 = Theme.Primary
				ToggleInner.BackgroundColor3 = Theme.Text
				ToggleInner.Position = UDim2.new(1, -18, 0.5, 0)
				Callback(Default)
			end

			ToggleBtn.MouseButton1Click:Connect(function()
				ToggleValue = not ToggleValue
				UpdateToggle()
			end)

			return {
				Set = function(_, value)
					ToggleValue = value
					UpdateToggle()
				end,
				Get = function()
					return ToggleValue
				end
			}
		end

		function TabObj:AddSlider(sliderConfig)
			sliderConfig = sliderConfig or {}
			local Title = sliderConfig.Title or "Slider"
			local Min = sliderConfig.Min or 0
			local Max = sliderConfig.Max or 100
			local Default = sliderConfig.Default or Min
			local Rounding = sliderConfig.Rounding or 0
			local Callback = sliderConfig.Callback or function() end

			local SliderFrame = Create("Frame", {
				Name = Title,
				Parent = self.Frame,
				BackgroundColor3 = Theme.ElementBackground,
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 0, 56)
			})

			local SliderCorner = Create("UICorner", {
				CornerRadius = UDim.new(0, 6),
				Parent = SliderFrame
			})

			local SliderStroke = Create("UIStroke", {
				Color = Theme.ElementStroke,
				Thickness = 1,
				Transparency = 0.5,
				Parent = SliderFrame
			})

			local TitleLabel = Create("TextLabel", {
				Name = "Title",
				Parent = SliderFrame,
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 12, 0, 8),
				Size = UDim2.new(1, -70, 0, 18),
				Font = Theme.Font,
				Text = Title,
				TextColor3 = Theme.Text,
				TextSize = 14,
				TextXAlignment = Enum.TextXAlignment.Left
			})

			local ValueLabel = Create("TextLabel", {
				Name = "Value",
				Parent = SliderFrame,
				BackgroundTransparency = 1,
				Position = UDim2.new(1, -60, 0, 8),
				Size = UDim2.new(0, 48, 0, 18),
				Font = Theme.Font,
				Text = tostring(Default),
				TextColor3 = Theme.Primary,
				TextSize = 14,
				TextXAlignment = Enum.TextXAlignment.Right
			})

			local SliderBar = Create("Frame", {
				Name = "Bar",
				Parent = SliderFrame,
				BackgroundColor3 = Theme.TabBackground,
				BorderSizePixel = 0,
				Position = UDim2.new(0, 12, 0, 36),
				Size = UDim2.new(1, -24, 0, 6)
			})

			local BarCorner = Create("UICorner", {
				CornerRadius = UDim.new(1, 0),
				Parent = SliderBar
			})

			local SliderFill = Create("Frame", {
				Name = "Fill",
				Parent = SliderBar,
				BackgroundColor3 = Theme.Primary,
				BorderSizePixel = 0,
				Size = UDim2.new((Default - Min) / (Max - Min), 0, 1, 0)
			})

			local FillCorner = Create("UICorner", {
				CornerRadius = UDim.new(1, 0),
				Parent = SliderFill
			})

			local SliderKnob = Create("Frame", {
				Name = "Knob",
				Parent = SliderBar,
				BackgroundColor3 = Theme.Text,
				BorderSizePixel = 0,
				Position = UDim2.new((Default - Min) / (Max - Min), -6, 0.5, -6),
				Size = UDim2.fromOffset(12, 12)
			})

			local KnobCorner = Create("UICorner", {
				CornerRadius = UDim.new(1, 0),
				Parent = SliderKnob
			})

			local Dragging = false

			local function UpdateSlider(input)
				local pos = math.clamp((input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
				local value = Min + (Max - Min) * pos
				if Rounding > 0 then
					value = math.floor(value * (10 ^ Rounding) + 0.5) / (10 ^ Rounding)
				else
					value = math.floor(value + 0.5)
				end
				value = math.clamp(value, Min, Max)

				SliderFill.Size = UDim2.new((value - Min) / (Max - Min), 0, 1, 0)
				SliderKnob.Position = UDim2.new((value - Min) / (Max - Min), -6, 0.5, -6)
				ValueLabel.Text = tostring(value)
				Callback(value)
				return value
			end

			SliderKnob.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					Dragging = true
				end
			end)

			SliderBar.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					Dragging = true
					UpdateSlider(input)
				end
			end)

			UserInputService.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					Dragging = false
				end
			end)

			UserInputService.InputChanged:Connect(function(input)
				if Dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
					UpdateSlider(input)
				end
			end)

			return SliderFrame
		end

		function TabObj:AddDropdown(dropdownConfig)
			dropdownConfig = dropdownConfig or {}
			local Title = dropdownConfig.Title or "Dropdown"
			local Values = dropdownConfig.Values or {}
			local Default = dropdownConfig.Default
			local Callback = dropdownConfig.Callback or function() end

			local DropdownFrame = Create("Frame", {
				Name = Title,
				Parent = self.Frame,
				BackgroundColor3 = Theme.ElementBackground,
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 0, 40),
				AutomaticSize = Enum.AutomaticSize.Y,
				ClipsDescendants = false
			})

			local DropdownCorner = Create("UICorner", {
				CornerRadius = UDim.new(0, 6),
				Parent = DropdownFrame
			})

			local DropdownStroke = Create("UIStroke", {
				Color = Theme.ElementStroke,
				Thickness = 1,
				Transparency = 0.5,
				Parent = DropdownFrame
			})

			local TitleLabel = Create("TextLabel", {
				Name = "Title",
				Parent = DropdownFrame,
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 12, 0, 0),
				Size = UDim2.new(1, -50, 0, 40),
				Font = Theme.Font,
				Text = Title,
				TextColor3 = Theme.Text,
				TextSize = 14,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Center
			})

			local SelectedLabel = Create("TextLabel", {
				Name = "Selected",
				Parent = DropdownFrame,
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 12, 0, 0),
				Size = UDim2.new(1, -50, 0, 40),
				Font = Theme.Font,
				Text = Default or "Select...",
				TextColor3 = Theme.SubText,
				TextSize = 14,
				TextXAlignment = Enum.TextXAlignment.Right,
				TextYAlignment = Enum.TextYAlignment.Center
			})

			local Arrow = Create("TextLabel", {
				Name = "Arrow",
				Parent = DropdownFrame,
				BackgroundTransparency = 1,
				Position = UDim2.new(1, -30, 0, 0),
				Size = UDim2.new(0, 30, 0, 40),
				Font = Theme.Font,
				Text = "▼",
				TextColor3 = Theme.SubText,
				TextSize = 12,
				TextYAlignment = Enum.TextYAlignment.Center
			})

			local DropdownBtn = Create("TextButton", {
				Name = "Click",
				Parent = DropdownFrame,
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 40),
				Text = ""
			})

			local OptionsFrame = Create("Frame", {
				Name = "Options",
				Parent = DropdownFrame,
				BackgroundColor3 = Theme.TabBackground,
				BorderSizePixel = 0,
				Position = UDim2.new(0, 0, 0, 44),
				Size = UDim2.new(1, 0, 0, 0),
				ClipsDescendants = true,
				Visible = false,
				ZIndex = 2
			})

			local OptionsCorner = Create("UICorner", {
				CornerRadius = UDim.new(0, 6),
				Parent = OptionsFrame
			})

			local OptionsStroke = Create("UIStroke", {
				Color = Theme.ElementStroke,
				Thickness = 1,
				Parent = OptionsFrame
			})

			local OptionsList = Create("UIListLayout", {
				Parent = OptionsFrame,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 2)
			})

			local OptionsPadding = Create("UIPadding", {
				Parent = OptionsFrame,
				PaddingTop = UDim.new(0, 4),
				PaddingBottom = UDim.new(0, 4),
				PaddingLeft = UDim.new(0, 4),
				PaddingRight = UDim.new(0, 4)
			})

			local Opened = false
			local Selected = Default

			local function CloseDropdown()
				Opened = false
				Tween(OptionsFrame, {Size = UDim2.new(1, 0, 0, 0)}, 0.2).Completed:Connect(function()
					OptionsFrame.Visible = false
				end)
				Tween(Arrow, {Rotation = 0}, 0.2)
			end

			for i, value in ipairs(Values) do
				local OptionBtn = Create("TextButton", {
					Name = tostring(value),
					Parent = OptionsFrame,
					BackgroundColor3 = Theme.ElementBackground,
					BorderSizePixel = 0,
					Size = UDim2.new(1, 0, 0, 32),
					Font = Theme.Font,
					Text = tostring(value),
					TextColor3 = Theme.Text,
					TextSize = 13,
					AutoButtonColor = false,
					LayoutOrder = i
				})

				local OptionCorner = Create("UICorner", {
					CornerRadius = UDim.new(0, 4),
					Parent = OptionBtn
				})

				OptionBtn.MouseEnter:Connect(function()
					Tween(OptionBtn, {BackgroundColor3 = Theme.ElementBackgroundHover}, 0.15)
				end)

				OptionBtn.MouseLeave:Connect(function()
					Tween(OptionBtn, {BackgroundColor3 = Theme.ElementBackground}, 0.15)
				end)

				OptionBtn.MouseButton1Click:Connect(function()
					Selected = value
					SelectedLabel.Text = tostring(value)
					Callback(value)
					CloseDropdown()
				end)
			end

			DropdownBtn.MouseButton1Click:Connect(function()
				Opened = not Opened
				if Opened then
					OptionsFrame.Visible = true
					local totalHeight = #Values * 34 + 8
					Tween(OptionsFrame, {Size = UDim2.new(1, 0, 0, math.min(totalHeight, 200))}, 0.2)
					Tween(Arrow, {Rotation = 180}, 0.2)
				else
					CloseDropdown()
				end
			end)

			return DropdownFrame
		end

		function TabObj:AddInput(inputConfig)
			inputConfig = inputConfig or {}
			local Title = inputConfig.Title or "Input"
			local Default = inputConfig.Default or ""
			local Placeholder = inputConfig.Placeholder or "Enter..."
			local Callback = inputConfig.Callback or function() end

			local InputFrame = Create("Frame", {
				Name = Title,
				Parent = self.Frame,
				BackgroundColor3 = Theme.ElementBackground,
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 0, 72)
			})

			local InputCorner = Create("UICorner", {
				CornerRadius = UDim.new(0, 6),
				Parent = InputFrame
			})

			local InputStroke = Create("UIStroke", {
				Color = Theme.ElementStroke,
				Thickness = 1,
				Transparency = 0.5,
				Parent = InputFrame
			})

			local TitleLabel = Create("TextLabel", {
				Name = "Title",
				Parent = InputFrame,
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 12, 0, 8),
				Size = UDim2.new(1, -24, 0, 18),
				Font = Theme.Font,
				Text = Title,
				TextColor3 = Theme.Text,
				TextSize = 14,
				TextXAlignment = Enum.TextXAlignment.Left
			})

			local TextBoxFrame = Create("Frame", {
				Name = "BoxFrame",
				Parent = InputFrame,
				BackgroundColor3 = Theme.TabBackground,
				BorderSizePixel = 0,
				Position = UDim2.new(0, 12, 0, 32),
				Size = UDim2.new(1, -24, 0, 28)
			})

			local BoxCorner = Create("UICorner", {
				CornerRadius = UDim.new(0, 4),
				Parent = TextBoxFrame
			})

			local TextBox = Create("TextBox", {
				Name = "TextBox",
				Parent = TextBoxFrame,
				BackgroundTransparency = 1,
				Size = UDim2.new(1, -12, 1, 0),
				Position = UDim2.new(0, 6, 0, 0),
				Font = Theme.Font,
				Text = Default,
				PlaceholderText = Placeholder,
				TextColor3 = Theme.Text,
				PlaceholderColor3 = Theme.DarkText,
				TextSize = 13,
				TextXAlignment = Enum.TextXAlignment.Left,
				ClearTextOnFocus = false
			})

			TextBox.Focused:Connect(function()
				Tween(TextBoxFrame, {BackgroundColor3 = Theme.ElementBackground}, 0.2)
				Tween(InputStroke, {Color = Theme.Primary}, 0.2)
			end)

			TextBox.FocusLost:Connect(function()
				Tween(TextBoxFrame, {BackgroundColor3 = Theme.TabBackground}, 0.2)
				Tween(InputStroke, {Color = Theme.ElementStroke}, 0.2)
				Callback(TextBox.Text)
			end)

			return TextBox
		end

		function TabObj:AddKeybind(keybindConfig)
			keybindConfig = keybindConfig or {}
			local Title = keybindConfig.Title or "Keybind"
			local Default = keybindConfig.Default or "None"
			local Callback = keybindConfig.Callback or function() end

			local KeybindFrame = Create("Frame", {
				Name = Title,
				Parent = self.Frame,
				BackgroundColor3 = Theme.ElementBackground,
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 0, 40)
			})

			local KeybindCorner = Create("UICorner", {
				CornerRadius = UDim.new(0, 6),
				Parent = KeybindFrame
			})

			local KeybindStroke = Create("UIStroke", {
				Color = Theme.ElementStroke,
				Thickness = 1,
				Transparency = 0.5,
				Parent = KeybindFrame
			})

			local TitleLabel = Create("TextLabel", {
				Name = "Title",
				Parent = KeybindFrame,
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 12, 0, 0),
				Size = UDim2.new(1, -100, 1, 0),
				Font = Theme.Font,
				Text = Title,
				TextColor3 = Theme.Text,
				TextSize = 14,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Center
			})

			local KeybindBtn = Create("TextButton", {
				Name = "KeybindBtn",
				Parent = KeybindFrame,
				BackgroundColor3 = Theme.TabBackground,
				BorderSizePixel = 0,
				Position = UDim2.new(1, -90, 0.5, 0),
				AnchorPoint = Vector2.new(0, 0.5),
				Size = UDim2.fromOffset(80, 28),
				Font = Theme.Font,
				Text = Default,
				TextColor3 = Theme.SubText,
				TextSize = 12,
				AutoButtonColor = false
			})

			local KeybindBtnCorner = Create("UICorner", {
				CornerRadius = UDim.new(0, 4),
				Parent = KeybindBtn
			})

			local Listening = false
			local CurrentKey = Default

			KeybindBtn.MouseButton1Click:Connect(function()
				if Listening then return end
				Listening = true
				KeybindBtn.Text = "..."
				Tween(KeybindBtn, {BackgroundColor3 = Theme.Primary}, 0.2)
			end)

			UserInputService.InputBegan:Connect(function(input, gameProcessed)
				if Listening and not gameProcessed then
					if input.UserInputType == Enum.UserInputType.Keyboard then
						CurrentKey = input.KeyCode.Name
						KeybindBtn.Text = CurrentKey
						Listening = false
						Tween(KeybindBtn, {BackgroundColor3 = Theme.TabBackground}, 0.2)
						Callback(input.KeyCode)
					elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
						CurrentKey = "MB1"
						KeybindBtn.Text = CurrentKey
						Listening = false
						Tween(KeybindBtn, {BackgroundColor3 = Theme.TabBackground}, 0.2)
					end
				elseif not gameProcessed and not Listening then
					if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode.Name == CurrentKey then
						Callback(input.KeyCode)
					elseif input.UserInputType == Enum.UserInputType.MouseButton1 and CurrentKey == "MB1" then
						Callback(Enum.UserInputType.MouseButton1)
					end
				end
			end)

			return KeybindFrame
		end

		function TabObj:AddColorpicker(colorConfig)
			colorConfig = colorConfig or {}
			local Title = colorConfig.Title or "Colorpicker"
			local Default = colorConfig.Default or Color3.fromRGB(255, 255, 255)
			local Callback = colorConfig.Callback or function() end

			local ColorFrame = Create("Frame", {
				Name = Title,
				Parent = self.Frame,
				BackgroundColor3 = Theme.ElementBackground,
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 0, 40)
			})

			local ColorCorner = Create("UICorner", {
				CornerRadius = UDim.new(0, 6),
				Parent = ColorFrame
			})

			local ColorStroke = Create("UIStroke", {
				Color = Theme.ElementStroke,
				Thickness = 1,
				Transparency = 0.5,
				Parent = ColorFrame
			})

			local TitleLabel = Create("TextLabel", {
				Name = "Title",
				Parent = ColorFrame,
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 12, 0, 0),
				Size = UDim2.new(1, -60, 1, 0),
				Font = Theme.Font,
				Text = Title,
				TextColor3 = Theme.Text,
				TextSize = 14,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Center
			})

			local ColorPreview = Create("TextButton", {
				Name = "Preview",
				Parent = ColorFrame,
				BackgroundColor3 = Default,
				BorderSizePixel = 0,
				Position = UDim2.new(1, -44, 0.5, 0),
				AnchorPoint = Vector2.new(0, 0.5),
				Size = UDim2.fromOffset(28, 28),
				Text = "",
				AutoButtonColor = false
			})

			local PreviewCorner = Create("UICorner", {
				CornerRadius = UDim.new(0, 6),
				Parent = ColorPreview
			})

			local PreviewStroke = Create("UIStroke", {
				Color = Theme.ElementStroke,
				Thickness = 2,
				Parent = ColorPreview
			})

			local PickerFrame = Create("Frame", {
				Name = "Picker",
				Parent = ColorFrame,
				BackgroundColor3 = Theme.TabBackground,
				BorderSizePixel = 0,
				Position = UDim2.new(0, 0, 0, 44),
				Size = UDim2.new(1, 0, 0, 0),
				ClipsDescendants = true,
				Visible = false,
				ZIndex = 2
			})

			local PickerCorner = Create("UICorner", {
				CornerRadius = UDim.new(0, 6),
				Parent = PickerFrame
			})

			local PickerStroke = Create("UIStroke", {
				Color = Theme.ElementStroke,
				Thickness = 1,
				Parent = PickerFrame
			})

			local PickerPadding = Create("UIPadding", {
				Parent = PickerFrame,
				PaddingTop = UDim.new(0, 8),
				PaddingBottom = UDim.new(0, 8),
				PaddingLeft = UDim.new(0, 8),
				PaddingRight = UDim.new(0, 8)
			})

			local PickerList = Create("UIListLayout", {
				Parent = PickerFrame,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 6)
			})

			local RSlider = Create("Frame", {
				Name = "R",
				Parent = PickerFrame,
				BackgroundColor3 = Theme.ElementBackground,
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 0, 28),
				LayoutOrder = 1
			})
			Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = RSlider})
			Create("TextLabel", {Name = "Label", Parent = RSlider, BackgroundTransparency = 1, Size = UDim2.new(0, 20, 1, 0), Position = UDim2.new(0, 8, 0, 0), Font = Theme.Font, Text = "R", TextColor3 = Theme.Error, TextSize = 12, TextYAlignment = Enum.TextYAlignment.Center})
			local RBox = Create("TextBox", {Name = "Box", Parent = RSlider, BackgroundTransparency = 1, Size = UDim2.new(1, -36, 1, 0), Position = UDim2.new(0, 28, 0, 0), Font = Theme.Font, Text = tostring(math.floor(Default.R * 255)), TextColor3 = Theme.Text, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Right})

			local GSlider = Create("Frame", {
				Name = "G",
				Parent = PickerFrame,
				BackgroundColor3 = Theme.ElementBackground,
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 0, 28),
				LayoutOrder = 2
			})
			Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = GSlider})
			Create("TextLabel", {Name = "Label", Parent = GSlider, BackgroundTransparency = 1, Size = UDim2.new(0, 20, 1, 0), Position = UDim2.new(0, 8, 0, 0), Font = Theme.Font, Text = "G", TextColor3 = Theme.Success, TextSize = 12, TextYAlignment = Enum.TextYAlignment.Center})
			local GBox = Create("TextBox", {Name = "Box", Parent = GSlider, BackgroundTransparency = 1, Size = UDim2.new(1, -36, 1, 0), Position = UDim2.new(0, 28, 0, 0), Font = Theme.Font, Text = tostring(math.floor(Default.G * 255)), TextColor3 = Theme.Text, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Right})

			local BSlider = Create("Frame", {
				Name = "B",
				Parent = PickerFrame,
				BackgroundColor3 = Theme.ElementBackground,
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 0, 28),
				LayoutOrder = 3
			})
			Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = BSlider})
			Create("TextLabel", {Name = "Label", Parent = BSlider, BackgroundTransparency = 1, Size = UDim2.new(0, 20, 1, 0), Position = UDim2.new(0, 8, 0, 0), Font = Theme.Font, Text = "B", TextColor3 = Theme.Primary, TextSize = 12, TextYAlignment = Enum.TextYAlignment.Center})
			local BBox = Create("TextBox", {Name = "Box", Parent = BSlider, BackgroundTransparency = 1, Size = UDim2.new(1, -36, 1, 0), Position = UDim2.new(0, 28, 0, 0), Font = Theme.Font, Text = tostring(math.floor(Default.B * 255)), TextColor3 = Theme.Text, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Right})

			local Opened = false
			local CurrentColor = Default

			local function UpdateColor()
				local r = math.clamp(tonumber(RBox.Text) or 0, 0, 255)
				local g = math.clamp(tonumber(GBox.Text) or 0, 0, 255)
				local b = math.clamp(tonumber(BBox.Text) or 0, 0, 255)
				CurrentColor = Color3.fromRGB(r, g, b)
				ColorPreview.BackgroundColor3 = CurrentColor
				Callback(CurrentColor)
			end

			RBox.FocusLost:Connect(UpdateColor)
			GBox.FocusLost:Connect(UpdateColor)
			BBox.FocusLost:Connect(UpdateColor)

			local function TogglePicker()
				Opened = not Opened
				if Opened then
					PickerFrame.Visible = true
					Tween(PickerFrame, {Size = UDim2.new(1, 0, 0, 120)}, 0.2)
				else
					Tween(PickerFrame, {Size = UDim2.new(1, 0, 0, 0)}, 0.2).Completed:Connect(function()
						PickerFrame.Visible = false
					end)
				end
			end

			ColorPreview.MouseButton1Click:Connect(TogglePicker)

			return {
				Set = function(_, color)
					CurrentColor = color
					ColorPreview.BackgroundColor3 = color
					RBox.Text = tostring(math.floor(color.R * 255))
					GBox.Text = tostring(math.floor(color.G * 255))
					BBox.Text = tostring(math.floor(color.B * 255))
					Callback(color)
				end,
				Get = function()
					return CurrentColor
				end
			}
		end

		function TabObj:AddLabel(labelConfig)
			labelConfig = labelConfig or {}
			local Text = labelConfig.Title or "Label"

			local LabelFrame = Create("Frame", {
				Name = "Label",
				Parent = self.Frame,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 0, 24)
			})

			local LabelText = Create("TextLabel", {
				Name = "Text",
				Parent = LabelFrame,
				BackgroundTransparency = 1,
				Size = UDim2.new(1, -12, 1, 0),
				Position = UDim2.new(0, 6, 0, 0),
				Font = Theme.Font,
				Text = Text,
				TextColor3 = Theme.SubText,
				TextSize = 13,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Center,
				RichText = true
			})

			return LabelText
		end

		function TabObj:AddParagraph(paraConfig)
			paraConfig = paraConfig or {}
			local Title = paraConfig.Title or "Paragraph"
			local Content = paraConfig.Content or ""

			local ParaFrame = Create("Frame", {
				Name = Title,
				Parent = self.Frame,
				BackgroundColor3 = Theme.ElementBackground,
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 0, 60),
				AutomaticSize = Enum.AutomaticSize.Y
			})

			local ParaCorner = Create("UICorner", {
				CornerRadius = UDim.new(0, 6),
				Parent = ParaFrame
			})

			local ParaStroke = Create("UIStroke", {
				Color = Theme.ElementStroke,
				Thickness = 1,
				Transparency = 0.5,
				Parent = ParaFrame
			})

			local TitleLabel = Create("TextLabel", {
				Name = "Title",
				Parent = ParaFrame,
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 12, 0, 8),
				Size = UDim2.new(1, -24, 0, 18),
				Font = Theme.Font,
				Text = Title,
				TextColor3 = Theme.Text,
				TextSize = 14,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Top
			})

			local ContentLabel = Create("TextLabel", {
				Name = "Content",
				Parent = ParaFrame,
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 12, 0, 28),
				Size = UDim2.new(1, -24, 0, 20),
				Font = Theme.Font,
				Text = Content,
				TextColor3 = Theme.SubText,
				TextSize = 12,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Top,
				TextWrapped = true
			})

			return ParaFrame
		end

		function TabObj:AddDivider()
			local DividerFrame = Create("Frame", {
				Name = "Divider",
				Parent = self.Frame,
				BackgroundColor3 = Theme.ElementStroke,
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 0, 1)
			})
			return DividerFrame
		end

		return TabObj
	end

	function WindowObj:Notify(notifyConfig)
		notifyConfig = notifyConfig or {}
		local Title = notifyConfig.Title or "Notification"
		local Content = notifyConfig.Content or ""
		local Duration = notifyConfig.Duration or 5
		local Type = notifyConfig.Type or "Info"

		local NotifGui = self.ScreenGui

		local NotifFrame = Create("Frame", {
			Name = "Notification",
			Parent = NotifGui,
			BackgroundColor3 = Theme.NotificationBackground,
			BorderSizePixel = 0,
			Position = UDim2.new(1, -20, 0, 20),
			AnchorPoint = Vector2.new(1, 0),
			Size = UDim2.fromOffset(300, 80),
			ClipsDescendants = true
		})

		local NotifCorner = Create("UICorner", {
			CornerRadius = UDim.new(0, 8),
			Parent = NotifFrame
		})

		local NotifStroke = Create("UIStroke", {
			Color = Theme.ElementStroke,
			Thickness = 1,
			Parent = NotifFrame
		})

		local AccentColor = Theme.Primary
		if Type == "Success" then AccentColor = Theme.Success
		elseif Type == "Error" then AccentColor = Theme.Error
		elseif Type == "Warning" then AccentColor = Theme.Warning end

		local AccentBar = Create("Frame", {
			Name = "Accent",
			Parent = NotifFrame,
			BackgroundColor3 = AccentColor,
			BorderSizePixel = 0,
			Size = UDim2.new(0, 4, 1, 0)
		})

		local NotifTitle = Create("TextLabel", {
			Name = "Title",
			Parent = NotifFrame,
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 16, 0, 12),
			Size = UDim2.new(1, -32, 0, 18),
			Font = Theme.Font,
			Text = Title,
			TextColor3 = Theme.Text,
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Left
		})

		local NotifContent = Create("TextLabel", {
			Name = "Content",
			Parent = NotifFrame,
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 16, 0, 34),
			Size = UDim2.new(1, -32, 0, 40),
			Font = Theme.Font,
			Text = Content,
			TextColor3 = Theme.SubText,
			TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
			TextWrapped = true
		})

		local CloseNotif = Create("TextButton", {
			Name = "Close",
			Parent = NotifFrame,
			BackgroundTransparency = 1,
			Position = UDim2.new(1, -28, 0, 8),
			Size = UDim2.fromOffset(20, 20),
			Font = Theme.Font,
			Text = "×",
			TextColor3 = Theme.SubText,
			TextSize = 18
		})

		CloseNotif.MouseButton1Click:Connect(function()
			Tween(NotifFrame, {Position = UDim2.new(1, 320, 0, NotifFrame.Position.Y.Offset)}, 0.3).Completed:Connect(function()
				NotifFrame:Destroy()
			end)
		end)

		NotifFrame.Position = UDim2.new(1, 320, 0, 20)
		Tween(NotifFrame, {Position = UDim2.new(1, -20, 0, 20)}, 0.4, Enum.EasingStyle.Back)

		task.delay(Duration, function()
			if NotifFrame and NotifFrame.Parent then
				Tween(NotifFrame, {Position = UDim2.new(1, 320, 0, NotifFrame.Position.Y.Offset)}, 0.3).Completed:Connect(function()
					if NotifFrame then
						NotifFrame:Destroy()
					end
				end)
			end
		end)
	end

	table.insert(Windows, WindowObj)
	return WindowObj
end

function Library:Notify(config)
	if #Windows > 0 then
		Windows[1]:Notify(config)
	end
end

return Library
