--[[
    Rivals Enhanced v3.5
    Author: Enhanced UI and Configuration System
    Description: Advanced gaming experience with ESP, Aimbot, and Configuration System
    Last Updated: April 2025
]]

-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")

-- Variables
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local TargetPlayer = nil
local IsLeftMouseDown = false 
local IsRightMouseDown = false 
local GuiVisible = true
local NoClipEnabled = false
local AutoClickConnection = nil
local RunningConnections = {}

-- UI Colors and Theme
local Colors = {
    Primary = Color3.fromRGB(35, 35, 45),
    Secondary = Color3.fromRGB(45, 45, 60),
    Tertiary = Color3.fromRGB(55, 55, 70),
    Accent = Color3.fromRGB(131, 0, 255),
    AccentDark = Color3.fromRGB(101, 0, 225),
    Text = Color3.fromRGB(255, 255, 255),
    TextDark = Color3.fromRGB(200, 200, 200),
    Success = Color3.fromRGB(0, 255, 127),
    Error = Color3.fromRGB(255, 50, 50),
    Warning = Color3.fromRGB(255, 184, 0),
    Highlight = Color3.fromRGB(131, 0, 255),
    Background = Color3.fromRGB(25, 25, 35),
    DropShadow = Color3.fromRGB(0, 0, 0),
    ESPHighlight = Color3.fromRGB(255, 0, 0) -- New color for ESP highlighting (red)
}

-- Settings
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
        BoxColor = Color3.fromRGB(255, 0, 0), -- Changed to red from purple
        MaxDistance = 1000,
        Players = {},
        BoxTransparency = 0.8,
        HealthBarSize = Vector2.new(2, 20)
    },
    Aimbot = {
        Enabled = true,
        TeamCheck = false,
        Smoothness = 0.2,
        FOV = 180,
        TargetPart = "Head",
        ShowFOV = true,
        PredictionMultiplier = 1.8,
        AutoPrediction = true,
        TriggerBot = false,
        TriggerDelay = 0.1,
        MaxDistance = 300,
        SilentAim = true,
        HitChance = 100
    },
    Misc = {
        NoClip = false,
        AutoClick = false,
        AutoClickRate = 0.05,
        FullBright = false,
        FreeCam = false
    },
    Config = {
        SaveEnabled = false,
        CurrentConfig = "Default",
        Configs = {
            Default = {
                -- Default config will be populated on init
            }
        }
    }
}

-- Store original lighting settings
local OriginalLighting = {
    Brightness = Lighting.Brightness,
    ClockTime = Lighting.ClockTime,
    FogEnd = Lighting.FogEnd,
    GlobalShadows = Lighting.GlobalShadows,
    Ambient = Lighting.Ambient
}

-- Utility Functions
local Utility = {}

-- Safe call to handle errors gracefully
function Utility.SafeCall(func, ...)
    local success, result = pcall(func, ...)
    if not success then
        warn("Rivals Enhanced Error: " .. tostring(result))
    end
    return success, result
end

-- Deep copy a table
function Utility.DeepCopy(original)
    local copy = {}
    for k, v in pairs(original) do
        if type(v) == "table" then
            copy[k] = Utility.DeepCopy(v)
        else
            copy[k] = v
        end
    end
    return copy
end

-- Get player character safely
function Utility.GetCharacter(player)
    if not player then return nil end
    
    local character = player.Character
    if not character then return nil end
    
    -- Verify character has essential parts
    if not character:FindFirstChild("HumanoidRootPart") or 
       not character:FindFirstChild("Humanoid") or
       not character:FindFirstChildOfClass("Humanoid") then
        return nil
    end
    
    return character
end

-- Check if player is alive
function Utility.IsAlive(player)
    local character = Utility.GetCharacter(player)
    if not character then return false end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    return humanoid and humanoid.Health > 0
end

-- Get player part position with prediction
function Utility.GetPartPosition(player, partName, predict)
    local character = Utility.GetCharacter(player)
    if not character then return nil end
    
    local part = character:FindFirstChild(partName)
    if not part then return nil end
    
    if not predict then
        return part.Position
    end
    
    -- Apply velocity prediction
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return part.Position end
    
    local velocity = rootPart.Velocity
    local predictionFactor = Settings.Aimbot.PredictionMultiplier
    
    -- Auto-adjust prediction based on distance if enabled
    if Settings.Aimbot.AutoPrediction then
        local distance = (rootPart.Position - Camera.CFrame.Position).Magnitude
        predictionFactor = predictionFactor * (1 - math.min(0.6, (distance / 1000)))
    end
    
    -- Apply prediction
    return part.Position + (velocity * predictionFactor)
end

-- Calculate distance between two 3D positions
function Utility.GetDistance(pos1, pos2)
    return (pos1 - pos2).Magnitude
end

-- Convert 3D world position to 2D screen position
function Utility.WorldToScreen(position)
    local screenPosition, onScreen = Camera:WorldToViewportPoint(position)
    return Vector2.new(screenPosition.X, screenPosition.Y), onScreen and screenPosition.Z > 0
end

-- Check if a player is on the same team as local player
function Utility.IsTeammate(player)
    if not Settings.ESP.TeamCheck and not Settings.Aimbot.TeamCheck then 
        return false 
    end
    
    local team1 = LocalPlayer.Team
    local team2 = player.Team
    
    return team1 and team2 and team1 == team2
end

-- Create a tween animation
function Utility.Tween(object, properties, duration, easingStyle, easingDirection)
    local tweenInfo = TweenInfo.new(
        duration or 0.3, 
        easingStyle or Enum.EasingStyle.Quad, 
        easingDirection or Enum.EasingDirection.Out
    )
    
    local tween = TweenService:Create(object, tweenInfo, properties)
    tween:Play()
    return tween
end

-- Calculate health color based on percentage
function Utility.GetHealthColor(health, maxHealth)
    local healthPercent = health / maxHealth
    
    if healthPercent > 0.7 then -- Green to yellow
        return Color3.fromRGB(
            255 * (1 - healthPercent) * 3.3, 
            255, 
            0
        )
    else -- Yellow to red
        return Color3.fromRGB(
            255, 
            255 * (healthPercent / 0.7), 
            0
        )
    end
end

-- Get rainbow color based on time
function Utility.GetRainbowColor()
    local hue = (tick() * 0.1) % 1
    return Color3.fromHSV(hue, 1, 1)
end

-- Get player avatar image
function Utility.GetPlayerAvatar(userId, size)
    return "https://www.roblox.com/headshot-thumbnail/image?userId=" .. userId .. "&width=" .. size .. "&height=" .. size .. "&format=png"
end

-- Create notification system
local Notifications = {
    Queue = {},
    Active = false,
    
    -- Show a notification
    Show = function(self, title, text, duration, notifType)
        table.insert(self.Queue, {
            Title = title,
            Text = text,
            Duration = duration or 3,
            Type = notifType or "Info" -- Info, Success, Error, Warning
        })
        
        if not self.Active then
            self:ProcessQueue()
        end
    end,
    
    -- Process notification queue
    ProcessQueue = function(self)
        if #self.Queue == 0 then
            self.Active = false
            return
        end
        
        self.Active = true
        local notification = table.remove(self.Queue, 1)
        
        -- Try in-game notification
        Utility.SafeCall(function()
            StarterGui:SetCore("SendNotification", {
                Title = notification.Title,
                Text = notification.Text,
                Duration = notification.Duration,
                Icon = "rbxassetid://13647654264"
            })
        end)
        
        task.delay(notification.Duration, function()
            self:ProcessQueue()
        end)
    end
}

-- Create FOV Circle
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2
FOVCircle.NumSides = 90
FOVCircle.Radius = Settings.Aimbot.FOV
FOVCircle.Filled = false
FOVCircle.Visible = Settings.Aimbot.ShowFOV and Settings.Aimbot.Enabled
FOVCircle.ZIndex = 999
FOVCircle.Transparency = 0.7
FOVCircle.Color = Colors.Accent

-- Config System
local Config = {
    -- Initialize default config
    Initialize = function(self)
        -- Create a copy of current settings as default
        Settings.Config.Configs.Default = {
            ESP = Utility.DeepCopy(Settings.ESP),
            Aimbot = Utility.DeepCopy(Settings.Aimbot),
            Misc = Utility.DeepCopy(Settings.Misc)
        }
        
        -- Remove Players table from the config
        Settings.Config.Configs.Default.ESP.Players = nil
    end,
    
    -- Save current config with name
    SaveConfig = function(self, name)
        if not name or name == "" then
            Notifications:Show("Config Error", "Please enter a valid config name", 3, "Error")
            return false
        end
        
        -- Create config
        local configData = {
            ESP = Utility.DeepCopy(Settings.ESP),
            Aimbot = Utility.DeepCopy(Settings.Aimbot),
            Misc = Utility.DeepCopy(Settings.Misc)
        }
        
        -- Remove Players table from the config
        configData.ESP.Players = nil
        
        -- Save config
        Settings.Config.Configs[name] = configData
        Settings.Config.CurrentConfig = name
        
        Notifications:Show("Config Saved", "Saved configuration: " .. name, 3, "Success")
        return true
    end,
    
    -- Load config by name
    LoadConfig = function(self, name)
        if not Settings.Config.Configs[name] then
            Notifications:Show("Config Error", "Config not found: " .. name, 3, "Error")
            return false
        end
        
        local config = Settings.Config.Configs[name]
        
        -- Store players table to restore
        local playersTable = Settings.ESP.Players
        
        -- Load config values
        Settings.ESP = Utility.DeepCopy(config.ESP)
        Settings.Aimbot = Utility.DeepCopy(config.Aimbot)
        Settings.Misc = Utility.DeepCopy(config.Misc)
        
        -- Restore players table
        Settings.ESP.Players = playersTable
        
        -- Update current config
        Settings.Config.CurrentConfig = name
        
        -- Apply settings immediately
        FOVCircle.Radius = Settings.Aimbot.FOV
        FOVCircle.Visible = Settings.Aimbot.ShowFOV and Settings.Aimbot.Enabled
        
        -- Handle NoClip
        NoClipEnabled = Settings.Misc.NoClip
        
        -- Handle FullBright
        ApplyFullBright()
        
        Notifications:Show("Config Loaded", "Loaded configuration: " .. name, 3, "Success")
        return true
    end,
    
    -- Delete config by name
    DeleteConfig = function(self, name)
        if name == "Default" then
            Notifications:Show("Config Error", "Cannot delete default config", 3, "Error")
            return false
        end
        
        if not Settings.Config.Configs[name] then
            Notifications:Show("Config Error", "Config not found: " .. name, 3, "Error")
            return false
        end
        
        -- Delete config
        Settings.Config.Configs[name] = nil
        
        -- If current config was deleted, switch to default
        if Settings.Config.CurrentConfig == name then
            Settings.Config.CurrentConfig = "Default"
            self:LoadConfig("Default")
        end
        
        Notifications:Show("Config Deleted", "Deleted configuration: " .. name, 3, "Success")
        return true
    end,
    
    -- Get list of config names
    GetConfigNames = function(self)
        local names = {}
        for name, _ in pairs(Settings.Config.Configs) do
            table.insert(names, name)
        end
        return names
    end
}

-- ESP Functions
local ESP = {}

-- Initialize ESP for a player
function ESP:CreatePlayerESP(player)
    if Settings.ESP.Players[player] then return end
    
    local espObject = {
        Player = player,
        
        -- Drawing objects
        Box = Drawing.new("Square"),
        BoxOutline = Drawing.new("Square"),
        Name = Drawing.new("Text"),
        Distance = Drawing.new("Text"),
        Snapline = Drawing.new("Line"),
        HealthBar = Drawing.new("Square"),
        HealthBarOutline = Drawing.new("Square"),
        HealthText = Drawing.new("Text"),
    }
    
    -- Box settings
    espObject.BoxOutline.Color = Color3.fromRGB(0, 0, 0)
    espObject.BoxOutline.Thickness = 3
    espObject.BoxOutline.Filled = false
    espObject.BoxOutline.Visible = false
    espObject.BoxOutline.ZIndex = 1
    
    espObject.Box.Color = Colors.ESPHighlight -- Using the red color for ESP
    espObject.Box.Thickness = 1
    espObject.Box.Filled = false
    espObject.Box.Visible = false
    espObject.Box.ZIndex = 2
    espObject.Box.Transparency = Settings.ESP.BoxTransparency
    
    -- Name settings
    espObject.Name.Color = Color3.fromRGB(255, 255, 255)
    espObject.Name.Size = 14
    espObject.Name.Center = true
    espObject.Name.Outline = true
    espObject.Name.OutlineColor = Color3.fromRGB(0, 0, 0)
    espObject.Name.Visible = false
    espObject.Name.ZIndex = 3
    
    -- Distance settings
    espObject.Distance.Color = Color3.fromRGB(200, 200, 200)
    espObject.Distance.Size = 12
    espObject.Distance.Center = true
    espObject.Distance.Outline = true
    espObject.Distance.OutlineColor = Color3.fromRGB(0, 0, 0)
    espObject.Distance.Visible = false
    espObject.Distance.ZIndex = 3
    
    -- Snapline settings
    espObject.Snapline.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
    espObject.Snapline.Color = Color3.fromRGB(255, 0, 0) -- Using red color for snaplines too
    espObject.Snapline.Thickness = 1
    espObject.Snapline.Visible = false
    espObject.Snapline.ZIndex = 2
    espObject.Snapline.Transparency = 0.7
    
    -- Health bar settings
    espObject.HealthBarOutline.Color = Color3.fromRGB(0, 0, 0)
    espObject.HealthBarOutline.Thickness = 1
    espObject.HealthBarOutline.Filled = true
    espObject.HealthBarOutline.Visible = false
    espObject.HealthBarOutline.ZIndex = 1
    
    espObject.HealthBar.Color = Color3.fromRGB(0, 255, 0)
    espObject.HealthBar.Thickness = 1
    espObject.HealthBar.Filled = true
    espObject.HealthBar.Visible = false
    espObject.HealthBar.ZIndex = 2
    
    espObject.HealthText.Color = Color3.fromRGB(255, 255, 255)
    espObject.HealthText.Size = 12
    espObject.HealthText.Center = true
    espObject.HealthText.Outline = true
    espObject.HealthText.OutlineColor = Color3.fromRGB(0, 0, 0)
    espObject.HealthText.Visible = false
    espObject.HealthText.ZIndex = 3
    
    -- Save to ESP registry
    Settings.ESP.Players[player] = espObject
end

-- Remove ESP for a player
function ESP:RemovePlayerESP(player)
    local espObject = Settings.ESP.Players[player]
    if not espObject then return end
    
    for _, drawing in pairs(espObject) do
        if typeof(drawing) == "table" and drawing.Remove then
            Utility.SafeCall(function()
                drawing:Remove()
            end)
        end
    end
    
    Settings.ESP.Players[player] = nil
end

-- Update ESP for all players
function ESP:UpdatePlayerESP()
    if not Settings.ESP.Enabled then
        for _, object in pairs(Settings.ESP.Players) do
            object.Box.Visible = false
            object.BoxOutline.Visible = false
            object.Name.Visible = false
            object.Distance.Visible = false
            object.Snapline.Visible = false
            object.HealthBar.Visible = false
            object.HealthBarOutline.Visible = false
            object.HealthText.Visible = false
        end
        return
    end
    
    for player, object in pairs(Settings.ESP.Players) do
        Utility.SafeCall(function()
            if not Utility.IsAlive(player) or player == LocalPlayer then
                object.Box.Visible = false
                object.BoxOutline.Visible = false
                object.Name.Visible = false
                object.Distance.Visible = false
                object.Snapline.Visible = false
                object.HealthBar.Visible = false
                object.HealthBarOutline.Visible = false
                object.HealthText.Visible = false
                return
            end
            
            -- Check if teammate
            if Settings.ESP.TeamCheck and Utility.IsTeammate(player) then
                object.Box.Visible = false
                object.BoxOutline.Visible = false
                object.Name.Visible = false
                object.Distance.Visible = false
                object.Snapline.Visible = false
                object.HealthBar.Visible = false
                object.HealthBarOutline.Visible = false
                object.HealthText.Visible = false
                return
            end
            
            local character = Utility.GetCharacter(player)
            if not character then return end
            
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            if not humanoid or not rootPart then return end
            
            -- Get player positions
            local rootPos = rootPart.Position
            local distance = Utility.GetDistance(Camera.CFrame.Position, rootPos)
            
            -- Check max distance
            if distance > Settings.ESP.MaxDistance then
                object.Box.Visible = false
                object.BoxOutline.Visible = false
                object.Name.Visible = false
                object.Distance.Visible = false
                object.Snapline.Visible = false
                object.HealthBar.Visible = false
                object.HealthBarOutline.Visible = false
                object.HealthText.Visible = false
                return
            end
            
            -- Get 3D corners of character
            local topPos = rootPos + Vector3.new(0, 3, 0)
            local bottomPos = rootPos - Vector3.new(0, 3, 0)
            
            -- Convert to screen positions
            local topScreenPos, topOnScreen = Utility.WorldToScreen(topPos)
            local bottomScreenPos, bottomOnScreen = Utility.WorldToScreen(bottomPos)
            
            if not topOnScreen and not bottomOnScreen then
                object.Box.Visible = false
                object.BoxOutline.Visible = false
                object.Name.Visible = false
                object.Distance.Visible = false
                object.Snapline.Visible = false
                object.HealthBar.Visible = false
                object.HealthBarOutline.Visible = false
                object.HealthText.Visible = false
                return
            end
            
            -- Calculate box dimensions
            local boxHeight = math.abs(topScreenPos.Y - bottomScreenPos.Y)
            local boxWidth = boxHeight * 0.6
            
            -- Update positions
            local boxPosition = Vector2.new(
                bottomScreenPos.X - boxWidth / 2,
                topScreenPos.Y
            )
            
            local boxSize = Vector2.new(boxWidth, boxHeight)
            
            -- Update box
            object.Box.Size = boxSize
            object.Box.Position = boxPosition
            object.BoxOutline.Size = boxSize
            object.BoxOutline.Position = boxPosition
            
            -- Update box colors
            if Settings.ESP.Rainbow then
                object.Box.Color = Utility.GetRainbowColor()
            else
                object.Box.Color = Colors.ESPHighlight -- Using red color for ESP
            end
            
            -- Show box if enabled
            object.Box.Visible = Settings.ESP.Boxes
            object.BoxOutline.Visible = Settings.ESP.Boxes
            
            -- Update name ESP
            if Settings.ESP.Names then
                object.Name.Position = Vector2.new(
                    boxPosition.X + (boxWidth / 2),
                    boxPosition.Y - 16
                )
                object.Name.Text = player.Name
                object.Name.Visible = true
            else
                object.Name.Visible = false
            end
            
            -- Update distance ESP
            if Settings.ESP.Distance then
                object.Distance.Position = Vector2.new(
                    boxPosition.X + (boxWidth / 2),
                    boxPosition.Y + boxHeight + 2
                )
                object.Distance.Text = math.floor(distance) .. "m"
                object.Distance.Visible = true
            else
                object.Distance.Visible = false
            end
            
            -- Update snaplines
            if Settings.ESP.Snaplines then
                object.Snapline.To = Vector2.new(
                    boxPosition.X + (boxWidth / 2),
                    boxPosition.Y + (boxHeight / 2)
                )
                
                if Settings.ESP.Rainbow then
                    object.Snapline.Color = Utility.GetRainbowColor()
                else
                    object.Snapline.Color = Colors.ESPHighlight -- Red snaplines as well
                end
                
                object.Snapline.Visible = true
            else
                object.Snapline.Visible = false
            end
            
            -- Update health bar
            if Settings.ESP.Health and humanoid then
                local healthPercent = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
                local barHeight = boxHeight * healthPercent
                
                -- Health bar background
                object.HealthBarOutline.Size = Vector2.new(
                    Settings.ESP.HealthBarSize.X + 2, 
                    boxHeight + 2
                )
                object.HealthBarOutline.Position = Vector2.new(
                    boxPosition.X - Settings.ESP.HealthBarSize.X - 4,
                    boxPosition.Y - 1
                )
                object.HealthBarOutline.Visible = true
                
                -- Health bar foreground
                object.HealthBar.Size = Vector2.new(
                    Settings.ESP.HealthBarSize.X, 
                    barHeight
                )
                object.HealthBar.Position = Vector2.new(
                    boxPosition.X - Settings.ESP.HealthBarSize.X - 3,
                    boxPosition.Y + (boxHeight - barHeight)
                )
                object.HealthBar.Color = Utility.GetHealthColor(humanoid.Health, humanoid.MaxHealth)
                object.HealthBar.Visible = true
                
                -- Health text
                object.HealthText.Text = math.floor(humanoid.Health) .. "HP"
                object.HealthText.Position = Vector2.new(
                    boxPosition.X - Settings.ESP.HealthBarSize.X - 3,
                    boxPosition.Y + boxHeight + 2
                )
                object.HealthText.Visible = true
            else
                object.HealthBar.Visible = false
                object.HealthBarOutline.Visible = false
                object.HealthText.Visible = false
            end
        end)
    end
end

-- Aimbot Functions
local Aimbot = {}

-- Get closest player to mouse for aimbot
function Aimbot:GetTarget()
    local closestPlayer = nil
    local closestDistance = math.huge
    local mousePos = UserInputService:GetMouseLocation()
    
    for _, player in pairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        
        -- Check if player is alive
        if not Utility.IsAlive(player) then continue end
        
        -- Check team
        if Settings.Aimbot.TeamCheck and Utility.IsTeammate(player) then continue end
        
        local character = Utility.GetCharacter(player)
        if not character then continue end
        
        -- Get part to aim at
        local partPos = Utility.GetPartPosition(player, Settings.Aimbot.TargetPart, true)
        if not partPos then continue end
        
        -- Check distance
        local distance = Utility.GetDistance(Camera.CFrame.Position, partPos)
        if distance > Settings.Aimbot.MaxDistance then continue end
        
        -- Convert to screen position
        local screenPos, onScreen = Utility.WorldToScreen(partPos)
        if not onScreen then continue end
        
        -- Check if within FOV
        local mouseDist = (mousePos - screenPos).Magnitude
        if mouseDist > Settings.Aimbot.FOV then continue end
        
        -- Check if closest
        if mouseDist < closestDistance then
            closestPlayer = player
            closestDistance = mouseDist
        end
    end
    
    return closestPlayer
end

-- Apply aimbot movement
function Aimbot:AimAt(player)
    if not player then return end
    
    -- Get target position
    local targetPos = Utility.GetPartPosition(player, Settings.Aimbot.TargetPart, true)
    if not targetPos then return end
    
    -- Calculate aim direction
    local aimDirection = (targetPos - Camera.CFrame.Position).Unit
    local currentDirection = Camera.CFrame.LookVector
    
    -- Apply smoothing
    local newDirection = currentDirection:Lerp(aimDirection, Settings.Aimbot.Smoothness)
    
    -- Create new camera CFrame
    local newCFrame = CFrame.lookAt(Camera.CFrame.Position, Camera.CFrame.Position + newDirection)
    
    -- Apply to camera
    Camera.CFrame = newCFrame
end

-- Create Silent Aim hook
function Aimbot:CreateSilentAimHook()
    if not Settings.Aimbot.SilentAim then return end
    
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        
        -- If Aimbot is not enabled or we're not firing
        if not Settings.Aimbot.Enabled or not (method == "FindPartOnRayWithIgnoreList" or method == "FindPartOnRay" or method == "Raycast") then
            return oldNamecall(self, ...)
        end
        
        -- Get target for silent aim
        local target = Aimbot:GetTarget()
        if not target then
            return oldNamecall(self, ...)
        end
        
        -- Check hit chance
        if math.random(1, 100) > Settings.Aimbot.HitChance then
            return oldNamecall(self, ...)
        end
        
        -- Get target position
        local targetPos = Utility.GetPartPosition(target, Settings.Aimbot.TargetPart, true)
        if not targetPos then
            return oldNamecall(self, ...)
        end
        
        -- Create new ray from camera to target
        local ray = Ray.new(Camera.CFrame.Position, (targetPos - Camera.CFrame.Position).Unit * 1000)
        
        -- Replace the ray in arguments
        if method == "FindPartOnRayWithIgnoreList" then
            args[1] = ray
        elseif method == "FindPartOnRay" then
            args[1] = ray
        elseif method == "Raycast" then
            args[1] = Camera.CFrame.Position
            args[2] = (targetPos - Camera.CFrame.Position).Unit * 1000
        end
        
        return oldNamecall(self, unpack(args))
    end)
end

-- Apply FullBright effect
function ApplyFullBright()
    if Settings.Misc.FullBright then
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = false
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
    else
        Lighting.Brightness = OriginalLighting.Brightness
        Lighting.ClockTime = OriginalLighting.ClockTime
        Lighting.FogEnd = OriginalLighting.FogEnd
        Lighting.GlobalShadows = OriginalLighting.GlobalShadows
        Lighting.Ambient = OriginalLighting.Ambient
    end
end

-- Auto Clicker Function
function ToggleAutoClick()
    if Settings.Misc.AutoClick then
        if AutoClickConnection then return end
        
        local clickDelay = Settings.Misc.AutoClickRate
        
        AutoClickConnection = RunService.Heartbeat:Connect(function()
            if IsLeftMouseDown then
                mouse1click()
                task.wait(clickDelay)
            end
        end)
    else
        if AutoClickConnection then
            AutoClickConnection:Disconnect()
            AutoClickConnection = nil
        end
    end
end

-- NoClip Function
function ApplyNoClip()
    if not NoClipEnabled then return end
    
    local character = Utility.GetCharacter(LocalPlayer)
    if not character then return end
    
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end
end

-- Create UI
local UI = {}

-- UI Variables
local ScreenGui = nil
local MainFrame = nil
local Tabs = {}
local ActiveTab = "ESP"
local DraggingUI = false
local DragStart = nil
local StartPosition = nil
local UIWidth = 550 -- Increased width from the typical 400 to make the UI wider
local UIHeight = 350
local ToggleButtons = {}
local SliderBars = {}
local Dropdowns = {}
local TabButtons = {}

-- Create new UI elements
function UI:CreateElement(class, properties)
    local element = Instance.new(class)
    
    for property, value in pairs(properties) do
        element[property] = value
    end
    
    return element
end

-- Create the main interface
function UI:CreateInterface()
    -- Check if UI already exists
    if ScreenGui then
        ScreenGui:Destroy()
    end
    
    -- Create ScreenGui
    ScreenGui = UI:CreateElement("ScreenGui", {
        Name = "RivalsEnhanced",
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false,
        Parent = CoreGui
    })
    
    -- Create main frame
    MainFrame = UI:CreateElement("Frame", {
        Name = "MainFrame",
        Size = UDim2.new(0, UIWidth, 0, UIHeight),
        Position = UDim2.new(0.5, -UIWidth/2, 0.5, -UIHeight/2),
        BackgroundColor3 = Colors.Primary,
        BorderSizePixel = 0,
        Parent = ScreenGui
    })
    
    -- Add corner radius
    local cornerRadius = UI:CreateElement("UICorner", {
        CornerRadius = UDim.new(0, 10),
        Parent = MainFrame
    })
    
    -- Add drop shadow
    local dropShadow = UI:CreateElement("Frame", {
        Name = "DropShadow",
        Size = UDim2.new(1, 10, 1, 10),
        Position = UDim2.new(0, -5, 0, -5),
        BackgroundTransparency = 0.5,
        BackgroundColor3 = Colors.DropShadow,
        BorderSizePixel = 0,
        ZIndex = -1,
        Parent = MainFrame
    })
    
    -- Add corner radius to shadow
    local shadowCorner = UI:CreateElement("UICorner", {
        CornerRadius = UDim.new(0, 14),
        Parent = dropShadow
    })
    
    -- Create title bar
    local titleBar = UI:CreateElement("Frame", {
        Name = "TitleBar",
        Size = UDim2.new(1, 0, 0, 40),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = Colors.Accent,
        BorderSizePixel = 0,
        Parent = MainFrame
    })
    
    -- Add corner radius to top corners only
    local titleCorner = UI:CreateElement("UICorner", {
        CornerRadius = UDim.new(0, 10),
        Parent = titleBar
    })
    
    -- Fix corner radius
    local cornerFix = UI:CreateElement("Frame", {
        Name = "CornerFix",
        Size = UDim2.new(1, 0, 0.5, 0),
        Position = UDim2.new(0, 0, 0.5, 0),
        BackgroundColor3 = Colors.Accent,
        BorderSizePixel = 0,
        Parent = titleBar
    })
    
    -- Create title text
    local titleText = UI:CreateElement("TextLabel", {
        Name = "TitleText",
        Size = UDim2.new(1, -40, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = "Rivals Enhanced v3.5",
        TextColor3 = Colors.Text,
        TextSize = 18,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = titleBar
    })
    
    -- Create close button
    local closeButton = UI:CreateElement("TextButton", {
        Name = "CloseButton",
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(1, -35, 0, 5),
        BackgroundColor3 = Colors.Error,
        Text = "X",
        TextColor3 = Colors.Text,
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        Parent = titleBar
    })
    
    -- Add corner radius to close button
    local closeCorner = UI:CreateElement("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = closeButton
    })
    
    -- Create tab buttons container
    local tabButtons = UI:CreateElement("Frame", {
        Name = "TabButtons",
        Size = UDim2.new(0, UIWidth, 0, 40),
        Position = UDim2.new(0, 0, 0, 40),
        BackgroundColor3 = Colors.Secondary,
        BorderSizePixel = 0,
        Parent = MainFrame
    })
    
    -- Create tab content container
    local tabContent = UI:CreateElement("Frame", {
        Name = "TabContent",
        Size = UDim2.new(1, 0, 1, -80),
        Position = UDim2.new(0, 0, 0, 80),
        BackgroundColor3 = Colors.Background,
        BorderSizePixel = 0,
        Parent = MainFrame
    })
    
    -- Add corner radius to bottom corners only
    local contentCorner = UI:CreateElement("UICorner", {
        CornerRadius = UDim.new(0, 10),
        Parent = tabContent
    })
    
    -- Fix corner radius
    local contentFix = UI:CreateElement("Frame", {
        Name = "CornerFix",
        Size = UDim2.new(1, 0, 0.5, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = Colors.Background,
        BorderSizePixel = 0,
        Parent = tabContent
    })
    
    -- Make UI draggable
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            DraggingUI = true
            DragStart = input.Position
            StartPosition = MainFrame.Position
        end
    end)
    
    titleBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            DraggingUI = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if DraggingUI and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - DragStart
            MainFrame.Position = UDim2.new(
                StartPosition.X.Scale,
                StartPosition.X.Offset + delta.X,
                StartPosition.Y.Scale,
                StartPosition.Y.Offset + delta.Y
            )
        end
    end)
    
    -- Close button functionality
    closeButton.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
        ScreenGui = nil
        
        -- Clean up
        for player, espObject in pairs(Settings.ESP.Players) do
            ESP:RemovePlayerESP(player)
        end
        
        -- Disconnect all running connections
        for _, connection in pairs(RunningConnections) do
            connection:Disconnect()
        end
        RunningConnections = {}
        
        if AutoClickConnection then
            AutoClickConnection:Disconnect()
            AutoClickConnection = nil
        end
        
        -- Remove FOV circle
        FOVCircle:Remove()
        GuiVisible = false
    end)
    
    -- Create tabs
    self:CreateTabs(tabButtons, tabContent)
end

-- Create tabs
function UI:CreateTabs(tabContainer, contentContainer)
    -- Define tabs
    local tabData = {
        ESP = {
            Name = "ESP",
            Icon = "rbxassetid://10738463056", -- Eye icon
            Color = Colors.Accent -- Purple for now, will highlight when active
        },
        Aimbot = {
            Name = "Aimbot",
            Icon = "rbxassetid://10723414494", -- Target icon
            Color = Colors.Tertiary
        },
        Misc = {
            Name = "Misc",
            Icon = "rbxassetid://10734923424", -- Gear icon
            Color = Colors.Tertiary
        },
        Config = {
            Name = "Config",
            Icon = "rbxassetid://10734930952", -- Settings icon
            Color = Colors.Tertiary
        }
    }
    
    -- Calculate button width
    local buttonWidth = UIWidth / #tabData
    local position = 0
    
    -- Create tab buttons
    for tabName, tab in pairs(tabData) do
        local tabButton = UI:CreateElement("TextButton", {
            Name = tabName .. "Button",
            Size = UDim2.new(0, buttonWidth, 1, 0),
            Position = UDim2.new(0, position, 0, 0),
            BackgroundColor3 = tabName == ActiveTab and Colors.Accent or Colors.Tertiary,
            BorderSizePixel = 0,
            Text = "",
            Parent = tabContainer
        })
        
        local tabIcon = UI:CreateElement("ImageLabel", {
            Name = "Icon",
            Size = UDim2.new(0, 20, 0, 20),
            Position = UDim2.new(0, 10, 0.5, -10),
            BackgroundTransparency = 1,
            Image = tab.Icon,
            ImageColor3 = Colors.Text,
            Parent = tabButton
        })
        
        local tabLabel = UI:CreateElement("TextLabel", {
            Name = "Label",
            Size = UDim2.new(1, -40, 1, 0),
            Position = UDim2.new(0, 35, 0, 0),
            BackgroundTransparency = 1,
            Text = tab.Name,
            TextColor3 = Colors.Text,
            TextSize = 14,
            Font = Enum.Font.GothamSemibold,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = tabButton
        })
        
        -- Create tab content
        local tabFrame = UI:CreateElement("ScrollingFrame", {
            Name = tabName .. "Tab",
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 4,
            ScrollBarImageColor3 = Colors.Accent,
            CanvasSize = UDim2.new(0, 0, 0, 500), -- Will adjust based on content
            Visible = tabName == ActiveTab,
            Parent = contentContainer
        })
        
        -- Store tab data
        Tabs[tabName] = tabFrame
        TabButtons[tabName] = tabButton
        
        -- Tab switching logic
        tabButton.MouseButton1Click:Connect(function()
            -- Update active tab
            ActiveTab = tabName
            
            -- Update tab visuals
            for name, button in pairs(TabButtons) do
                button.BackgroundColor3 = name == ActiveTab and Colors.Accent or Colors.Tertiary
            end
            
            -- Update tab content visibility
            for name, frame in pairs(Tabs) do
                frame.Visible = name == ActiveTab
            end
        end)
        
        -- Increase position for next button
        position = position + buttonWidth
    end
    
    -- Fill tabs with content
    self:CreateESPTab(Tabs.ESP)
    self:CreateAimbotTab(Tabs.Aimbot)
    self:CreateMiscTab(Tabs.Misc)
    self:CreateConfigTab(Tabs.Config)
    
    -- Highlight ESP tab by default (it's already active by default but this ensures styling)
    TabButtons.ESP.BackgroundColor3 = Colors.Accent
end

-- Create a section in a tab
function UI:CreateSection(parent, title, positionY)
    local section = UI:CreateElement("Frame", {
        Name = title .. "Section",
        Size = UDim2.new(1, -20, 0, 30),
        Position = UDim2.new(0, 10, 0, positionY),
        BackgroundTransparency = 1,
        Parent = parent
    })
    
    local sectionTitle = UI:CreateElement("TextLabel", {
        Name = "Title",
        Size = UDim2.new(1, 0, 0, 30),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = Colors.Accent,
        TextSize = 16,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = section
    })
    
    local separator = UI:CreateElement("Frame", {
        Name = "Separator",
        Size = UDim2.new(1, 0, 0, 2),
        Position = UDim2.new(0, 0, 0, 25),
        BackgroundColor3 = Colors.Accent,
        BorderSizePixel = 0,
        Parent = section
    })
    
    return section, positionY + 40
end

-- Create a toggle button
function UI:CreateToggle(parent, title, description, value, positionY, callback)
    local container = UI:CreateElement("Frame", {
        Name = title .. "Container",
        Size = UDim2.new(1, -20, 0, 50),
        Position = UDim2.new(0, 10, 0, positionY),
        BackgroundTransparency = 1,
        Parent = parent
    })
    
    local titleLabel = UI:CreateElement("TextLabel", {
        Name = "Title",
        Size = UDim2.new(1, -60, 0, 20),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = Colors.Text,
        TextSize = 14,
        Font = Enum.Font.GothamSemibold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = container
    })
    
    local descriptionLabel = UI:CreateElement("TextLabel", {
        Name = "Description",
        Size = UDim2.new(1, -60, 0, 20),
        Position = UDim2.new(0, 0, 0, 20),
        BackgroundTransparency = 1,
        Text = description,
        TextColor3 = Colors.TextDark,
        TextSize = 12,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        Parent = container
    })
    
    local toggleBG = UI:CreateElement("Frame", {
        Name = "ToggleBG",
        Size = UDim2.new(0, 40, 0, 20),
        Position = UDim2.new(1, -50, 0, 10),
        BackgroundColor3 = value and Colors.Accent or Colors.Tertiary,
        BorderSizePixel = 0,
        Parent = container
    })
    
    local toggleRadius = UI:CreateElement("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = toggleBG
    })
    
    local toggleCircle = UI:CreateElement("Frame", {
        Name = "ToggleCircle",
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(value and 1 or 0, value and -18 or 2, 0.5, -8),
        BackgroundColor3 = Colors.Text,
        BorderSizePixel = 0,
        Parent = toggleBG
    })
    
    local circleRadius = UI:CreateElement("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = toggleCircle
    })
    
    local toggleButton = UI:CreateElement("TextButton", {
        Name = "ToggleButton",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        Parent = toggleBG
    })
    
    -- Store toggle state
    ToggleButtons[title] = value
    
    -- Connect toggle function
    toggleButton.MouseButton1Click:Connect(function()
        ToggleButtons[title] = not ToggleButtons[title]
        
        -- Animate toggle
        Utility.Tween(toggleBG, {BackgroundColor3 = ToggleButtons[title] and Colors.Accent or Colors.Tertiary}, 0.2)
        Utility.Tween(toggleCircle, {Position = ToggleButtons[title] and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)}, 0.2)
        
        -- Call callback function
        if callback then
            callback(ToggleButtons[title])
        end
    end)
    
    return container, positionY + 60
end

-- Create a slider
function UI:CreateSlider(parent, title, description, min, max, value, displayFormat, positionY, callback)
    local container = UI:CreateElement("Frame", {
        Name = title .. "Container",
        Size = UDim2.new(1, -20, 0, 65),
        Position = UDim2.new(0, 10, 0, positionY),
        BackgroundTransparency = 1,
        Parent = parent
    })
    
    local titleLabel = UI:CreateElement("TextLabel", {
        Name = "Title",
        Size = UDim2.new(1, 0, 0, 20),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = Colors.Text,
        TextSize = 14,
        Font = Enum.Font.GothamSemibold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = container
    })
    
    local descriptionLabel = UI:CreateElement("TextLabel", {
        Name = "Description",
        Size = UDim2.new(1, 0, 0, 20),
        Position = UDim2.new(0, 0, 0, 20),
        BackgroundTransparency = 1,
        Text = description,
        TextColor3 = Colors.TextDark,
        TextSize = 12,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        Parent = container
    })
    
    local valueDisplay = UI:CreateElement("TextLabel", {
        Name = "Value",
        Size = UDim2.new(0, 50, 0, 20),
        Position = UDim2.new(1, -50, 0, 0),
        BackgroundTransparency = 1,
        Text = displayFormat:format(value),
        TextColor3 = Colors.Text,
        TextSize = 14,
        Font = Enum.Font.GothamSemibold,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = container
    })
    
    local sliderBG = UI:CreateElement("Frame", {
        Name = "SliderBG",
        Size = UDim2.new(1, 0, 0, 8),
        Position = UDim2.new(0, 0, 0, 45),
        BackgroundColor3 = Colors.Tertiary,
        BorderSizePixel = 0,
        Parent = container
    })
    
    local sliderRadius = UI:CreateElement("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = sliderBG
    })
    
    local sliderFill = UI:CreateElement("Frame", {
        Name = "SliderFill",
        Size = UDim2.new((value - min) / (max - min), 0, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = Colors.Accent,
        BorderSizePixel = 0,
        Parent = sliderBG
    })
    
    local fillRadius = UI:CreateElement("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = sliderFill
    })
    
    local sliderButton = UI:CreateElement("TextButton", {
        Name = "SliderButton",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        Parent = sliderBG
    })
    
    local handle = UI:CreateElement("Frame", {
        Name = "Handle",
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new((value - min) / (max - min), -8, 0.5, -8),
        BackgroundColor3 = Colors.Accent,
        BorderSizePixel = 0,
        Parent = sliderBG
    })
    
    local handleRadius = UI:CreateElement("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = handle
    })
    
    -- Store slider state
    SliderBars[title] = value
    
    -- Drag functionality
    local isDragging = false
    
    sliderButton.MouseButton1Down:Connect(function()
        isDragging = true
    end)
    
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = true
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = false
        end
    end)
    
    RunService.RenderStepped:Connect(function()
        if isDragging then
            local mousePos = UserInputService:GetMouseLocation()
            local sliderPos = sliderBG.AbsolutePosition
            local sliderSize = sliderBG.AbsoluteSize
            
            local relPos = math.clamp((mousePos.X - sliderPos.X) / sliderSize.X, 0, 1)
            local newValue = min + (max - min) * relPos
            
            -- Update slider visuals
            sliderFill.Size = UDim2.new(relPos, 0, 1, 0)
            handle.Position = UDim2.new(relPos, -8, 0.5, -8)
            valueDisplay.Text = displayFormat:format(newValue)
            
            -- Store new value
            SliderBars[title] = newValue
            
            -- Call callback function
            if callback then
                callback(newValue)
            end
        end
    end)
    
    return container, positionY + 75
end

-- Create a dropdown
function UI:CreateDropdown(parent, title, description, options, selected, positionY, callback)
    local container = UI:CreateElement("Frame", {
        Name = title .. "Container",
        Size = UDim2.new(1, -20, 0, 65),
        Position = UDim2.new(0, 10, 0, positionY),
        BackgroundTransparency = 1,
        Parent = parent
    })
    
    local titleLabel = UI:CreateElement("TextLabel", {
        Name = "Title",
        Size = UDim2.new(1, 0, 0, 20),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = Colors.Text,
        TextSize = 14,
        Font = Enum.Font.GothamSemibold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = container
    })
    
    local descriptionLabel = UI:CreateElement("TextLabel", {
        Name = "Description",
        Size = UDim2.new(1, 0, 0, 20),
        Position = UDim2.new(0, 0, 0, 20),
        BackgroundTransparency = 1,
        Text = description,
        TextColor3 = Colors.TextDark,
        TextSize = 12,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        Parent = container
    })
    
    local dropdownBox = UI:CreateElement("Frame", {
        Name = "DropdownBox",
        Size = UDim2.new(1, 0, 0, 30),
        Position = UDim2.new(0, 0, 0, 45),
        BackgroundColor3 = Colors.Tertiary,
        BorderSizePixel = 0,
        Parent = container
    })
    
    local boxRadius = UI:CreateElement("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = dropdownBox
    })
    
    local selectedLabel = UI:CreateElement("TextLabel", {
        Name = "SelectedLabel",
        Size = UDim2.new(1, -30, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = selected,
        TextColor3 = Colors.Text,
        TextSize = 14,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = dropdownBox
    })
    
    local dropdownArrow = UI:CreateElement("TextLabel", {
        Name = "DropdownArrow",
        Size = UDim2.new(0, 20, 0, 20),
        Position = UDim2.new(1, -25, 0.5, -10),
        BackgroundTransparency = 1,
        Text = "▼",
        TextColor3 = Colors.Text,
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        Parent = dropdownBox
    })
    
    local dropdownButton = UI:CreateElement("TextButton", {
        Name = "DropdownButton",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        Parent = dropdownBox
    })
    
    local dropdownContent = UI:CreateElement("Frame", {
        Name = "DropdownContent",
        Size = UDim2.new(1, 0, 0, 0), -- Will expand based on options
        Position = UDim2.new(0, 0, 1, 5),
        BackgroundColor3 = Colors.Tertiary,
        BorderSizePixel = 0,
        Visible = false,
        ZIndex = 10,
        Parent = dropdownBox
    })
    
    local contentRadius = UI:CreateElement("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = dropdownContent
    })
    
    -- Store dropdown state
    Dropdowns[title] = {
        Selected = selected,
        Open = false
    }
    
    -- Add options to dropdown
    local optionHeight = 25
    for i, option in ipairs(options) do
        local optionButton = UI:CreateElement("TextButton", {
            Name = "Option_" .. option,
            Size = UDim2.new(1, 0, 0, optionHeight),
            Position = UDim2.new(0, 0, 0, (i-1) * optionHeight),
            BackgroundTransparency = 1,
            Text = "",
            ZIndex = 11,
            Parent = dropdownContent
        })
        
        local optionLabel = UI:CreateElement("TextLabel", {
            Name = "OptionLabel",
            Size = UDim2.new(1, -20, 1, 0),
            Position = UDim2.new(0, 10, 0, 0),
            BackgroundTransparency = 1,
            Text = option,
            TextColor3 = Colors.Text,
            TextSize = 14,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 11,
            Parent = optionButton
        })
        
        -- Option hover effect
        optionButton.MouseEnter:Connect(function()
            optionButton.BackgroundTransparency = 0.8
            optionButton.BackgroundColor3 = Colors.Accent
        end)
        
        optionButton.MouseLeave:Connect(function()
            optionButton.BackgroundTransparency = 1
        end)
        
        -- Option selection logic
        optionButton.MouseButton1Click:Connect(function()
            selectedLabel.Text = option
            Dropdowns[title].Selected = option
            dropdownContent.Visible = false
            Dropdowns[title].Open = false
            Utility.Tween(dropdownArrow, {Rotation = 0}, 0.2)
            
            -- Call callback function
            if callback then
                callback(option)
            end
        end)
    end
    
    -- Update dropdown content size
    dropdownContent.Size = UDim2.new(1, 0, 0, #options * optionHeight)
    
    -- Toggle dropdown visibility
    dropdownButton.MouseButton1Click:Connect(function()
        Dropdowns[title].Open = not Dropdowns[title].Open
        dropdownContent.Visible = Dropdowns[title].Open
        
        -- Animate dropdown arrow
        if Dropdowns[title].Open then
            Utility.Tween(dropdownArrow, {Rotation = 180}, 0.2)
        else
            Utility.Tween(dropdownArrow, {Rotation = 0}, 0.2)
        end
    end)
    
    -- Close dropdown when clicking elsewhere
    UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and Dropdowns[title].Open then
            local mousePos = UserInputService:GetMouseLocation()
            local dropdownPos = dropdownBox.AbsolutePosition
            local dropdownSize = dropdownBox.AbsoluteSize
            local contentSize = dropdownContent.AbsoluteSize
            
            local inDropdown = mousePos.X >= dropdownPos.X and mousePos.X <= dropdownPos.X + dropdownSize.X and
                              mousePos.Y >= dropdownPos.Y and mousePos.Y <= dropdownPos.Y + dropdownSize.Y
            
            local inContent = mousePos.X >= dropdownPos.X and mousePos.X <= dropdownPos.X + dropdownSize.X and
                             mousePos.Y >= dropdownPos.Y + dropdownSize.Y + 5 and mousePos.Y <= dropdownPos.Y + dropdownSize.Y + 5 + contentSize.Y
            
            if not inDropdown and not inContent then
                dropdownContent.Visible = false
                Dropdowns[title].Open = false
                Utility.Tween(dropdownArrow, {Rotation = 0}, 0.2)
            end
        end
    end)
    
    return container, positionY + 85
end

-- Create a button
function UI:CreateButton(parent, title, positionY, callback)
    local button = UI:CreateElement("TextButton", {
        Name = title .. "Button",
        Size = UDim2.new(1, -20, 0, 40),
        Position = UDim2.new(0, 10, 0, positionY),
        BackgroundColor3 = Colors.Accent,
        BorderSizePixel = 0,
        Text = title,
        TextColor3 = Colors.Text,
        TextSize = 14,
        Font = Enum.Font.GothamSemibold,
        Parent = parent
    })
    
    local buttonRadius = UI:CreateElement("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = button
    })
    
    -- Button hover and click effects
    button.MouseEnter:Connect(function()
        Utility.Tween(button, {BackgroundColor3 = Colors.AccentDark}, 0.2)
    end)
    
    button.MouseLeave:Connect(function()
        Utility.Tween(button, {BackgroundColor3 = Colors.Accent}, 0.2)
    end)
    
    button.MouseButton1Down:Connect(function()
        Utility.Tween(button, {Size = UDim2.new(1, -24, 0, 36), Position = UDim2.new(0, 12, 0, positionY + 2)}, 0.1)
    end)
    
    button.MouseButton1Up:Connect(function()
        Utility.Tween(button, {Size = UDim2.new(1, -20, 0, 40), Position = UDim2.new(0, 10, 0, positionY)}, 0.1)
        
        -- Call callback function
        if callback then
            callback()
        end
    end)
    
    return button, positionY + 50
end

-- Create ESP Tab
function UI:CreateESPTab(tab)
    local posY = 10
    
    -- ESP Toggle Section
    local espSection, posY = self:CreateSection(tab, "ESP Settings", posY)
    
    -- Enable ESP Toggle
    local espToggle, posY = self:CreateToggle(tab, "EnableESP", "Toggle ESP features on/off", Settings.ESP.Enabled, posY, function(value)
        Settings.ESP.Enabled = value
    end)
    
    -- ESP Features Section
    local featuresSection, posY = self:CreateSection(tab, "ESP Features", posY)
    
    -- Box ESP Toggle
    local boxToggle, posY = self:CreateToggle(tab, "BoxESP", "Show bounding boxes around players", Settings.ESP.Boxes, posY, function(value)
        Settings.ESP.Boxes = value
    end)
    
    -- Name ESP Toggle
    local nameToggle, posY = self:CreateToggle(tab, "NameESP", "Show player names", Settings.ESP.Names, posY, function(value)
        Settings.ESP.Names = value
    end)
    
    -- Distance ESP Toggle
    local distanceToggle, posY = self:CreateToggle(tab, "DistanceESP", "Show distance to players", Settings.ESP.Distance, posY, function(value)
        Settings.ESP.Distance = value
    end)
    
    -- Health ESP Toggle
    local healthToggle, posY = self:CreateToggle(tab, "HealthESP", "Show player health bars", Settings.ESP.Health, posY, function(value)
        Settings.ESP.Health = value
    end)
    
    -- Snapline ESP Toggle
    local snaplineToggle, posY = self:CreateToggle(tab, "SnaplineESP", "Show lines to players", Settings.ESP.Snaplines, posY, function(value)
        Settings.ESP.Snaplines = value
    end)
    
    -- Team Check Toggle
    local teamToggle, posY = self:CreateToggle(tab, "TeamCheck", "Don't show ESP for teammates", Settings.ESP.TeamCheck, posY, function(value)
        Settings.ESP.TeamCheck = value
    end)
    
    -- Rainbow ESP Toggle
    local rainbowToggle, posY = self:CreateToggle(tab, "RainbowESP", "Cycle through colors for ESP", Settings.ESP.Rainbow, posY, function(value)
        Settings.ESP.Rainbow = value
    end)
    
    -- ESP Distance
    local distanceSlider, posY = self:CreateSlider(tab, "MaxDistance", "Maximum distance to show ESP", 100, 2000, Settings.ESP.MaxDistance, "%.0f", posY, function(value)
        Settings.ESP.MaxDistance = value
    end)
    
    -- ESP Transparency
    local transparencySlider, posY = self:CreateSlider(tab, "Transparency", "Box transparency", 0, 1, Settings.ESP.BoxTransparency, "%.1f", posY, function(value)
        Settings.ESP.BoxTransparency = value
    end)
    
    -- Update canvas size based on content
    tab.CanvasSize = UDim2.new(0, 0, 0, posY + 20)
end

-- Create Aimbot Tab
function UI:CreateAimbotTab(tab)
    local posY = 10
    
    -- Aimbot Toggle Section
    local aimbotSection, posY = self:CreateSection(tab, "Aimbot Settings", posY)
    
    -- Enable Aimbot Toggle
    local aimbotToggle, posY = self:CreateToggle(tab, "EnableAimbot", "Toggle aimbot features on/off", Settings.Aimbot.Enabled, posY, function(value)
        Settings.Aimbot.Enabled = value
        FOVCircle.Visible = value and Settings.Aimbot.ShowFOV
    end)
    
    -- Team Check Toggle
    local teamToggle, posY = self:CreateToggle(tab, "AimbotTeamCheck", "Don't target teammates", Settings.Aimbot.TeamCheck, posY, function(value)
        Settings.Aimbot.TeamCheck = value
    end)
    
    -- Silent Aim Toggle
    local silentToggle, posY = self:CreateToggle(tab, "SilentAim", "Aim without moving your camera", Settings.Aimbot.SilentAim, posY, function(value)
        Settings.Aimbot.SilentAim = value
    end)
    
    -- Triggerbot Toggle
    local triggerToggle, posY = self:CreateToggle(tab, "Triggerbot", "Automatically shoot when aiming at target", Settings.Aimbot.TriggerBot, posY, function(value)
        Settings.Aimbot.TriggerBot = value
    end)
    
    -- Show FOV Toggle
    local fovShowToggle, posY = self:CreateToggle(tab, "ShowFOV", "Show FOV circle on screen", Settings.Aimbot.ShowFOV, posY, function(value)
        Settings.Aimbot.ShowFOV = value
        FOVCircle.Visible = Settings.Aimbot.Enabled and value
    end)
    
    -- Auto Prediction Toggle
    local predictionToggle, posY = self:CreateToggle(tab, "AutoPrediction", "Automatically adjust prediction based on distance", Settings.Aimbot.AutoPrediction, posY, function(value)
        Settings.Aimbot.AutoPrediction = value
    end)
    
    -- Aimbot Configuration Section
    local configSection, posY = self:CreateSection(tab, "Aimbot Configuration", posY)
    
    -- Aimbot FOV
    local fovSlider, posY = self:CreateSlider(tab, "FOV", "Field of view for aimbot targeting", 10, 500, Settings.Aimbot.FOV, "%.0f", posY, function(value)
        Settings.Aimbot.FOV = value
        FOVCircle.Radius = value
    end)
    
    -- Aimbot Smoothness
    local smoothnessSlider, posY = self:CreateSlider(tab, "Smoothness", "Smoothness of aimbot movement (lower = faster)", 0.01, 1, Settings.Aimbot.Smoothness, "%.2f", posY, function(value)
        Settings.Aimbot.Smoothness = value
    end)
    
    -- Aimbot Prediction
    local predictionSlider, posY = self:CreateSlider(tab, "Prediction", "Prediction multiplier for moving targets", 0, 5, Settings.Aimbot.PredictionMultiplier, "%.1f", posY, function(value)
        Settings.Aimbot.PredictionMultiplier = value
    end)
    
    -- Hit Chance
    local hitChanceSlider, posY = self:CreateSlider(tab, "HitChance", "Chance of hitting target (silent aim)", 1, 100, Settings.Aimbot.HitChance, "%.0f%%", posY, function(value)
        Settings.Aimbot.HitChance = value
    end)
    
    -- Max Distance
    local distanceSlider, posY = self:CreateSlider(tab, "AimbotMaxDistance", "Maximum targeting distance", 50, 1000, Settings.Aimbot.MaxDistance, "%.0f", posY, function(value)
        Settings.Aimbot.MaxDistance = value
    end)
    
    -- Target Part
    local targetParts = {"Head", "Torso", "HumanoidRootPart", "Random"}
    local targetPartDropdown, posY = self:CreateDropdown(tab, "TargetPart", "Body part to target", targetParts, Settings.Aimbot.TargetPart, posY, function(value)
        Settings.Aimbot.TargetPart = value
    end)
    
    -- Update canvas size based on content
    tab.CanvasSize = UDim2.new(0, 0, 0, posY + 20)
end

-- Create Misc Tab
function UI:CreateMiscTab(tab)
    local posY = 10
    
    -- Misc Features Section
    local miscSection, posY = self:CreateSection(tab, "Misc Features", posY)
    
    -- NoClip Toggle
    local noclipToggle, posY = self:CreateToggle(tab, "NoClip", "Walk through walls and objects", Settings.Misc.NoClip, posY, function(value)
        Settings.Misc.NoClip = value
        NoClipEnabled = value
    end)
    
    -- Auto Click Toggle
    local autoClickToggle, posY = self:CreateToggle(tab, "AutoClick", "Automatically click when holding mouse button", Settings.Misc.AutoClick, posY, function(value)
        Settings.Misc.AutoClick = value
        ToggleAutoClick()
    end)
    
    -- FullBright Toggle
    local fullBrightToggle, posY = self:CreateToggle(tab, "FullBright", "Remove darkness and shadows", Settings.Misc.FullBright, posY, function(value)
        Settings.Misc.FullBright = value
        ApplyFullBright()
    end)
    
    -- Auto Click Rate
    local clickRateSlider, posY = self:CreateSlider(tab, "ClickRate", "Clicks per second for Auto Clicker", 0.01, 0.5, Settings.Misc.AutoClickRate, "%.2f", posY, function(value)
        Settings.Misc.AutoClickRate = value
        if AutoClickConnection then
            AutoClickConnection:Disconnect()
            AutoClickConnection = nil
            ToggleAutoClick()
        end
    end)
    
    -- UI Settings Section
    local uiSection, posY = self:CreateSection(tab, "UI Settings", posY)
    
    -- Toggle UI Button
    local toggleButton, posY = self:CreateButton(tab, "Toggle UI (Right Shift)", posY, function()
        Notifications:Show("UI Toggle", "Press Right Shift to toggle UI visibility", 3, "Info")
    end)
    
    -- Reset UI Button
    local resetButton, posY = self:CreateButton(tab, "Reset UI Position", posY, function()
        MainFrame.Position = UDim2.new(0.5, -UIWidth/2, 0.5, -UIHeight/2)
    end)
    
    -- About Section
    local aboutSection, posY = self:CreateSection(tab, "About", posY)
    
    -- Version info
    local versionInfo = UI:CreateElement("TextLabel", {
        Name = "VersionInfo",
        Size = UDim2.new(1, -20, 0, 60),
        Position = UDim2.new(0, 10, 0, posY),
        BackgroundTransparency = 1,
        Text = "Rivals Enhanced v3.5\nCreated by Enhanced UI Team\nLast Updated: April 2025",
        TextColor3 = Colors.TextDark,
        TextSize = 14,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        Parent = tab
    })
    
    posY = posY + 70
    
    -- Update canvas size based on content
    tab.CanvasSize = UDim2.new(0, 0, 0, posY + 20)
end

-- Create Config Tab
function UI:CreateConfigTab(tab)
    local posY = 10
    
    -- Config Management Section
    local configSection, posY = self:CreateSection(tab, "Config Management", posY)
    
    -- Config Name Input
    local nameContainer = UI:CreateElement("Frame", {
        Name = "ConfigNameContainer",
        Size = UDim2.new(1, -20, 0, 70),
        Position = UDim2.new(0, 10, 0, posY),
        BackgroundTransparency = 1,
        Parent = tab
    })
    
    local nameLabel = UI:CreateElement("TextLabel", {
        Name = "NameLabel",
        Size = UDim2.new(1, 0, 0, 20),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        Text = "Config Name",
        TextColor3 = Colors.Text,
        TextSize = 14,
        Font = Enum.Font.GothamSemibold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = nameContainer
    })
    
    local nameBox = UI:CreateElement("TextBox", {
        Name = "NameBox",
        Size = UDim2.new(1, 0, 0, 40),
        Position = UDim2.new(0, 0, 0, 25),
        BackgroundColor3 = Colors.Tertiary,
        BorderSizePixel = 0,
        Text = "",
        PlaceholderText = "Enter config name...",
        TextColor3 = Colors.Text,
        PlaceholderColor3 = Colors.TextDark,
        TextSize = 14,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
        Parent = nameContainer
    })
    
    local nameBoxRadius = UI:CreateElement("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = nameBox
    })
    
    local namePadding = UI:CreateElement("UIPadding", {
        PaddingLeft = UDim.new(0, 10),
        Parent = nameBox
    })
    
    posY = posY + 80
    
    -- Current Config Display
    local currentConfigContainer = UI:CreateElement("Frame", {
        Name = "CurrentConfigContainer",
        Size = UDim2.new(1, -20, 0, 50),
        Position = UDim2.new(0, 10, 0, posY),
        BackgroundTransparency = 1,
        Parent = tab
    })
    
    local currentConfigLabel = UI:CreateElement("TextLabel", {
        Name = "CurrentConfigLabel",
        Size = UDim2.new(1, 0, 0, 20),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        Text = "Current Config",
        TextColor3 = Colors.Text,
        TextSize = 14,
        Font = Enum.Font.GothamSemibold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = currentConfigContainer
    })
    
    local currentConfigValue = UI:CreateElement("TextLabel", {
        Name = "CurrentConfigValue",
        Size = UDim2.new(1, 0, 0, 20),
        Position = UDim2.new(0, 0, 0, 25),
        BackgroundTransparency = 1,
        Text = Settings.Config.CurrentConfig,
        TextColor3 = Colors.Accent,
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = currentConfigContainer
    })
    
    posY = posY + 60
    
    -- Config Action Buttons
    local saveButton, posY = self:CreateButton(tab, "Save Config", posY, function()
        local configName = nameBox.Text
        if configName and configName ~= "" then
            local success = Config:SaveConfig(configName)
            if success then
                currentConfigValue.Text = configName
            end
        else
            Notifications:Show("Config Error", "Please enter a config name", 3, "Error")
        end
    end)
    
    local loadButton, posY = self:CreateButton(tab, "Load Config", posY, function()
        local configName = nameBox.Text
        if configName and configName ~= "" then
            local success = Config:LoadConfig(configName)
            if success then
                currentConfigValue.Text = configName
                
                -- Update UI toggles to match loaded config
                for key, value in pairs(ToggleButtons) do
                    if key == "EnableESP" then ToggleButtons[key] = Settings.ESP.Enabled end
                    if key == "BoxESP" then ToggleButtons[key] = Settings.ESP.Boxes end
                    if key == "NameESP" then ToggleButtons[key] = Settings.ESP.Names end
                    if key == "DistanceESP" then ToggleButtons[key] = Settings.ESP.Distance end
                    if key == "HealthESP" then ToggleButtons[key] = Settings.ESP.Health end
                    if key == "SnaplineESP" then ToggleButtons[key] = Settings.ESP.Snaplines end
                    if key == "TeamCheck" then ToggleButtons[key] = Settings.ESP.TeamCheck end
                    if key == "RainbowESP" then ToggleButtons[key] = Settings.ESP.Rainbow end
                    
                    if key == "EnableAimbot" then ToggleButtons[key] = Settings.Aimbot.Enabled end
                    if key == "AimbotTeamCheck" then ToggleButtons[key] = Settings.Aimbot.TeamCheck end
                    if key == "SilentAim" then ToggleButtons[key] = Settings.Aimbot.SilentAim end
                    if key == "Triggerbot" then ToggleButtons[key] = Settings.Aimbot.TriggerBot end
                    if key == "ShowFOV" then ToggleButtons[key] = Settings.Aimbot.ShowFOV end
                    if key == "AutoPrediction" then ToggleButtons[key] = Settings.Aimbot.AutoPrediction end
                    
                    if key == "NoClip" then ToggleButtons[key] = Settings.Misc.NoClip end
                    if key == "AutoClick" then ToggleButtons[key] = Settings.Misc.AutoClick end
                    if key == "FullBright" then ToggleButtons[key] = Settings.Misc.FullBright end
                end
                
                -- Rebuild UI to reflect changes
                UI:CreateInterface()
            end
        else
            Notifications:Show("Config Error", "Please enter a config name", 3, "Error")
        end
    end)
    
    local deleteButton, posY = self:CreateButton(tab, "Delete Config", posY, function()
        local configName = nameBox.Text
        if configName and configName ~= "" then
            local success = Config:DeleteConfig(configName)
            if success and Settings.Config.CurrentConfig == "Default" then
                currentConfigValue.Text = "Default"
            end
        else
            Notifications:Show("Config Error", "Please enter a config name", 3, "Error")
        end
    end)
    
    -- Config List Section
    local listSection, posY = self:CreateSection(tab, "Available Configs", posY)
    
    -- Create list container
    local listContainer = UI:CreateElement("Frame", {
        Name = "ConfigListContainer",
        Size = UDim2.new(1, -20, 0, 150),
        Position = UDim2.new(0, 10, 0, posY),
        BackgroundColor3 = Colors.Tertiary,
        BorderSizePixel = 0,
        Parent = tab
    })
    
    local listRadius = UI:CreateElement("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = listContainer
    })
    
    local listScroll = UI:CreateElement("ScrollingFrame", {
        Name = "ConfigList",
        Size = UDim2.new(1, -10, 1, -10),
        Position = UDim2.new(0, 5, 0, 5),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = Colors.Accent,
        CanvasSize = UDim2.new(0, 0, 0, 0), -- Will adjust based on content
        Parent = listContainer
    })
    
    -- Function to refresh config list
    local function RefreshConfigList()
        -- Clear existing items
        for _, child in pairs(listScroll:GetChildren()) do
            if child:IsA("TextButton") then
                child:Destroy()
            end
        end
        
        -- Get config names
        local configs = Config:GetConfigNames()
        
        -- Add config items
        local itemHeight = 30
        local canvasHeight = 0
        
        for i, configName in ipairs(configs) do
            local configButton = UI:CreateElement("TextButton", {
                Name = "Config_" .. configName,
                Size = UDim2.new(1, -10, 0, itemHeight),
                Position = UDim2.new(0, 5, 0, (i-1) * (itemHeight + 5)),
                BackgroundColor3 = configName == Settings.Config.CurrentConfig and Colors.Accent or Colors.Secondary,
                BorderSizePixel = 0,
                Text = "",
                Parent = listScroll
            })
            
            local configRadius = UI:CreateElement("UICorner", {
                CornerRadius = UDim.new(0, 4),
                Parent = configButton
            })
            
            local configLabel = UI:CreateElement("TextLabel", {
                Name = "ConfigLabel",
                Size = UDim2.new(1, -10, 1, 0),
                Position = UDim2.new(0, 10, 0, 0),
                BackgroundTransparency = 1,
                Text = configName,
                TextColor3 = Colors.Text,
                TextSize = 14,
                Font = Enum.Font.Gotham,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = configButton
            })
            
            -- Add selection functionality
            configButton.MouseButton1Click:Connect(function()
                nameBox.Text = configName
            end)
            
            canvasHeight = canvasHeight + itemHeight + 5
        end
        
        -- Update canvas size
        listScroll.CanvasSize = UDim2.new(0, 0, 0, canvasHeight)
    end
    
    -- Refresh list button
    local refreshButton, posY = self:CreateButton(tab, "Refresh Config List", posY + 160, function()
        RefreshConfigList()
    end)
    
    -- Initial list population
    RefreshConfigList()
    
    -- Update canvas size based on content
    tab.CanvasSize = UDim2.new(0, 0, 0, posY + 20)
end

-- Main Functions
-- Initialize ESP for existing players
local function InitializeESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            ESP:CreatePlayerESP(player)
        end
    end
end

-- Initialize everything
local function Initialize()
    -- Initialize default config
    Config:Initialize()
    
    -- Create FOV circle
    FOVCircle.Visible = Settings.Aimbot.ShowFOV and Settings.Aimbot.Enabled
    FOVCircle.Radius = Settings.Aimbot.FOV
    
    -- Create UI
    UI:CreateInterface()
    
    -- Initialize ESP
    InitializeESP()
    
    -- Initialize aimbot hooks
    Aimbot:CreateSilentAimHook()
    
    -- Setup connections
    local connections = {
        -- Update ESP
        RunService.RenderStepped:Connect(function()
            -- Update FOV circle position
            FOVCircle.Position = UserInputService:GetMouseLocation()
            
            -- Update ESP
            ESP:UpdatePlayerESP()
            
            -- Apply aimbot
            if Settings.Aimbot.Enabled and IsRightMouseDown then
                local target = Aimbot:GetTarget()
                if target then
                    Aimbot:AimAt(target)
                    
                    -- Apply triggerbot
                    if Settings.Aimbot.TriggerBot then
                        local success, result = Utility.SafeCall(function()
                            -- Wait for trigger delay
                            task.wait(Settings.Aimbot.TriggerDelay)
                            -- Simulate left mouse click
                            mouse1click()
                        end)
                    end
                end
            end
            
            -- Apply noclip
            if NoClipEnabled then
                ApplyNoClip()
            end
        end),
        
        -- Handle new players
        Players.PlayerAdded:Connect(function(player)
            ESP:CreatePlayerESP(player)
        end),
        
        -- Handle players leaving
        Players.PlayerRemoving:Connect(function(player)
            ESP:RemovePlayerESP(player)
        end),
        
        -- Handle mouse input
        UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                IsLeftMouseDown = true
            elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
                IsRightMouseDown = true
            elseif input.KeyCode == Enum.KeyCode.RightShift then
                -- Toggle UI
                if GuiVisible then
                    if ScreenGui then
                        ScreenGui.Enabled = not ScreenGui.Enabled
                    end
                else
                    UI:CreateInterface()
                    GuiVisible = true
                end
            end
        end),
        
        -- Handle mouse input release
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                IsLeftMouseDown = false
            elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
                IsRightMouseDown = false
            end
        end)
    }
    
    -- Store connections
    for _, connection in pairs(connections) do
        table.insert(RunningConnections, connection)
    end
    
    -- Show welcome notification
    Notifications:Show("Rivals Enhanced", "Successfully loaded v3.5", 3, "Success")
end

-- Start everything
Initialize()
