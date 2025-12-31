local WindUI

do
    local ok, result = pcall(function()
        return require("./src/Init")
    end)
    
    if ok then
        WindUI = result
    else 
        WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
    end
end

--[[

WindUI.Creator.AddIcons("solar", {
    ["CheckSquareBold"] = "rbxassetid://132438947521974",
    ["CursorSquareBold"] = "rbxassetid://120306472146156",
    ["FileTextBold"] = "rbxassetid://89294979831077",
    ["FolderWithFilesBold"] = "rbxassetid://74631950400584",
    ["HamburgerMenuBold"] = "rbxassetid://134384554225463",
    ["Home2Bold"] = "rbxassetid://92190299966310",
    ["InfoSquareBold"] = "rbxassetid://119096461016615",
    ["PasswordMinimalisticInputBold"] = "rbxassetid://109919668957167",
    ["SolarSquareTransferHorizontalBold"] = "rbxassetid://125444491429160",
})--]]


-- */  Window  /* --
local Window = WindUI:CreateWindow({
    Title = "LS Hub - Fish It",
    Author = "developed by Louissxe",
    Folder = "LSHub-FishIt", -- folder penyimpanan pengaturan
    Icon = "rbxassetid://129609617845057",
    Transparent = true,
    IconSize = 12*2,
    NewElements = true,
    Size = UDim2.fromOffset(580, 380),
    ToggleKey = Enum.KeyCode.G,
        User = {
        Enabled = true,
        Anonymous = true,
    },
    
    HideSearchBar = false,
    
    OpenButton = {
        Title = "Open LS Hub", -- can be changed
        CornerRadius = UDim.new(0.3,0), -- fully rounded
        StrokeThickness = 3, -- removing outline
        Enabled = true, -- enable or disable openbutton
        Draggable = true,
        OnlyMobile = false,
        
        Color = ColorSequence.new( -- gradient
            Color3.fromHex("#6b31ff"), 
            Color3.fromHex("#FFD700")
        )
    },
    Topbar = {
        Height = 44,
        ButtonsType = "Default", -- Default or Mac
    },
    --[[
    KeySystem = {
        Title = "Key System Example  |  WindUI Example",
        Note = "Key System. Key: 1234",
        KeyValidator = function(EnteredKey)
            if EnteredKey == "1234" then
                createPopup()
                return true
            end
            return false
            -- return EnteredKey == "1234" -- if key == "1234" then return true else return false end
        end
    }
    ]]
})

-- */  Tags  /* --
Window:Tag({
    Title = "Prem v3.7",
    Color = WindUI:Gradient({
        ["0"]   = { Color = Color3.fromHex("#6b31ff"), Transparency = 0 },
        ["100"] = { Color = Color3.fromHex("#FFD700"), Transparency = 0 }, 
    }, {
        Rotation = 45,
    }),
    TextColor = Color3.new(0, 0, 0),
})

-- /  About Tab  / --
do
    local AboutTab = Window:Tab({
        Title = "About LS Hub",
        Icon = "solar:chat-square-like-bold",
        IconColor = Color3.fromHex("#6b31ff"),
        IconShape = true,
    })
    
    local AboutSection = AboutTab:Section({
        Title = "About LS Hub",
        Icon = "solar:info-square-bold",
        Opened = true
    })
    
    AboutTab:Image({
        Image = "rbxassetid://133168716285012",
        AspectRatio = "16:9",
        Radius = 9,
    })

    AboutTab:Section({
        Title = "What is LS Hub?",
        TextSize = 24,
        FontWeight = Enum.FontWeight.SemiBold,
    })
    
    AboutTab:Section({
        Title = [[Script Roblox universal yang simpel, cepat, dan modern. Meskipun script ini aman, penggunaan di ruang publik tetap memiliki risiko. Bijaksanalah saat menggunakannya.]],
        TextSize = 18,
        TextTransparency = .35,
        FontWeight = Enum.FontWeight.Medium,
    })

    AboutTab:Space({ Columns = 1 })

AboutTab:Button({
    Title = "Join Discord",
    Color = Color3.fromHex("#6b31ff"),
    Justify = "Center",
    IconAlign = "Left",
    Icon = "solar:clipboard-bold",
    Callback = function()
        local discordLink = "https://discord.gg/s9v49dwV" -- ganti ini
        local success = false

        -- Common exploit clipboard functions
        if type(setclipboard) == "function" then
            pcall(setclipboard, discordLink); success = true
        elseif syn and type(syn.set_clipboard) == "function" then
            pcall(syn.set_clipboard, discordLink); success = true
        elseif type(set_clipboard) == "function" then
            pcall(set_clipboard, discordLink); success = true
        else
            -- Roblox internal fallback (may be restricted on some clients)
            pcall(function()
                game:GetService("GuiService"):SetClipboard(discordLink)
                success = true
            end)
        end
    end
})
    
    AboutTab:Button({
        Title = "Destroy Window",
        Color = Color3.fromHex("#ff4830"),
        Justify = "Center",
        Icon = "shredder",
        IconAlign = "Left",
        Callback = function()
            Window:Destroy()
        end
    })
end

-- */  Elements Section  /* --
local UiSection = Window:Section({
    Title = "Open Features",
})

------------------------------------------------------------
-- 🔗 REMOTE BINDER
------------------------------------------------------------
local Rep = game:GetService("ReplicatedStorage")
local function RF(name)
    return Rep:WaitForChild("Packages",9e9)
        :WaitForChild("_Index",9e9)
        :WaitForChild("sleitnick_net@0.2.0",9e9)
        :WaitForChild("net",9e9)
        :WaitForChild(name,9e9)
end

local RFCancelFishingInputs       = RF("RF/CancelFishingInputs")
local RFChargeFishingRod          = RF("RF/ChargeFishingRod")
local RFRequestFishingMinigame    = RF("RF/RequestFishingMinigameStarted")
local REFishingCompleted          = RF("RE/FishingCompleted")
local RFSellAllItems              = RF("RF/SellAllItems")

------------------------------------------------------------
-- ⚙ VARIABEL
------------------------------------------------------------
local autoFish = false
local isFishing = false
local serverDelay = 1.1 -- Default delay waktu tunggu server (UI controlled)
local noAnimation = false -- timestamp fix
local cancelDelay = 0.01 -- internal cancel delay (kamu mau tetap cepat)
local cycleDelay = 1.78 -- default delay antar siklus

------------------------------------------------------------
-- 💾 SISTEM PENYIMPANAN PENGATURAN (DIPERBAIKI)
------------------------------------------------------------
-- Tambahkan HttpService untuk fungsi JSON
local HttpService = game:GetService("HttpService")

local fileName = "LS_Hub_AutoFishing_Settings.json"
local persistentSettings = {}

-- Fungsi untuk menyimpan pengaturan ke file
local function saveSettings()
    -- Periksa apakah writefile tersedia
    if not writefile then
        return
    end
    
    -- Update tabel dengan nilai terbaru
    persistentSettings["AutoFish"] = autoFish
    persistentSettings["CycleDelay"] = cycleDelay
    persistentSettings["ServerDelay"] = serverDelay

    -- Gunakan writefile dan JSONEncode untuk penyimpanan yang andal
    local json = HttpService:JSONEncode(persistentSettings)
    writefile(fileName, json)
end

-- Fungsi untuk memuat pengaturan dari file
local function loadSettings()
    -- Periksa apakah readfile tersedia
    if not readfile then
        return
    end
    
    -- Gunakan pcall untuk mencegah error jika file tidak ada (saat pertama kali run)
    local success, content = pcall(function()
        return readfile(fileName)
    end)

    if success then
        -- Decode JSON dari file
        local data = HttpService:JSONDecode(content)
        for key, value in pairs(data) do
            persistentSettings[key] = value
        end

        -- Terapkan nilai yang dimuat ke variabel script
        autoFish = persistentSettings["AutoFish"] or false
        cycleDelay = persistentSettings["CycleDelay"] or 1.78
        serverDelay = persistentSettings["ServerDelay"] or 1.1
    end
end

-- Panggil fungsi loadSettings SEKARANG
loadSettings()


------------------------------------------------------------
-- 📌 FUNGSI REMOTE (tetap sama seperti log orang)
------------------------------------------------------------
local function Cancel()
    pcall(function()
        RFCancelFishingInputs:InvokeServer({})
    end)
end

local function Cast()
    pcall(function()
        RFChargeFishingRod:InvokeServer(-1, 0.05555, noAnimation)
    end)
end

local function StartMinigame()
    pcall(function()
        RFRequestFishingMinigame:InvokeServer(-1, 0.0999, noAnimation)
    end)
end

local function Complete()
    pcall(function()
        REFishingCompleted:FireServer({})
    end)
end

------------------------------------------------------------
-- 🔎 HELPERS: deteksi minigame di sisi klien
------------------------------------------------------------
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Try to detect common client indicators that a fishing minigame started.
-- Returns true if detected within timeout, false otherwise.
local function waitForMinigameReady(timeout)
    timeout = timeout or 1.0
    local start = tick()

    while tick() - start < timeout do
        -- 1) Check PlayerGui for common minigame GUI names
        local pg = LocalPlayer:FindFirstChild("PlayerGui")
        if pg then
            if pg:FindFirstChild("FishingGui") then return true end
            if pg:FindFirstChild("FishingMinigame") then return true end
            if pg:FindFirstChild("MiniGame") then return true end
            -- some games use nested frames; check descendants lightly
            for _, child in ipairs(pg:GetChildren()) do
                if child.Name:lower():find("fish") or child.Name:lower():find("minigame") then
                    return true
                end
            end
        end

        -- 2) Check Character for values that some scripts use
        local char = LocalPlayer.Character
        if char then
            local s = char:FindFirstChild("FishingState") or char:FindFirstChild("IsFishing") or char:FindFirstChild("Fishing")
            if s then
                if s:IsA("BoolValue") and s.Value == true then return true end
                if s:IsA("StringValue") then
                    local v = s.Value:lower()
                    if v:find("minigame") or v:find("fishing") then return true end
                end
            end
        end

        task.wait(0.05)
    end

    return false
end

------------------------------------------------------------
-- 🔁 instantCycle (adaptive & safer)
------------------------------------------------------------
local function instantCycle()
    if isFishing then return end
    isFishing = true

    task.spawn(function()
        -- make sure we always try to leave server in clean state if something fails
        local ok, err = pcall(function()

            -- 1) ensure any prior session closed
            Cancel()
            task.wait(cancelDelay)

            -- 2) initial cast
            Cast()
            task.wait(cancelDelay)

            -- 3) start minigame request
            StartMinigame()

            -- 4) wait for client-side minigame indicator (best) with small timeout
            local detected = false
            -- use a short timeout that's adaptive: prefer up to 0.8s or serverDelay/1.5 whichever smaller
            local probeTimeout = math.clamp(math.min(0.8, serverDelay * 0.8), 0.2, 1.0)
            detected = waitForMinigameReady(probeTimeout)

            if detected then
                -- If detected, wait the configured serverDelay (user-controlled) before Complete()
                task.wait(serverDelay)
            else
                -- Fallback: server didn't show UI; use a conservative shorter wait so we don't miss server window
                -- We choose a fraction of serverDelay but not too small
                local fallbackWait = math.clamp(serverDelay * 0.6, 0.2, 1.0)
                task.wait(fallbackWait)
            end

            -- 5) Complete the minigame (send complete)
            Complete()

            -- 6) extra Cancel to ensure session truly reset on server (helps create distinct second cycle)
            task.wait(0.05)
            Cancel()
        end)

        if not ok then
            -- optional: notify error (non-blocking)
            -- WindUI:Notify({ Title = "Fishing Error", Content = tostring(err), Duration = 2 })
        end

        isFishing = false
    end)
end

---------------------------
-- DUA SIKLUS OTOMATIS —
-- TANPA ON–OFF–ON MANUAL
---------------------------

task.spawn(function()
    while task.wait() do
        if autoFish then

            -- 🔵 Siklus 1
            instantCycle()

            -- jeda antar siklus (kamu bisa ubah lewat UI)
            task.wait(cycleDelay)

            -- pastikan isFishing direset agar siklus kedua bisa mulai
            isFishing = false

            -- 🔴 Siklus 2
            instantCycle()

        end
    end
end)

------------------------------------------------------------
-- 🎣 UI PANEL
------------------------------------------------------------
local AutoTab = UiSection:Tab({
    Title = "Main Automatic",
    Icon = "solar:gamepad-bold",
    IconColor = Color3.fromHex("#007AFF"),
    IconShape = true,
})


local perfectSection = AutoTab:Section({
    Title = "Perfect Fishing",
    Icon = "solar:leaf-bold",
    Opened = false
})

-- 🔧 Other Script: Infinite Yield
perfectSection:Button({
    Title = "Auto Perfect Fishing",
    Icon = "solar:oven-mitts-bold",
    Justify = "Center",
    IconAlign = "Left",
    Desc = "Tap here to load.",
    Color = Color3.fromHex("#FFD700"),
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Louissyahpt/FishIt/refs/heads/main/perfect"))()
        WindUI:Notify({
            Title = "Perfect Fishing",
            Content = "Auto Perfect Fishing Ready.",
            Duration = 3
        })
    end
})

-- 🔧 Other Script: Infinite Yield
perfectSection:Button({
    Title = "Sett Elements Rod",
    Icon = "solar:oven-mitts-bold",
    Justify = "Center",
    IconAlign = "Left",
    Desc = "Tap here to load.",
    Color = Color3.fromHex("#6b31ff"),
    Callback = function()
        loadstring(game:HttpGet("https://pastefy.app/4cmWoXeQ/raw"))()
        WindUI:Notify({
            Title = "All Rod Settings",
            Content = "Sett Rod Ready.",
            Duration = 3
        })
    end
})


local FishingSection = AutoTab:Section({ Title = "Blatant Fishing", Icon = "solar:crown-star-bold", Opened = false })

AutoTab:Toggle({
    Title = "Blatant Fishing",
    Default = autoFish, -- Menggunakan nilai yang sudah dimuat
    Callback = function(v)
        autoFish = v
        saveSettings() -- Simpan status toggle
        WindUI:Notify({ Title = "Blatant Fishing", Content = v and "Aktif" or "Nonaktif", Duration = 1 })
    end
})

AutoTab:Input({
    Title = "Delay Reel",
    Desc = "Delay antar Cast",
    Value = tostring(cycleDelay),
    Placeholder = "Misal 1.0 - 3.0",
    Callback = function(input)
        local value = tonumber(input)
        if value and value >= 0.1 and value <= 5 then
            cycleDelay = value
            saveSettings() -- Simpan pengaturan baru
        end
    end
})

AutoTab:Input({
    Title = "Delay Fishing",
    Desc = "Delay setelah minigame",
    Value = tostring(serverDelay),
    Placeholder = "Masukkan nilai (0.1-5)",
    Callback = function(input)
        local value = tonumber(input)
        if value and value >= 0.1 and value <= 5 then
            serverDelay = value
            saveSettings() -- Simpan pengaturan baru
        end
    end
})

------------------------------------------------------------
-- 🔗 REMOTE BINDER
------------------------------------------------------------
local Rep = game:GetService("ReplicatedStorage")
local function RF(name)
    return Rep:WaitForChild("Packages",9e9)
        :WaitForChild("_Index",9e9)
        :WaitForChild("sleitnick_net@0.2.0",9e9)
        :WaitForChild("net",9e9)
        :WaitForChild(name,9e9)
end

local RFCancelFishingInputs       = RF("RF/CancelFishingInputs")
local RFChargeFishingRod          = RF("RF/ChargeFishingRod")
local RFRequestFishingMinigame    = RF("RF/RequestFishingMinigameStarted")
local REFishingCompleted          = RF("RE/FishingCompleted")
local RFSellAllItems              = RF("RF/SellAllItems")


------------------------------------------------------------
-- ⚙ VARIABEL
------------------------------------------------------------
local autoFish = false
local isFishing = false
local serverDelay = 1.1 -- Default delay waktu tunggu server
local noAnimation = false -- timestamp fix
local fishingMode = "Fast" -- Default fishing mode

------------------------------------------------------------
-- 📌 FUNGSI REMOTE MATCH EXACT DENGAN LOG ORANG
------------------------------------------------------------
local function Cancel()
    pcall(function()
        RFCancelFishingInputs:InvokeServer({})
    end)
end

local function Cast()
    pcall(function()
        if fishingMode == "Fast" then
            -- Mode Fast dengan args tetap
            RFChargeFishingRod:InvokeServer(-1, 0.05555, noAnimation)
        elseif fishingMode == "Random Result" then
            -- Mode Random Result dengan timestamp acak
            local randomTimestamp = tick() + math.random(100000, 999999)
            local args = {
                [1] = -1,
                [2] = 0.05555,
                [3] = noAnimation,
                [4] = randomTimestamp
            }
            RFChargeFishingRod:InvokeServer(unpack(args))
        end
    end)
end

local function StartMinigame()
    pcall(function()
        if fishingMode == "Fast" then
            -- Mode Fast dengan args tetap
            RFRequestFishingMinigame:InvokeServer(-1, 0.0999, noAnimation)
        elseif fishingMode == "Random Result" then
            -- Mode Random Result dengan timestamp acak
            local randomTimestamp = tick() + math.random(100000, 999999)
            local args = {
                [1] = -1,
                [2] = 0.0999,
                [3] = noAnimation,
                [4] = randomTimestamp
            }
            RFRequestFishingMinigame:InvokeServer(unpack(args))
        end
    end)
end

local function Complete()
    pcall(function()
        REFishingCompleted:FireServer({})
    end)
end

------------------------------------------------------------
-- 🔥 PERFECT INSTANT FISHING (MATCH REMOTE ORANG)
------------------------------------------------------------
local function instantCycle()
    if isFishing then return end
    isFishing = true

    task.spawn(function()

        -- CANCEL 1
        Cancel()
        task.wait()

        -- CAST 1
        Cast()
        task.wait()

        -- CANCEL 2
        Cancel()
        task.wait()

        -- CAST 2 (CAST VALID)
        Cast()

        -- START MINIGAME (3 ARGUMEN EXACT)
        StartMinigame()

        -- WAKTU SERVER (MENGGUNAKAN VARIABEL serverDelay)
        task.wait(serverDelay)

        -- COMPLETE CATCH
        Complete()

        isFishing = false
    end)
end

------------------------------------------------------------
-- 🔁 AUTO LOOP
------------------------------------------------------------
local function fishLoop()
    task.spawn(function()
        while autoFish do
            instantCycle()
            task.wait()
        end
    end)
end

------------------------------------------------------------
-- 🎣 UI PANEL
------------------------------------------------------------

local BlatantSection = AutoTab:Section({ Title = "Instan Fishing", Icon = "solar:hourglass-bold-duotone", Opened = false })

AutoTab:Dropdown({
    Title = "Fishing Mode",
    Multi = false, -- Ubah ke false karena hanya ingin memilih satu mode
    Values = { "Fast", "Random Result" },
    Default = "Fast", -- Default value
    Callback = function(selected)
        fishingMode = selected
    end
})


AutoTab:Toggle({
    Title = "Instan Fishing",
    Default = false,
    Callback = function(v)
        autoFish = v
        if v then
            WindUI:Notify({ Title = "Instan Fishing", Content = "Instan Fishing Aktif - Memulai...", Duration = 1 })
            fishLoop()
        else
            isFishing = false
            WindUI:Notify({ Title = "Instan Fishing", Content = "Instan Fishing Nonaktif", Duration = 1 })
        end
    end
})

-- TAMBAHKAN INPUT DELAY DI SINI
AutoTab:Input({
    Title = "Delay Fishing",
    Desc = "Sesuaikan jika ikan lolos.",
    Value = tostring(serverDelay),
    Placeholder = "Masukkan nilai (0.1-10)",
    Callback = function(input)
        local value = tonumber(input)
        if value and value >= 0.1 and value <= 10 then
            serverDelay = value
        end
    end
})

------------------------------------------------------------
-- 💰 AUTO SELL LOOP
------------------------------------------------------------
local delaySell = 5 -- default (detik)
local autoSell = false

task.spawn(function()
    while true do
        if autoSell then
            pcall(function()
                if RFSellAllItems then
                    RFSellAllItems:InvokeServer()
                end
            end)
            task.wait(delaySell) -- tunggu sesuai delay
        else
            task.wait(0.3) -- hemat CPU
        end
    end
end)

local AutoSellSection = AutoTab:Section({ Title = "Selling", Icon = "solar:dollar-bold", Opened = false })

AutoTab:Toggle({
    Title = "Sell All Fish",
    Default = false,
    Callback = function(v)
        autoSell = v
    end
})

AutoTab:Input({
    Title = "Sell Delay",
    Desc = "Waktu jeda antar Sell All (1 - 600 Detik).",
    Value = "1",
    Placeholder = "Misal: 1 - 600",
    Callback = function(input)
        local value = tonumber(input)
        if value and value >= 1 and value <= 600 then
            delaySell = value 
        end
    end
})

-- auto buy weather

local RFPurchaseWeatherEvent = RF("RF/PurchaseWeatherEvent")

local function BuyWeather(type)
    pcall(function()
        RFPurchaseWeatherEvent:InvokeServer(type)
    end)
end

-- WAJIB! Defaultkan jadi table kosong
local selectedWeathers = {}

local function BuyAllSelectedWeather()
    for _, weather in ipairs(selectedWeathers) do
        BuyWeather(weather)
        task.wait(0.2)
    end
end

local autoBuyWeather = false
local buyInterval = 60 -- default 1 menit

task.spawn(function()
    while task.wait() do
        if autoBuyWeather then
            task.wait(buyInterval)
            if autoBuyWeather then
                BuyAllSelectedWeather()
            end
        end
    end
end)

local BuySection = AutoTab:Section({
    Title = "Auto Buy Weather",
    Icon = "solar:cloud-storm-bold",
    Opened = false
})

AutoTab:Toggle({
    Title = "Auto Buy Weather",
    Default = false,
    Callback = function(v)
        autoBuyWeather = v
    end
})

AutoTab:Dropdown({
    Title = "Weather Type",
    Multi = true,
    Values = { "Storm", "Wind", "Cloudy", "Radiant" },
    Default = {},
    Callback = function(selectedList)
        selectedWeathers = selectedList
    end
})

AutoTab:Input({
    Title = "Interval Pembelian (detik)",
    Desc = "1 - 60 detik.",
    Value = "1",
    Placeholder = "Masukkan detik",
    Callback = function(input)
        local value = tonumber(input)
        if value and value >= 1 and value <= 60 then
            buyInterval = value -- FIXED!!
        end
    end
})

local AnimationsTab = UiSection:Tab({
    Title = "Animations",
    Icon = "solar:sleeping-circle-bold",
    IconColor = Color3.fromHex("#FF9500"),
    IconShape = true,
})


------------------------------------------------------------
-- 📍 PLAYER / POSITION + NO ANIMATION (FULL & FIXED)
------------------------------------------------------------
local Players = game:GetService("Players")
local player = Players.LocalPlayer

------------------------------------------------------------
-- 📍 POSITION SECTION
------------------------------------------------------------
local PositionSection = AnimationsTab:Section({
    Title = "Position",
    Icon = "solar:lock-keyhole-bold",
    Opened = false
})

local autoLockPosition = false
local lockedCFrame = nil

------------------------------------------------------------
-- 🚫 NO ANIMATION
------------------------------------------------------------
local noAnimation = false
local animBlockConnection = nil

------------------------------------------------------------
-- 🔒 LOCK POSITION (SAFE)
------------------------------------------------------------
local function lockPosition()
    local char = player.Character
    if not char then return end

    local root = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not root or not humanoid then return end

    if not lockedCFrame then
        lockedCFrame = root.CFrame
    end

    humanoid.AutoRotate = false
    humanoid.WalkSpeed = 0
    humanoid.JumpPower = 0

    root.Anchored = true
    root.CFrame = lockedCFrame
end

------------------------------------------------------------
-- 🔓 UNLOCK POSITION (RESTORE NORMAL)
------------------------------------------------------------
local function unlockPosition()
    local char = player.Character
    if not char then return end

    local root = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not root or not humanoid then return end

    root.Anchored = false

    humanoid.AutoRotate = true
    humanoid.WalkSpeed = 16
    humanoid.JumpPower = 50
    humanoid:ChangeState(Enum.HumanoidStateType.Running)
end

------------------------------------------------------------
-- 🚫 ENABLE NO ANIMATION (VISUAL ONLY)
------------------------------------------------------------
local function enableNoAnimation()
    local char = player.Character
    if not char then return end

    local humanoid = char:FindFirstChildOfClass("Humanoid")
    local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
    if not humanoid or not animator then return end

    -- Stop semua animasi yang sedang jalan
    for _, track in ipairs(humanoid:GetPlayingAnimationTracks()) do
        track:Stop(0)
    end

    -- Block animasi baru
    animBlockConnection = animator.AnimationPlayed:Connect(function(track)
        track:Stop(0)
    end)
end

------------------------------------------------------------
-- 🔊 DISABLE NO ANIMATION
------------------------------------------------------------
local function disableNoAnimation()
    if animBlockConnection then
        animBlockConnection:Disconnect()
        animBlockConnection = nil
    end

    local char = player.Character
    if not char then return end

    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid:ChangeState(Enum.HumanoidStateType.Running)
    end
end

------------------------------------------------------------
-- 🔁 MAINTAIN LOCK LOOP
------------------------------------------------------------
task.spawn(function()
    while task.wait(0.1) do
        if autoLockPosition then
            pcall(lockPosition)
        end
    end
end)

------------------------------------------------------------
-- 🔁 RESPAWN HANDLER
------------------------------------------------------------
player.CharacterAdded:Connect(function()
    task.wait(1)
    lockedCFrame = nil

    if autoLockPosition then
        lockPosition()
    end

    if noAnimation then
        enableNoAnimation()
    end
end)

------------------------------------------------------------
-- 🔘 TOGGLES
------------------------------------------------------------
AnimationsTab:Toggle({
    Title = "Lock Position",
    Default = false,
    Callback = function(v)
        autoLockPosition = v
        if v then
            lockedCFrame = nil
        else
            unlockPosition()
        end
    end
})

AnimationsTab:Toggle({
    Title = "Disable Animation",
    Default = false,
    Callback = function(v)
        noAnimation = v
        if v then
            enableNoAnimation()
        else
            disableNoAnimation()
        end
    end
})

local AnimationSection = AnimationsTab:Section({
    Title = "Animation Controls",
    Icon = "solar:play-bold",
    Opened = false
})

-- ==========================================================
-- >>>>> SISTEM LOOP ANIMASI YANG BISA DILIHAT ORANG LAIN <<<<<
-- ==========================================================
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local isLooping = false
local loopCoroutine = nil
local animationTracks = {} -- Menyimpan track yang sedang dimainkan
local selectedAnimation = "The Vanquisher" -- Animasi yang dipilih

-- Koleksi ID Animasi untuk setiap item
local animationSets = {
        ["Frozen Scythe"] = {
        equipIdle = "rbxassetid://124265469726043",
        rodThrow = "rbxassetid://96196869100887",
        reeling = "rbxassetid://98716967215984",
        caught = "rbxassetid://134934781977605"
    },
    ["The Vanquisher"] = {
        equipIdle = "rbxassetid://123194574699925",
        rodThrow = "rbxassetid://102380394663862",
        reeling = "rbxassetid://138790747812051",
        caught = "rbxassetid://93884986836266"
    },
    ["Eclipse Katana"] = {
        equipIdle = "rbxassetid://103641983335689",
        rodThrow = "rbxassetid://82600073500966",
        reeling = "rbxassetid://115229621326605",
        caught = "rbxassetid://107940819382815"
    },
    ["Princess Parasol"] = {
        equipIdle = "rbxassetid://79754634120924",
        rodThrow = "rbxassetid://108621937425425",
        reeling = "rbxassetid://104188512165442",
        caught = "rbxassetid://99143072029495"
    },
    ["Soul Scythe"] = {
        equipIdle = "rbxassetid://84686809448947",
        rodThrow = "rbxassetid://104946400643250",
        reeling = "rbxassetid://139621583239992",
        caught = "rbxassetid://82259219343456"
    },
    ["Holy Trident"] = {
        equipIdle = "rbxassetid://83219020397849",
        rodThrow = "rbxassetid://114917462794864",
        reeling = "rbxassetid://126831815839724",
        caught = "rbxassetid://128167068291703"
    },
    ["1x1x1x1 Ban Hammer"] = {
        equipIdle = "rbxassetid://81302570422307",
        rodThrow = "rbxassetid://123133988645038",
        reeling = "rbxassetid://74643095451174",
        caught = "rbxassetid://96285280763544"
    },
    ["Corruption Edge"] = {
        equipIdle = "rbxassetid://93958525241489",
        rodThrow = "rbxassetid://84892442268560",
        reeling = "rbxassetid://110738276580375",
        caught = "rbxassetid://126613975718573"
    },
    ["Binary Edge"] = {
        equipIdle = "rbxassetid://103714544264522",
        rodThrow = "rbxassetid://104527781253009",
        reeling = "rbxassetid://81700883907369",
        caught = "rbxassetid://109653945741202"
    }
}

-- Fungsi untuk memainkan animasi yang TER-REPLIKASI
local function playAnimation(animName)
    local character = player.Character
    if not character then return end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

    -- Cari atau buat Animator. Ini KUNCI untuk replikasi.
    local animator = humanoid:FindFirstChildOfClass("Animator")
    if not animator then
        animator = Instance.new("Animator")
        animator.Parent = humanoid
    end

    local animId = animationSets[selectedAnimation][animName]
    if not animId then return end

    pcall(function()
        -- Hentikan animasi sebelumnya dari sistem ini
        for _, track in pairs(animationTracks) do
            if track and track.IsPlaying then
                track:Stop()
            end
        end
        animationTracks = {}

        -- Buat objek animasi dan PARENT ke karakter
        local animation = Instance.new("Animation")
        animation.AnimationId = animId
        animation.Name = "animated" .. animName
        animation.Parent = character -- PARENTING KE KARAKTER ADALAH WAJIB

        -- Muat animasi menggunakan Animator, bukan Humanoid
        local track = animator:LoadAnimation(animation)
        track.Priority = Enum.AnimationPriority.Action
        track:Play()
        
        animationTracks[animName] = track
    end)
end

-- Fungsi loop utama
local function startLoop()
    if isLooping then return end
    isLooping = true

    loopCoroutine = task.spawn(function()
        -- Mainkan animasi equip sekali di awal
        playAnimation("equipIdle")
        task.wait(0.5)

        -- Loop utama
        while isLooping do
            playAnimation("rodThrow")
            task.wait(1) -- Durasi animasi lempar
            
            playAnimation("reeling")
            task.wait(2.5) -- Durasi animasi menunggu

            playAnimation("caught")
            task.wait(0.5) -- Durasi animasi caught
        end
    end)
end

-- Fungsi untuk menghentikan loop
local function stopLoop()
    isLooping = false
    if loopCoroutine then
        task.cancel(loopCoroutine)
        loopCoroutine = nil
    end
    
    -- Hentikan semua animasi yang sedang berjalan
    for _, track in pairs(animationTracks) do
        if track and track.IsPlaying then
            track:Stop()
        end
    end
    animationTracks = {}
end

-- ====== UI ELEMENTS ======
AnimationsTab:Paragraph({
    Title = "NOTE:",
    Desc = "Pilih animasi dari dropdown lalu aktifkan dengan toggle.",
})

-- Dropdown untuk memilih animasi
AnimationsTab:Dropdown({
    Title = "Pilih Animasi",
    Values = {
        "Frozen Scythe",
        "The Vanquisher",
        "Eclipse Katana",
        "Princess Parasol",
        "Soul Scythe",
        "Holy Trident",
        "1x1x1x1 Ban Hammer",
        "Corruption Edge",
        "Binary Edge"
    },
    Default = "Eclipse Katana",
    Callback = function(option)
        selectedAnimation = option
        WindUI:Notify({ Title = "Animasi Dipilih", Content = "Animasi: " .. option, Duration = 2 })
        
        -- Jika animasi sedang berjalan, hentikan dan mulai ulang dengan animasi baru
        if isLooping then
            stopLoop()
            startLoop()
        end
    end
})

-- Toggle untuk memulai/menghentikan animasi
AnimationsTab:Toggle({
    Title = "Aktifkan Animasi",
    Default = false,
    Callback = function(v)
        if v then
            startLoop()
            WindUI:Notify({ Title = "Loop Animations", Content = "Animasi dimulai (Orang lain bisa lihat)!", Duration = 2 })
        else
            stopLoop()
            WindUI:Notify({ Title = "Loop Animations", Content = "Animasi dihentikan.", Duration = 2 })
        end
    end
})

------------------------------------------------------------
-- 🗺 TAB TELEPORTATION (TELAH DIPERBAIKI DAN DIGABUNG)
------------------------------------------------------------
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

-- Pastikan karakter siap saat respawn
LocalPlayer.CharacterAdded:Connect(function(newChar)
    character = newChar
    newChar:WaitForChild("HumanoidRootPart")
    WindUI:Notify({
        Title = "Respawn Detected",
        Content = "Karakter baru terdeteksi — sistem teleport siap!",
        Duration = 3
    })
end)

-- --- DATA LOKASI ---

-- 1. Data untuk Teleportasi Biasa
local teleportLocations = {
    ["Fisherman Island"] = Vector3.new(34, 9, 2809),
    ["Fisherman Island Right"] = Vector3.new(95, 9, 2686),
    ["Fisherman Island Left"] = Vector3.new(-28, 9, 2689),
    ["Kohana"] = Vector3.new(-357, 4, 486 ),
    ["Kohana Spot"] = Vector3.new(-585, 17, 458),
    ["Kohana Volcano"] = Vector3.new(-562, 21, 156),
    ["Coral Refs"] = Vector3.new(-3272, 2, 2232),
    ["Coral Refs Spot"] = Vector3.new(-3021, 2, 2262),
    ["Esoteric Depths Enchant"] = Vector3.new(3232, -1303, 1401),
    ["Esoteric Depths Spot"] = Vector3.new(3200, -1303, 1429),
    ["Tropical Grove"] = Vector3.new(-2019, 9, 3750),
    ["Tropical Grove Spot"] = Vector3.new(-2151, 2, 3671),
    ["Crater Island"] = Vector3.new(1052, 2, 5022),
    ["Sysyphus Statue"] = Vector3.new(-3702, -136, -1016),
    ["Treasure Room"] = Vector3.new(-3603, -267, -1578),
    ["Ancient Jungle"] = Vector3.new(1260, 7, -165),
    ["Ancient Jungle Spot"] = Vector3.new(1496, 7, -433),
    ["Sacred Temple"] = Vector3.new(1475, -22, -632),
    ["Acient Ruin"] = Vector3.new(6089, -586, 4635),
    ["Underground Cellar"] = Vector3.new(2134, -92, -692),
    ["Classic Island"] = Vector3.new(1255, 9, 2817),
    ["Iron Cavern"] = Vector3.new(-8869, -582, 156),
    ["Iron Cafe"] = Vector3.new(-8634, -549, 161),
    ["Christmas Island"] = Vector3.new(693, 7, 1564),
    ["Christmas Island Spot 1"] = Vector3.new(1179, 24, 1548),
    ["Christmas Cave"] = Vector3.new(745, -487, 8858),
    ["Christmas Cave Spot 1"] = Vector3.new(579, -581, 8931)
}

-- 2. Data untuk Event & Anti Report (menggunakan CFrame untuk rotasi)
local EventData = {
    -- Lokasi Event
    ["Megalodon"] = CFrame.new(Vector3.new(-1075, 3, 1680), Vector3.new(0, 0, 0)),
    ["Worm Hunt"] = CFrame.new(Vector3.new(-2446, 2, 147), Vector3.new(0, 0, 0)),
    ["Ancient Lochness"] = CFrame.new(Vector3.new(6084, -585, 4635)) * CFrame.Angles(0, math.rad(130), 0),
    -- Lokasi Anti Report
    ["Kohana 1"] = CFrame.new(Vector3.new(-534, 6, 365), Vector3.new(0, 0, 0)),
    ["Kohana 2"] = CFrame.new(Vector3.new(-409, 1, 508)) * CFrame.Angles(0, math.rad(130), 0),
    ["Corral 1"] = CFrame.new(Vector3.new(-409, 1, 508)) * CFrame.Angles(0, math.rad(130), 0),
    ["Corral 2"] = CFrame.new(Vector3.new(-2940, 3, 2258), Vector3.new(0, 0, 0)),
    ["ESO"] = CFrame.new(Vector3.new(3338, -1317, 1379), Vector3.new(0, 0, 0)),
    ["Tropical"] = CFrame.new(Vector3.new(-2078, 2, 3862), Vector3.new(0, 0, 0)),
    ["Create"] = CFrame.new(Vector3.new(1015, 5, 5086), Vector3.new(0, 0, 0)),
    ["Jungle"] = CFrame.new(Vector3.new(1340, 2, -306), Vector3.new(0, 0, 0)),
    ["Temple"] = CFrame.new(Vector3.new(1417, -30, -681), Vector3.new(0, 0, 0)),
    ["Acient Ruin"] = CFrame.new(Vector3.new(6073, -565, 4564), Vector3.new(0, 0, 0)),
    ["Classic"] = CFrame.new(Vector3.new(1316, 9, 2853), Vector3.new(0, 0, 0)),
    ["Iron Cavern"] = CFrame.new(Vector3.new(-8758, -586, 46), Vector3.new(0, 0, 0)),
}

-- --- VARIABEL & LOGIKA UNTUK FREEZE ---

local selectedEventName = "Megalodon" -- Default yang ADA di tabel EventData
local autoLockPosition = false
local eventCFrame = EventData[selectedEventName] -- Inisialisasi aman

local function unlockPosition()
    local char = LocalPlayer.Character
    if not char then return end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.PlatformStand = false
        humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
    end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then part.Anchored = false end
    end
end

local function lockPosition()
    local char = LocalPlayer.Character
    if not char or not char.PrimaryPart or not eventCFrame then return end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid:ChangeState(Enum.HumanoidStateType.Physics)
        humanoid.PlatformStand = true
        for _, track in ipairs(humanoid:GetPlayingAnimationTracks()) do track:Stop(0) end
    end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then part.Anchored = true end
    end
    char.PrimaryPart.CFrame = eventCFrame
end

task.spawn(function()
    while task.wait(0.1) do
        if autoLockPosition then pcall(lockPosition) end
    end
end)

LocalPlayer.CharacterAdded:Connect(function(newCharacter)
    task.wait(1.5)
    if autoLockPosition and eventCFrame then
        pcall(function() newCharacter:SetPrimaryPartCFrame(eventCFrame) end)
    end
end)


-- --- PEMBUATAN TAB & UI ---

local TeleTab = UiSection:Tab({
    Title = "Teleportation",
    Icon = "solar:map-point-rotate-bold",
    IconColor = Color3.fromHex("#34C759"),
    IconShape = true,
})

-- Section untuk Teleportasi Biasa
local TeleportationSection = TeleTab:Section({
    Title = "Teleportation",
    Icon = "solar:star-fall-2-bold",
    Opened = false
})

TeleTab:Dropdown({
    Title = "Pilih Lokasi",
    Values = {"Fisherman Island", "Fisherman Island Right", "Fisherman Island Left", "Kohana", "Kohana Spot", "Kohana Volcano", "Coral Refs", "Coral Refs Spot", "Esoteric Depths Enchant", "Esoteric Depths Spot", "Tropical Grove", "Tropical Grove Spot", "Crater Island", "Sysyphus Statue", "Treasure Room", "Ancient Jungle", "Ancient Jungle Spot", "Sacred Temple", "Acient Ruin", "Underground Cellar", "Classic Island", "Iron Cavern", "Iron Cafe", "Christmas Island", "Christmas Island Spot 1", "Christmas Cave", "Christmas Cave Spot 1"},
    Default = "Fisherman Island",
    Callback = function(v)
        local selectedLocation = teleportLocations[v]
        if selectedLocation then
            character:MoveTo(selectedLocation)
            WindUI:Notify({
                Title = "Teleport",
                Content = "Berhasil teleport ke " .. v,
                Duration = 3
            })
        end
    end
})

TeleTab:Button({
    Title = "Sell Area",
    Icon = "solar:tea-cup-bold",
    Callback = function()
        character:MoveTo(Vector3.new(45, 17, 2867))
        WindUI:Notify({
            Title = "Teleport",
            Content = "Berhasil teleport ke area penjualan!",
            Duration = 3
        })
    end
})

-- Section untuk Event
local EventSection = TeleTab:Section({ Title = "Event & Anti Report", Icon = "solar:station-linear", Opened = false })

TeleTab:Dropdown({
    Title = "Select Event",
    Values = { "Megalodon", "Worm Hunt", "Ancient Lochness" },
    Default = selectedEventName,
    Callback = function(option)
        selectedEventName = option
        eventCFrame = EventData[option]
        WindUI:Notify({ Title = "Event Dipilih", Content = "Lokasi: " .. option, Duration = 2 })
    end
})

TeleTab:Dropdown({
    Title = "Anti Report Location",
    Values = { "Acient Ruin", "Kohana 1", "Kohana 2", "Corral 1", "Corral 2", "ESO", "Tropical", "Create", "Jungle", "Temple", "Classic", "Iron Cavern" },
    Default = "Kohana 1",
    Callback = function(option)
        selectedEventName = option
        eventCFrame = EventData[option]
        WindUI:Notify({ Title = "Lokasi Dipilih", Content = "Lokasi: " .. option, Duration = 2 })
    end
})

TeleTab:Toggle({
    Title = "Enable Teleport & Freeze",
    Desc = "Teleport ke lokasi yang dipilih (Event/Anti Report) dan bekukan posisi.",
    Default = autoLockPosition,
    Callback = function(v)
        autoLockPosition = v
        if v then
            if eventCFrame then
                pcall(function() LocalPlayer.Character:SetPrimaryPartCFrame(eventCFrame) end)
                WindUI:Notify({ Title = "Teleport", Content = "Berhasil teleport dan membekukan posisi.", Duration = 2 })
            else
                WindUI:Notify({ Title = "Error", Content = "Pilih lokasi Event/Anti Report terlebih dahulu!", Duration = 3 })
                autoLockPosition = false -- Kembalikan toggle ke off
            end
        else
            pcall(unlockPosition)
            WindUI:Notify({ Title = "Teleport", Content = "Posisi dibebaskan.", Duration = 2 })
        end
    end
})

------------------------------------------------------------
-- 🎯 AUTO QUEST TAB (HANYA TELEPORT)
------------------------------------------------------------
local AutoQuestTab = UiSection:Tab({
    Title = "Quest Rod",
    Icon = "solar:inbox-in-bold",
    IconColor = Color3.fromHex("#FF2D55"),
    IconShape = true,
})

-- Variabel untuk sistem quest
local selectedQuestLocation = ""
local isQuestActive = false
local questLocation = nil

-- Section untuk Misi Ghostfin
local GhostfinSection = AutoQuestTab:Section({ Title = "Quest Ghostfin", Icon = "solar:battery-low-minimalistic-bold"})

AutoQuestTab:Dropdown({
    Title = "Quest Location",
    Values = {
        "Catch 300 Rare/Epic",
        "Catch 3 Mythic Fish",
        "Catch 1 Secret Fish"
    },
    Default = "Catch 300 Rare/Epic",
    Callback = function(option)
        selectedQuestLocation = option
        if option == "Catch 300 Rare/Epic" then
            questLocation = Vector3.new(-3608, -280, -1590)
        elseif option == "Catch 3 Mythic Fish" then
            questLocation = Vector3.new(-3729, -136, -1013)
        elseif option == "Catch 1 Secret Fish" then
            questLocation = Vector3.new(-3729, -136, -1013)
        end
        WindUI:Notify({ Title = "Quest Dipilih", Content = "Lokasi: " .. option, Duration = 2 })
    end
})

AutoQuestTab:Toggle({
    Title = "Start Quest",
    Default = false,
    Callback = function(v)
        isQuestActive = v
        if v then
            if not questLocation then
                WindUI:Notify({ Title = "Error", Content = "Pilih lokasi quest terlebih dahulu!", Duration = 3 })
                -- Matikan toggle jika tidak ada lokasi
                -- Note: Fitur auto-matikan toggle dihapus untuk kesederhanaan
                isQuestActive = false
                return
            end
            
            WindUI:Notify({ Title = "Start Quest", Content = "Memulai auto teleport ke lokasi quest...", Duration = 2 })
            
            task.spawn(function()
                while isQuestActive do
                    local character = player.Character
                    if character and character:FindFirstChild("HumanoidRootPart") then
                        character.HumanoidRootPart.CFrame = CFrame.new(questLocation)
                    end
                    
                    -- Tunggu 5 detik sebelum teleport lagi (untuk menghindari lag)
                    task.wait(1)
                end
            end)
        else
            WindUI:Notify({ Title = "Auto Quest", Content = "Auto teleport dihentikan.", Duration = 2 })
        end
    end
})


-- Section untuk Misi element rod
local ElementRodSection = AutoQuestTab:Section({ Title = "Quest Element Rod", Icon = "solar:battery-charge-minimalistic-bold", Opened = false })

AutoQuestTab:Dropdown({
    Title = "Quest Artifact Location",
    Values = {
        "Hourglass Diamond Artifact",
        "Crescent Artifact",
        "Arrow Artifact",
        "Diamond Artifact"
    },
    Default = "Hourglass Diamond Artifact",
    Callback = function(option)
        selectedQuestLocation = option
        if option == "Hourglass Diamond Artifact" then
            questLocation = Vector3.new(1478, 4, -845)
        elseif option == "Crescent Artifact" then
            questLocation = Vector3.new(1406, 3, 123)
        elseif option == "Arrow Artifact" then
            questLocation = Vector3.new(876, 2, -341)
        elseif option == "Diamond Artifact" then
            questLocation = Vector3.new(1840, 3, -299)
        end
        WindUI:Notify({ Title = "Quest Dipilih", Content = "Lokasi: " .. option, Duration = 2 })
    end
})

AutoQuestTab:Toggle({
    Title = "Start Quest",
    Default = false,
    Callback = function(v)
        isQuestActive = v
        if v then
            if not questLocation then
                WindUI:Notify({ Title = "Error", Content = "Pilih lokasi quest terlebih dahulu!", Duration = 3 })
                -- Matikan toggle jika tidak ada lokasi
                -- Note: Fitur auto-matikan toggle dihapus untuk kesederhanaan
                isQuestActive = false
                return
            end
            
            WindUI:Notify({ Title = "Start Quest", Content = "Memulai auto teleport ke lokasi quest...", Duration = 2 })
            
            task.spawn(function()
                while isQuestActive do
                    local character = player.Character
                    if character and character:FindFirstChild("HumanoidRootPart") then
                        character.HumanoidRootPart.CFrame = CFrame.new(questLocation)
                    end
                    
                    -- Tunggu 5 detik sebelum teleport lagi (untuk menghindari lag)
                    task.wait(1)
                end
            end)
        else
            WindUI:Notify({ Title = "Start Quest", Content = "Auto teleport dihentikan.", Duration = 2 })
        end
    end
})

AutoQuestTab:Dropdown({
    Title = "Catch 1 secret Outdoor",
    Values = {
        "Best Location 1",
        "Best Location 2",
        "Best Location 3"
    },
    Default = "Best Location 1",
    Callback = function(option)
        selectedQuestLocation = option
        if option == "Best Location 1" then
            questLocation = Vector3.new(1467, 7, -336)
        elseif option == "Best Location 2" then
            questLocation = Vector3.new(1498, 7, -446)
        elseif option == "Best Location 3" then
            questLocation = Vector3.new(1368, 3, -165)
        end
        WindUI:Notify({ Title = "Lokasi Dipilih", Content = "Lokasi: " .. option, Duration = 2 })
    end
})

AutoQuestTab:Toggle({
    Title = "Go To Location",
    Default = false,
    Callback = function(v)
        isQuestActive = v
        if v then
            if not questLocation then
                WindUI:Notify({ Title = "Error", Content = "Pilih lokasi quest terlebih dahulu!", Duration = 3 })
                -- Matikan toggle jika tidak ada lokasi
                -- Note: Fitur auto-matikan toggle dihapus untuk kesederhanaan
                isQuestActive = false
                return
            end
            
            WindUI:Notify({ Title = "Start Quest", Content = "Memulai auto teleport ke lokasi quest...", Duration = 2 })
            
            task.spawn(function()
                while isQuestActive do
                    local character = player.Character
                    if character and character:FindFirstChild("HumanoidRootPart") then
                        character.HumanoidRootPart.CFrame = CFrame.new(questLocation)
                    end
                    
                    -- Tunggu 5 detik sebelum teleport lagi (untuk menghindari lag)
                    task.wait(1)
                end
            end)
        else
            WindUI:Notify({ Title = "Start Quest", Content = "Auto teleport dihentikan.", Duration = 2 })
        end
    end
})

------------------------------------------------------------
-- 👤 TAB PLAYER (MOVEMENT & POSITION)
------------------------------------------------------------
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local RunService = game:GetService("RunService")
local camera = workspace.CurrentCamera

local PlayerTab = UiSection:Tab({
    Title = "Player Settings",
    Icon = "solar:emoji-funny-circle-bold",
    IconColor = Color3.fromHex("#5856D6"),
    IconShape = true,
})

------------------------------------------------------------
-- ✈ MOVEMENT SECTION
------------------------------------------------------------
local flying = false
local ascending = false
local descending = false
local bodyGyro, bodyVel, hbConn
local flySpeed = 100
local SMOOTH_FACTOR = 10

-- Noclip variables
local noclipEnabled = false
local noclipConnection

local function startFlight(char)
    if bodyGyro or bodyVel then return end
    if not (char and char.Parent) then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChild("Humanoid")
    if not (hrp and hum and camera) then return end

    hum.PlatformStand = true
    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.P = 9e4
    bodyGyro.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
    bodyGyro.Parent = hrp

    bodyVel = Instance.new("BodyVelocity")
    bodyVel.MaxForce = Vector3.new(1e9, 1e9, 1e9)
    bodyVel.Velocity = Vector3.zero
    bodyVel.Parent = hrp

    hbConn = RunService.Heartbeat:Connect(function(dt)
        if not (bodyGyro and bodyVel) then return end
        local c = player.Character
        if not c then return end

        local hrp2 = c:FindFirstChild("HumanoidRootPart")
        local hum2 = c:FindFirstChild("Humanoid")
        if not (hrp2 and hum2) then return end

        hum2.PlatformStand = true
        local velocity = Vector3.zero
        local lookVector = camera.CFrame.LookVector
        local moveDir = hum2.MoveDirection

        if moveDir.Magnitude > 0 then
            velocity = lookVector * flySpeed
        end
        if ascending then
            velocity += Vector3.new(0, flySpeed, 0)
        elseif descending then
            velocity += Vector3.new(0, -flySpeed, 0)
        end

        bodyVel.Velocity = bodyVel.Velocity:Lerp(velocity, math.clamp(SMOOTH_FACTOR * dt, 0, 1))
        bodyGyro.CFrame = CFrame.lookAt(hrp2.Position, hrp2.Position + camera.CFrame.LookVector)
    end)
end

local function stopFlight()
    if hbConn then hbConn:Disconnect() end
    local c = player.Character
    local hum = c and c:FindFirstChild("Humanoid")
    if hum then hum.PlatformStand = false end
    if bodyGyro then bodyGyro:Destroy() end
    if bodyVel then bodyVel:Destroy() end
    bodyGyro, bodyVel, hbConn = nil, nil, nil
end

-- Noclip function
local function enableNoclip()
    if noclipConnection then noclipConnection:Disconnect() end
    
    noclipConnection = RunService.Stepped:Connect(function()
        if not noclipEnabled then return end
        local character = player.Character
        if not character then return end
        
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide == true then
                part.CanCollide = false
            end
        end
    end)
end

local function disableNoclip()
    if noclipConnection then 
        noclipConnection:Disconnect()
        noclipConnection = nil
    end
    
    local character = player.Character
    if not character then return end
    
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = true
        end
    end
end

-- === Infinite Jump, WalkSpeed, JumpHeight, FOV ===
local infJumpEnabled = false
local CurrentWalkSpeed = 16
local PermanentSpeed = false
local LastHumanoid

local function applySpeed(h)
    if PermanentSpeed and h and h.WalkSpeed ~= CurrentWalkSpeed then
        h.WalkSpeed = CurrentWalkSpeed
    end
end

player.CharacterAdded:Connect(function(c)
    task.defer(function()
        local h = c:FindFirstChildOfClass("Humanoid")
        if h then
            LastHumanoid = h
            applySpeed(h)
        end
        
        -- Re-enable noclip if it was active when character respawned
        if noclipEnabled then
            task.wait(0.5)
            enableNoclip()
        end
    end)
end)

RunService.Heartbeat:Connect(function()
    local c = player.Character
    if not c then return end
    local h = c:FindFirstChildOfClass("Humanoid")
    if not h then return end
    if h ~= LastHumanoid then
        LastHumanoid = h
        applySpeed(h)
    elseif h.WalkSpeed ~= CurrentWalkSpeed then
        applySpeed(h)
    end
end)

local MovementSection = PlayerTab:Section({
    Title = "Movement",
    Icon = "solar:skateboarding-bold",
    Opened = false  -- Membuat section tetap terbuka (non-dropdown)
})

PlayerTab:Toggle({
    Title = "Fly Mode",
    Default = false,
    Callback = function(state)
        flying = state
        if flying then startFlight(player.Character) else stopFlight() end
    end
})

PlayerTab:Input({
    Title = "Fly Speed",
    Desc = "Kecepatan terbang (10-200)",
    Value = tostring(flySpeed),
    Placeholder = "Masukkan nilai (10-200)",
    Callback = function(input)
        local value = tonumber(input)
        if value and value >= 10 and value <= 200 then
            flySpeed = value
        end
    end
})

PlayerTab:Toggle({
    Title = "Noclip",
    Default = false,
    Callback = function(state)
        noclipEnabled = state
        if noclipEnabled then
            enableNoclip()
            WindUI:Notify({
                Title = "Noclip",
                Content = "Noclip diaktifkan! Anda dapat melewati objek.",
                Duration = 2
            })
        else
            disableNoclip()
            WindUI:Notify({
                Title = "Noclip",
                Content = "Noclip dinonaktifkan!",
                Duration = 2
            })
        end
    end
})

PlayerTab:Toggle({
    Title = "Infinite Jump",
    Default = false,
    Callback = function(state)
        infJumpEnabled = state
        local UIS = game:GetService("UserInputService")
        UIS.JumpRequest:Connect(function()
            if infJumpEnabled and player.Character then
                local h = player.Character:FindFirstChildOfClass("Humanoid")
                if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
            end
        end)
    end
})

PlayerTab:Input({
    Title = "WalkSpeed",
    Desc = "Kecepatan berjalan (10-100)",
    Value = tostring(CurrentWalkSpeed),
    Placeholder = "Masukkan nilai (10-100)",
    Callback = function(input)
        local value = tonumber(input)
        if value and value >= 10 and value <= 100 then
            CurrentWalkSpeed = math.floor(value)
            if PermanentSpeed and player.Character then
                local h = player.Character:FindFirstChildOfClass("Humanoid")
                if h then h.WalkSpeed = CurrentWalkSpeed end
            end
        end
    end
})

PlayerTab:Toggle({
    Title = "Permanent Speed",
    Default = false,
    Callback = function(v)
        PermanentSpeed = v
        local h = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        if h then h.WalkSpeed = v and CurrentWalkSpeed or 16 end
    end
})

PlayerTab:Input({
    Title = "JumpHeight",
    Desc = "Tinggi lompatan (20-200)",
    Value = "50",
    Placeholder = "Masukkan nilai (20-200)",
    Callback = function(input)
        local value = tonumber(input)
        if value and value >= 20 and value <= 200 then
            local h = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
            if h then
                if h.UseJumpPower then h.JumpPower = value else h.JumpHeight = value / 10 end
            end
        end
    end
})

PlayerTab:Input({
    Title = "Sudut Pandang (FOV)",
    Desc = "Field of View (60-120)",
    Value = "70",
    Placeholder = "Masukkan nilai (60-120)",
    Callback = function(input)
        local value = tonumber(input)
        if value and value >= 60 and value <= 120 then
            if camera then camera.FieldOfView = value end
        end
    end
})

PlayerTab:Button({
    Title = "Reset Default",
    Callback = function()
        local h = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        if h then
            h.WalkSpeed = 16
            if h.UseJumpPower then h.JumpPower = 50 else h.JumpHeight = 5 end
        end
        if camera then camera.FieldOfView = 70 end
        WindUI:Notify({
            Title = "Reset",
            Content = "Semua nilai dikembalikan ke default!",
            Duration = 3
        })
    end
})


-- 🧰 TOOLS TAB
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

local ToolsTab = UiSection:Tab({
    Title = "Player Tools", -- GradientText dihapus
    Icon = "solar:lightbulb-bolt-bold",
    IconColor = Color3.fromHex("#FF9500"),
    IconShape = true,
})

-- === SECTION 1: SHIFT LOCK ===
local ShiftLockSection = ToolsTab:Section({
    Title = "Shift Lock",
    Icon = "solar:lock-password-bold",
    Opened = false -- Section terbuka secara default
})

local shiftLockEnabled = false
local shiftLockMode = "Back"

-- Toggle Shift Lock di WindUI
ToolsTab:Toggle({
    Title = "Shiftlock", -- GradientText dihapus
    Default = false,
    Callback = function(state)
        shiftLockEnabled = state
        LocalPlayer.DevEnableMouseLock = state
        print("Shift Lock:", state and "ON ✅" or "OFF ❌")
    end,
})

-- Dropdown Front/Back Mode di WindUI
ToolsTab:Dropdown({
    Title = "Mode Shiftlock", -- GradientText dihapus
    Values = {"Back", "Front"},
    Default = shiftLockMode,
    Callback = function(value)
        shiftLockMode = value
        print("Shift Lock Mode:", shiftLockMode)
    end,
})

-- RenderStep update HumanoidRootPart orientation
RunService:BindToRenderStep("ShiftLockWindUI", Enum.RenderPriority.Camera.Value + 1, function()
    if shiftLockEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = LocalPlayer.Character.HumanoidRootPart
        local cam = workspace.CurrentCamera
        local dir = Vector3.new(cam.CFrame.LookVector.X, 0, cam.CFrame.LookVector.Z)
        if shiftLockMode == "Front" then
            dir = -dir
        end
        if dir.Magnitude > 0 then
            hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + dir)
        end
    end
end)


-- === SECTION 2: ESP ===
local ESPSection = ToolsTab:Section({
    Title = "ESP",
    Icon = "solar:benzene-ring-bold",
    Opened = false -- Section terbuka secara default
})

-- ====== ESP V2: Avatar + Rounded HealthBar ======
local espEnabled = false
local espConnections = {}

local function createESP(player)
    if player == LocalPlayer then return end
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end

    local hrp = player.Character:WaitForChild("HumanoidRootPart")
    local humanoid = player.Character:FindFirstChildOfClass("Humanoid")

    -- Buat Billboard GUI utama
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "LSxESP"
    billboard.AlwaysOnTop = true
    billboard.Size = UDim2.new(0, 230, 0, 60)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.Parent = hrp

    -- Frame utama (background semi transparan)
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(1, 0, 1, 0)
    mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    mainFrame.BackgroundTransparency = 0.3
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = billboard

    local cornerMain = Instance.new("UICorner")
    cornerMain.CornerRadius = UDim.new(0, 8)
    cornerMain.Parent = mainFrame

    -- Avatar (headshot)
    local avatar = Instance.new("ImageLabel")
    avatar.Size = UDim2.new(0, 45, 0, 45)
    avatar.Position = UDim2.new(0, 5, 0.5, -22)
    avatar.BackgroundTransparency = 1
    avatar.Image = "rbxthumb://type=AvatarHeadShot&id=" .. player.UserId .. "&w=100&h=100"
    avatar.Parent = mainFrame

    local avatarCorner = Instance.new("UICorner")
    avatarCorner.CornerRadius = UDim.new(1, 0)
    avatarCorner.Parent = avatar

    -- Nama Player
    local nameLabel = Instance.new("TextLabel")
    nameLabel.BackgroundTransparency = 1
    nameLabel.Size = UDim2.new(1, -60, 0.5, 0)
    nameLabel.Position = UDim2.new(0, 60, 0, 2)
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextStrokeTransparency = 0.5
    nameLabel.TextScaled = true
    nameLabel.Text = player.DisplayName .. " (@" .. player.Name .. ")"
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Parent = mainFrame

    -- Frame untuk Health Bar
    local hpFrame = Instance.new("Frame")
    hpFrame.Size = UDim2.new(1, -75, 0, 10)
    hpFrame.Position = UDim2.new(0, 60, 1, -15)
    hpFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    hpFrame.BorderSizePixel = 0
    hpFrame.Parent = mainFrame

    local hpCorner = Instance.new("UICorner")
    hpCorner.CornerRadius = UDim.new(0, 6)
    hpCorner.Parent = hpFrame

    local hpBar = Instance.new("Frame")
    hpBar.Size = UDim2.new(1, 0, 1, 0)
    hpBar.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
    hpBar.BorderSizePixel = 0
    hpBar.Parent = hpFrame

    local hpBarCorner = Instance.new("UICorner")
    hpBarCorner.CornerRadius = UDim.new(0, 6)
    hpBarCorner.Parent = hpBar

    -- Update HealthBar real-time
    local conn = RunService.RenderStepped:Connect(function()
        if not espEnabled or not player.Character or not player.Character:FindFirstChild("Humanoid") then
            billboard.Enabled = false
            return
        end
        billboard.Enabled = true
        local health = player.Character.Humanoid.Health
        local maxHealth = player.Character.Humanoid.MaxHealth
        hpBar.Size = UDim2.new(math.clamp(health / maxHealth, 0, 1), 0, 1, 0)

        -- Warna HP berubah sesuai health
        if health / maxHealth > 0.6 then
            hpBar.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
        elseif health / maxHealth > 0.3 then
            hpBar.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
        else
            hpBar.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
        end
    end)

    espConnections[player] = {gui = billboard, conn = conn}
end

local function removeESP(player)
    if espConnections[player] then
        espConnections[player].conn:Disconnect()
        if espConnections[player].gui then
            espConnections[player].gui:Destroy()
        end
        espConnections[player] = nil
    end
end

local function enableESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            createESP(player)
        end
    end
    Players.PlayerAdded:Connect(createESP)
    Players.PlayerRemoving:Connect(removeESP)
end

local function disableESP()
    for _, data in pairs(espConnections) do
        data.conn:Disconnect()
        if data.gui then
            data.gui:Destroy()
        end
    end
    espConnections = {}
end

-- 🔘 Toggle ESP di WindUI
ToolsTab:Toggle({
    Title = "ESP (Ava + Health)", -- GradientText dihapus
    Default = false,
    Callback = function(state)
        espEnabled = state
        if state then
            enableESP()
            print("ESP Enabled ✅")
        else
            disableESP()
            print("ESP Disabled ❌")
        end
    end
})


-- === SECTION 3: PLAYER TARGETING ===
local PlayerTargetingSection = ToolsTab:Section({
    Title = "Player Targeting",
    Icon = "solar:plain-3-bold",
    Opened = false
})

-- ====== SPECTATE + TELEPORT + FLING (Unified Dropdown) ======
local targetPlayer = nil
local spectating = false
local camera = workspace.CurrentCamera

-- Ambil daftar nama player selain LocalPlayer
local function getPlayerNames()
    local names = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            table.insert(names, p.Name)
        end
    end
    return names
end

-- Dropdown untuk pilih target player
local playerDropdown = ToolsTab:Dropdown({
    Title = "Pilih Player", -- GradientText dihapus
    Values = getPlayerNames(),
    Default = nil,
    Callback = function(value)
        targetPlayer = Players:FindFirstChild(value)
        print("🎯 Target Player:", value)
    end,
})

-- 🔁 Tombol untuk refresh manual daftar player
ToolsTab:Button({
    Title = "Refresh Player", -- GradientText dihapus
    Callback = function()
        if playerDropdown then
            playerDropdown:UpdateValues(getPlayerNames())
            print("✅ Daftar player berhasil di-refresh!")
        end
    end,
})

-- ⏱️ Auto refresh setiap 5 detik
task.spawn(function()
    while task.wait(5) do
        if playerDropdown then
            playerDropdown:UpdateValues(getPlayerNames())
        end
    end
end)

-- 🎥 Toggle untuk Spectate Player
ToolsTab:Toggle({
    Title = "Spectate Player", -- GradientText dihapus
    Default = false,
    Callback = function(state)
        spectating = state
        if spectating and targetPlayer and targetPlayer.Character then
            print("👀 Spectating:", targetPlayer.Name)
        else
            print("🛑 Stopped spectating")
        end
    end,
})

-- Update kamera agar mengikuti targetPlayer saat spectate aktif
RunService:BindToRenderStep("Spectate", Enum.RenderPriority.Camera.Value + 1, function()
    if spectating and targetPlayer and targetPlayer.Character then
        local humanoid = targetPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            camera.CameraSubject = humanoid
            camera.CameraType = Enum.CameraType.Custom
        end
    else
        camera.CameraSubject = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        camera.CameraType = Enum.CameraType.Custom
    end
end)

-- 🚀 Tombol untuk teleport ke player target
ToolsTab:Button({
    Title = "Teleport Player", -- GradientText dihapus
    Callback = function()
        if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = targetPlayer.Character.HumanoidRootPart
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.CFrame = hrp.CFrame + Vector3.new(2, 0, 2)
                print("📍 Teleported to:", targetPlayer.Name)
            end
        else
            print("⚠️ Player target tidak valid!")
        end
    end,
})

------------------------------------------------------------
-- 🌀 TAB FLING PLAYER
------------------------------------------------------------
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

local flingTarget = nil
local spectating = false
local flingActive = false
local flingConn = nil
local spectateConn = nil
local bv = nil
local originalCFrame = nil
local originalVehicleCFrame = nil
local tickOffset = 0

-- 🌀 Tab Fling
local FlingTab = UiSection:Tab({
    Title = "Fling Player",
    Icon = "solar:user-block-bold",
    IconColor = Color3.fromHex("#FF3B30"),
    IconShape = true,
})

-- === SECTION TARGET SELECTION ===
local TargetSection = FlingTab:Section({
    Title = "Target Selection",
    Icon = "solar:pin-bold",
    Opened = false  -- Membuat section tetap terbuka (non-dropdown)
})

-- 🧍 Fungsi ambil daftar player
local function GetPlayerNames()
    local names = {}
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            table.insert(names, player.Name)
        end
    end
    return names
end

-- 🧩 Dropdown pilih player
local playerDropdown = FlingTab:Dropdown({
    Title = "List",
    Values = GetPlayerNames(),
    Default = nil,
    Callback = function(value)
        flingTarget = Players:FindFirstChild(value)
        print("Target dipilih:", value)
    end,
})

-- 🔁 Tombol refresh
FlingTab:Button({
    Title = "Refresh",
    Callback = function()
        playerDropdown:SetValues(GetPlayerNames())
        print("Daftar player diperbarui.")
    end,
})

-- === SECTION SPECTATE ===
local SpectateSection = FlingTab:Section({
    Title = "Spectate & Fling",
    Icon = "eye",
    Opened = false  -- Membuat section tetap terbuka (non-dropdown)
})

-- 👁 Toggle Spectate Player
FlingTab:Toggle({
    Title = "Spectate",
    Default = false,
    Callback = function(value)
        spectating = value
        if spectateConn then
            spectateConn:Disconnect()
            spectateConn = nil
        end
        if spectating then
            spectateConn = RunService.RenderStepped:Connect(function()
                if flingTarget and flingTarget.Character and flingTarget.Character:FindFirstChild("Humanoid") then
                    Camera.CameraSubject = flingTarget.Character.Humanoid
                else
                    Camera.CameraSubject = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
                end
            end)
            print("🎥 Spectate ON")
        else
            Camera.CameraSubject = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
            print("🚫 Spectate OFF")
        end
    end,
})

-- Fungsi paksa balik posisi kapal + karakter
local function forceResetPosition(vehicleModel, hrp, originalVehicleCFrame, originalCFrame)
    if vehicleModel and originalVehicleCFrame then
        for i = 1, 5 do
            vehicleModel:SetPrimaryPartCFrame(originalVehicleCFrame)
            task.wait(0.05)
        end
    end

    if hrp and originalCFrame then
        for i = 1, 5 do
            hrp.CFrame = originalCFrame
            task.wait(0.05)
        end
    end
end

-- Toggle Fling
FlingTab:Toggle({
    Title = "Fling",
    Default = false,
    Callback = function(value)
        flingActive = value
        local myChar = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local myHRP = myChar:FindFirstChild("HumanoidRootPart")
        local myHumanoid = myChar:FindFirstChild("Humanoid")
        if not myHRP or not myHumanoid then return warn("Tidak menemukan HumanoidRootPart atau Humanoid!") end

        -- Cek kapal
        local vehicleModel = nil
        if myHumanoid.SeatPart then
            vehicleModel = myHumanoid.SeatPart:FindFirstAncestorOfClass("Model")
        end
        if not vehicleModel then
            warn("Naik kapal dulu sebelum Fling!")
            flingActive = false
            return
        end

        -- Stop fling lama
        if flingConn then flingConn:Disconnect() flingConn = nil end
        if bv then bv:Destroy() bv = nil end

        if flingActive then
            if not flingTarget or not flingTarget.Character or not flingTarget.Character:FindFirstChild("HumanoidRootPart") then
                warn("Pilih target dulu!")
                flingActive = false
                return
            end

            local targetHRP = flingTarget.Character.HumanoidRootPart
            originalCFrame = myHRP.CFrame
            originalVehicleCFrame = vehicleModel.PrimaryPart.CFrame

            -- Pastikan karakter duduk / menempel di kapal
            myHumanoid.Sit = true
            task.wait(0.1) -- tunggu physics update

            -- BodyVelocity untuk karakter
            bv = Instance.new("BodyVelocity")
            bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            bv.Velocity = Vector3.new(0,0,0)
            bv.Parent = myHRP

            tickOffset = 0
            flingConn = RunService.Heartbeat:Connect(function(dt)
                if not flingTarget or not flingTarget.Character or not flingTarget.Character:FindFirstChild("HumanoidRootPart") then return end
                tickOffset = tickOffset + dt * 1000

                local yOffset = math.sin(tickOffset * 1000) * 1
                local xOffset = math.random(-1,1)
                local zOffset = math.random(-1,1)

                local targetPos = targetHRP.Position + Vector3.new(xOffset, 1 + yOffset, zOffset)

                -- Update posisi kapal + karakter
                if vehicleModel.PrimaryPart then
                    vehicleModel:SetPrimaryPartCFrame(CFrame.new(targetPos))
                end

                -- BodyVelocity arah target untuk karakter
                local direction = (targetHRP.Position - myHRP.Position).unit
                bv.Velocity = direction * 100
            end)

            print("Fling ON + Kapal + Karakter aktif")
        else
            -- Stop fling
            if flingConn then flingConn:Disconnect() flingConn = nil end
            if bv then bv:Destroy() bv = nil end

            -- Paksa balik ke posisi awal kapal + karakter
            forceResetPosition(vehicleModel, myHRP, originalVehicleCFrame, originalCFrame)

            -- Pastikan karakter duduk / stabil
            myHumanoid.Sit = true
            print("Fling OFF, kapal + karakter kembali ke posisi semula")
        end
    end,
})



-- ========================================================
-- SERVICES & VARIABLES
-- ========================================================
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local Camera = Workspace.CurrentCamera
local VirtualUser = game:GetService("VirtualUser")
local TeleportService = game:GetService("TeleportService")
local CoreGui = game:GetService("CoreGui")

-- ========================================================
-- TAB 1: PLAYER AUTOMATION
-- ========================================================
local MiscTab = UiSection:Tab({
    Title = "Miscellaneous",
    Icon = "solar:settings-bold",
    IconColor = Color3.fromHex("#8E8E93"),
    IconShape = true,
})

--- Section: Connection
local ConnectionSection = MiscTab:Section({
    Title = "Connection",
    Icon = "solar:login-2-bold",
    Opened = true
})

local antiAFK = false
local afkConnection

MiscTab:Toggle({
    Title = "Anti AFK",
    Type = "Checkbox",
    Default = false,
    Callback = function(v)
        antiAFK = v
        if v then
            afkConnection = LocalPlayer.Idled:Connect(function()
                if antiAFK then
                    VirtualUser:CaptureController()
                    VirtualUser:ClickButton2(Vector2.new())
                end
            end)
            WindUI:Notify({ Title = "Player", Content = "Anti AFK enabled.", Duration = 2 })
        else
            if afkConnection then afkConnection:Disconnect() afkConnection = nil end
            WindUI:Notify({ Title = "Player", Content = "Anti AFK disabled.", Duration = 2 })
        end
    end
})

local autoReconnect = false

MiscTab:Toggle({
    Title = "Auto Reconnect",
    Type = "Checkbox",
    Default = false,
    Callback = function(v)
        autoReconnect = v
        WindUI:Notify({ Title = "Player", Content = v and "Auto Reconnect enabled." or "Auto Reconnect disabled.", Duration = 2 })
    end
})

task.spawn(function()
    while task.wait(5) do
        if autoReconnect and not game:IsLoaded() then
            pcall(function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end)
        end
    end
end)

local function SafeServerHop()
    WindUI:Notify({ Title = "Rejoin Server", Content = "Attempting to rejoin...", Duration = 3 })
    task.wait(1)
    local ok, _ = pcall(function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end)
    if not ok then WindUI:Notify({ Title = "Rejoin Server", Content = "⚠ Failed to rejoin.", Duration = 4 }) end
end

MiscTab:Button({
    Title = "Rejoin Server",
    Callback = function() task.spawn(SafeServerHop) end,
})

--- Section: Rod Settings (MODIFIED to target ReplicatedStorage)
local RodSection = MiscTab:Section({
    Title = "Rod Settings",
    Icon = "solar:settings-bold",
    Opened = true
})

local removeVFX = false
local vfxConnection = nil

-- Fungsi untuk membersihkan VFX yang sudah ada
local function clearExistingVFX()
    local vfxFolder = game.ReplicatedStorage:FindFirstChild("VFX")
    if vfxFolder then
        -- Hapus semua anak dari folder VFX
        for _, vfx in ipairs(vfxFolder:GetChildren()) do
            vfx:Destroy()
        end
    end
end

-- Fungsi untuk memulai pembersihan VFX
local function startVFXRemoval()
    -- Pertama, bersihkan VFX yang sudah ada
    clearExistingVFX()

    -- Kedua, dengarkan VFX baru yang ditambahkan dan hapus secara instan
    local vfxFolder = game.ReplicatedStorage:WaitForChild("VFX", 5) -- Tunggu maksimal 5 detik
    if vfxFolder then
        vfxConnection = vfxFolder.DescendantAdded:Connect(function(vfx)
            if removeVFX and vfx then
                vfx:Destroy()
            end
        end)
    end
end

-- Fungsi untuk menghentikan pembersihan VFX
local function stopVFXRemoval()
    if vfxConnection then
        vfxConnection:Disconnect()
        vfxConnection = nil
    end
end

MiscTab:Toggle({
    Title = "Remove Rod Effect",
    Type = "Checkbox",
    Default = false,
    Callback = function(v)
        removeVFX = v
        if v then
            startVFXRemoval()
            WindUI:Notify({ Title = "Fishing", Content = "VFX removal started. Targeting ReplicatedStorage.", Duration = 2 })
        else
            stopVFXRemoval()
            WindUI:Notify({ Title = "Fishing", Content = "VFX removal stopped.", Duration = 2 })
        end
    end
})

local RemoveBigFish = false
local popupConnection

-- Fungsi yang sangat umum untuk mendeteksi dan menyembunyikan popup
local function hidePotentialPopup(descendant)
    if not RemoveBigFish then return end

    -- Target: Semua jenis GuiObject (Frame, ImageButton, ImageLabel, dll.)
    if descendant:IsA("GuiObject") then
        -- Ciri 1: Harus terlihat dan cukup besar untuk menjadi popup
        if descendant.Visible and descendant.AbsoluteSize.X >= 250 and descendant.AbsoluteSize.Y >= 250 then
            
            -- Ciri 2: Harus menjadi elemen utama (langsung di dalam ScreenGui)
            -- Ini membantu menghindari menyembunyikan bagian dari UI yang lebih besar
            local parent = descendant.Parent
            if parent and parent:IsA("ScreenGui") then

                -- Ciri 3 (SAFETY CHECK): Tidak boleh mengandung TextBox
                -- Ini untuk mencegah menyembunyikan menu, pengaturan, atau obrolan
                local hasTextBox = descendant:FindFirstChildOfClass("TextBox")

                if not hasTextBox then
                    -- Jika semua kriteria terpenuhi, ini kemungkinan besar adalah popup.
                    print("[LS Hub] Menyembunyikan popup: " .. descendant.Name .. " (Ukuran: " .. descendant.AbsoluteSize.X .. "x" .. descendant.AbsoluteSize.Y .. ")")
                    descendant.Visible = false
                end
            end
        end
    end
end

local function connectPopupRemover()
    -- Event ini akan bekerja untuk setiap elemen baru yang ditambahkan
    popupConnection = LocalPlayer.PlayerGui.DescendantAdded:Connect(hidePotentialPopup)
end

local function disconnectPopupRemover()
    if popupConnection then
        popupConnection:Disconnect()
        popupConnection = nil
    end
end

MiscTab:Toggle({
    Title = "Hide Obtained Popups",
	Desc = "Jangan dipakai, sedang dalam perbaikan",
    Type = "Checkbox",
    Default = false,
    Callback = function(v)
        RemoveBigFish = v
        if v then
            connectPopupRemover()
            
            -- Lakukan pemeriksaan awal pada semua UI yang sudah ada
            for _, existingDescendant in ipairs(LocalPlayer.PlayerGui:GetDescendants()) do
                hidePotentialPopup(existingDescendant)
            end
            
            WindUI:Notify({ Title = "Fishing", Content = "Universal popup hider enabled.", Duration = 2 })
            WindUI:Notify({ Title = "Debug", Content = "Buka F9 untuk melihat apa yang disembunyikan.", Duration = 5 })
        else
            disconnectPopupRemover()
            WindUI:Notify({ Title = "Fishing", Content = "Universal popup hider disabled.", Duration = 2 })
        end
    end
})

-- [MODIFIED] Low Graphics Mode
MiscTab:Toggle({
    Title = "Low Graphics Mode (Roblox Lite)",
    Default = false,
    Callback = function(v)
        if v then
            -- Pengaturan Lighting yang lebih ekstrem
            Lighting.GlobalShadows = false
            Lighting.FogEnd = 9e9
            Lighting.FogStart = 9e9
            Lighting.Brightness = 2
            Lighting.Ambient = Color3.new(1,1,1)
            Lighting.OutdoorAmbient = Color3.new(1,1,1)
            Lighting.ClockTime = 14
            
            -- Nonaktifkan semua efek pasca dan atmosfer
            for _, effect in ipairs(Lighting:GetChildren()) do 
                if effect:IsA("PostEffect") or effect:IsA("Atmosphere") or effect:IsA("Sky") then 
                    effect.Enabled = false 
                end 
            end
            
            -- Pengaturan kualitas render yang lebih rendah
            settings().Rendering.QualityLevel = 1
            settings().Rendering.MeshLevelOfDetail = 1
            
            -- Tambahkan pengaturan tambahan untuk efek "Roblox Lite"
            settings().Rendering.EagerBulkExecution = false
            settings().Rendering.GraphicsMode = 1 -- Direct3D9 (lebih ringan)
            settings().Physics.PhysicsEnvironmentalThrottle = Enum.EnviromentalPhysicsThrottle.High
            settings().Physics.AllowSleep = true
            settings().Network.PhysicsReceive = 20
            settings().Network.PhysicsSend = 20
            settings().Network.IncomingReplicationLag = 10
            
            -- Nonaktifkan fitur tambahan
            Workspace.StreamingEnabled = false
            
            -- Nonaktifkan partikel dan efek visual yang sudah ada
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj:IsA("ParticleEmitter") or obj:IsA("Beam") or obj:IsA("Trail") or obj:IsA("Fire") or obj:IsA("Smoke") then
                    obj.Enabled = false
                end
            end
            
            WindUI:Notify({ Title = "Performance", Content = "Roblox Lite Mode enabled.", Duration = 2 })
        else
            -- Kembalikan pengaturan ke default
            Lighting.GlobalShadows = true
            Lighting.FogEnd = 1000
            Lighting.FogStart = 0
            Lighting.Brightness = 1
            Lighting.Ambient = Color3.new(0.5,0.5,0.5)
            Lighting.OutdoorAmbient = Color3.new(0.5,0.5,0.5)
            Lighting.ClockTime = 12
            
            for _, effect in ipairs(Lighting:GetChildren()) do 
                if effect:IsA("PostEffect") or effect:IsA("Atmosphere") or effect:IsA("Sky") then 
                    effect.Enabled = true 
                end 
            end
            
            settings().Rendering.QualityLevel = 10
            settings().Rendering.MeshLevelOfDetail = 4
            settings().Rendering.EagerBulkExecution = true
            settings().Rendering.GraphicsMode = 0 -- Direct3D11
            settings().Physics.PhysicsEnvironmentalThrottle = Enum.EnviromentalPhysicsThrottle.None
            settings().Physics.AllowSleep = false
            settings().Network.PhysicsReceive = 60
            settings().Network.PhysicsSend = 40
            settings().Network.IncomingReplicationLag = 0
            
            Workspace.StreamingEnabled = true
            
            -- Aktifkan kembali partikel dan efek visual
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj:IsA("ParticleEmitter") or obj:IsA("Beam") or obj:IsA("Trail") or obj:IsA("Fire") or obj:IsA("Smoke") then
                    obj.Enabled = true
                end
            end
            
            WindUI:Notify({ Title = "Performance", Content = "Low Graphics Mode disabled.", Duration = 2 })
        end
    end
})

-- [MODIFIED] Disable Rendering
MiscTab:Toggle({
    Title = "Disable Rendering (Black Screen)",
    Default = false,
    Callback = function(v)
        isRenderingDisabled = v
        if v then
            -- Coba temukan ScreenGui WindUI untuk memastikannya tetap di atas
            local windUIGui = CoreGui:FindFirstChild("WindUI")
            
            renderingGui = Instance.new("ScreenGui")
            renderingGui.Name = "RenderingDisabler"
            renderingGui.Parent = CoreGui
            renderingGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
            renderingGui.IgnoreGuiInset = true
            renderingGui.DisplayOrder = 1 -- Set ke nilai rendah

            local frame = Instance.new("Frame")
            frame.Size = UDim2.fromScale(1, 1)
            frame.BackgroundColor3 = Color3.new(0, 0, 0)
            frame.BorderSizePixel = 0
            frame.Parent = renderingGui

            -- Pastikan WindUI berada di atas layar hitam
            if windUIGui then
                windUIGui.DisplayOrder = 999 -- Set ke nilai sangat tinggi
            end
            
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then 
                Camera.CameraType = Enum.CameraType.Scriptable
                Camera.CFrame = CFrame.new(0, -10000, 0) 
            end
            
            WindUI:Notify({ Title = "EXTREME MODE", Content = "Rendering disabled. UI remains visible.", Duration = 4 })
        else
            if renderingGui then 
                renderingGui:Destroy() 
                renderingGui = nil 
            end
            Camera.CameraType = Enum.CameraType.Custom
            WindUI:Notify({ Title = "EXTREME MODE", Content = "Rendering re-enabled.", Duration = 3 })
        end
    end
})

-- 🔧 Other Script
MiscTab:Button({
    Title = "Username Hider",
    Icon = "solar:shield-check-bold",
    Color = Color3.fromHex("#6b31ff"),
    Callback = function()
        loadstring(game:HttpGet("https://pastefy.app/VUGWWvKq/raw"))()
    end
})

local ConfigUsageSection = Window:Section({
    Title = "Config Usage",
})

------------------------------------------------------------
-- 🎨 TAB THEMES
------------------------------------------------------------
local ThemesTab = ConfigUsageSection:Tab({
    Title = "Theme Settings",
    Icon = "solar:add-folder-bold",
    IconColor = Color3.fromHex("#6366f1"),
    IconShape = true,
})

local ThemesSection = ThemesTab:Section({
    Title = "UI Themes",
    Icon = "palette",
    Opened = false  -- Membuat section tetap terbuka (non-dropdown)
})

-- Add custom themes
WindUI:AddTheme({
    Name = "Ocean",
    Accent = Color3.fromHex("#006994"), 
    Dialog = Color3.fromHex("#001f3f"), 
    Outline = Color3.fromHex("#0074D9"),
    Text = Color3.fromHex("#f8fafc"),  
    Placeholder = Color3.fromHex("#94a3b8"),
    Button = Color3.fromHex("#003f7f"), 
    Icon = Color3.fromHex("#39CCCC"), 
    
    WindowBackground = Color3.fromHex("#002855"),
    
    TopbarButtonIcon = Color3.fromHex("#39CCCC"),
    TopbarTitle = Color3.fromHex("#f8fafc"),
    TopbarAuthor = Color3.fromHex("#94a3b8"),
    TopbarIcon = Color3.fromHex("#0074D9"),
    
    TabBackground = Color3.fromHex("#003f7f"),    
    TabTitle = Color3.fromHex("#f8fafc"),
    TabIcon = Color3.fromHex("#39CCCC"),
    
    ElementBackground = Color3.fromHex("#003f7f"),
    ElementTitle = Color3.fromHex("#f8fafc"),
    ElementDesc = Color3.fromHex("#cbd5e1"),
    ElementIcon = Color3.fromHex("#39CCCC"),
})

WindUI:AddTheme({
    Name = "Sunset",
    Accent = Color3.fromHex("#FF6B35"), 
    Dialog = Color3.fromHex("#2D1B69"), 
    Outline = Color3.fromHex("#F77F00"),
    Text = Color3.fromHex("#FCBF49"),  
    Placeholder = Color3.fromHex("#EAE2B7"),
    Button = Color3.fromHex("#D62828"), 
    Icon = Color3.fromHex("#F77F00"), 
    
    WindowBackground = Color3.fromHex("#2D1B69"),
    
    TopbarButtonIcon = Color3.fromHex("#F77F00"),
    TopbarTitle = Color3.fromHex("#FCBF49"),
    TopbarAuthor = Color3.fromHex("#EAE2B7"),
    TopbarIcon = Color3.fromHex("#F77F00"),
    
    TabBackground = Color3.fromHex("#3D2C6D"),    
    TabTitle = Color3.fromHex("#FCBF49"),
    TabIcon = Color3.fromHex("#F77F00"),
    
    ElementBackground = Color3.fromHex("#3D2C6D"),
    ElementTitle = Color3.fromHex("#FCBF49"),
    ElementDesc = Color3.fromHex("#EAE2B7"),
    ElementIcon = Color3.fromHex("#F77F00"),
})

-- Tambahkan tema baru
WindUI:AddTheme({
    Name = "Dark",
    Accent = Color3.fromHex("#6366f1"), 
    Dialog = Color3.fromHex("#0f172a"), 
    Outline = Color3.fromHex("#475569"),
    Text = Color3.fromHex("#f1f5f9"),  
    Placeholder = Color3.fromHex("#94a3b8"),
    Button = Color3.fromHex("#1e293b"), 
    Icon = Color3.fromHex("#6366f1"), 
    
    WindowBackground = Color3.fromHex("#0f172a"),
    
    TopbarButtonIcon = Color3.fromHex("#6366f1"),
    TopbarTitle = Color3.fromHex("#f1f5f9"),
    TopbarAuthor = Color3.fromHex("#94a3b8"),
    TopbarIcon = Color3.fromHex("#6366f1"),
    
    TabBackground = Color3.fromHex("#1e293b"),    
    TabTitle = Color3.fromHex("#f1f5f9"),
    TabIcon = Color3.fromHex("#6366f1"),
    
    ElementBackground = Color3.fromHex("#1e293b"),
    ElementTitle = Color3.fromHex("#f1f5f9"),
    ElementDesc = Color3.fromHex("#cbd5e1"),
    ElementIcon = Color3.fromHex("#6366f1"),
})

WindUI:AddTheme({
    Name = "Light",
    Accent = Color3.fromHex("#3b82f6"), 
    Dialog = Color3.fromHex("#ffffff"), 
    Outline = Color3.fromHex("#e2e8f0"),
    Text = Color3.fromHex("#1e293b"),  
    Placeholder = Color3.fromHex("#64748b"),
    Button = Color3.fromHex("#f1f5f9"), 
    Icon = Color3.fromHex("#3b82f6"), 
    
    WindowBackground = Color3.fromHex("#ffffff"),
    
    TopbarButtonIcon = Color3.fromHex("#3b82f6"),
    TopbarTitle = Color3.fromHex("#1e293b"),
    TopbarAuthor = Color3.fromHex("#64748b"),
    TopbarIcon = Color3.fromHex("#3b82f6"),
    
    TabBackground = Color3.fromHex("#f8fafc"),    
    TabTitle = Color3.fromHex("#1e293b"),
    TabIcon = Color3.fromHex("#3b82f6"),
    
    ElementBackground = Color3.fromHex("#f8fafc"),
    ElementTitle = Color3.fromHex("#1e293b"),
    ElementDesc = Color3.fromHex("#475569"),
    ElementIcon = Color3.fromHex("#3b82f6"),
})

WindUI:AddTheme({
    Name = "Neon",
    Accent = Color3.fromHex("#ff00ff"), 
    Dialog = Color3.fromHex("#0a0a0a"), 
    Outline = Color3.fromHex("#ff00ff"),
    Text = Color3.fromHex("#ffffff"),  
    Placeholder = Color3.fromHex("#a0a0a0"),
    Button = Color3.fromHex("#1a1a1a"), 
    Icon = Color3.fromHex("#00ffff"), 
    
    WindowBackground = Color3.fromHex("#0a0a0a"),
    
    TopbarButtonIcon = Color3.fromHex("#00ffff"),
    TopbarTitle = Color3.fromHex("#ffffff"),
    TopbarAuthor = Color3.fromHex("#a0a0a0"),
    TopbarIcon = Color3.fromHex("#ff00ff"),
    
    TabBackground = Color3.fromHex("#1a1a1a"),    
    TabTitle = Color3.fromHex("#ffffff"),
    TabIcon = Color3.fromHex("#00ffff"),
    
    ElementBackground = Color3.fromHex("#1a1a1a"),
    ElementTitle = Color3.fromHex("#ffffff"),
    ElementDesc = Color3.fromHex("#d0d0d0"),
    ElementIcon = Color3.fromHex("#00ffff"),
})

WindUI:AddTheme({
    Name = "Forest",
    Accent = Color3.fromHex("#22c55e"), 
    Dialog = Color3.fromHex("#052e16"), 
    Outline = Color3.fromHex("#16a34a"),
    Text = Color3.fromHex("#f0fdf4"),  
    Placeholder = Color3.fromHex("#86efac"),
    Button = Color3.fromHex("#14532d"), 
    Icon = Color3.fromHex("#22c55e"), 
    
    WindowBackground = Color3.fromHex("#052e16"),
    
    TopbarButtonIcon = Color3.fromHex("#22c55e"),
    TopbarTitle = Color3.fromHex("#f0fdf4"),
    TopbarAuthor = Color3.fromHex("#86efac"),
    TopbarIcon = Color3.fromHex("#22c55e"),
    
    TabBackground = Color3.fromHex("#14532d"),    
    TabTitle = Color3.fromHex("#f0fdf4"),
    TabIcon = Color3.fromHex("#22c55e"),
    
    ElementBackground = Color3.fromHex("#14532d"),
    ElementTitle = Color3.fromHex("#f0fdf4"),
    ElementDesc = Color3.fromHex("#bbf7d0"),
    ElementIcon = Color3.fromHex("#22c55e"),
})

WindUI:AddTheme({
    Name = "Fire",
    Accent = Color3.fromHex("#ef4444"), 
    Dialog = Color3.fromHex("#450a0a"), 
    Outline = Color3.fromHex("#dc2626"),
    Text = Color3.fromHex("#fef2f2"),  
    Placeholder = Color3.fromHex("#fca5a5"),
    Button = Color3.fromHex("#7f1d1d"), 
    Icon = Color3.fromHex("#ef4444"), 
    
    WindowBackground = Color3.fromHex("#450a0a"),
    
    TopbarButtonIcon = Color3.fromHex("#ef4444"),
    TopbarTitle = Color3.fromHex("#fef2f2"),
    TopbarAuthor = Color3.fromHex("#fca5a5"),
    TopbarIcon = Color3.fromHex("#ef4444"),
    
    TabBackground = Color3.fromHex("#7f1d1d"),    
    TabTitle = Color3.fromHex("#fef2f2"),
    TabIcon = Color3.fromHex("#ef4444"),
    
    ElementBackground = Color3.fromHex("#7f1d1d"),
    ElementTitle = Color3.fromHex("#fef2f2"),
    ElementDesc = Color3.fromHex("#fecaca"),
    ElementIcon = Color3.fromHex("#ef4444"),
})

WindUI:AddTheme({
    Name = "Ice",
    Accent = Color3.fromHex("#06b6d4"), 
    Dialog = Color3.fromHex("#083344"), 
    Outline = Color3.fromHex("#0891b2"),
    Text = Color3.fromHex("#f0fdfa"),  
    Placeholder = Color3.fromHex("#67e8f9"),
    Button = Color3.fromHex("#164e63"), 
    Icon = Color3.fromHex("#06b6d4"), 
    
    WindowBackground = Color3.fromHex("#083344"),
    
    TopbarButtonIcon = Color3.fromHex("#06b6d4"),
    TopbarTitle = Color3.fromHex("#f0fdfa"),
    TopbarAuthor = Color3.fromHex("#67e8f9"),
    TopbarIcon = Color3.fromHex("#06b6d4"),
    
    TabBackground = Color3.fromHex("#164e63"),    
    TabTitle = Color3.fromHex("#f0fdfa"),
    TabIcon = Color3.fromHex("#06b6d4"),
    
    ElementBackground = Color3.fromHex("#164e63"),
    ElementTitle = Color3.fromHex("#f0fdfa"),
    ElementDesc = Color3.fromHex("#a5f3fc"),
    ElementIcon = Color3.fromHex("#06b6d4"),
})

WindUI:AddTheme({
    Name = "Purple",
    Accent = Color3.fromHex("#9333ea"), 
    Dialog = Color3.fromHex("#2e1065"), 
    Outline = Color3.fromHex("#7c3aed"),
    Text = Color3.fromHex("#faf5ff"),  
    Placeholder = Color3.fromHex("#c4b5fd"),
    Button = Color3.fromHex("#4c1d95"), 
    Icon = Color3.fromHex("#9333ea"), 
    
    WindowBackground = Color3.fromHex("#2e1065"),
    
    TopbarButtonIcon = Color3.fromHex("#9333ea"),
    TopbarTitle = Color3.fromHex("#faf5ff"),
    TopbarAuthor = Color3.fromHex("#c4b5fd"),
    TopbarIcon = Color3.fromHex("#9333ea"),
    
    TabBackground = Color3.fromHex("#4c1d95"),    
    TabTitle = Color3.fromHex("#faf5ff"),
    TabIcon = Color3.fromHex("#9333ea"),
    
    ElementBackground = Color3.fromHex("#4c1d95"),
    ElementTitle = Color3.fromHex("#faf5ff"),
    ElementDesc = Color3.fromHex("#ddd6fe"),
    ElementIcon = Color3.fromHex("#9333ea"),
})

WindUI:AddTheme({
    Name = "Gold",
    Accent = Color3.fromHex("#f59e0b"), 
    Dialog = Color3.fromHex("#451a03"), 
    Outline = Color3.fromHex("#d97706"),
    Text = Color3.fromHex("#fffbeb"),  
    Placeholder = Color3.fromHex("#fcd34d"),
    Button = Color3.fromHex("#78350f"), 
    Icon = Color3.fromHex("#f59e0b"), 
    
    WindowBackground = Color3.fromHex("#451a03"),
    
    TopbarButtonIcon = Color3.fromHex("#f59e0b"),
    TopbarTitle = Color3.fromHex("#fffbeb"),
    TopbarAuthor = Color3.fromHex("#fcd34d"),
    TopbarIcon = Color3.fromHex("#f59e0b"),
    
    TabBackground = Color3.fromHex("#78350f"),    
    TabTitle = Color3.fromHex("#fffbeb"),
    TabIcon = Color3.fromHex("#f59e0b"),
    
    ElementBackground = Color3.fromHex("#78350f"),
    ElementTitle = Color3.fromHex("#fffbeb"),
    ElementDesc = Color3.fromHex("#fde68a"),
    ElementIcon = Color3.fromHex("#f59e0b"),
})

-- Fungsi untuk mengatur tema default
local function setDefaultTheme()
    WindUI:SetTheme("Default")
end

ThemesSection:Dropdown({
    Title = "Select Theme",
    Values = {"Default", "Ocean", "Sunset", "Dark", "Light", "Neon", "Forest", "Fire", "Ice", "Purple", "Gold"},
    Default = "Default",
    Callback = function(value)
        if value == "Default" then
            -- Gunakan fungsi khusus untuk tema default
            setDefaultTheme()
        else
            WindUI:SetTheme(value)
        end
        WindUI:Notify({
            Title = "Theme Changed",
            Content = "UI theme changed to " .. value,
            Duration = 2
        })
    end
})

------------------------------------------------------------
-- 💾 TAB CONFIG
------------------------------------------------------------
local ConfigTab = ConfigUsageSection:Tab({
    Title = "Configuration",
    Icon = "solar:file-text-bold",
    IconColor = Color3.fromHex("#c4b5fd"),
    IconShape = true,
})

local ConfigManager = Window.ConfigManager
local ConfigName = "default"

local ConfigNameInput = ConfigTab:Input({
    Title = "Config Name",
    Icon = "file-cog",
    Callback = function(value)
        ConfigName = value
    end
})

local AllConfigs = ConfigManager:AllConfigs()
local DefaultValue = table.find(AllConfigs, ConfigName) and ConfigName or nil

ConfigTab:Dropdown({
    Title = "All Configs",
    Desc = "Select existing configs",
    Values = AllConfigs,
    Value = DefaultValue,
    Callback = function(value)
        ConfigName = value
        ConfigNameInput:Set(value)
    end
})

ConfigTab:Button({
    Title = "Save Config",
    Icon = "",
    Justify = "Center",
    Callback = function()
        Window.CurrentConfig = ConfigManager:CreateConfig(ConfigName)
        if Window.CurrentConfig:Save() then
            WindUI:Notify({
                Title = "Config Saved",
                Desc = "Config '" .. ConfigName .. "' saved",
                Icon = "check",
            })
        end
    end
})

ConfigTab:Button({
    Title = "Load Config",
    Icon = "",
    Justify = "Center",
    Callback = function()
        Window.CurrentConfig = ConfigManager:CreateConfig(ConfigName)
        if Window.CurrentConfig:Load() then
            WindUI:Notify({
                Title = "Config Loaded",
                Desc = "Config '" .. ConfigName .. "' loaded",
                Icon = "refresh-cw",
            })
        end
    end
})

ConfigTab:Button({
    Title = "Delete Config",
    Icon = "",
    Justify = "Center",
    Callback = function()
        local success = ConfigManager:DeleteConfig(ConfigName)
        if success then
            WindUI:Notify({
                Title = "Config Deleted",
                Desc = "Config '" .. ConfigName .. "' deleted",
                Icon = "trash-2",
            })
            -- Perbarui dropdown setelah penghapusan
            ConfigTab:Refresh()
        else
            WindUI:Notify({
                Title = "Error",
                Desc = "Failed to delete config '" .. ConfigName .. "'",
                Icon = "alert-circle",
            })
        end
    end
})