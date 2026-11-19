-- lang: Luau | target: Roblox Universal | Synapse X / KRNL / Fluxus
-- ZXC v2: yatay GUI · G toggle · ESP renk · FOV dairesi · sliderlar · server TP

local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInput  = game:GetService("UserInputService")
local TweenSvc   = game:GetService("TweenService")
local Camera     = workspace.CurrentCamera

local lp = Players.LocalPlayer

-- ══════════════════════════════════════════════
-- AYARLAR
-- ══════════════════════════════════════════════
local Cfg = {
    espEnabled    = false,
    espColor      = Color3.fromRGB(255, 50, 50),
    showFOV       = false,
    aimbotEnabled = false,
    aimbotFOV     = 150,
    aimbotSmooth  = 0.2,
    flyEnabled    = false,
    flySpeed      = 60,
    noclipEnabled = false,
    walkSpeed     = 16,
    jumpPower     = 50,
    infJump       = false,
    killAura      = false,
    killRange     = 20,
}

local flyBody       = {}
local espHighlights = {}
local prevFly       = false
local guiOpen       = true

local function getChar() return lp.Character end
local function getHRP()
    local c = getChar(); return c and c:FindFirstChild("HumanoidRootPart")
end
local function getHum()
    local c = getChar(); return c and c:FindFirstChildOfClass("Humanoid")
end

lp.CharacterAdded:Connect(function()
    for _, h in pairs(espHighlights) do h:Destroy() end
    espHighlights = {}
    prevFly = false
    flyBody = {}
end)

-- ══════════════════════════════════════════════
-- GUI TEMEL — 600x320 yatay dikdörtgen
-- ══════════════════════════════════════════════
local sg = Instance.new("ScreenGui")
sg.Name           = "ZXCv2"
sg.ResetOnSpawn   = false
sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
sg.Parent         = game:GetService("CoreGui")

local W, H = 600, 320

local Main = Instance.new("Frame")
Main.Size              = UDim2.new(0, W, 0, H)
Main.Position          = UDim2.new(0.5, -W/2, 0.5, -H/2)
Main.BackgroundColor3  = Color3.fromRGB(13, 13, 20)
Main.BorderSizePixel   = 0
Main.ClipsDescendants  = true
Main.Parent            = sg

local mc = Instance.new("UICorner")
mc.CornerRadius = UDim.new(0, 10)
mc.Parent       = Main

-- Stroke (ince mor çerçeve)
local stroke = Instance.new("UIStroke")
stroke.Color     = Color3.fromRGB(90, 60, 200)
stroke.Thickness = 1.2
stroke.Transparency = 0.4
stroke.Parent   = Main

-- Başlık çubuğu
local TitleBar = Instance.new("Frame")
TitleBar.Size             = UDim2.new(1, 0, 0, 30)
TitleBar.BackgroundColor3 = Color3.fromRGB(90, 60, 200)
TitleBar.BorderSizePixel  = 0
TitleBar.Parent           = Main

local tbc = Instance.new("UICorner")
tbc.CornerRadius = UDim.new(0, 10)
tbc.Parent       = TitleBar

local tbfix = Instance.new("Frame") -- alt köşeleri düzelt
tbfix.Size             = UDim2.new(1,0,0.5,0)
tbfix.Position         = UDim2.new(0,0,0.5,0)
tbfix.BackgroundColor3 = Color3.fromRGB(90, 60, 200)
tbfix.BorderSizePixel  = 0
tbfix.Parent           = TitleBar

local TitleTxt = Instance.new("TextLabel")
TitleTxt.Size               = UDim2.new(1,-16,1,0)
TitleTxt.Position           = UDim2.new(0,14,0,0)
TitleTxt.BackgroundTransparency = 1
TitleTxt.TextColor3         = Color3.fromRGB(255,255,255)
TitleTxt.Font               = Enum.Font.GothamBold
TitleTxt.TextSize           = 13
TitleTxt.TextXAlignment     = Enum.TextXAlignment.Left
TitleTxt.Text               = "ZXC MENU  ·  G = aç/kapat"
TitleTxt.Parent             = TitleBar

-- Sürükleme
local dragging, dragStart, dragBase
TitleBar.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true; dragStart = inp.Position; dragBase = Main.Position
    end
end)
TitleBar.InputEnded:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)
UserInput.InputChanged:Connect(function(inp)
    if dragging and inp.UserInputType == Enum.UserInputType.MouseMove then
        local d = inp.Position - dragStart
        Main.Position = UDim2.new(dragBase.X.Scale, dragBase.X.Offset+d.X,
                                   dragBase.Y.Scale, dragBase.Y.Offset+d.Y)
    end
end)

-- ══════════════════════════════════════════════
-- SOL TAB ÇUBUĞU — 115px
-- ══════════════════════════════════════════════
local TabBar = Instance.new("Frame")
TabBar.Size             = UDim2.new(0, 115, 1, -30)
TabBar.Position         = UDim2.new(0,0,0,30)
TabBar.BackgroundColor3 = Color3.fromRGB(9, 9, 15)
TabBar.BorderSizePixel  = 0
TabBar.Parent           = Main

local tLayout = Instance.new("UIListLayout")
tLayout.Padding   = UDim.new(0,3)
tLayout.SortOrder = Enum.SortOrder.LayoutOrder
tLayout.Parent    = TabBar

local tPad = Instance.new("UIPadding")
tPad.PaddingTop   = UDim.new(0,10)
tPad.PaddingLeft  = UDim.new(0,8)
tPad.PaddingRight = UDim.new(0,8)
tPad.Parent       = TabBar

local divLine = Instance.new("Frame")
divLine.Size             = UDim2.new(0,1,1,-30)
divLine.Position         = UDim2.new(0,115,0,30)
divLine.BackgroundColor3 = Color3.fromRGB(40,40,65)
divLine.BorderSizePixel  = 0
divLine.Parent           = Main

-- ══════════════════════════════════════════════
-- SAĞ İÇERİK ALANI
-- ══════════════════════════════════════════════
local ContentArea = Instance.new("Frame")
ContentArea.Size               = UDim2.new(1,-116,1,-30)
ContentArea.Position           = UDim2.new(0,116,0,30)
ContentArea.BackgroundTransparency = 1
ContentArea.ClipsDescendants   = true
ContentArea.Parent             = Main

-- ══════════════════════════════════════════════
-- UI YARDIMCILARI
-- ══════════════════════════════════════════════
local function MakeTabFrame()
    local sf = Instance.new("ScrollingFrame")
    sf.Size                = UDim2.new(1,0,1,0)
    sf.BackgroundTransparency = 1
    sf.BorderSizePixel     = 0
    sf.ScrollBarThickness  = 3
    sf.ScrollBarImageColor3 = Color3.fromRGB(90,60,200)
    sf.AutomaticCanvasSize = Enum.AutomaticSize.Y
    sf.CanvasSize          = UDim2.new(0,0,0,0)
    sf.Visible             = false
    sf.Parent              = ContentArea

    local ll = Instance.new("UIListLayout")
    ll.Padding   = UDim.new(0,5)
    ll.SortOrder = Enum.SortOrder.LayoutOrder
    ll.Parent    = sf

    local pp = Instance.new("UIPadding")
    pp.PaddingTop   = UDim.new(0,10)
    pp.PaddingLeft  = UDim.new(0,10)
    pp.PaddingRight = UDim.new(0,14)
    pp.Parent       = sf

    return sf
end

local function MakeHeader(parent, text)
    local f = Instance.new("TextLabel")
    f.Size               = UDim2.new(1,0,0,14)
    f.BackgroundTransparency = 1
    f.TextColor3         = Color3.fromRGB(90,60,200)
    f.Font               = Enum.Font.GothamBold
    f.TextSize           = 10
    f.TextXAlignment     = Enum.TextXAlignment.Left
    f.Text               = text:upper()
    f.Parent             = parent
    return f
end

local function MakeToggle(parent, label, getState, setState)
    local row = Instance.new("Frame")
    row.Size             = UDim2.new(1,0,0,30)
    row.BackgroundColor3 = Color3.fromRGB(20,20,30)
    row.BorderSizePixel  = 0
    row.Parent           = parent

    local rc = Instance.new("UICorner"); rc.CornerRadius = UDim.new(0,6); rc.Parent = row

    local lbl = Instance.new("TextLabel")
    lbl.Size               = UDim2.new(1,-52,1,0)
    lbl.Position           = UDim2.new(0,10,0,0)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3         = Color3.fromRGB(205,205,205)
    lbl.Font               = Enum.Font.Gotham
    lbl.TextSize           = 12
    lbl.TextXAlignment     = Enum.TextXAlignment.Left
    lbl.Text               = label
    lbl.Parent             = row

    local pill = Instance.new("Frame")
    pill.Size            = UDim2.new(0,36,0,18)
    pill.Position        = UDim2.new(1,-44,0.5,-9)
    pill.BackgroundColor3 = Color3.fromRGB(45,45,65)
    pill.BorderSizePixel = 0
    pill.Parent          = row

    local pc = Instance.new("UICorner"); pc.CornerRadius = UDim.new(1,0); pc.Parent = pill

    local knob = Instance.new("Frame")
    knob.Size            = UDim2.new(0,14,0,14)
    knob.Position        = UDim2.new(0,2,0.5,-7)
    knob.BackgroundColor3 = Color3.fromRGB(170,170,170)
    knob.BorderSizePixel = 0
    knob.Parent          = pill

    local kc = Instance.new("UICorner"); kc.CornerRadius = UDim.new(1,0); kc.Parent = knob

    local function refresh()
        local on = getState()
        TweenSvc:Create(pill, TweenInfo.new(0.14),{
            BackgroundColor3 = on and Color3.fromRGB(90,60,200) or Color3.fromRGB(45,45,65)
        }):Play()
        TweenSvc:Create(knob, TweenInfo.new(0.14),{
            Position         = on and UDim2.new(1,-16,0.5,-7) or UDim2.new(0,2,0.5,-7),
            BackgroundColor3 = on and Color3.fromRGB(255,255,255) or Color3.fromRGB(170,170,170)
        }):Play()
    end

    local btn = Instance.new("TextButton")
    btn.Size               = UDim2.new(1,0,1,0)
    btn.BackgroundTransparency = 1
    btn.Text               = ""; btn.Parent = row

    btn.MouseButton1Click:Connect(function()
        setState(not getState()); refresh()
    end)
    refresh()
    return row
end

local function MakeSlider(parent, label, minV, maxV, defV, isFloat, cb)
    local container = Instance.new("Frame")
    container.Size             = UDim2.new(1,0,0,48)
    container.BackgroundColor3 = Color3.fromRGB(20,20,30)
    container.BorderSizePixel  = 0
    container.Parent           = parent

    local cc = Instance.new("UICorner"); cc.CornerRadius = UDim.new(0,6); cc.Parent = container

    local fmt = function(v)
        return isFloat and string.format("%.2f", v) or tostring(math.floor(v))
    end

    local lbl = Instance.new("TextLabel")
    lbl.Size               = UDim2.new(1,-10,0,18)
    lbl.Position           = UDim2.new(0,10,0,6)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3         = Color3.fromRGB(205,205,205)
    lbl.Font               = Enum.Font.Gotham
    lbl.TextSize           = 11
    lbl.TextXAlignment     = Enum.TextXAlignment.Left
    lbl.Text               = label .. ":  " .. fmt(defV)
    lbl.Parent             = container

    local track = Instance.new("Frame")
    track.Size             = UDim2.new(1,-20,0,5)
    track.Position         = UDim2.new(0,10,0,33)
    track.BackgroundColor3 = Color3.fromRGB(38,38,58)
    track.BorderSizePixel  = 0
    track.Parent           = container

    local tc = Instance.new("UICorner"); tc.CornerRadius = UDim.new(1,0); tc.Parent = track

    local pct  = (defV-minV)/(maxV-minV)
    local fill = Instance.new("Frame")
    fill.Size             = UDim2.new(pct,0,1,0)
    fill.BackgroundColor3 = Color3.fromRGB(90,60,200)
    fill.BorderSizePixel  = 0
    fill.Parent           = track

    local fc = Instance.new("UICorner"); fc.CornerRadius = UDim.new(1,0); fc.Parent = fill

    local handle = Instance.new("Frame")
    handle.Size             = UDim2.new(0,13,0,13)
    handle.Position         = UDim2.new(pct,-6,0.5,-6)
    handle.BackgroundColor3 = Color3.fromRGB(220,220,220)
    handle.BorderSizePixel  = 0
    handle.Parent           = track

    local hc = Instance.new("UICorner"); hc.CornerRadius = UDim.new(1,0); hc.Parent = handle

    local hitbox = Instance.new("TextButton")
    hitbox.Size               = UDim2.new(1,0,0,26)
    hitbox.Position           = UDim2.new(0,0,0.5,-13)
    hitbox.BackgroundTransparency = 1
    hitbox.Text               = ""
    hitbox.Parent             = track

    local draggingSlider = false
    hitbox.MouseButton1Down:Connect(function() draggingSlider = true end)
    UserInput.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingSlider = false
        end
    end)
    UserInput.InputChanged:Connect(function(inp)
        if not draggingSlider then return end
        if inp.UserInputType ~= Enum.UserInputType.MouseMove then return end
        local t  = math.clamp((inp.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        local v  = isFloat and (minV + t*(maxV-minV)) or math.floor(minV + t*(maxV-minV))
        fill.Size       = UDim2.new(t,0,1,0)
        handle.Position = UDim2.new(t,-6,0.5,-6)
        lbl.Text        = label .. ":  " .. fmt(v)
        cb(v)
    end)
    return container
end

local function MakeButton(parent, label, cb)
    local btn = Instance.new("TextButton")
    btn.Size             = UDim2.new(1,0,0,30)
    btn.BackgroundColor3 = Color3.fromRGB(90,60,200)
    btn.TextColor3       = Color3.fromRGB(255,255,255)
    btn.Font             = Enum.Font.GothamBold
    btn.TextSize         = 12
    btn.Text             = label
    btn.BorderSizePixel  = 0
    btn.Parent           = parent

    local bc = Instance.new("UICorner"); bc.CornerRadius = UDim.new(0,6); bc.Parent = btn
    btn.MouseEnter:Connect(function()
        TweenSvc:Create(btn,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(110,80,235)}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenSvc:Create(btn,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(90,60,200)}):Play()
    end)
    btn.MouseButton1Click:Connect(cb)
    return btn
end

-- ══════════════════════════════════════════════
-- TAB SİSTEMİ
-- ══════════════════════════════════════════════
local tabFrames  = {}
local tabBtns    = {}
local activeTab  = nil

local function SwitchTab(name)
    for n, f in pairs(tabFrames) do f.Visible = (n == name) end
    for n, b in pairs(tabBtns)   do
        if n == name then
            b.BackgroundTransparency = 0
            b.BackgroundColor3       = Color3.fromRGB(90,60,200)
            b.TextColor3             = Color3.fromRGB(255,255,255)
        else
            b.BackgroundTransparency = 1
            b.TextColor3             = Color3.fromRGB(135,135,155)
        end
    end
    activeTab = name
end

local function AddTab(name, icon)
    local sf = MakeTabFrame()
    tabFrames[name] = sf

    local btn = Instance.new("TextButton")
    btn.Size               = UDim2.new(1,0,0,34)
    btn.BackgroundTransparency = 1
    btn.TextColor3         = Color3.fromRGB(135,135,155)
    btn.Font               = Enum.Font.Gotham
    btn.TextSize           = 12
    btn.Text               = icon .. "  " .. name
    btn.TextXAlignment     = Enum.TextXAlignment.Left
    btn.BorderSizePixel    = 0
    btn.Parent             = TabBar

    local bc = Instance.new("UICorner"); bc.CornerRadius = UDim.new(0,6); bc.Parent = btn
    tabBtns[name] = btn

    btn.MouseButton1Click:Connect(function() SwitchTab(name) end)
    btn.MouseEnter:Connect(function()
        if activeTab ~= name then
            TweenSvc:Create(btn,TweenInfo.new(0.1),{
                BackgroundTransparency = 0.82,
                BackgroundColor3 = Color3.fromRGB(90,60,200)
            }):Play()
        end
    end)
    btn.MouseLeave:Connect(function()
        if activeTab ~= name then
            TweenSvc:Create(btn,TweenInfo.new(0.1),{BackgroundTransparency=1}):Play()
        end
    end)
    return sf
end

-- ══════════════════════════════════════════════
-- ─── ESP TAB ──────────────────────────────────
-- ══════════════════════════════════════════════
local espTab = AddTab("ESP", "👁")
MakeHeader(espTab, "görünürlük")
MakeToggle(espTab, "ESP (Duvardan Görme)", function() return Cfg.espEnabled end,
    function(v) Cfg.espEnabled = v end)

-- Renk seçici
local colorRow = Instance.new("Frame")
colorRow.Size             = UDim2.new(1,0,0,36)
colorRow.BackgroundColor3 = Color3.fromRGB(20,20,30)
colorRow.BorderSizePixel  = 0
colorRow.Parent           = espTab

local crc = Instance.new("UICorner"); crc.CornerRadius = UDim.new(0,6); crc.Parent = colorRow

local crLbl = Instance.new("TextLabel")
crLbl.Size               = UDim2.new(0,66,1,0)
crLbl.Position           = UDim2.new(0,10,0,0)
crLbl.BackgroundTransparency = 1
crLbl.TextColor3         = Color3.fromRGB(205,205,205)
crLbl.Font               = Enum.Font.Gotham
crLbl.TextSize           = 11
crLbl.TextXAlignment     = Enum.TextXAlignment.Left
crLbl.Text               = "ESP Renk"
crLbl.Parent             = colorRow

local colorPalette = {
    Color3.fromRGB(255,50,50),
    Color3.fromRGB(50,230,100),
    Color3.fromRGB(50,140,255),
    Color3.fromRGB(255,215,45),
    Color3.fromRGB(255,255,255),
    Color3.fromRGB(180,50,255),
    Color3.fromRGB(255,120,30),
}

local selectedDot = nil

for i, c in ipairs(colorPalette) do
    local dot = Instance.new("TextButton")
    dot.Size             = UDim2.new(0,19,0,19)
    dot.Position         = UDim2.new(0, 76+(i-1)*25, 0.5, -9)
    dot.BackgroundColor3 = c
    dot.Text             = ""
    dot.BorderSizePixel  = 2
    dot.BorderColor3     = Color3.fromRGB(0,0,0)
    dot.Parent           = colorRow

    local dc = Instance.new("UICorner"); dc.CornerRadius = UDim.new(1,0); dc.Parent = dot

    dot.MouseButton1Click:Connect(function()
        Cfg.espColor = c
        for _, h in pairs(espHighlights) do
            h.FillColor = c; h.OutlineColor = c
        end
        if selectedDot then selectedDot.BorderColor3 = Color3.fromRGB(0,0,0) end
        dot.BorderColor3 = Color3.fromRGB(255,255,255)
        selectedDot = dot
    end)
end

-- ══════════════════════════════════════════════
-- ─── AİMBOT TAB ───────────────────────────────
-- ══════════════════════════════════════════════
local aimbotTab = AddTab("Aimbot", "🎯")
MakeHeader(aimbotTab, "hedefleme")
MakeToggle(aimbotTab, "Aimbot  (Sağ Tık)", function() return Cfg.aimbotEnabled end,
    function(v) Cfg.aimbotEnabled = v end)
MakeToggle(aimbotTab, "FOV Dairesi", function() return Cfg.showFOV end,
    function(v) Cfg.showFOV = v end)
MakeSlider(aimbotTab, "FOV Yarıçapı (px)", 30, 500, Cfg.aimbotFOV, false, function(v)
    Cfg.aimbotFOV = v
end)
MakeSlider(aimbotTab, "Smooth  (düşük = hızlı)", 0.02, 0.6, Cfg.aimbotSmooth, true, function(v)
    Cfg.aimbotSmooth = v
end)

-- ══════════════════════════════════════════════
-- ─── HAREKET TAB ──────────────────────────────
-- ══════════════════════════════════════════════
local moveTab = AddTab("Hareket", "🏃")
MakeHeader(moveTab, "fly")
MakeToggle(moveTab, "Fly  (W/A/S/D + Space/Shift)", function() return Cfg.flyEnabled end,
    function(v) Cfg.flyEnabled = v end)
MakeSlider(moveTab, "Fly Hızı", 20, 300, Cfg.flySpeed, false, function(v)
    Cfg.flySpeed = v
end)
MakeHeader(moveTab, "zemin")
MakeToggle(moveTab, "Noclip", function() return Cfg.noclipEnabled end,
    function(v) Cfg.noclipEnabled = v end)
MakeToggle(moveTab, "Sonsuz Zıplama", function() return Cfg.infJump end,
    function(v) Cfg.infJump = v end)
MakeSlider(moveTab, "WalkSpeed", 16, 500, Cfg.walkSpeed, false, function(v)
    Cfg.walkSpeed = v
    local h = getHum(); if h then h.WalkSpeed = v end
end)
MakeSlider(moveTab, "JumpPower", 7, 300, Cfg.jumpPower, false, function(v)
    Cfg.jumpPower = v
    local h = getHum(); if h then h.JumpPower = v end
end)

-- ══════════════════════════════════════════════
-- ─── OYUNCULAR TAB ────────────────────────────
-- ══════════════════════════════════════════════
local playersTab = AddTab("Oyuncular", "👥")
MakeHeader(playersTab, "kill aura")
MakeToggle(playersTab, "Kill Aura", function() return Cfg.killAura end,
    function(v) Cfg.killAura = v end)
MakeSlider(playersTab, "Kill Range (studs)", 5, 100, Cfg.killRange, false, function(v)
    Cfg.killRange = v
end)
MakeHeader(playersTab, "toplu teleport")
MakeButton(playersTab, "⬇  Herkesi Yanıma Çek", function()
    local hrp = getHRP(); if not hrp then return end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= lp and plr.Character then
            local ehr = plr.Character:FindFirstChild("HumanoidRootPart")
            if ehr then
                ehr.CFrame = hrp.CFrame + Vector3.new(math.random(-5,5),0,math.random(-5,5))
            end
        end
    end
end)
MakeButton(playersTab, "🎲  Rastgele Birine TP Git", function()
    local pool = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= lp and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            table.insert(pool, plr)
        end
    end
    if #pool == 0 then return end
    local t   = pool[math.random(1,#pool)]
    local hrp = getHRP()
    if hrp then
        hrp.CFrame = t.Character.HumanoidRootPart.CFrame + Vector3.new(2,0,0)
    end
end)

MakeHeader(playersTab, "liste — tek tek TP")

local playerListHolder = Instance.new("Frame")
playerListHolder.Size               = UDim2.new(1,0,0,0)
playerListHolder.AutomaticSize      = Enum.AutomaticSize.Y
playerListHolder.BackgroundTransparency = 1
playerListHolder.Parent             = playersTab

local plListLayout = Instance.new("UIListLayout")
plListLayout.Padding   = UDim.new(0,4)
plListLayout.SortOrder = Enum.SortOrder.LayoutOrder
plListLayout.Parent    = playerListHolder

local function RefreshPlayerList()
    for _, c in ipairs(playerListHolder:GetChildren()) do
        if not c:IsA("UIListLayout") then c:Destroy() end
    end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= lp then
            local row = Instance.new("Frame")
            row.Size             = UDim2.new(1,0,0,28)
            row.BackgroundColor3 = Color3.fromRGB(20,20,30)
            row.BorderSizePixel  = 0
            row.Parent           = playerListHolder

            local rc = Instance.new("UICorner"); rc.CornerRadius = UDim.new(0,5); rc.Parent = row

            local nameLbl = Instance.new("TextLabel")
            nameLbl.Size               = UDim2.new(1,-68,1,0)
            nameLbl.Position           = UDim2.new(0,8,0,0)
            nameLbl.BackgroundTransparency = 1
            nameLbl.TextColor3         = Color3.fromRGB(205,205,205)
            nameLbl.Font               = Enum.Font.Gotham
            nameLbl.TextSize           = 11
            nameLbl.TextXAlignment     = Enum.TextXAlignment.Left
            nameLbl.Text               = plr.DisplayName .. "  (@" .. plr.Name .. ")"
            nameLbl.TextTruncate       = Enum.TextTruncate.AtEnd
            nameLbl.Parent             = row

            local tpBtn = Instance.new("TextButton")
            tpBtn.Size             = UDim2.new(0,56,0,20)
            tpBtn.Position         = UDim2.new(1,-62,0.5,-10)
            tpBtn.BackgroundColor3 = Color3.fromRGB(90,60,200)
            tpBtn.TextColor3       = Color3.fromRGB(255,255,255)
            tpBtn.Font             = Enum.Font.GothamBold
            tpBtn.TextSize         = 10
            tpBtn.Text             = "TP Git"
            tpBtn.BorderSizePixel  = 0
            tpBtn.Parent           = row

            local tc = Instance.new("UICorner"); tc.CornerRadius = UDim.new(0,4); tc.Parent = tpBtn

            local capturedPlr = plr
            tpBtn.MouseButton1Click:Connect(function()
                local hrp = getHRP()
                if hrp and capturedPlr.Character and
                   capturedPlr.Character:FindFirstChild("HumanoidRootPart") then
                    hrp.CFrame = capturedPlr.Character.HumanoidRootPart.CFrame + Vector3.new(2,0,0)
                end
            end)
        end
    end
end

MakeButton(playersTab, "🔄  Listeyi Yenile", function() RefreshPlayerList() end)
RefreshPlayerList()

-- İlk tab
SwitchTab("ESP")

-- ══════════════════════════════════════════════
-- G TUŞU — SMOOTH SLIDE TOGGLE
-- ══════════════════════════════════════════════
local openY  = Main.Position.Y.Offset
local closeY = openY - H - 30

UserInput.InputBegan:Connect(function(inp, gpe)
    if gpe then return end
    if inp.KeyCode == Enum.KeyCode.G then
        guiOpen = not guiOpen
        TweenSvc:Create(Main, TweenInfo.new(0.28, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Position = UDim2.new(
                Main.Position.X.Scale, Main.Position.X.Offset,
                Main.Position.Y.Scale, guiOpen and openY or closeY
            )
        }):Play()
    end
end)

-- ══════════════════════════════════════════════
-- FOV DAİRESİ (Drawing API)
-- ══════════════════════════════════════════════
local fovCircle = nil
pcall(function()
    fovCircle           = Drawing.new("Circle")
    fovCircle.Visible   = false
    fovCircle.Thickness = 1.5
    fovCircle.Color     = Color3.fromRGB(255,255,255)
    fovCircle.Filled    = false
    fovCircle.NumSides  = 64
end)

-- ══════════════════════════════════════════════
-- FLY
-- ══════════════════════════════════════════════
local function EnableFly()
    local hrp = getHRP(); if not hrp then return end
    local bv = Instance.new("BodyVelocity")
    bv.Velocity = Vector3.zero; bv.MaxForce = Vector3.new(1e5,1e5,1e5); bv.Parent = hrp
    local bg = Instance.new("BodyGyro")
    bg.MaxTorque = Vector3.new(1e5,1e5,1e5); bg.D = 50; bg.Parent = hrp
    flyBody = {bv=bv, bg=bg}
    local h = getHum(); if h then h.PlatformStand = true end
end

local function DisableFly()
    if flyBody.bv then flyBody.bv:Destroy() end
    if flyBody.bg then flyBody.bg:Destroy() end
    flyBody = {}
    local h = getHum(); if h then h.PlatformStand = false end
end

-- ══════════════════════════════════════════════
-- ESP GÜNCELLE
-- ══════════════════════════════════════════════
local function UpdateESP()
    for pid, h in pairs(espHighlights) do
        local plr = Players:GetPlayerByUserId(pid)
        if not plr or not plr.Character or not Cfg.espEnabled then
            h:Destroy(); espHighlights[pid] = nil
        end
    end
    if not Cfg.espEnabled then return end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= lp and plr.Character then
            if not espHighlights[plr.UserId] then
                local h = Instance.new("Highlight")
                h.FillColor           = Cfg.espColor
                h.OutlineColor        = Cfg.espColor
                h.FillTransparency    = 0.65
                h.OutlineTransparency = 0
                h.DepthMode           = Enum.HighlightDepthMode.AlwaysOnTop
                h.Adornee             = plr.Character
                h.Parent              = workspace
                espHighlights[plr.UserId] = h
            else
                espHighlights[plr.UserId].FillColor    = Cfg.espColor
                espHighlights[plr.UserId].OutlineColor = Cfg.espColor
            end
        end
    end
end

-- ══════════════════════════════════════════════
-- AİMBOT — HEDEF
-- ══════════════════════════════════════════════
local function GetTarget()
    local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    local best, bd = nil, math.huge
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= lp and plr.Character then
            local head = plr.Character:FindFirstChild("Head")
            if head then
                local sp, onScreen = Camera:WorldToScreenPoint(head.Position)
                if onScreen then
                    local d = (Vector2.new(sp.X,sp.Y) - center).Magnitude
                    if d < Cfg.aimbotFOV and d < bd then bd=d; best=head end
                end
            end
        end
    end
    return best
end

-- ══════════════════════════════════════════════
-- SONSUZ ZIPLAMAMA
-- ══════════════════════════════════════════════
UserInput.JumpRequest:Connect(function()
    if Cfg.infJump then
        local h = getHum()
        if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

-- ══════════════════════════════════════════════
-- RENDERSTEPPED
-- ══════════════════════════════════════════════
RunService.RenderStepped:Connect(function()
    UpdateESP()

    if Cfg.flyEnabled ~= prevFly then
        if Cfg.flyEnabled then EnableFly() else DisableFly() end
        prevFly = Cfg.flyEnabled
    end

    if Cfg.flyEnabled and flyBody.bv and flyBody.bg then
        local cf = Camera.CFrame
        local dir = Vector3.zero
        if UserInput:IsKeyDown(Enum.KeyCode.W)         then dir = dir + cf.LookVector  end
        if UserInput:IsKeyDown(Enum.KeyCode.S)         then dir = dir - cf.LookVector  end
        if UserInput:IsKeyDown(Enum.KeyCode.A)         then dir = dir - cf.RightVector end
        if UserInput:IsKeyDown(Enum.KeyCode.D)         then dir = dir + cf.RightVector end
        if UserInput:IsKeyDown(Enum.KeyCode.Space)     then dir = dir + Vector3.yAxis  end
        if UserInput:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.yAxis  end
        flyBody.bv.Velocity = dir.Magnitude > 0 and dir.Unit * Cfg.flySpeed or Vector3.zero
        flyBody.bg.CFrame   = cf
    end

    if Cfg.noclipEnabled then
        local c = getChar()
        if c then
            for _, p in ipairs(c:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = false end
            end
        end
    end

    if Cfg.aimbotEnabled and UserInput:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local t = GetTarget()
        if t then
            Camera.CFrame = Camera.CFrame:Lerp(
                CFrame.lookAt(Camera.CFrame.Position, t.Position),
                Cfg.aimbotSmooth
            )
        end
    end

    if fovCircle then
        fovCircle.Visible  = Cfg.showFOV and Cfg.aimbotEnabled
        fovCircle.Radius   = Cfg.aimbotFOV
        fovCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    end
end)

-- ══════════════════════════════════════════════
-- STEPPED
-- ══════════════════════════════════════════════
RunService.Stepped:Connect(function()
    local h = getHum()
    if h and not Cfg.flyEnabled then
        h.WalkSpeed = Cfg.walkSpeed
        h.JumpPower = Cfg.jumpPower
    end

    if Cfg.killAura then
        local hrp = getHRP(); if not hrp then return end
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= lp and plr.Character then
                local ehr = plr.Character:FindFirstChild("HumanoidRootPart")
                if ehr and (ehr.Position-hrp.Position).Magnitude <= Cfg.killRange then
                    local orig = hrp.CFrame
                    hrp.CFrame = ehr.CFrame
                    task.wait()
                    hrp.CFrame = orig
                end
            end
        end
    end
end)

print("[ZXC v2] hazır  ·  G = menü")