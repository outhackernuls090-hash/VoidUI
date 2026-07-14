local Utilities = require(script.Parent.Parent.Core.Utilities)
local Base = require(script.Parent.Base)
local Icons = require(script.Parent.Parent.Assets.Icons)

local Accordion = {}
Accordion.__index = setmetatable(Accordion, Base)

function Accordion.new(Application, Parent, Options)
	local self = setmetatable(Base.new(Application, Parent, Options), Accordion)
	self.Items = Options.Items or {}
	self.MultiExpand = Options.MultiExpand or false
	self.Expanded = {}
	self._Build()
	return self
end

function Accordion:_Build()
	local Theme = self.Theme
	local Container = self:_CreateContainer(0)
	Container.AutomaticSize = Enum.AutomaticSize.Y
	local Card = self:_CreateCard(0, {
		AutomaticSize = Enum.AutomaticSize.Y,
	})
	local Layout = Utilities.AddListLayout(Card, Enum.FillDirection.Vertical, 6, Enum.HorizontalAlignment.Center)
	Layout.Padding = UDim.new(0, 6)
	local Padding = Utilities.AddPadding(Card, 10)
	self.Card = Card

	for Index, Item in ipairs(self.Items) do
		self:_CreateItem(Item, Index)
	end
end

function Accordion:_CreateItem(Item, Index)
	local Theme = self.Theme
	local ItemFrame = Utilities.Create("Frame", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Parent = self.Card,
	})

	local Header = Utilities.Create("TextButton", {
		BackgroundColor3 = Theme.Color("Surface"),
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 36),
		AutoButtonColor = false,
		Text = "",
		Parent = ItemFrame,
	})
	local HeaderCorner = Utilities.Roundify(Header, Theme.Layout("RadiusSmall"))
	local HeaderLayout = Utilities.AddListLayout(Header, Enum.FillDirection.Horizontal, 8, Enum.HorizontalAlignment.Left)
	HeaderLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	HeaderLayout.Padding = UDim.new(0, 12)

	local Title = Utilities.Create("TextLabel", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, -40, 1, 0),
		Font = Theme.Typography("FontSemibold"),
		TextSize = Theme.Typography("BodySize"),
		TextColor3 = Theme.Color("Text"),
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = Item.Title or ("Item " .. Index),
		Parent = Header,
	})
	local Chevron = Icons.Create("ChevronDown", Theme.Color("TextMuted"), 16)
	Chevron.Parent = Header

	local Body = Utilities.Create("Frame", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Visible = false,
		Parent = ItemFrame,
	})
	local BodyLayout = Utilities.AddListLayout(Body, Enum.FillDirection.Vertical, 6, Enum.HorizontalAlignment.Center)
	BodyLayout.Padding = UDim.new(0, 6)
	local BodyPadding = Utilities.AddPadding(Body, 8)

	if type(Item.Content) == "string" then
		local Text = Utilities.Create("TextLabel", {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			Font = Theme.Typography("Font"),
			TextSize = Theme.Typography("BodySize"),
			TextColor3 = Theme.Color("TextMuted"),
			TextWrapped = true,
			Text = Item.Content,
			Parent = Body,
		})
	elseif typeof(Item.Content) == "Instance" then
		Item.Content.Parent = Body
	end

	local Expanded = false
	local Click = Header.MouseButton1Click:Connect(function()
		Expanded = not Expanded
		self.Expanded[Index] = Expanded
		self.Animation:Animate(Chevron, "Rotation", Expanded and 180 or 0, { Duration = 0.2 })
		Body.Visible = true
		local TargetHeight = Expanded and Body.AbsoluteSize.Y or 0
		self.Animation:Tween({
			Duration = 0.25,
			Easing = "QuadOut",
			OnUpdate = function(_, _, Progress)
				Body.Size = UDim2.new(1, 0, 0, TargetHeight * Progress)
			end,
			OnComplete = function()
				if not Expanded then
					Body.Visible = false
				end
			end,
		})
		if not self.MultiExpand and Expanded then
			for OtherIndex, OtherExpanded in pairs(self.Expanded) do
				if OtherIndex ~= Index and OtherExpanded then
					self.Expanded[OtherIndex] = false
				end
			end
		end
		self.Changed:Fire(Index, Expanded)
	end)
	self.Cleanup:AddConnection(Click)
end

function Accordion:Expand(Index)
	self.Expanded[Index] = true
	self.Changed:Fire(Index, true)
end

function Accordion:Collapse(Index)
	self.Expanded[Index] = false
	self.Changed:Fire(Index, false)
end

return Accordion
