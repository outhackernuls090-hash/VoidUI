local Utilities = require(script.Parent.Parent.Core.Utilities)
local Base = require(script.Parent.Base)

local Graph = {}
Graph.__index = setmetatable(Graph, Base)

function Graph.new(Application, Parent, Options)
	local self = setmetatable(Base.new(Application, Parent, Options), Graph)
	self.Data = Options.Data or {}
	self.Width = Options.Width or 240
	self.Height = Options.Height or 120
	self.Min = Options.Min or 0
	self.Max = Options.Max or 100
	self.Color = Options.Color or self.Theme.Color("Accent")
	self.Filled = Options.Filled ~= false
	self:_Build()
	return self
end

function Graph:_Build()
	local Theme = self.Theme
	local Container = self:_CreateContainer(self.Height + 8)
	local Card = self:_CreateCard(Container.AbsoluteSize.Y, {
		AutomaticSize = Enum.AutomaticSize.Y,
	})
	local Padding = Utilities.AddPadding(Card, 4)

	local Canvas = Utilities.Create("Frame", {
		BackgroundColor3 = Theme.Color("Background"),
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, self.Height),
		Parent = Card,
	})
	local CanvasCorner = Utilities.Roundify(Canvas, Theme.Layout("RadiusSmall"))

	local Line = Utilities.Create("Frame", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 1, 0),
		Parent = Canvas,
	})
	self.Canvas = Canvas
	self.Line = Line

	self:_Render()
end

function Graph:_Render()
	for _, Child in ipairs(self.Line:GetChildren()) do
		if Child:IsA("Frame") then
			Child:Destroy()
		end
	end
	local Data = self.Data
	local Count = #Data
	if Count < 2 then
		return
	end
	local Width = self.Canvas.AbsoluteSize.X
	local Height = self.Canvas.AbsoluteSize.Y
	local Step = Width / (Count - 1)
	for I = 1, Count - 1 do
		local V1 = Utilities.Clamp(Data[I], self.Min, self.Max)
		local V2 = Utilities.Clamp(Data[I + 1], self.Min, self.Max)
		local Y1 = Height - Utilities.InverseLerp(self.Min, self.Max, V1) * Height
		local Y2 = Height - Utilities.InverseLerp(self.Min, self.Max, V2) * Height
		local X1 = (I - 1) * Step
		local X2 = I * Step
		local Length = math.sqrt((X2 - X1) ^ 2 + (Y2 - Y1) ^ 2)
		local Angle = math.deg(math.atan2(Y2 - Y1, X2 - X1))
		local Segment = Utilities.Create("Frame", {
			BackgroundColor3 = self.Color,
			BorderSizePixel = 0,
			Size = UDim2.new(0, Length, 0, 2),
			Position = UDim2.new(0, X1, 0, Y1),
			AnchorPoint = Vector2.new(0, 0.5),
			Rotation = Angle,
			Parent = self.Line,
		})
	end
	if self.Filled then
		local Fill = Utilities.Create("Frame", {
			BackgroundColor3 = self.Color,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 0),
			Position = UDim2.new(0, 0, 1, 0),
			AnchorPoint = Vector2.new(0, 1),
			BackgroundTransparency = 0.85,
			Parent = self.Line,
		})
	end
end

function Graph:SetData(Data)
	self.Data = Data
	self:_Render()
end

function Graph:Push(Value)
	table.insert(self.Data, Value)
	self:_Render()
end

function Graph:SetRange(Min, Max)
	self.Min = Min
	self.Max = Max
	self:_Render()
end

function Graph:SetColor(Color)
	self.Color = Color
	self:_Render()
end

return Graph
