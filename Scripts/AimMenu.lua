local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("Syfer-eng Menu v1.0", "Ocean")

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- FOV Circle
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = true
FOVCircle.Thickness = 2
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Filled = false
FOVCircle.Transparency = 1
FOVCircle.NumSides = 100
FOVCircle.Radius = 100

-- Settings
local Settings = {
    AimbotEnabled = false,
    TeamCheck = true,
    AimPart = "Head",
    ESPEnabled = false,
    BoxESP = false,
    NameESP = false,
    HealthESP = false,
    BoneESP = false,
    ShowFOV = true,
    RainbowESP = false,
    ESPColor = Color3.fromRGB(255, 255, 255)
}

-- ESP Objects Cache
local ESPObjects = {}

-- Bone Connections for R15
local BoneConnections = {
    {"Head", "UpperTorso"},
    {"UpperTorso", "LowerTorso"},
    {"UpperTorso", "LeftUpperArm"},
    {"LeftUpperArm", "LeftLowerArm"},
    {"LeftLowerArm", "LeftHand"},
    {"UpperTorso", "RightUpperArm"},
    {"RightUpperArm", "RightLowerArm"},
    {"RightLowerArm", "RightHand"},
    {"LowerTorso", "LeftUpperLeg"},
    {"LeftUpperLeg", "LeftLowerLeg"},
    {"LeftLowerLeg", "LeftFoot"},
    {"LowerTorso", "RightUpperLeg"},
    {"RightUpperLeg", "RightLowerLeg"},
    {"RightLowerLeg", "RightFoot"}
}

-- Create ESP Object Function
local function CreateESPObject()
    return {
        Box = Drawing.new("Square"),
        Name = Drawing.new("Text"),
        Distance = Drawing.new("Text"),
        HealthBar = Drawing.new("Square"),
        HealthBarOutline = Drawing.new("Square"),
        Bones = {},
        Tracer = Drawing.new("Line")
    }
end

-- Initialize ESP Object
local function InitializeESPObject(espObject)
    espObject.Box.Thickness = 1
    espObject.Box.Filled = false
    espObject.Box.Visible = false

    espObject.Name.Size = 13
    espObject.Name.Center = true
    espObject.Name.Outline = true
    espObject.Name.Visible = false

    espObject.Distance.Size = 12
    espObject.Distance.Center = true
    espObject.Distance.Outline = true
    espObject.Distance.Visible = false

    espObject.HealthBar.Thickness = 1
    espObject.HealthBar.Filled = true
    espObject.HealthBar.Visible = false

    espObject.HealthBarOutline.Thickness = 2
    espObject.HealthBarOutline.Filled = false
    espObject.HealthBarOutline.Visible = false

    espObject.Tracer.Thickness = 1
    espObject.Tracer.Visible = false

    for _ = 1, #BoneConnections do
        local bone = Drawing.new("Line")
        bone.Thickness = 1
        bone.Visible = false
        table.insert(espObject.Bones, bone)
    end
end

-- Get Closest Player Function
local function GetClosestPlayer()
    local closest = nil
    local shortestDistance = math.huge
    local mousePos = UserInputService:GetMouseLocation()

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            if Settings.TeamCheck and player.Team == LocalPlayer.Team then continue end
            
            local targetPart = player.Character:FindFirstChild(Settings.AimPart) or 
                             player.Character:FindFirstChild("Head") or 
                             player.Character:FindFirstChild("HumanoidRootPart")

            if targetPart then
                local pos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                if onScreen then
                    local distance = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
                    if distance < FOVCircle.Radius and distance < shortestDistance then
                        closest = player
                        shortestDistance = distance
                    end
                end
            end
        end
    end
    return closest
end

-- Update ESP Function
local function UpdateESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if not ESPObjects[player] then
                ESPObjects[player] = CreateESPObject()
                InitializeESPObject(ESPObjects[player])
            end

            local esp = ESPObjects[player]
            local character = player.Character
            local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
            local humanoid = character and character:FindFirstChild("Humanoid")

            if character and humanoidRootPart and humanoid and Settings.ESPEnabled then
                local vector, onScreen = Camera:WorldToViewportPoint(humanoidRootPart.Position)
                local distance = (Camera.CFrame.Position - humanoidRootPart.Position).Magnitude
                local espColor = Settings.RainbowESP and Color3.fromHSV(tick() % 5 / 5, 1, 1) or Settings.ESPColor

                if onScreen then
                    if Settings.BoxESP then
                        local size = Vector2.new(2000 / vector.Z, 3000 / vector.Z)
                        esp.Box.Size = size
                        esp.Box.Position = Vector2.new(vector.X - size.X / 2, vector.Y - size.Y / 2)
                        esp.Box.Color = espColor
                        esp.Box.Visible = true

                        if Settings.NameESP then
                            esp.Name.Text = string.format("%s\n[%d studs]", player.Name, math.floor(distance))
                            esp.Name.Position = Vector2.new(vector.X, vector.Y - size.Y / 2 - 15)
                            esp.Name.Color = espColor
                            esp.Name.Visible = true
                        end

                        if Settings.HealthESP then
                            local healthBarSize = Vector2.new(3, size.Y)
                            local healthBarPos = Vector2.new(vector.X - size.X / 2 - 5, vector.Y - size.Y / 2)
                            
                            esp.HealthBarOutline.Size = Vector2.new(5, size.Y + 2)
                            esp.HealthBarOutline.Position = Vector2.new(healthBarPos.X - 1, healthBarPos.Y - 1)
                            esp.HealthBarOutline.Color = Color3.new(0, 0, 0)
                            esp.HealthBarOutline.Visible = true

                            esp.HealthBar.Size = Vector2.new(3, size.Y * (humanoid.Health / humanoid.MaxHealth))
                            esp.HealthBar.Position = healthBarPos
                            esp.HealthBar.Color = Color3.fromRGB(255 * (1 - humanoid.Health / humanoid.MaxHealth), 255 * (humanoid.Health / humanoid.MaxHealth), 0)
                            esp.HealthBar.Visible = true
                        end
                    end

                    if Settings.BoneESP then
                        for i, connection in ipairs(BoneConnections) do
                            local part1 = character:FindFirstChild(connection[1])
                            local part2 = character:FindFirstChild(connection[2])

                            if part1 and part2 then
                                local pos1, vis1 = Camera:WorldToViewportPoint(part1.Position)
                                local pos2, vis2 = Camera:WorldToViewportPoint(part2.Position)

                                if vis1 and vis2 then
                                    esp.Bones[i].From = Vector2.new(pos1.X, pos1.Y)
                                    esp.Bones[i].To = Vector2.new(pos2.X, pos2.Y)
                                    esp.Bones[i].Color = espColor
                                    esp.Bones[i].Visible = true
                                else
                                    esp.Bones[i].Visible = false
                                end
                            end
                        end
                    end
                else
                    esp.Box.Visible = false
                    esp.Name.Visible = false
                    esp.HealthBar.Visible = false
                    esp.HealthBarOutline.Visible = false
                    for _, bone in pairs(esp.Bones) do
                        bone.Visible = false
                    end
                end
            else
                esp.Box.Visible = false
                esp.Name.Visible = false
                esp.HealthBar.Visible = false
                esp.HealthBarOutline.Visible = false
                for _, bone in pairs(esp.Bones) do
                    bone.Visible = false
                end
            end
        end
    end
end

-- Aimbot Function
local function UpdateAimbot()
    if Settings.AimbotEnabled and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
        local target = GetClosestPlayer()
        if target and target.Character then
            local targetPart = target.Character:FindFirstChild(Settings.AimPart) or 
                             target.Character:FindFirstChild("Head") or 
                             target.Character:FindFirstChild("HumanoidRootPart")

            if targetPart then
                local targetPos = targetPart.Position
                local mousePos = UserInputService:GetMouseLocation()
                local targetScreen = Camera:WorldToViewportPoint(targetPos)

                Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPos)
                mousemoverel(
                    (targetScreen.X - mousePos.X),
                    (targetScreen.Y - mousePos.Y)
                )
            end
        end
    end
end

-- Create UI Sections
local CombatTab = Window:NewTab("Combat")
local VisualsTab = Window:NewTab("Visuals")
local SettingsTab = Window:NewTab("Settings")

-- Combat Section
local CombatSection = CombatTab:NewSection("Aimbot")
CombatSection:NewToggle("Enable Aimbot", "Toggles aimbot functionality", function(state)
    Settings.AimbotEnabled = state
end)

CombatSection:NewToggle("Team Check", "Checks if player is on your team", function(state)
    Settings.TeamCheck = state
end)

CombatSection:NewDropdown("Aim Part", "Select part to aim at", {"Head", "Torso", "HumanoidRootPart"}, function(part)
    Settings.AimPart = part
end)

-- Visuals Section
local VisualsSection = VisualsTab:NewSection("ESP")
VisualsSection:NewToggle("Enable ESP", "Toggles ESP features", function(state)
    Settings.ESPEnabled = state
end)

VisualsSection:NewToggle("Box ESP", "Shows boxes around players", function(state)
    Settings.BoxESP = state
end)

VisualsSection:NewToggle("Name ESP", "Shows player names", function(state)
    Settings.NameESP = state
end)

VisualsSection:NewToggle("Health ESP", "Shows player health", function(state)
    Settings.HealthESP = state
end)

VisualsSection:NewToggle("Bone ESP", "Shows player skeleton", function(state)
    Settings.BoneESP = state
end)

VisualsSection:NewToggle("Rainbow ESP", "Makes ESP rainbow colored", function(state)
    Settings.RainbowESP = state
end)

-- Main Loop
RunService.RenderStepped:Connect(function()
    local mousePos = UserInputService:GetMouseLocation()
    FOVCircle.Position = mousePos
    
    UpdateAimbot()
    UpdateESP()
end)

-- Cleanup
Players.PlayerRemoving:Connect(function(player)
    if ESPObjects[player] then
        for _, drawing in pairs(ESPObjects[player]) do
            if typeof(drawing) == "table" then
                for _, bone in pairs(drawing) do
                    bone:Remove()
                end
            else
                drawing:Remove()
            end
        end
        ESPObjects[player] = nil
    end
end)
