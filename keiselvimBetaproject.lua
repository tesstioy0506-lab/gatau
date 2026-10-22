--[[
    ╔══════════════════════════════════════════════════════════════════════╗
    ║           KEI SELVIM — OMNIPOTENT EXPLOIT HUB v8.0                   ║
    ║           Index + Instan Steal + Anti Trap + Kick Interceptor        ║
    ╚══════════════════════════════════════════════════════════════════════╝
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer or Players:GetPropertyChangedSignal("LocalPlayer"):Wait() or Players.LocalPlayer

-- =========================================================================
-- ⚙️ STATE & CONFIG
-- =========================================================================
local State = {
    isAutoStealing = false,
    isMonsterFrozen = false,
    stealMethod = "Teleport",
    stealMode = "Best",
    minRarityFilter = "epic",
    targetPlotName = "Plots",
}

local RARITY_ORDER = {
    common = 1, rare = 2, epic = 3, legendary = 4, mythic = 5, 
    secret = 6, ["player god"] = 7, og = 8, champions = 9, 
    dynasty = 10, icons = 11, haunted = 12
}

local RARITY_PRICE = { -- Estimasi Harga Kalo Menetas (Rupiah/Robux)
    common = "1K", rare = "5K", epic = "25K", legendary = "100K", mythic = "500K",
    secret = "1M", ["player god"] = "5M", og = "10M", champions = "25M", dynasty = "50M",
    icons = "100M", haunted = "500M"
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
-- HELPER UI
-- =========================================================================
local function create(cls, props)
    local obj = Instance.new(cls)
    for k, v in pairs(props) do if k ~= "Parent" then obj[k] = v end end
    if props.Parent then obj.Parent = props.Parent end
    return obj
end

-- =========================================================================
-- FITUR 1: KICK INTERCEPTOR (PESAN CUSTOM)
-- =========================================================================
local function setupKickInterceptor()
    pcall(function()
        local oldIndex = getrawmetatable(StarterGui).__index
        setreadonly(getrawmetatable(StarterGui), false)
        
        getrawmetatable(StarterGui).__index = newcclosure(function(self, key, ...)
            if key == "SendNotification" then
                local args = {...}
                if args[1] and type(args[1]) == "table" then
                    local title = tostring(args[1].Title or ""):lower()
                    local text = tostring(args[1].Text or ""):lower()
                    
                    -- Deteksi pesan kick
                    if title:find("kick") or title:find("ban") or text:find("exploit") or text:find("cheat") or text:find("moderator") then
                        -- TIMPA PESAN NYA
                        args[1].Title = "🚫 SYSTEM OVERRIDE"
                        args[1].Text = "KAMU DI KICK OLEH MODERATORNYA! KAMU HARUS PERBAIKI, PAKE CELAH!"
                        args[1].Duration = 5
                        
                        -- Tampilkan notif custom (bukan kick beneran)
                        oldIndex(self, key, args[1])
                        return nil -- Blokir kick aslinya
                    end
                end
            end
            return oldIndex(self, key, ...)
        end)
        
        setreadonly(getrawmetatable(StarterGui), true)
        print("[Kei] Kick Interceptor: AKTIF. Pesan kick udah dimodifikasi.")
    end)
end

-- =========================================================================
-- FITUR 2: EGG INDEX (LIHAT NAMA & HARGA)
-- =========================================================================
local function openEggIndexUI()
    local eggList = {}
    
    -- Scan semua telur di workspace
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and (string.find(string.lower(obj.Name), "egg") or string.find(string.lower(obj.Name), "bok")) then
            local rName = "common"
            for rar, _ in pairs(RARITY_ORDER) do
                if string.find(string.lower(obj.Name), rar) then rName = rar; break end
            end
            table.insert(eggList, {name = obj.Name, rarity = rName, price = RARITY_PRICE[rName], obj = obj})
        end
    end
    
    -- Bikin UI List
    local parent = CoreGui
    if gethui then local ok, hui = pcall(gethui); if ok and hui then parent = hui end end
    
    local gui = create("ScreenGui", { Name = "EggIndexUI", ResetOnSpawn = false, DisplayOrder = 1000, Parent = parent })
    local frame = create("Frame", { Size = UDim2.new(0, 400, 0, 350), Position = UDim2.new(0.5, -200, 0.5, -175), BackgroundColor3 = C.BG, BorderSizePixel = 0, Parent = gui })
    create("UICorner", { CornerRadius = UDim.new(0, 10), Parent = frame })
    
    create("TextLabel", { Size = UDim2.new(1, 0, 0, 40), BackgroundColor3 = C.HEADER, Text = "🥚 EGG INDEX & PRICE", TextColor3 = C.TEXT, Font = Enum.Font.GothamBold, TextSize = 14, BorderSizePixel = 0, Parent = frame })
    local btnClose = create("TextButton", { Size = UDim2.new(0, 40, 0, 40), Position = UDim2.new(1, -40, 0, 0), BackgroundColor3 = C.RED, Text = "X", TextColor3 = C.TEXT, Parent = frame })
    
    local scroll = create("ScrollingFrame", { Size = UDim2.new(1, -20, 1, -60), Position = UDim2.new(0, 10, 0, 50), BackgroundTransparency = 1, CanvasSize = UDim2.new(0, 0, 0, #eggList * 50), Parent = frame })
    local list = create("UIListLayout", { Padding = UDim.new(0, 5), Parent = scroll })
    
    btnClose.MouseButton1Click:Connect(function() gui:Destroy() end)
    
    for i, egg in ipairs(eggList) do
        local itemFrame = create("Frame", { Size = UDim2.new(1, 0, 0, 45), BackgroundColor3 = C.CARD, BorderSizePixel = 0, Parent = scroll })
        create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = itemFrame })
        
        create("TextLabel", { Size = UDim2.new(0.6, 0, 1, 0), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1, Text = egg.name, TextColor3 = C.TEXT, Font = Enum.Font.GothamBold, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, Parent = itemFrame })
        create("TextLabel", { Size = UDim2.new(0.4, -10, 1, 0), Position = UDim2.new(0.6, 0, 0, 0), BackgroundTransparency = 1, Text = "💰 " .. egg.price .. " (" .. egg.rarity .. ")", TextColor3 = C.GREEN, Font = Enum.Font.Gotham, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Right, Parent = itemFrame })
        
        local btnSteal = create("TextButton", { Size = UDim2.new(0, 60, 0, 25), Position = UDim2.new(1, -70, 0, 10), BackgroundColor3 = C.BTN_ACT, Text = "Steal", TextColor3 = C.TEXT, Font = Enum.Font.GothamBold, TextSize = 11, BorderSizePixel = 0, Parent = itemFrame })
        create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = btnSteal })
        
        -- FITUR 3: INSTAN STEAL & ANTI JEBAKAN
        btnSteal.MouseButton1Click:Connect(function()
            -- 1. Matikan jebakan (Trap) di sekitar telur
            for _, trap in ipairs(Workspace:GetDescendants()) do
                if trap:IsA("BasePart") and (string.find(string.lower(trap.Name), "trap") or string.find(string.lower(trap.Name), "spike")) then
                    trap.CanTouch = false
                    trap.Transparency = 0.5
                end
            end
            
            -- 2. Teleport Instan ke telur
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                char.HumanoidRootPart.CFrame = CFrame.new(egg.obj.Position + Vector3.new(0, 3, 0))
            end
            
            task.wait(0.2)
            
            -- 3. Tembak Remote Nyuri (Scan otomatis)
            for _, r in ipairs(ReplicatedStorage:GetDescendants()) do
                if r.Name:lower():find("steal") or r.Name:lower():find("take") then
                    if r:IsA("RemoteEvent") then r:FireServer(egg.obj) end
                    if r:IsA("RemoteFunction") then r:InvokeServer(egg.obj) end
                end
            end
            
            btnSteal.Text = "Done!"
            task.wait(1)
            btnSteal.Text = "Steal"
        end)
    end
end

-- =========================================================================
-- FITUR 4: MONSTER FREEZE & ANTI JEBAKAN
-- =========================================================================
local function activateBaseDefenses()
    -- Matikan monster
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and (string.find(string.lower(obj.Name), "monster") or string.find(string.lower(obj.Name), "enemy")) then
            if obj.PrimaryPart then obj.PrimaryPart.Anchored = true end
            for _, p in ipairs(obj:GetDescendants()) do
                if p:IsA("Script") or p:IsA("LocalScript") then p.Disabled = true end
                if p:IsA("BasePart") then p.CanTouch = false end
            end
        end
    end
    
    -- Matikan jebakan
    for _, trap in ipairs(Workspace:GetDescendants()) do
        if trap:IsA("BasePart") and (string.find(string.lower(trap.Name), "trap") or string.find(string.lower(trap.Name), "spike") or string.find(string.lower(trap.Name), "laser")) then
            trap.CanTouch = false
        end
    end
    
    print("[Kei] Base Defenses OFF (Monster & Trap Dimatikan).")
end

-- =========================================================================
-- FUNGSI STEAL OTOMATIS (Loop)
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
                        -- Anti Jebakan: Matikan Trap disekitar sebelum teleport
                        for _, trap in ipairs(Workspace:GetDescendants()) do
                            if trap:IsA("BasePart") and string.find(string.lower(trap.Name), "trap") then
                                trap.CanTouch = false
                            end
                        end
                        
                        local char = LocalPlayer.Character
                        if char and char:FindFirstChild("HumanoidRootPart") then
                            char.HumanoidRootPart.CFrame = CFrame.new(block.Position + Vector3.new(0, 5, 0))
                        end
                        task.wait(0.5)
                        
                        for _, r in ipairs(ReplicatedStorage:GetDescendants()) do
                            if r.Name:lower():find("steal") or r.Name:lower():find("take") then
                                if r:IsA("RemoteEvent") then r:FireServer(block) end
                                if r:IsA("RemoteFunction") then r:InvokeServer(block) end
                            end
                        end
                        task.wait(1)
                    end
                end
            end
            task.wait(2)
        end
    end)
end

-- =========================================================================
-- BUILD UI UTAMA
-- =========================================================================
local function buildUI()
    local parent = CoreGui
    if gethui then local ok, hui = pcall(gethui); if ok and hui then parent = hui end end

    local gui = create("ScreenGui", { Name = "UltimateExploitUI", ResetOnSpawn = false, IgnoreGuiInset = true, DisplayOrder = 999, Parent = parent })
    local main = create("Frame", { Size = UDim2.new(0, 480, 0, 350), Position = UDim2.new(0.5, -240, 0.5, -175), BackgroundColor3 = C.BG, BorderSizePixel = 0, Active = true, Parent = gui })
    create("UICorner", { CornerRadius = UDim.new(0, 12), Parent = main })

    -- Header
    local header = create("Frame", { Size = UDim2.new(1, 0, 0, 45), BackgroundColor3 = C.HEADER, BorderSizePixel = 0, Active = true, Parent = main })
    create("UICorner", { CornerRadius = UDim.new(0, 12), Parent = header })
    create("TextLabel", { Size = UDim2.new(1, -20, 1, 0), Position = UDim2.new(0, 15, 0, 0), BackgroundTransparency = 1, Text = "⚡ OMNIPOTENT EXPLOIT HUB", TextColor3 = C.TEXT, Font = Enum.Font.GothamBold, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, Parent = header })
    
    local closeBtn = create("TextButton", { Size = UDim2.new(0, 30, 0, 30), Position = UDim2.new(1, -40, 0, 7), BackgroundColor3 = C.RED, Text = "X", TextColor3 = C.TEXT, Font = Enum.Font.GothamBold, TextSize = 14, BorderSizePixel = 0, AutoButtonColor = false, Parent = header })
    create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = closeBtn })
    closeBtn.MouseButton1Click:Connect(function() gui:Destroy() end)

    -- Content
    local content = create("Frame", { Size = UDim2.new(1, -30, 1, -65), Position = UDim2.new(0, 15, 0, 55), BackgroundColor3 = C.CONTENT, BorderSizePixel = 0, Parent = main })
    create("UICorner", { CornerRadius = UDim.new(0, 10), Parent = content })

    -- 1. TOMBOL FITUR UTAMA
    create("TextLabel", { Size = UDim2.new(1, -20, 0, 20), Position = UDim2.new(0, 15, 0, 15), BackgroundTransparency = 1, Text = "Menu Fitur:", TextColor3 = C.TEXT, Font = Enum.Font.GothamBold, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, Parent = content })

    local btnIndex = create("TextButton", { Size = UDim2.new(0.5, -20, 0, 35), Position = UDim2.new(0, 15, 0, 40), BackgroundColor3 = C.BTN_ACT, Text = "🥚 Buka Egg Index", TextColor3 = C.TEXT, Font = Enum.Font.GothamBold, TextSize = 12, BorderSizePixel = 0, Parent = content })
    create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = btnIndex })
    btnIndex.MouseButton1Click:Connect(openEggIndexUI)

    local btnDefense = create("TextButton", { Size = UDim2.new(0.5, -20, 0, 35), Position = UDim2.new(0.5, 5, 0, 40), BackgroundColor3 = C.RED, Text = "🚫 Matikan Monster/Trap", TextColor3 = C.TEXT, Font = Enum.Font.GothamBold, TextSize = 12, BorderSizePixel = 0, Parent = content })
    create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = btnDefense })
    btnDefense.MouseButton1Click:Connect(function()
        activateBaseDefenses()
        btnDefense.Text = "✅ Base Aman!"
        btnDefense.BackgroundColor3 = C.GREEN
        task.delay(2, function()
            btnDefense.Text = "🚫 Matikan Monster/Trap"
            btnDefense.BackgroundColor3 = C.RED
        end)
    end)

    -- 2. AUTO STEAL
    create("TextLabel", { Size = UDim2.new(1, -20, 0, 20), Position = UDim2.new(0, 15, 0, 85), BackgroundTransparency = 1, Text = "Auto Steal (Anti Hit):", TextColor3 = C.TEXT, Font = Enum.Font.GothamBold, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, Parent = content })

    local btnStart = create("TextButton", { Size = UDim2.new(1, -30, 0, 45), Position = UDim2.new(0, 15, 0, 110), BackgroundColor3 = C.GREEN, Text = "MULAI AUTO STEAL", TextColor3 = Color3.new(0,0,0), Font = Enum.Font.GothamBold, TextSize = 14, BorderSizePixel = 0, Parent = content })
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
        end
    end)

    -- 3. INFO KICK
    create("TextLabel", { Size = UDim2.new(1, -30, 0, 40), Position = UDim2.new(0, 15, 0, 165), BackgroundTransparency = 1, Text = "🛡️ Kick Interceptor Aktif (Kalo di kick, pesan bakal diganti)", TextColor3 = C.TEXT_DIM, Font = Enum.Font.Gotham, TextSize = 10, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, Parent = content })

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

-- JALANKAN SEMUA
task.wait(0.5)
setupKickInterceptor() -- Pasang pelindung kick duluan
local success, err = pcall(buildUI)
if not success then warn("[KeiExploit] UI Error: " .. tostring(err)) end
