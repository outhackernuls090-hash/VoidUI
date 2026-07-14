local Utilities = require(script.Parent.Parent.Core.Utilities)
local Base = require(script.Parent.Base)
local Icons = require(script.Parent.Parent.Assets.Icons)

local Audio = {}
Audio.__index = setmetatable(Audio, Base)

function Audio.new(Application, Parent, Options)
	local self = setmetatable(Base.new(Application, Parent, Options), Audio)
	self.SoundId = Options.SoundId or Options.Source or ""
	self.Label = Options.Label or "Audio"
	self.Volume = Options.Volume or 1
	self.Playing = false
	self._Build()
	return self
end

function Audio:_Build()
	local Theme = self.Theme
	local Container = self:_CreateContainer(56)
	local Card = self:_CreateCard(Container.AbsoluteSize.Y, {
		AutomaticSize = Enum.AutomaticSize.Y,
	})
	local Layout = Utilities.AddListLayout(Card, Enum.FillDirection.Horizontal, 10, Enum.HorizontalAlignment.Left)
	Layout.VerticalAlignment = Enum.VerticalAlignment.Center
	local Padding = Utilities.AddPadding(Card, 12)

	local PlayButton = Utilities.Create("TextButton", {
		BackgroundColor3 = Theme.Color("Accent"),
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(36, 36),
		AutoButtonColor = false,
		Text = "",
		Parent = Card,
	})
	local PlayCorner = Utilities.Roundify(PlayButton, 999)
	local PlayIcon = Icons.Create("Play", Theme.Color("TextInverse"), 18)
	PlayIcon.Parent = PlayButton
	self.PlayButton = PlayButton
	self.PlayIcon = PlayIcon

	local TextBlock = Utilities.Create("Frame", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, -50, 1, 0),
		Parent = Card,
	})
	local TextLayout = Utilities.AddListLayout(TextBlock, Enum.FillDirection.Vertical, 4)
	local Label = Utilities.Create("TextLabel", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 16),
		Font = Theme.Typography("FontSemibold"),
		TextSize = Theme.Typography("BodySize"),
		TextColor3 = Theme.Color("Text"),
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = self.Label,
		Parent = TextBlock,
	})

	local VolumeTrack = Utilities.Create("Frame", {
		BackgroundColor3 = Theme.Color("SurfaceActive"),
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 4),
		Parent = TextBlock,
	})
	local VolumeCorner = Utilities.Roundify(VolumeTrack, 999)
	local VolumeFill = Utilities.Create("Frame", {
		BackgroundColor3 = Theme.Color("Accent"),
		BorderSizePixel = 0,
		Size = UDim2.new(self.Volume, 0, 1, 0),
		Parent = VolumeTrack,
	})
	local VolumeFillCorner = Utilities.Roundify(VolumeFill, 999)
	self.VolumeFill = VolumeFill

	local Click = PlayButton.MouseButton1Click:Connect(function()
		self:Toggle()
	end)
	self.Cleanup:AddConnection(Click)
end

function Audio:Toggle()
	self.Playing = not self.Playing
	self.PlayIcon:Destroy()
	self.PlayIcon = Icons.Create(self.Playing and "Pause" or "Play", self.Theme.Color("TextInverse"), 18)
	self.PlayIcon.Parent = self.PlayButton
end

function Audio:SetVolume(Volume)
	self.Volume = Utilities.Clamp(Volume, 0, 1)
	self.VolumeFill.Size = UDim2.new(self.Volume, 0, 1, 0)
end

function Audio:SetSoundId(Id)
	self.SoundId = Id
end

return Audio
