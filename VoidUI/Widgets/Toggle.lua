local Utilities = require(script.Parent.Parent.Core.Utilities)
local Base = require(script.Parent.Base)

local Toggle = {}
Toggle.__index = setmetatable(Toggle, Base)

function Toggle.new(Application, Parent, Options)
	local self = setmetatable(Base.new(Application, Parent, Options), Toggle)
	self.Value = Options.Default or false
	self.Label = Options.Label or "Toggle"
	self.Description = Options.Description or ""
	self.Callback = Options.Callback
	self:_Build()
	return self
end

function Toggle:_Build()
	local Theme = self.Theme
	local Container = self:_CreateContainer(self.Description ~= "" and 56 or 44)
	local Card = self:_CreateCard(Container.AbsoluteSize.Y, {
		AutomaticSize = Enum.AutomaticSize.Y,
	})

	local Layout = Utilities.AddListLayout(Card, Enum.FillDirection.Horizontal, 12, Enum.HorizontalAlignment.Left)
	Layout.VerticalAlignment = Enum.VerticalAlignment.Center
	local Padding = Utilities.AddPadding(Card, 12)

	local TextBlock = Utilities.Create("Frame", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, -70, 1, 0),
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
	local Desc = Utilities.Create("TextLabel", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 14),
		Font = Theme.Typography("Font"),
		TextSize = Theme.Typography("SmallSize"),
		TextColor3 = Theme.Color("TextDim"),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextWrapped = true,
		Text = self.Description,
		Visible = self.Description ~= "",
		Parent = TextBlock,
	})

	local Switch = Utilities.Create("TextButton", {
		BackgroundColor3 = Theme.Color("SurfaceActive"),
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(46, 24),
		AutoButtonColor = false,
		Text = "",
		Parent = Card,
	})
	local SwitchCorner = Utilities.Roundify(Switch, 999)
	local SwitchStroke = Utilities.AddStroke(Switch, Theme.Color("Border"), 1)
	local Knob = Utilities.Create("Frame", {
		BackgroundColor3 = Theme.Color("Text"),
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(18, 18),
		Position = UDim2.new(0, 3, 0.5, 0),
		AnchorPoint = Vector2.new(0, 0.5),
		Parent = Switch,
	})
	local KnobCorner = Utilities.Roundify(Knob, 999)
	self.Switch = Switch
	self.Knob = Knob
	self.SwitchStroke = SwitchStroke

	self:_SetupInteractions(Switch)
	self:_UpdateVisual(false)
end

function Toggle:_SetupInteractions(Switch)
	local Click = Switch.MouseButton1Click:Connect(function()
		self:Set(not self.Value)
	end)
	self.Cleanup:AddConnection(Click)
	local Enter = Switch.MouseEnter:Connect(function()
		self.Renderer:ShowGlow(Switch, 0.3)
	end)
	local Leave = Switch.MouseLeave:Connect(function()
		self.Renderer:HideGlow(Switch)
	end)
	self.Cleanup:AddConnection(Enter)
	self.Cleanup:AddConnection(Leave)
end

function Toggle:_UpdateVisual(Animated)
	local Theme = self.Theme
	local TargetColor = self.Value and Theme.Color("Accent") or Theme.Color("SurfaceActive")
	local TargetPos = self.Value and UDim2.new(0, 25, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)
	local TargetKnob = self.Value and Theme.Color("TextInverse") or Theme.Color("Text")
	if Animated then
		self.Animation:Animate(self.Switch, "BackgroundColor3", TargetColor, { Duration = 0.25, Easing = "QuadOut" })
		self.Animation:Animate(self.Knob, "Position", TargetPos, { Duration = 0.25, Easing = "BackOut" })
		self.Animation:Animate(self.Knob, "BackgroundColor3", TargetKnob, { Duration = 0.25 })
	else
		self.Switch.BackgroundColor3 = TargetColor
		self.Knob.Position = TargetPos
		self.Knob.BackgroundColor3 = TargetKnob
	end
end

function Toggle:Set(Value, Silent)
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

function Toggle:Get()
	return self.Value
end

function Toggle:Toggle()
	self:Set(not self.Value)
end

function Toggle:SetLabel(Label)
	self.Label = Label
	self.Instance:FindFirstChild("TextLabel", true).Text = Label
end

function Toggle:_ApplyTheme()
	Base._ApplyTheme(self)
	self:_UpdateVisual(false)
end

return Toggle
