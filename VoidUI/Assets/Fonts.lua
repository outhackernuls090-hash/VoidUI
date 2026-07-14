local Fonts = {}

Fonts.Primary = Enum.Font.Gotham
Fonts.Bold = Enum.Font.GothamBold
Fonts.Semibold = Enum.Font.GothamMedium
Fonts.Medium = Enum.Font.GothamMedium
Fonts.Light = Enum.Font.Gotham
Fonts.Thin = Enum.Font.Gotham
Fonts.Mono = Enum.Font.Code
Fonts.Display = Enum.Font.GothamBold
Fonts.Rounded = Enum.Font.Gotham
Fonts.Heading = Enum.Font.GothamBold
Fonts.Body = Enum.Font.Gotham
Fonts.Caption = Enum.Font.Gotham
Fonts.Numeric = Enum.Font.GothamMedium

Fonts.Scale = {
	Display = 28,
	Title = 20,
	Header = 16,
	Subheader = 15,
	Body = 14,
	Caption = 12,
	Small = 11,
	Micro = 10,
	Tiny = 9,
}

Fonts.Weight = {
	Light = Enum.FontWeight.Light,
	Regular = Enum.FontWeight.Regular,
	Medium = Enum.FontWeight.Medium,
	Bold = Enum.FontWeight.Bold,
	Heavy = Enum.FontWeight.Heavy,
}

function Fonts.Get(Name)
	return Fonts[Name] or Fonts.Primary
end

function Fonts.Size(Name)
	return Fonts.Scale[Name] or 14
end

function Fonts.Resolve(Options)
	Options = Options or {}
	local Font = Fonts.Get(Options.Family or "Primary")
	local Size = Options.Size or Fonts.Size(Options.Scale or "Body")
	return Font, Size
end

function Fonts.Pair(Family, Scale)
	return Fonts.Get(Family), Fonts.Size(Scale)
end

Fonts.Measure = {
	Display = 1.1,
	Title = 1.2,
	Header = 1.25,
	Body = 1.35,
	Caption = 1.4,
	Small = 1.45,
}

function Fonts.LineHeight(Scale)
	return Fonts.Measure[Scale] or 1.3
end

return Fonts
