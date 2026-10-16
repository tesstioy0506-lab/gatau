--[[
    ╔══════════════════════════════════════════════════════════════════════╗
    ║                                                                      ║
    ║           KEI SELVIM — UI SHELL v1.1                                 ║
    ║           Modern Icon Edition (no emoji)                             ║
    ║                                                                      ║
    ╚══════════════════════════════════════════════════════════════════════╝
]]

-- ═══════════════════════════════════════════════════════════════════════
-- THEME
-- ═══════════════════════════════════════════════════════════════════════
local THEME = {
    BG_ASSET     = "rbxassetid://0",

    -- Warna
    ACCENT       = Color3.fromRGB(138, 43, 226),
    ACCENT_DIM   = Color3.fromRGB(70, 25, 120),
    ACCENT_GLOW  = Color3.fromRGB(170, 90, 245),
    PANEL        = Color3.fromRGB(20, 20, 28),
    PANEL_DARK   = Color3.fromRGB(12, 12, 18),
    DANGER       = Color3.fromRGB(220, 60, 80),
    SUCCESS      = Color3.fromRGB(100, 220, 140),
    TEXT         = Color3.fromRGB(240, 240, 245),
    TEXT_DIM     = Color3.fromRGB(150, 150, 175),

    -- Transparansi
    BG_TRANS     = 0.2,
    PANEL_TRANS  = 0.25,
    BTN_TRANS    = 0.2,

    -- Ukuran
    BASE_W       = 640,
    BASE_H       = 420,
    SIDEBAR_W    = 60,
    HEADER_H     = 40,
    PAD          = 12,
    ICON_SIZE    = 38,
    ICON_GAP     = 8,
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

local function button(parent, props)
    local b = Instance.new("TextButton")
    b.Name = props.Name or "Btn"
    b.BackgroundColor3 = props.Color or THEME.ACCENT
    b.BackgroundTransparency = props.Trans or THEME.BTN_TRANS
    b.Text = ""
    b.TextColor3 = props.TextColor or Color3.fromRGB(255, 255, 255)
    b.Font = props.Font or Enum.Font.GothamMedium
    b.TextSize = props.TextSize or 13
    b.Size = props.FrameSize or UDim2.new(1, 0, 0, 36)
    b.Position = props.Pos or UDim2.new(0, 0, 0, 0)
    b.BorderSizePixel = 0
    b.AutoButtonColor = false
    b.Active = true
    b.Selectable = true
    b.ZIndex = props.Z or 10
    b.Parent = parent
    corner(b, props.Radius or 8)
    stroke(b, props.StrokeColor or THEME.ACCENT, props.StrokeThick or 1, props.StrokeTrans or 0.3)

    -- Text label di atas button (biar bisa multi-element)
    if props.Text and props.Text ~= "" then
        label(b, {
            Text = props.Text,
            Color = props.TextColor or Color3.fromRGB(255, 255, 255),
            Font = props.Font or Enum.Font.GothamMedium,
            Size = props.TextSize or 13,
            FrameSize = UDim2.new(1, 0, 1, 0),
            XAlign = Enum.TextXAlignment.Center,
            Z = (props.Z or 10) + 1,
        })
    end

    local baseColor = props.Color or THEME.ACCENT
    local baseTrans = props.Trans or THEME.BTN_TRANS
    b.MouseEnter:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.15), {
            BackgroundColor3 = THEME.ACCENT_GLOW,
            BackgroundTransparency = math.max(0, baseTrans - 0.1),
        }):Play()
    end)
    b.MouseLeave:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.15), {
            BackgroundColor3 = baseColor,
            BackgroundTransparency = baseTrans,
        }):Play()
    end)

    return b
end

-- ═══════════════════════════════════════════════════════════════════════
-- ICON FACTORY — bikin icon line-style dari primitive shape
-- Semua icon digambar pakai Frame, bukan emoji/glyph
-- ═══════════════════════════════════════════════════════════════════════
-- Setiap icon = function(parent, size, color) yang return Frame container
local IconFactory = {}

-- Helper: bikin bar (line) di dalam parent
local function bar(parent, size, pos, col, radius, rot)
    local f = Instance.new("Frame")
    f.Size = size
    f.Position = pos
    f.BackgroundColor3 = col
    f.BorderSizePixel = 0
    f.ZIndex = 20
    f.Parent = parent
    if radius then corner(f, radius) end
    if rot then f.Rotation = rot end
    return f
end

-- 🏠 HOME → house outline (roof segitiga + body kotak)
IconFactory.home = function(parent, size, col, z)
    local c = Instance.new("Frame")
    c.Size = UDim2.new(0, size, 0, size)
    c.BackgroundTransparency = 1
    c.ZIndex = z or 20
    c.Parent = parent

    local s = size
    -- body (kotak bawah)
    bar(c, UDim2.new(0, s*0.7, 0, s*0.55),
        UDim2.new(0.5, -s*0.35, 1, -s*0.6), col, 2)
    -- roof (diamond diputar 45°, dipotong atas)
    local roof = Instance.new("Frame")
    roof.Size = UDim2.new(0, s*0.75, 0, s*0.75)
    roof.Position = UDim2.new(0.5, -s*0.375, 0, s*0.05)
    roof.BackgroundColor3 = col
    roof.BorderSizePixel = 0
    roof.Rotation = 45
    roof.ZIndex = (z or 20)
    roof.Parent = c
    corner(roof, 3)
    -- potong bawah roof pakai frame warna background (mask)
    local mask = Instance.new("Frame")
    mask.Size = UDim2.new(0, s*0.5, 0, s*0.4)
    mask.Position = UDim2.new(0.5, -s*0.25, 0.5, 0)
    mask.BackgroundColor3 = THEME.PANEL_DARK
    mask.BackgroundTransparency = 0.35
    mask.BorderSizePixel = 0
    mask.ZIndex = (z or 20) + 1
    mask.Parent = c
    return c
end

-- 🛠 TOOLS → wrench sederhana (garis diagonal + kepala)
IconFactory.tools = function(parent, size, col, z)
    local c = Instance.new("Frame")
    c.Size = UDim2.new(0, size, 0, size)
    c.BackgroundTransparency = 1
    c.ZIndex = z or 20
    c.Parent = parent

    local s = size
    -- handle diagonal
    bar(c, UDim2.new(0, s*0.65, 0, s*0.14),
        UDim2.new(0.15, 0, 0.5, -s*0.07), col, 3, -45)
    -- kepala (kotak kecil di ujung atas)
    local head = Instance.new("Frame")
    head.Size = UDim2.new(0, s*0.35, 0, s*0.35)
    head.Position = UDim2.new(0.5, 0, 0.05, 0)
    head.BackgroundColor3 = col
    head.BorderSizePixel = 0
    head.Rotation = 45
    head.ZIndex = (z or 20) + 1
    head.Parent = c
    corner(head, 3)
    -- lubang tengah kepala
    local hole = Instance.new("Frame")
    hole.Size = UDim2.new(0, s*0.14, 0, s*0.14)
    hole.Position = UDim2.new(0.5, -s*0.07, 0.5, -s*0.07)
    hole.BackgroundColor3 = THEME.PANEL_DARK
    hole.BackgroundTransparency = 0.35
    hole.BorderSizePixel = 0
    hole.ZIndex = (z or 20) + 2
    hole.Parent = head
    corner(hole, s)
    return c
end

-- ⚙️ CONFIG → gear (kotak + 4 gigi)
IconFactory.config = function(parent, size, col, z)
    local c = Instance.new("Frame")
    c.Size = UDim2.new(0, size, 0, size)
    c.BackgroundTransparency = 1
    c.ZIndex = z or 20
    c.Parent = parent

    local s = size
    -- ring tengah
    local ring = Instance.new("Frame")
    ring.Size = UDim2.new(0, s*0.55, 0, s*0.55)
    ring.Position = UDim2.new(0.5, -s*0.275, 0.5, -s*0.275)
    ring.BackgroundColor3 = col
    ring.BorderSizePixel = 0
    ring.ZIndex = z or 20
    ring.Parent = c
    corner(ring, s)
    -- lubang tengah
    local inner = Instance.new("Frame")
    inner.Size = UDim2.new(0, s*0.22, 0, s*0.22)
    inner.Position = UDim2.new(0.5, -s*0.11, 0.5, -s*0.11)
    inner.BackgroundColor3 = THEME.PANEL_DARK
    inner.BackgroundTransparency = 0.35
    inner.BorderSizePixel = 0
    inner.ZIndex = (z or 20) + 1
    inner.Parent = c
    corner(inner, s)
    -- 4 gigi
    local teeth = {
        {UDim2.new(0.5, -s*0.08, 0, 0),               UDim2.new(0, s*0.16, 0, s*0.28)}, -- top
        {UDim2.new(0.5, -s*0.08, 1, -s*0.28),         UDim2.new(0, s*0.16, 0, s*0.28)}, -- bottom
        {UDim2.new(0, 0, 0.5, -s*0.08),               UDim2.new(0, s*0.28, 0, s*0.16)}, -- left
        {UDim2.new(1, -s*0.28, 0.5, -s*0.08),         UDim2.new(0, s*0.28, 0, s*0.16)}, -- right
    }
    for _, t in ipairs(teeth) do
        bar(c, t[2], t[1], col, 2)
    end
    return c
end

-- 👑 CROWN → 3 puncak + base
IconFactory.crown = function(parent, size, col, z)
    local c = Instance.new("Frame")
    c.Size = UDim2.new(0, size, 0, size)
    c.BackgroundTransparency = 1
    c.ZIndex = z or 20
    c.Parent = parent

    local s = size
    -- base
    bar(c, UDim2.new(0, s*0.8, 0, s*0.16),
        UDim2.new(0.5, -s*0.4, 1, -s*0.24), col, 2)
    -- 3 puncak (triangle pakai Frame rotated 45)
    local peaks = {
        {UDim2.new(0.5, -s*0.14, 0, s*0.2),  s*0.28}, -- tengah
        {UDim2.new(0.1, 0, 0, s*0.4),         s*0.2},  -- kiri
        {UDim2.new(0.9, -s*0.2, 0, s*0.4),    s*0.2},  -- kanan
    }
    for _, p in ipairs(peaks) do
        local peak = Instance.new("Frame")
        peak.Size = UDim2.new(0, p[2], 0, p[2])
        peak.Position = p[1]
        peak.BackgroundColor3 = col
        peak.BorderSizePixel = 0
        peak.Rotation = 45
        peak.ZIndex = z or 20
        peak.Parent = c
        corner(peak, 2)
    end
    return c
end

-- ═══════════════════════════════════════════════════════════════════════
-- TOAST
-- ═══════════════════════════════════════════════════════════════════════
local function toast(msg, color)
    if not State.screenGui then return end
    local s = State.scale
    local W = math.floor(320 * s)
    local H = math.floor(44 * s)

    local t = Instance.new("Frame")
    t.Size = UDim2.new(0, W, 0, H)
    t.Position = UDim2.new(0.5, -W/2, 1, 30)
    t.BackgroundColor3 = THEME.PANEL
    t.BackgroundTransparency = THEME.PANEL_TRANS
    t.BorderSizePixel = 0
    t.ZIndex = 250
    t.Active = false
    t.Parent = State.screenGui
    corner(t, 10)
    stroke(t, color or THEME.ACCENT, 1.5, 0)

    label(t, {
        Text = msg,
        Color = color or THEME.TEXT,
        Font = Enum.Font.GothamMedium,
        Size = math.floor(11 * s),
        FrameSize = UDim2.new(1, -20, 1, 0),
        Pos = UDim2.new(0, 10, 0, 0),
        XAlign = Enum.TextXAlignment.Center,
        Wrap = true,
        Z = 251,
    })

    TweenService:Create(t, TweenInfo.new(0.4, Enum.EasingStyle.Quint),
        { Position = UDim2.new(0.5, -W/2, 1, -60) }):Play()

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

    -- Shadow
    local shadow = Instance.new("Frame")
    shadow.Size = UDim2.new(0, BW + 10, 0, BH + 10)
    shadow.Position = UDim2.new(0.5, -(BW+10)/2, 0.5, -(BH+10)/2 + 5)
    shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    shadow.BackgroundTransparency = 0.55
    shadow.BorderSizePixel = 0
    shadow.ZIndex = 0
    shadow.Active = false
    shadow.Parent = gui
    corner(shadow, 16)
    State.shadow = shadow

    -- Main
    local main = Instance.new("Frame")
    main.Name = "Main"
    main.Size = UDim2.new(0, BW, 0, BH)
    main.Position = UDim2.new(0.5, -BW/2, 0.5, -BH/2)
    main.BackgroundColor3 = THEME.PANEL_DARK
    main.BackgroundTransparency = THEME.BG_TRANS
    main.BorderSizePixel = 0
    main.ClipsDescendants = true
    main.Active = true
    main.ZIndex = 3
    main.Parent = gui
    corner(main, 14)
    stroke(main, THEME.ACCENT, 1.2, 0.2)
    State.mainFrame = main

    -- Background
    local bgImg = Instance.new("ImageLabel")
    bgImg.Size = UDim2.new(1, 0, 1, 0)
    bgImg.BackgroundTransparency = 1
    bgImg.Image = THEME.BG_ASSET
    bgImg.ScaleType = Enum.ScaleType.Crop
    bgImg.ImageTransparency = THEME.BG_TRANS
    bgImg.Active = false
    bgImg.ZIndex = 1
    bgImg.Parent = main
    corner(bgImg, 14)

    -- Overlay
    local ov = Instance.new("Frame")
    ov.Size = UDim2.new(1, 0, 1, 0)
    ov.BackgroundColor3 = Color3.fromRGB(8, 8, 12)
    ov.BackgroundTransparency = 0.35
    ov.BorderSizePixel = 0
    ov.Active = false
    ov.ZIndex = 2
    ov.Parent = main
    corner(ov, 14)
    local ovGrad = Instance.new("UIGradient")
    ovGrad.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.2),
        NumberSequenceKeypoint.new(0.5, 0.55),
        NumberSequenceKeypoint.new(1, 0.75),
    })
    ovGrad.Rotation = 90
    ovGrad.Parent = ov

    -- ═══════════════ HEADER ═══════════════
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, HH)
    header.BackgroundColor3 = THEME.PANEL_DARK
    header.BackgroundTransparency = THEME.BG_TRANS
    header.BorderSizePixel = 0
    header.Active = true
    header.ZIndex = 6
    header.Parent = main
    corner(header, 14)

    -- Logo diamond (bukan emoji)
    local logoWrap = Instance.new("Frame")
    logoWrap.Size = UDim2.new(0, math.floor(24 * s), 0, math.floor(24 * s))
    logoWrap.Position = UDim2.new(0, math.floor(14 * s), 0.5, -math.floor(12 * s))
    logoWrap.BackgroundTransparency = 1
    logoWrap.ZIndex = 7
    logoWrap.Parent = header
    local logoD = Instance.new("Frame")
    logoD.Size = UDim2.new(0, math.floor(14 * s), 0, math.floor(14 * s))
    logoD.Position = UDim2.new(0.5, -math.floor(7 * s), 0.5, -math.floor(7 * s))
    logoD.BackgroundColor3 = THEME.ACCENT
    logoD.BorderSizePixel = 0
    logoD.Rotation = 45
    logoD.ZIndex = 8
    logoD.Parent = logoWrap
    corner(logoD, 2)

    label(header, {
        Text = "KEI SELVIM",
        Color = THEME.TEXT,
        Font = Enum.Font.GothamBlack,
        Size = math.floor(12 * s),
        FrameSize = UDim2.new(0, math.floor(100 * s), 1, 0),
        Pos = UDim2.new(0, math.floor(46 * s), 0, 0),
        Z = 7,
    })

    local badge = Instance.new("Frame")
    badge.Size = UDim2.new(0, math.floor(38 * s), 0, math.floor(16 * s))
    badge.Position = UDim2.new(0, math.floor(150 * s), 0, math.floor((HH - 16 * s)/2))
    badge.BackgroundColor3 = THEME.ACCENT
    badge.BackgroundTransparency = 0.4
    badge.BorderSizePixel = 0
    badge.Active = false
    badge.ZIndex = 7
    badge.Parent = header
    corner(badge, 4)
    label(badge, {
        Text = "v1.1",
        Color = Color3.fromRGB(255, 220, 255),
        Font = Enum.Font.GothamBold,
        Size = math.floor(9 * s),
        XAlign = Enum.TextXAlignment.Center,
        Z = 8,
    })

    -- Close button — glyph ✕ (bukan emoji, ini symbol matematika)
    local btnS = math.floor(26 * s)
    local closeBtn = button(header, {
        Name = "Close",
        Text = "✕",
        Color = THEME.DANGER,
        StrokeColor = THEME.DANGER,
        Font = Enum.Font.GothamBold,
        TextSize = math.floor(12 * s),
        FrameSize = UDim2.new(0, btnS, 0, btnS),
        Pos = UDim2.new(1, -math.floor(34 * s), 0, math.floor((HH - btnS)/2)),
        Radius = 6,
        Z = 10,
    })

    -- Minimize button — pakai bar (bukan emoji)
    local minBtn = button(header, {
        Name = "Minimize",
        Color = THEME.PANEL,
        StrokeColor = THEME.ACCENT_DIM,
        FrameSize = UDim2.new(0, btnS, 0, btnS),
        Pos = UDim2.new(1, -math.floor(64 * s), 0, math.floor((HH - btnS)/2)),
        Radius = 6,
        Z = 10,
    })
    local minBar = Instance.new("Frame")
    minBar.Size = UDim2.new(0, math.floor(12 * s), 0, math.floor(2 * s))
    minBar.Position = UDim2.new(0.5, -math.floor(6 * s), 0.5, -math.floor(1 * s))
    minBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    minBar.BorderSizePixel = 0
    minBar.ZIndex = 12
    minBar.Parent = minBtn
    corner(minBar, 1)

    -- ═══════════════ SIDEBAR ═══════════════
    local sidebar = Instance.new("Frame")
    sidebar.Size = UDim2.new(0, SBW, 1, -HH)
    sidebar.Position = UDim2.new(0, 0, 0, HH)
    sidebar.BackgroundColor3 = THEME.PANEL_DARK
    sidebar.BackgroundTransparency = 0.35
    sidebar.BorderSizePixel = 0
    sidebar.Active = false
    sidebar.ZIndex = 5
    sidebar.Parent = main

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
            Size = math.floor(15 * s),
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
                Pos = UDim2.new(0, 0, 0, math.floor(26 * s)),
                Z = 8,
            })
        end

        local body = Instance.new("Frame")
        body.Size = UDim2.new(1, 0, 1, -math.floor(50 * s))
        body.Position = UDim2.new(0, 0, 0, math.floor(50 * s))
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
    profileCard.Size = UDim2.new(1, 0, 0, math.floor(64 * s))
    profileCard.BackgroundColor3 = THEME.PANEL
    profileCard.BackgroundTransparency = THEME.PANEL_TRANS
    profileCard.BorderSizePixel = 0
    profileCard.Active = false
    profileCard.ZIndex = 7
    profileCard.Parent = homeBody
    corner(profileCard, 10)
    stroke(profileCard, THEME.ACCENT_DIM, 1, 0.2)

    local av = Instance.new("ImageLabel")
    av.Size = UDim2.new(0, math.floor(46 * s), 0, math.floor(46 * s))
    av.Position = UDim2.new(0, math.floor(10 * s), 0.5, -math.floor(23 * s))
    av.BackgroundColor3 = THEME.ACCENT_DIM
    av.BackgroundTransparency = 0.3
    av.BorderSizePixel = 0
    av.Active = false
    av.ZIndex = 8
    av.Parent = profileCard
    corner(av, math.floor(23 * s))

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
        FrameSize = UDim2.new(1, -math.floor(70 * s), 0, math.floor(18 * s)),
        Pos = UDim2.new(0, math.floor(66 * s), 0, math.floor(10 * s)),
        Z = 8,
    })
    label(profileCard, {
        Text = "@" .. (LocalPlayer and LocalPlayer.Name or "unknown"),
        Color = THEME.TEXT_DIM,
        Font = Enum.Font.Gotham,
        Size = math.floor(10 * s),
        FrameSize = UDim2.new(1, -math.floor(70 * s), 0, math.floor(14 * s)),
        Pos = UDim2.new(0, math.floor(66 * s), 0, math.floor(28 * s)),
        Z = 8,
    })
    label(profileCard, {
        Text = "Kei Selvim  •  UI Shell",
        Color = THEME.ACCENT_GLOW,
        Font = Enum.Font.GothamMedium,
        Size = math.floor(9 * s),
        FrameSize = UDim2.new(1, -math.floor(70 * s), 0, math.floor(14 * s)),
        Pos = UDim2.new(0, math.floor(66 * s), 0, math.floor(44 * s)),
        Z = 8,
    })

    -- Stat grid
    local statsGrid = Instance.new("Frame")
    statsGrid.Size = UDim2.new(1, 0, 0, math.floor(130 * s))
    statsGrid.Position = UDim2.new(0, 0, 0, math.floor(72 * s))
    statsGrid.BackgroundTransparency = 1
    statsGrid.Active = false
    statsGrid.ZIndex = 7
    statsGrid.Parent = homeBody

    local grid = Instance.new("UIGridLayout")
    grid.CellSize = UDim2.new(0.5, -math.floor(6 * s), 0, math.floor(60 * s))
    grid.CellPadding = UDim2.new(0, math.floor(12 * s), 0, math.floor(10 * s))
    grid.SortOrder = Enum.SortOrder.LayoutOrder
    grid.Parent = statsGrid

    -- Icon kecil untuk stat card — pakai geometric symbol, bukan emoji
    local function makeStatCard(order, title, value, color, iconSymbol)
        local card = Instance.new("Frame")
        card.BackgroundColor3 = THEME.PANEL
        card.BackgroundTransparency = THEME.PANEL_TRANS
        card.BorderSizePixel = 0
        card.LayoutOrder = order
        card.Active = false
        card.ZIndex = 8
        card.Parent = statsGrid
        corner(card, 10)
        stroke(card, THEME.ACCENT_DIM, 1, 0.2)

        -- Icon pakai symbol geometris (◆ ● ▲ ■ dll)
        label(card, {
            Text = iconSymbol,
            Color = color,
            Font = Enum.Font.GothamBold,
            Size = math.floor(14 * s),
            FrameSize = UDim2.new(0, math.floor(22 * s), 0, math.floor(20 * s)),
            Pos = UDim2.new(0, math.floor(10 * s), 0, math.floor(8 * s)),
            XAlign = Enum.TextXAlignment.Center,
            Z = 9,
        })
        label(card, {
            Text = title,
            Color = THEME.TEXT_DIM,
            Font = Enum.Font.Gotham,
            Size = math.floor(9 * s),
            FrameSize = UDim2.new(1, -math.floor(40 * s), 0, math.floor(14 * s)),
            Pos = UDim2.new(0, math.floor(36 * s), 0, math.floor(10 * s)),
            Z = 9,
        })
        label(card, {
            Text = value,
            Color = color,
            Font = Enum.Font.GothamBold,
            Size = math.floor(15 * s),
            FrameSize = UDim2.new(1, -math.floor(20 * s), 0, math.floor(22 * s)),
            Pos = UDim2.new(0, math.floor(10 * s), 0, math.floor(30 * s)),
            Z = 9,
        })
    end

    makeStatCard(1, "FPS",     "60",     Color3.fromRGB(100, 255, 150), "▲")
    makeStatCard(2, "PING",    "0 ms",   Color3.fromRGB(255, 200, 100), "●")
    makeStatCard(3, "STATUS",  "Ready",  Color3.fromRGB(150, 200, 255), "◆")
    makeStatCard(4, "MODE",    "UI Only",Color3.fromRGB(255, 150, 200), "■")

    -- ─── TOOLS ───
    local toolsBody = makePage("tools", "Tools", "Function panel")

    local toolsCard = Instance.new("Frame")
    toolsCard.Size = UDim2.new(1, 0, 0, math.floor(150 * s))
    toolsCard.BackgroundColor3 = THEME.PANEL
    toolsCard.BackgroundTransparency = THEME.PANEL_TRANS
    toolsCard.BorderSizePixel = 0
    toolsCard.Active = false
    toolsCard.ZIndex = 7
    toolsCard.Parent = toolsBody
    corner(toolsCard, 10)
    stroke(toolsCard, THEME.ACCENT_DIM, 1, 0.2)

    -- Icon tools di tengah card
    local iconWrap = Instance.new("Frame")
    iconWrap.Size = UDim2.new(0, math.floor(36 * s), 0, math.floor(36 * s))
    iconWrap.Position = UDim2.new(0.5, -math.floor(18 * s), 0, math.floor(14 * s))
    iconWrap.BackgroundTransparency = 1
    iconWrap.ZIndex = 8
    iconWrap.Parent = toolsCard
    IconFactory.tools(iconWrap, math.floor(36 * s), THEME.ACCENT_GLOW, 20)

    label(toolsCard, {
        Text = "Tools panel — logic di sini nanti",
        Color = THEME.TEXT_DIM,
        Font = Enum.Font.Gotham,
        Size = math.floor(11 * s),
        FrameSize = UDim2.new(1, 0, 0, math.floor(20 * s)),
        Pos = UDim2.new(0, 0, 0, math.floor(58 * s)),
        XAlign = Enum.TextXAlignment.Center,
        Z = 8,
    })

    local sampleBtn = button(toolsCard, {
        Text = "Sample Button",
        FrameSize = UDim2.new(1, -math.floor(40 * s), 0, math.floor(32 * s)),
        Pos = UDim2.new(0, math.floor(20 * s), 0, math.floor(96 * s)),
        TextSize = math.floor(11 * s),
        Z = 9,
    })
    sampleBtn.MouseButton1Click:Connect(function()
        toast("Sample button clicked — placeholder", THEME.ACCENT_GLOW)
    end)

    -- ─── CONFIG ───
    local configBody = makePage("config", "Config", "Settings panel")

    local configCard = Instance.new("Frame")
    configCard.Size = UDim2.new(1, 0, 0, math.floor(120 * s))
    configCard.BackgroundColor3 = THEME.PANEL
    configCard.BackgroundTransparency = THEME.PANEL_TRANS
    configCard.BorderSizePixel = 0
    configCard.Active = false
    configCard.ZIndex = 7
    configCard.Parent = configBody
    corner(configCard, 10)
    stroke(configCard, THEME.ACCENT_DIM, 1, 0.2)

    local cfgIconWrap = Instance.new("Frame")
    cfgIconWrap.Size = UDim2.new(0, math.floor(36 * s), 0, math.floor(36 * s))
    cfgIconWrap.Position = UDim2.new(0.5, -math.floor(18 * s), 0, math.floor(16 * s))
    cfgIconWrap.BackgroundTransparency = 1
    cfgIconWrap.ZIndex = 8
    cfgIconWrap.Parent = configCard
    IconFactory.config(cfgIconWrap, math.floor(36 * s), THEME.ACCENT_GLOW, 20)

    label(configCard, {
        Text = "Config panel — logic di sini nanti",
        Color = THEME.TEXT_DIM,
        Font = Enum.Font.Gotham,
        Size = math.floor(11 * s),
        FrameSize = UDim2.new(1, 0, 0, math.floor(20 * s)),
        Pos = UDim2.new(0, 0, 0, math.floor(64 * s)),
        XAlign = Enum.TextXAlignment.Center,
        Z = 8,
    })

    -- ─── CROWN ───
    local crownBody = makePage("crown", "Crown", "Admin panel")

    local crownCard = Instance.new("Frame")
    crownCard.Size = UDim2.new(1, 0, 0, math.floor(120 * s))
    crownCard.BackgroundColor3 = THEME.PANEL
    crownCard.BackgroundTransparency = THEME.PANEL_TRANS
    crownCard.BorderSizePixel = 0
    crownCard.Active = false
    crownCard.ZIndex = 7
    crownCard.Parent = crownBody
    corner(crownCard, 10)
    stroke(crownCard, Color3.fromRGB(255, 200, 60), 1, 0.2)

    local crownIconWrap = Instance.new("Frame")
    crownIconWrap.Size = UDim2.new(0, math.floor(36 * s), 0, math.floor(36 * s))
    crownIconWrap.Position = UDim2.new(0.5, -math.floor(18 * s), 0, math.floor(16 * s))
    crownIconWrap.BackgroundTransparency = 1
    crownIconWrap.ZIndex = 8
    crownIconWrap.Parent = crownCard
    IconFactory.crown(crownIconWrap, math.floor(36 * s), Color3.fromRGB(255, 200, 60), 20)

    label(crownCard, {
        Text = "Admin panel — logic di sini nanti",
        Color = Color3.fromRGB(255, 200, 60),
        Font = Enum.Font.Gotham,
        Size = math.floor(11 * s),
        FrameSize = UDim2.new(1, 0, 0, math.floor(20 * s)),
        Pos = UDim2.new(0, 0, 0, math.floor(64 * s)),
        XAlign = Enum.TextXAlignment.Center,
        Z = 8,
    })

    -- ═══════════════ SIDEBAR ICONS ═══════════════
    -- Tiap icon digambar dari primitive shape, bukan emoji
    local iconList = {
        { id = "home",   factory = IconFactory.home },
        { id = "tools",  factory = IconFactory.tools },
        { id = "config", factory = IconFactory.config },
        { id = "crown",  factory = IconFactory.crown },
    }

    local iconY = math.floor(10 * s)
    for i, item in ipairs(iconList) do
        -- Container button
        local btn = Instance.new("TextButton")
        btn.Name = item.id .. "Icon"
        btn.BackgroundColor3 = THEME.ACCENT_DIM
        btn.BackgroundTransparency = THEME.BTN_TRANS
        btn.Text = ""
        btn.Size = UDim2.new(0, ICS, 0, ICS)
        btn.Position = UDim2.new(0, math.floor((SBW - ICS)/2), 0, iconY + (i-1) * (ICS + ICG))
        btn.BorderSizePixel = 0
        btn.AutoButtonColor = false
        btn.Active = true
        btn.Selectable = true
        btn.ZIndex = 10
        btn.Parent = sidebar
        corner(btn, 10)
        stroke(btn, THEME.ACCENT_DIM, 1, 0.3)

        -- Icon di dalam button
        local iconHolder = Instance.new("Frame")
        iconHolder.Size = UDim2.new(0, math.floor(22 * s), 0, math.floor(22 * s))
        iconHolder.Position = UDim2.new(0.5, -math.floor(11 * s), 0.5, -math.floor(11 * s))
        iconHolder.BackgroundTransparency = 1
        iconHolder.ZIndex = 12
        iconHolder.Parent = btn

        local iconFrame = item.factory(iconHolder, math.floor(22 * s), Color3.fromRGB(230, 220, 255), 12)
        State.sidebarButtons[item.id] = { button = btn, icon = iconFrame }

        -- Hover
        local baseColor = THEME.ACCENT_DIM
        local baseTrans = THEME.BTN_TRANS
        btn.MouseEnter:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.15), {
                BackgroundColor3 = THEME.ACCENT_GLOW,
                BackgroundTransparency = math.max(0, baseTrans - 0.1),
            }):Play()
        end)
        btn.MouseLeave:Connect(function()
            -- Kalo ini current page, tetap terang
            local target = (State.currentPage == item.id) and THEME.ACCENT or baseColor
            TweenService:Create(btn, TweenInfo.new(0.15), {
                BackgroundColor3 = target,
                BackgroundTransparency = baseTrans,
            }):Play()
        end)
    end

    -- ═══════════════ PAGE SWITCHING ═══════════════
    local function switchPage(id)
        for pid, page in pairs(State.pages) do
            page.Visible = (pid == id)
        end
        for bid, data in pairs(State.sidebarButtons) do
            if bid == id then
                data.button.BackgroundColor3 = THEME.ACCENT
            else
                data.button.BackgroundColor3 = THEME.ACCENT_DIM
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
                startPos.X.Scale, startPos.X.Offset + delta.X - 5,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y - 5
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
        local cW = math.floor(300 * s)
        local cH = math.floor(140 * s)
        local confirm = Instance.new("Frame")
        confirm.Size = UDim2.new(0, cW, 0, cH)
        confirm.Position = UDim2.new(0.5, -cW/2, 0.5, -cH/2)
        confirm.BackgroundColor3 = THEME.PANEL
        confirm.BackgroundTransparency = THEME.PANEL_TRANS
        confirm.BorderSizePixel = 0
        confirm.Active = true
        confirm.ZIndex = 300
        confirm.Parent = gui
        corner(confirm, 12)
        stroke(confirm, THEME.DANGER, 1.5, 0)

        label(confirm, {
            Text = "Konfirmasi",
            Color = Color3.fromRGB(255, 200, 100),
            Font = Enum.Font.GothamBold,
            Size = math.floor(14 * s),
            FrameSize = UDim2.new(1, 0, 0, math.floor(26 * s)),
            Pos = UDim2.new(0, 0, 0, math.floor(14 * s)),
            XAlign = Enum.TextXAlignment.Center,
            Z = 301,
        })
        label(confirm, {
            Text = "Yakin mau tutup Kei Selvim?",
            Color = THEME.TEXT,
            Font = Enum.Font.Gotham,
            Size = math.floor(11 * s),
            FrameSize = UDim2.new(1, -20, 0, math.floor(36 * s)),
            Pos = UDim2.new(0, 10, 0, math.floor(46 * s)),
            XAlign = Enum.TextXAlignment.Center,
            Wrap = true,
            Z = 301,
        })

        local bW = (cW - math.floor(30 * s)) / 2
        local yes = button(confirm, {
            Text = "Ya, Tutup",
            Color = THEME.DANGER,
            StrokeColor = THEME.DANGER,
            Font = Enum.Font.GothamBold,
            TextSize = math.floor(11 * s),
            FrameSize = UDim2.new(0, bW, 0, math.floor(30 * s)),
            Pos = UDim2.new(0, math.floor(10 * s), 0, math.floor(94 * s)),
            Radius = 8,
            Z = 302,
        })
        local no = button(confirm, {
            Text = "Batal",
            Color = THEME.ACCENT_DIM,
            StrokeColor = THEME.ACCENT_DIM,
            Font = Enum.Font.GothamBold,
            TextSize = math.floor(11 * s),
            FrameSize = UDim2.new(0, bW, 0, math.floor(30 * s)),
            Pos = UDim2.new(0, math.floor(20 * s) + bW, 0, math.floor(94 * s)),
            Radius = 8,
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
        State.minimized = true

        if not State.kButton or not State.kButton.Parent then
            local kS = math.floor(46 * s)
            local k = Instance.new("TextButton")
            k.Name = "KButton"
            k.Size = UDim2.new(0, kS, 0, kS)
            k.Position = UDim2.new(0, math.floor(20 * s), 0.5, -kS/2)
            k.BackgroundColor3 = THEME.ACCENT
            k.BackgroundTransparency = THEME.BTN_TRANS
            k.Text = "K"
            k.TextColor3 = Color3.fromRGB(255, 255, 255)
            k.Font = Enum.Font.GothamBlack
            k.TextSize = math.floor(20 * s)
            k.BorderSizePixel = 0
            k.AutoButtonColor = false
            k.Active = true
            k.Draggable = true
            k.ZIndex = 50
            k.Parent = gui
            corner(k, kS/2)
            stroke(k, Color3.fromRGB(255, 255, 255), 2, 0)

            k.MouseButton1Click:Connect(function()
                main.Visible = true
                shadow.Visible = true
                State.minimized = false
                k.Visible = false
            end)
            State.kButton = k
        end
        State.kButton.Visible = true
    end)

    switchPage("home")
    toast("Kei Selvim UI v1.1 loaded", THEME.SUCCESS)
end

-- ═══════════════════════════════════════════════════════════════════════
-- BOOT
-- ═══════════════════════════════════════════════════════════════════════
task.wait(0.3)
buildUI()
