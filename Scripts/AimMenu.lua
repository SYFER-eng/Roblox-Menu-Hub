local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Multi-Window Setup
local MainWindow = OrionLib:MakeWindow({Name = "Combat Suite", HidePremium = false, SaveConfig = true, ConfigFolder = "CombatConfig"})
local ESPWindow = OrionLib:MakeWindow({Name = "ESP Settings", HidePremium = false, SaveConfig = true, ConfigFolder = "ESPConfig"})
local AimbotWindow = OrionLib:MakeWindow({Name = "Aimbot Settings", HidePremium = false, SaveConfig = true, ConfigFolder = "AimbotConfig"})

-- Settings
local Settings = {
    AimbotEnabled = false,
    ESPEnabled = false,
    TeamCheck = true,
    WallCheck = true,
    AimPart = "Head",
    Smoothness = 0.5,
    FOVSize = 100,
    MaxDistance = 5000,
    PredictionEnabled = true,
    PredictionMultiplier = 1,
    AutoShoot = false,
    BoxESP = false,
    NameESP = false,
    HealthESP = false,
    BoneESP = false,
    TracerESP = false,
    RainbowESP = false,
    ESPColor = Color3.fromRGB(255, 255, 255),
    ShowFOV = true,
    VisibilityCheck = true,
    AimAssist = true,
    SilentAim = false,
    HeadshotChance = 50
}

-- FOV Circle
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = Settings.ShowFOV
FOVCircle.Thickness = 2
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Filled = false
FOVCircle.Transparency = 1
FOVCircle.NumSides = 100
FOVCircle.Radius = Settings.FOVSize

-- ESP Objects Cache
local ESPObjects = {}

-- Bone Connections for all rig types
local BoneConnections = {
    R15 = {
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
    },
    R6 = {
        {"Head", "Torso"},
        {"Torso", "Left Arm"},
        {"Torso", "Right Arm"},
        {"Torso", "Left Leg"},
        {"Torso", "Right Leg"}
    }
}

-- Universal Target Part Detection
local function GetTargetPart(character)
    local targetPart = character:FindFirstChild(Settings.AimPart, true)
    if targetPart and targetPart:IsA("BasePart") then
        return targetPart
    end
    
    -- Fallback hierarchy
    local fallbackParts = {
        "Head",
        "HumanoidRootPart",
        "UpperTorso",
        "Torso",
        "LowerTorso"
    }
    
    for _, partName in ipairs(fallbackParts) do
        local part = character:FindFirstChild(partName, true)
        if part and part:IsA("BasePart") then
            return part
        end
    end
end

-- Advanced Prediction System
local function CalculatePrediction(targetPart, distance)
    if not Settings.PredictionEnabled then return targetPart.Position end
    
    local velocity = targetPart.AssemblyLinearVelocity
    local ping = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue() / 1000
    local gravity = workspace.Gravity
    local timeToHit = distance / 1000 -- Adjust based on projectile speed
    
    local predictedPosition = targetPart.Position + 
                            (velocity * timeToHit * Settings.PredictionMultiplier) +
                            (Vector3.new(0, -gravity * timeToHit^2 / 2, 0))
    
    return predictedPosition
end

-- Enhanced Target Acquisition
local function GetClosestPlayer()
    local closest = nil
    local shortestDistance = math.huge
    local mousePos = UserInputService:GetMouseLocation()
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local humanoid = player.Character:FindFirstChild("Humanoid")
            if not humanoid or humanoid.Health <= 0 then continue end
            if Settings.TeamCheck and player.Team == LocalPlayer.Team then continue end
            
            local targetPart = GetTargetPart(player.Character)
            if targetPart then
                local distance = (Camera.CFrame.Position - targetPart.Position).Magnitude
                if distance > Settings.MaxDistance then continue end
                
                local predictedPos = CalculatePrediction(targetPart, distance)
                local pos, onScreen = Camera:WorldToViewportPoint(predictedPos)
                
                if onScreen then
                    local screenDistance = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
                    if screenDistance < Settings.FOVSize and screenDistance < shortestDistance then
                        if Settings.WallCheck then
                            local ray = Ray.new(Camera.CFrame.Position, (predictedPos - Camera.CFrame.Position).Unit * distance)
                            local hit = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, player.Character})
                            if hit then continue end
                        end
                        
                        closest = {
                            Player = player,
                            Part = targetPart,
                            Position = predictedPos,
                            Distance = distance,
                            ScreenPosition = Vector2.new(pos.X, pos.Y)
                        }
                        shortestDistance = screenDistance
                    end
                end
            end
        end
    end
    return closest
end

-- Advanced Aimbot System
local function UpdateAimbot()
    if Settings.AimbotEnabled and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local target = GetClosestPlayer()
        if target then
            local targetPos = target.Position
            local targetScreen = Camera:WorldToViewportPoint(targetPos)
            local mousePos = UserInputService:GetMouseLocation()
            
            -- Dynamic smoothing based on distance and speed
            local deltaX, deltaY
            if not Settings.Smoothness or Settings.Smoothness <= 0 then
                deltaX = (targetScreen.X - mousePos.X)
                deltaY = (targetScreen.Y - mousePos.Y)
            else
                local speedFactor = target.Part.AssemblyLinearVelocity.Magnitude / 50
                local smoothFactor = math.clamp(
                    Settings.Smoothness * (1 - (target.Distance / Settings.MaxDistance)) * (1 / speedFactor),
                    0.1,
                    1
                )
                
                deltaX = (targetScreen.X - mousePos.X) * smoothFactor
                deltaY = (targetScreen.Y - mousePos.Y) * smoothFactor
            end
            
            -- Enhanced mouse movement
            local magnitude = math.sqrt(deltaX * deltaX + deltaY * deltaY)
            local acceleration = math.min(1, magnitude / 200)
            
            mousemoverel(
                deltaX * acceleration,
                deltaY * acceleration
            )
            
            -- Auto shoot logic
            if Settings.AutoShoot and magnitude < Settings.FOVSize * 0.1 then
                mouse1press()
                wait()
                mouse1release()
            end
        end
    end
end

-- ESP System
local function CreateESPObject()
    local esp = {
        Box = Drawing.new("Square"),
        Name = Drawing.new("Text"),
        Distance = Drawing.new("Text"),
        HealthBar = Drawing.new("Square"),
        HealthBarOutline = Drawing.new("Square"),
        Tracer = Drawing.new("Line"),
        Bones = {}
    }
    
    -- Initialize ESP components
    esp.Box.Thickness = 1
    esp.Box.Filled = false
    esp.Box.Visible = false
    
    esp.Name.Center = true
    esp.Name.Outline = true
    esp.Name.Size = 14
    esp.Name.Visible = false
    
    esp.Distance.Center = true
    esp.Distance.Outline = true
    esp.Distance.Size = 13
    esp.Distance.Visible = false
    
    esp.HealthBar.Thickness = 1
    esp.HealthBar.Filled = true
    esp.HealthBar.Visible = false
    
    esp.HealthBarOutline.Thickness = 1
    esp.HealthBarOutline.Filled = false
    esp.HealthBarOutline.Visible = false
    
    esp.Tracer.Thickness = 1
    esp.Tracer.Visible = false
    
    -- Create bone lines
    for _ = 1, 15 do
        local bone = Drawing.new("Line")
        bone.Thickness = 1
        bone.Visible = false
        table.insert(esp.Bones, bone)
    end
    
    return esp
end

-- ESP Update Function
local function UpdateESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local esp = ESPObjects[player] or CreateESPObject()
            ESPObjects[player] = esp
            
            if Settings.ESPEnabled then
                local humanoid = player.Character:FindFirstChild("Humanoid")
                local rootPart = player.Character:FindFirstChild("HumanoidRootPart") or 
                                player.Character:FindFirstChild("Torso")
                
                if humanoid and rootPart and humanoid.Health > 0 then
                    local vector, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
                    local distance = (Camera.CFrame.Position - rootPart.Position).Magnitude
                    
                    if onScreen and distance < Settings.MaxDistance then
                        -- Calculate ESP color
                        local espColor = Settings.RainbowESP and 
                            Color3.fromHSV(tick() % 5 / 5, 1, 1) or 
                            Settings.ESPColor
                        
                        -- Box ESP
                        if Settings.BoxESP then
                            local size = Vector2.new(2000 / vector.Z, 2500 / vector.Z)
                            esp.Box.Size = size
                            esp.Box.Position = Vector2.new(vector.X - size.X / 2, vector.Y - size.Y / 2)
                            esp.Box.Color = espColor
                            esp.Box.Visible = true
                        end
                        
                        -- Name ESP
                        if Settings.NameESP then
                            esp.Name.Text = string.format("%s\n[%d studs]", player.Name, math.floor(distance))
                            esp.Name.Position = Vector2.new(vector.X, vector.Y - esp.Box.Size.Y / 2 - 15)
                            esp.Name.Color = espColor
                            esp.Name.Visible = true
                        end
                        
                        -- Health ESP
                        if Settings.HealthESP then
                            local healthPercent = humanoid.Health / humanoid.MaxHealth
                            esp.HealthBar.Size = Vector2.new(2, esp.Box.Size.Y * healthPercent)
                            esp.HealthBar.Position = Vector2.new(vector.X - esp.Box.Size.X / 2 - 5, vector.Y - esp.Box.Size.Y / 2)
                            esp.HealthBar.Color = Color3.fromRGB(255 * (1 - healthPercent), 255 * healthPercent, 0)
                            esp.HealthBar.Visible = true
                            
                            esp.HealthBarOutline.Size = Vector2.new(4, esp.Box.Size.Y + 2)
                            esp.HealthBarOutline.Position = Vector2.new(esp.HealthBar.Position.X - 1, esp.HealthBar.Position.Y - 1)
                            esp.HealthBarOutline.Visible = true
                        end
                        
                        -- Bone ESP
                        if Settings.BoneESP then
                            local rigType = player.Character.Humanoid.RigType.Name
                            local connections = BoneConnections[rigType] or BoneConnections.R15
                            
                            for i, connection in ipairs(connections) do
                                local part1 = player.Character:FindFirstChild(connection[1], true)
                                local part2 = player.Character:FindFirstChild(connection[2], true)
                                
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
                        
                        -- Tracer ESP
                        if Settings.TracerESP then
                            esp.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                            esp.Tracer.To = Vector2.new(vector.X, vector.Y)
                            esp.Tracer.Color = espColor
                            esp.Tracer.Visible = true
                        end
                    else
                        -- Hide ESP if out of view
                        esp.Box.Visible = false
                        esp.Name.Visible = false
                        esp.HealthBar.Visible = false
                        esp.HealthBarOutline.Visible = false
                        esp.Tracer.Visible = false
                        for _, bone in pairs(esp.Bones) do
                            bone.Visible = false
                        end
                    end
                end
            end
        end
    end
end

-- UI Tabs
local AimbotTab = AimbotWindow:MakeTab({
    Name = "Aimbot",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local ESPTab = ESPWindow:MakeTab({
    Name = "ESP",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local ConfigTab = MainWindow:MakeTab({
    Name = "Config",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

-- Aimbot Settings
AimbotTab:AddToggle({
    Name = "Enable Aimbot",
    Default = false,
    Save = true,
    Flag = "aimbotEnabled",
    Callback = function(Value)
        Settings.AimbotEnabled = Value
    end
})

AimbotTab:AddToggle({
    Name = "Team Check",
    Default = true,
    Save = true,
    Flag = "teamCheck",
    Callback = function(Value)
        Settings.TeamCheck = Value
    end
})

AimbotTab:AddToggle({
    Name = "Wall Check",
    Default = true,
    Save = true,
    Flag = "wallCheck",
    Callback = function(Value)
        Settings.WallCheck = Value
    end
})

AimbotTab:AddDropdown({
    Name = "Aim Part",
    Default = "Head",
    Options = {"Head", "UpperTorso", "LowerTorso", "HumanoidRootPart"},
    Save = true,
    Flag = "aimPart",
    Callback = function(Value)
        Settings.AimPart = Value
    end
})

AimbotTab:AddSlider({
    Name = "Smoothness",
    Min = 0,
    Max = 100,
    Default = 50,
    Save = true,
    Flag = "smoothness",
    Callback = function(Value)
        Settings.Smoothness = Value / 100
    end
})

AimbotTab:AddSlider({
    Name = "FOV Size",
    Min = 10,
    Max = 500,
    Default = 100,
    Save = true,
    Flag = "fovSize",
    Callback = function(Value)
        Settings.FOVSize = Value
        FOVCircle.Radius = Value
    end
})

-- ESP Settings
ESPTab:AddToggle({
    Name = "Enable ESP",
    Default = false,
    Save = true,
    Flag = "espEnabled",
    Callback = function(Value)
        Settings.ESPEnabled = Value
    end
})

ESPTab:AddToggle({
    Name = "Box ESP",
    Default = false,
    Save = true,
    Flag = "boxESP",
    Callback = function(Value)
        Settings.BoxESP = Value
    end
})

ESPTab:AddToggle({
    Name = "Name ESP",
    Default = false,
    Save = true,
    Flag = "nameESP",
    Callback = function(Value)
        Settings.NameESP = Value
    end
})

ESPTab:AddToggle({
    Name = "Health ESP",
    Default = false,
    Save = true,
    Flag = "healthESP",
    Callback = function(Value)
        Settings.HealthESP = Value
    end
})

ESPTab:AddToggle({
    Name = "Bone ESP",
    Default = false,
    Save = true,
    Flag = "boneESP",
    Callback = function(Value)
        Settings.BoneESP = Value
    end
})

ESPTab:AddToggle({
    Name = "Tracer ESP",
    Default = false,
    Save = true,
    Flag = "tracerESP",
    Callback = function(Value)
        Settings.TracerESP = Value
    end
})

ESPTab:AddToggle({
    Name = "Rainbow ESP",
    Default = false,
    Save = true,
    Flag = "rainbowESP",
    Callback = function(Value)
        Settings.RainbowESP = Value
    end
})

ESPTab:AddColorpicker({
    Name = "ESP Color",
    Default = Color3.fromRGB(255, 255, 255),
    Save = true,
    Flag = "espColor",
    Callback = function(Value)
        Settings.ESPColor = Value
    end
})

-- Config Settings
ConfigTab:AddButton({
    Name = "Save Configuration",
    Callback = function()
        OrionLib:SaveConfiguration()
    end
})

ConfigTab:AddButton({
    Name = "Reset All Settings",
    Callback = function()
        OrionLib:ResetConfiguration()
    end
})

-- Main Loop
RunService.RenderStepped:Connect(function()
    FOVCircle.Position = UserInputService:GetMouseLocation()
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
                pcall(function() drawing:Remove() end)
            end
        end
        ESPObjects[player] = nil
    end
end)

-- Initialize
OrionLib:Init()
