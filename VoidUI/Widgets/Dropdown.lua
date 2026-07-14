local Utilities = require(script.Parent.Parent.Core.Utilities)
local Base = require(script.Parent.Base)
local Icons = require(script.Parent.Parent.Assets.Icons)

local Dropdown = {}
Dropdown.__index = setmetatable(Dropdown, Base)

function Dropdown.new(Application, Parent, Options)
	local self = setmetatable(Base.new(Application, Parent, Options), Dropdown)
	self.Options = Options.Options or {}
	self.Value = Options.Default or self.Options[1]
	self.Label = Options.Label or ""
	self.Callback = Options.Callback
	self.MultiSelect = Options.MultiSelect or false
	self.Selected = {}
	self.Open = false
	self._Build()
	return self
end

function Dropdown:_Build()
	local Theme = self.Theme
	local Container = self:_CreateContainer(self.Label ~= "" and 66 or 44)
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

	local Trigger = Utilities.Create("TextButton", {
		BackgroundColor3 = Theme.Color("Background"),
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 28),
		AutoButtonColor = false,
		Text = "",
		Parent = Card,
	})
	local TriggerCorner = Utilities.Roundify(Trigger, Theme.Layout("RadiusSmall"))
	local TriggerStroke = Utilities.AddStroke(Trigger, Theme.Color("Border"), 1)
	local TriggerLayout = Utilities.AddListLayout(Trigger, Enum.FillDirection.Horizontal, 8, Enum.HorizontalAlignment.Left)
	TriggerLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	TriggerLayout.Padding = UDim.new(0, 10)

	local ValueLabel = Utilities.Create("TextLabel", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, -30, 1, 0),
		Font = Theme.Typography("Font"),
		TextSize = Theme.Typography("BodySize"),
		TextColor3 = Theme.Color("Text"),
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = self.Value or "Select...",
		Parent = Trigger,
	})
	local Chevron = Icons.Create("ChevronDown", Theme.Color("TextMuted"), 16)
	Chevron.Parent = Trigger

	local Panel = Utilities.Create("Frame", {
		BackgroundColor3 = Theme.Color("CardElevated"),
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 0),
		ClipsDescendants = true,
		Visible = false,
		Parent = Card,
	})
	local PanelCorner = Utilities.Roundify(Panel, Theme.Layout("RadiusSmall"))
	local PanelStroke = Utilities.AddStroke(Panel, Theme.Color("Border"), 1)
	local PanelScroll = Utilities.Create("ScrollingFrame", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 1, 0),
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticCanvasSize.Y,
		ScrollBarThickness = 4,
		ScrollBarImageColor3 = Theme.Color("Scrollbar"),
		Parent = Panel,
	})
	local PanelLayout = Utilities.AddListLayout(PanelScroll, Enum.FillDirection.Vertical, 4, Enum.HorizontalAlignment.Center)
	PanelLayout.Padding = UDim.new(0, 4)

	self.Trigger = Trigger
	self.ValueLabel = ValueLabel
	self.Chevron = Chevron
	self.Panel = Panel
	self.PanelScroll = PanelScroll

	self:_BuildOptions()
	self:_SetupInteractions(Trigger)
end

function Dropdown:_BuildOptions()
	local Theme = self.Theme
	for _, Option in ipairs(self.Options) do
		local Item = Utilities.Create("TextButton", {
			BackgroundColor3 = Theme.Color("Surface"),
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 28),
			AutoButtonColor = false,
			Text = "",
			Parent = self.PanelScroll,
		})
		local ItemCorner = Utilities.Roundify(Item, Theme.Layout("RadiusSmall"))
		local ItemLabel = Utilities.Create("TextLabel", {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, -16, 1, 0),
			Position = UDim2.new(0, 8, 0, 0),
			Font = Theme.Typography("Font"),
			TextSize = Theme.Typography("BodySize"),
			TextColor3 = Theme.Color("Text"),
			TextXAlignment = Enum.TextXAlignment.Left,
			Text = tostring(Option),
			Parent = Item,
		})
		local Enter = Item.MouseEnter:Connect(function()
			self.Animation:Animate(Item, "BackgroundColor3", Theme.Color("SurfaceHover"), { Duration = 0.12 })
		end)
		local Leave = Item.MouseLeave:Connect(function()
			self.Animation:Animate(Item, "BackgroundColor3", Theme.Color("Surface"), { Duration = 0.12 })
		end)
		local Click = Item.MouseButton1Click:Connect(function()
			self:_Select(Option)
		end)
		self.Cleanup:AddConnection(Enter)
		self.Cleanup:AddConnection(Leave)
		self.Cleanup:AddConnection(Click)
	end
end

function Dropdown:_SetupInteractions(Trigger)
	local Click = Trigger.MouseButton1Click:Connect(function()
		self:Toggle()
	end)
	self.Cleanup:AddConnection(Click)
end

function Dropdown:Toggle()
	self.Open = not self.Open
	self.Panel.Visible = true
	local TargetHeight = self.Open and math.min(200, #self.Options * 32 + 8) or 0
	self.Animation:Tween({
		Duration = 0.25,
		Easing = "QuadOut",
		OnUpdate = function(_, _, Progress)
			self.Panel.Size = UDim2.new(1, 0, 0, TargetHeight * Progress)
		end,
		OnComplete = function()
			if not self.Open then
				self.Panel.Visible = false
			end
		end,
	})
	self.Animation:Animate(self.Chevron, "Rotation", self.Open and 180 or 0, { Duration = 0.25 })
end

function Dropdown:_Select(Option)
	if self.MultiSelect then
		if self.Selected[Option] then
			self.Selected[Option] = nil
		else
			self.Selected[Option] = true
		end
		local Keys = Utilities.TableKeys(self.Selected)
		self.ValueLabel.Text = #Keys > 0 and table.concat(Keys, ", ") or "Select..."
		self.Changed:Fire(Keys)
		Utilities.SafeCall(self.Callback, Keys)
	else
		self.Value = Option
		self.ValueLabel.Text = tostring(Option)
		self:Toggle()
		self.Changed:Fire(Option)
		Utilities.SafeCall(self.Callback, Option)
	end
end

function Dropdown:Set(Value)
	self.Value = Value
	self.ValueLabel.Text = tostring(Value)
end

function Dropdown:Get()
	return self.Value
end

function Dropdown:SetOptions(Options)
	self.Options = Options
	for _, Child in ipairs(self.PanelScroll:GetChildren()) do
		if Child:IsA("TextButton") then
			Child:Destroy()
		end
	end
	self:_BuildOptions()
end

return Dropdown
