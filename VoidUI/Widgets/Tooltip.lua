local Utilities = require(script.Parent.Parent.Core.Utilities)
local Base = require(script.Parent.Base)

local Tooltip = {}
Tooltip.__index = setmetatable(Tooltip, Base)

function Tooltip.new(Application, Text)
	local self = setmetatable(Base.new(Application, Application.Renderer:GetLayer("Cursor"), {}), Tooltip)
	self.Text = Text or ""
	self.Target = nil
	self.Visible = false
	self:_Build()
	return self
end

function Tooltip:_Build()
	local Theme = self.Theme
	local TooltipFrame = Utilities.Create("Frame", {
		BackgroundColor3 = Theme.Color("CardElevated"),
		BorderSizePixel = 0,
		Size = UDim2.new(0, 0, 0, 28),
		AutomaticSize = Enum.AutomaticSize.X,
		ZIndex = 400,
		Visible = false,
		Parent = self.Parent,
	})
	local Corner = Utilities.Roundify(TooltipFrame, Theme.Layout("RadiusSmall"))
	local Stroke = Utilities.AddStroke(TooltipFrame, Theme.Color("Border"), 1)
	local Padding = Utilities.AddPadding(TooltipFrame, 10)

	local Label = Utilities.Create("TextLabel", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(0, 0, 1, 0),
		AutomaticSize = Enum.AutomaticSize.X,
		Font = Theme.Typography("Font"),
		TextSize = Theme.Typography("CaptionSize"),
		TextColor3 = Theme.Color("Text"),
		Text = self.Text,
		ZIndex = 401,
		Parent = TooltipFrame,
	})
	self.Frame = TooltipFrame
	self.Label = Label
end

function Tooltip:Attach(Instance)
	self.Target = Instance
	local Enter = Instance.MouseEnter:Connect(function()
		self:Show()
	end)
	local Leave = Instance.MouseLeave:Connect(function()
		self:Hide()
	end)
	self.Cleanup:AddConnection(Enter)
	self.Cleanup:AddConnection(Leave)
	local Move = Instance.MouseMoved:Connect(function()
		self:_Follow()
	end)
	self.Cleanup:AddConnection(Move)
end

function Tooltip:Show()
	self.Visible = true
	self.Frame.Visible = true
	self:_Follow()
end

function Tooltip:Hide()
	self.Visible = false
	self.Frame.Visible = false
end

function Tooltip:_Follow()
	local Mouse = self.Application.InputManager:GetMousePosition()
	self.Frame.Position = UDim2.fromOffset(Mouse.X + 14, Mouse.Y + 14)
end

function Tooltip:SetText(Text)
	self.Text = Text
	self.Label.Text = Text
end

return Tooltip
