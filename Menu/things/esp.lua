-- ESP Module
-- Handles ESP functionalities

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local ESPModule = {}
local Config = nil
local Utilities = nil
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local ESPState = {
    Objects = {},
    LastUpdate = 0,
    Enabled = false
}

-- Initialize function
function ESPModule.Initialize(ConfigModule, UtilitiesModule)
    Config = ConfigModule
    Utilities = UtilitiesModule
    ESPState.Enabled = Config.ESP.Enabled
    
    -- Initialize ESP for existing players
    ESPModule.InitializeESP()
    
    -- Connect player added/removed events
    Players.PlayerAdded:Connect(function(player)
        ESPModule.CreateESP(player)
    end)
    
    Players.PlayerRemoving:Connect(function(player)
        ESPModule.RemoveESP(player)
    end)
end

-- Create ESP objects for a player
function ESPModule.CreateESP(player)
    if player == LocalPlayer then return end
    
    -- Check if Drawing module exists
    if not Drawing then
        warn("Drawing module not available. ESP cannot be created.")
        return
    end
    
    -- Create ESP object structure
    local ESP = {
        Player = player,
        Character = player.Character,
        Objects = {
            Box = Drawing.new("Square"),
            BoxOutline = Drawing.new("Square"),
            BoxFill = Drawing.new("Square"),
            Name = Drawing.new("Text"),
            Distance = Drawing.new("Text"),
            Health = Drawing.new("Line"),
            HealthOutline = Drawing.new("Line"),
            Tracer = Drawing.new("Line"),
            TracerOutline = Drawing.new("Line")
        },
        Skeleton = {},
        Chams = nil
    }
    
    -- Configure box
    ESP.Objects.BoxOutline.Color = Config.ESP.BoxOutlineColor
    ESP.Objects.BoxOutline.Thickness = 3
    ESP.Objects.BoxOutline.Transparency = Config.ESP.BoxOutlineTransparency
    ESP.Objects.BoxOutline.Filled = false
    ESP.Objects.BoxOutline.Visible = false
    
    ESP.Objects.Box.Color = Config.ESP.BoxColor
    ESP.Objects.Box.Thickness = 1
    ESP.Objects.Box.Transparency = Config.ESP.BoxTransparency
    ESP.Objects.Box.Filled = false
    ESP.Objects.Box.Visible = false
    
    ESP.Objects.BoxFill.Color = Config.ESP.BoxFillColor
    ESP.Objects.BoxFill.Thickness = 1
    ESP.Objects.BoxFill.Transparency = Config.ESP.BoxFillTransparency
    ESP.Objects.BoxFill.Filled = true
    ESP.Objects.BoxFill.Visible = false
    
    -- Configure name
    ESP.Objects.Name.Color = Config.ESP.NameColor
    ESP.Objects.Name.Size = Config.ESP.NameSize
    ESP.Objects.Name.Center = true
    ESP.Objects.Name.Outline = Config.ESP.NameOutline
    ESP.Objects.Name.OutlineColor = Config.ESP.NameOutlineColor
    ESP.Objects.Name.Font = Config.ESP.NameFont
    ESP.Objects.Name.Visible = false
    
    -- Configure distance
    ESP.Objects.Distance.Color = Config.ESP.DistanceColor
    ESP.Objects.Distance.Size = Config.ESP.DistanceSize
    ESP.Objects.Distance.Center = true
    ESP.Objects.Distance.Outline = Config.ESP.DistanceOutline
    ESP.Objects.Distance.OutlineColor = Config.ESP.DistanceOutlineColor
    ESP.Objects.Distance.Font = Config.ESP.DistanceFont
    ESP.Objects.Distance.Visible = false
    
    -- Configure health bar
    ESP.Objects.HealthOutline.Color = Config.ESP.HealthOutlineColor
    ESP.Objects.HealthOutline.Thickness = 3
    ESP.Objects.HealthOutline.Transparency = Config.ESP.BoxOutlineTransparency
    ESP.Objects.HealthOutline.Visible = false
    
    ESP.Objects.Health.Thickness = 1
    ESP.Objects.Health.Transparency = 1
    ESP.Objects.Health.Visible = false
    
    -- Configure tracer
    ESP.Objects.TracerOutline.Color = Config.ESP.TracerOutlineColor
    ESP.Objects.TracerOutline.Thickness = Config.ESP.TracerThickness + 2
    ESP.Objects.TracerOutline.Transparency = Config.ESP.TracerOutlineTransparency
    ESP.Objects.TracerOutline.Visible = false
    
    ESP.Objects.Tracer.Color = Config.ESP.TracerColor
    ESP.Objects.Tracer.Thickness = Config.ESP.TracerThickness
    ESP.Objects.Tracer.Transparency = Config.ESP.TracerTransparency
    ESP.Objects.Tracer.Visible = false
    
    -- Skeleton (if enabled)
    if Config.ESP.SkeletonEnabled then
        local skeletonParts = {
            "Head-UpperTorso", "UpperTorso-LowerTorso",
            "UpperTorso-LeftUpperArm", "LeftUpperArm-LeftLowerArm", "LeftLowerArm-LeftHand",
            "UpperTorso-RightUpperArm", "RightUpperArm-RightLowerArm", "RightLowerArm-RightHand",
            "LowerTorso-LeftUpperLeg", "LeftUpperLeg-LeftLowerLeg", "LeftLowerLeg-LeftFoot",
            "LowerTorso-RightUpperLeg", "RightUpperLeg-RightLowerLeg", "RightLowerLeg-RightFoot"
        }
        
        for _, part in ipairs(skeletonParts) do
            ESP.Skeleton[part] = Drawing.new("Line")
            ESP.Skeleton[part].Color = Config.ESP.SkeletonColor
            ESP.Skeleton[part].Thickness = 1
            ESP.Skeleton[part].Transparency = Config.ESP.SkeletonTransparency
            ESP.Skeleton[part].Visible = false
        end
    end
    
    -- Connection for character changes
    ESP.CharacterAdded = player.CharacterAdded:Connect(function(character)
        ESP.Character = character
    end)
    
    ESPState.Objects[player] = ESP
    return ESP
end

-- Remove ESP for a player
function ESPModule.RemoveESP(player)
    local ESP = ESPState.Objects[player]
    if not ESP then return end
    
    -- Disconnect character events
    if ESP.CharacterAdded then
        ESP.CharacterAdded:Disconnect()
    end
    
    -- Remove all ESP objects
    for _, object in pairs(ESP.Objects) do
        if object and object.Remove then
            object:Remove()
        end
    end
    
    -- Remove skeleton objects
    for _, object in pairs(ESP.Skeleton) do
        if object and object.Remove then
            object:Remove()
        end
    end
    
    -- Remove chams
    if ESP.Chams then
        -- Remove chams implementation based on the method used
        for _, cham in pairs(ESP.Chams) do
            if cham and cham.Parent then
                cham:Destroy()
            end
        end
    end
    
    -- Remove from objects table
    ESPState.Objects[player] = nil
end

-- Initialize ESP for all existing players
function ESPModule.InitializeESP()
    -- Clear existing ESP
    ESPModule.CleanupESP()
    
    -- Create new ESP for all players
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            ESPModule.CreateESP(player)
        end
    end
end

-- Update ESP visuals
function ESPModule.Update(deltaTime)
    -- Don't update too frequently to save performance
    if os.clock() - ESPState.LastUpdate < (1 / Config.ESP.RefreshRate) then
        return
    end
    
    ESPState.LastUpdate = os.clock()
    
    -- Don't proceed if ESP is disabled
    if not Config.ESP.Enabled then
        for _, ESP in pairs(ESPState.Objects) do
            for _, object in pairs(ESP.Objects) do
                object.Visible = false
            end
            
            for _, object in pairs(ESP.Skeleton) do
                if object then object.Visible = false end
            end
        end
        return
    end
    
    -- Update each player's ESP
    for player, ESP in pairs(ESPState.Objects) do
        -- Check if player is valid for ESP display
        if not Config.ESP.Enabled or 
           not player or 
           not player.Character or 
           not player.Character:FindFirstChild("HumanoidRootPart") or
           not player.Character:FindFirstChild("Humanoid") or
           (Config.ESP.AliveCheck and player.Character.Humanoid.Health <= 0) or
           (Config.ESP.TeamCheck and Utilities.IsTeammate(player)) then
            
            -- Hide all ESP elements
            for _, object in pairs(ESP.Objects) do
                object.Visible = false
            end
            
            for _, object in pairs(ESP.Skeleton) do
                if object then object.Visible = false end
            end
            
            continue
        end
        
        -- Player is valid, get information for rendering
        local character = ESP.Character or player.Character
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        local humanoid = character:FindFirstChild("Humanoid")
        
        -- Calculate distance
        local distance = (humanoidRootPart.Position - Camera.CFrame.Position).Magnitude
        
        -- Don't show ESP if too far
        if distance > Config.ESP.MaxDistance then
            for _, object in pairs(ESP.Objects) do
                object.Visible = false
            end
            
            for _, object in pairs(ESP.Skeleton) do
                if object then object.Visible = false end
            end
            
            continue
        end
        
        -- Get screen position for bounding box
        local rootPos, rootOnScreen = Camera:WorldToViewportPoint(humanoidRootPart.Position)
        if not rootOnScreen then
            -- Not on screen, hide everything
            for _, object in pairs(ESP.Objects) do
                object.Visible = false
            end
            
            for _, object in pairs(ESP.Skeleton) do
                if object then object.Visible = false end
            end
            
            continue
        end
        
        -- Get player colors
        local espColor = Config.ESP.BoxColor
        if Config.ESP.TeamColor then
            espColor = Utilities.GetPlayerTeamColor(player)
        end
        
        -- Get health color
        local healthColor = Utilities.GetColorBasedOnHealth(humanoid.Health, humanoid.MaxHealth)
        
        -- Calculate transparency based on distance
        local transparency = Config.ESP.BoxTransparency
        if Config.ESP.FadeWithDistance then
            transparency = math.min(1, transparency + (distance / Config.ESP.MaxDistance) * 0.3)
        end
        
        -- Calculate bounding box
        local size = Vector3.new(4, 5, 0) * (1 / (distance * 0.05))
        local position = Vector2.new(rootPos.X - size.X / 2, rootPos.Y - size.Y / 2)
        
        -- Update box
        ESP.Objects.BoxOutline.Size = Vector2.new(size.X, size.Y)
        ESP.Objects.BoxOutline.Position = position
        ESP.Objects.BoxOutline.Visible = Config.ESP.BoxOutline and Config.ESP.BoxEnabled
        
        ESP.Objects.Box.Size = Vector2.new(size.X, size.Y)
        ESP.Objects.Box.Position = position
        ESP.Objects.Box.Color = espColor
        ESP.Objects.Box.Transparency = transparency
        ESP.Objects.Box.Visible = Config.ESP.BoxEnabled
        
        -- Box fill
        ESP.Objects.BoxFill.Size = Vector2.new(size.X, size.Y)
        ESP.Objects.BoxFill.Position = position
        ESP.Objects.BoxFill.Color = espColor
        ESP.Objects.BoxFill.Transparency = Config.ESP.BoxFillTransparency
        ESP.Objects.BoxFill.Visible = Config.ESP.BoxFill and Config.ESP.BoxEnabled
        
        -- Update name
        ESP.Objects.Name.Text = player.Name
        ESP.Objects.Name.Position = Vector2.new(rootPos.X, position.Y - 15)
        ESP.Objects.Name.Color = espColor
        ESP.Objects.Name.Visible = Config.ESP.NameEnabled
        
        -- Update health bar
        if Config.ESP.HealthEnabled then
            local healthPercent = humanoid.Health / humanoid.MaxHealth
            
            if Config.ESP.HealthBarSide == "Left" then
                -- Left side health bar
                ESP.Objects.HealthOutline.From = Vector2.new(position.X - 6, position.Y)
                ESP.Objects.HealthOutline.To = Vector2.new(position.X - 6, position.Y + size.Y)
                ESP.Objects.HealthOutline.Visible = Config.ESP.HealthBarEnabled
                
                ESP.Objects.Health.From = Vector2.new(position.X - 6, position.Y + size.Y * (1 - healthPercent))
                ESP.Objects.Health.To = Vector2.new(position.X - 6, position.Y + size.Y)
                ESP.Objects.Health.Color = healthColor
                ESP.Objects.Health.Visible = Config.ESP.HealthBarEnabled
            elseif Config.ESP.HealthBarSide == "Right" then
                -- Right side health bar
                ESP.Objects.HealthOutline.From = Vector2.new(position.X + size.X + 6, position.Y)
                ESP.Objects.HealthOutline.To = Vector2.new(position.X + size.X + 6, position.Y + size.Y)
                ESP.Objects.HealthOutline.Visible = Config.ESP.HealthBarEnabled
                
                ESP.Objects.Health.From = Vector2.new(position.X + size.X + 6, position.Y + size.Y * (1 - healthPercent))
                ESP.Objects.Health.To = Vector2.new(position.X + size.X + 6, position.Y + size.Y)
                ESP.Objects.Health.Color = healthColor
                ESP.Objects.Health.Visible = Config.ESP.HealthBarEnabled
            end
        else
            ESP.Objects.HealthOutline.Visible = false
            ESP.Objects.Health.Visible = false
        end
        
        -- Update distance
        if Config.ESP.DistanceEnabled then
            ESP.Objects.Distance.Text = math.floor(distance) .. "m"
            ESP.Objects.Distance.Position = Vector2.new(rootPos.X, position.Y + size.Y + 5)
            ESP.Objects.Distance.Visible = true
        else
            ESP.Objects.Distance.Visible = false
        end
        
        -- Update tracer
        if Config.ESP.TracerEnabled then
            local origin = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
            
            if Config.ESP.TracerOrigin == "Top" then
                origin = Vector2.new(Camera.ViewportSize.X / 2, 0)
            elseif Config.ESP.TracerOrigin == "Mouse" then
                origin = Vector2.new(Mouse.X, Mouse.Y)
            elseif Config.ESP.TracerOrigin == "Center" then
                origin = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
            end
            
            ESP.Objects.TracerOutline.From = origin
            ESP.Objects.TracerOutline.To = Vector2.new(rootPos.X, rootPos.Y)
            ESP.Objects.TracerOutline.Visible = Config.ESP.TracerOutline
            
            ESP.Objects.Tracer.From = origin
            ESP.Objects.Tracer.To = Vector2.new(rootPos.X, rootPos.Y)
            ESP.Objects.Tracer.Color = espColor
            ESP.Objects.Tracer.Transparency = Config.ESP.TracerTransparency
            ESP.Objects.Tracer.Visible = true
        else
            ESP.Objects.TracerOutline.Visible = false
            ESP.Objects.Tracer.Visible = false
        end
        
        -- Update skeleton if enabled
        if Config.ESP.SkeletonEnabled and ESP.Skeleton and #ESP.Skeleton > 0 then
            ESPModule.UpdateSkeleton(ESP, character, espColor)
        end
    end
end

-- Update skeleton lines
function ESPModule.UpdateSkeleton(ESP, character, color)
    -- Map of bones to character parts
    local bones = {
        ["Head-UpperTorso"] = {"Head", "UpperTorso"},
        ["UpperTorso-LowerTorso"] = {"UpperTorso", "LowerTorso"},
        
        ["UpperTorso-LeftUpperArm"] = {"UpperTorso", "LeftUpperArm"},
        ["LeftUpperArm-LeftLowerArm"] = {"LeftUpperArm", "LeftLowerArm"},
        ["LeftLowerArm-LeftHand"] = {"LeftLowerArm", "LeftHand"},
        
        ["UpperTorso-RightUpperArm"] = {"UpperTorso", "RightUpperArm"},
        ["RightUpperArm-RightLowerArm"] = {"RightUpperArm", "RightLowerArm"},
        ["RightLowerArm-RightHand"] = {"RightLowerArm", "RightHand"},
        
        ["LowerTorso-LeftUpperLeg"] = {"LowerTorso", "LeftUpperLeg"},
        ["LeftUpperLeg-LeftLowerLeg"] = {"LeftUpperLeg", "LeftLowerLeg"},
        ["LeftLowerLeg-LeftFoot"] = {"LeftLowerLeg", "LeftFoot"},
        
        ["LowerTorso-RightUpperLeg"] = {"LowerTorso", "RightUpperLeg"},
        ["RightUpperLeg-RightLowerLeg"] = {"RightUpperLeg", "RightLowerLeg"},
        ["RightLowerLeg-RightFoot"] = {"RightLowerLeg", "RightFoot"}
    }
    
    -- Support for R6 and R15 rigs
    local partMap = {
        -- R15 to R6 mapping
        Head = "Head",
        UpperTorso = "Torso", 
        LowerTorso = "Torso",
        LeftUpperArm = "Left Arm",
        LeftLowerArm = "Left Arm",
        LeftHand = "Left Arm",
        RightUpperArm = "Right Arm",
        RightLowerArm = "Right Arm",
        RightHand = "Right Arm",
        LeftUpperLeg = "Left Leg",
        LeftLowerLeg = "Left Leg",
        LeftFoot = "Left Leg",
        RightUpperLeg = "Right Leg",
        RightLowerLeg = "Right Leg",
        RightFoot = "Right Leg"
    }
    
    -- Draw each bone
    for boneName, bone in pairs(ESP.Skeleton) do
        local partNames = bones[boneName]
        if not partNames then continue end
        
        local part1, part2 = character:FindFirstChild(partNames[1]), character:FindFirstChild(partNames[2])
        
        -- Try R6 mapping if R15 parts aren't found
        if not part1 and partMap[partNames[1]] then 
            part1 = character:FindFirstChild(partMap[partNames[1]])
        end
        if not part2 and partMap[partNames[2]] then 
            part2 = character:FindFirstChild(partMap[partNames[2]])
        end
        
        if part1 and part2 then
            local pos1, onScreen1 = Camera:WorldToViewportPoint(part1.Position)
            local pos2, onScreen2 = Camera:WorldToViewportPoint(part2.Position)
            
            if onScreen1 and onScreen2 then
                bone.From = Vector2.new(pos1.X, pos1.Y)
                bone.To = Vector2.new(pos2.X, pos2.Y)
                bone.Color = color
                bone.Visible = true
            else
                bone.Visible = false
            end
        else
            bone.Visible = false
        end
    end
end

-- Toggle ESP programmatically
function ESPModule.Toggle(state)
    Config.ESP.Enabled = state
    return Config.ESP.Enabled
end

-- Clean up all ESP objects
function ESPModule.CleanupESP()
    for player, ESP in pairs(ESPState.Objects) do
        ESPModule.RemoveESP(player)
    end
    ESPState.Objects = {}
end

-- Main cleanup function
function ESPModule.Cleanup()
    ESPModule.CleanupESP()
end

return ESPModule