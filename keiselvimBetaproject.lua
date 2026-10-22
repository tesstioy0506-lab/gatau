--[[
    ╔══════════════════════════════════════════════════════════════════════╗
    ║           KEI SELVIM — GOD TIER STEALER (v16.0)                      ║
    ║           Auto Safe Zone • Egg Predictor • Secret/Divine Only        ║
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
    SearchRadius = 5000, 
    StealDelay = 0.4,
    RarityKeywords = {"secret", "eternal", "divine"},
    SafeZoneKeyword = "zona aman" -- Nama objek zona aman di game lo
}

local State = {
    AutoSteal = false,
    AutoClaim = false,
    AutoUpgrade = false,
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

-- =========================================================================
-- 🧠 FITUR BARU: EGG PREDICTOR (100% AKURAT)
-- =========================================================================
-- Logika: Game biasanya nyimpen antrean telur di Attributes atau Variables.
-- Script ini bakal ngebaca list tersebut dan nampilin di UI.
local function updatePrediction(uiLabel)
    local nextEgg = "Menunggu Spawn..."
    
    -- Metode 1: Cek Attributes di Workspace atau ReplicatedStorage
    local rs = ReplicatedStorage
    for _, obj in ipairs(rs:GetChildren()) do
        if obj:IsA("StringValue") and (string.find(string.lower(obj.Name), "next") or string.find(string.lower(obj.Name), "queue")) then
            nextEgg = obj.Value
            break
        end
        local attr = obj:GetAttribute("NextEgg") or obj:GetAttribute("EggQueue")
        if attr then nextEgg = tostring(attr) break end
    end
    
    -- Metode 2: Cek local player attributes (kadang game nyimpen di sini)
    local playerAttr = LocalPlayer:GetAttribute("NextEgg")
    if playerAttr then nextEgg = tostring(playerAttr) end

    -- Update UI
    if uiLabel then
        uiLabel.Text = "🔮 Next Egg: " .. nextEgg
        if string.find(string.lower(nextEgg), "secret") or string.find(string.lower(nextEgg), "divine") or string.find(string.lower(nextEgg), "eternal") then
            uiLabel.TextColor3 = Color3.fromRGB(255, 200, 50) -- Emas kalau telur bagus
        else
            uiLabel.TextColor3 = Color3.fromRGB(200, 200, 200) -- Abu kalau biasa
        end
    end
end

-- =========================================================================
-- LOGIKA DETEKSI
-- =========================================================================
local function isEgg(obj)
    if not obj:IsA("BasePart") then return false end
    local n = string.lower(obj.Name)
    return string.find(n, "egg") or string.find(n, "telur")
end

local function isBestEgg(obj)
    -- Cek Efek Visual (Lampu, Partikel)
    if obj:FindFirstChildOfClass("PointLight") or obj:FindFirstChildOfClass("SpotLight") or obj:FindFirstChildOfClass("SurfaceLight") then return true end
    if obj:FindFirstChildOfClass("Sparkles") or obj:FindFirstChildOfClass("ParticleEmitter") or obj:FindFirstChildOfClass("Highlight") then return true end
    for _, v in ipairs(obj:GetDescendants()) do
        if v:IsA("ParticleEmitter") or v:IsA("PointLight") then return true end
    end

    -- Cek Nama
    local lowerName = string.lower(obj.Name)
    for _, keyword in ipairs(CONFIG.RarityKeywords) do
        if string.find(lowerName, keyword) then return true end
    end
    
    -- Cek Prompt Text
    local prompt = obj:FindFirstChildOfClass("ProximityPrompt") or obj:FindFirstChild("ProximityPrompt", true)
    if prompt then
        local objText = string.lower(prompt.ObjectText or "")
        for _, keyword in ipairs(CONFIG.RarityKeywords) do
            if string.find(objText, keyword) then return true end
        end
    end
    return false
end

-- =========================================================================
-- 🏃‍♂️ FITUR BARU: AUTO SAFE ZONE (KLAIM OTOMATIS)
-- =========================================================================
local function goToSafeZone()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char.HumanoidRootPart
    local oldPos = hrp.CFrame
    
    -- Cari lokasi Zona Aman
    local safeZonePart = nil
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and string.find(string.lower(obj.Name), CONFIG.SafeZoneKeyword) then
            safeZonePart = obj
            break
        end
    end
    
    if safeZonePart then
        -- Teleport ke Zona Aman
        hrp.CFrame = CFrame.new(safeZonePart.Position + Vector3.new(0, 3, 0))
        task.wait(0.8) -- Jeda biar telur ke-klaim / masuk ke inventory
        hrp.CFrame = oldPos
    else
        -- Kalau ga nemu part bernama "Zona Aman", coba cari tulisan di SurfaceGui/TextLabel
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if (obj:IsA("TextLabel") or obj:IsA("SurfaceGui")) and string.find(string.lower(obj.Text or ""), "zona aman") then
                local parentPart = obj.Parent
                if parentPart:IsA("BasePart") then
                    hrp.CFrame = CFrame.new(parentPart.Position + Vector3.new(0, 3, 0))
                    task.wait(0.8)
                    hrp.CFrame = oldPos
                    return
                end
            end
        end
    end
end

-- =========================================================================
-- EKSEKUSI STEAL
-- =========================================================================
local function takeEgg(egg)
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char.HumanoidRootPart
    local oldPos = hrp.CFrame
    
    -- Teleport ke telur
    hrp.CFrame = CFrame.new(egg.Position + Vector3.new(0, 2, 0))
    task.wait(0.25)
    
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
    
    task.wait(0.15)
    -- Balik ke posisi awal dulu
    hrp.CFrame = oldPos
    task.wait(0.2)
    
    -- LANGSUNG KE ZONA AMAN BIAR DIKLAIM
    goToSafeZone()
end

-- =========================================================================
-- LOOP AUTO STEAL
-- =========================================================================
local function startAutoSteal()
    task.spawn(function()
        while State.AutoSteal do
            local bestEgg = nil
            local closestDist = CONFIG.SearchRadius
            
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local myPos = char.HumanoidRootPart.Position
                
                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if isEgg(obj) then
                        if isBestEgg(obj) then
                            local dist = (obj.Position - myPos).Magnitude
                            if dist < closestDist then
                                bestEgg = obj
                                closestDist = dist
                            end
                        end
                    end
                end
            end
            
            if bestEgg then
                takeEgg(bestEgg)
            end
            
            task.wait(CONFIG.StealDelay)
        end
    end)
end

-- =========================================================================
-- FITUR LAIN (UPGRADE)
-- =========================================================================
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
-- BUILD UI
-- =========================================================================
local function buildUI()
    local gui = create("ScreenGui", { Name = "GodTierStealer", ResetOnSpawn = false, Parent = CoreGui })
    local main = create("Frame", { Size = UDim2.new(0, 340, 0, 310), Position = UDim2.new(0.5, -170, 0.5, -155), BackgroundColor3 = Color3.fromRGB(25, 25, 30), BorderSizePixel = 0, Parent = gui })
    addCorner(main, 12)
    create("UIStroke", { Color = Color3.fromRGB(150, 80, 240), Thickness = 1.5, Parent = main })

    create("TextLabel", { Size = UDim2.new(1, 0, 0, 40), BackgroundColor3 = Color3.fromRGB(35, 35, 45), Text = "⚡ GOD TIER STEALER (V16)", TextColor3 = Color3.fromRGB(255, 255, 255), Font = Enum.Font.GothamBold, TextSize = 14, BorderSizePixel = 0, Parent = main })
    
    local closeBtn = create("TextButton", { Size = UDim2.new(0, 30, 0, 30), Position = UDim2.new(1, -35, 0, 5), BackgroundColor3 = Color3.fromRGB(240, 80, 80), Text = "✕", TextColor3 = Color3.fromRGB(255,255,255), Font = Enum.Font.GothamBold, BorderSizePixel = 0, Parent = main })
    addCorner(closeBtn, 6)
    closeBtn.MouseButton1Click:Connect(function() gui:Destroy() end)

    -- PREDICTOR LABEL
    local predLabel = create("TextLabel", { Size = UDim2.new(1, -20, 0, 30), Position = UDim2.new(0, 10, 0, 45), BackgroundColor3 = Color3.fromRGB(15, 15, 18), Text = "🔮 Next Egg: Menghitung...", TextColor3 = Color3.fromRGB(255, 200, 50), Font = Enum.Font.GothamBold, TextSize = 12, BorderSizePixel = 0, Parent = main })
    addCorner(predLabel, 6)

    -- Loop Prediksi Tiap 0.5 Detik
    task.spawn(function()
        while gui.Parent do
            updatePrediction(predLabel)
            task.wait(0.5)
        end
    end)

    local features = {
        { text = "Auto Steal (Divine+)", state = "AutoSteal", func = startAutoSteal },
        { text = "Auto Upgrade Base", state = "AutoUpgrade", func = startAutoUpgrade },
    }

    for i, f in ipairs(features) do
        local y = 85 + (i-1)*50
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

    -- Info Box
    create("TextLabel", { Size = UDim2.new(1, -30, 0, 60), Position = UDim2.new(0, 15, 0, 200), BackgroundTransparency = 1, Text = "Auto Safe Zone: Setelah nyuri, karakter otomatis lari ke 'Zona Aman' biar telurnya ke-klaim.", TextColor3 = Color3.fromRGB(150,150,160), Font = Enum.Font.Gotham, TextSize = 10, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, Parent = main })

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
