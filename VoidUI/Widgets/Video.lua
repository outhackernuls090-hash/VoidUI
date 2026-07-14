local Utilities = require(script.Parent.Parent.Core.Utilities)
local Base = require(script.Parent.Base)
local Icons = require(script.Parent.Parent.Assets.Icons)

local Video = {}
Video.__index = setmetatable(Video, Base)

function Video.new(Application, Parent, Options)
	local self = setmetatable(Base.new(Application, Parent, Options), Video)
	self.VideoId = Options.VideoId or Options.Source or ""
	self.Label = Options.Label or ""
	self.Playing = false
	self._Build()
	return self
end

function Video:_Build()
	local Theme = self.Theme
	local Container = self:_CreateContainer(self.Label ~= "" and 200 or 180)
	local Card = self:_CreateCard(Container.AbsoluteSize.Y, {
		AutomaticSize = Enum.AutomaticSize.Y,
	})
	local Layout = Utilities.AddListLayout(Card, Enum.FillDirection.Vertical, 6, Enum.HorizontalAlignment.Center)
	local Padding = Utilities.AddPadding(Card, 8)

	local Frame = Utilities.Create("ImageLabel", {
		Image = "rbxassetid://0",
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 150),
		ScaleType = Enum.ScaleType.Fit,
		Parent = Card,
	})
	local Corner = Utilities.Roundify(Frame, Theme.Layout("RadiusSmall"))

	local Overlay = Utilities.Create("TextButton", {
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundTransparency = 0.4,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		AutoButtonColor = false,
		Text = "",
		Parent = Frame,
	})
	local PlayButton = Utilities.Create("Frame", {
		BackgroundColor3 = Theme.Color("Accent"),
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(48, 48),
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Parent = Overlay,
	})
	local PlayCorner = Utilities.Roundify(PlayButton, 999)
	local PlayIcon = Icons.Create("Play", Theme.Color("TextInverse"), 22)
	PlayIcon.Position = UDim2.fromScale(0.5, 0.5)
	PlayIcon.AnchorPoint = Vector2.new(0.5, 0.5)
	PlayIcon.Parent = PlayButton

	self.Frame = Frame
	self.Overlay = Overlay
	self.PlayButton = PlayButton

	local Click = Overlay.MouseButton1Click:Connect(function()
		self:Toggle()
	end)
	self.Cleanup:AddConnection(Click)

	if self.Label ~= "" then
		local Label = Utilities.Create("TextLabel", {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 16),
			Font = Theme.Typography("FontSemibold"),
			TextSize = Theme.Typography("CaptionSize"),
			TextColor3 = Theme.Color("TextMuted"),
			Text = self.Label,
			Parent = Card,
		})
	end
end

function Video:Toggle()
	self.Playing = not self.Playing
	self.Overlay.BackgroundTransparency = self.Playing and 1 or 0.4
	self.PlayButton.Visible = not self.Playing
end

function Video:SetVideoId(Id)
	self.VideoId = Id
end

return Video
