--[[
╔══════════════════════════════════════════════════════════╗
║              V O I D   H U B  v4.0                      ║
║           Garden Horizons Edition  🌱                   ║
║                                                         ║
║  Fitur lengkap untuk Garden Horizons (Dawn Digital)     ║
║  Auto Farm | Auto Sell | Mutation Tracker | ESP         ║
║  Weather Monitor | Shop Sniper | Quest Auto             ║
║                                                         ║
║  Paste langsung ke executor — tidak perlu URL           ║
╚══════════════════════════════════════════════════════════╝
]]

-- ═══════════════════════════════════════════════════════════
-- SERVICES
-- ═══════════════════════════════════════════════════════════
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local ReplicatedStorage= game:GetService("ReplicatedStorage")
local HttpService      = game:GetService("HttpService")

local lp   = Players.LocalPlayer
local pgui = lp:WaitForChild("PlayerGui")

local function Char() return lp.Character end
local function HRP()  local c=Char(); return c and c:FindFirstChild("HumanoidRootPart") end
local function Hum()  local c=Char(); return c and c:FindFirstChildOfClass("Humanoid") end

-- ═══════════════════════════════════════════════════════════
-- GARDEN HORIZONS CONSTANTS
-- ═══════════════════════════════════════════════════════════
-- NPC Names (berdasarkan riset)
local NPC = {
    BILL  = "Bill",    -- Seed Shop
    MOLLY = "Molly",   -- Gear Shop
    STEVE = "Steve",   -- Sell / Appraise
    MAYA  = "Maya",    -- IGMA Quest NPC
    QUEST = "Quest",   -- Quest Board
}

-- Mutation multipliers (additive, lalu dikali trait)
local MUTATIONS = {
    ["Foggy"]      = 1.5,  ["Soaked"]    = 1.5,  ["Chilled"]   = 1.5,
    ["Flooded"]    = 1.5,  ["Tidal"]     = 2.0,  ["Silver"]    = 2.0,
    ["Snowy"]      = 2.0,  ["Sandy"]     = 2.5,  ["Frostbit"]  = 3.5,
    ["Mossy"]      = 3.5,  ["Shocked"]   = 4.5,  ["Muddy"]     = 4.5,
    ["Starstruck"] = 6.5,  ["Nova"]      = 6.5,  ["Galactic"]  = 5.0,
    ["Meteoric"]   = 10.0, ["Party"]     = 11.5,
}

-- Trait multipliers (multiplicative)
local TRAITS = {
    ["Unripe"]  = 1.0,
    ["Ripened"] = 2.0,
    ["Lush"]    = 3.0,
}

-- Plant base prices (Shillings)
local PLANT_PRICES = {
    -- Common
    ["Carrot"]        = 30,
    ["Corn"]          = 80,
    ["Dandelion"]     = 50,
    ["Sunpetal"]      = 60,
    ["Biohazard Melon"]= 200,
    -- Uncommon
    ["Bellpepper"]    = 180,
    ["Onion"]         = 250,
    ["Strawberry"]    = 600,
    ["Mushroom"]      = 1000,
    ["Goldenberry"]   = 800,
    ["Lablush Berry"] = 900,
    -- Rare
    ["Beetroot"]      = 2000,
    ["Birch"]         = 2500,
    ["Tomato"]        = 3500,
    ["Apple"]         = 6000,
    ["Amber Pine"]    = 5500,
    ["Rose"]          = 8000,
    -- Legendary
    ["Banana"]        = 25000,
    ["Plum"]          = 50000,
    ["Cherry"]        = 120000,
    ["Dawnfruit"]     = 200000,
    ["Cabbage"]       = 300000,
}

-- Weather info
local WEATHER_INFO = {
    ["Sunny"]   = {growth="Normal",  mutations={},                      color=Color3.fromRGB(255,210,50)},
    ["Rain"]    = {growth="+25%",    mutations={"Soaked","Flooded"},    color=Color3.fromRGB(80,160,255)},
    ["Fog"]     = {growth="+1x",     mutations={"Foggy"},               color=Color3.fromRGB(180,190,200)},
    ["Storm"]   = {growth="+2x",     mutations={"Shocked","Flooded"},   color=Color3.fromRGB(120,100,200)},
    ["Snow"]    = {growth="Slower",  mutations={"Snowy","Chilled","Frostbit"}, color=Color3.fromRGB(200,230,255)},
    ["Sand"]    = {growth="Normal",  mutations={"Sandy","Muddy"},       color=Color3.fromRGB(220,190,120)},
    ["Star"]    = {growth="+1x",     mutations={"Starstruck","Nova"},   color=Color3.fromRGB(255,240,100)},
    ["Meteor"]  = {growth="+2x",     mutations={"Meteoric","Galactic"}, color=Color3.fromRGB(255,120,50)},
    ["Tidal"]   = {growth="+1.5x",   mutations={"Tidal","Soaked"},      color=Color3.fromRGB(0,180,220)},
    ["Party"]   = {growth="+3x",     mutations={"Party"},               color=Color3.fromRGB(255,80,200)},
    ["Mossy"]   = {growth="+1x",     mutations={"Mossy"},               color=Color3.fromRGB(80,200,100)},
}

-- ═══════════════════════════════════════════════════════════
-- STATE
-- ═══════════════════════════════════════════════════════════
local Enabled = {
    AutoHarvest    = false,
    AutoSell       = false,
    AutoBuySeeds   = false,
    AutoWater      = false,
    ShopSniper     = false,
    AutoQuest      = false,
    MutationAlert  = false,
    WeatherAlert   = false,
    LushWait       = false,
    AntiAFK        = false,
    ESP_Crops      = false,
    ESP_Players    = false,
    ESP_NPCs       = false,
    SpeedBoost     = false,
    AutoFavorite   = false,
    AutoRebuy      = false,
}

local Config = {
    WalkSpeed       = 24,
    SellDelay       = 0.1,
    BuySeedPriority = "expensive",  -- "cheap" | "expensive" | "rare"
    MinMutMult      = 3.5,          -- hanya alert mutasi >= nilai ini
    TargetSeed      = "Carrot",     -- seed yang dibeli auto
    RarityFilter    = "All",        -- filter harvest
    AutoSellOnLush  = true,
    ShopSniperList  = {"Banana","Plum","Cherry","Cabbage","Dawnfruit"},
    WeatherHistory  = {},
    CurrentWeather  = "Sunny",
    LastShopCheck   = 0,
    ShillingsEarned = 0,
    HarvestCount    = 0,
    SeedsBought     = 0,
    SessionStart    = os.clock(),
}

-- Connection manager
local Conns = {}
local function AddConn(k, v) if Conns[k] then pcall(function()Conns[k]:Disconnect()end) end Conns[k]=v end
local function RemConn(k) if Conns[k] then pcall(function()Conns[k]:Disconnect()end) end Conns[k]=nil end
local function RemAll() for k in pairs(Conns) do RemConn(k) end end

-- ═══════════════════════════════════════════════════════════
-- UTILS
-- ═══════════════════════════════════════════════════════════
local function FormatNum(n)
    if n >= 1e9  then return string.format("%.1fb", n/1e9)
    elseif n >= 1e6 then return string.format("%.1fm", n/1e6)
    elseif n >= 1e3 then return string.format("%.1fk", n/1e3)
    else return tostring(math.floor(n)) end
end

local function FindNPC(name)
    for _, o in ipairs(workspace:GetDescendants()) do
        if o.Name:lower():find(name:lower()) and (o:IsA("Model") or o:IsA("NPC") or o:IsA("BasePart")) then
            return o
        end
    end
    return nil
end

local function GetNPCPos(name)
    local n = FindNPC(name)
    if n then
        if n:IsA("Model") then
            local hrp = n:FindFirstChild("HumanoidRootPart") or n:FindFirstChildWhichIsA("BasePart")
            return hrp and hrp.Position
        elseif n:IsA("BasePart") then
            return n.Position
        end
    end
    return nil
end

local function TeleportToPos(pos)
    local hrp = HRP()
    if hrp and pos then hrp.CFrame = CFrame.new(pos + Vector3.new(0,3,0)) end
end

-- Fire RemoteEvent safely
local function FireRemote(name, ...)
    local re = ReplicatedStorage:FindFirstChild(name, true)
    if re and re:IsA("RemoteEvent") then
        pcall(function() re:FireServer(...) end)
        return true
    end
    return false
end

-- Invoke RemoteFunction safely
local function InvokeRemote(name, ...)
    local rf = ReplicatedStorage:FindFirstChild(name, true)
    if rf and rf:IsA("RemoteFunction") then
        local ok, res = pcall(function() return rf:InvokeServer(...) end)
        return ok and res or nil
    end
    return nil
end

-- Find all crops/plants in workspace
local function GetAllCrops()
    local crops = {}
    for _, o in ipairs(workspace:GetDescendants()) do
        if o:IsA("Model") or o:IsA("BasePart") then
            local n = o.Name:lower()
            if n:find("crop") or n:find("plant") or n:find("fruit") or n:find("harvest")
            or n:find("carrot") or n:find("corn") or n:find("tomato") or n:find("apple")
            or n:find("rose") or n:find("mushroom") or n:find("strawberry")
            or n:find("beetroot") or n:find("onion") or n:find("banana")
            or n:find("cherry") or n:find("plum") or n:find("cabbage")
            or n:find("dawnfruit") or n:find("goldenberry") then
                table.insert(crops, o)
            end
        end
    end
    return crops
end

-- Get player's garden plot
local function GetMyGarden()
    local plots = {}
    for _, o in ipairs(workspace:GetDescendants()) do
        local n = o.Name:lower()
        if (n:find("plot") or n:find("garden") or n:find("patch") or n:find("bed"))
        and o:IsA("BasePart") or o:IsA("Model") then
            -- Check ownership via attributes
            local owner = o:GetAttribute("Owner") or o:GetAttribute("PlayerName")
            if owner == lp.Name or owner == lp.UserId then
                table.insert(plots, o)
            end
        end
    end
    return plots
end

-- Detect current weather from game
local function DetectWeather()
    -- Scan environment / lighting changes
    local lighting = game:GetService("Lighting")
    local sky = lighting:FindFirstChildWhichIsA("Sky", true)
    local atm = lighting:FindFirstChildWhichIsA("Atmosphere", true)
    local particles = workspace:FindFirstChildWhichIsA("ParticleEmitter", true)

    -- Check for weather-named objects in workspace
    for _, o in ipairs(workspace:GetDescendants()) do
        local n = o.Name:lower()
        for wName in pairs(WEATHER_INFO) do
            if n:find(wName:lower()) then
                Config.CurrentWeather = wName
                return wName
            end
        end
    end

    -- Check lighting clues
    local amb = lighting.Ambient
    if amb.R < 0.2 and amb.B > 0.4 then return "Storm"
    elseif amb.R > 0.8 and amb.G > 0.6 then return "Star"
    end

    return Config.CurrentWeather
end

-- Calculate crop value
local function CalcCropValue(plantName, mutations, trait)
    local base = PLANT_PRICES[plantName] or 30
    local mutMult = 1.0
    for _, m in ipairs(mutations or {}) do
        mutMult = mutMult + (MUTATIONS[m] or 0)
    end
    local traitMult = TRAITS[trait or "Unripe"] or 1.0
    return math.floor(base * mutMult * traitMult)
end

-- ═══════════════════════════════════════════════════════════
-- FEATURE: AUTO HARVEST
-- ═══════════════════════════════════════════════════════════
local function SetAutoHarvest(on)
    Enabled.AutoHarvest = on
    if not on then RemConn("harvest"); return end

    AddConn("harvest", RunService.Heartbeat:Connect(function()
        local hrp = HRP(); if not hrp then return end

        -- Method 1: Fire harvest remote
        local harvested = FireRemote("Harvest") or FireRemote("HarvestCrop")
            or FireRemote("PickCrop") or FireRemote("CollectCrop")

        -- Method 2: Find harvestable parts and touch them
        if not harvested then
            for _, o in ipairs(workspace:GetDescendants()) do
                if o:IsA("BasePart") then
                    local n = o.Name:lower()
                    if n:find("harvestable") or n:find("ripe") or n:find("lush") or n:find("fruit") then
                        local dist = (o.Position - hrp.Position).Magnitude
                        if dist < 30 then
                            -- Teleport briefly to touch
                            local saved = hrp.CFrame
                            hrp.CFrame = CFrame.new(o.Position + Vector3.new(0,2,0))
                            task.wait(0.05)
                            hrp.CFrame = saved
                            Config.HarvestCount = Config.HarvestCount + 1
                        end
                    end
                end
            end
        end
    end))
end

-- ═══════════════════════════════════════════════════════════
-- FEATURE: AUTO SELL
-- ═══════════════════════════════════════════════════════════
local function SetAutoSell(on)
    Enabled.AutoSell = on
    if not on then RemConn("sell"); return end

    AddConn("sell", task.spawn(function()
        while Enabled.AutoSell do
            -- Method 1: Remote event
            local sold = FireRemote("SellAll") or FireRemote("Sell")
                or FireRemote("SellCrops") or FireRemote("BulkSell")

            -- Method 2: Teleport to Steve NPC
            if not sold then
                local stevePos = GetNPCPos(NPC.STEVE)
                if stevePos then
                    TeleportToPos(stevePos)
                    task.wait(0.3)
                    -- Try clicking/touching NPC
                    FireRemote("SellAll")
                    FireRemote("Sell")
                    -- Also try ProximityPrompt
                    for _, o in ipairs(workspace:GetDescendants()) do
                        if o:IsA("ProximityPrompt") then
                            local n = o.Name:lower()
                            if n:find("sell") or n:find("steve") then
                                pcall(function()
                                    fireproximityprompt(o)
                                end)
                            end
                        end
                    end
                end
            end

            Config.ShillingsEarned = Config.ShillingsEarned + 1 -- placeholder counter
            task.wait(Config.SellDelay + 0.5)
        end
    end))
end

-- ═══════════════════════════════════════════════════════════
-- FEATURE: AUTO BUY SEEDS
-- ═══════════════════════════════════════════════════════════
local function SetAutoBuySeeds(on)
    Enabled.AutoBuySeeds = on
    if not on then RemConn("buyseeds"); return end

    AddConn("buyseeds", task.spawn(function()
        while Enabled.AutoBuySeeds do
            -- Teleport to Bill
            local billPos = GetNPCPos(NPC.BILL)
            if billPos then
                TeleportToPos(billPos)
                task.wait(0.3)
            end

            -- Try buying via remote
            local bought = FireRemote("BuySeed", Config.TargetSeed)
                or FireRemote("PurchaseSeed", Config.TargetSeed)
                or FireRemote("BuyItem", Config.TargetSeed)

            -- Try ProximityPrompt on Bill's shop
            if not bought then
                for _, o in ipairs(workspace:GetDescendants()) do
                    if o:IsA("ProximityPrompt") then
                        local n = o.Name:lower()
                        if n:find("buy") or n:find("bill") or n:find("seed") or n:find("shop") then
                            pcall(function() fireproximityprompt(o) end)
                        end
                    end
                end
            end

            Config.SeedsBought = Config.SeedsBought + 1
            task.wait(5.5) -- wait for shop restock (5 min = 300s, but buy every restock)
        end
    end))
end

-- ═══════════════════════════════════════════════════════════
-- FEATURE: SHOP SNIPER (beli seed langka saat restock)
-- ═══════════════════════════════════════════════════════════
local function SetShopSniper(on)
    Enabled.ShopSniper = on
    if not on then RemConn("sniper"); return end

    AddConn("sniper", RunService.Heartbeat:Connect(function()
        local now = os.clock()
        if now - Config.LastShopCheck < 0.5 then return end
        Config.LastShopCheck = now

        -- Scan shop UI atau remote untuk seed yang ada
        for _, o in ipairs(workspace:GetDescendants()) do
            local n = o.Name
            for _, target in ipairs(Config.ShopSniperList) do
                if n:lower():find(target:lower()) then
                    -- Found target seed in shop area
                    local billPos = GetNPCPos(NPC.BILL)
                    if billPos then
                        TeleportToPos(billPos)
                        task.wait(0.1)
                        FireRemote("BuySeed", target)
                        FireRemote("PurchaseSeed", target)
                        -- Try all buy proximityprompts
                        for _, pp in ipairs(workspace:GetDescendants()) do
                            if pp:IsA("ProximityPrompt") then
                                local pn = pp.Name:lower()
                                if pn:find("buy") or pn:find(target:lower()) then
                                    pcall(function() fireproximityprompt(pp) end)
                                end
                            end
                        end
                        Notify("🎯 Shop Sniper: Beli "..target.."!", "ok")
                    end
                end
            end
        end
    end))
end

-- ═══════════════════════════════════════════════════════════
-- FEATURE: AUTO WATER
-- ═══════════════════════════════════════════════════════════
local function SetAutoWater(on)
    Enabled.AutoWater = on
    if not on then RemConn("water"); return end

    AddConn("water", task.spawn(function()
        while Enabled.AutoWater do
            -- Try remote first
            local watered = FireRemote("WaterAll") or FireRemote("Water")
                or FireRemote("UseWateringCan") or FireRemote("WaterCrops")

            if not watered then
                -- Scan for watering-related proximityprompts
                for _, o in ipairs(workspace:GetDescendants()) do
                    if o:IsA("ProximityPrompt") then
                        local n = o.Name:lower()
                        if n:find("water") or n:find("sprinkler") then
                            pcall(function() fireproximityprompt(o) end)
                        end
                    end
                end
            end
            task.wait(8)
        end
    end))
end

-- ═══════════════════════════════════════════════════════════
-- FEATURE: WEATHER MONITOR
-- ═══════════════════════════════════════════════════════════
local weatherMonitorConn
local function SetWeatherMonitor(on)
    Enabled.WeatherAlert = on
    if not on then RemConn("weather"); return end

    AddConn("weather", RunService.Heartbeat:Connect(function()
        local detected = DetectWeather()
        if detected ~= Config.CurrentWeather then
            Config.CurrentWeather = detected
            local info = WEATHER_INFO[detected]
            if info then
                local mutStr = #info.mutations > 0 and table.concat(info.mutations, ", ") or "None"
                Notify("🌤 Weather: "..detected.." — "..mutStr, "info")
                table.insert(Config.WeatherHistory, 1, {w=detected, t=os.clock()})
                if #Config.WeatherHistory > 10 then table.remove(Config.WeatherHistory) end
            end
        end
    end))
end

-- ═══════════════════════════════════════════════════════════
-- FEATURE: MUTATION ALERT
-- ═══════════════════════════════════════════════════════════
local function SetMutationAlert(on)
    Enabled.MutationAlert = on
    if not on then RemConn("mutalert"); return end

    AddConn("mutalert", RunService.Heartbeat:Connect(function()
        -- Scan crops for mutation attributes
        for _, o in ipairs(workspace:GetDescendants()) do
            if o:IsA("Model") or o:IsA("BasePart") then
                for mutName, mult in pairs(MUTATIONS) do
                    local hasMut = o:GetAttribute(mutName)
                        or o:GetAttribute("Mutation_"..mutName)
                        or o:GetAttribute("mutation")
                    if hasMut and mult >= Config.MinMutMult then
                        local owner = o:GetAttribute("Owner") or ""
                        if owner == lp.Name or owner == "" then
                            Notify("✨ MUTASI "..mutName.." ("..mult.."x) di "..o.Name, "ok")
                        end
                    end
                end
            end
        end
    end))
end

-- ═══════════════════════════════════════════════════════════
-- FEATURE: LUSH WAIT (tunggu Lush sebelum jual)
-- ═══════════════════════════════════════════════════════════
local function SetLushWait(on)
    Enabled.LushWait = on
    if on then
        Notify("🌿 Lush Wait: Otomatis jual saat Lush (3x)", "info")
        AddConn("lushwait", RunService.Heartbeat:Connect(function()
            for _, o in ipairs(workspace:GetDescendants()) do
                local trait = o:GetAttribute("Trait") or o:GetAttribute("Stage") or o:GetAttribute("Ripeness")
                if trait and (trait == "Lush" or trait:lower():find("lush")) then
                    local owner = o:GetAttribute("Owner") or ""
                    if owner == lp.Name then
                        -- Sell this crop immediately
                        FireRemote("SellCrop", o) or FireRemote("Sell", o)
                        Config.ShillingsEarned = Config.ShillingsEarned + 1
                        Config.HarvestCount = Config.HarvestCount + 1
                        Notify("💰 Lush crop dijual: "..o.Name, "ok")
                    end
                end
            end
        end))
    else
        RemConn("lushwait")
        Notify("Lush Wait dimatikan", "warn")
    end
end

-- ═══════════════════════════════════════════════════════════
-- FEATURE: AUTO FAVORITE (tandai crop terbaik agar skip saat sell)
-- ═══════════════════════════════════════════════════════════
local function SetAutoFavorite(on)
    Enabled.AutoFavorite = on
    if not on then RemConn("autofav"); return end

    AddConn("autofav", RunService.Heartbeat:Connect(function()
        for _, o in ipairs(workspace:GetDescendants()) do
            if o:IsA("Model") or o:IsA("BasePart") then
                local owner = o:GetAttribute("Owner") or ""
                if owner == lp.Name then
                    -- Check mutation multiplier
                    local totalMult = 0
                    for mutName, mult in pairs(MUTATIONS) do
                        if o:GetAttribute(mutName) then
                            totalMult = totalMult + mult
                        end
                    end
                    if totalMult >= 6.0 then
                        -- Mark as favorite
                        FireRemote("FavoriteCrop", o) or FireRemote("Favorite", o)
                        pcall(function() o:SetAttribute("Favorited", true) end)
                    end
                end
            end
        end
    end))
end

-- ═══════════════════════════════════════════════════════════
-- FEATURE: AUTO QUEST
-- ═══════════════════════════════════════════════════════════
local function SetAutoQuest(on)
    Enabled.AutoQuest = on
    if not on then RemConn("quest"); return end

    AddConn("quest", task.spawn(function()
        while Enabled.AutoQuest do
            -- Teleport to Quest Board / Maya
            local questPos = GetNPCPos(NPC.QUEST) or GetNPCPos(NPC.MAYA)
            if questPos then
                TeleportToPos(questPos)
                task.wait(0.3)
            end
            -- Claim quests
            FireRemote("ClaimQuest") or FireRemote("CompleteQuest")
                or FireRemote("TurnInQuest") or FireRemote("AcceptQuest")
            -- ProximityPrompt approach
            for _, o in ipairs(workspace:GetDescendants()) do
                if o:IsA("ProximityPrompt") then
                    local n = o.Name:lower()
                    if n:find("quest") or n:find("daily") or n:find("weekly") or n:find("claim") then
                        pcall(function() fireproximityprompt(o) end)
                    end
                end
            end
            task.wait(30) -- check quests every 30 sec
        end
    end))
end

-- ═══════════════════════════════════════════════════════════
-- FEATURE: ESP
-- ═══════════════════════════════════════════════════════════
local espStore = {}
local function ClearESP() for _, v in ipairs(espStore) do pcall(function() v:Destroy() end) end espStore={} end

local function addHL(adornee, col, surfCol, thick)
    local h = Instance.new("SelectionBox")
    h.Adornee = adornee
    h.Color3 = col
    h.LineThickness = thick or 0.04
    h.SurfaceTransparency = 0.85
    h.SurfaceColor3 = surfCol or col
    h.Parent = game:GetService("CoreGui")
    table.insert(espStore, h)
    return h
end

local function RefreshESP()
    ClearESP()
    if Enabled.ESP_Crops then
        for _, o in ipairs(workspace:GetDescendants()) do
            local n = o.Name:lower()
            if o:IsA("BasePart") and (n:find("crop") or n:find("fruit") or n:find("lush") or n:find("ripe")) then
                local trait = o:GetAttribute("Trait") or ""
                local col = trait == "Lush" and Color3.fromRGB(0,255,100)
                         or trait == "Ripened" and Color3.fromRGB(255,220,0)
                         or Color3.fromRGB(0,120,255)
                addHL(o, col, col)
            end
        end
    end
    if Enabled.ESP_NPCs then
        for _, npcName in ipairs({NPC.BILL, NPC.MOLLY, NPC.STEVE, NPC.MAYA}) do
            local n = FindNPC(npcName)
            if n then addHL(n, Color3.fromRGB(255,180,0), Color3.fromRGB(200,120,0), 0.05) end
        end
    end
    if Enabled.ESP_Players then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= lp and p.Character then
                addHL(p.Character, Color3.fromRGB(0,160,255), Color3.fromRGB(0,80,200), 0.04)
            end
        end
    end
end

local function SetESP_Crops(on) Enabled.ESP_Crops = on; RefreshESP(); Notify(on and "🌾 Crop ESP ON" or "Crop ESP OFF", on and "ok" or "warn") end
local function SetESP_NPCs(on)  Enabled.ESP_NPCs  = on; RefreshESP(); Notify(on and "👴 NPC ESP ON"  or "NPC ESP OFF",  on and "ok" or "warn") end
local function SetESP_Players(on) Enabled.ESP_Players=on; RefreshESP(); Notify(on and "👤 Player ESP ON" or "Player ESP OFF", on and "ok" or "warn") end

-- ═══════════════════════════════════════════════════════════
-- FEATURE: ANTI AFK
-- ═══════════════════════════════════════════════════════════
local function SetAntiAFK(on)
    Enabled.AntiAFK = on
    if on then
        local vu = game:GetService("VirtualUser")
        AddConn("afk", lp.Idled:Connect(function()
            vu:Button2Down(Vector2.zero, workspace.CurrentCamera.CFrame)
            task.wait(0.1)
            vu:Button2Up(Vector2.zero, workspace.CurrentCamera.CFrame)
        end))
        Notify("🛡 Anti-AFK ON", "ok")
    else
        RemConn("afk")
        Notify("Anti-AFK OFF", "warn")
    end
end

-- ═══════════════════════════════════════════════════════════
-- FEATURE: SPEED BOOST
-- ═══════════════════════════════════════════════════════════
local function ApplySpeed()
    local h = Hum()
    if h then h.WalkSpeed = Enabled.SpeedBoost and Config.WalkSpeed or 16 end
end
local function SetSpeedBoost(on)
    Enabled.SpeedBoost = on; ApplySpeed()
    Notify(on and ("⚡ Speed "..Config.WalkSpeed) or "Speed OFF", on and "ok" or "warn")
end

-- ═══════════════════════════════════════════════════════════
-- FEATURE: TP TO NPC
-- ═══════════════════════════════════════════════════════════
local function TpToNPC(name)
    local pos = GetNPCPos(name)
    if pos then TeleportToPos(pos); Notify("📍 TP ke "..name, "ok")
    else Notify(name.." tidak ditemukan", "err") end
end

-- ═══════════════════════════════════════════════════════════
-- FEATURE: FULL AUTO MODE (semua auto aktif)
-- ═══════════════════════════════════════════════════════════
local function FullAutoMode(on)
    SetAutoHarvest(on)
    SetAutoSell(on)
    SetAutoBuySeeds(on)
    SetAutoWater(on)
    SetAntiAFK(on)
    SetWeatherMonitor(on)
    SetLushWait(on)
    if on then Notify("🚀 FULL AUTO MODE ON!", "ok")
    else      Notify("🛑 Full Auto dimatikan", "warn") end
end

-- ═══════════════════════════════════════════════════════════
-- FEATURE: RESPAWN HANDLER
-- ═══════════════════════════════════════════════════════════
lp.CharacterAdded:Connect(function()
    task.wait(0.5)
    if Enabled.SpeedBoost then ApplySpeed() end
    if Enabled.AntiAFK then SetAntiAFK(true) end
end)

-- ═══════════════════════════════════════════════════════════
-- MUTATION CALCULATOR
-- ═══════════════════════════════════════════════════════════
local function CalcDisplay(plantName, selectedMuts, trait)
    local val = CalcCropValue(plantName, selectedMuts, trait)
    return val
end

-- ═══════════════════════════════════════════════════════════
--          U I   B U I L D E R  —  VOID HUB v4
-- ═══════════════════════════════════════════════════════════
local cg = game:GetService("CoreGui")
if cg:FindFirstChild("VoidHubV4") then cg:FindFirstChild("VoidHubV4"):Destroy() end

-- Notif GUI
if cg:FindFirstChild("VHNotif4") then cg:FindFirstChild("VHNotif4"):Destroy() end
local notifSG = Instance.new("ScreenGui")
notifSG.Name = "VHNotif4"
notifSG.ResetOnSpawn = false
notifSG.DisplayOrder = 9999
notifSG.Parent = cg

local notifList = {}
local typeColor = { ok=Color3.fromRGB(0,200,110), info=Color3.fromRGB(0,130,255), warn=Color3.fromRGB(255,160,0), err=Color3.fromRGB(255,55,55) }

function Notify(msg, t)
    t = t or "info"
    local col = typeColor[t] or typeColor.info
    for _, f in ipairs(notifList) do
        TweenService:Create(f, TweenInfo.new(0.2), { Position=f.Position+UDim2.new(0,0,0,44) }):Play()
    end
    local f = Instance.new("Frame")
    f.Size = UDim2.new(0,230,0,36)
    f.Position = UDim2.new(1,-240,0,-50)
    f.BackgroundColor3 = Color3.fromRGB(7,9,18)
    f.BorderSizePixel = 0
    f.Parent = notifSG
    Instance.new("UICorner",f).CornerRadius = UDim.new(0,7)
    local bar=Instance.new("Frame",f); bar.Size=UDim2.new(0,3,1,0); bar.BackgroundColor3=col; bar.BorderSizePixel=0
    Instance.new("UICorner",bar).CornerRadius=UDim.new(0,3)
    local lbl=Instance.new("TextLabel",f)
    lbl.Size=UDim2.new(1,-12,1,0); lbl.Position=UDim2.new(0,9,0,0)
    lbl.BackgroundTransparency=1; lbl.Text=msg; lbl.TextSize=11
    lbl.Font=Enum.Font.GothamSemibold; lbl.TextColor3=Color3.fromRGB(210,225,255)
    lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.TextTruncate=Enum.TextTruncate.AtEnd
    local sk=Instance.new("UIStroke",f); sk.Color=col; sk.Thickness=1; sk.Transparency=0.5
    table.insert(notifList,1,f)
    TweenService:Create(f,TweenInfo.new(0.3,Enum.EasingStyle.Back),{Position=UDim2.new(1,-240,0,12)}):Play()
    task.delay(3.2, function()
        TweenService:Create(f,TweenInfo.new(0.2),{Position=UDim2.new(1,20,0,f.Position.Y.Offset),BackgroundTransparency=1}):Play()
        task.delay(0.25, function() local i=table.find(notifList,f); if i then table.remove(notifList,i) end; f:Destroy() end)
    end)
end

-- ── MAIN SCREEN GUI ─────────────────────────────
local SG = Instance.new("ScreenGui")
SG.Name = "VoidHubV4"
SG.ResetOnSpawn = false
SG.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
SG.DisplayOrder = 999
SG.Parent = cg

-- Colours
local CL = {
    bg=Color3.fromRGB(6,8,16), panel=Color3.fromRGB(10,13,24),
    row=Color3.fromRGB(13,17,30), rowH=Color3.fromRGB(17,22,40),
    acc=Color3.fromRGB(0,120,255), accB=Color3.fromRGB(35,150,255),
    accD=Color3.fromRGB(0,60,165), border=Color3.fromRGB(0,70,175),
    bF=Color3.fromRGB(16,24,50), text=Color3.fromRGB(210,225,255),
    muted=Color3.fromRGB(70,100,155), dim=Color3.fromRGB(30,50,90),
    ok=Color3.fromRGB(0,200,110), warn=Color3.fromRGB(255,160,0),
    danger=Color3.fromRGB(255,55,55), gold=Color3.fromRGB(255,200,40),
    green=Color3.fromRGB(60,210,100),
}

local function Cr(r,p)  local c=Instance.new("UICorner",p);c.CornerRadius=UDim.new(0,r);return c end
local function Sk(c,t,p) local s=Instance.new("UIStroke",p);s.Color=c;s.Thickness=t;return s end
local function Gd(c1,c2,rot,p)
    local g=Instance.new("UIGradient",p)
    g.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,c1),ColorSequenceKeypoint.new(1,c2)})
    g.Rotation=rot; return g
end
local function Fr(pr,pa) local f=Instance.new("Frame");f.BorderSizePixel=0;for k,v in pairs(pr) do pcall(function()f[k]=v end) end;if pa then f.Parent=pa end;return f end
local function Lb(pr,pa) local l=Instance.new("TextLabel");l.BackgroundTransparency=1;l.Font=Enum.Font.GothamSemibold;for k,v in pairs(pr) do pcall(function()l[k]=v end) end;if pa then l.Parent=pa end;return l end
local function Bt(pr,pa) local b=Instance.new("TextButton");b.BorderSizePixel=0;b.Font=Enum.Font.GothamBold;for k,v in pairs(pr) do pcall(function()b[k]=v end) end;if pa then b.Parent=pa end;return b end

-- ── WINDOW (300 x 420) ──────────────────────────
local W = Fr({
    Size=UDim2.new(0,305,0,430), Position=UDim2.new(0.5,-152,0.5,-215),
    BackgroundColor3=CL.bg, Active=true, Draggable=true,
}, SG)
Cr(12,W); Sk(CL.border,1.5,W)
Gd(Color3.fromRGB(7,10,22),Color3.fromRGB(4,6,14),150,W)

-- ── TITLE BAR ───────────────────────────────────
local TB = Fr({Size=UDim2.new(1,0,0,42),BackgroundColor3=CL.accD,ZIndex=3},W)
Cr(12,TB)
Fr({Size=UDim2.new(1,0,0.5,0),Position=UDim2.new(0,0,0.5,0),BackgroundColor3=CL.accD,ZIndex=2},TB)
Gd(Color3.fromRGB(0,105,235),Color3.fromRGB(0,48,145),120,TB)

-- Logo
local logo=Fr({Size=UDim2.new(0,28,0,28),Position=UDim2.new(0,8,0.5,-14),BackgroundColor3=CL.acc,ZIndex=4},TB)
Cr(7,logo); Gd(CL.accB,CL.accD,135,logo)
Lb({Size=UDim2.new(1,0,1,0),Text="V",TextSize=16,Font=Enum.Font.GothamBold,TextColor3=Color3.fromRGB(255,255,255),ZIndex=5},logo)
Lb({Size=UDim2.new(0,160,0,18),Position=UDim2.new(0,42,0,4),Text="VOID HUB",TextSize=14,Font=Enum.Font.GothamBold,TextColor3=Color3.fromRGB(255,255,255),TextXAlignment=Enum.TextXAlignment.Left,ZIndex=4},TB)
Lb({Size=UDim2.new(0,175,0,12),Position=UDim2.new(0,42,0,23),Text="v4.0  •  Garden Horizons 🌱",TextSize=9,Font=Enum.Font.Gotham,TextColor3=Color3.fromRGB(100,165,255),TextXAlignment=Enum.TextXAlignment.Left,ZIndex=4},TB)

local function TbBtn(xOff,col,lbl)
    local b=Bt({Size=UDim2.new(0,24,0,24),Position=UDim2.new(1,xOff,0.5,-12),BackgroundColor3=col,Text=lbl,TextSize=11,TextColor3=Color3.fromRGB(255,255,255),ZIndex=5},TB)
    Cr(5,b); return b
end
local BtnClose=TbBtn(-32,CL.danger,"✕")
local BtnMin=TbBtn(-60,CL.warn,"−")

-- Body frame
local Body = Fr({Size=UDim2.new(1,0,1,-42),Position=UDim2.new(0,0,0,42),BackgroundTransparency=1},W)

BtnClose.MouseButton1Click:Connect(function()
    TweenService:Create(W,TweenInfo.new(0.25,Enum.EasingStyle.Quad,Enum.EasingDirection.In),
        {Size=UDim2.new(0,305,0,0),Position=W.Position+UDim2.new(0,0,0,215)}):Play()
    task.delay(0.3,function() SG:Destroy(); notifSG:Destroy() end)
end)

local mini=false
BtnMin.MouseButton1Click:Connect(function()
    mini=not mini
    Body.Visible=not mini
    TweenService:Create(W,TweenInfo.new(0.25,Enum.EasingStyle.Quad),
        {Size=mini and UDim2.new(0,305,0,42) or UDim2.new(0,305,0,430)}):Play()
end)

-- ── 5-TAB BAR ───────────────────────────────────
local TabBar=Fr({Size=UDim2.new(1,-16,0,26),Position=UDim2.new(0,8,0,6),BackgroundColor3=CL.panel},Body)
Cr(6,TabBar); Sk(CL.bF,1,TabBar)
local tbl=Instance.new("UIListLayout",TabBar); tbl.FillDirection=Enum.FillDirection.Horizontal
tbl.SortOrder=Enum.SortOrder.LayoutOrder; tbl.Padding=UDim.new(0,2)
local tp2=Instance.new("UIPadding",TabBar); tp2.PaddingLeft=UDim.new(0,2); tp2.PaddingRight=UDim.new(0,2)
tp2.PaddingTop=UDim.new(0,2); tp2.PaddingBottom=UDim.new(0,2)

-- Scroll wrap
local scrollH2 = 430 - 42 - 26 - 10 - 20
local SWrap = Fr({Size=UDim2.new(1,-16,0,scrollH2),Position=UDim2.new(0,8,0,38),BackgroundTransparency=1},Body)

-- Status bar
local StatBar=Fr({Size=UDim2.new(1,-16,0,18),Position=UDim2.new(0,8,1,-22),BackgroundColor3=CL.panel},Body)
Cr(5,StatBar); Sk(CL.bF,1,StatBar)
local sDot=Fr({Size=UDim2.new(0,6,0,6),Position=UDim2.new(0,7,0.5,-3),BackgroundColor3=CL.ok},StatBar); Cr(3,sDot)
Lb({Size=UDim2.new(0.5,0,1,0),Position=UDim2.new(0,18,0,0),Text="VOID HUB AKTIF",TextSize=9,Font=Enum.Font.GothamBold,TextColor3=CL.ok,TextXAlignment=Enum.TextXAlignment.Left},StatBar)
local statRight=Lb({Size=UDim2.new(0.5,-4,1,0),Position=UDim2.new(0.5,0,0,0),Text="Garden Horizons 🌱",TextSize=8,TextColor3=CL.dim,TextXAlignment=Enum.TextXAlignment.Right},StatBar)
local sp=Instance.new("UIPadding",StatBar); sp.PaddingRight=UDim.new(0,6)

-- Dot blink
task.spawn(function()
    while SG.Parent do
        TweenService:Create(sDot,TweenInfo.new(1),{BackgroundTransparency=0.5}):Play(); task.wait(1)
        TweenService:Create(sDot,TweenInfo.new(1),{BackgroundTransparency=0}):Play(); task.wait(1)
    end
end)

-- Tab system
local tabData2={}
local function NewTab2(name,icon,order)
    local btn=Bt({Size=UDim2.new(0.2,-2,1,0),BackgroundColor3=CL.panel,Text=icon,TextSize=11,TextColor3=CL.muted,LayoutOrder=order,ZIndex=4,Font=Enum.Font.GothamBold},TabBar)
    Cr(4,btn)
    local panel=Fr({Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Visible=false,ZIndex=2},SWrap)
    local ps=Instance.new("ScrollingFrame",panel)
    ps.Size=UDim2.new(1,0,1,0); ps.BackgroundTransparency=1; ps.BorderSizePixel=0
    ps.ScrollBarThickness=2; ps.ScrollBarImageColor3=CL.acc
    ps.CanvasSize=UDim2.new(0,0,0,0); ps.AutomaticCanvasSize=Enum.AutomaticSize.Y
    local pl2=Instance.new("UIListLayout",ps); pl2.Padding=UDim.new(0,4); pl2.SortOrder=Enum.SortOrder.LayoutOrder
    local pp2=Instance.new("UIPadding",ps); pp2.PaddingBottom=UDim.new(0,4)
    tabData2[name]={btn=btn,panel=panel,scroll=ps}
    btn.MouseButton1Click:Connect(function()
        for n,d in pairs(tabData2) do
            local a=(n==name); d.panel.Visible=a
            TweenService:Create(d.btn,TweenInfo.new(0.15),{BackgroundColor3=a and CL.acc or CL.panel, TextColor3=a and Color3.fromRGB(255,255,255) or CL.muted}):Play()
        end
    end)
    return ps
end

local scAuto = NewTab2("AUTO",  "🌾", 1)
local scFarm = NewTab2("FARM",  "🪙", 2)
local scESP  = NewTab2("ESP",   "👁", 3)
local scCalc = NewTab2("CALC",  "🧮", 4)
local scUtil = NewTab2("⚙",     "⚙",  5)

-- Activate first
tabData2["AUTO"].panel.Visible=true
tabData2["AUTO"].btn.BackgroundColor3=CL.acc
tabData2["AUTO"].btn.TextColor3=Color3.fromRGB(255,255,255)

-- ── ROW BUILDERS ────────────────────────────────
local function SecL(txt,pa,ord)
    local f=Fr({Size=UDim2.new(1,0,0,18),BackgroundTransparency=1,LayoutOrder=ord},pa)
    Lb({Size=UDim2.new(1,0,1,0),Text="▸ "..txt:upper(),TextSize=9,Font=Enum.Font.GothamBold,TextColor3=CL.acc,TextXAlignment=Enum.TextXAlignment.Left},f)
    local ln=Fr({Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,-1),BackgroundColor3=CL.border},f); ln.BackgroundTransparency=0.65
    return f
end

local function TglRow(icon,lbl,desc,pa,ord,cb,accentCol)
    accentCol = accentCol or CL.acc
    local on=false
    local row=Fr({Size=UDim2.new(1,0,0,44),BackgroundColor3=CL.row,LayoutOrder=ord},pa)
    Cr(7,row); local sk=Sk(CL.bF,1,row)
    local ab=Fr({Size=UDim2.new(0,3,0,26),Position=UDim2.new(0,0,0.5,-13),BackgroundColor3=accentCol},row); Cr(2,ab); ab.BackgroundTransparency=1
    Lb({Size=UDim2.new(0,28,1,0),Position=UDim2.new(0,7,0,0),Text=icon,TextSize=16,TextColor3=CL.dim,ZIndex=3},row)
    local mL=Lb({Size=UDim2.new(1,-85,0,20),Position=UDim2.new(0,37,0,4),Text=lbl,TextSize=12,Font=Enum.Font.GothamBold,TextColor3=CL.muted,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=3},row)
    local dL=Lb({Size=UDim2.new(1,-85,0,14),Position=UDim2.new(0,37,0,24),Text=desc,TextSize=9,TextColor3=CL.dim,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=3},row)
    local pb=Fr({Size=UDim2.new(0,38,0,20),Position=UDim2.new(1,-46,0.5,-10),BackgroundColor3=Color3.fromRGB(16,20,38)},row); Cr(10,pb); Sk(CL.bF,1,pb)
    local kn=Fr({Size=UDim2.new(0,14,0,14),Position=UDim2.new(0,3,0.5,-7),BackgroundColor3=CL.muted},pb); Cr(7,kn)
    local hit=Bt({Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",ZIndex=5},row)
    local function upd()
        TweenService:Create(pb,TweenInfo.new(0.18),{BackgroundColor3=on and CL.accD or Color3.fromRGB(16,20,38)}):Play()
        TweenService:Create(kn,TweenInfo.new(0.18),{Position=on and UDim2.new(0,21,0.5,-7) or UDim2.new(0,3,0.5,-7),BackgroundColor3=on and Color3.fromRGB(255,255,255) or CL.muted}):Play()
        TweenService:Create(sk,TweenInfo.new(0.18),{Color=on and accentCol or CL.bF}):Play()
        TweenService:Create(ab,TweenInfo.new(0.18),{BackgroundTransparency=on and 0 or 1}):Play()
        TweenService:Create(mL,TweenInfo.new(0.18),{TextColor3=on and CL.text or CL.muted}):Play()
        TweenService:Create(row,TweenInfo.new(0.18),{BackgroundColor3=on and CL.rowH or CL.row}):Play()
    end
    hit.MouseButton1Click:Connect(function() on=not on; upd(); cb(on) end)
    return row, function(v) on=v; upd() end  -- return setter too
end

local function ActRow(icon,lbl,desc,pa,ord,cb,col)
    col = col or CL.accD
    local row=Fr({Size=UDim2.new(1,0,0,40),BackgroundColor3=CL.row,LayoutOrder=ord},pa); Cr(7,row)
    local sk=Sk(CL.bF,1,row)
    Lb({Size=UDim2.new(0,26,1,0),Position=UDim2.new(0,7,0,0),Text=icon,TextSize=14,TextColor3=CL.acc,ZIndex=3},row)
    Lb({Size=UDim2.new(1,-82,0,18),Position=UDim2.new(0,35,0,4),Text=lbl,TextSize=12,Font=Enum.Font.GothamBold,TextColor3=CL.text,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=3},row)
    Lb({Size=UDim2.new(1,-82,0,13),Position=UDim2.new(0,35,0,22),Text=desc,TextSize=9,TextColor3=CL.dim,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=3},row)
    local rb=Bt({Size=UDim2.new(0,50,0,24),Position=UDim2.new(1,-58,0.5,-12),BackgroundColor3=col,Text="RUN",TextSize=10,TextColor3=Color3.fromRGB(255,255,255),ZIndex=5},row)
    Cr(5,rb); Gd(CL.accB,col,90,rb)
    rb.MouseButton1Click:Connect(function()
        TweenService:Create(rb,TweenInfo.new(0.1),{BackgroundTransparency=0.5}):Play()
        task.delay(0.15,function() TweenService:Create(rb,TweenInfo.new(0.1),{BackgroundTransparency=0}):Play() end)
        cb()
    end)
    row.MouseEnter:Connect(function() TweenService:Create(sk,TweenInfo.new(0.1),{Color=CL.acc}):Play() end)
    row.MouseLeave:Connect(function() TweenService:Create(sk,TweenInfo.new(0.1),{Color=CL.bF}):Play() end)
    return row
end

local function SldRow(icon,lbl,pa,ord,mn,mx,def,cb)
    local row=Fr({Size=UDim2.new(1,0,0,50),BackgroundColor3=CL.row,LayoutOrder=ord},pa); Cr(7,row); Sk(CL.bF,1,row)
    Lb({Size=UDim2.new(0,22,0,20),Position=UDim2.new(0,7,0,5),Text=icon,TextSize=13,TextColor3=CL.acc},row)
    Lb({Size=UDim2.new(0.58,0,0,18),Position=UDim2.new(0,30,0,6),Text=lbl,TextSize=11,Font=Enum.Font.GothamBold,TextColor3=CL.text,TextXAlignment=Enum.TextXAlignment.Left},row)
    local vL=Lb({Size=UDim2.new(0.35,-4,0,18),Position=UDim2.new(0.65,0,0,6),Text=tostring(def),TextSize=12,Font=Enum.Font.GothamBold,TextColor3=CL.accB,TextXAlignment=Enum.TextXAlignment.Right},row)
    local tr=Fr({Size=UDim2.new(1,-18,0,5),Position=UDim2.new(0,9,0,35),BackgroundColor3=Color3.fromRGB(16,22,44)},row); Cr(3,tr); Sk(CL.bF,1,tr)
    local pct=(def-mn)/(mx-mn)
    local fi=Fr({Size=UDim2.new(pct,0,1,0),BackgroundColor3=CL.acc},tr); Cr(3,fi); Gd(CL.accB,CL.acc,90,fi)
    local kn2=Fr({Size=UDim2.new(0,12,0,12),Position=UDim2.new(pct,-6,0.5,-6),BackgroundColor3=Color3.fromRGB(255,255,255),ZIndex=4},tr); Cr(6,kn2); Sk(CL.acc,1.5,kn2)
    local d2=false
    kn2.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then d2=true end end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then d2=false end end)
    UserInputService.InputChanged:Connect(function(i)
        if d2 and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
            local ap=tr.AbsolutePosition.X; local as=tr.AbsoluteSize.X
            local r=math.clamp((i.Position.X-ap)/as,0,1)
            fi.Size=UDim2.new(r,0,1,0); kn2.Position=UDim2.new(r,-6,0.5,-6)
            vL.Text=tostring(math.round(mn+r*(mx-mn))); cb(math.round(mn+r*(mx-mn)))
        end
    end)
    return row
end

local function InfoBox(lines, pa, ord, col)
    col = col or CL.bF
    local row=Fr({Size=UDim2.new(1,0,0,#lines*15+14),BackgroundColor3=CL.row,LayoutOrder=ord},pa); Cr(7,row); Sk(col,1,row)
    local txt=table.concat(lines,"\n")
    local l=Lb({Size=UDim2.new(1,-14,1,0),Position=UDim2.new(0,7,0,0),Text=txt,TextSize=10,Font=Enum.Font.GothamMono or Enum.Font.Code,TextColor3=CL.muted,TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true,LineHeight=1.55},row)
    return row, l
end

-- ═══════════════════════════════════════════════
-- TAB 1: AUTO (Garden Automation)
-- ═══════════════════════════════════════════════
local o=0; local function no() o=o+1; return o end

SecL("🚀 Master Control", scAuto, no())
ActRow("⚡","FULL AUTO MODE","Aktifkan semua otomasi sekaligus",scAuto,no(),function() FullAutoMode(true) end, Color3.fromRGB(0,140,80))
ActRow("🛑","STOP SEMUA AUTO","Hentikan semua otomasi",scAuto,no(),function() FullAutoMode(false) end, Color3.fromRGB(150,40,40))

SecL("🌾 Harvest & Sell", scAuto, no())
TglRow("🌾","Auto Harvest","Otomatis panen semua crop",scAuto,no(),function(on) SetAutoHarvest(on) end, CL.green)
TglRow("💰","Auto Sell","Otomatis jual ke Steve",scAuto,no(),function(on) SetAutoSell(on) end, CL.gold)
TglRow("🌿","Lush Wait & Sell","Jual hanya saat Lush (3x value)",scAuto,no(),function(on) SetLushWait(on) end, CL.green)
TglRow("⭐","Auto Favorite","Tandai crop mutasi tinggi (≥6x)",scAuto,no(),function(on) SetAutoFavorite(on) end, CL.gold)
SldRow("⏱","Sell Delay (s)",scAuto,no(),0,3,0,function(v) Config.SellDelay=v end)

SecL("🌱 Planting", scAuto, no())
TglRow("🪴","Auto Buy Seeds","Beli seed otomatis dari Bill",scAuto,no(),function(on) SetAutoBuySeeds(on) end)
TglRow("💧","Auto Water","Siram tanaman otomatis",scAuto,no(),function(on) SetAutoWater(on) end)

SecL("🎯 Shop & Quest", scAuto, no())
TglRow("🎯","Shop Sniper","Beli seed langka saat restock",scAuto,no(),function(on) SetShopSniper(on) end, Color3.fromRGB(200,80,255))
TglRow("📋","Auto Quest","Claim quest harian/mingguan",scAuto,no(),function(on) SetAutoQuest(on) end)
TglRow("🔔","Weather Alert","Notif saat cuaca berubah",scAuto,no(),function(on) SetWeatherMonitor(on) end)
TglRow("✨","Mutation Alert","Notif mutasi berharga",scAuto,no(),function(on) SetMutationAlert(on) end, Color3.fromRGB(180,120,255))
SldRow("🎚","Min Mut Value",scAuto,no(),1,12,3.5,function(v) Config.MinMutMult=v end)

-- ═══════════════════════════════════════════════
-- TAB 2: FARM (NPC Teleport + Stats)
-- ═══════════════════════════════════════════════
o=0
SecL("📍 Teleport ke NPC", scFarm, no())
ActRow("🌱","TP ke Bill (Seeds)","Beli benih dari Bill",scFarm,no(),function() TpToNPC(NPC.BILL) end)
ActRow("🔧","TP ke Molly (Gear)","Beli alat dari Molly",scFarm,no(),function() TpToNPC(NPC.MOLLY) end)
ActRow("💵","TP ke Steve (Sell)","Jual crop ke Steve",scFarm,no(),function() TpToNPC(NPC.STEVE) end)
ActRow("🧪","TP ke Maya (IGMA)","Quest researcher NPC",scFarm,no(),function() TpToNPC(NPC.MAYA) end)
ActRow("📋","TP ke Quest Board","Ambil/claim quest",scFarm,no(),function() TpToNPC(NPC.QUEST) end)

SecL("⚡ Quick Actions", scFarm, no())
ActRow("🔄","Loop: Bill → Harvest → Steve","Auto 1 siklus penuh",scFarm,no(),function()
    task.spawn(function()
        TpToNPC(NPC.BILL); task.wait(0.5)
        FireRemote("BuySeed", Config.TargetSeed); task.wait(0.3)
        -- Go to garden
        task.wait(0.3)
        TpToNPC(NPC.STEVE); task.wait(0.5)
        FireRemote("SellAll")
        Notify("🔄 Satu siklus selesai!", "ok")
    end)
end, Color3.fromRGB(0,130,80))
ActRow("💎","Jual Semua Sekarang","Force sell semua crop",scFarm,no(),function()
    TpToNPC(NPC.STEVE); task.wait(0.3)
    FireRemote("SellAll"); FireRemote("Sell"); FireRemote("BulkSell")
    Notify("💰 Jual semua crop!", "ok")
end, CL.gold)
ActRow("🌊","Tunggu Weather Bagus","Scan & notif weather mutation",scFarm,no(),function()
    SetWeatherMonitor(true)
    Notify("🌤 Monitoring weather...", "info")
end)

SecL("📊 Statistik Sesi", scFarm, no())
local statsBox, statsLbl = InfoBox({
    "⏱ Waktu: 00:00",
    "🌾 Harvest: 0",
    "💰 Shillings: ~0",
    "🌱 Seeds Beli: 0",
    "🌤 Weather: Sunny",
}, scFarm, no(), CL.bF)

-- Live stats update
RunService.Heartbeat:Connect(function()
    local elapsed = os.clock() - Config.SessionStart
    local mins = math.floor(elapsed/60)
    local secs = math.floor(elapsed%60)
    if statsLbl then
        statsLbl.Text = string.format(
            "⏱ Waktu: %02d:%02d\n🌾 Harvest: %d\n💰 Shillings: ~%s\n🌱 Seeds Beli: %d\n🌤 Weather: %s",
            mins, secs, Config.HarvestCount,
            FormatNum(Config.ShillingsEarned), Config.SeedsBought,
            Config.CurrentWeather
        )
    end
end)

SecL("💡 Mutation Info", scFarm, no())
local mutInfoBox, mutInfoLbl = InfoBox({
    "🌧 Rain      → Soaked/Flooded (1.5x)",
    "⭐ Star      → Starstruck (6.5x)",
    "⚡ Storm     → Shocked (4.5x)",
    "🏜 Sand      → Sandy+Muddy (2.5/4.5x)",
    "🎉 Party     → Party (11.5x) BEST!",
    "☄ Meteor    → Meteoric (10x)",
}, scFarm, no(), Color3.fromRGB(0,50,120))

-- ═══════════════════════════════════════════════
-- TAB 3: ESP
-- ═══════════════════════════════════════════════
o=0
SecL("👁 ESP Options", scESP, no())
TglRow("🌾","Crop ESP","Highlight tanaman (warna = kematangan)",scESP,no(),function(on) SetESP_Crops(on) end, CL.green)
TglRow("👴","NPC ESP","Highlight semua NPC di peta",scESP,no(),function(on) SetESP_NPCs(on) end, CL.gold)
TglRow("👤","Player ESP","Highlight player lain",scESP,no(),function(on) SetESP_Players(on) end)
ActRow("🔄","Refresh ESP","Update semua highlight",scESP,no(),function() RefreshESP(); Notify("ESP refreshed","ok") end)
ActRow("❌","Clear ESP","Hapus semua highlight",scESP,no(),function() ClearESP(); Notify("ESP cleared","warn") end)

SecL("🎨 Warna ESP Crop", scESP, no())
local _, espKey = InfoBox({
    "🟢 Hijau  = Lush (3x value)",
    "🟡 Kuning = Ripened (2x value)",
    "🔵 Biru   = Unripe (1x value)",
    "🟠 Oranye = NPC",
    "🔷 Biru   = Player lain",
}, scESP, no(), Color3.fromRGB(0,50,80))

SecL("👁 ESP Visual", scESP, no())
TglRow("🔍","Nama Crop Overhead","Billboard nama di atas crop",scESP,no(),function(on)
    if on then
        for _, o2 in ipairs(workspace:GetDescendants()) do
            if o2:IsA("BasePart") then
                local n2=o2.Name:lower()
                if n2:find("crop") or n2:find("fruit") or n2:find("lush") or n2:find("ripe") then
                    local bb=Instance.new("BillboardGui",o2)
                    bb.Size=UDim2.new(0,80,0,20); bb.StudsOffset=Vector3.new(0,3,0)
                    bb.AlwaysOnTop=true; bb.Name="VoidESP"
                    local tl=Instance.new("TextLabel",bb)
                    tl.Size=UDim2.new(1,0,1,0); tl.BackgroundTransparency=1
                    tl.Text=o2.Name; tl.TextSize=11; tl.Font=Enum.Font.GothamBold
                    tl.TextColor3=Color3.fromRGB(255,255,255)
                    local trait=o2:GetAttribute("Trait") or ""
                    if trait=="Lush" then tl.TextColor3=Color3.fromRGB(0,255,100)
                    elseif trait=="Ripened" then tl.TextColor3=Color3.fromRGB(255,220,0) end
                    table.insert(espStore,bb)
                end
            end
        end
        Notify("📛 Nama crop ON","ok")
    else
        for _, s in ipairs(espStore) do
            if s:IsA("BillboardGui") and s.Name=="VoidESP" then s:Destroy() end
        end
        Notify("Nama crop OFF","warn")
    end
end, CL.green)

-- ═══════════════════════════════════════════════
-- TAB 4: CALC (Mutation Calculator)
-- ═══════════════════════════════════════════════
o=0
SecL("🧮 Mutation Calculator", scCalc, no())

local calcInfoBox,calcInfoLbl = InfoBox({
    "Pilih tanaman & mutasi",
    "untuk hitung nilai jual.",
    "",
    "Contoh: Carrot + Starstruck",
    "             + Lush = ?",
}, scCalc, no(), Color3.fromRGB(0,40,100))

-- Plant selector buttons (compact grid)
local plantGrid=Fr({Size=UDim2.new(1,0,0,60),BackgroundTransparency=1,LayoutOrder=no()},scCalc)
local pgLayout=Instance.new("UIGridLayout",plantGrid); pgLayout.CellSize=UDim2.new(0,68,0,22); pgLayout.CellPadding=UDim2.new(0,3,0,3)

local selectedPlant = "Carrot"
local selectedMuts  = {}
local selectedTrait = "Lush"
local calcResultLbl

local plantBtns = {}
local function mkPlantBtn(name)
    local b=Bt({BackgroundColor3=CL.row,Text=name,TextSize=9,TextColor3=CL.muted,ZIndex=3},plantGrid)
    Cr(4,b); Sk(CL.bF,1,b)
    b.MouseButton1Click:Connect(function()
        selectedPlant=name
        for n2,btn in pairs(plantBtns) do
            TweenService:Create(btn,TweenInfo.new(0.1),{BackgroundColor3=n2==name and CL.accD or CL.row, TextColor3=n2==name and Color3.fromRGB(255,255,255) or CL.muted}):Play()
        end
        if calcResultLbl then
            local val=CalcCropValue(selectedPlant,selectedMuts,selectedTrait)
            calcResultLbl.Text="💰 "..FormatNum(val).." Shillings"
        end
    end)
    plantBtns[name]=b
end
for _,name in ipairs({"Carrot","Corn","Onion","Strawberry","Tomato","Apple","Rose","Banana","Cherry","Cabbage"}) do
    mkPlantBtn(name)
end

-- Mutation toggles
SecL("Mutasi (pilih yg ada)", scCalc, no())
local mutGrid=Fr({Size=UDim2.new(1,0,0,90),BackgroundTransparency=1,LayoutOrder=no()},scCalc)
local mgLayout=Instance.new("UIGridLayout",mutGrid); mgLayout.CellSize=UDim2.new(0,88,0,22); mgLayout.CellPadding=UDim2.new(0,2,0,2)

local mutBtns={}
for mName, mVal in pairs(MUTATIONS) do
    local b=Bt({BackgroundColor3=CL.row,Text=mName.." "..mVal.."x",TextSize=8,TextColor3=CL.muted,ZIndex=3},mutGrid)
    Cr(4,b); Sk(CL.bF,1,b)
    local selMut=false
    b.MouseButton1Click:Connect(function()
        selMut=not selMut
        TweenService:Create(b,TweenInfo.new(0.1),{BackgroundColor3=selMut and CL.accD or CL.row, TextColor3=selMut and Color3.fromRGB(255,255,255) or CL.muted}):Play()
        if selMut then table.insert(selectedMuts,mName)
        else
            local idx=table.find(selectedMuts,mName)
            if idx then table.remove(selectedMuts,idx) end
        end
        if calcResultLbl then
            local val=CalcCropValue(selectedPlant,selectedMuts,selectedTrait)
            calcResultLbl.Text="💰 "..FormatNum(val).." Shillings"
        end
    end)
    mutBtns[mName]=b
end

-- Trait selector
SecL("Trait", scCalc, no())
local traitGrid=Fr({Size=UDim2.new(1,0,0,26),BackgroundTransparency=1,LayoutOrder=no()},scCalc)
local tgLayout=Instance.new("UIGridLayout",traitGrid); tgLayout.CellSize=UDim2.new(0.33,-2,1,0); tgLayout.CellPadding=UDim2.new(0,3,0,0); tgLayout.FillDirection=Enum.FillDirection.Horizontal

local traitBtns={}
for _,tName in ipairs({"Unripe","Ripened","Lush"}) do
    local b=Bt({BackgroundColor3=tName=="Lush" and CL.accD or CL.row,Text=tName,TextSize=10,TextColor3=tName=="Lush" and Color3.fromRGB(255,255,255) or CL.muted,ZIndex=3},traitGrid)
    Cr(4,b)
    b.MouseButton1Click:Connect(function()
        selectedTrait=tName
        for n2,btn in pairs(traitBtns) do
            TweenService:Create(btn,TweenInfo.new(0.1),{BackgroundColor3=n2==tName and CL.accD or CL.row, TextColor3=n2==tName and Color3.fromRGB(255,255,255) or CL.muted}):Play()
        end
        if calcResultLbl then
            local val=CalcCropValue(selectedPlant,selectedMuts,selectedTrait)
            calcResultLbl.Text="💰 "..FormatNum(val).." Shillings"
        end
    end)
    traitBtns[tName]=b
end

-- Result display
local resultFrame=Fr({Size=UDim2.new(1,0,0,42),BackgroundColor3=Color3.fromRGB(0,30,80),LayoutOrder=no()},scCalc)
Cr(8,resultFrame); Sk(CL.acc,1.5,resultFrame)
calcResultLbl=Lb({Size=UDim2.new(1,0,1,0),Text="💰 30 Shillings",TextSize=15,Font=Enum.Font.GothamBold,TextColor3=CL.accB},resultFrame)

ActRow("🧮","Hitung Sekarang","Update hasil kalkulasi",scCalc,no(),function()
    local val=CalcCropValue(selectedPlant,selectedMuts,selectedTrait)
    calcResultLbl.Text="💰 "..FormatNum(val).." Shillings"
    Notify("🧮 "..selectedPlant.." = "..FormatNum(val).." Shillings","ok")
end)

-- ═══════════════════════════════════════════════
-- TAB 5: UTIL
-- ═══════════════════════════════════════════════
o=0
SecL("⚡ Player", scUtil, no())
TglRow("⚡","Speed Boost","Gerak lebih cepat di garden",scUtil,no(),function(on) SetSpeedBoost(on) end)
SldRow("🏃","Walk Speed",scUtil,no(),16,80,24,function(v) Config.WalkSpeed=v; ApplySpeed() end)
TglRow("🛡","Anti-AFK","Cegah kick karena diam",scUtil,no(),function(on) SetAntiAFK(on) end)

SecL("📊 Live Info", scUtil, no())
local liveBox, liveLbl = InfoBox({"Loading..."},scUtil,no(),CL.bF)
liveBox.Size = UDim2.new(1,0,0,78)

RunService.Heartbeat:Connect(function()
    local hrp=HRP(); local h=Hum()
    if hrp and h and liveLbl then
        liveLbl.Text=string.format(
            "👤 %s\n📍 Y: %.1f\n❤ HP: %.0f\n🌐 %d players di server\n🌤 Weather: %s",
            lp.Name, hrp.Position.Y, math.min(h.Health,9999),
            #Players:GetPlayers(), Config.CurrentWeather
        )
    end
end)

SecL("🔧 Aksi", scUtil, no())
ActRow("🔄","Reset Karakter","Respawn sekarang",scUtil,no(),function() lp:LoadCharacter(); Notify("Respawn!","info") end)
ActRow("🛑","Stop Semua Fitur","Matikan semua sekaligus",scUtil,no(),function()
    FullAutoMode(false)
    SetESP_Crops(false); SetESP_NPCs(false); SetESP_Players(false)
    SetAntiAFK(false); SetSpeedBoost(false)
    ClearESP(); RemAll()
    for k in pairs(Enabled) do Enabled[k]=false end
    Notify("🛑 Semua fitur OFF","warn")
end, Color3.fromRGB(150,40,40))
ActRow("📋","Copy Username","Salin nama ke clipboard",scUtil,no(),function()
    pcall(function() setclipboard(lp.Name) end)
    Notify("📋 "..lp.Name.." disalin","ok")
end)

SecL("💡 Panduan Cepat", scUtil, no())
local _, guideLbl = InfoBox({
    "1. TAB AUTO → aktif FULL AUTO MODE",
    "2. FULL AUTO = harvest+sell+buy+air",
    "3. TAB FARM → TP ke NPC manual",
    "4. TAB ESP  → lihat crop & NPC",
    "5. TAB CALC → hitung nilai mutasi",
    "6. Auto Sell jual ke Steve otomatis",
    "7. Lush Wait = tunggu 3x nilai dulu",
    "8. Shop Sniper = auto beli seed langka",
}, scUtil, no(), Color3.fromRGB(0,35,70))

-- ── ENTRANCE ANIMATION ──────────────────────────
W.Position=UDim2.new(0.5,-152,1.5,0)
W.BackgroundTransparency=1
TweenService:Create(W,TweenInfo.new(0.5,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{
    Position=UDim2.new(0.5,-152,0.5,-215),
    BackgroundTransparency=0,
}):Play()

task.delay(0.5,function()
    Notify("🌱 VOID HUB v4.0 - Garden Horizons loaded!","ok")
    task.wait(0.6)
    Notify("Aktifkan FULL AUTO MODE di tab AUTO ⚡","info")
end)

-- ═══════════════════════════════════════════════
-- END — VOID HUB v4.0 Garden Horizons Edition
-- ═══════════════════════════════════════════════
