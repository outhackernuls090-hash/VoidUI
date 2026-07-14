<div align="center">

# ◈ VoidUI

**A futuristic, premium, single-file Roblox/Luau GUI framework — dark graphite surfaces, glowing borders, generous rounded corners, and a real theming engine.**

[![Version](https://img.shields.io/badge/version-4.0.0-7CA2FF)](https://github.com/outhackernuls090-hash/VoidUI)
[![Lua](https://img.shields.io/badge/language-Luau%20%2F%20Lua-7CA2FF)](https://luau.org)
[![Platform](https://img.shields.io/badge/platform-Roblox%20Executors-7CA2FF)](https://roblox.com)
[![Themes](https://img.shields.io/badge/themes-10%20built--in-7CA2FF)](https://github.com/outhackernuls090-hash/VoidUI)

*One file. No dependencies. No assets. Works in every major executor.*

</div>

---

## ✨ What is VoidUI?

VoidUI is a **single, self-contained Lua file** you can drop straight into a `loadstring` call — exactly like the popular executor libraries. It bundles a robust instance builder (`Forge.Make`), a declarative theming system (`Skin` + `Forge.Resolve`), crash-proof callbacks (`Guard`), and `cloneref`/`gethui`/`protectgui` executor compatibility into one tidy package.

Unlike the previous multi-file version, **everything now lives in `VoidUI.lua`** — no folder tree, no build step, no `require` rewriting. Just one file that works 100%.

## 📚 Contents

- [Why VoidUI?](#why-voidui)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [The Public API](#the-public-api)
- [Themes](#themes)
- [Widgets](#widgets)
- [License](#license)

## 🚀 Why VoidUI?

| Feature | Detail |
| --- | --- |
| **One file** | No module tree, no `build_bundle.py`, no `require` rewriting. Host `VoidUI.lua` anywhere and `loadstring` it. |
| **10 built-in themes** | Default, Midnight, Nebula, Crimson, Emerald, Amber, Ocean, Rose, Frost, Mono — plus live accent recoloring. |
| **Crash-proof callbacks** | Every user callback is wrapped in `pcall` (`Guard`), so a bug in your code never takes down the UI. |
| **Asset-free icons** | Icons render as Unicode glyphs — no `rbxassetid`, no network fetch, works everywhere. |
| **Real popups** | Dropdowns and color pickers open floating popups in an overlay layer (full HSV color picker). |
| **Window extras** | Draggable, resizable (corner handle), minimizable, maximizable, and a tab search box. |
| **Auto-dismissing notifications** | Toasts stack and fade out on their own. |
| **Executor-agnostic** | Uses `cloneref`/`gethui`/`protectgui` and a forgiving `Enum` proxy so missing members never throw. |

## 📦 Installation

Host `VoidUI.lua` somewhere reachable over HTTP (GitHub raw, a paste service, your own CDN) and load it in one line:

```lua
local VoidUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/outhackernuls090-hash/VoidUI/refs/heads/main/VoidUI.lua"))()

local UI = VoidUI.new({ Name = "My UI", Theme = "Midnight" })
UI:SetAccent(Color3.fromRGB(120, 180, 255))

local Window = UI:CreateWindow({ Title = "VoidUI", Icon = "Home" })
local Tab = Window:CreateTab({ Title = "Combat", Icon = "Sword" })
Tab:CreateToggle({ Title = "Aimbot", Default = false, Callback = function(v) print(v) end })
```

The loader is environment-agnostic: it works in Synapse X, Script-Ware, KRNL, Fluxus, and any executor that exposes `game`/`HttpGet`.

## ⚡ Quick Start

```lua
local VoidUI = loadstring(game:HttpGet(".../VoidUI.lua"))()

local UI = VoidUI.new({
	Name = "My UI",
	Theme = "Midnight",       -- optional; defaults to "Default"
	Accent = Color3.fromRGB(120, 180, 255),
})

local Window = UI:CreateWindow({
	Title = "VoidUI",
	Icon = "Home",
	Size = UDim2.fromOffset(560, 420),
	Position = UDim2.fromScale(0.5, 0.5),
})

local Combat = Window:CreateTab({ Title = "Combat", Icon = "Sword" })

Combat:CreateSection({ Title = "Aimbot" })

Combat:CreateToggle({
	Title = "Enable Aimbot",
	Default = false,
	Callback = function(Value) print("Aimbot:", Value) end,
})

Combat:CreateSlider({
	Title = "FOV",
	Min = 10, Max = 120, Default = 60,
	Callback = function(Value) print("FOV:", Value) end,
})

Combat:CreateDropdown({
	Title = "Target Priority",
	Options = { "Closest", "Lowest Health", "Crosshair" },
	Default = "Closest",
	Callback = function(Value) print("Priority:", Value) end,
})

Window:Notify({ Title = "Loaded", Description = "Welcome to the future.", Type = "Success" })
```

See `Examples/Example.lua` for a fuller tour.

## 🧩 The Public API

Everything below is callable on the object returned by `VoidUI.new(...)`.

### Library-level

| Function | What it does |
| --- | --- |
| `VoidUI.new(Options)` | Creates the root UI instance. `Options` accepts `Name`, `Theme`, `Accent`. |
| `:CreateWindow(Options)` | Opens a new window and returns it. |
| `:SetTheme(Name)` | Switches the active theme and re-skins every open window. |
| `:SetAccent(Color)` | Recolors the entire UI with a new `Color3` accent, live. |
| `:Notify(Options)` | Pushes a toast notification. `Options`: `Title`, `Description`, `Type` (`Success`/`Warning`/`Error`/`Info`), `Duration`. |
| `:GetStats()` | Returns a table with window count, theme name, and version. |
| `:OnThemeChange` | Assign a function to be called whenever the theme changes. |

### Window API

Returned by `:CreateWindow(...)`.

| Function | What it does |
| --- | --- |
| `:CreateTab(Options)` | Adds a sidebar tab (`Title`, `Icon`) and returns it. The first tab is selected automatically. |
| `:SelectTab(Tab)` | Switches focus to a given tab. |
| `:ToggleMinimize()` | Collapse to the header or bring it back. |
| `:ToggleMaximize()` | Snap to (almost) fullscreen and back. |
| `:Close()` | Hides the window. |
| `:Notify(Options)` | Pushes a notification into this window's notification layer. |

### Tab API (the widget factory)

Returned by `:CreateTab(...)`. Every `Create*` returns the widget instance so you can keep a reference and call its methods (`:Set`, `:Get`, `:Instance`).

**Layout & text**
- `:CreateSection({ Title })` — a titled separator with an accent rule.
- `:CreateDivider()` — a thin separator line.
- `:CreateLabel({ Title })` — a static text line.
- `:CreateParagraph({ Title, Content })` — a heading plus body text block.

**Inputs**
- `:CreateButton({ Title, Callback })` — accent-filled action button.
- `:CreateToggle({ Title, Default, Description, Callback })` — on/off switch; returns `:Get()` / `:Set(v)`.
- `:CreateSlider({ Title, Min, Max, Default, Decimal, Callback })` — numeric dragger; returns `:Get()` / `:Set(v)`.
- `:CreateTextbox({ Title, Default, Placeholder, Callback })` — text entry; returns `:Get()` / `:Set(v)`.
- `:CreateDropdown({ Title, Options, Default, Multi, Callback })` — select-one or select-many with a floating popup; returns `:Get()` / `:Set(v)`.
- `:CreateColorPicker({ Title, Default, Callback })` — full HSV color picker popup; returns `:Get()` / `:Set(v)`.
- `:CreateKeybind({ Title, Default, Callback })` — captures a key; returns `:Get()` / `:Set(v)`.

Every widget returns an object with `:Get()`, `:Set(value)`, and `:Instance` (the underlying `Frame`) so you can read/update state and parent it wherever you like.

## 🎨 Themes

```lua
UI:SetTheme("Nebula")
UI:SetAccent(Color3.fromRGB(180, 120, 255))
```

Themes are flat tables of hex strings / numbers. `Forge.Resolve` resolves them and applies `ThemeFallbacks` when a key is missing, so a theme swap is instant and never returns `nil`. Widgets register their themed properties via `Skin` and are re-skinned automatically on `SetTheme` — no per-frame polling.

| Theme | Accent | Background | Vibe |
| --- | --- | --- | --- |
| **Default** | `#7CA2FF` | `#0E1116` | Balanced graphite blue |
| **Midnight** | `#5B8DEF` | `#070A12` | Deep night blue |
| **Nebula** | `#B57CFF` | `#0C0A16` | Purple cosmic |
| **Crimson** | `#FF5C7A` | `#140A0E` | Warm red |
| **Emerald** | `#34D399` | `#07120E` | Cool green |
| **Amber** | `#FFB454` | `#16110A` | Warm gold |
| **Ocean** | `#22D3EE` | `#06141A` | Cyan teal |
| **Rose** | `#FB7185` | `#1A0E14` | Soft pink |
| **Frost** | `#A5B4FC` | `#0B0F1A` | Icy indigo |
| **Mono** | `#E6EAF2` | `#0A0A0A` | Minimal grayscale |

## 🏗️ Architecture (single file)

```
VoidUI.lua          # everything: Forge + Themes + Icons + Tab + Window + public API
Examples/
└── Example.lua     # runnable demonstration
```

Internally the file is organized into clearly commented sections:
- **Environment helpers** — `cloneref`, `gethui`, `protectgui`, forgiving `Enum` proxy.
- **Forge** — `Make`, `Skin`, `Guard`, `Resolve`, `Apply`, `Tween`.
- **Themes** — 10 themes + fallbacks.
- **Icons** — asset-free Unicode glyph table.
- **Tab** — the chainable widget factory.
- **Window** — chrome, tabs, notifications, drag/resize.
- **Public API root** — `VoidUI.new`, `CreateWindow`, `SetTheme`, `SetAccent`, `Notify`, `GetStats`.

## 📄 License

Internal use. No external dependencies.
