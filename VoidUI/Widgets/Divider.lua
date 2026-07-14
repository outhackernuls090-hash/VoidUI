local Utilities = require(script.Parent.Parent.Core.Utilities)
local Base = require(script.Parent.Base)

local Divider = {}
Divider.__index = setmetatable(Divider, Base)

function Divider.new(Application, Parent, Options)
	local self = setmetatable(Base.new(Application, Parent, Options), Divider)
	self.Orientation = Options.Orientation or "Horizontal"
	self.Text = Options.Text or ""
	self.Thickness = Options.Thickness or 1
	self:_Build()
	return self
end

function Divider:_Build()
	local Theme = self.Theme
	local IsHorizontal = self.Orientation == "Horizontal"
	local Container = self:_CreateContainer(self.Text ~= "" and 28 or self.Thickness + 12)

	if self.Text ~= "" then
		local Layout = Utilities.AddListLayout(Container, Enum.FillDirection.Horizontal, 10, Enum.HorizontalAlignment.Center)
		Layout.VerticalAlignment = Enum.VerticalAlignment.Center
		local Line1 = Utilities.Create("Frame", {
			BackgroundColor3 = Theme.Color("Border"),
			BorderSizePixel = 0,
			Size = UDim2.new(0.4, 0, 0, self.Thickness),
			Parent = Container,
		})
		local Label = Utilities.Create("TextLabel", {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(0, 0, 1, 0),
			AutomaticSize = Enum.AutomaticSize.X,
			Font = Theme.Typography("FontSemibold"),
			TextSize = Theme.Typography("SmallSize"),
			TextColor3 = Theme.Color("TextDim"),
			Text = self.Text,
			Parent = Container,
		})
		local Line2 = Utilities.Create("Frame", {
			BackgroundColor3 = Theme.Color("Border"),
			BorderSizePixel = 0,
			Size = UDim2.new(0.4, 0, 0, self.Thickness),
			Parent = Container,
		})
	else
		local Line = Utilities.Create("Frame", {
			BackgroundColor3 = Theme.Color("Border"),
			BorderSizePixel = 0,
			Size = IsHorizontal and UDim2.new(1, 0, 0, self.Thickness) or UDim2.new(0, self.Thickness, 1, 0),
			Position = IsHorizontal and UDim2.new(0, 0, 0.5, 0) or UDim2.new(0.5, 0, 0, 0),
			AnchorPoint = IsHorizontal and Vector2.new(0, 0.5) or Vector2.new(0.5, 0),
			Parent = Container,
		})
		self.Instance = Line
	end
end

function Divider:SetText(Text)
	self.Text = Text
end

return Divider
