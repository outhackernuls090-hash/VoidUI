local Utilities = require(script.Parent.Parent.Core.Utilities)
local Base = require(script.Parent.Base)
local Icons = require(script.Parent.Parent.Assets.Icons)

local GradientPicker = {}
GradientPicker.__index = setmetatable(GradientPicker, Base)

function GradientPicker.new(Application, Parent, Options)
	local self = setmetatable(Base.new(Application, Parent, Options), GradientPicker)
	self.Stops = Options.Default or {
		{ Position = 0, Color = Color3.fromRGB(124, 162, 255) },
		{ Position = 1, Color = Color3.fromRGB(170, 130, 255) },
	}
	self.Label = Options.Label or "Gradient"
	self.Callback = Options.Callback
	self.Open = false
	self.SelectedStop = 1
	self:_Build()
	return self
end

function GradientPicker:_Build()
	local Theme = self.Theme
	local Container = self:_CreateContainer(self.Label ~= "" and 66 or 44)
	local Card = self:_CreateCard(Container.AbsoluteSize.Y, {
		AutomaticSize = Enum.AutomaticSize.Y,
	})

	local Layout = Utilities.AddListLayout(Card, Enum.FillDirection.Horizontal, 12, Enum.HorizontalAlignment.Left)
	Layout.VerticalAlignment = Enum.VerticalAlignment.Center
	local Padding = Utilities.AddPadding(Card, 12)

	local TextBlock = Utilities.Create("Frame", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, -60, 1, 0),
		Parent = Card,
	})
	local TextLayout = Utilities.AddListLayout(TextBlock, Enum.FillDirection.Vertical, 2)
	local Label = Utilities.Create("TextLabel", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 18),
		Font = Theme.Typography("FontSemibold"),
		TextSize = Theme.Typography("BodySize"),
		TextColor3 = Theme.Color("Text"),
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = self.Label,
		Parent = TextBlock,
	})

	local Preview = Utilities.Create("TextButton", {
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(40, 40),
		AutoButtonColor = false,
		Text = "",
		Parent = Card,
	})
	local PreviewCorner = Utilities.Roundify(Preview, Theme.Layout("RadiusSmall"))
	local PreviewStroke = Utilities.AddStroke(Preview, Theme.Color("Border"), 1)
	local PreviewGradient = Utilities.AddGradient(Preview, self:_ToSequence(), 90)

	self.Preview = Preview
	self.PreviewGradient = PreviewGradient

	self:_BuildPanel()
	self:_SetupInteractions(Preview)
end

function GradientPicker:_ToSequence()
	local Keypoints = {}
	for _, Stop in ipairs(self.Stops) do
		table.insert(Keypoints, ColorSequenceKeypoint.new(Stop.Position, Stop.Color))
	end
	table.sort(Keypoints, function(A, B)
		return A.Time < B.Time
	end)
	return ColorSequence.new(Keypoints)
end

function GradientPicker:_BuildPanel()
	local Theme = self.Theme
	local Panel = Utilities.Create("Frame", {
		BackgroundColor3 = Theme.Color("CardElevated"),
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 0),
		ClipsDescendants = true,
		Visible = false,
		Parent = self.Container,
	})
	local PanelCorner = Utilities.Roundify(Panel, Theme.Layout("RadiusSmall"))
	local PanelStroke = Utilities.AddStroke(Panel, Theme.Color("Border"), 1)
	local PanelPadding = Utilities.AddPadding(Panel, 12)
	local PanelLayout = Utilities.AddListLayout(Panel, Enum.FillDirection.Vertical, 10, Enum.HorizontalAlignment.Center)

	local Bar = Utilities.Create("TextButton", {
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 24),
		AutoButtonColor = false,
		Text = "",
		Parent = Panel,
	})
	local BarCorner = Utilities.Roundify(Bar, 999)
	local BarGradient = Utilities.AddGradient(Bar, self:_ToSequence(), 0)

	local ColorRow = Utilities.Create("Frame", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 40),
		Parent = Panel,
	})
	local ColorRowLayout = Utilities.AddListLayout(ColorRow, Enum.FillDirection.Horizontal, 8, Enum.HorizontalAlignment.Left)
	ColorRowLayout.VerticalAlignment = Enum.VerticalAlignment.Center

	local Swatch = Utilities.Create("TextButton", {
		BackgroundColor3 = self.Stops[self.SelectedStop].Color,
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(40, 40),
		AutoButtonColor = false,
		Parent = ColorRow,
	})
	local SwatchCorner = Utilities.Roundify(Swatch, Theme.Layout("RadiusSmall"))
	local SwatchStroke = Utilities.AddStroke(Swatch, Theme.Color("Border"), 1)

	local HueBar = Utilities.Create("TextButton", {
		BorderSizePixel = 0,
		Size = UDim2.new(1, -48, 0, 16),
		AutoButtonColor = false,
		Text = "",
		Parent = ColorRow,
	})
	local HueBarCorner = Utilities.Roundify(HueBar, 999)
	local HueGradient = Utilities.AddGradient(HueBar, ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 1, 1)),
		ColorSequenceKeypoint.new(0.17, Color3.fromHSV(0.17, 1, 1)),
		ColorSequenceKeypoint.new(0.33, Color3.fromHSV(0.33, 1, 1)),
		ColorSequenceKeypoint.new(0.5, Color3.fromHSV(0.5, 1, 1)),
		ColorSequenceKeypoint.new(0.67, Color3.fromHSV(0.67, 1, 1)),
		ColorSequenceKeypoint.new(0.83, Color3.fromHSV(0.83, 1, 1)),
		ColorSequenceKeypoint.new(1, Color3.fromHSV(1, 1, 1)),
	}), 0)

	self.Panel = Panel
	self.Bar = Bar
	self.BarGradient = BarGradient
	self.Swatch = Swatch
	self.HueBar = HueBar

	self:_SetupPanelInteractions(Bar, HueBar, Swatch)
end

function GradientPicker:_SetupPanelInteractions(Bar, HueBar, Swatch)
	local UserInputService = game:GetService("UserInputService")
	local BarDrag = false
	local HueDrag = false

	local function UpdateBar(Input)
		local Pos = Input.Position - Bar.AbsolutePosition
		local Size = Bar.AbsoluteSize
		local Ratio = Utilities.Clamp(Pos.X / Size.X, 0, 1)
		self.Stops[self.SelectedStop].Position = Ratio
		self:_Refresh()
	end
	local function UpdateHue(Input)
		local Pos = Input.Position - HueBar.AbsolutePosition
		local Size = HueBar.AbsoluteSize
		local Hue = Utilities.Clamp(Pos.X / Size.X, 0, 1)
		local _, S, V = Color3.toHSV(self.Stops[self.SelectedStop].Color)
		self.Stops[self.SelectedStop].Color = Color3.fromHSV(Hue, S, V)
		self:_Refresh()
	end

	local BarBegin = Bar.InputBegan:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
			BarDrag = true
			UpdateBar(Input)
		end
	end)
	local HueBegin = HueBar.InputBegan:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
			HueDrag = true
			UpdateHue(Input)
		end
	end)
	local End = UserInputService.InputEnded:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
			BarDrag = false
			HueDrag = false
		end
	end)
	local Move = UserInputService.InputChanged:Connect(function(Input)
		if (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then
			if BarDrag then UpdateBar(Input) end
			if HueDrag then UpdateHue(Input) end
		end
	end)
	self.Cleanup:AddConnection(BarBegin)
	self.Cleanup:AddConnection(HueBegin)
	self.Cleanup:AddConnection(End)
	self.Cleanup:AddConnection(Move)
end

function GradientPicker:_Refresh()
	local Sequence = self:_ToSequence()
	self.PreviewGradient.Color = Sequence
	self.BarGradient.Color = Sequence
	self.Swatch.BackgroundColor3 = self.Stops[self.SelectedStop].Color
	self.Changed:Fire(Sequence)
	Utilities.SafeCall(self.Callback, Sequence)
end

function GradientPicker:_SetupInteractions(Preview)
	local Click = Preview.MouseButton1Click:Connect(function()
		self:Toggle()
	end)
	self.Cleanup:AddConnection(Click)
end

function GradientPicker:Toggle()
	self.Open = not self.Open
	self.Panel.Visible = true
	local TargetHeight = self.Open and 110 or 0
	self.Animation:Tween({
		Duration = 0.25,
		Easing = "QuadOut",
		OnUpdate = function(_, _, Progress)
			self.Panel.Size = UDim2.new(1, 0, 0, TargetHeight * Progress)
		end,
		OnComplete = function()
			if not self.Open then
				self.Panel.Visible = false
			end
		end,
	})
end

function GradientPicker:Set(Stops)
	self.Stops = Stops
	self:_Refresh()
end

function GradientPicker:Get()
	return self:_ToSequence()
end

function GradientPicker:AddStop(Color, Position)
	table.insert(self.Stops, { Position = Position or 0.5, Color = Color or Color3.fromRGB(255, 255, 255) })
	self:_Refresh()
end

function GradientPicker:RemoveStop(Index)
	table.remove(self.Stops, Index)
	self:_Refresh()
end

return GradientPicker
