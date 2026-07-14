local Utilities = require(script.Parent.Parent.Core.Utilities)
local Base = require(script.Parent.Base)

local Paragraph = {}
Paragraph.__index = setmetatable(Paragraph, Base)

function Paragraph.new(Application, Parent, Options)
	local self = setmetatable(Base.new(Application, Parent, Options), Paragraph)
	self.Title = Options.Title or ""
	self.Text = Options.Text or ""
	self:_Build()
	return self
end

function Paragraph:_Build()
	local Theme = self.Theme
	local Container = self:_CreateContainer(0)
	Container.AutomaticSize = Enum.AutomaticSize.Y
	local Card = self:_CreateCard(0, {
		AutomaticSize = Enum.AutomaticSize.Y,
	})

	local Layout = Utilities.AddListLayout(Card, Enum.FillDirection.Vertical, 4, Enum.HorizontalAlignment.Left)
	local Padding = Utilities.AddPadding(Card, 14)

	if self.Title ~= "" then
		local Title = Utilities.Create("TextLabel", {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 18),
			Font = Theme.Typography("FontBold"),
			TextSize = Theme.Typography("HeaderSize"),
			TextColor3 = Theme.Color("Text"),
			TextXAlignment = Enum.TextXAlignment.Left,
			Text = self.Title,
			Parent = Card,
		})
	end

	local Body = Utilities.Create("TextLabel", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Font = Theme.Typography("Font"),
		TextSize = Theme.Typography("BodySize"),
		TextColor3 = Theme.Color("TextMuted"),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		TextWrapped = true,
		LineHeight = 1.4,
		Text = self.Text,
		Parent = Card,
	})
	self.Instance = Body
end

function Paragraph:SetTitle(Title)
	self.Title = Title
end

function Paragraph:SetText(Text)
	self.Text = Text
	self.Instance.Text = Text
end

return Paragraph
