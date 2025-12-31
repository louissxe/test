-- Services
local Players = game:GetService("Players")
local ContentProvider = game:GetService("ContentProvider")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

-- Player
local LocalPlayer = Players.LocalPlayer
local playerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Destroy existing GUI
local existingGui = playerGui:FindFirstChild("CustomScreenGui")
if existingGui then
    existingGui:Destroy()
end

-- Create main GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CustomScreenGui"
ScreenGui.Parent = playerGui

-- Floating Button
local BorderFrame = Instance.new("Frame")
BorderFrame.Name = "BorderFrame"
BorderFrame.Parent = ScreenGui
BorderFrame.Size = UDim2.new(0, 52, 0, 52)
BorderFrame.Position = UDim2.new(0, 50, 0, 50)
BorderFrame.BackgroundColor3 = Color3.new(1, 1, 1)
BorderFrame.BackgroundTransparency = 0
BorderFrame.BorderSizePixel = 2
BorderFrame.BorderColor3 = Color3.fromRGB(0, 255, 255)

local BorderUICorner = Instance.new("UICorner")
BorderUICorner.CornerRadius = UDim.new(0.3, 0)
BorderUICorner.Parent = BorderFrame

local Button = Instance.new("ImageButton")
Button.Name = "CustomButton"
Button.Parent = BorderFrame
Button.Size = UDim2.new(1, -4, 1, -4)
Button.Position = UDim2.new(0.5, 0, 0.5, 0)
Button.AnchorPoint = Vector2.new(0.5, 0.5)
Button.BackgroundTransparency = 1
Button.Image = "rbxassetid://129264185201259"

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0.3, 0)
UICorner.Parent = Button

local Glow = Instance.new("UIStroke")
Glow.Thickness = 2
Glow.Color = Color3.fromRGB(0, 255, 255)
Glow.Parent = BorderFrame
Glow.Enabled = false

local imageLoaded = false
ContentProvider:PreloadAsync({ Button.Image }, function()
    imageLoaded = true
end)

-- Button Dragging Logic
local dragging = false
local dragStart = nil
local startPos = nil
local originalSize = Button.Size
local glowEnabled = false

Button.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = BorderFrame.Position
        TweenService:Create(Button, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(originalSize.X.Scale, originalSize.X.Offset * 0.9, originalSize.Y.Scale,
                originalSize.Y.Offset * 0.9)
        }):Play()
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
                TweenService:Create(Button, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                    { Size = originalSize }):Play()
            end
        end)
    end
end)

Button.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        if dragging then
            local delta = input.Position - dragStart
            local targetPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale,
                startPos.Y.Offset + delta.Y)
            TweenService:Create(BorderFrame, TweenInfo.new(0.08, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
                Position = targetPos
            }):Play()
        end
    end
end)

Button.MouseEnter:Connect(function()
    TweenService:Create(Button, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.new(originalSize.X.Scale, originalSize.X.Offset * 1.1, originalSize.Y.Scale,
            originalSize.Y.Offset * 1.1)
    }):Play()
end)

Button.MouseLeave:Connect(function()
    TweenService:Create(Button, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        { Size = originalSize }):Play()
end)

-- Load Fluent UI Library
local Library = loadstring(game:HttpGetAsync("https://github.com/ActualMasterOogway/Fluent-Renewed/releases/latest/download/Fluent.luau"))()
local SaveManager = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/ActualMasterOogway/Fluent-Renewed/master/Addons/SaveManager.luau"))()
local InterfaceManager = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/ActualMasterOogway/Fluent-Renewed/master/Addons/InterfaceManager.luau"))()

-- Detect platform and set appropriate UI size
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local windowSize = isMobile and UDim2.fromOffset(550, 350) or UDim2.fromOffset(700, 400)

local Window = Library:CreateWindow({
    Title = "LS Hub | The Forge",
    SubTitle = "Developed by Louissxe | FREE VERSION",
    BackgroundTransparency = 0.5,
    DropdownsOutsideWindow = true,
    TabsInHeader = true,
    Size = windowSize,
    TabWidth = 145,
    Acrylic = true, -- Enable blur effect
    Theme = "Darker", -- Default theme from theme list
    Search = true, -- Enable/disable element search, default true
    MinimizeKey = Enum.KeyCode.G, -- Key to minimize

    UserInfo = true, -- Show user information
    UserInfoTitle = game.Players.LocalPlayer.Name,
    UserInfoSubtitle = "Premium User",
    UserInfoSubtitleColor = Color3.fromRGB(255, 215, 0),
})

-- Button Click Event
Button.MouseButton1Click:Connect(function()
    glowEnabled = not glowEnabled
    Glow.Enabled = glowEnabled
    if not imageLoaded then return end
    pcall(function()
        Window:Minimize()
    end)
end)


local Tabs = {
    Help = Window:CreateTab{
        Title = "Information",
        Icon = "info"
    },
    Home = Window:CreateTab{
        Title = "Home Page",
        Icon = "rbxassetid://7733960981"
    },
    Forge = Window:CreateTab{
        Title = "Forge System",
        Icon = "hammer"
    },
    Combat = Window:CreateTab{
        Title = "Combat System",
        Icon = "sword"
    },
    Farms = Window:CreateTab{
        Title = "Auto Farm",
        Icon = "leaf"
    },
    Monsters = Window:CreateTab{
        Title = "Farm Monster",
        Icon = "skull"
    },
    Sell = Window:CreateTab{
        Title = "Auto Sell",
        Icon = "dollar-sign"
    },
    Shop = Window:CreateTab{
        Title = "Shop Items",
        Icon = "shopping-cart"
    },
    Quest = Window:CreateTab{
        Title = "Auto Quest",
        Icon = "map"
    },
    NPC = Window:CreateTab{
        Title = "NPC Tween",
        Icon = "bot"
    },
    Mics = Window:CreateTab{
        Title = "Player Setting",
        Icon = "user"
    },
    Settings = Window:CreateTab{
        Title = "Configs",
        Icon = "settings"
    }
}

local Options = Library.Options

-- ==================== HELP TAB ====================
Tabs.Help:CreateSection("PEMASALAHAN")

Tabs.Help:CreateParagraph("HelpInfo", {
    Title = "HUD Hilang / UI tidak muncul?",
    Content = "Jika Anda memuat script dan HUD (Antarmuka Pengguna) hilang atau tidak terlihat, harap perbarui executor Anda ke versi terbaru."
})

Tabs.Help:CreateSection("SUPPORT")

Tabs.Help:CreateButton({
    Title = "Gabung Discord: LS Hub",
    Description = "Klik untuk menyalin tautan undangan Discord",
    Callback = function()
        if setclipboard then
            setclipboard("https://discord.gg/ZnQ9XVhC")
            Library:Notify({
                Title = "Tautan Discord Disalin!",
                Content = "Tempel di browser: https://discord.gg/ZnQ9XVhC",
                Duration = 5
            })
        end
    end
})

-- ==================== STATE TABLES ====================
local State = {
    -- Farm states
    isAutoFarmEnabled = false,
    isHighlightEnabled = false,
    isAutoSelectTool = false,
    
    -- Monster states
    isMonsterHighlightEnabled = false,
    isAutoMonsterFarmEnabled = false,
    
    -- Material farm states
    isAutoMaterialFarmEnabled = false,
    
    -- Quest farm states
    isQuestAwareFarmEnabled = false,
    
    -- Misc states
    isTpWalkEnabled = false,
    isFullBrightEnabled = false,
    isNoFogEnabled = false,
    isCameraNoClipEnabled = false,
    isAutoRemoveLavaEnabled = true,
    
    -- Combat states
    isAutoAttackEnabled = false,
    isAutoBlockEnabled = false,
    attackSpeed = 0.3,
    blockDuration = 0.5,
    blockInterval = 1,
    
    -- Settings
    tpWalkSpeed = 1,
    selectedRockTypes = {["Pebble"] = true},
    selectedTool = "Pickaxe",
    selectedMonsterTypes = {["Zombie"] = true},
    selectedMaterial = "Tiny Essence",
    selectedMaterialMonsters = {},
    selectedQuestNPC = "Sensei Moro",
    selectedQuestTypes = {
        KILL = true,
        MINE = true,
        COLLECT = true,
        ORE = true,
        TALK = true,
        EQUIP = true,
        FORGE = false,
        UI = false
    }
}

-- Connection variables (keep as local for direct access)
local currentRock = nil
local currentMonster = nil
local currentMaterialMonster = nil
local currentQuestTarget = nil
local currentQuestType = nil
local activeHighlights = {}
local activeMonsterHighlights = {}
local availableTools = {}
local cachedQuestObjectives = {}
local originalLightingSettings = nil
local fullBrightConnection = nil

-- Fly/NoClip connections for rock farm
local flyBodyGyro = nil
local flyBodyVelocity = nil
local noClipConnection = nil
local antiJitterConnection = nil
local holdPositionConnection = nil

-- Fly/NoClip connections for monster farm
local monsterFlyBodyGyro = nil
local monsterFlyBodyVelocity = nil
local monsterNoClipConnection = nil
local monsterAntiJitterConnection = nil
local monsterHoldPositionConnection = nil

-- Material farm connections
local materialFarmHoldPositionConnection = nil

-- ==================== STATIC DATA ====================
local FarmTypes = {
    "Pebble", "Rock", "Boulder", "Lucky Block",
    "Basalt Rock", "Basalt Core", "Basalt Vein", "Volcanic Rock",
    "Earth Crystal", "Cyan Crystal", "Crimson Crystal", "Violet Crystal",
    "Light Crystal"
}

local SellOreTypes = {
    -- Stonewake's Cross ores
    "Stone", "Sand Stone", "Copper", "Iron", "Tin", "Silver", "Gold", "Platinum",
    "Poopite", "Bananite", "Cardboardite", "Mushroomite", "Aite",
    "Fichillium", "Fichilliugeromoriteite",
    -- Forgotten Kingdom ores
    "Cobalt", "Titanium", "Lapis Lazuli", "Quartz", "Amethyst", "Topaz", "Diamond", "Sapphire", 
    "Ruby", "Emerald", "Cuprite", "Eye Ore", "Rivalite", "Uranium", "Mythril",
    "Lightite", "Obsidian", "Fireite", "Magmaite", "Demonite", "Darkryte",
    -- Goblin Cave crystals
    "Blue Crystal", "Crimson Crystal", "Green Crystal", "Magenta Crystal", "Orange Crystal", "Rainbow Crystal", "Arcane Crystal"
}

local MonsterTypes = {
    "Zombie",
    "EliteZombie",
    "Delver Zombie",
    "Brute Zombie",
    "Bomber",
    "Skeleton Rogue",
    "Axe Skeleton",
    "Deathaxe Skeleton",
    "Elite Rogue Skeleton",
    "Elite Deathaxe Skeleton",
    "Reaper",
    "Blight Pyromancer",
    "Slime",
    "Blazing Slime"
}

local MonsterLootData = {
    ["Zombie"] = {
        {Name = "Tiny Essence", Chance = 3, Amount = "1-2"},
        {Name = "Small Essence", Chance = 3, Amount = "1-2"},
        {Name = "Medium Essence", Chance = 6, Amount = "1-2"}
    },
    ["EliteZombie"] = {
        {Name = "Tiny Essence", Chance = 100, Amount = "1-3"},
        {Name = "Small Essence", Chance = 3, Amount = "1-3"},
        {Name = "Medium Essence", Chance = 4, Amount = "1-3"}
    },
    ["Delver Zombie"] = {
        {Name = "Tiny Essence", Chance = 2, Amount = "1-2"},
        {Name = "Small Essence", Chance = 3, Amount = "1-2"},
        {Name = "Medium Essence", Chance = 6, Amount = "1-2"},
        {Name = "Pickaxe_T1", Chance = 35, Amount = "1-2"}
    },
    ["Brute Zombie"] = {
        {Name = "Medium Essence", Chance = 3, Amount = "1-3"},
        {Name = "Large Essence", Chance = 10, Amount = "1-2"}
    },
    ["Bomber"] = {
        {Name = "Boneite", Chance = 8, Amount = "1"},
        {Name = "Medium Essence", Chance = 4, Amount = "1-2"},
        {Name = "Large Essence", Chance = 8, Amount = "1-2"},
        {Name = "Explosion_T1", Chance = 10, Amount = "1"},
        {Name = "Pickaxe_T1", Chance = 15, Amount = "1"}
    },
    ["Skeleton Rogue"] = {
        {Name = "Boneite", Chance = 8, Amount = "1"},
        {Name = "Tiny Essence", Chance = 2, Amount = "1-4"},
        {Name = "Small Essence", Chance = 4, Amount = "1-3"},
        {Name = "Medium Essence", Chance = 6, Amount = "1-2"}
    },
    ["Axe Skeleton"] = {
        {Name = "Boneite", Chance = 6, Amount = "1"},
        {Name = "Medium Essence", Chance = 4, Amount = "1-3"},
        {Name = "Large Essence", Chance = 6, Amount = "1-2"}
    },
    ["Elite Rogue Skeleton"] = {
        {Name = "Dark Boneite", Chance = 6, Amount = "1"},
        {Name = "Greater Essence", Chance = 6, Amount = "1-3"},
        {Name = "Superior Essence", Chance = 10, Amount = "1-2"},
        {Name = "Epic Essence", Chance = 15, Amount = "1"},
        {Name = "Berserker_T1", Chance = 25, Amount = "1"}
    },
    ["Elite Deathaxe Skeleton"] = {
        {Name = "Dark Boneite", Chance = 6, Amount = "1"},
        {Name = "Greater Essence", Chance = 6, Amount = "1-3"},
        {Name = "Superior Essence", Chance = 10, Amount = "1-2"},
        {Name = "Epic Essence", Chance = 15, Amount = "1"},
        {Name = "Fire_T1", Chance = 25, Amount = "1"},
        {Name = "Thorn_T1", Chance = 40, Amount = "1"}
    },
    ["Deathaxe Skeleton"] = {
        {Name = "Boneite", Chance = 5, Amount = "1"},
        {Name = "Large Essence", Chance = 5, Amount = "2-3"},
        {Name = "Greater Essence", Chance = 8, Amount = "1-3"},
        {Name = "Epic Essence", Chance = 15, Amount = "1"},
        {Name = "Fire_T1", Chance = 35, Amount = "1"},
        {Name = "Thorn_T1", Chance = 50, Amount = "1"}
    },
    ["Reaper"] = {
        {Name = "Dark Boneite", Chance = 6, Amount = "1"},
        {Name = "Superior Essence", Chance = 4, Amount = "2-3"},
        {Name = "Epic Essence", Chance = 5, Amount = "1-3"},
        {Name = "Fire_T1", Chance = 5, Amount = "1"},
        {Name = "LifeSteal_T1", Chance = 12, Amount = "1"}
    },
    ["Blight Pyromancer"] = {
        {Name = "Poison_T1", Chance = 10, Amount = "1"}
    },
    ["Slime"] = {
        {Name = "Slimite", Chance = 6, Amount = "1-2"},
        {Name = "Medium Essence", Chance = 3, Amount = "2-4"},
        {Name = "Large Essence", Chance = 6, Amount = "1-2"},
        {Name = "Greater Essence", Chance = 10, Amount = "1-3"}
    },
    ["Blazing Slime"] = {
        {Name = "Slimite", Chance = 6, Amount = "1-3"},
        {Name = "Superior Essence", Chance = 4, Amount = "2-3"},
        {Name = "Epic Essence", Chance = 5, Amount = "1-2"},
        {Name = "Fire_T1", Chance = 12, Amount = "1"}
    }
}

local function getMobDropInfo(monsterName)
    local drops = MonsterLootData[monsterName]
    if not drops then return "No drop information for this monster" end
    
    local info = "Drops of " .. monsterName .. ":"
    for _, drop in ipairs(drops) do
        info = info .. "\n- " .. drop.Name .. ": " .. drop.Chance .. "% (Amount: " .. drop.Amount .. ")"
    end
    return info
end

-- ==================== AUTO FARM MATERIAL DATA ====================
local currentMaterialMonster = nil
local materialFarmHoldPositionConnection = nil

local MaterialTypes = {
    "Tiny Essence",
    "Small Essence", 
    "Medium Essence",
    "Large Essence",
    "Greater Essence",
    "Superior Essence",
    "Epic Essence",
    "Legendary Essence",
    "Mythical Essence",
    "Boneite",
    "Dark Boneite",
    "Slimite",
    "Pickaxe_T1",
    "Explosion_T1",
    "Fire_T1",
    "Thorn_T1",
    "Poison_T1",
    "LifeSteal_T1",
    "Berserker_T1"
}

local MaterialDropMonsters = {
    ["Tiny Essence"] = {"Zombie", "EliteZombie", "Delver Zombie", "Skeleton Rogue"},
    ["Small Essence"] = {"Zombie", "EliteZombie", "Delver Zombie", "Skeleton Rogue"},
    ["Medium Essence"] = {"Zombie", "EliteZombie", "Delver Zombie", "Brute Zombie", "Bomber", "Skeleton Rogue", "Axe Skeleton", "Slime"},
    ["Large Essence"] = {"Brute Zombie", "Bomber", "Axe Skeleton", "Deathaxe Skeleton", "Slime"},
    ["Greater Essence"] = {"Elite Rogue Skeleton", "Deathaxe Skeleton", "Elite Deathaxe Skeleton", "Reaper", "Slime"},
    ["Superior Essence"] = {"Elite Rogue Skeleton", "Elite Deathaxe Skeleton", "Reaper", "Blazing Slime"},
    ["Epic Essence"] = {"Elite Rogue Skeleton", "Deathaxe Skeleton", "Elite Deathaxe Skeleton", "Reaper", "Blazing Slime"},
    ["Boneite"] = {"Bomber", "Skeleton Rogue", "Axe Skeleton", "Deathaxe Skeleton"},
    ["Dark Boneite"] = {"Elite Rogue Skeleton", "Elite Deathaxe Skeleton", "Reaper"},
    ["Slimite"] = {"Slime", "Blazing Slime"},
    ["Pickaxe_T1"] = {"Delver Zombie", "Bomber"},
    ["Explosion_T1"] = {"Bomber"},
    ["Fire_T1"] = {"Deathaxe Skeleton", "Elite Deathaxe Skeleton", "Reaper", "Blazing Slime"},
    ["Thorn_T1"] = {"Deathaxe Skeleton", "Elite Deathaxe Skeleton"},
    ["Poison_T1"] = {"Blight Pyromancer"},
    ["LifeSteal_T1"] = {"Reaper"},
    ["Berserker_T1"] = {"Elite Rogue Skeleton"}
}

-- ==================== ISLAND MAPPINGS ====================
-- Based on game data: 2 main islands + Goblin Cave area
local IslandList = {"All", "Stonewake's Cross", "Forgotten Kingdom", "Goblin Cave"}

-- Rock types per island (from Rock.lua)
local IslandRockMap = {
    ["All"] = FarmTypes,
    ["Stonewake's Cross"] = {"Pebble", "Rock", "Boulder", "Lucky Block"},
    ["Forgotten Kingdom"] = {"Basalt Rock", "Basalt Core", "Basalt Vein", "Volcanic Rock"},
    ["Goblin Cave"] = {"Earth Crystal", "Cyan Crystal", "Crimson Crystal", "Violet Crystal", "Light Crystal"}
}

-- Monster types per island (from Enemies.lua - all monsters in Forgotten Kingdom except Iron Valley zombies)
local IslandMonsterMap = {
    ["All"] = MonsterTypes,
    ["Stonewake's Cross"] = {"Zombie", "EliteZombie", "Delver Zombie", "Brute Zombie"},
    ["Forgotten Kingdom"] = {"Bomber", "Skeleton Rogue", "Axe Skeleton", "Deathaxe Skeleton", "Elite Rogue Skeleton", "Elite Deathaxe Skeleton", "Reaper", "Blight Pyromancer", "Slime", "Blazing Slime"},
    ["Goblin Cave"] = {}
}

-- Ore types per island (from Rock.lua ore drops)
local IslandOreMap = {
    ["All"] = SellOreTypes,
    ["Stonewake's Cross"] = {"Stone", "Sand Stone", "Copper", "Iron", "Tin", "Silver", "Gold", "Platinum", "Poopite", "Bananite", "Cardboardite", "Mushroomite", "Aite", "Fichillium", "Fichilliugeromoriteite"},
    ["Forgotten Kingdom"] = {"Silver", "Gold", "Platinum", "Cobalt", "Titanium", "Lapis Lazuli", "Quartz", "Amethyst", "Topaz", "Diamond", "Sapphire", "Cuprite", "Emerald", "Ruby", "Rivalite", "Uranium", "Mythril", "Eye Ore", "Lightite", "Obsidian", "Fireite", "Magmaite", "Demonite", "Darkryte"},
    ["Goblin Cave"] = {"Blue Crystal", "Crimson Crystal", "Green Crystal", "Magenta Crystal", "Orange Crystal", "Rainbow Crystal", "Arcane Crystal"}
}

-- Material types per island (based on monster drops from Loot.lua)
local IslandMaterialMap = {
    ["All"] = MaterialTypes,
    ["Stonewake's Cross"] = {"Tiny Essence", "Small Essence", "Medium Essence", "Large Essence", "Pickaxe_T1"},
    ["Forgotten Kingdom"] = {"Tiny Essence", "Small Essence", "Medium Essence", "Large Essence", "Greater Essence", "Superior Essence", "Epic Essence", "Boneite", "Dark Boneite", "Slimite", "Pickaxe_T1", "Explosion_T1", "Fire_T1", "Thorn_T1", "Poison_T1", "LifeSteal_T1", "Berserker_T1"},
    ["Goblin Cave"] = {}
}
local function getMaterialDropRate(materialName, monsterName)
    local drops = MonsterLootData[monsterName]
    if not drops then return 0 end
    for _, drop in ipairs(drops) do
        if drop.Name == materialName then
            return drop.Chance
        end
    end
    return 0
end

local function getMonstersForMaterial(materialName)
    local monsters = MaterialDropMonsters[materialName] or {}
    local result = {}
    for _, monsterName in ipairs(monsters) do
        local rate = getMaterialDropRate(materialName, monsterName)
        table.insert(result, monsterName .. " (" .. rate .. "%)")
    end
    return result
end

-- ==================== QUEST-AWARE FARM DATA ====================
local currentQuestTarget = nil
local currentQuestType = nil

local MonsterIslandMap = {
    ["Zombie"] = "Stonewake's Cross",
    ["EliteZombie"] = "Stonewake's Cross",
    ["Delver Zombie"] = "Stonewake's Cross",
    ["Brute Zombie"] = "Stonewake's Cross",
    ["Bomber"] = "Forgotten Kingdom",
    ["Skeleton Rogue"] = "Forgotten Kingdom",
    ["Axe Skeleton"] = "Forgotten Kingdom",
    ["Deathaxe Skeleton"] = "Forgotten Kingdom",
    ["Elite Rogue Skeleton"] = "Forgotten Kingdom",
    ["Elite Deathaxe Skeleton"] = "Forgotten Kingdom",
    ["Reaper"] = "Forgotten Kingdom",
    ["Slime"] = "Forgotten Kingdom",
    ["Blazing Slime"] = "Forgotten Kingdom",
    ["Blight Pyromancer"] = "Forgotten Kingdom"
}

local OreToRockMap = {
    ["Stone"] = "Pebble", ["Copper"] = "Pebble", ["Tin"] = "Pebble", ["Sand Stone"] = "Pebble",
    ["Iron"] = "Rock", ["Silver"] = "Rock", ["Gold"] = "Rock",
    ["Platinum"] = "Boulder", ["Starite"] = "Boulder", ["Poopite"] = "Boulder",
    ["Bananite"] = "Boulder", ["Cardboardite"] = "Boulder",
    ["Cobalt"] = "Basalt Rock", ["Titanium"] = "Basalt Rock", ["Lapis Lazuli"] = "Basalt Rock",
    ["Quartz"] = "Basalt Core", ["Amethyst"] = "Basalt Core", ["Topaz"] = "Basalt Core",
    ["Diamond"] = "Basalt Core", ["Sapphire"] = "Basalt Core",
    ["Ruby"] = "Basalt Vein", ["Emerald"] = "Basalt Vein", ["Cuprite"] = "Basalt Vein",
    ["Eye Ore"] = "Basalt Vein", ["Rivalite"] = "Basalt Vein", ["Uranium"] = "Basalt Vein",
    ["Mythril"] = "Volcanic Rock", ["Lightite"] = "Volcanic Rock",
    ["Obsidian"] = "Volcanic Rock", ["Fireite"] = "Volcanic Rock",
    ["Magmaite"] = "Volcanic Rock", ["Demonite"] = "Volcanic Rock"
}

local RockIslandMap = {
    ["Pebble"] = "Stonewake's Cross", ["Rock"] = "Stonewake's Cross",
    ["Boulder"] = "Stonewake's Cross", ["Lucky Block"] = "Stonewake's Cross",
    ["Basalt Rock"] = "Forgotten Kingdom", ["Basalt Core"] = "Forgotten Kingdom",
    ["Basalt Vein"] = "Forgotten Kingdom", ["Volcanic Rock"] = "Forgotten Kingdom"
}

-- ==================== NEW QUEST SYSTEM (KNIT REPLICA) ====================
local function getQuestReplica()
    local Knit = require(ReplicatedStorage.Shared.Packages.Knit)
    local PlayerController = Knit.GetController("PlayerController")
    if PlayerController and PlayerController.Replica and PlayerController.Replica.Data then
        return PlayerController.Replica.Data.Quests
    end
    return nil
end

local function getQuestStaticData()
    -- Attempt to load static quest data
    local success, result = pcall(function()
        return require(ReplicatedStorage.Shared.Data.Quests)
    end)
    if success then return result end
    return nil
end

local function getFarmableQuestObjectives()
    local farmable = {}
    local quests = getQuestReplica()
    local staticQuests = getQuestStaticData()
    if not quests or not staticQuests then
        return farmable
    end

    local function normalizeType(t, target)
        t = tostring(t or ""):lower()
        target = tostring(target or "")
        if target == "Ore" then
            return "collect_ore"
        end
        if t == "kill" then return "kill" end
        if t == "collect" then return "collect" end
        if t == "mine" then return "mine" end
        if t == "forge" then return "forge" end
        if t == "equip" then return "equip" end
        if t == "talk" then return "talk" end
        if t == "ui" then return "ui" end
        return "unknown"
    end

    local function isCompleted(current, required)
        current = tonumber(current) or 0
        if required == nil then
            return current > 0
        end
        required = tonumber(required) or 0
        return current >= required
    end

    for questId, questData in pairs(quests) do
        local staticQuest = staticQuests[questId]
        if questData and questData.Progress and staticQuest and staticQuest.Objectives then
            for objectiveId, progressInfo in pairs(questData.Progress) do
                progressInfo = progressInfo or {}

                -- Resolve objective index robustly (Replica keys can be strings; sometimes progressInfo has Index)
                local objIndex = progressInfo.Index or progressInfo.index or tonumber(objectiveId) or objectiveId
                local staticObj = staticQuest.Objectives[objIndex]

                -- Fallback: try to find matching objective by target/type if indexing fails
                if not staticObj and (progressInfo.target or progressInfo.requiredAmount or progressInfo.questType) then
                    for _, cand in pairs(staticQuest.Objectives) do
                        if cand then
                            local candTarget = progressInfo.target or cand.Target
                            local candType = progressInfo.questType or cand.Type
                            if candTarget == cand.Target and candType == cand.Type then
                                staticObj = cand
                                break
                            end
                        end
                    end
                end

                local current = progressInfo.currentProgress or 0
                local required = (progressInfo.requiredAmount ~= nil and progressInfo.requiredAmount) or (staticObj and staticObj.Amount) or nil
                local target = (progressInfo.target ~= nil and progressInfo.target) or (staticObj and staticObj.Target) or "Unknown"
                local questType = (progressInfo.questType ~= nil and progressInfo.questType) or (staticObj and staticObj.Type) or "Unknown"

                if not isCompleted(current, required) then
                    local parsedType = normalizeType(questType, target)

                    -- Only list types that we can at least "handle" in some way (even if not fully farmable)
                    if parsedType ~= "unknown" then
                        table.insert(farmable, {
                            type = parsedType,
                            target = target,
                            current = tonumber(current) or 0,
                            required = tonumber(required) or (required == nil and 1 or 0),
                            questId = questId,
                            objectiveId = objectiveId,
                            rawType = questType
                        })
                    end
                end
            end
        end
    end

    return farmable
end


local function teleportToIsland(islandName)
    pcall(function()
        local args = {islandName}
        ReplicatedStorage:WaitForChild("Shared")
            :WaitForChild("Packages")
            :WaitForChild("Knit")
            :WaitForChild("Services")
            :WaitForChild("PortalService")
            :WaitForChild("RF")
            :WaitForChild("TeleportToIsland")
            :InvokeServer(unpack(args))
    end)
end

local QuestNPCList = {
    "Sensei Moro",
    "Nord",
    "UmutTheBrave",
    "Bard",
    "Wizard",
    "Masked Stranger",
    "Amber",
    "Barakkulf",
    "Ceypai ( Daily Quest )",
    "Sensei Moro 2",
    "Captain Rowan"
}

local function openDialogue(npcName)
    pcall(function()
        local npc = Workspace:WaitForChild("Proximity"):FindFirstChild(npcName)
        if npc then
            local args = {npc}
            ReplicatedStorage:WaitForChild("Shared")
                :WaitForChild("Packages")
                :WaitForChild("Knit")
                :WaitForChild("Services")
                :WaitForChild("ProximityService")
                :WaitForChild("RF")
                :WaitForChild("Dialogue")
                :InvokeServer(unpack(args))
        end
    end)
end

local function fireDialogueEvent(eventType)
    pcall(function()
        local args = {eventType}
        ReplicatedStorage:WaitForChild("Shared")
            :WaitForChild("Packages")
            :WaitForChild("Knit")
            :WaitForChild("Services")
            :WaitForChild("DialogueService")
            :WaitForChild("RE")
            :WaitForChild("DialogueEvent")
            :FireServer(unpack(args))
    end)
end

local function runDialogueCommand(command)
    pcall(function()
        local args = {command}
        ReplicatedStorage:WaitForChild("Shared")
            :WaitForChild("Packages")
            :WaitForChild("Knit")
            :WaitForChild("Services")
            :WaitForChild("DialogueService")
            :WaitForChild("RF")
            :WaitForChild("RunCommand")
            :InvokeServer(unpack(args))
    end)
end

local function autoTalkToNPC(npcName)
    openDialogue(npcName)
    task.wait(0.3)
    fireDialogueEvent("Opened")
    task.wait(0.2)
    runDialogueCommand("CheckQuest")
    task.wait(0.3)
    runDialogueCommand("FinishQuest")
    task.wait(0.3)
    fireDialogueEvent("Closed")
end



local function getCurrentQuestObjectives()
    local quests = getQuestReplica()
    if not quests then
        return "Cannot get Quest data (Replica not loaded)"
    end

    local staticQuests = getQuestStaticData()
    local objectives = {}

    local function isCompleted(current, required)
        current = tonumber(current) or 0
        if required == nil then
            return current > 0
        end
        required = tonumber(required) or 0
        return current >= required
    end

    for questId, questData in pairs(quests) do
        local staticQuest = staticQuests and staticQuests[questId] or nil
        local questName = (questData and questData.Name) or (staticQuest and staticQuest.Name) or tostring(questId)

        table.insert(objectives, ("[%s] %s"):format(tostring(questId), tostring(questName)))

        if questData and questData.Progress then
            for objectiveId, progressInfo in pairs(questData.Progress) do
                progressInfo = progressInfo or {}
                local objIndex = progressInfo.Index or progressInfo.index or tonumber(objectiveId) or objectiveId
                local staticObj = staticQuest and staticQuest.Objectives and staticQuest.Objectives[objIndex] or nil

                local current = progressInfo.currentProgress or 0
                local required = (progressInfo.requiredAmount ~= nil and progressInfo.requiredAmount) or (staticObj and staticObj.Amount) or nil
                local target = (progressInfo.target ~= nil and progressInfo.target) or (staticObj and staticObj.Target) or "Unknown"
                local qType = (progressInfo.questType ~= nil and progressInfo.questType) or (staticObj and staticObj.Type) or "Unknown"

                local done = isCompleted(current, required)
                local status = done and "✅" or "⏳"
                local reqText = (required == nil) and "?" or tostring(required)

                table.insert(objectives, string.format("  %s Obj[%s] %s - %s: %s/%s",
                    status, tostring(objectiveId), tostring(qType), tostring(target), tostring(current), reqText))
            end
        end

        table.insert(objectives, "") -- blank line between quests
    end

    if #objectives == 0 then
        return "No active quest"
    end

    return table.concat(objectives, "\n")
end


local function equipItem(itemName)
    pcall(function()
        local args = {
            {
                Runes = {},
                Name = itemName
            }
        }
        ReplicatedStorage:WaitForChild("Shared")
            :WaitForChild("Packages")
            :WaitForChild("Knit")
            :WaitForChild("Services")
            :WaitForChild("CharacterService")
            :WaitForChild("RF")
            :WaitForChild("EquipItem")
            :InvokeServer(unpack(args))
    end)
end

local function getIncompleteQuestObjectives()
    local incompleteObjectives = {}
    local quests = getQuestReplica()
    local staticQuests = getQuestStaticData()
    if not quests then
        return incompleteObjectives
    end

    local function normalizeType(t, target)
        t = tostring(t or ""):lower()
        target = tostring(target or "")
        if target == "Ore" then
            return "collect_ore"
        end
        if t == "kill" then return "kill" end
        if t == "collect" then return "collect" end
        if t == "mine" then return "mine" end
        if t == "forge" then return "forge" end
        if t == "equip" then return "equip" end
        if t == "talk" then return "talk" end
        if t == "ui" then return "ui" end
        return "unknown"
    end

    local function isCompleted(current, required)
        current = tonumber(current) or 0
        if required == nil then
            return current > 0
        end
        required = tonumber(required) or 0
        return current >= required
    end

    for questId, questData in pairs(quests) do
        local staticQuest = staticQuests and staticQuests[questId] or nil

        if questData and questData.Progress then
            for objectiveId, progressInfo in pairs(questData.Progress) do
                progressInfo = progressInfo or {}
                local objIndex = progressInfo.Index or progressInfo.index or tonumber(objectiveId) or objectiveId
                local staticObj = staticQuest and staticQuest.Objectives and staticQuest.Objectives[objIndex] or nil

                local current = progressInfo.currentProgress or 0
                local required = (progressInfo.requiredAmount ~= nil and progressInfo.requiredAmount) or (staticObj and staticObj.Amount) or nil
                local target = (progressInfo.target ~= nil and progressInfo.target) or (staticObj and staticObj.Target) or "Unknown"
                local questType = (progressInfo.questType ~= nil and progressInfo.questType) or (staticObj and staticObj.Type) or "Unknown"

                if not isCompleted(current, required) then
                    local parsedType = normalizeType(questType, target)
                    table.insert(incompleteObjectives, {
                        type = parsedType,
                        target = target,
                        amount = tonumber(required) or (required == nil and 1 or 0),
                        current = tonumber(current) or 0,
                        questType = questType,
                        questId = questId,
                        objectiveId = objectiveId,
                        raw = string.format("%s: %s", tostring(questType), tostring(target))
                    })
                end
            end
        end
    end

    return incompleteObjectives
end


local isAutoQuestEnabled = false

local PickaxeShopList = {
    "Stone Pickaxe - Free",
    "Bronze Pickaxe - 150 Gold",
    "Iron Pickaxe - 500 Gold",
    "Gold Pickaxe - 2,000 Gold",
    "Platinum Pickaxe - 8,000 Gold",
    "Cobalt Pickaxe - 25,000 Gold",
    "Titanium Pickaxe - 75,000 Gold",
    "Uranium Pickaxe - 200,000 Gold",
    "Mythril Pickaxe - 500,000 Gold",
    "Lightite Pickaxe - 1,500,000 Gold",
    "Arcane Pickaxe - 5,000,000 Gold",
    "Magma Pickaxe - 15,000,000 Gold",
    "Demonic Pickaxe - 50,000,000 Gold",
    "Stonewake's Pickaxe - Special"
}

local selectedShopPickaxe = "Bronze Pickaxe"

local function getPickaxeNameFromDropdown(dropdownValue)
    return dropdownValue:match("^(.+) %- ")
end

local function buyPickaxe(pickaxeName)
    pcall(function()
        local args = {pickaxeName, 1}
        ReplicatedStorage:WaitForChild("Shared")
            :WaitForChild("Packages")
            :WaitForChild("Knit")
            :WaitForChild("Services")
            :WaitForChild("ProximityService")
            :WaitForChild("RF")
            :WaitForChild("Purchase")
            :InvokeServer(unpack(args))
    end)
end

local PotionShopList = {
    "MinerPotion1 - Miner Potion I",
    "HealthPotion1 - Health Potion I",
    "HealthPotion2 - Health Potion II",
    "AttackDamagePotion1 - Damage Potion I",
    "MovementSpeedPotion1 - Speed Potion I",
    "LuckPotion1 - Luck Potion I"
}

local PotionDescriptions = {
    ["MinerPotion1"] = "15% faster mining, 10% extra mining damage",
    ["HealthPotion1"] = "Recover 30 health over 5 seconds",
    ["HealthPotion2"] = "Recover 75 health over 5 seconds",
    ["AttackDamagePotion1"] = "10% extra physical damage",
    ["MovementSpeedPotion1"] = "15% extra movement speed",
    ["LuckPotion1"] = "20% extra luck boost"
}

local selectedShopPotion = "MinerPotion1"

local function getPotionIdFromDropdown(dropdownValue)
    return dropdownValue:match("^(.+) %- ")
end

local function buyPotion(potionId)
    pcall(function()
        local args = {potionId, 1}
        ReplicatedStorage:WaitForChild("Shared")
            :WaitForChild("Packages")
            :WaitForChild("Knit")
            :WaitForChild("Services")
            :WaitForChild("ProximityService")
            :WaitForChild("RF")
            :WaitForChild("Purchase")
            :InvokeServer(unpack(args))
    end)
end

local FarmTypes = {
    "Pebble",
    "Rock",
    "Boulder",
    "Lucky Block",
    "Basalt Rock",
    "Basalt Core",
    "Basalt Vein",
    "Volcanic Rock",
    "Earth Crystal",
    "Cyan Crystal",
    "Crimson Crystal",
    "Violet Crystal",
    "Light Crystal"
}

local function findAllRocks()
    local rocks = {}
    local rocksFolder = Workspace:FindFirstChild("Rocks")
    if rocksFolder then
        for _, child in pairs(rocksFolder:GetDescendants()) do
            if State.selectedRockTypes[child.Name] and (child:IsA("BasePart") or child:IsA("Model")) then
                table.insert(rocks, child)
            end
        end
    end
    if #rocks == 0 then
        for _, child in pairs(Workspace:GetDescendants()) do
            if State.selectedRockTypes[child.Name] and (child:IsA("BasePart") or child:IsA("Model")) then
                table.insert(rocks, child)
            end
        end
    end
    return rocks
end

local function getRockPosition(rock)
    if rock:IsA("Model") then
        local primaryPart = rock.PrimaryPart or rock:FindFirstChildWhichIsA("BasePart")
        if primaryPart then
            return primaryPart.Position
        end
    elseif rock:IsA("BasePart") then
        return rock.Position
    end
    return nil
end

local function getRockPart(rock)
    if rock:IsA("Model") then
        return rock.PrimaryPart or rock:FindFirstChildWhichIsA("BasePart")
    elseif rock:IsA("BasePart") then
        return rock
    end
    return nil
end

local PLAYER_SKIP_DISTANCE = 5

local function isOtherPlayerNearRock(rock)
    local rockPos = getRockPosition(rock)
    if not rockPos then return false end
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local character = player.Character
            if character then
                local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
                if humanoidRootPart then
                    local distance = (humanoidRootPart.Position - rockPos).Magnitude
                    if distance <= PLAYER_SKIP_DISTANCE then
                        return true
                    end
                end
            end
        end
    end
    return false
end

local function findNearestRock()
    local rocks = findAllRocks()
    local character = LocalPlayer.Character
    if not character then return nil end
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return nil end
    local playerPos = humanoidRootPart.Position
    local nearestRock = nil
    local nearestDistance = math.huge
    for _, rock in pairs(rocks) do
        local rockPos = getRockPosition(rock)
        if rockPos then
            if not isOtherPlayerNearRock(rock) then
                local distance = (rockPos - playerPos).Magnitude
                if distance < nearestDistance then
                    nearestDistance = distance
                    nearestRock = rock
                end
            end
        end
    end
    return nearestRock
end

local function getRockHP(rock)
    local infoFrame = rock:FindFirstChild("infoFrame")
    if not infoFrame then return nil end
    local frame = infoFrame:FindFirstChild("Frame")
    if not frame then return nil end
    local rockHP = frame:FindFirstChild("rockHP")
    if not rockHP then return nil end
    local hpText = rockHP.Text
    if hpText then
        local hp = tonumber(hpText:match("[%d%.]+"))
        return hp
    end
    return nil
end

local function isRockValid(rock)
    if rock == nil then return false end
    if not rock.Parent then return false end
    local hp = getRockHP(rock)
    if hp ~= nil and hp <= 0 then
        return false
    end
    return true
end

local CLOSE_DISTANCE = 45
local CLOSE_TWEEN_TIME = 0.5
local FAR_TWEEN_TIME = 8
local ROCK_OFFSET_BELOW = 8

local function enableFly(character)
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end
    
    if flyBodyGyro then flyBodyGyro:Destroy() end
    if flyBodyVelocity then flyBodyVelocity:Destroy() end
    
    flyBodyGyro = Instance.new("BodyGyro")
    flyBodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    flyBodyGyro.P = 1000000
    flyBodyGyro.D = 100
    flyBodyGyro.Parent = humanoidRootPart
    
    flyBodyVelocity = Instance.new("BodyVelocity")
    flyBodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    flyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
    flyBodyVelocity.Parent = humanoidRootPart
end

local function disableFly()
    if flyBodyGyro then flyBodyGyro:Destroy() flyBodyGyro = nil end
    if flyBodyVelocity then flyBodyVelocity:Destroy() flyBodyVelocity = nil end
end

local function enableNoClip(character)
    if noClipConnection then noClipConnection:Disconnect() end
    noClipConnection = RunService.Stepped:Connect(function()
        if character and character:FindFirstChild("Humanoid") then
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end)
end

local function disableNoClip()
    if noClipConnection then noClipConnection:Disconnect() noClipConnection = nil end
end

local function enablePlatformStand(character)
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.PlatformStand = true
    end
end

local function disablePlatformStand(character)
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.PlatformStand = false
    end
end

local function enableAntiJitter(character)
    if antiJitterConnection then antiJitterConnection:Disconnect() end
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end
    antiJitterConnection = RunService.RenderStepped:Connect(function()
        if humanoidRootPart and humanoidRootPart.Parent then
            humanoidRootPart.Velocity = Vector3.new(0, 0, 0)
            humanoidRootPart.RotVelocity = Vector3.new(0, 0, 0)
        end
    end)
end

local function disableAntiJitter()
    if antiJitterConnection then antiJitterConnection:Disconnect() antiJitterConnection = nil end
end

local function tweenToRock(rock)
    local character = LocalPlayer.Character
    if not character then return false end
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return false end
    local rockPos = getRockPosition(rock)
    if not rockPos then return false end
    local distance = (rockPos - humanoidRootPart.Position).Magnitude
    local tweenTime = distance / 50
    
    local targetPos = rockPos + Vector3.new(0, ROCK_OFFSET_BELOW, 0)
    local lookUpCFrame = CFrame.new(targetPos) * CFrame.Angles(math.rad(-90), 0, 0)
    
    local tweenInfo = TweenInfo.new(tweenTime, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(humanoidRootPart, tweenInfo, {CFrame = lookUpCFrame})
    tween:Play()
    tween.Completed:Wait()
    return true
end

local function holdPositionBelowRock(rock)
    if holdPositionConnection then holdPositionConnection:Disconnect() end
    local character = LocalPlayer.Character
    if not character then return end
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end
    
    holdPositionConnection = RunService.Heartbeat:Connect(function()
        if not State.isAutoFarmEnabled or not isRockValid(rock) then
            if holdPositionConnection then holdPositionConnection:Disconnect() holdPositionConnection = nil end
            return
        end
        local rockPos = getRockPosition(rock)
        if rockPos then
            local targetPos = rockPos + Vector3.new(0, ROCK_OFFSET_BELOW, 0)
            local lookUpCFrame = CFrame.new(targetPos) * CFrame.Angles(math.rad(-90), 0, 0)
            humanoidRootPart.CFrame = lookUpCFrame
            if flyBodyGyro then
                flyBodyGyro.CFrame = lookUpCFrame
            end
        end
    end)
end

local function stopHoldPosition()
    if holdPositionConnection then holdPositionConnection:Disconnect() holdPositionConnection = nil end
end

local NumberKeyCodes = {
    Enum.KeyCode.One,
    Enum.KeyCode.Two,
    Enum.KeyCode.Three,
    Enum.KeyCode.Four,
    Enum.KeyCode.Five,
    Enum.KeyCode.Six,
    Enum.KeyCode.Seven,
    Enum.KeyCode.Eight,
    Enum.KeyCode.Nine
}

local function getToolSlotPosition(toolName)
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if not backpack then return nil end
    local tools = {}
    for _, item in pairs(backpack:GetChildren()) do
        if item:IsA("Tool") then
            table.insert(tools, item.Name)
        end
    end
    for i, name in ipairs(tools) do
        if name == toolName then
            return math.min(i, 9)
        end
    end
    return nil
end

local function equipTool()
    local character = LocalPlayer.Character
    if not character then return end
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then return end

    -- Check if already equipped
    local equipped = character:FindFirstChild(State.selectedTool)
    if equipped and equipped:IsA("Tool") then
        return -- Already equipped
    end

    -- Find in Backpack and Equip
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if backpack then
        local tool = backpack:FindFirstChild(State.selectedTool)
        if tool then
            humanoid:EquipTool(tool)
        end
    end
end

local function activatePickaxe()
    pcall(function()
        local toolArg = State.selectedTool
        if State.selectedTool == "Weapon" then
            toolArg = "Weapon"
        end
        local args = {toolArg}
        ReplicatedStorage:WaitForChild("Shared")
            :WaitForChild("Packages")
            :WaitForChild("Knit")
            :WaitForChild("Services")
            :WaitForChild("ToolService")
            :WaitForChild("RF")
            :WaitForChild("ToolActivated")
            :InvokeServer(unpack(args))
    end)
end

local function getBackpackPickaxes()
    local pickaxes = {"Weapon"}
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    local character = LocalPlayer.Character
    if backpack then
        for _, tool in pairs(backpack:GetChildren()) do
            if tool:IsA("Tool") and string.find(tool.Name, "Pickaxe") then
                table.insert(pickaxes, tool.Name)
            end
        end
    end
    if character then
        for _, tool in pairs(character:GetChildren()) do
            if tool:IsA("Tool") and string.find(tool.Name, "Pickaxe") then
                if not table.find(pickaxes, tool.Name) then
                    table.insert(pickaxes, tool.Name)
                end
            end
        end
    end
    if #pickaxes == 0 then
        table.insert(pickaxes, "Pickaxe")
    end
    return pickaxes
end

local function selectBestPickaxe()
    local pickaxes = getBackpackPickaxes()
    if #pickaxes > 0 then
        return pickaxes[#pickaxes]
    end
    return "Pickaxe"
end

local function clearAllHighlights()
    for _, highlight in pairs(activeHighlights) do
        if highlight and highlight.Parent then
            highlight:Destroy()
        end
    end
    activeHighlights = {}
end

local function createHighlight(rock)
    local part = getRockPart(rock)
    if not part then return nil end
    local existingHighlight = part:FindFirstChild("RockHighlight")
    if existingHighlight then return existingHighlight end
    local highlight = Instance.new("Highlight")
    highlight.Name = "RockHighlight"
    highlight.Adornee = rock:IsA("Model") and rock or part
    highlight.FillColor = Color3.fromRGB(0, 255, 100)
    highlight.FillTransparency = 0.5
    highlight.OutlineColor = Color3.fromRGB(255, 255, 0)
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = part
    table.insert(activeHighlights, highlight)
    return highlight
end

local function updateHighlights()
    clearAllHighlights()
    if not State.isHighlightEnabled then return end
    local rocks = findAllRocks()
    for _, rock in pairs(rocks) do
        createHighlight(rock)
    end
end

local function findAllMonsters()
    local monsters = {}
    local livingFolder = Workspace:FindFirstChild("Living")
    if livingFolder then
        for _, child in pairs(livingFolder:GetChildren()) do
            local monsterName = child.Name:gsub("%d+", "")
            if State.selectedMonsterTypes[monsterName] then
                table.insert(monsters, child)
            end
        end
    end
    return monsters
end

local function getMonsterPart(monster)
    if monster:IsA("Model") then
        return monster.PrimaryPart or monster:FindFirstChild("HumanoidRootPart") or monster:FindFirstChildWhichIsA("BasePart")
    elseif monster:IsA("BasePart") then
        return monster
    end
    return nil
end

local function clearAllMonsterHighlights()
    for _, highlight in pairs(activeMonsterHighlights) do
        if highlight and highlight.Parent then
            highlight:Destroy()
        end
    end
    activeMonsterHighlights = {}
end

local function createMonsterHighlight(monster)
    local part = getMonsterPart(monster)
    if not part then return nil end
    local existingHighlight = monster:FindFirstChild("MonsterHighlight")
    if existingHighlight then return existingHighlight end
    local highlight = Instance.new("Highlight")
    highlight.Name = "MonsterHighlight"
    highlight.Adornee = monster
    highlight.FillColor = Color3.fromRGB(255, 0, 0)
    highlight.FillTransparency = 0.5
    highlight.OutlineColor = Color3.fromRGB(255, 100, 0)
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = monster
    table.insert(activeMonsterHighlights, highlight)
    return highlight
end

local function updateMonsterHighlights()
    clearAllMonsterHighlights()
    if not State.isMonsterHighlightEnabled then return end
    local monsters = findAllMonsters()
    for _, monster in pairs(monsters) do
        createMonsterHighlight(monster)
    end
end

local MonsterDropdown = Tabs.Monsters:CreateDropdown("MonsterSelect", {
    Title = "Monster Select",
    Description = "Select Monster type to highlight",
    Values = MonsterTypes,
    Multi = true,
    Default = {"Zombie"}
})

local MonsterHighlightToggle = Tabs.Monsters:CreateToggle("MonsterHighlight", {
    Title = "Highlight Monster",
    Description = "Highlight selected Monster",
    Default = false
})

MonsterHighlightToggle:OnChanged(function()
    State.isMonsterHighlightEnabled = Options.MonsterHighlight.Value
    if State.isMonsterHighlightEnabled then
        updateMonsterHighlights()
    else
        clearAllMonsterHighlights()
    end
end)

local AutoMonsterFarmToggle = Tabs.Monsters:CreateToggle("AutoMonsterFarm", {
    Title = "Auto Farm Monster",
    Description = "Farm selected Monster",
    Default = false
})

local MobInfoSection = Tabs.Monsters:CreateSection("MOB INFO")

local MobInfoParagraph = Tabs.Monsters:CreateParagraph("MobInfo", {
    Title = "Mob Drop Information",
    Content = getMobDropInfo("Zombie")
})

MonsterDropdown:OnChanged(function(Value)
    -- Value is table { [Name] = true, ... }
    State.selectedMonsterTypes = Value
    if State.isMonsterHighlightEnabled then
        updateMonsterHighlights()
    end
    if MobInfoParagraph then
        -- Show info for first selected
        for k, v in pairs(Value) do
            if v == true then
                MobInfoParagraph:SetContent(getMobDropInfo(k))
                break
            end
        end
    end
end)

-- ==================== AUTO FARM MATERIAL UI SECTION ====================
local MaterialFarmSection = Tabs.Monsters:CreateSection("AUTO FARM MATERIAL")

local MaterialDropdown = Tabs.Monsters:CreateDropdown("MaterialSelect", {
    Title = "Select Material",
    Description = "Select Material type to farm",
    Values = MaterialTypes,
    Multi = false,
    Default = "Tiny Essence"
})

local MaterialMonsterDropdown = Tabs.Monsters:CreateDropdown("MaterialMonsterSelect", {
    Title = "Select Monsters to Farm",
    Description = "Select Monster to farm (by drop rate)",
    Values = getMonstersForMaterial("Tiny Essence"),
    Multi = true,
    Default = {}
})

local AutoMaterialFarmToggle = Tabs.Monsters:CreateToggle("AutoMaterialFarm", {
    Title = "Auto Farm Material",
    Description = "Automatically farm selected Monster to get Material",
    Default = false
})

MaterialDropdown:OnChanged(function(Value)
    State.selectedMaterial = Value
    local newMonsters = getMonstersForMaterial(Value)
    MaterialMonsterDropdown:SetValues(newMonsters)
    State.selectedMaterialMonsters = {}
end)

MaterialMonsterDropdown:OnChanged(function(Value)
    State.selectedMaterialMonsters = {}
    if type(Value) == "table" then
        for monsterWithRate, isSelected in pairs(Value) do
            if isSelected then
                local monsterName = monsterWithRate:match("^(.+) %(")
                if monsterName then
                    table.insert(State.selectedMaterialMonsters, monsterName)
                end
            end
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(2)
        if State.isMonsterHighlightEnabled then
            updateMonsterHighlights()
        end
    end
end)

-- ==================== CAMERA NOCLIP (View not blocked by parts) ====================
local originalPopperConstants = {}

local function enableCameraNoClip()
    pcall(function()
        local sc = (debug and debug.setconstant) or setconstant
        local gc = (debug and debug.getconstants) or getconstants
        if not sc or not getgc or not gc then
            Library:Notify({Title = "Error", Content = "Exploit does not support camera noclip", Duration = 3})
            return
        end
        local speaker = LocalPlayer
        local pop = speaker.PlayerScripts.PlayerModule.CameraModule.ZoomController.Popper
        for _, v in pairs(getgc()) do
            if type(v) == "function" and getfenv(v).script == pop then
                for i, v1 in pairs(gc(v)) do
                    if tonumber(v1) == 0.25 then
                        sc(v, i, 0)
                    end
                end
            end
        end
        State.isCameraNoClipEnabled = true
    end)
end

local function disableCameraNoClip()
    pcall(function()
        local sc = (debug and debug.setconstant) or setconstant
        local gc = (debug and debug.getconstants) or getconstants
        if not sc or not getgc or not gc then return end
        local speaker = LocalPlayer
        local pop = speaker.PlayerScripts.PlayerModule.CameraModule.ZoomController.Popper
        for _, v in pairs(getgc()) do
            if type(v) == "function" and getfenv(v).script == pop then
                for i, v1 in pairs(gc(v)) do
                    if tonumber(v1) == 0 then
                        sc(v, i, 0.25)
                    end
                end
            end
        end
        State.isCameraNoClipEnabled = false
    end)
end

local function getMonsterPosition(monster)
    if monster:IsA("Model") then
        local hrp = monster:FindFirstChild("HumanoidRootPart")
        if hrp then return hrp.Position end
        local primaryPart = monster.PrimaryPart or monster:FindFirstChildWhichIsA("BasePart")
        if primaryPart then return primaryPart.Position end
    elseif monster:IsA("BasePart") then
        return monster.Position
    end
    return nil
end

local function getMonsterHP(monster)
    local hrp = monster:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    local infoFrame = hrp:FindFirstChild("infoFrame")
    if not infoFrame then return nil end
    local frame = infoFrame:FindFirstChild("Frame")
    if not frame then return nil end
    local rockHP = frame:FindFirstChild("rockHP")
    if not rockHP then return nil end
    local hpText = rockHP.Text
    if hpText then
        local hp = tonumber(hpText:match("[%d%.]+"))
        return hp
    end
    return nil
end

local function isMonsterValid(monster)
    if monster == nil then return false end
    if not monster.Parent then return false end
    local hp = getMonsterHP(monster)
    if hp ~= nil and hp <= 0 then
        return false
    end
    return true
end

local function findNearestMonster()
    local monsters = findAllMonsters()
    local character = LocalPlayer.Character
    if not character then return nil end
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return nil end
    local playerPos = humanoidRootPart.Position
    local nearestMonster = nil
    local nearestDistance = math.huge
    for _, monster in pairs(monsters) do
        if isMonsterValid(monster) then
            local monsterPos = getMonsterPosition(monster)
            if monsterPos then
                local distance = (monsterPos - playerPos).Magnitude
                if distance < nearestDistance then
                    nearestDistance = distance
                    nearestMonster = monster
                end
            end
        end
    end
    return nearestMonster
end

do -- Auto Monster Farm Scope
    local MONSTER_CLOSE_DISTANCE = 45
    local MONSTER_CLOSE_TWEEN_TIME = 0.5
    local MONSTER_FAR_TWEEN_TIME = 8
    local MONSTER_OFFSET_BELOW = 7

    local function enableMonsterFly(character)
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if not humanoidRootPart then return end
        if monsterFlyBodyGyro then monsterFlyBodyGyro:Destroy() end
        if monsterFlyBodyVelocity then monsterFlyBodyVelocity:Destroy() end
        monsterFlyBodyGyro = Instance.new("BodyGyro")
        monsterFlyBodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        monsterFlyBodyGyro.P = 1000000
        monsterFlyBodyGyro.D = 100
        monsterFlyBodyGyro.Parent = humanoidRootPart
        monsterFlyBodyVelocity = Instance.new("BodyVelocity")
        monsterFlyBodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        monsterFlyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
        monsterFlyBodyVelocity.Parent = humanoidRootPart
    end

    local function disableMonsterFly()
        if monsterFlyBodyGyro then monsterFlyBodyGyro:Destroy() monsterFlyBodyGyro = nil end
        if monsterFlyBodyVelocity then monsterFlyBodyVelocity:Destroy() monsterFlyBodyVelocity = nil end
    end

    local function enableMonsterNoClip(character)
        if monsterNoClipConnection then monsterNoClipConnection:Disconnect() end
        monsterNoClipConnection = RunService.Stepped:Connect(function()
            if character and character:FindFirstChild("Humanoid") then
                for _, part in pairs(character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    end

    local function disableMonsterNoClip()
        if monsterNoClipConnection then monsterNoClipConnection:Disconnect() monsterNoClipConnection = nil end
    end

    local function enableMonsterAntiJitter(character)
        if monsterAntiJitterConnection then monsterAntiJitterConnection:Disconnect() end
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if not humanoidRootPart then return end
        monsterAntiJitterConnection = RunService.RenderStepped:Connect(function()
            if humanoidRootPart and humanoidRootPart.Parent then
                humanoidRootPart.Velocity = Vector3.new(0, 0, 0)
                humanoidRootPart.RotVelocity = Vector3.new(0, 0, 0)
            end
        end)
    end

    local function disableMonsterAntiJitter()
        if monsterAntiJitterConnection then monsterAntiJitterConnection:Disconnect() monsterAntiJitterConnection = nil end
    end

    local function tweenToMonster(monster)
        local character = LocalPlayer.Character
        if not character then return false end
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if not humanoidRootPart then return false end
        local monsterPos = getMonsterPosition(monster)
        if not monsterPos then return false end
        local distance = (monsterPos - humanoidRootPart.Position).Magnitude
        local tweenTime = distance / 50
        local targetPos = monsterPos + Vector3.new(0, MONSTER_OFFSET_BELOW, 0)
        local lookUpCFrame = CFrame.new(targetPos) * CFrame.Angles(math.rad(-90), 0, 0)
        local tweenInfo = TweenInfo.new(tweenTime, Enum.EasingStyle.Linear)
        local tween = TweenService:Create(humanoidRootPart, tweenInfo, {CFrame = lookUpCFrame})
        tween:Play()
        tween.Completed:Wait()
        return true
    end

    local function holdPositionBelowMonster(monster)
        if monsterHoldPositionConnection then monsterHoldPositionConnection:Disconnect() end
        local character = LocalPlayer.Character
        if not character then return end
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if not humanoidRootPart then return end
        monsterHoldPositionConnection = RunService.Heartbeat:Connect(function()
            if not State.isAutoMonsterFarmEnabled or not isMonsterValid(monster) then
                if monsterHoldPositionConnection then monsterHoldPositionConnection:Disconnect() monsterHoldPositionConnection = nil end
                return
            end
            local monsterPos = getMonsterPosition(monster)
            if monsterPos then
                local targetPos = monsterPos + Vector3.new(0, MONSTER_OFFSET_BELOW, 0)
                local lookUpCFrame = CFrame.new(targetPos) * CFrame.Angles(math.rad(-90), 0, 0)
                humanoidRootPart.CFrame = lookUpCFrame
                if monsterFlyBodyGyro then
                    monsterFlyBodyGyro.CFrame = lookUpCFrame
                end
            end
        end)
    end

    local function stopMonsterHoldPosition()
        if monsterHoldPositionConnection then monsterHoldPositionConnection:Disconnect() monsterHoldPositionConnection = nil end
    end

    local function activateWeapon()
        pcall(function()
            local args = {"Weapon"}
            ReplicatedStorage:WaitForChild("Shared")
                :WaitForChild("Packages")
                :WaitForChild("Knit")
                :WaitForChild("Services")
                :WaitForChild("ToolService")
                :WaitForChild("RF")
                :WaitForChild("ToolActivated")
                :InvokeServer(unpack(args))
        end)
    end

    AutoMonsterFarmToggle:OnChanged(function()
        State.isAutoMonsterFarmEnabled = Options.AutoMonsterFarm.Value
        local character = LocalPlayer.Character
        if State.isAutoMonsterFarmEnabled then
            enableCameraNoClip()
            if character then
                enableMonsterFly(character)
                enableMonsterNoClip(character)
                enablePlatformStand(character)
                enableMonsterAntiJitter(character)
            end
        else
            currentMonster = nil
            stopMonsterHoldPosition()
            disableMonsterFly()
            disableMonsterNoClip()
            disableMonsterAntiJitter()
            if character then
                disablePlatformStand(character)
            end
            disableCameraNoClip()
        end
    end)

    task.spawn(function()
        while true do
            task.wait(0.1)
            if State.isAutoMonsterFarmEnabled then
                pcall(function()
                    local character = LocalPlayer.Character
                    if character then
                        enablePlatformStand(character)
                    end
                    if not isMonsterValid(currentMonster) then
                        stopMonsterHoldPosition()
                        currentMonster = findNearestMonster()
                        if currentMonster then
                            tweenToMonster(currentMonster)
                            holdPositionBelowMonster(currentMonster)
                            task.wait(0.2)
                        end
                    end
                    if isMonsterValid(currentMonster) then
                        activateWeapon()
                    end
                end)
            end
        end
    end)

    -- ==================== AUTO FARM MATERIAL LOGIC ====================
    local function findAllMaterialFarmMonsters()
        local monsters = {}
        local livingFolder = Workspace:FindFirstChild("Living")
        if livingFolder then
            for _, child in pairs(livingFolder:GetChildren()) do
                local monsterName = child.Name:gsub("%d+", "")
                for _, selected in ipairs(State.selectedMaterialMonsters) do
                    if monsterName == selected then
                        table.insert(monsters, child)
                        break
                    end
                end
            end
        end
        return monsters
    end

    local function findNearestMaterialMonster()
        local monsters = findAllMaterialFarmMonsters()
        local character = LocalPlayer.Character
        if not character then return nil end
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if not humanoidRootPart then return nil end
        local playerPos = humanoidRootPart.Position
        local nearestMonster = nil
        local nearestDistance = math.huge
        for _, monster in pairs(monsters) do
            if isMonsterValid(monster) then
                local monsterPos = getMonsterPosition(monster)
                if monsterPos then
                    local distance = (monsterPos - playerPos).Magnitude
                    if distance < nearestDistance then
                        nearestDistance = distance
                        nearestMonster = monster
                    end
                end
            end
        end
        return nearestMonster
    end

    local function holdPositionBelowMaterialMonster(monster)
        if materialFarmHoldPositionConnection then materialFarmHoldPositionConnection:Disconnect() end
        local character = LocalPlayer.Character
        if not character then return end
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if not humanoidRootPart then return end
        materialFarmHoldPositionConnection = RunService.Heartbeat:Connect(function()
            if not State.isAutoMaterialFarmEnabled or not isMonsterValid(monster) then
                if materialFarmHoldPositionConnection then materialFarmHoldPositionConnection:Disconnect() materialFarmHoldPositionConnection = nil end
                return
            end
            local monsterPos = getMonsterPosition(monster)
            if monsterPos then
                local targetPos = monsterPos + Vector3.new(0, MONSTER_OFFSET_BELOW, 0)
                local lookUpCFrame = CFrame.new(targetPos) * CFrame.Angles(math.rad(-90), 0, 0)
                humanoidRootPart.CFrame = lookUpCFrame
                if monsterFlyBodyGyro then
                    monsterFlyBodyGyro.CFrame = lookUpCFrame
                end
            end
        end)
    end

    local function stopMaterialFarmHoldPosition()
        if materialFarmHoldPositionConnection then materialFarmHoldPositionConnection:Disconnect() materialFarmHoldPositionConnection = nil end
    end

    AutoMaterialFarmToggle:OnChanged(function()
        State.isAutoMaterialFarmEnabled = Options.AutoMaterialFarm.Value
        local character = LocalPlayer.Character
        if State.isAutoMaterialFarmEnabled then
            if #State.selectedMaterialMonsters == 0 then
                Library:Notify({
                    Title = "Warning",
                    Content = "Please select at least 1 monster to farm!",
                    Duration = 3
                })
                Options.AutoMaterialFarm:SetValue(false)
                return
            end
            if character then
                enableMonsterFly(character)
                enableMonsterNoClip(character)
                enablePlatformStand(character)
                enableMonsterAntiJitter(character)
            end
        else
            currentMaterialMonster = nil
            stopMaterialFarmHoldPosition()
            disableMonsterFly()
            disableMonsterNoClip()
            disableMonsterAntiJitter()
            if character then
                disablePlatformStand(character)
            end
        end
    end)

    task.spawn(function()
        while true do
            task.wait(0.1)
            if State.isAutoMaterialFarmEnabled then
                pcall(function()
                    local character = LocalPlayer.Character
                    if character then
                        enablePlatformStand(character)
                    end
                    if not isMonsterValid(currentMaterialMonster) then
                        stopMaterialFarmHoldPosition()
                        currentMaterialMonster = findNearestMaterialMonster()
                        if currentMaterialMonster then
                            tweenToMonster(currentMaterialMonster)
                            holdPositionBelowMaterialMonster(currentMaterialMonster)
                            task.wait(0.2)
                        end
                    end
                    if isMonsterValid(currentMaterialMonster) then
                        activateWeapon()
                    end
                end)
            end
        end
    end)
end

local PickaxeSection = Tabs.Shop:CreateSection("PICKAXE SHOP")

local ShopPickaxeDropdown = Tabs.Shop:CreateDropdown("ShopPickaxe", {
    Title = "Pickaxe Shop",
    Description = "Select Pickaxe to buy",
    Values = PickaxeShopList,
    Multi = false,
    Default = "Bronze Pickaxe - 150 Gold"
})

ShopPickaxeDropdown:OnChanged(function(Value)
    selectedShopPickaxe = getPickaxeNameFromDropdown(Value)
end)

Tabs.Shop:CreateButton({
    Title = "Buy Pickaxe",
    Description = "Buy selected Pickaxe",
    Callback = function()
        if selectedShopPickaxe then
            buyPickaxe(selectedShopPickaxe)
        end
    end
})

local PotionSection = Tabs.Shop:CreateSection("POTION SHOP")

local ShopPotionDropdown = Tabs.Shop:CreateDropdown("ShopPotion", {
    Title = "Potion Shop",
    Description = "Select Potion to buy",
    Values = PotionShopList,
    Multi = false,
    Default = "MinerPotion1 - Miner Potion I"
})

local PotionEffectParagraph = Tabs.Shop:CreateParagraph("PotionEffectInfo", {
    Title = "Potion Effect",
    Content = PotionDescriptions["MinerPotion1"]
})

ShopPotionDropdown:OnChanged(function(Value)
    selectedShopPotion = getPotionIdFromDropdown(Value)
    if selectedShopPotion and PotionDescriptions[selectedShopPotion] then
        PotionEffectParagraph:SetContent(PotionDescriptions[selectedShopPotion])
    end
end)

Tabs.Shop:CreateButton({
    Title = "Buy Potion",
    Description = "Buy selected Potion",
    Callback = function()
        if selectedShopPotion then
            buyPotion(selectedShopPotion)
        end
    end
})

availableTools = getBackpackPickaxes()

local ToolDropdown = Tabs.Home:CreateDropdown("ToolSelect", {
    Title = "Tool Select",
    Description = "Select Weapon to mine ores",
    Values = availableTools,
    Multi = false,
    Default = "Pickaxe"
})

ToolDropdown:OnChanged(function(Value)
    State.selectedTool = Value
end)

local AutoSelectToggle = Tabs.Home:CreateToggle("AutoSelectTool", {
    Title = "Auto Select Tool",
    Description = "Automatically equip selected weapon",
    Default = false
})

AutoSelectToggle:OnChanged(function()
    State.isAutoSelectTool = Options.AutoSelectTool.Value
    if State.isAutoSelectTool then
        State.selectedTool = selectBestPickaxe()
        ToolDropdown:SetValue(State.selectedTool)
    end
end)

Tabs.Home:CreateButton({
    Title = "Refresh Tools",
    Description = "Reset weapon list",
    Callback = function()
        availableTools = getBackpackPickaxes()
        ToolDropdown:SetValues(availableTools)
        if State.isAutoSelectTool then
            State.selectedTool = selectBestPickaxe()
            ToolDropdown:SetValue(State.selectedTool)
        end
    end
})

Tabs.Home:CreateButton({
    Title = "Reroll Race",
    Description = "Roll new Race",
    Callback = function()
        pcall(function()
            ReplicatedStorage:WaitForChild("Shared")
                :WaitForChild("Packages")
                :WaitForChild("Knit")
                :WaitForChild("Services")
                :WaitForChild("RaceService")
                :WaitForChild("RF")
                :WaitForChild("Reroll")
                :InvokeServer()
        end)
    end
})

local NPCList = {"Wizard", "Maria", "Marbles", "Sensei Moro", "Enchanter", "Runermaker", "Greedy Cey", "Miner Fred"}
local NPCPositions = {
    ["Wizard"] = Vector3.new(-23, 81, -357),
    ["Maria"] = Vector3.new(-154, 28, 117),
    ["Marbles"] = Vector3.new(-180, 29, 15),
    ["Sensei Moro"] = Vector3.new(-196, 29, 160),
    ["Enchanter"] = Vector3.new(-260, 20, 27),
    ["Runermaker"] = Vector3.new(-271, 20, 145),
    ["Greedy Cey"] = Vector3.new(-114, 38, -38),
    ["Miner Fred"] = Vector3.new(-88, 29, 94)
}
local selectedNPC = "Wizard"

local NPCDropdown = Tabs.NPC:CreateDropdown("NPCSelect", {
    Title = "NPC Select",
    Description = "Select NPC to move to",
    Values = NPCList,
    Multi = false,
    Default = "Wizard"
})

NPCDropdown:OnChanged(function(Value)
    selectedNPC = Value
end)

Tabs.NPC:CreateButton({
    Title = "Tween to NPC",
    Description = "Move to selected NPC",
    Callback = function()
        local character = LocalPlayer.Character
        if not character then return end
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if not humanoidRootPart then return end
        local targetPos = NPCPositions[selectedNPC]
        if not targetPos then return end
        local targetCFrame = CFrame.new(targetPos + Vector3.new(0, 2, 0))
        local tweenInfo = TweenInfo.new(5, Enum.EasingStyle.Linear)
        local tween = TweenService:Create(humanoidRootPart, tweenInfo, {CFrame = targetCFrame})
        tween:Play()
    end
})

local CameraNoClipToggle = Tabs.Mics:CreateToggle("CameraNoClip", {
    Title = "Camera NoClip",
    Description = "View not blocked by parts",
    Default = false
})

CameraNoClipToggle:OnChanged(function()
    local enabled = Options.CameraNoClip.Value
    if enabled then
        enableCameraNoClip()
    else
        disableCameraNoClip()
    end
end)

-- ==================== QUEST-AWARE FARM UI ====================
Tabs.Quest:CreateSection("QUEST-AWARE FARM")

local cachedQuestObjectives = {}

-- Quest Type Filter Dropdown
local QuestTypeOptions = {"KILL", "MINE", "COLLECT", "ORE", "TALK", "EQUIP", "FORGE", "UI"}
local QuestTypeDropdown = Tabs.Quest:CreateDropdown("QuestTypeFilter", {
    Title = "Quest Types to Auto",
    Description = "Select quest type to automatically do",
    Values = QuestTypeOptions,
    Multi = true,
    Default = {"KILL", "MINE", "COLLECT", "ORE", "TALK", "EQUIP"}
})

QuestTypeDropdown:OnChanged(function(Value)
    -- Update State.selectedQuestTypes based on selection
    for _, t in ipairs(QuestTypeOptions) do
        State.selectedQuestTypes[t] = false
    end
    if type(Value) == "table" then
        for k, v in pairs(Value) do
            if v == true then
                State.selectedQuestTypes[k] = true
            end
        end
    end
end)

local QuestTargetDropdown = Tabs.Quest:CreateDropdown("QuestTargetSelect", {
    Title = "Quest Target",
    Description = "Auto refresh every 1s",
    Values = {"(Loading...)"},
    Multi = false,
    Default = "(Loading...)"
})

local QuestProgressParagraph = Tabs.Quest:CreateParagraph("QuestFarmProgress", {
    Title = "Quest Farm Progress",
    Content = "Turn on Auto Quest Farm to start"
})

local AutoQuestFarmToggle = Tabs.Quest:CreateToggle("AutoQuestFarm", {
    Title = "Auto Quest Farm",
    Description = "Automatically farm in quest order, switch objective when completed",
    Default = false
})

-- Auto-refresh quest dropdown every 1s
task.spawn(function()
    while true do
        task.wait(1)
        pcall(function()
            local objectives = getFarmableQuestObjectives()
            
            -- Filter by selected quest types
            local filteredObjectives = {}
            for _, obj in ipairs(objectives) do
                local typeKey = obj.type:upper()
                if typeKey == "COLLECT_ORE" then typeKey = "ORE" end
                if State.selectedQuestTypes[typeKey] then
                    table.insert(filteredObjectives, obj)
                end
            end
            
            cachedQuestObjectives = filteredObjectives
            local values = {}
            for idx, obj in ipairs(filteredObjectives) do
                local typeLabel = obj.type:upper()
                if typeLabel == "COLLECT_ORE" then typeLabel = "ORE" end
                local display = string.format("[%s] %s (%d/%d)", 
                    typeLabel, obj.target or "?", 
                    obj.current or 0, obj.required or 0)
                table.insert(values, display)
            end
            if #values == 0 then
                values = {"No farmable quest"}
            end
            QuestTargetDropdown:SetValues(values)
        end)
    end
end)

local function startQuestAwareFarm(targetType, targetName)
    local function stopFarms()
        pcall(function()
            if State.isAutoFarmEnabled and Options.AutoFarm then
                Options.AutoFarm:SetValue(false)
            end
            if State.isAutoMonsterFarmEnabled and Options.AutoMonsterFarm then
                Options.AutoMonsterFarm:SetValue(false)
            end
        end)
    end

    -- Try to teleport to correct island first (helps if player is in wrong zone)
    pcall(function()
        if targetType == "kill" then
            local island = MonsterIslandMap[targetName]
            if island then teleportToIsland(island) end
        elseif targetType == "mine" then
            local island = RockIslandMap[targetName]
            if island then teleportToIsland(island) end
        elseif targetType == "collect" then
            local rockType = OreToRockMap[targetName]
            local island = rockType and RockIslandMap[rockType]
            if island then teleportToIsland(island) end
        end
    end)

    if targetType == "kill" then
        State.selectedMonsterTypes = {[targetName] = true}
        if MonsterDropdown then MonsterDropdown:SetValue({[targetName] = true}) end
        if not State.isAutoMonsterFarmEnabled then
            if Options.AutoMonsterFarm then
                Options.AutoMonsterFarm:SetValue(true)
            end
        end
        QuestProgressParagraph:SetContent("Farming: " .. targetName .. " (Monster)")

    elseif targetType == "collect" then
        local rockType = OreToRockMap[targetName]
        if rockType then
            State.selectedRockTypes = {[rockType] = true}
            if FarmDropdown then FarmDropdown:SetValue({[rockType] = true}) end
            if not State.isAutoFarmEnabled then
                if Options.AutoFarm then
                    Options.AutoFarm:SetValue(true)
                end
            end
            QuestProgressParagraph:SetContent("Farming: " .. rockType .. " (for " .. targetName .. ")")
        else
            QuestProgressParagraph:SetContent("Rock not found for: " .. tostring(targetName))
        end

    elseif targetType == "mine" then
        State.selectedRockTypes = {[targetName] = true}
        if FarmDropdown then FarmDropdown:SetValue({[targetName] = true}) end
        if not State.isAutoFarmEnabled then
            if Options.AutoFarm then
                Options.AutoFarm:SetValue(true)
            end
        end
        QuestProgressParagraph:SetContent("Farming: " .. targetName .. " (Rock)")

    elseif targetType == "collect_ore" then
        -- Farm rock type selected by user in Farm tab
        if not State.isAutoFarmEnabled then
            if Options.AutoFarm then
                Options.AutoFarm:SetValue(true)
            end
        end

        QuestProgressParagraph:SetContent("Farming: [Multi-Select] (for Ore quest)")

    elseif targetType == "equip" then
        stopFarms()
        equipItem(targetName)
        QuestProgressParagraph:SetContent("Equipped: " .. tostring(targetName) .. " (Quest Equip)")

    elseif targetType == "talk" then
        stopFarms()
        task.spawn(function()
            pcall(function()
                -- Try exact match first, then try without trailing number (e.g., "Sensei Moro 2" -> "Sensei Moro")
                local pos = NPCPositions[targetName]
                local npcNameForTalk = targetName
                
                if not pos then
                    -- Try removing trailing number/space (e.g., "Sensei Moro 2" -> "Sensei Moro")
                    local baseName = targetName:gsub("%s*%d+$", "")
                    pos = NPCPositions[baseName]
                    if pos then
                        npcNameForTalk = baseName
                    end
                end
                
                local character = LocalPlayer.Character
                local hrp = character and character:FindFirstChild("HumanoidRootPart")
                if pos and hrp then
                    -- Use tween like NPC tab instead of teleport
                    local targetCFrame = CFrame.new(pos + Vector3.new(0, 2, 0))
                    local distance = (pos - hrp.Position).Magnitude
                    local tweenTime = math.clamp(distance / 50, 2, 8) -- 2-8 seconds based on distance
                    local tweenInfo = TweenInfo.new(tweenTime, Enum.EasingStyle.Linear)
                    local tween = TweenService:Create(hrp, tweenInfo, {CFrame = targetCFrame})
                    tween:Play()
                    tween.Completed:Wait()
                    task.wait(0.3)
                end
                
                -- Use the resolved NPC name for talking
                autoTalkToNPC(npcNameForTalk)
            end)
            QuestProgressParagraph:SetContent("Talked to: " .. tostring(targetName) .. " (Quest Talk)")
        end)

    elseif targetType == "forge" or targetType == "ui" then
        stopFarms()
        QuestProgressParagraph:SetContent("Quest type '" .. tostring(targetType) .. "' not supported auto: " .. tostring(targetName))
        Library:Notify({Title = "Quest Farm", Content = "Quest '" .. tostring(targetType) .. "' not supported auto (" .. tostring(targetName) .. ")", Duration = 5})
    end
end


local function stopQuestAwareFarm()
    if State.isAutoFarmEnabled and Options.AutoFarm then
        Options.AutoFarm:SetValue(false)
    end
    if State.isAutoMonsterFarmEnabled and Options.AutoMonsterFarm then
        Options.AutoMonsterFarm:SetValue(false)
    end
    QuestProgressParagraph:SetContent("Stopped farming")
end

AutoQuestFarmToggle:OnChanged(function()
    State.isQuestAwareFarmEnabled = Options.AutoQuestFarm.Value
    if State.isQuestAwareFarmEnabled then
        local selected = Options.QuestTargetSelect.Value
        
        -- Auto-select first incomplete objective if nothing selected or invalid
        if not selected or selected == "(Loading...)" or selected == "No farmable quest" then
            -- Wait a moment for dropdown to refresh then pick first
            task.wait(0.5)
            if #cachedQuestObjectives > 0 then
                local firstObj = nil
                for _, obj in ipairs(cachedQuestObjectives) do
                    if obj.current < obj.required then
                        firstObj = obj
                        break
                    end
                end
                if firstObj then
                    currentQuestType = firstObj.type
                    currentQuestTarget = firstObj.target
                    startQuestAwareFarm(currentQuestType, currentQuestTarget)
                    enableCameraNoClip()
                    return
                end
            end
            Library:Notify({Title = "Warning", Content = "No farmable quest!", Duration = 3})
            Options.AutoQuestFarm:SetValue(false)
            return
        end
        
        -- Parse format: "✅ [TYPE] Target (x/y)" or "⏳ [TYPE] Target (x/y)"
        local typeMatch = selected:match("%[(%w+)%]")
        local targetMatch = selected:match("%]%s*([^%(]+)")
        
        if typeMatch and targetMatch then
            local targetType = typeMatch:lower()
            if targetType == "ore" then targetType = "collect_ore" end
            local targetName = targetMatch:gsub("^%s+", ""):gsub("%s+$", "")
            
            currentQuestType = targetType
            currentQuestTarget = targetName
            
            startQuestAwareFarm(targetType, targetName)
            enableCameraNoClip()
        else
            Library:Notify({Title = "Error", Content = "Cannot parse target", Duration = 3})
            Options.AutoQuestFarm:SetValue(false)
        end
    else
        stopQuestAwareFarm()
        disableCameraNoClip()
        currentQuestType = nil
        currentQuestTarget = nil
    end
end)

task.spawn(function()
    while true do
        task.wait(3)
        if State.isQuestAwareFarmEnabled then
            local objectives = getFarmableQuestObjectives()

            -- Filter by selected quest types
            local filteredObjectives = {}
            for _, obj in ipairs(objectives) do
                local typeKey = obj.type:upper()
                if typeKey == "COLLECT_ORE" then typeKey = "ORE" end
                if State.selectedQuestTypes[typeKey] then
                    table.insert(filteredObjectives, obj)
                end
            end
            objectives = filteredObjectives

            -- Check if current objective is completed (CRITICAL: prevent stuck farming)
            local currentObj = nil
            local isCurrentComplete = false
            for _, obj in ipairs(objectives) do
                if obj and obj.target == currentQuestTarget and obj.type == currentQuestType then
                    currentObj = obj
                    -- Check if completed
                    if obj.current >= obj.required then
                        isCurrentComplete = true
                    end
                    break
                end
            end

            -- If current objective is COMPLETED or GONE -> stop farms and switch to next
            if isCurrentComplete or (not currentObj and currentQuestTarget) then
                -- STOP all farms immediately to prevent stuck
                pcall(function()
                    if State.isAutoFarmEnabled and Options.AutoFarm then
                        Options.AutoFarm:SetValue(false)
                    end
                    if State.isAutoMonsterFarmEnabled and Options.AutoMonsterFarm then
                        Options.AutoMonsterFarm:SetValue(false)
                    end
                end)
                
                -- Find next incomplete objective
                local nextObj = nil
                for _, obj in ipairs(objectives) do
                    if obj.current < obj.required then
                        nextObj = obj
                        break
                    end
                end
                
                if nextObj then
                    currentQuestType = nextObj.type
                    currentQuestTarget = nextObj.target

                    -- Update dropdown display
                    pcall(function()
                        local typeLabel = tostring(nextObj.type or ""):upper()
                        if typeLabel == "COLLECT_ORE" then typeLabel = "ORE" end
                        local display = string.format("[%s] %s (%d/%d)",
                            typeLabel, nextObj.target or "?",
                            nextObj.current or 0, nextObj.required or 0)

                        if QuestTargetDropdown and QuestTargetDropdown.SetValue then
                            QuestTargetDropdown:SetValue(display)
                        end
                    end)

                    -- Start next farm
                    task.wait(0.5) -- Small delay before starting next objective
                    startQuestAwareFarm(currentQuestType, currentQuestTarget)
                    QuestProgressParagraph:SetContent("Switching to: " .. tostring(currentQuestTarget) .. " [" .. tostring(currentQuestType) .. "]")
                else
                    -- No more objectives
                    currentQuestType = nil
                    currentQuestTarget = nil
                    QuestProgressParagraph:SetContent("Completed all quests!")
                    Options.AutoQuestFarm:SetValue(false)
                end
            elseif currentObj then
                -- Update progress display
                local info = "Target: " .. tostring(currentQuestTarget) .. " [" .. tostring(currentQuestType) .. "]\n"
                info = info .. ("Progress: %d/%d"):format(currentObj.current, currentObj.required)
                QuestProgressParagraph:SetContent(info)
            end

            -- If no objectives left -> stop
            if #objectives == 0 then
                QuestProgressParagraph:SetContent("No more farmable quests")
            end
        end
    end
end)

-- ==================== COMBAT TAB ====================

Tabs.Combat:AddSection("AUTO COMBAT")

do -- Auto Combat Scope
local function getEquippedWeapon()
    local character = LocalPlayer.Character
    if not character then return nil end
    return character:FindFirstChild("Weapon")
end

local function activateWeaponAttack(isHeavy)
    pcall(function()
        local args = {"Weapon"}
        if isHeavy then
            args = {"Weapon", true}
        end
        ReplicatedStorage
            :WaitForChild("Shared")
            :WaitForChild("Packages")
            :WaitForChild("Knit")
            :WaitForChild("Services")
            :WaitForChild("ToolService")
            :WaitForChild("RF")
            :WaitForChild("ToolActivated")
            :InvokeServer(unpack(args))
    end)
end

local function startBlockAction()
    pcall(function()
        ReplicatedStorage
            :WaitForChild("Shared")
            :WaitForChild("Packages")
            :WaitForChild("Knit")
            :WaitForChild("Services")
            :WaitForChild("ToolService")
            :WaitForChild("RF")
            :WaitForChild("StartBlock")
            :InvokeServer()
    end)
end

local function stopBlockAction()
    pcall(function()
        ReplicatedStorage
            :WaitForChild("Shared")
            :WaitForChild("Packages")
            :WaitForChild("Knit")
            :WaitForChild("Services")
            :WaitForChild("ToolService")
            :WaitForChild("RF")
            :WaitForChild("StopBlock")
            :InvokeServer()
    end)
end

local AutoAttackToggle = Tabs.Combat:CreateToggle("AutoAttack", {
    Title = "Auto Attack",
    Description = "Automatically attack when holding weapon",
    Default = false
})

local AttackSpeedSlider = Tabs.Combat:CreateSlider("AttackSpeed", {
    Title = "Attack Speed",
    Description = "Adjust attack speed (seconds)",
    Default = 0.3,
    Min = 0.1,
    Max = 2,
    Rounding = 1
})

local HeavyAttackToggle = Tabs.Combat:CreateToggle("HeavyAttack", {
    Title = "Use Heavy Attack",
    Description = "Use heavy attack",
    Default = false
})

AttackSpeedSlider:OnChanged(function(Value)
    State.attackSpeed = Value
end)

AutoAttackToggle:OnChanged(function()
    State.isAutoAttackEnabled = Options.AutoAttack.Value
end)

task.spawn(function()
    while true do
        task.wait(State.attackSpeed)
        if State.isAutoAttackEnabled then
            local weapon = getEquippedWeapon()
            if weapon then
                local isHeavy = Options.HeavyAttack and Options.HeavyAttack.Value or false
                activateWeaponAttack(isHeavy)
            end
        end
    end
end)

Tabs.Combat:AddSection("SMART AUTO BLOCK")

local SmartAutoBlockToggle = Tabs.Combat:CreateToggle("SmartAutoBlock", {
    Title = "Smart Auto Block",
    Description = "Automatically block when detecting monster attack(beta)",
    Default = false
})

local BlockRangeSlider = Tabs.Combat:CreateSlider("BlockRange", {
    Title = "Detection Range",
    Description = "Monster detection range (studs)",
    Default = 15,
    Min = 5,
    Max = 30,
    Rounding = 0
})

local SmartBlockDurationSlider = Tabs.Combat:CreateSlider("SmartBlockDuration", {
    Title = "Block Duration",
    Description = "Block duration after detection (seconds)",
    Default = 0.5,
    Min = 0.2,
    Max = 2,
    Rounding = 1
})

State.isSmartAutoBlockEnabled = false
State.blockRange = 15
State.smartBlockDuration = 0.5

SmartAutoBlockToggle:OnChanged(function()
    State.isSmartAutoBlockEnabled = Options.SmartAutoBlock.Value
end)

BlockRangeSlider:OnChanged(function(Value)
    State.blockRange = Value
end)

SmartBlockDurationSlider:OnChanged(function(Value)
    State.smartBlockDuration = Value
end)

-- Monitor monster animations for attack detection
local function isMonsterAttacking(monster)
    local humanoid = monster:FindFirstChildOfClass("Humanoid")
    if not humanoid then return false end
    
    local animator = humanoid:FindFirstChildOfClass("Animator")
    if not animator then return false end
    
    local playingTracks = animator:GetPlayingAnimationTracks()
    for _, track in ipairs(playingTracks) do
        local animName = track.Name:lower()
        -- Check for attack-related animation names
        if animName:find("attack") or animName:find("slash") or 
           animName:find("swing") or animName:find("hit") or 
           animName:find("punch") or animName:find("strike") or
           animName:find("combat") then
            return true
        end
        -- Also check animation priority - Action priority usually means attack
        if track.Priority == Enum.AnimationPriority.Action then
            return true
        end
    end
    return false
end

local function findNearbyAttackingMonster(range)
    local character = LocalPlayer.Character
    if not character then return nil end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    
    local playerPos = hrp.Position
    local livingFolder = Workspace:FindFirstChild("Living")
    if not livingFolder then return nil end
    
    for _, child in pairs(livingFolder:GetChildren()) do
        if child ~= character and child:FindFirstChild("Humanoid") then
            local monsterHrp = child:FindFirstChild("HumanoidRootPart")
            if monsterHrp then
                local distance = (monsterHrp.Position - playerPos).Magnitude
                if distance <= range then
                    if isMonsterAttacking(child) then
                        return child
                    end
                end
            end
        end
    end
    return nil
end

-- Smart block loop - detect monster attacks
local isCurrentlyBlocking = false
local lastBlockTime = 0

task.spawn(function()
    while true do
        task.wait(0.05) -- Check every 50ms for fast response
        if State.isSmartAutoBlockEnabled then
            local weapon = getEquippedWeapon()
            if weapon then
                local attackingMonster = findNearbyAttackingMonster(State.blockRange)
                if attackingMonster and not isCurrentlyBlocking then
                    -- Monster is attacking, block now!
                    isCurrentlyBlocking = true
                    lastBlockTime = tick()
                    startBlockAction()
                elseif isCurrentlyBlocking then
                    -- Check if we should stop blocking
                    if tick() - lastBlockTime >= State.smartBlockDuration then
                        stopBlockAction()
                        isCurrentlyBlocking = false
                    end
                end
            else
                if isCurrentlyBlocking then
                    stopBlockAction()
                    isCurrentlyBlocking = false
                end
            end
        else
            if isCurrentlyBlocking then
                stopBlockAction()
                isCurrentlyBlocking = false
            end
        end
    end
end)

-- Additional: Block on HP decrease (backup detection)
local lastHP = 0
local function setupHPMonitor()
    local character = LocalPlayer.Character
    if not character then return end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    
    lastHP = humanoid.Health
    
    humanoid:GetPropertyChangedSignal("Health"):Connect(function()
        if not State.isSmartAutoBlockEnabled then return end
        if not getEquippedWeapon() then return end
        
        local newHP = humanoid.Health
        if newHP < lastHP then
            -- We took damage, block immediately for a short time
            if not isCurrentlyBlocking then
                isCurrentlyBlocking = true
                lastBlockTime = tick()
                startBlockAction()
                task.delay(State.smartBlockDuration, function()
                    if isCurrentlyBlocking and tick() - lastBlockTime >= State.smartBlockDuration - 0.1 then
                        stopBlockAction()
                        isCurrentlyBlocking = false
                    end
                end)
            end
        end
        lastHP = newHP
    end)
end

LocalPlayer.CharacterAdded:Connect(setupHPMonitor)
if LocalPlayer.Character then
    setupHPMonitor()
end

Tabs.Combat:AddSection("LEGACY AUTO BLOCK")

local AutoBlockToggle = Tabs.Combat:CreateToggle("AutoBlock", {
    Title = "Auto Block (Continuous)",  
    Description = "Continuous block",
    Default = false
})

local BlockDurationSlider = Tabs.Combat:CreateSlider("BlockDuration", {
    Title = "Block Duration",
    Description = "Block duration per time (seconds)",
    Default = 0.5,
    Min = 0.1,
    Max = 3,
    Rounding = 1
})

local BlockIntervalSlider = Tabs.Combat:CreateSlider("BlockInterval", {
    Title = "Block Interval", 
    Description = "Rest time between blocks (seconds)",
    Default = 1,
    Min = 0.5,
    Max = 5,
    Rounding = 1
})

BlockDurationSlider:OnChanged(function(Value)
    State.blockDuration = Value
end)

AutoBlockToggle:OnChanged(function()
    State.isAutoBlockEnabled = Options.AutoBlock.Value
end)

task.spawn(function()
    local blockInterval = 1
    while true do
        task.wait(0.1)
        if State.isAutoBlockEnabled and not State.isSmartAutoBlockEnabled then
            local weapon = getEquippedWeapon()
            if weapon then
                startBlockAction()
                task.wait(State.blockDuration)
                stopBlockAction()
                blockInterval = Options.BlockInterval and Options.BlockInterval.Value or 1
                task.wait(blockInterval)
            end
        end
    end
end)
end

-- ==================== MICS TAB ====================
local TpWalkToggle = Tabs.Mics:CreateToggle("TpWalk", {
    Title = "Walk Speed",
    Description = "Increase movement speed",
    Default = false
})

local TpWalkSlider = Tabs.Mics:CreateSlider("TpWalkSpeed", {
    Title = "Walk Speed Multiplier",
    Description = "Adjust movement speed (1-10)",
    Default = 1,
    Min = 1,
    Max = 10,
    Rounding = 1
})

TpWalkSlider:OnChanged(function(Value)
    State.tpWalkSpeed = Value
end)

TpWalkToggle:OnChanged(function()
    State.isTpWalkEnabled = Options.TpWalk.Value
end)

task.spawn(function()
    local heartbeat = RunService.Heartbeat
    while true do
        local delta = heartbeat:Wait()
        if State.isTpWalkEnabled then
            local character = LocalPlayer.Character
            if character then
                local humanoid = character:FindFirstChildWhichIsA("Humanoid")
                if humanoid and humanoid.MoveDirection.Magnitude > 0 then
                    pcall(function()
                        character:TranslateBy(humanoid.MoveDirection * State.tpWalkSpeed * delta * 10)
                    end)
                end
            end
        end
    end
end)

local FullBrightToggle = Tabs.Mics:CreateToggle("FullBright", {
    Title = "Full Bright",
    Description = "Brighten entire map",
    Default = false
})

FullBrightToggle:OnChanged(function()
    State.isFullBrightEnabled = Options.FullBright.Value
    if State.isFullBrightEnabled then
        if not originalLightingSettings then
            originalLightingSettings = {
                Brightness = Lighting.Brightness,
                ClockTime = Lighting.ClockTime,
                FogEnd = Lighting.FogEnd,
                GlobalShadows = Lighting.GlobalShadows,
                OutdoorAmbient = Lighting.OutdoorAmbient
            }
        end
        if fullBrightConnection then
            fullBrightConnection:Disconnect()
        end
        fullBrightConnection = RunService.RenderStepped:Connect(function()
            Lighting.Brightness = 2
            Lighting.ClockTime = 14
            Lighting.FogEnd = 100000
            Lighting.GlobalShadows = false
            Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
        end)
    else
        if fullBrightConnection then
            fullBrightConnection:Disconnect()
            fullBrightConnection = nil
        end
        if originalLightingSettings then
            Lighting.Brightness = originalLightingSettings.Brightness
            Lighting.ClockTime = originalLightingSettings.ClockTime
            Lighting.FogEnd = originalLightingSettings.FogEnd
            Lighting.GlobalShadows = originalLightingSettings.GlobalShadows
            Lighting.OutdoorAmbient = originalLightingSettings.OutdoorAmbient
        end
    end
end)

local NoFogToggle = Tabs.Mics:CreateToggle("NoFog", {
    Title = "No Fog",
    Description = "Remove fog effect",
    Default = false
})

NoFogToggle:OnChanged(function()
    State.isNoFogEnabled = Options.NoFog.Value
    if State.isNoFogEnabled then
        Lighting.FogEnd = 100000
        for _, v in pairs(Lighting:GetDescendants()) do
            if v:IsA("Atmosphere") then
                v:Destroy()
            end
        end
    end
end)

-- Island Filter for Farm
State.selectedFarmIsland = "All"

local FarmIslandDropdown = Tabs.Farms:CreateDropdown("FarmIslandSelect", {
    Title = "Island Select",
    Description = "Select Island to filter rock types",
    Values = IslandList,
    Multi = false,
    Default = "All"
})

local FarmDropdown = Tabs.Farms:CreateDropdown("FarmSelect", {
    Title = "Farm Select",
    Description = "Select rock/ore type to farm",
    Values = FarmTypes,
    Multi = true,
    Default = {"Pebble"}
})

FarmIslandDropdown:OnChanged(function(Value)
    State.selectedFarmIsland = Value
    local rocks = IslandRockMap[Value] or FarmTypes
    FarmDropdown:SetValues(rocks)
    if #rocks > 0 then
        State.selectedRockTypes = {[rocks[1]] = true}
        if FarmDropdown.SetValue then
            FarmDropdown:SetValue({[rocks[1]] = true})
        end
        currentRock = nil
    end
end)

FarmDropdown:OnChanged(function(Value)
    State.selectedRockTypes = Value
    currentRock = nil
    if State.isHighlightEnabled then
        updateHighlights()
    end
end)

local AutoFarmToggle = Tabs.Farms:CreateToggle("AutoFarm", {
    Title = "Auto Farm",
    Description = "Farm selected rock/ore",
    Default = false
})

AutoFarmToggle:OnChanged(function()
    State.isAutoFarmEnabled = Options.AutoFarm.Value
    local character = LocalPlayer.Character
    if State.isAutoFarmEnabled then
        enableCameraNoClip()
        if character then
            enableFly(character)
            enableNoClip(character)
            enablePlatformStand(character)
            enableAntiJitter(character)
        end
    else
        currentRock = nil
        stopHoldPosition()
        disableFly()
        disableNoClip()
        disableAntiJitter()
        if character then
            disablePlatformStand(character)
        end
        disableCameraNoClip()
    end
end)

local HighlightToggle = Tabs.Farms:CreateToggle("HighlightESP", {
    Title = "Highlight ESP",
    Description = "Highlight for selected Rock",
    Default = false
})

HighlightToggle:OnChanged(function()
    State.isHighlightEnabled = Options.HighlightESP.Value
    if State.isHighlightEnabled then
        updateHighlights()
    else
        clearAllHighlights()
    end
end)

task.spawn(function()
    while true do
        task.wait(0.1)
        if State.isAutoFarmEnabled then
            pcall(function()
                local character = LocalPlayer.Character
                if character then
                    enablePlatformStand(character)
                end
                
                if not isRockValid(currentRock) then
                    stopHoldPosition()
                    currentRock = findNearestRock()
                    if currentRock then
                        tweenToRock(currentRock)
                        holdPositionBelowRock(currentRock)
                        task.wait(0.2)
                        -- equipTool() removed by user request
                        task.wait(0.1)
                    end
                end
                if isRockValid(currentRock) then
                    activatePickaxe()
                end
            end)
        end
    end
end)

-- ==================== RESPAWN HANDLER FOR AUTO FARMS ====================
LocalPlayer.CharacterAdded:Connect(function(newCharacter)
    task.wait(0.5) -- Wait for character to fully load
    -- Re-enable auto farm rock if enabled
    if State.isAutoFarmEnabled then
        currentRock = nil
        stopHoldPosition()
        enableFly(newCharacter)
        enableNoClip(newCharacter)
        enablePlatformStand(newCharacter)
        enableAntiJitter(newCharacter)
    end
    -- Re-enable auto farm monster if enabled
    if State.isAutoMonsterFarmEnabled then
        currentMonster = nil
        stopMonsterHoldPosition()
        enableMonsterFly(newCharacter)
        enableMonsterNoClip(newCharacter)
        enablePlatformStand(newCharacter)
        enableMonsterAntiJitter(newCharacter)
    end
    -- Re-enable auto farm material if enabled
    if State.isAutoMaterialFarmEnabled then
        currentMaterialMonster = nil
        stopMaterialFarmHoldPosition()
        enableMonsterFly(newCharacter)
        enableMonsterNoClip(newCharacter)
        enablePlatformStand(newCharacter)
        enableMonsterAntiJitter(newCharacter)
    end
end)

-- ==================== FORGE TAB ====================
local AutoForgeToggle = Tabs.Forge:CreateToggle("AutoForge", {
    Title = "Auto Forge",
    Description = "Automatically perform forging minigames (Melt)",
    Default = false
})

State.isAutoForgeEnabled = false

AutoForgeToggle:OnChanged(function()
    State.isAutoForgeEnabled = Options.AutoForge.Value
end)

-- ==================== FAST FORGE ====================
State.isFastForgeEnabled = false

-- Hook ForgeController immediately
task.spawn(function()
    pcall(function()
        local Knit = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Packages"):WaitForChild("Knit"))
        local ForgeController = Knit.GetController("ForgeController")
        
        if ForgeController and not ForgeController._hooked then
            ForgeController._hooked = true
            ForgeController._originalChangeSequence = ForgeController.ChangeSequence
            
            ForgeController.ChangeSequence = function(self, sequence, args)
                -- Only skip if FastForge is enabled
                if State.isFastForgeEnabled then
                    if sequence == "Melt" then
                        local ForgeService = Knit.GetService("ForgeService")
                        if ForgeService then
                            local success, result = ForgeService:ChangeSequence("Melt", {
                                Ores = self.Ores,
                                ItemType = self.ItemType,
                                FastForge = true
                            }):await()
                            
                            if success and result then
                                return ForgeController._originalChangeSequence(self, "Hammer", args)
                            end
                        end
                    elseif sequence == "Pour" then
                        return ForgeController._originalChangeSequence(self, "Hammer", args)
                    end
                end
                return ForgeController._originalChangeSequence(self, sequence, args)
            end
        end
    end)
end)

Tabs.Forge:CreateToggle("FastForge", {
    Title = "Fast Forge",
    Description = "Skip 2/3 Forge (Not Recommended)",
    Default = false,
    Callback = function(Value)
        State.isFastForgeEnabled = Value
        State.isAutoForgeEnabled = Value
    end
})

local function getHammerMinigameUI()
    local pGui = LocalPlayer:FindFirstChild("PlayerGui")
    if not pGui then return nil end
    local forgeGui = pGui:FindFirstChild("Forge")
    if not forgeGui then return nil end
    local hammer = forgeGui:FindFirstChild("HammerMinigame")
    if hammer and hammer:IsA("GuiObject") then
        return hammer
    end
    return nil
end

local clickedNotes = {} 
local getMeltMinigameUI, getPourMinigameUI -- Pre-declare for local scope usage

do -- Scope strictly for Minigame Logic to save registers
    local function performHammerAction()
        pcall(function()
            local hammerUI = getHammerMinigameUI()
            
            -- Phase 1: Click Mold
            local debris = Workspace:FindFirstChild("Debris")
            if debris then
                for _, child in pairs(debris:GetChildren()) do
                    if child.Name == "Mold" and child:FindFirstChild("ClickDetector") then
                         fireclickdetector(child.ClickDetector)
                         task.wait(0.05) 
                    end
                end
            end

            -- Phase 2: Rhythm Game
            if not hammerUI or not hammerUI.Visible then 
                clickedNotes = {} 
                return 
            end
            
            for _, child in pairs(hammerUI:GetChildren()) do
                -- child = Note (v_u_clone in source)
                -- Structure: Note -> Frame -> Circle, Border
                if child:IsA("GuiObject") and child.Name ~= "Timer" and child.Visible then
                    if not clickedNotes[child] then
                        local frame = child:FindFirstChild("Frame")
                        if frame then
                            local circle = frame:FindFirstChild("Circle")
                            if circle and circle:IsA("ImageLabel") then
                                -- Use UDim2 Scale values instead of AbsoluteSize for accuracy
                                -- Circle tweens from initial size to (0,0) over Lifetime
                                -- Perfect is at 25/44 of Lifetime = ~56.8% through
                                -- At perfect, Circle.Size.X.Scale = 1 - 0.568 = ~0.432
                                
                                local circleScale = circle.Size.X.Scale
                                
                                -- Window: Click when scale is between 0.88 and 0.99
                                -- User reported 0.75-0.95 was still ~0.5s too late
                                if circleScale <= 0.99 and circleScale >= 0.88 then
                                    clickedNotes[child] = true
                                    
                                    -- Method 1: Direct firesignal (most reliable, bypasses input lag)
                                    local success = pcall(function()
                                        if firesignal then
                                            firesignal(child.MouseButton1Click)
                                        elseif fireclickdetector then
                                            -- Some executors rename it
                                            child.MouseButton1Click:Fire()
                                        end
                                    end)
                                    
                                    -- Method 2: Fallback to VirtualInputManager
                                    if not success then
                                        local absPos = child.AbsolutePosition
                                        local absSize = child.AbsoluteSize
                                        local centerX = absPos.X + (absSize.X / 2)
                                        local centerY = absPos.Y + (absSize.Y / 2)
                                        local guiInset = game:GetService("GuiService"):GetGuiInset()
                                        local trueY = centerY + guiInset.Y
                                        VirtualInputManager:SendMouseButtonEvent(centerX, trueY, 0, true, game, 1)
                                        VirtualInputManager:SendMouseButtonEvent(centerX, trueY, 0, false, game, 1)
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end)
    end

    function getMeltMinigameUI()
        local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
        if not playerGui then return nil end
        local forgeGui = playerGui:FindFirstChild("Forge")
        if not forgeGui then return nil end
        local melt = forgeGui:FindFirstChild("MeltMinigame")
        if melt and melt:IsA("GuiObject") then
            return melt
        end
        return nil
    end

    function getPourMinigameUI()
        local pGui = LocalPlayer:FindFirstChild("PlayerGui")
        if not pGui then return nil end
        local fGui = pGui:FindFirstChild("Forge")
        if not fGui then return nil end
        local pour = fGui:FindFirstChild("PourMinigame")
        if pour and pour:IsA("GuiObject") then
            return pour
        end
        return nil
    end

    local function performMeltAction()
        pcall(function()
            local meltUI = getMeltMinigameUI()
            if not meltUI or not meltUI.Visible then return end
            
            local heater = meltUI:FindFirstChild("Heater")
            if not heater then return end
            
            local top = heater:FindFirstChild("Top")
            local bottom = heater:FindFirstChild("Bottom")
            
            if top and bottom then
                local guiInset = game:GetService("GuiService"):GetGuiInset()
                local topPos = top.AbsolutePosition
                local topSize = top.AbsoluteSize
                local bottomPos = bottom.AbsolutePosition
                
                local startX = topPos.X + (topSize.X / 2)
                local startY = topPos.Y + (topSize.Y / 2) + guiInset.Y
                local endY = bottomPos.Y + guiInset.Y
                
                VirtualInputManager:SendMouseMoveEvent(startX, startY, game)
                VirtualInputManager:SendMouseButtonEvent(startX, startY, 0, true, game, 1)
                
                local steps = 4
                local stepY = (endY - startY) / steps
                
                for i = 1, steps do
                    local currentTargetY = startY + (stepY * i)
                    VirtualInputManager:SendMouseMoveEvent(startX, currentTargetY, game)
                    task.wait(0.02)
                end
                
                VirtualInputManager:SendMouseButtonEvent(startX, endY, 0, false, game, 1)
                task.wait(0.05) 
            end
        end)
    end

    State.isPourHolding = false

    local function performPourAction()
        pcall(function()
            local pourUI = getPourMinigameUI()
            if not pourUI or not pourUI.Visible then 
                if State.isPourHolding then
                     VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
                     State.isPourHolding = false
                end
                return 
            end
            
            local frame = pourUI:FindFirstChild("Frame")
            if not frame then return end
            
            local line = frame:FindFirstChild("Line")
            local area = frame:FindFirstChild("Area")
            
            if line and area and line:IsA("GuiObject") and area:IsA("GuiObject") then
                -- From source: Line.Position.Y.Scale moves between 0-1
                -- Holding mouse: Line goes UP (Y decreases)
                -- Releasing mouse: Line goes DOWN (Y increases)
                -- Goal: Keep Line inside Area
                
                local lineScale = line.Position.Y.Scale
                local areaTopScale = area.Position.Y.Scale
                local areaBottomScale = areaTopScale + area.Size.Y.Scale
                local areaCenterScale = (areaTopScale + areaBottomScale) / 2
                
                -- Click position for VIM (use frame center)
                local absPos = frame.AbsolutePosition
                local absSize = frame.AbsoluteSize
                local centerX = absPos.X + (absSize.X / 2)
                local centerY = absPos.Y + (absSize.Y / 2)
                local guiInset = game:GetService("GuiService"):GetGuiInset()
                local trueY = centerY + guiInset.Y
                
                -- Logic: 
                -- If Line is BELOW area center (higher Y value) -> Hold to move UP
                -- If Line is ABOVE area center (lower Y value) -> Release to move DOWN
                if lineScale > areaCenterScale then
                    -- Line is below center, need to hold to move up
                    if not State.isPourHolding then
                        VirtualInputManager:SendMouseMoveEvent(centerX, trueY, game)
                        VirtualInputManager:SendMouseButtonEvent(centerX, trueY, 0, true, game, 1)
                        State.isPourHolding = true
                    end
                else
                    -- Line is above center, need to release to move down
                    if State.isPourHolding then
                        VirtualInputManager:SendMouseButtonEvent(centerX, trueY, 0, false, game, 1)
                        State.isPourHolding = false
                    end
                end
            end
        end)
    end

    -- Minigame Loops
    task.spawn(function()
        while true do
            task.wait(0.1)
            if State.isAutoForgeEnabled then
                performMeltAction()
                performPourAction()
            end
        end
    end)

    task.spawn(function()
        RunService.RenderStepped:Connect(function()
            if State.isAutoForgeEnabled then
                 performHammerAction()
            end
        end)
    end)
end

task.spawn(function()
    while true do
        task.wait(2)
        if State.isHighlightEnabled then
            updateHighlights()
        end
    end
end)

-- ==================== SELL TAB ====================

-- Item lists for sell dropdowns
local SellOreTypes = {
    "Stone", "Copper", "Tin", "Sand Stone", "Iron", "Silver", "Gold",
    "Platinum", "Volcanic Rock", "Starite", "Poopite", "Bananite", "Cardboardite",
    "Cobalt", "Titanium", "Lapis Lazuli", "Quartz", "Amethyst", "Topaz",
    "Diamond", "Sapphire", "Ruby", "Emerald", "Cuprite", "Eye Ore",
    "Rivalite", "Uranium", "Mythril", "Lightite", "Obsidian", "Fireite",
    "Magmaite", "Demonite", "Slimite", "Boneite", "Dark Boneite",
    "Aite", "Grass", "Mushroomite", "Fichillium", "Fichilliumorite", "Galaxite", "Darkryte"
}

_G.OreRarityMap = {
    Stone = "Common", ["Sand Stone"] = "Common", Copper = "Common", 
    Iron = "Common", Cardboardite = "Common", Grass = "Common",
    Tin = "Uncommon", Silver = "Uncommon", Gold = "Uncommon", 
    Bananite = "Uncommon", Cobalt = "Uncommon", Titanium = "Uncommon", 
    ["Lapis Lazuli"] = "Uncommon",
    Platinum = "Rare", Mushroomite = "Rare", Quartz = "Rare", 
    Amethyst = "Rare", Topaz = "Rare", Diamond = "Rare", 
    Sapphire = "Rare", Boneite = "Rare", ["Dark Boneite"] = "Rare",
    Poopite = "Epic", Aite = "Epic", Ruby = "Epic", 
    Emerald = "Epic", Cuprite = "Epic", Rivalite = "Epic", 
    Obsidian = "Epic", Slimite = "Epic",
    Uranium = "Legendary", Mythril = "Legendary", Lightite = "Legendary", 
    Fireite = "Legendary", Magmaite = "Legendary", ["Eye Ore"] = "Legendary",
    Starite = "Mythic", Demonite = "Mythic", Darkryte = "Mythic",
    Fichillium = "Relic", Galaxite = "Divine", Fichilliumorite = "Unobtainable"
}

_G.RarityList = {"Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic"}

_G.getOresByRarity = function(rarity)
    local ores = {}
    for oreName, oreRarity in pairs(_G.OreRarityMap) do
        if oreRarity == rarity then
            ores[#ores + 1] = oreName
        end
    end
    table.sort(ores)
    return ores
end

local SellMaterialTypes = {
    "Tiny Essence", "Small Essence", "Medium Essence", "Large Essence",
    "Greater Essence", "Superior Essence", "Epic Essence", "Legendary Essence", "Mythical Essence"
}

local SellPickaxeTypes = {
    "Stone Pickaxe", "Bronze Pickaxe", "Iron Pickaxe", "Gold Pickaxe",
    "Platinum Pickaxe", "Arcane Pickaxe", "Cobalt Pickaxe", "Titanium Pickaxe",
    "Uranium Pickaxe", "Mythril Pickaxe", "Lightite Pickaxe", "Magma Pickaxe",
    "Demonic Pickaxe", "Stonewake's Pickaxe"
}

local SellWeaponTypes = {
    "Dagger", "Falchion Knife", "Gladius Dagger", "Hook", "Falchion",
    "Gladius", "Cutlass", "Rapier", "Chaos", "Ironhand", "Boxing Gloves",
    "Relevator", "Uchigatana", "Tachi", "Crusader Sword", "Long Sword",
    "Double Battle Axe", "Scythe", "Reaper", "Hammer", "Great Sword",
    "Dragon Slayer", "Skull Crusher", "Comically Large Spoon"
}

-- Sell State variables
State.isAutoSellOreEnabled = false
State.isAutoSellMaterialEnabled = false
State.isAutoSellPickaxeEnabled = false
State.isAutoSellWeaponEnabled = false
State.selectedSellOres = {}
State.selectedSellMaterials = {}
State.selectedSellPickaxes = {}
State.selectedSellWeapons = {}
State.sellOreQuantity = 1
State.sellMaterialQuantity = 1
State.sellInterval = 0.1
State.oreSearchText = ""
State.materialSearchText = ""
State.sellSessionInitialized = false
State.selectedSellRanks = {}
State.isAutoSellByRankEnabled = false

local SellOreDropdownRef = nil
local SellMaterialDropdownRef = nil
local SellStatusRef = nil

local function getSellReplicaData()
    local replicaData = nil
    pcall(function()
        local Knit = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Packages"):WaitForChild("Knit"))
        local PlayerController = Knit.GetController("PlayerController")
        if PlayerController and PlayerController.Replica then
            replicaData = PlayerController.Replica.Data
        end
    end)
    return replicaData
end

local function getSellPlayerInventory()
    local inventory = {Ores = {}, Materials = {}, Equipments = {}}
    local data = getSellReplicaData()
    if not data or not data.Inventory then return inventory end
    
    pcall(function()
        for itemName, quantity in pairs(data.Inventory) do
            if type(quantity) == "number" and quantity > 0 then
                inventory.Ores[itemName] = quantity
            end
        end
        
        if data.Inventory.Misc then
            for _, item in pairs(data.Inventory.Misc) do
                if type(item) == "table" then
                    local name = item.Name or item.Id
                    if name then
                        local qty = item.Quantity or 1
                        inventory.Materials[name] = (inventory.Materials[name] or 0) + qty
                    end
                end
            end
        end
        
        if data.Inventory.Equipments then
            for _, equip in pairs(data.Inventory.Equipments) do
                if type(equip) == "table" and equip.Name and equip.GUID then
                    table.insert(inventory.Equipments, {
                        Name = equip.Name,
                        GUID = equip.GUID,
                        Type = equip.Type,
                        Equipped = equip.Equipped or false
                    })
                end
            end
        end
    end)
    
    return inventory
end

local function filterSellList(list, searchText)
    if not searchText or searchText == "" then return list end
    local filtered = {}
    local lowerSearch = string.lower(searchText)
    for _, item in ipairs(list) do
        if string.lower(item):find(lowerSearch, 1, true) then
            table.insert(filtered, item)
        end
    end
    return filtered
end

local function initializeSellSession()
    if State.sellSessionInitialized then return true end
    
    -- Pause auto farms during sell initialization to prevent tween conflicts
    local wasAutoFarmEnabled = State.isAutoFarmEnabled
    local wasAutoMonsterFarmEnabled = State.isAutoMonsterFarmEnabled
    local wasAutoMaterialFarmEnabled = State.isAutoMaterialFarmEnabled
    
    -- Temporarily disable auto farms
    State.isAutoFarmEnabled = false
    State.isAutoMonsterFarmEnabled = false
    State.isAutoMaterialFarmEnabled = false
    task.wait(0.3) -- Let current farm loops stop
    
    local success = pcall(function()
        -- Find Greedy Cey NPC dynamically instead of fixed position
        local greedyCey = workspace:WaitForChild("Proximity", 5):WaitForChild("Greedy Cey", 5)
        if not greedyCey then
            error("Greedy Cey not found")
        end
        
        local npcPos = nil
        if greedyCey.PrimaryPart then
            npcPos = greedyCey.PrimaryPart.Position
        elseif greedyCey:FindFirstChild("HumanoidRootPart") then
            npcPos = greedyCey.HumanoidRootPart.Position
        else
            -- Fallback: get position from any part
            for _, part in pairs(greedyCey:GetDescendants()) do
                if part:IsA("BasePart") then
                    npcPos = part.Position
                    break
                end
            end
        end
        
        local character = LocalPlayer.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")
        
        if npcPos and hrp then
            local targetCFrame = CFrame.new(npcPos + Vector3.new(0, 3, 3), npcPos) -- Look at NPC, slightly higher
            local distance = (npcPos - hrp.Position).Magnitude
            local tweenTime = math.clamp(distance / 80, 0.5, 5)
            local tweenInfo = TweenInfo.new(tweenTime, Enum.EasingStyle.Linear)
            
            -- Prepare for tween: Noclip + Anchor + PlatformStand
            local humanoid = character:FindFirstChild("Humanoid")
            local originalCollision = {}
            local originalAnchored = hrp.Anchored
            
            if humanoid then humanoid.PlatformStand = true end
            hrp.Anchored = true
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
            
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    originalCollision[part] = part.CanCollide
                    part.CanCollide = false
                end
            end
            
            local tween = TweenService:Create(hrp, tweenInfo, {CFrame = targetCFrame})
            tween:Play()
            tween.Completed:Wait()
            
            -- Restore after tween
            for part, wasCollidable in pairs(originalCollision) do
                if part and part.Parent then
                    part.CanCollide = wasCollidable
                end
            end
            
            hrp.Anchored = originalAnchored
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
            if humanoid then humanoid.PlatformStand = false end
            
            task.wait(0.3)
        end
        
        -- Open dialogue with Greedy Cey
        ReplicatedStorage.Shared.Packages.Knit.Services.ProximityService.RF.Dialogue:InvokeServer(greedyCey)
        task.wait(0.2)
        ReplicatedStorage.Shared.Packages.Knit.Services.DialogueService.RE.DialogueEvent:FireServer("Opened")
    end)
    
    -- Close dialogue by clicking "No" button
    task.wait(5)
    pcall(function()
        local playerGui = LocalPlayer:WaitForChild("PlayerGui")
        local dialogueUI = playerGui:FindFirstChild("DialogueUI")
        if dialogueUI then
            local responseBillboard = dialogueUI:FindFirstChild("ResponseBillboard")
            if responseBillboard then
                -- Find response with LayoutOrder = 2 (option "No")
                for _, frame in pairs(responseBillboard:GetChildren()) do
                    if frame:IsA("Frame") and frame.LayoutOrder == 2 then
                        local button = frame:FindFirstChild("Button")
                        if button then
                            -- Try multiple click methods
                            -- Method 1: Fire MouseButton1Click signal directly
                            if firesignal then
                                pcall(function() firesignal(button.MouseButton1Click) end)
                            end
                            -- Method 2: Fire click using fireclickdetector if available
                            if fireclickdetector then
                                pcall(function() fireclickdetector(button) end)
                            end
                            -- Method 3: VirtualInputManager
                            local absPos = button.AbsolutePosition
                            local absSize = button.AbsoluteSize
                            local clickX = absPos.X + absSize.X / 2
                            local clickY = absPos.Y + absSize.Y / 2
                            VirtualInputManager:SendMouseButtonEvent(clickX, clickY, 0, true, game, 1)
                            task.wait(0.1)
                            VirtualInputManager:SendMouseButtonEvent(clickX, clickY, 0, false, game, 1)
                            break
                        end
                    end
                end
            end
        end
    end)
    task.wait(0.3)
    pcall(function()
        game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("DialogueService"):WaitForChild("RE"):WaitForChild("DialogueEvent"):FireServer("Closed")
    end)
    
    -- Restore auto farms state
    State.isAutoFarmEnabled = wasAutoFarmEnabled
    State.isAutoMonsterFarmEnabled = wasAutoMonsterFarmEnabled
    State.isAutoMaterialFarmEnabled = wasAutoMaterialFarmEnabled
    
    if success then
        State.sellSessionInitialized = true
    end
    return success
end

local function sellItems(basket)
    if not next(basket) then return false end
    
    -- Initialize session only once (tween + dialogue)
    if not State.sellSessionInitialized then
        initializeSellSession()
    end
    
    return pcall(function()
        -- Sell
        ReplicatedStorage.Shared.Packages.Knit.Services.DialogueService.RF.RunCommand
            :InvokeServer("SellConfirm", {Basket = basket})
        -- Update equipment info
        ReplicatedStorage.Shared.Packages.Knit.Services.StatusService.RF.GetPlayerEquipmentInfo
            :InvokeServer()
    end)
end

local function buildOreBasket()
    local basket = {}
    for oreName, isSelected in pairs(State.selectedSellOres) do
        if isSelected then
            basket[oreName] = State.sellOreQuantity
        end
    end
    return basket
end

local function buildMaterialBasket()
    local basket = {}
    for matName, isSelected in pairs(State.selectedSellMaterials) do
        if isSelected then
            basket[matName] = State.sellMaterialQuantity
        end
    end
    return basket
end

local function buildPickaxeBasket()
    local basket = {}
    for pickaxeName, isSelected in pairs(State.selectedSellPickaxes) do
        if isSelected then
            basket[pickaxeName] = true
        end
    end
    return basket
end

local function buildWeaponBasket()
    local basket = {}
    for weaponName, isSelected in pairs(State.selectedSellWeapons) do
        if isSelected then
            basket[weaponName] = true
        end
    end
    return basket
end

local function buildRankBasket()
    local basket = {}
    local rank = State.selectedSellRank or "Common"
    local ores = _G.getOresByRarity(rank)
    for _, oreName in ipairs(ores) do
        basket[oreName] = 99 -- Sell up to 99 of each
    end
    -- Debug: print basket size
    if next(basket) then
        print("[SELL BY RANK] Selling rank:", rank, "Ores:", #ores)
    end
    return basket
end

-- ISLAND FILTER FOR SELL
State.selectedSellIsland = "All"

local SellIslandDropdown = Tabs.Sell:CreateDropdown("SellIslandSelect", {
    Title = "Island Select",
    Description = "Select Island to filter Ore/Material",
    Values = IslandList,
    Multi = false,
    Default = "All"
})

SellIslandDropdown:OnChanged(function(Value)
    State.selectedSellIsland = Value
    -- Update Ore dropdown
    local ores = IslandOreMap[Value] or SellOreTypes
    if SellOreDropdownRef then
        SellOreDropdownRef:SetValues(ores)
    end
    -- Update Material dropdown  
    local materials = IslandMaterialMap[Value] or SellMaterialTypes
    if SellMaterialDropdownRef then
        SellMaterialDropdownRef:SetValues(materials)
    end
    -- Reset selections
    State.selectedSellOres = {}
    State.selectedSellMaterials = {}
end)

-- SELL BY RANK SECTION
Tabs.Sell:CreateSection("SELL BY RANK")

do -- Scope to avoid local register overflow
    local rankDropdown = Tabs.Sell:CreateDropdown("SellRankSelect", {
        Title = "Select Rank",
        Description = "Select multiple ranks to sell ore",
        Values = _G.RarityList,
        Multi = true,
        Default = {}
    })

    local rankParagraph = Tabs.Sell:CreateParagraph("RankOresInfo", {
        Title = "Ores in selected ranks",
        Content = "No rank selected"
    })

    -- Helper to get all ores from selected ranks
    local function getOresFromSelectedRanks()
        local allOres = {}
        local ranks = State.selectedSellRanks or {}
        for rank, isSelected in pairs(ranks) do
            if isSelected then
                local ores = _G.getOresByRarity(rank)
                for _, oreName in ipairs(ores) do
                    allOres[oreName] = true
                end
            end
        end
        return allOres
    end

    rankDropdown:OnChanged(function(Value)
        State.selectedSellRanks = Value
        -- Update paragraph with all ores from selected ranks
        local oreList = {}
        for rank, isSelected in pairs(Value) do
            if isSelected then
                local ores = _G.getOresByRarity(rank)
                for _, oreName in ipairs(ores) do
                    table.insert(oreList, oreName)
                end
            end
        end
        table.sort(oreList)
        rankParagraph:SetContent(#oreList > 0 and table.concat(oreList, ", ") or "No rank selected")
        
        -- If auto sell by rank is enabled, update ore selection
        if State.isAutoSellByRankEnabled then
            State.selectedSellOres = getOresFromSelectedRanks()
        end
    end)

    Tabs.Sell:CreateToggle("AutoSellByRank", {
        Title = "Auto Sell By Rank",
        Description = "Automatically sell ores of selected ranks",
        Default = false,
        Callback = function(Value)
            State.isAutoSellByRankEnabled = Value
            if Value then
                -- Populate selectedSellOres with all ores from selected ranks
                State.selectedSellOres = getOresFromSelectedRanks()
                -- Enable auto sell ore
                State.isAutoSellOreEnabled = true
                if Options.AutoSellOre then
                    Options.AutoSellOre:SetValue(true)
                end
            else
                -- Disable auto sell ore and clear selection
                State.isAutoSellOreEnabled = false
                State.selectedSellOres = {}
                if Options.AutoSellOre then
                    Options.AutoSellOre:SetValue(false)
                end
            end
        end
    })
end

-- ORE SELL SECTION
Tabs.Sell:CreateSection("ORE SELL")

Tabs.Sell:CreateInput("OreSearch", {
    Title = "Find Ore",
    Description = "Enter ore name to filter",
    Default = "",
    Placeholder = "Enter ore name...",
    Numeric = false,
    Finished = false,
    Callback = function(Value)
        State.oreSearchText = Value
        if SellOreDropdownRef then
            SellOreDropdownRef:SetValues(filterSellList(SellOreTypes, Value))
        end
    end
})

SellOreDropdownRef = Tabs.Sell:CreateDropdown("SellOreSelect", {
    Title = "Select Ore to sell",
    Description = "Select ore types",
    Values = SellOreTypes,
    Multi = true,
    Default = {}
})

SellOreDropdownRef:OnChanged(function(Value)
    State.selectedSellOres = Value
end)

Tabs.Sell:CreateInput("OreQuantity", {
    Title = "Ore Quantity",
    Description = "Each sale will sell this amount",
    Default = "1",
    Placeholder = "1",
    Numeric = true,
    Finished = true,
    Callback = function(Value)
        State.sellOreQuantity = tonumber(Value) or 1
    end
})

Tabs.Sell:CreateToggle("AutoSellOre", {
    Title = "Auto Sell Ore",
    Description = "Automatically sell selected ore",
    Default = false,
    Callback = function(Value)
        State.isAutoSellOreEnabled = Value
    end
})

-- MATERIAL SELL SECTION
Tabs.Sell:CreateSection("MATERIAL SELL")

Tabs.Sell:CreateInput("MaterialSearch", {
    Title = "Find Material",
    Description = "Enter material name to filter",
    Default = "",
    Placeholder = "Enter material name...",
    Numeric = false,
    Finished = false,
    Callback = function(Value)
        State.materialSearchText = Value
        if SellMaterialDropdownRef then
            SellMaterialDropdownRef:SetValues(filterSellList(SellMaterialTypes, Value))
        end
    end
})

SellMaterialDropdownRef = Tabs.Sell:CreateDropdown("SellMaterialSelect", {
    Title = "Select Material to sell",
    Description = "Select material types",
    Values = SellMaterialTypes,
    Multi = true,
    Default = {}
})

SellMaterialDropdownRef:OnChanged(function(Value)
    State.selectedSellMaterials = Value
end)

Tabs.Sell:CreateInput("MaterialQuantity", {
    Title = "Material Quantity",
    Description = "Each sale will sell this amount",
    Default = "1",
    Placeholder = "1",
    Numeric = true,
    Finished = true,
    Callback = function(Value)
        State.sellMaterialQuantity = tonumber(Value) or 1
    end
})

Tabs.Sell:CreateToggle("AutoSellMaterial", {
    Title = "Auto Sell Material",
    Description = "Automatically sell selected material",
    Default = false,
    Callback = function(Value)
        State.isAutoSellMaterialEnabled = Value
    end
})

-- PICKAXE SELL SECTION
Tabs.Sell:CreateSection("PICKAXE SELL")

local SellPickaxeDropdown = Tabs.Sell:CreateDropdown("SellPickaxeSelect", {
    Title = "Select Pickaxe to sell",
    Description = "Keep at least 1 pickaxe",
    Values = SellPickaxeTypes,
    Multi = true,
    Default = {}
})

SellPickaxeDropdown:OnChanged(function(Value)
    State.selectedSellPickaxes = Value
end)

Tabs.Sell:CreateToggle("AutoSellPickaxe", {
    Title = "Auto Sell Pickaxe",
    Description = "Automatically sell selected pickaxe",
    Default = false,
    Callback = function(Value)
        State.isAutoSellPickaxeEnabled = Value
    end
})

-- WEAPON SELL SECTION
Tabs.Sell:CreateSection("WEAPON SELL")

local SellWeaponDropdown = Tabs.Sell:CreateDropdown("SellWeaponSelect", {
    Title = "Select Weapon to sell",
    Description = "Don't sell equipped weapon",
    Values = SellWeaponTypes,
    Multi = true,
    Default = {}
})

SellWeaponDropdown:OnChanged(function(Value)
    State.selectedSellWeapons = Value
end)

Tabs.Sell:CreateToggle("AutoSellWeapon", {
    Title = "Auto Sell Weapon",
    Description = "Automatically sell selected weapon",
    Default = false,
    Callback = function(Value)
        State.isAutoSellWeaponEnabled = Value
    end
})

-- SETTINGS SECTION
Tabs.Sell:CreateSection("SETTINGS")

Tabs.Sell:CreateSlider("SellInterval", {
    Title = "Sell (s)",
    Description = "Time between each auto sell",
    Default = 0.1, Min = 0.1, Max = 60, Rounding = 1,
    Callback = function(Value) State.sellInterval = Value end
})

SellStatusRef = Tabs.Sell:CreateParagraph("SellStatus", {
    Title = "Sell Status",
    Content = "Ready"
})

Tabs.Sell:CreateButton({
    Title = "Sell All Now",
    Description = "Sell all selected items now",
    Callback = function()
        local count = 0
        if next(buildOreBasket()) then sellItems(buildOreBasket()) count = count + 1 end
        if next(buildMaterialBasket()) then sellItems(buildMaterialBasket()) count = count + 1 end
        if next(buildPickaxeBasket()) then sellItems(buildPickaxeBasket()) count = count + 1 end
        if next(buildWeaponBasket()) then sellItems(buildWeaponBasket()) count = count + 1 end
        if SellStatusRef then
            SellStatusRef:SetContent("Sold " .. count .. " types - " .. os.date("%H:%M:%S"))
        end
    end
})

task.spawn(function()
    while true do
        task.wait(State.sellInterval)
        local parts = {}
        if State.isAutoSellOreEnabled and next(buildOreBasket()) then sellItems(buildOreBasket()) table.insert(parts, State.isAutoSellByRankEnabled and "ByRank" or "Ore") end
        if State.isAutoSellMaterialEnabled and next(buildMaterialBasket()) then sellItems(buildMaterialBasket()) table.insert(parts, "Mat") end
        if State.isAutoSellPickaxeEnabled and next(buildPickaxeBasket()) then sellItems(buildPickaxeBasket()) table.insert(parts, "Pick") end
        if State.isAutoSellWeaponEnabled and next(buildWeaponBasket()) then sellItems(buildWeaponBasket()) table.insert(parts, "Weap") end
        if #parts > 0 and SellStatusRef then
            SellStatusRef:SetContent("Sold: " .. table.concat(parts, ", ") .. " - " .. os.date("%H:%M:%S"))
        end
    end
end)

-- UTILITY SECTION
Tabs.Sell:CreateSection("UTILITY")

Tabs.Sell:CreateButton({
    Title = "Remove Lava (Map 2)",
    Description = "Remove lava in Volcanic Depths/Cave to avoid losing HP when farming",
    Callback = function()
        local count = 0
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") then
                local name = obj.Name:lower()
                local isCrackedLava = obj.Material == Enum.Material.CrackedLava
                local isNeonOrange = obj.BrickColor == BrickColor.new("Bright orange") and obj.Material == Enum.Material.Neon
                if name:find("lava") or isCrackedLava or isNeonOrange then
                    obj.CanCollide = false
                    obj.CanTouch = false
                    obj.Transparency = 1
                    count = count + 1
                end
            end
        end
        Library:Notify({Title = "Remove Lava", Content = "Hidden " .. count .. " lava parts", Duration = 3})
    end
})

Tabs.Sell:CreateToggle("AutoRemoveLava", {
    Title = "Auto Remove Lava",
    Description = "Automatically hide lava when loading map (CrackedLava material)",
    Default = true,
    Callback = function(Value)
        State.isAutoRemoveLavaEnabled = Value
        if Value then
            -- Hide immediately
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj:IsA("BasePart") then
                    local name = obj.Name:lower()
                    local isCrackedLava = obj.Material == Enum.Material.CrackedLava
                    local isNeonOrange = obj.BrickColor == BrickColor.new("Bright orange") and obj.Material == Enum.Material.Neon
                    if name:find("lava") or isCrackedLava or isNeonOrange then
                        obj.CanCollide = false
                        obj.CanTouch = false
                        obj.Transparency = 1
                    end
                end
            end
        end
    end
})

-- Auto remove lava on new descendants
Workspace.DescendantAdded:Connect(function(obj)
    if State.isAutoRemoveLavaEnabled and obj:IsA("BasePart") then
        task.wait(0.1)
        local name = obj.Name:lower()
        local isCrackedLava = obj.Material == Enum.Material.CrackedLava
        local isNeonOrange = obj.BrickColor == BrickColor.new("Bright orange") and obj.Material == Enum.Material.Neon
        if name:find("lava") or isCrackedLava or isNeonOrange then
            obj.CanCollide = false
            obj.CanTouch = false
            obj.Transparency = 1
        end
    end
end)

SaveManager:SetLibrary(Library)
InterfaceManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes{}
InterfaceManager:SetFolder("VxezeHub-TheForge")
SaveManager:SetFolder("VxezeHub-TheForge/Configs")

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)


-- ================== AUTO TALK NPC (NO-LOCAL CHUNK PATCH) ==================
-- This patch avoids adding new top-level locals to prevent "local registers limit 200".

_G.__TF = _G.__TF or {}
_G.__TF.NpcAlias = _G.__TF.NpcAlias or {}  -- you can set: _G.__TF.NpcAlias["Wizard"]="The Wizard"

-- Call: _G.AutoTalkNPC("Sensei Moro") or _G.AutoTalkNPC(model)
_G.AutoTalkNPC = function(npc)
    -- resolve npc name
    local npcName = nil
    if typeof(npc) == "string" then
        npcName = npc
    elseif typeof(npc) == "Instance" then
        npcName = npc.Name
    else
        return false
    end
    npcName = _G.__TF.NpcAlias[npcName] or npcName

    -- pick position from existing tables in TheForge
    local pos = nil
    if type(QuestNPCPositions) == "table" then
        pos = QuestNPCPositions[npcName] or QuestNPCPositions[tostring(npcName)]
    end
    if not pos and type(NPCPositions) == "table" then
        pos = NPCPositions[npcName] or NPCPositions[tostring(npcName)]
    end

    -- tween to position (must be tween, no teleport fallback)
    local plr = game:GetService("Players").LocalPlayer
    local char = plr.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end

    if pos then
        local ts = game:GetService("TweenService")
        local cf = CFrame.new(pos + Vector3.new(0, 2, 0))
        local tw = ts:Create(hrp, TweenInfo.new(4.5, Enum.EasingStyle.Linear), {CFrame = cf})
        tw:Play()
        tw.Completed:Wait()
    elseif typeof(npc) == "Instance" then
        -- fallback: tween to model's PrimaryPart (still tween, not teleport)
        local part = npc.PrimaryPart or npc:FindFirstChildWhichIsA("BasePart")
        if not part then return false end
        local ts = game:GetService("TweenService")
        local cf = (part.CFrame * CFrame.new(0, 0, -3))
        local tw = ts:Create(hrp, TweenInfo.new(3.5, Enum.EasingStyle.Linear), {CFrame = cf})
        tw:Play()
        tw.Completed:Wait()
    else
        return false
    end

    -- wait for proximity to appear (as you described)
    local proxFolder = workspace:FindFirstChild("Proximity") or workspace:WaitForChild("Proximity", 6)
    if not proxFolder then return false end
    local proxNpc = proxFolder:FindFirstChild(npcName) or proxFolder:WaitForChild(npcName, 4)
    if not proxNpc then return false end

    -- call your remotes exactly
    local rs = game:GetService("ReplicatedStorage")
    local services = rs:WaitForChild("Shared"):WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services")

    local RF_Dialogue = services:WaitForChild("ProximityService"):WaitForChild("RF"):WaitForChild("Dialogue")
    local DialogueService = services:WaitForChild("DialogueService")
    local RE_DialogueEvent = DialogueService:WaitForChild("RE"):WaitForChild("DialogueEvent")
    local RF_RunCommand = DialogueService:WaitForChild("RF"):WaitForChild("RunCommand")

    local ok = pcall(function()
        RF_Dialogue:InvokeServer(proxNpc)
        RE_DialogueEvent:FireServer("Opened")
        RF_RunCommand:InvokeServer("CheckQuest")
        RE_DialogueEvent:FireServer("Closed")
    end)

    return ok
end

-- Optional: auto-refresh quest dropdown (no new locals in chunk)
_G.__TF.AutoQuestEnabled = _G.__TF.AutoQuestEnabled or false
_G.__TF.RegisterQuestDropdown = _G.__TF.RegisterQuestDropdown or function(cb)
    _G.__TF._QuestDropdownCallbacks = _G.__TF._QuestDropdownCallbacks or {}
    table.insert(_G.__TF._QuestDropdownCallbacks, cb)
end

task.spawn(function()
    while task.wait(1) do
        if _G.__TF.AutoQuestEnabled and getIncompleteQuestObjectives then
            local list = getIncompleteQuestObjectives()
            local cbs = _G.__TF._QuestDropdownCallbacks
            if type(cbs) == "table" then
                for _, cb in ipairs(cbs) do
                    pcall(cb, list)
                end
            end
        end
    end
end)
-- ================== END PATCH ==================