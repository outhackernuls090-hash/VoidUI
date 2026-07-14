local Utilities = require(script.Parent.Parent.Core.Utilities)
local Base = require(script.Parent.Base)
local Icons = require(script.Parent.Parent.Assets.Icons)
local Events = require(script.Parent.Parent.Core.Events)

local NestedTabs = {}
NestedTabs.__index = setmetatable(NestedTabs, Base)

function NestedTabs.new(Application, Parent, Options)
	local self = setmetatable(Base.new(Application, Parent, Options), NestedTabs)
	self.Tabs = Options.Tabs or {}
	self.Active = nil
	self.Changed = Events.new()
	self:_Build()
	return self
end

function NestedTabs:_Build()
	local Theme = self.Theme
	local Container = self:_CreateContainer(0)
	Container.AutomaticSize = Enum.AutomaticSize.Y
	local Card = self:_CreateCard(0, {
		AutomaticSize = Enum.AutomaticSize.Y,
	})

	local TabBar = Utilities.Create("Frame", {
		BackgroundColor3 = Theme.Color("Surface"),
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 34),
		Parent = Card,
	})
	local TabBarCorner = Utilities.Roundify(TabBar, Theme.Layout("RadiusSmall"))
	local TabBarLayout = Utilities.AddListLayout(TabBar, Enum.FillDirection.Horizontal, 4, Enum.HorizontalAlignment.Left)
	TabBarLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	TabBarLayout.Padding = UDim.new(0, 4)
	local TabBarPadding = Utilities.AddPadding(TabBar, 4)

	local Content = Utilities.Create("Frame", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Parent = Card,
	})
	local ContentLayout = Utilities.AddListLayout(Content, Enum.FillDirection.Vertical, 8, Enum.HorizontalAlignment.Center)
	ContentLayout.Padding = UDim.new(0, 8)
	local ContentPadding = Utilities.AddPadding(Content, 8)

	self.TabBar = TabBar
	self.Content = Content
	self.Buttons = {}

	for Index, Tab in ipairs(self.Tabs) do
		self:_CreateTabButton(Tab, Index)
	end

	if #self.Tabs > 0 then
		self:Select(1)
	end
end

function NestedTabs:_CreateTabButton(Tab, Index)
	local Theme = self.Theme
	local Button = Utilities.Create("TextButton", {
		BackgroundColor3 = Theme.Color("SurfaceHover"),
		BorderSizePixel = 0,
		Size = UDim2.new(0, 0, 1, -8),
		AutomaticSize = Enum.AutomaticSize.X,
		AutoButtonColor = false,
		Text = "",
		Parent = self.TabBar,
	})
	local ButtonCorner = Utilities.Roundify(Button, Theme.Layout("RadiusSmall"))
	local ButtonLayout = Utilities.AddListLayout(Button, Enum.FillDirection.Horizontal, 6, Enum.HorizontalAlignment.Left)
	ButtonLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	ButtonLayout.Padding = UDim.new(0, 8)
	local ButtonPadding = Utilities.AddPadding(Button, 8)

	if Tab.Icon then
		local IconFrame = Icons.Create(Tab.Icon, Theme.Color("TextMuted"), 16)
		IconFrame.Parent = Button
	end

	local Label = Utilities.Create("TextLabel", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(0, 0, 1, 0),
		AutomaticSize = Enum.AutomaticSize.X,
		Font = Theme.Typography("FontSemibold"),
		TextSize = Theme.Typography("CaptionSize"),
		TextColor3 = Theme.Color("TextMuted"),
		Text = Tab.Title or Tab.Name or ("Tab " .. Index),
		Parent = Button,
	})

	self.Buttons[Index] = { Button = Button, Label = Label, Icon = IconFrame }

	local Click = Button.MouseButton1Click:Connect(function()
		self:Select(Index)
	end)
	self.Cleanup:AddConnection(Click)
	local Enter = Button.MouseEnter:Connect(function()
		if self.Active ~= Index then
			self.Animation:Animate(Button, "BackgroundColor3", Theme.Color("SurfaceActive"), { Duration = 0.1 })
		end
	end)
	local Leave = Button.MouseLeave:Connect(function()
		if self.Active ~= Index then
			self.Animation:Animate(Button, "BackgroundColor3", Theme.Color("SurfaceHover"), { Duration = 0.1 })
		end
	end)
	self.Cleanup:AddConnection(Enter)
	self.Cleanup:AddConnection(Leave)
end

function NestedTabs:Select(Index)
	if self.Active == Index then
		return
	end
	local Theme = self.Theme
	if self.Active and self.Buttons[self.Active] then
		local Old = self.Buttons[self.Active]
		self.Animation:Animate(Old.Button, "BackgroundColor3", Theme.Color("SurfaceHover"), { Duration = 0.15 })
		self.Animation:Animate(Old.Label, "TextColor3", Theme.Color("TextMuted"), { Duration = 0.15 })
	end
	self.Active = Index
	local Current = self.Buttons[Index]
	self.Animation:Animate(Current.Button, "BackgroundColor3", Theme.Color("Accent"), { Duration = 0.15 })
	self.Animation:Animate(Current.Label, "TextColor3", Theme.Color("TextInverse"), { Duration = 0.15 })

	for _, Child in ipairs(self.Content:GetChildren()) do
		if Child:IsA("Frame") or Child:IsA("TextButton") then
			Child:Destroy()
		end
	end
	local Tab = self.Tabs[Index]
	if Tab.Content then
		if type(Tab.Content) == "string" then
			local Text = Utilities.Create("TextLabel", {
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				Font = Theme.Typography("Font"),
				TextSize = Theme.Typography("BodySize"),
				TextColor3 = Theme.Color("TextMuted"),
				TextWrapped = true,
				Text = Tab.Content,
				Parent = self.Content,
			})
		elseif typeof(Tab.Content) == "Instance" then
			Tab.Content.Parent = self.Content
		elseif type(Tab.Content) == "function" then
			pcall(Tab.Content, self.Content)
		end
	end
	self.Changed:Fire(Index, Tab)
end

function NestedTabs:AddTab(Tab)
	table.insert(self.Tabs, Tab)
	self:_CreateTabButton(Tab, #self.Tabs)
end

return NestedTabs
