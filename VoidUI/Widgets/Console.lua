local Utilities = require(script.Parent.Parent.Core.Utilities)
local Base = require(script.Parent.Base)
local Icons = require(script.Parent.Parent.Assets.Icons)

local Console = {}
Console.__index = setmetatable(Console, Base)

function Console.new(Application, Parent, Options)
	local self = setmetatable(Base.new(Application, Parent, Options), Console)
	self.MaxLines = Options.MaxLines or 200
	self.Lines = {}
	self.Filter = Options.Filter or {}
	self:_Build()
	return self
end

function Console:_Build()
	local Theme = self.Theme
	local Container = self:_CreateContainer(0)
	Container.AutomaticSize = Enum.AutomaticSize.Y
	local Card = self:_CreateCard(0, {
		AutomaticSize = Enum.AutomaticSize.Y,
	})

	local Toolbar = Utilities.Create("Frame", {
		BackgroundColor3 = Theme.Color("Surface"),
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 32),
		Parent = Card,
	})
	local ToolbarCorner = Utilities.Roundify(Toolbar, Theme.Layout("RadiusSmall"))
	local ToolbarLayout = Utilities.AddListLayout(Toolbar, Enum.FillDirection.Horizontal, 6, Enum.HorizontalAlignment.Left)
	ToolbarLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	ToolbarLayout.Padding = UDim.new(0, 8)
	local ToolbarPadding = Utilities.AddPadding(Toolbar, 8)

	local Title = Utilities.Create("TextLabel", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, -80, 1, 0),
		Font = Theme.Typography("FontBold"),
		TextSize = Theme.Typography("CaptionSize"),
		TextColor3 = Theme.Color("TextMuted"),
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = "Console",
		Parent = Toolbar,
	})

	local ClearButton = Utilities.Create("TextButton", {
		BackgroundColor3 = Theme.Color("SurfaceHover"),
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(60, 22),
		AutoButtonColor = false,
		Font = Theme.Typography("Font"),
		TextSize = Theme.Typography("SmallSize"),
		TextColor3 = Theme.Color("Text"),
		Text = "Clear",
		Parent = Toolbar,
	})
	local ClearCorner = Utilities.Roundify(ClearButton, Theme.Layout("RadiusSmall"))
	local ClearClick = ClearButton.MouseButton1Click:Connect(function()
		self:Clear()
		self.LogArea.CanvasPosition = Vector2.new(0, 0)
	end)
	self.Cleanup:AddConnection(ClearClick)

	local LogHeight = (self.Options and self.Options.Height) or 160
	local LogArea = Utilities.Create("ScrollingFrame", {
		BackgroundColor3 = Theme.Color("Background"),
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, LogHeight),
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticCanvasSize.Y,
		ScrollBarThickness = 6,
		ScrollBarImageColor3 = Theme.Color("Scrollbar"),
		Parent = Card,
	})
	local LogCorner = Utilities.Roundify(LogArea, Theme.Layout("RadiusSmall"))
	local LogPadding = Utilities.AddPadding(LogArea, 8)
	local LogLayout = Utilities.AddListLayout(LogArea, Enum.FillDirection.Vertical, 2, Enum.HorizontalAlignment.Left)

	self.LogArea = LogArea
end

function Console:_AddLine(Text, Level)
	local Theme = self.Theme
	local ColorMap = {
		Info = Theme.Color("Text"),
		Success = Theme.Color("Success"),
		Warning = Theme.Color("Warning"),
		Error = Theme.Color("Danger"),
		Debug = Theme.Color("TextDim"),
	}
	local Color = ColorMap[Level] or Theme.Color("Text")
	local Prefix = {
		Info = "[INFO]",
		Success = "[ OK ]",
		Warning = "[WARN]",
		Error = "[ERR ]",
		Debug = "[DBG ]",
	}
	local Line = Utilities.Create("TextLabel", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 18),
		Font = Theme.Typography("FontMono"),
		TextSize = Theme.Typography("SmallSize"),
		TextColor3 = Color,
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = (Prefix[Level] or "") .. " " .. Text,
		Parent = self.LogArea,
	})
	table.insert(self.Lines, { Text = Text, Level = Level, Instance = Line })
	if #self.Lines > self.MaxLines then
		local Old = table.remove(self.Lines, 1)
		if Old.Instance then
			Old.Instance:Destroy()
		end
	end
	self.LogArea.CanvasPosition = Vector2.new(0, self.LogArea.CanvasSize.Y.Offset)
end

function Console:Log(Text)
	self:_AddLine(tostring(Text), "Info")
end

function Console:Success(Text)
	self:_AddLine(tostring(Text), "Success")
end

function Console:Warn(Text)
	self:_AddLine(tostring(Text), "Warning")
end

function Console:Error(Text)
	self:_AddLine(tostring(Text), "Error")
end

function Console:Debug(Text)
	self:_AddLine(tostring(Text), "Debug")
end

function Console:Clear()
	for _, Line in ipairs(self.Lines) do
		if Line.Instance then
			Line.Instance:Destroy()
		end
	end
	self.Lines = {}
end

function Console:GetLines()
	return self.Lines
end

return Console
