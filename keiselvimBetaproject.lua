--[[
    ╔══════════════════════════════════════════════════════════════════════╗
    ║                                                                      ║
    ║           KEI SELVIM — UI SHELL v2.1                                 ║
    ║           Glassmorphism • Line Icons • State Buttons                 ║
    ║                                                                      ║
    ╚══════════════════════════════════════════════════════════════════════╝
]]

-- ═══════════════════════════════════════════════════════════════════════
-- THEME
-- ═══════════════════════════════════════════════════════════════════════
local THEME = {
    BG_ASSET     = "rbxassetid://137253259807797",

    -- Warna inti
    ACCENT       = Color3.fromRGB(150, 80, 240),
    ACCENT_LITE  = Color3.fromRGB(180, 130, 255),
    ACCENT_DIM   = Color3.fromRGB(60, 30, 105),
    ACCENT_GLOW  = Color3.fromRGB(190, 140, 255),

    -- Surface (default state)
    SURFACE      = Color3.fromRGB(22, 22, 32),
    SURFACE_2    = Color3.fromRGB(16, 16, 24),
    SURFACE_3    = Color3.fromRGB(30, 30, 44),
    BTN_IDLE     = Color3.fromRGB(38, 38, 52),     -- default tombol (abu gelap)
    BTN_HOVER    = Color3.fromRGB(52, 52, 68),     -- hover idle
    HAIRLINE     = Color3.fromRGB(255, 255, 255),

    -- Text
    TEXT         = Color3.fromRGB(245, 245, 250),
    TEXT_DIM     = Color3.fromRGB(150, 150, 170),
    TEXT_FAINT   = Color3.fromRGB(100, 100, 120),

    -- Status
    DANGER       = Color3.fromRGB(240, 80, 105),
    SUCCESS      = Color3.fromRGB(100, 220, 150),
    WARN         = Color3.fromRGB(255, 190, 90),

    -- Transparansi
    BG_TRANS     = 0.15,
    PANEL_TRANS  = 0.35,
    BTN_TRANS    = 0.15,
    HAIRLINE_TR  = 0.85,

    -- Ukuran
    BASE_W       = 660,
    BASE_H       = 440,
    SIDEBAR_W    = 64,
    HEADER_H     = 44,
    PAD          = 14,
    ICON_SIZE    = 42,
    ICON_GAP     = 6,
    RADIUS_LG    = 16,
    RADIUS_MD    = 10,
    RADIUS_SM    = 6,
}

-- ═══════════════════════════════════════════════════════════════════════
-- SERVICES
-- ═══════════════════════════════════════════════════════════════════════
local Players          = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local CoreGui          = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

-- ═══════════════════════════════════════════════════════════════════════
-- STATE
-- ═══════════════════════════════════════════════════════════════════════
local State = {
    screenGui = nil,
    mainFrame = nil,
    shadow = nil,
    kButton = nil,
    minimized = false,
    currentPage = "home",
    pages = {},
    sidebarButtons = {},
    scale = 1,
}

-- ═══════════════════════════════════════════════════════════════════════
-- PARENT FINDER
-- ═══════════════════════════════════════════════════════════════════════
local function getParent()
    if gethui then
        local ok, hui = pcall(gethui)
        if ok and hui then return hui end
    end
    local ok = pcall(function()
        local t = Instance.new("Folder")
        t.Parent = CoreGui
        t:Destroy()
    end)
    if ok then return CoreGui end
    if LocalPlayer then
        local pg = LocalPlayer:FindFirstChild("PlayerGui")
        if pg then return pg end
    end
    return nil
end

-- ═══════════════════════════════════════════════════════════════════════
-- UI HELPERS
-- ═══════════════════════════════════════════════════════════════════════
local function corner(parent, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 8)
    c.Parent = parent
    return c
end

local function stroke(parent, col, thick, trans)
    local s = Instance.new("UIStroke")
    s.Color = col or THEME.ACCENT_DIM
    s.Thickness = thick or 1
    s.Transparency = trans or 0
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = parent
    return s
end

local function gradient(parent, c1, c2, rot)
    local g = Instance.new("UIGradient")
    g.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, c1),
        ColorSequenceKeypoint.new(1, c2),
    })
    g.Rotation = rot or 90
    g.Parent = parent
    return g
end

local function label(parent, props)
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1
    l.Text = props.Text or ""
    l.TextColor3 = props.Color or THEME.TEXT
    l.Font = props.Font or Enum.Font.Gotham
    l.TextSize = props.Size or 13
    l.TextXAlignment = props.XAlign or Enum.TextXAlignment.Left
    l.TextYAlignment = props.YAlign or Enum.TextYAlignment.Center
    l.Size = props.FrameSize or UDim2.new(1, 0, 1, 0)
    l.Position = props.Pos or UDim2.new(0, 0, 0, 0)
    l.TextWrapped = props.Wrap or false
    l.TextTruncate = Enum.TextTruncate.AtEnd
    l.ZIndex = props.Z or 9
    l.Active = false
    l.Parent = parent
    return l
end

-- ═══════════════════════════════════════════════════════════════════════
-- STATEFUL BUTTON
-- default = abu gelap, hover = abu terang, aktif (dipencet/dipilih) = ungu
-- ═══════════════════════════════════════════════════════════════════════
local ButtonState = {}  -- registry untuk reset state

local function makeButton(parent, props)
    local b = Instance.new("TextButton")
    b.Name = props.Name or "Btn"
    b.BackgroundColor3 = props.IdleColor or THEME.BTN_IDLE
    b.BackgroundTransparency = props.Trans or THEME.BTN_TRANS
    b.Text = ""
    b.Size = props.FrameSize or UDim2.new(1, 0, 0, 36)
    b.Position = props.Pos or UDim2.new(0, 0, 0, 0)
    b.BorderSizePixel = 0
    b.AutoButtonColor = false
    b.Active = true
    b.Selectable = true
    b.ZIndex = props.Z or 10
    b.Parent = parent
    corner(b, props.Radius or THEME.RADIUS_MD)
    local s = stroke(b, props.StrokeColor or THEME.HAIRLINE, props.StrokeThick or 1, props.StrokeTrans or 0.88)

    -- Text
    local textLabel = nil
    if props.Text and props.Text ~= "" then
        textLabel = label(b, {
            Text = props.Text,
            Color = props.TextColor or THEME.TEXT,
            Font = props.Font or Enum.Font.GothamSemibold,
            Size = props.TextSize or 12,
            FrameSize = UDim2.new(1, 0, 1, 0),
            XAlign = Enum.TextXAlignment.Center,
            Z = (props.Z or 10) + 2,
        })
    end

    -- State
    local isActive = false
    local idleCol = props.IdleColor or THEME.BTN_IDLE
    local idleTrans = props.Trans or THEME.BTN_TRANS
    local activeCol = props.ActiveColor or THEME.ACCENT
    local activeTrans = math.max(0, idleTrans - 0.05)
    local hoverCol = props.HoverColor or THEME.BTN_HOVER

    local function refresh(hovering)
        local targetCol, targetTrans, targetStroke, targetTextCol
        if isActive then
            targetCol = activeCol
            targetTrans = activeTrans
            targetStroke = 0.15
            targetTextCol = Color3.fromRGB(255, 255, 255)
        elseif hovering then
            targetCol = hoverCol
            targetTrans = idleTrans
            targetStroke = 0.6
            targetTextCol = THEME.TEXT
        else
            targetCol = idleCol
            targetTrans = idleTrans
            targetStroke = 0.88
            targetTextCol = props.TextColor or THEME.TEXT
        end
        TweenService:Create(b, TweenInfo.new(0.18, Enum.EasingStyle.Quad), {
            BackgroundColor3 = targetCol,
            BackgroundTransparency = targetTrans,
        }):Play()
        TweenService:Create(s, TweenInfo.new(0.18), { Transparency = targetStroke }):Play()
        if textLabel then
            TweenService:Create(textLabel, TweenInfo.new(0.18), { TextColor3 = targetTextCol }):Play()
        end
    end

    b.MouseEnter:Connect(function() refresh(true) end)
    b.MouseLeave:Connect(function() refresh(false) end)

    -- API untuk set state aktif
    b.SetActive = function(v)
        isActive = v and true or false
        refresh(false)
    end
    b.GetActive = function() return isActive end

    return b
end

-- ═══════════════════════════════════════════════════════════════════════
-- ICON FACTORY — line-style tipis, di dalam holder
-- ═══════════════════════════════════════════════════════════════════════
local IconFactory = {}

local function line(parent, size, pos, col, rot, r)
    local f = Instance.new("Frame")
    f.Size = size
    f.Position = pos
    f.BackgroundColor3 = col
    f.BorderSizePixel = 0
    f.ZIndex = 25
    f.Parent = parent
    if r then corner(f, r) end
    if rot then f.Rotation = rot end
    return f
end

-- Warna icon berubah menurut state tombol
-- Factory signature: function(holder, size, color) -> container + list of icon parts

-- HOME: atap segitiga outline + body kotak outline
IconFactory.home = function(holder, size, col)
    local c = Instance.new("Frame")
    c.Size = UDim2.new(0, size, 0, size)
    c.BackgroundTransparency = 1
    c.ZIndex = 24
    c.Parent = holder
    local parts = {}

    local s = size
    local t = math.max(1.5, s * 0.09)

    -- Body: 4 garis kotak
    local bx, by = s*0.24, s*0.44
    local bw, bh = s*0.52, s*0.44
    parts[#parts+1] = line(c, UDim2.new(0, bw, 0, t), UDim2.new(0, bx, 0, by), col, 0, 1)
    parts[#parts+1] = line(c, UDim2.new(0, bw, 0, t), UDim2.new(0, bx, 0, by+bh), col, 0, 1)
    parts[#parts+1] = line(c, UDim2.new(0, t, 0, bh+t), UDim2.new(0, bx, 0, by), col, 0, 1)
    parts[#parts+1] = line(c, UDim2.new(0, t, 0, bh+t), UDim2.new(0, bx+bw, 0, by), col, 0, 1)

    -- Atap: segitiga dari 2 garis diagonal (bukan blok)
    -- Bikin pakai rotated frames
    local roofW = s * 0.4
    local roofH = s * 0.28
    local roofLeft = line(c,
        UDim2.new(0, roofW, 0, t),
        UDim2.new(0.5, -roofW, by - roofH + t/2, 0),
        col, -35, 1)
    local roofRight = line(c,
        UDim2.new(0, roofW, 0, t),
        UDim2.new(0.5, 0, by - roofH + t/2, 0),
        col, 35, 1)
    parts[#parts+1] = roofLeft
    parts[#parts+1] = roofRight

    return parts
end

-- TOOLS: wrench — handle diagonal + kepala C
IconFactory.tools = function(holder, size, col)
    local c = Instance.new("Frame")
    c.Size = UDim2.new(0, size, 0, size)
    c.BackgroundTransparency = 1
    c.ZIndex = 24
    c.Parent = holder
    local parts = {}

    local s = size
    local t = math.max(1.5, s * 0.09)

    -- Handle diagonal (dari tengah bawah ke atas kanan)
    parts[#parts+1] = line(c,
        UDim2.new(0, s*0.55, 0, t),
        UDim2.new(0.18, 0, 0.55, -t/2),
        col, -40, 1)

    -- Kepala: 3 garis bikin C terbuka ke kiri
    parts[#parts+1] = line(c, UDim2.new(0, t, 0, s*0.28),
        UDim2.new(0.62, 0, 0.14, 0), col, 0, 1)
    parts[#parts+1] = line(c, UDim2.new(0, s*0.22, 0, t),
        UDim2.new(0.62, 0, 0.14, 0), col, 0, 1)
    parts[#parts+1] = line(c, UDim2.new(0, s*0.22, 0, t),
        UDim2.new(0.62, 0, 0.40, 0), col, 0, 1)

    return parts
end

-- CONFIG: gear outline — ring stroke + inner dot + 4 gigi garis
IconFactory.config = function(holder, size, col)
    local c = Instance.new("Frame")
    c.Size = UDim2.new(0, size, 0, size)
    c.BackgroundTransparency = 1
    c.ZIndex = 24
    c.Parent = holder
    local parts = {}

    local s = size
    local t = math.max(1.5, s * 0.09)

    -- Ring pakai stroke frame
    local ring = Instance.new("Frame")
    ring.Size = UDim2.new(0, s*0.56, 0, s*0.56)
    ring.Position = UDim2.new(0.5, -s*0.28, 0.5, -s*0.28)
    ring.BackgroundTransparency = 1
    ring.ZIndex = 24
    ring.Parent = c
    corner(ring, s)
    local rs = stroke(ring, col, t*1.1, 0)
    parts[#parts+1] = ring
    -- stroke color ikut berubah — track lewat parts? stroke bukan Frame
    -- Simpelnya: simpan referensi stroke di field
    ring._stroke = rs

    -- Inner dot
    parts[#parts+1] = line(c,
        UDim2.new(0, s*0.14, 0, s*0.14),
        UDim2.new(0.5, -s*0.07, 0.5, -s*0.07),
        col, 0, s)

    -- 4 gigi
    parts[#parts+1] = line(c, UDim2.new(0, t, 0, s*0.16),
        UDim2.new(0.5, -t/2, 0, s*0.08), col, 0, 1)
    parts[#parts+1] = line(c, UDim2.new(0, t, 0, s*0.16),
        UDim2.new(0.5, -t/2, 1, -s*0.24), col, 0, 1)
    parts[#parts+1] = line(c, UDim2.new(0, s*0.16, 0, t),
        UDim2.new(0, s*0.08, 0.5, -t/2), col, 0, 1)
    parts[#parts+1] = line(c, UDim2.new(0, s*0.16, 0, t),
        UDim2.new(1, -s*0.24, 0.5, -t/2), col, 0, 1)

    return parts
end

-- CROWN: 3 puncak diamond + base line
IconFactory.crown = function(holder, size, col)
    local c = Instance.new("Frame")
    c.Size = UDim2.new(0, size, 0, size)
    c.BackgroundTransparency = 1
    c.ZIndex = 24
    c.Parent = holder
    local parts = {}

    local s = size
    local t = math.max(1.5, s * 0.09)

    -- Base horizontal
    parts[#parts+1] = line(c,
        UDim2.new(0, s*0.72, 0, t),
        UDim2.new(0.5, -s*0.36, 1, -s*0.22),
        col, 0, 1)

    -- 3 puncak (diamond rotated 45, ukuran beda)
    local peaks = {
        {pos = UDim2.new(0.5, -s*0.12, 0, s*0.18), size = s*0.24},
        {pos = UDim2.new(0.12, 0, 0, s*0.34), size = s*0.2},
        {pos = UDim2.new(0.88, -s*0.2, 0, s*0.34), size = s*0.2},
    }
    for _, p in ipairs(peaks) do
        local pk = Instance.new("Frame")
        pk.Size = UDim2.new(0, p.size, 0, p.size)
        pk.Position = p.pos
        pk.BackgroundColor3 = col
        pk.BorderSizePixel = 0
        pk.Rotation = 45
        pk.ZIndex = 24
        pk.Parent = c
        corner(pk, 2)
        parts[#parts+1] = pk
    end

    return parts
end

-- Helper: apply color ke semua parts icon
local function recolorParts(parts, col)
    for _, p in ipairs(parts) do
        if p:IsA("Frame") then
            if p._stroke then
                p._stroke.Color = col
            else
                p.BackgroundColor3 = col
            end
        end
    end
end

-- ═══════════════════════════════════════════════════════════════════════
-- TOAST
-- ═══════════════════════════════════════════════════════════════════════
local function toast(msg, color)
    if not State.screenGui then return end
    local s = State.scale
    local W = math.floor(340 * s)
    local H = math.floor(46 * s)

    local t = Instance.new("Frame")
    t.Size = UDim2.new(0, W, 0, H)
    t.Position = UDim2.new(0.5, -W/2, 1, 30)
    t.BackgroundColor3 = THEME.SURFACE
    t.BackgroundTransparency = THEME.PANEL_TRANS
    t.BorderSizePixel = 0
    t.ZIndex = 250
    t.Active = false
    t.Parent = State.screenGui
    corner(t, THEME.RADIUS_MD)
    stroke(t, color or THEME.ACCENT_LITE, 1, 0.4)

    -- Dot indikator
    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, math.floor(8 * s), 0, math.floor(8 * s))
    dot.Position = UDim2.new(0, math.floor(14 * s), 0.5, -math.floor(4 * s))
    dot.BackgroundColor3 = color or THEME.ACCENT_LITE
    dot.BorderSizePixel = 0
    dot.ZIndex = 252
    dot.Parent = t
    corner(dot, 4)

    label(t, {
        Text = msg,
        Color = THEME.TEXT,
        Font = Enum.Font.GothamMedium,
        Size = math.floor(11 * s),
        FrameSize = UDim2.new(1, -math.floor(36 * s), 1, 0),
        Pos = UDim2.new(0, math.floor(30 * s), 0, 0),
        XAlign = Enum.TextXAlignment.Left,
        Wrap = true,
        Z = 251,
    })

    TweenService:Create(t, TweenInfo.new(0.4, Enum.EasingStyle.Quint),
        { Position = UDim2.new(0.5, -W/2, 1, -66) }):Play()

    task.delay(2.5, function()
        if t and t.Parent then
            TweenService:Create(t, TweenInfo.new(0.3),
                { Position = UDim2.new(0.5, -W/2, 1, 30) }):Play()
            task.wait(0.4)
            t:Destroy()
        end
    end)
end

-- ═══════════════════════════════════════════════════════════════════════
-- BUILD UI
-- ═══════════════════════════════════════════════════════════════════════
local function buildUI()
    local parentGui = getParent()
    if not parentGui then return end

    local vp = workspace.CurrentCamera.ViewportSize
    local s
    if vp.X < 480 then s = 0.6
    elseif vp.X < 720 then s = 0.75
    elseif vp.X < 1024 then s = 0.88
    else s = 1 end
    State.scale = s

    local BW  = math.floor(THEME.BASE_W * s)
    local BH  = math.floor(THEME.BASE_H * s)
    local SBW = math.floor(THEME.SIDEBAR_W * s)
    local HH  = math.floor(THEME.HEADER_H * s)
    local PAD = math.floor(THEME.PAD * s)
    local ICS = math.floor(THEME.ICON_SIZE * s)
    local ICG = math.floor(THEME.ICON_GAP * s)

    local gui = Instance.new("ScreenGui")
    gui.Name = "KeiSelvimUI"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.DisplayOrder = 2147483647
    gui.IgnoreGuiInset = true
    gui.Parent = parentGui
    State.screenGui = gui

    -- Shadow (outer glow feel)
    local shadow = Instance.new("Frame")
    shadow.Size = UDim2.new(0, BW + 16, 0, BH + 16)
    shadow.Position = UDim2.new(0.5, -(BW+16)/2, 0.5, -(BH+16)/2 + 6)
    shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    shadow.BackgroundTransparency = 0.55
    shadow.BorderSizePixel = 0
    shadow.ZIndex = 0
    shadow.Active = false
    shadow.Parent = gui
    corner(shadow, THEME.RADIUS_LG + 4)
    State.shadow = shadow

    -- Soft accent glow (di belakang frame)
    local glow = Instance.new("Frame")
    glow.Size = UDim2.new(0, BW + 30, 0, BH + 30)
    glow.Position = UDim2.new(0.5, -(BW+30)/2, 0.5, -(BH+30)/2 + 4)
    glow.BackgroundColor3 = THEME.ACCENT
    glow.BackgroundTransparency = 0.88
    glow.BorderSizePixel = 0
    glow.ZIndex = 0
    glow.Active = false
    glow.Parent = gui
    corner(glow, THEME.RADIUS_LG + 8)

    -- Main
    local main = Instance.new("Frame")
    main.Name = "Main"
    main.Size = UDim2.new(0, BW, 0, BH)
    main.Position = UDim2.new(0.5, -BW/2, 0.5, -BH/2)
    main.BackgroundColor3 = THEME.SURFACE_2
    main.BackgroundTransparency = THEME.BG_TRANS
    main.BorderSizePixel = 0
    main.ClipsDescendants = true
    main.Active = true
    main.ZIndex = 3
    main.Parent = gui
    corner(main, THEME.RADIUS_LG)
    stroke(main, THEME.HAIRLINE, 1, 0.9)
    State.mainFrame = main

    -- Background image
    local bgImg = Instance.new("ImageLabel")
    bgImg.Size = UDim2.new(1, 0, 1, 0)
    bgImg.BackgroundTransparency = 1
    bgImg.Image = THEME.BG_ASSET
    bgImg.ScaleType = Enum.ScaleType.Crop
    bgImg.ImageTransparency = THEME.BG_TRANS
    bgImg.Active = false
    bgImg.ZIndex = 1
    bgImg.Parent = main
    corner(bgImg, THEME.RADIUS_LG)

    -- Overlay gradient (dark top-bottom)
    local ov = Instance.new("Frame")
    ov.Size = UDim2.new(1, 0, 1, 0)
    ov.BackgroundColor3 = Color3.fromRGB(8, 8, 14)
    ov.BackgroundTransparency = 0.3
    ov.BorderSizePixel = 0
    ov.Active = false
    ov.ZIndex = 2
    ov.Parent = main
    corner(ov, THEME.RADIUS_LG)
    local ovGrad = Instance.new("UIGradient")
    ovGrad.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.15),
        NumberSequenceKeypoint.new(0.5, 0.5),
        NumberSequenceKeypoint.new(1, 0.75),
    })
    ovGrad.Rotation = 90
    ovGrad.Parent = ov

    -- ═══════════════ HEADER ═══════════════
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, HH)
    header.BackgroundColor3 = THEME.SURFACE
    header.BackgroundTransparency = 0.3
    header.BorderSizePixel = 0
    header.Active = true
    header.ZIndex = 6
    header.Parent = main
    corner(header, THEME.RADIUS_LG)

    -- Bottom hairline
    local headerLine = Instance.new("Frame")
    headerLine.Size = UDim2.new(1, -20, 0, 1)
    headerLine.Position = UDim2.new(0, 10, 1, -1)
    headerLine.BackgroundColor3 = THEME.HAIRLINE
    headerLine.BackgroundTransparency = 0.85
    headerLine.BorderSizePixel = 0
    headerLine.ZIndex = 20
    headerLine.Parent = header

     -- Logo: hexagon-ish (diamond + ring accent)
    local logoWrap = Instance.new("Frame")
    logoWrap.Size = UDim2.new(0, math.floor(26 * s), 0, math.floor(26 * s))
    logoWrap.Position = UDim2.new(0, math.floor(16 * s), 0.5, -math.floor(13 * s))
    logoWrap.BackgroundTransparency = 1
    logoWrap.ZIndex = 7
    logoWrap.Parent = header

    local logoRing = Instance.new("Frame")
    logoRing.Size = UDim2.new(0, math.floor(22 * s), 0, math.floor(22 * s))
    logoRing.Position = UDim2.new(0.5, -math.floor(11 * s), 0.5, -math.floor(11 * s))
    logoRing.BackgroundTransparency = 1
    logoRing.ZIndex = 7
    logoRing.Parent = logoWrap
    corner(logoRing, math.floor(11 * s))
    stroke(logoRing, THEME.ACCENT, 1.5, 0.1)

    local logoD = Instance.new("Frame")
    logoD.Size = UDim2.new(0, math.floor(11 * s), 0, math.floor(11 * s))
    logoD.Position = UDim2.new(0.5, -math.floor(5.5 * s), 0.5, -math.floor(5.5 * s))
    logoD.BackgroundColor3 = THEME.ACCENT
    logoD.BorderSizePixel = 0
    logoD.Rotation = 45
    logoD.ZIndex = 8
    logoD.Parent = logoWrap
    corner(logoD, 2)

    -- Brand text
    label(header, {
        Text = "KEI SELVIM",
        Color = THEME.TEXT,
        Font = Enum.Font.GothamBold,
        Size = math.floor(12 * s),
        FrameSize = UDim2.new(0, math.floor(110 * s), 0, math.floor(16 * s)),
        Pos = UDim2.new(0, math.floor(52 * s), 0, math.floor(HH/2 - 10 * s)),
        Z = 7,
    })

    label(header, {
        Text = "SHELL",
        Color = THEME.TEXT_FAINT,
        Font = Enum.Font.GothamMedium,
        Size = math.floor(8 * s),
        FrameSize = UDim2.new(0, math.floor(110 * s), 0, math.floor(12 * s)),
        Pos = UDim2.new(0, math.floor(53 * s), 0, math.floor(HH/2 + 6 * s)),
        Z = 7,
    })

    -- Version pill
    local badge = Instance.new("Frame")
    badge.Size = UDim2.new(0, math.floor(40 * s), 0, math.floor(18 * s))
    badge.Position = UDim2.new(0, math.floor(158 * s), 0, math.floor((HH - 18 * s)/2))
    badge.BackgroundColor3 = THEME.ACCENT
    badge.BackgroundTransparency = 0.55
    badge.BorderSizePixel = 0
    badge.Active = false
    badge.ZIndex = 7
    badge.Parent = header
    corner(badge, 9)
    stroke(badge, THEME.ACCENT_LITE, 1, 0.6)
    label(badge, {
        Text = "v2.1",
        Color = THEME.ACCENT_LITE,
        Font = Enum.Font.GothamBold,
        Size = math.floor(9 * s),
        XAlign = Enum.TextXAlignment.Center,
        Z = 8,
    })

    -- Close button (merah, outline saja)
    local btnS = math.floor(28 * s)
    local closeBtn = makeButton(header, {
        Name = "Close",
        Text = "✕",
        IdleColor = Color3.fromRGB(60, 24, 34),
        ActiveColor = THEME.DANGER,
        HoverColor = Color3.fromRGB(90, 32, 46),
        TextColor = Color3.fromRGB(255, 180, 190),
        Font = Enum.Font.GothamBold,
        TextSize = math.floor(12 * s),
        FrameSize = UDim2.new(0, btnS, 0, btnS),
        Pos = UDim2.new(1, -math.floor(38 * s), 0, math.floor((HH - btnS)/2)),
        Radius = THEME.RADIUS_SM,
        StrokeColor = THEME.DANGER,
        Z = 10,
    })

    -- Minimize button (garis di tengah)
    local minBtn = makeButton(header, {
        Name = "Minimize",
        IdleColor = THEME.BTN_IDLE,
        HoverColor = THEME.BTN_HOVER,
        FrameSize = UDim2.new(0, btnS, 0, btnS),
        Pos = UDim2.new(1, -math.floor(72 * s), 0, math.floor((HH - btnS)/2)),
        Radius = THEME.RADIUS_SM,
        StrokeColor = THEME.HAIRLINE,
        Z = 10,
    })
    local minBar = Instance.new("Frame")
    minBar.Size = UDim2.new(0, math.floor(12 * s), 0, math.floor(2 * s))
    minBar.Position = UDim2.new(0.5, -math.floor(6 * s), 0.5, -math.floor(1 * s))
    minBar.BackgroundColor3 = THEME.TEXT_DIM
    minBar.BorderSizePixel = 0
    minBar.ZIndex = 14
    minBar.Parent = minBtn
    corner(minBar, 1)

    -- ═══════════════ SIDEBAR ═══════════════
    local sidebar = Instance.new("Frame")
    sidebar.Size = UDim2.new(0, SBW, 1, -HH)
    sidebar.Position = UDim2.new(0, 0, 0, HH)
    sidebar.BackgroundColor3 = THEME.SURFACE_2
    sidebar.BackgroundTransparency = 0.5
    sidebar.BorderSizePixel = 0
    sidebar.Active = false
    sidebar.ZIndex = 5
    sidebar.Parent = main

    -- Sidebar right hairline
    local sbLine = Instance.new("Frame")
    sbLine.Size = UDim2.new(0, 1, 1, -20)
    sbLine.Position = UDim2.new(1, -1, 0, 10)
    sbLine.BackgroundColor3 = THEME.HAIRLINE
    sbLine.BackgroundTransparency = 0.88
    sbLine.BorderSizePixel = 0
    sbLine.ZIndex = 20
    sbLine.Parent = sidebar

    -- ═══════════════ CONTENT ═══════════════
    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, -(SBW + PAD*2), 1, -(HH + PAD*2))
    content.Position = UDim2.new(0, SBW + PAD, 0, HH + PAD)
    content.BackgroundTransparency = 1
    content.Active = false
    content.ZIndex = 5
    content.Parent = main

    -- ═══════════════ PAGE FACTORY ═══════════════
    local function makePage(id, title, subtitle)
        local p = Instance.new("Frame")
        p.Name = id .. "Page"
        p.Size = UDim2.new(1, 0, 1, 0)
        p.BackgroundTransparency = 1
        p.Visible = false
        p.Active = false
        p.ZIndex = 5
        p.Parent = content

        label(p, {
            Text = title,
            Color = THEME.TEXT,
            Font = Enum.Font.GothamBold,
            Size = math.floor(16 * s),
            FrameSize = UDim2.new(1, 0, 0, math.floor(24 * s)),
            Pos = UDim2.new(0, 0, 0, 0),
            Z = 8,
        })
        if subtitle then
            label(p, {
                Text = subtitle,
                Color = THEME.TEXT_DIM,
                Font = Enum.Font.Gotham,
                Size = math.floor(10 * s),
                FrameSize = UDim2.new(1, 0, 0, math.floor(16 * s)),
                Pos = UDim2.new(0, 0, 0, math.floor(28 * s)),
                Z = 8,
            })
        end

        local body = Instance.new("Frame")
        body.Size = UDim2.new(1, 0, 1, -math.floor(56 * s))
        body.Position = UDim2.new(0, 0, 0, math.floor(56 * s))
        body.BackgroundTransparency = 1
        body.Active = false
        body.ZIndex = 6
        body.Parent = p

        State.pages[id] = p
        return body
    end

    -- ─── HOME ───
    local homeBody = makePage("home", "Home", "Dashboard & info")

    local profileCard = Instance.new("Frame")
    profileCard.Size = UDim2.new(1, 0, 0, math.floor(70 * s))
    profileCard.BackgroundColor3 = THEME.SURFACE
    profileCard.BackgroundTransparency = THEME.PANEL_TRANS
    profileCard.BorderSizePixel = 0
    profileCard.Active = false
    profileCard.ZIndex = 7
    profileCard.Parent = homeBody
    corner(profileCard, THEME.RADIUS_MD)
    stroke(profileCard, THEME.HAIRLINE, 1, 0.88)

    local av = Instance.new("ImageLabel")
    av.Size = UDim2.new(0, math.floor(50 * s), 0, math.floor(50 * s))
    av.Position = UDim2.new(0, math.floor(12 * s), 0.5, -math.floor(25 * s))
    av.BackgroundColor3 = THEME.SURFACE_3
    av.BackgroundTransparency = 0.3
    av.BorderSizePixel = 0
    av.Active = false
    av.ZIndex = 8
    av.Parent = profileCard
    corner(av, math.floor(25 * s))
    stroke(av, THEME.ACCENT_LITE, 1.5, 0.5)

    task.spawn(function()
        if LocalPlayer then
            local ok, thumb = pcall(function()
                return Players:GetUserThumbnailAsync(LocalPlayer.UserId,
                    Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
            end)
            if ok and thumb then av.Image = thumb end
        end
    end)

    label(profileCard, {
        Text = LocalPlayer and LocalPlayer.DisplayName or "Unknown",
        Color = THEME.TEXT,
        Font = Enum.Font.GothamBold,
        Size = math.floor(13 * s),
        FrameSize = UDim2.new(1, -math.floor(80 * s), 0, math.floor(18 * s)),
        Pos = UDim2.new(0, math.floor(74 * s), 0, math.floor(12 * s)),
        Z = 8,
    })
    label(profileCard, {
        Text = "@" .. (LocalPlayer and LocalPlayer.Name or "unknown"),
        Color = THEME.TEXT_DIM,
        Font = Enum.Font.Gotham,
        Size = math.floor(10 * s),
        FrameSize = UDim2.new(1, -math.floor(80 * s), 0, math.floor(14 * s)),
        Pos = UDim2.new(0, math.floor(74 * s), 0, math.floor(30 * s)),
        Z = 8,
    })
    label(profileCard, {
        Text = "◈  Kei Selvim  ·  Shell v2.1",
        Color = THEME.ACCENT_LITE,
        Font = Enum.Font.GothamMedium,
        Size = math.floor(9 * s),
        FrameSize = UDim2.new(1, -math.floor(80 * s), 0, math.floor(14 * s)),
        Pos = UDim2.new(0, math.floor(74 * s), 0, math.floor(46 * s)),
        Z = 8,
    })

    -- Stat grid
    local statsGrid = Instance.new("Frame")
    statsGrid.Size = UDim2.new(1, 0, 0, math.floor(140 * s))
    statsGrid.Position = UDim2.new(0, 0, 0, math.floor(82 * s))
    statsGrid.BackgroundTransparency = 1
    statsGrid.Active = false
    statsGrid.ZIndex = 7
    statsGrid.Parent = homeBody

    local grid = Instance.new("UIGridLayout")
    grid.CellSize = UDim2.new(0.5, -math.floor(6 * s), 0, math.floor(64 * s))
    grid.CellPadding = UDim2.new(0, math.floor(12 * s), 0, math.floor(10 * s))
    grid.SortOrder = Enum.SortOrder.LayoutOrder
    grid.Parent = statsGrid

    local function makeStatCard(order, title, value, color, symbol)
        local card = Instance.new("Frame")
        card.BackgroundColor3 = THEME.SURFACE
        card.BackgroundTransparency = THEME.PANEL_TRANS
        card.BorderSizePixel = 0
        card.LayoutOrder = order
        card.Active = false
        card.ZIndex = 8
        card.Parent = statsGrid
        corner(card, THEME.RADIUS_MD)
        stroke(card, THEME.HAIRLINE, 1, 0.88)

        -- Accent bar kiri
        local bar = Instance.new("Frame")
        bar.Size = UDim2.new(0, math.floor(3 * s), 1, -math.floor(20 * s))
        bar.Position = UDim2.new(0, 0, 0, math.floor(10 * s))
        bar.BackgroundColor3 = color
        bar.BorderSizePixel = 0
        bar.ZIndex = 9
        bar.Parent = card
        corner(bar, 2)

        label(card, {
            Text = title,
            Color = THEME.TEXT_DIM,
            Font = Enum.Font.GothamMedium,
            Size = math.floor(9 * s),
            FrameSize = UDim2.new(1, -math.floor(50 * s), 0, math.floor(14 * s)),
            Pos = UDim2.new(0, math.floor(14 * s), 0, math.floor(10 * s)),
            Z = 9,
        })

        label(card, {
            Text = value,
            Color = color,
            Font = Enum.Font.GothamBold,
            Size = math.floor(18 * s),
            FrameSize = UDim2.new(1, -math.floor(50 * s), 0, math.floor(26 * s)),
            Pos = UDim2.new(0, math.floor(14 * s), 0, math.floor(28 * s)),
            Z = 9,
        })

        -- Symbol kanan atas
        label(card, {
            Text = symbol,
            Color = color,
            Font = Enum.Font.GothamBold,
            Size = math.floor(16 * s),
            FrameSize = UDim2.new(0, math.floor(30 * s), 0, math.floor(30 * s)),
            Pos = UDim2.new(1, -math.floor(38 * s), 0, math.floor(12 * s)),
            XAlign = Enum.TextXAlignment.Center,
            Z = 9,
        })
    end

    makeStatCard(1, "FPS",     "60",      Color3.fromRGB(100, 255, 150), "▲")
    makeStatCard(2, "PING",    "0 ms",    Color3.fromRGB(255, 200, 100), "●")
    makeStatCard(3, "STATUS",  "Ready",   Color3.fromRGB(150, 200, 255), "◆")
    makeStatCard(4, "MODE",    "UI Only", Color3.fromRGB(255, 150, 200), "■")

    -- ─── TOOLS ───
    local toolsBody = makePage("tools", "Tools", "Function panel")

    local toolsCard = Instance.new("Frame")
    toolsCard.Size = UDim2.new(1, 0, 0, math.floor(170 * s))
    toolsCard.BackgroundColor3 = THEME.SURFACE
    toolsCard.BackgroundTransparency = THEME.PANEL_TRANS
    toolsCard.BorderSizePixel = 0
    toolsCard.Active = false
    toolsCard.ZIndex = 7
    toolsCard.Parent = toolsBody
    corner(toolsCard, THEME.RADIUS_MD)
    stroke(toolsCard, THEME.HAIRLINE, 1, 0.88)

    local toolsIconWrap = Instance.new("Frame")
    toolsIconWrap.Size = UDim2.new(0, math.floor(40 * s), 0, math.floor(40 * s))
    toolsIconWrap.Position = UDim2.new(0.5, -math.floor(20 * s), 0, math.floor(18 * s))
    toolsIconWrap.BackgroundTransparency = 1
    toolsIconWrap.ZIndex = 8
    toolsIconWrap.Parent = toolsCard
    IconFactory.tools(toolsIconWrap, math.floor(40 * s), THEME.ACCENT_LITE)

    label(toolsCard, {
        Text = "Tools panel — logic di sini nanti",
        Color = THEME.TEXT_DIM,
        Font = Enum.Font.Gotham,
        Size = math.floor(11 * s),
        FrameSize = UDim2.new(1, 0, 0, math.floor(20 * s)),
        Pos = UDim2.new(0, 0, 0, math.floor(68 * s)),
        XAlign = Enum.TextXAlignment.Center,
        Z = 8,
    })

    local sampleBtn = makeButton(toolsCard, {
        Text = "Sample Button",
        FrameSize = UDim2.new(1, -math.floor(40 * s), 0, math.floor(36 * s)),
        Pos = UDim2.new(0, math.floor(20 * s), 0, math.floor(108 * s)),
        TextSize = math.floor(11 * s),
        Z = 9,
    })
    local sampleActive = false
    sampleBtn.MouseButton1Click:Connect(function()
        sampleActive = not sampleActive
        sampleBtn.SetActive(sampleActive)
        toast(sampleActive and "Sample: ON" or "Sample: OFF",
            sampleActive and THEME.ACCENT_LITE or THEME.TEXT_DIM)
    end)

    -- ─── CONFIG ───
    local configBody = makePage("config", "Config", "Settings panel")

    local configCard = Instance.new("Frame")
    configCard.Size = UDim2.new(1, 0, 0, math.floor(130 * s))
    configCard.BackgroundColor3 = THEME.SURFACE
    configCard.BackgroundTransparency = THEME.PANEL_TRANS
    configCard.BorderSizePixel = 0
    configCard.Active = false
    configCard.ZIndex = 7
    configCard.Parent = configBody
    corner(configCard, THEME.RADIUS_MD)
    stroke(configCard, THEME.HAIRLINE, 1, 0.88)

    local cfgIconWrap = Instance.new("Frame")
    cfgIconWrap.Size = UDim2.new(0, math.floor(40 * s), 0, math.floor(40 * s))
    cfgIconWrap.Position = UDim2.new(0.5, -math.floor(20 * s), 0, math.floor(18 * s))
    cfgIconWrap.BackgroundTransparency = 1
    cfgIconWrap.ZIndex = 8
    cfgIconWrap.Parent = configCard
    IconFactory.config(cfgIconWrap, math.floor(40 * s), THEME.ACCENT_LITE)

    label(configCard, {
        Text = "Config panel — logic di sini nanti",
        Color = THEME.TEXT_DIM,
        Font = Enum.Font.Gotham,
        Size = math.floor(11 * s),
        FrameSize = UDim2.new(1, 0, 0, math.floor(20 * s)),
        Pos = UDim2.new(0, 0, 0, math.floor(70 * s)),
        XAlign = Enum.TextXAlignment.Center,
        Z = 8,
    })

    -- ─── CROWN ───
    local crownBody = makePage("crown", "Crown", "Admin panel")

    local crownCard = Instance.new("Frame")
    crownCard.Size = UDim2.new(1, 0, 0, math.floor(130 * s))
    crownCard.BackgroundColor3 = THEME.SURFACE
    crownCard.BackgroundTransparency = THEME.PANEL_TRANS
    crownCard.BorderSizePixel = 0
    crownCard.Active = false
    crownCard.ZIndex = 7
    crownCard.Parent = crownBody
    corner(crownCard, THEME.RADIUS_MD)
    stroke(crownCard, Color3.fromRGB(255, 200, 60), 1, 0.6)

    local crownIconWrap = Instance.new("Frame")
    crownIconWrap.Size = UDim2.new(0, math.floor(40 * s), 0, math.floor(40 * s))
    crownIconWrap.Position = UDim2.new(0.5, -math.floor(20 * s), 0, math.floor(18 * s))
    crownIconWrap.BackgroundTransparency = 1
    crownIconWrap.ZIndex = 8
    crownIconWrap.Parent = crownCard
    IconFactory.crown(crownIconWrap, math.floor(40 * s), Color3.fromRGB(255, 200, 60))

    label(crownCard, {
        Text = "Admin panel — logic di sini nanti",
        Color = Color3.fromRGB(255, 200, 60),
        Font = Enum.Font.Gotham,
        Size = math.floor(11 * s),
        FrameSize = UDim2.new(1, 0, 0, math.floor(20 * s)),
        Pos = UDim2.new(0, 0, 0, math.floor(70 * s)),
        XAlign = Enum.TextXAlignment.Center,
        Z = 8,
    })

    -- ═══════════════ SIDEBAR ICONS ═══════════════
    local iconList = {
        { id = "home",   factory = IconFactory.home },
        { id = "tools",  factory = IconFactory.tools },
        { id = "config", factory = IconFactory.config },
        { id = "crown",  factory = IconFactory.crown, color = Color3.fromRGB(255, 200, 60) },
    }

    local iconY = math.floor(14 * s)
    for i, item in ipairs(iconList) do
        -- Button pakai makeButton (state: idle abu, active ungu)
        local btn = makeButton(sidebar, {
            Name = item.id .. "Btn",
            IdleColor = THEME.BTN_IDLE,
            HoverColor = THEME.BTN_HOVER,
            ActiveColor = THEME.ACCENT,
            FrameSize = UDim2.new(0, ICS, 0, ICS),
            Pos = UDim2.new(0, math.floor((SBW - ICS)/2), 0, iconY + (i-1) * (ICS + ICG)),
            Radius = THEME.RADIUS_MD,
            StrokeColor = THEME.HAIRLINE,
            Z = 10,
        })

        -- Icon holder di dalam button
        local holder = Instance.new("Frame")
        holder.Size = UDim2.new(0, math.floor(24 * s), 0, math.floor(24 * s))
        holder.Position = UDim2.new(0.5, -math.floor(12 * s), 0.5, -math.floor(12 * s))
        holder.BackgroundTransparency = 1
        holder.ZIndex = 15
        holder.Parent = btn

        local iconColor = item.color or THEME.TEXT_DIM
        local parts = item.factory(holder, math.floor(24 * s), iconColor)

        State.sidebarButtons[item.id] = {
            button = btn,
            parts = parts,
            idleIconColor = iconColor,
            activeIconColor = Color3.fromRGB(255, 255, 255),
        }

        -- Update icon color saat state berubah
        btn.MouseEnter:Connect(function()
            if not btn.GetActive() then
                recolorParts(parts, THEME.TEXT)
            end
        end)
        btn.MouseLeave:Connect(function()
            if btn.GetActive() then
                recolorParts(parts, Color3.fromRGB(255, 255, 255))
            else
                recolorParts(parts, iconColor)
            end
        end)
        btn.MouseButton1Click:Connect(function()
            -- handled below in switchPage
        end)
    end

    -- ═══════════════ PAGE SWITCHING ═══════════════
    local function switchPage(id)
        for pid, page in pairs(State.pages) do
            page.Visible = (pid == id)
        end
        for bid, data in pairs(State.sidebarButtons) do
            if bid == id then
                data.button.SetActive(true)
                recolorParts(data.parts, data.activeIconColor)
            else
                data.button.SetActive(false)
                recolorParts(data.parts, data.idleIconColor)
            end
        end
        State.currentPage = id
    end

    for id, data in pairs(State.sidebarButtons) do
        data.button.MouseButton1Click:Connect(function()
            switchPage(id)
        end)
    end

    -- ═══════════════ DRAG ═══════════════
    local dragging, dragStart, startPos = false, nil, nil
    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = main.Position
        end
    end)
    header.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            main.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
            shadow.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X - 8,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y - 2
            )
            glow.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X - 15,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y - 11
            )
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    -- ═══════════════ CLOSE ═══════════════
    closeBtn.MouseButton1Click:Connect(function()
        local cW = math.floor(310 * s)
        local cH = math.floor(150 * s)
        local confirm = Instance.new("Frame")
        confirm.Size = UDim2.new(0, cW, 0, cH)
        confirm.Position = UDim2.new(0.5, -cW/2, 0.5, -cH/2)
        confirm.BackgroundColor3 = THEME.SURFACE
        confirm.BackgroundTransparency = 0.15
        confirm.BorderSizePixel = 0
        confirm.Active = true
        confirm.ZIndex = 300
        confirm.Parent = gui
        corner(confirm, THEME.RADIUS_LG)
        stroke(confirm, THEME.DANGER, 1.5, 0.3)

        label(confirm, {
            Text = "Konfirmasi",
            Color = Color3.fromRGB(255, 200, 100),
            Font = Enum.Font.GothamBold,
            Size = math.floor(14 * s),
            FrameSize = UDim2.new(1, 0, 0, math.floor(26 * s)),
            Pos = UDim2.new(0, 0, 0, math.floor(16 * s)),
            XAlign = Enum.TextXAlignment.Center,
            Z = 301,
        })
        label(confirm, {
            Text = "Yakin mau tutup Kei Selvim?",
            Color = THEME.TEXT,
            Font = Enum.Font.Gotham,
            Size = math.floor(11 * s),
            FrameSize = UDim2.new(1, -20, 0, math.floor(36 * s)),
            Pos = UDim2.new(0, 10, 0, math.floor(48 * s)),
            XAlign = Enum.TextXAlignment.Center,
            Wrap = true,
            Z = 301,
        })

        local bW = (cW - math.floor(30 * s)) / 2
        local yes = makeButton(confirm, {
            Text = "Ya, Tutup",
            IdleColor = THEME.DANGER,
            ActiveColor = THEME.DANGER,
            HoverColor = Color3.fromRGB(255, 100, 130),
            Font = Enum.Font.GothamBold,
            TextSize = math.floor(11 * s),
            FrameSize = UDim2.new(0, bW, 0, math.floor(34 * s)),
            Pos = UDim2.new(0, math.floor(10 * s), 0, math.floor(100 * s)),
            Radius = THEME.RADIUS_MD,
            StrokeColor = THEME.DANGER,
            Z = 302,
        })
        local no = makeButton(confirm, {
            Text = "Batal",
            IdleColor = THEME.BTN_IDLE,
            ActiveColor = THEME.ACCENT,
            HoverColor = THEME.BTN_HOVER,
            Font = Enum.Font.GothamBold,
            TextSize = math.floor(11 * s),
            FrameSize = UDim2.new(0, bW, 0, math.floor(34 * s)),
            Pos = UDim2.new(0, math.floor(20 * s) + bW, 0, math.floor(100 * s)),
            Radius = THEME.RADIUS_MD,
            StrokeColor = THEME.HAIRLINE,
            Z = 302,
        })

        no.MouseButton1Click:Connect(function() confirm:Destroy() end)
        yes.MouseButton1Click:Connect(function()
            gui:Destroy()
            if State.kButton then State.kButton:Destroy() end
        end)
    end)

    -- ═══════════════ MINIMIZE ═══════════════
    minBtn.MouseButton1Click:Connect(function()
        main.Visible = false
        shadow.Visible = false
        glow.Visible = false
        State.minimized = true

        if not State.kButton or not State.kButton.Parent then
            local kS = math.floor(50 * s)
            local k = Instance.new("TextButton")
            k.Name = "KButton"
            k.Size = UDim2.new(0, kS, 0, kS)
            k.Position = UDim2.new(0, math.floor(20 * s), 0.5, -kS/2)
            k.BackgroundColor3 = THEME.ACCENT
            k.BackgroundTransparency = THEME.BTN_TRANS
            k.Text = "K"
            k.TextColor3 = Color3.fromRGB(255, 255, 255)
            k.Font = Enum.Font.GothamBold
            k.TextSize = math.floor(22 * s)
            k.BorderSizePixel = 0
            k.AutoButtonColor = false
            k.Active = true
            k.Draggable = true
            k.ZIndex = 50
            k.Parent = gui
            corner(k, kS/2)
            stroke(k, THEME.ACCENT_LITE, 1.5, 0.3)

            k.MouseButton1Click:Connect(function()
                main.Visible = true
                shadow.Visible = true
                glow.Visible = true
                State.minimized = false
                k.Visible = false
            end)
            State.kButton = k
        end
        State.kButton.Visible = true
    end)

    switchPage("home")
    toast("Kei Selvim UI v2.1 loaded", THEME.SUCCESS)
end

-- ═══════════════════════════════════════════════════════════════════════
-- BOOT
-- ═══════════════════════════════════════════════════════════════════════
task.wait(0.3)
buildUI()
