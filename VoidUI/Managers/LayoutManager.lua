local Utilities = require(script.Parent.Parent.Core.Utilities)
local Events = require(script.Parent.Parent.Core.Events)

local LayoutManager = {}
LayoutManager.__index = LayoutManager

function LayoutManager.new()
	local self = setmetatable({}, LayoutManager)
	self.Regions = {}
	self.Constraints = {}
	self.Changed = Events.new()
	self.VirtualLists = {}
	return self
end

function LayoutManager:RegisterRegion(Name, Frame, Options)
	Options = Options or {}
	local Region = {
		Name = Name,
		Frame = Frame,
		Direction = Options.Direction or Enum.FillDirection.Vertical,
		Padding = Options.Padding or 8,
		Align = Options.Align or Enum.HorizontalAlignment.Left,
		Virtual = Options.Virtual or false,
		ItemHeight = Options.ItemHeight or 36,
		RenderWindow = Options.RenderWindow or 200,
		Items = {},
		Layout = nil,
	}
	if not Options.Virtual then
		local Layout = Utilities.AddListLayout(Frame, Region.Direction, Region.Padding, Region.Align)
		Region.Layout = Layout
	end
	self.Regions[Name] = Region
	return Region
end

function LayoutManager:AddItem(RegionName, Item, Index)
	local Region = self.Regions[RegionName]
	if not Region then
		return
	end
	if Index then
		table.insert(Region.Items, Index, Item)
	else
		table.insert(Region.Items, Item)
	end
	if not Region.Virtual and Item.Instance then
		Item.Instance.Parent = Region.Frame
		Item.Instance.LayoutOrder = #Region.Items
	end
	self.Changed:Fire(RegionName, "Add")
end

function LayoutManager:RemoveItem(RegionName, Item)
	local Region = self.Regions[RegionName]
	if not Region then
		return
	end
	local Index = Utilities.TableFind(Region.Items, Item)
	if Index then
		table.remove(Region.Items, Index)
		if Item.Instance and Item.Instance.Parent == Region.Frame then
			Item.Instance.Parent = nil
		end
		self.Changed:Fire(RegionName, "Remove")
	end
end

function LayoutManager:ClearRegion(RegionName)
	local Region = self.Regions[RegionName]
	if not Region then
		return
	end
	for _, Item in ipairs(Region.Items) do
		if Item.Instance then
			Item.Instance:Destroy()
		end
	end
	Region.Items = {}
	self.Changed:Fire(RegionName, "Clear")
end

function LayoutManager:EnableVirtual(RegionName, ScrollFrame, Viewport)
	local Region = self.Regions[RegionName]
	if not Region then
		return
	end
	Region.Virtual = true
	Region.ScrollFrame = ScrollFrame
	Region.Viewport = Viewport
	self.VirtualLists[RegionName] = Region
	self:_SetupVirtual(Region)
end

function LayoutManager:_SetupVirtual(Region)
	local Content = Utilities.Create("Frame", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Parent = Region.ScrollFrame,
	})
	Region.Content = Content
	local Layout = Utilities.AddListLayout(Content, Region.Direction, Region.Padding, Region.Align)
	Region.Layout = Layout

	local Connection
	Connection = Region.ScrollFrame:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
		self:_UpdateVirtual(Region)
	end)
	Region._Connection = Connection
	self:_UpdateVirtual(Region)
end

function LayoutManager:_UpdateVirtual(Region)
	if not Region.ScrollFrame or not Region.Content then
		return
	end
	local Total = #Region.Items
	local ViewportHeight = Region.Viewport or Region.ScrollFrame.AbsoluteSize.Y
	local ScrollY = Region.ScrollFrame.CanvasPosition.Y
	local StartIndex = math.max(1, math.floor(ScrollY / Region.ItemHeight) - 2)
	local EndIndex = math.min(Total, math.ceil((ScrollY + ViewportHeight) / Region.ItemHeight) + 2)

	for Index, Item in ipairs(Region.Items) do
		local Visible = Index >= StartIndex and Index <= EndIndex
		if Visible and not Item.Instance then
			Item.Instance = Item.Factory and Item:Factory() or Item.Create()
			Item.Instance.LayoutOrder = Index
			Item.Instance.Parent = Region.Content
		elseif not Visible and Item.Instance then
			Item.Instance:Destroy()
			Item.Instance = nil
		end
	end
end

function LayoutManager:RefreshVirtual(RegionName)
	local Region = self.VirtualLists[RegionName]
	if Region then
		self:_UpdateVirtual(Region)
	end
end

function LayoutManager:SetConstraint(RegionName, Constraint)
	self.Constraints[RegionName] = Constraint
end

function LayoutManager:ApplyGrid(Frame, CellSize, CellPadding)
	return Utilities.AddGridLayout(Frame, CellSize, CellPadding)
end

function LayoutManager:ApplyList(Frame, Direction, Padding, Align)
	return Utilities.AddListLayout(Frame, Direction, Padding, Align)
end

function LayoutManager:ApplyPadding(Frame, Padding)
	return Utilities.AddPadding(Frame, Padding)
end

function LayoutManager:ApplyFlex(Frame, Direction, Padding, Align, Wrap)
	local Layout = Utilities.AddListLayout(Frame, Direction, Padding, Align)
	Layout.Wraps = Wrap or false
	return Layout
end

function LayoutManager:GetRegion(Name)
	return self.Regions[Name]
end

function LayoutManager:GetItemCount(RegionName)
	local Region = self.Regions[RegionName]
	return Region and #Region.Items or 0
end

function LayoutManager:Subscribe(Callback)
	return self.Changed:Connect(Callback)
end

function LayoutManager:Destroy()
	for _, Region in pairs(self.Regions) do
		if Region._Connection then
			Region._Connection:Disconnect()
		end
		self:ClearRegion(Region.Name)
	end
	self.Regions = {}
	self.VirtualLists = {}
	self.Constraints = {}
	self.Changed:DisconnectAll()
end

return LayoutManager
