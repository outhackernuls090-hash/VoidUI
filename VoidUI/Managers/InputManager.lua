local Utilities = require(script.Parent.Parent.Core.Utilities)
local Events = require(script.Parent.Parent.Core.Events)
local Cleanup = require(script.Parent.Parent.Core.Cleanup)

local InputManager = {}
InputManager.__index = InputManager

function InputManager.new()
	local self = setmetatable({}, InputManager)
	self.Hotkeys = {}
	self.ContextMenus = {}
	self.Tooltips = {}
	self.KeyDown = Events.new()
	self.KeyUp = Events.new()
	self.PointerMoved = Events.new()
	self.PointerDown = Events.new()
	self.PointerUp = Events.new()
	self.Cleanup = Cleanup.new()
	self.MousePosition = Vector2.new(0, 0)
	self.PressedKeys = {}
	self:_Initialize()
	return self
end

function InputManager:_Initialize()
	local UserInputService = game:GetService("UserInputService")

	local DownConnection = UserInputService.InputBegan:Connect(function(Input, Processed)
		if Processed then
			return
		end
		self.PressedKeys[Input.KeyCode] = true
		self.KeyDown:Fire(Input, Processed)
		self:_CheckHotkeys(Input, false)
	end)
	self.Cleanup:AddConnection(DownConnection)

	local UpConnection = UserInputService.InputEnded:Connect(function(Input, Processed)
		self.PressedKeys[Input.KeyCode] = nil
		self.KeyUp:Fire(Input, Processed)
		self:_CheckHotkeys(Input, true)
	end)
	self.Cleanup:AddConnection(UpConnection)

	local MoveConnection = UserInputService.InputChanged:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseMovement then
			self.MousePosition = Input.Position
			self.PointerMoved:Fire(Input.Position)
		end
	end)
	self.Cleanup:AddConnection(MoveConnection)

	local DownPointer = UserInputService.InputBegan:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
			self.PointerDown:Fire(Input)
		end
	end)
	self.Cleanup:AddConnection(DownPointer)

	local UpPointer = UserInputService.InputEnded:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
			self.PointerUp:Fire(Input)
		end
	end)
	self.Cleanup:AddConnection(UpPointer)
end

function InputManager:BindHotkey(Name, KeyCodes, Callback, Options)
	Options = Options or {}
	local Hotkey = {
		Name = Name,
		Keys = type(KeyCodes) == "table" and KeyCodes or { KeyCodes },
		Callback = Callback,
		Modifiers = Options.Modifiers or {},
		Repeat = Options.Repeat or false,
		Enabled = true,
	}
	self.Hotkeys[Name] = Hotkey
	return Hotkey
end

function InputManager:UnbindHotkey(Name)
	self.Hotkeys[Name] = nil
end

function InputManager:EnableHotkey(Name)
	if self.Hotkeys[Name] then
		self.Hotkeys[Name].Enabled = true
	end
end

function InputManager:DisableHotkey(Name)
	if self.Hotkeys[Name] then
		self.Hotkeys[Name].Enabled = false
	end
end

function InputManager:_CheckHotkeys(Input, Released)
	for _, Hotkey in pairs(self.Hotkeys) do
		if not Hotkey.Enabled then
			continue
		end
		local Match = false
		for _, Key in ipairs(Hotkey.Keys) do
			if Key == Input.KeyCode then
				Match = true
				break
			end
		end
		if Match then
			local ModifiersOk = true
			for _, Mod in ipairs(Hotkey.Modifiers) do
				if not self.PressedKeys[Mod] then
					ModifiersOk = false
					break
				end
			end
			if ModifiersOk then
				pcall(Hotkey.Callback, Input, Released)
			end
		end
	end
end

function InputManager:IsKeyDown(KeyCode)
	return self.PressedKeys[KeyCode] == true
end

function InputManager:GetPressedKeys()
	return Utilities.ShallowCopy(self.PressedKeys)
end

function InputManager:FormatKey(KeyCode)
	local Name = tostring(KeyCode)
	return Name:gsub("Enum.KeyCode.", "")
end

function InputManager:ListenForNextKey(Callback)
	local Connection
	Connection = game:GetService("UserInputService").InputBegan:Connect(function(Input, Processed)
		if Processed then
			return
		end
		if Input.UserInputType == Enum.UserInputType.Keyboard then
			Connection:Disconnect()
			pcall(Callback, Input.KeyCode)
		end
	end)
	return Connection
end

function InputManager:RegisterContextMenu(Name, Items)
	self.ContextMenus[Name] = Items
end

function InputManager:ShowContextMenu(Name, Position)
	local Items = self.ContextMenus[Name]
	if not Items then
		return nil
	end
	return Items, Position
end

function InputManager:RegisterTooltip(Instance, Text)
	self.Tooltips[Instance] = Text
end

function InputManager:GetMousePosition()
	return self.MousePosition
end

function InputManager:SetMousePosition(Position)
	self.MousePosition = Position
end

function InputManager:IsModifierDown()
	local UserInputService = game:GetService("UserInputService")
	return UserInputService:IsKeyDown(Enum.KeyCode.LeftControl)
		or UserInputService:IsKeyDown(Enum.KeyCode.RightControl)
		or UserInputService:IsKeyDown(Enum.KeyCode.LeftShift)
		or UserInputService:IsKeyDown(Enum.KeyCode.RightShift)
end

function InputManager:GetDevice()
	local UserInputService = game:GetService("UserInputService")
	if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
		return "Touch"
	elseif UserInputService.GamepadEnabled then
		return "Gamepad"
	end
	return "Desktop"
end

function InputManager:SubscribeKeyDown(Callback)
	return self.KeyDown:Connect(Callback)
end

function InputManager:SubscribeKeyUp(Callback)
	return self.KeyUp:Connect(Callback)
end

function InputManager:SubscribePointerMoved(Callback)
	return self.PointerMoved:Connect(Callback)
end

function InputManager:Destroy()
	self.Cleanup:Destroy()
	self.Hotkeys = {}
	self.ContextMenus = {}
	self.Tooltips = {}
	self.KeyDown:DisconnectAll()
	self.KeyUp:DisconnectAll()
	self.PointerMoved:DisconnectAll()
	self.PointerDown:DisconnectAll()
	self.PointerUp:DisconnectAll()
end

return InputManager
