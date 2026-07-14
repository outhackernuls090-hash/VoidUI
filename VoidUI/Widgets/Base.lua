local Utilities = require(script.Parent.Parent.Core.Utilities)
local Events = require(script.Parent.Parent.Core.Events)
local Cleanup = require(script.Parent.Parent.Core.Cleanup)

local Base = {}
Base.__index = Base

function Base.new(Application, Parent, Options)
	local self = setmetatable({}, Base)
	self.Application = Application
	self.Theme = Application.Theme
	self.Renderer = Application.Renderer
	self.Animation = Application.Animation
	self.Parent = Parent
	self.Options = Options or {}
	self.Instance = nil
	self.Container = nil
	self.Changed = Events.new()
	self.Destroyed = Events.new()
	self.Cleanup = Cleanup.new()
	self.Enabled = true
	self.Visible = true
	self.LayoutOrder = 0
	self._Hover = false
	self._Focused = false
	return self
end

function Base:SetParent(Parent)
	self.Parent = Parent
	if self.Container then
		self.Container.Parent = Parent
	end
end

function Base:SetLayoutOrder(Order)
	self.LayoutOrder = Order
	if self.Container then
		self.Container.LayoutOrder = Order
	end
end

function Base:SetEnabled(Enabled)
	self.Enabled = Enabled
	if self.Container then
		self.Container.Visible = Enabled
	end
end

function Base:SetVisible(Visible)
	self.Visible = Visible
	if self.Container then
		self.Container.Visible = Visible
	end
end

function Base:IsEnabled()
	return self.Enabled
end

function Base:IsVisible()
	return self.Visible
end

function Base:GetSize()
	if self.Container then
		return self.Container.AbsoluteSize
	end
	return Vector2.new(0, 0)
end

function Base:GetInstance()
	return self.Container or self.Instance
end

function Base:_CreateContainer(Height)
	local Theme = self.Theme
	local Container = Utilities.Create("Frame", {
		Name = "Widget",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, Height or 36),
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = self.LayoutOrder,
		Parent = self.Parent,
	})
	self.Container = Container
	return Container
end

function Base:_CreateCard(Height, Properties)
	local Theme = self.Theme
	local Card = Utilities.Create("Frame", Utilities.Merge({
		Name = "Card",
		BackgroundColor3 = Theme.Color("Surface"),
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, Height or 36),
		Parent = self.Container,
	}, Properties or {}))
	local Corner = Utilities.Roundify(Card, Theme.Layout("RadiusSmall"))
	local Stroke = Utilities.AddStroke(Card, Theme.Color("Border"), Theme.Layout("BorderThickness"))
	self.Instance = Card
	return Card
end

function Base:_SetupHover(Card, HoverColor, GlowColor)
	local Theme = self.Theme
	HoverColor = HoverColor or Theme.Color("SurfaceHover")
	GlowColor = GlowColor or Theme.Color("AccentGlow")
	local Enter = Card.MouseEnter:Connect(function()
		self._Hover = true
		self.Animation:Animate(Card, "BackgroundColor3", HoverColor, { Duration = 0.15 })
		self.Renderer:ShowGlow(Card, 0.3)
	end)
	local Leave = Card.MouseLeave:Connect(function()
		self._Hover = false
		self.Animation:Animate(Card, "BackgroundColor3", Theme.Color("Surface"), { Duration = 0.15 })
		self.Renderer:HideGlow(Card)
	end)
	self.Cleanup:AddConnection(Enter)
	self.Cleanup:AddConnection(Leave)
end

function Base:_ApplyTheme()
	if self.Instance then
		self.Instance.BackgroundColor3 = self.Theme.Color("Surface")
	end
end

function Base:OnChanged(Callback)
	return self.Changed:Connect(Callback)
end

function Base:TriggerChanged(...)
	self.Changed:Fire(...)
end

function Base:Destroy()
	if self.Destroyed.Connected then
		self.Destroyed:Fire()
	end
	self.Cleanup:Destroy()
	if self.Container then
		self.Container:Destroy()
	end
	self.Changed:DisconnectAll()
	self.Destroyed:DisconnectAll()
end

return Base
