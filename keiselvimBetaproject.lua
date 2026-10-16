--[[
    ╔══════════════════════════════════════════════════════════════════════╗
    ║                                                                      ║
    ║           KEI SELVIM — UI SHELL v3.0 FINAL                           ║
    ║           Glassmorphism • Glyph Icons • State Buttons                ║
    ║                                                                      ║
    ╚══════════════════════════════════════════════════════════════════════╝

    Yang ada di sini:
    - ScreenGui + main frame + shadow + overlay
    - Header (drag, close, minimize)
    - Sidebar navigasi 4 tombol dengan glyph unicode
    - 4 halaman (Home / Tools / Config / Crown)
    - Toast notif
    - K button (restore after minimize)

    Icon pakai glyph unicode geometric (bukan emoji):
      ⌂  house    ⚙  gear    ☰  list    ♛  crown
      ◆  ✕  —  ▲  ●  ■
]]

-- ═══════════════════════════════════════════════════════════════════════
-- THEME
-- ═══════════════════════════════════════════════════════════════════════
local THEME = {
    BG_ASSET     = "rbxassetid://0",

    -- Warna inti
    ACCENT       = Color3.fromRGB(150, 80, 240),
    ACCENT_LITE  = Color3.fromRGB(190, 145, 255),
    ACCENT_DIM   = Color3.fromRGB(70, 35, 120),

    -- Surface
    SURFACE      = Color3.fromRGB(28, 28, 40),
    SURFACE_2    = Color3.fromRGB(18, 18, 26),
    SURFACE_3    = Color3.fromRGB(40, 40, 58),
    BTN_IDLE     = Color3.fromRGB(48, 48, 66),
    BTN_HOVER    = Color3.fromRGB(65, 65, 88),

    -- Text
    TEXT         = Color3.fromRGB(245, 245, 250),
    TEXT_DIM     = Color3.fromRGB(170, 170, 195),
    TEXT_FAINT   = Color3.fromRGB(120, 120, 145),

    -- Status
    DANGER       = Color3.fromRGB(240, 80, 105),
    SUCCESS      = Color3.fromRGB(100, 220, 150),
    GOLD         = Color3.fromRGB(255, 200, 60),

    -- Transparansi
    BG_TRANS     = 0.1,
    PANEL_TRANS  = 0.2,
    BTN_TRANS    = 0.1,

    -- Ukuran
    BASE_W       = 660,
    BASE_H       = 440,
    SIDEBAR_W    = 66,
    HEADER_H     = 46,
    PAD          = 14,
    ICON_SIZE    = 42,
    ICON_GAP     = 8,
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
local LocalPlayer      = Players.LocalPlayer

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
local function corner(p, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 8)
    c.Parent = p
    return c
end

local function stroke(p, col, thick, trans)
    local s = Instance.new("UIStroke")
    s.Color = col or THEME.TEXT_FAINT
    s.Thickness = thick or 1
    s.Transparency = trans or 0.85
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

-- Button: idle abu, hover abu terang, active ungu
local function makeButton(parent, props)
    local b = Instance.new("TextButton")
    b.Name = props.Name or "Btn"
    b.BackgroundColor3 = props.IdleColor or THEME.BTN_IDLE
    b.BackgroundTransparency = props.Trans or THEME.BTN_TRANS
    b.Text = props.Text or ""
    b.TextColor3 = props.TextColor or THEME.TEXT
    b.Font = props.Font or Enum.Font.GothamSemibold
    b.TextSize = props.TextSize or 12
    b.Size = props.FrameSize or UDim2.new(1, 0, 0, 36)
    b.Position = props.Pos or UDim2.new(0, 0, 0, 0)
    b.BorderSizePixel = 0
    b.AutoButtonColor = false
    b.Active = true
    b.Selectable = true
    b.ZIndex = props.Z or 5
    b.Parent = parent
    corner(b, props.Radius or THEME.RADIUS_MD)
    local s = stroke(b, props.StrokeColor or THEME.TEXT_FAINT, 1, props.StrokeTrans or 0.85)

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
            col, trans, st, tc = hoverCol, idleTrans, 0.5, THEME.TEXT
        else
            col, trans, st, tc = idleCol, idleTrans, 0.85, props.TextColor or THEME.TEXT
        end
        TweenService:Create(b, TweenInfo.new(0.15), {
            BackgroundColor3 = col,
            BackgroundTransparency = trans,
        }):Play()
        TweenService:Create(s, TweenInfo.new(0.15), { Transparency = st }):Play()
        TweenService:Create(b, TweenInfo.new(0.15), { TextColor3 = tc }):Play()
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
-- ICON GLYPHS — unicode geometric murni (bukan emoji)
-- ═══════════════════════════════════════════════════════════════════════
local ICON = {
    home   = "⌂",
    tools  = "⚙",
    config = "☰",
    crown  = "♛",
}

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
    t.BackgroundTransparency = 0.1
    t.BorderSizePixel = 0
    t.ZIndex = 200
    t.Active = false
    t.Parent = State.screenGui
    corner(t, THEME.RADIUS_MD)
    stroke(t, color or THEME.ACCENT_LITE, 1.5, 0.3)

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
        warn("[Kei] no parent gui")
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

    -- ScreenGui
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
    shadow.Size = UDim2.new(0, BW + 12, 0, BH + 12)
    shadow.Position = UDim2.new(0.5, -(BW+12)/2, 0.5, -(BH+12)/2 + 5)
    shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    shadow.BackgroundTransparency = 0.5
    shadow.BorderSizePixel = 0
    shadow.ZIndex = 1
    shadow.Active = false
    shadow.Parent = gui
    corner(shadow, THEME.RADIUS_LG + 4)
    State.shadow = shadow

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
    stroke(main, THEME.ACCENT, 1.2, 0.55)
    State.mainFrame = main

    -- BG image (opsional)
    if THEME.BG_ASSET ~= "rbxassetid://0" then
        local bgImg = Instance.new("ImageLabel")
        bgImg.Size = UDim2.new(1, 0, 1, 0)
        bgImg.BackgroundTransparency = 1
        bgImg.Image = THEME.BG_ASSET
        bgImg.ScaleType = Enum.ScaleType.Crop
        bgImg.ImageTransparency = THEME.BG_TRANS
        bgImg.Active = false
        bgImg.ZIndex = 2
        bgImg.Parent = main
        corner(bgImg, THEME.RADIUS_LG)
    end

    -- Dark overlay
    local ov = Instance.new("Frame")
    ov.Size = UDim2.new(1, 0, 1, 0)
    ov.BackgroundColor3 = Color3.fromRGB(10, 10, 16)
    ov.BackgroundTransparency = 0.35
    ov.BorderSizePixel = 0
    ov.Active = false
    ov.ZIndex = 3
    ov.Parent = main
    corner(ov, THEME.RADIUS_LG)

    -- ═══════════ HEADER ═══════════
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, HH)
    header.BackgroundColor3 = THEME.SURFACE
    header.BackgroundTransparency = 0.15
    header.BorderSizePixel = 0
    header.Active = true
    header.ZIndex = 10
    header.Parent = main
    corner(header, THEME.RADIUS_LG)

    -- Logo diamond
    label(header, {
        Text = "◆",
        Color = THEME.ACCENT_LITE,
        Font = Enum.Font.GothamBold,
        Size = math.floor(20 * s),
        FrameSize = UDim2.new(0, math.floor(28 * s), 1, 0),
        Pos = UDim2.new(0, math.floor(16 * s), 0, 0),
        XAlign = Enum.TextXAlignment.Center,
        Z = 11,
    })

    label(header, {
        Text = "KEI SELVIM",
        Color = THEME.TEXT,
        Font = Enum.Font.GothamBold,
        Size = math.floor(13 * s),
        FrameSize = UDim2.new(0, math.floor(120 * s), 0, math.floor(16 * s)),
        Pos = UDim2.new(0, math.floor(48 * s), 0, math.floor(HH/2 - 10 * s)),
        Z = 11,
    })

    label(header, {
        Text = "SHELL v3.0",
        Color = THEME.TEXT_FAINT,
        Font = Enum.Font.GothamMedium,
        Size = math.floor(9 * s),
        FrameSize = UDim2.new(0, math.floor(120 * s), 0, math.floor(12 * s)),
        Pos = UDim2.new(0, math.floor(49 * s), 0, math.floor(HH/2 + 6 * s)),
        Z = 11,
    })

    -- Version badge
    local badge = Instance.new("Frame")
    badge.Size = UDim2.new(0, math.floor(42 * s), 0, math.floor(18 * s))
    badge.Position = UDim2.new(0, math.floor(160 * s), 0, math.floor((HH - 18 * s)/2))
    badge.BackgroundColor3 = THEME.ACCENT
    badge.BackgroundTransparency = 0.4
    badge.BorderSizePixel = 0
    badge.Active = false
    badge.ZIndex = 11
    badge.Parent = header
    corner(badge, 9)
    stroke(badge, THEME.ACCENT_LITE, 1, 0.4)
    label(badge, {
        Text = "v3.0",
        Color = Color3.fromRGB(255, 255, 255),
        Font = Enum.Font.GothamBold,
        Size = math.floor(9 * s),
        XAlign = Enum.TextXAlignment.Center,
        Z = 12,
    })

    -- Close button
    local btnS = math.floor(30 * s)
    local closeBtn = makeButton(header, {
        Name = "Close",
        Text = "✕",
        IdleColor = THEME.BTN_IDLE,
        HoverColor = THEME.DANGER,
        ActiveColor = THEME.DANGER,
        Font = Enum.Font.GothamBold,
        TextSize = math.floor(13 * s),
        FrameSize = UDim2.new(0, btnS, 0, btnS),
        Pos = UDim2.new(1, -math.floor(40 * s), 0, math.floor((HH - btnS)/2)),
        Radius = THEME.RADIUS_SM,
        Z = 11,
    })

    -- Minimize button
    local minBtn = makeButton(header, {
        Name = "Minimize",
        Text = "—",
        IdleColor = THEME.BTN_IDLE,
        HoverColor = THEME.BTN_HOVER,
        Font = Enum.Font.GothamBold,
        TextSize = math.floor(14 * s),
        FrameSize = UDim2.new(0, btnS, 0, btnS),
        Pos = UDim2.new(1, -math.floor(76 * s), 0, math.floor((HH - btnS)/2)),
        Radius = THEME.RADIUS_SM,
        Z = 11,
    })

    -- ═══════════ SIDEBAR ═══════════
    local sidebar = Instance.new("Frame")
    sidebar.Name = "Sidebar"
    sidebar.Size = UDim2.new(0, SBW, 1, -HH)
    sidebar.Position = UDim2.new(0, 0, 0, HH)
    sidebar.BackgroundColor3 = Color3.fromRGB(14, 14, 20)
    sidebar.BackgroundTransparency = 0.2
    sidebar.BorderSizePixel = 0
    sidebar.Active = false
    sidebar.ZIndex = 10
    sidebar.Parent = main

    -- ═══════════ CONTENT ═══════════
    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Size = UDim2.new(1, -(SBW + PAD*2), 1, -(HH + PAD*2))
    content.Position = UDim2.new(0, SBW + PAD, 0, HH + PAD)
    content.BackgroundTransparency = 1
    content.Active = false
    content.ZIndex = 10
    content.Parent = main

    -- ═══════════ PAGES ═══════════
    local function makePage(id, title, subtitle)
        local p = Instance.new("Frame")
        p.Name = id .. "Page"
        p.Size = UDim2.new(1, 0, 1, 0)
        p.BackgroundTransparency = 1
        p.Visible = false
        p.Active = false
        p.ZIndex = 10
        p.Parent = content

        label(p, {
            Text = title,
            Color = THEME.TEXT,
            Font = Enum.Font.GothamBold,
            Size = math.floor(16 * s),
            FrameSize = UDim2.new(1, 0, 0, math.floor(24 * s)),
            Pos = UDim2.new(0, 0, 0, 0),
            Z = 11,
        })
        if subtitle then
            label(p, {
                Text = subtitle,
                Color = THEME.TEXT_DIM,
                Font = Enum.Font.Gotham,
                Size = math.floor(10 * s),
                FrameSize = UDim2.new(1, 0, 0, math.floor(16 * s)),
                Pos = UDim2.new(0, 0, 0, math.floor(28 * s)),
                Z = 11,
            })
        end

        local body = Instance.new("Frame")
        body.Name = "Body"
        body.Size = UDim2.new(1, 0, 1, -math.floor(56 * s))
        body.Position = UDim2.new(0, 0, 0, math.floor(56 * s))
        body.BackgroundTransparency = 1
        body.Active = false
        body.ZIndex = 11
        body.Parent = p

        State.pages[id] = p
        return body
    end

    -- HOME
    local homeBody = makePage("home", "Home", "Dashboard & info")

    local profileCard = Instance.new("Frame")
    profileCard.Size = UDim2.new(1, 0, 0, math.floor(72 * s))
    profileCard.BackgroundColor3 = THEME.SURFACE
    profileCard.BackgroundTransparency = THEME.PANEL_TRANS
    profileCard.BorderSizePixel = 0
    profileCard.Active = false
    profileCard.ZIndex = 12
    profileCard.Parent = homeBody
    corner(profileCard, THEME.RADIUS_MD)
    stroke(profileCard, THEME.TEXT_FAINT, 1, 0.8)

    local av = Instance.new("ImageLabel")
    av.Size = UDim2.new(0, math.floor(52 * s), 0, math.floor(52 * s))
    av.Position = UDim2.new(0, math.floor(12 * s), 0.5, -math.floor(26 * s))
    av.BackgroundColor3 = THEME.SURFACE_3
    av.BackgroundTransparency = 0.2
    av.BorderSizePixel = 0
    av.Active = false
    av.ZIndex = 13
    av.Parent = profileCard
    corner(av, math.floor(26 * s))
    stroke(av, THEME.ACCENT_LITE, 1.5, 0.3)

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
        Pos = UDim2.new(0, math.floor(76 * s), 0, math.floor(14 * s)),
        Z = 13,
    })
    label(profileCard, {
        Text = "@" .. (LocalPlayer and LocalPlayer.Name or "unknown"),
        Color = THEME.TEXT_DIM,
        Font = Enum.Font.Gotham,
        Size = math.floor(10 * s),
        FrameSize = UDim2.new(1, -math.floor(80 * s), 0, math.floor(14 * s)),
        Pos = UDim2.new(0, math.floor(76 * s), 0, math.floor(32 * s)),
        Z = 13,
    })
    label(profileCard, {
        Text = "Kei Selvim  ·  Shell v3.0",
        Color = THEME.ACCENT_LITE,
        Font = Enum.Font.GothamMedium,
        Size = math.floor(9 * s),
        FrameSize = UDim2.new(1, -math.floor(80 * s), 0, math.floor(14 * s)),
        Pos = UDim2.new(0, math.floor(76 * s), 0, math.floor(48 * s)),
        Z = 13,
    })

    -- Stat grid
    local statsGrid = Instance.new("Frame")
    statsGrid.Size = UDim2.new(1, 0, 0, math.floor(140 * s))
    statsGrid.Position = UDim2.new(0, 0, 0, math.floor(84 * s))
    statsGrid.BackgroundTransparency = 1
    statsGrid.Active = false
    statsGrid.ZIndex = 12
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
        card.ZIndex = 13
        card.Parent = statsGrid
        corner(card, THEME.RADIUS_MD)
        stroke(card, THEME.TEXT_FAINT, 1, 0.8)

        local barF = Instance.new("Frame")
        barF.Size = UDim2.new(0, math.floor(3 * s), 1, -math.floor(20 * s))
        barF.Position = UDim2.new(0, 0, 0, math.floor(10 * s))
        barF.BackgroundColor3 = color
        barF.BorderSizePixel = 0
        barF.ZIndex = 14
        barF.Parent = card
        corner(barF, 2)

        label(card, {
            Text = title,
            Color = THEME.TEXT_DIM,
            Font = Enum.Font.GothamMedium,
            Size = math.floor(9 * s),
            FrameSize = UDim2.new(1, -math.floor(50 * s), 0, math.floor(14 * s)),
            Pos = UDim2.new(0, math.floor(14 * s), 0, math.floor(10 * s)),
            Z = 14,
        })
        label(card, {
            Text = value,
            Color = color,
            Font = Enum.Font.GothamBold,
            Size = math.floor(18 * s),
            FrameSize = UDim2.new(1, -math.floor(50 * s), 0, math.floor(26 * s)),
            Pos = UDim2.new(0, math.floor(14 * s), 0, math.floor(28 * s)),
            Z = 14,
        })
        label(card, {
            Text = symbol,
            Color = color,
            Font = Enum.Font.GothamBold,
            Size = math.floor(18 * s),
            FrameSize = UDim2.new(0, math.floor(30 * s), 0, math.floor(30 * s)),
            Pos = UDim2.new(1, -math.floor(40 * s), 0, math.floor(14 * s)),
            XAlign = Enum.TextXAlignment.Center,
            Z = 14,
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
    toolsCard.ZIndex = 12
    toolsCard.Parent = toolsBody
    corner(toolsCard, THEME.RADIUS_MD)
    stroke(toolsCard, THEME.TEXT_FAINT, 1, 0.8)

    label(toolsCard, {
        Text = "⚙",
        Color = THEME.ACCENT_LITE,
        Font = Enum.Font.GothamBold,
        Size = math.floor(36 * s),
        FrameSize = UDim2.new(1, 0, 0, math.floor(48 * s)),
        Pos = UDim2.new(0, 0, 0, math.floor(18 * s)),
        XAlign = Enum.TextXAlignment.Center,
        Z = 13,
    })
    label(toolsCard, {
        Text = "Tools panel — logic di sini nanti",
        Color = THEME.TEXT_DIM,
        Font = Enum.Font.Gotham,
        Size = math.floor(11 * s),
        FrameSize = UDim2.new(1, 0, 0, math.floor(20 * s)),
        Pos = UDim2.new(0, 0, 0, math.floor(72 * s)),
        XAlign = Enum.TextXAlignment.Center,
        Z = 13,
    })

    local sampleActive = false
    local sampleBtn = makeButton(toolsCard, {
        Text = "Sample Button",
        FrameSize = UDim2.new(1, -math.floor(40 * s), 0, math.floor(36 * s)),
        Pos = UDim2.new(0, math.floor(20 * s), 0, math.floor(110 * s)),
        TextSize = math.floor(11 * s),
        Z = 13,
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
    configCard.ZIndex = 12
    configCard.Parent = configBody
    corner(configCard, THEME.RADIUS_MD)
    stroke(configCard, THEME.TEXT_FAINT, 1, 0.8)

    label(configCard, {
        Text = "☰",
        Color = THEME.ACCENT_LITE,
        Font = Enum.Font.GothamBold,
        Size = math.floor(36 * s),
        FrameSize = UDim2.new(1, 0, 0, math.floor(48 * s)),
        Pos = UDim2.new(0, 0, 0, math.floor(18 * s)),
        XAlign = Enum.TextXAlignment.Center,
        Z = 13,
    })
    label(configCard, {
        Text = "Config panel — logic di sini nanti",
        Color = THEME.TEXT_DIM,
        Font = Enum.Font.Gotham,
        Size = math.floor(11 * s),
        FrameSize = UDim2.new(1, 0, 0, math.floor(20 * s)),
        Pos = UDim2.new(0, 0, 0, math.floor(74 * s)),
        XAlign = Enum.TextXAlignment.Center,
        Z = 13,
    })

    -- CROWN
    local crownBody = makePage("crown", "Crown", "Admin panel")
    local crownCard = Instance.new("Frame")
    crownCard.Size = UDim2.new(1, 0, 0, math.floor(130 * s))
    crownCard.BackgroundColor3 = THEME.SURFACE
    crownCard.BackgroundTransparency = THEME.PANEL_TRANS
    crownCard.BorderSizePixel = 0
    crownCard.Active = false
    crownCard.ZIndex = 12
    crownCard.Parent = crownBody
    corner(crownCard, THEME.RADIUS_MD)
    stroke(crownCard, THEME.GOLD, 1, 0.6)

    label(crownCard, {
        Text = "♛",
        Color = THEME.GOLD,
        Font = Enum.Font.GothamBold,
        Size = math.floor(36 * s),
        FrameSize = UDim2.new(1, 0, 0, math.floor(48 * s)),
        Pos = UDim2.new(0, 0, 0, math.floor(18 * s)),
        XAlign = Enum.TextXAlignment.Center,
        Z = 13,
    })
    label(crownCard, {
        Text = "Admin panel — logic di sini nanti",
        Color = THEME.GOLD,
        Font = Enum.Font.Gotham,
        Size = math.floor(11 * s),
        FrameSize = UDim2.new(1, 0, 0, math.floor(20 * s)),
        Pos = UDim2.new(0, 0, 0, math.floor(74 * s)),
        XAlign = Enum.TextXAlignment.Center,
        Z = 13,
    })

    -- ═══════════ SIDEBAR BUTTONS ═══════════
    local iconList = {
        { id = "home",   glyph = ICON.home,   color = THEME.TEXT },
        { id = "tools",  glyph = ICON.tools,  color = THEME.TEXT },
        { id = "config", glyph = ICON.config, color = THEME.TEXT },
        { id = "crown",  glyph = ICON.crown,  color = THEME.GOLD },
    }

    local iconY = math.floor(14 * s)
    for i, item in ipairs(iconList) do
        local btn = makeButton(sidebar, {
            Name = item.id .. "Btn",
            Text = item.glyph,
            TextColor = item.color,
            IdleColor = THEME.BTN_IDLE,
            HoverColor = THEME.BTN_HOVER,
            ActiveColor = THEME.ACCENT,
            Font = Enum.Font.GothamBold,
            TextSize = math.floor(22 * s),
            FrameSize = UDim2.new(0, ICS, 0, ICS),
            Pos = UDim2.new(0, math.floor((SBW - ICS)/2), 0, iconY + (i-1) * (ICS + ICG)),
            Radius = THEME.RADIUS_MD,
            Z = 12,
        })
        State.sidebarButtons[item.id] = btn
    end

    -- ═══════════ PAGE SWITCH ═══════════
    local function switchPage(id)
        for pid, page in pairs(State.pages) do
            page.Visible = (pid == id)
        end
        for bid, btn in pairs(State.sidebarButtons) do
            btn.SetActive(bid == id)
        end
        State.currentPage = id
    end

    for id, btn in pairs(State.sidebarButtons) do
        btn.MouseButton1Click:Connect(function()
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
                startPos.X.Scale, startPos.X.Offset + delta.X - 6,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y - 1
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
        local cW = math.floor(320 * s)
        local cH = math.floor(160 * s)
        local confirm = Instance.new("Frame")
        confirm.Size = UDim2.new(0, cW, 0, cH)
        confirm.Position = UDim2.new(0.5, -cW/2, 0.5, -cH/2)
        confirm.BackgroundColor3 = THEME.SURFACE_2
        confirm.BackgroundTransparency = 0.05
        confirm.BorderSizePixel = 0
        confirm.Active = true
        confirm.ZIndex = 300
        confirm.Parent = gui
        corner(confirm, THEME.RADIUS_LG)
        stroke(confirm, THEME.DANGER, 1.5, 0.2)

        label(confirm, {
            Text = "Konfirmasi",
            Color = THEME.TEXT,
            Font = Enum.Font.GothamBold,
            Size = math.floor(15 * s),
            FrameSize = UDim2.new(1, 0, 0, math.floor(28 * s)),
            Pos = UDim2.new(0, 0, 0, math.floor(18 * s)),
            XAlign = Enum.TextXAlignment.Center,
            Z = 301,
        })
        label(confirm, {
            Text = "Yakin mau tutup Kei Selvim?",
            Color = THEME.TEXT_DIM,
            Font = Enum.Font.Gotham,
            Size = math.floor(11 * s),
            FrameSize = UDim2.new(1, -20, 0, math.floor(40 * s)),
            Pos = UDim2.new(0, 10, 0, math.floor(52 * s)),
            XAlign = Enum.TextXAlignment.Center,
            Wrap = true,
            Z = 301,
        })

        local bW = (cW - math.floor(30 * s)) / 2
        local yes = makeButton(confirm, {
            Text = "Ya, Tutup",
            IdleColor = THEME.DANGER,
            ActiveColor = THEME.DANGER,
            HoverColor = Color3.fromRGB(255, 110, 135),
            TextColor = Color3.fromRGB(255, 255, 255),
            Font = Enum.Font.GothamBold,
            TextSize = math.floor(11 * s),
            FrameSize = UDim2.new(0, bW, 0, math.floor(34 * s)),
            Pos = UDim2.new(0, math.floor(10 * s), 0, math.floor(106 * s)),
            Radius = THEME.RADIUS_MD,
            Z = 301,
        })
        local no = makeButton(confirm, {
            Text = "Batal",
            IdleColor = THEME.BTN_IDLE,
            ActiveColor = THEME.ACCENT,
            HoverColor = THEME.BTN_HOVER,
            Font = Enum.Font.GothamBold,
            TextSize = math.floor(11 * s),
            FrameSize = UDim2.new(0, bW, 0, math.floor(34 * s)),
            Pos = UDim2.new(0, math.floor(20 * s) + bW, 0, math.floor(106 * s)),
            Radius = THEME.RADIUS_MD,
            Z = 301,
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
        State.minimized = true

        if not State.kButton or not State.kButton.Parent then
            local kS = math.floor(52 * s)
            local k = Instance.new("TextButton")
            k.Name = "KButton"
            k.Size = UDim2.new(0, kS, 0, kS)
            k.Position = UDim2.new(0, math.floor(20 * s), 0.5, -kS/2)
            k.BackgroundColor3 = THEME.ACCENT
            k.BackgroundTransparency = 0.1
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
            stroke(k, THEME.ACCENT_LITE, 1.5, 0.2)

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
    toast("Kei Selvim v3.0 loaded", THEME.SUCCESS)
end

-- ═══════════════════════════════════════════════════════════════════════
-- BOOT
-- ═══════════════════════════════════════════════════════════════════════
task.wait(0.3)
buildUI()
