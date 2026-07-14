local Utilities = require(script.Parent.Parent.Core.Utilities)
local Base = require(script.Parent.Base)
local Icons = require(script.Parent.Parent.Assets.Icons)

local Button = {}
Button.__index = setmetatable(Button, Base)

function Button.new(Application, Parent, Options)
	local self = setmetatable(Base.new(Application, Parent, Options), Button)
	self.Variant = Options.Variant or "Primary"
	self.Icon = Options.Icon
	self.Text = Options.Text or "Button"
	self.Callback = Options.Callback
	self.Loading = false
	self:_Build()
	return self
end

function Button:_Build()
	local Theme = self.Theme
	local Container = self:_CreateContainer(44)
	local Colors = self:_ResolveColors()

	local Card = Utilities.Create("TextButton", {
		Name = "Button",
		BackgroundColor3 = Colors.Background,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 1, 0),
		AutoButtonColor = false,
		Text = "",
		Parent = Container,
	})
	local Corner = Utilities.Roundify(Card, Theme.Layout("Radius"))
	local Stroke = Utilities.AddStroke(Card, Colors.Stroke, Theme.Layout("BorderThickness"))
	local Gradient = Utilities.AddGradient(Card, Colors.Gradient, 90)
	Gradient.Transparency = NumberSequence.new(Colors.GradientTransparency)
	self.Instance = Card
	self.Stroke = Stroke

	local Content = Utilities.Create("Frame", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 1, 0),
		Parent = Card,
	})
	local Layout = Utilities.AddListLayout(Content, Enum.FillDirection.Horizontal, 8, Enum.HorizontalAlignment.Center)
	Layout.VerticalAlignment = Enum.VerticalAlignment.Center

	if self.Icon then
		local IconFrame = Icons.Create(self.Icon, Colors.Text, 18)
		IconFrame.Parent = Content
		self.IconFrame = IconFrame
	end

	local Label = Utilities.Create("TextLabel", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(0, 0, 1, 0),
		AutomaticSize = Enum.AutomaticSize.X,
		Font = Theme.Typography("FontSemibold"),
		TextSize = Theme.Typography("BodySize"),
		TextColor3 = Colors.Text,
		Text = self.Text,
		Parent = Content,
	})
	self.Label = Label

	self:_SetupInteractions(Card, Colors)
end

function Button:_ResolveColors()
	local Theme = self.Theme
	local Variant = self.Variant
	if Variant == "Primary" then
		return {
			Background = Theme.Color("Accent"),
			Stroke = Theme.Color("AccentLight"),
			Text = Theme.Color("TextInverse"),
			Gradient = Theme.Gradient("Accent"),
			GradientTransparency = 0.4,
		}
	elseif Variant == "Danger" then
		return {
			Background = Theme.Color("Danger"),
			Stroke = Theme.Color("Danger"),
			Text = Color3.fromRGB(255, 255, 255),
			Gradient = ColorSequence.new(Theme.Color("Danger")),
			GradientTransparency = 0.5,
		}
	elseif Variant == "Ghost" then
		return {
			Background = Theme.Color("Surface"),
			Stroke = Theme.Color("Border"),
			Text = Theme.Color("Text"),
			Gradient = ColorSequence.new(Theme.Color("Surface")),
			GradientTransparency = 1,
		}
	elseif Variant == "Icon" then
		return {
			Background = Theme.Color("Surface"),
			Stroke = Theme.Color("Border"),
			Text = Theme.Color("Text"),
			Gradient = ColorSequence.new(Theme.Color("Surface")),
			GradientTransparency = 1,
		}
	else
		return {
			Background = Theme.Color("SurfaceHover"),
			Stroke = Theme.Color("BorderStrong"),
			Text = Theme.Color("Text"),
			Gradient = ColorSequence.new(Theme.Color("SurfaceHover")),
			GradientTransparency = 1,
		}
	end
end

function Button:_SetupInteractions(Card, Colors)
	local Theme = self.Theme
	local Enter = Card.MouseEnter:Connect(function()
		self.Animation:Animate(Card, "BackgroundColor3", Theme.Color("AccentLight"), { Duration = 0.15 })
		self.Renderer:ShowGlow(Card, 0.4)
		self.Animation:Animate(Card, "Size", UDim2.new(1, 0, 1, -2), { Duration = 0.12, Easing = "QuadOut" })
	end)
	local Leave = Card.MouseLeave:Connect(function()
		self.Animation:Animate(Card, "BackgroundColor3", Colors.Background, { Duration = 0.15 })
		self.Renderer:HideGlow(Card)
		self.Animation:Animate(Card, "Size", UDim2.new(1, 0, 1, 0), { Duration = 0.12, Easing = "QuadOut" })
	end)
	local Down = Card.MouseButton1Down:Connect(function()
		self.Animation:Animate(Card, "Size", UDim2.new(1, 0, 1, 2), { Duration = 0.1 })
	end)
	local Up = Card.MouseButton1Up:Connect(function()
		self.Animation:Animate(Card, "Size", UDim2.new(1, 0, 1, -2), { Duration = 0.1 })
	end)
	local Click = Card.MouseButton1Click:Connect(function()
		if self.Loading then
			return
		end
		self.Renderer:Pulse(Card, 1.03)
		Utilities.SafeCall(self.Callback)
		self.Changed:Fire(self.Text)
	end)
	self.Cleanup:AddConnection(Enter)
	self.Cleanup:AddConnection(Leave)
	self.Cleanup:AddConnection(Down)
	self.Cleanup:AddConnection(Up)
	self.Cleanup:AddConnection(Click)
end

function Button:SetText(Text)
	self.Text = Text
	self.Label.Text = Text
end

function Button:SetVariant(Variant)
	self.Variant = Variant
	local Colors = self:_ResolveColors()
	self.Instance.BackgroundColor3 = Colors.Background
	self.Stroke.Color = Colors.Stroke
	self.Label.TextColor3 = Colors.Text
end

function Button:SetIcon(Icon)
	if self.IconFrame then
		self.IconFrame:Destroy()
		self.IconFrame = nil
	end
	if Icon then
		local Colors = self:_ResolveColors()
		self.IconFrame = Icons.Create(Icon, Colors.Text, 18)
		self.IconFrame.Parent = self.Instance:FindFirstChildOfClass("Frame")
	end
	self.Icon = Icon
end

function Button:SetCallback(Callback)
	self.Callback = Callback
end

function Button:SetLoading(Loading)
	self.Loading = Loading
	self.Instance.AutoButtonColor = not Loading
	self.Instance.BackgroundTransparency = Loading and 0.4 or 0
end

function Button:Click()
	Utilities.SafeCall(self.Callback)
end

return Button
