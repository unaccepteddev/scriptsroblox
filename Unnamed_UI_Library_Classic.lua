-- Unnamed UI Library - rebuilt from scratch
-- Preserves public API: Library:Window, Window:Tab, Tab:Section,
-- Section:Button/Toggle/Slider/Input/Dropdown/Keybind, Tab:Select,
-- Dropdown:Add/Remove/Clear, Slider:Set, Toggle:Set, Keybind:Set,
-- Window:Toggle/Destroy/SetWatermark/SetWatermarkVisible, Library:Notification

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

local Library = { Flags = {}, SectionsOpened = true, Theme = "Neon" }
Library.flags = Library.Flags
Library.theme = Library.Theme

local Themes = {
 Dark = {bg=Color3.fromRGB(28,29,33),panel=Color3.fromRGB(18,19,22),surface=Color3.fromRGB(25,26,30),line=Color3.fromRGB(72,73,80),text=Color3.fromRGB(226,226,232),muted=Color3.fromRGB(150,151,160),accent=Color3.fromRGB(91,190,207),accent2=Color3.fromRGB(155,110,230)},
 Neon = {bg=Color3.fromRGB(18,19,22),panel=Color3.fromRGB(12,13,16),surface=Color3.fromRGB(23,24,28),line=Color3.fromRGB(83,73,103),text=Color3.fromRGB(232,230,240),muted=Color3.fromRGB(155,150,171),accent=Color3.fromRGB(99,193,211),accent2=Color3.fromRGB(174,108,232)},
 ["Tokyo Night"] = {bg=Color3.fromRGB(29,22,54),panel=Color3.fromRGB(24,18,47),surface=Color3.fromRGB(32,24,60),line=Color3.fromRGB(83,65,125),text=Color3.fromRGB(238,231,255),muted=Color3.fromRGB(167,153,198),accent=Color3.fromRGB(111,198,218),accent2=Color3.fromRGB(205,92,150)},
 ["Starry Night"] = {bg=Color3.fromRGB(18,22,29),panel=Color3.fromRGB(13,16,22),surface=Color3.fromRGB(24,29,38),line=Color3.fromRGB(55,68,87),text=Color3.fromRGB(232,238,245),muted=Color3.fromRGB(146,160,177),accent=Color3.fromRGB(100,190,210),accent2=Color3.fromRGB(130,150,255)}
}
local function theme() return Themes[Library.Theme] or Themes.Neon end
local function create(class, props, parent)
 local obj=Instance.new(class)
 for k,v in pairs(props or {}) do obj[k]=v end
 if parent then obj.Parent=parent end
 return obj
end
local function round(obj, px) create("UICorner", {CornerRadius=UDim.new(0,px or 8)}, obj) end
local function outline(obj, color, transparency)
 return create("UIStroke", {Color=color or theme().line, Transparency=transparency or 0, Thickness=1}, obj)
end
local function pad(obj, l, r, t, b)
 create("UIPadding", {PaddingLeft=UDim.new(0,l or 0),PaddingRight=UDim.new(0,r or 0),PaddingTop=UDim.new(0,t or 0),PaddingBottom=UDim.new(0,b or 0)}, obj)
end
local function tw(obj, duration, props, style, direction)
 if not obj or not obj.Parent then return end
 local t=TweenService:Create(obj,TweenInfo.new(duration or .18,style or Enum.EasingStyle.Quart,direction or Enum.EasingDirection.Out),props)
 t:Play(); return t
end
local function label(parent, text, size, color, font)
 return create("TextLabel", {BackgroundTransparency=1,Text=text or "",TextColor3=color or theme().text,Font=font or Enum.Font.Gotham,TextSize=size or 12,TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Center,RichText=false}, parent)
end
local function button(parent, text, size)
 local b=create("TextButton",{AutoButtonColor=false,Text=text or "",TextColor3=theme().text,Font=Enum.Font.GothamMedium,TextSize=12,BackgroundColor3=theme().surface,BorderSizePixel=0,Size=size or UDim2.new(1,0,0,34)},parent)
 round(b,2); outline(b)
 b.MouseEnter:Connect(function() if b.Parent then tw(b,.12,{BackgroundColor3=theme().line}) end end)
 b.MouseLeave:Connect(function() if b.Parent then tw(b,.12,{BackgroundColor3=theme().surface}) end end)
 return b
end
local function setFlag(info, value)
 if info and info.Flag then Library.Flags[info.Flag]=value end
end

function Library:Notification(info)
 info=info or {}; local T=theme()
 local pg=LocalPlayer and LocalPlayer:FindFirstChildOfClass("PlayerGui")
 if not pg then return end
 local gui=pg:FindFirstChild("UnnamedNotifications")
 if not gui then gui=create("ScreenGui",{Name="UnnamedNotifications",ResetOnSpawn=false,IgnoreGuiInset=true},pg) end
 local holder=gui:FindFirstChild("Holder")
 if not holder then
  holder=create("Frame",{Name="Holder",BackgroundTransparency=1,AnchorPoint=Vector2.new(1,1),Position=UDim2.new(1,-18,1,-18),Size=UDim2.new(0,300,1,-36)},gui)
  create("UIListLayout",{HorizontalAlignment=Enum.HorizontalAlignment.Right,VerticalAlignment=Enum.VerticalAlignment.Bottom,Padding=UDim.new(0,8),SortOrder=Enum.SortOrder.LayoutOrder},holder)
 end
 local card=create("Frame",{BackgroundColor3=T.panel,BorderSizePixel=0,Size=UDim2.new(1,0,0,72)},holder); round(card,10); outline(card,T.accent)
 local bar=create("Frame",{BackgroundColor3=T.accent,BorderSizePixel=0,Size=UDim2.new(0,3,1,-18),Position=UDim2.new(0,8,0,9)},card); round(bar,2)
 local title=label(card,info.Title or "Notification",13,T.text,Enum.Font.GothamBold); title.Position=UDim2.new(0,20,0,8); title.Size=UDim2.new(1,-30,0,20)
 local desc=label(card,info.Description or info.Text or "",11,T.muted); desc.Position=UDim2.new(0,20,0,29); desc.Size=UDim2.new(1,-30,0,32); desc.TextWrapped=true
 card.Position=UDim2.new(0,24,0,0); card.BackgroundTransparency=1; tw(card,.22,{Position=UDim2.new(0,0,0,0),BackgroundTransparency=0})
 task.delay(tonumber(info.Duration) or 3,function() if card.Parent then tw(card,.18,{Position=UDim2.new(0,24,0,0),BackgroundTransparency=1}); task.wait(.2); if card.Parent then card:Destroy() end end end)
end

function Library:Window(info)
 info=info or {}; local T=theme()
 info.Text=info.Text or "Window"; info.ToggleKey=info.ToggleKey or Enum.KeyCode.RightShift
 local playerGui=LocalPlayer:WaitForChild("PlayerGui")
 local old=playerGui:FindFirstChild("UnnamedRebuiltUI"); if old then old:Destroy() end
 local gui=create("ScreenGui",{Name="UnnamedRebuiltUI",ResetOnSpawn=false,IgnoreGuiInset=true,ZIndexBehavior=Enum.ZIndexBehavior.Sibling},playerGui)
 local root=create("Frame",{Name="Root",AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=UDim2.fromOffset(900,520),BackgroundTransparency=1},gui)
 local scale=create("UIScale",{Scale=1},root)
 local main=create("Frame",{Name="Main",Size=UDim2.fromScale(1,1),BackgroundColor3=T.bg,BorderSizePixel=0,ClipsDescendants=true},root); round(main,3); outline(main,T.line)
 local top=create("Frame",{Name="Topbar",Size=UDim2.new(1,0,0,48),BackgroundColor3=T.panel,BorderSizePixel=0},main); round(top,3)
 create("Frame",{Name="AccentLine",BackgroundColor3=T.accent,BorderSizePixel=0,Size=UDim2.new(1,0,0,3),ZIndex=5},top)
 create("Frame",{BackgroundColor3=T.panel,BorderSizePixel=0,Position=UDim2.new(0,0,1,-8),Size=UDim2.new(1,0,0,8)},top)
 local logo=create("Frame",{Position=UDim2.new(0,17,.5,-5),Size=UDim2.fromOffset(10,10),Rotation=45,BackgroundColor3=T.accent,BorderSizePixel=0},top); round(logo,2)
 local title=label(top,info.Text,13,T.text,Enum.Font.GothamBold); title.Position=UDim2.new(0,38,0,0); title.Size=UDim2.new(0,240,1,0)
 local close=create("TextButton",{Text="×",Font=Enum.Font.Gotham,TextSize=25,TextColor3=T.text,BackgroundTransparency=1,AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,-12,.5,0),Size=UDim2.fromOffset(24,28)},top)
 local mini=create("TextButton",{Text="—",Font=Enum.Font.Gotham,TextSize=18,TextColor3=T.text,BackgroundTransparency=1,AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,-43,.5,0),Size=UDim2.fromOffset(24,28)},top)
 local profile=create("Frame",{BackgroundTransparency=1,Visible=false,AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,-75,.5,0),Size=UDim2.fromOffset(170,36)},top)
 local avatar=create("ImageLabel",{BackgroundColor3=T.surface,Size=UDim2.fromOffset(28,28),Position=UDim2.new(0,0,.5,-14),Image="",BorderSizePixel=0},profile); round(avatar,14); outline(avatar,T.accent)
 local display=label(profile,LocalPlayer.DisplayName,11,T.text,Enum.Font.GothamBold); display.Position=UDim2.new(0,36,0,1); display.Size=UDim2.new(1,-38,0,16); display.TextTruncate=Enum.TextTruncate.AtEnd
 local username=label(profile,"@"..LocalPlayer.Name,10,T.accent2); username.Position=UDim2.new(0,36,0,17); username.Size=UDim2.new(1,-38,0,14); username.TextTruncate=Enum.TextTruncate.AtEnd
 task.spawn(function() local ok,url=pcall(function() return Players:GetUserThumbnailAsync(LocalPlayer.UserId,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size100x100) end); if ok and avatar.Parent then avatar.Image=url end end)
 local tabsBar=create("ScrollingFrame",{Name="TabsBar",Position=UDim2.new(0,6,0,42),Size=UDim2.new(1,-12,0,30),BackgroundColor3=T.panel,BorderSizePixel=0,ScrollBarThickness=0,CanvasSize=UDim2.new(),AutomaticCanvasSize=Enum.AutomaticSize.X,ScrollingDirection=Enum.ScrollingDirection.X},main); round(tabsBar,3); pad(tabsBar,7,7,4,4)
 create("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal,Padding=UDim.new(0,6),SortOrder=Enum.SortOrder.LayoutOrder,VerticalAlignment=Enum.VerticalAlignment.Center},tabsBar)
 local sidebar=create("Frame",{Name="Sidebar",Position=UDim2.new(0,0,0,76),Size=UDim2.new(0,150,1,-98),BackgroundColor3=T.panel,BorderSizePixel=0},main)
 local sideLine=create("Frame",{BackgroundColor3=T.line,BorderSizePixel=0,Position=UDim2.new(1,-1,0,0),Size=UDim2.new(0,1,1,0)},sidebar)
 local sideCard=create("Frame",{BackgroundColor3=T.surface,BorderSizePixel=0,AnchorPoint=Vector2.new(.5,1),Position=UDim2.new(.5,0,1,-8),Size=UDim2.new(1,-16,0,48)},sidebar); round(sideCard,3)
 local sideAvatar=create("ImageLabel",{BackgroundColor3=T.bg,Position=UDim2.new(0,6,.5,-15),Size=UDim2.fromOffset(30,30),Image=avatar.Image,BorderSizePixel=0},sideCard); round(sideAvatar,15); outline(sideAvatar,T.accent)
 avatar:GetPropertyChangedSignal("Image"):Connect(function() sideAvatar.Image=avatar.Image end)
 local sideName=label(sideCard,LocalPlayer.DisplayName,10,T.text,Enum.Font.GothamBold); sideName.Position=UDim2.new(0,42,0,6); sideName.Size=UDim2.new(1,-46,0,16); sideName.TextTruncate=Enum.TextTruncate.AtEnd
 local sideUser=label(sideCard,"@"..LocalPlayer.Name,9,T.muted); sideUser.Position=UDim2.new(0,42,0,23); sideUser.Size=UDim2.new(1,-46,0,14); sideUser.TextTruncate=Enum.TextTruncate.AtEnd
 local content=create("Frame",{Name="Content",BackgroundTransparency=1,Position=UDim2.new(0,160,0,76),Size=UDim2.new(1,-170,1,-98),ClipsDescendants=true},main)
 local status=create("Frame",{Name="Statusbar",BackgroundColor3=T.panel,BorderSizePixel=0,Position=UDim2.new(0,0,1,-22),Size=UDim2.new(1,0,0,22)},main)
 local crumb=label(status,info.Text,10,T.muted); crumb.Position=UDim2.new(0,12,0,0); crumb.Size=UDim2.new(.7,0,1,0)
 local hint=label(status,"[RightShift] toggle UI",10,T.muted); hint.TextXAlignment=Enum.TextXAlignment.Right; hint.Position=UDim2.new(.7,0,0,0); hint.Size=UDim2.new(.3,-12,1,0)
 -- Compact floating watermark remains visible while UI is hidden/minimized.
 local wm=create("Frame",{Name="Watermark",Visible=false,BackgroundColor3=T.panel,BorderSizePixel=0,Position=UDim2.new(0,20,0,20),Size=UDim2.fromOffset(190,38),ZIndex=20},gui); round(wm,3); outline(wm,T.accent)
 local wmBar=create("Frame",{BackgroundColor3=T.accent,BorderSizePixel=0,Size=UDim2.new(0,3,1,-12),Position=UDim2.new(0,7,0,6),ZIndex=21},wm); round(wmBar,2)
 local wmText=label(wm,info.WatermarkText or info.Text,11,T.text,Enum.Font.GothamBold); wmText.Position=UDim2.new(0,17,0,3); wmText.Size=UDim2.new(1,-25,0,17); wmText.ZIndex=21
 local wmSub=label(wm,"@"..LocalPlayer.Name.."  •  ACTIVE",9,T.muted); wmSub.Position=UDim2.new(0,17,0,19); wmSub.Size=UDim2.new(1,-25,0,14); wmSub.ZIndex=21
 local wmDrag,wmStart,wmPos
 wm.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then wmDrag=true; wmStart=i.Position; wmPos=wm.Position end end)
 UIS.InputChanged:Connect(function(i) if wmDrag and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then local d=i.Position-wmStart; wm.Position=UDim2.new(wmPos.X.Scale,wmPos.X.Offset+d.X,wmPos.Y.Scale,wmPos.Y.Offset+d.Y) end end)
 UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then wmDrag=false end end)
 local wmEnabled=info.Watermark ~= false
 local fullSize=UDim2.fromOffset(900,520); local miniSize=UDim2.fromOffset(900,38)
 local minimized=false; local visible=true; local destroyed=false; local tabs={}; local selectedTab=nil; local connections={}
 local function connect(signal,fn) local c=signal:Connect(fn); table.insert(connections,c); return c end
 -- Drag window only from topbar, excluding buttons.
 local drag,dragStart,rootStart=false,nil,nil
 top.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then if i.Position.X < top.AbsolutePosition.X+top.AbsoluteSize.X-68 then drag=true; dragStart=i.Position; rootStart=root.Position end end end)
 UIS.InputChanged:Connect(function(i) if drag and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then local d=i.Position-dragStart; root.Position=UDim2.new(rootStart.X.Scale,rootStart.X.Offset+d.X,rootStart.Y.Scale,rootStart.Y.Offset+d.Y) end end)
 UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drag=false end end)
 local function setMinimized(state)
  if minimized==state then return end; minimized=state
  if state then
   wm.Visible=wmEnabled; content.Visible=false; tabsBar.Visible=false; sidebar.Visible=false; status.Visible=false
   tw(root,.24,{Size=miniSize},Enum.EasingStyle.Quart)
  else
   tw(root,.28,{Size=fullSize},Enum.EasingStyle.Quart)
   task.delay(.12,function() if root.Parent and not minimized then content.Visible=true; tabsBar.Visible=true; sidebar.Visible=true; status.Visible=true; wm.Visible=false end end)
  end
 end
 local function setVisible(state)
  visible=state
  if state then
   if minimized then setMinimized(false) end
   root.Visible=true; wm.Visible=false; scale.Scale=1
  else
   root.Visible=false; wm.Visible=wmEnabled
  end
 end
 close.MouseButton1Click:Connect(function() destroyed=true; gui:Destroy(); if wm.Parent then wm:Destroy() end end)
 mini.MouseButton1Click:Connect(function() setMinimized(not minimized) end)
 close.MouseEnter:Connect(function() tw(close,.1,{TextColor3=Color3.fromRGB(255,90,100)}) end); close.MouseLeave:Connect(function() tw(close,.1,{TextColor3=T.text}) end)
 mini.MouseEnter:Connect(function() tw(mini,.1,{TextColor3=T.accent}) end); mini.MouseLeave:Connect(function() tw(mini,.1,{TextColor3=T.text}) end)
 connect(UIS.InputBegan,function(i,processed) if i.KeyCode==info.ToggleKey then setVisible(not visible) end end)
 local window={}
 function window:SetWatermark(text) wmText.Text=tostring(text or info.Text) end
 function window:Toggle(bool) setVisible(bool==nil and not visible or bool) end
 function window:SetWatermarkVisible(bool) wmEnabled=bool and true or false; wm.Visible=wmEnabled and (not visible or minimized) end
 function window:Destroy() destroyed=true; for _,c in ipairs(connections) do pcall(function() c:Disconnect() end) end; gui:Destroy() end
 function window:Tab(tabInfo)
  tabInfo=tabInfo or {}; tabInfo.Text=tabInfo.Text or "Tab"
  local tab={}; local tabBtn=button(tabsBar,tabInfo.Text,UDim2.fromOffset(108,28)); tabBtn.LayoutOrder=#tabs+1
  local page=create("Frame",{Name="Page_"..tabInfo.Text,BackgroundTransparency=1,Size=UDim2.fromScale(1,1),Visible=false},content)
  local columns={}
  for _,side in ipairs({"Left","Right"}) do
   local col=create("ScrollingFrame",{Name=side,BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=3,ScrollBarImageColor3=T.accent,Position=side=="Left" and UDim2.new(0,6,0,6) or UDim2.new(.5,3,0,6),Size=UDim2.new(.5,-9,1,-12),CanvasSize=UDim2.new(),AutomaticCanvasSize=Enum.AutomaticSize.Y},page)
   create("UIListLayout",{Padding=UDim.new(0,5),SortOrder=Enum.SortOrder.LayoutOrder},col); pad(col,1,4,1,6); columns[side]=col
  end
  local entry={page=page,btn=tabBtn}; table.insert(tabs,entry)
  function tab:Select()
   for _,e in ipairs(tabs) do e.page.Visible=false; tw(e.btn,.12,{BackgroundColor3=T.surface,TextColor3=T.muted}) end
   selectedTab=entry; page.Visible=true; page.Position=UDim2.new(0,0,0,6); tw(page,.18,{Position=UDim2.new(0,0,0,0)}); tw(tabBtn,.14,{BackgroundColor3=T.accent,TextColor3=Color3.new(1,1,1)}); crumb.Text=tabInfo.Text
  end
  tabBtn.MouseButton1Click:Connect(function() tab:Select() end)
  function tab:Section(sectionInfo)
   sectionInfo=sectionInfo or {}; sectionInfo.Text=sectionInfo.Text or "Section"; sectionInfo.Side=sectionInfo.Side or "Left"
   local sec={}; local parent=columns[sectionInfo.Side] or columns.Left
   local frame=create("Frame",{Name="Section_"..sectionInfo.Text,BackgroundColor3=T.panel,BorderSizePixel=0,Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y},parent); round(frame,2); outline(frame,T.line)
   create("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,0)},frame)
   local header=create("TextButton",{Name="Header",Text="",AutoButtonColor=false,BackgroundColor3=T.panel,BorderSizePixel=0,Size=UDim2.new(1,0,0,26),LayoutOrder=1},frame); round(header,2)
   local accent=create("Frame",{BackgroundColor3=T.accent,BorderSizePixel=0,Position=UDim2.new(0,9,.5,-6),Size=UDim2.fromOffset(3,10)},header); round(accent,1)
   local secTitle=label(header,sectionInfo.Text,12,T.text,Enum.Font.GothamBold); secTitle.Position=UDim2.new(0,19,0,0); secTitle.Size=UDim2.new(1,-42,1,0)
   local arrow=label(header,"⌄",18,T.text); arrow.TextXAlignment=Enum.TextXAlignment.Center; arrow.Position=UDim2.new(1,-24,0,0); arrow.Size=UDim2.fromOffset(20,26)
   local body=create("Frame",{Name="Controls",BackgroundTransparency=1,BorderSizePixel=0,Size=UDim2.new(1,0,0,0),ClipsDescendants=true,LayoutOrder=2},frame)
   pad(body,6,6,0,6); local layout=create("UIListLayout",{Padding=UDim.new(0,3),SortOrder=Enum.SortOrder.LayoutOrder},body)
   local opened=sectionInfo.Opened==true or (sectionInfo.Opened==nil and Library.SectionsOpened==true); body.Visible=opened; arrow.Text=opened and "⌃" or "⌄"
   local function refreshBody() body.Size=UDim2.new(1,0,0,opened and (layout.AbsoluteContentSize.Y+6) or 0) end
   layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(refreshBody)
   local function setOpened(v) opened=v and true or false; refreshBody(); arrow.Text=opened and "⌃" or "⌄"; tw(arrow,.14,{TextColor3=T.accent}) end
   refreshBody()
   header.MouseButton1Click:Connect(function() setOpened(not opened) end)
   function sec:Select() setOpened(not opened) end
   local function row(height) local f=create("Frame",{BackgroundColor3=T.surface,BorderSizePixel=0,Size=UDim2.new(1,0,0,height or 34)},body); round(f,2); outline(f,T.line); return f end
   function sec:Button(ci)
    ci=ci or {}; local b=button(body,ci.Text or "Button",UDim2.new(1,0,0,34)); b.LayoutOrder=layout.AbsoluteContentSize.Y
    b.MouseButton1Click:Connect(function() if ci.Callback then task.spawn(ci.Callback) end end); return b
   end
   function sec:Toggle(ci)
    ci=ci or {}; local val=ci.Default==true; local f=row(36); local txt=label(f,ci.Text or "Toggle",12,T.text); txt.Position=UDim2.new(0,10,0,0); txt.Size=UDim2.new(1,-65,1,0)
    local track=create("Frame",{BackgroundColor3=val and T.accent or T.bg,Position=UDim2.new(1,-48,.5,-9),Size=UDim2.fromOffset(38,18),BorderSizePixel=0},f); round(track,10)
    local knob=create("Frame",{BackgroundColor3=Color3.new(1,1,1),Position=val and UDim2.new(1,-17,0,2) or UDim2.new(0,2,0,2),Size=UDim2.fromOffset(14,14),BorderSizePixel=0},track); round(knob,8)
    local hit=create("TextButton",{Text="",BackgroundTransparency=1,Size=UDim2.fromScale(1,1)},f)
    local function apply(v,callback) val=v and true or false; tw(track,.15,{BackgroundColor3=val and T.accent or T.bg}); tw(knob,.15,{Position=val and UDim2.new(1,-17,0,2) or UDim2.new(0,2,0,2)}); setFlag(ci,val); if callback and ci.Callback then ci.Callback(val) end end
    hit.MouseButton1Click:Connect(function() apply(not val,true) end); setFlag(ci,val)
    local obj={}; function obj:Set(v) apply(v,true) end; return obj
   end
   function sec:Slider(ci)
    ci=ci or {}; local min=tonumber(ci.Minimum) or 0; local max=tonumber(ci.Maximum) or 100; if max<=min then max=min+1 end
    local val=math.clamp(tonumber(ci.Default) or min,min,max); local f=row(52)
    local txt=label(f,ci.Text or "Slider",12,T.text); txt.Position=UDim2.new(0,10,0,3); txt.Size=UDim2.new(1,-65,0,20)
    local num=label(f,tostring(val),11,T.accent2); num.TextXAlignment=Enum.TextXAlignment.Right; num.Position=UDim2.new(1,-55,0,3); num.Size=UDim2.fromOffset(45,20)
    local rail=create("Frame",{BackgroundColor3=T.bg,Position=UDim2.new(0,10,0,31),Size=UDim2.new(1,-20,0,6),BorderSizePixel=0},f); round(rail,4)
    local fill=create("Frame",{BackgroundColor3=T.accent,Size=UDim2.new((val-min)/(max-min),0,1,0),BorderSizePixel=0},rail); round(fill,4)
    local hit=create("TextButton",{Text="",BackgroundTransparency=1,Size=UDim2.new(1,0,0,22),Position=UDim2.new(0,0,0,-8)},rail)
    local function apply(v,cb) val=math.clamp(v,min,max); local p=(val-min)/(max-min); fill.Size=UDim2.new(p,0,1,0); num.Text=tostring(math.floor(val*100+.5)/100); setFlag(ci,val); if cb and ci.Callback then ci.Callback(val) end end
    local sliding=false; hit.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then sliding=true; local p=math.clamp((i.Position.X-rail.AbsolutePosition.X)/rail.AbsoluteSize.X,0,1); apply(min+(max-min)*p,true) end end)
    UIS.InputChanged:Connect(function(i) if sliding and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then apply(min+(max-min)*math.clamp((i.Position.X-rail.AbsolutePosition.X)/rail.AbsoluteSize.X,0,1),true) end end)
    UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then sliding=false end end)
    setFlag(ci,val); local obj={}; function obj:Set(v) apply(tonumber(v) or min,true) end; return obj
   end
   function sec:Input(ci)
    ci=ci or {}; local f=row(36); local txt=label(f,ci.Text or "Input",12,T.text); txt.Position=UDim2.new(0,10,0,0); txt.Size=UDim2.new(.38,-8,1,0)
    local box=create("TextBox",{BackgroundColor3=T.bg,BorderSizePixel=0,Text="",PlaceholderText=ci.Placeholder or "Enter text...",PlaceholderColor3=T.muted,TextColor3=T.text,Font=Enum.Font.Gotham,TextSize=11,ClearTextOnFocus=false,Position=UDim2.new(.38,0,0,5),Size=UDim2.new(.62,-8,1,-10)},f); round(box,6); pad(box,7,7,0,0)
    box.FocusLost:Connect(function(enter) setFlag(ci,box.Text); if ci.Callback then ci.Callback(box.Text,enter) end end); return box
   end
   function sec:Keybind(ci)
    ci=ci or {}; local key=ci.Default or Enum.KeyCode.Unknown; local waiting=false; local f=row(36); local txt=label(f,ci.Text or "Keybind",12,T.text); txt.Position=UDim2.new(0,10,0,0); txt.Size=UDim2.new(1,-100,1,0)
    local kb=button(f,key.Name,UDim2.fromOffset(78,25)); kb.Position=UDim2.new(1,-86,.5,-12)
    local function set(k) key=k; kb.Text=k.Name; setFlag(ci,k) end
    kb.MouseButton1Click:Connect(function() waiting=true; kb.Text="..." end)
    local c=UIS.InputBegan:Connect(function(i,processed) if waiting and i.UserInputType==Enum.UserInputType.Keyboard then waiting=false; set(i.KeyCode) elseif not processed and i.KeyCode==key and ci.Callback then ci.Callback(key) end end)
    local obj={}; function obj:Set(k) set(k) end; setFlag(ci,key); return obj
   end
   function sec:Dropdown(ci)
    ci=ci or {}; local opts=ci.List or {}; local selected=nil; local expanded=false
    local f=create("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,34),AutomaticSize=Enum.AutomaticSize.Y},body)
    local head=button(f,ci.Text or "Dropdown  ▾",UDim2.new(1,0,0,34)); head.TextXAlignment=Enum.TextXAlignment.Left; pad(head,10,8,0,0)
    local list=create("Frame",{BackgroundColor3=T.panel,BorderSizePixel=0,Position=UDim2.new(0,0,0,38),Size=UDim2.new(1,0,0,0),Visible=false,ClipsDescendants=true},f); round(list,7); outline(list,T.line)
    local ll=create("UIListLayout",{Padding=UDim.new(0,3),SortOrder=Enum.SortOrder.LayoutOrder},list); pad(list,5,5,5,5)
    local function refresh() for _,ch in ipairs(list:GetChildren()) do if ch:IsA("TextButton") then ch:Destroy() end end
     for _,opt in ipairs(opts) do local ob=button(list,tostring(opt),UDim2.new(1,0,0,28)); ob.TextXAlignment=Enum.TextXAlignment.Left; pad(ob,8,6,0,0); ob.MouseButton1Click:Connect(function() selected=opt; head.Text=(ci.Text or "Dropdown")..": "..tostring(opt).."  ▾"; expanded=false; list.Visible=false; list.Size=UDim2.new(1,0,0,0); f.Size=UDim2.new(1,0,0,34); setFlag(ci,opt); if ci.Callback then ci.Callback(opt) end end) end
     if expanded then local h=math.min(#opts*31+10,155); list.Size=UDim2.new(1,0,0,h); f.Size=UDim2.new(1,0,0,42+h) end
    end
    head.MouseButton1Click:Connect(function() expanded=not expanded; list.Visible=expanded; if expanded then refresh() else list.Size=UDim2.new(1,0,0,0); f.Size=UDim2.new(1,0,0,34) end end)
    local obj={}; function obj:Add(v) table.insert(opts,v); if expanded then refresh() end end
    function obj:Remove(v) for i=#opts,1,-1 do if opts[i]==v then table.remove(opts,i) end end; if selected==v then selected=nil; head.Text=ci.Text or "Dropdown" end; if expanded then refresh() end end
    function obj:Clear() table.clear(opts); selected=nil; head.Text=ci.Text or "Dropdown"; refresh() end
    return obj
   end
   return sec
  end
  if #tabs==1 then tab:Select() end
  return tab
 end
 function window:Toggle(bool) setVisible(bool==nil and not visible or bool) end
 return window
end

return Library
