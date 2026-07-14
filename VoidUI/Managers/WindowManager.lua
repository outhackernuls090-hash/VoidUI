local Utilities = require(script.Parent.Parent.Core.Utilities)
local Events = require(script.Parent.Parent.Core.Events)
local Cleanup = require(script.Parent.Parent.Core.Cleanup)

local WindowManager = {}
WindowManager.__index = WindowManager

function WindowManager.new(Parent)
	local self = setmetatable({}, WindowManager)
	self.Parent = Parent
	self.Windows = {}
	self.Active = nil
	self.ZIndexCounter = 100
	self.Changed = Events.new()
	self.WindowAdded = Events.new()
	self.WindowRemoved = Events.new()
	self.FocusChanged = Events.new()
	self.Cleanup = Cleanup.new()
	self.SnappingEnabled = true
	self.SnapThreshold = 24
	return self
end

function WindowManager:Register(Window)
	if Utilities.TableFind(self.Windows, Window) then
		return
	end
	table.insert(self.Windows, Window)
	self.WindowAdded:Fire(Window)
	self:Focus(Window)
end

function WindowManager:Unregister(Window)
	local Index = Utilities.TableFind(self.Windows, Window)
	if Index then
		table.remove(self.Windows, Index)
		self.WindowRemoved:Fire(Window)
	end
end

function WindowManager:GetAll()
	return self.Windows
end

function WindowManager:Count()
	return #self.Windows
end

function WindowManager:Focus(Window)
	if self.Active == Window then
		return
	end
	self.Active = Window
	self.ZIndexCounter = self.ZIndexCounter + 10
	if Window and Window.SetZIndex then
		Window:SetZIndex(self.ZIndexCounter)
	end
	self.FocusChanged:Fire(Window)
end

function WindowManager:GetActive()
	return self.Active
end

function WindowManager:NextZIndex()
	self.ZIndexCounter = self.ZIndexCounter + 1
	return self.ZIndexCounter
end

function WindowManager:Tile(Direction)
	local Count = #self.Windows
	if Count == 0 then
		return
	end
	local Viewport = Utilities.GetViewportSize()
	local Columns = math.ceil(math.sqrt(Count))
	local Rows = math.ceil(Count / Columns)
	local CellWidth = Viewport.X / Columns
	local CellHeight = Viewport.Y / Rows
	for Index, Window in ipairs(self.Windows) do
		local Col = (Index - 1) % Columns
		local Row = math.floor((Index - 1) / Columns)
		if Window.SetPosition then
			Window:SetPosition(UDim2.fromOffset(Col * CellWidth + 10, Row * CellHeight + 10))
		end
		if Window.SetSize then
			Window:SetSize(UDim2.fromOffset(CellWidth - 20, CellHeight - 20))
		end
	end
end

function WindowManager:Cascade()
	local Offset = 40
	for Index, Window in ipairs(self.Windows) do
		if Window.SetPosition then
			Window:SetPosition(UDim2.fromOffset(60 + (Index - 1) * Offset, 60 + (Index - 1) * Offset))
		end
	end
end

function WindowManager:MinimizeAll()
	for _, Window in ipairs(self.Windows) do
		if Window.Minimize then
			Window:Minimize()
		end
	end
end

function WindowManager:RestoreAll()
	for _, Window in ipairs(self.Windows) do
		if Window.Restore then
			Window:Restore()
		end
	end
end

function WindowManager:CloseAll()
	for _, Window in ipairs(self.Windows) do
		if Window.Close then
			Window:Close()
		end
	end
end

function WindowManager:FindByTitle(Title)
	for _, Window in ipairs(self.Windows) do
		if Window.Title == Title then
			return Window
		end
	end
	return nil
end

function WindowManager:Snap(Window, Position)
	if not self.SnappingEnabled then
		return Position
	end
	local Viewport = Utilities.GetViewportSize()
	local Threshold = self.SnapThreshold
	local X = Position.X.Offset
	local Y = Position.Y.Offset
	if math.abs(X) < Threshold then
		X = 0
	elseif math.abs(X + Window.Size.X.Offset - Viewport.X) < Threshold then
		X = Viewport.X - Window.Size.X.Offset
	end
	if math.abs(Y) < Threshold then
		Y = 0
	elseif math.abs(Y + Window.Size.Y.Offset - Viewport.Y) < Threshold then
		Y = Viewport.Y - Window.Size.Y.Offset
	end
	return UDim2.fromOffset(X, Y)
end

function WindowManager:SetSnapping(Enabled)
	self.SnappingEnabled = Enabled
end

function WindowManager:SubscribeWindowAdded(Callback)
	return self.WindowAdded:Connect(Callback)
end

function WindowManager:SubscribeWindowRemoved(Callback)
	return self.WindowRemoved:Connect(Callback)
end

function WindowManager:SubscribeFocusChanged(Callback)
	return self.FocusChanged:Connect(Callback)
end

function WindowManager:Destroy()
	for _, Window in ipairs(self.Windows) do
		if Window.Destroy then
			pcall(Window.Destroy, Window)
		end
	end
	self.Windows = {}
	self.Active = nil
	self.Cleanup:Destroy()
	self.Changed:DisconnectAll()
	self.WindowAdded:DisconnectAll()
	self.WindowRemoved:DisconnectAll()
	self.FocusChanged:DisconnectAll()
end

return WindowManager
