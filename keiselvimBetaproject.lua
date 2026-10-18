--[[
    KEI SELVIM — UI SHELL v4.0 (CLEAN & FIXED)
    - Icon digambar manual pakai Frame (100% render, no unicode glitch)
    - Layout Home dirombak (anti-kepanjangan)
    - Sizing & positioning rapi
]]

local Players          = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local CoreGui          = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer or Players:GetPropertyChangedSignal("LocalPlayer"):Wait() or Players.LocalPlayer

-- ═══════════════════════════════════════════════════════════════════════
-- THEME & CONFIG
-- ═══════════════════════════════════════════════════════════════════════
local C = {
    SHADOW       = Color3.fromRGB(0, 0, 0),
    BG           = Color3.fromRGB(22, 22, 30),
    HEADER       = Color3.fromRGB(30, 30, 42),
    SIDEBAR      = Color3.fromRGB(18, 18, 26),
    CONTENT      = Color3.fromRGB(26, 26, 36),
    CARD         = Color3.fromRGB(34, 34, 48),
    BTN_IDLE     = Color3.fromRGB(50, 50, 70),
    BTN_ACTIVE   = Color3.fromRGB(150, 80, 240),
    BTN_HOVER    = Color3.fromRGB(70, 70, 95),
    TEXT         = Color3.fromRGB(245, 245, 250),
    TEXT_DIM     = Color3.fromRGB(160, 160, 185),
    ACCENT       = Color3.fromRGB(150, 80, 240),
    ACCENT_LITE  = Color3.fromRGB(190, 140, 255),
    DANGER       = Color3.fromRGB(240, 80, 105),
    GOLD         = Color3.fromRGB(255, 200, 60),
    GREEN        = Color3.fromRGB(100, 220, 150),
    BLUE         = Color3.fromRGB(100, 180, 255),
    PINK         = Color3.fromRGB(255, 130, 180),
}

local SIZE = {
    W = 680, H = 440,
    HEADER_H = 48,
    SIDEBAR_W = 70,
    ICON = 46,
    PAD = 16,
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
-- HELPERS
-- ═══════════════════════════════════════════════════════════════════════
local function corner(p, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r)
    c.Parent = p
    return c
end

local function stroke(p, col, thick, trans)
    local s = Instance.new("UIStroke")
    s.Color = col or C.BTN_IDLE
    s.Thickness = thick or 1
    s.Transparency = trans or 0.8
    s.Parent = p
    return s
end

local function label(parent, text, size, color, font, pos, sz, xalign)
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextSize = size
    l.TextColor3 = color
    l.Font = font or Enum.Font.Gotham
    l.TextXAlignment = xalign or Enum.TextXAlignment.Left
    l.TextYAlignment = Enum.TextYAlignment.Center
    l.Position = pos or UDim2.new(0, 0, 0, 0)
    l.Size = sz or UDim2.new(1, 0, 1, 0)
    l.Parent = parent
    return l
end

-- ═══════════════════════════════════════════════════════════════════════
-- VECTOR ICON FACTORY (Dijamin render sempurna)
-- ═══════════════════════════════════════════════════════════════════════
local function createIcon(parent, type, size, color)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(0, size, 0, size)
    holder.BackgroundTransparency = 1
    holder.AnchorPoint = Vector2.new(0.5, 0.5)
    holder.Position = UDim2.new(0.5, 0, 0.5, 0)
    holder.ZIndex = 12
    holder.Parent = parent

    local s = size
    local t = math.max(2, s * 0.1) -- Ketebalan garis
    local parts = {}

    local function line(w, h, x, y, r)
        local f = Instance.new("Frame")
        f.Size = UDim2.new(0, w, 0, h)
        f.Position = UDim2.new(0.5, x, 0.5, y)
        f.AnchorPoint = Vector2.new(0.5, 0.5)
        f.BackgroundColor3 = color
        f.BorderSizePixel = 0
        f.ZIndex = 12
        f.Parent = holder
        if r then f.Rotation = r end
        table.insert(parts, f)
        return f
    end

    if type == "home" then
        -- Atap
        line(s*0.4, t, -s*0.2, -s*0.1, 35)
        line(s*0.4, t, s*0.2, -s*0.1, -35)
        -- Kotak bawah
        line(t, s*0.35, -s*0.25, s*0.15)
        line(t, s*0.35, s*0.25, s*0.15)
        line(s*0.5, t, 0, s*0.32)
        line(s*0.5, t, 0, -s*0.02)
    elseif type == "tools" then
        -- Kunci pas
        line(t, s*0.6, -s*0.1, s*0.1, 45)
        -- Kepala
        local c1 = Instance.new("Frame")
        c1.Size = UDim2.new(0, s*0.3, 0, s*0.3)
        c1.Position = UDim2.new(0.5, s*0.15, 0.5, -s*0.2)
        c1.AnchorPoint = Vector2.new(0.5, 0.5)
        c1.BackgroundTransparency = 1
        c1.Parent = holder
        local cs = Instance.new("UIStroke")
        cs.Color = color
        cs.Thickness = t
        cs.Parent = c1
        corner(c1, s*0.15)
        -- Potong (mask)
        local mask = Instance.new("Frame")
        mask.Size = UDim2.new(0, s*0.2, 0, s*0.2)
        mask.Position = UDim2.new(0.5, s*0.15, 0.5, -s*0.2)
        mask.AnchorPoint = Vector2.new(0.5, 0.5)
        mask.BackgroundColor3 = C.BTN_IDLE -- bakal ketiban pas di color
        mask.ZIndex = 13
        mask.Parent = holder
        table.insert(parts, mask)
    elseif type == "config" then
        -- Gear (Ring)
        local ring = Instance.new("Frame")
        ring.Size = UDim2.new(0, s*0.55, 0, s*0.55)
        ring.Position = UDim2.new(0.5, 0, 0.5, 0)
        ring.AnchorPoint = Vector2.new(0.5, 0.5)
        ring.BackgroundTransparency = 1
        ring.Parent = holder
        local rs = Instance.new("UIStroke")
        rs.Color = color
        rs.Thickness = t * 1.2
        rs.Parent = ring
        corner(ring, s)
        -- Dot tengah
        line(s*0.15, s*0.15, 0, 0, 45)
        -- 4 Gigi
        line(s*0.15, t*1.5, 0, -s*0.3)
        line(s*0.15, t*1.5, 0, s*0.3)
        line(t*1.5, s*0.15, -s*0.3, 0)
        line(t*1.5, s*0.15, s*0.3, 0)
    elseif type == "crown" then
        -- Dasar
        line(s*0.6, t*1.2, 0, s*0.25)
        -- 3 Puncak
        line(t*1.5, s*0.35, -s*0.25, -s*0.05)
        line(t*1.5, s*0.35, s*0.25, -s*0.05)
        line(t*1.5, s*0.35, 0, -s*0.15)
    end

    -- Fungsi ganti warna semua elemen ikon
    holder.SetColor = function(newColor)
        for _, v in ipairs(parts) do
            if v:IsA("Frame") then
                if v:FindFirstChildOfClass("UIStroke") then
                    v:FindFirstChildOfClass("UIStroke").Color = newColor
                else
                    v.BackgroundColor3 = newColor
                end
            end
        end
        -- Ring config
        if type == "config" and holder:FindFirstChildOfClass("Frame") then
             for _, f in ipairs(holder:GetChildren()) do
                 if f:FindFirstChildOfClass("UIStroke") then
                     f:FindFirstChildOfClass("UIStroke").Color = newColor
                 end
             end
        end
    end

    return holder
end

-- ═══════════════════════════════════════════════════════════════════════
-- STATE
-- ═══════════════════════════════════════════════════════════════════════
local State = {
    gui = nil, main = nil, kBtn = nil, current = "home",
    pages = {}, tabs = {},
}

-- ═══════════════════════════════════════════════════════════════════════
-- BUILD UI
-- ═══════════════════════════════════════════════════════════════════════
local function build()
    local parent = getParent()
    if not parent then return end

    local vp = workspace.CurrentCamera.ViewportSize
    local s = 1
    if vp.X < 480 then s = 0.65
    elseif vp.X < 720 then s = 0.8
    elseif vp.X < 1024 then s = 0.9 end

    local W  = math.floor(SIZE.W * s)
    local H  = math.floor(SIZE.H * s)
    local HH = math.floor(SIZE.HEADER_H * s)
    local SW = math.floor(SIZE.SIDEBAR_W * s)
    local IC = math.floor(SIZE.ICON * s)
    local PD = math.floor(SIZE.PAD * s)

    -- GUI
    local gui = Instance.new("ScreenGui")
    gui.Name = "KeiSelvimUI"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.DisplayOrder = 2147483647
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent = parent
    State.gui = gui

    -- Shadow
    local shadow = Instance.new("Frame")
    shadow.Size = UDim2.new(0, W + 16, 0, H + 16)
    shadow.Position = UDim2.new(0.5, -(W+16)/2, 0.5, -(H+16)/2 + 6)
    shadow.BackgroundColor3 = C.SHADOW
    shadow.BackgroundTransparency = 0.5
    shadow.BorderSizePixel = 0
    shadow.ZIndex = 1
    shadow.Parent = gui
    corner(shadow, 20)

    -- Main
    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, W, 0, H)
    main.Position = UDim2.new(0.5, -W/2, 0.5, -H/2)
    main.BackgroundColor3 = C.BG
    main.BorderSizePixel = 0
    main.Active = true
    main.ZIndex = 2
    main.Parent = gui
    corner(main, 16)
    stroke(main, C.ACCENT_LITE, 1, 0.8)
    State.main = main

    -- HEADER
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, HH)
    header.BackgroundColor3 = C.HEADER
    header.BorderSizePixel = 0
    header.Active = true
    header.ZIndex = 5
    header.Parent = main
    corner(header, 16)

    label(header, "◆", math.floor(20*s), C.ACCENT_LITE, Enum.Font.GothamBold,
        UDim2.new(0, math.floor(16*s), 0, 0), UDim2.new(0, math.floor(24*s), 1, 0), Enum.TextXAlignment.Center)

    label(header, "KEI SELVIM", math.floor(14*s), C.TEXT, Enum.Font.GothamBold,
        UDim2.new(0, math.floor(46*s), 0, math.floor(HH/2 - 10*s)), UDim2.new(0, math.floor(140*s), 0, math.floor(16*s)))

    label(header, "SHELL v4.0", math.floor(9*s), C.TEXT_DIM, Enum.Font.Gotham,
        UDim2.new(0, math.floor(47*s), 0, math.floor(HH/2 + 4*s)), UDim2.new(0, math.floor(140*s), 0, math.floor(12*s)))

    local badge = Instance.new("Frame")
    badge.Size = UDim2.new(0, math.floor(44*s), 0, math.floor(20*s))
    badge.Position = UDim2.new(0, math.floor(186*s), 0, math.floor((HH - 20*s)/2))
    badge.BackgroundColor3 = C.ACCENT
    badge.BorderSizePixel = 0
    badge.ZIndex = 6
    badge.Parent = header
    corner(badge, 10)
    label(badge, "v4.0", math.floor(9*s), Color3.fromRGB(255,255,255), Enum.Font.GothamBold,
        UDim2.new(0,0,0,0), UDim2.new(1,0,1,0), Enum.TextXAlignment.Center)

    -- Close & Min
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, math.floor(32*s), 0, math.floor(32*s))
    closeBtn.Position = UDim2.new(1, -math.floor(44*s), 0, math.floor((HH - 32*s)/2))
    closeBtn.BackgroundColor3 = C.DANGER
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = C.TEXT
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = math.floor(14*s)
    closeBtn.BorderSizePixel = 0
    closeBtn.AutoButtonColor = false
    closeBtn.ZIndex = 10
    closeBtn.Parent = header
    corner(closeBtn, 8)

    local minBtn = Instance.new("TextButton")
    minBtn.Size = UDim2.new(0, math.floor(32*s), 0, math.floor(32*s))
    minBtn.Position = UDim2.new(1, -math.floor(84*s), 0, math.floor((HH - 32*s)/2))
    minBtn.BackgroundColor3 = C.BTN_IDLE
    minBtn.Text = "—"
    minBtn.TextColor3 = C.TEXT
    minBtn.Font = Enum.Font.GothamBold
    minBtn.TextSize = math.floor(16*s)
    minBtn.BorderSizePixel = 0
    minBtn.AutoButtonColor = false
    minBtn.ZIndex = 10
    minBtn.Parent = header
    corner(minBtn, 8)

    -- SIDEBAR
    local sidebar = Instance.new("Frame")
    sidebar.Size = UDim2.new(0, SW, 1, -HH)
    sidebar.Position = UDim2.new(0, 0, 0, HH)
    sidebar.BackgroundColor3 = C.SIDEBAR
    sidebar.BorderSizePixel = 0
    sidebar.ZIndex = 4
    sidebar.Parent = main

    -- CONTENT
    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, -(SW + PD*2), 1, -(HH + PD*2))
    content.Position = UDim2.new(0, SW + PD, 0, HH + PD)
    content.BackgroundColor3 = C.CONTENT
    content.BorderSizePixel = 0
    content.ZIndex = 4
    content.Parent = main
    corner(content, 12)

    -- ═══════════ PAGES ═══════════
    local function makePage(id, title, subtitle)
        local p = Instance.new("Frame")
        p.Size = UDim2.new(1, 0, 1, 0)
        p.BackgroundTransparency = 1
        p.Visible = false
        p.ZIndex = 5
        p.Parent = content

        label(p, title, math.floor(18*s), C.TEXT, Enum.Font.GothamBold,
            UDim2.new(0, math.floor(16*s), 0, math.floor(14*s)), UDim2.new(1, -math.floor(32*s), 0, math.floor(24*s)))

        label(p, subtitle, math.floor(11*s), C.TEXT_DIM, Enum.Font.Gotham,
            UDim2.new(0, math.floor(17*s), 0, math.floor(40*s)), UDim2.new(1, -math.floor(32*s), 0, math.floor(16*s)))

        local body = Instance.new("Frame")
        body.Size = UDim2.new(1, -math.floor(32*s), 1, -math.floor(76*s))
        body.Position = UDim2.new(0, math.floor(16*s), 0, math.floor(66*s))
        body.BackgroundTransparency = 1
        body.ZIndex = 6
        body.Parent = p

        State.pages[id] = p
        return body
    end

    -- HOME
    local homeBody = makePage("home", "Home", "Dashboard & info")

    local profile = Instance.new("Frame")
    profile.Size = UDim2.new(1, 0, 0, math.floor(76*s))
    profile.BackgroundColor3 = C.CARD
    profile.BorderSizePixel = 0
    profile.ZIndex = 7
    profile.Parent = homeBody
    corner(profile, 12)

    local av = Instance.new("ImageLabel")
    av.Size = UDim2.new(0, math.floor(52*s), 0, math.floor(52*s))
    av.Position = UDim2.new(0, math.floor(12*s), 0.5, -math.floor(26*s))
    av.BackgroundColor3 = C.SIDEBAR
    av.BorderSizePixel = 0
    av.ZIndex = 8
    av.Parent = profile
    corner(av, math.floor(26*s))
    task.spawn(function()
        if LocalPlayer then
            local ok, thumb = pcall(function() return Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150) end)
            if ok and thumb then av.Image = thumb end
        end
    end)

    label(profile, LocalPlayer and LocalPlayer.DisplayName or "Player", math.floor(15*s), C.TEXT, Enum.Font.GothamBold,
        UDim2.new(0, math.floor(76*s), 0, math.floor(16*s)), UDim2.new(1, -math.floor(90*s), 0, math.floor(18*s)))
    label(profile, "@" .. (LocalPlayer and LocalPlayer.Name or "user"), math.floor(11*s), C.TEXT_DIM, Enum.Font.Gotham,
        UDim2.new(0, math.floor(76*s), 0, math.floor(36*s)), UDim2.new(1, -math.floor(90*s), 0, math.floor(14*s)))
    label(profile, "Kei Selvim • Shell v4.0", math.floor(10*s), C.ACCENT_LITE, Enum.Font.GothamMedium,
        UDim2.new(0, math.floor(76*s), 0, math.floor(54*s)), UDim2.new(1, -math.floor(90*s), 0, math.floor(14*s)))

    -- STATS (Fixed grid)
    local statsFrame = Instance.new("Frame")
    statsFrame.Size = UDim2.new(1, 0, 0, math.floor(146*s))
    statsFrame.Position = UDim2.new(0, 0, 0, math.floor(88*s))
    statsFrame.BackgroundTransparency = 1
    statsFrame.ZIndex = 7
    statsFrame.Parent = homeBody

    local grid = Instance.new("UIGridLayout")
    grid.CellSize = UDim2.new(0.5, -math.floor(6*s), 0, math.floor(64*s))
    grid.CellPadding = UDim2.new(0, math.floor(12*s), 0, math.floor(10*s))
    grid.SortOrder = Enum.SortOrder.LayoutOrder
    grid.Parent = statsFrame

    local function addStat(txt, val, col, order)
        local c = Instance.new("Frame")
        c.LayoutOrder = order
        c.BackgroundColor3 = C.CARD
        c.BorderSizePixel = 0
        c.ZIndex = 8
        c.Parent = statsFrame
        corner(c, 10)

        local bar = Instance.new("Frame")
        bar.Size = UDim2.new(0, math.floor(4*s), 1, -math.floor(16*s))
        bar.Position = UDim2.new(0, 0, 0, math.floor(8*s))
        bar.BackgroundColor3 = col
        bar.BorderSizePixel = 0
        bar.ZIndex = 9
        bar.Parent = c
        corner(bar, 2)

        label(c, txt, math.floor(10*s), C.TEXT_DIM, Enum.Font.Gotham,
            UDim2.new(0, math.floor(16*s), 0, math.floor(12*s)), UDim2.new(1, -math.floor(30*s), 0, math.floor(14*s)))
        label(c, val, math.floor(20*s), col, Enum.Font.GothamBold,
            UDim2.new(0, math.floor(16*s), 0, math.floor(28*s)), UDim2.new(1, -math.floor(30*s), 0, math.floor(26*s)))
    end

    addStat("FPS", "60", C.GREEN, 1)
    addStat("PING", "0 ms", C.GOLD, 2)
    addStat("STATUS", "Ready", C.BLUE, 3)
    addStat("MODE", "UI Only", C.PINK, 4)

    -- TOOLS
    local toolsBody = makePage("tools", "Tools", "Function panel")
    local toolsCard = Instance.new("Frame")
    toolsCard.Size = UDim2.new(1, 0, 0, math.floor(180*s))
    toolsCard.BackgroundColor3 = C.CARD
    toolsCard.BorderSizePixel = 0
    toolsCard.ZIndex = 7
    toolsCard.Parent = toolsBody
    corner(toolsCard, 12)

    createIcon(toolsCard, "tools", math.floor(48*s), C.ACCENT_LITE).Position = UDim2.new(0.5, 0, 0, math.floor(30*s))
    label(toolsCard, "Tools panel — siap diisi logic", math.floor(12*s), C.TEXT_DIM, Enum.Font.Gotham,
        UDim2.new(0, 0, 0, math.floor(80*s)), UDim2.new(1, 0, 0, math.floor(20*s)), Enum.TextXAlignment.Center)

    local sampleBtn = Instance.new("TextButton")
    sampleBtn.Size = UDim2.new(1, -math.floor(40*s), 0, math.floor(40*s))
    sampleBtn.Position = UDim2.new(0, math.floor(20*s), 0, math.floor(116*s))
    sampleBtn.BackgroundColor3 = C.BTN_IDLE
    sampleBtn.Text = "Sample Button"
    sampleBtn.TextColor3 = C.TEXT
    sampleBtn.Font = Enum.Font.GothamSemibold
    sampleBtn.TextSize = math.floor(12*s)
    sampleBtn.BorderSizePixel = 0
    sampleBtn.AutoButtonColor = false
    sampleBtn.ZIndex = 8
    sampleBtn.Parent = toolsCard
    corner(sampleBtn, 8)

    local on = false
    sampleBtn.MouseButton1Click:Connect(function()
        on = not on
        sampleBtn.BackgroundColor3 = on and C.ACCENT or C.BTN_IDLE
        sampleBtn.Text = on and "Sample — ON" or "Sample Button"
    end)

    -- CONFIG
    local configBody = makePage("config", "Config", "Settings panel")
    local configCard = Instance.new("Frame")
    configCard.Size = UDim2.new(1, 0, 0, math.floor(140*s))
    configCard.BackgroundColor3 = C.CARD
    configCard.BorderSizePixel = 0
    configCard.ZIndex = 7
    configCard.Parent = configBody
    corner(configCard, 12)

    createIcon(configCard, "config", math.floor(48*s), C.ACCENT_LITE).Position = UDim2.new(0.5, 0, 0, math.floor(30*s))
    label(configCard, "Config panel — siap diisi logic", math.floor(12*s), C.TEXT_DIM, Enum.Font.Gotham,
        UDim2.new(0, 0, 0, math.floor(90*s)), UDim2.new(1, 0, 0, math.floor(20*s)), Enum.TextXAlignment.Center)

    -- CROWN
    local crownBody = makePage("crown", "Crown", "Admin panel")
    local crownCard = Instance.new("Frame")
    crownCard.Size = UDim2.new(1, 0, 0, math.floor(140*s))
    crownCard.BackgroundColor3 = C.CARD
    crownCard.BorderSizePixel = 0
    crownCard.ZIndex = 7
    crownCard.Parent = crownBody
    corner(crownCard, 12)

    createIcon(crownCard, "crown", math.floor(48*s), C.GOLD).Position = UDim2.new(0.5, 0, 0, math.floor(30*s))
    label(crownCard, "Admin panel — siap diisi logic", math.floor(12*s), C.GOLD, Enum.Font.Gotham,
        UDim2.new(0, 0, 0, math.floor(90*s)), UDim2.new(1, 0, 0, math.floor(20*s)), Enum.TextXAlignment.Center)

    -- SIDEBAR TABS
    local tabs = {
        { id = "home",   type = "home" },
        { id = "tools",  type = "tools" },
        { id = "config", type = "config" },
        { id = "crown",  type = "crown", col = C.GOLD },
    }

    local startY = math.floor(16*s)
    for i, tab in ipairs(tabs) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, IC, 0, IC)
        btn.Position = UDim2.new(0, math.floor((SW - IC)/2), 0, startY + (i-1) * (IC + math.floor(8*s)))
        btn.BackgroundColor3 = C.BTN_IDLE
        btn.Text = ""
        btn.BorderSizePixel = 0
        btn.AutoButtonColor = false
        btn.ZIndex = 8
        btn.Parent = sidebar
        corner(btn, 10)

        local idleCol = tab.col or C.TEXT_DIM
        local icon = createIcon(btn, tab.type, math.floor(22*s), idleCol)
        
        State.tabs[tab.id] = { btn = btn, icon = icon, idleCol = idleCol }

        btn.MouseButton1Click:Connect(function()
            for id, data in pairs(State.tabs) do
                State.pages[id].Visible = (id == tab.id)
                data.btn.BackgroundColor3 = (id == tab.id) and C.ACCENT or C.BTN_IDLE
                data.icon.SetColor((id == tab.id) and Color3.fromRGB(255,255,255) or data.idleCol)
            end
            State.current = tab.id
        end)

        btn.MouseEnter:Connect(function()
            if State.current ~= tab.id then
                btn.BackgroundColor3 = C.BTN_HOVER
                icon.SetColor(C.TEXT)
            end
        end)

        btn.MouseLeave:Connect(function()
            if State.current ~= tab.id then
                btn.BackgroundColor3 = C.BTN_IDLE
                icon.SetColor(idleCol)
            end
        end)
    end

    -- DRAG
    local drag, dragStart, startPos = false, nil, nil
    header.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            drag = true; dragStart = i.Position; startPos = main.Position
        end
    end)
    header.InputChanged:Connect(function(i)
        if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - dragStart
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
            shadow.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X - math.floor(8*s), startPos.Y.Scale, startPos.Y.Offset + d.Y - math.floor(2*s))
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag = false end
    end)

    -- CLOSE
    closeBtn.MouseButton1Click:Connect(function()
        local cW, cH = math.floor(300*s), math.floor(150*s)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0, cW, 0, cH)
        frame.Position = UDim2.new(0.5, -cW/2, 0.5, -cH/2)
        frame.BackgroundColor3 = C.HEADER
        frame.ZIndex = 100
        frame.Parent = gui
        corner(frame, 12)
        
        label(frame, "Konfirmasi", math.floor(16*s), C.TEXT, Enum.Font.GothamBold, UDim2.new(0,0,0,math.floor(20*s)), UDim2.new(1,0,0,math.floor(24*s)), Enum.TextXAlignment.Center)
        label(frame, "Yakin mau tutup Kei Selvim?", math.floor(11*s), C.TEXT_DIM, Enum.Font.Gotham, UDim2.new(0,math.floor(10*s),0,math.floor(50*s)), UDim2.new(1,-math.floor(20*s),0,math.floor(30*s)), Enum.TextXAlignment.Center)

        local y = Instance.new("TextButton")
        y.Size = UDim2.new(0, math.floor(120*s), 0, math.floor(36*s))
        y.Position = UDim2.new(0, math.floor(15*s), 0, math.floor(96*s))
        y.BackgroundColor3 = C.DANGER
        y.Text = "Ya, Tutup"
        y.TextColor3 = C.TEXT
        y.Font = Enum.Font.GothamBold
        y.TextSize = math.floor(11*s)
        y.ZIndex = 101
        y.Parent = frame
        corner(y, 8)

        local n = Instance.new("TextButton")
        n.Size = UDim2.new(0, math.floor(120*s), 0, math.floor(36*s))
        n.Position = UDim2.new(1, -math.floor(135*s), 0, math.floor(96*s))
        n.BackgroundColor3 = C.BTN_IDLE
        n.Text = "Batal"
        n.TextColor3 = C.TEXT
        n.Font = Enum.Font.GothamBold
        n.TextSize = math.floor(11*s)
        n.ZIndex = 101
        n.Parent = frame
        corner(n, 8)

        n.MouseButton1Click:Connect(function() frame:Destroy() end)
        y.MouseButton1Click:Connect(function() gui:Destroy(); if State.kBtn then State.kBtn:Destroy() end end)
    end)

    -- MINIMIZE
    minBtn.MouseButton1Click:Connect(function()
        main.Visible = false
        if not State.kBtn or not State.kBtn.Parent then
            local k = Instance.new("TextButton")
            k.Size = UDim2.new(0, math.floor(54*s), 0, math.floor(54*s))
            k.Position = UDim2.new(0, math.floor(24*s), 0.5, -math.floor(27*s))
            k.BackgroundColor3 = C.ACCENT
            k.Text = "K"
            k.TextColor3 = C.TEXT
            k.Font = Enum.Font.GothamBold
            k.TextSize = math.floor(22*s)
            k.BorderSizePixel = 0
            k.ZIndex = 50
            k.Parent = gui
            corner(k, math.floor(27*s))
            k.MouseButton1Click:Connect(function() main.Visible = true; k.Visible = false end)
            State.kBtn = k
        end
        State.kBtn.Visible = true
    end)

    -- Init
    for id, data in pairs(State.tabs) do
        State.pages[id].Visible = (id == "home")
        data.btn.BackgroundColor3 = (id == "home") and C.ACCENT or C.BTN_IDLE
        data.icon.SetColor((id == "home") and Color3.fromRGB(255,255,255) or data.idleCol)
    end
end

task.wait(0.5)
pcall(build)
