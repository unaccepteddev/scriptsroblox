--[[
	Unnamed UI Library  -  REDESIGN
	API neschimbat: library:Window / window:Tab / tab:Section /
	section:Toggle / Slider / Button / Input / Dropdown / Keybind / library:Notification
	Teme neschimbate (Dark, Tokyo Night, Starry Night)
]]

local library = {
	Flags = {},
	SectionsOpened = false,
	Theme = "Dark"
}
library.flags = library.Flags
library.theme = library.Theme

local Themes = {
	["Dark"] = {
		Topbar = Color3.fromRGB(30, 30, 35),
		TabContainer = Color3.fromRGB(25, 25, 30),
		Lines = Color3.fromRGB(50, 50, 55),
		HoverTabFrame = Color3.fromRGB(53, 53, 57),
		ItemUIStroke = Color3.fromRGB(41, 41, 50),
		TabFrame = Color3.fromRGB(35, 35, 40),
		SectionFrame = Color3.fromRGB(30, 30, 35),
		TabText = Color3.fromRGB(237, 237, 237),
		ItemText = Color3.fromRGB(237, 237, 237),
		ItemUIStrokeSelected = Color3.fromRGB(80, 201, 206),
		DropdownIcon = Color3.fromRGB(175, 175, 175),
		SectionText = Color3.fromRGB(237, 237, 237),
		SelectedTabFrame = Color3.fromRGB(65, 65, 70),
		ItemFrame = Color3.fromRGB(35, 35, 40),
		HoverItemFrame = Color3.fromRGB(53, 53, 57),
		SectionUIStroke = Color3.fromRGB(37, 37, 44),
		MainUIStroke = Color3.fromRGB(54, 54, 63),
		Main = Color3.fromRGB(20, 20, 25),
		Shadow = Color3.fromRGB(20, 20, 25),
		TabUIStroke = Color3.fromRGB(39, 39, 47),
		SliderOuter = Color3.fromRGB(60, 60, 70),
		SliderInner = Color3.fromRGB(80, 201, 206),
		ToggleOuter = Color3.fromRGB(35, 35, 40),
		InputPlaceHolder = Color3.fromRGB(60, 60, 65),
		ToggleOuterEnabled = Color3.fromRGB(53, 53, 61),
		ToggleOuterUIStroke = Color3.fromRGB(54, 54, 62),
		ToggleOuterUIStrokeEnabled = Color3.fromRGB(67, 67, 77),
		ToggleInner = Color3.fromRGB(66, 66, 76),
		ToggleInnerEnabled = Color3.fromRGB(80, 201, 206),
		ContainerHolder = Color3.fromRGB(26, 26, 31),
		HighlightUIStroke = Color3.fromRGB(79, 79, 86),
		Highlight = Color3.fromRGB(80, 201, 206)
	},
	["Tokyo Night"] = {
		Topbar = Color3.fromRGB(39, 40, 57),
		TabContainer = Color3.fromRGB(31, 32, 45),
		Lines = Color3.fromRGB(62, 63, 90),
		HoverTabFrame = Color3.fromRGB(52, 53, 76),
		ItemUIStroke = Color3.fromRGB(51, 53, 75),
		TabFrame = Color3.fromRGB(39, 40, 57),
		SectionFrame = Color3.fromRGB(31, 32, 45),
		TabText = Color3.fromRGB(237, 237, 237),
		ItemText = Color3.fromRGB(237, 237, 237),
		SectionText = Color3.fromRGB(237, 237, 237),
		ItemUIStrokeSelected = Color3.fromRGB(255, 183, 38),
		SelectedTabFrame = Color3.fromRGB(70, 72, 102),
		ItemFrame = Color3.fromRGB(39, 40, 57),
		HoverItemFrame = Color3.fromRGB(50, 52, 74),
		DropdownIcon = Color3.fromRGB(175, 175, 175),
		SectionUIStroke = Color3.fromRGB(45, 46, 66),
		MainUIStroke = Color3.fromRGB(64, 67, 100),
		Main = Color3.fromRGB(26, 27, 38),
		Shadow = Color3.fromRGB(26, 27, 38),
		SliderOuter = Color3.fromRGB(56, 59, 83),
		SliderInner = Color3.fromRGB(255, 183, 38),
		TabUIStroke = Color3.fromRGB(55, 56, 80),
		InputPlaceHolder = Color3.fromRGB(70, 73, 94),
		ToggleOuter = Color3.fromRGB(56, 59, 83),
		ToggleOuterEnabled = Color3.fromRGB(77, 82, 115),
		ToggleOuterUIStroke = Color3.fromRGB(76, 79, 112),
		ToggleOuterUIStrokeEnabled = Color3.fromRGB(255, 183, 38),
		ToggleInner = Color3.fromRGB(76, 79, 112),
		ToggleInnerEnabled = Color3.fromRGB(255, 183, 38),
		ContainerHolder = Color3.fromRGB(32, 32, 47),
		HighlightUIStroke = Color3.fromRGB(86, 89, 127),
		Highlight = Color3.fromRGB(253, 191, 67)
	},
	["Starry Night"] = {
		Topbar = Color3.fromRGB(21, 26, 33),
		TabContainer = Color3.fromRGB(19, 23, 30),
		Lines = Color3.fromRGB(44, 53, 67),
		HoverTabFrame = Color3.fromRGB(41, 49, 65),
		ItemUIStroke = Color3.fromRGB(42, 49, 65),
		TabFrame = Color3.fromRGB(34, 41, 54),
		SectionFrame = Color3.fromRGB(23, 27, 35),
		TabText = Color3.fromRGB(237, 237, 237),
		ItemText = Color3.fromRGB(237, 237, 237),
		SectionText = Color3.fromRGB(237, 237, 237),
		ItemUIStrokeSelected = Color3.fromRGB(255, 211, 105),
		SelectedTabFrame = Color3.fromRGB(53, 64, 84),
		ItemFrame = Color3.fromRGB(32, 37, 49),
		HoverItemFrame = Color3.fromRGB(43, 50, 67),
		DropdownIcon = Color3.fromRGB(175, 175, 175),
		SectionUIStroke = Color3.fromRGB(35, 41, 54),
		MainUIStroke = Color3.fromRGB(54, 65, 85),
		Main = Color3.fromRGB(19, 22, 29),
		InputPlaceHolder = Color3.fromRGB(57, 66, 89),
		Shadow = Color3.fromRGB(19, 22, 29),
		SliderOuter = Color3.fromRGB(48, 56, 75),
		SliderInner = Color3.fromRGB(255, 211, 105),
		TabUIStroke = Color3.fromRGB(45, 54, 71),
		ToggleOuter = Color3.fromRGB(48, 56, 75),
		ToggleOuterEnabled = Color3.fromRGB(58, 68, 91),
		ToggleOuterUIStroke = Color3.fromRGB(42, 49, 65),
		ToggleOuterUIStrokeEnabled = Color3.fromRGB(255, 211, 105),
		ToggleInner = Color3.fromRGB(77, 90, 121),
		ToggleInnerEnabled = Color3.fromRGB(255, 211, 105),
		ContainerHolder = Color3.fromRGB(25, 32, 43),
		HighlightUIStroke = Color3.fromRGB(79, 94, 124),
		Highlight = Color3.fromRGB(255, 229, 121)
	}
}

----------------------------------------------------------------------
-- Servicii / utilitare
----------------------------------------------------------------------
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local Blacklist = {Enum.KeyCode.Unknown, Enum.KeyCode.CapsLock, Enum.KeyCode.Escape, Enum.KeyCode.Tab, Enum.KeyCode.Return, Enum.KeyCode.Backspace, Enum.KeyCode.Space, Enum.KeyCode.W, Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D}

local request = syn and syn.request or http and http.request or http_request or request or httprequest
local getcustomasset = getcustomasset or getsynasset
local isfolder = isfolder or syn_isfolder or is_folder
local makefolder = makefolder or make_folder or createfolder or create_folder

if not isfolder("Unnamed") then
	makefolder("Unnamed")
end

local function fetchAsset(fileName, url)
	local path = "Unnamed/" .. fileName
	if not isfile(path) then
		local ok, res = pcall(request, {Url = url, Method = "GET"})
		if ok and res and res.Body then
			writefile(path, res.Body)
		end
	end
	local ok, asset = pcall(getcustomasset, path)
	return ok and asset or ""
end

local ShadowAsset = fetchAsset("Shadow.png", "https://raw.githubusercontent.com/Rain-Design/Unnamed/main/Icons/UnnamedShadow.png")
local ChevronAsset = fetchAsset("Chevron.png", "https://raw.githubusercontent.com/Rain-Design/Unnamed/main/Icons/Chevron.png")
local CircleAsset = fetchAsset("Circle.png", "https://raw.githubusercontent.com/Rain-Design/Unnamed/main/Icons/Circle.png")

local function getTheme()
	local T = Themes[library.Theme]
	if T == nil then
		error("There's no theme called: " .. tostring(library.Theme), 0)
	end
	return T
end

local function parentGui(gui)
	if syn and syn.protect_gui then pcall(syn.protect_gui, gui) end
	local ok = pcall(function()
		gui.Parent = (gethui and gethui()) or CoreGui
	end)
	if not ok then gui.Parent = CoreGui end
end

local function tween(obj, time, props, style, dir)
	local t = TweenService:Create(obj, TweenInfo.new(time, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out), props)
	t:Play()
	return t
end

local function new(class, props)
	local o = Instance.new(class)
	local parent
	for k, v in pairs(props or {}) do
		if k == "Parent" then parent = v else o[k] = v end
	end
	if parent then o.Parent = parent end
	return o
end

local function corner(parent, radius)
	return new("UICorner", {CornerRadius = UDim.new(0, radius or 3), Parent = parent})
end

local function stroke(parent, color, thickness)
	return new("UIStroke", {Color = color, Thickness = thickness or 1, Parent = parent})
end

local function padding(parent, l, t, r, b)
	return new("UIPadding", {
		PaddingLeft = UDim.new(0, l or 0), PaddingTop = UDim.new(0, t or 0),
		PaddingRight = UDim.new(0, r or 0), PaddingBottom = UDim.new(0, b or 0),
		Parent = parent
	})
end

local function rgbString(c)
	return string.format("rgb(%d,%d,%d)", math.floor(c.R * 255 + 0.5), math.floor(c.G * 255 + 0.5), math.floor(c.B * 255 + 0.5))
end

function library:Darken(clr3)
	local z, x, brightness = clr3:ToHSV()
	brightness = math.clamp(brightness - 0.5, 0, 1)
	return Color3.fromHSV(z, x, brightness)
end

function library:GetXY(GuiObject)
	local Max, May = GuiObject.AbsoluteSize.X, GuiObject.AbsoluteSize.Y
	local Px, Py = math.clamp(Mouse.X - GuiObject.AbsolutePosition.X, 0, Max), math.clamp(Mouse.Y - GuiObject.AbsolutePosition.Y, 0, May)
	return Px / Max, Py / May
end

----------------------------------------------------------------------
-- Notificari (carduri slide-in cu bara de progres)
----------------------------------------------------------------------
local notifGui, notifHolder

local function ensureNotifications()
	if notifGui and notifGui.Parent then return end
	notifGui = new("ScreenGui", {
		Name = HttpService:GenerateGUID(true),
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		ResetOnSpawn = false,
		DisplayOrder = 100
	})
	parentGui(notifGui)
	notifHolder = new("Frame", {Name = "NotificationHolder", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Parent = notifGui})
	new("UIListLayout", {
		Padding = UDim.new(0, 6),
		HorizontalAlignment = Enum.HorizontalAlignment.Right,
		VerticalAlignment = Enum.VerticalAlignment.Bottom,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = notifHolder
	})
	padding(notifHolder, 0, 0, 14, 24)
end

function library:Notification(Info)
	Info = Info or {}
	Info.Title = Info.Title or "Notification"
	Info.Description = Info.Description or "Placeholder"
	Info.Timeout = Info.Timeout or nil
	Info.Callback = Info.Callback or function() end

	local Theme = getTheme()
	ensureNotifications()

	local wrapper = new("Frame", {
		Name = "Notification", BackgroundTransparency = 1,
		Size = UDim2.new(0, 310, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
		Parent = notifHolder
	})
	local card = new("Frame", {
		Name = "Card", BackgroundColor3 = Theme.Main, BackgroundTransparency = 0.04, BorderSizePixel = 0,
		Position = UDim2.new(0, 340, 0, 0), Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y, ClipsDescendants = true, Parent = wrapper
	})
	corner(card, 4)
	stroke(card, Theme.MainUIStroke)

	local inner = new("Frame", {BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Parent = card})
	padding(inner, 16, 9, 34, 12)
	new("UIListLayout", {Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder, Parent = inner})

	new("Frame", {Name = "Accent", BackgroundColor3 = Theme.Highlight, BorderSizePixel = 0, Size = UDim2.new(0, 3, 1, 0), Parent = card})

	new("TextLabel", {
		Name = "Title", Font = Enum.Font.GothamBold, Text = Info.Title, TextColor3 = Theme.SectionText,
		TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 18), LayoutOrder = 1, Parent = inner
	})
	new("TextLabel", {
		Name = "Description", Font = Enum.Font.GothamMedium, Text = Info.Description, TextColor3 = Theme.SectionText,
		TextTransparency = 0.25, TextSize = 12, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top, BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = 2, Parent = inner
	})

	local closeBtn = new("ImageButton", {
		Image = "rbxassetid://10738425363", ImageColor3 = Theme.SectionText, ImageTransparency = 0.2,
		BackgroundTransparency = 1, Position = UDim2.new(1, -24, 0, 8), Size = UDim2.new(0, 15, 0, 15), Parent = card
	})
	closeBtn.MouseEnter:Connect(function() tween(closeBtn, .1, {ImageColor3 = Color3.fromRGB(255, 66, 66)}) end)
	closeBtn.MouseLeave:Connect(function() tween(closeBtn, .1, {ImageColor3 = Theme.SectionText}) end)

	local bar
	if Info.Timeout then
		bar = new("Frame", {
			Name = "Progress", BackgroundColor3 = Theme.Highlight, BorderSizePixel = 0,
			AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 0, 1, 0), Size = UDim2.new(1, 0, 0, 2), Parent = card
		})
	end

	local dismissed = false
	local function dismiss()
		if dismissed then return end
		dismissed = true
		task.spawn(Info.Callback)
		local t = tween(card, .25, {Position = UDim2.new(0, 340, 0, 0)}, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
		t.Completed:Wait()
		wrapper:Destroy()
	end

	closeBtn.MouseButton1Click:Connect(dismiss)
	tween(card, .3, {Position = UDim2.new(0, 0, 0, 0)}, Enum.EasingStyle.Back)

	if Info.Timeout then
		tween(bar, Info.Timeout, {Size = UDim2.new(0, 0, 0, 2)}, Enum.EasingStyle.Linear)
		task.delay(Info.Timeout, dismiss)
	end
end

----------------------------------------------------------------------
-- Window
----------------------------------------------------------------------
function library:Window(Info)
	Info = Info or {}
	Info.Text = Info.Text or "Window"
	Info.SubText = Info.SubText or ""
	Info.ToggleKey = Info.ToggleKey or Enum.KeyCode.RightShift
	if Info.Watermark == nil then Info.Watermark = true end
	Info.WatermarkText = Info.WatermarkText or Info.Text

	local Theme = getTheme()
	local window = {}
	local connections = {}
	local function connect(signal, fn)
		local c = signal:Connect(fn)
		table.insert(connections, c)
		return c
	end

	local WIDTH, HEIGHT = 640, 420
	local TOPBAR, STATUS, SIDEBAR = 36, 22, 150

	local gui = new("ScreenGui", {Name = HttpService:GenerateGUID(true), ZIndexBehavior = Enum.ZIndexBehavior.Sibling, ResetOnSpawn = false})
	parentGui(gui)

	local root = new("Frame", {
		Name = "Root", BackgroundTransparency = 1,
		Position = UDim2.new(0.5, -WIDTH / 2, 0.5, -HEIGHT / 2), Size = UDim2.new(0, WIDTH, 0, HEIGHT), Parent = gui
	})
	local uiScale = new("UIScale", {Scale = 0.94, Parent = root})
	tween(uiScale, .3, {Scale = 1}, Enum.EasingStyle.Back)

	new("ImageLabel", {
		Name = "Shadow", Image = ShadowAsset, ImageColor3 = Theme.Shadow, ImageTransparency = 0.2,
		BackgroundTransparency = 1, Position = UDim2.new(0, -10, 0, -10), Size = UDim2.new(1, 20, 1, 20), Parent = root
	})

	local main = new("Frame", {
		Name = "Main", BackgroundColor3 = Theme.Main, BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 1, 0), ClipsDescendants = true, Parent = root
	})
	corner(main, 4)
	stroke(main, Theme.MainUIStroke)

	---------------- Topbar ----------------
	local topbar = new("Frame", {Name = "Topbar", BackgroundColor3 = Theme.Topbar, BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, TOPBAR), ZIndex = 3, Parent = main})
	corner(topbar, 4)
	new("Frame", {BackgroundColor3 = Theme.Topbar, BorderSizePixel = 0, Position = UDim2.new(0, 0, 1, -6), Size = UDim2.new(1, 0, 0, 6), ZIndex = 3, Parent = topbar})
	new("Frame", {Name = "TopbarLine", BackgroundColor3 = Theme.Lines, BorderSizePixel = 0, Position = UDim2.new(0, 0, 1, -1), Size = UDim2.new(1, 0, 0, 1), ZIndex = 4, Parent = topbar})

	local titleHolder = new("Frame", {BackgroundTransparency = 1, Position = UDim2.new(0, 12, 0, 0), Size = UDim2.new(0, 0, 1, 0), AutomaticSize = Enum.AutomaticSize.X, ZIndex = 4, Parent = topbar})
	new("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, VerticalAlignment = Enum.VerticalAlignment.Center, Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder, Parent = titleHolder})

	local logoHolder = new("Frame", {BackgroundTransparency = 1, Size = UDim2.new(0, 16, 0, 16), LayoutOrder = 1, ZIndex = 4, Parent = titleHolder})
	local logo = new("Frame", {BackgroundColor3 = Theme.Highlight, AnchorPoint = Vector2.new(.5, .5), Position = UDim2.new(.5, 0, .5, 0), Size = UDim2.new(0, 10, 0, 10), Rotation = 45, ZIndex = 4, Parent = logoHolder})
	corner(logo, 2)
	new("Frame", {BackgroundColor3 = Theme.Topbar, AnchorPoint = Vector2.new(.5, .5), Position = UDim2.new(.5, 0, .5, 0), Size = UDim2.new(0, 4, 0, 4), ZIndex = 5, Parent = logo})

	new("TextLabel", {
		Name = "WindowName", Font = Enum.Font.GothamBold, Text = Info.Text, TextColor3 = Color3.fromRGB(255, 255, 255),
		TextSize = 13, TextTransparency = 0.1, BackgroundTransparency = 1, LayoutOrder = 2, ZIndex = 4,
		Size = UDim2.new(0, 0, 1, 0), AutomaticSize = Enum.AutomaticSize.X, Parent = titleHolder
	})
	if Info.SubText ~= "" then
		new("TextLabel", {
			Name = "SubText", Font = Enum.Font.GothamMedium, Text = Info.SubText, TextColor3 = Theme.Highlight,
			TextSize = 11, TextTransparency = 0.2, BackgroundTransparency = 1, LayoutOrder = 3, ZIndex = 4,
			Size = UDim2.new(0, 0, 1, 0), AutomaticSize = Enum.AutomaticSize.X, Parent = titleHolder
		})
	end

	local closeButton = new("ImageButton", {
		Name = "CloseButton", Image = "rbxassetid://10738425363", ImageTransparency = 0.1, BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, .5), Position = UDim2.new(1, -10, .5, 0), Size = UDim2.new(0, 17, 0, 17), ZIndex = 5, Parent = topbar
	})
	local minimizeButton = new("ImageButton", {
		Name = "MinimizeButton", Image = "rbxassetid://10664064072", ImageTransparency = 0.1, BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, .5), Position = UDim2.new(1, -34, .5, 0), Size = UDim2.new(0, 17, 0, 17), ZIndex = 5, Parent = topbar
	})

	closeButton.MouseEnter:Connect(function() tween(closeButton, .125, {ImageColor3 = Color3.fromRGB(255, 66, 66)}, Enum.EasingStyle.Linear) end)
	closeButton.MouseLeave:Connect(function() tween(closeButton, .125, {ImageColor3 = Color3.fromRGB(255, 255, 255)}, Enum.EasingStyle.Linear) end)
	minimizeButton.MouseEnter:Connect(function() tween(minimizeButton, .125, {ImageColor3 = Theme.Highlight}, Enum.EasingStyle.Linear) end)
	minimizeButton.MouseLeave:Connect(function() tween(minimizeButton, .125, {ImageColor3 = Color3.fromRGB(255, 255, 255)}, Enum.EasingStyle.Linear) end)

	---------------- Drag ----------------
	local dragging, dragInput, dragStart, startPos
	topbar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = root.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then dragging = false end
			end)
		end
	end)
	topbar.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)
	connect(UserInputService.InputChanged, function(input)
		if input == dragInput and dragging then
			local delta = input.Position - dragStart
			root.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)

	---------------- Sidebar ----------------
	local sidebar = new("Frame", {
		Name = "Sidebar", BackgroundColor3 = Theme.TabContainer, BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 0, TOPBAR), Size = UDim2.new(0, SIDEBAR, 1, -(TOPBAR + STATUS)), Parent = main
	})
	new("Frame", {Name = "SidebarLine", BackgroundColor3 = Theme.Lines, BorderSizePixel = 0, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 0, 0, 0), Size = UDim2.new(0, 1, 1, 0), ZIndex = 2, Parent = sidebar})

	-- search
	local searchFrame = new("Frame", {BackgroundColor3 = Theme.ItemFrame, BorderSizePixel = 0, Position = UDim2.new(0, 8, 0, 8), Size = UDim2.new(1, -17, 0, 26), Parent = sidebar})
	corner(searchFrame, 3)
	local searchStroke = stroke(searchFrame, Theme.ItemUIStroke)
	local searchBox = new("TextBox", {
		Font = Enum.Font.GothamBold, PlaceholderText = "Search tabs...", PlaceholderColor3 = Theme.InputPlaceHolder, Text = "",
		TextColor3 = Theme.ItemText, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false,
		BackgroundTransparency = 1, Position = UDim2.new(0, 10, 0, 0), Size = UDim2.new(1, -20, 1, 0), Parent = searchFrame
	})
	searchBox.Focused:Connect(function() tween(searchStroke, .1, {Color = Theme.ItemUIStrokeSelected}) end)
	searchBox.FocusLost:Connect(function() tween(searchStroke, .1, {Color = Theme.ItemUIStroke}) end)

	local tabScroll = new("ScrollingFrame", {
		Name = "TabContainerScrolling", AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(),
		ScrollBarThickness = 0, BackgroundTransparency = 1, BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 0, 42), Size = UDim2.new(1, -1, 1, -(42 + 64)), Parent = sidebar
	})
	new("UIListLayout", {Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder, Parent = tabScroll})
	padding(tabScroll, 8, 2, 8, 2)

	-- avatar card
	local avatarCard = new("Frame", {
		Name = "AvatarCard", BackgroundColor3 = Theme.ItemFrame, BorderSizePixel = 0,
		Position = UDim2.new(0, 8, 1, -60), Size = UDim2.new(1, -17, 0, 52), Parent = sidebar
	})
	corner(avatarCard, 4)
	stroke(avatarCard, Theme.ItemUIStroke)

	local avatarImg = new("ImageLabel", {
		Name = "Avatar", BackgroundColor3 = Theme.SelectedTabFrame, BorderSizePixel = 0,
		Position = UDim2.new(0, 8, 0.5, -17), Size = UDim2.new(0, 34, 0, 34), ScaleType = Enum.ScaleType.Crop, Parent = avatarCard
	})
	corner(avatarImg, 17)
	stroke(avatarImg, Theme.Highlight, 2)
	local statusDot = new("Frame", {BackgroundColor3 = Theme.Highlight, BorderSizePixel = 0, Position = UDim2.new(0, 33, 0.5, 8), Size = UDim2.new(0, 10, 0, 10), ZIndex = 3, Parent = avatarCard})
	corner(statusDot, 5)
	stroke(statusDot, Theme.ItemFrame, 2)

	new("TextLabel", {
		Name = "DisplayName", Font = Enum.Font.GothamBold, Text = LocalPlayer.DisplayName, TextColor3 = Theme.ItemText,
		TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, BackgroundTransparency = 1,
		Position = UDim2.new(0, 50, 0, 9), Size = UDim2.new(1, -56, 0, 16), Parent = avatarCard
	})
	new("TextLabel", {
		Name = "UserName", Font = Enum.Font.GothamMedium, Text = "@" .. LocalPlayer.Name, TextColor3 = Theme.ItemText, TextTransparency = 0.45,
		TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, BackgroundTransparency = 1,
		Position = UDim2.new(0, 50, 0, 25), Size = UDim2.new(1, -56, 0, 16), Parent = avatarCard
	})

	task.spawn(function()
		local ok, content = pcall(function()
			return Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.AvatarBust, Enum.ThumbnailSize.Size100x100)
		end)
		if ok and avatarImg.Parent then avatarImg.Image = content end
	end)

	---------------- Content ----------------
	local containers = new("Frame", {
		Name = "Containers", BackgroundTransparency = 1,
		Position = UDim2.new(0, SIDEBAR, 0, TOPBAR), Size = UDim2.new(1, -SIDEBAR, 1, -(TOPBAR + STATUS)),
		ClipsDescendants = true, Parent = main
	})

	---------------- Status bar ----------------
	local statusbar = new("Frame", {Name = "StatusBar", BackgroundColor3 = Theme.Topbar, BorderSizePixel = 0, Position = UDim2.new(0, 0, 1, -STATUS), Size = UDim2.new(1, 0, 0, STATUS), ZIndex = 3, Parent = main})
	corner(statusbar, 4)
	new("Frame", {BackgroundColor3 = Theme.Topbar, BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 6), ZIndex = 3, Parent = statusbar})
	new("Frame", {BackgroundColor3 = Theme.Lines, BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 1), ZIndex = 4, Parent = statusbar})
	local breadcrumb = new("TextLabel", {
		Font = Enum.Font.GothamMedium, Text = Info.Text, TextColor3 = Theme.ItemText, TextTransparency = 0.35, TextSize = 11,
		TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 1, Position = UDim2.new(0, 12, 0, 0), Size = UDim2.new(0.5, -12, 1, 0), ZIndex = 4, Parent = statusbar
	})
	new("TextLabel", {
		Font = Enum.Font.GothamMedium, Text = "[" .. Info.ToggleKey.Name .. "] toggle UI", TextColor3 = Theme.ItemText, TextTransparency = 0.35, TextSize = 11,
		TextXAlignment = Enum.TextXAlignment.Right, BackgroundTransparency = 1, Position = UDim2.new(0.5, 0, 0, 0), Size = UDim2.new(0.5, -12, 1, 0), ZIndex = 4, Parent = statusbar
	})

	---------------- Watermark ----------------
	local wmGui = new("ScreenGui", {Name = HttpService:GenerateGUID(true), ZIndexBehavior = Enum.ZIndexBehavior.Sibling, ResetOnSpawn = false, DisplayOrder = 50})
	parentGui(wmGui)
	local wmFrame = new("Frame", {
		Name = "Watermark", BackgroundColor3 = Theme.Main, BackgroundTransparency = 0.08, BorderSizePixel = 0,
		Position = UDim2.new(0, 14, 0, 14), Size = UDim2.new(0, 0, 0, 26), AutomaticSize = Enum.AutomaticSize.X,
		Visible = Info.Watermark, Parent = wmGui
	})
	corner(wmFrame, 4)
	stroke(wmFrame, Theme.MainUIStroke)
	new("Frame", {BackgroundColor3 = Theme.Highlight, BorderSizePixel = 0, Position = UDim2.new(0, 4, 0, 0), Size = UDim2.new(1, -8, 0, 2), Parent = wmFrame})
	padding(wmFrame, 10, 0, 10, 0)
	local wmLabel = new("TextLabel", {
		Font = Enum.Font.GothamBold, RichText = true, Text = "", TextColor3 = Theme.ItemText, TextSize = 12,
		BackgroundTransparency = 1, Size = UDim2.new(0, 0, 1, 0), AutomaticSize = Enum.AutomaticSize.X, Parent = wmFrame
	})

	local wmTitle = Info.WatermarkText
	local lastFps, lastPing = 0, 0
	local function refreshWatermark()
		local hl = rgbString(Theme.Highlight)
		wmLabel.Text = string.format('<font color="%s">%s</font>  |  %s  |  %d FPS  |  %d ms  |  %s',
			hl, wmTitle, LocalPlayer.Name, lastFps, lastPing, os.date("%H:%M:%S"))
	end
	refreshWatermark()

	-- Watermark drag (mouse + touch), independent from the main window.
	local wmDragging, wmDragStart, wmStartPos = false, nil, nil
	wmFrame.Active = true
	wmFrame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			wmDragging = true
			wmDragStart = input.Position
			wmStartPos = wmFrame.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then wmDragging = false end
			end)
		end
	end)
	connect(UserInputService.InputChanged, function(input)
		if wmDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - wmDragStart
			wmFrame.Position = UDim2.new(wmStartPos.X.Scale, wmStartPos.X.Offset + delta.X, wmStartPos.Y.Scale, wmStartPos.Y.Offset + delta.Y)
		end
	end)

	local frames, lastT = 0, os.clock()
	connect(RunService.RenderStepped, function()
		frames = frames + 1
		local now = os.clock()
		if now - lastT >= 0.5 then
			lastFps = math.floor(frames / (now - lastT) + 0.5)
			frames, lastT = 0, now
			pcall(function()
				lastPing = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue() + 0.5)
			end)
			refreshWatermark()
		end
	end)

	function window:SetWatermark(text)
		wmTitle = tostring(text)
		refreshWatermark()
	end
	function window:SetWatermarkVisible(bool)
		wmFrame.Visible = bool and true or false
	end

	---------------- Minimizare / Toggle / Inchidere ----------------
	local Minimized = false
	local windowSize = UDim2.new(0, WIDTH, 0, HEIGHT)
	local minimizeTween
	minimizeButton.MouseButton1Click:Connect(function()
		Minimized = not Minimized
		if minimizeTween then minimizeTween:Cancel() end
		-- Hide the content while collapsed so scrolling/layouts cannot fight the resize.
		if Minimized then
			sidebar.Visible = false
			containers.Visible = false
			statusbar.Visible = false
			minimizeTween = tween(root, .22, {Size = UDim2.new(0, WIDTH, 0, TOPBAR)}, Enum.EasingStyle.Quad)
		else
			minimizeTween = tween(root, .22, {Size = windowSize}, Enum.EasingStyle.Quad)
			minimizeTween.Completed:Connect(function()
				if not Minimized and root.Parent then
					sidebar.Visible = true
					containers.Visible = true
					statusbar.Visible = true
				end
			end)
		end
	end)

	function window:Toggle(bool)
		if bool == nil then bool = not root.Visible end
		root.Visible = bool
	end

	connect(UserInputService.InputBegan, function(input, processed)
		-- RightShift should toggle even when Roblox marks the input as processed.
		if input.KeyCode == Info.ToggleKey then
			root.Visible = not root.Visible
		end
	end)

	function window:Destroy()
		for _, c in ipairs(connections) do c:Disconnect() end
		gui:Destroy()
		wmGui:Destroy()
		if notifGui then notifGui:Destroy() notifGui = nil end
	end
	closeButton.MouseButton1Click:Connect(function() window:Destroy() end)

	---------------- Tabs ----------------
	local tabs = {}
	local selectedTab = nil

	connect(searchBox:GetPropertyChangedSignal("Text"), function()
		local q = string.lower(searchBox.Text)
		for _, t in ipairs(tabs) do
			t.button.Visible = q == "" or string.find(string.lower(t.name), q, 1, true) ~= nil
		end
	end)

	function window:Tab(Info)
		Info = Info or {}
		Info.Text = Info.Text or "Tab"
		Info.Icon = Info.Icon or nil

		local tabtable = {}

		local tabFrame = new("Frame", {
			Name = "Tab", BackgroundColor3 = Theme.TabFrame, BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 30), LayoutOrder = #tabs + 1, Parent = tabScroll
		})
		corner(tabFrame, 3)
		local tabStroke = stroke(tabFrame, Theme.TabUIStroke)

		local indicator = new("Frame", {
			BackgroundColor3 = Theme.Highlight, BorderSizePixel = 0, AnchorPoint = Vector2.new(0, .5),
			Position = UDim2.new(0, 5, .5, 0), Size = UDim2.new(0, 3, 0, 0), Parent = tabFrame
		})
		corner(indicator, 2)

		local textX = 16
		if Info.Icon then
			new("ImageLabel", {
				Image = Info.Icon, ImageColor3 = Theme.TabText, BackgroundTransparency = 1,
				Position = UDim2.new(0, 15, .5, -8), Size = UDim2.new(0, 16, 0, 16), Parent = tabFrame
			})
			textX = 38
		end

		local tabName = new("TextLabel", {
			Name = "TabName", Font = Enum.Font.GothamBold, Text = Info.Text, TextColor3 = Theme.TabText, TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 1,
			Position = UDim2.new(0, textX, 0, 0), Size = UDim2.new(1, -textX - 6, 1, 0), Parent = tabFrame
		})
		local tabButton = new("TextButton", {Text = "", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Parent = tabFrame})

		-- pagina (Left / Right)
		local page = new("Frame", {Name = "Page", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Visible = false, Parent = containers})

		local function makeColumn(name, pos, size)
			local col = new("ScrollingFrame", {
				Name = name, AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(),
				ScrollBarThickness = 0, BackgroundTransparency = 1, BorderSizePixel = 0, Selectable = false,
				Position = pos, Size = size, Parent = page
			})
			new("UIListLayout", {Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder, Parent = col})
			padding(col, 1, 1, 1, 1)
			return col
		end
		local Left = makeColumn("Left", UDim2.new(0, 6, 0, 6), UDim2.new(0.5, -9, 1, -12))
		local Right = makeColumn("Right", UDim2.new(0.5, 3, 0, 6), UDim2.new(0.5, -9, 1, -12))

		local entry = {button = tabFrame, name = Info.Text, page = page}

		function entry.deselect()
			page.Visible = false
			tween(tabFrame, .15, {BackgroundColor3 = Theme.TabFrame}, Enum.EasingStyle.Linear)
			tween(tabStroke, .15, {Color = Theme.TabUIStroke}, Enum.EasingStyle.Linear)
			tween(tabName, .15, {TextColor3 = Theme.TabText, Position = UDim2.new(0, textX, 0, 0)}, Enum.EasingStyle.Linear)
			tween(indicator, .15, {Size = UDim2.new(0, 3, 0, 0)})
		end
		table.insert(tabs, entry)

		tabFrame.MouseEnter:Connect(function()
			if selectedTab ~= entry then
				tween(tabFrame, .125, {BackgroundColor3 = Theme.HoverTabFrame}, Enum.EasingStyle.Linear)
				tween(tabName, .15, {Position = UDim2.new(0, textX + 3, 0, 0)}, Enum.EasingStyle.Linear)
			end
		end)
		tabFrame.MouseLeave:Connect(function()
			if selectedTab ~= entry then
				tween(tabFrame, .125, {BackgroundColor3 = Theme.TabFrame}, Enum.EasingStyle.Linear)
				tween(tabName, .15, {Position = UDim2.new(0, textX, 0, 0)}, Enum.EasingStyle.Linear)
			end
		end)

		function tabtable:Select()
			if selectedTab == entry then return end
			if selectedTab then selectedTab.deselect() end
			selectedTab = entry

			page.Position = UDim2.new(0, 0, 0, 10)
			page.Visible = true
			tween(page, .2, {Position = UDim2.new(0, 0, 0, 0)})

			tween(tabFrame, .15, {BackgroundColor3 = Theme.SelectedTabFrame}, Enum.EasingStyle.Linear)
			tween(tabStroke, .15, {Color = Theme.HighlightUIStroke}, Enum.EasingStyle.Linear)
			tween(tabName, .15, {TextColor3 = Theme.Highlight, Position = UDim2.new(0, textX + 3, 0, 0)}, Enum.EasingStyle.Linear)
			tween(indicator, .2, {Size = UDim2.new(0, 3, 0, 14)}, Enum.EasingStyle.Back)
			breadcrumb.Text = Info.Text .. "  ›  " .. tabName.Text
			breadcrumb.Text = (window and Info and Info.Text or "") ~= "" and (tabName.Text) or tabName.Text
		end

		tabButton.MouseButton1Click:Connect(function() tabtable:Select() end)

		-------------- Section --------------
		function tabtable:Section(Info)
			Info = Info or {}
			Info.Text = Info.Text or "Section"
			Info.Side = Info.Side or "Left"
			Info.Opened = Info.Opened or library.SectionsOpened

			local sectiontable = {}
			local closers = {}

			local section = new("Frame", {
				Name = "Section", BackgroundColor3 = Theme.SectionFrame, BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
				Parent = (Info.Side == "Left") and Left or Right
			})
			corner(section, 4)
			stroke(section, Theme.SectionUIStroke)
			new("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Parent = section})

			local header = new("Frame", {Name = "Header", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 30), LayoutOrder = 1, Parent = section})
			local accent = new("Frame", {BackgroundColor3 = Theme.Highlight, BorderSizePixel = 0, AnchorPoint = Vector2.new(0, .5), Position = UDim2.new(0, 8, .5, 0), Size = UDim2.new(0, 3, 0, 12), Parent = header})
			corner(accent, 2)
			local sectionName = new("TextLabel", {
				Name = "SectionName", Font = Enum.Font.GothamBold, Text = Info.Text, TextColor3 = Theme.SectionText, TextSize = 12,
				TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 1,
				Position = UDim2.new(0, 18, 0, 0), Size = UDim2.new(1, -44, 1, 0), Parent = header
			})
			local sectionIcon = new("ImageLabel", {
				Name = "SectionIcon", Image = ChevronAsset, ImageColor3 = Theme.SectionText, BackgroundTransparency = 1,
				AnchorPoint = Vector2.new(1, .5), Position = UDim2.new(1, -6, .5, 0), Size = UDim2.new(0, 17, 0, 17), Rotation = 90, Parent = header
			})
			local sectionButton = new("TextButton", {Text = "", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Parent = header})
			sectionButton.MouseEnter:Connect(function() tween(sectionName, .12, {TextColor3 = Theme.Highlight}, Enum.EasingStyle.Linear) end)
			sectionButton.MouseLeave:Connect(function() tween(sectionName, .12, {TextColor3 = Theme.SectionText}, Enum.EasingStyle.Linear) end)

			local body = new("Frame", {
				Name = "ItemContainer", BackgroundColor3 = Theme.ContainerHolder, BorderSizePixel = 0,
				ClipsDescendants = true, Size = UDim2.new(1, 0, 0, 0), LayoutOrder = 2, Parent = section
			})
			corner(body, 4)
			padding(body, 5, 5, 5, 5)
			local bodyLayout = new("UIListLayout", {Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder, Parent = body})

			local Opened = false
			local function targetHeight()
				return Opened and (bodyLayout.AbsoluteContentSize.Y + 10) or 0
			end
			connect(bodyLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
				if Opened then tween(body, .12, {Size = UDim2.new(1, 0, 0, targetHeight())}) end
			end)

			function sectiontable:Select()
				Opened = not Opened
				if not Opened then
					for _, fn in ipairs(closers) do fn() end
				end
				tween(body, .2, {Size = UDim2.new(1, 0, 0, targetHeight())})
				tween(sectionIcon, .2, {Rotation = Opened and -90 or 90})
			end
			sectionButton.MouseButton1Click:Connect(function() sectiontable:Select() end)

			if Info.Opened then
				Opened = true
				sectionIcon.Rotation = -90
				body.Size = UDim2.new(1, 0, 0, bodyLayout.AbsoluteContentSize.Y + 10)
			end

			-- helpers para items
			local function itemFrame(name, h)
				local f = new("Frame", {Name = name, BackgroundColor3 = Theme.ItemFrame, BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, h or 26), Parent = body})
				corner(f, 3)
				local s = stroke(f, Theme.ItemUIStroke)
				f.MouseEnter:Connect(function() tween(f, .1, {BackgroundColor3 = Theme.HoverItemFrame}, Enum.EasingStyle.Linear) end)
				f.MouseLeave:Connect(function()
					tween(f, .1, {BackgroundColor3 = Theme.ItemFrame}, Enum.EasingStyle.Linear)
					tween(s, .1, {Color = Theme.ItemUIStroke}, Enum.EasingStyle.Linear)
				end)
				return f, s
			end
			local function itemLabel(parent, text, h)
				return new("TextLabel", {
					Font = Enum.Font.GothamBold, Text = text, TextColor3 = Theme.ItemText, TextSize = 12,
					TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 1,
					Position = UDim2.new(0, 10, 0, 0), Size = UDim2.new(1, -20, 0, h or 26), Parent = parent
				})
			end
			local function clickArea(parent, h)
				return new("TextButton", {Text = "", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, h or 26), ZIndex = 2, Parent = parent})
			end
			local function pressStroke(btn, s)
				btn.MouseButton1Down:Connect(function() tween(s, .1, {Color = Theme.ItemUIStrokeSelected}, Enum.EasingStyle.Linear) end)
				btn.MouseButton1Up:Connect(function() tween(s, .1, {Color = Theme.ItemUIStroke}, Enum.EasingStyle.Linear) end)
			end

			-------------- Keybind --------------
			function sectiontable:Keybind(Info)
				Info = Info or {}
				Info.Text = Info.Text or "Keybind"
				Info.Default = Info.Default or Enum.KeyCode.LeftAlt
				Info.Flag = Info.Flag or nil
				Info.Callback = Info.Callback or function() end

				local keybindtable = {}
				local PressKey = Info.Default
				if Info.Flag then library.Flags[Info.Flag] = PressKey.Name end

				local frame = itemFrame("Keybind")
				itemLabel(frame, Info.Text)

				local pill = new("Frame", {
					BackgroundColor3 = Theme.ToggleOuter, AnchorPoint = Vector2.new(1, .5), Position = UDim2.new(1, -6, .5, 0),
					Size = UDim2.new(0, 0, 0, 16), AutomaticSize = Enum.AutomaticSize.X, Parent = frame
				})
				corner(pill, 3)
				local pillStroke = stroke(pill, Theme.ToggleOuterUIStroke)
				padding(pill, 6, 0, 6, 0)
				local pillText = new("TextLabel", {
					Font = Enum.Font.GothamBold, Text = PressKey.Name, TextColor3 = Color3.fromRGB(232, 232, 232), TextSize = 11,
					BackgroundTransparency = 1, Size = UDim2.new(0, 0, 1, 0), AutomaticSize = Enum.AutomaticSize.X, Parent = pill
				})

				local btn = clickArea(frame)
				local KeybindConnection
				local Changing = false

				function keybindtable:Set(key)
					PressKey = key
					pillText.Text = key.Name
					if Info.Flag then library.Flags[Info.Flag] = key.Name end
				end

				btn.MouseButton1Click:Connect(function()
					if KeybindConnection then KeybindConnection:Disconnect() end
					Changing = true
					pillText.Text = "..."
					pillStroke.Color = Theme.ItemUIStrokeSelected
					KeybindConnection = UserInputService.InputBegan:Connect(function(Key, gameProcessed)
						if Key.KeyCode == Enum.KeyCode.Escape then
							KeybindConnection:Disconnect()
							pillText.Text = PressKey.Name
							pillStroke.Color = Theme.ToggleOuterUIStroke
							task.wait(.1)
							Changing = false
						elseif not table.find(Blacklist, Key.KeyCode) and not gameProcessed then
							KeybindConnection:Disconnect()
							keybindtable:Set(Key.KeyCode)
							pillStroke.Color = Theme.ToggleOuterUIStroke
							task.wait(.1)
							Changing = false
						end
					end)
				end)

				connect(UserInputService.InputBegan, function(Key, gameProcessed)
					if not Changing and Key.KeyCode == PressKey and not gameProcessed then
						task.spawn(Info.Callback)
					end
				end)

				return keybindtable
			end

			-------------- Slider --------------
			function sectiontable:Slider(Info)
				Info = Info or {}
				Info.Text = Info.Text or "Slider"
				Info.Flag = Info.Flag or nil
				Info.Default = Info.Default or 5
				Info.Minimum = Info.Minimum or 0
				Info.Maximum = Info.Maximum or 10
				Info.Postfix = Info.Postfix or ""
				Info.Callback = Info.Callback or function() end

				if Info.Minimum > Info.Maximum then
					Info.Minimum, Info.Maximum = Info.Maximum, Info.Minimum
				end
				Info.Default = math.clamp(Info.Default, Info.Minimum, Info.Maximum)

				local slidertable = {}
				local range = Info.Maximum - Info.Minimum
				local function toScale(v)
					if range == 0 then return 0 end
					return (v - Info.Minimum) / range
				end

				local frame, frameStroke = itemFrame("Slider", 38)
				local text = itemLabel(frame, Info.Text, 24)
				text.Position = UDim2.new(0, 10, 0, 2)
				local valueText = new("TextLabel", {
					Font = Enum.Font.GothamBold, Text = tostring(Info.Default) .. Info.Postfix, TextColor3 = Theme.ItemText, TextSize = 12,
					TextXAlignment = Enum.TextXAlignment.Right, BackgroundTransparency = 1,
					Position = UDim2.new(0, 10, 0, 2), Size = UDim2.new(1, -20, 0, 24), Parent = frame
				})

				local track = new("Frame", {BackgroundColor3 = Theme.SliderOuter, BorderSizePixel = 0, Position = UDim2.new(0, 10, 0, 28), Size = UDim2.new(1, -20, 0, 5), Parent = frame})
				corner(track, 100)
				local fill = new("Frame", {BackgroundColor3 = Theme.SliderInner, BorderSizePixel = 0, Size = UDim2.new(toScale(Info.Default), 0, 1, 0), Parent = track})
				corner(fill, 100)
				local knob = new("ImageLabel", {
					Image = CircleAsset, ImageColor3 = Theme.ItemText, BackgroundTransparency = 1, AnchorPoint = Vector2.new(.5, .5),
					Position = UDim2.new(toScale(Info.Default), 0, .5, 0), Size = UDim2.new(0, 10, 0, 10), ZIndex = 3, Parent = track
				})

				local function apply(value, px)
					value = math.clamp(value, Info.Minimum, Info.Maximum)
					px = px or toScale(value)
					tween(fill, .09, {Size = UDim2.new(px, 0, 1, 0)}, Enum.EasingStyle.Linear)
					tween(knob, .09, {Position = UDim2.new(px, 0, .5, 0)}, Enum.EasingStyle.Linear)
					valueText.Text = tostring(value) .. Info.Postfix
					if Info.Flag then library.Flags[Info.Flag] = value end
					task.spawn(Info.Callback, value)
				end

				task.spawn(Info.Callback, Info.Default)
				if Info.Flag then library.Flags[Info.Flag] = Info.Default end

				function slidertable:Set(value) apply(value) end

				local btn = clickArea(frame, 38)
				local function update()
					local Px = library:GetXY(track)
					local Value = math.floor(Info.Minimum + (range * Px))
					apply(Value, Px)
				end

				btn.MouseButton1Down:Connect(function()
					tween(frameStroke, .1, {Color = Theme.ItemUIStrokeSelected}, Enum.EasingStyle.Linear)
					update()
					local move, kill
					move = Mouse.Move:Connect(update)
					kill = UserInputService.InputEnded:Connect(function(i)
						if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
							move:Disconnect()
							kill:Disconnect()
							tween(frameStroke, .1, {Color = Theme.ItemUIStroke}, Enum.EasingStyle.Linear)
						end
					end)
				end)

				return slidertable
			end

			-------------- Input --------------
			function sectiontable:Input(Info)
				Info = Info or {}
				Info.Text = Info.Text or "Input"
				Info.Flag = Info.Flag or nil
				Info.Callback = Info.Callback or function() end

				local frame, frameStroke = itemFrame("Input")
				frame.ClipsDescendants = true
				local textBox = new("TextBox", {
					Font = Enum.Font.GothamBold, PlaceholderColor3 = Theme.InputPlaceHolder, PlaceholderText = Info.Text, Text = "",
					TextColor3 = Theme.ItemText, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false,
					BackgroundTransparency = 1, Position = UDim2.new(0, 10, 0, 0), Size = UDim2.new(1, -20, 1, 0), Parent = frame
				})
				textBox.Focused:Connect(function() tween(frameStroke, .1, {Color = Theme.ItemUIStrokeSelected}, Enum.EasingStyle.Linear) end)
				textBox.FocusLost:Connect(function()
					tween(frameStroke, .1, {Color = Theme.ItemUIStroke}, Enum.EasingStyle.Linear)
					task.spawn(Info.Callback, textBox.Text)
					if Info.Flag ~= nil then library.Flags[Info.Flag] = textBox.Text end
				end)
			end

			-------------- Dropdown --------------
			function sectiontable:Dropdown(Info)
				Info = Info or {}
				Info.Text = Info.Text or "Dropdown"
				Info.Flag = Info.Flag or nil
				Info.Default = Info.Default or nil
				Info.List = Info.List or {}
				Info.Callback = Info.Callback or function() end
				Info.ChangeTextOnPick = Info.ChangeTextOnPick or false

				local insidedropdown = {}
				local frame, frameStroke = itemFrame("Dropdown")
				frame.ClipsDescendants = true

				local text = itemLabel(frame, Info.Text)
				text.Size = UDim2.new(1, -36, 0, 26)
				local icon = new("ImageLabel", {
					Image = ChevronAsset, ImageColor3 = Theme.DropdownIcon, BackgroundTransparency = 1,
					Position = UDim2.new(1, -23, 0, 5), Size = UDim2.new(0, 16, 0, 16), Rotation = 90, Parent = frame
				})
				new("Frame", {BackgroundColor3 = Theme.Lines, BorderSizePixel = 0, Position = UDim2.new(0, 6, 0, 26), Size = UDim2.new(1, -12, 0, 1), Parent = frame})

				local list = new("Frame", {BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 28), Size = UDim2.new(1, 0, 0, 0), Parent = frame})
				new("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Parent = list})

				local header = clickArea(frame, 26)

				local DropdownOpened = false
				local count, order = 0, 0
				local options = {}
				local Selected = Info.Default

				local function resize()
					tween(frame, .12, {Size = UDim2.new(1, 0, 0, DropdownOpened and (28 + count * 22 + 4) or 26)})
				end
				local function setOpen(v)
					DropdownOpened = v
					resize()
					tween(icon, .12, {Rotation = v and -90 or 90})
				end
				local function refreshColors()
					for name, b in pairs(options) do
						b.TextColor3 = (name == Selected) and Theme.Highlight or Theme.ItemText
					end
				end
				table.insert(closers, function() if DropdownOpened then setOpen(false) end end)

				header.MouseButton1Down:Connect(function() tween(frameStroke, .1, {Color = Theme.ItemUIStrokeSelected}, Enum.EasingStyle.Linear) end)
				header.MouseButton1Up:Connect(function() tween(frameStroke, .1, {Color = Theme.ItemUIStroke}, Enum.EasingStyle.Linear) end)
				header.MouseButton1Click:Connect(function() setOpen(not DropdownOpened) end)

				if Info.Default then
					task.spawn(Info.Callback, Info.Default)
					if Info.Flag then library.Flags[Info.Flag] = Info.Default end
					if Info.ChangeTextOnPick then text.Text = Info.Default end
				end

				function insidedropdown:Add(str)
					order = order + 1
					count = count + 1
					local b = new("TextButton", {
						Name = "dropdownElement", Font = Enum.Font.GothamBold, Text = str, TextSize = 12,
						TextColor3 = (str == Selected) and Theme.Highlight or Theme.ItemText, TextXAlignment = Enum.TextXAlignment.Left,
						AutoButtonColor = false, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 22), LayoutOrder = order, Parent = list
					})
					padding(b, 10, 0, 0, 0)
					options[str] = b

					b.MouseEnter:Connect(function() tween(b, .125, {TextColor3 = Theme.Highlight}, Enum.EasingStyle.Linear) end)
					b.MouseLeave:Connect(function()
						tween(b, .125, {TextColor3 = (str == Selected) and Theme.Highlight or Theme.ItemText}, Enum.EasingStyle.Linear)
					end)
					b.MouseButton1Click:Connect(function()
						Selected = str
						task.spawn(Info.Callback, str)
						if Info.Flag then library.Flags[Info.Flag] = str end
						if Info.ChangeTextOnPick then text.Text = str end
						refreshColors()
						setOpen(false)
					end)
					if DropdownOpened then resize() end
				end

				function insidedropdown:Remove(opt)
					local b = options[opt]
					if b then
						b:Destroy()
						options[opt] = nil
						count = count - 1
						if DropdownOpened then resize() end
					end
				end

				function insidedropdown:Clear()
					for name in pairs(options) do
						insidedropdown:Remove(name)
					end
				end

				for _, v in ipairs(Info.List) do
					insidedropdown:Add(v)
				end

				return insidedropdown
			end

			-------------- Toggle --------------
			function sectiontable:Toggle(Info)
				Info = Info or {}
				Info.Text = Info.Text or "Toggle"
				Info.Default = Info.Default or false
				Info.Flag = Info.Flag or nil
				Info.Callback = Info.Callback or function() end

				local toggletable = {}
				if Info.Flag then library.Flags[Info.Flag] = Info.Default end
				local Enabled = false

				local frame, frameStroke = itemFrame("Toggle")
				itemLabel(frame, Info.Text)

				local outer = new("Frame", {
					Name = "ToggleOuter", BackgroundColor3 = Theme.ToggleOuter, AnchorPoint = Vector2.new(1, .5),
					Position = UDim2.new(1, -8, .5, 0), Size = UDim2.new(0, 30, 0, 14), Parent = frame
				})
				corner(outer, 7)
				local outerStroke = stroke(outer, Theme.ToggleOuterUIStroke)
				local inner = new("ImageLabel", {
					Name = "toggleInner", Image = CircleAsset, ImageColor3 = Theme.ToggleInner, BackgroundTransparency = 1,
					Position = UDim2.new(0, 2, 0, 2), Size = UDim2.new(0, 10, 0, 10), Parent = outer
				})

				function toggletable:Set(bool)
					Enabled = bool
					if Info.Flag then library.Flags[Info.Flag] = bool end
					tween(outer, .125, {BackgroundColor3 = bool and Theme.ToggleOuterEnabled or Theme.ToggleOuter}, Enum.EasingStyle.Linear)
					tween(inner, .125, {ImageColor3 = bool and Theme.ToggleInnerEnabled or Theme.ToggleInner, Position = bool and UDim2.new(0, 18, 0, 2) or UDim2.new(0, 2, 0, 2)}, Enum.EasingStyle.Linear)
					tween(outerStroke, .125, {Color = bool and Theme.ToggleOuterUIStrokeEnabled or Theme.ToggleOuterUIStroke}, Enum.EasingStyle.Linear)
					task.spawn(Info.Callback, bool)
				end

				if Info.Default then toggletable:Set(true) end

				local btn = clickArea(frame)
				pressStroke(btn, frameStroke)
				btn.MouseButton1Click:Connect(function() toggletable:Set(not Enabled) end)

				return toggletable
			end

			-------------- Button --------------
			function sectiontable:Button(Info)
				Info = Info or {}
				Info.Text = Info.Text or "Button"
				Info.Callback = Info.Callback or function() end

				local frame, frameStroke = itemFrame("Button")
				new("TextLabel", {
					Font = Enum.Font.GothamBold, Text = Info.Text, TextColor3 = Theme.ItemText, TextSize = 12,
					BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Parent = frame
				})
				local btn = clickArea(frame)
				pressStroke(btn, frameStroke)
				btn.MouseButton1Click:Connect(function()
					task.spawn(Info.Callback)
				end)
			end

			return sectiontable
		end

		-- prima tab creata se selecteaza automat
		if not selectedTab then tabtable:Select() end

		return tabtable
	end

	return window
end

return library
