local Utilities = require(script.Parent.Parent.Core.Utilities)
local Base = require(script.Parent.Base)
local Icons = require(script.Parent.Parent.Assets.Icons)
local Dropdown = require(script.Parent.Dropdown)

local SearchDropdown = {}
SearchDropdown.__index = setmetatable(SearchDropdown, Base)

function SearchDropdown.new(Application, Parent, Options)
	local self = setmetatable(Base.new(Application, Parent, Options), SearchDropdown)
	self.AllOptions = Options.Options or {}
	self.Filtered = Utilities.ShallowCopy(self.AllOptions)
	self.Value = Options.Default or self.AllOptions[1]
	self.Label = Options.Label or ""
	self.Callback = Options.Callback
	self.MaxResults = Options.MaxResults or 50
	self.Open = false
	self._Build()
	return self
end

function SearchDropdown:_Build()
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

	local SearchBox = Utilities.Create("TextBox", {
		BackgroundColor3 = Theme.Color("Background"),
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 28),
		Font = Theme.Typography("Font"),
		TextSize = Theme.Typography("BodySize"),
		TextColor3 = Theme.Color("Text"),
		PlaceholderColor3 = Theme.Color("Placeholder"),
		PlaceholderText = "Search...",
		TextXAlignment = Enum.TextXAlignment.Left,
		ClearTextOnFocus = false,
		Parent = Card,
	})
	local SearchCorner = Utilities.Roundify(SearchBox, Theme.Layout("RadiusSmall"))
	local SearchStroke = Utilities.AddStroke(SearchBox, Theme.Color("Border"), 1)
	local SearchIcon = Icons.Create("Search", Theme.Color("TextDim"), 14)
	SearchIcon.Position = UDim2.new(0, 8, 0.5, 0)
	SearchIcon.AnchorPoint = Vector2.new(0, 0.5)
	SearchIcon.Parent = SearchBox
	SearchBox.TextPadding = UDim.new(0, 28)

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

	self.SearchBox = SearchBox
	self.Panel = Panel
	self.PanelScroll = PanelScroll

	self:_BuildResults()
	self:_SetupInteractions(SearchBox)
end

function SearchDropdown:_BuildResults()
	local Theme = self.Theme
	for _, Child in ipairs(self.PanelScroll:GetChildren()) do
		if Child:IsA("TextButton") then
			Child:Destroy()
		end
	end
	local Count = 0
	for _, Option in ipairs(self.Filtered) do
		if Count >= self.MaxResults then
			break
		end
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
		Count = Count + 1
	end
end

function SearchDropdown:_SetupInteractions(SearchBox)
	local Changed = SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
		local Query = string.lower(SearchBox.Text)
		self.Filtered = Utilities.TableFilter(self.AllOptions, function(Option)
			return Query == "" or string.find(string.lower(tostring(Option)), Query, 1, true) ~= nil
		end)
		self:_BuildResults()
		if not self.Open and #self.Filtered > 0 then
			self:Open()
		end
	end)
	self.Cleanup:AddConnection(Changed)
	local Focus = SearchBox.Focused:Connect(function()
		if #self.Filtered > 0 then
			self:Open()
		end
	end)
	self.Cleanup:AddConnection(Focus)
end

function SearchDropdown:Open()
	self.Open = true
	self.Panel.Visible = true
	local TargetHeight = math.min(200, #self.Filtered * 32 + 8)
	self.Animation:Tween({
		Duration = 0.2,
		Easing = "QuadOut",
		OnUpdate = function(_, _, Progress)
			self.Panel.Size = UDim2.new(1, 0, 0, TargetHeight * Progress)
		end,
	})
end

function SearchDropdown:Close()
	self.Open = false
	self.Animation:Tween({
		Duration = 0.2,
		Easing = "QuadIn",
		OnUpdate = function(_, _, Progress)
			self.Panel.Size = UDim2.new(1, 0, 0, TargetHeight * (1 - Progress))
		end,
		OnComplete = function()
			self.Panel.Visible = false
		end,
	})
end

function SearchDropdown:_Select(Option)
	self.Value = Option
	self.SearchBox.Text = tostring(Option)
	self:Close()
	self.Changed:Fire(Option)
	Utilities.SafeCall(self.Callback, Option)
end

function SearchDropdown:Set(Value)
	self.Value = Value
	self.SearchBox.Text = tostring(Value)
end

function SearchDropdown:Get()
	return self.Value
end

function SearchDropdown:SetOptions(Options)
	self.AllOptions = Options
	self.Filtered = Utilities.ShallowCopy(Options)
	self:_BuildResults()
end

return SearchDropdown
