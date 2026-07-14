local Utilities = require(script.Parent.Parent.Core.Utilities)
local Base = require(script.Parent.Base)
local Icons = require(script.Parent.Parent.Assets.Icons)

local Timeline = {}
Timeline.__index = setmetatable(Timeline, Base)

function Timeline.new(Application, Parent, Options)
	local self = setmetatable(Base.new(Application, Parent, Options), Timeline)
	self.Events = Options.Events or {}
	self.Duration = Options.Duration or 100
	self.Height = Options.Height or 120
	self.Playing = false
	self.Position = 0
	self.OnSeek = Options.OnSeek
	self:_Build()
	return self
end

function Timeline:_Build()
	local Theme = self.Theme
	local Container = self:_CreateContainer(self.Height + 50)
	local Card = self:_CreateCard(Container.AbsoluteSize.Y, {
		AutomaticSize = Enum.AutomaticSize.Y,
	})
	local Padding = Utilities.AddPadding(Card, 12)

	local Controls = Utilities.Create("Frame", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 32),
		Parent = Card,
	})
	local ControlsLayout = Utilities.AddListLayout(Controls, Enum.FillDirection.Horizontal, 8, Enum.HorizontalAlignment.Left)
	ControlsLayout.VerticalAlignment = Enum.VerticalAlignment.Center

	local PlayButton = Utilities.Create("TextButton", {
		BackgroundColor3 = Theme.Color("Accent"),
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(32, 32),
		AutoButtonColor = false,
		Text = "",
		Parent = Controls,
	})
	local PlayCorner = Utilities.Roundify(PlayButton, Theme.Layout("RadiusSmall"))
	local PlayIcon = Icons.Create("Play", Theme.Color("TextInverse"), 16)
	PlayIcon.Parent = PlayButton
	local PlayClick = PlayButton.MouseButton1Click:Connect(function()
		self:TogglePlay()
	end)
	self.Cleanup:AddConnection(PlayClick)

	local TimeLabel = Utilities.Create("TextLabel", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, -40, 1, 0),
		Font = Theme.Typography("FontMono"),
		TextSize = Theme.Typography("CaptionSize"),
		TextColor3 = Theme.Color("TextMuted"),
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = "0.0 / " .. self.Duration .. "s",
		Parent = Controls,
	})
	self.TimeLabel = TimeLabel

	local Track = Utilities.Create("TextButton", {
		BackgroundColor3 = Theme.Color("SurfaceActive"),
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, self.Height),
		AutoButtonColor = false,
		Text = "",
		Parent = Card,
	})
	local TrackCorner = Utilities.Roundify(Track, Theme.Layout("RadiusSmall"))
	local TrackGradient = Utilities.AddGradient(Track, Theme.Gradient("Surface"), 90)
	TrackGradient.Transparency = NumberSequence.new(0.6)

	local Playhead = Utilities.Create("Frame", {
		BackgroundColor3 = Theme.Color("Accent"),
		BorderSizePixel = 0,
		Size = UDim2.new(0, 2, 1, 0),
		Position = UDim2.new(0, 0, 0, 0),
		Parent = Track,
	})

	for _, Event in ipairs(self.Events) do
		local Marker = Utilities.Create("Frame", {
			BackgroundColor3 = Theme.Color("AccentGlow"),
			BorderSizePixel = 0,
			Size = UDim2.new(0, 4, 1, 0),
			Position = UDim2.new(Utilities.Clamp(Event.Time / self.Duration, 0, 1), 0, 0, 0),
			Parent = Track,
		})
	end

	self.Track = Track
	self.Playhead = Playhead

	local UserInputService = game:GetService("UserInputService")
	local Dragging = false
	local Begin = Track.InputBegan:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
			Dragging = true
			self:_SeekFromInput(Input)
		end
	end)
	local End = UserInputService.InputEnded:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
			Dragging = false
		end
	end)
	local Move = UserInputService.InputChanged:Connect(function(Input)
		if Dragging and (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then
			self:_SeekFromInput(Input)
		end
	end)
	self.Cleanup:AddConnection(Begin)
	self.Cleanup:AddConnection(End)
	self.Cleanup:AddConnection(Move)

	local Connection
	Connection = game:GetService("RunService").Heartbeat:Connect(function(Delta)
		if self.Playing then
			self.Position = self.Position + Delta
			if self.Position >= self.Duration then
				self.Position = self.Duration
				self:Stop()
			end
			self:_UpdatePlayhead()
		end
	end)
	self.Cleanup:AddConnection(Connection)
end

function Timeline:_SeekFromInput(Input)
	local Ratio = Utilities.Clamp((Input.Position.X - self.Track.AbsolutePosition.X) / self.Track.AbsoluteSize.X, 0, 1)
	self.Position = Ratio * self.Duration
	self:_UpdatePlayhead()
	Utilities.SafeCall(self.OnSeek, self.Position)
end

function Timeline:_UpdatePlayhead()
	local Ratio = self.Position / self.Duration
	self.Playhead.Position = UDim2.new(Ratio, 0, 0, 0)
	self.TimeLabel.Text = string.format("%.1f / %ds", self.Position, self.Duration)
end

function Timeline:TogglePlay()
	if self.Playing then
		self:Stop()
	else
		self:Play()
	end
end

function Timeline:Play()
	self.Playing = true
end

function Timeline:Stop()
	self.Playing = false
end

function Timeline:Seek(Position)
	self.Position = Utilities.Clamp(Position, 0, self.Duration)
	self:_UpdatePlayhead()
end

function Timeline:SetEvents(Events)
	self.Events = Events
end

return Timeline
