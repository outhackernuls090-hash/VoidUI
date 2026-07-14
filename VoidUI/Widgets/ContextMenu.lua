local Utilities = require(script.Parent.Parent.Core.Utilities)
local Base = require(script.Parent.Base)
local Icons = require(script.Parent.Parent.Assets.Icons)

local ContextMenu = {}
ContextMenu.__index = setmetatable(ContextMenu, Base)

function ContextMenu.new(Application, Items)
	local self = setmetatable(Base.new(Application, Application.Renderer:GetLayer("Overlays"), {}), ContextMenu)
	self.Items = Items or {}
	self.Open = false
	self:_Build()
	return self
end

function ContextMenu:_Build()
	local Theme = self.Theme
	local Menu = Utilities.Create("Frame", {
		BackgroundColor3 = Theme.Color("CardElevated"),
		BorderSizePixel = 0,
		Size = UDim2.new(0, 200, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		ZIndex = 300,
		Visible = false,
		Parent = self.Parent,
	})
	local MenuCorner = Utilities.Roundify(Menu, Theme.Layout("Radius"))
	local MenuStroke = Utilities.AddStroke(Menu, Theme.Color("Border"), 1)
	local MenuGradient = Utilities.AddGradient(Menu, Theme.Gradient("Surface"), 90)
	MenuGradient.Transparency = NumberSequence.new(0.5)
	local MenuPadding = Utilities.AddPadding(Menu, 6)
	local MenuLayout = Utilities.AddListLayout(Menu, Enum.FillDirection.Vertical, 2, Enum.HorizontalAlignment.Center)
	self.Menu = Menu

	for _, Item in ipairs(self.Items) do
		self:_CreateItem(Item)
	end
end

function ContextMenu:_CreateItem(Item)
	local Theme = self.Theme
	if Item.Separator then
		local Divider = Utilities.Create("Frame", {
			BackgroundColor3 = Theme.Color("Border"),
			BorderSizePixel = 0,
			Size = UDim2.new(1, -12, 0, 1),
			Parent = self.Menu,
		})
		return
	end
	local Button = Utilities.Create("TextButton", {
		BackgroundColor3 = Theme.Color("Surface"),
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 32),
		AutoButtonColor = false,
		Text = "",
		ZIndex = 301,
		Parent = self.Menu,
	})
	local ButtonCorner = Utilities.Roundify(Button, Theme.Layout("RadiusSmall"))
	local ButtonLayout = Utilities.AddListLayout(Button, Enum.FillDirection.Horizontal, 8, Enum.HorizontalAlignment.Left)
	ButtonLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	ButtonLayout.Padding = UDim.new(0, 8)

	if Item.Icon then
		local IconFrame = Icons.Create(Item.Icon, Item.Danger and Theme.Color("Danger") or Theme.Color("TextMuted"), 16)
		IconFrame.ZIndex = 302
		IconFrame.Parent = Button
	end

	local Label = Utilities.Create("TextLabel", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, -40, 1, 0),
		Font = Theme.Typography("Font"),
		TextSize = Theme.Typography("BodySize"),
		TextColor3 = Item.Danger and Theme.Color("Danger") or Theme.Color("Text"),
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = Item.Label or Item.Title or "",
		ZIndex = 302,
		Parent = Button,
	})

	local Enter = Button.MouseEnter:Connect(function()
		self.Animation:Animate(Button, "BackgroundColor3", Theme.Color("SurfaceHover"), { Duration = 0.1 })
	end)
	local Leave = Button.MouseLeave:Connect(function()
		self.Animation:Animate(Button, "BackgroundColor3", Theme.Color("Surface"), { Duration = 0.1 })
	end)
	local Click = Button.MouseButton1Click:Connect(function()
		self:Close()
		Utilities.SafeCall(Item.Callback)
	end)
	self.Cleanup:AddConnection(Enter)
	self.Cleanup:AddConnection(Leave)
	self.Cleanup:AddConnection(Click)
end

function ContextMenu:Show(Position)
	self.Open = true
	self.Menu.Visible = true
	self.Menu.Position = UDim2.fromOffset(Position.X, Position.Y)
	self.Animation:Tween({
		Duration = 0.15,
		Easing = "BackOut",
		OnUpdate = function(_, _, Progress)
			self.Menu.Size = UDim2.new(0, 200, 0, self.Menu.AbsoluteSize.Y * Progress)
			self.Menu.BackgroundTransparency = 1 - Progress
		end,
	})
end

function ContextMenu:Close()
	self.Open = false
	self.Animation:Tween({
		Duration = 0.12,
		Easing = "QuadIn",
		OnUpdate = function(_, _, Progress)
			self.Menu.BackgroundTransparency = Progress
		end,
		OnComplete = function()
			self.Menu.Visible = false
		end,
	})
end

function ContextMenu:SetItems(Items)
	self.Items = Items
	for _, Child in ipairs(self.Menu:GetChildren()) do
		if Child:IsA("TextButton") or Child:IsA("Frame") then
			Child:Destroy()
		end
	end
	for _, Item in ipairs(Items) do
		self:_CreateItem(Item)
	end
end

return ContextMenu
