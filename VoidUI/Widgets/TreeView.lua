local Utilities = require(script.Parent.Parent.Core.Utilities)
local Base = require(script.Parent.Base)
local Icons = require(script.Parent.Parent.Assets.Icons)

local TreeView = {}
TreeView.__index = setmetatable(TreeView, Base)

function TreeView.new(Application, Parent, Options)
	local self = setmetatable(Base.new(Application, Parent, Options), TreeView)
	self.Nodes = Options.Nodes or {}
	self.OnSelect = Options.OnSelect
	self._Build()
	return self
end

function TreeView:_Build()
	local Theme = self.Theme
	local Container = self:_CreateContainer(0)
	Container.AutomaticSize = Enum.AutomaticSize.Y
	local Card = self:_CreateCard(0, {
		AutomaticSize = Enum.AutomaticSize.Y,
	})
	local Padding = Utilities.AddPadding(Card, 8)
	local Layout = Utilities.AddListLayout(Card, Enum.FillDirection.Vertical, 2, Enum.HorizontalAlignment.Left)
	self.Card = Card

	self:_BuildNodes(self.Nodes, Card, 0)
end

function TreeView:_BuildNodes(Nodes, Parent, Depth)
	local Theme = self.Theme
	for _, Node in ipairs(Nodes) do
		local Row = Utilities.Create("TextButton", {
			BackgroundColor3 = Theme.Color("Surface"),
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 28),
			AutoButtonColor = false,
			Text = "",
			Parent = Parent,
		})
		local RowCorner = Utilities.Roundify(Row, Theme.Layout("RadiusSmall"))
		local RowLayout = Utilities.AddListLayout(Row, Enum.FillDirection.Horizontal, 6, Enum.HorizontalAlignment.Left)
		RowLayout.VerticalAlignment = Enum.VerticalAlignment.Center
		RowLayout.Padding = UDim.new(0, 6 + Depth * 16)

		local HasChildren = Node.Children and #Node.Children > 0
		local Chevron
		if HasChildren then
			Chevron = Icons.Create("ChevronRight", Theme.Color("TextMuted"), 14)
			Chevron.Parent = Row
		else
			local Spacer = Utilities.Create("Frame", {
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Size = UDim2.fromOffset(14, 14),
				Parent = Row,
			})
		end

		local IconName = Node.Icon or (HasChildren and "Folder" or "File")
		local IconFrame = Icons.Create(IconName, Theme.Color("TextMuted"), 16)
		IconFrame.Parent = Row

		local Label = Utilities.Create("TextLabel", {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, -60, 1, 0),
			Font = Theme.Typography("Font"),
			TextSize = Theme.Typography("BodySize"),
			TextColor3 = Theme.Color("Text"),
			TextXAlignment = Enum.TextXAlignment.Left,
			Text = Node.Label or Node.Name or "Node",
			Parent = Row,
		})

		local ChildContainer
		if HasChildren then
			ChildContainer = Utilities.Create("Frame", {
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				Visible = false,
				Parent = Parent,
			})
			local ChildLayout = Utilities.AddListLayout(ChildContainer, Enum.FillDirection.Vertical, 2, Enum.HorizontalAlignment.Left)
			self:_BuildNodes(Node.Children, ChildContainer, Depth + 1)
		end

		local Expanded = false
		local Click = Row.MouseButton1Click:Connect(function()
			if HasChildren then
				Expanded = not Expanded
				self.Animation:Animate(Chevron, "Rotation", Expanded and 90 or 0, { Duration = 0.15 })
				ChildContainer.Visible = Expanded
			end
			self.Changed:Fire(Node)
			Utilities.SafeCall(self.OnSelect, Node)
		end)
		self.Cleanup:AddConnection(Click)
		local Enter = Row.MouseEnter:Connect(function()
			self.Animation:Animate(Row, "BackgroundColor3", Theme.Color("SurfaceHover"), { Duration = 0.1 })
		end)
		local Leave = Row.MouseLeave:Connect(function()
			self.Animation:Animate(Row, "BackgroundColor3", Theme.Color("Surface"), { Duration = 0.1 })
		end)
		self.Cleanup:AddConnection(Enter)
		self.Cleanup:AddConnection(Leave)
	end
end

function TreeView:SetNodes(Nodes)
	self.Nodes = Nodes
	for _, Child in ipairs(self.Card:GetChildren()) do
		if Child:IsA("TextButton") or Child:IsA("Frame") then
			Child:Destroy()
		end
	end
	self:_BuildNodes(Nodes, self.Card, 0)
end

return TreeView
