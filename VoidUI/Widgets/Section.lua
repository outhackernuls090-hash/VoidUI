local Utilities = require(script.Parent.Parent.Core.Utilities)
local Base = require(script.Parent.Base)
local Icons = require(script.Parent.Parent.Assets.Icons)

local Section = {}
Section.__index = setmetatable(Section, Base)

function Section.new(Application, Parent, Options)
	local self = setmetatable(Base.new(Application, Parent, Options), Section)
	self.Title = Options.Title or "Section"
	self.Icon = Options.Icon
	self.Collapsible = Options.Collapsible or false
	self.Collapsed = Options.Collapsed or false
	self.Children = {}
	self._Build()
	return self
end

function Section:_Build()
	local Theme = self.Theme
	local Container = self:_CreateContainer(0)
	Container.AutomaticSize = Enum.AutomaticSize.Y

	local Header = Utilities.Create("TextButton", {
		BackgroundColor3 = Theme.Color("Surface"),
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 36),
		AutoButtonColor = false,
		Text = "",
		Parent = Container,
	})
	local HeaderCorner = Utilities.Roundify(Header, Theme.Layout("RadiusSmall"))
	local HeaderStroke = Utilities.AddStroke(Header, Theme.Color("Border"), 1)
	local HeaderLayout = Utilities.AddListLayout(Header, Enum.FillDirection.Horizontal, 8, Enum.HorizontalAlignment.Left)
	HeaderLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	HeaderLayout.Padding = UDim.new(0, 12)

	if self.Icon then
		local IconFrame = Icons.Create(self.Icon, Theme.Color("Accent"), 18)
		IconFrame.Parent = Header
	end

	local Title = Utilities.Create("TextLabel", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, -40, 1, 0),
		Font = Theme.Typography("FontBold"),
		TextSize = Theme.Typography("HeaderSize"),
		TextColor3 = Theme.Color("Text"),
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = self.Title,
		Parent = Header,
	})

	local Chevron
	if self.Collapsible then
		Chevron = Icons.Create("ChevronDown", Theme.Color("TextMuted"), 16)
		Chevron.Parent = Header
	end

	local Body = Utilities.Create("Frame", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Parent = Container,
	})
	local BodyLayout = Utilities.AddListLayout(Body, Enum.FillDirection.Vertical, 8, Enum.HorizontalAlignment.Center)
	BodyLayout.Padding = UDim.new(0, 8)
	local BodyPadding = Utilities.AddPadding(Body, 8)

	self.Header = Header
	self.Body = Body
	self.Chevron = Chevron

	if self.Collapsible then
		local Click = Header.MouseButton1Click:Connect(function()
			self:ToggleCollapse()
		end)
		self.Cleanup:AddConnection(Click)
	end
	local Enter = Header.MouseEnter:Connect(function()
		self.Animation:Animate(Header, "BackgroundColor3", Theme.Color("SurfaceHover"), { Duration = 0.12 })
	end)
	local Leave = Header.MouseLeave:Connect(function()
		self.Animation:Animate(Header, "BackgroundColor3", Theme.Color("Surface"), { Duration = 0.12 })
	end)
	self.Cleanup:AddConnection(Enter)
	self.Cleanup:AddConnection(Leave)
end

function Section:Add(Widget)
	Widget:SetParent(self.Body)
	table.insert(self.Children, Widget)
	return Widget
end

function Section:ToggleCollapse()
	self.Collapsed = not self.Collapsed
	if self.Chevron then
		self.Animation:Animate(self.Chevron, "Rotation", self.Collapsed and -90 or 0, { Duration = 0.2 })
	end
	self.Body.Visible = not self.Collapsed
end

function Section:SetTitle(Title)
	self.Title = Title
	self.Header:FindFirstChild("TextLabel", true).Text = Title
end

function Section:_ApplyTheme()
	Base._ApplyTheme(self)
	if self.Header then
		self.Header.BackgroundColor3 = self.Theme.Color("Surface")
	end
end

return Section
