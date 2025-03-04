local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

-- Settings Initialization
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
        Tracers = {}
    },
    Aimbot = {
        Enabled = true,
        TeamCheck = false,
        Smoothness = 1,
        FOV = 100,
        TargetPart = "Head",
        ShowFOV = true
    }
}

-- FOV Circle Setup
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2
FOVCircle.NumSides = 100
FOVCircle.Radius = 100
FOVCircle.Filled = false
FOVCircle.Visible = false
FOVCircle.ZIndex = 999
FOVCircle.Transparency = 1
FOVCircle.Color = Color3.fromRGB(255, 0, 255)

-- Utility function to get the closest player
local function GetClosestPlayer()
    local closestPlayer, shortestDistance = nil, math.huge
    local mousePos = UserInputService:GetMouseLocation()

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= Players.LocalPlayer then
            if Settings.Aimbot.TeamCheck and player.Team == Players.LocalPlayer.Team then continue end

            local character = player.Character
            if character then
                local targetPart = character:FindFirstChild(Settings.Aimbot.TargetPart)
                if targetPart then
                    local pos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(targetPart.Position)
                    if onScreen then
                        local distance = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
                        if distance <= Settings.Aimbot.FOV and distance < shortestDistance then
                            closestPlayer, shortestDistance = player, distance
                        end
                    end
                end
            end
        end
    end

    return closestPlayer
end

-- Utility function to create ESP for a player
local function CreateESP(player)
    local esp = {
        Box = Drawing.new("Square"),
        Name = Drawing.new("Text"),
        Distance = Drawing.new("Text"),
        Snapline = Drawing.new("Line")
    }

    esp.Box.Visible = false
    esp.Box.Color = Settings.ESP.BoxColor
    esp.Box.Thickness = 2
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

    Settings.ESP.Players[player] = esp
end

-- Utility function to update ESP for all players
local function UpdateESP()
    for player, esp in pairs(Settings.ESP.Players) do
        if player.Character and player ~= Players.LocalPlayer and player.Character:FindFirstChild("HumanoidRootPart") then
            local humanoidRootPart = player.Character.HumanoidRootPart
            local head = player.Character:FindFirstChild("Head")
            local screenPos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(humanoidRootPart.Position)

            if onScreen and Settings.ESP.Enabled then
                if Settings.ESP.TeamCheck and player.Team == Players.LocalPlayer.Team then
                    esp.Box.Visible, esp.Name.Visible, esp.Distance.Visible, esp.Snapline.Visible = false, false, false, false
                    continue
                end

                -- Update Box ESP
                if Settings.ESP.Boxes then
                    local size = (workspace.CurrentCamera:WorldToViewportPoint(humanoidRootPart.Position + Vector3.new(3, 6, 0)).Y - workspace.CurrentCamera:WorldToViewportPoint(humanoidRootPart.Position + Vector3.new(-3, -3, 0)).Y) / 2
                    esp.Box.Size = Vector2.new(size * 0.7, size * 1)
                    esp.Box.Position = Vector2.new(screenPos.X - esp.Box.Size.X / 2, screenPos.Y - esp.Box.Size.Y / 2)
                    esp.Box.Color = Settings.ESP.Rainbow and Color3.fromHSV(tick() % 5 / 5, 1, 1) or Settings.ESP.BoxColor
                    esp.Box.Visible = true
                else
                    esp.Box.Visible = false
                end

                -- Snaplines
                if Settings.ESP.Snaplines then
                    esp.Snapline.From = Vector2.new(workspace.CurrentCamera.ViewportSize.X / 2, workspace.CurrentCamera.ViewportSize.Y)
                    esp.Snapline.To = Vector2.new(screenPos.X, screenPos.Y)
                    esp.Snapline.Color = Settings.ESP.Rainbow and Color3.fromHSV(tick() % 5 / 5, 1, 1) or Settings.ESP.BoxColor
                    esp.Snapline.Visible = true
                else
                    esp.Snapline.Visible = false
                end

                -- Names and Distance
                if Settings.ESP.Names and head then
                    esp.Name.Position = Vector2.new(screenPos.X, screenPos.Y - esp.Box.Size.Y / 2 - 15)
                    esp.Name.Text = player.Name
                    esp.Name.Visible = true
                else
                    esp.Name.Visible = false
                end

                if Settings.ESP.Distance then
                    local distance = math.floor((humanoidRootPart.Position - workspace.CurrentCamera.CFrame.Position).Magnitude)
                    esp.Distance.Position = Vector2.new(screenPos.X, screenPos.Y + esp.Box.Size.Y / 2 + 5)
                    esp.Distance.Text = tostring(distance) .. " studs"
                    esp.Distance.Visible = true
                else
                    esp.Distance.Visible = false
                end
            else
                esp.Box.Visible, esp.Name.Visible, esp.Distance.Visible, esp.Snapline.Visible = false, false, false, false
            end
        else
            esp.Box.Visible, esp.Name.Visible, esp.Distance.Visible, esp.Snapline.Visible = false, false, false, false
        end
    end
end

-- Handle user input for toggling features
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed then
        -- Toggle settings based on keypad input
        local keyToggleMapping = {
            [Enum.KeyCode.KeypadOne] = function() Settings.ESP.Enabled = not Settings.ESP.Enabled end,
            [Enum.KeyCode.KeypadTwo] = function() Settings.Aimbot.Enabled = not Settings.Aimbot.Enabled end,
            [Enum.KeyCode.KeypadThree] = function() Settings.ESP.Boxes = not Settings.ESP.Boxes end,
            [Enum.KeyCode.KeypadFour] = function() Settings.ESP.Names = not Settings.ESP.Names end,
            [Enum.KeyCode.KeypadFive] = function() Settings.ESP.Distance = not Settings.ESP.Distance end,
            [Enum.KeyCode.KeypadSix] = function() Settings.ESP.Snaplines = not Settings.ESP.Snaplines end,
            [Enum.KeyCode.KeypadSeven] = function() 
                Settings.ESP.TeamCheck = not Settings.ESP.TeamCheck
                Settings.Aimbot.TeamCheck = not Settings.Aimbot.TeamCheck
            end,
            [Enum.KeyCode.KeypadEight] = function() Settings.ESP.Rainbow = not Settings.ESP.Rainbow end,
            [Enum.KeyCode.KeypadNine] = function() 
                Settings.Aimbot.ShowFOV = not Settings.Aimbot.ShowFOV
                FOVCircle.Visible = Settings.Aimbot.ShowFOV
            end,
        }

        if keyToggleMapping[input.KeyCode] then
            keyToggleMapping[input.KeyCode]()
        end
    end
end)

-- Initialize ESP for all existing players
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

-- Main Update Loop
RunService.RenderStepped:Connect(function()
    UpdateESP()

    if Settings.Aimbot.Enabled and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local target = GetClosestPlayer()
        if target and target.Character then
            local targetPart = target.Character:FindFirstChild(Settings.Aimbot.TargetPart)
            if targetPart then
                local targetPos = targetPart.Position
                local currentCFrame = workspace.CurrentCamera.CFrame
                local targetCFrame = CFrame.new(currentCFrame.Position, targetPos)
                local smoothness = Settings.Aimbot.Smoothness

                workspace.CurrentCamera.CFrame = smoothness > 1 and currentCFrame:Lerp(targetCFrame, 1 / smoothness) or targetCFrame
            end
        end
    end

    if Settings.Aimbot.ShowFOV then
        FOVCircle.Position = UserInputService:GetMouseLocation()
        FOVCircle.Radius = Settings.Aimbot.FOV
        FOVCircle.Visible = true
    else
        FOVCircle.Visible = false
    end
end)
