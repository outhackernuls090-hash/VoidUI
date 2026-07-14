local Utilities = require(script.Parent.Parent.Core.Utilities)
local Base = require(script.Parent.Base)
local Icons = require(script.Parent.Parent.Assets.Icons)

local CodeEditor = {}
CodeEditor.__index = setmetatable(CodeEditor, Base)

function CodeEditor.new(Application, Parent, Options)
	local self = setmetatable(Base.new(Application, Parent, Options), CodeEditor)
	self.Code = Options.Code or ""
	self.Language = Options.Language or "lua"
	self.LineNumbers = Options.LineNumbers ~= false
	self._Build()
	return self
end

function CodeEditor:_Build()
	local Theme = self.Theme
	local Container = self:_CreateContainer(0)
	Container.AutomaticSize = Enum.AutomaticSize.Y
	local Card = self:_CreateCard(0, {
		AutomaticSize = Enum.AutomaticSize.Y,
	})

	local Toolbar = Utilities.Create("Frame", {
		BackgroundColor3 = Theme.Color("Surface"),
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 30),
		Parent = Card,
	})
	local ToolbarCorner = Utilities.Roundify(Toolbar, Theme.Layout("RadiusSmall"))
	local ToolbarLayout = Utilities.AddListLayout(Toolbar, Enum.FillDirection.Horizontal, 8, Enum.HorizontalAlignment.Left)
	ToolbarLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	ToolbarLayout.Padding = UDim.new(0, 10)
	local ToolbarPadding = Utilities.AddPadding(Toolbar, 10)

	local Title = Utilities.Create("TextLabel", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, -120, 1, 0),
		Font = Theme.Typography("FontBold"),
		TextSize = Theme.Typography("CaptionSize"),
		TextColor3 = Theme.Color("TextMuted"),
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = self.Language:upper() .. " Editor",
		Parent = Toolbar,
	})

	local RunButton = Utilities.Create("TextButton", {
		BackgroundColor3 = Theme.Color("Accent"),
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(50, 22),
		AutoButtonColor = false,
		Font = Theme.Typography("FontSemibold"),
		TextSize = Theme.Typography("SmallSize"),
		TextColor3 = Theme.Color("TextInverse"),
		Text = "Run",
		Parent = Toolbar,
	})
	local RunCorner = Utilities.Roundify(RunButton, Theme.Layout("RadiusSmall"))
	local RunClick = RunButton.MouseButton1Click:Connect(function()
		self:Run()
	end)
	self.Cleanup:AddConnection(RunClick)

	local Body = Utilities.Create("Frame", {
		BackgroundColor3 = Color3.fromRGB(10, 11, 15),
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, (self.Options and self.Options.Height) or 200),
		Parent = Card,
	})
	local BodyCorner = Utilities.Roundify(Body, Theme.Layout("RadiusSmall"))
	local BodyLayout = Utilities.AddListLayout(Body, Enum.FillDirection.Horizontal, 0, Enum.HorizontalAlignment.Left)

	local Gutter = Utilities.Create("Frame", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(40, 1),
		Parent = Body,
	})
	local GutterLayout = Utilities.AddListLayout(Gutter, Enum.FillDirection.Vertical, 0, Enum.HorizontalAlignment.Right)
	GutterLayout.Padding = UDim.new(0, 6)
	local GutterPadding = Utilities.AddPadding(Gutter, 6)

	local Editor = Utilities.Create("TextBox", {
		BackgroundColor3 = Color3.fromRGB(10, 11, 15),
		BorderSizePixel = 0,
		Size = UDim2.new(1, -40, 1, 0),
		Font = Theme.Typography("FontMono"),
		TextSize = Theme.Typography("CaptionSize"),
		TextColor3 = Theme.Color("Text"),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		Text = self.Code,
		MultiLine = true,
		ClearTextOnFocus = false,
		Parent = Body,
	})
	local EditorPadding = Utilities.AddPadding(Editor, 8)

	self.Gutter = Gutter
	self.Editor = Editor

	local Changed = Editor:GetPropertyChangedSignal("Text"):Connect(function()
		self.Code = Editor.Text
		self:_UpdateGutter()
	end)
	self.Cleanup:AddConnection(Changed)

	self:_UpdateGutter()
end

function CodeEditor:_UpdateGutter()
	for _, Child in ipairs(self.Gutter:GetChildren()) do
		if Child:IsA("TextLabel") then
			Child:Destroy()
		end
	end
	local Lines = Utilities.Split(self.Code, "\n")
	for Index, _ in ipairs(Lines) do
		local Number = Utilities.Create("TextLabel", {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 18),
			Font = self.Theme.Typography("FontMono"),
			TextSize = self.Theme.Typography("SmallSize"),
			TextColor3 = self.Theme.Color("TextDim"),
			TextXAlignment = Enum.TextXAlignment.Right,
			Text = tostring(Index),
			Parent = self.Gutter,
		})
	end
end

function CodeEditor:Run()
	local Success, Result = pcall(function()
		return loadstring(self.Code)()
	end)
	if not Success then
		warn("[VoidUI] CodeEditor error:", Result)
	end
	return Result
end

function CodeEditor:SetCode(Code)
	self.Code = Code
	self.Editor.Text = Code
	self:_UpdateGutter()
end

function CodeEditor:GetCode()
	return self.Code
end

return CodeEditor
