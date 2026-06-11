--[[
    ================================================================
    [ SCRIPT INFORMATION ]
    Project: Custom Script
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
    -- 🔴 CRITICAL: This MUST exactly match the 'Secret' value in your Key System's Config!
    -- If your Key System has: Secret = "Test"
    -- Then this must also be: SecretKey = "Test"
    SecretKey = "LOLSCRIPTSBEST111",
    
    -- The name of your Hub (shown in the kick message if they try to bypass)
    HubName = "LOL HUB"
}

-- Anti-Bypass Logic: Checks if the Key System successfully set the global variable
if not _G[ProtectionConfig.SecretKey] then
    local player = game:GetService("Players").LocalPlayer
    if player then
        player:Kick("\n🛡️ Unauthorized Execution 🛡️\n\nPlease use the official Key System to run " .. ProtectionConfig.HubName)
    end
    return -- Stops the rest of the script from loading!
end

-------------------------------------------------------------------------------
-- 👇 YOUR MAIN SCRIPT CODE STARTS HERE 👇
-------------------------------------------------------------------------------

local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local VirtualInputManager = game:GetService("VirtualInputManager")

if not LocalPlayer then
    LocalPlayer = Players.PlayerAdded:Wait()
end

local Settings = {
    Auto = {
        AutoSell = false,
        AutoSellDelay = 0.5,
        AutoClick = false,
        AutoClickDelay = 0.1,
        AutoCollect = false,
        AutoCollectDelay = 1
    }
}
-- Функция поиска кнопок по тексту
local function findButtonByText(parent, text)
    for _, child in ipairs(parent:GetDescendants()) do
        if child:IsA("TextButton") or child:IsA("ImageButton") then
            if child.Name == text or (child:IsA("TextButton") and child.Text == text) then
                return child
            end
        end
    end
    return nil
end

-- Функция поиска всех кнопок с определённым текстом
local function findAllButtonsByText(parent, text)
    local buttons = {}
    for _, child in ipairs(parent:GetDescendants()) do
        if child:IsA("TextButton") or child:IsA("ImageButton") then
            if child.Name == text or (child:IsA("TextButton") and child.Text == text) then
                table.insert(buttons, child)
            end
        end
    end
    return buttons
end

-- Функция для симуляции клика
local function simulateClick(button)
    if not button then return false end
    if button.Visible == false or button.Active == false then return false end
    pcall(function()
        -- Способ 1: прямой вызов события
        firesignal(button.MouseButton1Click)
    end)
    pcall(function()
        -- Способ 2: через GUI service
        local guiService = game:GetService("GuiService")
        guiService:Select(button)
    end)
    pcall(function()
        -- Способ 3: виртуальный ввод
        VirtualInputManager:SendMouseButtonEvent(
            button.AbsolutePosition.X + button.AbsoluteSize.X / 2,
            button.AbsolutePosition.Y + button.AbsoluteSize.Y / 2,
            0, true, game, 0
        )
        task.wait(0.05)
        VirtualInputManager:SendMouseButtonEvent(
            button.AbsolutePosition.X + button.AbsoluteSize.X / 2,
            button.AbsolutePosition.Y + button.AbsoluteSize.Y / 2,
            0, false, game, 0
        )
    end)
    return true
end

-- Auto Sell функция
local lastSellTime = 0
local function autoSellLoop()
    if not Settings.Auto.AutoSell then return end
    
    local currentTime = tick()
    if currentTime - lastSellTime < Settings.Auto.AutoSellDelay then return end
    lastSellTime = currentTime
    
    -- Ищем кнопки продажи (разные возможные названия)
    local sellButtons = {}
    
    -- Поиск в PlayerGui
    if LocalPlayer.PlayerGui then
        local buttons1 = findAllButtonsByText(LocalPlayer.PlayerGui, "Sell")
        for _, btn in ipairs(buttons1) do table.insert(sellButtons, btn) end
        
        local buttons2 = findAllButtonsByText(LocalPlayer.PlayerGui, "SELL")
        for _, btn in ipairs(buttons2) do table.insert(sellButtons, btn) end
        
        local buttons3 = findAllButtonsByText(LocalPlayer.PlayerGui, "Sell Lemons")
        for _, btn in ipairs(buttons3) do table.insert(sellButtons, btn) end
        
        local buttons4 = findAllButtonsByText(LocalPlayer.PlayerGui, "Sell Lemonade")
        for _, btn in ipairs(buttons4) do table.insert(sellButtons, btn) end
        
        local buttons5 = findAllButtonsByText(LocalPlayer.PlayerGui, "Sell Lemon")
        for _, btn in ipairs(buttons5) do table.insert(sellButtons, btn) end
    end
    
    -- Поиск в CoreGui (некоторые игры используют CoreGui)
    for _, btn in ipairs(findAllButtonsByText(game.CoreGui, "Sell")) do
        table.insert(sellButtons, btn)
    end
    
    -- Нажимаем все найденные кнопки
    for _, btn in ipairs(sellButtons) do
        if btn.Visible and btn.Active then
            simulateClick(btn)
        end
    end
end

-- Auto Click функция (быстрое нажатие на всё подряд)
local lastClickTime = 0
local function autoClickLoop()
    if not Settings.Auto.AutoClick then return end
    
    local currentTime = tick()
    if currentTime - lastClickTime < Settings.Auto.AutoClickDelay then return end
    lastClickTime = currentTime
    
    if LocalPlayer.PlayerGui then
        for _, child in ipairs(LocalPlayer.PlayerGui:GetDescendants()) do
            if (child:IsA("TextButton") or child:IsA("ImageButton")) and child.Visible and child.Active then
                -- Пропускаем кнопки закрытия и меню
                local skipTexts = {"Close", "X", "Menu", "Settings", "Shop", "Store", "Exit"}
                local shouldSkip = false
                for _, skipText in ipairs(skipTexts) do
                    if child.Name == skipText or (child:IsA("TextButton") and child.Text == skipText) then
                        shouldSkip = true
                        break
                    end
                end
                if not shouldSkip then
                    simulateClick(child)
                    break
                end
            end
        end
    end
end

-- Auto Collect функция (сбор лимонов с деревьев)
local lastCollectTime = 0
local function autoCollectLoop()
    if not Settings.Auto.AutoCollect then return end
    
    local currentTime = tick()
    if currentTime - lastCollectTime < Settings.Auto.AutoCollectDelay then return end
    lastCollectTime = currentTime
    
    -- Ищем лимонные деревья в рабочем пространстве
    local lemonTrees = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") and obj.Enabled then
            local parentName = obj.Parent and obj.Parent.Name or ""
            local grandParentName = obj.Parent and obj.Parent.Parent and obj.Parent.Parent.Name or ""
            if parentName:lower():find("lemon") or parentName:lower():find("tree") or
               grandParentName:lower():find("lemon") or grandParentName:lower():find("tree") then
                table.insert(lemonTrees, obj)
            end
        end
    end
    
    -- Ищем все ProximityPrompt (для общего сбора)
    if #lemonTrees == 0 then
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("ProximityPrompt") and obj.Enabled then
                table.insert(lemonTrees, obj)
            end
        end
    end
    
    -- Активируем найденные ProximityPrompt
    for _, prompt in ipairs(lemonTrees) do
        if prompt.Enabled then
            local character = LocalPlayer.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                local distance = (character.HumanoidRootPart.Position - prompt.Parent.Position).Magnitude
                if distance <= (prompt.MaxActivationDistance or 10) then
                    pcall(function()
                        fireproximityprompt(prompt)
                    end)
                end
            end
        end
    end
end

-- Loading Screen GUI
local LoadingGui = Instance.new("ScreenGui")
LoadingGui.Name = "LoadingScreen"
LoadingGui.Parent = game.CoreGui
LoadingGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local LoadingBg = Instance.new("Frame")
LoadingBg.Parent = LoadingGui
LoadingBg.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
LoadingBg.BorderSizePixel = 0
LoadingBg.Size = UDim2.new(1, 0, 1, 0)
LoadingBg.ZIndex = 100

local LoadingLogo = Instance.new("TextLabel")
LoadingLogo.Parent = LoadingBg
LoadingLogo.BackgroundTransparency = 1
LoadingLogo.Position = UDim2.new(0.5, -120, 0.35, 0)
LoadingLogo.Size = UDim2.new(0, 240, 0, 60)
LoadingLogo.Font = Enum.Font.GothamBlack
LoadingLogo.Text = "LOL SCRIPTS"
LoadingLogo.TextColor3 = Color3.fromRGB(255, 50, 100)
LoadingLogo.TextSize = 36
LoadingLogo.ZIndex = 101

local LoadingSub = Instance.new("TextLabel")
LoadingSub.Parent = LoadingBg
LoadingSub.BackgroundTransparency = 1
LoadingSub.Position = UDim2.new(0.5, -120, 0.42, 0)
LoadingSub.Size = UDim2.new(0, 240, 0, 30)
LoadingSub.Font = Enum.Font.Gotham
LoadingSub.Text = "by OYB"
LoadingSub.TextColor3 = Color3.fromRGB(200, 200, 200)
LoadingSub.TextSize = 16
LoadingSub.ZIndex = 101

local LoadingBarBg = Instance.new("Frame")
LoadingBarBg.Parent = LoadingBg
LoadingBarBg.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
LoadingBarBg.BorderSizePixel = 0
LoadingBarBg.Position = UDim2.new(0.5, -100, 0.55, 0)
LoadingBarBg.Size = UDim2.new(0, 200, 0, 6)
LoadingBarBg.ZIndex = 101

local LoadingBarCorner = Instance.new("UICorner")
LoadingBarCorner.CornerRadius = UDim.new(0, 3)
LoadingBarCorner.Parent = LoadingBarBg

local LoadingBarFill = Instance.new("Frame")
LoadingBarFill.Parent = LoadingBarBg
LoadingBarFill.BackgroundColor3 = Color3.fromRGB(255, 50, 100)
LoadingBarFill.BorderSizePixel = 0
LoadingBarFill.Size = UDim2.new(0, 0, 1, 0)
LoadingBarFill.ZIndex = 102

local LoadingBarFillCorner = Instance.new("UICorner")
LoadingBarFillCorner.CornerRadius = UDim.new(0, 3)
LoadingBarFillCorner.Parent = LoadingBarFill

local LoadingStatus = Instance.new("TextLabel")
LoadingStatus.Parent = LoadingBg
LoadingStatus.BackgroundTransparency = 1
LoadingStatus.Position = UDim2.new(0.5, -100, 0.59, 0)
LoadingStatus.Size = UDim2.new(0, 200, 0, 20)
LoadingStatus.Font = Enum.Font.Gotham
LoadingStatus.Text = "Loading... 0%"
LoadingStatus.TextColor3 = Color3.fromRGB(150, 150, 150)
LoadingStatus.TextSize = 12
LoadingStatus.ZIndex = 101

task.spawn(function()
    for i = 0, 100 do
        LoadingBarFill:TweenSize(UDim2.new(i/100, 0, 1, 0), "Out", "Linear", 0.02, true)
        LoadingStatus.Text = "Loading... "..i.."%"
        task.wait(0.015)
    end
    task.wait(0.3)
    LoadingGui:Destroy()
end)
-- Main GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "LolScriptsHub"
ScreenGui.Parent = game.CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.1, 0, 0.1, 0)
MainFrame.Size = UDim2.new(0, 300, 0, 320)
MainFrame.Visible = false
MainFrame.Active = true
MainFrame.Draggable = true

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

local TitleFrame = Instance.new("Frame")
TitleFrame.Parent = MainFrame
TitleFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 38)
TitleFrame.BorderSizePixel = 0
TitleFrame.Size = UDim2.new(1, 0, 0, 42)

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 12)
TitleCorner.Parent = TitleFrame

local TitleCover = Instance.new("Frame")
TitleCover.Parent = TitleFrame
TitleCover.BackgroundColor3 = Color3.fromRGB(25, 25, 38)
TitleCover.BorderSizePixel = 0
TitleCover.Position = UDim2.new(0, 0, 0.5, 0)
TitleCover.Size = UDim2.new(1, 0, 0.5, 0)

local TitleIcon = Instance.new("TextLabel")
TitleIcon.Parent = TitleFrame
TitleIcon.BackgroundTransparency = 1
TitleIcon.Position = UDim2.new(0, 12, 0, 0)
TitleIcon.Size = UDim2.new(0, 30, 1, 0)
TitleIcon.Font = Enum.Font.GothamBlack
TitleIcon.Text = "⚡"
TitleIcon.TextColor3 = Color3.fromRGB(255, 50, 100)
TitleIcon.TextSize = 20

local Title = Instance.new("TextLabel")
Title.Parent = TitleFrame
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 42, 0, 0)
Title.Size = UDim2.new(0.5, 0, 1, 0)
Title.Font = Enum.Font.GothamBlack
Title.Text = "LOL SCRIPTS"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 15
Title.TextXAlignment = Enum.TextXAlignment.Left

local CloseButton = Instance.new("TextButton")
CloseButton.Parent = TitleFrame
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 50, 100)
CloseButton.BorderSizePixel = 0
CloseButton.Position = UDim2.new(0.88, 0, 0.18, 0)
CloseButton.Size = UDim2.new(0, 28, 0, 28)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Text = "x"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 18

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 14)
CloseCorner.Parent = CloseButton

CloseButton.MouseButton1Click:Connect(function() MainFrame.Visible = false end)

local TabFrame = Instance.new("Frame")
TabFrame.Parent = MainFrame
TabFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 35)
TabFrame.BorderSizePixel = 0
TabFrame.Position = UDim2.new(0, 0, 0, 42)
TabFrame.Size = UDim2.new(1, 0, 0, 34)

local AutoTab = Instance.new("TextButton")
AutoTab.Parent = TabFrame
AutoTab.BackgroundColor3 = Color3.fromRGB(255, 50, 100)
AutoTab.BorderSizePixel = 0
AutoTab.Position = UDim2.new(0.01, 0, 0.12, 0)
AutoTab.Size = UDim2.new(0.98, 0, 0.76, 0)
AutoTab.Font = Enum.Font.GothamBold
AutoTab.Text = "Auto"
AutoTab.TextColor3 = Color3.fromRGB(255, 255, 255)
AutoTab.TextSize = 10

local AutoTabCorner = Instance.new("UICorner")
AutoTabCorner.CornerRadius = UDim.new(0, 6)
AutoTabCorner.Parent = AutoTab

-- Content Frame
local AutoContent = Instance.new("ScrollingFrame")
AutoContent.Parent = MainFrame
AutoContent.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
AutoContent.BorderSizePixel = 0
AutoContent.Position = UDim2.new(0, 0, 0, 76)
AutoContent.Size = UDim2.new(1, 0, 1, -76)
AutoContent.CanvasSize = UDim2.new(0, 0, 0, 400)
AutoContent.ScrollBarThickness = 3
AutoContent.ScrollBarImageColor3 = Color3.fromRGB(255, 50, 100)
AutoContent.Visible = true

local AutoLayout = Instance.new("UIListLayout")
AutoLayout.Parent = AutoContent
AutoLayout.SortOrder = Enum.SortOrder.LayoutOrder
AutoLayout.Padding = UDim.new(0, 8)

local AutoPadding = Instance.new("UIPadding")
AutoPadding.Parent = AutoContent
AutoPadding.PaddingLeft = UDim.new(0, 10)
AutoPadding.PaddingRight = UDim.new(0, 10)
AutoPadding.PaddingTop = UDim.new(0, 8)

-- UI Element Functions
local function createSection(parent, title)
    local Section = Instance.new("Frame")
    Section.BackgroundColor3 = Color3.fromRGB(28, 28, 42)
    Section.BorderSizePixel = 0
    Section.Size = UDim2.new(1, 0, 0, 26)
    Section.Parent = parent
    local SectionCorner = Instance.new("UICorner")
    SectionCorner.CornerRadius = UDim.new(0, 6)
    SectionCorner.Parent = Section
    local SectionLabel = Instance.new("TextLabel")
    SectionLabel.Parent = Section
    SectionLabel.BackgroundTransparency = 1
    SectionLabel.Position = UDim2.new(0, 10, 0, 0)
    SectionLabel.Size = UDim2.new(1, -20, 1, 0)
    SectionLabel.Font = Enum.Font.GothamBold
    SectionLabel.Text = title
    SectionLabel.TextColor3 = Color3.fromRGB(255, 50, 100)
    SectionLabel.TextSize = 12
    SectionLabel.TextXAlignment = Enum.TextXAlignment.Left
    return Section
end

local function createSlider(parent, name, min, max, default, suffix, callback)
    local SliderFrame = Instance.new("Frame")
    SliderFrame.BackgroundColor3 = Color3.fromRGB(32, 32, 48)
    SliderFrame.BorderSizePixel = 0
    SliderFrame.Size = UDim2.new(1, 0, 0, 50)
    SliderFrame.Parent = parent
    local SliderCorner = Instance.new("UICorner")
    SliderCorner.CornerRadius = UDim.new(0, 8)
    SliderCorner.Parent = SliderFrame
    local SliderLabel = Instance.new("TextLabel")
    SliderLabel.Parent = SliderFrame
    SliderLabel.BackgroundTransparency = 1
    SliderLabel.Position = UDim2.new(0, 10, 0, 3)
    SliderLabel.Size = UDim2.new(1, -20, 0, 14)
    SliderLabel.Font = Enum.Font.Gotham
    SliderLabel.Text = name..": "..default..(suffix or "")
    SliderLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    SliderLabel.TextSize = 11
    SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
    local SliderBg = Instance.new("Frame")
    SliderBg.Parent = SliderFrame
    SliderBg.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
    SliderBg.BorderSizePixel = 0
    SliderBg.Position = UDim2.new(0.03, 0, 0.58, 0)
    SliderBg.Size = UDim2.new(0.94, 0, 0, 4)
    local SliderBgCorner = Instance.new("UICorner")
    SliderBgCorner.CornerRadius = UDim.new(0, 2)
    SliderBgCorner.Parent = SliderBg
    local SliderFill = Instance.new("Frame")
    SliderFill.Parent = SliderBg
    SliderFill.BackgroundColor3 = Color3.fromRGB(255, 50, 100)
    SliderFill.BorderSizePixel = 0
    SliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    local SliderFillCorner = Instance.new("UICorner")
    SliderFillCorner.CornerRadius = UDim.new(0, 2)
    SliderFillCorner.Parent = SliderFill
    local SliderButton = Instance.new("TextButton")
    SliderButton.Parent = SliderBg
    SliderButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    SliderButton.BorderSizePixel = 0
    SliderButton.Size = UDim2.new(0, 14, 0, 14)
    SliderButton.Position = UDim2.new((default - min) / (max - min), -7, 0.5, -7)
    SliderButton.Font = Enum.Font.Gotham
    SliderButton.Text = ""
    local SliderButtonCorner = Instance.new("UICorner")
    SliderButtonCorner.CornerRadius = UDim.new(1, 0)
    SliderButtonCorner.Parent = SliderButton
    local value = default
    local function updateSlider(input)
        local barAbsolutePos = SliderBg.AbsolutePosition.X
        local barAbsoluteSize = SliderBg.AbsoluteSize.X
        local relativePos = math.clamp((input.Position.X - barAbsolutePos) / barAbsoluteSize, 0, 1)
        value = math.floor(min + (max - min) * relativePos * 10) / 10
        SliderFill.Size = UDim2.new(relativePos, 0, 1, 0)
        SliderButton.Position = UDim2.new(relativePos, -7, 0.5, -7)
        SliderLabel.Text = name..": "..value..(suffix or "")
        if callback then callback(value) end
    end
    SliderButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            local connection
            connection = UserInputService.InputChanged:Connect(function(moveInput)
                if moveInput.UserInputType == Enum.UserInputType.Touch or moveInput.UserInputType == Enum.UserInputType.MouseMovement then
                    updateSlider(moveInput)
                end
            end)
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then connection:Disconnect() end
            end)
        end
    end)
    SliderBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            updateSlider(input)
        end
    end)
    return {
        getValue = function() return value end,
        setValue = function(v) 
            value = v
            local relativePos = (v - min) / (max - min)
            SliderFill.Size = UDim2.new(relativePos, 0, 1, 0)
            SliderButton.Position = UDim2.new(relativePos, -7, 0.5, -7)
            SliderLabel.Text = name..": "..v..(suffix or "")
        end,
        frame = SliderFrame
    }
end

local function createToggle(parent, name, callback)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(32, 32, 48)
    ToggleFrame.BorderSizePixel = 0
    ToggleFrame.Size = UDim2.new(1, 0, 0, 36)
    ToggleFrame.Parent = parent
    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, 8)
    ToggleCorner.Parent = ToggleFrame
    local ToggleLabel = Instance.new("TextLabel")
    ToggleLabel.Parent = ToggleFrame
    ToggleLabel.BackgroundTransparency = 1
    ToggleLabel.Position = UDim2.new(0, 10, 0, 0)
    ToggleLabel.Size = UDim2.new(0.6, 0, 1, 0)
    ToggleLabel.Font = Enum.Font.Gotham
    ToggleLabel.Text = name..": OFF"
    ToggleLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    ToggleLabel.TextSize = 12
    ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
    local ToggleButton = Instance.new("Frame")
    ToggleButton.Parent = ToggleFrame
    ToggleButton.BackgroundColor3 = Color3.fromRGB(55, 55, 70)
    ToggleButton.BorderSizePixel = 0
    ToggleButton.Position = UDim2.new(0.82, 0, 0.2, 0)
    ToggleButton.Size = UDim2.new(0, 38, 0, 22)
    local ToggleCorner2 = Instance.new("UICorner")
    ToggleCorner2.CornerRadius = UDim.new(1, 0)
    ToggleCorner2.Parent = ToggleButton
    local ToggleCircle = Instance.new("Frame")
    ToggleCircle.Parent = ToggleButton
    ToggleCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ToggleCircle.BorderSizePixel = 0
    ToggleCircle.Position = UDim2.new(0.05, 0, 0.12, 0)
    ToggleCircle.Size = UDim2.new(0, 17, 0, 17)
    local ToggleCircleCorner = Instance.new("UICorner")
    ToggleCircleCorner.CornerRadius = UDim.new(1, 0)
    ToggleCircleCorner.Parent = ToggleCircle
    local toggled = false
    local clickButton = Instance.new("TextButton")
    clickButton.Parent = ToggleFrame
    clickButton.BackgroundTransparency = 1
    clickButton.Size = UDim2.new(1, 0, 1, 0)
    clickButton.Font = Enum.Font.Gotham
    clickButton.Text = ""
    clickButton.MouseButton1Click:Connect(function()
        toggled = not toggled
        if toggled then
            ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 50, 100)
            ToggleCircle:TweenPosition(UDim2.new(0.5, 0, 0.12, 0), "Out", "Quad", 0.2, true)
            ToggleLabel.Text = name..": ON"
            ToggleLabel.TextColor3 = Color3.fromRGB(100, 255, 150)
        else
            ToggleButton.BackgroundColor3 = Color3.fromRGB(55, 55, 70)
            ToggleCircle:TweenPosition(UDim2.new(0.05, 0, 0.12, 0), "Out", "Quad", 0.2, true)
            ToggleLabel.Text = name..": OFF"
            ToggleLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        end
        if callback then callback(toggled) end
    end)
    return { toggle = function() return toggled end, frame = ToggleFrame }
end
-- Auto Content
createSection(AutoContent, "Auto Farm")

local autoSellToggle = createToggle(AutoContent, "Auto Sell Lemons", function(state)
    Settings.Auto.AutoSell = state
end)

local autoSellDelaySlider = createSlider(AutoContent, "Sell Delay", 0.1, 5, 0.5, "s", function(value)
    Settings.Auto.AutoSellDelay = value
end)

createSection(AutoContent, "Auto Clicker")

local autoClickToggle = createToggle(AutoContent, "Auto Click", function(state)
    Settings.Auto.AutoClick = state
end)

local autoClickDelaySlider = createSlider(AutoContent, "Click Delay", 0.05, 2, 0.1, "s", function(value)
    Settings.Auto.AutoClickDelay = value
end)

createSection(AutoContent, "Auto Collect")

local autoCollectToggle = createToggle(AutoContent, "Auto Collect Lemons", function(state)
    Settings.Auto.AutoCollect = state
end)

local autoCollectDelaySlider = createSlider(AutoContent, "Collect Delay", 0.1, 5, 1, "s", function(value)
    Settings.Auto.AutoCollectDelay = value
end)

-- Информационная панель
local infoFrame = Instance.new("Frame")
infoFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 42)
infoFrame.BorderSizePixel = 0
infoFrame.Size = UDim2.new(1, 0, 0, 60)
infoFrame.Parent = AutoContent
local infoCorner = Instance.new("UICorner")
infoCorner.CornerRadius = UDim.new(0, 8)
infoCorner.Parent = infoFrame

local infoLabel = Instance.new("TextLabel")
infoLabel.Parent = infoFrame
infoLabel.BackgroundTransparency = 1
infoLabel.Position = UDim2.new(0, 10, 0, 5)
infoLabel.Size = UDim2.new(1, -20, 0, 20)
infoLabel.Font = Enum.Font.GothamBold
infoLabel.Text = "💡 Информация"
infoLabel.TextColor3 = Color3.fromRGB(255, 50, 100)
infoLabel.TextSize = 12
infoLabel.TextXAlignment = Enum.TextXAlignment.Left

local infoText = Instance.new("TextLabel")
infoText.Parent = infoFrame
infoText.BackgroundTransparency = 1
infoText.Position = UDim2.new(0, 10, 0, 28)
infoText.Size = UDim2.new(1, -20, 0, 30)
infoText.Font = Enum.Font.Gotham
infoText.Text = "Auto Sell - продажа лимонов\nAuto Click - авто нажатия\nAuto Collect - сбор с деревьев"
infoText.TextColor3 = Color3.fromRGB(150, 150, 150)
infoText.TextSize = 9
infoText.TextXAlignment = Enum.TextXAlignment.Left
infoText.TextWrapped = true

-- Update Canvas Size
task.spawn(function()
    while task.wait(0.2) do
        pcall(function()
            AutoContent.CanvasSize = UDim2.new(0, 0, 0, AutoLayout.AbsoluteContentSize.Y + 15)
        end)
    end
end)

-- Draggable Icon
local DragButton = Instance.new("TextButton")
DragButton.Parent = ScreenGui
DragButton.BackgroundColor3 = Color3.fromRGB(255, 50, 100)
DragButton.BorderSizePixel = 0
DragButton.Position = UDim2.new(0.45, 0, 0.45, 0)
DragButton.Size = UDim2.new(0, 46, 0, 46)
DragButton.Font = Enum.Font.GothamBlack
DragButton.Text = "LS"
DragButton.TextColor3 = Color3.fromRGB(255, 255, 255)
DragButton.TextSize = 15

local DragGradient = Instance.new("UIGradient")
DragGradient.Parent = DragButton
DragGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 50, 100)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 100, 150))
})

local DragCorner = Instance.new("UICorner")
DragCorner.CornerRadius = UDim.new(1, 0)
DragCorner.Parent = DragButton

local DragStroke = Instance.new("UIStroke")
DragStroke.Parent = DragButton
DragStroke.Color = Color3.fromRGB(255, 255, 255)
DragStroke.Thickness = 1.5
DragStroke.Transparency = 0.7

local dragging = false
local dragStart = nil
local startPos = nil
local clickMoved = false

DragButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true clickMoved = false dragStart = input.Position startPos = DragButton.Position
        input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local delta = input.Position - dragStart
        if math.abs(delta.X) > 3 or math.abs(delta.Y) > 3 then
            clickMoved = true
            local newX = math.clamp(startPos.X.Offset + delta.X, 0, Camera.ViewportSize.X - 46)
            local newY = math.clamp(startPos.Y.Offset + delta.Y, 0, Camera.ViewportSize.Y - 46)
            DragButton.Position = UDim2.new(0, newX, 0, newY)
        end
    end
end)

DragButton.MouseButton1Click:Connect(function()
    if not clickMoved then MainFrame.Visible = not MainFrame.Visible end
end)

-- Main Loop
RunService.RenderStepped:Connect(function()
    autoSellLoop()
    autoClickLoop()
    autoCollectLoop()
end)

-- Character Connection
LocalPlayer.CharacterAdded:Connect(function(character)
    local humanoid = character:WaitForChild("Humanoid")
end)

print("LOL SCRIPTS - Sell Lemons Auto Farm Loaded!")
print("Click the LS button to open the menu!")
