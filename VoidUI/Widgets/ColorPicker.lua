local Utilities = require(script.Parent.Parent.Core.Utilities)
local Base = require(script.Parent.Base)
local Icons = require(script.Parent.Parent.Assets.Icons)

local ColorPicker = {}
ColorPicker.__index = setmetatable(ColorPicker, Base)

function ColorPicker.new(Application, Parent, Options)
	local self = setmetatable(Base.new(Application, Parent, Options), ColorPicker)
	self.Value = Options.Default or Color3.fromRGB(124, 162, 255)
	self.Label = Options.Label or "Color"
	self.Callback = Options.Callback
	self.Open = false
	local H, S, V = Color3.toHSV(self.Value)
	self.Hue = H
	self.Saturation = S
	self.ValueV = V
	self:_Build()
	return self
end

function ColorPicker:_Build()
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
	local HexLabel = Utilities.Create("TextLabel", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 14),
		Font = Theme.Typography("FontMono"),
		TextSize = Theme.Typography("SmallSize"),
		TextColor3 = Theme.Color("TextDim"),
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = Utilities.Color3ToHex(self.Value),
		Parent = TextBlock,
	})

	local Swatch = Utilities.Create("TextButton", {
		BackgroundColor3 = self.Value,
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(40, 40),
		AutoButtonColor = false,
		Parent = Card,
	})
	local SwatchCorner = Utilities.Roundify(Swatch, Theme.Layout("RadiusSmall"))
	local SwatchStroke = Utilities.AddStroke(Swatch, Theme.Color("Border"), 1)

	self.Swatch = Swatch
	self.HexLabel = HexLabel

	self:_BuildPanel()
	self:_SetupInteractions(Swatch)
end

function ColorPicker:_BuildPanel()
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

	local SatVal = Utilities.Create("TextButton", {
		BackgroundColor3 = Color3.fromHSV(self.Hue, 1, 1),
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 140),
		AutoButtonColor = false,
		Text = "",
		Parent = Panel,
	})
	local SatValCorner = Utilities.Roundify(SatVal, Theme.Layout("RadiusSmall"))
	local SatValGradient = Utilities.AddGradient(SatVal, ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromHSV(self.Hue, 1, 1)),
	}), 90)
	local SatValOverlay = Utilities.Create("Frame", {
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 1, 0),
		Parent = SatVal,
	})
	local OverlayGradient = Utilities.AddGradient(SatValOverlay, ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0)),
	}), 0)
	OverlayGradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(1, 1),
	})
	local Cursor = Utilities.Create("Frame", {
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(12, 12),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Parent = SatVal,
	})
	local CursorCorner = Utilities.Roundify(Cursor, 999)
	local CursorStroke = Utilities.AddStroke(Cursor, Color3.fromRGB(0, 0, 0), 2)

	local HueBar = Utilities.Create("TextButton", {
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 16),
		AutoButtonColor = false,
		Text = "",
		Parent = Panel,
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
	self.SatVal = SatVal
	self.SatValGradient = SatValGradient
	self.Cursor = Cursor
	self.HueBar = HueBar

	self:_SetupPanelInteractions(SatVal, HueBar)
	self:_UpdateCursor()
end

function ColorPicker:_SetupPanelInteractions(SatVal, HueBar)
	local UserInputService = game:GetService("UserInputService")
	local SV_Drag = false
	local Hue_Drag = false

	local function UpdateSV(Input)
		local Pos = Input.Position - SatVal.AbsolutePosition
		local Size = SatVal.AbsoluteSize
		self.Saturation = Utilities.Clamp(Pos.X / Size.X, 0, 1)
		self.ValueV = Utilities.Clamp(1 - Pos.Y / Size.Y, 0, 1)
		self:_ApplyColor()
	end
	local function UpdateHue(Input)
		local Pos = Input.Position - HueBar.AbsolutePosition
		local Size = HueBar.AbsoluteSize
		self.Hue = Utilities.Clamp(Pos.X / Size.X, 0, 1)
		self.SatValGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromHSV(self.Hue, 1, 1)),
		})
		self:_ApplyColor()
	end

	local SVBegin = SatVal.InputBegan:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
			SV_Drag = true
			UpdateSV(Input)
		end
	end)
	local HueBegin = HueBar.InputBegan:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
			Hue_Drag = true
			UpdateHue(Input)
		end
	end)
	local End = UserInputService.InputEnded:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
			SV_Drag = false
			Hue_Drag = false
		end
	end)
	local Move = UserInputService.InputChanged:Connect(function(Input)
		if (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then
			if SV_Drag then UpdateSV(Input) end
			if Hue_Drag then UpdateHue(Input) end
		end
	end)
	self.Cleanup:AddConnection(SVBegin)
	self.Cleanup:AddConnection(HueBegin)
	self.Cleanup:AddConnection(End)
	self.Cleanup:AddConnection(Move)
end

function ColorPicker:_ApplyColor()
	local Color = Color3.fromHSV(self.Hue, self.Saturation, self.ValueV)
	self.Value = Color
	self.Swatch.BackgroundColor3 = Color
	self.HexLabel.Text = Utilities.Color3ToHex(Color)
	self:_UpdateCursor()
	self.Changed:Fire(Color)
	Utilities.SafeCall(self.Callback, Color)
end

function ColorPicker:_UpdateCursor()
	self.Cursor.Position = UDim2.new(self.Saturation, 0, 1 - self.ValueV, 0)
end

function ColorPicker:_SetupInteractions(Swatch)
	local Click = Swatch.MouseButton1Click:Connect(function()
		self:Toggle()
	end)
	self.Cleanup:AddConnection(Click)
end

function ColorPicker:Toggle()
	self.Open = not self.Open
	self.Panel.Visible = true
	local TargetHeight = self.Open and 200 or 0
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

function ColorPicker:Set(Color)
	self.Value = Color
	local H, S, V = Color3.toHSV(Color)
	self.Hue = H
	self.Saturation = S
	self.ValueV = V
	self.Swatch.BackgroundColor3 = Color
	self.HexLabel.Text = Utilities.Color3ToHex(Color)
	self.SatValGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromHSV(self.Hue, 1, 1)),
	})
	self:_UpdateCursor()
end

function ColorPicker:Get()
	return self.Value
end

return ColorPicker
