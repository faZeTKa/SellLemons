--[[
    ================================================================
    [ SCRIPT INFORMATION ]
    Project: Zombie Project Lazarus
    Author: OYB
    YouTube: https://www.youtube.com/channel/UCAlXXV1Hbvf7WbfXARuVtiQ
    
    [ TERMS AND CONDITIONS ]
    - You ARE allowed to use and modify this script for your own games.
    - You ARE NOT allowed to re-upload, redistribute, or claim 
      ownership of this script.
    - Removing or altering these credits is strictly prohibited.
    
    Copyright (c) 2026 OYB. All rights reserved.
    ================================================================
]]

-- ⚠️ IMPORTANT: Put this code at the VERY TOP of your Main Script (before obfuscating) ⚠️

local ProtectionConfig = {
    SecretKey = "LOLSCRIPTSBEST111",
    HubName = "LOL HUB"
}

-- Anti-Bypass Logic
if not _G[ProtectionConfig.SecretKey] then
    local player = game:GetService("Players").LocalPlayer
    if player then
        player:Kick("\n🛡️ Unauthorized Execution 🛡️\n\nPlease use the official Key System to run " .. ProtectionConfig.HubName)
    end
    return
end

-------------------------------------------------------------------------------
-- 👇 MAIN SCRIPT FOR ZOMBIE PROJECT LAZARUS 👇
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

-- Ждём загрузки персонажа
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

-- Настройки
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
    Aimbot = {
        Enabled = false,
        FOV = 200,
        ShowFOV = false,
        WallCheck = true,
        Smoothness = 3,
        TargetPart = "Head"
    },
    Weapon = {
        NoReload = false,
        InfiniteAmmo = false,
        NoRecoil = false,
        NoSpread = false,
        RapidFire = false,
        RapidFireDelay = 0.05
    },
    Player = {
        AutoRevive = false,
        AutoReviveRange = 50,
        WalkSpeed = 16,
        JumpPower = 50,
        GodMode = false
    }
}

-- Оригинальные значения для восстановления
local OriginalValues = {
    WalkSpeed = 16,
    JumpPower = 50,
    FieldOfView = 70
}

print("╔══════════════════════════════════════╗")
print("║   LOL SCRIPTS - Zombie Lazarus      ║")
print("║   Loaded Successfully!              ║")
print("╚══════════════════════════════════════╝")
-- ============================================================
-- ESP SYSTEM
-- ============================================================

-- Подключаем Drawing API (работает в Delta, Xeno, CodeX, Arceus X)
local Drawing = Drawing or {}
local espObjects = {}

-- Функция безопасного создания Drawing объектов
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

-- Очистка ESP объектов
local function clearESP()
    for _, obj in pairs(espObjects) do
        pcall(function() obj:Remove() end)
    end
    espObjects = {}
end

-- Создание ESP для одного объекта
local function createObjectESP(parent, config)
    local espData = {}
    
    -- Box
    if config.Boxes then
        local boxOutline = createDrawing("Square", {
            Visible = false, Thickness = 3, Color = Color3.fromRGB(0, 0, 0),
            Transparency = 0.8, Filled = false, ZIndex = 2
        })
        local box = createDrawing("Square", {
            Visible = false, Thickness = 1.5, Color = config.Color or Color3.fromRGB(255, 255, 255),
            Transparency = 0.5, Filled = false, ZIndex = 3
        })
        espData.BoxOutline = boxOutline
        espData.Box = box
    end
    
    -- Name
    if config.Names then
        local nameTag = createDrawing("Text", {
            Visible = false, Color = Color3.fromRGB(255, 255, 255),
            Size = 13, Center = true, Outline = true, OutlineColor = Color3.fromRGB(0, 0, 0),
            Font = 2, ZIndex = 3
        })
        espData.Name = nameTag
    end
    
    -- Distance
    if config.Distance then
        local distanceTag = createDrawing("Text", {
            Visible = false, Color = Color3.fromRGB(200, 200, 200),
            Size = 12, Center = true, Outline = true, OutlineColor = Color3.fromRGB(0, 0, 0),
            Font = 2, ZIndex = 3
        })
        espData.Distance = distanceTag
    end
    
    -- Health Bar
    if config.HealthBar then
        local healthBarBg = createDrawing("Square", {
            Visible = false, Thickness = 1, Color = Color3.fromRGB(0, 0, 0),
            Transparency = 0.7, Filled = true, ZIndex = 2
        })
        local healthBar = createDrawing("Square", {
            Visible = false, Thickness = 1, Color = Color3.fromRGB(100, 255, 100),
            Transparency = 0.4, Filled = true, ZIndex = 3
        })
        espData.HealthBarBg = healthBarBg
        espData.HealthBar = healthBar
    end
    
    -- Tracer
    if config.Tracers then
        local tracer = createDrawing("Line", {
            Visible = false, Thickness = 1, Color = config.Color or Color3.fromRGB(255, 255, 255),
            Transparency = 0.4, ZIndex = 2
        })
        espData.Tracer = tracer
    end
    
    espData.Parent = parent
    espData.Config = config
    return espData
end

-- Обновление позиций ESP
local function updateObjectESP(espData, position, size, healthPercent, name, distance)
    if not position then return end
    
    local screenPos, onScreen = Camera:WorldToViewportPoint(position)
    
    if not onScreen then
        for _, obj in pairs(espData) do
            if type(obj) == "table" and obj.Visible ~= nil then
                obj.Visible = false
            end
        end
        return
    end
    
    local screenPoint = Vector2.new(screenPos.X, screenPos.Y)
    
    -- Box
    if espData.Box and espData.BoxOutline then
        local boxSize = size or Vector2.new(50, 80)
        espData.BoxOutline.Visible = true
        espData.BoxOutline.Position = Vector2.new(screenPoint.X - boxSize.X/2 - 1, screenPoint.Y - boxSize.Y - 1)
        espData.BoxOutline.Size = Vector2.new(boxSize.X + 2, boxSize.Y + 2)
        espData.Box.Visible = true
        espData.Box.Position = Vector2.new(screenPoint.X - boxSize.X/2, screenPoint.Y - boxSize.Y)
        espData.Box.Size = boxSize
    end
    
    -- Name
    if espData.Name then
        espData.Name.Visible = true
        espData.Name.Text = name or "Unknown"
        espData.Name.Position = Vector2.new(screenPoint.X, screenPoint.Y - (size and size.Y + 18 or 98))
    end
    
    -- Distance
    if espData.Distance then
        espData.Distance.Visible = true
        espData.Distance.Text = "[" .. math.floor(distance or 0) .. "m]"
        espData.Distance.Position = Vector2.new(screenPoint.X, screenPoint.Y - (size and size.Y + 32 or 112))
    end
    
    -- Health Bar
    if espData.HealthBar and espData.HealthBarBg and healthPercent then
        local barWidth = 4
        local barHeight = size and size.Y or 80
        local barX = screenPoint.X - (size and size.X/2 or 25) - barWidth - 4
        local barY = screenPoint.Y - barHeight
        local healthHeight = barHeight * math.clamp(healthPercent, 0, 1)
        
        espData.HealthBarBg.Visible = true
        espData.HealthBarBg.Position = Vector2.new(barX, barY)
        espData.HealthBarBg.Size = Vector2.new(barWidth, barHeight)
        
        espData.HealthBar.Visible = true
        espData.HealthBar.Position = Vector2.new(barX, barY + barHeight - healthHeight)
        espData.HealthBar.Size = Vector2.new(barWidth, healthHeight)
        
        -- Цвет хп бара
        if healthPercent > 0.6 then
            espData.HealthBar.Color = Color3.fromRGB(100, 255, 100)
        elseif healthPercent > 0.3 then
            espData.HealthBar.Color = Color3.fromRGB(255, 255, 50)
        else
            espData.HealthBar.Color = Color3.fromRGB(255, 50, 50)
        end
    end
    
    -- Tracer
    if espData.Tracer then
        espData.Tracer.Visible = true
        espData.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
        espData.Tracer.To = screenPoint
    end
end

-- Хранилище ESP объектов
local zombieESPObjects = {}
local chestESPObjects = {}

-- Обновление ESP зомби
local function updateZombieESP()
    -- Очищаем старые объекты
    for zombie, espData in pairs(zombieESPObjects) do
        if not zombie or not zombie.Parent or (zombie:FindFirstChild("Humanoid") and zombie.Humanoid.Health <= 0) then
            for _, obj in pairs(espData) do
                if type(obj) ~= "table" then pcall(function() obj:Remove() end) end
            end
            zombieESPObjects[zombie] = nil
        end
    end
    
    if not Settings.ESP.Zombie.Enabled then
        for _, espData in pairs(zombieESPObjects) do
            for _, obj in pairs(espData) do
                if type(obj) ~= "table" then pcall(function() obj.Visible = false end) end
            end
        end
        return
    end
    
    -- Поиск зомби
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj:FindFirstChild("Head") then
            -- Проверяем, зомби ли это (не игрок)
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
                        Color = Color3.fromRGB(0, 255, 0), -- Зелёный для зомби
                        Boxes = Settings.ESP.Zombie.Boxes,
                        Names = Settings.ESP.Zombie.Names,
                        Distance = Settings.ESP.Zombie.Distance,
                        HealthBar = Settings.ESP.Zombie.HealthBar,
                        Tracers = Settings.ESP.Zombie.Tracers
                    })
                end
                
                if zombieESPObjects[obj] then
                    local head = obj:FindFirstChild("Head")
                    local humanoid = obj:FindFirstChild("Humanoid")
                    local rootPart = obj:FindFirstChild("HumanoidRootPart")
                    
                    if head and humanoid then
                        local position = head.Position
                        local size = Vector2.new(50, 80)
                        local healthPercent = humanoid.Health / humanoid.MaxHealth
                        local distance = 0
                        
                        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                            if rootPart then
                                distance = (LocalPlayer.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude
                            else
                                distance = (LocalPlayer.Character.HumanoidRootPart.Position - head.Position).Magnitude
                            end
                        end
                        
                        updateObjectESP(zombieESPObjects[obj], position, size, healthPercent, "Zombie", distance)
                    end
                end
            end
        end
    end
end

-- Обновление ESP сундуков
local function updateChestESP()
    -- Очистка
    for chest, espData in pairs(chestESPObjects) do
        if not chest or not chest.Parent then
            for _, obj in pairs(espData) do
                if type(obj) ~= "table" then pcall(function() obj:Remove() end) end
            end
            chestESPObjects[chest] = nil
        end
    end
    
    if not Settings.ESP.Chest.Enabled then
        for _, espData in pairs(chestESPObjects) do
            for _, obj in pairs(espData) do
                if type(obj) ~= "table" then pcall(function() obj.Visible = false end) end
            end
        end
        return
    end
    
    -- Поиск сундуков (разные возможные названия)
    local chestNames = {"Chest", "chest", "Crate", "crate", "Box", "box", "Loot", "loot", "Supply", "supply", "WeaponCrate", "AmmoBox", "SupplyDrop"}
    
    for _, obj in ipairs(Workspace:GetDescendants()) do
        local shouldESP = false
        for _, name in ipairs(chestNames) do
            if obj.Name:lower():find(name:lower()) then
                shouldESP = true
                break
            end
        end
        
        -- Также проверяем по наличию дочерних объектов (ProximityPrompt, Sparkles, Parts с определёнными именами)
        if obj:IsA("Model") or obj:IsA("BasePart") then
            for _, child in ipairs(obj:GetChildren()) do
                if child:IsA("ProximityPrompt") then
                    for _, name in ipairs(chestNames) do
                        if child.Name:lower():find(name:lower()) or child.ActionText:lower():find(name:lower()) or child.ObjectText:lower():find(name:lower()) then
                            shouldESP = true
                            break
                        end
                    end
                end
                if child:IsA("Sparkles") or child.Name:lower():find("glow") or child.Name:lower():find("highlight") then
                    shouldESP = true
                end
            end
        end
        
        if shouldESP then
            local mainPart = obj:IsA("BasePart") and obj or obj:FindFirstChild("Base") or obj:FindFirstChild("Main") or obj:FindFirstChildWhichIsA("BasePart")
            
            if mainPart then
                if not chestESPObjects[obj] then
                    chestESPObjects[obj] = createObjectESP(obj, {
                        Color = Color3.fromRGB(255, 215, 0), -- Золотой для сундуков
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
                    
                    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        distance = (LocalPlayer.Character.HumanoidRootPart.Position - position).Magnitude
                    end
                    
                    updateObjectESP(chestESPObjects[obj], position, size, nil, "📦 Chest", distance)
                end
            end
        end
    end
end
-- ============================================================
-- WEAPON FUNCTIONS
-- ============================================================

-- Бесконечные патроны + No Reload
local function setupInfiniteAmmo(tool)
    if not tool then return end
    
    task.spawn(function()
        while Settings.Weapon.InfiniteAmmo and tool and tool.Parent do
            pcall(function()
                -- Обходим магазин
                if tool:FindFirstChild("Ammo") then
                    tool.Ammo.Value = 999
                end
                if tool:FindFirstChild("MaxAmmo") then
                    tool.MaxAmmo.Value = 999
                end
                if tool:FindFirstChild("CurrentAmmo") then
                    tool.CurrentAmmo.Value = 999
                end
                if tool:FindFirstChild("Magazine") then
                    tool.Magazine.Value = 999
                end
                if tool:FindFirstChild("AmmoInClip") then
                    tool.AmmoInClip.Value = 999
                end
                
                -- Ищем скрипты патронов в туле
                for _, child in ipairs(tool:GetDescendants()) do
                    if child:IsA("IntValue") or child:IsA("NumberValue") then
                        if child.Name:lower():find("ammo") or child.Name:lower():find("mag") or child.Name:lower():find("clip") then
                            child.Value = 999
                        end
                    end
                    if child:IsA("LocalScript") or child:IsA("ModuleScript") then
                        -- Отключаем скрипты перезарядки
                        if child.Name:lower():find("reload") then
                            child.Disabled = true
                        end
                    end
                end
            end)
            task.wait(0.1)
        end
    end)
    
    -- No Reload
    task.spawn(function()
        while Settings.Weapon.NoReload and tool and tool.Parent do
            pcall(function()
                -- Отключаем анимации перезарядки
                local humanoid = Character:FindFirstChild("Humanoid")
                if humanoid then
                    for _, track in ipairs(humanoid:GetPlayingAnimationTracks()) do
                        if track.Animation.AnimationId:lower():find("reload") then
                            track:Stop()
                        end
                    end
                end
                
                -- Принудительно устанавливаем патроны
                if tool:FindFirstChild("Ammo") then
                    local ammo = tool.Ammo
                    if ammo.Value < 1 then
                        ammo.Value = 999
                    end
                end
            end)
            task.wait(0.05)
        end
    end)
end

-- No Recoil
local function setupNoRecoil()
    task.spawn(function()
        while Settings.Weapon.NoRecoil do
            pcall(function()
                if Character then
                    local humanoid = Character:FindFirstChild("Humanoid")
                    if humanoid then
                        -- Сбрасываем отдачу через изменение положения камеры
                        local recoil = humanoid:FindFirstChild("Recoil") or humanoid:FindFirstChild("RecoilEffect")
                        if recoil then
                            recoil:Destroy()
                        end
                    end
                end
            end)
            task.wait(0.1)
        end
    end)
end

-- No Spread
local function setupNoSpread(tool)
    if not tool then return end
    
    task.spawn(function()
        while Settings.Weapon.NoSpread and tool and tool.Parent do
            pcall(function()
                for _, child in ipairs(tool:GetDescendants()) do
                    if child:IsA("NumberValue") or child:IsA("IntValue") then
                        if child.Name:lower():find("spread") or child.Name:lower():find("accuracy") then
                            child.Value = 0
                        end
                    end
                end
            end)
            task.wait(0.2)
        end
    end)
end

-- Rapid Fire
local function setupRapidFire(tool)
    if not tool then return end
    
    task.spawn(function()
        while Settings.Weapon.RapidFire and tool and tool.Parent do
            pcall(function()
                -- Уменьшаем задержку между выстрелами
                for _, child in ipairs(tool:GetDescendants()) do
                    if child:IsA("NumberValue") or child:IsA("IntValue") then
                        if child.Name:lower():find("firerate") or child.Name:lower():find("cooldown") or child.Name:lower():find("delay") then
                            child.Value = Settings.Weapon.RapidFireDelay
                        end
                    end
                    if child.Name:lower():find("fire") and child:IsA("RemoteEvent") then
                        -- Авто-спам выстрелов
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

-- Отслеживание текущего оружия
local currentTool = nil
Character.ChildAdded:Connect(function(child)
    if child:IsA("Tool") then
        currentTool = child
        task.wait(0.5)
        if Settings.Weapon.InfiniteAmmo then setupInfiniteAmmo(child) end
        if Settings.Weapon.NoReload then setupInfiniteAmmo(child) end
        if Settings.Weapon.NoSpread then setupNoSpread(child) end
        if Settings.Weapon.RapidFire then setupRapidFire(child) end
    end
end)

Character.ChildRemoved:Connect(function(child)
    if child == currentTool then
        currentTool = nil
    end
end)

-- ============================================================
-- PLAYER FUNCTIONS
-- ============================================================

-- Авто-возрождение союзников
local function autoReviveLoop()
    if not Settings.Player.AutoRevive then return end
    if not Character or not Character:FindFirstChild("HumanoidRootPart") then return end
    
    local rootPos = Character.HumanoidRootPart.Position
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local teammateChar = player.Character
            if teammateChar and teammateChar:FindFirstChild("Humanoid") then
                if teammateChar.Humanoid.Health <= 0 then
                    -- Союзник мёртв, ищем его позицию
                    local teammateRoot = teammateChar:FindFirstChild("HumanoidRootPart")
                    if teammateRoot then
                        local distance = (rootPos - teammateRoot.Position).Magnitude
                        if distance <= Settings.Player.AutoReviveRange then
                            -- Ищем ProximityPrompt для возрождения
                            for _, obj in ipairs(Workspace:GetDescendants()) do
                                if obj:IsA("ProximityPrompt") and obj.Enabled then
                                    local objPos = obj.Parent and obj.Parent.Position or Vector3.new(0,0,0)
                                    local distToPrompt = (rootPos - objPos).Magnitude
                                    if distToPrompt < 15 then
                                        -- Проверяем, что это возрождение (ищем текст)
                                        local actionText = obj.ActionText:lower()
                                        if actionText:find("revive") or actionText:find("res") or actionText:find("help") or actionText:find("возр") then
                                            pcall(function()
                                                fireproximityprompt(obj)
                                            end)
                                        end
                                    end
                                end
                            end
                            
                            -- Альтернатива: ищем кнопки "Revive" в GUI
                            if LocalPlayer.PlayerGui then
                                for _, guiObj in ipairs(LocalPlayer.PlayerGui:GetDescendants()) do
                                    if (guiObj:IsA("TextButton") or guiObj:IsA("ImageButton")) then
                                        local guiText = guiObj:IsA("TextButton") and guiObj.Text:lower() or guiObj.Name:lower()
                                        if guiText:find("revive") or guiText:find("res") or guiText:find("возр") then
                                            pcall(function()
                                                firesignal(guiObj.MouseButton1Click)
                                            end)
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

-- God Mode
local function godModeLoop()
    if not Settings.Player.GodMode then return end
    if not Character then return end
    
    pcall(function()
        local humanoid = Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.Health = humanoid.MaxHealth
        end
    end)
end
-- ============================================================
-- GUI CREATION
-- ============================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "LolScriptsHub"
ScreenGui.Parent = game.CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.05, 0, 0.1, 0)
MainFrame.Size = UDim2.new(0, 300, 0, 420)
MainFrame.Visible = false
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ZIndex = 10

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
Title.Parent = TitleFrame
Title.BackgroundTransparency = 1
Title.Size = UDim2.new(1, -40, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.Font = Enum.Font.GothamBold
Title.Text = "LOL SCRIPTS - Lazarus"
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
ContentFrame.CanvasSize = UDim2.new(0, 0, 0, 800)
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

-- Функция создания секции
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

-- Функция создания тогла
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

createSection("[ AIMBOT ]")
createToggle("Enable Aimbot", function(state) Settings.Aimbot.Enabled = state end)
createToggle("Show FOV", function(state) Settings.Aimbot.ShowFOV = state end)

createSection("[ WEAPON ]")
createToggle("Infinite Ammo", function(state)
    Settings.Weapon.InfiniteAmmo = state
    if state and currentTool then setupInfiniteAmmo(currentTool) end
end)
createToggle("No Reload", function(state)
    Settings.Weapon.NoReload = state
    if state and currentTool then setupInfiniteAmmo(currentTool) end
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
createToggle("Auto Revive Teammates", function(state) Settings.Player.AutoRevive = state end)
createToggle("God Mode", function(state) Settings.Player.GodMode = state end)

-- Обновление размера канваса
task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            ContentFrame.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y + 10)
        end)
    end
end)

-- Драг-кнопка
local DragButton = Instance.new("TextButton")
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
    updateZombieESP()
    updateChestESP()
    autoReviveLoop()
    godModeLoop()
end)

print("✅ All systems loaded!")
print("📱 Mobile compatible: Delta, Xeno, CodeX, Arceus X")
