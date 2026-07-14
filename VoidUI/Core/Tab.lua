local Forge = require(script.Parent.Forge)
local Icons = require(script.Parent.Parent.Assets.Icons)

local RealEnum = Enum
local Enum = setmetatable({}, {
	__index = function(_, Category)
		local Cat = RealEnum[Category]
		if Cat == nil then
			return setmetatable({}, { __index = function() return nil end })
		end
		return setmetatable({}, { __index = function(_, Member)
			return Cat[Member]
		end })
	end,
})

local Tab = {}
Tab.__index = Tab

function Tab.new(Window, Options)
	Options = Options or {}
	local self = setmetatable({}, Tab)
	self.Window = Window
	self.Title = Options.Title or "Tab"
	self.Icon = Options.Icon or "Circle"
	self.Selected = false
	self.Widgets = {}

	local Theme = Window.VoidUI.Themes[Window.VoidUI.CurrentTheme]

	local Button = Forge.Make("TextButton", {
		Name = "TabButton",
		Size = UDim2.new(1, -16, 0, 36),
		BackgroundTransparency = 1,
		Text = "",
		Parent = Window.Sidebar,
	}, {
		Forge.Make("UICorner", { CornerRadius = UDim.new(0, 8) }),
		Forge.Make("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			Padding = UDim.new(0, 10),
			VerticalAlignment = Enum.VerticalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
		Forge.Make("UIPadding", { PaddingLeft = UDim.new(0, 12) }),
		Icons.Create(self.Icon, Theme.TextDim, 18),
		Forge.Make("TextLabel", {
			Text = self.Title,
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextColor3 = Theme.TextDim,
			Size = UDim2.new(1, -40, 1, 0),
			FontFace = Font.fromEnum(Enum.Font.Gotham),
			Skin = { TextColor3 = "TextDim" },
		}),
	})
	Button.MouseButton1Click:Connect(function()
		Window:SelectTab(self)
	end)
	self.Button = Button

	local Section = Forge.Make("Frame", {
		Name = "TabContent",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Visible = false,
		Parent = Window.Content,
	}, {
		Forge.Make("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			Padding = UDim.new(0, 8),
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
	})
	self.Section = Section

	return self
end

function Tab:Select()
	self.Selected = true
	self.Section.Visible = true
	local Theme = self.Window.VoidUI.Themes[self.Window.VoidUI.CurrentTheme]
	Forge.Guard(function()
		self.Button.BackgroundTransparency = 0.85
		self.Button.BackgroundColor3 = Theme.SurfaceHover
	end)
end

function Tab:Deselect()
	self.Selected = false
	self.Section.Visible = false
	Forge.Guard(function()
		self.Button.BackgroundTransparency = 1
	end)
end

function Tab:_Row(Title, Desc)
	local Theme = self.Window.VoidUI.Themes[self.Window.VoidUI.CurrentTheme]
	local Row = Forge.Make("Frame", {
		Size = UDim2.new(1, 0, 0, Desc and 46 or 36),
		BackgroundTransparency = 1,
		Parent = self.Section,
	}, {
		Forge.Make("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			Padding = UDim.new(0, 2),
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
		Forge.Make("TextLabel", {
			Text = Title or "",
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextColor3 = Theme.Text,
			Size = UDim2.new(1, 0, 0, Desc and 18 or 36),
			FontFace = Font.fromEnum(Enum.Font.Gotham),
			Skin = { TextColor3 = "Text" },
		}),
	})
	if Desc then
		Forge.Make("TextLabel", {
			Text = Desc,
			TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextColor3 = Theme.TextDim,
			Size = UDim2.new(1, 0, 0, 16),
			FontFace = Font.fromEnum(Enum.Font.Gotham),
			Skin = { TextColor3 = "TextDim" },
			Parent = Row,
		})
	end
	return Row
end

function Tab:CreateSection(Options)
	Options = Options or {}
	local Theme = self.Window.VoidUI.Themes[self.Window.VoidUI.CurrentTheme]
	local Section = Forge.Make("Frame", {
		Size = UDim2.new(1, 0, 0, 30),
		BackgroundTransparency = 1,
		Parent = self.Section,
	}, {
		Forge.Make("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			Padding = UDim.new(0, 8),
			VerticalAlignment = Enum.VerticalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
		Forge.Make("TextLabel", {
			Text = Options.Title or "Section",
			TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextColor3 = Theme.Accent,
			Size = UDim2.new(0, 0, 1, 0),
			FontFace = Font.fromEnum(Enum.Font.Gotham),
			Skin = { TextColor3 = "Accent" },
		}),
		Forge.Make("Frame", {
			BackgroundColor3 = Theme.Border,
			Size = UDim2.new(1, -10, 0, 1),
			Skin = { BackgroundColor3 = "Border" },
		}),
	})
	return Section
end

function Tab:CreateDivider(Options)
	Options = Options or {}
	local Theme = self.Window.VoidUI.Themes[self.Window.VoidUI.CurrentTheme]
	local Div = Forge.Make("Frame", {
		Size = UDim2.new(1, 0, 0, 1),
		BackgroundColor3 = Theme.Border,
		Parent = self.Section,
		Skin = { BackgroundColor3 = "Border" },
	})
	return Div
end

function Tab:CreateLabel(Options)
	Options = Options or {}
	local Theme = self.Window.VoidUI.Themes[self.Window.VoidUI.CurrentTheme]
	local Label = Forge.Make("TextLabel", {
		Text = Options.Title or "",
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = Theme.Text,
		Size = UDim2.new(1, 0, 0, 24),
		FontFace = Font.fromEnum(Enum.Font.Gotham),
		Parent = self.Section,
		Skin = { TextColor3 = "Text" },
	})
	return Label
end

function Tab:CreateParagraph(Options)
	Options = Options or {}
	local Theme = self.Window.VoidUI.Themes[self.Window.VoidUI.CurrentTheme]
	local Para = Forge.Make("Frame", {
		Size = UDim2.new(1, 0, 0, 60),
		BackgroundColor3 = Theme.Surface,
		Parent = self.Section,
		Skin = { BackgroundColor3 = "Surface" },
	}, {
		Forge.Make("UICorner", { CornerRadius = UDim.new(0, 10) }),
		Forge.Make("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			Padding = UDim.new(0, 4),
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
		Forge.Make("UIPadding", { PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12), PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10) }),
		Forge.Make("TextLabel", {
			Text = Options.Title or "",
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextColor3 = Theme.Text,
			Size = UDim2.new(1, 0, 0, 18),
			FontFace = Font.fromEnum(Enum.Font.Gotham),
			Skin = { TextColor3 = "Text" },
		}),
		Forge.Make("TextLabel", {
			Text = Options.Content or "",
			TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextColor3 = Theme.TextDim,
			Size = UDim2.new(1, 0, 0, 28),
			TextWrapped = true,
			FontFace = Font.fromEnum(Enum.Font.Gotham),
			Skin = { TextColor3 = "TextDim" },
		}),
	})
	return Para
end

function Tab:CreateToggle(Options)
	Options = Options or {}
	local Theme = self.Window.VoidUI.Themes[self.Window.VoidUI.CurrentTheme]
	local Value = Options.Default or false
	local Callback = Options.Callback or function() end

	local Row = self:_Row(Options.Title, Options.Description)
	local Control = Forge.Make("Frame", {
		Size = UDim2.new(1, 0, 0, 24),
		BackgroundTransparency = 1,
		Parent = Row,
	}, {
		Forge.Make("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			Padding = UDim.new(0, 0),
			VerticalAlignment = Enum.VerticalAlignment.Center,
			HorizontalAlignment = Enum.HorizontalAlignment.Right,
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
	})

	local Knob = Forge.Make("Frame", {
		Name = "Knob",
		Size = UDim2.fromOffset(16, 16),
		BackgroundColor3 = Color3.fromHex("#FFFFFF"),
		Position = Value and UDim2.new(1, -19, 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
		AnchorPoint = Vector2.new(0, 0.5),
	})
	local Track = Forge.Make("TextButton", {
		Size = UDim2.fromOffset(40, 22),
		BackgroundColor3 = Value and Theme.Accent or Theme.SurfaceHover,
		Text = "",
		Parent = Control,
		Skin = { BackgroundColor3 = Value and "Accent" or "SurfaceHover" },
	}, {
		Forge.Make("UICorner", { CornerRadius = UDim.new(1, 0) }),
		Knob,
	})

	local function SetState(newVal)
		Value = newVal
		Forge.Guard(function()
			Track.BackgroundColor3 = Value and Theme.Accent or Theme.SurfaceHover
			Knob.Position = Value and UDim2.new(1, -19, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)
		end)
		Forge.Guard(Callback, Value)
	end

	Track.MouseButton1Click:Connect(function()
		SetState(not Value)
	end)

	local api = {
		Set = function(_, v) SetState(v) end,
		Get = function() return Value end,
		Instance = Row,
	}
	return api
end

function Tab:CreateSlider(Options)
	Options = Options or {}
	local Theme = self.Window.VoidUI.Themes[self.Window.VoidUI.CurrentTheme]
	local Min = Options.Min or 0
	local Max = Options.Max or 100
	local Value = Options.Default or Min
	local Callback = Options.Callback or function() end
	local Decimal = Options.Decimal or 0

	local Row = self:_Row(Options.Title, Options.Description)
	local Control = Forge.Make("Frame", {
		Size = UDim2.new(1, 0, 0, 26),
		BackgroundTransparency = 1,
		Parent = Row,
	}, {
		Forge.Make("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			Padding = UDim.new(0, 10),
			VerticalAlignment = Enum.VerticalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
	})

	local Fill = Forge.Make("Frame", {
		Name = "Fill",
		Size = UDim2.new(math.clamp((Value - Min) / (Max - Min), 0, 1), 0, 1, 0),
		BackgroundColor3 = Theme.Accent,
		Skin = { BackgroundColor3 = "Accent" },
	}, {
		Forge.Make("UICorner", { CornerRadius = UDim.new(1, 0) }),
	})
	local Bar = Forge.Make("Frame", {
		Size = UDim2.new(1, -60, 0, 6),
		BackgroundColor3 = Theme.SurfaceHover,
		Parent = Control,
		Skin = { BackgroundColor3 = "SurfaceHover" },
	}, {
		Forge.Make("UICorner", { CornerRadius = UDim.new(1, 0) }),
		Fill,
	})

	local ValueLabel = Forge.Make("TextLabel", {
		Text = tostring(Value),
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Right,
		TextColor3 = Theme.Text,
		Size = UDim2.new(0, 50, 1, 0),
		FontFace = Font.fromEnum(Enum.Font.Gotham),
		Skin = { TextColor3 = "Text" },
		Parent = Control,
	})

	local function SetValue(newVal)
		newVal = math.clamp(newVal, Min, Max)
		if Decimal > 0 then
			newVal = math.floor(newVal * (10 ^ Decimal) + 0.5) / (10 ^ Decimal)
		else
			newVal = math.floor(newVal + 0.5)
		end
		Value = newVal
		Forge.Guard(function()
			Fill.Size = UDim2.new(math.clamp((Value - Min) / (Max - Min), 0, 1), 0, 1, 0)
			ValueLabel.Text = tostring(Value)
		end)
		Forge.Guard(Callback, Value)
	end

	local dragging
	Bar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
		end
	end)
	Bar.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local absPos = Bar.AbsolutePosition
			local absSize = Bar.AbsoluteSize
			local ratio = math.clamp((input.Position.X - absPos.X) / absSize.X, 0, 1)
			SetValue(Min + ratio * (Max - Min))
		end
	end)
	Bar.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)

	local api = {
		Set = function(_, v) SetValue(v) end,
		Get = function() return Value end,
		Instance = Row,
	}
	return api
end

function Tab:CreateDropdown(Options)
	Options = Options or {}
	local Theme = self.Window.VoidUI.Themes[self.Window.VoidUI.CurrentTheme]
	local Items = Options.Options or {}
	local Multi = Options.Multi or false
	local Value
	if Multi then
		Value = (type(Options.Default) == "table") and Options.Default or {}
	else
		Value = Options.Default or Items[1] or nil
	end
	local Callback = Options.Callback or function() end

	local Row = self:_Row(Options.Title, Options.Description)
	local Control = Forge.Make("Frame", {
		Size = UDim2.new(1, 0, 0, 30),
		BackgroundColor3 = Theme.Surface,
		Parent = Row,
		Skin = { BackgroundColor3 = "Surface" },
	}, {
		Forge.Make("UICorner", { CornerRadius = UDim.new(0, 8) }),
		Forge.Make("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			Padding = UDim.new(0, 8),
			VerticalAlignment = Enum.VerticalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
		Forge.Make("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10) }),
		Forge.Make("TextLabel", {
			Name = "Current",
			Text = Multi and (#Value > 0 and table.concat(Value, ", ") or "None") or tostring(Value or "None"),
			TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextColor3 = Theme.Text,
			Size = UDim2.new(1, -24, 1, 0),
			FontFace = Font.fromEnum(Enum.Font.Gotham),
			Skin = { TextColor3 = "Text" },
		}),
		Icons.Create("ChevronDown", Theme.TextDim, 16),
	})

	local function SetValue(newVal)
		if Multi then
			Value = (type(newVal) == "table") and newVal or { newVal }
		else
			Value = newVal
		end
		Forge.Guard(function()
			Control.Current.Text = Multi and (#Value > 0 and table.concat(Value, ", ") or "None") or tostring(Value or "None")
		end)
		Forge.Guard(Callback, Value)
	end

	Control.MouseButton1Click:Connect(function()
		if Multi then
			local first = Items[1]
			if table.find(Value, first) then
				table.remove(Value, table.find(Value, first))
			else
				table.insert(Value, first)
			end
			SetValue(Value)
		else
			local idx = 1
			for i, v in ipairs(Items) do
				if v == Value then idx = i end
			end
			SetValue(Items[idx % #Items + 1])
		end
	end)

	local api = {
		Set = function(_, v) SetValue(v) end,
		Get = function() return Value end,
		Instance = Row,
	}
	return api
end

function Tab:CreateColorPicker(Options)
	Options = Options or {}
	local Theme = self.Window.VoidUI.Themes[self.Window.VoidUI.CurrentTheme]
	local Value = Options.Default or Color3.fromHex("#FFFFFF")
	local Callback = Options.Callback or function() end

	local Row = self:_Row(Options.Title, Options.Description)
	local Swatch = Forge.Make("TextButton", {
		Size = UDim2.fromOffset(28, 28),
		BackgroundColor3 = Value,
		Text = "",
		Parent = Row,
	}, {
		Forge.Make("UICorner", { CornerRadius = UDim.new(0, 6) }),
	})
	Swatch.MouseButton1Click:Connect(function()
		local palette = { Color3.fromHex("#FF5C7A"), Color3.fromHex("#5B8DEF"), Color3.fromHex("#34D399"), Color3.fromHex("#B57CFF"), Color3.fromHex("#FFD166") }
		local next = palette[(table.find(palette, Value) or 0) % #palette + 1]
		Value = next
		Forge.Guard(function() Swatch.BackgroundColor3 = Value end)
		Forge.Guard(Callback, Value)
	end)

	local api = {
		Set = function(_, v) Value = v; Forge.Guard(function() Swatch.BackgroundColor3 = v end) end,
		Get = function() return Value end,
		Instance = Row,
	}
	return api
end

function Tab:CreateKeybind(Options)
	Options = Options or {}
	local Theme = self.Window.VoidUI.Themes[self.Window.VoidUI.CurrentTheme]
	local Value = Options.Default or Enum.KeyCode.RightShift
	local Callback = Options.Callback or function() end

	local Row = self:_Row(Options.Title, Options.Description)
	local Button = Forge.Make("TextButton", {
		Size = UDim2.fromOffset(120, 28),
		BackgroundColor3 = Theme.Surface,
		Text = tostring(Value),
		TextSize = 13,
		TextColor3 = Theme.Text,
		Parent = Row,
		FontFace = Font.fromEnum(Enum.Font.Gotham),
		Skin = { BackgroundColor3 = "Surface", TextColor3 = "Text" },
	}, {
		Forge.Make("UICorner", { CornerRadius = UDim.new(0, 6) }),
	})
	Button.MouseButton1Click:Connect(function()
		Button.Text = "Press a key..."
		local conn
		conn = game:GetService("UserInputService").InputBegan:Connect(function(input, gp)
			if gp then return end
			if input.UserInputType == Enum.UserInputType.Keyboard then
				Value = input.KeyCode
				Forge.Guard(function() Button.Text = tostring(Value) end)
				Forge.Guard(Callback, Value)
				conn:Disconnect()
			end
		end)
	end)

	local api = {
		Set = function(_, v) Value = v; Forge.Guard(function() Button.Text = tostring(v) end) end,
		Get = function() return Value end,
		Instance = Row,
	}
	return api
end

function Tab:CreateTextbox(Options)
	Options = Options or {}
	local Theme = self.Window.VoidUI.Themes[self.Window.VoidUI.CurrentTheme]
	local Value = Options.Default or ""
	local Callback = Options.Callback or function() end

	local Row = self:_Row(Options.Title, Options.Description)
	local Box = Forge.Make("TextBox", {
		Size = UDim2.new(1, 0, 0, 30),
		BackgroundColor3 = Theme.Surface,
		Text = Value,
		PlaceholderText = Options.Placeholder or "",
		TextSize = 13,
		TextColor3 = Theme.Text,
		ClearTextOnFocus = false,
		Parent = Row,
		FontFace = Font.fromEnum(Enum.Font.Gotham),
		Skin = { BackgroundColor3 = "Surface", TextColor3 = "Text" },
	}, {
		Forge.Make("UICorner", { CornerRadius = UDim.new(0, 8) }),
		Forge.Make("UIPadding", { PaddingLeft = UDim.new(0, 10) }),
	})
	Box.FocusLost:Connect(function(enter)
		Value = Box.Text
		Forge.Guard(Callback, Value, enter)
	end)

	local api = {
		Set = function(_, v) Value = v; Forge.Guard(function() Box.Text = v end) end,
		Get = function() return Value end,
		Instance = Row,
	}
	return api
end

function Tab:CreateButton(Options)
	Options = Options or {}
	local Theme = self.Window.VoidUI.Themes[self.Window.VoidUI.CurrentTheme]
	local Callback = Options.Callback or function() end

	local Button = Forge.Make("TextButton", {
		Size = UDim2.new(1, 0, 0, 34),
		BackgroundColor3 = Theme.Accent,
		Text = Options.Title or "Button",
		TextSize = 14,
		TextColor3 = Color3.fromHex("#0E1116"),
		Parent = self.Section,
		FontFace = Font.fromEnum(Enum.Font.Gotham),
		Skin = { BackgroundColor3 = "Accent" },
	}, {
		Forge.Make("UICorner", { CornerRadius = UDim.new(0, 8) }),
	})
	Button.MouseButton1Click:Connect(function()
		Forge.Guard(Callback)
	end)

	local api = { Instance = Button }
	return api
end

return Tab
