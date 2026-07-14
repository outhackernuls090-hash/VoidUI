local Utilities = require(script.Parent.Parent.Core.Utilities)
local Base = require(script.Parent.Base)
local Icons = require(script.Parent.Parent.Assets.Icons)

local Breadcrumbs = {}
Breadcrumbs.__index = setmetatable(Breadcrumbs, Base)

function Breadcrumbs.new(Application, Parent, Options)
	local self = setmetatable(Base.new(Application, Parent, Options or {}), Breadcrumbs)
	self.Items = (Options and Options.Items) or {}
	self.OnNavigate = Options and Options.OnNavigate
	self:_Build()
	return self
end

function Breadcrumbs:_Build()
	local Theme = self.Theme
	local Container = self:_CreateContainer(28)
	local Card = self:_CreateCard(Container.AbsoluteSize.Y, {
		AutomaticSize = Enum.AutomaticSize.Y,
	})
	local Layout = Utilities.AddListLayout(Card, Enum.FillDirection.Horizontal, 4, Enum.HorizontalAlignment.Left)
	Layout.VerticalAlignment = Enum.VerticalAlignment.Center
	local Padding = Utilities.AddPadding(Card, 10)
	self.Card = Card
	self:_Render()
end

function Breadcrumbs:_Render()
	for _, Child in ipairs(self.Card:GetChildren()) do
		if Child:IsA("TextButton") or Child:IsA("TextLabel") or Child:IsA("Frame") then
			Child:Destroy()
		end
	end
	local Theme = self.Theme
	for Index, Item in ipairs(self.Items) do
		local IsLast = Index == #self.Items
		local Crumb = Utilities.Create("TextButton", {
			BackgroundColor3 = Theme.Color("Surface"),
			BorderSizePixel = 0,
			Size = UDim2.new(0, 0, 1, -8),
			AutomaticSize = Enum.AutomaticSize.X,
			AutoButtonColor = false,
			Text = "",
			Parent = self.Card,
		})
		local CrumbCorner = Utilities.Roundify(Crumb, Theme.Layout("RadiusSmall"))
		local CrumbLayout = Utilities.AddListLayout(Crumb, Enum.FillDirection.Horizontal, 6, Enum.HorizontalAlignment.Left)
		CrumbLayout.VerticalAlignment = Enum.VerticalAlignment.Center
		CrumbLayout.Padding = UDim.new(0, 8)
		local CrumbPadding = Utilities.AddPadding(Crumb, 8)

		if Item.Icon then
			local IconFrame = Icons.Create(Item.Icon, IsLast and Theme.Color("Accent") or Theme.Color("TextMuted"), 14)
			IconFrame.Parent = Crumb
		end
		local Label = Utilities.Create("TextLabel", {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(0, 0, 1, 0),
			AutomaticSize = Enum.AutomaticSize.X,
			Font = Theme.Typography("Font"),
			TextSize = Theme.Typography("CaptionSize"),
			TextColor3 = IsLast and Theme.Color("Accent") or Theme.Color("TextMuted"),
			Text = Item.Label or Item.Name or "",
			Parent = Crumb,
		})
		if not IsLast then
			local Click = Crumb.MouseButton1Click:Connect(function()
				self.Changed:Fire(Item, Index)
				Utilities.SafeCall(self.OnNavigate, Item, Index)
			end)
			self.Cleanup:AddConnection(Click)
		end

		if not IsLast then
			local Separator = Utilities.Create("TextLabel", {
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Size = UDim2.new(0, 12, 1, 0),
				Font = Theme.Typography("Font"),
				TextSize = Theme.Typography("CaptionSize"),
				TextColor3 = Theme.Color("TextDim"),
				Text = "/",
				Parent = self.Card,
			})
		end
	end
end

function Breadcrumbs:SetItems(Items)
	self.Items = Items
	self:_Render()
end

function Breadcrumbs:Push(Item)
	table.insert(self.Items, Item)
	self:_Render()
end

function Breadcrumbs:Pop()
	table.remove(self.Items)
	self:_Render()
end

return Breadcrumbs
