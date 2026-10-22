--[[
    ╔══════════════════════════════════════════════════════════════════════╗
    ║           KEI SELVIM — AUTO STEAL GLOWING (100% WORK)                ║
    ║           Prompt Bypass • Anti-Rubberband • Glow Detection           ║
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
    SearchRadius = 3000, -- Jarak scan maksimal
    StealDelay = 0.3,
    -- Nama Zona (bisa lo tambahin)
    Zones = {
        "Terumbu karang yang disinari matahari", "lagun mutiara", "terumbu karang", 
        "parit alga", "bank hiu", "jurang hitam", "reaktor yang tenggelam", 
        "kedalaman gula", "gunung berapi", "celestial"
    }
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

-- =========================================================================
-- LOGIKA DETEKSI BEST EGG (PUNYA CAHAYA)
-- =========================================================================
local function isEgg(obj)
    if not obj:IsA("BasePart") then return false end
    local n = string.lower(obj.Name)
    return string.find(n, "egg") or string.find(n, "telur")
end

-- Cek apakah telur punya glow (cahaya, partikel, atau teks menyala)
local function isGlowing(egg)
    -- 1. Cek lampu di dalam part
    if egg:FindFirstChildOfClass("PointLight") or egg:FindFirstChildOfClass("SpotLight") or egg:FindFirstChildOfClass("SurfaceLight") then return true end
    -- 2. Cek efek partikel
    if egg:FindFirstChildOfClass("Sparkles") or egg:FindFirstChildOfClass("ParticleEmitter") or egg:FindFirstChildOfClass("Trail") then return true end
    -- 3. Cek Highlight (Outline)
    if egg:FindFirstChildOfClass("Highlight") then return true end
    -- 4. Cek Decal/Texture yang namanya ada "glow" atau "aura"
    for _, v in ipairs(egg:GetDescendants()) do
        if v:IsA("Decal") or v:IsA("Texture") then
            local vn = string.lower(v.Name)
            if string.find(vn, "glow") or string.find(vn, "aura") or string.find(vn, "shine") then return true end
        end
    end
    -- 5. Cek nama telur (kalau ada rarity)
    local lower = string.lower(egg.Name)
    if string.find(lower, "secret") or string.find(lower, "mythic") or string.find(lower, "legendary") or string.find(lower, "god") or string.find(lower, "divine") then return true end
    
    return false
end

-- =========================================================================
-- LOGIKA EKSEKUSI (ANTI GAGAL)
-- =========================================================================
local function takeEgg(egg)
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char.HumanoidRootPart
    
    -- Simpan posisi awal
    local oldPos = hrp.CFrame
    
    -- 1. ANCHOR / KUNCI KARAKTER (Biar ga ditarik anti-cheat)
    hrp.Anchored = true
    
    -- 2. Teleport Nempel ke Telur
    hrp.CFrame = CFrame.new(egg.Position + Vector3.new(0, 1, 0))
    task.wait(0.15) -- Jeda bentar biar server sadar kita di sana
    
    -- 3. EKSEKUSI PROMPT / TOUCH
    local prompt = egg:FindFirstChildOfClass("ProximityPrompt") or egg:FindFirstChild("ProximityPrompt", true)
    
    if prompt then
        -- Nembak tombol "Curi"
        pcall(function() fireproximityprompt(prompt) end)
    else
        -- Kalau ga ada prompt, paksa sentuh
        pcall(function()
            firetouchinterest(hrp, egg, 0)
            task.wait(0.05)
            firetouchinterest(hrp, egg, 1)
        end)
    end
    
    task.wait(0.1)
    
    -- 4. BALIK KE POSISI AWAL & LEPAS ANCHOR
    hrp.CFrame = oldPos
    hrp.Anchored = false
end

-- =========================================================================
-- LOOP AUTO STEAL
-- =========================================================================
local function startAutoSteal()
    task.spawn(function()
        while State.AutoSteal do
            local bestEgg = nil
            local bestEggIsGlowing = false
            local closestDist = CONFIG.SearchRadius
            
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local myPos = char.HumanoidRootPart.Position
                
                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if isEgg(obj) then
                        local dist = (obj.Position - myPos).Magnitude
                        local glowing = isGlowing(obj)
                        
                        -- Prioritas: Ambil yang glowing meskipun jauh, kalau ga ada baru ambil yang deket
                        if glowing and not bestEggIsGlowing then
                            bestEgg = obj
                            bestEggIsGlowing = true
                            closestDist = dist
                        elseif glowing == bestEggIsGlowing then
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
-- FITUR LAIN (Claim & Upgrade)
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

local function startAutoClaim()
    task.spawn(function()
        while State.AutoClaim do
            for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
                if remote.Name:lower():find("claim") or remote.Name:lower():find("index") then
                    pcall(function()
                        if remote:IsA("RemoteEvent") then remote:FireServer() end
                        if remote:IsA("RemoteFunction") then remote:InvokeServer() end
                    end)
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
    local gui = create("ScreenGui", { Name = "AutoStealGlow", ResetOnSpawn = false, Parent = CoreGui })
    local main = create("Frame", { Size = UDim2.new(0, 320, 0, 300), Position = UDim2.new(0.5, -160, 0.5, -150), BackgroundColor3 = Color3.fromRGB(25, 25, 30), BorderSizePixel = 0, Parent = gui })
    addCorner(main, 12)
    create("UIStroke", { Color = Color3.fromRGB(150, 80, 240), Thickness = 1.5, Parent = main })

    create("TextLabel", { Size = UDim2.new(1, 0, 0, 40), BackgroundColor3 = Color3.fromRGB(35, 35, 45), Text = "⚡ AUTO STEAL (GLOW FIX)", TextColor3 = Color3.fromRGB(255, 255, 255), Font = Enum.Font.GothamBold, TextSize = 14, BorderSizePixel = 0, Parent = main })
    
    local closeBtn = create("TextButton", { Size = UDim2.new(0, 30, 0, 30), Position = UDim2.new(1, -35, 0, 5), BackgroundColor3 = Color3.fromRGB(240, 80, 80), Text = "✕", TextColor3 = Color3.fromRGB(255,255,255), Font = Enum.Font.GothamBold, BorderSizePixel = 0, Parent = main })
    addCorner(closeBtn, 6)
    closeBtn.MouseButton1Click:Connect(function() gui:Destroy() end)

    local features = {
        { text = "Auto Steal (Prioritas Cahaya)", state = "AutoSteal", func = startAutoSteal },
        { text = "Auto Claim Index", state = "AutoClaim", func = startAutoClaim },
        { text = "Auto Upgrade Base", state = "AutoUpgrade", func = startAutoUpgrade },
    }

    for i, f in ipairs(features) do
        local y = 55 + (i-1)*50
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

    -- Info Teks
    create("TextLabel", { Size = UDim2.new(1, -30, 0, 40), Position = UDim2.new(0, 15, 0, 210), BackgroundTransparency = 1, Text = "Script ini otomatis nyari telur yang ada efek menyala (Glow) & nembak tombol 'Curi' (Prompt Bypass).", TextColor3 = Color3.fromRGB(150,150,160), Font = Enum.Font.Gotham, TextSize = 10, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, Parent = main })

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
