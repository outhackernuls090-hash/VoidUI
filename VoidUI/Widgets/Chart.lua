local Utilities = require(script.Parent.Parent.Core.Utilities)
local Base = require(script.Parent.Base)

local Chart = {}
Chart.__index = setmetatable(Chart, Base)

function Chart.new(Application, Parent, Options)
	local self = setmetatable(Base.new(Application, Parent, Options), Chart)
	self.Type = Options.Type or "Bar"
	self.Data = Options.Data or {}
	self.Width = Options.Width or 280
	self.Height = Options.Height or 160
	self.Colors = Options.Colors or { self.Theme.Color("Accent"), self.Theme.Color("Success"), self.Theme.Color("Warning"), self.Theme.Color("Danger"), self.Theme.Color("Info") }
	self.ShowLegend = Options.ShowLegend or false
	self:_Build()
	return self
end

function Chart:_Build()
	local Theme = self.Theme
	local Container = self:_CreateContainer(self.Height + (self.ShowLegend and 40 or 8))
	local Card = self:_CreateCard(Container.AbsoluteSize.Y, {
		AutomaticSize = Enum.AutomaticSize.Y,
	})
	local Padding = Utilities.AddPadding(Card, 12)

	local Canvas = Utilities.Create("Frame", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, self.Height),
		Parent = Card,
	})
	self.Canvas = Canvas

	if self.ShowLegend then
		local Legend = Utilities.Create("Frame", {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 28),
			Parent = Card,
		})
		local LegendLayout = Utilities.AddListLayout(Legend, Enum.FillDirection.Horizontal, 12, Enum.HorizontalAlignment.Center)
		LegendLayout.VerticalAlignment = Enum.VerticalAlignment.Center
		self.Legend = Legend
	end

	self:_Render()
end

function Chart:_Render()
	for _, Child in ipairs(self.Canvas:GetChildren()) do
		if Child:IsA("Frame") or Child:IsA("TextLabel") then
			Child:Destroy()
		end
	end
	local Data = self.Data
	local Count = #Data
	if Count == 0 then
		return
	end
	local Width = self.Canvas.AbsoluteSize.X
	local Height = self.Canvas.AbsoluteSize.Y

	if self.Type == "Bar" then
		local Max = 0
		for _, Item in ipairs(Data) do
			Max = math.max(Max, Item.Value or 0)
		end
		local Slot = Width / Count
		local BarWidth = Slot * 0.6
		for I, Item in ipairs(Data) do
			local Ratio = Max > 0 and (Item.Value or 0) / Max or 0
			local BarHeight = Ratio * (Height - 20)
			local Color = self.Colors[(I - 1) % #self.Colors + 1]
			local Bar = Utilities.Create("Frame", {
				BackgroundColor3 = Color,
				BorderSizePixel = 0,
				Size = UDim2.new(0, BarWidth, 0, 0),
				Position = UDim2.new(0, (I - 1) * Slot + (Slot - BarWidth) / 2, 1, -20),
				AnchorPoint = Vector2.new(0, 1),
				Parent = self.Canvas,
			})
			local BarCorner = Utilities.Roundify(Bar, 4)
			local BarGradient = Utilities.AddGradient(Bar, ColorSequence.new({
				ColorSequenceKeypoint.new(0, Utilities.Lighten(Color, 0.2)),
				ColorSequenceKeypoint.new(1, Color),
			}), 90)
			self.Animation:Tween({
				Duration = 0.4,
				Easing = "BackOut",
				Delay = I * 0.04,
				OnUpdate = function(_, _, Progress)
					Bar.Size = UDim2.new(0, BarWidth, 0, BarHeight * Progress)
				end,
			})
			local Label = Utilities.Create("TextLabel", {
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Size = UDim2.new(0, Slot, 0, 16),
				Position = UDim2.new(0, (I - 1) * Slot, 1, 0),
				AnchorPoint = Vector2.new(0, 1),
				Font = self.Theme.Typography("Font"),
				TextSize = self.Theme.Typography("SmallSize"),
				TextColor3 = self.Theme.Color("TextMuted"),
				Text = tostring(Item.Label or ""),
				Parent = self.Canvas,
			})
		end
	elseif self.Type == "Pie" then
		local Total = 0
		for _, Item in ipairs(Data) do
			Total = Total + (Item.Value or 0)
		end
		local Center = Utilities.Create("Frame", {
			BackgroundColor3 = self.Theme.Color("SurfaceActive"),
			BorderSizePixel = 0,
			Size = UDim2.fromOffset(Height - 20, Height - 20),
			Position = UDim2.fromScale(0.5, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Parent = self.Canvas,
		})
		local CenterCorner = Utilities.Roundify(Center, 999)
		local Angle = 0
		for I, Item in ipairs(Data) do
			local Fraction = Total > 0 and (Item.Value or 0) / Total or 0
			local Color = self.Colors[(I - 1) % #self.Colors + 1]
			local Slice = Utilities.Create("Frame", {
				BackgroundColor3 = Color,
				BorderSizePixel = 0,
				Size = UDim2.fromScale(1, 1),
				Parent = Center,
			})
			local SliceCorner = Utilities.Roundify(Slice, 999)
			Slice.ClipsDescendants = true
		end
	end
end

function Chart:SetData(Data)
	self.Data = Data
	self:_Render()
end

function Chart:SetType(Type)
	self.Type = Type
	self:_Render()
end

return Chart
