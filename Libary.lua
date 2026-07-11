local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local TextService = game:GetService("TextService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local Library = {}
local Windows = {}
local ThemeManager = {}
local ConfigManager = {}

-- Icon mapping (Lucide-style names to rbxassetids)
local Icons = {
    ["alert-circle"] = "rbxassetid://10747384394",
    ["check"] = "rbxassetid://10709766959",
    ["chevron-down"] = "rbxassetid://10709766959",
    ["copy"] = "rbxassetid://10734884548",
    ["moon"] = "rbxassetid://10734950020",
    ["sun"] = "rbxassetid://10734950256",
    ["x"] = "rbxassetid://10747384394",
    ["search"] = "rbxassetid://10734943674",
    ["settings"] = "rbxassetid://10734950020",
    ["user"] = "rbxassetid://10734950256",
    ["bell"] = "rbxassetid://10709766959",
    ["layout-grid"] = "rbxassetid://10709766959",
    ["brush"] = "rbxassetid://10709766959",
    ["save"] = "rbxassetid://10734884548",
    ["folder"] = "rbxassetid://10734884548",
    ["refresh-cw"] = "rbxassetid://10709766959",
    ["arrow-right"] = "rbxassetid://10709766959",
    ["sparkles"] = "rbxassetid://10709766959",
    ["palette"] = "rbxassetid://10709766959",
    ["plus"] = "rbxassetid://10709766959",
    ["minus"] = "rbxassetid://10709766959",
    ["maximize"] = "rbxassetid://10709766959",
    ["minimize"] = "rbxassetid://10709766959",
    ["github"] = "rbxassetid://10709766959",
    ["droplet"] = "rbxassetid://10709766959",
    ["bird"] = "rbxassetid://10709766959",
    ["component"] = "rbxassetid://10709766959",
    ["geist:window"] = "rbxassetid://10709766959",
    ["info"] = "rbxassetid://10709766959",
    ["warning"] = "rbxassetid://10709766959",
    ["alert-triangle"] = "rbxassetid://10747384394",
}

-- Default theme (Dark)
local Themes = {
    Dark = {
        Font = Enum.Font.Gotham,
        FontBold = Enum.Font.GothamBold,
        FontMedium = Enum.Font.GothamMedium,
        FontMono = Enum.Font.Code,

        Background = Color3.fromRGB(20, 20, 24),
        BackgroundSecondary = Color3.fromRGB(26, 26, 32),
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
        Notification = Color3.fromRGB(30, 30, 38),
        Acrylic = Color3.fromRGB(30, 30, 38),
    },
    Light = {
        Font = Enum.Font.Gotham,
        FontBold = Enum.Font.GothamBold,
        FontMedium = Enum.Font.GothamMedium,
        FontMono = Enum.Font.Code,

        Background = Color3.fromRGB(245, 245, 250),
        BackgroundSecondary = Color3.fromRGB(235, 235, 240),
        Topbar = Color3.fromRGB(235, 235, 240),
        Sidebar = Color3.fromRGB(230, 230, 235),
        TabActive = Color3.fromRGB(220, 220, 228),
        TabHover = Color3.fromRGB(210, 210, 218),
        Element = Color3.fromRGB(255, 255, 255),
        ElementHover = Color3.fromRGB(240, 240, 245),
        ElementActive = Color3.fromRGB(220, 220, 228),
        Stroke = Color3.fromRGB(200, 200, 210),
        StrokeHover = Color3.fromRGB(160, 160, 175),

        Accent = Color3.fromRGB(59, 130, 246),
        AccentHover = Color3.fromRGB(37, 99, 235),
        AccentGlow = Color3.fromRGB(59, 130, 246),

        Text = Color3.fromRGB(15, 15, 20),
        TextDim = Color3.fromRGB(80, 80, 95),
        TextDark = Color3.fromRGB(140, 140, 155),

        Success = Color3.fromRGB(34, 197, 94),
        Error = Color3.fromRGB(239, 68, 68),
        Warning = Color3.fromRGB(245, 158, 11),
        Info = Color3.fromRGB(59, 130, 246),

        Shadow = Color3.fromRGB(0, 0, 0),
        Notification = Color3.fromRGB(255, 255, 255),
        Acrylic = Color3.fromRGB(255, 255, 255),
    },
    Midnight = {
        Font = Enum.Font.Gotham,
        FontBold = Enum.Font.GothamBold,
        FontMedium = Enum.Font.GothamMedium,
        FontMono = Enum.Font.Code,

        Background = Color3.fromRGB(10, 10, 18),
        BackgroundSecondary = Color3.fromRGB(15, 15, 25),
        Topbar = Color3.fromRGB(15, 15, 25),
        Sidebar = Color3.fromRGB(12, 12, 22),
        TabActive = Color3.fromRGB(30, 30, 50),
        TabHover = Color3.fromRGB(25, 25, 40),
        Element = Color3.fromRGB(25, 25, 40),
        ElementHover = Color3.fromRGB(35, 35, 55),
        ElementActive = Color3.fromRGB(40, 40, 65),
        Stroke = Color3.fromRGB(45, 45, 70),
        StrokeHover = Color3.fromRGB(70, 70, 100),

        Accent = Color3.fromRGB(139, 92, 246),
        AccentHover = Color3.fromRGB(167, 139, 250),
        AccentGlow = Color3.fromRGB(139, 92, 246),

        Text = Color3.fromRGB(245, 245, 250),
        TextDim = Color3.fromRGB(170, 170, 190),
        TextDark = Color3.fromRGB(110, 110, 135),

        Success = Color3.fromRGB(75, 220, 120),
        Error = Color3.fromRGB(255, 85, 85),
        Warning = Color3.fromRGB(255, 185, 70),
        Info = Color3.fromRGB(139, 92, 246),

        Shadow = Color3.fromRGB(0, 0, 0),
        Notification = Color3.fromRGB(20, 20, 35),
        Acrylic = Color3.fromRGB(20, 20, 35),
    }
}

local CurrentTheme = "Dark"
local Theme = Themes.Dark

function ThemeManager:SetTheme(name)
    if Themes[name] then
        CurrentTheme = name
        Theme = Themes[name]
        for _, window in ipairs(Windows) do
            if window.UpdateTheme then
                window:UpdateTheme()
            end
        end
    end
end

function ThemeManager:GetTheme() return CurrentTheme end
function ThemeManager:GetThemes() return Themes end
function ThemeManager:RegisterTheme(name, themeTable)
    Themes[name] = themeTable
end

-- Utility functions
local function Create(class, props)
    local obj = Instance.new(class)
    for k, v in pairs(props) do
        if k ~= "Parent" then
            obj[k] = v
        end
    end
    if props.Parent then
        obj.Parent = props.Parent
    end
    return obj
end

local function Tween(obj, props, duration, style, dir)
    if not obj or not obj.Parent then return nil end
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
        obj.Parent = CoreGui
    elseif gethui then
        obj.Parent = gethui()
    else
        obj.Parent = CoreGui
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
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
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

local function GetIcon(name)
    if Icons[name] then return Icons[name] end
    if name:match("^rbxassetid://") then return name end
    return nil
end

-- Config Manager
function ConfigManager:Init(window)
    self.Window = window
    self.Folder = window.Folder or "AetherUI"
    self.Configs = {}
end

function ConfigManager:CreateConfig(name)
    local config = {
        Name = name,
        Data = {},
        Elements = {},
        Register = function(self, key, element)
            self.Elements[key] = element
        end,
        Set = function(self, key, value)
            self.Data[key] = value
        end,
        Get = function(self, key)
            return self.Data[key]
        end,
        Save = function(self)
            local data = {}
            for k, v in pairs(self.Data) do
                data[k] = v
            end
            for k, element in pairs(self.Elements) do
                if element.Get then
                    data[k] = element.Get()
                elseif element.Value ~= nil then
                    data[k] = element.Value
                end
            end
            local success, encoded = pcall(function() return HttpService:JSONEncode(data) end)
            if success then
                if writefile then
                    pcall(function()
                        if not isfolder(self.Folder) then makefolder(self.Folder) end
                        writefile(self.Folder .. "/" .. self.Name .. ".json", encoded)
                    end)
                end
                return true
            end
            return false
        end,
        Load = function(self)
            if readfile then
                local success, content = pcall(function()
                    return readfile(self.Folder .. "/" .. self.Name .. ".json")
                end)
                if success and content then
                    local ok, data = pcall(function() return HttpService:JSONDecode(content) end)
                    if ok and data then
                        self.Data = data
                        for k, element in pairs(self.Elements) do
                            if data[k] ~= nil then
                                if element.Set then
                                    element.Set(data[k])
                                end
                            end
                        end
                        return data
                    end
                end
            end
            return nil
        end
    }
    table.insert(self.Configs, config)
    return config
end

-- Gradient text helper
function Library:GradientText(text, startColor, endColor)
    local result = ""
    for i = 1, #text do
        local t = (i - 1) / math.max(#text - 1, 1)
        local r = math.floor((startColor.R + (endColor.R - startColor.R) * t) * 255)
        local g = math.floor((startColor.G + (endColor.G - startColor.G) * t) * 255)
        local b = math.floor((startColor.B + (endColor.B - startColor.B) * t) * 255)
        result = result .. string.format('<font color="rgb(%d,%d,%d)">%s</font>', r, g, b, text:sub(i, i))
    end
    return result
end

function Library:CreateWindow(config)
    config = config or {}
    local Title = config.Title or "Window"
    local SubTitle = config.SubTitle or ""
    local Size = config.Size or UDim2.fromOffset(640, 480)
    local TabWidth = config.TabWidth or 180
    local MinimizeKey = config.MinimizeKey
    local Folder = config.Folder or "AetherUI"
    local Acrylic = config.Acrylic or false
    local UserConfig = config.User or { Enabled = false }
    local OnCloseCallback = config.OnClose
    local OnDestroyCallback = config.OnDestroy

    local ScreenGui = Create("ScreenGui", {
        Name = HttpService:GenerateGUID(false),
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 999
    })
    ProtectGui(ScreenGui)

    -- Acrylic background
    local AcrylicFrame = nil
    if Acrylic then
        AcrylicFrame = Create("Frame", {
            Parent = ScreenGui,
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = Theme.Acrylic,
            BackgroundTransparency = 0.3,
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.new(1, 100, 1, 100),
            ZIndex = -5,
        })
        Create("UICorner", {CornerRadius = UDim.new(0, 20), Parent = AcrylicFrame})
    end

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
    Create("UICorner", {CornerRadius = UDim.new(0, 12), Parent = MainFrame})

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
    Create("UICorner", {CornerRadius = UDim.new(0, 12), Parent = Topbar})

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

    -- Tags/Badges
    local TagsContainer = Create("Frame", {
        Parent = Topbar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 18 + TextService:GetTextSize(TitleLabel.Text, 17, Theme.FontBold, Vector2.new(999, 50)).X + 10, 0, 0),
        Size = UDim2.new(0, 200, 1, 0),
    })
    Create("UIListLayout", {
        Parent = TagsContainer,
        FillDirection = Enum.FillDirection.Horizontal,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 6),
        VerticalAlignment = Enum.VerticalAlignment.Center
    })

    -- Topbar buttons container
    local TopbarButtons = Create("Frame", {
        Parent = Topbar,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -140, 0, 0),
        Size = UDim2.new(0, 100, 1, 0),
    })
    Create("UIListLayout", {
        Parent = TopbarButtons,
        FillDirection = Enum.FillDirection.Horizontal,
        SortOrder = Enum.SortOrder.LayoutOrder,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        Padding = UDim.new(0, 8),
        VerticalAlignment = Enum.VerticalAlignment.Center
    })

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

    -- User profile button
    if UserConfig.Enabled then
        local UserBtn = Create("ImageButton", {
            Parent = Topbar,
            BackgroundTransparency = 1,
            Position = UDim2.new(1, -108, 0, 13),
            Size = UDim2.fromOffset(24, 24),
            Image = GetIcon("user") or "",
            ImageColor3 = Theme.TextDim,
            AutoButtonColor = false
        })
        UserBtn.MouseEnter:Connect(function() Tween(UserBtn, {ImageColor3 = Theme.Text}, 0.15) end)
        UserBtn.MouseLeave:Connect(function() Tween(UserBtn, {ImageColor3 = Theme.TextDim}, 0.15) end)
        UserBtn.MouseButton1Click:Connect(function()
            if UserConfig.Callback then
                UserConfig.Callback()
            end
        end)
    end

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

    local SidebarLine = Create("Frame", {
        Parent = Sidebar,
        BackgroundColor3 = Theme.Stroke,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 1, 1, 0),
        Position = UDim2.new(1, 0, 0, 0),
        BackgroundTransparency = 0.5
    })

    -- Search bar
    local SearchBar = nil
    if not config.HideSearchBar then
        SearchBar = Create("Frame", {
            Parent = Sidebar,
            BackgroundColor3 = Theme.BackgroundSecondary,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 10, 0, 10),
            Size = UDim2.new(1, -20, 0, 32),
        })
        Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = SearchBar})

        local SearchIcon = Create("ImageLabel", {
            Parent = SearchBar,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 8, 0.5, -8),
            Size = UDim2.fromOffset(16, 16),
            Image = GetIcon("search") or "",
            ImageColor3 = Theme.TextDark,
        })

        local SearchBox = Create("TextBox", {
            Parent = SearchBar,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 30, 0, 0),
            Size = UDim2.new(1, -40, 1, 0),
            Font = Theme.Font,
            Text = "",
            PlaceholderText = "Search...",
            TextColor3 = Theme.Text,
            PlaceholderColor3 = Theme.TextDark,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            ClearTextOnFocus = false
        })
    end

    local TabContainer = Create("ScrollingFrame", {
        Parent = Sidebar,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = SearchBar and UDim2.new(0, 0, 0, 52) or UDim2.new(0, 0, 0, 0),
        Size = SearchBar and UDim2.new(1, 0, 1, -52) or UDim2.new(1, 0, 1, 0),
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
        Keybinds = {},
        Folder = Folder,
        Tags = {},
        TopbarButtons = TopbarButtons,
        OnClose = OnCloseCallback,
        OnDestroy = OnDestroyCallback,
        Acrylic = Acrylic,
        AcrylicFrame = AcrylicFrame,
        ConfigManager = nil,
        Elements = {},
        ThemeConnections = {},
    }

    -- Config Manager setup
    ConfigManager:Init(WindowObj)
    WindowObj.ConfigManager = ConfigManager

    function WindowObj:UpdateTheme()
        MainFrame.BackgroundColor3 = Theme.Background
        Topbar.BackgroundColor3 = Theme.Topbar
        Sidebar.BackgroundColor3 = Theme.Sidebar
        MainStroke.Color = Theme.Stroke
        TitleLabel.TextColor3 = Theme.Text
        MinimizeBtn.ImageColor3 = Theme.TextDim
        CloseBtn.ImageColor3 = Theme.TextDim
        if AcrylicFrame then
            AcrylicFrame.BackgroundColor3 = Theme.Acrylic
        end
        for _, tab in ipairs(self.Tabs) do
            if tab ~= self.ActiveTab then
                tab.Button.BackgroundColor3 = Theme.Sidebar
                tab.TextLabel.TextColor3 = Theme.TextDim
                if tab.Icon then tab.Icon.ImageColor3 = Theme.TextDim end
            else
                tab.Button.BackgroundColor3 = Theme.TabActive
                tab.TextLabel.TextColor3 = Theme.Text
                if tab.Icon then tab.Icon.ImageColor3 = Theme.Accent end
            end
        end
        for _, element in ipairs(self.Elements) do
            if element.UpdateTheme then
                element.UpdateTheme()
            end
        end
    end

    MakeDraggable(Topbar, MainFrame)

    local function ToggleMinimize()
        WindowObj.Minimized = not WindowObj.Minimized
        if WindowObj.Minimized then
            Tween(MainFrame, {Size = UDim2.new(0, Size.X.Offset, 0, 50)}, 0.35, Enum.EasingStyle.Quint)
            Content.Visible = false
            if AcrylicFrame then AcrylicFrame.Visible = false end
        else
            Tween(MainFrame, {Size = Size}, 0.35, Enum.EasingStyle.Quint)
            Content.Visible = true
            if AcrylicFrame then AcrylicFrame.Visible = true end
        end
    end

    CloseBtn.MouseEnter:Connect(function()
        Tween(CloseBtn, {ImageColor3 = Theme.Error}, 0.15)
    end)
    CloseBtn.MouseLeave:Connect(function()
        Tween(CloseBtn, {ImageColor3 = Theme.TextDim}, 0.15)
    end)
    CloseBtn.MouseButton1Click:Connect(function()
        if WindowObj.OnClose then
            pcall(WindowObj.OnClose)
        end
        Tween(MainFrame, {Size = UDim2.fromOffset(0, 0)}, 0.4, Enum.EasingStyle.Quint)
        Tween(ShadowLayer, {ImageTransparency = 1}, 0.4)
        task.delay(0.4, function()
            if ScreenGui then ScreenGui:Destroy() end
            if WindowObj.OnDestroy then
                pcall(WindowObj.OnDestroy)
            end
        end)
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

    function WindowObj:Tag(tagConfig)
        tagConfig = tagConfig or {}
        local tagTitle = tagConfig.Title or "Tag"
        local tagColor = tagConfig.Color or Theme.Accent
        local radius = tagConfig.Radius ~= nil and tagConfig.Radius or 4

        local TagFrame = Create("Frame", {
            Parent = TagsContainer,
            BackgroundColor3 = typeof(tagColor) == "Color3" and tagColor or Theme.Accent,
            BorderSizePixel = 0,
            Size = UDim2.new(0, TextService:GetTextSize(tagTitle, 11, Theme.FontBold, Vector2.new(999, 20)).X + 12, 0, 20),
            LayoutOrder = #self.Tags + 1
        })
        Create("UICorner", {CornerRadius = UDim.new(0, radius), Parent = TagFrame})

        local TagText = Create("TextLabel", {
            Parent = TagFrame,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Font = Theme.FontBold,
            Text = tagTitle,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 11,
            TextYAlignment = Enum.TextYAlignment.Center
        })

        local tagObj = {
            Frame = TagFrame,
            TextLabel = TagText,
            SetTitle = function(_, t)
                TagText.Text = t
                TagFrame.Size = UDim2.new(0, TextService:GetTextSize(t, 11, Theme.FontBold, Vector2.new(999, 20)).X + 12, 0, 20)
            end,
            SetColor = function(_, c)
                TagFrame.BackgroundColor3 = c
            end,
            Destroy = function()
                TagFrame:Destroy()
            end
        }
        table.insert(self.Tags, tagObj)
        return tagObj
    end

    function WindowObj:CreateTopbarButton(id, icon, callback, order)
        local iconId = GetIcon(icon) or icon
        local Btn = Create("ImageButton", {
            Name = id,
            Parent = self.TopbarButtons,
            BackgroundTransparency = 1,
            Size = UDim2.fromOffset(24, 24),
            Image = iconId,
            ImageColor3 = Theme.TextDim,
            AutoButtonColor = false,
            LayoutOrder = order or 1
        })
        Btn.MouseEnter:Connect(function() Tween(Btn, {ImageColor3 = Theme.Text}, 0.15) end)
        Btn.MouseLeave:Connect(function() Tween(Btn, {ImageColor3 = Theme.TextDim}, 0.15) end)
        Btn.MouseButton1Click:Connect(function()
            if callback then callback() end
        end)
        return Btn
    end

    function WindowObj:AddTab(tabConfig)
        tabConfig = tabConfig or {}
        local TabName = tabConfig.Title or "Tab"
        local TabIcon = tabConfig.Icon
        local TabDesc = tabConfig.Desc

        self.TabCount = self.TabCount + 1
        local layoutOrder = self.TabCount

        local TabButton = Create("TextButton", {
            Name = TabName .. "Btn",
            Parent = self.TabContainer,
            BackgroundColor3 = Theme.Sidebar,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 38),
            Font = Theme.Font,
            Text = "",
            AutoButtonColor = false,
            LayoutOrder = layoutOrder
        })
        Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = TabButton})

        local IconLabel = nil
        if TabIcon then
            local iconId = GetIcon(TabIcon) or TabIcon
            IconLabel = Create("ImageLabel", {
                Name = "Icon",
                Parent = TabButton,
                BackgroundTransparency = 1,
                Size = UDim2.fromOffset(18, 18),
                Position = UDim2.new(0, 10, 0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5),
                Image = iconId,
                ImageColor3 = Theme.TextDim
            })
        end

        local TabText = Create("TextLabel", {
            Name = "Title",
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
            Icon = IconLabel,
            TextLabel = TabText,
            Elements = {},
            ElementCount = 0,
            Window = self
        }

        table.insert(self.Tabs, TabObj)

        if not self.ActiveTab then
            self.ActiveTab = TabObj
            TabFrame.Visible = true
            TabButton.BackgroundColor3 = Theme.TabActive
            TabText.TextColor3 = Theme.Text
            if IconLabel then IconLabel.ImageColor3 = Theme.Accent end
            self.TabIndicator.Visible = true
            task.wait(0.1)
            if TabButton and TabButton.Parent then
                self.TabIndicator.Position = UDim2.new(0, 10, 0, TabButton.AbsolutePosition.Y - self.TabContainer.AbsolutePosition.Y + 3)
            end
            self.TabIndicator.Size = UDim2.new(0, 3, 0, 32)
        end

        TabButton.MouseButton1Click:Connect(function()
            if self.ActiveTab == TabObj then return end
            if self.ActiveTab then
                self.ActiveTab.Frame.Visible = false
                Tween(self.ActiveTab.Button, {BackgroundColor3 = Theme.Sidebar}, 0.25)
                self.ActiveTab.TextLabel.TextColor3 = Theme.TextDim
                local icon = self.ActiveTab.Icon
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

        -- Search functionality
        if SearchBar then
            local SearchBox = SearchBar:FindFirstChildOfClass("TextBox")
            if SearchBox then
                SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
                    local query = SearchBox.Text:lower()
                    for _, tab in ipairs(self.Tabs) do
                        if query == "" or tab.Name:lower():find(query) then
                            tab.Button.Visible = true
                        else
                            tab.Button.Visible = false
                        end
                    end
                end)
            end
        end

        function TabObj:GetNextLayoutOrder()
            self.ElementCount = self.ElementCount + 1
            return self.ElementCount
        end

        function TabObj:AddSection(title)
            local order = self:GetNextLayoutOrder()
            local SectionFrame = Create("Frame", {
                Parent = self.Frame,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 30),
                LayoutOrder = order
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
            local Icon = btnConfig.Icon
            local Callback = btnConfig.Callback or function() end
            local Variant = btnConfig.Variant or "Default"

            local order = self:GetNextLayoutOrder()
            local ButtonFrame = Create("Frame", {
                Parent = self.Frame,
                BackgroundColor3 = Variant == "Primary" and Theme.Accent or Theme.Element,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, Description and 68 or 42),
                LayoutOrder = order
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
                TextColor3 = Variant == "Primary" and Color3.fromRGB(255,255,255) or Theme.Text,
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
                    TextColor3 = Variant == "Primary" and Color3.fromRGB(230,230,255) or Theme.TextDim,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextYAlignment = Enum.TextYAlignment.Top
                })
                ButtonFrame.Size = UDim2.new(1, 0, 0, 64)
            end

            if Icon then
                local iconId = GetIcon(Icon) or Icon
                local IconImg = Create("ImageLabel", {
                    Parent = ButtonFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -36, 0.5, -10),
                    Size = UDim2.fromOffset(20, 20),
                    Image = iconId,
                    ImageColor3 = Variant == "Primary" and Color3.fromRGB(255,255,255) or Theme.TextDim,
                })
            end

            local ClickBtn = Create("TextButton", {
                Parent = ButtonFrame,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Text = "",
                ZIndex = 2
            })

            ClickBtn.MouseEnter:Connect(function()
                Tween(ButtonFrame, {BackgroundColor3 = Variant == "Primary" and Theme.AccentHover or Theme.ElementHover}, 0.2)
                Tween(ButtonStroke, {Color = Theme.StrokeHover, Transparency = 0.3}, 0.2)
                Tween(Glow, {ImageTransparency = 0.92}, 0.3)
            end)
            ClickBtn.MouseLeave:Connect(function()
                Tween(ButtonFrame, {BackgroundColor3 = Variant == "Primary" and Theme.Accent or Theme.Element}, 0.2)
                Tween(ButtonStroke, {Color = Theme.Stroke, Transparency = 0.5}, 0.2)
                Tween(Glow, {ImageTransparency = 1}, 0.3)
            end)
            ClickBtn.MouseButton1Down:Connect(function()
                Tween(ButtonFrame, {BackgroundColor3 = Variant == "Primary" and Theme.AccentGlow or Theme.ElementActive}, 0.1)
                local x = ClickBtn.AbsolutePosition.X + ClickBtn.AbsoluteSize.X / 2 - ButtonFrame.AbsolutePosition.X
                local y = ClickBtn.AbsolutePosition.Y + ClickBtn.AbsoluteSize.Y / 2 - ButtonFrame.AbsolutePosition.Y
                Ripple(ButtonFrame, x, y)
            end)
            ClickBtn.MouseButton1Up:Connect(function()
                Tween(ButtonFrame, {BackgroundColor3 = Variant == "Primary" and Theme.AccentHover or Theme.ElementHover}, 0.15)
            end)
            ClickBtn.MouseButton1Click:Connect(Callback)

            table.insert(self.Window.Elements, ButtonFrame)
            return ButtonFrame
        end

        function TabObj:AddToggle(toggleConfig)
            toggleConfig = toggleConfig or {}
            local Title = toggleConfig.Title or "Toggle"
            local Description = toggleConfig.Description
            local Default = toggleConfig.Default or false
            local Callback = toggleConfig.Callback or function() end

            local order = self:GetNextLayoutOrder()
            local height = Description and 64 or 42
            local ToggleFrame = Create("Frame", {
                Parent = self.Frame,
                BackgroundColor3 = Theme.Element,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, height),
                LayoutOrder = order
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
                Size = UDim2.new(1, -80, 0, 42),
                Font = Theme.FontMedium,
                Text = Title,
                TextColor3 = Theme.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Center
            })

            if Description then
                Create("TextLabel", {
                    Parent = ToggleFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 14, 0, 28),
                    Size = UDim2.new(1, -80, 0, 22),
                    Font = Theme.Font,
                    Text = Description,
                    TextColor3 = Theme.TextDim,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextYAlignment = Enum.TextYAlignment.Top
                })
            end

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

            local toggleObj = {
                Set = function(_, v) Value = v; Update() end,
                Get = function() return Value end,
                Frame = ToggleFrame
            }
            table.insert(self.Window.Elements, toggleObj)
            return toggleObj
        end

        function TabObj:AddSlider(sliderConfig)
            sliderConfig = sliderConfig or {}
            local Title = sliderConfig.Title or "Slider"
            local Description = sliderConfig.Description
            local Min = sliderConfig.Min or 0
            local Max = sliderConfig.Max or 100
            local Default = sliderConfig.Default or Min
            local Rounding = sliderConfig.Rounding or 0
            local Suffix = sliderConfig.Suffix or ""
            local Step = sliderConfig.Step
            local Callback = sliderConfig.Callback or function() end

            local order = self:GetNextLayoutOrder()
            local height = Description and 78 or 60
            local SliderFrame = Create("Frame", {
                Parent = self.Frame,
                BackgroundColor3 = Theme.Element,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, height),
                LayoutOrder = order
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

            if Description then
                Create("TextLabel", {
                    Parent = SliderFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 14, 0, 26),
                    Size = UDim2.new(1, -80, 0, 16),
                    Font = Theme.Font,
                    Text = Description,
                    TextColor3 = Theme.TextDim,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
            end

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
                Position = UDim2.new(0, 14, 0, Description and 48 or 38),
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

            local function RoundValue(val)
                if Step then
                    val = math.floor(val / Step + 0.5) * Step
                elseif Rounding > 0 then
                    val = math.floor(val * (10 ^ Rounding) + 0.5) / (10 ^ Rounding)
                else
                    val = math.floor(val + 0.5)
                end
                return math.clamp(val, Min, Max)
            end

            local function Update(input)
                local pos = math.clamp((input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
                local val = Min + (Max - Min) * pos
                val = RoundValue(val)
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

            local sliderObj = {
                Set = function(_, v)
                    v = math.clamp(v, Min, Max)
                    v = RoundValue(v)
                    Fill.Size = UDim2.new((v - Min) / (Max - Min), 0, 1, 0)
                    Knob.Position = UDim2.new((v - Min) / (Max - Min), -7, 0.5, -7)
                    ValueLabel.Text = tostring(v) .. Suffix
                    Callback(v)
                end,
                Get = function()
                    local pos = Fill.Size.X.Scale
                    return RoundValue(Min + (Max - Min) * pos)
                end,
                Frame = SliderFrame
            }
            table.insert(self.Window.Elements, sliderObj)
            return sliderObj
        end

        function TabObj:AddDropdown(dropdownConfig)
            dropdownConfig = dropdownConfig or {}
            local Title = dropdownConfig.Title or "Dropdown"
            local Values = dropdownConfig.Values or {}
            local Default = dropdownConfig.Default
            local Callback = dropdownConfig.Callback or function() end
            local Multi = dropdownConfig.Multi or false

            local order = self:GetNextLayoutOrder()
            local DropdownFrame = Create("Frame", {
                Parent = self.Frame,
                BackgroundColor3 = Theme.Element,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 42),
                ClipsDescendants = false,
                LayoutOrder = order
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
                Text = Default and tostring(Default) or (Multi and "Select..." or "Select..."),
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
                Image = GetIcon("chevron-down") or "rbxassetid://10709766959",
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
            local Selected = Multi and {} or Default
            if Multi and Default then
                for _, v in ipairs(Default) do
                    Selected[v] = true
                end
            end

            local function UpdateLabel()
                if Multi then
                    local items = {}
                    for k, v in pairs(Selected) do
                        if v then table.insert(items, tostring(k)) end
                    end
                    SelectedLabel.Text = #items > 0 and table.concat(items, ", ") or "Select..."
                else
                    SelectedLabel.Text = Selected and tostring(Selected) or "Select..."
                end
            end

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

                if Multi then
                    local Check = Create("Frame", {
                        Parent = OptionBtn,
                        BackgroundColor3 = Selected[val] and Theme.Accent or Theme.Background,
                        BorderSizePixel = 0,
                        Position = UDim2.new(1, -28, 0.5, -8),
                        Size = UDim2.fromOffset(16, 16),
                    })
                    Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = Check})
                    if Selected[val] then
                        Create("ImageLabel", {
                            Parent = Check,
                            BackgroundTransparency = 1,
                            Size = UDim2.new(1, 0, 1, 0),
                            Image = GetIcon("check") or "",
                            ImageColor3 = Color3.fromRGB(255,255,255),
                        })
                    end
                end

                OptionBtn.MouseEnter:Connect(function()
                    Tween(OptionBtn, {BackgroundColor3 = Theme.ElementHover}, 0.15)
                end)
                OptionBtn.MouseLeave:Connect(function()
                    Tween(OptionBtn, {BackgroundColor3 = Theme.Element}, 0.15)
                end)
                OptionBtn.MouseButton1Click:Connect(function()
                    if Multi then
                        Selected[val] = not Selected[val]
                        if OptionBtn:FindFirstChildOfClass("Frame") then
                            local check = OptionBtn:FindFirstChildOfClass("Frame")
                            check.BackgroundColor3 = Selected[val] and Theme.Accent or Theme.Background
                            if Selected[val] then
                                if not check:FindFirstChildOfClass("ImageLabel") then
                                    Create("ImageLabel", {
                                        Parent = check,
                                        BackgroundTransparency = 1,
                                        Size = UDim2.new(1, 0, 1, 0),
                                        Image = GetIcon("check") or "",
                                        ImageColor3 = Color3.fromRGB(255,255,255),
                                    })
                                end
                            else
                                local img = check:FindFirstChildOfClass("ImageLabel")
                                if img then img:Destroy() end
                            end
                        end
                        Callback(Selected)
                    else
                        Selected = val
                        Callback(val)
                        Close()
                    end
                    UpdateLabel()
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

            local dropdownObj = {
                Select = function(_, val)
                    if Multi then
                        Selected = {}
                        for _, v in ipairs(val) do Selected[v] = true end
                    else
                        Selected = val
                    end
                    UpdateLabel()
                    Callback(Selected)
                end,
                Get = function() return Selected end,
                Frame = DropdownFrame
            }
            table.insert(self.Window.Elements, dropdownObj)
            return dropdownObj
        end

        function TabObj:AddInput(inputConfig)
            inputConfig = inputConfig or {}
            local Title = inputConfig.Title or "Input"
            local Default = inputConfig.Default or ""
            local Placeholder = inputConfig.Placeholder or "Type..."
            local Numeric = inputConfig.Numeric or false
            local Callback = inputConfig.Callback or function() end

            local order = self:GetNextLayoutOrder()
            local InputFrame = Create("Frame", {
                Parent = self.Frame,
                BackgroundColor3 = Theme.Element,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 76),
                LayoutOrder = order
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

            if Numeric then
                TextBox:GetPropertyChangedSignal("Text"):Connect(function()
                    TextBox.Text = TextBox.Text:gsub("[^%d%.%-]", "")
                end)
            end

            TextBox.Focused:Connect(function()
                Tween(BoxFrame, {BackgroundColor3 = Theme.Element}, 0.2)
                Tween(InputStroke, {Color = Theme.Accent, Transparency = 0.3}, 0.2)
            end)
            TextBox.FocusLost:Connect(function()
                Tween(BoxFrame, {BackgroundColor3 = Theme.Background}, 0.2)
                Tween(InputStroke, {Color = Theme.Stroke, Transparency = 0.5}, 0.2)
                Callback(TextBox.Text)
            end)

            local inputObj = {
                Set = function(_, v) TextBox.Text = tostring(v); Callback(v) end,
                Get = function() return TextBox.Text end,
                Frame = InputFrame
            }
            table.insert(self.Window.Elements, inputObj)
            return inputObj
        end

        function TabObj:AddKeybind(keybindConfig)
            keybindConfig = keybindConfig or {}
            local Title = keybindConfig.Title or "Keybind"
            local Default = keybindConfig.Default or "None"
            local Callback = keybindConfig.Callback or function() end

            local order = self:GetNextLayoutOrder()
            local KeybindFrame = Create("Frame", {
                Parent = self.Frame,
                BackgroundColor3 = Theme.Element,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 42),
                LayoutOrder = order
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

            local keybindObj = {
                Set = function(_, k) CurrentKey = k; KeybindBtn.Text = k end,
                Get = function() return CurrentKey end,
                Frame = KeybindFrame
            }
            table.insert(self.Window.Elements, keybindObj)
            return keybindObj
        end

        function TabObj:AddColorpicker(colorConfig)
            colorConfig = colorConfig or {}
            local Title = colorConfig.Title or "Colorpicker"
            local Default = colorConfig.Default or Color3.fromRGB(255, 255, 255)
            local Transparency = colorConfig.Transparency
            local Callback = colorConfig.Callback or function() end

            local order = self:GetNextLayoutOrder()
            local ColorFrame = Create("Frame", {
                Parent = self.Frame,
                BackgroundColor3 = Theme.Element,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 42),
                ClipsDescendants = false,
                LayoutOrder = order
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

            local function CreateChannel(name, color, orderNum, default)
                local Channel = Create("Frame", {
                    Parent = Picker,
                    BackgroundColor3 = Theme.Element,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 32),
                    LayoutOrder = orderNum
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
                Box:GetPropertyChangedSignal("Text"):Connect(function()
                    Box.Text = Box.Text:gsub("[^%d]", "")
                end)
                return Box
            end

            local RBox = CreateChannel("R", Theme.Error, 1, math.floor(Default.R * 255))
            local GBox = CreateChannel("G", Theme.Success, 2, math.floor(Default.G * 255))
            local BBox = CreateChannel("B", Theme.Accent, 3, math.floor(Default.B * 255))
            local TBox = nil
            if Transparency then
                TBox = CreateChannel("A", Theme.TextDim, 4, math.floor((Transparency or 0) * 255))
            end

            local CurrentColor = Default
            local CurrentTransparency = Transparency or 0

            local function UpdateColor()
                local r = math.clamp(tonumber(RBox.Text) or 0, 0, 255)
                local g = math.clamp(tonumber(GBox.Text) or 0, 0, 255)
                local b = math.clamp(tonumber(BBox.Text) or 0, 0, 255)
                local t = TBox and math.clamp(tonumber(TBox.Text) or 0, 0, 255) / 255 or 0
                CurrentColor = Color3.fromRGB(r, g, b)
                CurrentTransparency = t
                Preview.BackgroundColor3 = CurrentColor
                if TBox then Preview.BackgroundTransparency = t end
                Callback(CurrentColor, CurrentTransparency)
            end

            RBox.FocusLost:Connect(UpdateColor)
            GBox.FocusLost:Connect(UpdateColor)
            BBox.FocusLost:Connect(UpdateColor)
            if TBox then TBox.FocusLost:Connect(UpdateColor) end

            local Opened = false
            Preview.MouseButton1Click:Connect(function()
                Opened = not Opened
                if Opened then
                    Picker.Visible = true
                    Tween(Picker, {Size = UDim2.new(1, 0, 0, Transparency and 170 or 130)}, 0.25, Enum.EasingStyle.Quint)
                else
                    Tween(Picker, {Size = UDim2.new(1, 0, 0, 0)}, 0.2).Completed:Connect(function()
                        Picker.Visible = false
                    end)
                end
            end)

            local colorObj = {
                Set = function(_, c, t)
                    CurrentColor = c
                    CurrentTransparency = t or 0
                    Preview.BackgroundColor3 = c
                    if TBox then Preview.BackgroundTransparency = CurrentTransparency end
                    RBox.Text = tostring(math.floor(c.R * 255))
                    GBox.Text = tostring(math.floor(c.G * 255))
                    BBox.Text = tostring(math.floor(c.B * 255))
                    if TBox then TBox.Text = tostring(math.floor(CurrentTransparency * 255)) end
                    Callback(c, CurrentTransparency)
                end,
                Get = function() return CurrentColor, CurrentTransparency end,
                Frame = ColorFrame
            }
            table.insert(self.Window.Elements, colorObj)
            return colorObj
        end

        function TabObj:AddLabel(labelConfig)
            labelConfig = labelConfig or {}
            local Text = labelConfig.Title or "Label"
            local Color = labelConfig.Color or Theme.TextDim

            local order = self:GetNextLayoutOrder()
            local Frame = Create("Frame", {
                Parent = self.Frame,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 22),
                LayoutOrder = order
            })
            table.insert(self.Elements, Frame)

            Create("TextLabel", {
                Parent = Frame,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -12, 1, 0),
                Position = UDim2.new(0, 6, 0, 0),
                Font = Theme.Font,
                Text = Text,
                TextColor3 = Color,
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
            local Content = paraConfig.Content or paraConfig.Desc or ""
            local Image = paraConfig.Image
            local ImageSize = paraConfig.ImageSize or 20
            local Color = paraConfig.Color or "White"
            local Buttons = paraConfig.Buttons or {}

            local order = self:GetNextLayoutOrder()
            local Frame = Create("Frame", {
                Parent = self.Frame,
                BackgroundColor3 = Theme.Element,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 64),
                AutomaticSize = Enum.AutomaticSize.Y,
                LayoutOrder = order
            })
            Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = Frame})
            Create("UIStroke", {
                Color = Theme.Stroke,
                Thickness = 1,
                Transparency = 0.5,
                Parent = Frame
            })

            local yOffset = 10
            if Image then
                local iconId = GetIcon(Image) or Image
                local Img = Create("ImageLabel", {
                    Parent = Frame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 14, 0, yOffset),
                    Size = UDim2.fromOffset(ImageSize, ImageSize),
                    Image = iconId,
                    ImageColor3 = Color == "White" and Theme.Text or (typeof(Color) == "Color3" and Color or Theme.Accent),
                })
                yOffset = yOffset + ImageSize + 6
            end

            Create("TextLabel", {
                Parent = Frame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 14, 0, yOffset),
                Size = UDim2.new(1, -28, 0, 18),
                Font = Theme.FontBold,
                Text = Title,
                TextColor3 = Theme.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left
            })

            local contentLabel = Create("TextLabel", {
                Parent = Frame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 14, 0, yOffset + 20),
                Size = UDim2.new(1, -28, 0, 20),
                Font = Theme.Font,
                Text = Content,
                TextColor3 = Theme.TextDim,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Top,
                TextWrapped = true
            })

            if #Buttons > 0 then
                local BtnContainer = Create("Frame", {
                    Parent = Frame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 14, 0, yOffset + 44),
                    Size = UDim2.new(1, -28, 0, 30),
                })
                Create("UIListLayout", {
                    Parent = BtnContainer,
                    FillDirection = Enum.FillDirection.Horizontal,
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Padding = UDim.new(0, 8),
                    VerticalAlignment = Enum.VerticalAlignment.Center
                })
                for i, btnData in ipairs(Buttons) do
                    local variant = btnData.Variant or "Default"
                    local btn = Create("TextButton", {
                        Parent = BtnContainer,
                        BackgroundColor3 = variant == "Primary" and Theme.Accent or Theme.Background,
                        BorderSizePixel = 0,
                        Size = UDim2.new(0, TextService:GetTextSize(btnData.Title or "Button", 12, Theme.FontMedium, Vector2.new(999, 30)).X + 20, 0, 28),
                        Font = Theme.FontMedium,
                        Text = btnData.Title or "Button",
                        TextColor3 = variant == "Primary" and Color3.fromRGB(255,255,255) or Theme.Text,
                        TextSize = 12,
                        AutoButtonColor = false,
                        LayoutOrder = i
                    })
                    Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = btn})
                    btn.MouseEnter:Connect(function()
                        Tween(btn, {BackgroundColor3 = variant == "Primary" and Theme.AccentHover or Theme.ElementHover}, 0.15)
                    end)
                    btn.MouseLeave:Connect(function()
                        Tween(btn, {BackgroundColor3 = variant == "Primary" and Theme.Accent or Theme.Background}, 0.15)
                    end)
                    btn.MouseButton1Click:Connect(function()
                        if btnData.Callback then btnData.Callback() end
                    end)
                end
                contentLabel.Size = UDim2.new(1, -28, 0, 40)
            end

            return Frame
        end

        function TabObj:AddDivider()
            local order = self:GetNextLayoutOrder()
            local Frame = Create("Frame", {
                Parent = self.Frame,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 8),
                LayoutOrder = order
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

        function TabObj:AddCode(codeConfig)
            codeConfig = codeConfig or {}
            local Title = codeConfig.Title or "code.lua"
            local Code = codeConfig.Code or ""
            local OnCopy = codeConfig.OnCopy

            local order = self:GetNextLayoutOrder()
            local CodeFrame = Create("Frame", {
                Parent = self.Frame,
                BackgroundColor3 = Theme.Background,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 120),
                LayoutOrder = order
            })
            Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = CodeFrame})
            Create("UIStroke", {Color = Theme.Stroke, Thickness = 1, Parent = CodeFrame})

            Create("TextLabel", {
                Parent = CodeFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 6),
                Size = UDim2.new(1, -20, 0, 18),
                Font = Theme.FontMedium,
                Text = Title,
                TextColor3 = Theme.TextDim,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left
            })

            local CopyBtn = Create("ImageButton", {
                Parent = CodeFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(1, -30, 0, 6),
                Size = UDim2.fromOffset(18, 18),
                Image = GetIcon("copy") or "",
                ImageColor3 = Theme.TextDim,
            })
            CopyBtn.MouseEnter:Connect(function() Tween(CopyBtn, {ImageColor3 = Theme.Text}, 0.15) end)
            CopyBtn.MouseLeave:Connect(function() Tween(CopyBtn, {ImageColor3 = Theme.TextDim}, 0.15) end)
            CopyBtn.MouseButton1Click:Connect(function()
                if setclipboard then setclipboard(Code) end
                if OnCopy then OnCopy() end
            end)

            local Scroll = Create("ScrollingFrame", {
                Parent = CodeFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 28),
                Size = UDim2.new(1, -20, 1, -36),
                ScrollBarThickness = 2,
                ScrollBarImageColor3 = Theme.Stroke,
                CanvasSize = UDim2.new(0, 0, 0, 0),
                AutomaticCanvasSize = Enum.AutomaticSize.Y
            })

            Create("TextLabel", {
                Parent = Scroll,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                Font = Theme.FontMono,
                Text = Code,
                TextColor3 = Theme.Text,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Top,
                TextWrapped = true
            })

            return CodeFrame
        end

        return TabObj
    end

    function WindowObj:Dialog(dialogConfig)
        dialogConfig = dialogConfig or {}
        local DTitle = dialogConfig.Title or "Dialog"
        local DContent = dialogConfig.Content or ""
        local Buttons = dialogConfig.Buttons or {{Title = "OK", Variant = "Primary"}}

        local DialogGui = Create("ScreenGui", {
            Name = "Dialog_" .. HttpService:GenerateGUID(false),
            Parent = ScreenGui,
            ResetOnSpawn = false,
            ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
            DisplayOrder = 1000
        })

        local Backdrop = Create("Frame", {
            Parent = DialogGui,
            BackgroundColor3 = Color3.fromRGB(0, 0, 0),
            BackgroundTransparency = 0.6,
            Size = UDim2.new(1, 0, 1, 0),
            BorderSizePixel = 0,
        })

        local DialogFrame = Create("Frame", {
            Parent = DialogGui,
            BackgroundColor3 = Theme.Background,
            BorderSizePixel = 0,
            Size = UDim2.fromOffset(380, 0),
            Position = UDim2.fromScale(0.5, 0.5),
            AnchorPoint = Vector2.new(0.5, 0.5),
            ClipsDescendants = true
        })
        Create("UICorner", {CornerRadius = UDim.new(0, 12), Parent = DialogFrame})
        Create("UIStroke", {Color = Theme.Stroke, Thickness = 1, Parent = DialogFrame})

        Create("TextLabel", {
            Parent = DialogFrame,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 20, 0, 16),
            Size = UDim2.new(1, -40, 0, 22),
            Font = Theme.FontBold,
            Text = DTitle,
            TextColor3 = Theme.Text,
            TextSize = 16,
            TextXAlignment = Enum.TextXAlignment.Left
        })

        Create("TextLabel", {
            Parent = DialogFrame,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 20, 0, 46),
            Size = UDim2.new(1, -40, 0, 40),
            Font = Theme.Font,
            Text = DContent,
            TextColor3 = Theme.TextDim,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            TextWrapped = true
        })

        local BtnContainer = Create("Frame", {
            Parent = DialogFrame,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 20, 0, 96),
            Size = UDim2.new(1, -40, 0, 36),
        })
        Create("UIListLayout", {
            Parent = BtnContainer,
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            Padding = UDim.new(0, 10),
            VerticalAlignment = Enum.VerticalAlignment.Center
        })

        for _, btnData in ipairs(Buttons) do
            local variant = btnData.Variant or "Default"
            local btn = Create("TextButton", {
                Parent = BtnContainer,
                BackgroundColor3 = variant == "Primary" and Theme.Accent or Theme.Element,
                BorderSizePixel = 0,
                Size = UDim2.new(0, TextService:GetTextSize(btnData.Title or "Button", 13, Theme.FontMedium, Vector2.new(999, 36)).X + 24, 1, 0),
                Font = Theme.FontMedium,
                Text = btnData.Title or "Button",
                TextColor3 = variant == "Primary" and Color3.fromRGB(255,255,255) or Theme.Text,
                TextSize = 13,
                AutoButtonColor = false
            })
            Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = btn})
            btn.MouseEnter:Connect(function()
                Tween(btn, {BackgroundColor3 = variant == "Primary" and Theme.AccentHover or Theme.ElementHover}, 0.15)
            end)
            btn.MouseLeave:Connect(function()
                Tween(btn, {BackgroundColor3 = variant == "Primary" and Theme.Accent or Theme.Element}, 0.15)
            end)
            btn.MouseButton1Click:Connect(function()
                Tween(DialogFrame, {Size = UDim2.fromOffset(380, 0)}, 0.25).Completed:Connect(function()
                    DialogGui:Destroy()
                end)
                if btnData.Callback then
                    task.spawn(btnData.Callback)
                end
            end)
        end

        Spring(DialogFrame, {Size = UDim2.fromOffset(380, 150)}, 0.4)
    end

    function WindowObj:Notify(notifyConfig)
        notifyConfig = notifyConfig or {}
        local Title = notifyConfig.Title or "Notification"
        local Content = notifyConfig.Content or ""
        local Duration = notifyConfig.Duration or 5
        local Type = notifyConfig.Type or "Info"
        local Icon = notifyConfig.Icon

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

        if Icon then
            local iconId = GetIcon(Icon) or Icon
            Create("ImageLabel", {
                Parent = NotifFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 12, 0, 12),
                Size = UDim2.fromOffset(18, 18),
                Image = iconId,
                ImageColor3 = AccentColor,
            })
        end

        local NotifTitle = Create("TextLabel", {
            Parent = NotifFrame,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, Icon and 36 or 18, 0, 10),
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
            Position = UDim2.new(0, Icon and 36 or 18, 0, 30),
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
            Image = GetIcon("x") or "rbxassetid://10747384394",
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

    function WindowObj:ToggleTransparency(enabled)
        if not self.Acrylic then return end
        if enabled then
            Tween(self.MainFrame, {BackgroundTransparency = 0.15}, 0.3)
            if self.AcrylicFrame then
                Tween(self.AcrylicFrame, {BackgroundTransparency = 0.3}, 0.3)
            end
        else
            Tween(self.MainFrame, {BackgroundTransparency = 0}, 0.3)
            if self.AcrylicFrame then
                Tween(self.AcrylicFrame, {BackgroundTransparency = 1}, 0.3)
            end
        end
    end

    table.insert(Windows, WindowObj)
    return WindowObj
end

function Library:Notify(config)
    if #Windows > 0 then
        Windows[1]:Notify(config)
    end
end

function Library:SetTheme(name)
    ThemeManager:SetTheme(name)
end

function Library:GetTheme()
    return ThemeManager:GetTheme()
end

function Library:GetThemes()
    return ThemeManager:GetThemes()
end

function Library:RegisterTheme(name, theme)
    ThemeManager:RegisterTheme(name, theme)
end

function Library:OnThemeChange(callback)
    table.insert(ThemeManager.Connections or {}, callback)
end

return Library
