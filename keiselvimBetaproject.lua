--[[
    ╔══════════════════════════════════════════════════════════════════════╗
    ║           KEI SELVIM — OMNIPOTENT EXPLOIT HUB v9.0                   ║
    ║           Auto-Extract Info + Remote Spy Stealer + Anti-Kick         ║
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
-- HELPER UI & LOG
-- =========================================================================
local function create(cls, props)
    local obj = Instance.new(cls)
    for k, v in pairs(props) do if k ~= "Parent" then obj[k] = v end end
    if props.Parent then obj.Parent = props.Parent end
    return obj
end

local function log(msg) print("[KeiExploit] " .. msg) end

-- =========================================================================
-- 1. ANTI-KICK & KICK INTERCEPTOR
-- =========================================================================
local function setupProtections()
    pcall(function()
        local oldIndex = getrawmetatable(StarterGui).__index
        setreadonly(getrawmetatable(StarterGui), false)
        getrawmetatable(StarterGui).__index = newcclosure(function(self, key, ...)
            if key == "SendNotification" then
                local args = {...}
                if args[1] and type(args[1]) == "table" then
                    local title = tostring(args[1].Title or ""):lower()
                    local text = tostring(args[1].Text or ""):lower()
                    if title:find("kick") or title:find("ban") or text:find("exploit") or text:find("cheat") then
                        args[1].Title = "🚫 SYSTEM OVERRIDE"
                        args[1].Text = "KAMU DI KICK OLEH MODERATORNYA! KAMU HARUS PERBAIKI, PAKE CELAH!"
                        oldIndex(self, key, args[1])
                        return nil
                    end
                end
            end
            return oldIndex(self, key, ...)
        end)
        setreadonly(getrawmetatable(StarterGui), true)
        log("Protection: AKTIF.")
    end)
end

-- =========================================================================
-- 2. REMOTE SPY (MEREKAM CARA NYURI)
-- =========================================================================
local function activateRemoteSpy()
    State.SpyActive = true
    State.SpyRemote = nil
    State.SpyArgs = nil
    
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        
        if State.SpyActive and (method == "FireServer" or method == "InvokeServer") then
            -- Anggap ini remote nyuri kalo namanya ada "steal" atau "take" atau "egg"
            local n = string.lower(self.Name)
            if string.find(n, "steal") or string.find(n, "take") or string.find(n, "egg") then
                State.SpyRemote = self
                State.SpyArgs = args
                State.SpyActive = false
                log("✅ Remote Nyuri Berhasil Direkam! Nama: " .. self.Name)
                
                -- Tampilkan ke UI
                local ui = CoreGui:FindFirstChild("SpyUI")
                if ui then
                    ui.TextLabel.Text = "✅ Remote Terekam: " .. self.Name .. " | Siap Auto Steal!"
                    ui.TextLabel.TextColor3 = C.GREEN
                end
            end
        end
        
        return oldNamecall(self, ...)
    end))
end

-- =========================================================================
-- 3. AUTO EXTRACT DATA TELUR (GAMBAR, HARGA, NAMA)
-- =========================================================================
local function getEggInfo(eggPart)
    local name = eggPart.Name
    local image = "rbxassetid://0"
    local price = "0"
    
    -- Cari Gambar (Decal / Texture / ImageLabel di dalem telur)
    for _, v in ipairs(eggPart:GetDescendants()) do
        if v:IsA("Decal") or v:IsA("Texture") then
            image = v.Texture
            break
        elseif v:IsA("BillboardGui") and v:FindFirstChild("ImageLabel") then
            image = v.ImageLabel.Image
            break
        end
    end
    
    -- Cari Harga / Value (Angka di dalem nama atau atribut)
    local val = eggPart:GetAttribute("Price") or eggPart:GetAttribute("Value") or eggPart:GetAttribute("Cost")
    if val then
        price = tostring(val)
    else
        -- Kalo ga ada atribut, coba tebak dari nama (misal "10k Egg")
        local num = string.match(name, "%d+[kKmM]?")
        if num then price = num end
    end
    
    return name, image, price
end

-- =========================================================================
-- 4. FUNGSI STEAL INSTAN (ANTI GAGAL)
-- =========================================================================
local function doInstantSteal(targetEgg)
    if not State.SpyRemote then
        log("⚠️ Kamu belum rekam Remote! Silakan nyuri manual 1x.")
        return
    end
    
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char.HumanoidRootPart
    
    -- 1. Simpan posisi asli
    State.OriginalPos = hrp.CFrame
    
    -- 2. Matikan anti-cheat fisik (fly/noclip bentar)
    hrp.Anchored = true
    
    -- 3. Teleport ke telur
    hrp.CFrame = CFrame.new(targetEgg.Position + Vector3.new(0, 3, 0))
    task.wait(0.15)
    
    -- 4. Tembak Remote Pake Argumen yang udah direkam
    local success, err = pcall(function()
        -- Trik: Ganti target argumen dengan telur baru
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
    
    if not success then log("❌ Gagal tembak remote: " .. tostring(err)) end
    
    task.wait(0.2)
    
    -- 5. Balik ke posisi asli & nyalain fisik
    hrp.CFrame = State.OriginalPos
    hrp.Anchored = false
end

-- =========================================================================
-- 5. UI: EGG INDEX (AUTO GENERATE)
-- =========================================================================
local function openEggIndexUI()
    local eggList = {}
    
    -- Scan semua telur di map
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and (string.find(string.lower(obj.Name), "egg") or string.find(string.lower(obj.Name), "bok")) then
            local name, img, price = getEggInfo(obj)
            table.insert(eggList, {name = name, img = img, price = price, part = obj})
        end
    end
    
    -- Bikin GUI
    local parent = CoreGui
    if gethui then local ok, hui = pcall(gethui); if ok and hui then parent = hui end end
    
    local gui = create("ScreenGui", { Name = "EggIndexUI", ResetOnSpawn = false, DisplayOrder = 1000, Parent = parent })
    local frame = create("Frame", { Size = UDim2.new(0, 450, 0, 400), Position = UDim2.new(0.5, -225, 0.5, -200), BackgroundColor3 = C.BG, BorderSizePixel = 0, Parent = gui })
    create("UICorner", { CornerRadius = UDim.new(0, 10), Parent = frame })
    
    create("TextLabel", { Size = UDim2.new(1, 0, 0, 40), BackgroundColor3 = C.HEADER, Text = "🥚 EGG SCANNER & STEALER", TextColor3 = C.TEXT, Font = Enum.Font.GothamBold, TextSize = 14, BorderSizePixel = 0, Parent = frame })
    
    local btnClose = create("TextButton", { Size = UDim2.new(0, 40, 0, 40), Position = UDim2.new(1, -40, 0, 0), BackgroundColor3 = C.RED, Text = "X", TextColor3 = C.TEXT, Font = Enum.Font.GothamBold, Parent = frame })
    btnClose.MouseButton1Click:Connect(function() gui:Destroy() end)
    
    local scroll = create("ScrollingFrame", { Size = UDim2.new(1, -20, 1, -60), Position = UDim2.new(0, 10, 0, 50), BackgroundTransparency = 1, CanvasSize = UDim2.new(0, 0, 0, #eggList * 60), Parent = frame })
    create("UIListLayout", { Padding = UDim.new(0, 5), Parent = scroll })
    
    for i, egg in ipairs(eggList) do
        local itemFrame = create("Frame", { Size = UDim2.new(1, 0, 0, 55), BackgroundColor3 = C.CARD, BorderSizePixel = 0, Parent = scroll })
        create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = itemFrame })
        
        -- Gambar Telur
        local imgFrame = create("ImageLabel", { Size = UDim2.new(0, 40, 0, 40), Position = UDim2.new(0, 8, 0, 7), BackgroundColor3 = C.HEADER, Image = egg.img, Parent = itemFrame })
        create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = imgFrame })
        
        -- Nama & Harga
        create("TextLabel", { Size = UDim2.new(0.6, 0, 0, 20), Position = UDim2.new(0, 55, 0, 8), BackgroundTransparency = 1, Text = egg.name, TextColor3 = C.TEXT, Font = Enum.Font.GothamBold, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, Parent = itemFrame })
        create("TextLabel", { Size = UDim2.new(0.6, 0, 0, 15), Position = UDim2.new(0, 55, 0, 30), BackgroundTransparency = 1, Text = "💰 " .. egg.price .. " Coins", TextColor3 = C.GREEN, Font = Enum.Font.Gotham, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, Parent = itemFrame })
        
        -- Tombol Steal
        local btnSteal = create("TextButton", { Size = UDim2.new(0, 70, 0, 30), Position = UDim2.new(1, -80, 0, 12), BackgroundColor3 = C.BTN_ACT, Text = "STEAL", TextColor3 = C.TEXT, Font = Enum.Font.GothamBold, TextSize = 11, BorderSizePixel = 0, Parent = itemFrame })
        create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = btnSteal })
        
        btnSteal.MouseButton1Click:Connect(function()
            doInstantSteal(egg.part)
            btnSteal.Text = "DONE!"
            task.wait(1)
            btnSteal.Text = "STEAL"
        end)
    end
end

-- =========================================================================
-- 6. BUILD UI UTAMA
-- =========================================================================
local function buildUI()
    local parent = CoreGui
    if gethui then local ok, hui = pcall(gethui); if ok and hui then parent = hui end end

    local gui = create("ScreenGui", { Name = "UltimateExploitUI", ResetOnSpawn = false, IgnoreGuiInset = true, DisplayOrder = 999, Parent = parent })
    local main = create("Frame", { Size = UDim2.new(0, 480, 0, 280), Position = UDim2.new(0.5, -240, 0.5, -140), BackgroundColor3 = C.BG, BorderSizePixel = 0, Active = true, Parent = gui })
    create("UICorner", { CornerRadius = UDim.new(0, 12), Parent = main })

    -- Header
    local header = create("Frame", { Size = UDim2.new(1, 0, 0, 45), BackgroundColor3 = C.HEADER, BorderSizePixel = 0, Active = true, Parent = main })
    create("UICorner", { CornerRadius = UDim.new(0, 12), Parent = header })
    create("TextLabel", { Size = UDim2.new(1, -20, 1, 0), Position = UDim2.new(0, 15, 0, 0), BackgroundTransparency = 1, Text = "⚡ OMNIPOTENT HUB v9.0", TextColor3 = C.TEXT, Font = Enum.Font.GothamBold, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, Parent = header })
    
    local closeBtn = create("TextButton", { Size = UDim2.new(0, 30, 0, 30), Position = UDim2.new(1, -40, 0, 7), BackgroundColor3 = C.RED, Text = "X", TextColor3 = C.TEXT, Font = Enum.Font.GothamBold, TextSize = 14, BorderSizePixel = 0, AutoButtonColor = false, Parent = header })
    create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = closeBtn })
    closeBtn.MouseButton1Click:Connect(function() gui:Destroy() end)

    -- Content
    local content = create("Frame", { Size = UDim2.new(1, -30, 1, -65), Position = UDim2.new(0, 15, 0, 55), BackgroundColor3 = C.CONTENT, BorderSizePixel = 0, Parent = main })
    create("UICorner", { CornerRadius = UDim.new(0, 10), Parent = content })

    -- 1. STEP WAJIB: REKAM REMOTE
    create("TextLabel", { Size = UDim2.new(1, -20, 0, 40), Position = UDim2.new(0, 15, 0, 15), BackgroundTransparency = 1, Text = "⚠️ LANGKAH 1: Klik 'Mulai Rekam', lalu CURIlah 1 TELUR secara MANUAL. Script akan merekam caranya.", TextColor3 = C.GOLD, Font = Enum.Font.Gotham, TextSize = 11, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, Parent = content })

    local btnSpy = create("TextButton", { Size = UDim2.new(1, -30, 0, 35), Position = UDim2.new(0, 15, 0, 55), BackgroundColor3 = C.BTN_ACT, Text = "📡 MULAI REKAM REMOTE", TextColor3 = C.TEXT, Font = Enum.Font.GothamBold, TextSize = 12, BorderSizePixel = 0, Parent = content })
    create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = btnSpy })
    
    -- Label Status
    local lblStatus = create("TextLabel", { Size = UDim2.new(1, -30, 0, 20), Position = UDim2.new(0, 15, 0, 95), BackgroundTransparency = 1, Text = "Status: Belum Direkam", TextColor3 = C.RED, Font = Enum.Font.GothamBold, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, Parent = content })
    lblStatus.Name = "SpyStatus"

    btnSpy.MouseButton1Click:Connect(function()
        activateRemoteSpy()
        btnSpy.Text = "🔴 SEDANG MEREKAM... (Curi 1 Telur)"
        btnSpy.BackgroundColor3 = C.RED
        lblStatus.Text = "Status: Menunggu interaksi Remote..."
        lblStatus.TextColor3 = C.GOLD
    end)

    -- 2. MENU INDEX
    create("TextLabel", { Size = UDim2.new(1, -20, 0, 20), Position = UDim2.new(0, 15, 0, 125), BackgroundTransparency = 1, Text = "LANGKAH 2: Buka Index & Auto Steal", TextColor3 = C.TEXT, Font = Enum.Font.GothamBold, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, Parent = content })

    local btnIndex = create("TextButton", { Size = UDim2.new(0.5, -20, 0, 35), Position = UDim2.new(0, 15, 0, 150), BackgroundColor3 = C.GREEN, Text = "🥚 Buka Egg Index", TextColor3 = Color3.new(0,0,0), Font = Enum.Font.GothamBold, TextSize = 12, BorderSizePixel = 0, Parent = content })
    create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = btnIndex })
    btnIndex.MouseButton1Click:Connect(openEggIndexUI)

    -- Fitur Base Defense (Monster/Trap)
    local btnDefense = create("TextButton", { Size = UDim2.new(0.5, -20, 0, 35), Position = UDim2.new(0.5, 5, 0, 150), BackgroundColor3 = C.RED, Text = "🚫 Matikan Trap/Monster", TextColor3 = C.TEXT, Font = Enum.Font.GothamBold, TextSize = 12, BorderSizePixel = 0, Parent = content })
    create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = btnDefense })
    btnDefense.MouseButton1Click:Connect(function()
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") and (string.find(string.lower(obj.Name), "trap") or string.find(string.lower(obj.Name), "spike")) then
                obj.CanTouch = false
            elseif obj:IsA("Model") and (string.find(string.lower(obj.Name), "monster") or string.find(string.lower(obj.Name), "enemy")) then
                if obj.PrimaryPart then obj.PrimaryPart.Anchored = true end
                for _, p in ipairs(obj:GetDescendants()) do
                    if p:IsA("Script") or p:IsA("LocalScript") then p.Disabled = true end
                    if p:IsA("BasePart") then p.CanTouch = false end
                end
            end
        end
        btnDefense.Text = "✅ Base Aman!"
        task.wait(2)
        btnDefense.Text = "🚫 Matikan Trap/Monster"
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

-- =========================================================================
-- JALANKAN
-- =========================================================================
task.wait(0.5)
setupProtections()
local success, err = pcall(buildUI)
if not success then warn("[KeiExploit] UI Error: " .. tostring(err)) end
