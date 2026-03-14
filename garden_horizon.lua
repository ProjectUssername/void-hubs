-- VOID HUB v5.0 | Garden Horizons | Android Optimized
-- Anti-lag + Auto detect remotes + Fixed semua fitur

-- ══════════════════════════════════════════
-- SERVICES
-- ══════════════════════════════════════════
local Players   = game:GetService("Players")
local RunService= game:GetService("RunService")
local UIS       = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RS        = game:GetService("ReplicatedStorage")

local lp  = Players.LocalPlayer
local pg  = lp:WaitForChild("PlayerGui")

local function Char() return lp.Character end
local function HRP()
    local c = Char()
    return c and c:FindFirstChild("HumanoidRootPart")
end
local function Hum()
    local c = Char()
    return c and c:FindFirstChildOfClass("Humanoid")
end

-- ══════════════════════════════════════════
-- GUI PARENT (safe untuk semua executor)
-- ══════════════════════════════════════════
local function MakeGui(name, order)
    local sg = Instance.new("ScreenGui")
    sg.Name = name
    sg.ResetOnSpawn = false
    sg.DisplayOrder = order or 100
    sg.IgnoreGuiInset = true

    if syn and syn.protect_gui then
        syn.protect_gui(sg)
        sg.Parent = game.CoreGui
    elseif gethui then
        sg.Parent = gethui()
    else
        local ok = pcall(function() sg.Parent = game:GetService("CoreGui") end)
        if not ok then sg.Parent = pg end
    end
    return sg
end

local MainGui  = MakeGui("VoidHub5", 100)
local NotifGui = MakeGui("VoidNotif5", 999)

-- ══════════════════════════════════════════
-- REMOTE DETECTOR (scan sekali saat load)
-- ══════════════════════════════════════════
local Remotes = {
    -- akan diisi otomatis
    Harvest = nil, Sell = nil, BuySeed = nil,
    Water = nil, Quest = nil, Favorite = nil,
}

-- Keyword untuk tiap remote
local RemoteKeywords = {
    Harvest  = {"harvest","pick","collect","pluck","reap"},
    Sell     = {"sell","sellall","sellcrop","submit"},
    BuySeed  = {"buyseed","purchaseseed","buyitem","buy"},
    Water    = {"water","irrigate","sprinkle"},
    Quest    = {"quest","claim","turnin","complete","daily"},
    Favorite = {"favorite","favourite","fav","mark"},
}

local function ScanRemotes()
    local function scan(parent, depth)
        if depth > 5 then return end
        local ok, children = pcall(function() return parent:GetChildren() end)
        if not ok then return end
        for _, obj in ipairs(children) do
            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                local n = obj.Name:lower()
                for rName, keywords in pairs(RemoteKeywords) do
                    if not Remotes[rName] then
                        for _, kw in ipairs(keywords) do
                            if n:find(kw) then
                                Remotes[rName] = obj
                                break
                            end
                        end
                    end
                end
            end
            scan(obj, depth + 1)
        end
    end
    scan(RS, 1)
    -- juga scan game langsung
    for _, service in ipairs({RS, game:GetService("ReplicatedStorage"), game:GetService("Workspace")}) do
        pcall(function() scan(service, 1) end)
    end

    local found = 0
    for _, v in pairs(Remotes) do if v then found = found + 1 end end
    return found
end

local foundCount = ScanRemotes()

-- Fire remote safely
local function FR(remote, ...)
    if not remote then return false end
    local args = {...}
    if remote:IsA("RemoteEvent") then
        pcall(function() remote:FireServer(table.unpack(args)) end)
        return true
    elseif remote:IsA("RemoteFunction") then
        pcall(function() remote:InvokeServer(table.unpack(args)) end)
        return true
    end
    return false
end

-- Try ProximityPrompt
local function TryPP(keywords)
    for _, o in ipairs(workspace:GetDescendants()) do
        if o:IsA("ProximityPrompt") then
            local n = o.Name:lower()
            for _, kw in ipairs(keywords) do
                if n:find(kw) then
                    pcall(function() fireproximityprompt(o) end)
                end
            end
        end
    end
end

-- Try ClickDetector
local function TryCD(keywords)
    for _, o in ipairs(workspace:GetDescendants()) do
        if o:IsA("ClickDetector") then
            local p = o.Parent
            if p then
                local n = p.Name:lower()
                for _, kw in ipairs(keywords) do
                    if n:find(kw) then
                        pcall(function() fireclickdetector(o) end)
                    end
                end
            end
        end
    end
end

-- ══════════════════════════════════════════
-- NPC FINDER (cached, scan tiap 10 detik)
-- ══════════════════════════════════════════
local NpcCache = {}
local lastNpcScan = 0

local function FindNPC(keywords)
    local now = os.clock()
    -- pakai cache kalau masih fresh
    if now - lastNpcScan < 10 then
        for _, kw in ipairs(keywords) do
            if NpcCache[kw] then return NpcCache[kw] end
        end
    end

    -- scan workspace
    lastNpcScan = now
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") or obj:IsA("BasePart") then
            local n = obj.Name:lower()
            for _, kw in ipairs(keywords) do
                if n:find(kw) then
                    local pos
                    if obj:IsA("Model") then
                        local hrp2 = obj:FindFirstChild("HumanoidRootPart")
                            or obj:FindFirstChildWhichIsA("BasePart")
                        if hrp2 then pos = hrp2.Position end
                    else
                        pos = obj.Position
                    end
                    if pos then
                        NpcCache[kw] = pos
                        return pos
                    end
                end
            end
        end
    end
    return nil
end

local function TP(pos)
    if not pos then return end
    local h = HRP()
    if h then pcall(function() h.CFrame = CFrame.new(pos + Vector3.new(0, 4, 0)) end) end
end

-- ══════════════════════════════════════════
-- ANTI-LAG TIMER SYSTEM
-- Ganti Heartbeat dengan timer interval
-- ══════════════════════════════════════════
local Timers = {}  -- { name = {interval, lastRun, fn} }

local function AddTimer(name, interval, fn)
    Timers[name] = {interval=interval, lastRun=0, fn=fn}
end
local function RemTimer(name)
    Timers[name] = nil
end

-- Satu Heartbeat untuk semua timer (JAUH lebih hemat)
local masterConn
masterConn = RunService.Heartbeat:Connect(function()
    local now = os.clock()
    for name, t in pairs(Timers) do
        if now - t.lastRun >= t.interval then
            t.lastRun = now
            local ok, err = pcall(t.fn)
            -- kalau error, jangan crash
        end
    end
end)

-- ══════════════════════════════════════════
-- STATE
-- ══════════════════════════════════════════
local E = {
    AutoHarvest=false, AutoSell=false, AutoBuy=false,
    AutoWater=false, LushWait=false, ShopSniper=false,
    AutoQuest=false, MutAlert=false, WeatherAlert=false,
    ESPCrop=false, ESPNpc=false, ESPPlay=false,
    AntiAFK=false, Speed=false, AutoFav=false,
}
local CFG = {
    WalkSpeed=24, SellInterval=3, BuyInterval=8,
    WaterInterval=15, HarvestInterval=2,
    MinMut=3.5, TargetSeed="Carrot",
    Weather="Sunny", Harvest=0, Seeds=0, Est=0,
    Start=os.clock(),
}

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
local TRAITS = {Unripe=1.0, Ripened=2.0, Lush=3.0}
local PRICES = {
    Carrot=30, Corn=80, Dandelion=50, Bellpepper=180,
    Onion=250, Strawberry=600, Mushroom=1000, Goldenberry=800,
    Beetroot=2000, Tomato=3500, Apple=6000, Rose=8000,
    Banana=25000, Plum=50000, Cherry=120000,
    Dawnfruit=200000, Cabbage=300000,
}
local SNIPER = {"Banana","Plum","Cherry","Cabbage","Dawnfruit","Rose","Apple"}

local function CalcVal(plant, muts, trait)
    local base = PRICES[plant] or 30
    local mult = 1.0
    for _, m in ipairs(muts or {}) do mult = mult + (MUTATIONS[m] or 0) end
    return math.floor(base * mult * (TRAITS[trait] or 1.0))
end

local function FmtN(n)
    if n >= 1e9 then return string.format("%.1fb",n/1e9)
    elseif n >= 1e6 then return string.format("%.1fm",n/1e6)
    elseif n >= 1e3 then return string.format("%.1fk",n/1e3)
    else return tostring(math.floor(n)) end
end

-- ══════════════════════════════════════════
-- FEATURES
-- ══════════════════════════════════════════

-- AUTO HARVEST
-- Interval 2 detik, bukan tiap frame
local function SetHarvest(on)
    E.AutoHarvest = on
    if not on then RemTimer("harvest"); return end
    AddTimer("harvest", CFG.HarvestInterval, function()
        -- Method 1: Remote
        FR(Remotes.Harvest)
        -- Method 2: ProximityPrompt
        TryPP({"harvest","pick","collect","pluck"})
        -- Method 3: Touch harvestable parts
        local hrp = HRP()
        if hrp then
            for _, o in ipairs(workspace:GetDescendants()) do
                if o:IsA("BasePart") then
                    local n = o.Name:lower()
                    if n:find("lush") or n:find("harvestable") or n:find("ripe") then
                        if (o.Position - hrp.Position).Magnitude < 40 then
                            pcall(function() hrp.CFrame = CFrame.new(o.Position + Vector3.new(0,2,0)) end)
                            CFG.Harvest = CFG.Harvest + 1
                        end
                    end
                end
            end
        end
    end)
end

-- AUTO SELL
-- Interval 3 detik
local function SetSell(on)
    E.AutoSell = on
    if not on then RemTimer("sell"); return end
    AddTimer("sell", CFG.SellInterval, function()
        -- Method 1: Remote
        local sold = FR(Remotes.Sell)
        -- Method 2: Teleport ke Steve lalu ProximityPrompt
        if not sold then
            local pos = FindNPC({"steve","sell","seller","shop"})
            if pos then
                TP(pos)
                task.wait(0.3)
            end
            TryPP({"sell","submit"})
            TryCD({"sell","steve"})
        end
        CFG.Est = CFG.Est + 200
    end)
end

-- AUTO BUY SEEDS
-- Interval 8 detik
local function SetBuy(on)
    E.AutoBuy = on
    if not on then RemTimer("buy"); return end
    AddTimer("buy", CFG.BuyInterval, function()
        -- Method 1: Remote
        local bought = FR(Remotes.BuySeed, CFG.TargetSeed)
        -- Method 2: Teleport ke Bill
        if not bought then
            local pos = FindNPC({"bill","seed","seedshop","seeds"})
            if pos then TP(pos); task.wait(0.3) end
            TryPP({"buy","seed","purchase"})
            TryCD({"bill","seed"})
        end
        CFG.Seeds = CFG.Seeds + 1
    end)
end

-- AUTO WATER
-- Interval 15 detik (sprinkler tidak perlu sering)
local function SetWater(on)
    E.AutoWater = on
    if not on then RemTimer("water"); return end
    AddTimer("water", CFG.WaterInterval, function()
        FR(Remotes.Water)
        TryPP({"water","sprinkler","irrigate"})
        TryCD({"water","sprinkler"})
    end)
end

-- LUSH WAIT
-- Interval 5 detik, bukan tiap frame
local function SetLush(on)
    E.LushWait = on
    if not on then RemTimer("lush"); return end
    AddTimer("lush", 5, function()
        for _, o in ipairs(workspace:GetDescendants()) do
            local trait = o:GetAttribute("Trait") or o:GetAttribute("Stage")
                       or o:GetAttribute("Ripeness") or ""
            local owner = o:GetAttribute("Owner") or o:GetAttribute("PlayerName")
                       or o:GetAttribute("UserId") or ""
            if (trait == "Lush" or trait:lower():find("lush"))
            and (owner == lp.Name or owner == tostring(lp.UserId) or owner == "") then
                FR(Remotes.Sell, o)
                TryPP({"sell","harvest"})
                CFG.Harvest = CFG.Harvest + 1
                CFG.Est = CFG.Est + 5000
            end
        end
    end)
end

-- AUTO FAVORITE
-- Interval 8 detik
local function SetFav(on)
    E.AutoFav = on
    if not on then RemTimer("fav"); return end
    AddTimer("fav", 8, function()
        for _, o in ipairs(workspace:GetDescendants()) do
            local owner = o:GetAttribute("Owner") or o:GetAttribute("PlayerName") or ""
            if owner == lp.Name or owner == tostring(lp.UserId) then
                local total = 0
                for mName in pairs(MUTATIONS) do
                    if o:GetAttribute(mName) then total = total + MUTATIONS[mName] end
                end
                if total >= 6.0 then
                    FR(Remotes.Favorite, o)
                    TryPP({"favorite","fav"})
                end
            end
        end
    end)
end

-- SHOP SNIPER
-- Interval 2 detik
local function SetSniper(on)
    E.ShopSniper = on
    if not on then RemTimer("sniper"); return end
    AddTimer("sniper", 2, function()
        for _, o in ipairs(workspace:GetDescendants()) do
            local n = o.Name:lower()
            for _, target in ipairs(SNIPER) do
                if n:find(target:lower()) and n:find("seed") then
                    local pos = FindNPC({"bill","seed","shop"})
                    if pos then TP(pos); task.wait(0.2) end
                    FR(Remotes.BuySeed, target)
                    TryPP({"buy",target:lower()})
                    Notify("Sniper: Beli "..target,"ok")
                end
            end
        end
    end)
end

-- AUTO QUEST
-- Interval 30 detik
local function SetQuest(on)
    E.AutoQuest = on
    if not on then RemTimer("quest"); return end
    AddTimer("quest", 30, function()
        local pos = FindNPC({"quest","maya","board","daily"})
        if pos then TP(pos); task.wait(0.4) end
        FR(Remotes.Quest)
        TryPP({"quest","claim","daily","weekly","turnin"})
        TryCD({"quest","board"})
    end)
end

-- MUTATION ALERT
-- Interval 10 detik (bukan tiap frame!)
local function SetMutAlert(on)
    E.MutAlert = on
    if not on then RemTimer("mutalert"); return end
    AddTimer("mutalert", 10, function()
        for _, o in ipairs(workspace:GetDescendants()) do
            for mName, mVal in pairs(MUTATIONS) do
                if mVal >= CFG.MinMut and o:GetAttribute(mName) then
                    local owner = o:GetAttribute("Owner") or ""
                    if owner == lp.Name or owner == "" then
                        Notify("Mutasi "..mName.." ("..mVal.."x)!","ok")
                    end
                end
            end
        end
    end)
end

-- WEATHER ALERT
-- Interval 5 detik
local weatherNames = {"Sunny","Rain","Fog","Storm","Snow","Sand","Star","Meteor","Tidal","Party","Mossy"}
local lastWeather = ""
local function SetWeatherAlert(on)
    E.WeatherAlert = on
    if not on then RemTimer("weather"); return end
    AddTimer("weather", 5, function()
        for _, wName in ipairs(weatherNames) do
            for _, o in ipairs(workspace:GetDescendants()) do
                if o.Name:lower():find(wName:lower()) then
                    if wName ~= lastWeather then
                        lastWeather = wName
                        CFG.Weather = wName
                        Notify("Weather: "..wName,"info")
                    end
                    return
                end
            end
        end
    end)
end

-- ANTI AFK
local afkConn
local function SetAFK(on)
    E.AntiAFK = on
    if afkConn then pcall(function() afkConn:Disconnect() end); afkConn = nil end
    if not on then return end
    pcall(function()
        local vu = game:GetService("VirtualUser")
        afkConn = lp.Idled:Connect(function()
            vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
            task.wait(0.1)
            vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        end)
    end)
    Notify("Anti-AFK ON","ok")
end

-- SPEED
local function ApplySpd()
    local h = Hum()
    if h then h.WalkSpeed = E.Speed and CFG.WalkSpeed or 16 end
end
local function SetSpeed(on)
    E.Speed = on; ApplySpd()
    Notify(on and ("Speed "..CFG.WalkSpeed) or "Speed OFF", on and "ok" or "warn")
end

-- ESP
local espObjs = {}
local function ClearESP()
    for _, v in ipairs(espObjs) do pcall(function() v:Destroy() end) end
    espObjs = {}
end
local function AddHL(adornee, col)
    if not adornee then return end
    local h = Instance.new("SelectionBox")
    h.Adornee = adornee
    h.Color3 = col; h.LineThickness = 0.04
    h.SurfaceTransparency = 0.88; h.SurfaceColor3 = col
    local ok = pcall(function() h.Parent = game:GetService("CoreGui") end)
    if not ok then h.Parent = MainGui end
    table.insert(espObjs, h)
end
local function RefESP()
    ClearESP()
    if E.ESPCrop then
        for _, o in ipairs(workspace:GetDescendants()) do
            if o:IsA("BasePart") then
                local n = o.Name:lower()
                if n:find("crop") or n:find("fruit") or n:find("lush") or n:find("ripe") then
                    local trait = o:GetAttribute("Trait") or ""
                    local col = (trait == "Lush") and Color3.fromRGB(0,255,100)
                             or (trait == "Ripened") and Color3.fromRGB(255,220,0)
                             or Color3.fromRGB(0,130,255)
                    AddHL(o, col)
                end
            end
        end
    end
    if E.ESPNpc then
        for _, name in ipairs({"Bill","Molly","Steve","Maya","Quest"}) do
            for _, o in ipairs(workspace:GetDescendants()) do
                if o.Name:lower():find(name:lower()) and o:IsA("Model") then
                    AddHL(o, Color3.fromRGB(255,180,0)); break
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
    SetHarvest(on); SetSell(on); SetBuy(on)
    SetWater(on); SetAFK(on)
    if on then SetLush(on) end
    Notify(on and "FULL AUTO ON!" or "FULL AUTO OFF", on and "ok" or "warn")
end

-- RESPAWN
lp.CharacterAdded:Connect(function()
    task.wait(0.8)
    if E.Speed then ApplySpd() end
end)

-- ══════════════════════════════════════════
-- NOTIFICATION SYSTEM
-- ══════════════════════════════════════════
local nList = {}
local nCol = {
    ok=Color3.fromRGB(0,200,110), info=Color3.fromRGB(0,130,255),
    warn=Color3.fromRGB(255,160,0), err=Color3.fromRGB(255,55,55)
}

function Notify(msg, t)
    t = t or "info"
    local col = nCol[t] or nCol.info
    for _, f in ipairs(nList) do
        TweenService:Create(f, TweenInfo.new(0.15), {
            Position = f.Position + UDim2.new(0,0,0,40)
        }):Play()
    end
    local f = Instance.new("Frame", NotifGui)
    f.Size = UDim2.new(0,215,0,32)
    f.Position = UDim2.new(1,-225,0,-50)
    f.BackgroundColor3 = Color3.fromRGB(7,9,18)
    f.BorderSizePixel = 0
    Instance.new("UICorner",f).CornerRadius = UDim.new(0,7)
    local bar = Instance.new("Frame",f)
    bar.Size = UDim2.new(0,3,1,0); bar.BackgroundColor3 = col; bar.BorderSizePixel = 0
    Instance.new("UICorner",bar).CornerRadius = UDim.new(0,3)
    local lb = Instance.new("TextLabel",f)
    lb.Size = UDim2.new(1,-10,1,0); lb.Position = UDim2.new(0,8,0,0)
    lb.BackgroundTransparency = 1; lb.Text = msg; lb.TextSize = 11
    lb.Font = Enum.Font.GothamSemibold
    lb.TextColor3 = Color3.fromRGB(210,225,255)
    lb.TextXAlignment = Enum.TextXAlignment.Left
    lb.TextTruncate = Enum.TextTruncate.AtEnd
    local sk = Instance.new("UIStroke",f); sk.Color = col; sk.Thickness = 1; sk.Transparency = 0.5
    table.insert(nList, 1, f)
    TweenService:Create(f, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
        Position = UDim2.new(1,-225,0,10)
    }):Play()
    task.delay(2.8, function()
        TweenService:Create(f, TweenInfo.new(0.2), {
            Position = UDim2.new(1,10,0,f.Position.Y.Offset)
        }):Play()
        task.delay(0.25, function()
            local i = table.find(nList,f)
            if i then table.remove(nList,i) end
            pcall(function() f:Destroy() end)
        end)
    end)
end

-- ══════════════════════════════════════════════════════
--   U I   B U I L D E R
-- ══════════════════════════════════════════════════════
local C = {
    bg     = Color3.fromRGB(6,8,16),
    panel  = Color3.fromRGB(10,13,24),
    row    = Color3.fromRGB(13,17,30),
    rowH   = Color3.fromRGB(17,22,40),
    acc    = Color3.fromRGB(0,120,255),
    accB   = Color3.fromRGB(35,150,255),
    accD   = Color3.fromRGB(0,60,165),
    border = Color3.fromRGB(0,70,175),
    bF     = Color3.fromRGB(16,24,50),
    txt    = Color3.fromRGB(210,225,255),
    muted  = Color3.fromRGB(70,100,155),
    dim    = Color3.fromRGB(30,50,90),
    ok     = Color3.fromRGB(0,200,110),
    warn   = Color3.fromRGB(255,160,0),
    danger = Color3.fromRGB(255,55,55),
    gold   = Color3.fromRGB(255,200,40),
    green  = Color3.fromRGB(60,210,100),
}

local function Fr(p,pa) local f=Instance.new("Frame"); f.BorderSizePixel=0; for k,v in pairs(p) do pcall(function()f[k]=v end) end; if pa then f.Parent=pa end; return f end
local function Lb(p,pa) local l=Instance.new("TextLabel"); l.BackgroundTransparency=1; l.Font=Enum.Font.GothamSemibold; for k,v in pairs(p) do pcall(function()l[k]=v end) end; if pa then l.Parent=pa end; return l end
local function Bt(p,pa) local b=Instance.new("TextButton"); b.BorderSizePixel=0; b.Font=Enum.Font.GothamBold; for k,v in pairs(p) do pcall(function()b[k]=v end) end; if pa then b.Parent=pa end; return b end
local function Cr(r,p) Instance.new("UICorner",p).CornerRadius=UDim.new(0,r) end
local function Sk(col,th,p) local s=Instance.new("UIStroke",p); s.Color=col; s.Thickness=th; return s end
local function Gd(c1,c2,rot,p) local g=Instance.new("UIGradient",p); g.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,c1),ColorSequenceKeypoint.new(1,c2)}); g.Rotation=rot end

-- ── WINDOW ───────────────────────────────────
local W = Fr({
    Size=UDim2.new(0,300,0,420),
    Position=UDim2.new(0.5,-150,0.5,-210),
    BackgroundColor3=C.bg, Active=true, Draggable=true,
}, MainGui)
Cr(12,W); Sk(C.border,1.5,W); Gd(Color3.fromRGB(7,10,22),Color3.fromRGB(4,6,14),150,W)

-- ── TITLE BAR ────────────────────────────────
local TB=Fr({Size=UDim2.new(1,0,0,42),BackgroundColor3=C.accD,ZIndex=3},W); Cr(12,TB)
Fr({Size=UDim2.new(1,0,0.5,0),Position=UDim2.new(0,0,0.5,0),BackgroundColor3=C.accD,BorderSizePixel=0,ZIndex=2},TB)
Gd(Color3.fromRGB(0,105,235),Color3.fromRGB(0,48,145),120,TB)

local logo=Fr({Size=UDim2.new(0,28,0,28),Position=UDim2.new(0,8,0.5,-14),BackgroundColor3=C.acc,ZIndex=4},TB); Cr(7,logo); Gd(C.accB,C.accD,135,logo)
Lb({Size=UDim2.new(1,0,1,0),Text="V",TextSize=16,Font=Enum.Font.GothamBold,TextColor3=Color3.fromRGB(255,255,255),ZIndex=5},logo)
Lb({Size=UDim2.new(0,150,0,18),Position=UDim2.new(0,42,0,4),Text="VOID HUB",TextSize=14,Font=Enum.Font.GothamBold,TextColor3=Color3.fromRGB(255,255,255),TextXAlignment=Enum.TextXAlignment.Left,ZIndex=4},TB)
Lb({Size=UDim2.new(0,170,0,12),Position=UDim2.new(0,42,0,24),Text="v5.0  •  Garden Horizons",TextSize=9,TextColor3=Color3.fromRGB(100,165,255),TextXAlignment=Enum.TextXAlignment.Left,ZIndex=4},TB)

local BC=Bt({Size=UDim2.new(0,24,0,24),Position=UDim2.new(1,-32,0.5,-12),BackgroundColor3=C.danger,Text="x",TextSize=12,TextColor3=Color3.fromRGB(255,255,255),ZIndex=5},TB); Cr(5,BC)
local BM=Bt({Size=UDim2.new(0,24,0,24),Position=UDim2.new(1,-60,0.5,-12),BackgroundColor3=C.warn,Text="-",TextSize=16,TextColor3=Color3.fromRGB(255,255,255),ZIndex=5},TB); Cr(5,BM)

local Body=Fr({Size=UDim2.new(1,0,1,-42),Position=UDim2.new(0,0,0,42),BackgroundTransparency=1},W)

BC.MouseButton1Click:Connect(function()
    masterConn:Disconnect()
    TweenService:Create(W,TweenInfo.new(0.25,Enum.EasingStyle.Quad,Enum.EasingDirection.In),
        {Size=UDim2.new(0,300,0,0)}):Play()
    task.delay(0.3, function()
        pcall(function() MainGui:Destroy() end)
        pcall(function() NotifGui:Destroy() end)
    end)
end)

local mini=false
BM.MouseButton1Click:Connect(function()
    mini=not mini; Body.Visible=not mini
    TweenService:Create(W,TweenInfo.new(0.2),
        {Size=mini and UDim2.new(0,300,0,42) or UDim2.new(0,300,0,420)}):Play()
end)

-- ── TAB BAR (5 tab) ──────────────────────────
local TabBar=Fr({Size=UDim2.new(1,-16,0,26),Position=UDim2.new(0,8,0,6),BackgroundColor3=C.panel},Body)
Cr(6,TabBar); Sk(C.bF,1,TabBar)
local tLL=Instance.new("UIListLayout",TabBar); tLL.FillDirection=Enum.FillDirection.Horizontal; tLL.SortOrder=Enum.SortOrder.LayoutOrder; tLL.Padding=UDim.new(0,2)
local tPad=Instance.new("UIPadding",TabBar); tPad.PaddingLeft=UDim.new(0,2); tPad.PaddingRight=UDim.new(0,2); tPad.PaddingTop=UDim.new(0,2); tPad.PaddingBottom=UDim.new(0,2)

local SWrap=Fr({Size=UDim2.new(1,-16,0,352),Position=UDim2.new(0,8,0,38),BackgroundTransparency=1},Body)

-- Status bar
local StBar=Fr({Size=UDim2.new(1,-16,0,18),Position=UDim2.new(0,8,1,-22),BackgroundColor3=C.panel},Body); Cr(5,StBar); Sk(C.bF,1,StBar)
local sDot=Fr({Size=UDim2.new(0,6,0,6),Position=UDim2.new(0,7,0.5,-3),BackgroundColor3=C.ok},StBar); Cr(3,sDot)
Lb({Size=UDim2.new(0.55,0,1,0),Position=UDim2.new(0,18,0,0),Text="VOID HUB AKTIF",TextSize=9,Font=Enum.Font.GothamBold,TextColor3=C.ok,TextXAlignment=Enum.TextXAlignment.Left},StBar)
local stR=Lb({Size=UDim2.new(0.4,0,1,0),Position=UDim2.new(0.58,0,0,0),Text="Remote: "..foundCount,TextSize=9,TextColor3=C.dim,TextXAlignment=Enum.TextXAlignment.Right},StBar)
local spd=Instance.new("UIPadding",StBar); spd.PaddingRight=UDim.new(0,6)

task.spawn(function()
    while MainGui and MainGui.Parent do
        TweenService:Create(sDot,TweenInfo.new(1),{BackgroundTransparency=0.5}):Play(); task.wait(1)
        TweenService:Create(sDot,TweenInfo.new(1),{BackgroundTransparency=0}):Play(); task.wait(1)
    end
end)

local featN=0
local function UF(d) featN=math.max(0,featN+d); stR.Text=featN.." aktif | RE:"..foundCount end

-- ── TAB SYSTEM ───────────────────────────────
local TD={}
local function NewTab(name,icon,order)
    local btn=Bt({Size=UDim2.new(0.2,-2,1,0),BackgroundColor3=C.panel,Text=icon,TextSize=10,TextColor3=C.muted,LayoutOrder=order,ZIndex=4,Font=Enum.Font.GothamBold},TabBar); Cr(4,btn)
    local panel=Fr({Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Visible=false,ZIndex=2},SWrap)
    local ps=Instance.new("ScrollingFrame",panel)
    ps.Size=UDim2.new(1,0,1,0); ps.BackgroundTransparency=1; ps.BorderSizePixel=0
    ps.ScrollBarThickness=2; ps.ScrollBarImageColor3=C.acc
    ps.CanvasSize=UDim2.new(0,0,0,0); ps.AutomaticCanvasSize=Enum.AutomaticSize.Y
    local pl=Instance.new("UIListLayout",ps); pl.Padding=UDim.new(0,4); pl.SortOrder=Enum.SortOrder.LayoutOrder
    local pp=Instance.new("UIPadding",ps); pp.PaddingBottom=UDim.new(0,4)
    TD[name]={btn=btn,panel=panel,scroll=ps}
    btn.MouseButton1Click:Connect(function()
        for n,d in pairs(TD) do
            local a=(n==name); d.panel.Visible=a
            TweenService:Create(d.btn,TweenInfo.new(0.15),{BackgroundColor3=a and C.acc or C.panel, TextColor3=a and Color3.fromRGB(255,255,255) or C.muted}):Play()
        end
    end)
    return ps
end

local sA=NewTab("AUTO","🌾",1)
local sF=NewTab("FARM","🪙",2)
local sE=NewTab("ESP","👁",3)
local sC=NewTab("CALC","🧮",4)
local sU=NewTab("UTIL","⚙",5)

TD["AUTO"].panel.Visible=true
TD["AUTO"].btn.BackgroundColor3=C.acc
TD["AUTO"].btn.TextColor3=Color3.fromRGB(255,255,255)

-- ── ROW BUILDERS ─────────────────────────────
local function SecL(txt,pa,ord)
    local f=Fr({Size=UDim2.new(1,0,0,18),BackgroundTransparency=1,LayoutOrder=ord},pa)
    Lb({Size=UDim2.new(1,-4,1,0),Position=UDim2.new(0,4,0,0),Text="  "..txt:upper(),TextSize=9,Font=Enum.Font.GothamBold,TextColor3=C.acc,TextXAlignment=Enum.TextXAlignment.Left},f)
    local ln=Fr({Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,-1),BackgroundColor3=C.border},f); ln.BackgroundTransparency=0.6
end

local function TglRow(icon,label,desc,pa,ord,cb,aCol)
    aCol=aCol or C.acc
    local on=false
    local row=Fr({Size=UDim2.new(1,0,0,44),BackgroundColor3=C.row,LayoutOrder=ord},pa); Cr(7,row)
    local sk=Sk(C.bF,1,row)
    local ab=Fr({Size=UDim2.new(0,3,0,26),Position=UDim2.new(0,0,0.5,-13),BackgroundColor3=aCol},row); Cr(2,ab); ab.BackgroundTransparency=1
    Lb({Size=UDim2.new(0,28,1,0),Position=UDim2.new(0,7,0,0),Text=icon,TextSize=16,TextColor3=C.dim,ZIndex=3},row)
    local mL=Lb({Size=UDim2.new(1,-84,0,20),Position=UDim2.new(0,37,0,4),Text=label,TextSize=12,Font=Enum.Font.GothamBold,TextColor3=C.muted,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=3},row)
    Lb({Size=UDim2.new(1,-84,0,14),Position=UDim2.new(0,37,0,24),Text=desc,TextSize=9,TextColor3=C.dim,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=3},row)
    local pb=Fr({Size=UDim2.new(0,38,0,20),Position=UDim2.new(1,-46,0.5,-10),BackgroundColor3=Color3.fromRGB(16,20,38)},row); Cr(10,pb); Sk(C.bF,1,pb)
    local kn=Fr({Size=UDim2.new(0,14,0,14),Position=UDim2.new(0,3,0.5,-7),BackgroundColor3=C.muted},pb); Cr(7,kn)
    local hit=Bt({Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",ZIndex=5},row)
    local function upd()
        TweenService:Create(pb,TweenInfo.new(0.15),{BackgroundColor3=on and C.accD or Color3.fromRGB(16,20,38)}):Play()
        TweenService:Create(kn,TweenInfo.new(0.15),{Position=on and UDim2.new(0,21,0.5,-7) or UDim2.new(0,3,0.5,-7),BackgroundColor3=on and Color3.fromRGB(255,255,255) or C.muted}):Play()
        TweenService:Create(sk,TweenInfo.new(0.15),{Color=on and aCol or C.bF}):Play()
        TweenService:Create(ab,TweenInfo.new(0.15),{BackgroundTransparency=on and 0 or 1}):Play()
        TweenService:Create(mL,TweenInfo.new(0.15),{TextColor3=on and C.txt or C.muted}):Play()
        TweenService:Create(row,TweenInfo.new(0.15),{BackgroundColor3=on and C.rowH or C.row}):Play()
    end
    hit.MouseButton1Click:Connect(function()
        on=not on; upd(); UF(on and 1 or -1); cb(on)
    end)
end

local function ActRow(icon,label,desc,pa,ord,cb,aCol)
    aCol=aCol or C.accD
    local row=Fr({Size=UDim2.new(1,0,0,40),BackgroundColor3=C.row,LayoutOrder=ord},pa); Cr(7,row)
    local sk=Sk(C.bF,1,row)
    Lb({Size=UDim2.new(0,26,1,0),Position=UDim2.new(0,7,0,0),Text=icon,TextSize=14,TextColor3=C.acc,ZIndex=3},row)
    Lb({Size=UDim2.new(1,-80,0,18),Position=UDim2.new(0,35,0,4),Text=label,TextSize=12,Font=Enum.Font.GothamBold,TextColor3=C.txt,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=3},row)
    Lb({Size=UDim2.new(1,-80,0,13),Position=UDim2.new(0,35,0,22),Text=desc,TextSize=9,TextColor3=C.dim,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=3},row)
    local rb=Bt({Size=UDim2.new(0,50,0,24),Position=UDim2.new(1,-57,0.5,-12),BackgroundColor3=aCol,Text="RUN",TextSize=10,TextColor3=Color3.fromRGB(255,255,255),ZIndex=5},row); Cr(5,rb); Gd(C.accB,aCol,90,rb)
    rb.MouseButton1Click:Connect(function()
        TweenService:Create(rb,TweenInfo.new(0.1),{BackgroundTransparency=0.5}):Play()
        task.delay(0.15,function() TweenService:Create(rb,TweenInfo.new(0.1),{BackgroundTransparency=0}):Play() end)
        cb()
    end)
    row.MouseEnter:Connect(function() TweenService:Create(sk,TweenInfo.new(0.1),{Color=C.acc}):Play() end)
    row.MouseLeave:Connect(function() TweenService:Create(sk,TweenInfo.new(0.1),{Color=C.bF}):Play() end)
end

local function SldRow(icon,label,pa,ord,mn,mx,def,cb)
    local row=Fr({Size=UDim2.new(1,0,0,48),BackgroundColor3=C.row,LayoutOrder=ord},pa); Cr(7,row); Sk(C.bF,1,row)
    Lb({Size=UDim2.new(0,22,0,18),Position=UDim2.new(0,7,0,7),Text=icon,TextSize=13,TextColor3=C.acc},row)
    Lb({Size=UDim2.new(0.58,0,0,18),Position=UDim2.new(0,30,0,7),Text=label,TextSize=11,Font=Enum.Font.GothamBold,TextColor3=C.txt,TextXAlignment=Enum.TextXAlignment.Left},row)
    local vL=Lb({Size=UDim2.new(0.35,0,0,18),Position=UDim2.new(0.63,0,0,7),Text=tostring(def),TextSize=12,Font=Enum.Font.GothamBold,TextColor3=C.accB,TextXAlignment=Enum.TextXAlignment.Right},row)
    local tr=Fr({Size=UDim2.new(1,-18,0,5),Position=UDim2.new(0,9,0,34),BackgroundColor3=Color3.fromRGB(14,20,40)},row); Cr(3,tr); Sk(C.bF,1,tr)
    local pct=(def-mn)/(mx-mn)
    local fi=Fr({Size=UDim2.new(pct,0,1,0),BackgroundColor3=C.acc},tr); Cr(3,fi); Gd(C.accB,C.acc,90,fi)
    local kn2=Fr({Size=UDim2.new(0,12,0,12),Position=UDim2.new(pct,-6,0.5,-6),BackgroundColor3=Color3.fromRGB(255,255,255),ZIndex=4},tr); Cr(6,kn2); Sk(C.acc,1.5,kn2)
    local drag=false
    kn2.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drag=true end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drag=false end
    end)
    UIS.InputChanged:Connect(function(i)
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
    local h2=#lines*14+10
    local row=Fr({Size=UDim2.new(1,0,0,h2),BackgroundColor3=C.row,LayoutOrder=ord},pa); Cr(7,row); Sk(col,1,row)
    local lbl2=Lb({Size=UDim2.new(1,-14,1,0),Position=UDim2.new(0,7,0,0),Text=table.concat(lines,"\n"),TextSize=10,Font=Enum.Font.Code or Enum.Font.Gotham,TextColor3=C.muted,TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true,LineHeight=1.5},row)
    return row, lbl2
end

-- ══════════════════════════════════════
-- TAB AUTO
-- ══════════════════════════════════════
local o=0; local function no() o=o+1; return o end

SecL("Master",sA,no())
ActRow("⚡","FULL AUTO MODE","Aktifkan semua otomasi",sA,no(),function() FullAuto(true) end, Color3.fromRGB(0,130,70))
ActRow("🛑","STOP SEMUA","Hentikan semua",sA,no(),function() FullAuto(false) end, Color3.fromRGB(140,40,40))

SecL("Harvest & Sell",sA,no())
TglRow("🌾","Auto Harvest","Panen tiap 2 detik",sA,no(),function(on) SetHarvest(on) end, C.green)
TglRow("💰","Auto Sell","Jual tiap 3 detik",sA,no(),function(on) SetSell(on) end, C.gold)
TglRow("🌿","Lush Wait & Sell","Jual hanya saat Lush (3x)",sA,no(),function(on) SetLush(on) end, C.green)
TglRow("⭐","Auto Favorite","Tandai crop mutasi tinggi",sA,no(),function(on) SetFav(on) end, C.gold)
SldRow("⏱","Sell Interval (s)",sA,no(),1,10,3,function(v) CFG.SellInterval=v end)

SecL("Planting & Water",sA,no())
TglRow("🌱","Auto Buy Seeds","Beli seed tiap 8 detik",sA,no(),function(on) SetBuy(on) end)
TglRow("💧","Auto Water","Siram tiap 15 detik",sA,no(),function(on) SetWater(on) end)

SecL("Alert & Sniper",sA,no())
TglRow("🎯","Shop Sniper","Beli seed langka otomatis",sA,no(),function(on) SetSniper(on) end, Color3.fromRGB(180,80,255))
TglRow("📋","Auto Quest","Claim quest tiap 30 detik",sA,no(),function(on) SetQuest(on) end)
TglRow("🔔","Weather Alert","Notif cuaca berubah",sA,no(),function(on) SetWeatherAlert(on) end)
TglRow("✨","Mutation Alert","Notif mutasi berharga",sA,no(),function(on) SetMutAlert(on) end, Color3.fromRGB(160,100,255))
SldRow("🎚","Min Mutasi Value",sA,no(),1,12,3.5,function(v) CFG.MinMut=v end)

-- ══════════════════════════════════════
-- TAB FARM
-- ══════════════════════════════════════
o=0
SecL("Teleport NPC",sF,no())
ActRow("🌱","TP ke Bill / Seeds","Beli benih",sF,no(),function()
    local p=FindNPC({"bill","seed","seedshop"})
    TP(p); Notify(p and "TP ke Bill!" or "Bill tidak ditemukan", p and "ok" or "err")
end)
ActRow("🔧","TP ke Molly / Gear","Beli alat",sF,no(),function()
    local p=FindNPC({"molly","gear","gearshop","tool"})
    TP(p); Notify(p and "TP ke Molly!" or "Molly tidak ditemukan", p and "ok" or "err")
end)
ActRow("💵","TP ke Steve / Sell","Jual crop",sF,no(),function()
    local p=FindNPC({"steve","sell","seller","appraise"})
    TP(p); Notify(p and "TP ke Steve!" or "Steve tidak ditemukan", p and "ok" or "err")
end)
ActRow("🧪","TP ke Maya / IGMA","Quest NPC",sF,no(),function()
    local p=FindNPC({"maya","igma","researcher"})
    TP(p); Notify(p and "TP ke Maya!" or "Maya tidak ditemukan", p and "ok" or "err")
end)
ActRow("📋","TP ke Quest Board","Ambil quest",sF,no(),function()
    local p=FindNPC({"quest","board","daily","weekly"})
    TP(p); Notify(p and "TP ke Quest!" or "Quest tidak ditemukan", p and "ok" or "err")
end)

SecL("Quick Actions",sF,no())
ActRow("💎","Force Sell Sekarang","Langsung jual semua",sF,no(),function()
    local p=FindNPC({"steve","sell"})
    if p then TP(p); task.wait(0.3) end
    FR(Remotes.Sell); TryPP({"sell","submit"})
    Notify("Force sell!","ok")
end, C.gold)
ActRow("🔄","Rescan Remotes","Cari ulang remote event",sF,no(),function()
    foundCount = ScanRemotes()
    stR.Text = featN.." aktif | RE:"..foundCount
    Notify("Ditemukan "..foundCount.." remote","ok")
end)
ActRow("🔁","Satu Siklus Farm","Bill -> Harvest -> Steve",sF,no(),function()
    task.spawn(function()
        local bp=FindNPC({"bill","seed"}); if bp then TP(bp) end; task.wait(0.5)
        FR(Remotes.BuySeed, CFG.TargetSeed); TryPP({"buy","seed"}); task.wait(0.5)
        local sp=FindNPC({"steve","sell"}); if sp then TP(sp) end; task.wait(0.5)
        FR(Remotes.Sell); TryPP({"sell"})
        Notify("Siklus selesai!","ok")
    end)
end, Color3.fromRGB(0,120,70))

SecL("Statistik Sesi",sF,no())
local _,statsL=InfoBox({"Memuat..."},sF,no(),C.bF)

AddTimer("stats_ui", 2, function()
    if not statsL then return end
    local el=os.clock()-CFG.Start
    statsL.Text=string.format(
        "Waktu: %02d:%02d\nHarvest: %d  |  Seeds: %d\nEst Shillings: %s\nWeather: %s\nRemote ditemukan: %d",
        math.floor(el/60), math.floor(el%60),
        CFG.Harvest, CFG.Seeds, FmtN(CFG.Est),
        CFG.Weather, foundCount
    )
end)

SecL("Info Mutasi Cuaca",sF,no())
InfoBox({
    "Rain  -> Soaked+Flooded (1.5x)",
    "Storm -> Shocked (4.5x)",
    "Sand  -> Sandy+Muddy (4.5x)",
    "Star  -> Starstruck (6.5x)",
    "Meteor-> Meteoric (10x)",
    "Party -> Party (11.5x) BEST!",
},sF,no(), Color3.fromRGB(0,35,100))

-- ══════════════════════════════════════
-- TAB ESP
-- ══════════════════════════════════════
o=0
SecL("ESP",sE,no())
TglRow("🌾","Crop ESP","Highlight tanaman",sE,no(),function(on) E.ESPCrop=on; RefESP() end, C.green)
TglRow("👴","NPC ESP","Highlight NPC",sE,no(),function(on) E.ESPNpc=on; RefESP() end, C.gold)
TglRow("👤","Player ESP","Highlight player lain",sE,no(),function(on) E.ESPPlay=on; RefESP() end)
ActRow("🔄","Refresh ESP","Update highlight",sE,no(),function() RefESP(); Notify("ESP refreshed","ok") end)
ActRow("❌","Clear ESP","Hapus semua highlight",sE,no(),function() ClearESP(); Notify("ESP cleared","warn") end)
InfoBox({
    "Hijau  = Lush (3x value)",
    "Kuning = Ripened (2x value)",
    "Biru   = Unripe",
    "Oranye = NPC",
},sE,no(), Color3.fromRGB(0,35,80))

-- ══════════════════════════════════════
-- TAB CALC
-- ══════════════════════════════════════
o=0
SecL("Mutation Calculator",sC,no())

local selP="Carrot"; local selM={}; local selT="Lush"
local calcLbl

local pg2=Fr({Size=UDim2.new(1,0,0,72),BackgroundTransparency=1,LayoutOrder=no()},sC)
local pgL2=Instance.new("UIGridLayout",pg2); pgL2.CellSize=UDim2.new(0,64,0,22); pgL2.CellPadding=UDim2.new(0,3,0,3)

local pBtns={}
local function mkP(name)
    local b=Bt({BackgroundColor3=C.row,Text=name,TextSize=8,TextColor3=C.muted,ZIndex=3,Font=Enum.Font.GothamBold},pg2); Cr(4,b); Sk(C.bF,1,b)
    b.MouseButton1Click:Connect(function()
        selP=name
        for n2,b2 in pairs(pBtns) do TweenService:Create(b2,TweenInfo.new(0.1),{BackgroundColor3=n2==name and C.accD or C.row,TextColor3=n2==name and Color3.fromRGB(255,255,255) or C.muted}):Play() end
        if calcLbl then calcLbl.Text="Nilai: "..FmtN(CalcVal(selP,selM,selT)).." Shillings" end
    end)
    pBtns[name]=b
end
for _,n in ipairs({"Carrot","Onion","Tomato","Apple","Rose","Banana","Cherry","Plum","Cabbage","Dawnfruit"}) do mkP(n) end

SecL("Pilih Mutasi",sC,no())
local mg2=Fr({Size=UDim2.new(1,0,0,96),BackgroundTransparency=1,LayoutOrder=no()},sC)
local mgL2=Instance.new("UIGridLayout",mg2); mgL2.CellSize=UDim2.new(0,86,0,22); mgL2.CellPadding=UDim2.new(0,2,0,2)

for mN,mV in pairs(MUTATIONS) do
    local b=Bt({BackgroundColor3=C.row,Text=mN.." "..mV.."x",TextSize=8,TextColor3=C.muted,ZIndex=3,Font=Enum.Font.Gotham},mg2); Cr(4,b); Sk(C.bF,1,b)
    local sel=false
    b.MouseButton1Click:Connect(function()
        sel=not sel
        TweenService:Create(b,TweenInfo.new(0.1),{BackgroundColor3=sel and C.accD or C.row,TextColor3=sel and Color3.fromRGB(255,255,255) or C.muted}):Play()
        if sel then table.insert(selM,mN) else local i=table.find(selM,mN); if i then table.remove(selM,i) end end
        if calcLbl then calcLbl.Text="Nilai: "..FmtN(CalcVal(selP,selM,selT)).." Shillings" end
    end)
end

SecL("Trait",sC,no())
local tg2=Fr({Size=UDim2.new(1,0,0,26),BackgroundTransparency=1,LayoutOrder=no()},sC)
local tgL2=Instance.new("UIListLayout",tg2); tgL2.FillDirection=Enum.FillDirection.Horizontal; tgL2.Padding=UDim.new(0,3)
local trBtns2={}
for _,tN in ipairs({"Unripe","Ripened","Lush"}) do
    local b=Bt({Size=UDim2.new(0.33,-2,1,0),BackgroundColor3=tN=="Lush" and C.accD or C.row,Text=tN,TextSize=10,TextColor3=tN=="Lush" and Color3.fromRGB(255,255,255) or C.muted,ZIndex=3},tg2); Cr(4,b)
    b.MouseButton1Click:Connect(function()
        selT=tN
        for tn2,b2 in pairs(trBtns2) do TweenService:Create(b2,TweenInfo.new(0.1),{BackgroundColor3=tn2==tN and C.accD or C.row,TextColor3=tn2==tN and Color3.fromRGB(255,255,255) or C.muted}):Play() end
        if calcLbl then calcLbl.Text="Nilai: "..FmtN(CalcVal(selP,selM,selT)).." Shillings" end
    end)
    trBtns2[tN]=b
end

local rF=Fr({Size=UDim2.new(1,0,0,36),BackgroundColor3=Color3.fromRGB(0,25,70),LayoutOrder=no()},sC); Cr(8,rF); Sk(C.acc,1.5,rF)
calcLbl=Lb({Size=UDim2.new(1,0,1,0),Text="Nilai: 90 Shillings",TextSize=13,Font=Enum.Font.GothamBold,TextColor3=C.accB},rF)
ActRow("🧮","Hitung Sekarang","Update nilai crop",sC,no(),function()
    local v=CalcVal(selP,selM,selT)
    calcLbl.Text="Nilai: "..FmtN(v).." Shillings"
    Notify(selP.." = "..FmtN(v).." Shillings","ok")
end)

-- ══════════════════════════════════════
-- TAB UTIL
-- ══════════════════════════════════════
o=0
SecL("Player",sU,no())
TglRow("⚡","Speed Boost","Gerak lebih cepat",sU,no(),function(on) SetSpeed(on) end)
SldRow("🏃","Walk Speed",sU,no(),16,80,24,function(v) CFG.WalkSpeed=v; ApplySpd() end)
TglRow("🛡","Anti-AFK","Cegah kick karena diam",sU,no(),function(on) SetAFK(on) end)

SecL("Live Info",sU,no())
local _,liveL=InfoBox({"Loading..."},sU,no(),C.bF)

AddTimer("live_ui", 3, function()
    if not liveL then return end
    local hrp=HRP(); local h=Hum()
    if hrp and h then
        liveL.Text=string.format(
            "Player: %s\nY: %.1f  |  HP: %.0f\nSpeed: %.0f  |  Server: %d player\nWeather: %s",
            lp.Name, hrp.Position.Y, math.min(h.Health,9999),
            h.WalkSpeed, #Players:GetPlayers(), CFG.Weather
        )
    end
end)

SecL("Aksi",sU,no())
ActRow("🔄","Reset Karakter","Respawn karakter",sU,no(),function()
    lp:LoadCharacter(); Notify("Respawn!","info")
end)
ActRow("🛑","Stop Semua Fitur","Matikan semuanya",sU,no(),function()
    FullAuto(false); SetAFK(false); SetSpeed(false)
    SetMutAlert(false); SetWeatherAlert(false); SetSniper(false)
    SetQuest(false); SetFav(false)
    ClearESP()
    for k in pairs(E) do E[k]=false end
    Timers={} -- clear all timers
    Notify("Semua fitur OFF","warn")
end, Color3.fromRGB(140,40,40))
ActRow("📋","Copy Username","Salin nama ke clipboard",sU,no(),function()
    pcall(function() setclipboard(lp.Name) end)
    Notify(lp.Name.." disalin","ok")
end)

SecL("Panduan Singkat",sU,no())
InfoBox({
    "1. Tab AUTO -> Full Auto Mode",
    "2. Tab FARM -> Teleport ke NPC",
    "3. Tab ESP  -> Highlight crop/NPC",
    "4. Tab CALC -> Hitung nilai mutasi",
    "  ",
    "Jika fitur tidak jalan:",
    "-> Tap 'Rescan Remotes' di FARM",
    "-> Status bar tunjukkan RE found",
},sU,no(), Color3.fromRGB(0,28,60))

-- ── ENTRANCE ANIMATION ───────────────────────
W.Position=UDim2.new(0.5,-150,1.5,0)
W.BackgroundTransparency=1
TweenService:Create(W,TweenInfo.new(0.5,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{
    Position=UDim2.new(0.5,-150,0.5,-210),
    BackgroundTransparency=0,
}):Play()

task.delay(0.5, function()
    Notify("VOID HUB v5.0 loaded!","ok")
    task.delay(1, function()
        Notify("Remote ditemukan: "..foundCount.."/6","info")
    end)
end)
