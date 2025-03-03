local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

-- Settings
Settings = {
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
    },
    Misc = {
        NoRecoil = false,
        BunnyHop = false
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
-- Navigation Setup
local Navigation = Instance.new("Frame")
Navigation.Size = UDim2.new(1, 0, 0, 50)
Navigation.Position = UDim2.new(0, 0, 0, 40)
Navigation.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Navigation.ZIndex = 999999
Navigation.Parent = MainFrame


local function GetClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = math.huge
    local mousePos = UserInputService:GetMouseLocation()

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= Players.LocalPlayer then
            if Settings.Aimbot.TeamCheck and player.Team == Players.LocalPlayer.Team then
                continue
            end

            local character = player.Character
            if character then
                local targetPart = character:FindFirstChild(Settings.Aimbot.TargetPart)
                if targetPart then
                    local pos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(targetPart.Position)
                    if onScreen then
                        local distance = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
                        if distance <= Settings.Aimbot.FOV then
                            if distance < shortestDistance then
                                closestPlayer = player
                                shortestDistance = distance
                            end
                        end
                    end
                end
            end
        end
    end
    return closestPlayer
end

-- Function to make the player's character face the target
local function MakePlayerLookAtTarget(target)
    if target and target.Character then
        local targetPart = target.Character:FindFirstChild(Settings.Aimbot.TargetPart)
        if targetPart then
            -- Get the target position and the player's humanoid root part position
            local targetPosition = targetPart.Position
            local playerCharacter = Players.LocalPlayer.Character
            local playerHumanoidRootPart = playerCharacter:FindFirstChild("HumanoidRootPart")
            
            -- Ensure the player character exists and the humanoid root part is found
            if playerHumanoidRootPart then
                -- Calculate the direction vector to the target
                local direction = (targetPosition - playerHumanoidRootPart.Position).unit
                
                -- Create a new CFrame to make the character rotate toward the target
                local newCFrame = CFrame.lookAt(playerHumanoidRootPart.Position, targetPosition)
                
                -- Update the character's HumanoidRootPart to look at the target
                playerHumanoidRootPart.CFrame = newCFrame
            end
        end
    end
end

-- Function to detect right mouse button press and hold
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.UserInputType == Enum.UserInputType.MouseButton2 then
        aiming = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        aiming = false
    end
end)

-- Main loop to continuously aim and make your player look at the closest player when aiming
RunService.RenderStepped:Connect(function()
    if aiming and Settings.Aimbot.Enabled then
        local closestPlayer = GetClosestPlayer()
        if closestPlayer then
            MakePlayerLookAtTarget(closestPlayer)
        end
    end
end)

-- ESP Implementation
local function CreateSnapline(player)
    local Line = Drawing.new("Line")
    Line.Thickness = 2 -- Increased thickness for glow effect
    Line.Color = Color3.fromRGB(255, 0, 255) -- Default color before rainbow toggle
    Line.Transparency = 1
    Line.Visible = false
    Line.ZIndex = 999998
    Settings.ESP.Tracers[player] = Line
end

-- ESP Implementation
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

local function UpdateESP()
    for player, esp in pairs(Settings.ESP.Players) do
        if player.Character and player ~= Players.LocalPlayer and player.Character:FindFirstChild("HumanoidRootPart") then
            local humanoidRootPart = player.Character.HumanoidRootPart
            local head = player.Character:FindFirstChild("Head")
            local screenPos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(humanoidRootPart.Position)
            
            if onScreen and Settings.ESP.Enabled then
                if Settings.ESP.TeamCheck and player.Team == Players.LocalPlayer.Team then
                    esp.Box.Visible = false
                    esp.Name.Visible = false
                    esp.Distance.Visible = false
                    esp.Snapline.Visible = false
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

                -- Update Snaplines
                if Settings.ESP.Snaplines then
                    esp.Snapline.From = Vector2.new(workspace.CurrentCamera.ViewportSize.X / 2, workspace.CurrentCamera.ViewportSize.Y)
                    esp.Snapline.To = Vector2.new(screenPos.X, screenPos.Y)
                    esp.Snapline.Color = Settings.ESP.Rainbow and Color3.fromHSV(tick() % 5 / 5, 1, 1) or Settings.ESP.BoxColor
                    esp.Snapline.Visible = true
                else
                    esp.Snapline.Visible = false
                end

                -- Update Names
                if Settings.ESP.Names and head then
                    esp.Name.Position = Vector2.new(screenPos.X, screenPos.Y - esp.Box.Size.Y / 2 - 15)
                    esp.Name.Text = player.Name
                    esp.Name.Visible = true
                else
                    esp.Name.Visible = false
                end

                -- Update Distance
                if Settings.ESP.Distance then
                    local distance = math.floor((humanoidRootPart.Position - workspace.CurrentCamera.CFrame.Position).Magnitude)
                    esp.Distance.Position = Vector2.new(screenPos.X, screenPos.Y + esp.Box.Size.Y / 2 + 5)
                    esp.Distance.Text = tostring(distance) .. " studs"
                    esp.Distance.Visible = true
                else
                    esp.Distance.Visible = false
                end
            else
                esp.Box.Visible = false
                esp.Name.Visible = false
                esp.Distance.Visible = false
                esp.Snapline.Visible = false
            end
        else
            esp.Box.Visible = false
            esp.Name.Visible = false
            esp.Distance.Visible = false
            esp.Snapline.Visible = false
        end
    end
end

-- Initialize UI Elements
local function InitializeUI()
    -- ESP Page
    CreateToggle(Pages.ESP, "Enable ESP", function(enabled)
        Settings.ESP.Enabled = enabled
    end)
    
    CreateToggle(Pages.ESP, "Box ESP", function(enabled)
        Settings.ESP.Boxes = enabled
    end)
    
    CreateToggle(Pages.ESP, "Snaplines", function(enabled)
        Settings.ESP.Snaplines = enabled
    end)
    
    CreateToggle(Pages.ESP, "Team Check", function(enabled)
        Settings.ESP.TeamCheck = enabled
    end)
    
    CreateToggle(Pages.ESP, "Rainbow Mode", function(enabled)
        Settings.ESP.Rainbow = enabled
    end)

    -- Aimbot Page
    CreateToggle(Pages.Aimbot, "Enable Aimbot", function(enabled)
        Settings.Aimbot.Enabled = enabled
    end)

    CreateToggle(Pages.Aimbot, "Show FOV", function(enabled)
        Settings.Aimbot.ShowFOV = enabled
        FOVCircle.Visible = enabled
    end)

    CreateToggle(Pages.Aimbot, "Team Check", function(enabled)
        Settings.Aimbot.TeamCheck = enabled
    end)

    CreateSlider(Pages.Aimbot, "Smoothness", 1, 10, 1, function(value)
        Settings.Aimbot.Smoothness = value
    end)

    CreateSlider(Pages.Aimbot, "FOV Size", 10, 800, 100, function(value)
        Settings.Aimbot.FOV = value
        FOVCircle.Radius = value
    end)

    -- Misc Page
    CreateToggle(Pages.Misc, "No Recoil", function(enabled)
        Settings.Misc.NoRecoil = enabled
    end)

    CreateToggle(Pages.Misc, "Bunny Hop", function(enabled)
        Settings.Misc.BunnyHop = enabled
    end)
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

-- Cleanup when players leave
Players.PlayerRemoving:Connect(function(player)
    if Settings.ESP.Players[player] then
        Settings.ESP.Players[player]:Remove()
        Settings.ESP.Players[player] = nil
    end
    if Settings.ESP.Tracers[player] then
        Settings.ESP.Tracers[player]:Remove()
        Settings.ESP.Tracers[player] = nil
    end
end)

-- Main Update Loop
RunService.RenderStepped:Connect(function()
    UpdateESP() -- Make sure this is called every frame
    if Settings.Aimbot.Enabled and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local target = GetClosestPlayer()
        if target and target.Character then
            local targetPart = target.Character:FindFirstChild(Settings.Aimbot.TargetPart)
            if targetPart then
                local targetPos = targetPart.Position
                local smoothness = Settings.Aimbot.Smoothness
                
                local currentCFrame = workspace.CurrentCamera.CFrame
                local targetCFrame = CFrame.new(currentCFrame.Position, targetPos)
                
                if smoothness > 1 then
                    workspace.CurrentCamera.CFrame = currentCFrame:Lerp(targetCFrame, 1 / smoothness)
                else
                    workspace.CurrentCamera.CFrame = targetCFrame
                    
                end
            end
        end
    end

    if Settings.Aimbot.ShowFOV then
        UpdateESP()
        FOVCircle.Position = UserInputService:GetMouseLocation()
        FOVCircle.Radius = Settings.Aimbot.FOV
        FOVCircle.Visible = true
    else
        FOVCircle.Visible = false
    end
end)

local function DisableAllFeatures()
    -- ESP Settings
    Settings.ESP.Enabled = false
    Settings.ESP.Boxes = false
    Settings.ESP.Names = false
    Settings.ESP.Distance = false
    Settings.ESP.Snaplines = false
    Settings.ESP.TeamCheck = false
    Settings.ESP.Rainbow = false
    
    -- Aimbot Settings
    Settings.Aimbot.Enabled = false
    Settings.Aimbot.TeamCheck = false
    Settings.Aimbot.ShowFOV = false
    FOVCircle.Visible = false
    
    -- Misc Settings
    Settings.Misc.NoRecoil = false
    Settings.Misc.BunnyHop = false
    
    -- Clean up ESP drawings
    for _, esp in pairs(Settings.ESP.Players) do
        esp.Box.Visible = false
        esp.Name.Visible = false
        esp.Distance.Visible = false
        esp.Snapline.Visible = false
    end
    
    -- Remove the GUI
    if ScreenGui then
        ScreenGui:Destroy()
    end
end

-- Add key detection for End and Delete keys
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed then
        if input.KeyCode == Enum.KeyCode.End or input.KeyCode == Enum.KeyCode.Delete then
            DisableAllFeatures()
        end
    end
end)

-- Initialize the UI
InitializeUI()

-- Show first page by default
Pages.ESP.Visible = true
NavButtons.ESP.BackgroundColor3 = Color3.fromRGB(255, 0, 255)

-- Toggle GUI visibility
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.Insert then
        MainFrame.Visible = not MainFrame.Visible
    end
end)
