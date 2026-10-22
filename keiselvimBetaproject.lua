--[[
    ╔══════════════════════════════════════════════════════════════════════╗
    ║           KEI SELVIM — OMNIPOTENT EXPLOIT HUB v10.0                  ║
    ║           Failover Methods (TP -> ZigZag -> Fly) + 0.9ms Delay       ║
    ╚══════════════════════════════════════════════════════════════════════╝
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer or Players:GetPropertyChangedSignal("LocalPlayer"):Wait() or Players.LocalPlayer

-- =========================================================================
-- ⚙️ STATE & CONFIG
-- =========================================================================
local State = {
    isAutoStealing = false,
    SpyRemote = nil,
    SpyArgs = nil,
    SpyActive = false,
    OriginalPos = nil,
    currentMethod = "Teleport" -- Default
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
    GOLD     = Color3.fromRGB(255, 200, 60),
}

-- =========================================================================
-- HELPER
-- =========================================================================
local function create(cls, props)
    local obj = Instance.new(cls)
    for k, v in pairs(props) do if k ~= "Parent" then obj[k] = v end end
    if props.Parent then obj.Parent = props.Parent end
    return obj
end

local function log(msg) print("[KeiExploit] " .. msg) end

-- =========================================================================
-- SISTEM FAILOVER (METODE BERLAPIS)
-- =========================================================================

-- Metode 1: Teleport Instan
local function methodTeleport(targetPos)
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = CFrame.new(targetPos + Vector3.new(0, 3, 0))
        return true -- Anggap sukses
    end
    return false
end

-- Metode 2: Zig-Zag (Anti-Cheat Evasion)
local function methodZigZag(targetPos)
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local hrp = char.HumanoidRootPart
        local startPos = hrp.Position
        -- 3 Langkah Zig-Zag
        for i = 1, 3 do
            local offset = (i % 2 == 0) and Vector3.new(5, 0, 5) or Vector3.new(-5, 0, -5)
            hrp.CFrame = CFrame.new(startPos:Lerp(targetPos, i/3) + offset + Vector3.new(0, 3, 0))
            task.wait(0.0003) -- 0.3ms per step
        end
        hrp.CFrame = CFrame.new(targetPos + Vector3.new(0, 3, 0))
        return true
    end
    return false
end

-- Metode 3: Fly (BodyVelocity)
local flyBV, flyBG
local function methodFly(targetPos)
    local char = LocalPlayer.Character
    if not char then return false end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    
    -- Bersihin fly sebelumnya
    if flyBV then flyBV:Destroy() end
    if flyBG then flyBG:Destroy() end
    
    flyBV = Instance.new("BodyVelocity")
    flyBV.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    flyBV.Parent = hrp
    
    flyBG = Instance.new("BodyGyro")
    flyBG.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
    flyBG.Parent = hrp
    
    -- Terbang ke target dengan kecepatan tinggi
    local dist = (targetPos - hrp.Position).Magnitude
    flyBV.Velocity = (targetPos - hrp.Position).Unit * math.min(dist * 2, 150)
    flyBG.CFrame = CFrame.new(hrp.Position, targetPos)
    
    task.wait(0.0003) -- 0.3ms
    
    flyBV:Destroy()
    flyBG:Destroy()
    hrp.CFrame = CFrame.new(targetPos + Vector3.new(0, 3, 0))
    return true
end

-- FUNGSI EKSEKUSI UTAMA (Dengan Auto-Retry)
local function executeSteal(targetEgg)
    if not State.SpyRemote then
        log("⚠️ Remote belum direkam! Lakukan 'Mulai Rekam' dan curi manual 1x.")
        return false
    end

    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return false end
    local hrp = char.HumanoidRootPart
    
    -- Simpan posisi awal
    State.OriginalPos = hrp.CFrame
    
    -- Kunci posisi biar ga jatuh
    hrp.Anchored = true

    local success = false
    local targetPos = targetEgg.Position
    
    -- LOGIKA FAILOVER: TP -> ZigZag -> Fly
    -- (Kalo mau maksa pake metode tertentu, tinggal ganti State.currentMethod)
    
    if State.currentMethod == "Teleport" then
        success = methodTeleport(targetPos)
        if not success then 
            log("TP gagal, pindah ke ZigZag...")
            success = methodZigZag(targetPos) 
        end
    elseif State.currentMethod == "ZigZag" then
        success = methodZigZag(targetPos)
        if not success then
            log("ZigZag gagal, pindah ke Fly...")
            success = methodFly(targetPos)
        end
    else
        success = methodFly(targetPos)
    end

    -- JEDA 0.9 MILIDETIK (Sesuai Request)
    task.wait(0.0009) 
    
    -- TEMBAK REMOTE
    local remoteSuccess, err = pcall(function()
        local newArgs = {}
        for i, arg in ipairs(State.SpyArgs) do
            if typeof(arg) == "Instance" and (arg:IsA("BasePart") or arg:IsA("Model")) then
                newArgs[i] = targetEgg
            else
                newArgs[i] = arg
            end
        end
        
        if State.SpyRemote:IsA("RemoteEvent") then
            State.SpyRemote:FireServer(unpack(newArgs))
        else
            State.SpyRemote:InvokeServer(unpack(newArgs))
        end
    end)

    if not remoteSuccess then log("❌ Gagal eksekusi remote: " .. tostring(err)) end
    
    -- Jeda bentar buat memastikan telur keambil
    task.wait(0.0009)
    
    -- BALIK KE POSISI ASLI & LEPAS ANCHOR
    hrp.CFrame = State.OriginalPos
    hrp.Anchored = false
    
    return remoteSuccess
end

-- =========================================================================
-- UI: EGG SCANNER & STEAL
-- =========================================================================
local function getEggInfo(eggPart)
    local name = eggPart.Name
    local image = "rbxassetid://0"
    local price = "0"
    
    -- Cari Gambar
    for _, v in ipairs(eggPart:GetDescendants()) do
        if v:IsA("Decal") or v:IsA("Texture") then image = v.Texture; break
        elseif v:IsA("BillboardGui") and v:FindFirstChild("ImageLabel") then image = v.ImageLabel.Image; break end
    end
    
    -- Cari Harga (Attribute atau tebakan nama)
    local val = eggPart:GetAttribute("Price") or eggPart:GetAttribute("Value") or eggPart:GetAttribute("Cost")
    if val then price = tostring(val) else
        local num = string.match(name, "%d+[kKmM]?")
        if num then price = num end
    end
    
    return name, image, price
end

local function openEggIndexUI()
    local eggList = {}
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and (string.find(string.lower(obj.Name), "egg") or string.find(string.lower(obj.Name), "bok")) then
            local name, img, price = getEggInfo(obj)
            table.insert(eggList, {name = name, img = img, price = price, part = obj})
        end
    end
    
    local parent = CoreGui
    if gethui then local ok, hui = pcall(gethui); if ok and hui then parent = hui end end
    
    local gui = create("ScreenGui", { Name = "EggIndexUI", ResetOnSpawn = false, DisplayOrder = 1000, Parent = parent })
    local frame = create("Frame", { Size = UDim2.new(0, 450, 0, 400), Position = UDim2.new(0.5, -225, 0.5, -200), BackgroundColor3 = C.BG, BorderSizePixel = 0, Parent = gui })
    create("UICorner", { CornerRadius = UDim.new(0, 10), Parent = frame })
    
    create("TextLabel", { Size = UDim2.new(1, 0, 0, 40), BackgroundColor3 = C.HEADER, Text = "🥚 EGG SCANNER (INSTANT STEAL)", TextColor3 = C.TEXT, Font = Enum.Font.GothamBold, TextSize = 14, BorderSizePixel = 0, Parent = frame })
    
    local btnClose = create("TextButton", { Size = UDim2.new(0, 40, 0, 40), Position = UDim2.new(1, -40, 0, 0), BackgroundColor3 = C.RED, Text = "X", TextColor3 = C.TEXT, Font = Enum.Font.GothamBold, Parent = frame })
    btnClose.MouseButton1Click:Connect(function() gui:Destroy() end)
    
    local scroll = create("ScrollingFrame", { Size = UDim2.new(1, -20, 1, -60), Position = UDim2.new(0, 10, 0, 50), BackgroundTransparency = 1, CanvasSize = UDim2.new(0, 0, 0, #eggList * 60), Parent = frame })
    create("UIListLayout", { Padding = UDim.new(0, 5), Parent = scroll })
    
    for i, egg in ipairs(eggList) do
        local itemFrame = create("Frame", { Size = UDim2.new(1, 0, 0, 55), BackgroundColor3 = C.CARD, BorderSizePixel = 0, Parent = scroll })
        create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = itemFrame })
        
        local imgFrame = create("ImageLabel", { Size = UDim2.new(0, 40, 0, 40), Position = UDim2.new(0, 8, 0, 7), BackgroundColor3 = C.HEADER, Image = egg.img, Parent = itemFrame })
        create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = imgFrame })
        
        create("TextLabel", { Size = UDim2.new(0.6, 0, 0, 20), Position = UDim2.new(0, 55, 0, 8), BackgroundTransparency = 1, Text = egg.name, TextColor3 = C.TEXT, Font = Enum.Font.GothamBold, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, Parent = itemFrame })
        create("TextLabel", { Size = UDim2.new(0.6, 0, 0, 15), Position = UDim2.new(0, 55, 0, 30), BackgroundTransparency = 1, Text = "💰 " .. egg.price .. " Coins", TextColor3 = C.GREEN, Font = Enum.Font.Gotham, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, Parent = itemFrame })
        
        local btnSteal = create("TextButton", { Size = UDim2.new(0, 70, 0, 30), Position = UDim2.new(1, -80, 0, 12), BackgroundColor3 = C.BTN_ACT, Text = "STEAL", TextColor3 = C.TEXT, Font = Enum.Font.GothamBold, TextSize = 11, BorderSizePixel = 0, Parent = itemFrame })
        create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = btnSteal })
        
        btnSteal.MouseButton1Click:Connect(function()
            btnSteal.Text = "..."
            executeSteal(egg.part)
            btnSteal.Text = "DONE"
            task.wait(0.5)
            btnSteal.Text = "STEAL"
        end)
    end
end

-- =========================================================================
-- UI UTAMA
-- =========================================================================
local function buildUI()
    local parent = CoreGui
    if gethui then local ok, hui = pcall(gethui); if ok and hui then parent = hui end end

    local gui = create("ScreenGui", { Name = "UltimateExploitUI", ResetOnSpawn = false, IgnoreGuiInset = true, DisplayOrder = 999, Parent = parent })
    local main = create("Frame", { Size = UDim2.new(0, 480, 0, 320), Position = UDim2.new(0.5, -240, 0.5, -160), BackgroundColor3 = C.BG, BorderSizePixel = 0, Active = true, Parent = gui })
    create("UICorner", { CornerRadius = UDim.new(0, 12), Parent = main })

    local header = create("Frame", { Size = UDim2.new(1, 0, 0, 45), BackgroundColor3 = C.HEADER, BorderSizePixel = 0, Active = true, Parent = main })
    create("UICorner", { CornerRadius = UDim.new(0, 12), Parent = header })
    create("TextLabel", { Size = UDim2.new(1, -20, 1, 0), Position = UDim2.new(0, 15, 0, 0), BackgroundTransparency = 1, Text = "⚡ HUB v10.0 — 0.9ms Steal", TextColor3 = C.TEXT, Font = Enum.Font.GothamBold, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, Parent = header })
    
    local closeBtn = create("TextButton", { Size = UDim2.new(0, 30, 0, 30), Position = UDim2.new(1, -40, 0, 7), BackgroundColor3 = C.RED, Text = "X", TextColor3 = C.TEXT, Font = Enum.Font.GothamBold, TextSize = 14, BorderSizePixel = 0, Parent = header })
    create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = closeBtn })
    closeBtn.MouseButton1Click:Connect(function() gui:Destroy() end)

    local content = create("Frame", { Size = UDim2.new(1, -30, 1, -65), Position = UDim2.new(0, 15, 0, 55), BackgroundColor3 = C.CONTENT, BorderSizePixel = 0, Parent = main })
    create("UICorner", { CornerRadius = UDim.new(0, 10), Parent = content })

    -- Rekam Remote
    create("TextLabel", { Size = UDim2.new(1, -20, 0, 40), Position = UDim2.new(0, 15, 0, 10), BackgroundTransparency = 1, Text = "1. Klik Rekam, lalu curi manual 1x.\n2. Klik Buka Egg Index, lalu tekan Steal.", TextColor3 = C.GOLD, Font = Enum.Font.Gotham, TextSize = 11, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, Parent = content })

    local btnSpy = create("TextButton", { Size = UDim2.new(1, -30, 0, 35), Position = UDim2.new(0, 15, 0, 60), BackgroundColor3 = C.BTN_ACT, Text = "📡 MULAI REKAM REMOTE", TextColor3 = C.TEXT, Font = Enum.Font.GothamBold, TextSize = 12, BorderSizePixel = 0, Parent = content })
    create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = btnSpy })
    
    local lblStatus = create("TextLabel", { Size = UDim2.new(1, -30, 0, 20), Position = UDim2.new(0, 15, 0, 100), BackgroundTransparency = 1, Text = "Status: Belum Direkam", TextColor3 = C.RED, Font = Enum.Font.GothamBold, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, Parent = content })

    btnSpy.MouseButton1Click:Connect(function()
        -- Setup Spy
        State.SpyActive = true
        State.SpyRemote = nil
        local oldNamecall
        oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
            local method = getnamecallmethod()
            local args = {...}
            if State.SpyActive and (method == "FireServer" or method == "InvokeServer") then
                local n = string.lower(self.Name)
                if string.find(n, "steal") or string.find(n, "take") or string.find(n, "egg") then
                    State.SpyRemote = self
                    State.SpyArgs = args
                    State.SpyActive = false
                    lblStatus.Text = "Status: ✅ Rekaman Sukses! ("..self.Name..")"
                    lblStatus.TextColor3 = C.GREEN
                    btnSpy.Text = "✅ REMOTE TERKUNCI"
                    btnSpy.BackgroundColor3 = C.GREEN
                end
            end
            return oldNamecall(self, ...)
        end))
        
        btnSpy.Text = "🔴 MEREKAM... (Curi Manual)"
        btnSpy.BackgroundColor3 = C.RED
        lblStatus.Text = "Status: Menunggu interaksi Remote..."
        lblStatus.TextColor3 = C.GOLD
    end)

    -- Buka Index
    local btnIndex = create("TextButton", { Size = UDim2.new(1, -30, 0, 45), Position = UDim2.new(0, 15, 0, 140), BackgroundColor3 = C.GREEN, Text = "🥚 BUKA EGG INDEX & STEAL", TextColor3 = Color3.new(0,0,0), Font = Enum.Font.GothamBold, TextSize = 14, BorderSizePixel = 0, Parent = content })
    create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = btnIndex })
    btnIndex.MouseButton1Click:Connect(openEggIndexUI)

    -- Pilihan Metode
    create("TextLabel", { Size = UDim2.new(1, -20, 0, 20), Position = UDim2.new(0, 15, 0, 200), BackgroundTransparency = 1, Text = "Pilih Metode (Failover Otomatis):", TextColor3 = C.TEXT_DIM, Font = Enum.Font.Gotham, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, Parent = content })

    local methods = {"Teleport", "ZigZag", "Fly"}
    local methodBtns = {}
    for i, m in ipairs(methods) do
        local btn = create("TextButton", { Size = UDim2.new(0, 100, 0, 30), Position = UDim2.new(0, 15 + (i-1)*110, 0, 225), BackgroundColor3 = (m == "Teleport") and C.BTN_ACT or C.BTN_IDLE, Text = m, TextColor3 = C.TEXT, Font = Enum.Font.Gotham, TextSize = 12, BorderSizePixel = 0, Parent = content })
        create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = btn })
        methodBtns[m] = btn
        
        btn.MouseButton1Click:Connect(function()
            State.currentMethod = m
            for name, b in pairs(methodBtns) do
                b.BackgroundColor3 = (name == m) and C.BTN_ACT or C.BTN_IDLE
            end
        end)
    end

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
