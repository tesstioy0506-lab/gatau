--[[
    ╔══════════════════════════════════════════════════════════════════════╗
    ║                                                                      ║
    ║           KEI SELVIM — UI SHELL v1.0                                 ║
    ║           Tampilan & Tombol Only                                     ║
    ║                                                                      ║
    ╚══════════════════════════════════════════════════════════════════════╝

    Cuma ada:
    - ScreenGui + main frame + shadow
    - Header (drag, close, minimize)
    - Sidebar navigasi 4 tombol
    - 4 halaman kosong siap diisi
    - Toast notif
    - K button (restore after minimize)

    Belum ada: key verify, crypto, github, map stealer, broadcast.
]]

-- ═══════════════════════════════════════════════════════════════════════
-- THEME — ubah di sini
-- ═══════════════════════════════════════════════════════════════════════
local THEME = {
    -- Background asset ID (isi punya lo, "rbxassetid://ANGKA")
    BG_ASSET     = "rbxassetid://0",

    -- Warna utama
    ACCENT       = Color3.fromRGB(138, 43, 226),   -- ungu terang (aktif)
    ACCENT_DIM   = Color3.fromRGB(70, 25, 120),    -- ungu redup (inaktif)
    ACCENT_GLOW  = Color3.fromRGB(170, 90, 245),   -- ungu hover
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

    -- Ukuran (base, sebelum auto-scale)
    BASE_W       = 640,
    BASE_H       = 420,
    SIDEBAR_W    = 56,
    HEADER_H     = 38,
    PAD          = 12,
    ICON_SIZE    = 36,
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

-- Tombol universal: ungu, transparan 0.2, hover jadi ungu terang
local function button(parent, props)
    local b = Instance.new("TextButton")
    b.Name = props.Name or "Btn"
    b.BackgroundColor3 = props.Color or THEME.ACCENT
    b.BackgroundTransparency = props.Trans or THEME.BTN_TRANS
    b.Text = props.Text or ""
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
-- TOAST NOTIF
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

    -- Main frame
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

    -- Background image
    local bgImg = Instance.new("ImageLabel")
    bgImg.Name = "BG"
    bgImg.Size = UDim2.new(1, 0, 1, 0)
    bgImg.BackgroundTransparency = 1
    bgImg.Image = THEME.BG_ASSET
    bgImg.ScaleType = Enum.ScaleType.Crop
    bgImg.ImageTransparency = THEME.BG_TRANS
    bgImg.Active = false
    bgImg.ZIndex = 1
    bgImg.Parent = main
    corner(bgImg, 14)

    -- Overlay gradient
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
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, HH)
    header.BackgroundColor3 = THEME.PANEL_DARK
    header.BackgroundTransparency = THEME.BG_TRANS
    header.BorderSizePixel = 0
    header.Active = true
    header.ZIndex = 6
    header.Parent = main
    corner(header, 14)

    label(header, {
        Text = "◆",
        Color = THEME.ACCENT,
        Font = Enum.Font.GothamBlack,
        Size = math.floor(16 * s),
        FrameSize = UDim2.new(0, math.floor(28 * s), 1, 0),
        Pos = UDim2.new(0, math.floor(12 * s), 0, 0),
        XAlign = Enum.TextXAlignment.Center,
        Z = 7,
    })

    label(header, {
        Text = "KEI SELVIM",
        Color = THEME.TEXT,
        Font = Enum.Font.GothamBlack,
        Size = math.floor(12 * s),
        FrameSize = UDim2.new(0, math.floor(100 * s), 1, 0),
        Pos = UDim2.new(0, math.floor(42 * s), 0, 0),
        Z = 7,
    })

    local badge = Instance.new("Frame")
    badge.Size = UDim2.new(0, math.floor(38 * s), 0, math.floor(16 * s))
    badge.Position = UDim2.new(0, math.floor(146 * s), 0, math.floor((HH - 16 * s)/2))
    badge.BackgroundColor3 = THEME.ACCENT
    badge.BackgroundTransparency = 0.4
    badge.BorderSizePixel = 0
    badge.Active = false
    badge.ZIndex = 7
    badge.Parent = header
    corner(badge, 4)
    label(badge, {
        Text = "v1.0",
        Color = Color3.fromRGB(255, 220, 255),
        Font = Enum.Font.GothamBold,
        Size = math.floor(9 * s),
        XAlign = Enum.TextXAlignment.Center,
        Z = 8,
    })

    local btnS = math.floor(24 * s)
    local closeBtn = button(header, {
        Name = "Close",
        Text = "✕",
        Color = THEME.DANGER,
        StrokeColor = THEME.DANGER,
        Font = Enum.Font.GothamBold,
        TextSize = math.floor(11 * s),
        FrameSize = UDim2.new(0, btnS, 0, btnS),
        Pos = UDim2.new(1, -math.floor(32 * s), 0, math.floor((HH - btnS)/2)),
        Radius = 6,
        Z = 10,
    })

    local minBtn = button(header, {
        Name = "Minimize",
        Text = "—",
        Color = THEME.PANEL,
        StrokeColor = THEME.ACCENT_DIM,
        Font = Enum.Font.GothamBold,
        TextSize = math.floor(13 * s),
        FrameSize = UDim2.new(0, btnS, 0, btnS),
        Pos = UDim2.new(1, -math.floor(60 * s), 0, math.floor((HH - btnS)/2)),
        Radius = 6,
        Z = 10,
    })

    -- ═══════════════ SIDEBAR ═══════════════
    local sidebar = Instance.new("Frame")
    sidebar.Name = "Sidebar"
    sidebar.Size = UDim2.new(0, SBW, 1, -HH)
    sidebar.Position = UDim2.new(0, 0, 0, HH)
    sidebar.BackgroundColor3 = THEME.PANEL_DARK
    sidebar.BackgroundTransparency = 0.35
    sidebar.BorderSizePixel = 0
    sidebar.Active = false
    sidebar.ZIndex = 5
    sidebar.Parent = main

    -- ═══════════════ CONTENT AREA ═══════════════
    local content = Instance.new("Frame")
    content.Name = "Content"
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
        body.Name = "Body"
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
    local homeBody = makePage("home", "🏠  Home", "Dashboard & info")

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
        Text = "◆  Kei Selvim UI Shell",
        Color = THEME.ACCENT_GLOW,
        Font = Enum.Font.GothamMedium,
        Size = math.floor(9 * s),
        FrameSize = UDim2.new(1, -math.floor(70 * s), 0, math.floor(14 * s)),
        Pos = UDim2.new(0, math.floor(66 * s), 0, math.floor(44 * s)),
        Z = 8,
    })

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

    local function makeStatCard(order, title, value, color, icon)
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

        label(card, {
            Text = icon,
            Color = color,
            Font = Enum.Font.GothamBold,
            Size = math.floor(16 * s),
            FrameSize = UDim2.new(0, math.floor(24 * s), 0, math.floor(20 * s)),
            Pos = UDim2.new(0, math.floor(10 * s), 0, math.floor(8 * s)),
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

    makeStatCard(1, "FPS", "60", Color3.fromRGB(100, 255, 150), "🎮")
    makeStatCard(2, "PING", "0 ms", Color3.fromRGB(255, 200, 100), "📡")
    makeStatCard(3, "STATUS", "Ready", Color3.fromRGB(150, 200, 255), "✦")
    makeStatCard(4, "MODE", "UI Only", Color3.fromRGB(255, 150, 200), "◈")

    -- ─── TOOLS ───
    local toolsBody = makePage("tools", "🛠  Tools", "Function panel — placeholder")

    local toolsCard = Instance.new("Frame")
    toolsCard.Size = UDim2.new(1, 0, 0, math.floor(140 * s))
    toolsCard.BackgroundColor3 = THEME.PANEL
    toolsCard.BackgroundTransparency = THEME.PANEL_TRANS
    toolsCard.BorderSizePixel = 0
    toolsCard.Active = false
    toolsCard.ZIndex = 7
    toolsCard.Parent = toolsBody
    corner(toolsCard, 10)
    stroke(toolsCard, THEME.ACCENT_DIM, 1, 0.2)

    label(toolsCard, {
        Text = "🛠",
        Color = THEME.ACCENT_GLOW,
        Font = Enum.Font.GothamBold,
        Size = math.floor(28 * s),
        FrameSize = UDim2.new(1, 0, 0, math.floor(36 * s)),
        Pos = UDim2.new(0, 0, 0, math.floor(16 * s)),
        XAlign = Enum.TextXAlignment.Center,
        Z = 8,
    })
    label(toolsCard, {
        Text = "Tools panel — isi logic di sini nanti",
        Color = THEME.TEXT_DIM,
        Font = Enum.Font.Gotham,
        Size = math.floor(11 * s),
        FrameSize = UDim2.new(1, 0, 0, math.floor(20 * s)),
        Pos = UDim2.new(0, 0, 0, math.floor(56 * s)),
        XAlign = Enum.TextXAlignment.Center,
        Z = 8,
    })

    local sampleBtn = button(toolsCard, {
        Text = "Sample Button",
        FrameSize = UDim2.new(1, -math.floor(40 * s), 0, math.floor(32 * s)),
        Pos = UDim2.new(0, math.floor(20 * s), 0, math.floor(86 * s)),
        TextSize = math.floor(11 * s),
        Z = 9,
    })
    sampleBtn.MouseButton1Click:Connect(function()
        toast("Sample button clicked — placeholder", THEME.ACCENT_GLOW)
    end)

    -- ─── CONFIG ───
    local configBody = makePage("config", "⚙️  Config", "Settings — placeholder")

    local configCard = Instance.new("Frame")
    configCard.Size = UDim2.new(1, 0, 0, math.floor(100 * s))
    configCard.BackgroundColor3 = THEME.PANEL
    configCard.BackgroundTransparency = THEME.PANEL_TRANS
    configCard.BorderSizePixel = 0
    configCard.Active = false
    configCard.ZIndex = 7
    configCard.Parent = configBody
    corner(configCard, 10)
    stroke(configCard, THEME.ACCENT_DIM, 1, 0.2)

    label(configCard, {
        Text = "⚙️  Config panel — isi logic di sini nanti",
        Color = THEME.TEXT_DIM,
        Font = Enum.Font.Gotham,
        Size = math.floor(11 * s),
        FrameSize = UDim2.new(1, -math.floor(20 * s), 1, 0),
        Pos = UDim2.new(0, math.floor(10 * s), 0, 0),
        XAlign = Enum.TextXAlignment.Center,
        Z = 8,
    })

    -- ─── CROWN ───
    local crownBody = makePage("crown", "👑  Crown", "Admin panel — placeholder")

    local crownCard = Instance.new("Frame")
    crownCard.Size = UDim2.new(1, 0, 0, math.floor(100 * s))
    crownCard.BackgroundColor3 = THEME.PANEL
    crownCard.BackgroundTransparency = THEME.PANEL_TRANS
    crownCard.BorderSizePixel = 0
    crownCard.Active = false
    crownCard.ZIndex = 7
    crownCard.Parent = crownBody
    corner(crownCard, 10)
    stroke(crownCard, Color3.fromRGB(255, 200, 60), 1, 0.2)

    label(crownCard, {
        Text = "👑  Admin panel — isi logic di sini nanti",
        Color = Color3.fromRGB(255, 200, 60),
        Font = Enum.Font.Gotham,
        Size = math.floor(11 * s),
        FrameSize = UDim2.new(1, -math.floor(20 * s), 1, 0),
        Pos = UDim2.new(0, math.floor(10 * s), 0, 0),
        XAlign = Enum.TextXAlignment.Center,
        Z = 8,
    })

    -- ═══════════════ SIDEBAR ICONS ═══════════════
    local iconList = {
        { id = "home",   icon = "🏠" },
        { id = "tools",  icon = "🛠" },
        { id = "config", icon = "⚙️" },
        { id = "crown",  icon = "👑" },
    }

    local iconY = math.floor(10 * s)
    for i, item in ipairs(iconList) do
        local btn = button(sidebar, {
            Name = item.id .. "Icon",
            Text = item.icon,
            Color = THEME.ACCENT_DIM,
            StrokeColor = THEME.ACCENT_DIM,
            Font = Enum.Font.GothamBold,
            TextSize = math.floor(16 * s),
            FrameSize = UDim2.new(0, ICS, 0, ICS),
            Pos = UDim2.new(0, math.floor((SBW - ICS)/2), 0, iconY + (i-1) * (ICS + ICG)),
            Radius = 9,
            Z = 10,
        })
        State.sidebarButtons[item.id] = btn
    end

    -- ═══════════════ PAGE SWITCHING ═══════════════
    local function switchPage(id)
        for pid, page in pairs(State.pages) do
            page.Visible = (pid == id)
        end
        for bid, btn in pairs(State.sidebarButtons) do
            if bid == id then
                btn.BackgroundColor3 = THEME.ACCENT
            else
                btn.BackgroundColor3 = THEME.ACCENT_DIM
            end
        end
        State.currentPage = id
    end

    for id, btn in pairs(State.sidebarButtons) do
        btn.MouseButton1Click:Connect(function()
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
            Text = "⚠️  Konfirmasi",
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

    -- Initial page
    switchPage("home")
    toast("Kei Selvim UI loaded", THEME.SUCCESS)
end

-- ═══════════════════════════════════════════════════════════════════════
-- BOOT
-- ═══════════════════════════════════════════════════════════════════════
task.wait(0.3)
buildUI()