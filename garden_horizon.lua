-- VOID HUB v4.1 | Garden Horizons | Fixed All Executor
-- Oleh: Kita Berdua

-- ══════════════════════════════════════════
-- SERVICES
-- ══════════════════════════════════════════
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local RS               = game:GetService("ReplicatedStorage")

local lp = Players.LocalPlayer
local function Char() return lp.Character end
local function HRP()  local c = Char() if not c then return nil end return c:FindFirstChild("HumanoidRootPart") end
local function Hum()  local c = Char() if not c then return nil end return c:FindFirstChildOfClass("Humanoid") end

-- ══════════════════════════════════════════
-- SAFE GUI PARENT (fix executor mobile)
-- ══════════════════════════════════════════
local guiParent
if syn and syn.protect_gui then
    local sg = Instance.new("ScreenGui")
    syn.protect_gui(sg)
    sg.Parent = game.CoreGui
    guiParent = sg
else
    local ok, cg = pcall(function() return game:GetService("CoreGui") end)
    if ok and cg then
        local sg = Instance.new("ScreenGui")
        sg.Name = "VoidHubV41"
        sg.ResetOnSpawn = false
        sg.DisplayOrder = 999
        pcall(function() sg.Parent = cg end)
        if sg.Parent ~= cg then
            sg.Parent = lp.PlayerGui
        end
        guiParent = sg
    else
        local sg = Instance.new("ScreenGui")
        sg.Name = "VoidHubV41"
        sg.ResetOnSpawn = false
        sg.DisplayOrder = 999
        sg.Parent = lp.PlayerGui
        guiParent = sg
    end
end
guiParent.ResetOnSpawn = false

-- Notif GUI (terpisah)
local notifParent
local ok2 = pcall(function()
    notifParent = Instance.new("ScreenGui")
    notifParent.Name = "VHN41"
    notifParent.ResetOnSpawn = false
    notifParent.DisplayOrder = 9999
    notifParent.Parent = game:GetService("CoreGui")
end)
if not ok2 or not notifParent then
    notifParent = Instance.new("ScreenGui")
    notifParent.Name = "VHN41"
    notifParent.ResetOnSpawn = false
    notifParent.DisplayOrder = 9999
    notifParent.Parent = lp.PlayerGui
end

-- ══════════════════════════════════════════
-- GARDEN HORIZONS DATA
-- ══════════════════════════════════════════
local MUTATIONS = {
    Foggy=1.5, Soaked=1.5, Chilled=1.5, Flooded=1.5,
    Tidal=2.0, Silver=2.0, Snowy=2.0, Sandy=2.5,
    Frostbit=3.5, Mossy=3.5, Shocked=4.5, Muddy=4.5,
    Starstruck=6.5, Nova=6.5, Galactic=5.0,
    Meteoric=10.0, Party=11.5,
}
local TRAITS = { Unripe=1.0, Ripened=2.0, Lush=3.0 }
local PRICES = {
    Carrot=30, Corn=80, Dandelion=50, Sunflower=60,
    Bellpepper=180, Onion=250, Strawberry=600,
    Mushroom=1000, Goldenberry=800,
    Beetroot=2000, Tomato=3500, Apple=6000, Rose=8000,
    Banana=25000, Plum=50000, Cherry=120000,
    Dawnfruit=200000, Cabbage=300000,
}
local SNIPER_LIST = {"Banana","Plum","Cherry","Cabbage","Dawnfruit","Rose"}
local WEATHER_MUTS = {
    Sunny={}, Rain={"Soaked","Flooded"}, Fog={"Foggy"},
    Storm={"Shocked","Flooded"}, Snow={"Snowy","Chilled","Frostbit"},
    Sand={"Sandy","Muddy"}, Star={"Starstruck","Nova"},
    Meteor={"Meteoric","Galactic"}, Tidal={"Tidal","Soaked"},
    Party={"Party"}, Mossy={"Mossy"},
}

-- ══════════════════════════════════════════
-- STATE
-- ══════════════════════════════════════════
local E = {
    AutoHarvest=false, AutoSell=false, AutoBuySeeds=false,
    AutoWater=false, ShopSniper=false, AutoQuest=false,
    MutAlert=false, WeatherAlert=false, LushWait=false,
    AntiAFK=false, ESPCrop=false, ESPNpc=false, ESPPlay=false,
    SpeedBoost=false, AutoFavorite=false,
}
local CFG = {
    WalkSpeed=24, SellDelay=0.5, TargetSeed="Carrot",
    MinMutMult=3.5, CurrentWeather="Sunny",
    HarvestCount=0, SeedsBought=0, ShillingsEst=0,
    SessionStart=os.clock(), LastShopCheck=0,
}
local CONNS = {}
local function AC(k,v) if CONNS[k] then pcall(function() CONNS[k]:Disconnect() end) end CONNS[k]=v end
local function DC(k)   if CONNS[k] then pcall(function() CONNS[k]:Disconnect() end) end CONNS[k]=nil end

-- ══════════════════════════════════════════
-- UTILS
-- ══════════════════════════════════════════
local function FmtNum(n)
    if n>=1e9 then return string.format("%.1fb",n/1e9)
    elseif n>=1e6 then return string.format("%.1fm",n/1e6)
    elseif n>=1e3 then return string.format("%.1fk",n/1e3)
    else return tostring(math.floor(n)) end
end

local function SafeTP(pos)
    local h = HRP()
    if h and pos then
        pcall(function() h.CFrame = CFrame.new(pos + Vector3.new(0,3,0)) end)
    end
end

local function FireRE(name, ...)
    local args = {...}
    local re = RS:FindFirstChild(name,true)
    if re and re:IsA("RemoteEvent") then
        pcall(function() re:FireServer(table.unpack(args)) end)
        return true
    end
    return false
end

local function TryPrompt(keyword)
    for _, o in ipairs(workspace:GetDescendants()) do
        if o:IsA("ProximityPrompt") then
            local n = o.Name:lower()
            if n:find(keyword:lower()) then
                pcall(function() fireproximityprompt(o) end)
            end
        end
    end
end

local function FindNPCPos(name)
    for _, o in ipairs(workspace:GetDescendants()) do
        if o.Name:lower():find(name:lower()) then
            if o:IsA("Model") then
                local h2 = o:FindFirstChild("HumanoidRootPart")
                    or o:FindFirstChildWhichIsA("BasePart")
                if h2 then return h2.Position end
            elseif o:IsA("BasePart") then
                return o.Position
            end
        end
    end
    return nil
end

local function CalcValue(plant, muts, trait)
    local base  = PRICES[plant] or 30
    local mult  = 1.0
    for _, m in ipairs(muts or {}) do
        mult = mult + (MUTATIONS[m] or 0)
    end
    return math.floor(base * mult * (TRAITS[trait] or 1.0))
end

-- ══════════════════════════════════════════
-- NOTIFICATION
-- ══════════════════════════════════════════
local nList = {}
local nColors = {
    ok=Color3.fromRGB(0,200,110), info=Color3.fromRGB(0,130,255),
    warn=Color3.fromRGB(255,160,0), err=Color3.fromRGB(255,55,55)
}

local function Notify(msg, t)
    t = t or "info"
    local col = nColors[t] or nColors.info
    -- push existing down
    for _, f in ipairs(nList) do
        TweenService:Create(f, TweenInfo.new(0.2), {
            Position = f.Position + UDim2.new(0,0,0,42)
        }):Play()
    end
    local f = Instance.new("Frame", notifParent)
    f.Size = UDim2.new(0,220,0,34)
    f.Position = UDim2.new(1,-230,0,-50)
    f.BackgroundColor3 = Color3.fromRGB(7,9,18)
    f.BorderSizePixel = 0
    local uc = Instance.new("UICorner",f); uc.CornerRadius = UDim.new(0,7)
    local bar = Instance.new("Frame",f)
    bar.Size = UDim2.new(0,3,1,0); bar.BackgroundColor3 = col; bar.BorderSizePixel = 0
    local ubc = Instance.new("UICorner",bar); ubc.CornerRadius = UDim.new(0,3)
    local lbl = Instance.new("TextLabel",f)
    lbl.Size = UDim2.new(1,-10,1,0); lbl.Position = UDim2.new(0,8,0,0)
    lbl.BackgroundTransparency = 1; lbl.Text = msg; lbl.TextSize = 11
    lbl.Font = Enum.Font.GothamSemibold
    lbl.TextColor3 = Color3.fromRGB(210,225,255)
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextTruncate = Enum.TextTruncate.AtEnd
    local sk = Instance.new("UIStroke",f); sk.Color = col; sk.Thickness = 1; sk.Transparency = 0.5
    table.insert(nList, 1, f)
    TweenService:Create(f, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
        Position = UDim2.new(1,-230,0,12)
    }):Play()
    task.delay(3, function()
        TweenService:Create(f, TweenInfo.new(0.2), {
            Position = UDim2.new(1,10,0,f.Position.Y.Offset)
        }):Play()
        task.delay(0.25, function()
            local idx = table.find(nList,f)
            if idx then table.remove(nList,idx) end
            pcall(function() f:Destroy() end)
        end)
    end)
end

-- ══════════════════════════════════════════
-- FEATURES
-- ══════════════════════════════════════════

-- AUTO HARVEST
local function SetAutoHarvest(on)
    E.AutoHarvest = on
    if not on then DC("harvest"); return end
    AC("harvest", RunService.Heartbeat:Connect(function()
        local hrp = HRP()
        if not hrp then return end
        FireRE("Harvest"); FireRE("HarvestCrop"); FireRE("PickCrop")
        for _, o in ipairs(workspace:GetDescendants()) do
            if o:IsA("BasePart") then
                local n = o.Name:lower()
                if (n:find("lush") or n:find("ripe") or n:find("harvestable")) then
                    if (o.Position - hrp.Position).Magnitude < 35 then
                        local saved = hrp.CFrame
                        pcall(function() hrp.CFrame = CFrame.new(o.Position+Vector3.new(0,2,0)) end)
                        task.wait(0.05)
                        pcall(function() hrp.CFrame = saved end)
                        CFG.HarvestCount = CFG.HarvestCount + 1
                    end
                end
            end
        end
    end))
    Notify("🌾 Auto Harvest ON","ok")
end

-- AUTO SELL
local function SetAutoSell(on)
    E.AutoSell = on
    if not on then DC("sell"); Notify("Auto Sell OFF","warn"); return end
    AC("sell", task.spawn(function()
        while E.AutoSell do
            local stevePos = FindNPCPos("Steve") or FindNPCPos("Sell") or FindNPCPos("Seller")
            if stevePos then SafeTP(stevePos); task.wait(0.4) end
            FireRE("SellAll"); FireRE("Sell"); FireRE("SellCrops"); FireRE("BulkSell")
            TryPrompt("sell")
            CFG.ShillingsEst = CFG.ShillingsEst + 500
            task.wait(math.max(0.5, CFG.SellDelay))
        end
    end))
    Notify("💰 Auto Sell ON","ok")
end

-- AUTO BUY SEEDS
local function SetAutoBuy(on)
    E.AutoBuySeeds = on
    if not on then DC("buy"); Notify("Auto Buy OFF","warn"); return end
    AC("buy", task.spawn(function()
        while E.AutoBuySeeds do
            local billPos = FindNPCPos("Bill") or FindNPCPos("Seed") or FindNPCPos("Shop")
            if billPos then SafeTP(billPos); task.wait(0.4) end
            FireRE("BuySeed", CFG.TargetSeed)
            FireRE("PurchaseSeed", CFG.TargetSeed)
            FireRE("BuyItem", CFG.TargetSeed)
            TryPrompt("buy"); TryPrompt("seed")
            CFG.SeedsBought = CFG.SeedsBought + 1
            task.wait(6)
        end
    end))
    Notify("🌱 Auto Buy Seeds ON","ok")
end

-- AUTO WATER
local function SetAutoWater(on)
    E.AutoWater = on
    if not on then DC("water"); Notify("Auto Water OFF","warn"); return end
    AC("water", task.spawn(function()
        while E.AutoWater do
            FireRE("WaterAll"); FireRE("Water"); FireRE("WaterCrops")
            TryPrompt("water"); TryPrompt("sprinkler")
            task.wait(10)
        end
    end))
    Notify("💧 Auto Water ON","ok")
end

-- SHOP SNIPER
local function SetShopSniper(on)
    E.ShopSniper = on
    if not on then DC("sniper"); Notify("Shop Sniper OFF","warn"); return end
    AC("sniper", RunService.Heartbeat:Connect(function()
        local now = os.clock()
        if now - CFG.LastShopCheck < 1 then return end
        CFG.LastShopCheck = now
        for _, o in ipairs(workspace:GetDescendants()) do
            for _, target in ipairs(SNIPER_LIST) do
                if o.Name:lower():find(target:lower()) then
                    local bPos = FindNPCPos("Bill")
                    if bPos then SafeTP(bPos); task.wait(0.2) end
                    FireRE("BuySeed", target)
                    FireRE("PurchaseSeed", target)
                    TryPrompt("buy")
                    Notify("🎯 Sniper: Beli "..target,"ok")
                end
            end
        end
    end))
    Notify("🎯 Shop Sniper ON","ok")
end

-- AUTO WATER
local function SetLushWait(on)
    E.LushWait = on
    if not on then DC("lush"); Notify("Lush Wait OFF","warn"); return end
    AC("lush", RunService.Heartbeat:Connect(function()
        for _, o in ipairs(workspace:GetDescendants()) do
            local trait = o:GetAttribute("Trait") or o:GetAttribute("Stage") or ""
            local owner = o:GetAttribute("Owner") or o:GetAttribute("PlayerName") or ""
            if (trait == "Lush" or trait:lower():find("lush"))
            and (owner == lp.Name or owner == tostring(lp.UserId) or owner == "") then
                FireRE("SellCrop", o); FireRE("Sell", o)
                CFG.HarvestCount = CFG.HarvestCount + 1
                CFG.ShillingsEst = CFG.ShillingsEst + 1000
                Notify("💰 Lush dijual: "..o.Name,"ok")
            end
        end
    end))
    Notify("🌿 Lush Wait ON","ok")
end

-- AUTO FAVORITE
local function SetAutoFav(on)
    E.AutoFavorite = on
    if not on then DC("fav"); Notify("Auto Favorite OFF","warn"); return end
    AC("fav", RunService.Heartbeat:Connect(function()
        for _, o in ipairs(workspace:GetDescendants()) do
            local owner = o:GetAttribute("Owner") or ""
            if owner == lp.Name or owner == tostring(lp.UserId) then
                local totalMult = 0
                for mName, mVal in pairs(MUTATIONS) do
                    if o:GetAttribute(mName) then totalMult = totalMult + mVal end
                end
                if totalMult >= 6.0 then
                    FireRE("FavoriteCrop",o); FireRE("Favorite",o)
                    pcall(function() o:SetAttribute("Favorited",true) end)
                end
            end
        end
    end))
    Notify("⭐ Auto Favorite ON","ok")
end

-- SHOP SNIPER (auto quest)
local function SetAutoQuest(on)
    E.AutoQuest = on
    if not on then DC("quest"); Notify("Auto Quest OFF","warn"); return end
    AC("quest", task.spawn(function()
        while E.AutoQuest do
            local qPos = FindNPCPos("Quest") or FindNPCPos("Maya") or FindNPCPos("Board")
            if qPos then SafeTP(qPos); task.wait(0.4) end
            FireRE("ClaimQuest"); FireRE("CompleteQuest")
            FireRE("TurnInQuest"); FireRE("AcceptQuest")
            TryPrompt("quest"); TryPrompt("claim"); TryPrompt("daily")
            task.wait(30)
        end
    end))
    Notify("📋 Auto Quest ON","ok")
end

-- MUTATION ALERT
local function SetMutAlert(on)
    E.MutAlert = on
    if not on then DC("mutalert"); Notify("Mutation Alert OFF","warn"); return end
    AC("mutalert", RunService.Heartbeat:Connect(function()
        for _, o in ipairs(workspace:GetDescendants()) do
            for mName, mVal in pairs(MUTATIONS) do
                if o:GetAttribute(mName) and mVal >= CFG.MinMutMult then
                    local owner = o:GetAttribute("Owner") or ""
                    if owner == lp.Name or owner == "" then
                        Notify("✨ "..mName.." ("..mVal.."x) — "..o.Name,"ok")
                    end
                end
            end
        end
    end))
    Notify("✨ Mutation Alert ON","ok")
end

-- WEATHER ALERT
local function SetWeatherAlert(on)
    E.WeatherAlert = on
    if not on then DC("weather"); Notify("Weather Alert OFF","warn"); return end
    local lastW = ""
    AC("weather", RunService.Heartbeat:Connect(function()
        -- Scan untuk weather object
        for wName in pairs(WEATHER_MUTS) do
            for _, o in ipairs(workspace:GetDescendants()) do
                if o.Name:lower():find(wName:lower()) then
                    if wName ~= lastW then
                        lastW = wName
                        CFG.CurrentWeather = wName
                        local muts = WEATHER_MUTS[wName]
                        local mutStr = #muts > 0 and table.concat(muts,", ") or "None"
                        Notify("🌤 "..wName.." → "..mutStr,"info")
                    end
                    return
                end
            end
        end
    end))
    Notify("🌤 Weather Alert ON","ok")
end

-- ANTI AFK
local function SetAntiAFK(on)
    E.AntiAFK = on
    if not on then DC("afk"); Notify("Anti-AFK OFF","warn"); return end
    local ok3, vu = pcall(function() return game:GetService("VirtualUser") end)
    if ok3 and vu then
        AC("afk", lp.Idled:Connect(function()
            pcall(function()
                vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                task.wait(0.1)
                vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
            end)
        end))
    end
    Notify("🛡 Anti-AFK ON","ok")
end

-- SPEED
local function ApplySpeed()
    local h = Hum()
    if h then h.WalkSpeed = E.SpeedBoost and CFG.WalkSpeed or 16 end
end
local function SetSpeed(on)
    E.SpeedBoost = on; ApplySpeed()
    Notify(on and ("⚡ Speed "..CFG.WalkSpeed) or "Speed OFF", on and "ok" or "warn")
end

-- ESP
local espObjs = {}
local function ClearESP()
    for _, v in ipairs(espObjs) do pcall(function() v:Destroy() end) end
    espObjs = {}
end
local function AddHL(adornee, col)
    local h = Instance.new("SelectionBox")
    h.Adornee = adornee
    h.Color3 = col
    h.LineThickness = 0.04
    h.SurfaceTransparency = 0.88
    h.SurfaceColor3 = col
    pcall(function() h.Parent = game:GetService("CoreGui") end)
    if not h.Parent then h.Parent = guiParent end
    table.insert(espObjs, h)
end
local function RefreshESP()
    ClearESP()
    if E.ESPCrop then
        for _, o in ipairs(workspace:GetDescendants()) do
            if o:IsA("BasePart") then
                local n = o.Name:lower()
                if n:find("crop") or n:find("fruit") or n:find("lush") or n:find("ripe") then
                    local trait = o:GetAttribute("Trait") or ""
                    local col = (trait=="Lush") and Color3.fromRGB(0,255,100)
                             or (trait=="Ripened") and Color3.fromRGB(255,220,0)
                             or Color3.fromRGB(0,130,255)
                    AddHL(o, col)
                end
            end
        end
    end
    if E.ESPNpc then
        for _, name in ipairs({"Bill","Molly","Steve","Maya","Quest"}) do
            local pos = FindNPCPos(name)
            if pos then
                for _, o in ipairs(workspace:GetDescendants()) do
                    if o.Name:lower():find(name:lower()) and o:IsA("Model") then
                        AddHL(o, Color3.fromRGB(255,180,0)); break
                    end
                end
            end
        end
    end
    if E.ESPPlay then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= lp and p.Character then
                AddHL(p.Character, Color3.fromRGB(0,160,255))
            end
        end
    end
end

-- FULL AUTO
local function FullAuto(on)
    SetAutoHarvest(on); SetAutoSell(on); SetAutoBuy(on)
    SetAutoWater(on); SetAntiAFK(on); SetLushWait(on)
    Notify(on and "🚀 FULL AUTO ON!" or "🛑 Full Auto OFF", on and "ok" or "warn")
end

-- RESPAWN HANDLER
lp.CharacterAdded:Connect(function()
    task.wait(0.6)
    if E.SpeedBoost then ApplySpeed() end
end)

-- ══════════════════════════════════════════════════
--  U I   B U I L D E R
-- ══════════════════════════════════════════════════

-- Warna
local C = {
    bg=Color3.fromRGB(6,8,16), panel=Color3.fromRGB(10,13,24),
    row=Color3.fromRGB(13,17,30), rowH=Color3.fromRGB(17,22,40),
    acc=Color3.fromRGB(0,120,255), accB=Color3.fromRGB(35,150,255),
    accD=Color3.fromRGB(0,60,165), border=Color3.fromRGB(0,70,175),
    bF=Color3.fromRGB(16,24,50), txt=Color3.fromRGB(210,225,255),
    muted=Color3.fromRGB(70,100,155), dim=Color3.fromRGB(30,50,90),
    ok=Color3.fromRGB(0,200,110), warn=Color3.fromRGB(255,160,0),
    danger=Color3.fromRGB(255,55,55), gold=Color3.fromRGB(255,200,40),
    green=Color3.fromRGB(60,210,100),
}

-- Shorthand builders
local function Fr(props, parent)
    local f = Instance.new("Frame"); f.BorderSizePixel = 0
    for k,v in pairs(props) do pcall(function() f[k]=v end) end
    if parent then f.Parent = parent end; return f
end
local function Lb(props, parent)
    local l = Instance.new("TextLabel"); l.BackgroundTransparency=1; l.Font=Enum.Font.GothamSemibold
    for k,v in pairs(props) do pcall(function() l[k]=v end) end
    if parent then l.Parent = parent end; return l
end
local function Bt(props, parent)
    local b = Instance.new("TextButton"); b.BorderSizePixel=0; b.Font=Enum.Font.GothamBold
    for k,v in pairs(props) do pcall(function() b[k]=v end) end
    if parent then b.Parent = parent end; return b
end
local function Cr(r,p) local c=Instance.new("UICorner",p); c.CornerRadius=UDim.new(0,r) end
local function Sk(col,th,p) local s=Instance.new("UIStroke",p); s.Color=col; s.Thickness=th; return s end
local function Gd(c1,c2,rot,p)
    local g=Instance.new("UIGradient",p)
    g.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,c1),ColorSequenceKeypoint.new(1,c2)})
    g.Rotation=rot
end

-- ── MAIN WINDOW ──────────────────────────────
local W = Fr({
    Size=UDim2.new(0,305,0,430),
    Position=UDim2.new(0.5,-152,0.5,-215),
    BackgroundColor3=C.bg, Active=true, Draggable=true,
}, guiParent)
Cr(12,W); Sk(C.border,1.5,W)
Gd(Color3.fromRGB(7,10,22),Color3.fromRGB(4,6,14),150,W)

-- ── TITLE BAR ────────────────────────────────
local TB = Fr({Size=UDim2.new(1,0,0,42),BackgroundColor3=C.accD,ZIndex=3},W)
Cr(12,TB)
Fr({Size=UDim2.new(1,0,0.5,0),Position=UDim2.new(0,0,0.5,0),BackgroundColor3=C.accD,BorderSizePixel=0,ZIndex=2},TB)
Gd(Color3.fromRGB(0,105,235),Color3.fromRGB(0,48,145),120,TB)

local logo=Fr({Size=UDim2.new(0,28,0,28),Position=UDim2.new(0,8,0.5,-14),BackgroundColor3=C.acc,ZIndex=4},TB)
Cr(7,logo); Gd(C.accB,C.accD,135,logo)
Lb({Size=UDim2.new(1,0,1,0),Text="V",TextSize=16,Font=Enum.Font.GothamBold,TextColor3=Color3.fromRGB(255,255,255),ZIndex=5},logo)

Lb({Size=UDim2.new(0,155,0,18),Position=UDim2.new(0,42,0,4),Text="VOID HUB",TextSize=14,Font=Enum.Font.GothamBold,TextColor3=Color3.fromRGB(255,255,255),TextXAlignment=Enum.TextXAlignment.Left,ZIndex=4},TB)
Lb({Size=UDim2.new(0,175,0,12),Position=UDim2.new(0,42,0,23),Text="v4.1  •  Garden Horizons",TextSize=9,Font=Enum.Font.Gotham,TextColor3=Color3.fromRGB(100,165,255),TextXAlignment=Enum.TextXAlignment.Left,ZIndex=4},TB)

local BClose=Bt({Size=UDim2.new(0,24,0,24),Position=UDim2.new(1,-32,0.5,-12),BackgroundColor3=C.danger,Text="x",TextSize=12,TextColor3=Color3.fromRGB(255,255,255),ZIndex=5},TB); Cr(5,BClose)
local BMin=Bt({Size=UDim2.new(0,24,0,24),Position=UDim2.new(1,-60,0.5,-12),BackgroundColor3=C.warn,Text="-",TextSize=16,TextColor3=Color3.fromRGB(255,255,255),ZIndex=5},TB); Cr(5,BMin)

-- ── BODY ─────────────────────────────────────
local Body = Fr({Size=UDim2.new(1,0,1,-42),Position=UDim2.new(0,0,0,42),BackgroundTransparency=1},W)

BClose.MouseButton1Click:Connect(function()
    TweenService:Create(W,TweenInfo.new(0.25,Enum.EasingStyle.Quad,Enum.EasingDirection.In),
        {Size=UDim2.new(0,305,0,0),Position=W.Position+UDim2.new(0,0,0,215)}):Play()
    task.delay(0.3,function()
        pcall(function() guiParent:Destroy() end)
        pcall(function() notifParent:Destroy() end)
    end)
end)

local mini=false
BMin.MouseButton1Click:Connect(function()
    mini=not mini
    Body.Visible=not mini
    TweenService:Create(W,TweenInfo.new(0.2),
        {Size=mini and UDim2.new(0,305,0,42) or UDim2.new(0,305,0,430)}):Play()
end)

-- ── 5-TAB BAR ────────────────────────────────
local TabBar=Fr({Size=UDim2.new(1,-16,0,26),Position=UDim2.new(0,8,0,6),BackgroundColor3=C.panel},Body)
Cr(6,TabBar); Sk(C.bF,1,TabBar)
local tLL=Instance.new("UIListLayout",TabBar); tLL.FillDirection=Enum.FillDirection.Horizontal
tLL.SortOrder=Enum.SortOrder.LayoutOrder; tLL.Padding=UDim.new(0,2)
local tPad=Instance.new("UIPadding",TabBar)
tPad.PaddingLeft=UDim.new(0,2); tPad.PaddingRight=UDim.new(0,2)
tPad.PaddingTop=UDim.new(0,2); tPad.PaddingBottom=UDim.new(0,2)

-- Scroll wrap
local SWrap=Fr({Size=UDim2.new(1,-16,0,362),Position=UDim2.new(0,8,0,38),BackgroundTransparency=1},Body)

-- Status bar
local StBar=Fr({Size=UDim2.new(1,-16,0,18),Position=UDim2.new(0,8,1,-22),BackgroundColor3=C.panel},Body)
Cr(5,StBar); Sk(C.bF,1,StBar)
local sDot=Fr({Size=UDim2.new(0,6,0,6),Position=UDim2.new(0,7,0.5,-3),BackgroundColor3=C.ok},StBar); Cr(3,sDot)
Lb({Size=UDim2.new(0.55,0,1,0),Position=UDim2.new(0,18,0,0),Text="VOID HUB AKTIF",TextSize=9,Font=Enum.Font.GothamBold,TextColor3=C.ok,TextXAlignment=Enum.TextXAlignment.Left},StBar)
local stR=Lb({Size=UDim2.new(0.4,-4,1,0),Position=UDim2.new(0.58,0,0,0),Text="0 aktif",TextSize=9,TextColor3=C.dim,TextXAlignment=Enum.TextXAlignment.Right},StBar)
local sp=Instance.new("UIPadding",StBar); sp.PaddingRight=UDim.new(0,6)

-- dot blink
task.spawn(function()
    while guiParent and guiParent.Parent do
        TweenService:Create(sDot,TweenInfo.new(1),{BackgroundTransparency=0.5}):Play(); task.wait(1)
        TweenService:Create(sDot,TweenInfo.new(1),{BackgroundTransparency=0}):Play(); task.wait(1)
    end
end)

-- feature counter
local featN=0
local function UpdFeat(d) featN=math.max(0,featN+d); stR.Text=featN.." aktif" end

-- ── TAB SYSTEM ───────────────────────────────
local tabData={}
local function NewTab(name, icon, order)
    local btn=Bt({Size=UDim2.new(0.2,-2,1,0),BackgroundColor3=C.panel,Text=icon,TextSize=10,TextColor3=C.muted,LayoutOrder=order,ZIndex=4,Font=Enum.Font.GothamBold},TabBar)
    Cr(4,btn)
    local panel=Fr({Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Visible=false,ZIndex=2},SWrap)
    local ps=Instance.new("ScrollingFrame",panel)
    ps.Size=UDim2.new(1,0,1,0); ps.BackgroundTransparency=1; ps.BorderSizePixel=0
    ps.ScrollBarThickness=2; ps.ScrollBarImageColor3=C.acc
    ps.CanvasSize=UDim2.new(0,0,0,0); ps.AutomaticCanvasSize=Enum.AutomaticSize.Y
    local pl=Instance.new("UIListLayout",ps); pl.Padding=UDim.new(0,4); pl.SortOrder=Enum.SortOrder.LayoutOrder
    local pp=Instance.new("UIPadding",ps); pp.PaddingBottom=UDim.new(0,4)
    tabData[name]={btn=btn,panel=panel,scroll=ps}
    btn.MouseButton1Click:Connect(function()
        for n,d in pairs(tabData) do
            local a=(n==name); d.panel.Visible=a
            TweenService:Create(d.btn,TweenInfo.new(0.15),{
                BackgroundColor3=a and C.acc or C.panel,
                TextColor3=a and Color3.fromRGB(255,255,255) or C.muted
            }):Play()
        end
    end)
    return ps
end

local sAuto = NewTab("AUTO","🌾",1)
local sFarm = NewTab("FARM","🪙",2)
local sESP  = NewTab("ESP","👁",3)
local sCalc = NewTab("CALC","🧮",4)
local sUtil = NewTab("UTIL","⚙",5)

-- Activate first tab
tabData["AUTO"].panel.Visible=true
tabData["AUTO"].btn.BackgroundColor3=C.acc
tabData["AUTO"].btn.TextColor3=Color3.fromRGB(255,255,255)

-- ── ROW BUILDERS ─────────────────────────────

local function SecL(txt,pa,ord)
    local f=Fr({Size=UDim2.new(1,0,0,18),BackgroundTransparency=1,LayoutOrder=ord},pa)
    Lb({Size=UDim2.new(1,0,1,0),Text="  "..txt:upper(),TextSize=9,Font=Enum.Font.GothamBold,TextColor3=C.acc,TextXAlignment=Enum.TextXAlignment.Left},f)
    local ln=Fr({Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,-1),BackgroundColor3=C.border},f); ln.BackgroundTransparency=0.6
end

local function TglRow(icon,label,desc,pa,ord,cb,aCol)
    aCol = aCol or C.acc
    local on=false
    local row=Fr({Size=UDim2.new(1,0,0,44),BackgroundColor3=C.row,LayoutOrder=ord},pa); Cr(7,row)
    local sk=Sk(C.bF,1,row)
    local ab=Fr({Size=UDim2.new(0,3,0,26),Position=UDim2.new(0,0,0.5,-13),BackgroundColor3=aCol},row); Cr(2,ab); ab.BackgroundTransparency=1
    Lb({Size=UDim2.new(0,28,1,0),Position=UDim2.new(0,7,0,0),Text=icon,TextSize=16,TextColor3=C.dim,ZIndex=3},row)
    local mL=Lb({Size=UDim2.new(1,-85,0,20),Position=UDim2.new(0,37,0,4),Text=label,TextSize=12,Font=Enum.Font.GothamBold,TextColor3=C.muted,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=3},row)
    Lb({Size=UDim2.new(1,-85,0,14),Position=UDim2.new(0,37,0,24),Text=desc,TextSize=9,TextColor3=C.dim,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=3},row)
    local pb=Fr({Size=UDim2.new(0,38,0,20),Position=UDim2.new(1,-46,0.5,-10),BackgroundColor3=Color3.fromRGB(16,20,38)},row); Cr(10,pb); Sk(C.bF,1,pb)
    local kn=Fr({Size=UDim2.new(0,14,0,14),Position=UDim2.new(0,3,0.5,-7),BackgroundColor3=C.muted},pb); Cr(7,kn)
    local hit=Bt({Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",ZIndex=5},row)
    local function upd()
        TweenService:Create(pb,TweenInfo.new(0.18),{BackgroundColor3=on and C.accD or Color3.fromRGB(16,20,38)}):Play()
        TweenService:Create(kn,TweenInfo.new(0.18),{Position=on and UDim2.new(0,21,0.5,-7) or UDim2.new(0,3,0.5,-7),BackgroundColor3=on and Color3.fromRGB(255,255,255) or C.muted}):Play()
        TweenService:Create(sk,TweenInfo.new(0.18),{Color=on and aCol or C.bF}):Play()
        TweenService:Create(ab,TweenInfo.new(0.18),{BackgroundTransparency=on and 0 or 1}):Play()
        TweenService:Create(mL,TweenInfo.new(0.18),{TextColor3=on and C.txt or C.muted}):Play()
        TweenService:Create(row,TweenInfo.new(0.18),{BackgroundColor3=on and C.rowH or C.row}):Play()
    end
    hit.MouseButton1Click:Connect(function()
        on=not on; upd(); UpdFeat(on and 1 or -1); cb(on)
    end)
end

local function ActRow(icon,label,desc,pa,ord,cb,aCol)
    aCol = aCol or C.accD
    local row=Fr({Size=UDim2.new(1,0,0,40),BackgroundColor3=C.row,LayoutOrder=ord},pa); Cr(7,row)
    local sk=Sk(C.bF,1,row)
    Lb({Size=UDim2.new(0,26,1,0),Position=UDim2.new(0,7,0,0),Text=icon,TextSize=14,TextColor3=C.acc,ZIndex=3},row)
    Lb({Size=UDim2.new(1,-82,0,18),Position=UDim2.new(0,35,0,4),Text=label,TextSize=12,Font=Enum.Font.GothamBold,TextColor3=C.txt,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=3},row)
    Lb({Size=UDim2.new(1,-82,0,13),Position=UDim2.new(0,35,0,22),Text=desc,TextSize=9,TextColor3=C.dim,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=3},row)
    local rb=Bt({Size=UDim2.new(0,50,0,24),Position=UDim2.new(1,-58,0.5,-12),BackgroundColor3=aCol,Text="RUN",TextSize=10,TextColor3=Color3.fromRGB(255,255,255),ZIndex=5},row); Cr(5,rb)
    Gd(C.accB,aCol,90,rb)
    rb.MouseButton1Click:Connect(function()
        TweenService:Create(rb,TweenInfo.new(0.1),{BackgroundTransparency=0.5}):Play()
        task.delay(0.15,function() TweenService:Create(rb,TweenInfo.new(0.1),{BackgroundTransparency=0}):Play() end)
        cb()
    end)
    row.MouseEnter:Connect(function() TweenService:Create(sk,TweenInfo.new(0.1),{Color=C.acc}):Play() end)
    row.MouseLeave:Connect(function() TweenService:Create(sk,TweenInfo.new(0.1),{Color=C.bF}):Play() end)
end

local function SldRow(icon,label,pa,ord,mn,mx,def,cb)
    local row=Fr({Size=UDim2.new(1,0,0,50),BackgroundColor3=C.row,LayoutOrder=ord},pa); Cr(7,row); Sk(C.bF,1,row)
    Lb({Size=UDim2.new(0,22,0,20),Position=UDim2.new(0,7,0,6),Text=icon,TextSize=13,TextColor3=C.acc},row)
    Lb({Size=UDim2.new(0.58,0,0,18),Position=UDim2.new(0,30,0,7),Text=label,TextSize=11,Font=Enum.Font.GothamBold,TextColor3=C.txt,TextXAlignment=Enum.TextXAlignment.Left},row)
    local vL=Lb({Size=UDim2.new(0.35,-4,0,18),Position=UDim2.new(0.65,0,0,7),Text=tostring(def),TextSize=12,Font=Enum.Font.GothamBold,TextColor3=C.accB,TextXAlignment=Enum.TextXAlignment.Right},row)
    local tr=Fr({Size=UDim2.new(1,-18,0,5),Position=UDim2.new(0,9,0,35),BackgroundColor3=Color3.fromRGB(16,22,44)},row); Cr(3,tr); Sk(C.bF,1,tr)
    local pct=(def-mn)/(mx-mn)
    local fi=Fr({Size=UDim2.new(pct,0,1,0),BackgroundColor3=C.acc},tr); Cr(3,fi); Gd(C.accB,C.acc,90,fi)
    local kn2=Fr({Size=UDim2.new(0,12,0,12),Position=UDim2.new(pct,-6,0.5,-6),BackgroundColor3=Color3.fromRGB(255,255,255),ZIndex=4},tr); Cr(6,kn2); Sk(C.acc,1.5,kn2)
    local drag=false
    kn2.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            drag=true
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            drag=false
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if drag and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
            local ap=tr.AbsolutePosition.X; local as2=tr.AbsoluteSize.X
            local r=math.clamp((i.Position.X-ap)/as2,0,1)
            local v=math.round(mn+r*(mx-mn))
            fi.Size=UDim2.new(r,0,1,0); kn2.Position=UDim2.new(r,-6,0.5,-6)
            vL.Text=tostring(v); cb(v)
        end
    end)
end

local function InfoBox(lines,pa,ord,col)
    col=col or C.bF
    local h2=#lines*14+12
    local row=Fr({Size=UDim2.new(1,0,0,h2),BackgroundColor3=C.row,LayoutOrder=ord},pa); Cr(7,row); Sk(col,1,row)
    local txt2=table.concat(lines,"\n")
    local lbl2=Lb({Size=UDim2.new(1,-14,1,0),Position=UDim2.new(0,7,0,0),Text=txt2,TextSize=10,Font=Enum.Font.Code or Enum.Font.Gotham,TextColor3=C.muted,TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true,LineHeight=1.5},row)
    return row, lbl2
end

-- ══════════════════════════════════════════════
-- TAB: AUTO
-- ══════════════════════════════════════════════
local o=0
local function no() o=o+1; return o end

SecL("Master Control",sAuto,no())
ActRow("⚡","FULL AUTO MODE","Aktifkan semua otomasi",sAuto,no(),function() FullAuto(true) end, Color3.fromRGB(0,130,75))
ActRow("🛑","STOP SEMUA","Hentikan semua otomasi",sAuto,no(),function() FullAuto(false) end, Color3.fromRGB(140,40,40))

SecL("Harvest & Sell",sAuto,no())
TglRow("🌾","Auto Harvest","Otomatis panen crop",sAuto,no(),function(on) SetAutoHarvest(on) end, C.green)
TglRow("💰","Auto Sell","Otomatis jual ke Steve",sAuto,no(),function(on) SetAutoSell(on) end, C.gold)
TglRow("🌿","Lush Wait & Sell","Jual hanya saat Lush (3x)",sAuto,no(),function(on) SetLushWait(on) end, C.green)
TglRow("⭐","Auto Favorite","Tandai crop mutasi tinggi",sAuto,no(),function(on) SetAutoFav(on) end, C.gold)
SldRow("⏱","Sell Delay (s)",sAuto,no(),0,5,0.5,function(v) CFG.SellDelay=v end)

SecL("Planting",sAuto,no())
TglRow("🪴","Auto Buy Seeds","Beli seed dari Bill otomatis",sAuto,no(),function(on) SetAutoBuy(on) end)
TglRow("💧","Auto Water","Siram tanaman otomatis",sAuto,no(),function(on) SetAutoWater(on) end)

SecL("Shop & Quest",sAuto,no())
TglRow("🎯","Shop Sniper","Beli seed langka saat restock",sAuto,no(),function(on) SetShopSniper(on) end, Color3.fromRGB(180,80,255))
TglRow("📋","Auto Quest","Claim quest harian/mingguan",sAuto,no(),function(on) SetAutoQuest(on) end)
TglRow("🔔","Weather Alert","Notif saat cuaca berubah",sAuto,no(),function(on) SetWeatherAlert(on) end)
TglRow("✨","Mutation Alert","Notif mutasi berharga",sAuto,no(),function(on) SetMutAlert(on) end, Color3.fromRGB(160,100,255))
SldRow("🎚","Min Mutasi",sAuto,no(),1,12,3.5,function(v) CFG.MinMutMult=v end)

-- ══════════════════════════════════════════════
-- TAB: FARM
-- ══════════════════════════════════════════════
o=0
SecL("Teleport ke NPC",sFarm,no())
ActRow("🌱","TP ke Bill (Seeds)","Beli benih",sFarm,no(),function() local p=FindNPCPos("Bill") or FindNPCPos("Seed") SafeTP(p) Notify("TP ke Bill","ok") end)
ActRow("🔧","TP ke Molly (Gear)","Beli alat",sFarm,no(),function() local p=FindNPCPos("Molly") or FindNPCPos("Gear") SafeTP(p) Notify("TP ke Molly","ok") end)
ActRow("💵","TP ke Steve (Sell)","Jual crop",sFarm,no(),function() local p=FindNPCPos("Steve") or FindNPCPos("Sell") SafeTP(p) Notify("TP ke Steve","ok") end)
ActRow("🧪","TP ke Maya (IGMA)","Quest NPC",sFarm,no(),function() local p=FindNPCPos("Maya") or FindNPCPos("IGMA") SafeTP(p) Notify("TP ke Maya","ok") end)
ActRow("📋","TP ke Quest Board","Ambil quest",sFarm,no(),function() local p=FindNPCPos("Quest") or FindNPCPos("Board") SafeTP(p) Notify("TP ke Quest","ok") end)

SecL("Quick Actions",sFarm,no())
ActRow("🔄","Siklus Penuh","Bill → Harvest → Steve",sFarm,no(),function()
    task.spawn(function()
        local billP=FindNPCPos("Bill"); if billP then SafeTP(billP) end; task.wait(0.5)
        FireRE("BuySeed",CFG.TargetSeed); task.wait(0.3)
        local steveP=FindNPCPos("Steve"); if steveP then SafeTP(steveP) end; task.wait(0.5)
        FireRE("SellAll"); TryPrompt("sell")
        Notify("🔄 Satu siklus selesai!","ok")
    end)
end, Color3.fromRGB(0,120,75))
ActRow("💎","Jual Semua Sekarang","Force sell semua crop",sFarm,no(),function()
    local p=FindNPCPos("Steve"); if p then SafeTP(p) end; task.wait(0.3)
    FireRE("SellAll"); FireRE("Sell"); TryPrompt("sell")
    Notify("💰 Force sell!","ok")
end, C.gold)

SecL("Statistik Sesi",sFarm,no())
local _,statsL=InfoBox({
    "Memuat...",
},sFarm,no(),C.bF)

-- Live stats
RunService.Heartbeat:Connect(function()
    if not statsL then return end
    local elapsed=os.clock()-CFG.SessionStart
    local m=math.floor(elapsed/60)
    local s=math.floor(elapsed%60)
    statsL.Text=string.format("Waktu: %02d:%02d  |  Harvest: %d\nShillings est: %s  |  Seeds: %d\nWeather: %s",
        m,s,CFG.HarvestCount,FmtNum(CFG.ShillingsEst),CFG.SeedsBought,CFG.CurrentWeather)
end)

SecL("Info Mutasi",sFarm,no())
InfoBox({
    "Rain  -> Soaked/Flooded (1.5x)",
    "Storm -> Shocked (4.5x)",
    "Sand  -> Sandy+Muddy (2.5/4.5x)",
    "Star  -> Starstruck (6.5x)",
    "Meteor-> Meteoric (10x)",
    "Party -> Party (11.5x) BEST!",
},sFarm,no(), Color3.fromRGB(0,40,110))

-- ══════════════════════════════════════════════
-- TAB: ESP
-- ══════════════════════════════════════════════
o=0
SecL("ESP Options",sESP,no())
TglRow("🌾","Crop ESP","Highlight tanaman (warna=matang)",sESP,no(),function(on) E.ESPCrop=on; RefreshESP() end, C.green)
TglRow("👴","NPC ESP","Highlight semua NPC",sESP,no(),function(on) E.ESPNpc=on; RefreshESP() end, C.gold)
TglRow("👤","Player ESP","Highlight player lain",sESP,no(),function(on) E.ESPPlay=on; RefreshESP() end)
ActRow("🔄","Refresh ESP","Update semua highlight",sESP,no(),function() RefreshESP(); Notify("ESP refreshed","ok") end)
ActRow("❌","Clear ESP","Hapus semua highlight",sESP,no(),function() ClearESP(); Notify("ESP cleared","warn") end)
InfoBox({
    "Hijau  = Lush (3x value)",
    "Kuning = Ripened (2x value)",
    "Biru   = Unripe (belum matang)",
    "Oranye = NPC",
},sESP,no(), Color3.fromRGB(0,40,80))

-- ══════════════════════════════════════════════
-- TAB: CALC
-- ══════════════════════════════════════════════
o=0
SecL("Mutation Calculator",sCalc,no())

local selPlant="Carrot"; local selMuts={}; local selTrait="Lush"
local calcLbl

-- Plant buttons
local plantGrid=Fr({Size=UDim2.new(1,0,0,72),BackgroundTransparency=1,LayoutOrder=no()},sCalc)
local pgL=Instance.new("UIGridLayout",plantGrid); pgL.CellSize=UDim2.new(0,66,0,22); pgL.CellPadding=UDim2.new(0,3,0,3)

local plantBtns2={}
local function mkPBtn(name)
    local b=Bt({BackgroundColor3=C.row,Text=name,TextSize=8,TextColor3=C.muted,ZIndex=3,Font=Enum.Font.GothamBold},plantGrid); Cr(4,b); Sk(C.bF,1,b)
    b.MouseButton1Click:Connect(function()
        selPlant=name
        for n2,btn2 in pairs(plantBtns2) do
            TweenService:Create(btn2,TweenInfo.new(0.1),{
                BackgroundColor3=n2==name and C.accD or C.row,
                TextColor3=n2==name and Color3.fromRGB(255,255,255) or C.muted
            }):Play()
        end
        if calcLbl then calcLbl.Text="💰 "..FmtNum(CalcValue(selPlant,selMuts,selTrait)).." Shillings" end
    end)
    plantBtns2[name]=b
end
for _,n2 in ipairs({"Carrot","Onion","Strawberry","Tomato","Apple","Rose","Banana","Cherry","Plum","Cabbage"}) do mkPBtn(n2) end

-- Mutation buttons
SecL("Pilih Mutasi",sCalc,no())
local mutGrid=Fr({Size=UDim2.new(1,0,0,96),BackgroundTransparency=1,LayoutOrder=no()},sCalc)
local mgL=Instance.new("UIGridLayout",mutGrid); mgL.CellSize=UDim2.new(0,88,0,22); mgL.CellPadding=UDim2.new(0,2,0,2)

for mName,mVal in pairs(MUTATIONS) do
    local b=Bt({BackgroundColor3=C.row,Text=mName.." "..mVal.."x",TextSize=8,TextColor3=C.muted,ZIndex=3,Font=Enum.Font.Gotham},mutGrid); Cr(4,b); Sk(C.bF,1,b)
    local sel=false
    b.MouseButton1Click:Connect(function()
        sel=not sel
        TweenService:Create(b,TweenInfo.new(0.1),{
            BackgroundColor3=sel and C.accD or C.row,
            TextColor3=sel and Color3.fromRGB(255,255,255) or C.muted
        }):Play()
        if sel then table.insert(selMuts,mName)
        else local i=table.find(selMuts,mName); if i then table.remove(selMuts,i) end end
        if calcLbl then calcLbl.Text="💰 "..FmtNum(CalcValue(selPlant,selMuts,selTrait)).." Shillings" end
    end)
end

-- Trait
SecL("Trait",sCalc,no())
local trGrid=Fr({Size=UDim2.new(1,0,0,26),BackgroundTransparency=1,LayoutOrder=no()},sCalc)
local tgL=Instance.new("UIListLayout",trGrid); tgL.FillDirection=Enum.FillDirection.Horizontal; tgL.Padding=UDim.new(0,3)

local trBtns={}
for _,tN in ipairs({"Unripe","Ripened","Lush"}) do
    local b=Bt({Size=UDim2.new(0.33,-2,1,0),BackgroundColor3=tN=="Lush" and C.accD or C.row,Text=tN,TextSize=10,TextColor3=tN=="Lush" and Color3.fromRGB(255,255,255) or C.muted,ZIndex=3},trGrid); Cr(4,b)
    b.MouseButton1Click:Connect(function()
        selTrait=tN
        for tn2,btn2 in pairs(trBtns) do
            TweenService:Create(btn2,TweenInfo.new(0.1),{
                BackgroundColor3=tn2==tN and C.accD or C.row,
                TextColor3=tn2==tN and Color3.fromRGB(255,255,255) or C.muted
            }):Play()
        end
        if calcLbl then calcLbl.Text="💰 "..FmtNum(CalcValue(selPlant,selMuts,selTrait)).." Shillings" end
    end)
    trBtns[tN]=b
end

-- Result
local resF=Fr({Size=UDim2.new(1,0,0,38),BackgroundColor3=Color3.fromRGB(0,28,75),LayoutOrder=no()},sCalc); Cr(8,resF); Sk(C.acc,1.5,resF)
calcLbl=Lb({Size=UDim2.new(1,0,1,0),Text="💰 90 Shillings",TextSize=14,Font=Enum.Font.GothamBold,TextColor3=C.accB},resF)
ActRow("🧮","Hitung Nilai Crop","Update kalkulasi",sCalc,no(),function()
    local v=CalcValue(selPlant,selMuts,selTrait)
    calcLbl.Text="💰 "..FmtNum(v).." Shillings"
    Notify("🧮 "..selPlant.." = "..FmtNum(v).." Shillings","ok")
end)

-- ══════════════════════════════════════════════
-- TAB: UTIL
-- ══════════════════════════════════════════════
o=0
SecL("Player",sUtil,no())
TglRow("⚡","Speed Boost","Gerak lebih cepat",sUtil,no(),function(on) SetSpeed(on) end)
SldRow("🏃","Walk Speed",sUtil,no(),16,80,24,function(v) CFG.WalkSpeed=v; ApplySpeed() end)
TglRow("🛡","Anti-AFK","Cegah kick karena diam",sUtil,no(),function(on) SetAntiAFK(on) end)

SecL("Live Info",sUtil,no())
local _,liveL=InfoBox({"Loading..."},sUtil,no(),C.bF)
RunService.Heartbeat:Connect(function()
    if not liveL then return end
    local hrp=HRP(); local h=Hum()
    if hrp and h then
        liveL.Text=string.format(
            "Player: %s\nY: %.1f  |  HP: %.0f\nSpeed: %.0f  |  Players: %d\nWeather: %s",
            lp.Name, hrp.Position.Y, math.min(h.Health,9999),
            h.WalkSpeed, #Players:GetPlayers(), CFG.CurrentWeather
        )
    end
end)

SecL("Aksi",sUtil,no())
ActRow("🔄","Reset Karakter","Respawn sekarang",sUtil,no(),function() lp:LoadCharacter(); Notify("Respawn!","info") end)
ActRow("🛑","Stop Semua Fitur","Matikan semuanya",sUtil,no(),function()
    FullAuto(false); ClearESP()
    for k in pairs(E) do E[k]=false end
    for k in pairs(CONNS) do DC(k) end
    ApplySpeed()
    Notify("🛑 Semua OFF","warn")
end, Color3.fromRGB(140,40,40))
ActRow("📋","Copy Username","Salin nama ke clipboard",sUtil,no(),function()
    pcall(function() setclipboard(lp.Name) end)
    Notify("📋 "..lp.Name.." disalin","ok")
end)

SecL("Panduan",sUtil,no())
InfoBox({
    "1. Tab AUTO  -> Full Auto Mode",
    "2. Tab FARM  -> TP ke NPC manual",
    "3. Tab ESP   -> Highlight crop/NPC",
    "4. Tab CALC  -> Hitung nilai mutasi",
    "5. Lush = 3x, Ripened = 2x value",
    "6. Party weather = mutasi terbaik!",
},sUtil,no(), Color3.fromRGB(0,32,65))

-- ── ENTRANCE ANIMATION ───────────────────────
W.Position=UDim2.new(0.5,-152,1.5,0)
W.BackgroundTransparency=1
TweenService:Create(W,TweenInfo.new(0.5,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{
    Position=UDim2.new(0.5,-152,0.5,-215),
    BackgroundTransparency=0,
}):Play()

task.delay(0.5, function()
    Notify("VOID HUB v4.1 loaded! Garden Horizons","ok")
    task.delay(0.8, function()
        Notify("Tab AUTO -> Full Auto Mode untuk mulai","info")
    end)
end)

-- ══════════════════════════════════════════════
-- END — VOID HUB v4.1
-- ══════════════════════════════════════════════
