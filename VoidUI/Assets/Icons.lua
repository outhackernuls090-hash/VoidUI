local Utilities = require(script.Parent.Parent.Core.Utilities)

local Icons = {}
Icons.__index = Icons

local IconLibrary = {
	Home = { { "path", { { 12, 3 }, { 4, 10 }, { 6, 10 }, { 6, 20 }, { 18, 20 }, { 18, 10 }, { 20, 10 } } } },
	Settings = {
		{ "circle", 12, 12, 3 },
		{ "path", { { 12, 4 }, { 12, 7 }, { 12, 17 }, { 12, 20 } } },
		{ "path", { { 4, 12 }, { 7, 12 }, { 17, 12 }, { 20, 12 } } },
		{ "path", { { 6, 6 }, { 8, 8 }, { 16, 16 }, { 18, 18 } } },
		{ "path", { { 18, 6 }, { 16, 8 }, { 8, 16 }, { 6, 18 } } },
	},
	Search = {
		{ "circle", 10, 10, 5 },
		{ "line", 14, 14, 20, 20, 2 },
	},
	Close = {
		{ "line", 6, 6, 18, 18, 2 },
		{ "line", 18, 6, 6, 18, 2 },
	},
	Check = { { "path", { { 5, 12 }, { 10, 17 }, { 19, 7 } } } },
	CheckCircle = { { "circle", 12, 12, 8 }, { "path", { { 8, 12 }, { 11, 15 }, { 16, 9 } } } },
	ChevronDown = { { "path", { { 6, 9 }, { 12, 15 }, { 18, 9 } } } },
	ChevronUp = { { "path", { { 6, 15 }, { 12, 9 }, { 18, 15 } } } },
	ChevronLeft = { { "path", { { 15, 6 }, { 9, 12 }, { 15, 18 } } } },
	ChevronRight = { { "path", { { 9, 6 }, { 15, 12 }, { 9, 18 } } } },
	ArrowRight = { { "path", { { 5, 12 }, { 19, 12 } } }, { "path", { { 13, 6 }, { 19, 12 }, { 13, 18 } } } },
	ArrowLeft = { { "path", { { 19, 12 }, { 5, 12 } } }, { "path", { { 11, 6 }, { 5, 12 }, { 11, 18 } } } },
	ArrowUp = { { "path", { { 12, 19 }, { 12, 5 } } }, { "path", { { 6, 11 }, { 12, 5 }, { 18, 11 } } } },
	ArrowDown = { { "path", { { 12, 5 }, { 12, 19 } } }, { "path", { { 6, 13 }, { 12, 19 }, { 18, 13 } } } },
	Plus = { { "line", 12, 5, 12, 19, 2 }, { "line", 5, 12, 19, 12, 2 } },
	Minus = { { "line", 5, 12, 19, 12, 2 } },
	Star = { { "path", { { 12, 3 }, { 14.5, 9 }, { 21, 9.5 }, { 16, 14 }, { 17.5, 21 }, { 12, 17 }, { 6.5, 21 }, { 8, 14 }, { 3, 9.5 }, { 9.5, 9 } } } },
	Heart = { { "path", { { 12, 20 }, { 4, 13 }, { 4, 7 }, { 8, 4 }, { 12, 7 }, { 16, 4 }, { 20, 7 }, { 20, 13 } } } },
	Bell = { { "path", { { 6, 9 }, { 6, 18 }, { 18, 18 }, { 18, 9 }, { 15, 9 }, { 15, 6 }, { 9, 6 }, { 9, 9 } } } },
	User = { { "circle", 12, 8, 4 }, { "path", { { 5, 20 }, { 5, 15 }, { 19, 15 }, { 19, 20 } } } },
	Users = {
		{ "circle", 9, 8, 3 },
		{ "circle", 16, 8, 3 },
		{ "path", { { 3, 20 }, { 3, 15 }, { 15, 15 }, { 15, 20 } } },
		{ "path", { { 13, 20 }, { 13, 16 }, { 21, 16 }, { 21, 20 } } },
	},
	Lock = { { "rect", 6, 11, 12, 9, 2 }, { "path", { { 9, 11 }, { 9, 8 }, { 15, 8 }, { 15, 11 } } } },
	Unlock = { { "rect", 6, 11, 12, 9, 2 }, { "path", { { 9, 11 }, { 9, 7 }, { 13, 7 } } } },
	Eye = { { "path", { { 3, 12 }, { 8, 5 }, { 16, 5 }, { 21, 12 }, { 16, 19 }, { 8, 19 } } }, { "circle", 12, 12, 3 } },
	EyeOff = { { "line", 4, 4, 20, 20, 2 }, { "path", { { 9, 9 }, { 9, 12 }, { 12, 15 } } }, { "circle", 12, 12, 3 } },
	Trash = { { "path", { { 5, 7 }, { 19, 7 } } }, { "rect", 7, 7, 10, 12, 1 }, { "path", { { 10, 7 }, { 10, 4 }, { 14, 4 }, { 14, 7 } } } },
	Edit = { { "path", { { 4, 20 }, { 4, 16 }, { 14, 6 }, { 18, 10 }, { 8, 20 } } } },
	Copy = { { "rect", 8, 8, 11, 11, 1 }, { "rect", 5, 5, 11, 11, 1 } },
	Download = { { "path", { { 12, 4 }, { 12, 15 } } }, { "path", { { 7, 11 }, { 12, 16 }, { 17, 11 } } }, { "line", 5, 20, 19, 20, 2 } },
	Upload = { { "path", { { 12, 16 }, { 12, 5 } } }, { "path", { { 7, 9 }, { 12, 4 }, { 17, 9 } } }, { "line", 5, 20, 19, 20, 2 } },
	Refresh = { { "path", { { 20, 12 }, { 20, 6 }, { 14, 6 } } }, { "path", { { 4, 12 }, { 4, 18 }, { 10, 18 } } }, { "path", { { 18, 8 }, { 20, 12 }, { 16, 12 } } } },
	Play = { { "path", { { 7, 5 }, { 7, 19 }, { 19, 12 } } } },
	Pause = { { "rect", 7, 5, 3, 14, 1 }, { "rect", 14, 5, 3, 14, 1 } },
	Stop = { { "rect", 6, 6, 12, 12, 2 } },
	Volume = { { "path", { { 4, 9 }, { 4, 15 }, { 8, 15 }, { 12, 19 }, { 12, 5 }, { 8, 9 } } }, { "path", { { 16, 9 }, { 19, 12 }, { 16, 15 } } } },
	Mute = { { "line", 4, 4, 20, 20, 2 }, { "path", { { 4, 9 }, { 4, 15 }, { 8, 15 }, { 12, 19 }, { 12, 5 }, { 8, 9 } } } },
	Info = { { "circle", 12, 12, 9 }, { "line", 12, 11, 12, 16, 2 }, { "circle", 12, 8, 1 } },
	Warning = { { "path", { { 12, 4 }, { 21, 19 }, { 3, 19 } } }, { "line", 12, 10, 12, 14, 2 }, { "circle", 12, 17, 1 } },
	Danger = { { "circle", 12, 12, 9 }, { "line", 12, 7, 12, 13, 2 }, { "circle", 12, 16, 1 } },
	Question = { { "circle", 12, 12, 9 }, { "path", { { 9, 9 }, { 12, 9 }, { 12, 12 } } }, { "circle", 12, 16, 1 } },
	Folder = { { "path", { { 4, 7 }, { 9, 7 }, { 11, 9 }, { 20, 9 }, { 20, 18 }, { 4, 18 } } } },
	File = { { "path", { { 6, 4 }, { 14, 4 }, { 18, 8 }, { 18, 20 }, { 6, 20 } } }, { "path", { { 14, 4 }, { 14, 8 }, { 18, 8 } } } },
	Image = { { "rect", 4, 5, 16, 14, 2 }, { "circle", 9, 10, 2 }, { "path", { { 5, 17 }, { 10, 12 }, { 14, 16 }, { 19, 11 }, { 19, 17 } } } },
	Video = { { "rect", 3, 6, 13, 12, 2 }, { "path", { { 16, 10 }, { 21, 7 }, { 21, 17 }, { 16, 14 } } } },
	Music = { { "path", { { 9, 18 }, { 9, 5 }, { 18, 3 }, { 18, 16 } } }, { "circle", 7, 18, 2 }, { "circle", 16, 16, 2 } },
	Calendar = { { "rect", 4, 5, 16, 15, 2 }, { "line", 4, 9, 20, 9, 1 }, { "line", 8, 3, 8, 7, 1 }, { "line", 16, 3, 16, 7, 1 } },
	Clock = { { "circle", 12, 12, 9 }, { "line", 12, 12, 12, 7, 2 }, { "line", 12, 12, 16, 14, 2 } },
	Grid = { { "rect", 4, 4, 7, 7, 1 }, { "rect", 13, 4, 7, 7, 1 }, { "rect", 4, 13, 7, 7, 1 }, { "rect", 13, 13, 7, 7, 1 } },
	List = { { "line", 8, 7, 20, 7, 2 }, { "line", 8, 12, 20, 12, 2 }, { "line", 8, 17, 20, 17, 2 }, { "circle", 4, 7, 1 }, { "circle", 4, 12, 1 }, { "circle", 4, 17, 1 } },
	Menu = { { "line", 4, 7, 20, 7, 2 }, { "line", 4, 12, 20, 12, 2 }, { "line", 4, 17, 20, 17, 2 } },
	Link = { { "path", { { 9, 15 }, { 9, 9 }, { 15, 9 } } }, { "path", { { 15, 9 }, { 15, 15 }, { 9, 15 } } }, { "line", 7, 17, 5, 15, 2 }, { "line", 17, 7, 19, 9, 2 } },
	Tag = { { "path", { { 4, 4 }, { 14, 4 }, { 20, 10 }, { 20, 20 }, { 4, 20 } } }, { "circle", 9, 12, 2 } },
	Bookmark = { { "path", { { 6, 4 }, { 18, 4 }, { 18, 20 }, { 12, 16 }, { 6, 20 } } } },
	Flag = { { "line", 6, 4, 6, 20, 2 }, { "path", { { 6, 5 }, { 18, 5 }, { 15, 10 }, { 18, 15 }, { 6, 15 } } } },
	Target = { { "circle", 12, 12, 9 }, { "circle", 12, 12, 5 }, { "circle", 12, 12, 1 } },
	Zap = { { "path", { { 13, 3 }, { 5, 13 }, { 11, 13 }, { 11, 21 }, { 19, 11 }, { 13, 11 } } } },
	Shield = { { "path", { { 12, 3 }, { 20, 6 }, { 20, 12 }, { 12, 21 }, { 4, 12 }, { 4, 6 } } } },
	Key = { { "circle", 8, 12, 4 }, { "line", 11, 12, 20, 12, 2 }, { "line", 17, 12, 17, 16, 2 }, { "line", 20, 12, 20, 15, 2 } },
	Wrench = { { "path", { { 15, 6 }, { 18, 9 }, { 14, 13 }, { 16, 15 }, { 12, 19 }, { 9, 16 }, { 13, 12 }, { 11, 10 } } } },
	Gear = {
		{ "circle", 12, 12, 3 },
		{ "path", { { 12, 3 }, { 12, 6 } } },
		{ "path", { { 12, 18 }, { 12, 21 } } },
		{ "path", { { 3, 12 }, { 6, 12 } } },
		{ "path", { { 18, 12 }, { 21, 12 } } },
		{ "path", { { 5.5, 5.5 }, { 7.5, 7.5 } } },
		{ "path", { { 16.5, 16.5 }, { 18.5, 18.5 } } },
		{ "path", { { 5.5, 18.5 }, { 7.5, 16.5 } } },
		{ "path", { { 16.5, 7.5 }, { 18.5, 5.5 } } },
	},
	Sun = { { "circle", 12, 12, 4 }, { "line", 12, 3, 12, 6, 2 }, { "line", 12, 18, 12, 21, 2 }, { "line", 3, 12, 6, 12, 2 }, { "line", 18, 12, 21, 12, 2 }, { "line", 5.5, 5.5, 7.5, 7.5, 2 }, { "line", 16.5, 16.5, 18.5, 18.5, 2 }, { "line", 5.5, 18.5, 7.5, 16.5, 2 }, { "line", 16.5, 7.5, 18.5, 5.5, 2 } },
	Moon = { { "path", { { 16, 14 }, { 11, 14 }, { 11, 4 }, { 13, 6 }, { 15, 6 }, { 16, 8 }, { 16, 14 } } } },
	Cloud = { { "path", { { 7, 18 }, { 7, 14 }, { 5, 14 }, { 5, 18 }, { 7, 18 } } }, { "path", { { 8, 18 }, { 8, 13 }, { 12, 13 }, { 12, 18 } } }, { "path", { { 13, 18 }, { 13, 15 }, { 17, 15 }, { 17, 18 } } } },
	Mail = { { "rect", 3, 5, 18, 14, 2 }, { "path", { { 4, 7 }, { 12, 13 }, { 20, 7 } } } },
	Phone = { { "path", { { 7, 4 }, { 9, 4 }, { 10, 8 }, { 8, 9 }, { 9, 12 }, { 12, 9 }, { 13, 11 }, { 13, 13 }, { 9, 20 }, { 7, 20 }, { 7, 17 } } } },
	Globe = { { "circle", 12, 12, 9 }, { "line", 3, 12, 21, 12, 1 }, { "path", { { 12, 3 }, { 12, 21 } } }, { "path", { { 6, 6 }, { 18, 18 } } }, { "path", { { 18, 6 }, { 6, 18 } } } },
	Code = { { "path", { { 9, 8 }, { 5, 12 }, { 9, 16 } } }, { "path", { { 15, 8 }, { 19, 12 }, { 15, 16 } } } },
	Terminal = { { "rect", 3, 4, 18, 16, 2 }, { "path", { { 7, 9 }, { 11, 12 }, { 7, 15 } } }, { "line", 13, 15, 17, 15, 2 } },
	Database = { { "ellipse", 12, 6, 8, 3 }, { "path", { { 4, 6 }, { 4, 12 }, { 20, 12 }, { 20, 6 } } }, { "path", { { 4, 12 }, { 4, 18 }, { 20, 18 }, { 20, 12 } } } },
	Server = { { "rect", 4, 4, 16, 7, 2 }, { "rect", 4, 13, 16, 7, 2 }, { "circle", 8, 7, 1 }, { "circle", 8, 16, 1 } },
	CPU = { { "rect", 7, 7, 10, 10, 1 }, { "rect", 10, 10, 4, 4, 1 }, { "line", 9, 4, 9, 7, 1 }, { "line", 15, 4, 15, 7, 1 }, { "line", 9, 17, 9, 20, 1 }, { "line", 15, 17, 15, 20, 1 }, { "line", 4, 9, 7, 9, 1 }, { "line", 4, 15, 7, 15, 1 }, { "line", 17, 9, 20, 9, 1 }, { "line", 17, 15, 20, 15, 1 } },
	Chart = { { "line", 4, 20, 20, 20, 1 }, { "line", 4, 20, 4, 4, 1 }, { "path", { { 7, 16 }, { 11, 10 }, { 15, 13 }, { 19, 6 } } } },
	ChartBar = { { "line", 4, 20, 20, 20, 1 }, { "rect", 6, 12, 3, 8, 0 }, { "rect", 11, 8, 3, 12, 0 }, { "rect", 16, 14, 3, 6, 0 } },
	ChartPie = { { "circle", 12, 12, 9 }, { "path", { { 12, 12 }, { 12, 3 }, { 19, 8 } } }, { "path", { { 12, 12 }, { 19, 8 }, { 19, 12 } } } },
	Layers = { { "path", { { 12, 3 }, { 21, 8 }, { 12, 13 }, { 3, 8 } } }, { "path", { { 3, 13 }, { 12, 18 }, { 21, 13 } } } },
	Package = { { "path", { { 12, 3 }, { 21, 8 }, { 12, 13 }, { 3, 8 } } }, { "path", { { 3, 8 }, { 3, 16 }, { 12, 21 }, { 21, 16 }, { 21, 8 } } }, { "line", 12, 13, 12, 21, 1 } },
	Box = { { "path", { { 12, 3 }, { 20, 7 }, { 20, 17 }, { 12, 21 }, { 4, 17 }, { 4, 7 } } }, { "path", { { 4, 7 }, { 12, 11 }, { 20, 7 } } }, { "line", 12, 11, 12, 21, 1 } },
	Compass = { { "circle", 12, 12, 9 }, { "path", { { 15, 9 }, { 13, 13 }, { 9, 15 }, { 11, 11 } } } },
	Map = { { "path", { { 4, 6 }, { 9, 4 }, { 15, 6 }, { 20, 4 }, { 20, 18 }, { 15, 20 }, { 9, 18 }, { 4, 20 } } }, { "line", 9, 4, 9, 18, 1 }, { "line", 15, 6, 15, 20, 1 } },
	Camera = { { "rect", 3, 7, 18, 13, 2 }, { "circle", 12, 13, 3 }, { "path", { { 8, 7 }, { 10, 4 }, { 14, 4 }, { 16, 7 } } } },
	Mic = { { "rect", 9, 3, 6, 11, 3 }, { "path", { { 6, 11 }, { 6, 14 }, { 18, 14 }, { 18, 11 } } }, { "line", 12, 14, 12, 20, 2 }, { "line", 8, 20, 16, 20, 2 } },
	Send = { { "path", { { 4, 12 }, { 20, 4 }, { 13, 20 }, { 11, 13 } } } },
	Filter = { { "path", { { 4, 5 }, { 20, 5 }, { 14, 12 }, { 14, 19 }, { 10, 17 }, { 10, 12 } } } },
	BookmarkPlus = { { "path", { { 6, 4 }, { 18, 4 }, { 18, 20 }, { 12, 16 }, { 6, 20 } } }, { "line", 12, 8, 12, 13, 2 }, { "line", 9, 10, 15, 10, 2 } },
	Sparkle = { { "path", { { 12, 3 }, { 14, 10 }, { 21, 12 }, { 14, 14 }, { 12, 21 }, { 10, 14 }, { 3, 12 }, { 10, 10 } } } },
	Void = { { "circle", 12, 12, 8 }, { "circle", 12, 12, 4 }, { "circle", 12, 12, 1 } },
	Sword = { { "path", { { 14, 4 }, { 20, 4 }, { 20, 10 }, { 8, 22 }, { 4, 22 }, { 4, 18 }, { 14, 4 } } }, { "line", 4, 18, 8, 22, 2 } },
	ShieldPlus = { { "path", { { 12, 3 }, { 20, 6 }, { 20, 12 }, { 12, 21 }, { 4, 12 }, { 4, 6 } } }, { "line", 12, 9, 12, 15, 2 }, { "line", 9, 12, 15, 12, 2 } },
	Flame = { { "path", { { 12, 3 }, { 9, 9 }, { 14, 11 }, { 10, 14 }, { 12, 21 }, { 18, 14 }, { 15, 9 }, { 17, 7 }, { 12, 3 } } } },
	Droplet = { { "path", { { 12, 3 }, { 19, 13 }, { 12, 21 }, { 5, 13 } } } },
	Activity = { { "path", { { 3, 12 }, { 8, 12 }, { 11, 5 }, { 15, 19 }, { 18, 12 }, { 21, 12 } } } },
	Gauge = { { "path", { { 4, 18 }, { 12, 4 }, { 20, 18 } } }, { "circle", 12, 18, 2 }, { "line", 12, 18, 16, 12, 2 } },
	Command = { { "rect", 6, 6, 12, 12, 2 }, { "rect", 9, 9, 6, 6, 1 }, { "line", 12, 4, 12, 9, 2 }, { "line", 12, 15, 12, 20, 2 }, { "line", 4, 12, 9, 12, 2 }, { "line", 15, 12, 20, 12, 2 } },
	Power = { { "path", { { 12, 4 }, { 12, 12 } } }, { "path", { { 7, 7 }, { 17, 7 }, { 20, 12 }, { 12, 21 }, { 4, 12 }, { 7, 7 } } } },
	Wifi = { { "path", { { 5, 12 }, { 8, 15 } } }, { "path", { { 16, 12 }, { 19, 15 } } }, { "path", { { 3, 9 }, { 7, 13 } } }, { "path", { { 17, 9 }, { 21, 13 } } }, { "circle", 12, 17, 1 } },
	Bug = { { "rect", 8, 8, 8, 11, 3 }, { "path", { { 12, 8 }, { 12, 4 } } }, { "path", { { 8, 11 }, { 4, 11 } } }, { "path", { { 16, 11 }, { 20, 11 } } }, { "path", { { 8, 16 }, { 4, 18 } } }, { "path", { { 16, 16 }, { 20, 18 } } }, { "circle", 10, 13, 1 }, { "circle", 14, 13, 1 } },
	Rocket = { { "path", { { 12, 3 }, { 16, 8 }, { 16, 14 }, { 8, 14 }, { 8, 8 } } }, { "circle", 12, 9, 2 }, { "path", { { 8, 14 }, { 5, 18 }, { 8, 18 } } }, { "path", { { 16, 14 }, { 19, 18 }, { 16, 18 } } }, { "line", 12, 14, 12, 20, 2 } },
	Bot = { { "rect", 6, 9, 12, 11, 3 }, { "circle", 12, 6, 3 }, { "circle", 9, 14, 1 }, { "circle", 15, 14, 1 }, { "line", 12, 3, 12, 6, 2 } },
	Brain = { { "path", { { 9, 5 }, { 9, 9 }, { 6, 9 }, { 6, 13 }, { 9, 13 }, { 9, 19 }, { 15, 19 }, { 15, 15 }, { 18, 15 }, { 18, 9 }, { 15, 9 }, { 15, 5 } } }, { "line", 12, 5, 12, 19, 1 } },
	Palette = { { "path", { { 12, 3 }, { 20, 9 }, { 18, 18 }, { 6, 18 }, { 4, 9 } } }, { "circle", 9, 11, 1 }, { "circle", 12, 9, 1 }, { "circle", 15, 11, 1 }, { "circle", 11, 14, 1 }, { "circle", 14, 14, 1 } },
	Magic = { { "path", { { 6, 18 }, { 6, 14 }, { 10, 14 } } }, { "path", { { 14, 4 }, { 20, 10 }, { 16, 14 }, { 10, 8 } } }, { "path", { { 16, 4 }, { 18, 6 } } }, { "path", { { 19, 9 }, { 21, 11 } } } },
}

local function CreateIconFrame(Size)
	local Frame = Utilities.Create("Frame", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(Size, Size),
	})
	return Frame
end

local function DrawLine(Container, X1, Y1, X2, Y2, Thickness, Color)
	local Length = math.sqrt((X2 - X1) ^ 2 + (Y2 - Y1) ^ 2)
	local Angle = math.atan2(Y2 - Y1, X2 - X1)
	local Line = Utilities.Create("Frame", {
		BackgroundColor3 = Color,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale((X1 + X2) / 24, (Y1 + Y2) / 24),
		Size = UDim2.new(0, Length, 0, Thickness),
		Rotation = math.deg(Angle),
		Parent = Container,
	})
	local Corner = Utilities.Roundify(Line, Thickness / 2)
	return Line
end

local function DrawCircle(Container, CX, CY, Radius, Color, Filled)
	local Circle = Utilities.Create("Frame", {
		BackgroundColor3 = Color,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(CX / 24, CY / 24),
		Size = UDim2.fromScale(Radius * 2 / 24, Radius * 2 / 24),
		Parent = Container,
	})
	local Corner = Utilities.Roundify(Circle, 999)
	if not Filled then
		Circle.BackgroundTransparency = 1
		local Stroke = Utilities.AddStroke(Circle, Color, 2)
	end
	return Circle
end

local function DrawEllipse(Container, CX, CY, RX, RY, Color)
	local Ellipse = Utilities.Create("Frame", {
		BackgroundColor3 = Color,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(CX / 24, CY / 24),
		Size = UDim2.fromScale(RX * 2 / 24, RY * 2 / 24),
		Parent = Container,
	})
	local Corner = Utilities.Roundify(Ellipse, 999)
	return Ellipse
end

local function DrawRect(Container, X, Y, W, H, Radius, Color, Filled)
	local Rect = Utilities.Create("Frame", {
		BackgroundColor3 = Color,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0, 0),
		Position = UDim2.fromScale(X / 24, Y / 24),
		Size = UDim2.fromScale(W / 24, H / 24),
		Parent = Container,
	})
	local Corner = Utilities.Roundify(Rect, Radius)
	if not Filled then
		Rect.BackgroundTransparency = 1
		local Stroke = Utilities.AddStroke(Rect, Color, 2)
	end
	return Rect
end

local function DrawPath(Container, Points, Color, Thickness, Closed)
	local Count = #Points
	if Count < 2 then
		return
	end
	for I = 1, Count - 1 do
		local P1 = Points[I]
		local P2 = Points[I + 1]
		DrawLine(Container, P1[1], P1[2], P2[1], P2[2], Thickness or 2, Color)
	end
	if Closed then
		local First = Points[1]
		local Last = Points[Count]
		DrawLine(Container, Last[1], Last[2], First[1], First[2], Thickness or 2, Color)
	end
end

function Icons.Create(Name, Color, Size)
	Size = Size or 20
	Color = Color or Color3.fromRGB(255, 255, 255)
	local Frame = CreateIconFrame(Size)
	local Spec = IconLibrary[Name]
	if not Spec then
		Spec = IconLibrary.Void
	end
	for _, Shape in ipairs(Spec) do
		local Kind = Shape[1]
		if Kind == "line" then
			DrawLine(Frame, Shape[2], Shape[3], Shape[4], Shape[5], Shape[6] or 2, Color)
		elseif Kind == "circle" then
			DrawCircle(Frame, Shape[2], Shape[3], Shape[4], Color, false)
		elseif Kind == "ellipse" then
			DrawEllipse(Frame, Shape[2], Shape[3], Shape[4], Shape[5], Color)
		elseif Kind == "rect" then
			DrawRect(Frame, Shape[2], Shape[3], Shape[4], Shape[5], Shape[6] or 1, Color, false)
		elseif Kind == "path" then
			DrawPath(Frame, Shape[2], Color, 2, false)
		end
	end
	Frame.Name = "Icon_" .. Name
	return Frame
end

function Icons.Exists(Name)
	return IconLibrary[Name] ~= nil
end

function Icons.GetNames()
	return Utilities.TableKeys(IconLibrary)
end

function Icons.Register(Name, Spec)
	IconLibrary[Name] = Spec
end

function Icons.Count()
	return Utilities.TableLength(IconLibrary)
end

Icons.Library = IconLibrary

return Icons
