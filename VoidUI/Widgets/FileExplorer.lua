local Utilities = require(script.Parent.Parent.Core.Utilities)
local Base = require(script.Parent.Base)
local Icons = require(script.Parent.Parent.Assets.Icons)

local FileExplorer = {}
FileExplorer.__index = setmetatable(FileExplorer, Base)

function FileExplorer.new(Application, Parent, Options)
	local self = setmetatable(Base.new(Application, Parent, Options), FileExplorer)
	self.Root = Options.Root or {
		Name = "root",
		Type = "Folder",
		Children = {
			{ Name = "Scripts", Type = "Folder", Children = {
				{ Name = "main.lua", Type = "File" },
				{ Name = "utils.lua", Type = "File" },
			} },
			{ Name = "Assets", Type = "Folder", Children = {
				{ Name = "icon.png", Type = "File" },
			} },
			{ Name = "README.md", Type = "File" },
		},
	}
	self.OnOpen = Options.OnOpen
	self._Build()
	return self
end

function FileExplorer:_Build()
	local Theme = self.Theme
	local Container = self:_CreateContainer(0)
	Container.AutomaticSize = Enum.AutomaticSize.Y
	local Card = self:_CreateCard(0, {
		AutomaticSize = Enum.AutomaticSize.Y,
	})
	local Padding = Utilities.AddPadding(Card, 8)
	local Layout = Utilities.AddListLayout(Card, Enum.FillDirection.Vertical, 2, Enum.HorizontalAlignment.Left)
	self.Card = Card

	self:_RenderNode(self.Root, Card, 0)
end

function FileExplorer:_RenderNode(Node, Parent, Depth)
	local Theme = self.Theme
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

	local IsFolder = Node.Type == "Folder"
	local IconName = IsFolder and "Folder" or "File"
	local IconFrame = Icons.Create(IconName, IsFolder and Theme.Color("Accent") or Theme.Color("TextMuted"), 16)
	IconFrame.Parent = Row

	local Label = Utilities.Create("TextLabel", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, -40, 1, 0),
		Font = Theme.Typography("Font"),
		TextSize = Theme.Typography("BodySize"),
		TextColor3 = Theme.Color("Text"),
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = Node.Name,
		Parent = Row,
	})

	local ChildContainer
	if IsFolder and Node.Children then
		ChildContainer = Utilities.Create("Frame", {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			Visible = false,
			Parent = Parent,
		})
		local ChildLayout = Utilities.AddListLayout(ChildContainer, Enum.FillDirection.Vertical, 2, Enum.HorizontalAlignment.Left)
		self:_RenderNodeList(Node.Children, ChildContainer, Depth + 1)
	end

	local Expanded = false
	local Click = Row.MouseButton1Click:Connect(function()
		if IsFolder then
			Expanded = not Expanded
			ChildContainer.Visible = Expanded
		else
			self.Changed:Fire(Node)
			Utilities.SafeCall(self.OnOpen, Node)
		end
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

function FileExplorer:_RenderNodeList(Nodes, Parent, Depth)
	for _, Node in ipairs(Nodes) do
		self:_RenderNode(Node, Parent, Depth)
	end
end

return FileExplorer
