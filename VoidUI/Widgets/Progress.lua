local Utilities = require(script.Parent.Parent.Core.Utilities)
local Base = require(script.Parent.Base)

local Progress = {}
Progress.__index = setmetatable(Progress, Base)

function Progress.new(Application, Parent, Options)
	local self = setmetatable(Base.new(Application, Parent, Options), Progress)
	self.Value = Options.Default or 0
	self.Min = Options.Min or 0
	self.Max = Options.Max or 100
	self.Label = Options.Label or ""
	self.ShowPercent = Options.ShowPercent ~= false
	self.Callback = Options.Callback
	self:_Build()
	return self
end

function Progress:_Build()
	local Theme = self.Theme
	local Container = self:_CreateContainer(self.Label ~= "" and 56 or 24)
	local Card = self:_CreateCard(Container.AbsoluteSize.Y, {
		AutomaticSize = Enum.AutomaticSize.Y,
	})

	local Layout = Utilities.AddListLayout(Card, Enum.FillDirection.Vertical, 6, Enum.HorizontalAlignment.Left)
	local Padding = Utilities.AddPadding(Card, 12)

	if self.Label ~= "" then
		local Header = Utilities.Create("Frame", {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 18),
			Parent = Card,
		})
		local HeaderLayout = Utilities.AddListLayout(Header, Enum.FillDirection.Horizontal, 8, Enum.HorizontalAlignment.Left)
		HeaderLayout.VerticalAlignment = Enum.VerticalAlignment.Center
		local Label = Utilities.Create("TextLabel", {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, -50, 1, 0),
			Font = Theme.Typography("FontSemibold"),
			TextSize = Theme.Typography("BodySize"),
			TextColor3 = Theme.Color("Text"),
			TextXAlignment = Enum.TextXAlignment.Left,
			Text = self.Label,
			Parent = Header,
		})
		local Percent = Utilities.Create("TextLabel", {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(0, 50, 1, 0),
			Font = Theme.Typography("FontMono"),
			TextSize = Theme.Typography("CaptionSize"),
			TextColor3 = Theme.Color("Accent"),
			TextXAlignment = Enum.TextXAlignment.Right,
			Parent = Header,
		})
		self.Percent = Percent
	end

	local Track = Utilities.Create("Frame", {
		BackgroundColor3 = Theme.Color("SurfaceActive"),
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 8),
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

	self.Track = Track
	self.Fill = Fill

	self:_UpdateVisual(false)
end

function Progress:_UpdateVisual(Animated)
	local Ratio = Utilities.InverseLerp(self.Min, self.Max, self.Value)
	local Target = UDim2.new(Ratio, 0, 1, 0)
	if Animated then
		self.Animation:Animate(self.Fill, "Size", Target, { Duration = 0.3, Easing = "QuadOut" })
	else
		self.Fill.Size = Target
	end
	if self.Percent then
		self.Percent.Text = math.round(Ratio * 100) .. "%"
	end
end

function Progress:Set(Value, Silent)
	Value = Utilities.Clamp(Value, self.Min, self.Max)
	self.Value = Value
	self:_UpdateVisual(true)
	if not Silent then
		self.Changed:Fire(Value)
		Utilities.SafeCall(self.Callback, Value)
	end
end

function Progress:Get()
	return self.Value
end

function Progress:SetLabel(Label)
	self.Label = Label
	self.Instance:FindFirstChild("TextLabel", true).Text = Label
end

return Progress
