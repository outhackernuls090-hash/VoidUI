local Utilities = require(script.Parent.Parent.Core.Utilities)
local Base = require(script.Parent.Base)

local ProgressRing = {}
ProgressRing.__index = setmetatable(ProgressRing, Base)

function ProgressRing.new(Application, Parent, Options)
	local self = setmetatable(Base.new(Application, Parent, Options), ProgressRing)
	self.Value = Options.Default or 0
	self.Min = Options.Min or 0
	self.Max = Options.Max or 100
	self.Size = Options.Size or 80
	self.Label = Options.Label or ""
	self:_Build()
	return self
end

function ProgressRing:_Build()
	local Theme = self.Theme
	local Container = self:_CreateContainer(self.Size + (self.Label ~= "" and 24 or 0))
	local Card = self:_CreateCard(Container.AbsoluteSize.Y, {
		AutomaticSize = Enum.AutomaticSize.Y,
	})

	local Layout = Utilities.AddListLayout(Card, Enum.FillDirection.Vertical, 6, Enum.HorizontalAlignment.Center)
	local Padding = Utilities.AddPadding(Card, 12)

	local Ring = Utilities.Create("Frame", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(self.Size, self.Size),
		Parent = Card,
	})

	local Track = Utilities.Create("ImageLabel", {
		Image = "rbxassetid://0",
		ImageTransparency = 1,
		BackgroundColor3 = Theme.Color("SurfaceActive"),
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		Parent = Ring,
	})
	local TrackCorner = Utilities.Roundify(Track, 999)

	local Fill = Utilities.Create("ImageLabel", {
		Image = "rbxassetid://0",
		ImageTransparency = 1,
		BackgroundColor3 = Theme.Color("Accent"),
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		Parent = Ring,
	})
	local FillCorner = Utilities.Roundify(Fill, 999)
	local FillGradient = Utilities.AddGradient(Fill, Theme.Gradient("Accent"), 90)

	local Percent = Utilities.Create("TextLabel", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		Font = Theme.Typography("FontBold"),
		TextSize = math.round(self.Size * 0.28),
		TextColor3 = Theme.Color("Text"),
		Parent = Ring,
	})

	if self.Label ~= "" then
		local Label = Utilities.Create("TextLabel", {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 18),
			Font = Theme.Typography("FontSemibold"),
			TextSize = Theme.Typography("CaptionSize"),
			TextColor3 = Theme.Color("TextMuted"),
			Text = self.Label,
			Parent = Card,
		})
	end

	self.Ring = Ring
	self.Fill = Fill
	self.Percent = Percent

	self:_UpdateVisual(false)
end

function ProgressRing:_UpdateVisual(Animated)
	local Ratio = Utilities.InverseLerp(self.Min, self.Max, self.Value)
	local Target = UDim2.new(Ratio, 0, Ratio, 0)
	if Animated then
		self.Animation:Animate(self.Fill, "Size", Target, { Duration = 0.3, Easing = "QuadOut" })
	else
		self.Fill.Size = Target
	end
	self.Percent.Text = math.round(Ratio * 100) .. "%"
end

function ProgressRing:Set(Value, Silent)
	Value = Utilities.Clamp(Value, self.Min, self.Max)
	self.Value = Value
	self:_UpdateVisual(true)
	if not Silent then
		self.Changed:Fire(Value)
	end
end

function ProgressRing:Get()
	return self.Value
end

return ProgressRing
