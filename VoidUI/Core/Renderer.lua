local Utilities = require(script.Parent.Utilities)
local Cleanup = require(script.Parent.Cleanup)
local Events = require(script.Parent.Events)
local Glow = require(script.Parent.Parent.Animations.Glow)
local Blur = require(script.Parent.Parent.Animations.Blur)
local Particles = require(script.Parent.Parent.Animations.Particles)

local Renderer = {}
Renderer.__index = Renderer

function Renderer.new(Theme, Animation)
	local self = setmetatable({}, Renderer)
	self.Theme = Theme
	self.Animation = Animation
	self.Screen = nil
	self.Layers = {}
	self.Cleanup = Cleanup.new()
	self.Updated = Events.new()
	self.Glows = {}
	self.Blurs = {}
	self.ParticleSystems = {}
	self.CursorLight = nil
	self._Initialize()
	return self
end

function Renderer:_Initialize()
	local Player = game:GetService("Players").LocalPlayer
	local PlayerGui = Player and Player:WaitForChild("PlayerGui")
	local Screen = Utilities.Create("ScreenGui", {
		Name = "VoidUI",
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		DisplayOrder = 1000,
		IgnoreGuiInset = true,
	})
	if PlayerGui then
		Screen.Parent = PlayerGui
	else
		Screen.Parent = game:GetService("CoreGui")
	end
	self.Screen = Screen
	self.Cleanup:AddInstance(Screen)

	self.Layers.Background = self:_CreateLayer("Background", 1)
	self.Layers.Windows = self:_CreateLayer("Windows", 2)
	self.Layers.Overlays = self:_CreateLayer("Overlays", 3)
	self.Layers.Notifications = self:_CreateLayer("Notifications", 4)
	self.Layers.Cursor = self:_CreateLayer("Cursor", 5)
	self.Layers.Splash = self:_CreateLayer("Splash", 6)

	self:_BuildCursorLight()
end

function Renderer:_CreateLayer(Name, ZIndex)
	local Layer = Utilities.Create("Frame", {
		Name = Name,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 1, 0),
		ZIndex = ZIndex,
		Parent = self.Screen,
	})
	return Layer
end

function Renderer:_BuildCursorLight()
	if not self.Theme.Effect("CursorLightEnabled") then
		return
	end
	local Light = Utilities.Create("Frame", {
		Name = "CursorLight",
		BackgroundColor3 = self.Theme.Color("Accent"),
		BackgroundTransparency = 0.85,
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(220, 220),
		AnchorPoint = Vector2.new(0.5, 0.5),
		ZIndex = 0,
		Parent = self.Layers.Cursor,
	})
	local Corner = Utilities.Roundify(Light, 999)
	local Gradient = Utilities.AddGradient(Light, ColorSequence.new({
		ColorSequenceKeypoint.new(0, self.Theme.Color("AccentGlow")),
		ColorSequenceKeypoint.new(1, Color3.new(0, 0, 0)),
	}), 0)
	Gradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.6),
		NumberSequenceKeypoint.new(1, 1),
	})
	self.CursorLight = Light

	local UserInputService = game:GetService("UserInputService")
	local Connection = UserInputService.InputChanged:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseMovement then
			Light.Position = UDim2.fromOffset(Input.Position.X, Input.Position.Y)
		end
	end)
	self.Cleanup:AddConnection(Connection)
end

function Renderer:CreateCard(Properties, Layer)
	local Theme = self.Theme
	local Card = Utilities.Create("Frame", Utilities.Merge({
		BackgroundColor3 = Theme.Color("Card"),
		BorderSizePixel = 0,
	}, Properties or {}))
	local Corner = Utilities.Roundify(Card, Theme.Layout("Radius"))
	local Stroke = Utilities.AddStroke(Card, Theme.Color("Border"), Theme.Layout("BorderThickness"))
	if Theme.Effect("GlowEnabled") then
		local GlowEffect = self.Animation:Glow(Card, {
			Color = Theme.Color("AccentGlow"),
			Intensity = 0,
		})
		self.Glows[Card] = GlowEffect
	end
	local LayerFrame = Layer and self.Layers[Layer] or self.Layers.Windows
	Card.Parent = LayerFrame
	return Card
end

function Renderer:CreateShadow(Frame, Intensity)
	local Theme = self.Theme
	if not Theme.Effect("ShadowEnabled") then
		return nil
	end
	local Shadow = Utilities.Create("ImageLabel", {
		Name = "Shadow",
		BackgroundColor3 = Theme.Color("Shadow"),
		BackgroundTransparency = 1 - (Intensity or Theme.Layout("ShadowOpacity")),
		BorderSizePixel = 0,
		Size = UDim2.new(1, Theme.Layout("ShadowBlur"), 1, Theme.Layout("ShadowBlur")),
		Position = UDim2.fromOffset(-Theme.Layout("ShadowBlur") / 2, -Theme.Layout("ShadowBlur") / 2),
		ZIndex = Frame.ZIndex - 1,
		Image = "rbxassetid://0",
		ImageTransparency = 1,
		Parent = Frame,
	})
	local Corner = Utilities.Roundify(Shadow, Theme.Layout("Radius") + Theme.Layout("ShadowBlur") / 2)
	return Shadow
end

function Renderer:CreateBlur(Parent)
	local BlurEffect = self.Animation:Blur()
	BlurEffect:Create(Parent or game:GetService("Lighting"))
	table.insert(self.Blurs, BlurEffect)
	return BlurEffect
end

function Renderer:CreateParticles(Container)
	local ParticleSystem = self.Animation:Particles(Container)
	table.insert(self.ParticleSystems, ParticleSystem)
	return ParticleSystem
end

function Renderer:SetGlow(Frame, Intensity)
	local GlowEffect = self.Glows[Frame]
	if GlowEffect then
		GlowEffect:SetIntensity(Intensity)
	end
end

function Renderer:ShowGlow(Frame, Intensity)
	local GlowEffect = self.Glows[Frame]
	if GlowEffect then
		GlowEffect:Show(Intensity)
	end
end

function Renderer:HideGlow(Frame)
	local GlowEffect = self.Glows[Frame]
	if GlowEffect then
		GlowEffect:Hide()
	end
end

function Renderer:ApplyTheme(Theme)
	self.Theme = Theme
end

function Renderer:GetLayer(Name)
	return self.Layers[Name]
end

function Renderer:SetDisplayOrder(Order)
	self.Screen.DisplayOrder = Order
end

function Renderer:SetIgnoreGuiInset(Ignore)
	self.Screen.IgnoreGuiInset = Ignore
end

function Renderer:Flash(Frame, Color)
	local Original = Frame.BackgroundColor3
	self.Animation:Animate(Frame, "BackgroundColor3", Color or self.Theme.Color("Accent"), {
		Duration = 0.15,
		Easing = "QuadOut",
	})
	task.delay(0.15, function()
		self.Animation:Animate(Frame, "BackgroundColor3", Original, {
			Duration = 0.3,
			Easing = "QuadOut",
		})
	end)
end

function Renderer:Pulse(Frame, Scale)
	Scale = Scale or 1.05
	local Original = Frame.Size
	self.Animation:Tween({
		Duration = 0.12,
		Easing = "BackOut",
		OnUpdate = function(_, _, Progress)
			local S = Utilities.Lerp(1, Scale, Progress)
			Frame.Size = UDim2.new(Original.X.Scale * S, Original.X.Offset * S, Original.Y.Scale * S, Original.Y.Offset * S)
		end,
	})
	task.delay(0.12, function()
		self.Animation:Tween({
			Duration = 0.2,
			Easing = "BackOut",
			OnUpdate = function(_, _, Progress)
				local S = Utilities.Lerp(Scale, 1, Progress)
				Frame.Size = UDim2.new(Original.X.Scale * S, Original.X.Offset * S, Original.Y.Scale * S, Original.Y.Offset * S)
			end,
		})
	end)
end

function Renderer:Destroy()
	for _, GlowEffect in pairs(self.Glows) do
		GlowEffect:Destroy()
	end
	self.Glows = {}
	for _, BlurEffect in ipairs(self.Blurs) do
		BlurEffect:Destroy()
	end
	self.Blurs = {}
	for _, ParticleSystem in ipairs(self.ParticleSystems) do
		ParticleSystem:Destroy()
	end
	self.ParticleSystems = {}
	self.Cleanup:Destroy()
	self.Updated:DisconnectAll()
end

return Renderer
