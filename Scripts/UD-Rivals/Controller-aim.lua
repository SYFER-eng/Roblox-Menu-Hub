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

local ControllerSettings = {
    AimAssist = true,
    AimAssistStrength = 0.5,
    DeadZone = 0.1,
    Sensitivity = {
        X = 1.0,
        Y = 1.0
    }
}

local AimSettings = {
    SilentAim = true,
    HitChance = 100,
    TargetPart = "Head",
    PredictionEnabled = true,
    PredictionAmount = 0.165,
    AutoPrediction = {
        Enabled = true,
        Ping = 30,
        Amount = 0.165
    }
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
        BoxStyle = "Corner",
        BoxThickness = 2,
        BoxTransparency = 0.8,
        MaxDistance = 2000,
        TeamCheck = false,
        HealthBarStyle = "Side",
        RainbowSpeed = 1,
        RefreshRate = 0.1,
        Players = {},
        BoxColor = Color3.fromRGB(255, 0, 255),
        HealthBarSize = Vector2.new(2, 20)
    },
    Aimbot = {
        Enabled = true,
        TeamCheck = false,
        Smoothness = 0.009,
        FOV = 180,
        DynamicFOV = true,
        FOVScaleWithDistance = true,
        PredictMovement = true,
        MaxDistance = 500,
        TargetPriority = "Distance",
        ShowFOV = true
    },
    Controller = ControllerSettings
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

local function HandleControllerInput()
    local rightThumb = UserInputService:GetGamepadState(Enum.UserInputType.Gamepad1).Thumbstick2
    local leftThumb = UserInputService:GetGamepadState(Enum.UserInputType.Gamepad1).Thumbstick1
    
    if math.abs(rightThumb.X) < Settings.Controller.DeadZone then rightThumb = Vector2.new(0, rightThumb.Y) end
    if math.abs(rightThumb.Y) < Settings.Controller.DeadZone then rightThumb = Vector2.new(rightThumb.X, 0) end
    
    if Settings.Controller.AimAssist and Settings.Aimbot.Enabled then
        local target = GetClosestPlayerToMouse()
        if target and target.Character then
            local targetPart = target.Character:FindFirstChild(AimSettings.TargetPart)
            if targetPart then
                local targetPos = camera:WorldToViewportPoint(targetPart.Position)
                local mousePos = UserInputService:GetMouseLocation()
                local diff = Vector2.new(
                    (targetPos.X - mousePos.X) * Settings.Controller.AimAssistStrength,
                    (targetPos.Y - mousePos.Y) * Settings.Controller.AimAssistStrength
                )
                rightThumb = rightThumb + Vector2.new(diff.X, diff.Y)
            end
        end
    end
    
    if rightThumb.Magnitude > 0 then
        local rotX = rightThumb.X * Settings.Controller.Sensitivity.X
        local rotY = rightThumb.Y * Settings.Controller.Sensitivity.Y
        camera.CFrame = camera.CFrame * CFrame.Angles(math.rad(-rotY), math.rad(rotX), 0)
    end
end

local function PredictPosition(target)
    if not AimSettings.PredictionEnabled then return target.Position end
    
    local velocity = target.Velocity
    local ping = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()
    
    local predictionAmount = AimSettings.AutoPrediction.Enabled and 
        (ping / 1000 * AimSettings.AutoPrediction.Amount) or 
        AimSettings.PredictionAmount
    
    return target.Position + (velocity * predictionAmount)
end
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
    esp.Box.Thickness = Settings.ESP.BoxThickness
    esp.Box.Transparency = Settings.ESP.BoxTransparency
    esp.Box.Filled = false
    
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
    local mousePosition = UserInputService:GetMouseLocation()

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
                local distance = (screenPosition - mousePosition).Magnitude

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
                    
                    if Settings.ESP.BoxStyle == "Corner" then
                        local cornerSize = size * 0.2
                        esp.Box.Size = Vector2.new(size * 1.5, size * 3)
                        esp.Box.Position = Vector2.new(pos.X - esp.Box.Size.X / 2, pos.Y - esp.Box.Size.Y / 2)
                    else
                        esp.Box.Size = Vector2.new(size * 1.5, size * 3)
                        esp.Box.Position = Vector2.new(pos.X - esp.Box.Size.X / 2, pos.Y - esp.Box.Size.Y / 2)
                    end
                    
                    esp.Box.Color = Settings.ESP.Rainbow and Color3.fromHSV(tick() * Settings.ESP.RainbowSpeed % 1, 1, 1) or Settings.ESP.BoxColor
                    esp.Box.Visible = Toggles.Boxes
                    
                    local healthPercent = humanoid.Health / humanoid.MaxHealth
                    local healthColor = Color3.fromRGB(
                        255 * (1 - healthPercent),
                        255 * healthPercent,
                        0
                    )
                    
                    if Settings.ESP.HealthBarStyle == "Side" then
                        local healthBarHeight = esp.Box.Size.Y * healthPercent
                        esp.HealthBar.Size = Vector2.new(Settings.ESP.HealthBarSize.X, healthBarHeight)
                        esp.HealthBar.Position = Vector2.new(esp.Box.Position.X - esp.HealthBar.Size.X * 2, esp.Box.Position.Y + esp.Box.Size.Y - healthBarHeight)
                        esp.HealthBar.Color = healthColor
                    end
                    
                    esp.Name.Position = Vector2.new(pos.X, esp.Box.Position.Y - 20)
                    esp.Name.Text = string.format("%s [%d%%]", player.Name, healthPercent * 100)
                    esp.Name.Visible = Toggles.Names
                    
                    esp.Distance.Position = Vector2.new(pos.X, esp.Box.Position.Y + esp.Box.Size.Y + 10)
                    esp.Distance.Text = string.format("%.0f studs", distance)
                    esp.Distance.Visible = Toggles.Distance
                    
                    esp.Snapline.From = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)
                    esp.Snapline.To = Vector2.new(pos.X, pos.Y)
                    esp.Snapline.Visible = Toggles.Snaplines
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
local controllerButtons = {
    [Enum.KeyCode.ButtonL2] = function()
        isRightMouseDown = true
        targetPlayer = GetClosestPlayerToMouse()
    end,
    [Enum.KeyCode.ButtonR2] = function()
        isLeftMouseDown = true
    end,
    [Enum.KeyCode.DPadUp] = function()
        Toggles.ESP = not Toggles.ESP
    end,
    [Enum.KeyCode.DPadRight] = function()
        Toggles.Aimbot = not Toggles.Aimbot
    end,
    [Enum.KeyCode.DPadDown] = function()
        Toggles.Boxes = not Toggles.Boxes
    end,
    [Enum.KeyCode.DPadLeft] = function()
        Toggles.Names = not Toggles.Names
    end
}

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
    end,
    [Enum.KeyCode.KeypadEight] = function()
        Settings.ESP.BoxStyle = Settings.ESP.BoxStyle == "Corner" and "Full" or "Corner"
    end,
    [Enum.KeyCode.KeypadNine] = function()
        Settings.Aimbot.DynamicFOV = not Settings.Aimbot.DynamicFOV
    end
}

local function cleanup()
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
    
    script:Destroy()
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

-- Input Handling
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.UserInputType == Enum.UserInputType.Gamepad1 then
        if controllerButtons[input.KeyCode] then
            controllerButtons[input.KeyCode]()
        end
    else
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
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.UserInputType == Enum.UserInputType.Gamepad1 then
        if input.KeyCode == Enum.KeyCode.ButtonL2 then
            isRightMouseDown = false
            targetPlayer = nil
        elseif input.KeyCode == Enum.KeyCode.ButtonR2 then
            isLeftMouseDown = false
        end
    else
        -- Rest of the input handling remains the same
    end
end)

-- Main Loop
RunService.RenderStepped:Connect(function()
    FOVCircle.Position = UserInputService:GetMouseLocation()
    FOVCircle.Visible = Toggles.Aimbot and Settings.Aimbot.ShowFOV
    
    if Settings.Aimbot.DynamicFOV then
        local scale = Settings.Aimbot.FOVScaleWithDistance and (camera.ViewportSize.Y / 1080) or 1
        FOVCircle.Radius = Settings.Aimbot.FOV * scale
    end
    
    UpdateESP()
    HandleControllerInput()
    
    if Settings.Aimbot.Enabled and Toggles.Aimbot and (isRightMouseDown or UserInputService:IsGamepadButtonDown(Enum.UserInputType.Gamepad1, Enum.KeyCode.ButtonL2)) then
        if not targetPlayer then
            targetPlayer = GetClosestPlayerToMouse()
        end
        if targetPlayer and targetPlayer.Character then
            local targetPart = targetPlayer.Character:FindFirstChild(AimSettings.TargetPart)
            if targetPart then
                local predictedPosition = PredictPosition(targetPart)
                if Settings.Aimbot.Smoothness > 0 then
                    local mousePos = UserInputService:GetMouseLocation()
                    local targetPos = camera:WorldToViewportPoint(predictedPosition)
                    mousemoverel(
                        (targetPos.X - mousePos.X) * Settings.Aimbot.Smoothness,
                        (targetPos.Y - mousePos.Y) * Settings.Aimbot.Smoothness
                    )
                end
            end
        end
    end
end)
