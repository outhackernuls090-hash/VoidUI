local Application = require(script.Core.Application)

local VoidUI = {}
VoidUI.__index = VoidUI

function VoidUI.new(Options)
	local self = setmetatable({}, VoidUI)
	self.Application = Application.new(Options or {})
	return self
end

function VoidUI:CreateWindow(Options)
	return self.Application:CreateWindow(Options)
end

function VoidUI:SetTheme(Name)
	return self.Application:SetTheme(Name)
end

function VoidUI:SetAccent(Color)
	return self.Application:SetAccent(Color)
end

function VoidUI:Notify(Options)
	return self.Application:Notify(Options)
end

function VoidUI:RegisterPlugin(Plugin)
	return self.Application:RegisterPlugin(Plugin)
end

function VoidUI:RunStartupSequence(Options)
	return self.Application:RunStartupSequence(Options)
end

function VoidUI:CreateCommandPalette(Options)
	return self.Application:CreateCommandPalette(Options)
end

function VoidUI:CreateContextMenu(Items)
	return self.Application:CreateContextMenu(Items)
end

function VoidUI:CreateTooltip(Text)
	return self.Application:CreateTooltip(Text)
end

function VoidUI:CreateModal(Options)
	return self.Application:CreateModal(Options)
end

function VoidUI:CreateBreadcrumbs(Items)
	return self.Application:CreateBreadcrumbs(Items)
end

function VoidUI:GetStats()
	return self.Application:GetStats()
end

function VoidUI:Destroy()
	return self.Application:Destroy()
end

return VoidUI
