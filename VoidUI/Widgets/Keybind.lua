local Utilities = require(script.Parent.Parent.Core.Utilities)
local Base = require(script.Parent.Base)
local Icons = require(script.Parent.Parent.Assets.Icons)

local Keybind = {}
Keybind.__index = setmetatable(Keybind, Base)

function Keybind.new(Application, Parent, Options)
	local self = setmetatable(Base.new(Application, Parent, Options), Keybind)
	self.Value = Options.Default or Enum.KeyCode.F
	self.Label = Options.Label or "Keybind"
	self.Callback = Options.Callback
	self.Listening = false
	self:_Build()
	return self
end

function Keybind:_Build()
	local Theme = self.Theme
	local Container = self:_CreateContainer(44)
	local Card = self:_CreateCard(Container.AbsoluteSize.Y, {
		AutomaticSize = Enum.AutomaticSize.Y,
	})

	local Layout = Utilities.AddListLayout(Card, Enum.FillDirection.Horizontal, 12, Enum.HorizontalAlignment.Left)
	Layout.VerticalAlignment = Enum.VerticalAlignment.Center
	local Padding = Utilities.AddPadding(Card, 12)

	local Label = Utilities.Create("TextLabel", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, -90, 1, 0),
		Font = Theme.Typography("FontSemibold"),
		TextSize = Theme.Typography("BodySize"),
		TextColor3 = Theme.Color("Text"),
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = self.Label,
		Parent = Card,
	})

	local Button = Utilities.Create("TextButton", {
		BackgroundColor3 = Theme.Color("Background"),
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(80, 28),
		AutoButtonColor = false,
		Font = Theme.Typography("FontMono"),
		TextSize = Theme.Typography("CaptionSize"),
		TextColor3 = Theme.Color("Accent"),
		Text = self:_Format(self.Value),
		Parent = Card,
	})
	local ButtonCorner = Utilities.Roundify(Button, Theme.Layout("RadiusSmall"))
	local ButtonStroke = Utilities.AddStroke(Button, Theme.Color("Border"), 1)

	self.Button = Button
	self.ButtonStroke = ButtonStroke

	self:_SetupInteractions(Button)
end

function Keybind:_Format(Key)
	if type(Key) == "string" then
		return Key
	end
	local Name = tostring(Key):gsub("Enum.KeyCode.", "")
	return Name
end

function Keybind:_SetupInteractions(Button)
	local Click = Button.MouseButton1Click:Connect(function()
		self:StartListening()
	end)
	self.Cleanup:AddConnection(Click)
	local Enter = Button.MouseEnter:Connect(function()
		self.Renderer:ShowGlow(Button, 0.3)
	end)
	local Leave = Button.MouseLeave:Connect(function()
		self.Renderer:HideGlow(Button)
	end)
	self.Cleanup:AddConnection(Enter)
	self.Cleanup:AddConnection(Leave)
end

function Keybind:StartListening()
	if self.Listening then
		return
	end
	self.Listening = true
	self.Button.Text = "..."
	self.Animation:Animate(self.ButtonStroke, "Color", Theme.Color("Accent"), { Duration = 0.15 })
	local Connection
	Connection = game:GetService("UserInputService").InputBegan:Connect(function(Input, Processed)
		if Processed then
			return
		end
		if Input.UserInputType == Enum.UserInputType.Keyboard then
			Connection:Disconnect()
			self.Listening = false
			self.Value = Input.KeyCode
			self.Button.Text = self:_Format(self.Value)
			self.Animation:Animate(self.ButtonStroke, "Color", Theme.Color("Border"), { Duration = 0.15 })
			self.Changed:Fire(self.Value)
			Utilities.SafeCall(self.Callback, self.Value)
		end
	end)
	self.Cleanup:AddConnection(Connection)
end

function Keybind:Set(Key)
	self.Value = Key
	self.Button.Text = self:_Format(Key)
end

function Keybind:Get()
	return self.Value
end

function Keybind:IsDown()
	return game:GetService("UserInputService"):IsKeyDown(self.Value)
end

return Keybind
