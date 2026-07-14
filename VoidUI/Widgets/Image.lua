local Utilities = require(script.Parent.Parent.Core.Utilities)
local Base = require(script.Parent.Base)
local Images = require(script.Parent.Parent.Assets.Images)

local Image = {}
Image.__index = setmetatable(Image, Base)

function Image.new(Application, Parent, Options)
	local self = setmetatable(Base.new(Application, Parent, Options), Image)
	self.Source = Options.Source or Options.Image or ""
	self.Label = Options.Label or ""
	self.Rounded = Options.Rounded ~= false
	self:_Build()
	return self
end

function Image:_Build()
	local Theme = self.Theme
	local Height = self.Label ~= "" and 160 or 140
	local Container = self:_CreateContainer(self.Label ~= "" and Height + 24 or Height)
	local Card = self:_CreateCard(Container.AbsoluteSize.Y, {
		AutomaticSize = Enum.AutomaticSize.Y,
	})
	local Layout = Utilities.AddListLayout(Card, Enum.FillDirection.Vertical, 6, Enum.HorizontalAlignment.Center)
	local Padding = Utilities.AddPadding(Card, 8)

	local Frame = Utilities.Create("ImageLabel", {
		Image = self.Source,
		BackgroundColor3 = Theme.Color("SurfaceActive"),
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 140),
		ScaleType = Enum.ScaleType.Fit,
		Parent = Card,
	})
	if self.Rounded then
		local Corner = Utilities.Roundify(Frame, Theme.Layout("RadiusSmall"))
	end
	self.Frame = Frame

	if self.Label ~= "" then
		local Label = Utilities.Create("TextLabel", {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 16),
			Font = Theme.Typography("FontSemibold"),
			TextSize = Theme.Typography("CaptionSize"),
			TextColor3 = Theme.Color("TextMuted"),
			Text = self.Label,
			Parent = Card,
		})
	end
end

function Image:SetSource(Source)
	self.Source = Source
	self.Frame.Image = Source
end

function Image:SetLabel(Label)
	self.Label = Label
end

return Image
