local Utilities = require(script.Parent.Parent.Core.Utilities)
local Base = require(script.Parent.Base)
local Icons = require(script.Parent.Parent.Assets.Icons)

local CommandPalette = {}
CommandPalette.__index = setmetatable(CommandPalette, Base)

function CommandPalette.new(Application, Options)
	local self = setmetatable(Base.new(Application, Application.Renderer:GetLayer("Overlays"), Options), CommandPalette)
	self.Commands = Options and Options.Commands or {}
	self.Open = false
	self:_Build()
	return self
end

function CommandPalette:_Build()
	local Theme = self.Theme
	local Backdrop = Utilities.Create("Frame", {
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundTransparency = 0.6,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 1, 0),
		Visible = false,
		ZIndex = 200,
		Parent = self.Parent,
	})

	local Panel = Utilities.Create("Frame", {
		BackgroundColor3 = Theme.Color("CardElevated"),
		BorderSizePixel = 0,
		Size = UDim2.new(0, 520, 0, 0),
		Position = UDim2.fromScale(0.5, 0.3),
		AnchorPoint = Vector2.new(0.5, 0),
		ZIndex = 201,
		ClipsDescendants = true,
		Parent = Backdrop,
	})
	local PanelCorner = Utilities.Roundify(Panel, Theme.Layout("RadiusLarge"))
	local PanelStroke = Utilities.AddStroke(Panel, Theme.Color("Border"), 1)
	local PanelGradient = Utilities.AddGradient(Panel, Theme.Gradient("Surface"), 90)
	PanelGradient.Transparency = NumberSequence.new(0.5)

	local SearchBox = Utilities.Create("TextBox", {
		BackgroundColor3 = Theme.Color("Background"),
		BorderSizePixel = 0,
		Size = UDim2.new(1, -24, 0, 40),
		Position = UDim2.new(0, 12, 0, 12),
		Font = Theme.Typography("Font"),
		TextSize = Theme.Typography("BodySize"),
		TextColor3 = Theme.Color("Text"),
		PlaceholderColor3 = Theme.Color("Placeholder"),
		PlaceholderText = "Search commands...",
		TextXAlignment = Enum.TextXAlignment.Left,
		ClearTextOnFocus = false,
		ZIndex = 202,
		Parent = Panel,
	})
	local SearchCorner = Utilities.Roundify(SearchBox, Theme.Layout("RadiusSmall"))
	local SearchStroke = Utilities.AddStroke(SearchBox, Theme.Color("Border"), 1)
	local SearchIcon = Icons.Create("Search", Theme.Color("TextDim"), 16)
	SearchIcon.Position = UDim2.new(0, 10, 0.5, 0)
	SearchIcon.AnchorPoint = Vector2.new(0, 0.5)
	SearchIcon.ZIndex = 203
	SearchIcon.Parent = SearchBox
	SearchBox.TextPadding = UDim.new(0, 28)

	local Results = Utilities.Create("ScrollingFrame", {
		BackgroundColor3 = Theme.Color("Card"),
		BorderSizePixel = 0,
		Size = UDim2.new(1, -24, 1, -64),
		Position = UDim2.new(0, 12, 0, 60),
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticCanvasSize.Y,
		ScrollBarThickness = 4,
		ScrollBarImageColor3 = Theme.Color("Scrollbar"),
		ZIndex = 202,
		Parent = Panel,
	})
	local ResultsCorner = Utilities.Roundify(Results, Theme.Layout("RadiusSmall"))
	local ResultsLayout = Utilities.AddListLayout(Results, Enum.FillDirection.Vertical, 4, Enum.HorizontalAlignment.Center)
	ResultsLayout.Padding = UDim.new(0, 4)
	local ResultsPadding = Utilities.AddPadding(Results, 6)

	self.Backdrop = Backdrop
	self.Panel = Panel
	self.SearchBox = SearchBox
	self.Results = Results

	local Changed = SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
		self:_Filter(SearchBox.Text)
	end)
	self.Cleanup:AddConnection(Changed)

	local BackdropClick = Backdrop.InputBegan:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 and Input.Position.Y < Panel.AbsolutePosition.Y then
			self:Close()
		end
	end)
	self.Cleanup:AddConnection(BackdropClick)

	local Focus = SearchBox.FocusLost:Connect(function(Enter, _, _)
		if Enter then
			self:_ExecuteFirst()
		end
	end)
	self.Cleanup:AddConnection(Focus)

	self:_Filter("")
end

function CommandPalette:Register(Name, Description, Callback, Icon)
	table.insert(self.Commands, {
		Name = Name,
		Description = Description or "",
		Callback = Callback,
		Icon = Icon,
	})
end

function CommandPalette:_Filter(Query)
	local Theme = self.Theme
	Query = string.lower(Query)
	for _, Child in ipairs(self.Results:GetChildren()) do
		if Child:IsA("TextButton") then
			Child:Destroy()
		end
	end
	local Count = 0
	for _, Command in ipairs(self.Commands) do
		if Query == "" or string.find(string.lower(Command.Name), Query, 1, true) then
			local Item = Utilities.Create("TextButton", {
				BackgroundColor3 = Theme.Color("Surface"),
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 0, 40),
				AutoButtonColor = false,
				Text = "",
				ZIndex = 203,
				Parent = self.Results,
			})
			local ItemCorner = Utilities.Roundify(Item, Theme.Layout("RadiusSmall"))
			local ItemLayout = Utilities.AddListLayout(Item, Enum.FillDirection.Horizontal, 10, Enum.HorizontalAlignment.Left)
			ItemLayout.VerticalAlignment = Enum.VerticalAlignment.Center
			ItemLayout.Padding = UDim.new(0, 10)

			if Command.Icon then
				local IconFrame = Icons.Create(Command.Icon, Theme.Color("Accent"), 18)
				IconFrame.ZIndex = 204
				IconFrame.Parent = Item
			end
			local TextBlock = Utilities.Create("Frame", {
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Size = UDim2.new(1, -40, 1, 0),
				ZIndex = 204,
				Parent = Item,
			})
			local TextLayout = Utilities.AddListLayout(TextBlock, Enum.FillDirection.Vertical, 0)
			local NameLabel = Utilities.Create("TextLabel", {
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 0, 18),
				Font = Theme.Typography("FontSemibold"),
				TextSize = Theme.Typography("BodySize"),
				TextColor3 = Theme.Color("Text"),
				TextXAlignment = Enum.TextXAlignment.Left,
				Text = Command.Name,
				ZIndex = 205,
				Parent = TextBlock,
			})
			local DescLabel = Utilities.Create("TextLabel", {
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 0, 14),
				Font = Theme.Typography("Font"),
				TextSize = Theme.Typography("SmallSize"),
				TextColor3 = Theme.Color("TextDim"),
				TextXAlignment = Enum.TextXAlignment.Left,
				Text = Command.Description,
				ZIndex = 205,
				Parent = TextBlock,
			})

			local Enter = Item.MouseEnter:Connect(function()
				self.Animation:Animate(Item, "BackgroundColor3", Theme.Color("SurfaceHover"), { Duration = 0.1 })
			end)
			local Leave = Item.MouseLeave:Connect(function()
				self.Animation:Animate(Item, "BackgroundColor3", Theme.Color("Surface"), { Duration = 0.1 })
			end)
			local Click = Item.MouseButton1Click:Connect(function()
				self:_Execute(Command)
			end)
			self.Cleanup:AddConnection(Enter)
			self.Cleanup:AddConnection(Leave)
			self.Cleanup:AddConnection(Click)
			Count = Count + 1
		end
	end
	self._Filtered = Count
end

function CommandPalette:_ExecuteFirst()
	if #self.Results:GetChildren() > 0 then
		local First = self.Results:GetChildren()[1]
		if First then
			First.MouseButton1Click:Fire()
		end
	end
end

function CommandPalette:_Execute(Command)
	self:Close()
	Utilities.SafeCall(Command.Callback)
end

function CommandPalette:Open()
	self.Open = true
	self.Backdrop.Visible = true
	self.Animation:Tween({
		Duration = 0.25,
		Easing = "BackOut",
		OnUpdate = function(_, _, Progress)
			self.Panel.Size = UDim2.new(0, 520, 0, 360 * Progress)
		end,
	})
	self.SearchBox:CaptureFocus()
end

function CommandPalette:Close()
	self.Open = false
	self.Animation:Tween({
		Duration = 0.2,
		Easing = "QuadIn",
		OnUpdate = function(_, _, Progress)
			self.Panel.Size = UDim2.new(0, 520, 0, 360 * (1 - Progress))
		end,
		OnComplete = function()
			self.Backdrop.Visible = false
		end,
	})
end

function CommandPalette:Toggle()
	if self.Open then
		self:Close()
	else
		self:Open()
	end
end

return CommandPalette
