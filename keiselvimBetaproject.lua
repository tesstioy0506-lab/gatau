--[[
    ╔══════════════════════════════════════════════════════════════════════╗
    ║           KEI SELVIM — KOTA GUI v17.1                                ║
    ║           Modern Box UI • Decimal Coordinates • Toggle Features      ║
    ╚══════════════════════════════════════════════════════════════════════╝
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

-- =========================================================================
-- ⚙️ KONFIGURASI & STATE
-- =========================================================================
local CONFIG = {
    GoodKeywords = {"secret", "eternal", "divine", "mythic", "legendary"},
    SafeZoneKeyword = "zona aman",
    StealDelay = 0.4
}

local State = {
    AutoSteal = false,
    AutoSafeZone = true,
    AutoClaim = false,
    AutoUpgrade = false,
    IsProcessing = false,
    ActiveEggs = {},
    LastPos = Vector3.zero
}

-- =========================================================================
-- HELPER UI (Desain Kota Minimalis)
-- =========================================================================
local C = {
    BG      = Color3.fromRGB(20, 20, 24),
    PANEL   = Color3.fromRGB(28, 28, 34),
    BOX     = Color3.fromRGB(18, 18, 20),
    TEXT    = Color3.fromRGB(240, 240, 240),
    DIM     = Color3.fromRGB(150, 150, 160),
    ACCENT  = Color3.fromRGB(90, 90, 255),
    GREEN   = Color3.fromRGB(100, 220, 150),
    RED     = Color3.fromRGB(240, 80, 80),
    BORDER  = Color3.fromRGB(50, 50, 60)
}

local function create(cls, props)
    local obj = Instance.new(cls)
    for k, v in pairs(props) do if k ~= "Parent" then obj[k] = v end end
    if props.Parent then obj.Parent = props.Parent end
    return obj
end

local function addCorner(parent, r)
    return create("UICorner", { CornerRadius = UDim.new(0, r or 6), Parent = parent })
end

local function addStroke(parent, col)
    return create("UIStroke", { Color = col or C.BORDER, Thickness = 1, Parent = parent })
end

-- =========================================================================
-- 🧠 FUNGSI DETEKSI
-- =========================================================================
local function isBestEgg(obj)
    if not obj:IsA("BasePart") and not obj:IsA("Model") then return false end
    local lowerName = string.lower(obj.Name)
    for _, k in ipairs(CONFIG.GoodKeywords) do if string.find(lowerName, k) then return true end end
    
    local rarity = obj:GetAttribute("Rarity") or obj:GetAttribute("RarityName")
    if rarity then
        local lowerRarity = string.lower(tostring(rarity))
        for _, k in ipairs(CONFIG.GoodKeywords) do if string.find(lowerRarity, k) then return true end end
    end
    
    if obj:FindFirstChildOfClass("PointLight") or obj:FindFirstChildOfClass("Highlight") then return true end
    for _, v in ipairs(obj:GetChildren()) do
        if v:IsA("ParticleEmitter") or v:IsA("PointLight") then return true end
    end
    return false
end

-- =========================================================================
-- 🏃‍♂️ FUNGSI EKSEKUSI
-- =========================================================================
local function processEgg(egg)
    if State.IsProcessing then return end
    State.IsProcessing = true
    
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then State.IsProcessing = false return end
    local hrp = char.HumanoidRootPart
    local oldPos = hrp.CFrame
    
    print("[🔥 BEST EGG] Ditemukan: " .. egg.Name)
    hrp.CFrame = CFrame.new(egg.Position + Vector3.new(0, 2, 0))
    task.wait(0.2)
    
    local prompt = egg:FindFirstChildOfClass("ProximityPrompt") or egg:FindFirstChild("ProximityPrompt", true)
    if prompt then
        pcall(function() fireproximityprompt(prompt) end)
    else
        pcall(function()
            firetouchinterest(hrp, egg, 0)
            task.wait(0.1)
            firetouchinterest(hrp, egg, 1)
        end)
    end
    task.wait(0.1)
    hrp.CFrame = oldPos
    task.wait(0.2)
    
    -- Zona Aman
    if State.AutoSafeZone then
        local safeZone = nil
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") and string.find(string.lower(obj.Name), CONFIG.SafeZoneKeyword) then
                safeZone = obj
                break
            end
        end
        if safeZone then
            hrp.CFrame = CFrame.new(safeZone.Position + Vector3.new(0, 2, 0))
            task.wait(0.8)
            hrp.CFrame = oldPos
        end
    end
    State.IsProcessing = false
end

local function startAutoSteal()
    task.spawn(function()
        while State.AutoSteal do
            local bestEgg = nil
            local closestDist = 5000
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local myPos = char.HumanoidRootPart.Position
                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if isBestEgg(obj) then
                        local dist = (obj.Position - myPos).Magnitude
                        if dist < closestDist then bestEgg = obj; closestDist = dist end
                    end
                end
            end
            if bestEgg then processEgg(bestEgg) end
            task.wait(CONFIG.StealDelay)
        end
    end)
end

local function startAutoUpgrade()
    task.spawn(function()
        while State.AutoUpgrade do
            for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
                if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
                    local rName = string.lower(remote.Name)
                    if string.find(rName, "upgrade") or string.find(rName, "buy") then
                        pcall(function()
                            if remote:IsA("RemoteEvent") then remote:FireServer("Base") remote:FireServer("Treadmill") end
                            if remote:IsA("RemoteFunction") then remote:InvokeServer("Base") remote:InvokeServer("Treadmill") end
                        end)
                    end
                end
            end
            task.wait(2)
        end
    end)
end

-- =========================================================================
-- 🎨 BUILD GUI
-- =========================================================================
local function buildUI()
    local gui = create("ScreenGui", { Name = "KotaUI", ResetOnSpawn = false, Parent = CoreGui })
    
    -- Main Frame
    local main = create("Frame", { Size = UDim2.new(0, 280, 0, 300), Position = UDim2.new(0.5, -140, 0.5, -150), BackgroundColor3 = C.BG, BorderSizePixel = 0, Parent = gui })
    addCorner(main, 10); addStroke(main, C.BORDER)

    -- Header
    local header = create("Frame", { Size = UDim2.new(1, 0, 0, 40), BackgroundColor3 = C.PANEL, BorderSizePixel = 0, Parent = main })
    addCorner(header, 10)
    create("TextLabel", { Size = UDim2.new(1, -40, 1, 0), Position = UDim2.new(0, 15, 0, 0), BackgroundTransparency = 1, Text = "KEI SELVIM", TextColor3 = C.TEXT, Font = Enum.Font.GothamBold, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, Parent = header })
    
    local closeBtn = create("TextButton", { Size = UDim2.new(0, 24, 0, 24), Position = UDim2.new(1, -32, 0, 8), BackgroundColor3 = C.RED, Text = "✕", TextColor3 = C.TEXT, Font = Enum.Font.GothamBold, TextSize = 12, BorderSizePixel = 0, Parent = header })
    addCorner(closeBtn, 6)
    closeBtn.MouseButton1Click:Connect(function() gui:Destroy() end)

    -- Live Coordinate Display
    local coordBox = create("Frame", { Size = UDim2.new(1, -20, 0, 45), Position = UDim2.new(0, 10, 0, 50), BackgroundColor3 = C.BOX, BorderSizePixel = 0, Parent = main })
    addCorner(coordBox, 6); addStroke(coordBox, C.BORDER)
    
    local coordLbl = create("TextLabel", { Size = UDim2.new(1, -20, 1, 0), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1, Text = "📍 0.00, 0.00, 0.00", TextColor3 = C.DIM, Font = Enum.Font.Code, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, Parent = coordBox })

    -- Spawn Tracker Loop
    task.spawn(function()
        while gui.Parent do
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local pos = char.HumanoidRootPart.Position
                local status = (pos - State.LastPos).Magnitude > 2 and "🟢" or "🔴"
                
                -- FORMAT: 2 angka di belakang koma (Contoh: -87.02, 3.75, -180.10)
                coordLbl.Text = string.format("%s %.2f, %.2f, %.2f", status, pos.X, pos.Y, pos.Z)
                
                State.LastPos = pos
            end
            task.wait(0.2)
        end
    end)

    -- Fitur Toggles
    local features = {
        { text = "Auto Steal (Best Egg)", state = "AutoSteal", func = startAutoSteal, y = 110 },
        { text = "Auto Safe Zone (Klaim)", state = "AutoSafeZone", y = 150, defaultOn = true },
        { text = "Auto Upgrade Base", state = "AutoUpgrade", func = startAutoUpgrade, y = 190 },
    }

    for _, f in ipairs(features) do
        local row = create("Frame", { Size = UDim2.new(1, -20, 0, 30), Position = UDim2.new(0, 10, 0, f.y), BackgroundTransparency = 1, Parent = main })
        create("TextLabel", { Size = UDim2.new(0.7, 0, 1, 0), BackgroundTransparency = 1, Text = f.text, TextColor3 = C.TEXT, Font = Enum.Font.Gotham, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, Parent = row })
        
        local btn = create("TextButton", { Size = UDim2.new(0, 45, 0, 24), Position = UDim2.new(1, -45, 0, 3), BackgroundColor3 = f.defaultOn and C.GREEN or C.BOX, Text = f.defaultOn and "ON" or "OFF", TextColor3 = C.TEXT, Font = Enum.Font.GothamBold, TextSize = 11, BorderSizePixel = 0, Parent = row })
        addCorner(btn, 6); addStroke(btn, C.BORDER)
        
        btn.MouseButton1Click:Connect(function()
            State[f.state] = not State[f.state]
            btn.Text = State[f.state] and "ON" or "OFF"
            btn.BackgroundColor3 = State[f.state] and C.GREEN or C.BOX
            if State[f.state] and f.func then f.func() end
        end)
    end

    -- Footer Info
    create("TextLabel", { Size = UDim2.new(1, -20, 0, 30), Position = UDim2.new(0, 10, 1, -40), BackgroundTransparency = 1, Text = "Script by Kei Selvim", TextColor3 = C.DIM, Font = Enum.Font.Gotham, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Center, Parent = main })

    -- Drag Logic
    local dragging, dragStart, startPos
    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = main.Position
        end
    end)
    header.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local d = input.Position - dragStart
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
end

-- =========================================================================
-- EVENT LISTENER
-- =========================================================================
Workspace.DescendantAdded:Connect(function(obj)
    if State.IsProcessing or not State.AutoSteal then return end
    if isBestEgg(obj) then
        if not State.ActiveEggs[obj] then
            State.ActiveEggs[obj] = true
            task.spawn(function()
                processEgg(obj)
                State.ActiveEggs[obj] = nil
            end)
        end
    end
end)

-- JALANKAN UI
task.wait(1)
local success, err = pcall(buildUI)
if not success then warn("[Kota UI] Error: " .. tostring(err)) end
