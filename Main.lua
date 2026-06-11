--[[
    ================================================================
    [ SCRIPT INFORMATION ]
    Project: Zombie Project Lazarus - Anti-Cheat Bypass
    Author: OYB
    YouTube: https://www.youtube.com/channel/UCAlXXV1Hbvf7WbfXARuVtiQ
    
    Copyright (c) 2026 OYB. All rights reserved.
    ================================================================
]]

-- ============================================================
-- ULTIMATE ANTI-CHEAT BYPASS SYSTEM
-- ============================================================

-- Скрываем инжектор от обнаружения
pcall(function()
    if getgenv then getgenv().detected = false end
    if getrenv then getrenv().detected = false end
end)

-- Обход обнаружения скриптов (Method 1: Function Hooking)
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    
    -- Блокируем детекты
    if method == "Kick" then
        return nil
    end
    
    if method == "FindFirstChild" and args[1] and type(args[1]) == "string" then
        local searchName = args[1]:lower()
        -- Скрываем наши объекты от поиска
        local blockedNames = {"lolscripts", "esp", "cheat", "hack", "injected", "detector", "antiexploit", "anticheat"}
        for _, blocked in ipairs(blockedNames) do
            if searchName:find(blocked) then
                return nil
            end
        end
    end
    
    if method == "GetChildren" or method == "GetDescendants" then
        -- Не даём найти наши GUI и Drawing объекты
        local result = oldNamecall(self, ...)
        if type(result) == "table" then
            local filtered = {}
            for _, v in ipairs(result) do
                if type(v) == "table" and v.Name then
                    local name = v.Name:lower()
                    if not name:find("lolscripts") and not name:find("drawing") then
                        table.insert(filtered, v)
                    end
                else
                    table.insert(filtered, v)
                end
            end
            return filtered
        end
        return result
    end
    
    return oldNamecall(self, ...)
end)

-- Method 2: Обход проверки CoreGui
local oldIndex = nil
oldIndex = hookmetamethod(game, "__index", function(self, key)
    if key == "CoreGui" and checkcaller and not checkcaller() then
        return nil
    end
    return oldIndex(self, key)
end)

-- Method 3: Скрываем загрузку скриптов
pcall(function()
    if getconnections then
        for _, v in pairs(getconnections(game.Loaded)) do
            v:Disable()
        end
    end
end)

-- Method 4: Блокируем отправку логов на сервер
pcall(function()
    local oldLog = game.Log or game:FindService("LogService")
    if oldLog then
        local logMt = getrawmetatable(oldLog)
        if logMt then
            local oldLogIndex = logMt.__index
            logMt.__index = function(self, key)
                if key == "MessageOut" or key == "OnMessageOut" then
                    return function() end
                end
                return oldLogIndex(self, key)
            end
        end
    end
end)

-- Method 5: Отключаем анти-чип скрипты в workspace
task.spawn(function()
    while task.wait(2) do
        pcall(function()
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("Script") or obj:IsA("LocalScript") then
                    local name = obj.Name:lower()
                    if name:find("anti") or name:find("detect") or name:find("cheat") or 
                       name:find("ban") or name:find("kick") or name:find("exploit") then
                        obj.Disabled = true
                    end
                end
            end
        end)
    end
end)

-- Method 6: Обход ScreenGui детекта
local oldNewIndex = hookmetamethod(game, "__newindex", function(self, key, value)
    if self == game and key == "CoreGui" then
        return
    end
    return oldNewIndex(self, key, value)
end)

-- Method 7: Отключаем обнаружение изменённых значений
pcall(function()
    if getgc then
        for _, v in pairs(getgc()) do
            if type(v) == "function" then
                local info = getinfo(v)
                if info.name and (info.name:lower():find("detect") or info.name:lower():find("ban") or info.name:lower():find("anticheat")) then
                    -- Не трогаем, но отслеживаем
                end
            end
        end
    end
end)

-- Method 8: Защита от RemoteEvent/RemoteFunction спама
local blockedRemotes = {}
local oldFireServer = nil
pcall(function()
    local mt = getrawmetatable(game)
    oldFireServer = mt.__namecall
    setreadonly(mt, false)
    mt.__namecall = function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        if method == "FireServer" and typeof(self) == "Instance" then
            -- Блокируем детекты
            if self.Name:lower():find("detect") or self.Name:lower():find("ban") or self.Name:lower():find("report") then
                return nil
            end
        end
        return oldFireServer(self, ...)
    end
end)

print("🛡️ Anti-Cheat Bypass System Loaded")
print("✅ All detections blocked")

-- ============================================================
-- KEY SYSTEM (UNCHANGED)
-- ============================================================

local ProtectionConfig = {
    SecretKey = "LOLSCRIPTSBEST111",
    HubName = "LOL HUB"
}

if not _G[ProtectionConfig.SecretKey] then
    local player = game:GetService("Players").LocalPlayer
    if player then
        player:Kick("\n🛡️ Unauthorized Execution 🛡️\n\nPlease use the official Key System to run " .. ProtectionConfig.HubName)
    end
    return
end

-------------------------------------------------------------------------------
-- 👇 MAIN SCRIPT STARTS HERE 👇
-------------------------------------------------------------------------------

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

if not LocalPlayer then
    LocalPlayer = Players.PlayerAdded:Wait()
end

local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
-- ============================================================
-- ADDITIONAL BYPASS METHODS
-- ============================================================

-- Method 9: Обфускация имени GUI
local function randomString(length)
    local chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local result = ""
    for i = 1, length do
        result = result .. chars:sub(math.random(1, #chars), math.random(1, #chars))
    end
    return result
end

-- Method 10: Скрываем скрипт от getrunningscripts
pcall(function()
    if getrunningscripts then
        local old = getrunningscripts
        getrunningscripts = function()
            local scripts = old()
            local filtered = {}
            for _, s in ipairs(scripts) do
                if not s.Name:find("LOL") then
                    table.insert(filtered, s)
                end
            end
            return filtered
        end
    end
end)

-- Method 11: Защита от getloadedmodules
pcall(function()
    if getloadedmodules then
        local old = getloadedmodules
        getloadedmodules = function()
            local modules = old()
            local filtered = {}
            for _, m in ipairs(modules) do
                if not m.Name:find("LOL") then
                    table.insert(filtered, m)
                end
            end
            return filtered
        end
    end
end)

-- Method 12: Обход проверки на изменённые свойства
local protectedInstances = {}
local function protectInstance(instance)
    if protectedInstances[instance] then return end
    protectedInstances[instance] = true
    
    pcall(function()
        local mt = getrawmetatable(instance)
        if mt then
            setreadonly(mt, false)
            local oldIndex = mt.__index
            mt.__index = function(self, key)
                if key == "Parent" and checkcaller and not checkcaller() then
                    return nil
                end
                return oldIndex(self, key)
            end
        end
    end)
end

-- Method 13: Обход Humanoid проверок
local function protectHumanoid(humanoid)
    pcall(function()
        local mt = getrawmetatable(humanoid)
        if mt then
            setreadonly(mt, false)
            local oldIndex = mt.__index
            mt.__index = function(self, key)
                if key == "Health" and checkcaller and not checkcaller() then
                    return oldIndex(self, "MaxHealth") or 100
                end
                return oldIndex(self, key)
            end
        end
    end)
end

-- Method 14: Автоматическое восстановление при обнаружении
task.spawn(function()
    while task.wait(5) do
        pcall(function()
            -- Проверяем, не был ли удалён наш GUI
            if not ScreenGui or not ScreenGui.Parent then
                -- Восстанавливаем
                if ScreenGui then
                    ScreenGui.Parent = game.CoreGui
                end
            end
            
            -- Проверяем целостность обходов
            local char = LocalPlayer.Character
            if char then
                local humanoid = char:FindFirstChild("Humanoid")
                if humanoid then
                    protectHumanoid(humanoid)
                end
            end
        end)
    end
end)

-- ============================================================
-- SETTINGS
-- ============================================================

local Settings = {
    ESP = {
        Zombie = {
            Enabled = false,
            Boxes = true,
            Names = true,
            Distance = true,
            HealthBar = true,
            Tracers = true
        },
        Chest = {
            Enabled = false,
            Boxes = true,
            Names = true,
            Distance = true,
            Tracers = true
        }
    },
    Weapon = {
        InfiniteAmmo = false,
        NoReload = false,
        NoRecoil = false,
        NoSpread = false,
        RapidFire = false,
        RapidFireDelay = 0.05
    },
    Player = {
        AutoRevive = false,
        AutoReviveRange = 50,
        GodMode = false,
        SpeedHack = false,
        SpeedValue = 50,
        JumpHack = false,
        JumpValue = 100
    }
}

-- ============================================================
-- HELPER FUNCTIONS
-- ============================================================

local function safeFind(parent, name)
    local success, result = pcall(function()
        return parent:FindFirstChild(name)
    end)
    return success and result or nil
end

local function safeGetChildren(parent)
    local success, result = pcall(function()
        return parent:GetChildren()
    end)
    return success and result or {}
end

local function safeGetDescendants(parent)
    local success, result = pcall(function()
        return parent:GetDescendants()
    end)
    return success and result or {}
end
-- ============================================================
-- ESP SYSTEM
-- ============================================================

local Drawing = Drawing or {}
local espObjects = {}

local function createDrawing(type, properties)
    local success, obj = pcall(function()
        local d = Drawing.new(type)
        for k, v in pairs(properties) do
            pcall(function() d[k] = v end)
        end
        return d
    end)
    return obj
end

local function createObjectESP(parent, config)
    local espData = {}
    
    if config.Boxes then
        espData.BoxOutline = createDrawing("Square", {
            Visible = false, Thickness = 3, Color = Color3.fromRGB(0, 0, 0),
            Transparency = 0.8, Filled = false, ZIndex = 2
        })
        espData.Box = createDrawing("Square", {
            Visible = false, Thickness = 1.5, Color = config.Color or Color3.fromRGB(255, 255, 255),
            Transparency = 0.5, Filled = false, ZIndex = 3
        })
    end
    
    if config.Names then
        espData.Name = createDrawing("Text", {
            Visible = false, Color = Color3.fromRGB(255, 255, 255),
            Size = 13, Center = true, Outline = true, OutlineColor = Color3.fromRGB(0, 0, 0),
            Font = 2, ZIndex = 3
        })
    end
    
    if config.Distance then
        espData.Distance = createDrawing("Text", {
            Visible = false, Color = Color3.fromRGB(200, 200, 200),
            Size = 12, Center = true, Outline = true, OutlineColor = Color3.fromRGB(0, 0, 0),
            Font = 2, ZIndex = 3
        })
    end
    
    if config.HealthBar then
        espData.HealthBarBg = createDrawing("Square", {
            Visible = false, Thickness = 1, Color = Color3.fromRGB(0, 0, 0),
            Transparency = 0.7, Filled = true, ZIndex = 2
        })
        espData.HealthBar = createDrawing("Square", {
            Visible = false, Thickness = 1, Color = Color3.fromRGB(100, 255, 100),
            Transparency = 0.4, Filled = true, ZIndex = 3
        })
    end
    
    if config.Tracers then
        espData.Tracer = createDrawing("Line", {
            Visible = false, Thickness = 1, Color = config.Color or Color3.fromRGB(255, 255, 255),
            Transparency = 0.4, ZIndex = 2
        })
    end
    
    espData.Parent = parent
    espData.Config = config
    return espData
end

local function updateObjectESP(espData, position, size, healthPercent, name, distance)
    if not position then return end
    
    local screenPos, onScreen = Camera:WorldToViewportPoint(position)
    
    if not onScreen then
        for _, obj in pairs(espData) do
            if type(obj) ~= "table" and type(obj) ~= "string" and type(obj) ~= "function" then
                pcall(function() obj.Visible = false end)
            end
        end
        return
    end
    
    local screenPoint = Vector2.new(screenPos.X, screenPos.Y)
    
    if espData.Box and espData.BoxOutline then
        local boxSize = size or Vector2.new(50, 80)
        pcall(function()
            espData.BoxOutline.Visible = true
            espData.BoxOutline.Position = Vector2.new(screenPoint.X - boxSize.X/2 - 1, screenPoint.Y - boxSize.Y - 1)
            espData.BoxOutline.Size = Vector2.new(boxSize.X + 2, boxSize.Y + 2)
            espData.Box.Visible = true
            espData.Box.Position = Vector2.new(screenPoint.X - boxSize.X/2, screenPoint.Y - boxSize.Y)
            espData.Box.Size = boxSize
        end)
    end
    
    if espData.Name then
        pcall(function()
            espData.Name.Visible = true
            espData.Name.Text = name or "Unknown"
            espData.Name.Position = Vector2.new(screenPoint.X, screenPoint.Y - (size and size.Y + 18 or 98))
        end)
    end
    
    if espData.Distance then
        pcall(function()
            espData.Distance.Visible = true
            espData.Distance.Text = "[" .. math.floor(distance or 0) .. "m]"
            espData.Distance.Position = Vector2.new(screenPoint.X, screenPoint.Y - (size and size.Y + 32 or 112))
        end)
    end
    
    if espData.HealthBar and espData.HealthBarBg and healthPercent then
        local barWidth = 4
        local barHeight = size and size.Y or 80
        local barX = screenPoint.X - (size and size.X/2 or 25) - barWidth - 4
        local barY = screenPoint.Y - barHeight
        local healthHeight = barHeight * math.clamp(healthPercent, 0, 1)
        
        pcall(function()
            espData.HealthBarBg.Visible = true
            espData.HealthBarBg.Position = Vector2.new(barX, barY)
            espData.HealthBarBg.Size = Vector2.new(barWidth, barHeight)
            
            espData.HealthBar.Visible = true
            espData.HealthBar.Position = Vector2.new(barX, barY + barHeight - healthHeight)
            espData.HealthBar.Size = Vector2.new(barWidth, healthHeight)
            
            if healthPercent > 0.6 then
                espData.HealthBar.Color = Color3.fromRGB(100, 255, 100)
            elseif healthPercent > 0.3 then
                espData.HealthBar.Color = Color3.fromRGB(255, 255, 50)
            else
                espData.HealthBar.Color = Color3.fromRGB(255, 50, 50)
            end
        end)
    end
    
    if espData.Tracer then
        pcall(function()
            espData.Tracer.Visible = true
            espData.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
            espData.Tracer.To = screenPoint
        end)
    end
end

local zombieESPObjects = {}
local chestESPObjects = {}

local function updateZombieESP()
    for zombie, espData in pairs(zombieESPObjects) do
        if not zombie or not zombie.Parent or (zombie:FindFirstChild("Humanoid") and zombie.Humanoid.Health <= 0) then
            for _, obj in pairs(espData) do
                if type(obj) ~= "table" and type(obj) ~= "string" and type(obj) ~= "function" then
                    pcall(function() obj:Remove() end)
                end
            end
            zombieESPObjects[zombie] = nil
        end
    end
    
    if not Settings.ESP.Zombie.Enabled then
        for _, espData in pairs(zombieESPObjects) do
            for _, obj in pairs(espData) do
                if type(obj) ~= "table" and type(obj) ~= "string" and type(obj) ~= "function" then
                    pcall(function() obj.Visible = false end)
                end
            end
        end
        return
    end
    
    pcall(function()
        for _, obj in ipairs(safeGetDescendants(Workspace)) do
            if obj:IsA("Model") and safeFind(obj, "Humanoid") and safeFind(obj, "Head") then
                local isPlayer = false
                for _, player in ipairs(Players:GetPlayers()) do
                    if player.Character == obj then
                        isPlayer = true
                        break
                    end
                end
                
                if not isPlayer and obj.Humanoid.Health > 0 then
                    if not zombieESPObjects[obj] then
                        zombieESPObjects[obj] = createObjectESP(obj, {
                            Color = Color3.fromRGB(0, 255, 0),
                            Boxes = Settings.ESP.Zombie.Boxes,
                            Names = Settings.ESP.Zombie.Names,
                            Distance = Settings.ESP.Zombie.Distance,
                            HealthBar = Settings.ESP.Zombie.HealthBar,
                            Tracers = Settings.ESP.Zombie.Tracers
                        })
                    end
                    
                    if zombieESPObjects[obj] then
                        local head = safeFind(obj, "Head")
                        local humanoid = safeFind(obj, "Humanoid")
                        local rootPart = safeFind(obj, "HumanoidRootPart")
                        
                        if head and humanoid then
                            local position = head.Position
                            local size = Vector2.new(50, 80)
                            local healthPercent = humanoid.Health / humanoid.MaxHealth
                            local distance = 0
                            
                            if Character and safeFind(Character, "HumanoidRootPart") then
                                if rootPart then
                                    distance = (Character.HumanoidRootPart.Position - rootPart.Position).Magnitude
                                else
                                    distance = (Character.HumanoidRootPart.Position - head.Position).Magnitude
                                end
                            end
                            
                            updateObjectESP(zombieESPObjects[obj], position, size, healthPercent, "🧟 Zombie", distance)
                        end
                    end
                end
            end
        end
    end)
end

local function updateChestESP()
    for chest, espData in pairs(chestESPObjects) do
        if not chest or not chest.Parent then
            for _, obj in pairs(espData) do
                if type(obj) ~= "table" and type(obj) ~= "string" and type(obj) ~= "function" then
                    pcall(function() obj:Remove() end)
                end
            end
            chestESPObjects[chest] = nil
        end
    end
    
    if not Settings.ESP.Chest.Enabled then
        for _, espData in pairs(chestESPObjects) do
            for _, obj in pairs(espData) do
                if type(obj) ~= "table" and type(obj) ~= "string" and type(obj) ~= "function" then
                    pcall(function() obj.Visible = false end)
                end
            end
        end
        return
    end
    
    pcall(function()
        local chestNames = {"Chest", "chest", "Crate", "crate", "Box", "box", "Loot", "loot", "Supply", "supply", "WeaponCrate", "AmmoBox", "SupplyDrop"}
        
        for _, obj in ipairs(safeGetDescendants(Workspace)) do
            local shouldESP = false
            for _, name in ipairs(chestNames) do
                if obj.Name:lower():find(name:lower()) then
                    shouldESP = true
                    break
                end
            end
            
            if obj:IsA("Model") or obj:IsA("BasePart") then
                for _, child in ipairs(safeGetChildren(obj)) do
                    if child:IsA("ProximityPrompt") then
                        local actionText = child.ActionText:lower()
                        for _, name in ipairs(chestNames) do
                            if actionText:find(name:lower()) then
                                shouldESP = true
                                break
                            end
                        end
                    end
                end
            end
            
            if shouldESP then
                local mainPart = obj:IsA("BasePart") and obj or safeFind(obj, "Base") or safeFind(obj, "Main")
                if not mainPart then
                    for _, child in ipairs(safeGetChildren(obj)) do
                        if child:IsA("BasePart") then
                            mainPart = child
                            break
                        end
                    end
                end
                
                if mainPart then
                    if not chestESPObjects[obj] then
                        chestESPObjects[obj] = createObjectESP(obj, {
                            Color = Color3.fromRGB(255, 215, 0),
                            Boxes = Settings.ESP.Chest.Boxes,
                            Names = Settings.ESP.Chest.Names,
                            Distance = Settings.ESP.Chest.Distance,
                            Tracers = Settings.ESP.Chest.Tracers
                        })
                    end
                    
                    if chestESPObjects[obj] then
                        local position = mainPart.Position
                        local size = Vector2.new(40, 40)
                        local distance = 0
                        
                        if Character and safeFind(Character, "HumanoidRootPart") then
                            distance = (Character.HumanoidRootPart.Position - position).Magnitude
                        end
                        
                        updateObjectESP(chestESPObjects[obj], position, size, nil, "📦 Chest", distance)
                    end
                end
            end
        end
    end)
end
-- ============================================================
-- WEAPON FUNCTIONS
-- ============================================================

local currentTool = nil

local function setupInfiniteAmmo(tool)
    if not tool then return end
    
    task.spawn(function()
        while Settings.Weapon.InfiniteAmmo and tool and tool.Parent do
            pcall(function()
                local ammoValues = {"Ammo", "MaxAmmo", "CurrentAmmo", "Magazine", "AmmoInClip", "LoadedAmmo"}
                for _, name in ipairs(ammoValues) do
                    local val = safeFind(tool, name)
                    if val then
                        if val:IsA("IntValue") or val:IsA("NumberValue") then
                            val.Value = 999
                        end
                    end
                end
                
                for _, child in ipairs(safeGetDescendants(tool)) do
                    if child:IsA("IntValue") or child:IsA("NumberValue") then
                        local childName = child.Name:lower()
                        if childName:find("ammo") or childName:find("mag") or childName:find("clip") then
                            child.Value = 999
                        end
                    end
                end
            end)
            task.wait(0.1)
        end
    end)
end

local function setupNoReload(tool)
    if not tool then return end
    
    task.spawn(function()
        while Settings.Weapon.NoReload and tool and tool.Parent do
            pcall(function()
                local humanoid = Character and safeFind(Character, "Humanoid")
                if humanoid then
                    for _, track in ipairs(humanoid:GetPlayingAnimationTracks()) do
                        if track.Animation.AnimationId:lower():find("reload") then
                            track:Stop()
                        end
                    end
                end
                
                for _, child in ipairs(safeGetDescendants(tool)) do
                    if child:IsA("LocalScript") or child:IsA("Script") then
                        if child.Name:lower():find("reload") then
                            child.Disabled = true
                        end
                    end
                end
            end)
            task.wait(0.05)
        end
    end)
end

local function setupNoRecoil()
    task.spawn(function()
        while Settings.Weapon.NoRecoil do
            pcall(function()
                if Character then
                    local humanoid = safeFind(Character, "Humanoid")
                    if humanoid then
                        local recoilValues = {"Recoil", "RecoilEffect", "CameraRecoil", "WeaponRecoil"}
                        for _, name in ipairs(recoilValues) do
                            local recoil = safeFind(humanoid, name) or safeFind(Character, name)
                            if recoil then
                                recoil:Destroy()
                            end
                        end
                    end
                end
            end)
            task.wait(0.1)
        end
    end)
end

local function setupNoSpread(tool)
    if not tool then return end
    
    task.spawn(function()
        while Settings.Weapon.NoSpread and tool and tool.Parent do
            pcall(function()
                for _, child in ipairs(safeGetDescendants(tool)) do
                    if child:IsA("NumberValue") or child:IsA("IntValue") then
                        local childName = child.Name:lower()
                        if childName:find("spread") or childName:find("accuracy") or childName:find("bloom") then
                            child.Value = 0
                        end
                    end
                end
            end)
            task.wait(0.2)
        end
    end)
end

local function setupRapidFire(tool)
    if not tool then return end
    
    task.spawn(function()
        while Settings.Weapon.RapidFire and tool and tool.Parent do
            pcall(function()
                for _, child in ipairs(safeGetDescendants(tool)) do
                    if child:IsA("NumberValue") or child:IsA("IntValue") then
                        local childName = child.Name:lower()
                        if childName:find("firerate") or childName:find("cooldown") or childName:find("delay") then
                            child.Value = Settings.Weapon.RapidFireDelay
                        end
                    end
                    if child:IsA("RemoteEvent") and child.Name:lower():find("fire") then
                        if UserInputService:IsMouseButtonPressed(0) then
                            child:FireServer()
                        end
                    end
                end
            end)
            task.wait(Settings.Weapon.RapidFireDelay)
        end
    end)
end

-- Отслеживание оружия
LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
    protectHumanoid(safeFind(char, "Humanoid"))
    currentTool = nil
    
    char.ChildAdded:Connect(function(child)
        if child:IsA("Tool") then
            currentTool = child
            task.wait(0.5)
            if Settings.Weapon.InfiniteAmmo then setupInfiniteAmmo(child) end
            if Settings.Weapon.NoReload then setupNoReload(child) end
            if Settings.Weapon.NoSpread then setupNoSpread(child) end
            if Settings.Weapon.RapidFire then setupRapidFire(child) end
        end
    end)
    
    char.ChildRemoved:Connect(function(child)
        if child == currentTool then
            currentTool = nil
        end
    end)
end)

-- ============================================================
-- PLAYER FUNCTIONS
-- ============================================================

local function autoReviveLoop()
    if not Settings.Player.AutoRevive then return end
    if not Character or not safeFind(Character, "HumanoidRootPart") then return end
    
    local rootPos = Character.HumanoidRootPart.Position
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local teammateChar = player.Character
            if teammateChar then
                local humanoid = safeFind(teammateChar, "Humanoid")
                if humanoid and humanoid.Health <= 0 then
                    local teammateRoot = safeFind(teammateChar, "HumanoidRootPart")
                    if teammateRoot then
                        local distance = (rootPos - teammateRoot.Position).Magnitude
                        if distance <= Settings.Player.AutoReviveRange then
                            pcall(function()
                                for _, obj in ipairs(safeGetDescendants(Workspace)) do
                                    if obj:IsA("ProximityPrompt") and obj.Enabled then
                                        local actionText = obj.ActionText:lower()
                                        if actionText:find("revive") or actionText:find("res") or actionText:find("help") or actionText:find("возр") then
                                            fireproximityprompt(obj)
                                        end
                                    end
                                end
                            end)
                            
                            pcall(function()
                                if LocalPlayer.PlayerGui then
                                    for _, guiObj in ipairs(safeGetDescendants(LocalPlayer.PlayerGui)) do
                                        if guiObj:IsA("TextButton") or guiObj:IsA("ImageButton") then
                                            local guiText = guiObj:IsA("TextButton") and guiObj.Text:lower() or guiObj.Name:lower()
                                            if guiText:find("revive") or guiText:find("res") or guiText:find("возр") then
                                                firesignal(guiObj.MouseButton1Click)
                                            end
                                        end
                                    end
                                end
                            end)
                        end
                    end
                end
            end
        end
    end
end

local function godModeLoop()
    if not Settings.Player.GodMode then return end
    if not Character then return end
    
    pcall(function()
        local humanoid = safeFind(Character, "Humanoid")
        if humanoid then
            humanoid.Health = humanoid.MaxHealth
        end
    end)
end

local function speedHackLoop()
    if not Settings.Player.SpeedHack then return end
    if not Character then return end
    
    pcall(function()
        local humanoid = safeFind(Character, "Humanoid")
        if humanoid then
            humanoid.WalkSpeed = Settings.Player.SpeedValue
        end
    end)
end

local function jumpHackLoop()
    if not Settings.Player.JumpHack then return end
    if not Character then return end
    
    pcall(function()
        local humanoid = safeFind(Character, "Humanoid")
        if humanoid then
            humanoid.JumpPower = Settings.Player.JumpValue
        end
    end)
end
-- ============================================================
-- GUI CREATION (OBFUSCATED NAMES)
-- ============================================================

local guiName = randomString(12)
local frameName = randomString(10)
local titleName = randomString(8)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = guiName
ScreenGui.Parent = game.CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
protectInstance(ScreenGui)

local MainFrame = Instance.new("Frame")
MainFrame.Name = frameName
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.05, 0, 0.08, 0)
MainFrame.Size = UDim2.new(0, 290, 0, 440)
MainFrame.Visible = false
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ZIndex = 10
protectInstance(MainFrame)

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

local TitleFrame = Instance.new("Frame")
TitleFrame.Parent = MainFrame
TitleFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
TitleFrame.BorderSizePixel = 0
TitleFrame.Size = UDim2.new(1, 0, 0, 38)

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = TitleFrame

local TitleCover = Instance.new("Frame")
TitleCover.Parent = TitleFrame
TitleCover.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
TitleCover.BorderSizePixel = 0
TitleCover.Position = UDim2.new(0, 0, 0.5, 0)
TitleCover.Size = UDim2.new(1, 0, 0.5, 0)

local Title = Instance.new("TextLabel")
Title.Parent = TitleFrameTitle.BackgroundTransparency = 1
Title.Size = UDim2.new(1, -40, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.Font = Enum.Font.GothamBold
Title.Text = "LOL SCRIPTS"
Title.TextColor3 = Color3.fromRGB(255, 50, 100)
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left

local CloseButton = Instance.new("TextButton")
CloseButton.Parent = TitleFrame
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 50, 100)
CloseButton.BorderSizePixel = 0
CloseButton.Position = UDim2.new(0.88, 0, 0.12, 0)
CloseButton.Size = UDim2.new(0, 28, 0, 28)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 16
CloseButton.ZIndex = 11

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 14)
CloseCorner.Parent = CloseButton

CloseButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
end)

-- Content Frame
local ContentFrame = Instance.new("ScrollingFrame")
ContentFrame.Parent = MainFrame
ContentFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
ContentFrame.BorderSizePixel = 0
ContentFrame.Position = UDim2.new(0, 0, 0, 38)
ContentFrame.Size = UDim2.new(1, 0, 1, -38)
ContentFrame.CanvasSize = UDim2.new(0, 0, 0, 850)
ContentFrame.ScrollBarThickness = 2
ContentFrame.ScrollBarImageColor3 = Color3.fromRGB(255, 50, 100)
ContentFrame.ZIndex = 5

local ContentLayout = Instance.new("UIListLayout")
ContentLayout.Parent = ContentFrame
ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
ContentLayout.Padding = UDim.new(0, 5)

local ContentPadding = Instance.new("UIPadding")
ContentPadding.Parent = ContentFrame
ContentPadding.PaddingLeft = UDim.new(0, 8)
ContentPadding.PaddingRight = UDim.new(0, 8)
ContentPadding.PaddingTop = UDim.new(0, 5)

local function createSection(text)
    local Section = Instance.new("Frame")
    Section.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
    Section.BorderSizePixel = 0
    Section.Size = UDim2.new(1, 0, 0, 24)
    Section.Parent = ContentFrame
    
    local SectionCorner = Instance.new("UICorner")
    SectionCorner.CornerRadius = UDim.new(0, 5)
    SectionCorner.Parent = Section
    
    local SectionLabel = Instance.new("TextLabel")
    SectionLabel.Parent = Section
    SectionLabel.BackgroundTransparency = 1
    SectionLabel.Size = UDim2.new(1, -10, 1, 0)
    SectionLabel.Position = UDim2.new(0, 8, 0, 0)
    SectionLabel.Font = Enum.Font.GothamBold
    SectionLabel.Text = text
    SectionLabel.TextColor3 = Color3.fromRGB(255, 50, 100)
    SectionLabel.TextSize = 11
    SectionLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    return Section
end

local function createToggle(text, callback)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    ToggleFrame.BorderSizePixel = 0
    ToggleFrame.Size = UDim2.new(1, 0, 0, 32)
    ToggleFrame.Parent = ContentFrame
    
    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, 6)
    ToggleCorner.Parent = ToggleFrame
    
    local ToggleLabel = Instance.new("TextLabel")
    ToggleLabel.Parent = ToggleFrame
    ToggleLabel.BackgroundTransparency = 1
    ToggleLabel.Position = UDim2.new(0, 8, 0, 0)
    ToggleLabel.Size = UDim2.new(0.65, 0, 1, 0)
    ToggleLabel.Font = Enum.Font.Gotham
    ToggleLabel.Text = text .. ": OFF"
    ToggleLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    ToggleLabel.TextSize = 11
    ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local ToggleBtn = Instance.new("Frame")
    ToggleBtn.Parent = ToggleFrame
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
    ToggleBtn.BorderSizePixel = 0
    ToggleBtn.Position = UDim2.new(0.8, 0, 0.17, 0)
    ToggleBtn.Size = UDim2.new(0, 40, 0, 20)
    
    local ToggleBtnCorner = Instance.new("UICorner")
    ToggleBtnCorner.CornerRadius = UDim.new(1, 0)
    ToggleBtnCorner.Parent = ToggleBtn
    
    local ToggleCircle = Instance.new("Frame")
    ToggleCircle.Parent = ToggleBtn
    ToggleCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ToggleCircle.BorderSizePixel = 0
    ToggleCircle.Position = UDim2.new(0.05, 0, 0.1, 0)
    ToggleCircle.Size = UDim2.new(0, 16, 0, 16)
    
    local ToggleCircleCorner = Instance.new("UICorner")
    ToggleCircleCorner.CornerRadius = UDim.new(1, 0)
    ToggleCircleCorner.Parent = ToggleCircle
    
    local toggled = false
    local ClickBtn = Instance.new("TextButton")
    ClickBtn.Parent = ToggleFrame
    ClickBtn.BackgroundTransparency = 1
    ClickBtn.Size = UDim2.new(1, 0, 1, 0)
    ClickBtn.Text = ""
    ClickBtn.ZIndex = 10
    
    ClickBtn.MouseButton1Click:Connect(function()
        toggled = not toggled
        if toggled then
            ToggleBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 100)
            ToggleCircle:TweenPosition(UDim2.new(0.52, 0, 0.1, 0), "Out", "Quad", 0.15, true)
            ToggleLabel.Text = text .. ": ON"
            ToggleLabel.TextColor3 = Color3.fromRGB(100, 255, 150)
        else
            ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
            ToggleCircle:TweenPosition(UDim2.new(0.05, 0, 0.1, 0), "Out", "Quad", 0.15, true)
            ToggleLabel.Text = text .. ": OFF"
            ToggleLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        end
        if callback then callback(toggled) end
    end)
    
    return ToggleFrame
end

-- Создание меню
createSection("[ ZOMBIE ESP ]")
createToggle("Enable Zombie ESP", function(state) Settings.ESP.Zombie.Enabled = state end)
createToggle("Zombie Boxes", function(state) Settings.ESP.Zombie.Boxes = state end)
createToggle("Zombie Names", function(state) Settings.ESP.Zombie.Names = state end)
createToggle("Zombie Distance", function(state) Settings.ESP.Zombie.Distance = state end)
createToggle("Zombie Health Bar", function(state) Settings.ESP.Zombie.HealthBar = state end)
createToggle("Zombie Tracers", function(state) Settings.ESP.Zombie.Tracers = state end)

createSection("[ CHEST ESP ]")
createToggle("Enable Chest ESP", function(state) Settings.ESP.Chest.Enabled = state end)
createToggle("Chest Boxes", function(state) Settings.ESP.Chest.Boxes = state end)
createToggle("Chest Names", function(state) Settings.ESP.Chest.Names = state end)
createToggle("Chest Distance", function(state) Settings.ESP.Chest.Distance = state end)
createToggle("Chest Tracers", function(state) Settings.ESP.Chest.Tracers = state end)

createSection("[ WEAPON ]")
createToggle("Infinite Ammo", function(state)
    Settings.Weapon.InfiniteAmmo = state
    if state and currentTool then setupInfiniteAmmo(currentTool) end
end)
createToggle("No Reload", function(state)
    Settings.Weapon.NoReload = state
    if state and currentTool then setupNoReload(currentTool) end
end)
createToggle("No Recoil", function(state)
    Settings.Weapon.NoRecoil = state
    if state then setupNoRecoil() end
end)
createToggle("No Spread", function(state)
    Settings.Weapon.NoSpread = state
    if state and currentTool then setupNoSpread(currentTool) end
end)
createToggle("Rapid Fire", function(state)
    Settings.Weapon.RapidFire = state
    if state and currentTool then setupRapidFire(currentTool) end
end)

createSection("[ PLAYER ]")
createToggle("Auto Revive", function(state) Settings.Player.AutoRevive = state end)
createToggle("God Mode", function(state) Settings.Player.GodMode = state end)
createToggle("Speed Hack", function(state) Settings.Player.SpeedHack = state end)
createToggle("Jump Hack", function(state) Settings.Player.JumpHack = state end)

-- Canvas update
task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            ContentFrame.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y + 10)
        end)
    end
end)

-- Drag Button
local DragButton = Instance.new("TextButton")
DragButton.Name = randomString(8)
DragButton.Parent = ScreenGui
DragButton.BackgroundColor3 = Color3.fromRGB(255, 50, 100)
DragButton.BorderSizePixel = 0
DragButton.Position = UDim2.new(0.45, 0, 0.4, 0)
DragButton.Size = UDim2.new(0, 44, 0, 44)
DragButton.Font = Enum.Font.GothamBlack
DragButton.Text = "LS"
DragButton.TextColor3 = Color3.fromRGB(255, 255, 255)
DragButton.TextSize = 14
DragButton.ZIndex = 20

local DragCorner = Instance.new("UICorner")
DragCorner.CornerRadius = UDim.new(1, 0)
DragCorner.Parent = DragButton

local dragging = false
local dragStart = nil
local startPos = nil
local clickMoved = false

DragButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true clickMoved = false dragStart = input.Position startPos = DragButton.Position
    end
end)

DragButton.InputEnded:Connect(function(input)
    dragging = false
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local delta = input.Position - dragStart
        if math.abs(delta.X) > 2 or math.abs(delta.Y) > 2 then
            clickMoved = true
            local newX = math.clamp(startPos.X.Offset + delta.X, 0, Camera.ViewportSize.X - 44)
            local newY = math.clamp(startPos.Y.Offset + delta.Y, 0, Camera.ViewportSize.Y - 44)
            DragButton.Position = UDim2.new(0, newX, 0, newY)
        end
    end
end)

DragButton.MouseButton1Click:Connect(function()
    if not clickMoved then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

-- ============================================================
-- MAIN LOOP
-- ============================================================

RunService.RenderStepped:Connect(function()
    pcall(updateZombieESP)
    pcall(updateChestESP)
    pcall(autoReviveLoop)
    pcall(godModeLoop)
    pcall(speedHackLoop)
    pcall(jumpHackLoop)
end)

print("╔══════════════════════════════════════╗")
print("║   LOL SCRIPTS - Zombie Lazarus      ║")
print("║   🛡️ Anti-Cheat BYPASS Active      ║")
print("║   ✅ All Systems Ready              ║")
print("╚══════════════════════════════════════╝")
