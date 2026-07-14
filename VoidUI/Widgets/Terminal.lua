local Utilities = require(script.Parent.Parent.Core.Utilities)
local Base = require(script.Parent.Base)
local Icons = require(script.Parent.Parent.Assets.Icons)

local Terminal = {}
Terminal.__index = setmetatable(Terminal, Base)

function Terminal.new(Application, Parent, Options)
	local self = setmetatable(Base.new(Application, Parent, Options), Terminal)
	self.Prompt = Options.Prompt or "void@ui:~$"
	self.History = {}
	self.Commands = Options.Commands or {}
	self._Build()
	return self
end

function Terminal:_Build()
	local Theme = self.Theme
	local Container = self:_CreateContainer(0)
	Container.AutomaticSize = Enum.AutomaticSize.Y
	local Card = self:_CreateCard(0, {
		AutomaticSize = Enum.AutomaticSize.Y,
	})

	local TitleBar = Utilities.Create("Frame", {
		BackgroundColor3 = Theme.Color("Surface"),
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 30),
		Parent = Card,
	})
	local TitleCorner = Utilities.Roundify(TitleBar, Theme.Layout("RadiusSmall"))
	local TitleLayout = Utilities.AddListLayout(TitleBar, Enum.FillDirection.Horizontal, 8, Enum.HorizontalAlignment.Left)
	TitleLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	TitleLayout.Padding = UDim.new(0, 10)
	local TitlePadding = Utilities.AddPadding(TitleBar, 10)

	local Dots = Utilities.Create("Frame", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(50, 12),
		Parent = TitleBar,
	})
	local DotLayout = Utilities.AddListLayout(Dots, Enum.FillDirection.Horizontal, 6, Enum.HorizontalAlignment.Left)
	for _, Color in ipairs({ Theme.Color("Danger"), Theme.Color("Warning"), Theme.Color("Success") }) do
		local Dot = Utilities.Create("Frame", {
			BackgroundColor3 = Color,
			BorderSizePixel = 0,
			Size = UDim2.fromOffset(10, 10),
			Parent = Dots,
		})
		local DotCorner = Utilities.Roundify(Dot, 999)
	end

	local Title = Utilities.Create("TextLabel", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, -60, 1, 0),
		Font = Theme.Typography("FontBold"),
		TextSize = Theme.Typography("CaptionSize"),
		TextColor3 = Theme.Color("TextMuted"),
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = "Terminal",
		Parent = TitleBar,
	})

	local Output = Utilities.Create("ScrollingFrame", {
		BackgroundColor3 = Color3.fromRGB(8, 9, 12),
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, (self.Options and self.Options.Height) or 160),
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticCanvasSize.Y,
		ScrollBarThickness = 6,
		ScrollBarImageColor3 = Theme.Color("Scrollbar"),
		Parent = Card,
	})
	local OutputCorner = Utilities.Roundify(Output, Theme.Layout("RadiusSmall"))
	local OutputPadding = Utilities.AddPadding(Output, 10)
	local OutputLayout = Utilities.AddListLayout(Output, Enum.FillDirection.Vertical, 2, Enum.HorizontalAlignment.Left)

	local InputRow = Utilities.Create("Frame", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 28),
		Parent = Card,
	})
	local InputLayout = Utilities.AddListLayout(InputRow, Enum.FillDirection.Horizontal, 6, Enum.HorizontalAlignment.Left)
	InputLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	InputLayout.Padding = UDim.new(0, 10)

	local PromptLabel = Utilities.Create("TextLabel", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(0, 0, 1, 0),
		AutomaticSize = Enum.AutomaticSize.X,
		Font = Theme.Typography("FontMono"),
		TextSize = Theme.Typography("SmallSize"),
		TextColor3 = Theme.Color("Success"),
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = self.Prompt,
		Parent = InputRow,
	})

	local Input = Utilities.Create("TextBox", {
		BackgroundColor3 = Color3.fromRGB(8, 9, 12),
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 1, 0),
		Font = Theme.Typography("FontMono"),
		TextSize = Theme.Typography("SmallSize"),
		TextColor3 = Theme.Color("Text"),
		PlaceholderColor3 = Theme.Color("Placeholder"),
		PlaceholderText = "Type a command...",
		TextXAlignment = Enum.TextXAlignment.Left,
		ClearTextOnFocus = false,
		Parent = InputRow,
	})
	local InputCorner = Utilities.Roundify(Input, Theme.Layout("RadiusSmall"))

	self.Output = Output
	self.Input = Input

	local Focus = Input.FocusLost:Connect(function(EnterPressed)
		if EnterPressed then
			local Command = Input.Text
			if Command ~= "" then
				self:Run(Command)
				Input.Text = ""
			end
		end
	end)
	self.Cleanup:AddConnection(Focus)
end

function Terminal:_Print(Text, Color)
	local Theme = self.Theme
	local Line = Utilities.Create("TextLabel", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 18),
		Font = Theme.Typography("FontMono"),
		TextSize = Theme.Typography("SmallSize"),
		TextColor3 = Color or Theme.Color("Text"),
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = Text,
		Parent = self.Output,
	})
	self.Output.CanvasPosition = Vector2.new(0, self.Output.CanvasSize.Y.Offset)
end

function Terminal:Run(Command)
	self:_Print(self.Prompt .. " " .. Command, self.Theme.Color("Success"))
	table.insert(self.History, Command)
	local Parts = Utilities.Split(Command, " ")
	local Name = Parts[1]
	local Handler = self.Commands[Name]
	if Handler then
		local Result = Utilities.SafeCall(Handler, table.unpack(Parts, 2))
		if type(Result) == "string" then
			self:_Print(Result)
		end
	else
		self:_Print("command not found: " .. Name, self.Theme.Color("Danger"))
	end
end

function Terminal:RegisterCommand(Name, Handler)
	self.Commands[Name] = Handler
end

function Terminal:Clear()
	for _, Child in ipairs(self.Output:GetChildren()) do
		if Child:IsA("TextLabel") then
			Child:Destroy()
		end
	end
end

function Terminal:GetHistory()
	return self.History
end

return Terminal
