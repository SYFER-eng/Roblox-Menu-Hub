local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

-- Enhanced settings with Rivals-specific configurations
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
        Smoothness = 0.5,
        FOV = 150,
        TargetPart = "Head",
        ShowFOV = true,
        PredictionMultiplier = 1.5,
        AutoPrediction = true,
        TriggerBot = false,
        TriggerDelay = 0.1
    }
}

-- Improved FOV Circle
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1.5
FOVCircle.NumSides = 60
FOVCircle.Radius = Settings.Aimbot.FOV
FOVCircle.Filled = false
FOVCircle.Visible = Settings.Aimbot.ShowFOV
FOVCircle.ZIndex = 999
FOVCircle.Transparency = 0.7
FOVCircle.Color = Color3.fromRGB(255, 255, 255)

-- Enhanced ESP creation function
local function CreateESP(player)
    local esp = {
        Box = Drawing.new("Square"),
        Name = Drawing.new("Text"),
        Distance = Drawing.new("Text"),
        Snapline = Drawing.new("Line"),
        HealthBar = Drawing.new("Square"),
        HealthBarBackground = Drawing.new("Square")
    }
    
    -- Box setup
    esp.Box.Visible = false
    esp.Box.Color = Settings.ESP.BoxColor
    esp.Box.Thickness = 1
    esp.Box.Filled = false
    esp.Box.Transparency = 1
    
    -- Name setup
    esp.Name.Visible = false
    esp.Name.Color = Color3.new(1, 1, 1)
    esp.Name.Size = 14
    esp.Name.Center = true
    esp.Name.Outline = true
    
    -- Distance setup
    esp.Distance.Visible = false
    esp.Distance.Color = Color3.new(1, 1, 1)
    esp.Distance.Size = 12
    esp.Distance.Center = true
    esp.Distance.Outline = true
    
    -- Snapline setup
    esp.Snapline.Visible = false
    esp.Snapline.Color = Settings.ESP.BoxColor
    esp.Snapline.Thickness = 1
    esp.Snapline.Transparency = 1
    
    -- Health bar setup
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

-- Get the gun muzzle position
local function GetGunMuzzlePosition(player)
    -- Assume the weapon is part of the character, specifically looking for the gun's muzzle
    local character = player.Character
    if character then
        local weapon = character:FindFirstChild("Weapon")  -- Change this based on the actual weapon name in Rivals
        if weapon then
            local muzzle = weapon:FindFirstChild("Muzzle")  -- Adjust for the actual part in the game
            if muzzle then
                return muzzle.Position
            end
        end
    end
    return nil
end

-- Enhanced target acquisition
local function GetClosestPlayer()
    local closestPlayer, shortestDistance = nil, Settings.Aimbot.FOV
    local mousePos = UserInputService:GetMouseLocation()
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= Players.LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            if Settings.Aimbot.TeamCheck and player.Team == Players.LocalPlayer.Team then continue end
            
            local humanoid = player.Character:FindFirstChild("Humanoid")
            if not humanoid or humanoid.Health <= 0 then continue end
            
            local targetPart = player.Character:FindFirstChild(Settings.Aimbot.TargetPart)
            if not targetPart then
                -- If the target part is not found, aim at the humanoid root part.
                targetPart = player.Character.HumanoidRootPart
            end
            
            local velocity = player.Character.HumanoidRootPart.Velocity
            local prediction = velocity * Settings.Aimbot.PredictionMultiplier
            local predictedPosition = targetPart.Position + prediction
            
            local pos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(predictedPosition)
            if onScreen then
                local distance = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
                if distance < shortestDistance then
                    closestPlayer = player
                    shortestDistance = distance
                end
            end
        end
    end
    return closestPlayer
end

-- Improved aiming mechanics with additional prediction and smoothness
local function AimAt(targetPosition)
    local camera = workspace.CurrentCamera
    local mousePos = UserInputService:GetMouseLocation()
    local targetPos = camera:WorldToViewportPoint(targetPosition)
    
    -- Smooth aiming with dynamic adjustment based on distance
    local aimDelta = Vector2.new(
        (targetPos.X - mousePos.X) * Settings.Aimbot.Smoothness,
        (targetPos.Y - mousePos.Y) * Settings.Aimbot.Smoothness
    )
    
    -- Apply small corrective movements to the mouse for better aim
    mousemoverel(aimDelta.X, aimDelta.Y)
end

-- Enhanced ESP update function
local function UpdateESP()
    for player, esp in pairs(Settings.ESP.Players) do
        if player.Character and player ~= Players.LocalPlayer then
            local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
            local humanoid = player.Character:FindFirstChild("Humanoid")
            
            if humanoidRootPart and humanoid then
                local pos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(humanoidRootPart.Position)
                local distance = (humanoidRootPart.Position - workspace.CurrentCamera.CFrame.Position).Magnitude
                
                if onScreen and distance <= Settings.ESP.MaxDistance then
                    -- Update box
                    local size = (workspace.CurrentCamera:WorldToViewportPoint(humanoidRootPart.Position + Vector3.new(2, 3, 0)).Y - workspace.CurrentCamera:WorldToViewportPoint(humanoidRootPart.Position + Vector3.new(-2, -3, 0)).Y) / 2
                    esp.Box.Size = Vector2.new(size * 1.5, size * 3)
                    esp.Box.Position = Vector2.new(pos.X - esp.Box.Size.X / 2, pos.Y - esp.Box.Size.Y / 2)
                    esp.Box.Color = Settings.ESP.Rainbow and Color3.fromHSV(tick() % 5 / 5, 1, 1) or Settings.ESP.BoxColor
                    esp.Box.Visible = Settings.ESP.Boxes
                    
                    -- Update health bar
                    local healthBarHeight = esp.Box.Size.Y * (humanoid.Health / humanoid.MaxHealth)
                    esp.HealthBarBackground.Size = Vector2.new(Settings.ESP.HealthBarSize.X, esp.Box.Size.Y)
                    esp.HealthBarBackground.Position = Vector2.new(esp.Box.Position.X - esp.HealthBarBackground.Size.X * 2, esp.Box.Position.Y)
                    esp.HealthBarBackground.Visible = Settings.ESP.Health
                    
                    esp.HealthBar.Size = Vector2.new(Settings.ESP.HealthBarSize.X, healthBarHeight)
                    esp.HealthBar.Position = Vector2.new(esp.Box.Position.X - esp.HealthBar.Size.X * 2, esp.Box.Position.Y + esp.Box.Size.Y - healthBarHeight)
                    esp.HealthBar.Visible = Settings.ESP.Health
                    
                    -- Update name and distance
                    esp.Name.Position = Vector2.new(pos.X, esp.Box.Position.Y - 20)
                    esp.Name.Text = player.Name
                    esp.Name.Visible = Settings.ESP.Names
                    
                    esp.Distance.Position = Vector2.new(pos.X, esp.Box.Position.Y + esp.Box.Size.Y + 10)
                    esp.Distance.Text = string.format("%.0f studs", distance)
                    esp.Distance.Visible = Settings.ESP.Distance
                    
                    -- Update snapline
                    esp.Snapline.From = Vector2.new(workspace.CurrentCamera.ViewportSize.X / 2, workspace.CurrentCamera.ViewportSize.Y)
                    esp.Snapline.To = Vector2.new(pos.X, pos.Y)
                    esp.Snapline.Visible = Settings.ESP.Snaplines
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

-- Initialize ESP for existing players
for _, player in pairs(Players:GetPlayers()) do
    if player ~= Players.LocalPlayer then
        CreateESP(player)
    end
end

-- Handle new players
Players.PlayerAdded:Connect(function(player)
    if player ~= Players.LocalPlayer then
        CreateESP(player)
    end
end)

-- Handle player removal
Players.PlayerRemoving:Connect(function(player)
    if Settings.ESP.Players[player] then
        for _, drawing in pairs(Settings.ESP.Players[player]) do
            drawing:Remove()
        end
        Settings.ESP.Players[player] = nil
    end
end)

-- Main update loop
RunService.RenderStepped:Connect(function()
    UpdateESP()
    
    if Settings.Aimbot.Enabled and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local target = GetClosestPlayer()
        if target and target.Character then
            local targetPart = target.Character:FindFirstChild(Settings.Aimbot.TargetPart)
            if targetPart then
                local velocity = target.Character.HumanoidRootPart.Velocity
                local prediction = velocity * Settings.Aimbot.PredictionMultiplier
                local predictedPosition = targetPart.Position + prediction
                
                AimAt(predictedPosition)
            end
        end
    end
    
    FOVCircle.Position = UserInputService:GetMouseLocation()
    FOVCircle.Visible = Settings.Aimbot.ShowFOV
end)

-- Keybind handling
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed then
        local keyBinds = {
            [Enum.KeyCode.End] = function() Settings.ESP.Enabled = not Settings.ESP.Enabled end,
            [Enum.KeyCode.RightAlt] = function() Settings.Aimbot.Enabled = not Settings.Aimbot.Enabled end,
            [Enum.KeyCode.F1] = function() Settings.ESP.Boxes = not Settings.ESP.Boxes end,
            [Enum.KeyCode.F2] = function() Settings.ESP.Names = not Settings.ESP.Names end,
            [Enum.KeyCode.F3] = function() Settings.ESP.Distance = not Settings.ESP.Distance end,
            [Enum.KeyCode.F4] = function() Settings.ESP.Snaplines = not Settings.ESP.Snaplines end
        }
        
        if keyBinds[input.KeyCode] then
            keyBinds[input.KeyCode]()
        end
    end
end)
