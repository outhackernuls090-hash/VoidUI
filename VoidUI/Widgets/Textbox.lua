local Utilities = require(script.Parent.Parent.Core.Utilities)
local Base = require(script.Parent.Base)

local Textbox = {}
Textbox.__index = setmetatable(Textbox, Base)

function Textbox.new(Application, Parent, Options)
	local self = setmetatable(Base.new(Application, Parent, Options), Textbox)
	self.Value = Options.Default or ""
	self.Placeholder = Options.Placeholder or "Type here..."
	self.Label = Options.Label or ""
	self.Callback = Options.Callback
	self.Numeric = Options.Numeric or false
	self.Password = Options.Password or false
	self.Multiline = Options.Multiline or false
	self.MaxLength = Options.MaxLength or 99999
	self._Build()
	return self
end

function Textbox:_Build()
	local Theme = self.Theme
	local Height = self.Multiline and 100 or 44
	local Container = self:_CreateContainer(self.Label ~= "" and Height + 22 or Height)
	local Card = self:_CreateCard(Container.AbsoluteSize.Y, {
		AutomaticSize = Enum.AutomaticSize.Y,
	})

	local Layout = Utilities.AddListLayout(Card, Enum.FillDirection.Vertical, 6, Enum.HorizontalAlignment.Left)
	local Padding = Utilities.AddPadding(Card, 12)

	if self.Label ~= "" then
		local Label = Utilities.Create("TextLabel", {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 16),
			Font = Theme.Typography("FontSemibold"),
			TextSize = Theme.Typography("CaptionSize"),
			TextColor3 = Theme.Color("TextMuted"),
			TextXAlignment = Enum.TextXAlignment.Left,
			Text = self.Label,
			Parent = Card,
		})
	end

	local InputClass = self.Multiline and "TextBox" or "TextBox"
	local Input = Utilities.Create(InputClass, {
		BackgroundColor3 = Theme.Color("Background"),
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, self.Multiline and 76 or 28),
		Font = Theme.Typography("Font"),
		TextSize = Theme.Typography("BodySize"),
		TextColor3 = Theme.Color("Text"),
		PlaceholderColor3 = Theme.Color("Placeholder"),
		PlaceholderText = self.Placeholder,
		Text = self.Password and "" or self.Value,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = self.Multiline and Enum.TextYAlignment.Top or Enum.TextYAlignment.Center,
		ClearTextOnFocus = false,
		MultiLine = self.Multiline,
		Parent = Card,
	})
	local InputCorner = Utilities.Roundify(Input, Theme.Layout("RadiusSmall"))
	local InputStroke = Utilities.AddStroke(Input, Theme.Color("Border"), 1)
	self.Input = Input
	self.InputStroke = InputStroke

	self:_SetupInteractions(Input)
	if self.Password then
		self:_ApplyPasswordMask()
	end
end

function Textbox:_ApplyPasswordMask()
	self.Input.Text = string.rep("•", #self.Value)
end

function Textbox:_SetupInteractions(Input)
	local Theme = self.Theme
	local Focus = Input.Focused:Connect(function()
		self._Focused = true
		self.Animation:Animate(Input, "BackgroundColor3", Theme.Color("SurfaceActive"), { Duration = 0.15 })
		self.Animation:Animate(InputStroke, "Color", Theme.Color("Accent"), { Duration = 0.15 })
		self.Renderer:ShowGlow(Input, 0.25)
	end)
	local Blur = Input.FocusLost:Connect(function(EnterPressed)
		self._Focused = false
		self.Animation:Animate(Input, "BackgroundColor3", Theme.Color("Background"), { Duration = 0.15 })
		self.Animation:Animate(InputStroke, "Color", Theme.Color("Border"), { Duration = 0.15 })
		self.Renderer:HideGlow(Input)
		if self.Password then
			self:_ApplyPasswordMask()
		end
		self.Changed:Fire(self.Value)
		Utilities.SafeCall(self.Callback, self.Value, EnterPressed)
	end)
	local Changed = Input:GetPropertyChangedSignal("Text"):Connect(function()
		local Text = Input.Text
		if #Text > self.MaxLength then
			Text = Text:sub(1, self.MaxLength)
			Input.Text = Text
		end
		if self.Numeric then
			local Num = tonumber(Text)
			if Num == nil and Text ~= "" and Text ~= "-" then
				Input.Text = self.Value
				return
			end
		end
		self.Value = Text
		if self.Password and self._Focused then
			Input.Text = Text
		end
	end)
	self.Cleanup:AddConnection(Focus)
	self.Cleanup:AddConnection(Blur)
	self.Cleanup:AddConnection(Changed)
end

function Textbox:Set(Value, Silent)
	self.Value = tostring(Value)
	if self.Password then
		self:_ApplyPasswordMask()
	else
		self.Input.Text = self.Value
	end
	if not Silent then
		self.Changed:Fire(self.Value)
	end
end

function Textbox:Get()
	return self.Value
end

function Textbox:Clear()
	self:Set("")
end

function Textbox:Focus()
	self.Input:CaptureFocus()
end

function Textbox:SetPlaceholder(Text)
	self.Placeholder = Text
	self.Input.PlaceholderText = Text
end

return Textbox
