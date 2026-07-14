local Utilities = {}

local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")

function Utilities.DeepCopy(Original)
	local Copy
	if type(Original) == "table" then
		Copy = {}
		for Key, Value in pairs(Original) do
			Copy[Utilities.DeepCopy(Key)] = Utilities.DeepCopy(Value)
		end
	else
		Copy = Original
	end
	return Copy
end

function Utilities.ShallowCopy(Original)
	local Copy = {}
	for Key, Value in pairs(Original) do
		Copy[Key] = Value
	end
	return Copy
end

function Utilities.Merge(Base, Override)
	local Result = Utilities.ShallowCopy(Base)
	if Override then
		for Key, Value in pairs(Override) do
			if type(Value) == "table" and type(Result[Key]) == "table" then
				Result[Key] = Utilities.Merge(Result[Key], Value)
			else
				Result[Key] = Value
			end
		end
	end
	return Result
end

function Utilities.Clone(Table)
	return Utilities.DeepCopy(Table)
end

function Utilities.IsTable(Value)
	return type(Value) == "table"
end

function Utilities.IsCallable(Value)
	return type(Value) == "function"
end

function Utilities.IsInstance(Value)
	return typeof(Value) == "Instance"
end

function Utilities.IsColor3(Value)
	return typeof(Value) == "Color3"
end

function Utilities.IsUDim2(Value)
	return typeof(Value) == "UDim2"
end

function Utilities.IsVector2(Value)
	return typeof(Value) == "Vector2"
end

function Utilities.Clamp(Value, Minimum, Maximum)
	return math.max(Minimum, math.min(Maximum, Value))
end

function Utilities.Lerp(Start, Goal, Alpha)
	return Start + (Goal - Start) * Alpha
end

function Utilities.InverseLerp(Start, Goal, Value)
	if Start == Goal then
		return 0
	end
	return (Value - Start) / (Goal - Start)
end

function Utilities.Map(Value, InMin, InMax, OutMin, OutMax)
	return Utilities.Lerp(OutMin, OutMax, Utilities.InverseLerp(InMin, InMax, Value))
end

function Utilities.Round(Value, Precision)
	local Multiplier = 10 ^ (Precision or 0)
	return math.floor(Value * Multiplier + 0.5) / Multiplier
end

function Utilities.Snap(Value, Increment)
	if Increment <= 0 then
		return Value
	end
	return math.floor(Value / Increment + 0.5) * Increment
end

function Utilities.Sign(Value)
	if Value > 0 then
		return 1
	elseif Value < 0 then
		return -1
	end
	return 0
end

function Utilities.Approach(Current, Target, Delta)
	if Current < Target then
		return math.min(Current + Delta, Target)
	elseif Current > Target then
		return math.max(Current - Delta, Target)
	end
	return Target
end

function Utilities.Damp(Current, Target, Lambda, DeltaTime)
	return Utilities.Lerp(Current, Target, 1 - math.exp(-Lambda * DeltaTime))
end

function Utilities.Color3ToHex(Color)
	return string.format("#%02X%02X%02X", math.floor(Color.R * 255 + 0.5), math.floor(Color.G * 255 + 0.5), math.floor(Color.B * 255 + 0.5))
end

function Utilities.HexToColor3(Hex)
	Hex = Hex:gsub("#", "")
	local Length = #Hex
	if Length == 3 then
		Hex = Hex:gsub("(.)", "%1%1")
	elseif Length == 8 then
		Hex = Hex:sub(1, 6)
	end
	local Red = tonumber(Hex:sub(1, 2), 16) or 0
	local Green = tonumber(Hex:sub(3, 4), 16) or 0
	local Blue = tonumber(Hex:sub(5, 6), 16) or 0
	return Color3.fromRGB(Red, Green, Blue)
end

function Utilities.Color3ToRGB(Color)
	return math.floor(Color.R * 255 + 0.5), math.floor(Color.G * 255 + 0.5), math.floor(Color.B * 255 + 0.5)
end

function Utilities.RGBToColor3(Red, Green, Blue)
	return Color3.fromRGB(Red, Green, Blue)
end

function Utilities.HSVToColor3(Hue, Saturation, Value)
	return Color3.fromHSV(Hue, Saturation, Value)
end

function Utilities.Color3ToHSV(Color)
	return Color3.toHSV(Color)
end

function Utilities.Lighten(Color, Amount)
	local Hue, Saturation, Value = Color3.toHSV(Color)
	return Color3.fromHSV(Hue, Saturation, Utilities.Clamp(Value + Amount, 0, 1))
end

function Utilities.Darken(Color, Amount)
	local Hue, Saturation, Value = Color3.toHSV(Color)
	return Color3.fromHSV(Hue, Saturation, Utilities.Clamp(Value - Amount, 0, 1))
end

function Utilities.Saturate(Color, Amount)
	local Hue, Saturation, Value = Color3.toHSV(Color)
	return Color3.fromHSV(Hue, Utilities.Clamp(Saturation + Amount, 0, 1), Value)
end

function Utilities.Desaturate(Color, Amount)
	local Hue, Saturation, Value = Color3.toHSV(Color)
	return Color3.fromHSV(Hue, Utilities.Clamp(Saturation - Amount, 0, 1), Value)
end

function Utilities.MixColors(First, Second, Alpha)
	return Color3.new(
		Utilities.Lerp(First.R, Second.R, Alpha),
		Utilities.Lerp(First.G, Second.G, Alpha),
		Utilities.Lerp(First.B, Second.B, Alpha)
	)
end

function Utilities.Complementary(Color)
	local Hue, Saturation, Value = Color3.toHSV(Color)
	return Color3.fromHSV((Hue + 0.5) % 1, Saturation, Value)
end

function Utilities.WithAlpha(Color, Alpha)
	return Color3.new(Color.R, Color.G, Color.B)
end

function Utilities.GenerateAccent(BaseColor)
	local Palette = {}
	Palette.Base = BaseColor
	Palette.Light = Utilities.Lighten(BaseColor, 0.18)
	Palette.Lighter = Utilities.Lighten(BaseColor, 0.34)
	Palette.Dark = Utilities.Darken(BaseColor, 0.18)
	Palette.Darker = Utilities.Darken(BaseColor, 0.34)
	Palette.Complement = Utilities.Complementary(BaseColor)
	Palette.Glow = Utilities.MixColors(BaseColor, Color3.new(1, 1, 1), 0.25)
	return Palette
end

function Utilities.ContrastColor(Background)
	local Luminance = 0.2126 * Background.R + 0.7152 * Background.G + 0.0722 * Background.B
	if Luminance > 0.5 then
		return Color3.new(0.08, 0.08, 0.1)
	else
		return Color3.new(0.96, 0.96, 0.98)
	end
end

function Utilities.UUID()
	return HttpService:GenerateGUID(false)
end

function Utilities.RandomString(Length)
	local Characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
	local Result = ""
	for _ = 1, (Length or 8) do
		local Index = math.random(1, #Characters)
		Result = Result .. Characters:sub(Index, Index)
	end
	return Result
end

function Utilities.Split(String, Separator)
	local Parts = {}
	local Pattern = string.format("([^%s]+)", Separator or " ")
	for Part in string.gmatch(String, Pattern) do
		table.insert(Parts, Part)
	end
	return Parts
end

function Utilities.Trim(String)
	return String:match("^%s*(.-)%s*$")
end

function Utilities.StartsWith(String, Prefix)
	return String:sub(1, #Prefix) == Prefix
end

function Utilities.EndsWith(String, Suffix)
	return String:sub(-#Suffix) == Suffix
end

function Utilities.Contains(String, Substring)
	return string.find(String, Substring, 1, true) ~= nil
end

function Utilities.Capitalize(String)
	return String:sub(1, 1):upper() .. String:sub(2)
end

function Utilities.TitleCase(String)
	local Result = String:gsub("(%a)([%w_']*)", function(First, Rest)
		return First:upper() .. Rest:lower()
	end)
	return Result
end

function Utilities.FormatNumber(Value)
	local Suffixes = { "", "K", "M", "B", "T" }
	local Index = 1
	local Number = Value
	while Number >= 1000 and Index < #Suffixes do
		Number = Number / 1000
		Index = Index + 1
	end
	if Index == 1 then
		return tostring(Value)
	end
	return string.format("%.2f%s", Number, Suffixes[Index])
end

function Utilities.FormatTime(Seconds)
	local Minutes = math.floor(Seconds / 60)
	local Remaining = math.floor(Seconds % 60)
	return string.format("%02d:%02d", Minutes, Remaining)
end

function Utilities.TableLength(Table)
	local Count = 0
	for _ in pairs(Table) do
		Count = Count + 1
	end
	return Count
end

function Utilities.TableKeys(Table)
	local Keys = {}
	for Key in pairs(Table) do
		table.insert(Keys, Key)
	end
	return Keys
end

function Utilities.TableValues(Table)
	local Values = {}
	for _, Value in pairs(Table) do
		table.insert(Values, Value)
	end
	return Values
end

function Utilities.TableFind(Table, Value)
	for Index, Item in pairs(Table) do
		if Item == Value then
			return Index
		end
	end
	return nil
end

function Utilities.TableContains(Table, Value)
	return Utilities.TableFind(Table, Value) ~= nil
end

function Utilities.TableFilter(Table, Predicate)
	local Result = {}
	for Index, Value in pairs(Table) do
		if Predicate(Value, Index) then
			table.insert(Result, Value)
		end
	end
	return Result
end

function Utilities.TableMap(Table, Transform)
	local Result = {}
	for Index, Value in pairs(Table) do
		Result[Index] = Transform(Value, Index)
	end
	return Result
end

function Utilities.TableReverse(Table)
	local Result = {}
	local Length = #Table
	for Index = 1, Length do
		Result[Index] = Table[Length - Index + 1]
	end
	return Result
end

function Utilities.TableFlatten(Table)
	local Result = {}
	local function Flatten(Input)
		for _, Value in ipairs(Input) do
			if type(Value) == "table" then
				Flatten(Value)
			else
				table.insert(Result, Value)
			end
		end
	end
	Flatten(Table)
	return Result
end

function Utilities.SortBy(Table, Key, Ascending)
	local Result = Utilities.ShallowCopy(Table)
	table.sort(Result, function(First, Second)
		if Ascending == false then
			return First[Key] > Second[Key]
		end
		return First[Key] < Second[Key]
	end)
	return Result
end

function Utilities.First(Table)
	return Table[1]
end

function Utilities.Last(Table)
	return Table[#Table]
end

function Utilities.GetOrCreate(Table, Key, Default)
	if Table[Key] == nil then
		Table[Key] = Default
	end
	return Table[Key]
end

function Utilities.Try(Function, ...)
	local Success, Result = pcall(Function, ...)
	if Success then
		return true, Result
	else
		return false, Result
	end
end

function Utilities.SafeCall(Function, ...)
	if type(Function) == "function" then
		local Success, Result = pcall(Function, ...)
		if not Success then
			warn("[VoidUI] Callback error:", Result)
		end
		return Success, Result
	end
	return false
end

function Utilities.Debounce(Function, Delay)
	local LastCall = 0
	Delay = Delay or 0.1
	return function(...)
		local Now = tick()
		if Now - LastCall >= Delay then
			LastCall = Now
			return Function(...)
		end
	end
end

function Utilities.Throttle(Function, Delay)
	local LastRun = 0
	local PendingArgs
	Delay = Delay or 0.1
	return function(...)
		local Now = tick()
		PendingArgs = { ... }
		if Now - LastRun >= Delay then
			LastRun = Now
			Function(unpack(PendingArgs))
		end
	end
end

function Utilities.Delay(Duration, Function)
	local Connection
	Connection = delay(Duration, function()
		if Connection then
			Connection = nil
		end
		Utilities.SafeCall(Function)
	end)
	return Connection
end

function Utilities.Spawn(Function, ...)
	task.spawn(Function, ...)
end

function Utilities.Wait(Seconds)
	task.wait(Seconds)
end

function Utilities.IsDescendantOf(Instance, Ancestor)
	local Current = Instance
	while Current do
		if Current == Ancestor then
			return true
		end
		Current = Current.Parent
	end
	return false
end

function Utilities.FindFirstChildOfClass(Parent, ClassName)
	for _, Child in ipairs(Parent:GetChildren()) do
		if Child.ClassName == ClassName then
			return Child
		end
	end
	return nil
end

function Utilities.DestroyChildren(Parent, ClassName)
	for _, Child in ipairs(Parent:GetChildren()) do
		if not ClassName or Child.ClassName == ClassName then
			Child:Destroy()
		end
	end
end

function Utilities.SetProperty(Instance, Property, Value)
	local Success = pcall(function()
		Instance[Property] = Value
	end)
	return Success
end

function Utilities.Tween(Instance, Property, Goal, Duration, EasingStyle, EasingDirection)
	local Info = TweenInfo.new(
		Duration or 0.3,
		EasingStyle or Enum.EasingStyle.Quad,
		EasingDirection or Enum.EasingDirection.Out
	)
	local Tween = TweenService:Create(Instance, Info, { [Property] = Goal })
	Tween:Play()
	return Tween
end

function Utilities.Create(Class, Properties, Children)
	local Instance = Instance.new(Class)
	if Properties then
		for Key, Value in pairs(Properties) do
			local Success = pcall(function()
				Instance[Key] = Value
			end)
			if not Success then
				warn("[VoidUI] Failed to set property", Key, "on", Class)
			end
		end
	end
	if Children then
		for _, Child in ipairs(Children) do
			if type(Child) == "table" and Child.Instance then
				Child.Instance.Parent = Instance
			elseif typeof(Child) == "Instance" then
				Child.Parent = Instance
			end
		end
	end
	return Instance
end

function Utilities.New(Class, Properties)
	return Utilities.Create(Class, Properties)
end

function Utilities.UDim2FromOffset(X, Y)
	return UDim2.fromOffset(X, Y)
end

function Utilities.UDim2FromScale(X, Y)
	return UDim2.fromScale(X, Y)
end

function Utilities.Vector2(X, Y)
	return Vector2.new(X, Y)
end

function Utilities.Color(R, G, B)
	if type(R) == "number" and G == nil then
		return Color3.fromRGB(R, R, R)
	end
	return Color3.fromRGB(R, G, B)
end

function Utilities.GetMouse()
	local Player = game:GetService("Players").LocalPlayer
	if Player then
		return Player:GetMouse()
	end
	return nil
end

function Utilities.GetViewportSize()
	local Camera = workspace.CurrentCamera
	if Camera then
		return Camera.ViewportSize
	end
	return Vector2.new(1920, 1080)
end

function Utilities.IsStudio()
	return RunService:IsStudio()
end

function Utilities.IsRunning()
	return RunService:IsRunning()
end

function Utilities.GetDeltaTime()
	return RunService:IsRunning() and game:GetService("RunService").RenderStepped:Wait() or 0
end

function Utilities.Frame(Properties)
	return Utilities.Create("Frame", Properties)
end

function Utilities.Label(Properties)
	return Utilities.Create("TextLabel", Properties)
end

function Utilities.Button(Properties)
	return Utilities.Create("TextButton", Properties)
end

function Utilities.Image(Properties)
	return Utilities.Create("ImageLabel", Properties)
end

function Utilities.Roundify(Instance, Radius)
	local Corner = Instance.new("UICorner")
	Corner.CornerRadius = UDim.new(0, Radius or 8)
	Corner.Parent = Instance
	return Corner
end

function Utilities.AddPadding(Instance, Padding)
	local UIPadding = Instance.new("UIPadding")
	UIPadding.PaddingLeft = UDim.new(0, Padding or 8)
	UIPadding.PaddingRight = UDim.new(0, Padding or 8)
	UIPadding.PaddingTop = UDim.new(0, Padding or 8)
	UIPadding.PaddingBottom = UDim.new(0, Padding or 8)
	UIPadding.Parent = Instance
	return UIPadding
end

function Utilities.AddListLayout(Instance, Direction, Padding, Align)
	local Layout = Instance.new("UIListLayout")
	Layout.FillDirection = Direction or Enum.FillDirection.Vertical
	Layout.Padding = UDim.new(0, Padding or 6)
	Layout.SortOrder = Enum.SortOrder.LayoutOrder
	Layout.HorizontalAlignment = Align or Enum.HorizontalAlignment.Left
	Layout.VerticalAlignment = Enum.VerticalAlignment.Top
	Layout.Parent = Instance
	return Layout
end

function Utilities.AddGridLayout(Instance, CellSize, CellPadding)
	local Layout = Instance.new("UIGridLayout")
	Layout.CellSize = CellSize or UDim2.fromOffset(100, 100)
	Layout.CellPadding = CellPadding or UDim2.fromOffset(6, 6)
	Layout.SortOrder = Enum.SortOrder.LayoutOrder
	Layout.Parent = Instance
	return Layout
end

function Utilities.AddStroke(Instance, Color, Thickness, Transparency)
	local Stroke = Instance.new("UIStroke")
	Stroke.Color = Color or Color3.fromRGB(255, 255, 255)
	Stroke.Thickness = Thickness or 1
	Stroke.Transparency = Transparency or 0
	Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	Stroke.Parent = Instance
	return Stroke
end

function Utilities.AddGradient(Instance, Colors, Rotation)
	local Gradient = Instance.new("UIGradient")
	Gradient.Color = Colors or ColorSequence.new(Color3.fromRGB(255, 255, 255))
	Gradient.Rotation = Rotation or 90
	Gradient.Parent = Instance
	return Gradient
end

function Utilities.AddAspectRatio(Instance, Ratio)
	local Constraint = Instance.new("UIAspectRatioConstraint")
	Constraint.AspectRatio = Ratio or 1
	Constraint.Parent = Instance
	return Constraint
end

function Utilities.AddScale(Instance, XScale, YScale)
	local Constraint = Instance.new("UIScale")
	Constraint.Scale = 1
	Constraint.Parent = Instance
	return Constraint
end

function Utilities.Bezier(Points, T)
	local N = #Points
	if N == 0 then
		return Vector2.new()
	elseif N == 1 then
		return Points[1]
	end
	local Result = Vector2.new()
	for I = 0, N - 1 do
		local Coefficient = Utilities.Binomial(N - 1, I) * (1 - T) ^ (N - 1 - I) * T ^ I
		Result = Result + Points[I + 1] * Coefficient
	end
	return Result
end

function Utilities.Binomial(N, K)
	if K > N then
		return 0
	end
	local Result = 1
	for I = 1, K do
		Result = Result * (N - K + I) / I
	end
	return Result
end

function Utilities.EaseInOutSine(T)
	return -(math.cos(math.pi * T) - 1) / 2
end

function Utilities.EaseOutBack(T)
	local C1 = 1.70158
	local C3 = C1 + 1
	return 1 + C3 * (T - 1) ^ 3 + C1 * (T - 1) ^ 2
end

function Utilities.EaseOutElastic(T)
	if T == 0 then
		return 0
	elseif T == 1 then
		return 1
	end
	local C4 = (2 * math.pi) / 3
	return 2 ^ (-10 * T) * math.sin((T * 10 - 0.75) * C4) + 1
end

function Utilities.EaseOutBounce(T)
	local N1 = 7.5625
	local D1 = 2.75
	if T < 1 / D1 then
		return N1 * T * T
	elseif T < 2 / D1 then
		T = T - 1.5 / D1
		return N1 * T * T + 0.75
	elseif T < 2.5 / D1 then
		T = T - 2.25 / D1
		return N1 * T * T + 0.9375
	else
		T = T - 2.625 / D1
		return N1 * T * T + 0.984375
	end
end

function Utilities.Smoothstep(Edge0, Edge1, X)
	local T = Utilities.Clamp((X - Edge0) / (Edge1 - Edge0), 0, 1)
	return T * T * (3 - 2 * T)
end

function Utilities.Distance(PointA, PointB)
	return (PointA - PointB).Magnitude
end

function Utilities.AngleBetween(VectorA, VectorB)
	return math.acos(math.clamp(VectorA.Unit:Dot(VectorB.Unit), -1, 1))
end

function Utilities.PointInBounds(Point, Min, Max)
	return Point.X >= Min.X and Point.X <= Max.X and Point.Y >= Min.Y and Point.Y <= Max.Y
end

function Utilities.WrapIndex(Index, Length)
	return ((Index - 1) % Length) + 1
end

function Utilities.Chunk(Table, Size)
	local Result = {}
	for Index = 1, #Table, Size do
		local Slice = {}
		for J = Index, math.min(Index + Size - 1, #Table) do
			table.insert(Slice, Table[J])
		end
		table.insert(Result, Slice)
	end
	return Result
end

function Utilities.UniqueId()
	return Utilities.RandomString(12)
end

function Utilities.EncodeJSON(Data)
	local Success, Result = pcall(function()
		return HttpService:JSONEncode(Data)
	end)
	if Success then
		return Result
	else
		warn("[VoidUI] JSON encode failed:", Result)
		return "{}"
	end
end

function Utilities.DecodeJSON(String)
	local Success, Result = pcall(function()
		return HttpService:JSONDecode(String)
	end)
	if Success then
		return Result
	else
		warn("[VoidUI] JSON decode failed:", Result)
		return {}
	end
end

function Utilities.VersionCompare(VersionA, VersionB)
	local PartsA = Utilities.Split(VersionA, ".")
	local PartsB = Utilities.Split(VersionB, ".")
	for I = 1, math.max(#PartsA, #PartsB) do
		local A = tonumber(PartsA[I]) or 0
		local B = tonumber(PartsB[I]) or 0
		if A > B then
			return 1
		elseif A < B then
			return -1
		end
	end
	return 0
end

return Utilities
