--[[
    ╔══════════════════════════════════════════════════════════════════════╗
    ║           KEI SELVIM — ULTIMATE EXPLOIT HUB v7.0                     ║
    ║           Intel + 3 Steal Methods + Monster Freeze + Shop Bypass     ║
    ╚══════════════════════════════════════════════════════════════════════╝
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer or Players:GetPropertyChangedSignal("LocalPlayer"):Wait() or Players.LocalPlayer

-- =========================================================================
-- ⚙️ STATE & CONFIG
-- =========================================================================
local State = {
    isAutoStealing = false,
    isMonsterFrozen = false,
    stealMethod = "Teleport", -- "Fly", "Teleport", "ZigZag"
    stealMode = "Best",
    minRarityFilter = "epic",
    targetPlotName = "Plots", -- Nama folder base (bisa diganti)
    autoPlace = true,
    speed = 50,
}

local Connections = {}
local RARITY_ORDER = {
    common = 1, rare = 2, epic = 3, legendary = 4, mythic = 5, 
    secret = 6, ["player god"] = 7, og = 8, champions = 9, 
    dynasty = 10, icons = 11, haunted = 12
}

local C = {
    BG       = Color3.fromRGB(22, 22, 30),
    HEADER   = Color3.fromRGB(30, 30, 42),
    CONTENT  = Color3.fromRGB(26, 26, 36),
    CARD     = Color3.fromRGB(34, 34, 48),
    BTN_IDLE = Color3.fromRGB(50, 50, 70),
    BTN_ACT  = Color3.fromRGB(150, 80, 240),
    TEXT     = Color3.fromRGB(255, 255, 255),
    TEXT_DIM = Color3.fromRGB(160, 160, 185),
    RED      = Color3.fromRGB(240, 80, 105),
    GREEN    = Color3.fromRGB(100, 220, 150),
}

-- =========================================================================
-- HELPER UI & LOG
-- =========================================================================
local function create(cls, props)
    local obj = Instance.new(cls)
    for k, v in pairs(props) do if k ~= "Parent" then obj[k] = v end end
    if props.Parent then obj.Parent = props.Parent end
    return obj
end

local function log(msg)
    print("[KeiExploit] " .. msg)
end

-- =========================================================================
-- METODE 1: 3 CARA NYURI (FLY, TELEPORT, ZIGZAG)
-- =========================================================================

-- A. Teleport Instan (Rawan Anti-Cheat)
local function doTeleport(targetPos)
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = CFrame.new(targetPos + Vector3.new(0, 5, 0))
    end
end

-- B. Fly / Terbang (Bypass Anti-TP karena pergerakan halus)
local flyBV, flyBG
local function toggleFly(state)
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    
    if state then
        flyBV = Instance.new("BodyVelocity")
        flyBV.MaxForce = Vector3.new(1e5, 1e5, 1e5)
        flyBV.Velocity = Vector3.zero
        flyBV.Parent = hrp
        
        flyBG = Instance.new("BodyGyro")
        flyBG.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
        flyBG.P = 1000
        flyBG.Parent = hrp
        
        Connections.Fly = RunService.RenderStepped:Connect(function()
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                flyBV.Velocity = workspace.CurrentCamera.CFrame.LookVector * State.speed
            elseif UserInputService:IsKeyDown(Enum.KeyCode.S) then
                flyBV.Velocity = -workspace.CurrentCamera.CFrame.LookVector * State.speed
            else
                flyBV.Velocity = Vector3.zero
            end
            flyBG.CFrame = workspace.CurrentCamera.CFrame
        end)
    else
        if flyBV then flyBV:Destroy() end
        if flyBG then flyBG:Destroy() end
        if Connections.Fly then Connections.Fly:Disconnect() end
    end
end

-- C. Jalan Zig-Zag (Anti-Cheat Evasion)
local function doZigZag(targetPos)
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char.HumanoidRootPart
    
    local startPos = hrp.Position
    local steps = 5
    for i = 1, steps do
        local t = i / steps
        local basePos = startPos:Lerp(targetPos, t)
        -- Tambahin gerakan zigzag (kiri-kanan)
        local offset = (i % 2 == 0) and Vector3.new(5, 0, 0) or Vector3.new(-5, 0, 0)
        hrp.CFrame = CFrame.new(basePos + offset + Vector3.new(0, 5, 0))
        task.wait(0.1)
    end
    hrp.CFrame = CFrame.new(targetPos + Vector3.new(0, 5, 0))
end

-- =========================================================================
-- METODE 2: MONSTER FREEZE (ANTI HIT)
-- =========================================================================
local function toggleMonstersFreeze(state)
    State.isMonsterFrozen = state
    local baseFolder = Workspace:FindFirstChild(State.targetPlotName)
    
    if baseFolder then
        for _, obj in ipairs(baseFolder:GetDescendants()) do
            if obj:IsA("Model") and (string.find(string.lower(obj.Name), "monster") or string.find(string.lower(obj.Name), "enemy") or string.find(string.lower(obj.Name), "pet")) then
                if state then
                    -- Matikan script AI & Anchor posisinya
                    if obj.PrimaryPart then obj.PrimaryPart.Anchored = true end
                    for _, p in ipairs(obj:GetDescendants()) do
                        if p:IsA("Script") or p:IsA("LocalScript") then p.Disabled = true end
                        if p:IsA("BasePart") then p.CanTouch = false end
                    end
                else
                    if obj.PrimaryPart then obj.PrimaryPart.Anchored = false end
                    for _, p in ipairs(obj:GetDescendants()) do
                        if p:IsA("BasePart") then p.CanTouch = true end
                    end
                end
            end
        end
    end
end

-- =========================================================================
-- METODE 3: SHOP BYPASS (ROBUX GRATIS / ZERO-PRICE)
-- =========================================================================
local function bypassShopRobux(itemName)
    local success = false
    -- Scan semua remote event di ReplicatedStorage
    for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
        if remote:IsA("RemoteFunction") or remote:IsA("RemoteEvent") then
            local name = string.lower(remote.Name)
            -- Cari remote yang ada hubungannya sama toko/beli
            if string.find(name, "buy") or string.find(name, "purchase") or string.find(name, "shop") then
                -- Coba tembak dengan berbagai argumen celah (Bypass Validation)
                pcall(function()
                    if remote:IsA("RemoteFunction") then
                        -- Coba (ItemName, 0) -> Harga 0
                        remote:InvokeServer(itemName, 0)
                        -- Coba (ItemId, false) -> Bypass status
                        remote:InvokeServer(itemName, false)
                    else
                        remote:FireServer(itemName, 0)
                        remote:FireServer(itemName, false)
                    end
                    success = true
                end)
            end
        end
    end
    return success
end

-- =========================================================================
-- FUNGSI AUTO STEAL INTI
-- =========================================================================
local function scanPlayerBase(targetPlayer)
    local bestBlock, bestVal = nil, 0
    local baseFolder = Workspace:FindFirstChild(State.targetPlotName)
    local plot = baseFolder and baseFolder:FindFirstChild(targetPlayer.Name)
    
    if plot then
        for _, block in ipairs(plot:GetDescendants()) do
            if block:IsA("BasePart") and (string.find(string.lower(block.Name), "egg") or string.find(string.lower(block.Name), "bok")) then
                local rName = "common"
                for rar, _ in pairs(RARITY_ORDER) do
                    if string.find(string.lower(block.Name), rar) then rName = rar; break end
                end
                local val = RARITY_ORDER[rName] or 1
                
                if State.stealMode == "Filter" then
                    if val >= (RARITY_ORDER[State.minRarityFilter] or 1) and val > bestVal then
                        bestBlock = block; bestVal = val
                    end
                else
                    if val > bestVal then bestBlock = block; bestVal = val end
                end
            end
        end
    end
    return bestBlock, bestVal
end

local function startAutoSteal()
    task.spawn(function()
        while State.isAutoStealing do
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and State.isAutoStealing then
                    local block, val = scanPlayerBase(plr)
                    if block then
                        local targetPos = block.Position
                        log("Target: " .. block.Name .. " (" .. plr.Name .. ")")
                        
                        -- Eksekusi berdasarkan metode
                        if State.stealMethod == "Teleport" then
                            doTeleport(targetPos)
                        elseif State.stealMethod == "ZigZag" then
                            doZigZag(targetPos)
                        elseif State.stealMethod == "Fly" then
                            toggleFly(true)
                            task.wait(1) -- Terbang manual sebentar
                        end
                        
                        task.wait(0.5)
                        
                        -- Tembak Remote Nyuri (Scan otomatis remote nyuri)
                        for _, r in ipairs(ReplicatedStorage:GetDescendants()) do
                            if r.Name:lower():find("steal") or r.Name:lower():find("take") then
                                if r:IsA("RemoteEvent") then r:FireServer(block) end
                                if r:IsA("RemoteFunction") then r:InvokeServer(block) end
                            end
                        end
                        
                        if State.stealMethod == "Fly" then toggleFly(false) end
                        task.wait(1)
                    end
                end
            end
            task.wait(2)
        end
    end)
end

-- =========================================================================
-- BUILD UI
-- =========================================================================
local function buildUI()
    local parent = CoreGui
    if gethui then local ok, hui = pcall(gethui); if ok and hui then parent = hui end end

    local gui = create("ScreenGui", { Name = "UltimateExploitUI", ResetOnSpawn = false, IgnoreGuiInset = true, DisplayOrder = 999, Parent = parent })
    local main = create("Frame", { Size = UDim2.new(0, 480, 0, 380), Position = UDim2.new(0.5, -240, 0.5, -190), BackgroundColor3 = C.BG, BorderSizePixel = 0, Active = true, Parent = gui })
    create("UICorner", { CornerRadius = UDim.new(0, 12), Parent = main })

    -- Header
    local header = create("Frame", { Size = UDim2.new(1, 0, 0, 45), BackgroundColor3 = C.HEADER, BorderSizePixel = 0, Active = true, Parent = main })
    create("UICorner", { CornerRadius = UDim.new(0, 12), Parent = header })
    create("TextLabel", { Size = UDim2.new(1, -20, 1, 0), Position = UDim2.new(0, 15, 0, 0), BackgroundTransparency = 1, Text = "⚡ ULTIMATE EXPLOIT HUB", TextColor3 = C.TEXT, Font = Enum.Font.GothamBold, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, Parent = header })
    
    local closeBtn = create("TextButton", { Size = UDim2.new(0, 30, 0, 30), Position = UDim2.new(1, -40, 0, 7), BackgroundColor3 = C.RED, Text = "X", TextColor3 = C.TEXT, Font = Enum.Font.GothamBold, TextSize = 14, BorderSizePixel = 0, AutoButtonColor = false, Parent = header })
    create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = closeBtn })
    closeBtn.MouseButton1Click:Connect(function() gui:Destroy() end)

    -- Content
    local content = create("Frame", { Size = UDim2.new(1, -30, 1, -65), Position = UDim2.new(0, 15, 0, 55), BackgroundColor3 = C.CONTENT, BorderSizePixel = 0, Parent = main })
    create("UICorner", { CornerRadius = UDim.new(0, 10), Parent = content })

    -- 1. STEAL METHODS
    create("TextLabel", { Size = UDim2.new(1, -20, 0, 20), Position = UDim2.new(0, 15, 0, 15), BackgroundTransparency = 1, Text = "Metode Mencuri (Celah Anti-Cheat):", TextColor3 = C.TEXT, Font = Enum.Font.GothamBold, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, Parent = content })

    local methods = {"Teleport", "ZigZag", "Fly"}
    local methodBtns = {}
    for i, m in ipairs(methods) do
        local btn = create("TextButton", { Size = UDim2.new(0, 100, 0, 30), Position = UDim2.new(0, 15 + (i-1)*110, 0, 40), BackgroundColor3 = (m == "Teleport") and C.BTN_ACT or C.BTN_IDLE, Text = m, TextColor3 = C.TEXT, Font = Enum.Font.Gotham, TextSize = 12, BorderSizePixel = 0, Parent = content })
        create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = btn })
        methodBtns[m] = btn
        
        btn.MouseButton1Click:Connect(function()
            State.stealMethod = m
            for name, b in pairs(methodBtns) do
                b.BackgroundColor3 = (name == m) and C.BTN_ACT or C.BTN_IDLE
            end
        end)
    end

    -- 2. MONSTER FREEZE & SHOP BYPASS
    create("TextLabel", { Size = UDim2.new(1, -20, 0, 20), Position = UDim2.new(0, 15, 0, 85), BackgroundTransparency = 1, Text = "Fitur Celah Tambahan:", TextColor3 = C.TEXT, Font = Enum.Font.GothamBold, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, Parent = content })

    local btnFreeze = create("TextButton", { Size = UDim2.new(0, 180, 0, 35), Position = UDim2.new(0, 15, 0, 110), BackgroundColor3 = C.BTN_IDLE, Text = "Freeze Monster (OFF)", TextColor3 = C.TEXT, Font = Enum.Font.GothamBold, TextSize = 12, BorderSizePixel = 0, Parent = content })
    create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = btnFreeze })
    btnFreeze.MouseButton1Click:Connect(function()
        State.isMonsterFrozen = not State.isMonsterFrozen
        toggleMonstersFreeze(State.isMonsterFrozen)
        btnFreeze.Text = "Freeze Monster (" .. (State.isMonsterFrozen and "ON" or "OFF") .. ")"
        btnFreeze.BackgroundColor3 = State.isMonsterFrozen and C.BTN_ACT or C.BTN_IDLE
    end)

    local btnShop = create("TextButton", { Size = UDim2.new(0, 180, 0, 35), Position = UDim2.new(0, 205, 0, 110), BackgroundColor3 = C.RED, Text = "Bypass Shop Robux", TextColor3 = C.TEXT, Font = Enum.Font.GothamBold, TextSize = 12, BorderSizePixel = 0, Parent = content })
    create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = btnShop })
    btnShop.MouseButton1Click:Connect(function()
        btnShop.Text = "Mencari Celah..."
        task.spawn(function()
            -- Scan semua item di game (contoh nama item)
            local testItem = "VIP" -- Ganti dengan nama item toko
            local ok = bypassShopRobux(testItem)
            btnShop.Text = ok and "Bypass Sukses!" or "Bypass Gagal"
            task.wait(2)
            btnShop.Text = "Bypass Shop Robux"
        end)
    end)

    -- 3. START STEAL
    local btnStart = create("TextButton", { Size = UDim2.new(1, -30, 0, 45), Position = UDim2.new(0, 15, 0, 170), BackgroundColor3 = C.GREEN, Text = "MULAI AUTO STEAL", TextColor3 = Color3.new(0,0,0), Font = Enum.Font.GothamBold, TextSize = 14, BorderSizePixel = 0, Parent = content })
    create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = btnStart })
    btnStart.MouseButton1Click:Connect(function()
        State.isAutoStealing = not State.isAutoStealing
        if State.isAutoStealing then
            btnStart.Text = "STOP AUTO STEAL"
            btnStart.BackgroundColor3 = C.RED
            btnStart.TextColor3 = C.TEXT
            startAutoSteal()
        else
            btnStart.Text = "MULAI AUTO STEAL"
            btnStart.BackgroundColor3 = C.GREEN
            btnStart.TextColor3 = Color3.new(0,0,0)
            toggleFly(false)
        end
    end)

    -- Drag UI
    local drag, startPos, dragStart
    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            drag = true; dragStart = input.Position; startPos = main.Position
        end
    end)
    header.InputChanged:Connect(function(input)
        if drag and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local d = input.Position - dragStart
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then drag = false end
    end)
end

-- JALANKAN
task.wait(0.5)
local success, err = pcall(buildUI)
if not success then warn("[KeiExploit] UI Error: " .. tostring(err)) end
