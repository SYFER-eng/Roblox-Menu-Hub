local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local localPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera
local targetPlayer = nil
local isLeftMouseDown = false 
local isRightMouseDown = false
local autoClickConnection = nil

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

-- Create UI
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local TabButtons = Instance.new("Frame")
local AimbotTab = Instance.new("TextButton")
local ESPTab = Instance.new("TextButton")
local TabContainer = Instance.new("Frame")
local AimbotPage = Instance.new("ScrollingFrame")
local ESPPage = Instance.new("ScrollingFrame")

ScreenGui.Name = "RivalsGUI"
ScreenGui.Parent = CoreGui

MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 250, 0, 350)
MainFrame.Position = UDim2.new(0.8, 0, 0.5, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.Parent = ScreenGui
MainFrame.Active = true
MainFrame.Draggable = true
-- Continue UI Setup
TabButtons.Name = "TabButtons"
TabButtons.Size = UDim2.new(1, 0, 0, 40)
TabButtons.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
TabButtons.Parent = MainFrame

AimbotTab.Name = "AimbotTab"
AimbotTab.Size = UDim2.new(0.5, 0, 1, 0)
AimbotTab.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
AimbotTab.Text = "Aimbot"
AimbotTab.TextColor3 = Color3.fromRGB(255, 255, 255)
AimbotTab.Font = Enum.Font.GothamBold
AimbotTab.TextSize = 14
AimbotTab.Parent = TabButtons

ESPTab.Name = "ESPTab"
ESPTab.Size = UDim2.new(0.5, 0, 1, 0)
ESPTab.Position = UDim2.new(0.5, 0, 0, 0)
ESPTab.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ESPTab.Text = "ESP"
ESPTab.TextColor3 = Color3.fromRGB(255, 255, 255)
ESPTab.Font = Enum.Font.GothamBold
ESPTab.TextSize = 14
ESPTab.Parent = TabButtons

TabContainer.Name = "TabContainer"
TabContainer.Size = UDim2.new(1, 0, 1, -40)
TabContainer.Position = UDim2.new(0, 0, 0, 40)
TabContainer.BackgroundTransparency = 1
TabContainer.Parent = MainFrame

-- Create FOV Circle
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1.5
FOVCircle.NumSides = 60
FOVCircle.Radius = Settings.Aimbot.FOV
FOVCircle.Filled = false
FOVCircle.Visible = Settings.Aimbot.ShowFOV
FOVCircle.ZIndex = 999
FOVCircle.Transparency = 0.7
FOVCircle.Color = Color3.fromRGB(255, 255, 255)

-- Perfect Aim Function
local function perfectAim(targetPart)
    local screenCenter = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
    local targetPosition = camera:WorldToViewportPoint(targetPart.Position)
    local targetVector = Vector2.new(targetPosition.X, targetPosition.Y)
    
    local distanceFromCenter = (targetVector - screenCenter).Magnitude
    
    if distanceFromCenter > 5 then
        mousemoverel(targetPosition.X - screenCenter.X, targetPosition.Y - screenCenter.Y)
    end
end

-- Create ESP Function
local function CreateESP(player)
    local esp = {
        Box = Drawing.new("Square"),
        Name = Drawing.new("Text"),
        Distance = Drawing.new("Text"),
        Snapline = Drawing.new("Line"),
        HealthBar = Drawing.new("Square"),
        HealthBarBackground = Drawing.new("Square")
    }
    
    esp.Box.Visible = false
    esp.Box.Color = Settings.ESP.BoxColor
    esp.Box.Thickness = 1
    esp.Box.Filled = false
    esp.Box.Transparency = 1
    
    esp.Name.Visible = false
    esp.Name.Color = Color3.new(1, 1, 1)
    esp.Name.Size = 14
    esp.Name.Center = true
    esp.Name.Outline = true
    
    esp.Distance.Visible = false
    esp.Distance.Color = Color3.new(1, 1, 1)
    esp.Distance.Size = 12
    esp.Distance.Center = true
    esp.Distance.Outline = true
    
    esp.Snapline.Visible = false
    esp.Snapline.Color = Settings.ESP.BoxColor
    esp.Snapline.Thickness = 1
    esp.Snapline.Transparency = 1
    
    esp.HealthBar.Visible = false
    esp.HealthBar.Color = Color3.fromRGB(0, 255, 0)
    esp.HealthBar.Filled = true
    esp.HealthBar.Thickness = 1
    esp.HealthBar.Transparency = 1
    
    esp.HealthBarBackground.Visible = false
    esp.HealthBarBackground.Color = Color3.fromRGB(255, 0, 0)
    esp.HealthBarBackground.Filled = true
    esp.HealthBarBackground.Thickness = 1
    esp.HealthBarBackground.Transparency = 1
    
    Settings.ESP.Players[player] = esp
end
-- Get Closest Player Function
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

-- Update ESP Function
local function UpdateESP()
    if not Toggles.ESP then return end
    
    for player, esp in pairs(Settings.ESP.Players) do
        if player.Character and player ~= localPlayer then
            local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
            local humanoid = player.Character:FindFirstChild("Humanoid")
            
            if humanoidRootPart and humanoid then
                local pos, onScreen = camera:WorldToViewportPoint(humanoidRootPart.Position)
                local distance = (humanoidRootPart.Position - camera.CFrame.Position).Magnitude
                
                if onScreen and distance <= Settings.ESP.MaxDistance then
                    local size = (camera:WorldToViewportPoint(humanoidRootPart.Position + Vector3.new(2, 3, 0)).Y - camera:WorldToViewportPoint(humanoidRootPart.Position + Vector3.new(-2, -3, 0)).Y) / 2
                    
                    esp.Box.Size = Vector2.new(size * 1.5, size * 3)
                    esp.Box.Position = Vector2.new(pos.X - esp.Box.Size.X / 2, pos.Y - esp.Box.Size.Y / 2)
                    esp.Box.Color = Settings.ESP.Rainbow and Color3.fromHSV(tick() % 5 / 5, 1, 1) or Settings.ESP.BoxColor
                    esp.Box.Visible = Toggles.Boxes and Settings.ESP.Boxes
                    
                    local healthBarHeight = esp.Box.Size.Y * (humanoid.Health / humanoid.MaxHealth)
                    esp.HealthBarBackground.Size = Vector2.new(Settings.ESP.HealthBarSize.X, esp.Box.Size.Y)
                    esp.HealthBarBackground.Position = Vector2.new(esp.Box.Position.X - esp.HealthBarBackground.Size.X * 2, esp.Box.Position.Y)
                    esp.HealthBarBackground.Visible = Toggles.Health and Settings.ESP.Health
                    
                    esp.HealthBar.Size = Vector2.new(Settings.ESP.HealthBarSize.X, healthBarHeight)
                    esp.HealthBar.Position = Vector2.new(esp.Box.Position.X - esp.HealthBar.Size.X * 2, esp.Box.Position.Y + esp.Box.Size.Y - healthBarHeight)
                    esp.HealthBar.Visible = Toggles.Health and Settings.ESP.Health
                    
                    esp.Name.Position = Vector2.new(pos.X, esp.Box.Position.Y - 20)
                    esp.Name.Text = player.Name
                    esp.Name.Visible = Toggles.Names and Settings.ESP.Names
                    
                    esp.Distance.Position = Vector2.new(pos.X, esp.Box.Position.Y + esp.Box.Size.Y + 10)
                    esp.Distance.Text = string.format("%.0f studs", distance)
                    esp.Distance.Visible = Toggles.Distance and Settings.ESP.Distance
                    
                    esp.Snapline.From = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)
                    esp.Snapline.To = Vector2.new(pos.X, pos.Y)
                    esp.Snapline.Visible = Toggles.Snaplines and Settings.ESP.Snaplines
                else
                    esp.Box.Visible = false
                    esp.Name.Visible = false
                    esp.Distance.Visible = false
                    esp.Snapline.Visible = false
                    esp.HealthBar.Visible = false
                    esp.HealthBarBackground.Visible = false
                end
            end
        end
    end
end
-- Lock Camera Function
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

-- Create Toggle Button Function
local function CreateToggle(parent, name, category, setting)
    local ToggleFrame = Instance.new("Frame")
    local ToggleButton = Instance.new("TextButton")
    local ToggleStatus = Instance.new("Frame")
    
    ToggleFrame.Name = name .. "Toggle"
    ToggleFrame.Size = UDim2.new(0.9, 0, 0, 35)
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
    ToggleStatus.Size = UDim2.new(0, 20, 0, 20)
    ToggleStatus.Position = UDim2.new(0.9, 0, 0.5, 0)
    ToggleStatus.AnchorPoint = Vector2.new(0, 0.5)
    ToggleStatus.BackgroundColor3 = Settings[category][setting] and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 50, 50)
    ToggleStatus.Parent = ToggleFrame
    
    local StatusCorner = Instance.new("UICorner")
    StatusCorner.CornerRadius = UDim.new(1, 0)
    StatusCorner.Parent = ToggleStatus
    
    ToggleButton.MouseButton1Click:Connect(function()
        Settings[category][setting] = not Settings[category][setting]
        Toggles[name] = Settings[category][setting]
        ToggleStatus.BackgroundColor3 = Settings[category][setting] and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 50, 50)
    end)
    
    return ToggleFrame
end

-- Setup Pages
AimbotPage.Name = "AimbotPage"
AimbotPage.Size = UDim2.new(1, 0, 1, 0)
AimbotPage.BackgroundTransparency = 1
AimbotPage.ScrollBarThickness = 2
AimbotPage.Visible = true
AimbotPage.Parent = TabContainer

ESPPage.Name = "ESPPage"
ESPPage.Size = UDim2.new(1, 0, 1, 0)
ESPPage.BackgroundTransparency = 1
ESPPage.ScrollBarThickness = 2
ESPPage.Visible = false
ESPPage.Parent = TabContainer

-- Create UIListLayout for both pages
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
local AimbotToggles = {
    {name = "Enabled", setting = "Enabled"},
    {name = "Silent Aim", setting = "SilentAim"},
    {name = "Team Check", setting = "TeamCheck"},
    {name = "Show FOV", setting = "ShowFOV"},
    {name = "Auto Prediction", setting = "AutoPrediction"},
    {name = "Trigger Bot", setting = "TriggerBot"}
}

local ESPToggles = {
    {name = "Enabled", setting = "Enabled"},
    {name = "Boxes", setting = "Boxes"},
    {name = "Names", setting = "Names"},
    {name = "Distance", setting = "Distance"},
    {name = "Snaplines", setting = "Snaplines"},
    {name = "Health", setting = "Health"},
    {name = "Team Check", setting = "TeamCheck"},
    {name = "Rainbow", setting = "Rainbow"}
}

for _, toggle in ipairs(AimbotToggles) do
    CreateToggle(AimbotPage, toggle.name, "Aimbot", toggle.setting)
end

for _, toggle in ipairs(ESPToggles) do
    CreateToggle(ESPPage, toggle.name, "ESP", toggle.setting)
end

-- Tab Switching Logic
AimbotTab.MouseButton1Click:Connect(function()
    AimbotTab.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    ESPTab.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    AimbotPage.Visible = true
    ESPPage.Visible = false
end)

ESPTab.MouseButton1Click:Connect(function()
    ESPTab.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    AimbotTab.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    ESPPage.Visible = true
    AimbotPage.Visible = false
end)

-- Cleanup Function
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
    
    ScreenGui:Destroy()
end
-- Event Connections
for _, player in pairs(Players:GetPlayers()) do
    if player ~= localPlayer then
        CreateESP(player)
    end
end

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
    elseif input.KeyCode == Enum.KeyCode.RightControl then
        ScreenGui.Enabled = not ScreenGui.Enabled
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

-- Main Loop
RunService.RenderStepped:Connect(function()
    FOVCircle.Position = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
    FOVCircle.Visible = Settings.Aimbot.ShowFOV and Settings.Aimbot.Enabled
    
    UpdateESP()
    
    if Settings.Aimbot.Enabled and isRightMouseDown then
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
