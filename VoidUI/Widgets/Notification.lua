local Utilities = require(script.Parent.Parent.Core.Utilities)
local Base = require(script.Parent.Base)
local Icons = require(script.Parent.Parent.Assets.Icons)

local Notification = {}
Notification.__index = setmetatable(Notification, Base)

function Notification.new(Application, Parent, Options)
	local self = setmetatable(Base.new(Application, Parent, Options), Notification)
	self.Title = Options.Title or "Notification"
	self.Description = Options.Description or ""
	self.Type = Options.Type or "Info"
	self.Duration = Options.Duration or 4
	self:_Build()
	return self
end

function Notification:_Build()
	local Theme = self.Theme
	local Container = self:_CreateContainer(0)
	Container.AutomaticSize = Enum.AutomaticSize.Y
	local Card = self:_CreateCard(0, {
		AutomaticSize = Enum.AutomaticSize.Y,
	})

	local ColorMap = {
		Success = Theme.Color("Success"),
		Warning = Theme.Color("Warning"),
		Danger = Theme.Color("Danger"),
		Info = Theme.Color("Info"),
	}
	local IconMap = {
		Success = "CheckCircle",
		Warning = "Warning",
		Danger = "Danger",
		Info = "Info",
	}
	local Accent = ColorMap[self.Type] or Theme.Color("Accent")

	local Layout = Utilities.AddListLayout(Card, Enum.FillDirection.Horizontal, 12, Enum.HorizontalAlignment.Left)
	Layout.VerticalAlignment = Enum.VerticalAlignment.Center
	local Padding = Utilities.AddPadding(Card, 14)

	local IconFrame = Icons.Create(IconMap[self.Type] or "Info", Accent, 22)
	IconFrame.Parent = Card

	local TextBlock = Utilities.Create("Frame", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, -34, 1, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Parent = Card,
	})
	local TextLayout = Utilities.AddListLayout(TextBlock, Enum.FillDirection.Vertical, 3)
	local Title = Utilities.Create("TextLabel", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 18),
		Font = Theme.Typography("FontBold"),
		TextSize = Theme.Typography("BodySize"),
		TextColor3 = Theme.Color("Text"),
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = self.Title,
		Parent = TextBlock,
	})
	local Desc = Utilities.Create("TextLabel", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Font = Theme.Typography("Font"),
		TextSize = Theme.Typography("CaptionSize"),
		TextColor3 = Theme.Color("TextMuted"),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextWrapped = true,
		Text = self.Description,
		Parent = TextBlock,
	})

	local AccentBar = Utilities.Create("Frame", {
		BackgroundColor3 = Accent,
		BorderSizePixel = 0,
		Size = UDim2.new(0, 3, 1, 0),
		Parent = Card,
	})

	self.Instance = Card
	self.Card = Card

	if self.Duration > 0 then
		local Connection
		Connection = game:GetService("RunService").Heartbeat:Connect(function(Delta)
			self.Duration = self.Duration - Delta
			if self.Duration <= 0 then
				Connection:Disconnect()
				self:Dismiss()
			end
		end)
		self.Cleanup:AddConnection(Connection)
	end

	local Click = Card.InputBegan:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 then
			self:Dismiss()
		end
	end)
	self.Cleanup:AddConnection(Click)
end

function Notification:Dismiss()
	self.Animation:Tween({
		Duration = 0.3,
		Easing = "QuadIn",
		OnUpdate = function(_, _, Progress)
			self.Card.Size = UDim2.new(1, 0, 0, self.Card.AbsoluteSize.Y * (1 - Progress))
			self.Card.BackgroundTransparency = Progress
		end,
		OnComplete = function()
			self:Destroy()
		end,
	})
end

function Notification:SetTitle(Title)
	self.Title = Title
	self.Instance:FindFirstChild("TextLabel", true).Text = Title
end

function Notification:SetDescription(Description)
	self.Description = Description
end

return Notification
