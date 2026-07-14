local Utilities = require(script.Parent.Parent.Core.Utilities)
local Base = require(script.Parent.Base)
local Icons = require(script.Parent.Parent.Assets.Icons)

local Modal = {}
Modal.__index = setmetatable(Modal, Base)

function Modal.new(Application, Options)
	local self = setmetatable(Base.new(Application, Application.Renderer:GetLayer("Overlays"), Options), Modal)
	self.Title = Options.Title or "Dialog"
	self.Description = Options.Description or ""
	self.Buttons = Options.Buttons or { { Label = "OK", Variant = "Primary" } }
	self.Open = false
	self:_Build()
	return self
end

function Modal:_Build()
	local Theme = self.Theme
	local Backdrop = Utilities.Create("Frame", {
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundTransparency = 0.65,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 1, 0),
		ZIndex = 250,
		Visible = false,
		Parent = self.Parent,
	})

	local Dialog = Utilities.Create("Frame", {
		BackgroundColor3 = Theme.Color("CardElevated"),
		BorderSizePixel = 0,
		Size = UDim2.new(0, 400, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		ZIndex = 251,
		Parent = Backdrop,
	})
	local DialogCorner = Utilities.Roundify(Dialog, Theme.Layout("RadiusLarge"))
	local DialogStroke = Utilities.AddStroke(Dialog, Theme.Color("Border"), 1)
	local DialogGradient = Utilities.AddGradient(Dialog, Theme.Gradient("Surface"), 90)
	DialogGradient.Transparency = NumberSequence.new(0.4)
	local DialogPadding = Utilities.AddPadding(Dialog, 20)
	local DialogLayout = Utilities.AddListLayout(Dialog, Enum.FillDirection.Vertical, 12, Enum.HorizontalAlignment.Center)

	local Title = Utilities.Create("TextLabel", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 24),
		Font = Theme.Typography("FontBold"),
		TextSize = Theme.Typography("HeaderSize"),
		TextColor3 = Theme.Color("Text"),
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = self.Title,
		ZIndex = 252,
		Parent = Dialog,
	})

	local Description = Utilities.Create("TextLabel", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Font = Theme.Typography("Font"),
		TextSize = Theme.Typography("BodySize"),
		TextColor3 = Theme.Color("TextMuted"),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextWrapped = true,
		Text = self.Description,
		ZIndex = 252,
		Parent = Dialog,
	})

	local ButtonRow = Utilities.Create("Frame", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 36),
		ZIndex = 252,
		Parent = Dialog,
	})
	local ButtonLayout = Utilities.AddListLayout(ButtonRow, Enum.FillDirection.Horizontal, 8, Enum.HorizontalAlignment.Right)
	ButtonLayout.VerticalAlignment = Enum.VerticalAlignment.Center

	for _, ButtonOption in ipairs(self.Buttons) do
		local Button = Utilities.Create("TextButton", {
			BackgroundColor3 = ButtonOption.Variant == "Danger" and Theme.Color("Danger") or (ButtonOption.Variant == "Ghost" and Theme.Color("Surface") or Theme.Color("Accent")),
			BorderSizePixel = 0,
			Size = UDim2.fromOffset(100, 36),
			AutoButtonColor = false,
			Font = Theme.Typography("FontSemibold"),
			TextSize = Theme.Typography("BodySize"),
			TextColor3 = ButtonOption.Variant == "Ghost" and Theme.Color("Text") or Theme.Color("TextInverse"),
			Text = ButtonOption.Label,
			ZIndex = 253,
			Parent = ButtonRow,
		})
		local ButtonCorner = Utilities.Roundify(Button, Theme.Layout("RadiusSmall"))
		local Click = Button.MouseButton1Click:Connect(function()
			self:Close()
			Utilities.SafeCall(ButtonOption.Callback, self)
		end)
		self.Cleanup:AddConnection(Click)
		local Enter = Button.MouseEnter:Connect(function()
			self.Animation:Animate(Button, "BackgroundColor3", ButtonOption.Variant == "Danger" and Theme.Color("Danger") or Theme.Color("AccentLight"), { Duration = 0.12 })
		end)
		local Leave = Button.MouseLeave:Connect(function()
			self.Animation:Animate(Button, "BackgroundColor3", ButtonOption.Variant == "Danger" and Theme.Color("Danger") or (ButtonOption.Variant == "Ghost" and Theme.Color("Surface") or Theme.Color("Accent")), { Duration = 0.12 })
		end)
		self.Cleanup:AddConnection(Enter)
		self.Cleanup:AddConnection(Leave)
	end

	self.Backdrop = Backdrop
	self.Dialog = Dialog
end

function Modal:Open()
	self.Open = true
	self.Backdrop.Visible = true
	self.Animation:Tween({
		Duration = 0.3,
		Easing = "BackOut",
		OnUpdate = function(_, _, Progress)
			self.Dialog.Size = UDim2.new(0, 400, 0, self.Dialog.AbsoluteSize.Y * Progress)
			self.Dialog.BackgroundTransparency = 1 - Progress
		end,
	})
end

function Modal:Close()
	self.Open = false
	self.Animation:Tween({
		Duration = 0.2,
		Easing = "QuadIn",
		OnUpdate = function(_, _, Progress)
			self.Dialog.BackgroundTransparency = Progress
		end,
		OnComplete = function()
			self.Backdrop.Visible = false
		end,
	})
end

return Modal
