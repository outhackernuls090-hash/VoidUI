local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local TextService = game:GetService("TextService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local Library = {}
local Windows = {}

local Theme = {
    Font = Enum.Font.Gotham,
    FontBold = Enum.Font.GothamBold,
    FontMedium = Enum.Font.GothamMedium,
    
    Background = Color3.fromRGB(20, 20, 24),
    BackgroundTransparent = Color3.fromRGB(20, 20, 24),
    Topbar = Color3.fromRGB(26, 26, 32),
    Sidebar = Color3.fromRGB(22, 22, 28),
    TabActive = Color3.fromRGB(38, 38, 48),
    TabHover = Color3.fromRGB(32, 32, 40),
    Element = Color3.fromRGB(36, 36, 44),
    ElementHover = Color3.fromRGB(46, 46, 56),
    ElementActive = Color3.fromRGB(52, 52, 64),
    Stroke = Color3.fromRGB(55, 55, 68),
    StrokeHover = Color3.fromRGB(80, 80, 100),
    
    Accent = Color3.fromRGB(92, 168, 255),
    AccentHover = Color3.fromRGB(120, 185, 255),
    AccentGlow = Color3.fromRGB(92, 168, 255),
    
    Text = Color3.fromRGB(245, 245, 250),
    TextDim = Color3.fromRGB(175, 175, 190),
    TextDark = Color3.fromRGB(115, 115, 130),
    
    Success = Color3.fromRGB(75, 220, 120),
    Error = Color3.fromRGB(255, 85, 85),
    Warning = Color3.fromRGB(255, 185, 70),
    Info = Color3.fromRGB(92, 168, 255),
    
    Shadow = Color3.fromRGB(0, 0, 0),
    Notification = Color3.fromRGB(30, 30, 38)
}

local function Create(class, props)
    local obj = Instance.new(class)
    for k, v in pairs(props) do
        obj[k] = v
    end
    return obj
end

local function Tween(obj, props, duration, style, dir)
    style = style or Enum.EasingStyle.Quint
    dir = dir or Enum.EasingDirection.Out
    local tween = TweenService:Create(obj, TweenInfo.new(duration or 0.3, style, dir), props)
    tween:Play()
    return tween
end

local function Spring(obj, props, duration)
    return Tween(obj, props, duration or 0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
end

local function Elastic(obj, props, duration)
    return Tween(obj, props, duration or 0.6, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out)
end

local function ProtectGui(obj)
    if syn and syn.protect_gui then
        syn.protect_gui(obj)
        obj.Parent = game:GetService("CoreGui")
    elseif gethui then
        obj.Parent = gethui()
    else
        obj.Parent = game:GetService("CoreGui")
    end
end

local function Ripple(parent, x, y)
    local ripple = Create("Frame", {
        Parent = parent,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 0.85,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(x - 4, y - 4),
        Size = UDim2.fromOffset(8, 8),
        ZIndex = 10
    })
    Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = ripple})
    Tween(ripple, {
        Size = UDim2.fromOffset(120, 120),
        Position = UDim2.fromOffset(x - 60, y - 60),
        BackgroundTransparency = 1
    }, 0.6, Enum.EasingStyle.Quad)
    task.delay(0.6, function() if ripple then ripple:Destroy() end end)
end

local function MakeDraggable(header, frame)
    local dragging, dragInput, dragStart, startPos = false, nil, nil, nil
    local function update(input)
        local delta = input.Position - dragStart
        Tween(frame, {Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)}, 0.18, Enum.EasingStyle.Quad)
    end
    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    header.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
end

function Library:CreateWindow(config)
    config = config or {}
    local Title = config.Title or "Window"
    local SubTitle = config.SubTitle or ""
    local Size = config.Size or UDim2.fromOffset(640, 480)
    local TabWidth = config.TabWidth or 180
    local MinimizeKey = config.MinimizeKey

    local ScreenGui = Create("ScreenGui", {
        Name = HttpService:GenerateGUID(false),
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 999
    })
    ProtectGui(ScreenGui)

    local ShadowLayer = Create("ImageLabel", {
        Parent = ScreenGui,
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.new(1, 80, 1, 80),
        ZIndex = -3,
        Image = "rbxassetid://6015897843",
        ImageColor3 = Color3.fromRGB(0, 0, 0),
        ImageTransparency = 1,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(49, 49, 450, 450)
    })

    local MainFrame = Create("Frame", {
        Name = "Main",
        Parent = ScreenGui,
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,
        Size = UDim2.fromOffset(0, 0),
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        ClipsDescendants = true
    })
    Create("UICorner", {CornerRadius = UDim.new(0, 10), Parent = MainFrame})

    local MainStroke = Create("UIStroke", {
        Color = Theme.Stroke,
        Thickness = 1.2,
        Transparency = 0.4,
        Parent = MainFrame
    })

    Tween(ShadowLayer, {ImageTransparency = 0.55, Size = UDim2.new(1, 100, 1, 100)}, 0.8, Enum.EasingStyle.Quint)
    Spring(MainFrame, {Size = Size}, 0.7)

    local Topbar = Create("Frame", {
        Name = "Topbar",
        Parent = MainFrame,
        BackgroundColor3 = Theme.Topbar,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 50)
    })
    Create("UICorner", {CornerRadius = UDim.new(0, 10), Parent = Topbar})

    local TopbarLine = Create("Frame", {
        Parent = Topbar,
        BackgroundColor3 = Theme.Stroke,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 1, 0),
        BackgroundTransparency = 0.6
    })

    local TitleLabel = Create("TextLabel", {
        Name = "Title",
        Parent = Topbar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 18, 0, 0),
        Size = UDim2.new(0.5, 0, 1, 0),
        Font = Theme.FontBold,
        Text = Title,
        TextColor3 = Theme.Text,
        TextSize = 17,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        RichText = true
    })

    if SubTitle ~= "" then
        TitleLabel.Text = Title .. ' <font color="rgb(160,160,175)" face="Gotham" size="14"> ' .. SubTitle .. "</font>"
    end

    local MinimizeBtn = Create("ImageButton", {
        Parent = Topbar,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -72, 0, 13),
        Size = UDim2.fromOffset(24, 24),
        Image = "rbxassetid://10734950020",
        ImageColor3 = Theme.TextDim,
        AutoButtonColor = false
    })

    local CloseBtn = Create("ImageButton", {
        Parent = Topbar,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -40, 0, 13),
        Size = UDim2.fromOffset(24, 24),
        Image = "rbxassetid://10747384394",
        ImageColor3 = Theme.TextDim,
        AutoButtonColor = false
    })

    local Content = Create("Frame", {
        Name = "Content",
        Parent = MainFrame,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 50),
        Size = UDim2.new(1, 0, 1, -50)
    })

    local Sidebar = Create("Frame", {
        Name = "Sidebar",
        Parent = Content,
        BackgroundColor3 = Theme.Sidebar,
        BorderSizePixel = 0,
        Size = UDim2.new(0, TabWidth, 1, 0)
    })
    Create("UICorner", {CornerRadius = UDim.new(0, 0), Parent = Sidebar})

    local SidebarLine = Create("Frame", {
        Parent = Sidebar,
        BackgroundColor3 = Theme.Stroke,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 1, 1, 0),
        Position = UDim2.new(1, 0, 0, 0),
        BackgroundTransparency = 0.5
    })

    local TabContainer = Create("ScrollingFrame", {
        Parent = Sidebar,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 1, 0),
        ScrollBarThickness = 0,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y
    })
    Create("UIPadding", {
        Parent = TabContainer,
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10),
        PaddingTop = UDim.new(0, 10),
        PaddingBottom = UDim.new(0, 10)
    })
    Create("UIListLayout", {
        Parent = TabContainer,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 6)
    })

    local TabIndicator = Create("Frame", {
        Parent = Sidebar,
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 3, 0, 32),
        Position = UDim2.new(0, 10, 0, 10),
        Visible = false,
        ZIndex = 2
    })
    Create("UICorner", {CornerRadius = UDim.new(0, 2), Parent = TabIndicator})

    local TabContent = Create("Frame", {
        Name = "TabContent",
        Parent = Content,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0, TabWidth, 0, 0),
        Size = UDim2.new(1, -TabWidth, 1, 0)
    })

    local WindowObj = {
        ScreenGui = ScreenGui,
        MainFrame = MainFrame,
        Topbar = Topbar,
        TabContent = TabContent,
        TabContainer = TabContainer,
        TabIndicator = TabIndicator,
        Tabs = {},
        ActiveTab = nil,
        Minimized = false,
        TabCount = 0,
        Keybinds = {}
    }

    MakeDraggable(Topbar, MainFrame)

    local function ToggleMinimize()
        WindowObj.Minimized = not WindowObj.Minimized
        if WindowObj.Minimized then
            Tween(MainFrame, {Size = UDim2.new(0, Size.X.Offset, 0, 50)}, 0.35, Enum.EasingStyle.Quint)
            Content.Visible = false
            MinimizeBtn.Image = "rbxassetid://10734950020"
        else
            Tween(MainFrame, {Size = Size}, 0.35, Enum.EasingStyle.Quint)
            Content.Visible = true
            MinimizeBtn.Image = "rbxassetid://10734950020"
        end
    end

    CloseBtn.MouseEnter:Connect(function()
        Tween(CloseBtn, {ImageColor3 = Theme.Error}, 0.15)
    end)
    CloseBtn.MouseLeave:Connect(function()
        Tween(CloseBtn, {ImageColor3 = Theme.TextDim}, 0.15)
    end)
    CloseBtn.MouseButton1Click:Connect(function()
        Tween(MainFrame, {Size = UDim2.fromOffset(0, 0)}, 0.4, Enum.EasingStyle.Quint)
        Tween(ShadowLayer, {ImageTransparency = 1}, 0.4)
        task.delay(0.4, function() ScreenGui:Destroy() end)
    end)

    MinimizeBtn.MouseEnter:Connect(function()
        Tween(MinimizeBtn, {ImageColor3 = Theme.Text}, 0.15)
    end)
    MinimizeBtn.MouseLeave:Connect(function()
        Tween(MinimizeBtn, {ImageColor3 = Theme.TextDim}, 0.15)
    end)
    MinimizeBtn.MouseButton1Click:Connect(ToggleMinimize)

    if MinimizeKey then
        UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if not gameProcessed and input.KeyCode == MinimizeKey then
                ToggleMinimize()
            end
        end)
    end

    function WindowObj:AddTab(tabConfig)
        tabConfig = tabConfig or {}
        local TabName = tabConfig.Title or "Tab"
        local TabIcon = tabConfig.Icon

        self.TabCount = self.TabCount + 1

        local TabButton = Create("TextButton", {
            Name = TabName .. "Btn",
            Parent = self.TabContainer,
            BackgroundColor3 = Theme.Sidebar,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 38),
            Font = Theme.Font,
            Text = "",
            AutoButtonColor = false,
            LayoutOrder = self.TabCount
        })
        Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = TabButton})

        local IconLabel = nil
        if TabIcon then
            IconLabel = Create("ImageLabel", {
                Parent = TabButton,
                BackgroundTransparency = 1,
                Size = UDim2.fromOffset(18, 18),
                Position = UDim2.new(0, 10, 0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5),
                Image = TabIcon,
                ImageColor3 = Theme.TextDim
            })
        end

        local TabText = Create("TextLabel", {
            Parent = TabButton,
            BackgroundTransparency = 1,
            Position = IconLabel and UDim2.new(0, 34, 0, 0) or UDim2.new(0, 10, 0, 0),
            Size = IconLabel and UDim2.new(1, -44, 1, 0) or UDim2.new(1, -20, 1, 0),
            Font = Theme.FontMedium,
            Text = TabName,
            TextColor3 = Theme.TextDim,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Center
        })

        local TabFrame = Create("ScrollingFrame", {
            Name = TabName .. "Content",
            Parent = self.TabContent,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 1, 0),
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = Theme.Stroke,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Visible = false
        })
        Create("UIPadding", {
            Parent = TabFrame,
            PaddingLeft = UDim.new(0, 14),
            PaddingRight = UDim.new(0, 14),
            PaddingTop = UDim.new(0, 14),
            PaddingBottom = UDim.new(0, 14)
        })
        Create("UIListLayout", {
            Parent = TabFrame,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 8)
        })

        local TabObj = {
            Button = TabButton,
            Frame = TabFrame,
            Name = TabName,
            Elements = {}
        }

        table.insert(self.Tabs, TabObj)

        if not self.ActiveTab then
            self.ActiveTab = TabObj
            TabFrame.Visible = true
            TabButton.BackgroundColor3 = Theme.TabActive
            TabText.TextColor3 = Theme.Text
            if IconLabel then IconLabel.ImageColor3 = Theme.Accent end
            self.TabIndicator.Visible = true
            self.TabIndicator.Position = UDim2.new(0, 10, 0, TabButton.AbsolutePosition.Y - self.TabContainer.AbsolutePosition.Y + 3)
            self.TabIndicator.Size = UDim2.new(0, 3, 0, 32)
        end

        TabButton.MouseButton1Click:Connect(function()
            if self.ActiveTab == TabObj then return end
            if self.ActiveTab then
                self.ActiveTab.Frame.Visible = false
                Tween(self.ActiveTab.Button, {BackgroundColor3 = Theme.Sidebar}, 0.25)
                self.ActiveTab.Button:FindFirstChild("Title").TextColor3 = Theme.TextDim
                local icon = self.ActiveTab.Button:FindFirstChild("Icon")
                if icon then icon.ImageColor3 = Theme.TextDim end
            end

            self.ActiveTab = TabObj
            TabFrame.Visible = true
            Tween(TabButton, {BackgroundColor3 = Theme.TabActive}, 0.25)
            TabText.TextColor3 = Theme.Text
            if IconLabel then Tween(IconLabel, {ImageColor3 = Theme.Accent}, 0.25) end

            local targetY = TabButton.AbsolutePosition.Y - self.TabContainer.AbsolutePosition.Y + 3
            Tween(self.TabIndicator, {Position = UDim2.new(0, 10, 0, targetY)}, 0.3, Enum.EasingStyle.Quint)
        end)

        TabButton.MouseEnter:Connect(function()
            if self.ActiveTab ~= TabObj then
                Tween(TabButton, {BackgroundColor3 = Theme.TabHover}, 0.2)
            end
        end)
        TabButton.MouseLeave:Connect(function()
            if self.ActiveTab ~= TabObj then
                Tween(TabButton, {BackgroundColor3 = Theme.Sidebar}, 0.2)
            end
        end)

        function TabObj:AddSection(title)
            local SectionFrame = Create("Frame", {
                Parent = self.Frame,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 30),
                LayoutOrder = #self.Elements
            })
            table.insert(self.Elements, SectionFrame)

            local SectionText = Create("TextLabel", {
                Parent = SectionFrame,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Font = Theme.FontBold,
                Text = title,
                TextColor3 = Theme.Text,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Bottom
            })
            local SectionLine = Create("Frame", {
                Parent = SectionFrame,
                BackgroundColor3 = Theme.Stroke,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 1),
                Position = UDim2.new(0, 0, 1, -1)
            })
            return SectionFrame
        end

        function TabObj:AddButton(btnConfig)
            btnConfig = btnConfig or {}
            local Title = btnConfig.Title or "Button"
            local Description = btnConfig.Description
            local Callback = btnConfig.Callback or function() end

            local ButtonFrame = Create("Frame", {
                Parent = self.Frame,
                BackgroundColor3 = Theme.Element,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, Description and 68 or 42),
                LayoutOrder = #self.Elements
            })
            Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = ButtonFrame})
            local ButtonStroke = Create("UIStroke", {
                Color = Theme.Stroke,
                Thickness = 1,
                Transparency = 0.5,
                Parent = ButtonFrame
            })
            local Glow = Create("ImageLabel", {
                Parent = ButtonFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0.5, -60, 0.5, -60),
                Size = UDim2.fromOffset(120, 120),
                Image = "rbxassetid://5028857084",
                ImageColor3 = Theme.Accent,
                ImageTransparency = 1,
                ZIndex = 0
            })

            local TitleLabel = Create("TextLabel", {
                Parent = ButtonFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 14, 0, 0),
                Size = UDim2.new(1, -28, 0, 42),
                Font = Theme.FontMedium,
                Text = Title,
                TextColor3 = Theme.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Center
            })

            if Description then
                TitleLabel.Size = UDim2.new(1, -28, 0, 26)
                TitleLabel.Position = UDim2.new(0, 14, 0, 8)
                Create("TextLabel", {
                    Parent = ButtonFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 14, 0, 34),
                    Size = UDim2.new(1, -28, 0, 22),
                    Font = Theme.Font,
                    Text = Description,
                    TextColor3 = Theme.TextDim,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextYAlignment = Enum.TextYAlignment.Top
                })
                ButtonFrame.Size = UDim2.new(1, 0, 0, 64)
            end

            local ClickBtn = Create("TextButton", {
                Parent = ButtonFrame,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Text = "",
                ZIndex = 2
            })

            ClickBtn.MouseEnter:Connect(function()
                Tween(ButtonFrame, {BackgroundColor3 = Theme.ElementHover}, 0.2)
                Tween(ButtonStroke, {Color = Theme.StrokeHover, Transparency = 0.3}, 0.2)
                Tween(Glow, {ImageTransparency = 0.92}, 0.3)
            end)
            ClickBtn.MouseLeave:Connect(function()
                Tween(ButtonFrame, {BackgroundColor3 = Theme.Element}, 0.2)
                Tween(ButtonStroke, {Color = Theme.Stroke, Transparency = 0.5}, 0.2)
                Tween(Glow, {ImageTransparency = 1}, 0.3)
            end)
            ClickBtn.MouseButton1Down:Connect(function()
                Tween(ButtonFrame, {BackgroundColor3 = Theme.ElementActive}, 0.1)
                local x = ClickBtn.AbsolutePosition.X + ClickBtn.AbsoluteSize.X / 2 - ButtonFrame.AbsolutePosition.X
                local y = ClickBtn.AbsolutePosition.Y + ClickBtn.AbsoluteSize.Y / 2 - ButtonFrame.AbsolutePosition.Y
                Ripple(ButtonFrame, x, y)
            end)
            ClickBtn.MouseButton1Up:Connect(function()
                Tween(ButtonFrame, {BackgroundColor3 = Theme.ElementHover}, 0.15)
            end)
            ClickBtn.MouseButton1Click:Connect(Callback)

            return ButtonFrame
        end

        function TabObj:AddToggle(toggleConfig)
            toggleConfig = toggleConfig or {}
            local Title = toggleConfig.Title or "Toggle"
            local Default = toggleConfig.Default or false
            local Callback = toggleConfig.Callback or function() end

            local ToggleFrame = Create("Frame", {
                Parent = self.Frame,
                BackgroundColor3 = Theme.Element,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 42),
                LayoutOrder = #self.Elements
            })
            Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = ToggleFrame})
            local ToggleStroke = Create("UIStroke", {
                Color = Theme.Stroke,
                Thickness = 1,
                Transparency = 0.5,
                Parent = ToggleFrame
            })

            Create("TextLabel", {
                Parent = ToggleFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 14, 0, 0),
                Size = UDim2.new(1, -80, 1, 0),
                Font = Theme.FontMedium,
                Text = Title,
                TextColor3 = Theme.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Center
            })

            local ToggleOuter = Create("Frame", {
                Parent = ToggleFrame,
                BackgroundColor3 = Theme.Background,
                BorderSizePixel = 0,
                Position = UDim2.new(1, -56, 0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5),
                Size = UDim2.fromOffset(42, 22)
            })
            Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = ToggleOuter})

            local ToggleInner = Create("Frame", {
                Parent = ToggleOuter,
                BackgroundColor3 = Theme.TextDark,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 2, 0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5),
                Size = UDim2.fromOffset(18, 18)
            })
            Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = ToggleInner})

            local Glow = Create("ImageLabel", {
                Parent = ToggleOuter,
                BackgroundTransparency = 1,
                Position = UDim2.new(0.5, -25, 0.5, -25),
                Size = UDim2.fromOffset(50, 50),
                Image = "rbxassetid://5028857084",
                ImageColor3 = Theme.Accent,
                ImageTransparency = 1,
                ZIndex = 0
            })

            local ClickBtn = Create("TextButton", {
                Parent = ToggleFrame,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Text = ""
            })

            local Value = Default

            local function Update()
                if Value then
                    Tween(ToggleOuter, {BackgroundColor3 = Theme.Accent}, 0.25, Enum.EasingStyle.Quint)
                    Spring(ToggleInner, {Position = UDim2.new(1, -20, 0.5, 0), BackgroundColor3 = Theme.Text}, 0.35)
                    Tween(Glow, {ImageTransparency = 0.85}, 0.3)
                    Tween(ToggleStroke, {Color = Theme.Accent, Transparency = 0.3}, 0.25)
                else
                    Tween(ToggleOuter, {BackgroundColor3 = Theme.Background}, 0.25, Enum.EasingStyle.Quint)
                    Spring(ToggleInner, {Position = UDim2.new(0, 2, 0.5, 0), BackgroundColor3 = Theme.TextDark}, 0.35)
                    Tween(Glow, {ImageTransparency = 1}, 0.3)
                    Tween(ToggleStroke, {Color = Theme.Stroke, Transparency = 0.5}, 0.25)
                end
                Callback(Value)
            end

            if Default then
                ToggleOuter.BackgroundColor3 = Theme.Accent
                ToggleInner.Position = UDim2.new(1, -20, 0.5, 0)
                ToggleInner.BackgroundColor3 = Theme.Text
                ToggleStroke.Color = Theme.Accent
                ToggleStroke.Transparency = 0.3
                Callback(Default)
            end

            ClickBtn.MouseButton1Click:Connect(function()
                Value = not Value
                Update()
            end)

            return {
                Set = function(_, v) Value = v; Update() end,
                Get = function() return Value end
            }
        end

        function TabObj:AddSlider(sliderConfig)
            sliderConfig = sliderConfig or {}
            local Title = sliderConfig.Title or "Slider"
            local Min = sliderConfig.Min or 0
            local Max = sliderConfig.Max or 100
            local Default = sliderConfig.Default or Min
            local Rounding = sliderConfig.Rounding or 0
            local Suffix = sliderConfig.Suffix or ""
            local Callback = sliderConfig.Callback or function() end

            local SliderFrame = Create("Frame", {
                Parent = self.Frame,
                BackgroundColor3 = Theme.Element,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 60),
                LayoutOrder = #self.Elements
            })
            Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = SliderFrame})
            Create("UIStroke", {
                Color = Theme.Stroke,
                Thickness = 1,
                Transparency = 0.5,
                Parent = SliderFrame
            })

            Create("TextLabel", {
                Parent = SliderFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 14, 0, 8),
                Size = UDim2.new(1, -80, 0, 18),
                Font = Theme.FontMedium,
                Text = Title,
                TextColor3 = Theme.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left
            })

            local ValueLabel = Create("TextLabel", {
                Parent = SliderFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(1, -70, 0, 8),
                Size = UDim2.new(0, 56, 0, 18),
                Font = Theme.FontMedium,
                Text = tostring(Default) .. Suffix,
                TextColor3 = Theme.Accent,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Right
            })

            local Bar = Create("Frame", {
                Parent = SliderFrame,
                BackgroundColor3 = Theme.Background,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 14, 0, 38),
                Size = UDim2.new(1, -28, 0, 6)
            })
            Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = Bar})

            local Fill = Create("Frame", {
                Parent = Bar,
                BackgroundColor3 = Theme.Accent,
                BorderSizePixel = 0,
                Size = UDim2.new((Default - Min) / (Max - Min), 0, 1, 0)
            })
            Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = Fill})

            local Knob = Create("Frame", {
                Parent = Bar,
                BackgroundColor3 = Theme.Text,
                BorderSizePixel = 0,
                Position = UDim2.new((Default - Min) / (Max - Min), -7, 0.5, -7),
                Size = UDim2.fromOffset(14, 14),
                ZIndex = 2
            })
            Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = Knob})
            local KnobGlow = Create("ImageLabel", {
                Parent = Knob,
                BackgroundTransparency = 1,
                Position = UDim2.new(0.5, -20, 0.5, -20),
                Size = UDim2.fromOffset(40, 40),
                Image = "rbxassetid://5028857084",
                ImageColor3 = Theme.Accent,
                ImageTransparency = 1,
                ZIndex = 0
            })

            local Dragging = false

            local function Update(input)
                local pos = math.clamp((input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
                local val = Min + (Max - Min) * pos
                if Rounding > 0 then
                    val = math.floor(val * (10 ^ Rounding) + 0.5) / (10 ^ Rounding)
                else
                    val = math.floor(val + 0.5)
                end
                val = math.clamp(val, Min, Max)
                Fill.Size = UDim2.new((val - Min) / (Max - Min), 0, 1, 0)
                Knob.Position = UDim2.new((val - Min) / (Max - Min), -7, 0.5, -7)
                ValueLabel.Text = tostring(val) .. Suffix
                Callback(val)
                return val
            end

            Knob.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    Dragging = true
                    Tween(Knob, {Size = UDim2.fromOffset(18, 18), Position = UDim2.new(Knob.Position.X.Scale, -9, 0.5, -9)}, 0.15)
                    Tween(KnobGlow, {ImageTransparency = 0.85}, 0.2)
                end
            end)
            Bar.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    Dragging = true
                    Tween(Knob, {Size = UDim2.fromOffset(18, 18)}, 0.15)
                    Tween(KnobGlow, {ImageTransparency = 0.85}, 0.2)
                    Update(input)
                end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    Dragging = false
                    Tween(Knob, {Size = UDim2.fromOffset(14, 14)}, 0.15)
                    Tween(KnobGlow, {ImageTransparency = 1}, 0.2)
                end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if Dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    Update(input)
                end
            end)

            return SliderFrame
        end

        function TabObj:AddDropdown(dropdownConfig)
            dropdownConfig = dropdownConfig or {}
            local Title = dropdownConfig.Title or "Dropdown"
            local Values = dropdownConfig.Values or {}
            local Default = dropdownConfig.Default
            local Callback = dropdownConfig.Callback or function() end

            local DropdownFrame = Create("Frame", {
                Parent = self.Frame,
                BackgroundColor3 = Theme.Element,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 42),
                ClipsDescendants = false,
                LayoutOrder = #self.Elements
            })
            Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = DropdownFrame})
            local DropdownStroke = Create("UIStroke", {
                Color = Theme.Stroke,
                Thickness = 1,
                Transparency = 0.5,
                Parent = DropdownFrame
            })

            Create("TextLabel", {
                Parent = DropdownFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 14, 0, 0),
                Size = UDim2.new(1, -120, 1, 0),
                Font = Theme.FontMedium,
                Text = Title,
                TextColor3 = Theme.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Center
            })

            local SelectedLabel = Create("TextLabel", {
                Parent = DropdownFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 14, 0, 0),
                Size = UDim2.new(1, -50, 1, 0),
                Font = Theme.Font,
                Text = Default or "Select...",
                TextColor3 = Theme.TextDim,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Right,
                TextYAlignment = Enum.TextYAlignment.Center
            })

            local Arrow = Create("ImageLabel", {
                Parent = DropdownFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(1, -30, 0, 11),
                Size = UDim2.fromOffset(20, 20),
                Image = "rbxassetid://10709766959",
                ImageColor3 = Theme.TextDim
            })

            local DropdownBtn = Create("TextButton", {
                Parent = DropdownFrame,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 42),
                Text = ""
            })

            local OptionsFrame = Create("Frame", {
                Parent = DropdownFrame,
                BackgroundColor3 = Theme.Background,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 0, 0, 46),
                Size = UDim2.new(1, 0, 0, 0),
                ClipsDescendants = true,
                Visible = false,
                ZIndex = 5
            })
            Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = OptionsFrame})
            Create("UIStroke", {
                Color = Theme.Stroke,
                Thickness = 1,
                Parent = OptionsFrame
            })
            Create("UIPadding", {
                Parent = OptionsFrame,
                PaddingTop = UDim.new(0, 6),
                PaddingBottom = UDim.new(0, 6),
                PaddingLeft = UDim.new(0, 6),
                PaddingRight = UDim.new(0, 6)
            })
            local OptionsList = Create("UIListLayout", {
                Parent = OptionsFrame,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 4)
            })

            local Opened = false
            local Selected = Default

            local function Close()
                Opened = false
                Tween(Arrow, {Rotation = 0}, 0.2)
                Tween(OptionsFrame, {Size = UDim2.new(1, 0, 0, 0)}, 0.25, Enum.EasingStyle.Quint).Completed:Connect(function()
                    OptionsFrame.Visible = false
                end)
                Tween(DropdownStroke, {Color = Theme.Stroke}, 0.2)
            end

            for i, val in ipairs(Values) do
                local OptionBtn = Create("TextButton", {
                    Parent = OptionsFrame,
                    BackgroundColor3 = Theme.Element,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 32),
                    Font = Theme.Font,
                    Text = tostring(val),
                    TextColor3 = Theme.Text,
                    TextSize = 13,
                    AutoButtonColor = false,
                    LayoutOrder = i
                })
                Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = OptionBtn})

                OptionBtn.MouseEnter:Connect(function()
                    Tween(OptionBtn, {BackgroundColor3 = Theme.ElementHover}, 0.15)
                end)
                OptionBtn.MouseLeave:Connect(function()
                    Tween(OptionBtn, {BackgroundColor3 = Theme.Element}, 0.15)
                end)
                OptionBtn.MouseButton1Click:Connect(function()
                    Selected = val
                    SelectedLabel.Text = tostring(val)
                    Callback(val)
                    Close()
                end)
            end

            DropdownBtn.MouseButton1Click:Connect(function()
                Opened = not Opened
                if Opened then
                    OptionsFrame.Visible = true
                    local h = math.min(#Values * 36 + 12, 220)
                    Tween(OptionsFrame, {Size = UDim2.new(1, 0, 0, h)}, 0.25, Enum.EasingStyle.Quint)
                    Tween(Arrow, {Rotation = 180}, 0.2)
                    Tween(DropdownStroke, {Color = Theme.Accent, Transparency = 0.3}, 0.2)
                else
                    Close()
                end
            end)

            DropdownBtn.MouseEnter:Connect(function()
                if not Opened then
                    Tween(DropdownFrame, {BackgroundColor3 = Theme.ElementHover}, 0.2)
                end
            end)
            DropdownBtn.MouseLeave:Connect(function()
                if not Opened then
                    Tween(DropdownFrame, {BackgroundColor3 = Theme.Element}, 0.2)
                end
            end)

            return DropdownFrame
        end

        function TabObj:AddInput(inputConfig)
            inputConfig = inputConfig or {}
            local Title = inputConfig.Title or "Input"
            local Default = inputConfig.Default or ""
            local Placeholder = inputConfig.Placeholder or "Type..."
            local Callback = inputConfig.Callback or function() end

            local InputFrame = Create("Frame", {
                Parent = self.Frame,
                BackgroundColor3 = Theme.Element,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 76),
                LayoutOrder = #self.Elements
            })
            Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = InputFrame})
            local InputStroke = Create("UIStroke", {
                Color = Theme.Stroke,
                Thickness = 1,
                Transparency = 0.5,
                Parent = InputFrame
            })

            Create("TextLabel", {
                Parent = InputFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 14, 0, 8),
                Size = UDim2.new(1, -28, 0, 18),
                Font = Theme.FontMedium,
                Text = Title,
                TextColor3 = Theme.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left
            })

            local BoxFrame = Create("Frame", {
                Parent = InputFrame,
                BackgroundColor3 = Theme.Background,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 14, 0, 34),
                Size = UDim2.new(1, -28, 0, 30)
            })
            Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = BoxFrame})

            local TextBox = Create("TextBox", {
                Parent = BoxFrame,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -16, 1, 0),
                Position = UDim2.new(0, 8, 0, 0),
                Font = Theme.Font,
                Text = Default,
                PlaceholderText = Placeholder,
                TextColor3 = Theme.Text,
                PlaceholderColor3 = Theme.TextDark,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                ClearTextOnFocus = false
            })

            TextBox.Focused:Connect(function()
                Tween(BoxFrame, {BackgroundColor3 = Theme.Element}, 0.2)
                Tween(InputStroke, {Color = Theme.Accent, Transparency = 0.3}, 0.2)
            end)
            TextBox.FocusLost:Connect(function()
                Tween(BoxFrame, {BackgroundColor3 = Theme.Background}, 0.2)
                Tween(InputStroke, {Color = Theme.Stroke, Transparency = 0.5}, 0.2)
                Callback(TextBox.Text)
            end)

            return TextBox
        end

        function TabObj:AddKeybind(keybindConfig)
            keybindConfig = keybindConfig or {}
            local Title = keybindConfig.Title or "Keybind"
            local Default = keybindConfig.Default or "None"
            local Callback = keybindConfig.Callback or function() end

            local KeybindFrame = Create("Frame", {
                Parent = self.Frame,
                BackgroundColor3 = Theme.Element,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 42),
                LayoutOrder = #self.Elements
            })
            Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = KeybindFrame})
            Create("UIStroke", {
                Color = Theme.Stroke,
                Thickness = 1,
                Transparency = 0.5,
                Parent = KeybindFrame
            })

            Create("TextLabel", {
                Parent = KeybindFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 14, 0, 0),
                Size = UDim2.new(1, -110, 1, 0),
                Font = Theme.FontMedium,
                Text = Title,
                TextColor3 = Theme.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Center
            })

            local KeybindBtn = Create("TextButton", {
                Parent = KeybindFrame,
                BackgroundColor3 = Theme.Background,
                BorderSizePixel = 0,
                Position = UDim2.new(1, -100, 0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5),
                Size = UDim2.fromOffset(90, 28),
                Font = Theme.FontMedium,
                Text = Default,
                TextColor3 = Theme.TextDim,
                TextSize = 12,
                AutoButtonColor = false
            })
            Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = KeybindBtn})

            local Listening = false
            local CurrentKey = Default

            KeybindBtn.MouseButton1Click:Connect(function()
                if Listening then return end
                Listening = true
                KeybindBtn.Text = "..."
                Tween(KeybindBtn, {BackgroundColor3 = Theme.Accent, TextColor3 = Theme.Text}, 0.2)
            end)

            UserInputService.InputBegan:Connect(function(input, gameProcessed)
                if Listening and not gameProcessed then
                    if input.UserInputType == Enum.UserInputType.Keyboard then
                        CurrentKey = input.KeyCode.Name
                        KeybindBtn.Text = CurrentKey
                        Listening = false
                        Tween(KeybindBtn, {BackgroundColor3 = Theme.Background, TextColor3 = Theme.TextDim}, 0.2)
                        Callback(input.KeyCode)
                    end
                elseif not gameProcessed and not Listening then
                    if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode.Name == CurrentKey then
                        Callback(input.KeyCode)
                    end
                end
            end)

            return KeybindFrame
        end

        function TabObj:AddColorpicker(colorConfig)
            colorConfig = colorConfig or {}
            local Title = colorConfig.Title or "Colorpicker"
            local Default = colorConfig.Default or Color3.fromRGB(255, 255, 255)
            local Callback = colorConfig.Callback or function() end

            local ColorFrame = Create("Frame", {
                Parent = self.Frame,
                BackgroundColor3 = Theme.Element,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 42),
                ClipsDescendants = false,
                LayoutOrder = #self.Elements
            })
            Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = ColorFrame})
            Create("UIStroke", {
                Color = Theme.Stroke,
                Thickness = 1,
                Transparency = 0.5,
                Parent = ColorFrame
            })

            Create("TextLabel", {
                Parent = ColorFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 14, 0, 0),
                Size = UDim2.new(1, -60, 1, 0),
                Font = Theme.FontMedium,
                Text = Title,
                TextColor3 = Theme.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Center
            })

            local Preview = Create("TextButton", {
                Parent = ColorFrame,
                BackgroundColor3 = Default,
                BorderSizePixel = 0,
                Position = UDim2.new(1, -44, 0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5),
                Size = UDim2.fromOffset(28, 28),
                Text = "",
                AutoButtonColor = false
            })
            Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = Preview})
            Create("UIStroke", {Color = Theme.Stroke, Thickness = 2, Parent = Preview})

            local Picker = Create("Frame", {
                Parent = ColorFrame,
                BackgroundColor3 = Theme.Background,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 0, 0, 46),
                Size = UDim2.new(1, 0, 0, 0),
                ClipsDescendants = true,
                Visible = false,
                ZIndex = 5
            })
            Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = Picker})
            Create("UIStroke", {Color = Theme.Stroke, Thickness = 1, Parent = Picker})
            Create("UIPadding", {
                Parent = Picker,
                PaddingTop = UDim.new(0, 10),
                PaddingBottom = UDim.new(0, 10),
                PaddingLeft = UDim.new(0, 10),
                PaddingRight = UDim.new(0, 10)
            })
            Create("UIListLayout", {
                Parent = Picker,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 8)
            })

            local function CreateChannel(name, color, order, default)
                local Channel = Create("Frame", {
                    Parent = Picker,
                    BackgroundColor3 = Theme.Element,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 32),
                    LayoutOrder = order
                })
                Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = Channel})
                Create("TextLabel", {
                    Parent = Channel,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0, 24, 1, 0),
                    Position = UDim2.new(0, 10, 0, 0),
                    Font = Theme.FontBold,
                    Text = name,
                    TextColor3 = color,
                    TextSize = 12,
                    TextYAlignment = Enum.TextYAlignment.Center
                })
                local Box = Create("TextBox", {
                    Parent = Channel,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, -40, 1, 0),
                    Position = UDim2.new(0, 34, 0, 0),
                    Font = Theme.Font,
                    Text = tostring(default),
                    TextColor3 = Theme.Text,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Right
                })
                return Box
            end

            local RBox = CreateChannel("R", Theme.Error, 1, math.floor(Default.R * 255))
            local GBox = CreateChannel("G", Theme.Success, 2, math.floor(Default.G * 255))
            local BBox = CreateChannel("B", Theme.Accent, 3, math.floor(Default.B * 255))

            local CurrentColor = Default

            local function UpdateColor()
                local r = math.clamp(tonumber(RBox.Text) or 0, 0, 255)
                local g = math.clamp(tonumber(GBox.Text) or 0, 0, 255)
                local b = math.clamp(tonumber(BBox.Text) or 0, 0, 255)
                CurrentColor = Color3.fromRGB(r, g, b)
                Preview.BackgroundColor3 = CurrentColor
                Callback(CurrentColor)
            end

            RBox.FocusLost:Connect(UpdateColor)
            GBox.FocusLost:Connect(UpdateColor)
            BBox.FocusLost:Connect(UpdateColor)

            local Opened = false
            Preview.MouseButton1Click:Connect(function()
                Opened = not Opened
                if Opened then
                    Picker.Visible = true
                    Tween(Picker, {Size = UDim2.new(1, 0, 0, 130)}, 0.25, Enum.EasingStyle.Quint)
                else
                    Tween(Picker, {Size = UDim2.new(1, 0, 0, 0)}, 0.2).Completed:Connect(function()
                        Picker.Visible = false
                    end)
                end
            end)

            return {
                Set = function(_, c)
                    CurrentColor = c
                    Preview.BackgroundColor3 = c
                    RBox.Text = tostring(math.floor(c.R * 255))
                    GBox.Text = tostring(math.floor(c.G * 255))
                    BBox.Text = tostring(math.floor(c.B * 255))
                    Callback(c)
                end,
                Get = function() return CurrentColor end
            }
        end

        function TabObj:AddLabel(labelConfig)
            labelConfig = labelConfig or {}
            local Text = labelConfig.Title or "Label"

            local Frame = Create("Frame", {
                Parent = self.Frame,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 22),
                LayoutOrder = #self.Elements
            })
            table.insert(self.Elements, Frame)

            Create("TextLabel", {
                Parent = Frame,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -12, 1, 0),
                Position = UDim2.new(0, 6, 0, 0),
                Font = Theme.Font,
                Text = Text,
                TextColor3 = Theme.TextDim,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Center,
                RichText = true
            })
            return Frame
        end

        function TabObj:AddParagraph(paraConfig)
            paraConfig = paraConfig or {}
            local Title = paraConfig.Title or "Paragraph"
            local Content = paraConfig.Content or ""

            local Frame = Create("Frame", {
                Parent = self.Frame,
                BackgroundColor3 = Theme.Element,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 64),
                AutomaticSize = Enum.AutomaticSize.Y,
                LayoutOrder = #self.Elements
            })
            Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = Frame})
            Create("UIStroke", {
                Color = Theme.Stroke,
                Thickness = 1,
                Transparency = 0.5,
                Parent = Frame
            })

            Create("TextLabel", {
                Parent = Frame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 14, 0, 10),
                Size = UDim2.new(1, -28, 0, 18),
                Font = Theme.FontBold,
                Text = Title,
                TextColor3 = Theme.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left
            })

            Create("TextLabel", {
                Parent = Frame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 14, 0, 30),
                Size = UDim2.new(1, -28, 0, 20),
                Font = Theme.Font,
                Text = Content,
                TextColor3 = Theme.TextDim,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Top,
                TextWrapped = true
            })
            return Frame
        end

        function TabObj:AddDivider()
            local Frame = Create("Frame", {
                Parent = self.Frame,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 8),
                LayoutOrder = #self.Elements
            })
            table.insert(self.Elements, Frame)

            Create("Frame", {
                Parent = Frame,
                BackgroundColor3 = Theme.Stroke,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 1),
                Position = UDim2.new(0, 0, 0.5, 0),
                BackgroundTransparency = 0.5
            })
            return Frame
        end

        return TabObj
    end

    function WindowObj:Notify(notifyConfig)
        notifyConfig = notifyConfig or {}
        local Title = notifyConfig.Title or "Notification"
        local Content = notifyConfig.Content or ""
        local Duration = notifyConfig.Duration or 5
        local Type = notifyConfig.Type or "Info"

        local NotifContainer = self.ScreenGui:FindFirstChild("NotifContainer")
        if not NotifContainer then
            NotifContainer = Create("Frame", {
                Name = "NotifContainer",
                Parent = self.ScreenGui,
                BackgroundTransparency = 1,
                Size = UDim2.new(0, 320, 1, 0),
                Position = UDim2.new(1, -340, 0, 20),
                ClipsDescendants = false
            })
            Create("UIListLayout", {
                Parent = NotifContainer,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 10),
                VerticalAlignment = Enum.VerticalAlignment.Top
            })
        end

        local NotifFrame = Create("Frame", {
            Parent = NotifContainer,
            BackgroundColor3 = Theme.Notification,
            BorderSizePixel = 0,
            Size = UDim2.fromOffset(300, 0),
            LayoutOrder = tick(),
            ClipsDescendants = true
        })
        Create("UICorner", {CornerRadius = UDim.new(0, 10), Parent = NotifFrame})

        local AccentColor = Theme.Info
        if Type == "Success" then AccentColor = Theme.Success
        elseif Type == "Error" then AccentColor = Theme.Error
        elseif Type == "Warning" then AccentColor = Theme.Warning end

        local AccentBar = Create("Frame", {
            Parent = NotifFrame,
            BackgroundColor3 = AccentColor,
            BorderSizePixel = 0,
            Size = UDim2.new(0, 4, 1, 0)
        })
        Create("UICorner", {CornerRadius = UDim.new(0, 10), Parent = AccentBar})

        local NotifTitle = Create("TextLabel", {
            Parent = NotifFrame,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 18, 0, 10),
            Size = UDim2.new(1, -40, 0, 18),
            Font = Theme.FontBold,
            Text = Title,
            TextColor3 = Theme.Text,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left
        })

        local NotifContent = Create("TextLabel", {
            Parent = NotifFrame,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 18, 0, 30),
            Size = UDim2.new(1, -36, 0, 40),
            Font = Theme.Font,
            Text = Content,
            TextColor3 = Theme.TextDim,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            TextWrapped = true
        })

        local CloseBtn = Create("ImageButton", {
            Parent = NotifFrame,
            BackgroundTransparency = 1,
            Position = UDim2.new(1, -28, 0, 8),
            Size = UDim2.fromOffset(18, 18),
            Image = "rbxassetid://10747384394",
            ImageColor3 = Theme.TextDim
        })

        local ProgressBar = Create("Frame", {
            Parent = NotifFrame,
            BackgroundColor3 = AccentColor,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 2),
            Position = UDim2.new(0, 0, 1, -2)
        })

        CloseBtn.MouseEnter:Connect(function()
            Tween(CloseBtn, {ImageColor3 = Theme.Text}, 0.15)
        end)
        CloseBtn.MouseLeave:Connect(function()
            Tween(CloseBtn, {ImageColor3 = Theme.TextDim}, 0.15)
        end)
        CloseBtn.MouseButton1Click:Connect(function()
            Tween(NotifFrame, {Size = UDim2.fromOffset(300, 0)}, 0.3, Enum.EasingStyle.Quint).Completed:Connect(function()
                NotifFrame:Destroy()
            end)
        end)

        NotifFrame.Size = UDim2.fromOffset(300, 0)
        Spring(NotifFrame, {Size = UDim2.fromOffset(300, 70)}, 0.4)

        Tween(ProgressBar, {Size = UDim2.new(0, 0, 0, 2)}, Duration, Enum.EasingStyle.Linear)

        task.delay(Duration, function()
            if NotifFrame and NotifFrame.Parent then
                Tween(NotifFrame, {Size = UDim2.fromOffset(300, 0)}, 0.3, Enum.EasingStyle.Quint).Completed:Connect(function()
                    if NotifFrame then NotifFrame:Destroy() end
                end)
            end
        end)
    end

    table.insert(Windows, WindowObj)
    return WindowObj
end

function Library:Notify(config)
    if #Windows > 0 then
        Windows[1]:Notify(config)
    end
end

return Library
