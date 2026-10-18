--[[
    KEI SELVIM — UI SHELL v3.2 — GUARANTEED VISIBLE
    - No Tween, No UIStroke, No ImageLabel, No UIGradient
    - LocalPlayer di-fetch dengan aman (WaitForChild)
    - Semua build dibungkus pcall, error muncul di console
    - Layout manual yang anti-gagal
]]

local Players          = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local CoreGui          = game:GetService("CoreGui")

-- Fetch LocalPlayer dengan aman
local LocalPlayer
if Players.LocalPlayer then
    LocalPlayer = Players.LocalPlayer
else
    Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
    LocalPlayer = Players.LocalPlayer
end

-- ═══════════════════════════════════════════════════════════════════════
-- WARNA & UKURAN
-- ═══════════════════════════════════════════════════════════════════════
local C = {
    BG           = Color3.fromRGB(22, 22, 30),
    HEADER       = Color3.fromRGB(32, 32, 46),
    SIDEBAR      = Color3.fromRGB(18, 18, 26),
    CONTENT      = Color3.fromRGB(26, 26, 38),
    CARD         = Color3.fromRGB(36, 36, 52),
    BTN_IDLE     = Color3.fromRGB(54, 54, 74),
    BTN_ACTIVE   = Color3.fromRGB(150, 80, 240),
    BTN_HOVER    = Color3.fromRGB(78, 78, 105),
    TEXT         = Color3.fromRGB(245, 245, 250),
    TEXT_DIM     = Color3.fromRGB(160, 160, 185),
    ACCENT       = Color3.fromRGB(150, 80, 240),
    ACCENT_LITE  = Color3.fromRGB(200, 160, 255),
    DANGER       = Color3.fromRGB(240, 80, 105),
    GOLD         = Color3.fromRGB(255, 200, 60),
    GREEN        = Color3.fromRGB(100, 220, 150),
    BLUE         = Color3.fromRGB(100, 180, 255),
    PINK         = Color3.fromRGB(255, 130, 180),
}

local SIZE = {
    W = 660, H = 440,
    HEADER_H = 48,
    SIDEBAR_W = 72,
    ICON = 48,
    ICON_GAP = 8,
    PAD = 14,
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

local function mkLabel(parent, text, size, color, font, pos, sz, xalign)
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
    l.TextWrapped = false
    l.Parent = parent
    return l
end

local function mkButton(parent, text, size, color, fontSize)
    local b = Instance.new("TextButton")
    b.Text = text
    b.TextColor3 = C.TEXT
    b.Font = Enum.Font.GothamSemibold
    b.TextSize = fontSize or 12
    b.BackgroundColor3 = color or C.BTN_IDLE
    b.BorderSizePixel = 0
    b.AutoButtonColor = false
    b.Size = size
    b.Parent = parent
    corner(b, 8)
    return b
end

-- ═══════════════════════════════════════════════════════════════════════
-- STATE
-- ═══════════════════════════════════════════════════════════════════════
local State = {
    gui = nil,
    main = nil,
    kBtn = nil,
    current = "home",
    pages = {},
    tabs = {},
    tabColors = {},  -- simpan warna idle per tab (crown = gold)
}

-- ═══════════════════════════════════════════════════════════════════════
-- BUILD UI
-- ═══════════════════════════════════════════════════════════════════════
local function build()
    local parent = getParent()
    if not parent then
        warn("[Kei] FATAL: no parent gui. gethui() failed and CoreGui protected.")
        return
    end
    print("[Kei] parent ok:", parent:GetFullName())

    local vp = workspace.CurrentCamera.ViewportSize
    local s = 1
    if vp.X < 480 then s = 0.6
    elseif vp.X < 720 then s = 0.75
    elseif vp.X < 1024 then s = 0.88 end

    local W  = math.floor(SIZE.W * s)
    local H  = math.floor(SIZE.H * s)
    local HH = math.floor(SIZE.HEADER_H * s)
    local SW = math.floor(SIZE.SIDEBAR_W * s)
    local IC = math.floor(SIZE.ICON * s)
    local IG = math.floor(SIZE.ICON_GAP * s)
    local PD = math.floor(SIZE.PAD * s)

    -- ScreenGui
    local gui = Instance.new("ScreenGui")
    gui.Name = "KeiSelvimUI"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.DisplayOrder = 2147483647
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent = parent
    State.gui = gui
    print("[Kei] ScreenGui created")

    -- Main
    local main = Instance.new("Frame")
    main.Name = "Main"
    main.Size = UDim2.new(0, W, 0, H)
    main.Position = UDim2.new(0.5, -W/2, 0.5, -H/2)
    main.BackgroundColor3 = C.BG
    main.BorderSizePixel = 0
    main.Active = true
    main.ZIndex = 2
    main.Parent = gui
    corner(main, 14)
    State.main = main
    print("[Kei] main frame created")

    -- ═══════════ HEADER ═══════════
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, HH)
    header.BackgroundColor3 = C.HEADER
    header.BorderSizePixel = 0
    header.Active = true
    header.ZIndex = 5
    header.Parent = main
    corner(header, 14)

    -- Logo
    mkLabel(header, "◆", math.floor(22*s), C.ACCENT_LITE, Enum.Font.GothamBold,
        UDim2.new(0, math.floor(16*s), 0, 0),
        UDim2.new(0, math.floor(28*s), 1, 0),
        Enum.TextXAlignment.Center)

    -- Title
    mkLabel(header, "KEI SELVIM", math.floor(14*s), C.TEXT, Enum.Font.GothamBold,
        UDim2.new(0, math.floor(48*s), 0, math.floor(HH/2 - 11*s)),
        UDim2.new(0, math.floor(140*s), 0, math.floor(16*s)))

    mkLabel(header, "SHELL v3.2", math.floor(9*s), C.TEXT_DIM, Enum.Font.Gotham,
        UDim2.new(0, math.floor(49*s), 0, math.floor(HH/2 + 3*s)),
        UDim2.new(0, math.floor(140*s), 0, math.floor(12*s)))

    -- Version badge
    local badge = Instance.new("Frame")
    badge.Size = UDim2.new(0, math.floor(46*s), 0, math.floor(20*s))
    badge.Position = UDim2.new(0, math.floor(196*s), 0, math.floor((HH - 20*s)/2))
    badge.BackgroundColor3 = C.ACCENT
    badge.BorderSizePixel = 0
    badge.ZIndex = 6
    badge.Parent = header
    corner(badge, 10)
    mkLabel(badge, "v3.2", math.floor(9*s), Color3.fromRGB(255,255,255), Enum.Font.GothamBold,
        UDim2.new(0,0,0,0), UDim2.new(1,0,1,0), Enum.TextXAlignment.Center)

    -- Close button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, math.floor(34*s), 0, math.floor(34*s))
    closeBtn.Position = UDim2.new(1, -math.floor(44*s), 0, math.floor((HH - 34*s)/2))
    closeBtn.BackgroundColor3 = C.DANGER
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.fromRGB(255,255,255)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = math.floor(15*s)
    closeBtn.BorderSizePixel = 0
    closeBtn.AutoButtonColor = false
    closeBtn.ZIndex = 10
    closeBtn.Parent = header
    corner(closeBtn, 6)

    -- Minimize button
    local minBtn = Instance.new("TextButton")
    minBtn.Size = UDim2.new(0, math.floor(34*s), 0, math.floor(34*s))
    minBtn.Position = UDim2.new(1, -math.floor(84*s), 0, math.floor((HH - 34*s)/2))
    minBtn.BackgroundColor3 = C.BTN_IDLE
    minBtn.Text = "—"
    minBtn.TextColor3 = C.TEXT
    minBtn.Font = Enum.Font.GothamBold
    minBtn.TextSize = math.floor(18*s)
    minBtn.BorderSizePixel = 0
    minBtn.AutoButtonColor = false
    minBtn.ZIndex = 10
    minBtn.Parent = header
    corner(minBtn, 6)

    -- ═══════════ SIDEBAR ═══════════
    local sidebar = Instance.new("Frame")
    sidebar.Name = "Sidebar"
    sidebar.Size = UDim2.new(0, SW, 1, -HH)
    sidebar.Position = UDim2.new(0, 0, 0, HH)
    sidebar.BackgroundColor3 = C.SIDEBAR
    sidebar.BorderSizePixel = 0
    sidebar.ZIndex = 4
    sidebar.Parent = main

    -- ═══════════ CONTENT ═══════════
    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Size = UDim2.new(1, -(SW + PD*2), 1, -(HH + PD*2))
    content.Position = UDim2.new(0, SW + PD, 0, HH + PD)
    content.BackgroundColor3 = C.CONTENT
    content.BorderSizePixel = 0
    content.ZIndex = 4
    content.Parent = main
    corner(content, 10)

    -- ═══════════ PAGE FACTORY ═══════════
    local function makePage(id, title, subtitle)
        local p = Instance.new("Frame")
        p.Name = id .. "Page"
        p.Size = UDim2.new(1, 0, 1, 0)
        p.BackgroundTransparency = 1
        p.Visible = false
        p.ZIndex = 5
        p.Parent = content

        mkLabel(p, title, math.floor(18*s), C.TEXT, Enum.Font.GothamBold,
            UDim2.new(0, math.floor(16*s), 0, math.floor(12*s)),
            UDim2.new(1, -math.floor(32*s), 0, math.floor(24*s)))

        mkLabel(p, subtitle, math.floor(11*s), C.TEXT_DIM, Enum.Font.Gotham,
            UDim2.new(0, math.floor(17*s), 0, math.floor(38*s)),
            UDim2.new(1, -math.floor(32*s), 0, math.floor(16*s)))

        local body = Instance.new("Frame")
        body.Size = UDim2.new(1, -math.floor(32*s), 1, -math.floor(74*s))
        body.Position = UDim2.new(0, math.floor(16*s), 0, math.floor(64*s))
        body.BackgroundTransparency = 1
        body.ZIndex = 6
        body.Parent = p

        State.pages[id] = p
        return body
    end

    -- ─── HOME ───
    local homeBody = makePage("home", "Home", "Dashboard & info")

    -- Profile card
    local profile = Instance.new("Frame")
    profile.Size = UDim2.new(1, 0, 0, math.floor(76*s))
    profile.BackgroundColor3 = C.CARD
    profile.BorderSizePixel = 0
    profile.ZIndex = 7
    profile.Parent = homeBody
    corner(profile, 10)

    mkLabel(profile, "◆", math.floor(32*s), C.ACCENT_LITE, Enum.Font.GothamBold,
        UDim2.new(0, math.floor(14*s), 0, 0),
        UDim2.new(0, math.floor(56*s), 1, 0),
        Enum.TextXAlignment.Center)

    mkLabel(profile, (LocalPlayer and LocalPlayer.DisplayName) or "Player",
        math.floor(15*s), C.TEXT, Enum.Font.GothamBold,
        UDim2.new(0, math.floor(80*s), 0, math.floor(14*s)),
        UDim2.new(1, -math.floor(96*s), 0, math.floor(18*s)))

    mkLabel(profile, "@" .. ((LocalPlayer and LocalPlayer.Name) or "player"),
        math.floor(11*s), C.TEXT_DIM, Enum.Font.Gotham,
        UDim2.new(0, math.floor(80*s), 0, math.floor(34*s)),
        UDim2.new(1, -math.floor(96*s), 0, math.floor(14*s)))

    mkLabel(profile, "Kei Selvim  ·  Shell v3.2",
        math.floor(10*s), C.ACCENT_LITE, Enum.Font.GothamMedium,
        UDim2.new(0, math.floor(80*s), 0, math.floor(52*s)),
        UDim2.new(1, -math.floor(96*s), 0, math.floor(14*s)))

    -- Stat cards (pakai grid layout)
    local statsHolder = Instance.new("Frame")
    statsHolder.Size = UDim2.new(1, 0, 0, math.floor(148*s))
    statsHolder.Position = UDim2.new(0, 0, 0, math.floor(86*s))
    statsHolder.BackgroundTransparency = 1
    statsHolder.ZIndex = 7
    statsHolder.Parent = homeBody

    local grid = Instance.new("UIGridLayout")
    grid.CellSize = UDim2.new(0.5, -math.floor(6*s), 0, math.floor(66*s))
    grid.CellPadding = UDim2.new(0, math.floor(12*s), 0, math.floor(10*s))
    grid.SortOrder = Enum.SortOrder.LayoutOrder
    grid.Parent = statsHolder

    local statData = {
        {title = "FPS", value = "60", color = C.GREEN, sym = "▲"},
        {title = "PING", value = "0 ms", color = C.GOLD, sym = "●"},
        {title = "STATUS", value = "Ready", color = C.BLUE, sym = "◆"},
        {title = "MODE", value = "UI Only", color = C.PINK, sym = "■"},
    }

    for i, d in ipairs(statData) do
        local card = Instance.new("Frame")
        card.LayoutOrder = i
        card.BackgroundColor3 = C.CARD
        card.BorderSizePixel = 0
        card.ZIndex = 8
        card.Parent = statsHolder
        corner(card, 10)

        mkLabel(card, d.title, math.floor(10*s), C.TEXT_DIM, Enum.Font.Gotham,
            UDim2.new(0, math.floor(14*s), 0, math.floor(10*s)),
            UDim2.new(1, -math.floor(54*s), 0, math.floor(14*s)))

        mkLabel(card, d.value, math.floor(20*s), d.color, Enum.Font.GothamBold,
            UDim2.new(0, math.floor(14*s), 0, math.floor(28*s)),
            UDim2.new(1, -math.floor(54*s), 0, math.floor(28*s)))

        mkLabel(card, d.sym, math.floor(20*s), d.color, Enum.Font.GothamBold,
            UDim2.new(1, -math.floor(42*s), 0, math.floor(16*s)),
            UDim2.new(0, math.floor(34*s), 0, math.floor(34*s)),
            Enum.TextXAlignment.Center)
    end

    -- ─── TOOLS ───
    local toolsBody = makePage("tools", "Tools", "Function panel")
    local toolsCard = Instance.new("Frame")
    toolsCard.Size = UDim2.new(1, 0, 0, math.floor(200*s))
    toolsCard.BackgroundColor3 = C.CARD
    toolsCard.BorderSizePixel = 0
    toolsCard.ZIndex = 7
    toolsCard.Parent = toolsBody
    corner(toolsCard, 10)

    mkLabel(toolsCard, "⚙", math.floor(56*s), C.ACCENT_LITE, Enum.Font.GothamBold,
        UDim2.new(0, 0, 0, math.floor(20*s)),
        UDim2.new(1, 0, 0, math.floor(60*s)),
        Enum.TextXAlignment.Center)

    mkLabel(toolsCard, "Tools panel — siap diisi logic",
        math.floor(12*s), C.TEXT_DIM, Enum.Font.Gotham,
        UDim2.new(0, 0, 0, math.floor(88*s)),
        UDim2.new(1, 0, 0, math.floor(20*s)),
        Enum.TextXAlignment.Center)

    local sampleBtn = mkButton(toolsCard, "Sample Button",
        UDim2.new(1, -math.floor(40*s), 0, math.floor(42*s)),
        C.BTN_IDLE, math.floor(12*s))
    sampleBtn.Position = UDim2.new(0, math.floor(20*s), 0, math.floor(126*s))
    sampleBtn.ZIndex = 8

    local sampleOn = false
    sampleBtn.MouseButton1Click:Connect(function()
        sampleOn = not sampleOn
        sampleBtn.BackgroundColor3 = sampleOn and C.ACCENT or C.BTN_IDLE
        sampleBtn.Text = sampleOn and "Sample — ON" or "Sample Button"
    end)
    sampleBtn.MouseEnter:Connect(function()
        if not sampleOn then sampleBtn.BackgroundColor3 = C.BTN_HOVER end
    end)
    sampleBtn.MouseLeave:Connect(function()
        if not sampleOn then sampleBtn.BackgroundColor3 = C.BTN_IDLE end
    end)

    -- ─── CONFIG ───
    local configBody = makePage("config", "Config", "Settings panel")
    local configCard = Instance.new("Frame")
    configCard.Size = UDim2.new(1, 0, 0, math.floor(150*s))
    configCard.BackgroundColor3 = C.CARD
    configCard.BorderSizePixel = 0
    configCard.ZIndex = 7
    configCard.Parent = configBody
    corner(configCard, 10)

    mkLabel(configCard, "☰", math.floor(56*s), C.ACCENT_LITE, Enum.Font.GothamBold,
        UDim2.new(0, 0, 0, math.floor(20*s)),
        UDim2.new(1, 0, 0, math.floor(60*s)),
        Enum.TextXAlignment.Center)

    mkLabel(configCard, "Config panel — siap diisi logic",
        math.floor(12*s), C.TEXT_DIM, Enum.Font.Gotham,
        UDim2.new(0, 0, 0, math.floor(92*s)),
        UDim2.new(1, 0, 0, math.floor(20*s)),
        Enum.TextXAlignment.Center)

    -- ─── CROWN ───
    local crownBody = makePage("crown", "Crown", "Admin panel")
    local crownCard = Instance.new("Frame")
    crownCard.Size = UDim2.new(1, 0, 0, math.floor(150*s))
    crownCard.BackgroundColor3 = C.CARD
    crownCard.BorderSizePixel = 0
    crownCard.ZIndex = 7
    crownCard.Parent = crownBody
    corner(crownCard, 10)

    mkLabel(crownCard, "♛", math.floor(56*s), C.GOLD, Enum.Font.GothamBold,
        UDim2.new(0, 0, 0, math.floor(20*s)),
        UDim2.new(1, 0, 0, math.floor(60*s)),
        Enum.TextXAlignment.Center)

    mkLabel(crownCard, "Admin panel — siap diisi logic",
        math.floor(12*s), C.GOLD, Enum.Font.Gotham,
        UDim2.new(0, 0, 0, math.floor(92*s)),
        UDim2.new(1, 0, 0, math.floor(20*s)),
        Enum.TextXAlignment.Center)

    -- ═══════════ SIDEBAR TABS ═══════════
    local tabs = {
        { id = "home",   glyph = "⌂", idleCol = C.TEXT },
        { id = "tools",  glyph = "⚙", idleCol = C.TEXT },
        { id = "config", glyph = "☰", idleCol = C.TEXT },
        { id = "crown",  glyph = "♛", idleCol = C.GOLD },
    }

    local startY = math.floor(14*s)
    for i, tab in ipairs(tabs) do
        local btn = Instance.new("TextButton")
        btn.Name = tab.id .. "Tab"
        btn.Size = UDim2.new(0, IC, 0, IC)
        btn.Position = UDim2.new(0, math.floor((SW - IC)/2), 0, startY + (i-1) * (IC + IG))
        btn.BackgroundColor3 = C.BTN_IDLE
        btn.Text = tab.glyph
        btn.TextColor3 = tab.idleCol
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = math.floor(26*s)
        btn.BorderSizePixel = 0
        btn.AutoButtonColor = false
        btn.ZIndex = 8
        btn.Parent = sidebar
        corner(btn, 8)
        State.tabs[tab.id] = btn
        State.tabColors[tab.id] = tab.idleCol
    end

    -- ═══════════ PAGE SWITCH ═══════════
    local function switchPage(id)
        for pid, page in pairs(State.pages) do
            page.Visible = (pid == id)
        end
        for tid, btn in pairs(State.tabs) do
            if tid == id then
                btn.BackgroundColor3 = C.BTN_ACTIVE
                btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            else
                btn.BackgroundColor3 = C.BTN_IDLE
                btn.TextColor3 = State.tabColors[tid] or C.TEXT
            end
        end
        State.current = id
    end

    for id, btn in pairs(State.tabs) do
        btn.MouseButton1Click:Connect(function()
            switchPage(id)
        end)
        btn.MouseEnter:Connect(function()
            if State.current ~= id then
                btn.BackgroundColor3 = C.BTN_HOVER
            end
        end)
        btn.MouseLeave:Connect(function()
            if State.current ~= id then
                btn.BackgroundColor3 = C.BTN_IDLE
            end
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
            local d = input.Position - dragStart
            main.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + d.X,
                startPos.Y.Scale, startPos.Y.Offset + d.Y
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
        local cW = math.floor(310*s)
        local cH = math.floor(160*s)
        local confirm = Instance.new("Frame")
        confirm.Size = UDim2.new(0, cW, 0, cH)
        confirm.Position = UDim2.new(0.5, -cW/2, 0.5, -cH/2)
        confirm.BackgroundColor3 = C.HEADER
        confirm.BorderSizePixel = 0
        confirm.ZIndex = 100
        confirm.Parent = gui
        corner(confirm, 12)

        mkLabel(confirm, "Konfirmasi", math.floor(15*s), C.TEXT, Enum.Font.GothamBold,
            UDim2.new(0, 0, 0, math.floor(18*s)),
            UDim2.new(1, 0, 0, math.floor(24*s)),
            Enum.TextXAlignment.Center)

        mkLabel(confirm, "Yakin mau tutup Kei Selvim?",
            math.floor(11*s), C.TEXT_DIM, Enum.Font.Gotham,
            UDim2.new(0, math.floor(10*s), 0, math.floor(48*s)),
            UDim2.new(1, -math.floor(20*s), 0, math.floor(36*s)),
            Enum.TextXAlignment.Center)

        local bW = (cW - math.floor(30*s)) / 2
        local yes = mkButton(confirm, "Ya, Tutup",
            UDim2.new(0, bW, 0, math.floor(34*s)), C.DANGER, math.floor(11*s))
        yes.Position = UDim2.new(0, math.floor(10*s), 0, math.floor(104*s))
        yes.ZIndex = 101

        local no = mkButton(confirm, "Batal",
            UDim2.new(0, bW, 0, math.floor(34*s)), C.BTN_IDLE, math.floor(11*s))
        no.Position = UDim2.new(0, math.floor(20*s) + bW, 0, math.floor(104*s))
        no.ZIndex = 101

        no.MouseButton1Click:Connect(function() confirm:Destroy() end)
        yes.MouseButton1Click:Connect(function()
            gui:Destroy()
            if State.kBtn then State.kBtn:Destroy() end
        end)
    end)

    -- ═══════════ MINIMIZE ═══════════
    minBtn.MouseButton1Click:Connect(function()
        main.Visible = false

        if not State.kBtn or not State.kBtn.Parent then
            local kS = math.floor(54*s)
            local k = Instance.new("TextButton")
            k.Name = "KButton"
            k.Size = UDim2.new(0, kS, 0, kS)
            k.Position = UDim2.new(0, math.floor(20*s), 0.5, -kS/2)
            k.BackgroundColor3 = C.ACCENT
            k.Text = "K"
            k.TextColor3 = Color3.fromRGB(255,255,255)
            k.Font = Enum.Font.GothamBold
            k.TextSize = math.floor(24*s)
            k.BorderSizePixel = 0
            k.AutoButtonColor = false
            k.Active = true
            k.Draggable = true
            k.ZIndex = 50
            k.Parent = gui
            corner(k, kS/2)

            k.MouseButton1Click:Connect(function()
                main.Visible = true
                k.Visible = false
            end)
            State.kBtn = k
        end
        State.kBtn.Visible = true
    end)

    -- Init
    switchPage("home")
    print("[Kei] BUILD OK — all elements created")
end

-- ═══════════════════════════════════════════════════════════════════════
-- BOOT dengan error trace
-- ═══════════════════════════════════════════════════════════════════════
task.wait(0.5)
local ok, err = pcall(build)
if not ok then
    warn("[Kei] BUILD FAILED:", err)
end
