--[[
    ╔══════════════════════════════════════════════════════════════════════╗
    ║           KEI SELVIM — AUTO STEAL TOUCH METHOD (100% WORK)           ║
    ║           Auto Glowing Egg • Auto Claim • Upgrades • Treadmill       ║
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
    -- Nama remote buat klaim index & upgrade (kalau ada)
    ClaimIndexRemote = "ClaimIndex",
    UpgradeRemote = "UpgradeBase",
    
    -- Jarak deteksi telur (stud)
    SearchRadius = 1000,
    
    -- Kecepatan loop (detik)
    StealDelay = 0.2
}

local State = {
    AutoSteal = false,
    AutoClaim = false,
    AutoUpgrade = false,
    AutoTreadmill = false,
}

-- =========================================================================
-- HELPER UI
-- =========================================================================
local function create(cls, props)
    local obj = Instance.new(cls)
    for k, v in pairs(props) do if k ~= "Parent" then obj[k] = v end end
    if props.Parent then obj.Parent = props.Parent end
    return obj
end

local function addCorner(parent, r)
    return create("UICorner", { CornerRadius = UDim.new(0, r or 8), Parent = parent })
end

local function fireRemote(remoteName, ...)
    local remote = ReplicatedStorage:FindFirstChild(remoteName, true)
    if remote then
        if remote:IsA("RemoteEvent") then remote:FireServer(...) end
        if remote:IsA("RemoteFunction") then remote:InvokeServer(...) end
    end
end

-- =========================================================================
-- LOGIKA UTAMA
-- =========================================================================

-- Fungsi ngecek apakah telur itu "Bagus" (Glowing / ada efek)
local function isBestEgg(egg)
    if egg:FindFirstChildOfClass("PointLight") or egg:FindFirstChildOfClass("SpotLight") then return true end
    if egg:FindFirstChildOfClass("Highlight") or egg:FindFirstChildOfClass("Sparkles") then return true end
    if egg:FindFirstChildOfClass("BillboardGui") then return true end
    local lower = string.lower(egg.Name)
    if string.find(lower, "secret") or string.find(lower, "mythic") or string.find(lower, "legendary") or string.find(lower, "god") or string.find(lower, "divine") then
        return true
    end
    return false
end

-- Metode "Touch Interest" (Paling ampuh buat ngambil item)
local function touchEgg(egg)
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    
    local oldPos = char.HumanoidRootPart.CFrame
    
    -- 1. Teleport ke telur
    char.HumanoidRootPart.CFrame = CFrame.new(egg.Position + Vector3.new(0, 2, 0))
    task.wait(0.1)
    
    -- 2. Metode Touch (Tempel karakter ke telur)
    local success = pcall(function()
        firetouchinterest(char.HumanoidRootPart, egg, 0) -- Touch (Press)
        task.wait(0.05)
        firetouchinterest(char.HumanoidRootPart, egg, 1) -- Untouch (Release)
    end)
    
    -- 3. Metode ProximityPrompt (Kalau game pakai tombol "E")
    if not success then
        local prompt = egg:FindFirstChildOfClass("ProximityPrompt")
        if prompt then
            pcall(function()
                fireproximityprompt(prompt)
            end)
        end
    end
    
    -- 4. Metode Remote (Cadangan)
    if not success then
        pcall(function() fireRemote("StealEgg", egg) end)
    end
    
    task.wait(0.1)
    -- 5. Balik ke posisi awal
    char.HumanoidRootPart.CFrame = oldPos
end

local function startAutoSteal()
    task.spawn(function()
        while State.AutoSteal do
            local bestEgg = nil
            local shortestDist = CONFIG.SearchRadius
            
            local myPos = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character.HumanoidRootPart.Position
            
            -- Scan semua telur di map
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj:IsA("BasePart") and string.find(string.lower(obj.Name), "egg") then
                    if isBestEgg(obj) then
                        local dist = myPos and (obj.Position - myPos).Magnitude or 0
                        if dist < shortestDist then
                            bestEgg = obj
                            shortestDist = dist
                        end
                    end
                end
            end
            
            -- Eksekusi
            if bestEgg then
                touchEgg(bestEgg)
            end
            
            task.wait(CONFIG.StealDelay)
        end
    end)
end

local function startAutoClaim()
    task.spawn(function()
        while State.AutoClaim do
            fireRemote(CONFIG.ClaimIndexRemote)
            task.wait(2)
        end
    end)
end

local function startAutoUpgrade()
    task.spawn(function()
        while State.AutoUpgrade do
            fireRemote(CONFIG.UpgradeRemote, "Base")
            fireRemote(CONFIG.UpgradeRemote, "Treadmill")
            task.wait(2)
        end
    end)
end

local function startAutoTreadmill()
    task.spawn(function()
        while State.AutoTreadmill do
            -- Biasanya game naruh telur ke treadmill otomatis kalau kita nyentuh areanya
            local treadmill = Workspace:FindFirstChild("Treadmill", true)
            if treadmill and LocalPlayer.Character then
                pcall(function()
                    firetouchinterest(LocalPlayer.Character.HumanoidRootPart, treadmill, 0)
                    task.wait(0.1)
                    firetouchinterest(LocalPlayer.Character.HumanoidRootPart, treadmill, 1)
                end)
            end
            task.wait(3)
        end
    end)
end

-- =========================================================================
-- BUILD UI
-- =========================================================================
local function buildUI()
    local gui = create("ScreenGui", { Name = "AutoStealTouch", ResetOnSpawn = false, Parent = CoreGui })
    local main = create("Frame", { Size = UDim2.new(0, 300, 0, 260), Position = UDim2.new(0.5, -150, 0.5, -130), BackgroundColor3 = Color3.fromRGB(25, 25, 30), BorderSizePixel = 0, Parent = gui })
    addCorner(main, 12)
    create("UIStroke", { Color = Color3.fromRGB(150, 80, 240), Thickness = 1.5, Parent = main })

    create("TextLabel", { Size = UDim2.new(1, 0, 0, 40), BackgroundColor3 = Color3.fromRGB(35, 35, 45), Text = "⚡ AUTO STEAL (TOUCH)", TextColor3 = Color3.fromRGB(255, 255, 255), Font = Enum.Font.GothamBold, TextSize = 14, BorderSizePixel = 0, Parent = main })
    
    local closeBtn = create("TextButton", { Size = UDim2.new(0, 30, 0, 30), Position = UDim2.new(1, -35, 0, 5), BackgroundColor3 = Color3.fromRGB(240, 80, 80), Text = "✕", TextColor3 = Color3.fromRGB(255,255,255), Font = Enum.Font.GothamBold, BorderSizePixel = 0, Parent = main })
    addCorner(closeBtn, 6)
    closeBtn.MouseButton1Click:Connect(function() gui:Destroy() end)

    local features = {
        { text = "Auto Steal Glowing Egg", state = "AutoSteal", func = startAutoSteal },
        { text = "Auto Claim Index", state = "AutoClaim", func = startAutoClaim },
        { text = "Auto Upgrade Base", state = "AutoUpgrade", func = startAutoUpgrade },
        { text = "Auto Treadmill", state = "AutoTreadmill", func = startAutoTreadmill },
    }

    for i, f in ipairs(features) do
        local y = 55 + (i-1)*45
        create("TextLabel", { Size = UDim2.new(0.7, 0, 0, 30), Position = UDim2.new(0, 15, 0, y), BackgroundTransparency = 1, Text = f.text, TextColor3 = Color3.fromRGB(220, 220, 220), Font = Enum.Font.Gotham, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, Parent = main })
        
        local btn = create("TextButton", { Size = UDim2.new(0, 50, 0, 26), Position = UDim2.new(1, -65, 0, y+2), BackgroundColor3 = Color3.fromRGB(50, 50, 65), Text = "OFF", TextColor3 = Color3.fromRGB(255,255,255), Font = Enum.Font.GothamBold, TextSize = 11, BorderSizePixel = 0, Parent = main })
        addCorner(btn, 6)
        
        btn.MouseButton1Click:Connect(function()
            State[f.state] = not State[f.state]
            btn.Text = State[f.state] and "ON" or "OFF"
            btn.BackgroundColor3 = State[f.state] and Color3.fromRGB(100, 220, 150) or Color3.fromRGB(50, 50, 65)
            btn.TextColor3 = State[f.state] and Color3.fromRGB(0,0,0) or Color3.fromRGB(255,255,255)
            if State[f.state] then f.func() end
        end)
    end

    -- Drag
    local dragging, dragStart, startPos
    main.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = main.Position
        end
    end)
    main.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local d = input.Position - dragStart
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
end

-- JALANKAN
task.wait(1)
local success, err = pcall(buildUI)
if not success then warn("[AutoSteal] UI Error: " .. tostring(err)) end
