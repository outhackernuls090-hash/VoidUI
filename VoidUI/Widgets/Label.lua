local Utilities = require(script.Parent.Parent.Core.Utilities)
local Base = require(script.Parent.Base)

local Label = {}
Label.__index = setmetatable(Label, Base)

function Label.new(Application, Parent, Options)
	local self = setmetatable(Base.new(Application, Parent, Options), Label)
	self.Text = Options.Text or "Label"
	self.Size = Options.Size or "Body"
	self.Color = Options.Color
	self.Align = Options.Align or Enum.TextXAlignment.Left
	self.Wrap = Options.Wrap or false
	self.Rich = Options.Rich or false
	self._Build()
	return self
end

function Label:_Build()
	local Theme = self.Theme
	local Container = self:_CreateContainer(20)
	local Label = Utilities.Create("TextLabel", {
		Name = "Label",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 1, 0),
		Font = Theme.Typography("Font"),
		TextSize = Theme.Typography(self.Size == "Body" and "BodySize" or self.Size .. "Size"),
		TextColor3 = self.Color or Theme.Color("Text"),
		TextXAlignment = self.Align,
		TextWrapped = self.Wrap,
		RichText = self.Rich,
		Text = self.Text,
		Parent = Container,
	})
	if self.Wrap then
		Label.AutomaticSize = Enum.AutomaticSize.Y
		Container.AutomaticSize = Enum.AutomaticSize.Y
	end
	self.Instance = Label
end

function Label:SetText(Text)
	self.Text = Text
	self.Instance.Text = Text
end

function Label:SetColor(Color)
	self.Color = Color
	self.Instance.TextColor3 = Color
end

function Label:SetAlign(Align)
	self.Align = Align
	self.Instance.TextXAlignment = Align
end

return Label
