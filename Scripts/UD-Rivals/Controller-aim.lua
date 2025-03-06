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

local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1.5
FOVCircle.NumSides = 60
FOVCircle.Radius = Settings.Aimbot.FOV
FOVCircle.Filled = false
FOVCircle.Visible = Settings.Aimbot.ShowFOV
FOVCircle.ZIndex = 999
FOVCircle.Transparency = 0.7
FOVCircle.Color = Color3.fromRGB(255, 255, 255)

local function perfectAim(targetPart)
    local screenCenter = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
    local targetPosition = camera:WorldToViewportPoint(targetPart.Position)
    local targetVector = Vector2.new(targetPosition.X, targetPosition.Y)
    
    -- Calculate distance from center
    local distanceFromCenter = (targetVector - screenCenter).Magnitude
    
    -- Only move mouse if target isn't centered (with small threshold)
    if distanceFromCenter > 5 then
        mousemoverel(targetPosition.X - screenCenter.X, targetPosition.Y - screenCenter.Y)
    end
end

-- Update the RenderStepped connection
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

local function cleanup()
    -- Turn off all toggles
    for toggle in pairs(Toggles) do
        Toggles[toggle] = false
    end
    
    -- Remove FOV Circle
    FOVCircle:Remove()
    
    -- Clean up all ESP elements
    for _, esp in pairs(Settings.ESP.Players) do
        for _, drawing in pairs(esp) do
            drawing:Remove()
        end
    end
    
    -- Clear ESP players table
    Settings.ESP.Players = {}
    
    -- Reset variables
    targetPlayer = nil
    isLeftMouseDown = false
    isRightMouseDown = false
    
    -- Disconnect auto click if exists
    if autoClickConnection then
        autoClickConnection:Disconnect()
    end
    
    -- Disable all settings
    Settings.ESP.Enabled = false
    Settings.Aimbot.Enabled = false
    
    -- Remove all connections
    for _, connection in pairs(getconnections(RunService.RenderStepped)) do
        connection:Disable()
    end
    
    for _, connection in pairs(getconnections(UserInputService.InputBegan)) do
        connection:Disable()
    end
    
    for _, connection in pairs(getconnections(UserInputService.InputEnded)) do
        connection:Disable()
    end
    
    -- Destroy the script
    script:Destroy()
end

local toggleKeys = {
    [Enum.KeyCode.KeypadOne] = function()
        Toggles.ESP = not Toggles.ESP
        for _, esp in pairs(Settings.ESP.Players) do
            esp.Box.Visible = false
            esp.Name.Visible = false
            esp.Distance.Visible = false
            esp.Snapline.Visible = false
            esp.HealthBar.Visible = false
            esp.HealthBarBackground.Visible = false
        end
    end,
    [Enum.KeyCode.KeypadTwo] = function()
        Toggles.Aimbot = not Toggles.Aimbot
        FOVCircle.Visible = Toggles.Aimbot and Settings.Aimbot.ShowFOV
    end,
    [Enum.KeyCode.KeypadThree] = function()
        Toggles.Boxes = not Toggles.Boxes
    end,
    [Enum.KeyCode.KeypadFour] = function()
        Toggles.Names = not Toggles.Names
    end,
    [Enum.KeyCode.KeypadFive] = function()
        Toggles.Distance = not Toggles.Distance
    end,
    [Enum.KeyCode.KeypadSix] = function()
        Toggles.Snaplines = not Toggles.Snaplines
    end,
    [Enum.KeyCode.KeypadSeven] = function()
        Toggles.Health = not Toggles.Health
    end
}

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
