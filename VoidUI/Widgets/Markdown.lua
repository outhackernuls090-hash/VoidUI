local Utilities = require(script.Parent.Parent.Core.Utilities)
local Base = require(script.Parent.Base)

local Markdown = {}
Markdown.__index = setmetatable(Markdown, Base)

function Markdown.new(Application, Parent, Options)
	local self = setmetatable(Base.new(Application, Parent, Options), Markdown)
	self.Content = Options.Content or ""
	self._Build()
	return self
end

function Markdown:_Build()
	local Theme = self.Theme
	local Container = self:_CreateContainer(0)
	Container.AutomaticSize = Enum.AutomaticSize.Y
	local Card = self:_CreateCard(0, {
		AutomaticSize = Enum.AutomaticSize.Y,
	})
	local Padding = Utilities.AddPadding(Card, 14)
	local Layout = Utilities.AddListLayout(Card, Enum.FillDirection.Vertical, 6, Enum.HorizontalAlignment.Left)
	self.Card = Card

	self:SetContent(self.Content)
end

function Markdown:SetContent(Content)
	self.Content = Content
	for _, Child in ipairs(self.Card:GetChildren()) do
		if Child:IsA("TextLabel") or Child:IsA("Frame") then
			Child:Destroy()
		end
	end
	local Lines = Utilities.Split(Content, "\n")
	for _, Line in ipairs(Lines) do
		self:_RenderLine(Line)
	end
end

function Markdown:_RenderLine(Line)
	local Theme = self.Theme
	local Text = Line
	local Size = Theme.Typography("BodySize")
	local Color = Theme.Color("Text")
	local Font = Theme.Typography("Font")
	local Bold = false

	if Utilities.StartsWith(Line, "# ") then
		Text = Line:sub(3)
		Size = Theme.Typography("TitleSize")
		Bold = true
		Font = Theme.Typography("FontBold")
	elseif Utilities.StartsWith(Line, "## ") then
		Text = Line:sub(4)
		Size = Theme.Typography("HeaderSize")
		Bold = true
		Font = Theme.Typography("FontBold")
	elseif Utilities.StartsWith(Line, "### ") then
		Text = Line:sub(5)
		Size = Theme.Typography("SubheaderSize")
		Bold = true
		Font = Theme.Typography("FontSemibold")
	elseif Utilities.StartsWith(Line, "- ") or Utilities.StartsWith(Line, "* ") then
		Text = "• " .. Line:sub(3)
		Color = Theme.Color("TextMuted")
	elseif Utilities.StartsWith(Line, "> ") then
		Text = Line:sub(3)
		Color = Theme.Color("TextDim")
		Font = Theme.Typography("FontItalic") or Theme.Typography("Font")
	end

	Text = Text:gsub("%*%*([^%*]+)%*%*", function(Inner)
		return Inner
	end)

	local Label = Utilities.Create("TextLabel", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Font = Font,
		TextSize = Size,
		TextColor3 = Color,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		TextWrapped = true,
		LineHeight = 1.4,
		RichText = true,
		Text = Text,
		Parent = self.Card,
	})
end

return Markdown
