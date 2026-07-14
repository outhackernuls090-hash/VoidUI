local Utilities = require(script.Parent.Parent.Core.Utilities)
local Base = require(script.Parent.Base)

local Slider = {}
Slider.__index = setmetatable(Slider, Base)

function Slider.new(Application, Parent, Options)
	local self = setmetatable(Base.new(Application, Parent, Options), Slider)
	self.Value = Options.Default or Options.Min or 0
	self.Min = Options.Min or 0
	self.Max = Options.Max or 100
	self.Increment = Options.Increment or 1
	self.Label = Options.Label or "Slider"
	self.Suffix = Options.Suffix or ""
	self.Callback = Options.Callback
	self.Precision = Options.Precision or 0
	self._Dragging = false
	self._Build()
	return self
end

function Slider:_Build()
	local Theme = self.Theme
	local Container = self:_CreateContainer(64)
	local Card = self:_CreateCard(Container.AbsoluteSize.Y, {
		AutomaticSize = Enum.AutomaticSize.Y,
	})

	local Header = Utilities.Create("Frame", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 22),
		Parent = Card,
	})
	local HeaderLayout = Utilities.AddListLayout(Header, Enum.FillDirection.Horizontal, 8, Enum.HorizontalAlignment.Left)
	HeaderLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	local Padding = Utilities.AddPadding(Card, 14)

	local Label = Utilities.Create("TextLabel", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, -60, 1, 0),
		Font = Theme.Typography("FontSemibold"),
		TextSize = Theme.Typography("BodySize"),
		TextColor3 = Theme.Color("Text"),
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = self.Label,
		Parent = Header,
	})
	local ValueLabel = Utilities.Create("TextLabel", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(0, 60, 1, 0),
		Font = Theme.Typography("FontMono"),
		TextSize = Theme.Typography("CaptionSize"),
		TextColor3 = Theme.Color("Accent"),
		TextXAlignment = Enum.TextXAlignment.Right,
		Parent = Header,
	})

	local Track = Utilities.Create("TextButton", {
		BackgroundColor3 = Theme.Color("SurfaceActive"),
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 6),
		AutoButtonColor = false,
		Text = "",
		Parent = Card,
	})
	local TrackCorner = Utilities.Roundify(Track, 999)
	local Fill = Utilities.Create("Frame", {
		BackgroundColor3 = Theme.Color("Accent"),
		BorderSizePixel = 0,
		Size = UDim2.new(0, 0, 1, 0),
		Parent = Track,
	})
	local FillCorner = Utilities.Roundify(Fill, 999)
	local FillGradient = Utilities.AddGradient(Fill, Theme.Gradient("Accent"), 90)
	local Knob = Utilities.Create("Frame", {
		BackgroundColor3 = Theme.Color("Text"),
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(16, 16),
		Position = UDim2.new(0, 0, 0.5, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Parent = Track,
	})
	local KnobCorner = Utilities.Roundify(Knob, 999)
	local KnobStroke = Utilities.AddStroke(Knob, Theme.Color("AccentLight"), 2)

	self.Track = Track
	self.Fill = Fill
	self.Knob = Knob
	self.ValueLabel = ValueLabel

	self:_SetupInteractions(Track)
	self:_UpdateVisual(false)
end

function Slider:_SetupInteractions(Track)
	local UserInputService = game:GetService("UserInputService")
	local function UpdateFromInput(Input)
		local Absolute = Track.AbsolutePosition
		local Size = Track.AbsoluteSize
		local Ratio = Utilities.Clamp((Input.Position.X - Absolute.X) / Size.X, 0, 1)
		local Raw = Utilities.Lerp(self.Min, self.Max, Ratio)
		local Snapped = Utilities.Snap(Raw, self.Increment)
		Snapped = Utilities.Clamp(Snapped, self.Min, self.Max)
		Snapped = Utilities.Round(Snapped, self.Precision)
		self:Set(Snapped)
	end
	local Begin = Track.InputBegan:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
			self._Dragging = true
			UpdateFromInput(Input)
		end
	end)
	local End = UserInputService.InputEnded:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
			self._Dragging = false
		end
	end)
	local Move = UserInputService.InputChanged:Connect(function(Input)
		if self._Dragging and (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then
			UpdateFromInput(Input)
		end
	end)
	local Enter = Track.MouseEnter:Connect(function()
		self.Renderer:ShowGlow(Track, 0.3)
	end)
	local Leave = Track.MouseLeave:Connect(function()
		self.Renderer:HideGlow(Track)
	end)
	self.Cleanup:AddConnection(Begin)
	self.Cleanup:AddConnection(End)
	self.Cleanup:AddConnection(Move)
	self.Cleanup:AddConnection(Enter)
	self.Cleanup:AddConnection(Leave)
end

function Slider:_UpdateVisual(Animated)
	local Ratio = Utilities.InverseLerp(self.Min, self.Max, self.Value)
	local TargetFill = UDim2.new(Ratio, 0, 1, 0)
	local TargetKnob = UDim2.new(Ratio, 0, 0.5, 0)
	if Animated then
		self.Animation:Animate(self.Fill, "Size", TargetFill, { Duration = 0.1 })
		self.Animation:Animate(self.Knob, "Position", TargetKnob, { Duration = 0.1 })
	else
		self.Fill.Size = TargetFill
		self.Knob.Position = TargetKnob
	end
	self.ValueLabel.Text = tostring(self.Value) .. self.Suffix
end

function Slider:Set(Value, Silent)
	Value = Utilities.Clamp(Value, self.Min, self.Max)
	if self.Value == Value then
		return
	end
	self.Value = Value
	self:_UpdateVisual(true)
	if not Silent then
		self.Changed:Fire(Value)
		Utilities.SafeCall(self.Callback, Value)
	end
end

function Slider:Get()
	return self.Value
end

function Slider:SetRange(Min, Max)
	self.Min = Min
	self.Max = Max
	self:Set(Utilities.Clamp(self.Value, Min, Max))
end

function Slider:SetLabel(Label)
	self.Label = Label
	self.Instance:FindFirstChild("TextLabel", true).Text = Label
end

return Slider
