local Utilities = require(script.Parent.Parent.Core.Utilities)
local Base = require(script.Parent.Base)

local Table = {}
Table.__index = setmetatable(Table, Base)

function Table.new(Application, Parent, Options)
	local self = setmetatable(Base.new(Application, Parent, Options), Table)
	self.Columns = Options.Columns or {}
	self.Rows = Options.Rows or {}
	self.Sortable = Options.Sortable ~= false
	self.Striped = Options.Striped or false
	self.OnRowClick = Options.OnRowClick
	self._Build()
	return self
end

function Table:_Build()
	local Theme = self.Theme
	local Container = self:_CreateContainer(0)
	Container.AutomaticSize = Enum.AutomaticSize.Y
	local Card = self:_CreateCard(0, {
		AutomaticSize = Enum.AutomaticSize.Y,
	})
	local Padding = Utilities.AddPadding(Card, 0)
	self.Card = Card

	local Header = Utilities.Create("Frame", {
		BackgroundColor3 = Theme.Color("Surface"),
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 34),
		Parent = Card,
	})
	local HeaderCorner = Utilities.Roundify(Header, Theme.Layout("RadiusSmall"))
	local HeaderLayout = Utilities.AddListLayout(Header, Enum.FillDirection.Horizontal, 0, Enum.HorizontalAlignment.Left)
	HeaderLayout.VerticalAlignment = Enum.VerticalAlignment.Center

	for _, Column in ipairs(self.Columns) do
		local Cell = Utilities.Create("TextButton", {
			BackgroundColor3 = Theme.Color("Surface"),
			BorderSizePixel = 0,
			Size = UDim2.new(Column.Width or 0.25, 0, 1, 0),
			AutoButtonColor = false,
			Text = "",
			Parent = Header,
		})
		local Label = Utilities.Create("TextLabel", {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, -16, 1, 0),
			Position = UDim2.new(0, 8, 0, 0),
			Font = Theme.Typography("FontBold"),
			TextSize = Theme.Typography("CaptionSize"),
			TextColor3 = Theme.Color("TextMuted"),
			TextXAlignment = Enum.TextXAlignment.Left,
			Text = Column.Title or Column.Name or "",
			Parent = Cell,
		})
		if self.Sortable then
			local Click = Cell.MouseButton1Click:Connect(function()
				self:_SortBy(Column)
			end)
			self.Cleanup:AddConnection(Click)
		end
	end

	self.Body = Utilities.Create("Frame", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Parent = Card,
	})
	local BodyLayout = Utilities.AddListLayout(self.Body, Enum.FillDirection.Vertical, 2, Enum.HorizontalAlignment.Center)
	BodyLayout.Padding = UDim.new(0, 2)

	self:_BuildRows()
end

function Table:_BuildRows()
	local Theme = self.Theme
	for RowIndex, Row in ipairs(self.Rows) do
		local RowFrame = Utilities.Create("TextButton", {
			BackgroundColor3 = self.Striped and (RowIndex % 2 == 0 and Theme.Color("Surface") or Theme.Color("Card")) or Theme.Color("Card"),
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 30),
			AutoButtonColor = false,
			Text = "",
			Parent = self.Body,
		})
		local RowCorner = Utilities.Roundify(RowFrame, Theme.Layout("RadiusSmall"))
		local RowLayout = Utilities.AddListLayout(RowFrame, Enum.FillDirection.Horizontal, 0, Enum.HorizontalAlignment.Left)
		RowLayout.VerticalAlignment = Enum.VerticalAlignment.Center

		for ColIndex, Column in ipairs(self.Columns) do
			local Value = Row[Column.Name] or Row[ColIndex]
			local Cell = Utilities.Create("TextLabel", {
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Size = UDim2.new(Column.Width or 0.25, 0, 1, 0),
				Position = UDim2.new(0, 8, 0, 0),
				Font = Theme.Typography("Font"),
				TextSize = Theme.Typography("CaptionSize"),
				TextColor3 = Theme.Color("Text"),
				TextXAlignment = Enum.TextXAlignment.Left,
				TextTruncate = Enum.TextTruncate.AtEnd,
				Text = tostring(Value),
				Parent = RowFrame,
			})
		end

		local Click = RowFrame.MouseButton1Click:Connect(function()
			self.Changed:Fire(Row, RowIndex)
			Utilities.SafeCall(self.OnRowClick, Row, RowIndex)
		end)
		self.Cleanup:AddConnection(Click)
		local Enter = RowFrame.MouseEnter:Connect(function()
			self.Animation:Animate(RowFrame, "BackgroundColor3", Theme.Color("SurfaceHover"), { Duration = 0.1 })
		end)
		local Leave = RowFrame.MouseLeave:Connect(function()
			self.Animation:Animate(RowFrame, "BackgroundColor3", self.Striped and (RowIndex % 2 == 0 and Theme.Color("Surface") or Theme.Color("Card")) or Theme.Color("Card"), { Duration = 0.1 })
		end)
		self.Cleanup:AddConnection(Enter)
		self.Cleanup:AddConnection(Leave)
	end
end

function Table:_SortBy(Column)
	local Sorted = Utilities.SortBy(self.Rows, Column.Name, self._SortAscending)
	self._SortAscending = not self._SortAscending
	self.Rows = Sorted
	for _, Child in ipairs(self.Body:GetChildren()) do
		if Child:IsA("TextButton") then
			Child:Destroy()
		end
	end
	self:_BuildRows()
end

function Table:SetRows(Rows)
	self.Rows = Rows
	for _, Child in ipairs(self.Body:GetChildren()) do
		if Child:IsA("TextButton") then
			Child:Destroy()
		end
	end
	self:_BuildRows()
end

function Table:AddRow(Row)
	table.insert(self.Rows, Row)
	self:SetRows(self.Rows)
end

return Table
