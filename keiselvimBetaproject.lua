--[[
    ╔══════════════════════════════════════════════════════════════════════╗
    ║           KEI SELVIM — AUTO STEAL (GLOWING PRIORITY)                 ║
    ║           Fokus Cahaya/Highlight • Touch Bypass • Upgrades           ║
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
-- ⚙️ KONFIGURASI
-- =========================================================================
local CONFIG = {
    SearchRadius = 2000,
    StealDelay = 0.2,
    UpgradeNames = {"Base", "Treadmill", "Plot"},
    ClaimRemote = "ClaimIndex"
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
-- LOGIKA UTAMA: DETEKSI TELUR & CAHAYA
-- =========================================================================

-- 1. Cek apakah objek ini telur
local function isEgg(obj)
    if not obj:IsA("BasePart") then return false end
    local name = string.lower(obj.Name)
    return string.find(name, "egg") or (obj.Parent and string.find(string.lower(obj.Parent.Name), "egg"))
end

-- 2. Cek apakah telur ini "Glowing" (Prioritas Utama)
local function isGlowing(egg)
    -- Cek efek Partikel/Cahaya langsung di dalam part
    if egg:FindFirstChildOfClass("PointLight") or egg:FindFirstChildOfClass("SpotLight") or egg:FindFirstChildOfClass("Sparkles") then
        return true
    end
    if egg:FindFirstChildOfClass("Highlight") then
        return true
    end
    -- Cek BillboardGui (biasanya ada tulisan efek di atas telur)
    if egg:FindFirstChildOfClass("BillboardGui") then
        return true
    end
    
    -- Cek Nama Rarity (Kalau part-nya gak ada cahaya, tapi namanya ini)
    local lower = string.lower(egg.Name)
    if string.find(lower, "secret") or string.find(lower, "mythic") or string.find(lower, "legendary") or string.find(lower, "god") or string.find(lower, "divine") or string.find(lower, "shiny") then
        return true
    end
    
    -- Cek atribut di dalam game (kadang game nyimpen data "IsGlowing" atau "Shiny" di Attributes)
    local shinyAttr = egg:GetAttribute("Shiny") or egg:GetAttribute("Glowing") or egg:GetAttribute("IsShiny")
    if shinyAttr then return true end
    
    return false
end

-- 3. Fungsi Eksekusi Ambil Telur
local function takeEgg(egg)
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char.HumanoidRootPart
    local oldPos = hrp.CFrame
    
    -- Teleport tepat ke telur
    hrp.CFrame = CFrame.new(egg.Position)
    task.wait(0.1)
    
    -- Metode 1: FireTouchInterest
    pcall(function()
        firetouchinterest(hrp, egg, 0)
        task.wait(0.05)
        firetouchinterest(hrp, egg, 1)
    end)
    
    -- Metode 2: Proximity Prompt (Kalau pakai tombol E)
    local prompt = egg:FindFirstChildOfClass("ProximityPrompt")
    if not prompt then
        prompt = egg:FindFirstChild("ProximityPrompt", true)
    end
    if prompt then
        pcall(function() fireproximityprompt(prompt) end)
    end
    
    -- Metode 3: Remote Event (Tebakan)
    pcall(function()
        for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
            if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
                local rName = string.lower(remote.Name)
                if string.find(rName, "steal") or string.find(rName, "take") or string.find(rName, "collect") or string.find(rName, "pickup") then
                    if remote:IsA("RemoteEvent") then remote:FireServer(egg) end
                    if remote:IsA("RemoteFunction") then remote:InvokeServer(egg) end
                end
            end
        end
    end)
    
    task.wait(0.2)
    hrp.CFrame = oldPos
end

-- 4. Loop Auto Steal (PRIORITAS GLOWING)
local function startAutoSteal()
    task.spawn(function()
        while State.AutoSteal do
            local bestEgg = nil
            local bestEggIsGlowing = false
            local closestDist = CONFIG.SearchRadius
            
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local myPos = char.HumanoidRootPart.Position
                
                -- Scan seluruh workspace
                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if isEgg(obj) then
                        local dist = (obj.Position - myPos).Magnitude
                        
                        -- Cek apakah telur ini glowing/bagus
                        local glowing = isGlowing(obj)
                        
                        -- LOGIKA PRIORITAS:
                        -- Kalau nemu telur glowing, ambil ini, buang telur biasa yang udah di-incar
                        if glowing and not bestEggIsGlowing then
                            bestEgg = obj
                            bestEggIsGlowing = true
                            closestDist = dist
                        -- Kalau dua-duanya glowing ATAU dua-duanya biasa, ambil yang paling dekat
                        elseif glowing == bestEggIsGlowing then
                            if dist < closestDist then
                                bestEgg = obj
                                closestDist = dist
                            end
                        end
                    end
                end
            end
            
            -- Eksekusi
            if bestEgg then
                takeEgg(bestEgg)
            end
            
            task.wait(CONFIG.StealDelay)
        end
    end)
end

-- =========================================================================
-- FITUR LAINNYA
-- =========================================================================
local function startAutoUpgrade()
    task.spawn(function()
        while State.AutoUpgrade do
            for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
                if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
                    local rName = string.lower(remote.Name)
                    if string.find(rName, "upgrade") or string.find(rName, "buy") then
                        for _, name in ipairs(CONFIG.UpgradeNames) do
                            pcall(function()
                                if remote:IsA("RemoteEvent") then remote:FireServer(name) end
                                if remote:IsA("RemoteFunction") then remote:InvokeServer(name) end
                            end)
                        end
                    end
                end
            end
            task.wait(2)
        end
    end)
end

local function startAutoClaim()
    task.spawn(function()
        while State.AutoClaim do
            fireRemote(CONFIG.ClaimRemote)
            task.wait(2)
        end
    end)
end

local function startAutoTreadmill()
    task.spawn(function()
        while State.AutoTreadmill do
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local hrp = char.HumanoidRootPart
                local oldPos = hrp.CFrame
                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if obj:IsA("BasePart") and (string.find(string.lower(obj.Name), "treadmill") or string.find(string.lower(obj.Name), "conveyor")) then
                        hrp.CFrame = CFrame.new(obj.Position + Vector3.new(0, 3, 0))
                        task.wait(0.5)
                        break
                    end
                end
                hrp.CFrame = oldPos
            end
            task.wait(3)
        end
    end)
end

-- =========================================================================
-- BUILD UI
-- =========================================================================
local function buildUI()
    local gui = create("ScreenGui", { Name = "AutoStealGlow", ResetOnSpawn = false, Parent = CoreGui })
    local main = create("Frame", { Size = UDim2.new(0, 320, 0, 260), Position = UDim2.new(0.5, -160, 0.5, -130), BackgroundColor3 = Color3.fromRGB(25, 25, 30), BorderSizePixel = 0, Parent = gui })
    addCorner(main, 12)
    create("UIStroke", { Color = Color3.fromRGB(150, 80, 240), Thickness = 1.5, Parent = main })

    create("TextLabel", { Size = UDim2.new(1, 0, 0, 40), BackgroundColor3 = Color3.fromRGB(35, 35, 45), Text = "⚡ AUTO STEAL (GLOWING)", TextColor3 = Color3.fromRGB(255, 255, 255), Font = Enum.Font.GothamBold, TextSize = 14, BorderSizePixel = 0, Parent = main })
    
    local closeBtn = create("TextButton", { Size = UDim2.new(0, 30, 0, 30), Position = UDim2.new(1, -35, 0, 5), BackgroundColor3 = Color3.fromRGB(240, 80, 80), Text = "✕", TextColor3 = Color3.fromRGB(255,255,255), Font = Enum.Font.GothamBold, BorderSizePixel = 0, Parent = main })
    addCorner(closeBtn, 6)
    closeBtn.MouseButton1Click:Connect(function() gui:Destroy() end)

    local features = {
        { text = "Auto Steal (Prioritas Glowing)", state = "AutoSteal", func = startAutoSteal },
        { text = "Auto Claim Index", state = "AutoClaim", func = startAutoClaim },
        { text = "Auto Upgrade Base", state = "AutoUpgrade", func = startAutoUpgrade },
        { text = "Auto Treadmill", state = "AutoTreadmill", func = startAutoTreadmill },
    }

    for i, f in ipairs(features) do
        local y = 55 + (i-1)*45
        create("TextLabel", { Size = UDim2.new(0.75, 0, 0, 30), Position = UDim2.new(0, 15, 0, y), BackgroundTransparency = 1, Text = f.text, TextColor3 = Color3.fromRGB(220, 220, 220), Font = Enum.Font.Gotham, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, Parent = main })
        
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

task.wait(1)
local success, err = pcall(buildUI)
if not success then warn("[AutoSteal] UI Error: " .. tostring(err)) end
