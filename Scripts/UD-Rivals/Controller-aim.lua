local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

-- Epic animated notification sequence
spawn(function()
    local function createNotification(title, text, duration)
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = duration,
            Icon = "rbxassetid://13647654264"
        })
        wait(duration)
    end

    -- Cool notification sequence
    createNotification("Syfer-eng's Rival Enhanced", "Features Loaded!", 2)
    createNotification("💫 Ready!", "Press INSERT to toggle UI and End to close it", 3)
end)

local localPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera
local targetPlayer = nil
local isLeftMouseDown = false 
local isRightMouseDown = false
local autoClickConnection = nil

-- Settings
local AimSettings = {
    SilentAim = true,
    HitChance = 100,
    TargetPart = "Head"
}

local Toggles = {
    ESP = true,
    Aimbot = true,
    Boxes = true,
    Names = true,
    Distance = true,
    Snaplines = true,
    Health = true
}

local Settings = {
    ESP = {
        Enabled = true,
        Boxes = true,
        Names = true,
        Distance = true,
        Health = true,
        Snaplines = true,
        TeamCheck = false,
        Rainbow = true,
        BoxColor = Color3.fromRGB(255, 0, 255),
        Players = {},
        MaxDistance = 1000,
        HealthBarSize = Vector2.new(2, 20)
    },
    Aimbot = {
        Enabled = true,
        TeamCheck = false,
        Smoothness = 0.2,
        FOV = 150,
        TargetPart = "Head",
        ShowFOV = true,
        PredictionMultiplier = 1.5,
        AutoPrediction = true,
        TriggerBot = false,
        TriggerDelay = 0.1,
        MaxDistance = 250
    }
}

-- Create Enhanced UI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RivalsEnhancedGUI"
ScreenGui.Parent = CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 300, 0, 400)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

-- Add UI Enhancement Elements
local UIGradient = Instance.new("UIGradient")
UIGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 30)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 20))
})
UIGradient.Rotation = 45
UIGradient.Parent = MainFrame

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

local DropShadow = Instance.new("ImageLabel")
DropShadow.Name = "DropShadow"
DropShadow.BackgroundTransparency = 1
DropShadow.Position = UDim2.new(0, -15, 0, -15)
DropShadow.Size = UDim2.new(1, 30, 1, 30)
DropShadow.Image = "rbxassetid://6014261993"
DropShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
DropShadow.ImageTransparency = 0.5
DropShadow.Parent = MainFrame

-- Create Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 30)
TitleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleText = Instance.new("TextLabel")
TitleText.Name = "Title"
TitleText.Size = UDim2.new(1, 0, 1, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "Rivals Enhanced"
TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleText.TextSize = 16
TitleText.Font = Enum.Font.GothamBold
TitleText.Parent = TitleBar

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = TitleBar

-- Create Tab System
local TabButtons = Instance.new("Frame")
TabButtons.Name = "TabButtons"
TabButtons.Size = UDim2.new(1, 0, 0, 40)
TabButtons.Position = UDim2.new(0, 0, 0, 35)
TabButtons.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
TabButtons.BorderSizePixel = 0
TabButtons.Parent = MainFrame

local TabContainer = Instance.new("Frame")
TabContainer.Name = "TabContainer"
TabContainer.Size = UDim2.new(1, 0, 1, -80)
TabContainer.Position = UDim2.new(0, 0, 0, 80)
TabContainer.BackgroundTransparency = 1
TabContainer.Parent = MainFrame

-- Create Tabs
local AimbotTab = Instance.new("TextButton")
local ESPTab = Instance.new("TextButton")

-- Enhanced Dragging Functionality
local dragging, dragInput, dragStart, startPos

local function updateDrag(input)
    local delta = input.Position - dragStart
    local targetPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    
    local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    TweenService:Create(MainFrame, tweenInfo, {Position = targetPos}):Play()
end
-- Setup Tab Buttons
AimbotTab.Name = "AimbotTab"
AimbotTab.Size = UDim2.new(0.5, -5, 1, -10)
AimbotTab.Position = UDim2.new(0, 5, 0, 5)
AimbotTab.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
AimbotTab.Text = "Aimbot"
AimbotTab.TextColor3 = Color3.fromRGB(255, 255, 255)
AimbotTab.Font = Enum.Font.GothamBold
AimbotTab.TextSize = 14
AimbotTab.Parent = TabButtons
AimbotTab.AutoButtonColor = false

ESPTab.Name = "ESPTab"
ESPTab.Size = UDim2.new(0.5, -5, 1, -10)
ESPTab.Position = UDim2.new(0.5, 0, 0, 5)
ESPTab.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ESPTab.Text = "ESP"
ESPTab.TextColor3 = Color3.fromRGB(255, 255, 255)
ESPTab.Font = Enum.Font.GothamBold
ESPTab.TextSize = 14
ESPTab.Parent = TabButtons
ESPTab.AutoButtonColor = false

-- Add Corner Radius to Tabs
local function AddCorners(button)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = button
end

AddCorners(AimbotTab)
AddCorners(ESPTab)

-- Create Pages
local AimbotPage = Instance.new("ScrollingFrame")
AimbotPage.Name = "AimbotPage"
AimbotPage.Size = UDim2.new(1, -20, 1, -10)
AimbotPage.Position = UDim2.new(0, 10, 0, 5)
AimbotPage.BackgroundTransparency = 1
AimbotPage.ScrollBarThickness = 2
AimbotPage.ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255)
AimbotPage.Visible = true
AimbotPage.Parent = TabContainer

local ESPPage = Instance.new("ScrollingFrame")
ESPPage.Name = "ESPPage"
ESPPage.Size = UDim2.new(1, -20, 1, -10)
ESPPage.Position = UDim2.new(0, 10, 0, 5)
ESPPage.BackgroundTransparency = 1
ESPPage.ScrollBarThickness = 2
ESPPage.ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255)
ESPPage.Visible = false
ESPPage.Parent = TabContainer

-- Create Enhanced Toggle Button Function
local function CreateToggle(parent, name, category, setting)
    local ToggleFrame = Instance.new("Frame")
    local ToggleButton = Instance.new("TextButton")
    local ToggleStatus = Instance.new("Frame")
    
    ToggleFrame.Name = name .. "Toggle"
    ToggleFrame.Size = UDim2.new(0.9, 0, 0, 40)
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    ToggleFrame.Parent = parent
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 6)
    UICorner.Parent = ToggleFrame
    
    ToggleButton.Name = "Button"
    ToggleButton.Size = UDim2.new(1, 0, 1, 0)
    ToggleButton.BackgroundTransparency = 1
    ToggleButton.Text = name
    ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleButton.TextSize = 14
    ToggleButton.Font = Enum.Font.GothamBold
    ToggleButton.Parent = ToggleFrame
    
    ToggleStatus.Name = "Status"
    ToggleStatus.Size = UDim2.new(0, 24, 0, 24)
    ToggleStatus.Position = UDim2.new(0.92, 0, 0.5, 0)
    ToggleStatus.AnchorPoint = Vector2.new(0, 0.5)
    ToggleStatus.BackgroundColor3 = Settings[category][setting] and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 50, 50)
    ToggleStatus.Parent = ToggleFrame
    
    local StatusCorner = Instance.new("UICorner")
    StatusCorner.CornerRadius = UDim.new(1, 0)
    StatusCorner.Parent = ToggleStatus
    
    -- Add hover effect
    local hovering = false
    
    ToggleButton.MouseEnter:Connect(function()
        hovering = true
        TweenService:Create(ToggleFrame, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(45, 45, 45)}):Play()
    end)
    
    ToggleButton.MouseLeave:Connect(function()
        hovering = false
        TweenService:Create(ToggleFrame, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(35, 35, 35)}):Play()
    end)
    
    ToggleButton.MouseButton1Click:Connect(function()
        Settings[category][setting] = not Settings[category][setting]
        Toggles[name] = Settings[category][setting]
        
        local targetColor = Settings[category][setting] and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 50, 50)
        TweenService:Create(ToggleStatus, TweenInfo.new(0.2), {BackgroundColor3 = targetColor}):Play()
    end)
    
    return ToggleFrame
end
-- Create FOV Circle with enhanced visuals
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2
FOVCircle.NumSides = 90
FOVCircle.Radius = Settings.Aimbot.FOV
FOVCircle.Filled = false
FOVCircle.Visible = Settings.Aimbot.ShowFOV
FOVCircle.ZIndex = 999
FOVCircle.Transparency = 0.7
FOVCircle.Color = Color3.fromRGB(255, 255, 255)

-- Enhanced Perfect Aim Function
local function perfectAim(targetPart)
    local screenCenter = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
    local targetPosition = camera:WorldToViewportPoint(targetPart.Position)
    local targetVector = Vector2.new(targetPosition.X, targetPosition.Y)
    
    local distanceFromCenter = (targetVector - screenCenter).Magnitude
    
    if distanceFromCenter > 5 then
        mousemoverel(targetPosition.X - screenCenter.X, targetPosition.Y - screenCenter.Y)
    end
end

-- Enhanced ESP Function
local function CreateESP(player)
    local esp = {
        Box = Drawing.new("Square"),
        Name = Drawing.new("Text"),
        Distance = Drawing.new("Text"),
        Snapline = Drawing.new("Line"),
        HealthBar = Drawing.new("Square"),
        HealthBarBackground = Drawing.new("Square"),
        HeadDot = Drawing.new("Circle")
    }
    
    -- Box ESP
    esp.Box.Visible = false
    esp.Box.Color = Settings.ESP.BoxColor
    esp.Box.Thickness = 1.5
    esp.Box.Filled = false
    esp.Box.Transparency = 1
    
    -- Name ESP
    esp.Name.Visible = false
    esp.Name.Color = Color3.new(1, 1, 1)
    esp.Name.Size = 16
    esp.Name.Center = true
    esp.Name.Outline = true
    esp.Name.OutlineColor = Color3.new(0, 0, 0)
    
    -- Distance ESP
    esp.Distance.Visible = false
    esp.Distance.Color = Color3.new(1, 1, 1)
    esp.Distance.Size = 14
    esp.Distance.Center = true
    esp.Distance.Outline = true
    esp.Distance.OutlineColor = Color3.new(0, 0, 0)
    
    -- Snapline ESP
    esp.Snapline.Visible = false
    esp.Snapline.Color = Settings.ESP.BoxColor
    esp.Snapline.Thickness = 1.5
    esp.Snapline.Transparency = 1
    
    -- Health Bar
    esp.HealthBar.Visible = false
    esp.HealthBar.Color = Color3.fromRGB(0, 255, 0)
    esp.HealthBar.Filled = true
    esp.HealthBar.Thickness = 1
    esp.HealthBar.Transparency = 1
    
    -- Health Bar Background
    esp.HealthBarBackground.Visible = false
    esp.HealthBarBackground.Color = Color3.fromRGB(255, 0, 0)
    esp.HealthBarBackground.Filled = true
    esp.HealthBarBackground.Thickness = 1
    esp.HealthBarBackground.Transparency = 1
    
    -- Head Dot
    esp.HeadDot.Visible = false
    esp.HeadDot.Color = Color3.fromRGB(255, 255, 255)
    esp.HeadDot.Thickness = 1
    esp.HeadDot.NumSides = 12
    esp.HeadDot.Radius = 3
    esp.HeadDot.Filled = true
    esp.HeadDot.Transparency = 1
    
    Settings.ESP.Players[player] = esp
end

-- Enhanced Get Closest Player Function
local function GetClosestPlayerToMouse()
    local closestPlayer = nil
    local shortestDistance = math.huge
    local screenCenter = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)

    if targetPlayer and isRightMouseDown then
        if targetPlayer.Character and targetPlayer.Character:FindFirstChild(AimSettings.TargetPart) then
            return targetPlayer
        end
    end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= localPlayer and player.Character and player.Character:FindFirstChild(AimSettings.TargetPart) then
            local targetPart = player.Character[AimSettings.TargetPart]
            local targetPosition, onScreen = camera:WorldToViewportPoint(targetPart.Position)
            
            local characterDistance = (targetPart.Position - localPlayer.Character.HumanoidRootPart.Position).Magnitude
            if characterDistance > Settings.Aimbot.MaxDistance then
                continue
            end

            if onScreen then
                local screenPosition = Vector2.new(targetPosition.X, targetPosition.Y)
                local distance = (screenPosition - screenCenter).Magnitude

                if distance <= Settings.Aimbot.FOV and distance < shortestDistance then
                    closestPlayer = player
                    shortestDistance = distance
                end
            end
        end
    end

    return closestPlayer
end
-- Enhanced Update ESP Function
local function UpdateESP()
    if not Toggles.ESP then return end
    
    for player, esp in pairs(Settings.ESP.Players) do
        if player.Character and player ~= localPlayer then
            local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
            local humanoid = player.Character:FindFirstChild("Humanoid")
            local head = player.Character:FindFirstChild("Head")
            
            if humanoidRootPart and humanoid and head then
                local pos, onScreen = camera:WorldToViewportPoint(humanoidRootPart.Position)
                local headPos = camera:WorldToViewportPoint(head.Position)
                local distance = (humanoidRootPart.Position - camera.CFrame.Position).Magnitude
                
                if onScreen and distance <= Settings.ESP.MaxDistance then
                    -- Dynamic ESP Size based on distance
                    local scaleFactor = 1 / (distance * 0.05)
                    local size = (camera:WorldToViewportPoint(humanoidRootPart.Position + Vector3.new(2, 3, 0)).Y - camera:WorldToViewportPoint(humanoidRootPart.Position + Vector3.new(-2, -3, 0)).Y) / 2
                    
                    -- Box ESP
                    esp.Box.Size = Vector2.new(size * 1.5, size * 3)
                    esp.Box.Position = Vector2.new(pos.X - esp.Box.Size.X / 2, pos.Y - esp.Box.Size.Y / 2)
                    esp.Box.Color = Settings.ESP.Rainbow and Color3.fromHSV(tick() % 5 / 5, 1, 1) or Settings.ESP.BoxColor
                    esp.Box.Visible = Toggles.Boxes and Settings.ESP.Boxes
                    
                    -- Health Bar
                    local healthBarHeight = esp.Box.Size.Y * (humanoid.Health / humanoid.MaxHealth)
                    esp.HealthBarBackground.Size = Vector2.new(Settings.ESP.HealthBarSize.X, esp.Box.Size.Y)
                    esp.HealthBarBackground.Position = Vector2.new(esp.Box.Position.X - esp.HealthBarBackground.Size.X * 2, esp.Box.Position.Y)
                    esp.HealthBarBackground.Visible = Toggles.Health and Settings.ESP.Health
                    
                    esp.HealthBar.Size = Vector2.new(Settings.ESP.HealthBarSize.X, healthBarHeight)
                    esp.HealthBar.Position = Vector2.new(esp.Box.Position.X - esp.HealthBar.Size.X * 2, esp.Box.Position.Y + esp.Box.Size.Y - healthBarHeight)
                    esp.HealthBar.Color = Color3.fromRGB(255 - (255 * (humanoid.Health / humanoid.MaxHealth)), 255 * (humanoid.Health / humanoid.MaxHealth), 0)
                    esp.HealthBar.Visible = Toggles.Health and Settings.ESP.Health
                    
                    -- Name ESP
                    esp.Name.Position = Vector2.new(pos.X, esp.Box.Position.Y - 20)
                    esp.Name.Text = string.format("%s", player.Name)
                    esp.Name.Size = math.clamp(16 * scaleFactor, 12, 16)
                    esp.Name.Visible = Toggles.Names and Settings.ESP.Names
                    
                    -- Distance ESP
                    esp.Distance.Position = Vector2.new(pos.X, esp.Box.Position.Y + esp.Box.Size.Y + 10)
                    esp.Distance.Text = string.format("[%d studs]", distance)
                    esp.Distance.Size = math.clamp(14 * scaleFactor, 10, 14)
                    esp.Distance.Visible = Toggles.Distance and Settings.ESP.Distance
                    
                    -- Snapline ESP
                    esp.Snapline.From = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)
                    esp.Snapline.To = Vector2.new(pos.X, pos.Y)
                    esp.Snapline.Color = esp.Box.Color
                    esp.Snapline.Visible = Toggles.Snaplines and Settings.ESP.Snaplines
                    
                    -- Head Dot ESP
                    esp.HeadDot.Position = Vector2.new(headPos.X, headPos.Y)
                    esp.HeadDot.Color = esp.Box.Color
                    esp.HeadDot.Visible = Toggles.Boxes and Settings.ESP.Boxes
                else
                    -- Hide ESP when not on screen
                    for _, drawing in pairs(esp) do
                        drawing.Visible = false
                    end
                end
            end
        end
    end
end

local function lockCameraToHead()
    if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild(AimSettings.TargetPart) then
        local targetPart = targetPlayer.Character[AimSettings.TargetPart]
        local targetPosition = camera:WorldToViewportPoint(targetPart.Position)
        if targetPosition.Z > 0 then
            local cameraPosition = camera.CFrame.Position
            camera.CFrame = CFrame.new(cameraPosition, targetPart.Position)
        end
    end
end
-- Enhanced UI Interaction Setup
local function SetupUIInteractions()
    -- Tab Switching with Animation
    local function SwitchTab(showAimbot)
        -- Animate tab buttons
        TweenService:Create(AimbotTab, TweenInfo.new(0.3), {
            BackgroundColor3 = showAimbot and Color3.fromRGB(40, 40, 40) or Color3.fromRGB(30, 30, 30)
        }):Play()
        
        TweenService:Create(ESPTab, TweenInfo.new(0.3), {
            BackgroundColor3 = showAimbot and Color3.fromRGB(30, 30, 30) or Color3.fromRGB(40, 40, 40)
        }):Play()
        
        -- Switch pages
        AimbotPage.Visible = showAimbot
        ESPPage.Visible = not showAimbot
    end

    AimbotTab.MouseButton1Click:Connect(function()
        SwitchTab(true)
    end)

    ESPTab.MouseButton1Click:Connect(function()
        SwitchTab(false)
    end)

    -- Enhanced Dragging
    MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    MainFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            updateDrag(input)
        end
    end)

    -- Toggle GUI with Insert Key
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if input.KeyCode == Enum.KeyCode.Insert then
            -- Animate GUI visibility
            if ScreenGui.Enabled then
                TweenService:Create(MainFrame, TweenInfo.new(0.3), {
                    Position = UDim2.new(MainFrame.Position.X.Scale, MainFrame.Position.X.Offset, 1.5, 0)
                }):Play()
                wait(0.3)
                ScreenGui.Enabled = false
            else
                ScreenGui.Enabled = true
                MainFrame.Position = UDim2.new(MainFrame.Position.X.Scale, MainFrame.Position.X.Offset, 1.5, 0)
                TweenService:Create(MainFrame, TweenInfo.new(0.3), {
                    Position = UDim2.new(MainFrame.Position.X.Scale, MainFrame.Position.X.Offset, 0.5, -200)
                }):Play()
            end
        end
    end)
end

-- Create Toggles
local AimbotToggles = {
    {name = "Enabled", setting = "Enabled"},
    {name = "Team Check", setting = "TeamCheck"},
    {name = "Show FOV", setting = "ShowFOV"}
}

local ESPToggles = {
    {name = "Boxes", setting = "Boxes"},
    {name = "Names", setting = "Names"},
    {name = "Distance", setting = "Distance"},
    {name = "Snaplines", setting = "Snaplines"},
    {name = "Health", setting = "Health"},
    {name = "Team Check", setting = "TeamCheck"},
    {name = "Rainbow", setting = "Rainbow"}
}

-- Create UI List Layouts
local function CreateUIListLayout(parent)
    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.Parent = parent
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Padding = UDim.new(0, 5)
    UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    return UIListLayout
end

CreateUIListLayout(AimbotPage)
CreateUIListLayout(ESPPage)

-- Create Toggles for Both Pages
for _, toggle in ipairs(AimbotToggles) do
    CreateToggle(AimbotPage, toggle.name, "Aimbot", toggle.setting)
end

for _, toggle in ipairs(ESPToggles) do
    CreateToggle(ESPPage, toggle.name, "ESP", toggle.setting)
end
-- Enhanced Cleanup Function
local function cleanup()
    for toggle in pairs(Toggles) do
        Toggles[toggle] = false
    end
    
    FOVCircle:Remove()
    
    for _, esp in pairs(Settings.ESP.Players) do
        for _, drawing in pairs(esp) do
            drawing:Remove()
        end
    end
    
    Settings.ESP.Players = {}
    targetPlayer = nil
    isLeftMouseDown = false
    isRightMouseDown = false
    
    if autoClickConnection then
        autoClickConnection:Disconnect()
    end
    
    Settings.ESP.Enabled = false
    Settings.Aimbot.Enabled = false
    
    -- Animate GUI removal
    TweenService:Create(MainFrame, TweenInfo.new(0.3), {
        Position = UDim2.new(MainFrame.Position.X.Scale, MainFrame.Position.X.Offset, 1.5, 0)
    }):Play()
    wait(0.3)
    ScreenGui:Destroy()
end

-- Initialize ESP for existing players
for _, player in pairs(Players:GetPlayers()) do
    if player ~= localPlayer then
        CreateESP(player)
    end
end

-- Player Events
Players.PlayerAdded:Connect(function(player)
    if player ~= localPlayer then
        CreateESP(player)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    if Settings.ESP.Players[player] then
        for _, drawing in pairs(Settings.ESP.Players[player]) do
            drawing:Remove()
        end
        Settings.ESP.Players[player] = nil
    end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        isLeftMouseDown = true
    elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
        isRightMouseDown = true
        if not targetPlayer then
            targetPlayer = GetClosestPlayerToMouse()
        end
    elseif input.KeyCode == Enum.KeyCode.End then
        cleanup()
    end
    
    if toggleKeys[input.KeyCode] then
        toggleKeys[input.KeyCode]()
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        isLeftMouseDown = false
    elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
        isRightMouseDown = false
        targetPlayer = nil
    end
end)

FOVCircle.Position = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
RunService.RenderStepped:Connect(function()
    FOVCircle.Position = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
    FOVCircle.Visible = Toggles.Aimbot and Settings.Aimbot.ShowFOV
    
    UpdateESP()
    
    if Settings.Aimbot.Enabled and Toggles.Aimbot and isRightMouseDown then
        if not targetPlayer then
            targetPlayer = GetClosestPlayerToMouse()
        end
        if targetPlayer and targetPlayer.Character then
            local targetPart = targetPlayer.Character:FindFirstChild(AimSettings.TargetPart)
            if targetPart then
                if AimSettings.SilentAim then
                    perfectAim(targetPart)
                else
                    lockCameraToHead()
                end
            end
        end
    end
end)

SetupUIInteractions()

-- Initialize UI with animation
MainFrame.Position = UDim2.new(0.5, -150, 1.5, 0)
TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Bounce), {
    Position = UDim2.new(0.5, -150, 0.5, -200)
}):Play()
