--[[
    ╔══════════════════════════════════════════════════════════════════════╗
    ║           SCRIPT INTEL & SAFETY CHECKER v1.0                         ║
    ║           Scan Anti-Cheat, Deteksi Kick, & Saran Bypass              ║
    ╚══════════════════════════════════════════════════════════════════════╝

    Cara pakai:
    1. Execute script ini di Delta sebelum lo nge-hack.
    2. Cek console (F9) buat liat hasil scan.
    3. Script bakal ngasih tau map pake keamanan apa & bypass apa yang harus dipake.
]]

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer

local Log = {}
local function log(msg, color)
    table.insert(Log, msg)
    print("[INTEL] " .. msg)
end

-- ═══════════════════════════════════════════════════════════════════════
-- 1. DETEKSI ANTI-CHEAT / KEAMANAN
-- ═══════════════════════════════════════════════════════════════════════
local function scanSecurity()
    log("=== SCAN KEAMANAN MAP ===", Color3.fromRGB(255, 200, 0))

    -- A. Deteksi Anti-Cheat Bawaan Roblox / Game
    local gameName = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name or "Unknown Game"
    log("Game: " .. gameName)

    local antiCheatFound = false

    -- Cek script pelindung di ServerScriptService (walau client ga bisa liat isinya)
    local ss = game:GetService("ServerScriptService")
    if ss:FindFirstChild("AntiCheat") or ss:FindFirstChild("AC") or ss:FindFirstChild("Security") then
        log("⚠️ TERDETEKSI: Folder Script Anti-Cheat di ServerScriptService!", Color3.fromRGB(255, 100, 100))
        antiCheatFound = true
    end

    -- Cek Byfron / Hyperion (Anti-cheat Client Roblox)
    local ok = pcall(function()
        -- Byfron biasanya memblokir fungsi executor
        local test = getgenv and getgenv().print or nil
        if not test then error("Executor restricted") end
    end)
    if not ok then
        log("⚠️ BYFRON AKTIF: Executor lo dibatasi. Butuh Delta versi bypass (delta-ios/delta-android terbaru).", Color3.fromRGB(255, 100, 100))
    else
        log("✅ Executor bypass Byfron: AMAN (Delta version detected).", Color3.fromRGB(100, 255, 100))
    end

    -- B. Deteksi Anti-Kick (Client-side)
    local mt = getrawmetatable and getrawmetatable(game)
    if mt then
        log("✅ Executor Support getrawmetatable (Bisa Hook Anti-Kick).", Color3.fromRGB(100, 255, 100))
    else
        log("❌ getrawmetatable NOT SUPPORTED. Lo gak bisa hook kick.", Color3.fromRGB(255, 100, 100))
    end

    -- C. Deteksi Remote Event (Server-side Security)
    local remotes = {}
    for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            table.insert(remotes, obj.Name)
        end
    end
    log("Total Remote di ReplicatedStorage: " .. #remotes)
    
    if #remotes > 50 then
        log("⚠️ Remote sangat banyak. Kemungkinan besar game ini pakai Advanced Anti-Exploit (Validasi Argumen Ketat).", Color3.fromRGB(255, 200, 0))
    else
        log("✅ Remote sedikit. Kemungkinan game gak terlalu ngurusin exploit (Gampang di-hack).", Color3.fromRGB(100, 255, 100))
    end

    -- D. Deteksi Anti-Teleport (Map Check)
    local antiTP = false
    local myChar = LocalPlayer.Character
    if myChar and myChar:FindFirstChild("HumanoidRootPart") then
        local before = myChar.HumanoidRootPart.Position
        -- Cobain gerak dikit
        myChar.HumanoidRootPart.CFrame = myChar.HumanoidRootPart.CFrame + Vector3.new(0, 5, 0)
        task.wait(0.2)
        local after = myChar.HumanoidRootPart.Position
        if (after - before).Magnitude < 1 then
            log("⚠️ ANTI-TELEPORT TERDETEKSI: Karakter lo balik ke tempat semula (Rubberbanding)!", Color3.fromRGB(255, 100, 100))
            antiTP = true
        else
            log("✅ Anti-Teleport: TIDAK TERDETEKSI. Lo bisa bebas teleport.", Color3.fromRGB(100, 255, 100))
        end
    end

    -- E. Deteksi Konsep Keamanan (Client vs Server)
    log("=== KONSEP KEAMANAN ===", Color3.fromRGB(255, 200, 0))
    if antiCheatFound and antiTP then
        log("Konsep: SERVER-AUTHORITATIVE (Sangat Ketat)", Color3.fromRGB(255, 100, 100))
        log("Server ngecek semua pergerakan dan argumen remote. Lo butuh 'Remote Argument Spoofer' buat nyuri (By-Pass Remote).", Color3.fromRGB(255, 200, 100))
    elseif antiTP then
        log("Konsep: ANTI-TELEPORT FOCUSED", Color3.fromRGB(255, 200, 0))
        log("Lo ga bisa teleport sembarangan. Gunakan teknik 'WalkSpeed' atau 'CFrame Tween' (gerak cepet) biar ga di-kick.", Color3.fromRGB(255, 200, 100))
    else
        log("Konsep: CLIENT-TRUST (Gampang di-hack)", Color3.fromRGB(100, 255, 100))
        log("Server percaya apa yang dikirim client. Lo tinggal teleport & tembak remote seperti script Auto Steal biasa.", Color3.fromRGB(100, 255, 100))
    end
end

-- ═══════════════════════════════════════════════════════════════════════
-- 2. DETEKSI KICK & ALASAN
-- ═══════════════════════════════════════════════════════════════════════
local function monitorKicks()
    log("=== MONITOR KICK ===", Color3.fromRGB(255, 200, 0))

    -- 1. Cek alasan kick terakhir di Console
    LocalPlayer.OnTeleport:Connect(function()
        log("⚠️ Lo Sedang Di-kick/Teleport paksa oleh server!", Color3.fromRGB(255, 100, 100))
    end)

    -- 2. Hook SendNotification (Kick message)
    pcall(function()
        local oldIndex = getrawmetatable(StarterGui).__index
        setreadonly(getrawmetatable(StarterGui), false)
        getrawmetatable(StarterGui).__index = newcclosure(function(self, key, ...)
            if key == "SendNotification" then
                local args = {...}
                if args[1] and type(args[1]) == "table" and args[1].Title then
                    local title = string.lower(tostring(args[1].Title))
                    local text = string.lower(tostring(args[1].Text))
                    if title:find("kick") or title:find("ban") or text:find("exploit") or text:find("cheat") then
                        log("❌ USER DI-KICK: " .. LocalPlayer.Name .. " | ALASAN: " .. tostring(args[1].Text), Color3.fromRGB(255, 100, 100))
                    end
                end
            end
            return oldIndex(self, key, ...)
        end)
        setreadonly(getrawmetatable(StarterGui), true)
        log("✅ Hook Kick Message: AKTIF (Gua bakal ngasih tau kalo lo di-kick).")
    end)

    -- 3. Hook Kick via RemoteEvent (Kalo ada game yang nge-kick pake remote)
    for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") and (string.find(string.lower(obj.Name), "kick") or string.find(string.lower(obj.Name), "ban")) then
            obj.OnClientEvent:Connect(function(...)
                log("❌ USER DI-KICK (Remote): " .. LocalPlayer.Name .. " | ALASAN: " .. tostring(...), Color3.fromRGB(255, 100, 100))
            end)
        end
    end
end

-- ═══════════════════════════════════════════════════════════════════════
-- 3. SARAN BYPASS
-- ═══════════════════════════════════════════════════════════════════════
local function suggestBypass()
    log("=== REKOMENDASI BYPASS ===", Color3.fromRGB(255, 200, 0))
    
    log("1. Kalo game pakai ANTI-TELEPORT (Rubberbanding):", Color3.fromRGB(255, 255, 255))
    log("   -> Gunakan 'CFrame Tween' atau 'WalkSpeed 200' buat ngelewatin tembok, jangan teleport instan.")
    log("   -> Bypass: `Character.HumanoidRootPart.CFrame = target` sambil nyalain 'Noclip'.")
    
    log("2. Kalo game pakai ANTI-REMOTE (Argumen ketat):", Color3.fromRGB(255, 255, 255))
    log("   -> Lo butuh 'Remote Spy' (F9 console) buat liat argumen asli yang dikirim pas lo nyuri manual.")
    log("   -> Bypass: Kirim argumen yang sama persis seperti yang dikirim game (ga boleh ngarang).")
    
    log("3. Kalo game pakai BYFRON (Executor dibatasi):", Color3.fromRGB(255, 255, 255))
    log("   -> Pake Delta versi terbaru (bukan yang lama). Byfron ga bisa di-bypass sembarangan, Delta udah handle itu.")
    
    log("4. Kalo lo DI-KICK:", Color3.fromRGB(255, 255, 255))
    log("   -> Artinya server ngedeteksi lo ngirim data aneh. Jangan spam Remote terlalu cepet. Kasih delay 1-2 detik.")
end

-- ═══════════════════════════════════════════════════════════════════════
-- EKSEKUSI SCAN
-- ═══════════════════════════════════════════════════════════════════════
task.spawn(function()
    task.wait(1)
    scanSecurity()
    task.wait(1)
    monitorKicks()
    task.wait(1)
    suggestBypass()

    log("=== SCAN SELESAI. CEK LOG DI ATAS. ===", Color3.fromRGB(100, 255, 100))
end)
