--[[
    ================================================================
    [ SCRIPT INFORMATION ]
    Project: Zombie Project Lazarus
    Author: OYB
    YouTube: https://www.youtube.com/channel/UCAlXXV1Hbvf7WbfXARuVtiQ
    
    Copyright (c) 2026 OYB. All rights reserved.
    ================================================================
]]

-- ============================================================
-- KEY SYSTEM (ORIGINAL - DO NOT MODIFY)
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

-- ============================================================
-- SAFE ANTI-CHEAT BYPASS (No crash methods)
-- ============================================================

-- Отключаем анти-чит скрипты в workspace (безопасный метод)
task.spawn(function()
    while task.wait(3) do
        pcall(function()
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("Script") or obj:IsA("LocalScript") then
                    local name = obj.Name:lower()
                    if name:find("anti") or name:find("cheat") or name:find("detect") or name:find("ban") or name:find("kick") then
                        obj.Disabled = true
                    end
                end
            end
        end)
    end
end)

-- Скрываем GUI от поиска
local function randomString(length)
    local chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local result = ""
    for i = 1, length do
        result = result .. chars:sub(math.random(1, #chars), math.random(1, #chars))
    end
    return result
end

print("🛡️ Anti-Cheat loaded")
print("✅ Key System passed")

-- ============================================================
-- SERVICES
-- ============================================================

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
        GodMode = false
    }
}
-- ============================================================
-- DRAWING API SAFE WRAPPER
-- ============================================================

local espObjects = {}

local function newDrawing(type, props)
    local success, drawing = pcall(function()
        local d = Drawing.new(type)
        if d and props then
            for k, v in pairs(props) do
                pcall(function() d[k] = v end)
            end
        end
        return d
    end)
    return drawing
end

local function createESPObject(config)
    local data = {}
    
    if config.Boxes then
        data.BoxOutline = newDrawing("Square", {
            Visible = false, Thickness = 3, Color = Color3.fromRGB(0, 0, 0),
            Transparency = 0.8, Filled = false, ZIndex = 2
        })
        data.Box = newDrawing("Square", {
            Visible = false, Thickness = 1.5, Color = config.Color or Color3.fromRGB(255, 255, 255),
            Transparency = 0.5, Filled = false, ZIndex = 3
        })
    end
    
    if config.Names then
        data.Name = newDrawing("Text", {
            Visible = false, Color = Color3.fromRGB(255, 255, 255),
            Size = 13, Center = true, Outline = true,
            OutlineColor = Color3.fromRGB(0, 0, 0), Font = 2, ZIndex = 3
        })
    end
    
    if config.Distance then
        data.Distance = newDrawing("Text", {
            Visible = false, Color = Color3.fromRGB(200, 200, 200),
            Size = 12, Center = true, Outline = true,
            OutlineColor = Color3.fromRGB(0, 0, 0), Font = 2, ZIndex = 3
        })
    end
    
    if config.HealthBar then
        data.HealthBarBg = newDrawing("Square", {
            Visible = false, Thickness = 1, Color = Color3.fromRGB(0, 0, 0),
            Transparency = 0.7, Filled = true, ZIndex = 2
        })
        data.HealthBar = newDrawing("Square", {
            Visible = false, Thickness = 1, Color = Color3.fromRGB(100, 255, 100),
            Transparency = 0.4, Filled = true, ZIndex = 3
        })
    end
    
    if config.Tracers then
        data.Tracer = newDrawing("Line", {
            Visible = false, Thickness = 1, Color = config.Color or Color3.fromRGB(255, 255, 255),
            Transparency = 0.4, ZIndex = 2
        })
    end
    
    return data
end

local function updateESP(espData, position, size, healthPercent, nameText, distance)
    if not espData or not position then return end
    
    local screenPos, onScreen = pcall(function()
        return Camera:WorldToViewportPoint(position)
    end)
    
    if not screenPos or not onScreen then
        for k, obj in pairs(espData) do
            if type(obj) ~= "string" and type(obj) ~= "function" and type(obj) ~= "table" then
                pcall(function() obj.Visible = false end)
            end
        end
        return
    end
    
    local sx, sy = screenPos.X, screenPos.Y
    
    -- Box
    if espData.Box and espData.BoxOutline then
        local boxSize = size or Vector2.new(50, 80)
        pcall(function()
            espData.BoxOutline.Visible = true
            espData.BoxOutline.Position = Vector2.new(sx - boxSize.X/2 - 1, sy - boxSize.Y - 1)
            espData.BoxOutline.Size = Vector2.new(boxSize.X + 2, boxSize.Y + 2)
            espData.Box.Visible = true
            espData.Box.Position = Vector2.new(sx - boxSize.X/2, sy - boxSize.Y)
            espData.Box.Size = boxSize
        end)
    end
    
    -- Name
    if espData.Name then
        pcall(function()
            espData.Name.Visible = true
            espData.Name.Text = nameText or "???"
            espData.Name.Position = Vector2.new(sx, sy - ((size and size.Y or 80) + 18))
        end)
    end
    
    -- Distance
    if espData.Distance then
        pcall(function()
            espData.Distance.Visible = true
            espData.Distance.Text = "[" .. math.floor(distance or 0) .. "m]"
            espData.Distance.Position = Vector2.new(sx, sy - ((size and size.Y or 80) + 32))
        end)
    end
    
    -- Health Bar
    if espData.HealthBar and espData.HealthBarBg and healthPercent then
        local barW = 4
        local barH = (size and size.Y or 80)
        local barX = sx - (size and size.X/2 or 25) - barW - 4
        local barY = sy - barH
        local healthH = barH * math.clamp(healthPercent, 0, 1)
        
        pcall(function()
            espData.HealthBarBg.Visible = true
            espData.HealthBarBg.Position = Vector2.new(barX, barY)
            espData.HealthBarBg.Size = Vector2.new(barW, barH)
            
            espData.HealthBar.Visible = true
            espData.HealthBar.Position = Vector2.new(barX, barY + barH - healthH)
            espData.HealthBar.Size = Vector2.new(barW, healthH)
            
            if healthPercent > 0.6 then
                espData.HealthBar.Color = Color3.fromRGB(100, 255, 100)
            elseif healthPercent > 0.3 then
                espData.HealthBar.Color = Color3.fromRGB(255, 255, 50)
            else
                espData.HealthBar.Color = Color3.fromRGB(255, 50, 50)
            end
        end)
    end
    
    -- Tracer
    if espData.Tracer then
        pcall(function()
            espData.Tracer.Visible = true
            espData.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
            espData.Tracer.To = Vector2.new(sx, sy)
        end)
    end
end

-- Хранилища ESP
local zombieESP = {}
local chestESP = {}

-- Очистка неактивных ESP
local function cleanupESP(storage)
    for obj, data in pairs(storage) do
        if not obj or not obj.Parent then
            for _, d in pairs(data) do
                if type(d) ~= "string" and type(d) ~= "function" and type(d) ~= "table" then
                    pcall(function() d:Remove() end)
                end
            end
            storage[obj] = nil
        end
    end
end
-- ============================================================
-- ZOMBIE ESP UPDATE
-- ============================================================

local function updateZombieESP()
    cleanupESP(zombieESP)
    
    if not Settings.ESP.Zombie.Enabled then
        for _, data in pairs(zombieESP) do
            for _, d in pairs(data) do
                if type(d) ~= "string" and type(d) ~= "function" and type(d) ~= "table" then
                    pcall(function() d.Visible = false end)
                end
            end
        end
        return
    end
    
    pcall(function()
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") then
                local humanoid = obj:FindFirstChild("Humanoid")
                local head = obj:FindFirstChild("Head")
                
                if humanoid and head and humanoid.Health > 0 then
                    -- Проверяем что это не игрок
                    local isPlayer = false
                    for _, plr in ipairs(Players:GetPlayers()) do
                        if plr.Character == obj then
                            isPlayer = true
                            break
                        end
                    end
                    
                    if not isPlayer then
                        -- Создаём ESP если нет
                        if not zombieESP[obj] then
                            zombieESP[obj] = createESPObject({
                                Color = Color3.fromRGB(0, 255, 0),
                                Boxes = Settings.ESP.Zombie.Boxes,
                                Names = Settings.ESP.Zombie.Names,
                                Distance = Settings.ESP.Zombie.Distance,
                                HealthBar = Settings.ESP.Zombie.HealthBar,
                                Tracers = Settings.ESP.Zombie.Tracers
                            })
                        end
                        
                        -- Обновляем позицию
                        local hp = humanoid.Health / humanoid.MaxHealth
                        local dist = 0
                        if Character and Character:FindFirstChild("HumanoidRootPart") then
                            local root = obj:FindFirstChild("HumanoidRootPart")
                            if root then
                                dist = (Character.HumanoidRootPart.Position - root.Position).Magnitude
                            end
                        end
                        
                        updateESP(zombieESP[obj], head.Position, Vector2.new(50, 80), hp, "🧟 Zombie", dist)
                    end
                end
            end
        end
    end)
end

-- ============================================================
-- CHEST ESP UPDATE
-- ============================================================

local function updateChestESP()
    cleanupESP(chestESP)
    
    if not Settings.ESP.Chest.Enabled then
        for _, data in pairs(chestESP) do
            for _, d in pairs(data) do
                if type(d) ~= "string" and type(d) ~= "function" and type(d) ~= "table" then
                    pcall(function() d.Visible = false end)
                end
            end
        end
        return
    end
    
    pcall(function()
        local keywords = {"chest", "crate", "loot", "supply", "weaponcrate", "ammobox", "box"}
        
        for _, obj in ipairs(Workspace:GetDescendants()) do
            local found = false
            local objName = obj.Name:lower()
            
            -- Проверяем имя
            for _, kw in ipairs(keywords) do
                if objName:find(kw) then
                    found = true
                    break
                end
            end
            
            -- Проверяем ProximityPrompt
            if not found and obj:IsA("Model") then
                for _, child in ipairs(obj:GetChildren()) do
                    if child:IsA("ProximityPrompt") then
                        local txt = child.ActionText:lower() .. child.ObjectText:lower()
                        for _, kw in ipairs(keywords) do
                            if txt:find(kw) then
                                found = true
                                break
                            end
                        end
                    end
                end
            end
            
            if found then
                -- Находим основную часть
                local mainPart = nil
                if obj:IsA("BasePart") then
                    mainPart = obj
                else
                    for _, child in ipairs(obj:GetChildren()) do
                        if child:IsA("BasePart") and not child.Name:lower():find("decal") then
                            mainPart = child
                            break
                        end
                    end
                end
                
                if mainPart then
                    if not chestESP[obj] then
                        chestESP[obj] = createESPObject({
                            Color = Color3.fromRGB(255, 215, 0),
                            Boxes = Settings.ESP.Chest.Boxes,
                            Names = Settings.ESP.Chest.Names,
                            Distance = Settings.ESP.Chest.Distance,
                            Tracers = Settings.ESP.Chest.Tracers
                        })
                    end
                    
                    local dist = 0
                    if Character and Character:FindFirstChild("HumanoidRootPart") then
                        dist = (Character.HumanoidRootPart.Position - mainPart.Position).Magnitude
                    end
                    
                    updateESP(chestESP[obj], mainPart.Position, Vector2.new(35, 35), nil, "📦 "..obj.Name, dist)
                end
            end
        end
    end)
end
-- ============================================================
-- WEAPON FUNCTIONS
-- ============================================================

local currentTool = nil

local function processWeapon(tool)
    if not tool then return end
    
    -- Infinite Ammo
    task.spawn(function()
        while Settings.Weapon.InfiniteAmmo and tool and tool.Parent do
            pcall(function()
                local ammoNames = {"Ammo", "MaxAmmo", "CurrentAmmo", "Magazine", "AmmoInClip", "LoadedAmmo"}
                for _, n in ipairs(ammoNames) do
                    local v = tool:FindFirstChild(n)
                    if v then
                        v.Value = 999
                    end
                end
                
                for _, child in ipairs(tool:GetDescendants()) do
                    if (child:IsA("IntValue") or child:IsA("NumberValue")) and
                       (child.Name:lower():find("ammo") or child.Name:lower():find("mag") or child.Name:lower():find("clip")) then
                        child.Value = 999
                    end
                end
            end)
            task.wait(0.15)
        end
    end)
    
    -- No Reload
    task.spawn(function()
        while Settings.Weapon.NoReload and tool and tool.Parent do
            pcall(function()
                if Character then
                    local hum = Character:FindFirstChild("Humanoid")
                    if hum then
                        for _, track in ipairs(hum:GetPlayingAnimationTracks()) do
                            if track.Animation.AnimationId:lower():find("reload") then
                                track:Stop()
                            end
                        end
                    end
                end
            end)
            task.wait(0.05)
        end
    end)
    
    -- No Spread
    task.spawn(function()
        while Settings.Weapon.NoSpread and tool and tool.Parent do
            pcall(function()
                for _, child in ipairs(tool:GetDescendants()) do
                    if (child:IsA("NumberValue") or child:IsA("IntValue")) and
                       (child.Name:lower():find("spread") or child.Name:lower():find("accuracy") or child.Name:lower():find("bloom")) then
                        child.Value = 0
                    end
                end
            end)
            task.wait(0.2)
        end
    end)
    
    -- Rapid Fire
    task.spawn(function()
        while Settings.Weapon.RapidFire and tool and tool.Parent do
            pcall(function()
                for _, child in ipairs(tool:GetDescendants()) do
                    if (child:IsA("NumberValue") or child:IsA("IntValue")) and
                       (child.Name:lower():find("firerate") or child.Name:lower():find("cooldown") or child.Name:lower():find("delay")) then
                        child.Value = Settings.Weapon.RapidFireDelay
                    end
                    if child:IsA("RemoteEvent") and child.Name:lower():find("fire") and UserInputService:IsMouseButtonPressed(0) then
                        child:FireServer()
                    end
                end
            end)
            task.wait(Settings.Weapon.RapidFireDelay)
        end
    end)
end

-- No Recoil (глобальный)
task.spawn(function()
    while task.wait(0.1) do
        if Settings.Weapon.NoRecoil and Character then
            pcall(function()
                for _, child in ipairs(Character:GetChildren()) do
                    if child.Name:lower():find("recoil") then
                        child:Destroy()
                    end
                end
            end)
        end
    end
end)

-- Отслеживание оружия
LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
    currentTool = nil
    
    char.ChildAdded:Connect(function(child)
        if child:IsA("Tool") then
            currentTool = child
            task.wait(0.3)
            processWeapon(child)
        end
    end)
    
    char.ChildRemoved:Connect(function(child)
        if child == currentTool then
            currentTool = nil
        end
    end)
end)

-- Проверяем уже экипированное оружие
if Character then
    for _, child in ipairs(Character:GetChildren()) do
        if child:IsA("Tool") then
            currentTool = child
            processWeapon(child)
            break
        end
    end
end

-- ============================================================
-- PLAYER FUNCTIONS
-- ============================================================

-- Auto Revive
task.spawn(function()
    while task.wait(0.3) do
        if not Settings.Player.AutoRevive then continue end
        if not Character or not Character:FindFirstChild("HumanoidRootPart") then continue end
        
        pcall(function()
            local myPos = Character.HumanoidRootPart.Position
            
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and plr.Character then
                    local hum = plr.Character:FindFirstChild("Humanoid")
                    if hum and hum.Health <= 0 then
                        local root = plr.Character:FindFirstChild("HumanoidRootPart")
                        if root and (myPos - root.Position).Magnitude <= Settings.Player.AutoReviveRange then
                            -- Ищем кнопку возрождения
                            if LocalPlayer.PlayerGui then
                                for _, gui in ipairs(LocalPlayer.PlayerGui:GetDescendants()) do
                                    if gui:IsA("TextButton") or gui:IsA("ImageButton") then
                                        local txt = gui:IsA("TextButton") and gui.Text:lower() or gui.Name:lower()
                                        if txt:find("revive") or txt:find("возр") or txt:find("ress") then
                                            firesignal(gui.MouseButton1Click)
                                        end
                                    end
                                end
                            end
                            
                            -- Ищем ProximityPrompt
                            for _, obj in ipairs(Workspace:GetDescendants()) do
                                if obj:IsA("ProximityPrompt") and obj.Enabled then
                                    local txt = obj.ActionText:lower()
                                    if txt:find("revive") or txt:find("возр") or txt:find("ress") then
                                        fireproximityprompt(obj)
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end)
    end
end)

-- God Mode
task.spawn(function()
    while task.wait(0.1) do
        if Settings.Player.GodMode and Character then
            pcall(function()
                local hum = Character:FindFirstChild("Humanoid")
                if hum then
                    hum.Health = hum.MaxHealth
                end
            end)
        end
    end
end)
-- ============================================================
-- GUI
-- ============================================================

local guiName = randomString(10)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = guiName
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 22)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.05, 0, 0.08, 0)
MainFrame.Size = UDim2.new(0, 280, 0, 400)
MainFrame.Visible = false
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ZIndex = 10

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

-- Title
local TitleFrame = Instance.new("Frame")
TitleFrame.Parent = MainFrame
TitleFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 32)
TitleFrame.BorderSizePixel = 0
TitleFrame.Size = UDim2.new(1, 0, 0, 36)

Instance.new("UICorner", TitleFrame).CornerRadius = UDim.new(0, 10)

local TitleCover = Instance.new("Frame")
TitleCover.Parent = TitleFrame
TitleCover.BackgroundColor3 = Color3.fromRGB(18, 18, 32)
TitleCover.BorderSizePixel = 0
TitleCover.Position = UDim2.new(0, 0, 0.5, 0)
TitleCover.Size = UDim2.new(1, 0, 0.5, 0)

local Title = Instance.new("TextLabel")
Title.Parent = TitleFrame
Title.BackgroundTransparency = 1
Title.Size = UDim2.new(1, -36, 1, 0)
Title.Position = UDim2.new(0, 12, 0, 0)
Title.Font = Enum.Font.GothamBold
Title.Text = "LOL SCRIPTS"
Title.TextColor3 = Color3.fromRGB(255, 50, 100)
Title.TextSize = 13
Title.TextXAlignment = Enum.TextXAlignment.Left

local CloseBtn = Instance.new("TextButton")
CloseBtn.Parent = TitleFrame
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 100)
CloseBtn.BorderSizePixel = 0
CloseBtn.Position = UDim2.new(0.87, 0, 0.1, 0)
CloseBtn.Size = UDim2.new(0, 26, 0, 26)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 15
CloseBtn.ZIndex = 11

Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 13)

CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
end)

-- Content
local Content = Instance.new("ScrollingFrame")
Content.Parent = MainFrame
Content.BackgroundColor3 = Color3.fromRGB(12, 12, 22)
Content.BorderSizePixel = 0
Content.Position = UDim2.new(0, 0, 0, 36)
Content.Size = UDim2.new(1, 0, 1, -36)
Content.CanvasSize = UDim2.new(0, 0, 0, 800)
Content.ScrollBarThickness = 2
Content.ScrollBarImageColor3 = Color3.fromRGB(255, 50, 100)

local Layout = Instance.new("UIListLayout")
Layout.Parent = Content
Layout.SortOrder = Enum.SortOrder.LayoutOrder
Layout.Padding = UDim.new(0, 4)

local Padding = Instance.new("UIPadding")
Padding.Parent = Content
Padding.PaddingLeft = UDim.new(0, 8)
Padding.PaddingRight = UDim.new(0, 8)
Padding.PaddingTop = UDim.new(0, 5)

-- UI Functions
local function makeSection(title)
    local sec = Instance.new("Frame")
    sec.BackgroundColor3 = Color3.fromRGB(22, 22, 38)
    sec.BorderSizePixel = 0
    sec.Size = UDim2.new(1, 0, 0, 22)
    sec.Parent = Content
    Instance.new("UICorner", sec).CornerRadius = UDim.new(0, 5)
    
    local lbl = Instance.new("TextLabel")
    lbl.Parent = sec
    lbl.BackgroundTransparency = 1
    lbl.Size = UDim2.new(1, -10, 1, 0)
    lbl.Position = UDim2.new(0, 8, 0, 0)
    lbl.Font = Enum.Font.GothamBold
    lbl.Text = title
    lbl.TextColor3 = Color3.fromRGB(255, 50, 100)
    lbl.TextSize = 10
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    return sec
end

local function makeToggle(name, callback)
    local frame = Instance.new("Frame")
    frame.BackgroundColor3 = Color3.fromRGB(26, 26, 42)
    frame.BorderSizePixel = 0
    frame.Size = UDim2.new(1, 0, 0, 30)
    frame.Parent = Content
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)
    
    local lbl = Instance.new("TextLabel")
    lbl.Parent = frame
    lbl.BackgroundTransparency = 1
    lbl.Position = UDim2.new(0, 8, 0, 0)
    lbl.Size = UDim2.new(0.65, 0, 1, 0)
    lbl.Font = Enum.Font.Gotham
    lbl.Text = name .. ": OFF"
    lbl.TextColor3 = Color3.fromRGB(180, 180, 180)
    lbl.TextSize = 10
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    
    local btn = Instance.new("Frame")
    btn.Parent = frame
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
    btn.BorderSizePixel = 0
    btn.Position = UDim2.new(0.82, 0, 0.18, 0)
    btn.Size = UDim2.new(0, 36, 0, 18)
    Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)
    
    local circle = Instance.new("Frame")
    circle.Parent = btn
    circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    circle.BorderSizePixel = 0
    circle.Position = UDim2.new(0.05, 0, 0.1, 0)
    circle.Size = UDim2.new(0, 14, 0, 14)
    Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)
    
    local on = false
    local click = Instance.new("TextButton")
    click.Parent = frame
    click.BackgroundTransparency = 1
    click.Size = UDim2.new(1, 0, 1, 0)
    click.Text = ""
    click.ZIndex = 10
    
    click.MouseButton1Click:Connect(function()
        on = not on
        if on then
            btn.BackgroundColor3 = Color3.fromRGB(255, 50, 100)
            circle:TweenPosition(UDim2.new(0.5, 0, 0.1, 0), "Out", "Quad", 0.15, true)
            lbl.Text = name .. ": ON"
            lbl.TextColor3 = Color3.fromRGB(100, 255, 150)
        else
            btn.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
            circle:TweenPosition(UDim2.new(0.05, 0, 0.1, 0), "Out", "Quad", 0.15, true)
            lbl.Text = name .. ": OFF"
            lbl.TextColor3 = Color3.fromRGB(180, 180, 180)
        end
        if callback then callback(on) end
    end)
    
    return frame
end

-- Build Menu
makeSection("[ ZOMBIE ESP ]")
makeToggle("Zombie ESP", function(s) Settings.ESP.Zombie.Enabled = s end)
makeToggle("Boxes", function(s) Settings.ESP.Zombie.Boxes = s end)
makeToggle("Names", function(s) Settings.ESP.Zombie.Names = s end)
makeToggle("Distance", function(s) Settings.ESP.Zombie.Distance = s end)
makeToggle("Health Bar", function(s) Settings.ESP.Zombie.HealthBar = s end)
makeToggle("Tracers", function(s) Settings.ESP.Zombie.Tracers = s end)

makeSection("[ CHEST ESP ]")
makeToggle("Chest ESP", function(s) Settings.ESP.Chest.Enabled = s end)
makeToggle("Boxes", function(s) Settings.ESP.Chest.Boxes = s end)
makeToggle("Names", function(s) Settings.ESP.Chest.Names = s end)
makeToggle("Distance", function(s) Settings.ESP.Chest.Distance = s end)
makeToggle("Tracers", function(s) Settings.ESP.Chest.Tracers = s end)

makeSection("[ WEAPON ]")
makeToggle("Infinite Ammo", function(s) Settings.Weapon.InfiniteAmmo = s end)
makeToggle("No Reload", function(s) Settings.Weapon.NoReload = s end)
makeToggle("No Recoil", function(s) Settings.Weapon.NoRecoil = s end)
makeToggle("No Spread", function(s) Settings.Weapon.NoSpread = s end)
makeToggle("Rapid Fire", function(s) Settings.Weapon.RapidFire = s end)

makeSection("[ PLAYER ]")
makeToggle("Auto Revive", function(s) Settings.Player.AutoRevive = s end)
makeToggle("God Mode", function(s) Settings.Player.GodMode = s end)

-- Update canvas
task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            Content.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 10)
        end)
    end
end)

-- Drag Button
local DragBtn = Instance.new("TextButton")
DragBtn.Name = randomString(8)
DragBtn.Parent = ScreenGui
DragBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 100)
DragBtn.BorderSizePixel = 0
DragBtn.Position = UDim2.new(0.45, 0, 0.4, 0)
DragBtn.Size = UDim2.new(0, 42, 0, 42)
DragBtn.Font = Enum.Font.GothamBlack
DragBtn.Text = "LS"
DragBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
DragBtn.TextSize = 13
DragBtn.ZIndex = 20

Instance.new("UICorner", DragBtn).CornerRadius = UDim.new(1, 0)

local dragging = false
local dragStart = nil
local startPos = nil
local moved = false

DragBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        moved = false
        dragStart = input.Position
        startPos = DragBtn.Position
    end
end)

DragBtn.InputEnded:Connect(function()
    dragging = false
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local delta = input.Position - dragStart
        if math.abs(delta.X) > 2 or math.abs(delta.Y) > 2 then
            moved = true
            DragBtn.Position = UDim2.new(0, 
                math.clamp(startPos.X.Offset + delta.X, 0, Camera.ViewportSize.X - 42),
                0, math.clamp(startPos.Y.Offset + delta.Y, 0, Camera.ViewportSize.Y - 42))
        end
    end
end)

DragBtn.MouseButton1Click:Connect(function()
    if not moved then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

-- ============================================================
-- MAIN LOOP
-- ============================================================

RunService.RenderStepped:Connect(function()
    pcall(updateZombieESP)
    pcall(updateChestESP)
end)

print("✅ LOL SCRIPTS loaded!")
print("📱 Delta/Xeno/CodeX ready")
print("🟢 Zombie ESP | 🟡 Chest ESP | 🔫 Weapons | ❤️ Player")
