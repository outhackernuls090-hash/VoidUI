local Utilities = require(script.Parent.Parent.Core.Utilities)
local Events = require(script.Parent.Parent.Core.Events)
local Cleanup = require(script.Parent.Parent.Core.Cleanup)
local Icons = require(script.Parent.Parent.Assets.Icons)

local NotificationManager = {}
NotificationManager.__index = NotificationManager

function NotificationManager.new(Parent, Theme)
	local self = setmetatable({}, NotificationManager)
	self.Parent = Parent
	self.Theme = Theme
	self.Notifications = {}
	self.Queue = {}
	self.MaxVisible = 4
	self.Position = "TopRight"
	self.Changed = Events.new()
	self.Dismissed = Events.new()
	self.Cleanup = Cleanup.new()
	self.Container = nil
	self:_Build()
	return self
end

function NotificationManager:_Build()
	local Container = Utilities.Create("Frame", {
		Name = "NotificationContainer",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(0, 320, 1, 0),
		Position = UDim2.new(1, -20, 0, 20),
		AnchorPoint = Vector2.new(1, 0),
		Parent = self.Parent,
	})
	local Layout = Utilities.AddListLayout(Container, Enum.FillDirection.Vertical, 10, Enum.HorizontalAlignment.Right)
	Layout.VerticalAlignment = Enum.VerticalAlignment.Top
	self.Container = Container
	self.Cleanup:AddInstance(Container)
end

function NotificationManager:SetPosition(Position)
	self.Position = Position
	local Anchor = Vector2.new(1, 0)
	local Pos = UDim2.new(1, -20, 0, 20)
	if Position == "TopLeft" then
		Anchor = Vector2.new(0, 0)
		Pos = UDim2.new(0, 20, 0, 20)
	elseif Position == "BottomRight" then
		Anchor = Vector2.new(1, 1)
		Pos = UDim2.new(1, -20, 1, -20)
	elseif Position == "BottomLeft" then
		Anchor = Vector2.new(0, 1)
		Pos = UDim2.new(0, 20, 1, -20)
	end
	self.Container.AnchorPoint = Anchor
	self.Container.Position = Pos
end

function NotificationManager:Notify(Options)
	Options = Options or {}
	local Notification = self:_Create(Options)
	table.insert(self.Notifications, Notification)
	self.Changed:Fire(Notification)
	self:_Reflow()
	return Notification
end

function NotificationManager:Success(Title, Description, Duration)
	return self:Notify({ Title = Title, Description = Description, Type = "Success", Duration = Duration })
end

function NotificationManager:Warning(Title, Description, Duration)
	return self:Notify({ Title = Title, Description = Description, Type = "Warning", Duration = Duration })
end

function NotificationManager:Error(Title, Description, Duration)
	return self:Notify({ Title = Title, Description = Description, Type = "Danger", Duration = Duration })
end

function NotificationManager:Info(Title, Description, Duration)
	return self:Notify({ Title = Title, Description = Description, Type = "Info", Duration = Duration })
end

function NotificationManager:_Create(Options)
	local Theme = self.Theme
	local Type = Options.Type or "Info"
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
	local Accent = ColorMap[Type] or Theme.Color("Accent")
	local Card = Utilities.Create("Frame", {
		Name = "Notification",
		BackgroundColor3 = Theme.Color("CardElevated"),
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		ClipsDescendants = true,
		Parent = self.Container,
	})
	local Corner = Utilities.Roundify(Card, Theme.Layout("Radius"))
	local Stroke = Utilities.AddStroke(Card, Theme.Color("Border"), 1)
	local Padding = Utilities.AddPadding(Card, 14)

	local AccentBar = Utilities.Create("Frame", {
		BackgroundColor3 = Accent,
		BorderSizePixel = 0,
		Size = UDim2.new(0, 3, 1, 0),
		Position = UDim2.new(0, 0, 0, 0),
		Parent = Card,
	})

	local Content = Utilities.Create("Frame", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, -16, 1, 0),
		Position = UDim2.new(0, 16, 0, 0),
		Parent = Card,
	})
	local ContentLayout = Utilities.AddListLayout(Content, Enum.FillDirection.Horizontal, 12, Enum.HorizontalAlignment.Left)
	ContentLayout.VerticalAlignment = Enum.VerticalAlignment.Center

	local IconFrame = Icons.Create(IconMap[Type] or "Info", Accent, 22)
	IconFrame.Parent = Content

	local TextBlock = Utilities.Create("Frame", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, -34, 1, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Parent = Content,
	})
	local TextLayout = Utilities.AddListLayout(TextBlock, Enum.FillDirection.Vertical, 3)
	local TitleLabel = Utilities.Create("TextLabel", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 18),
		Font = Theme.Typography("FontBold"),
		TextSize = Theme.Typography("BodySize"),
		TextColor3 = Theme.Color("Text"),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Text = Options.Title or "Notification",
		Parent = TextBlock,
	})
	local DescLabel = Utilities.Create("TextLabel", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Font = Theme.Typography("Font"),
		TextSize = Theme.Typography("CaptionSize"),
		TextColor3 = Theme.Color("TextMuted"),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextWrapped = true,
		Text = Options.Description or "",
		Parent = TextBlock,
	})

	local Notification = {
		Id = Utilities.UniqueId(),
		Card = Card,
		Options = Options,
		Type = Type,
		CreatedAt = tick(),
		Duration = Options.Duration or 4,
		Dismissed = false,
		Dismiss = function()
			self:Dismiss(Notification)
		end,
	}

	Card.Size = UDim2.new(1, 0, 0, 0)
	Card.BackgroundTransparency = 1
	Card.Visible = true
	local TargetHeight = Card.AbsoluteSize.Y
	Card.Size = UDim2.new(1, 0, 0, 0)

	local TweenService = game:GetService("TweenService")
	local ShowTween = TweenService:Create(Card, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = UDim2.new(1, 0, 0, math.max(TargetHeight, 56)),
		BackgroundTransparency = 0,
	})
	ShowTween:Play()

	if Notification.Duration > 0 then
		local Connection
		Connection = game:GetService("RunService").Heartbeat:Connect(function(Delta)
			Notification.Duration = Notification.Duration - Delta
			if Notification.Duration <= 0 then
				Connection:Disconnect()
				Notification:Dismiss()
			end
		end)
		self.Cleanup:AddConnection(Connection)
	end

	local ClickConnection = Card.InputBegan:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 then
			Notification:Dismiss()
		end
	end)
	self.Cleanup:AddConnection(ClickConnection)

	return Notification
end

function NotificationManager:Dismiss(Notification)
	if Notification.Dismissed then
		return
	end
	Notification.Dismissed = true
	local TweenService = game:GetService("TweenService")
	local HideTween = TweenService:Create(Notification.Card, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
		Size = UDim2.new(1, 0, 0, 0),
		BackgroundTransparency = 1,
	})
	HideTween:Play()
	HideTween.Completed:Connect(function()
		Notification.Card:Destroy()
		local Index = Utilities.TableFind(self.Notifications, Notification)
		if Index then
			table.remove(self.Notifications, Index)
		end
		self.Dismissed:Fire(Notification)
		self:_Reflow()
	end)
end

function NotificationManager:_Reflow()
	local Layout = self.Container:FindFirstChildOfClass("UIListLayout")
	if Layout then
		Layout:ApplyLayout()
	end
end

function NotificationManager:Clear()
	for _, Notification in ipairs(self.Notifications) do
		Notification:Dismiss()
	end
end

function NotificationManager:Count()
	return #self.Notifications
end

function NotificationManager:SetMaxVisible(Max)
	self.MaxVisible = Max
end

function NotificationManager:Destroy()
	self:Clear()
	self.Cleanup:Destroy()
end

return NotificationManager
