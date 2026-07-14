local Utilities = require(script.Parent.Parent.Core.Utilities)

local Images = {}
Images.__index = Images

local ImageCache = {}

local BuiltIn = {
	VoidLogo = "rbxassetid://0",
	Noise = "rbxassetid://0",
	GradientMesh = "rbxassetid://0",
	Glow = "rbxassetid://0",
	Sparkle = "rbxassetid://0",
	Cursor = "rbxassetid://0",
	Avatar = "rbxassetid://0",
	Pattern = "rbxassetid://0",
}

function Images.Get(Name)
	return BuiltIn[Name]
end

function Images.Register(Name, AssetId)
	BuiltIn[Name] = AssetId
end

function Images.Create(Name, Properties)
	local AssetId = BuiltIn[Name] or Name
	local Image = Utilities.Create("ImageLabel", Utilities.Merge({
		Image = AssetId,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
	}, Properties or {}))
	return Image
end

function Images.CreateButton(Name, Properties)
	local AssetId = BuiltIn[Name] or Name
	local Image = Utilities.Create("ImageButton", Utilities.Merge({
		Image = AssetId,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
	}, Properties or {}))
	return Image
end

function Images.Cache(Name, AssetId)
	ImageCache[Name] = AssetId
end

function Images.GetCached(Name)
	return ImageCache[Name]
end

function Images.ClearCache()
	ImageCache = {}
end

function Images.Has(Name)
	return BuiltIn[Name] ~= nil
end

function Images.List()
	return Utilities.TableKeys(BuiltIn)
end

function Images.CreateRounded(Name, Radius, Properties)
	local Image = Images.Create(Name, Properties)
	local Corner = Utilities.Roundify(Image, Radius or 8)
	return Image
end

function Images.CreateGradient(Name, Colors, Rotation, Properties)
	local Image = Images.Create(Name, Properties)
	local Gradient = Utilities.AddGradient(Image, Colors, Rotation or 90)
	return Image, Gradient
end

function Images.CreateGlow(Name, Size, Color, Properties)
	local Image = Images.Create(Name, Utilities.Merge({
		ImageColor3 = Color or Color3.fromRGB(255, 255, 255),
		Size = UDim2.fromOffset(Size or 100, Size or 100),
		ImageTransparency = 0.5,
	}, Properties or {}))
	return Image
end

function Images.CreateAvatar(UserId, Properties)
	local Success, Thumbnail = pcall(function()
		return game:GetService("Players"):GetUserThumbnailAsync(UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
	end)
	local Image = Utilities.Create("ImageLabel", Utilities.Merge({
		Image = Success and Thumbnail or "",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
	}, Properties or {}))
	return Image
end

Images.BuiltIn = BuiltIn

return Images
