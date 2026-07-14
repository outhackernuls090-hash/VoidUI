local cloneref = (cloneref or clonereference or function(instance)
	return instance
end)

local RunService = cloneref(game:GetService("RunService"))
local TweenService = cloneref(game:GetService("TweenService"))
local UserInputService = cloneref(game:GetService("UserInputService"))

local Forge = {
	Font = Enum.Font.Gotham,
	Theme = nil,
	Themes = nil,
	ThemeFallbacks = nil,
	Skins = {},
	ThemeHooks = {},
	Fonts = {},
	UIScale = 1,
	Defaults = {
		ScreenGui = {
			ResetOnSpawn = false,
			ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		},
		CanvasGroup = {
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.new(1, 1, 1),
		},
		Frame = {
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.new(1, 1, 1),
		},
		TextLabel = {
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderSizePixel = 0,
			Text = "",
			RichText = true,
			TextColor3 = Color3.new(1, 1, 1),
			TextSize = 14,
			FontFace = Font.fromEnum(Enum.Font.Gotham),
		},
		TextButton = {
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderSizePixel = 0,
			Text = "",
			AutoButtonColor = false,
			TextColor3 = Color3.new(1, 1, 1),
			TextSize = 14,
			FontFace = Font.fromEnum(Enum.Font.Gotham),
		},
		TextBox = {
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderColor3 = Color3.new(0, 0, 0),
			ClearTextOnFocus = false,
			Text = "",
			TextColor3 = Color3.new(0, 0, 0),
			TextSize = 14,
			FontFace = Font.fromEnum(Enum.Font.Gotham),
		},
		ImageLabel = {
			BackgroundTransparency = 1,
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderSizePixel = 0,
		},
		ImageButton = {
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderSizePixel = 0,
			AutoButtonColor = false,
		},
		UIListLayout = {
			SortOrder = Enum.SortOrder.LayoutOrder,
		},
		UIPadding = {
			PaddingLeft = UDim.new(0, 0),
			PaddingRight = UDim.new(0, 0),
			PaddingTop = UDim.new(0, 0),
			PaddingBottom = UDim.new(0, 0),
		},
		UIStroke = {
			Thickness = 1,
		},
		UICorner = {
			CornerRadius = UDim.new(0, 0),
		},
		ScrollingFrame = {
			ScrollBarImageTransparency = 1,
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.new(1, 1, 1),
			AutomaticCanvasSize = Enum.AutomaticCanvasSize.Y,
			ScrollingDirection = Enum.ScrollingDirection.Y,
			VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Left,
		},
	},
}

function Forge.Guard(Callback, ...)
	if type(Callback) ~= "function" then
		return
	end
	local Success, Error = pcall(Callback, ...)
	if not Success then
		warn("[VoidUI] Callback error:", Error)
	end
end

function Forge.Make(Name, Properties, Children)
	local Object = Instance.new(Name)

	for Property, Value in next, Forge.Defaults[Name] or {} do
		Object[Property] = Value
	end

	for Property, Value in next, Properties or {} do
		if Property ~= "Skin" then
			Object[Property] = Value
		end
	end

	for _, Child in next, Children or {} do
		if Child ~= nil then
			Child.Parent = Object
		end
	end

	if Properties and Properties.Skin then
		Forge.Tag(Object, Properties.Skin)
	end
	if Properties and Properties.FontFace then
		Forge.TrackFont(Object)
	end
	return Object
end

function Forge.TrackFont(Object)
	table.insert(Forge.Fonts, Object)
end

function Forge.SetFont(FontEnum)
	Forge.Font = FontEnum
	for _, Obj in next, Forge.Fonts do
		local ok, err = pcall(function()
			Obj.FontFace = Font.fromEnum(FontEnum)
		end)
		if not ok then
			warn("[VoidUI] Font update failed:", err)
		end
	end
end

function Forge.Resolve(Property, Theme)
	local function read(prop, themeTable)
		local value = themeTable[prop]
		if value == nil then
			return nil
		end
		if type(value) == "string" and string.sub(value, 1, 1) == "#" then
			return Color3.fromHex(value)
		end
		if type(value) == "Color3" then
			return value
		end
		if type(value) == "number" then
			return value
		end
		if type(value) == "table" and value.Color and value.Transparency then
			return value
		end
		if type(value) == "function" then
			return value(themeTable)
		end
		return value
	end

	local value = read(Property, Theme)
	if value ~= nil then
		if type(value) == "string" and string.sub(value, 1, 1) ~= "#" then
			local referenced = Forge.Resolve(value, Theme)
			if referenced ~= nil then
				return referenced
			end
		else
			return value
		end
	end

	local fallback = Forge.ThemeFallbacks and Forge.ThemeFallbacks[Property]
	if fallback ~= nil then
		if type(fallback) == "string" and string.sub(fallback, 1, 1) ~= "#" then
			return Forge.Resolve(fallback, Theme)
		else
			return read(Property, { [Property] = fallback })
		end
	end

	value = read(Property, Forge.Themes and Forge.Themes["Default"] or {})
	if value ~= nil then
		if type(value) == "string" and string.sub(value, 1, 1) ~= "#" then
			local referenced = Forge.Resolve(value, Forge.Themes and Forge.Themes["Default"] or {})
			if referenced ~= nil then
				return referenced
			end
		else
			return value
		end
	end

	return nil
end

function Forge.Tag(Object, Properties, skipUpdate)
	if Forge.Skins[Object] then
		for prop, value in pairs(Properties) do
			Forge.Skins[Object].Properties[prop] = value
		end
	else
		Forge.Skins[Object] = { Object = Object, Properties = Properties }
	end

	if not skipUpdate then
		Forge.Refresh(Object, false)
	end
	return Object
end

function Forge.Refresh(Object, ThemeChanged)
	local Theme = Forge.Theme
	if not Theme then
		return
	end
	if Object then
		local data = Forge.Skins[Object]
		if not data then
			return
		end
		for prop, value in pairs(data.Properties) do
			local ThemeValue = Forge.Resolve(value, Theme)
			if ThemeValue ~= nil then
				local ok, err = pcall(function()
					Object[prop] = ThemeValue
				end)
				if not ok then
					warn("[VoidUI] Theme apply failed for", prop, err)
				end
			end
		end
		return
	end
	for _, data in pairs(Forge.Skins) do
		for prop, value in pairs(data.Properties) do
			local ThemeValue = Forge.Resolve(value, Theme)
			if ThemeValue ~= nil then
				pcall(function()
					data.Object[prop] = ThemeValue
				end)
			end
		end
	end
end

function Forge.Apply(Theme)
	local PreviousTheme = Forge.Theme
	Forge.Theme = Theme
	Forge.Refresh(nil, true)

	for _, Callback in next, Forge.ThemeHooks do
		Forge.Guard(Callback, Theme, PreviousTheme)
	end
end

function Forge.OnTheme(Callback)
	table.insert(Forge.ThemeHooks, Callback)
end

function Forge.Tween(Object, Time, Properties, ...)
	return TweenService:Create(Object, TweenInfo.new(Time, ...), Properties)
end

function Forge.Spring(Object, Property, Target, Options)
	Options = Options or {}
	local Tween = Forge.Tween(Object, Options.Duration or 0.3, { [Property] = Target }, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	Tween:Play()
	return Tween
end

return Forge
