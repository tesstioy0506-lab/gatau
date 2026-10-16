--[[
    KEI SELVIM — UI SHELL v2.2
    Fixed: menu/icon/tombol render, no double-connect, no ZIndex trap
]]

local THEME = {
    BG_ASSET     = "rbxassetid://0",
    ACCENT       = Color3.fromRGB(150, 80, 240),
    ACCENT_LITE  = Color3.fromRGB(180, 130, 255),
    ACCENT_DIM   = Color3.fromRGB(60, 30, 105),
    ACCENT_GLOW  = Color3.fromRGB(190, 140, 255),
    SURFACE      = Color3.fromRGB(22, 22, 32),
    SURFACE_2    = Color3.fromRGB(16, 16, 24),
    SURFACE_3    = Color3.fromRGB(30, 30, 44),
    BTN_IDLE     = Color3.fromRGB(38, 38, 52),
    BTN_HOVER    = Color3.fromRGB(52, 52, 68),
    HAIRLINE     = Color3.fromRGB(255, 255, 255),
    TEXT         = Color3.fromRGB(245, 245, 250),
    TEXT_DIM     = Color3.fromRGB(150, 150, 170),
    TEXT_FAINT   = Color3.fromRGB(100, 100, 120),
    DANGER       = Color3.fromRGB(240, 80, 105),
    SUCCESS      = Color3.fromRGB(100, 220, 150),
    WARN         = Color3.fromRGB(255, 190, 90),
    BG_TRANS     = 0.15,
    PANEL_TRANS  = 0.35,
    BTN_TRANS    = 0.15,
    HAIRLINE_TR  = 0.85,
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

local Players          = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local CoreGui          = game:GetService("CoreGui")
local LocalPlayer      = Players.LocalPlayer

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

local function corner(p, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 8)
    c.Parent = p
    return c
end

local function stroke(p, col, thick, trans)
    local s = Instance.new("UIStroke")
    s.Color = col or THEME.HAIRLINE
    s.Thickness = thick or 1
    s.Transparency = trans or 0
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = p
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
    l.ZIndex = props.Z or 5
    l.Active = false
    l.Parent = parent
    return l
end

-- Tombol: idle abu → active ungu, hover abu terang
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
    b.ZIndex = props.Z or 5
    b.Parent = parent
    corner(b, props.Radius or THEME.RADIUS_MD)
    local s = stroke(b, props.StrokeColor or THEME.HAIRLINE, 1, props.StrokeTrans or 0.88)

    -- Text di atas button — ZIndex default 5 (sama) tapi render belakangan
    if props.Text and props.Text ~= "" then
        local tl = Instance.new("TextLabel")
        tl.BackgroundTransparency = 1
        tl.Text = props.Text
        tl.TextColor3 = props.TextColor or THEME.TEXT
        tl.Font = props.Font or Enum.Font.GothamSemibold
        tl.TextSize = props.TextSize or 12
        tl.Size = UDim2.new(1, 0, 1, 0)
        tl.Position = UDim2.new(0, 0, 0, 0)
        tl.ZIndex = 6
        tl.Active = false
        tl.Parent = b
        b._textLabel = tl
    end

    local isActive = false
    local idleCol = props.IdleColor or THEME.BTN_IDLE
    local hoverCol = props.HoverColor or THEME.BTN_HOVER
    local activeCol = props.ActiveColor or THEME.ACCENT
    local idleTrans = props.Trans or THEME.BTN_TRANS
    local activeTrans = math.max(0, idleTrans - 0.05)

    local function refresh(hovering)
        local col, trans, st, tc
        if isActive then
            col, trans, st, tc = activeCol, activeTrans, 0.15, Color3.fromRGB(255, 255, 255)
        elseif hovering then
            col, trans, st, tc = hoverCol, idleTrans, 0.6, THEME.TEXT
        else
            col, trans, st, tc = idleCol, idleTrans, 0.88, props.TextColor or THEME.TEXT
        end
        TweenService:Create(b, TweenInfo.new(0.15), {
            BackgroundColor3 = col,
            BackgroundTransparency = trans,
        }):Play()
        TweenService:Create(s, TweenInfo.new(0.15), { Transparency = st }):Play()
        if b._textLabel then
            TweenService:Create(b._textLabel, TweenInfo.new(0.15), { TextColor3 = tc }):Play()
        end
    end

    b.MouseEnter:Connect(function() refresh(true) end)
    b.MouseLeave:Connect(function() refresh(false) end)

    b.SetActive = function(v)
        isActive = v and true or false
        refresh(false)
    end
    b.GetActive = function() return isActive end

    return b
end

-- ═══════════════════════════════════════════════════════════════════════
-- ICON FACTORY — return { container, frames[], strokes[] }
-- Semua part di-flatten biar gampang recolor tanpa hack
-- ═══════════════════════════════════════════════════════════════════════
local IconFactory = {}

local function makeIconHolder(parent, size)
    local c = Instance.new("Frame")
    c.Size = UDim2.new(0, size, 0, size)
    c.Position = UDim2.new(0.5, -size/2, 0.5, -size/2)
    c.BackgroundTransparency = 1
    c.ZIndex = 6
    c.Parent = parent
    return c
end

local function bar(parent, size, pos, col, rot, r)
    local f = Instance.new("Frame")
    f.Size = size
    f.Position = pos
    f.BackgroundColor3 = col
    f.BorderSizePixel = 0
    f.ZIndex = 6
    f.Parent = parent
    if r then corner(f, r) end
    if rot then f.Rotation = rot end
    return f
end

-- HOME: outline rumah
IconFactory.home = function(holder, size, col)
    local frames = {}
    local s = size
    local t = math.max(1.5, s * 0.1)

    -- Body kotak (4 garis)
    local bx, by = s*0.22, s*0.42
    local bw, bh = s*0.56, s*0.48
    table.insert(frames, bar(holder, UDim2.new(0, bw, 0, t), UDim2.new(0, bx, 0, by), col, 0, 1))
    table.insert(frames, bar(holder, UDim2.new(0, bw, 0, t), UDim2.new(0, bx, 0, by+bh), col, 0, 1))
    table.insert(frames, bar(holder, UDim2.new(0, t, 0, bh+t), UDim2.new(0, bx, 0, by), col, 0, 1))
    table.insert(frames, bar(holder, UDim2.new(0, t, 0, bh+t), UDim2.new(0, bx+bw, 0, by), col, 0, 1))

    -- Atap: 2 garis diagonal
    local roofW = s * 0.4
    local roofH = s * 0.28
    table.insert(frames, bar(holder,
        UDim2.new(0, roofW, 0, t),
        UDim2.new(0.5, -roofW, by - roofH + t/2, 0),
        col, -35, 1))
    table.insert(frames, bar(holder,
        UDim2.new(0, roofW, 0, t),
        UDim2.new(0.5, 0, by - roofH + t/2, 0),
        col, 35, 1))

    return frames
end

-- TOOLS: wrench outline
IconFactory.tools = function(holder, size, col)
    local frames = {}
    local s = size
    local t = math.max(1.5, s * 0.1)

    table.insert(frames, bar(holder,
        UDim2.new(0, s*0.5, 0, t),
        UDim2.new(0.2, 0, 0.55, -t/2),
        col, -40, 1))

    table.insert(frames, bar(holder, UDim2.new(0, t, 0, s*0.28),
        UDim2.new(0.62, 0, 0.14, 0), col, 0, 1))
    table.insert(frames, bar(holder, UDim2.new(0, s*0.22, 0, t),
        UDim2.new(0.62, 0, 0.14, 0), col, 0, 1))
    table.insert(frames, bar(holder, UDim2.new(0, s*0.22, 0, t),
        UDim2.new(0.62, 0, 0.40, 0), col, 0, 1))

    return frames
end

-- CONFIG: gear outline
IconFactory.config = function(holder, size, col)
    local frames = {}
    local s = size
    local t = math.max(1.5, s * 0.1)

    -- Outer ring pakai Frame + UICorner, isi dot kecil di tengah
    local ring = Instance.new("Frame")
    ring.Size = UDim2.new(0, s*0.58, 0, s*0.58)
    ring.Position = UDim2.new(0.5, -s*0.29, 0.5, -s*0.29)
    ring.BackgroundColor3 = col
    ring.BorderSizePixel = 0
    ring.ZIndex = 6
    ring.Parent = holder
    corner(ring, s*0.29)
    table.insert(frames, ring)

    -- Inner dot (warna surface biar bikin ring keliatan berlubang)
    local inner = Instance.new("Frame")
    inner.Size = UDim2.new(0, s*0.2, 0, s*0.2)
    inner.Position = UDim2.new(0.5, -s*0.1, 0.5, -s*0.1)
    inner.BackgroundColor3 = THEME.SURFACE_2
    inner.BackgroundTransparency = 0.2
    inner.BorderSizePixel = 0
    inner.ZIndex = 7
    inner.Parent = holder
    corner(inner, s*0.1)

    -- 4 gigi
    table.insert(frames, bar(holder, UDim2.new(0, t, 0, s*0.16),
        UDim2.new(0.5, -t/2, 0, s*0.1), col, 0, 1))
    table.insert(frames, bar(holder, UDim2.new(0, t, 0, s*0.16),
        UDim2.new(0.5, -t/2, 1, -s*0.26), col, 0, 1))
    table.insert(frames, bar(holder, UDim2.new(0, s*0.16, 0, t),
        UDim2.new(0, s*0.1, 0.5, -t/2), col, 0, 1))
    table.insert(frames, bar(holder, UDim2.new(0, s*0.16, 0, t),
        UDim2.new(1, -s*0.26, 0.5, -t/2), col, 0, 1))

    return frames
end

-- CROWN: 3 puncak + base
IconFactory.crown = function(holder, size, col)
    local frames = {}
    local s = size
    local t = math.max(1.5, s * 0.1)

    table.insert(frames, bar(holder, UDim2.new(0, s*0.7, 0, t),
        UDim2.new(0.5, -s*0.35, 1, -s*0.22), col, 0, 1))

    local peaks = {
        {pos = UDim2.new(0.5, -s*0.11, 0, s*0.2),  size = s*0.22},
        {pos = UDim2.new(0.14, 0, 0, s*0.34),       size = s*0.18},
        {pos = UDim2.new(0.86, -s*0.18, 0, s*0.34), size = s*0.18},
    }
    for _, p in ipairs(peaks) do
        local pk = Instance.new("Frame")
        pk.Size = UDim2.new(0, p.size, 0, p.size)
        pk.Position = p.pos
        pk.BackgroundColor3 = col
        pk.BorderSizePixel = 0
        pk.Rotation = 45
        pk.ZIndex = 6
        pk.Parent = holder
        corner(pk, 2)
        table.insert(frames, pk)
    end

    return frames
end

local function recolor(frames, col)
    for _, f in ipairs(frames) do
        if f and f.Parent then
            f.BackgroundColor3 = col
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
    t.BackgroundTransparency = 0.15
    t.BorderSizePixel = 0
    t.ZIndex = 200
    t.Active = false
    t.Parent = State.screenGui
    corner(t, THEME.RADIUS_MD)
    stroke(t, color or THEME.ACCENT_LITE, 1, 0.4)

    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, math.floor(8 * s), 0, math.floor(8 * s))
    dot.Position = UDim2.new(0, math.floor(14 * s), 0.5, -math.floor(4 * s))
    dot.BackgroundColor3 = color or THEME.ACCENT_LITE
    dot.BorderSizePixel = 0
    dot.ZIndex = 202
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
        Z = 201,
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
    if not parentGui then
        warn("[Kei] no parent")
        return
    end

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

    -- Shadow + glow
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

    local glow = Instance.new("Frame")
    glow.Size = UDim2.new(0, BW + 30, 0, BH + 30)
    glow.Position = UDim2.new(0.5, -(BW+30)/2, 0.5, -(BH+30)/2 + 4)
    glow.BackgroundColor3 = THEME.ACCENT
    glow.BackgroundTransparency = 0.9
    glow.BorderSizePixel = 0
    glow.ZIndex = 0
    glow.Active = false
    glow.Parent = gui
    corner(glow, THEME.RADIUS_LG + 8)

    -- Main frame
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

    -- BG image
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

    -- Overlay gradient
    local ov = Instance.new("Frame")
    ov.Size = UDim2.new(1, 0, 1, 0)
    ov.BackgroundColor3 = Color3.fromRGB(8, 8, 14)
    ov.BackgroundTransparency = 0.3
    ov.BorderSizePixel = 0
    ov.Active = false
    ov.ZIndex = 2
    ov.Parent = main
    corner(ov, THEME.RADIUS_LG)
    local ovg = Instance.new("UIGradient")
    ovg.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.15),
        NumberSequenceKeypoint.new(0.5, 0.5),
        NumberSequenceKeypoint.new(1, 0.75),
    })
    ovg.Rotation = 90
    ovg.Parent = ov

    -- ═══════════ HEADER ═══════════
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, HH)
    header.BackgroundColor3 = THEME.SURFACE
    header.BackgroundTransparency = 0.3
    header.BorderSizePixel = 0
    header.Active = true
    header.ZIndex = 4
    header.Parent = main
    corner(header, THEME.RADIUS_LG)

    local hLine = Instance.new("Frame")
    hLine.Size = UDim2.new(1, -20, 0, 1)
    hLine.Position = UDim2.new(0, 10, 1, -1)
    hLine.BackgroundColor3 = THEME.HAIRLINE
    hLine.BackgroundTransparency = 0.88
    hLine.BorderSizePixel = 0
    hLine.ZIndex = 5
    hLine.Parent = header

    -- Logo diamond
    local logoWrap = Instance.new("Frame")
    logoWrap.Size = UDim2.new(0, math.floor(26 * s), 0, math.floor(26 * s))
    logoWrap.Position = UDim2.new(0, math.floor(16 * s), 0.5, -math.floor(13 * s))
    logoWrap.BackgroundTransparency = 1
    logoWrap.ZIndex = 5
    logoWrap.Parent = header

    local logoRing = Instance.new("Frame")
    logoRing.Size = UDim2.new(0, math.floor(22 * s), 0, math.floor(22 * s))
    logoRing.Position = UDim2.new(0.5, -math.floor(11 * s), 0.5, -math.floor(11 * s))
    logoRing.BackgroundTransparency = 1
    logoRing.ZIndex = 5
    logoRing.Parent = logoWrap
    corner(logoRing, math.floor(11 * s))
    stroke(logoRing, THEME.ACCENT, 1.5, 0.1)

    local logoD = Instance.new("Frame")
    logoD.Size = UDim2.new(0, math.floor(10 * s), 0, math.floor(10 * s))
    logoD.Position = UDim2.new(0.5, -math.floor(5 * s), 0.5, -math.floor(5 * s))
    logoD.BackgroundColor3 = THEME.ACCENT
    logoD.BorderSizePixel = 0
    logoD.Rotation = 45
    logoD.ZIndex = 6
    logoD.Parent = logoWrap
    corner(logoD, 2)

    label(header, {
        Text = "KEI SELVIM",
        Color = THEME.TEXT,
        Font = Enum.Font.GothamBold,
        Size = math.floor(12 * s),
        FrameSize = UDim2.new(0, math.floor(110 * s), 0, math.floor(16 * s)),
        Pos = UDim2.new(0, math.floor(52 * s), 0, math.floor(HH/2 - 10 * s)),
        Z = 5,
    })
    label(header, {
        Text = "SHELL v2.2",
        Color = THEME.TEXT_FAINT,
        Font = Enum.Font.GothamMedium,
        Size = math.floor(8 * s),
        FrameSize = UDim2.new(0, math.floor(110 * s), 0, math.floor(12 * s)),
        Pos = UDim2.new(0, math.floor(53 * s), 0, math.floor(HH/2 + 6 * s)),
        Z = 5,
    })

    local badge = Instance.new("Frame")
    badge.Size = UDim2.new(0, math.floor(42 * s), 0, math.floor(18 * s))
    badge.Position = UDim2.new(0, math.floor(162 * s), 0, math.floor((HH - 18 * s)/2))
    badge.BackgroundColor3 = THEME.ACCENT
    badge.BackgroundTransparency = 0.55
    badge.BorderSizePixel = 0
    badge.Active = false
    badge.ZIndex = 5
    badge.Parent = header
    corner(badge, 9)
    stroke(badge, THEME.ACCENT_LITE, 1, 0.6)
    label(badge, {
        Text = "v2.2",
        Color = THEME.ACCENT_LITE,
        Font = Enum.Font.GothamBold,
        Size = math.floor(9 * s),
        XAlign = Enum.TextXAlignment.Center,
        Z = 6,
    })

    -- Header buttons
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
        Z = 5,
    })

    local minBtn = makeButton(header, {
        Name = "Minimize",
        IdleColor = THEME.BTN_IDLE,
        HoverColor = THEME.BTN_HOVER,
        FrameSize = UDim2.new(0, btnS, 0, btnS),
        Pos = UDim2.new(1, -math.floor(72 * s), 0, math.floor((HH - btnS)/2)),
        Radius = THEME.RADIUS_SM,
        Z = 5,
    })
    local minBar = Instance.new("Frame")
    minBar.Size = UDim2.new(0, math.floor(12 * s), 0, math.floor(2 * s))
    minBar.Position = UDim2.new(0.5, -math.floor(6 * s), 0.5, -math.floor(1 * s))
    minBar.BackgroundColor3 = THEME.TEXT_DIM
    minBar.BorderSizePixel = 0
    minBar.ZIndex = 7
    minBar.Parent = minBtn
    corner(minBar, 1)

    -- ═══════════ SIDEBAR ═══════════
    local sidebar = Instance.new("Frame")
    sidebar.Size = UDim2.new(0, SBW, 1, -HH)
    sidebar.Position = UDim2.new(0, 0, 0, HH)
    sidebar.BackgroundColor3 = THEME.SURFACE_2
    sidebar.BackgroundTransparency = 0.5
    sidebar.BorderSizePixel = 0
    sidebar.Active = false
    sidebar.ZIndex = 4
    sidebar.Parent = main

    local sbLine = Instance.new("Frame")
    sbLine.Size = UDim2.new(0, 1, 1, -20)
    sbLine.Position = UDim2.new(1, -1, 0, 10)
    sbLine.BackgroundColor3 = THEME.HAIRLINE
    sbLine.BackgroundTransparency = 0.88
    sbLine.BorderSizePixel = 0
    sbLine.ZIndex = 5
    sbLine.Parent = sidebar

    -- ═══════════ CONTENT ═══════════
    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, -(SBW + PAD*2), 1, -(HH + PAD*2))
    content.Position = UDim2.new(0, SBW + PAD, 0, HH + PAD)
    content.BackgroundTransparency = 1
    content.Active = false
    content.ZIndex = 4
    content.Parent = main

    -- ═══════════ PAGE FACTORY ═══════════
    local function makePage(id, title, subtitle)
        local p = Instance.new("Frame")
        p.Name = id .. "Page"
        p.Size = UDim2.new(1, 0, 1, 0)
        p.BackgroundTransparency = 1
        p.Visible = false
        p.Active = false
        p.ZIndex = 4
        p.Parent = content

        label(p, {
            Text = title,
            Color = THEME.TEXT,
            Font = Enum.Font.GothamBold,
            Size = math.floor(16 * s),
            FrameSize = UDim2.new(1, 0, 0, math.floor(24 * s)),
            Pos = UDim2.new(0, 0, 0, 0),
            Z = 5,
        })
        if subtitle then
            label(p, {
                Text = subtitle,
                Color = THEME.TEXT_DIM,
                Font = Enum.Font.Gotham,
                Size = math.floor(10 * s),
                FrameSize = UDim2.new(1, 0, 0, math.floor(16 * s)),
                Pos = UDim2.new(0, 0, 0, math.floor(28 * s)),
                Z = 5,
            })
        end

        local body = Instance.new("Frame")
        body.Size = UDim2.new(1, 0, 1, -math.floor(56 * s))
        body.Position = UDim2.new(0, 0, 0, math.floor(56 * s))
        body.BackgroundTransparency = 1
        body.Active = false
        body.ZIndex = 4
        body.Parent = p

        State.pages[id] = p
        return body
    end

    -- HOME
    local homeBody = makePage("home", "Home", "Dashboard & info")

    local profileCard = Instance.new("Frame")
    profileCard.Size = UDim2.new(1, 0, 0, math.floor(70 * s))
    profileCard.BackgroundColor3 = THEME.SURFACE
    profileCard.BackgroundTransparency = THEME.PANEL_TRANS
    profileCard.BorderSizePixel = 0
    profileCard.Active = false
    profileCard.ZIndex = 5
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
    av.ZIndex = 6
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
        Z = 6,
    })
    label(profileCard, {
        Text = "@" .. (LocalPlayer and LocalPlayer.Name or "unknown"),
        Color = THEME.TEXT_DIM,
        Font = Enum.Font.Gotham,
        Size = math.floor(10 * s),
        FrameSize = UDim2.new(1, -math.floor(80 * s), 0, math.floor(14 * s)),
        Pos = UDim2.new(0, math.floor(74 * s), 0, math.floor(30 * s)),
        Z = 6,
    })
    label(profileCard, {
        Text = "Kei Selvim  ·  Shell v2.2",
        Color = THEME.ACCENT_LITE,
        Font = Enum.Font.GothamMedium,
        Size = math.floor(9 * s),
        FrameSize = UDim2.new(1, -math.floor(80 * s), 0, math.floor(14 * s)),
        Pos = UDim2.new(0, math.floor(74 * s), 0, math.floor(46 * s)),
        Z = 6,
    })

    local statsGrid = Instance.new("Frame")
    statsGrid.Size = UDim2.new(1, 0, 0, math.floor(140 * s))
    statsGrid.Position = UDim2.new(0, 0, 0, math.floor(82 * s))
    statsGrid.BackgroundTransparency = 1
    statsGrid.Active = false
    statsGrid.ZIndex = 5
    statsGrid.Parent = homeBody

    local grid = Instance.new("UIGridLayout")
    grid.CellSize = UDim2.new(0.5, -math.floor(6 * s), 0, math.floor(64 * s))
    grid.CellPadding = UDim2.new(0, math.floor(12 * s), 0, math.floor(10 * s))
    grid.SortOrder = Enum.SortOrder.LayoutOrder
    grid.Parent = statsGrid

    local function statCard(order, title, value, color, symbol)
        local card = Instance.new("Frame")
        card.BackgroundColor3 = THEME.SURFACE
        card.BackgroundTransparency = THEME.PANEL_TRANS
        card.BorderSizePixel = 0
        card.LayoutOrder = order
        card.Active = false
        card.ZIndex = 6
        card.Parent = statsGrid
        corner(card, THEME.RADIUS_MD)
        stroke(card, THEME.HAIRLINE, 1, 0.88)

        local barF = Instance.new("Frame")
        barF.Size = UDim2.new(0, math.floor(3 * s), 1, -math.floor(20 * s))
        barF.Position = UDim2.new(0, 0, 0, math.floor(10 * s))
        barF.BackgroundColor3 = color
        barF.BorderSizePixel = 0
        barF.ZIndex = 7
        barF.Parent = card
        corner(barF, 2)

        label(card, {
            Text = title,
            Color = THEME.TEXT_DIM,
            Font = Enum.Font.GothamMedium,
            Size = math.floor(9 * s),
            FrameSize = UDim2.new(1, -math.floor(50 * s), 0, math.floor(14 * s)),
            Pos = UDim2.new(0, math.floor(14 * s), 0, math.floor(10 * s)),
            Z = 7,
        })
        label(card, {
            Text = value,
            Color = color,
            Font = Enum.Font.GothamBold,
            Size = math.floor(18 * s),
            FrameSize = UDim2.new(1, -math.floor(50 * s), 0, math.floor(26 * s)),
            Pos = UDim2.new(0, math.floor(14 * s), 0, math.floor(28 * s)),
            Z = 7,
        })
        label(card, {
            Text = symbol,
            Color = color,
            Font = Enum.Font.GothamBold,
            Size = math.floor(16 * s),
            FrameSize = UDim2.new(0, math.floor(30 * s), 0, math.floor(30 * s)),
            Pos = UDim2.new(1, -math.floor(38 * s), 0, math.floor(12 * s)),
            XAlign = Enum.TextXAlignment.Center,
            Z = 7,
        })
    end

    statCard(1, "FPS",     "60",      Color3.fromRGB(100, 255, 150), "▲")
    statCard(2, "PING",    "0 ms",    Color3.fromRGB(255, 200, 100), "●")
    statCard(3, "STATUS",  "Ready",   Color3.fromRGB(150, 200, 255), "◆")
    statCard(4, "MODE",    "UI Only", Color3.fromRGB(255, 150, 200), "■")

    -- TOOLS
    local toolsBody = makePage("tools", "Tools", "Function panel")
    local toolsCard = Instance.new("Frame")
    toolsCard.Size = UDim2.new(1, 0, 0, math.floor(170 * s))
    toolsCard.BackgroundColor3 = THEME.SURFACE
    toolsCard.BackgroundTransparency = THEME.PANEL_TRANS
    toolsCard.BorderSizePixel = 0
    toolsCard.Active = false
    toolsCard.ZIndex = 5
    toolsCard.Parent = toolsBody
    corner(toolsCard, THEME.RADIUS_MD)
    stroke(toolsCard, THEME.HAIRLINE, 1, 0.88)

    local toolsIcon = makeIconHolder(toolsCard, math.floor(40 * s))
    IconFactory.tools(toolsIcon, math.floor(40 * s), THEME.ACCENT_LITE)

    label(toolsCard, {
        Text = "Tools panel — logic di sini nanti",
        Color = THEME.TEXT_DIM,
        Font = Enum.Font.Gotham,
        Size = math.floor(11 * s),
        FrameSize = UDim2.new(1, 0, 0, math.floor(20 * s)),
        Pos = UDim2.new(0, 0, 0, math.floor(68 * s)),
        XAlign = Enum.TextXAlignment.Center,
        Z = 6,
    })

    local sampleActive = false
    local sampleBtn = makeButton(toolsCard, {
        Text = "Sample Button",
        FrameSize = UDim2.new(1, -math.floor(40 * s), 0, math.floor(36 * s)),
        Pos = UDim2.new(0, math.floor(20 * s), 0, math.floor(108 * s)),
        TextSize = math.floor(11 * s),
        Z = 6,
    })
    sampleBtn.MouseButton1Click:Connect(function()
        sampleActive = not sampleActive
        sampleBtn.SetActive(sampleActive)
        toast(sampleActive and "Sample: ON" or "Sample: OFF",
            sampleActive and THEME.ACCENT_LITE or THEME.TEXT_DIM)
    end)

    -- CONFIG
    local configBody = makePage("config", "Config", "Settings panel")
    local configCard = Instance.new("Frame")
    configCard.Size = UDim2.new(1, 0, 0, math.floor(130 * s))
    configCard.BackgroundColor3 = THEME.SURFACE
    configCard.BackgroundTransparency = THEME.PANEL_TRANS
    configCard.BorderSizePixel = 0
    configCard.Active = false
    configCard.ZIndex = 5
    configCard.Parent = configBody
    corner(configCard, THEME.RADIUS_MD)
    stroke(configCard, THEME.HAIRLINE, 1, 0.88)

    local cfgIcon = makeIconHolder(configCard, math.floor(40 * s))
    IconFactory.config(cfgIcon, math.floor(40 * s), THEME.ACCENT_LITE)

    label(configCard, {
        Text = "Config panel — logic di sini nanti",
        Color = THEME.TEXT_DIM,
        Font = Enum.Font.Gotham,
        Size = math.floor(11 * s),
        FrameSize = UDim2.new(1, 0, 0, math.floor(20 * s)),
        Pos = UDim2.new(0, 0, 0, math.floor(70 * s)),
        XAlign = Enum.TextXAlignment.Center,
        Z = 6,
    })

    -- CROWN
    local crownBody = makePage("crown", "Crown", "Admin panel")
    local crownCard = Instance.new("Frame")
    crownCard.Size = UDim2.new(1, 0, 0, math.floor(130 * s))
    crownCard.BackgroundColor3 = THEME.SURFACE
    crownCard.BackgroundTransparency = THEME.PANEL_TRANS
    crownCard.BorderSizePixel = 0
    crownCard.Active = false
    crownCard.ZIndex = 5
    crownCard.Parent = crownBody
    corner(crownCard, THEME.RADIUS_MD)
    stroke(crownCard, Color3.fromRGB(255, 200, 60), 1, 0.6)

    local crownIcon = makeIconHolder(crownCard, math.floor(40 * s))
    IconFactory.crown(crownIcon, math.floor(40 * s), Color3.fromRGB(255, 200, 60))

    label(crownCard, {
        Text = "Admin panel — logic di sini nanti",
        Color = Color3.fromRGB(255, 200, 60),
        Font = Enum.Font.Gotham,
        Size = math.floor(11 * s),
        FrameSize = UDim2.new(1, 0, 0, math.floor(20 * s)),
        Pos = UDim2.new(0, 0, 0, math.floor(70 * s)),
        XAlign = Enum.TextXAlignment.Center,
        Z = 6,
    })

    -- ═══════════ SIDEBAR ICONS ═══════════
    local iconList = {
        { id = "home",   factory = IconFactory.home,   iconColor = THEME.TEXT_DIM },
        { id = "tools",  factory = IconFactory.tools,  iconColor = THEME.TEXT_DIM },
        { id = "config", factory = IconFactory.config, iconColor = THEME.TEXT_DIM },
        { id = "crown",  factory = IconFactory.crown,  iconColor = Color3.fromRGB(255, 200, 60) },
    }

    local iconY = math.floor(14 * s)
    for i, item in ipairs(iconList) do
        local btn = makeButton(sidebar, {
            Name = item.id .. "Btn",
            IdleColor = THEME.BTN_IDLE,
            HoverColor = THEME.BTN_HOVER,
            ActiveColor = THEME.ACCENT,
            FrameSize = UDim2.new(0, ICS, 0, ICS),
            Pos = UDim2.new(0, math.floor((SBW - ICS)/2), 0, iconY + (i-1) * (ICS + ICG)),
            Radius = THEME.RADIUS_MD,
            Z = 5,
        })

        -- Icon holder
        local holder = Instance.new("Frame")
        holder.Size = UDim2.new(0, math.floor(24 * s), 0, math.floor(24 * s))
        holder.Position = UDim2.new(0.5, -math.floor(12 * s), 0.5, -math.floor(12 * s))
        holder.BackgroundTransparency = 1
        holder.ZIndex = 6
        holder.Parent = btn

        local frames = item.factory(holder, math.floor(24 * s), item.iconColor)

        State.sidebarButtons[item.id] = {
            button = btn,
            frames = frames,
            idleColor = item.iconColor,
            activeColor = Color3.fromRGB(255, 255, 255),
        }

        btn.MouseEnter:Connect(function()
            if not btn.GetActive() then
                recolor(frames, THEME.TEXT)
            end
        end)
        btn.MouseLeave:Connect(function()
            if btn.GetActive() then
                recolor(frames, Color3.fromRGB(255, 255, 255))
            else
                recolor(frames, item.iconColor)
            end
        end)
    end

    -- ═══════════ PAGE SWITCH ═══════════
    local function switchPage(id)
        for pid, page in pairs(State.pages) do
            page.Visible = (pid == id)
        end
        for bid, data in pairs(State.sidebarButtons) do
            if bid == id then
                data.button.SetActive(true)
                recolor(data.frames, data.activeColor)
            else
                data.button.SetActive(false)
                recolor(data.frames, data.idleColor)
            end
        end
        State.currentPage = id
    end

    for id, data in pairs(State.sidebarButtons) do
        data.button.MouseButton1Click:Connect(function()
            switchPage(id)
        end)
    end

    -- ═══════════ DRAG ═══════════
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

    -- ═══════════ CLOSE ═══════════
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
        confirm.ZIndex = 100
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
            Z = 101,
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
            Z = 101,
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
            Z = 101,
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
            Z = 101,
        })

        no.MouseButton1Click:Connect(function() confirm:Destroy() end)
        yes.MouseButton1Click:Connect(function()
            gui:Destroy()
            if State.kButton then State.kButton:Destroy() end
        end)
    end)

    -- ═══════════ MINIMIZE ═══════════
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
            k.BackgroundTransparency = 0.15
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
    toast("Kei Selvim UI v2.2 loaded", THEME.SUCCESS)
end

task.wait(0.3)
buildUI()
