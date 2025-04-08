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
    DropShadow = Color3.fromRGB(0, 0, 0)
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
        BoxColor = Color3.fromRGB(131, 0, 255),
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
function ESP.InitializePlayer(player)
    if Settings.ESP.Players[player] then return end
    
    local esp = {
        Box = Drawing.new("Square"),
        Name = Drawing.new("Text"),
        Distance = Drawing.new("Text"),
        Snapline = Drawing.new("Line"),
        HealthBar = Drawing.new("Square"),
        HealthBarBackground = Drawing.new("Square"),
        HeadDot = Drawing.new("Circle")
    }
    
    -- Box ESP
    esp.Box.Visible = false
    esp.Box.Color = Settings.ESP.BoxColor
    esp.Box.Thickness = 1.5
    esp.Box.Filled = false
    esp.Box.Transparency = Settings.ESP.BoxTransparency
    
    -- Name ESP
    esp.Name.Visible = false
    esp.Name.Color = Color3.new(1, 1, 1)
    esp.Name.Size = 16
    esp.Name.Center = true
    esp.Name.Outline = true
    esp.Name.OutlineColor = Color3.new(0, 0, 0)
    
    -- Distance ESP
    esp.Distance.Visible = false
    esp.Distance.Color = Color3.new(1, 1, 1)
    esp.Distance.Size = 14
    esp.Distance.Center = true
    esp.Distance.Outline = true
    esp.Distance.OutlineColor = Color3.new(0, 0, 0)
    
    -- Snapline ESP
    esp.Snapline.Visible = false
    esp.Snapline.Color = Settings.ESP.BoxColor
    esp.Snapline.Thickness = 1.5
    esp.Snapline.Transparency = 1
    
    -- Health Bar
    esp.HealthBar.Visible = false
    esp.HealthBar.Color = Color3.fromRGB(0, 255, 0)
    esp.HealthBar.Filled = true
    esp.HealthBar.Thickness = 1
    esp.HealthBar.Transparency = 1
    
    -- Health Bar Background
    esp.HealthBarBackground.Visible = false
    esp.HealthBarBackground.Color = Color3.fromRGB(255, 0, 0)
    esp.HealthBarBackground.Filled = true
    esp.HealthBarBackground.Thickness = 1
    esp.HealthBarBackground.Transparency = 1
    
    -- Head Dot
    esp.HeadDot.Visible = false
    esp.HeadDot.Color = Color3.fromRGB(255, 255, 255)
    esp.HeadDot.Thickness = 1
    esp.HeadDot.NumSides = 12
    esp.HeadDot.Radius = 3
    esp.HeadDot.Filled = true
    esp.HeadDot.Transparency = 1
    
    Settings.ESP.Players[player] = esp
end

-- Clean up ESP objects for a player
function ESP.CleanupPlayer(player)
    if not Settings.ESP.Players[player] then return end
    
    for _, object in pairs(Settings.ESP.Players[player]) do
        Utility.SafeCall(function()
            if object and typeof(object) == "table" and object.Remove then
                object:Remove()
            end
        end)
    end
    
    Settings.ESP.Players[player] = nil
end

-- Set visibility of all ESP elements for a player
function ESP.SetVisibility(player, visible)
    if not Settings.ESP.Players[player] then return end
    
    for _, object in pairs(Settings.ESP.Players[player]) do
        Utility.SafeCall(function()
            if object and typeof(object) == "table" and object.Visible ~= nil then
                object.Visible = visible
            end
        end)
    end
end

-- Update ESP for a player
function ESP.Update(player)
    if player == LocalPlayer then return end
    if not Settings.ESP.Players[player] then
        ESP.InitializePlayer(player)
    end
    
    local character = Utility.GetCharacter(player)
    if not character then
        ESP.SetVisibility(player, false)
        return
    end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local hrp = character:FindFirstChild("HumanoidRootPart")
    
    if not humanoid or not hrp then
        ESP.SetVisibility(player, false)
        return
    end
    
    -- Check if player should be rendered based on team
    if Settings.ESP.TeamCheck and Utility.IsTeammate(player) then
        ESP.SetVisibility(player, false)
        return
    end
    
    -- Check if player is within render distance
    local distance = Utility.GetDistance(hrp.Position, Camera.CFrame.Position)
    if distance > Settings.ESP.MaxDistance then
        ESP.SetVisibility(player, false)
        return
    end
    
    -- Get character dimensions for ESP box
    local minX, minY, maxX, maxY
    local screenPositions = {}
    
    for _, part in pairs(character:GetChildren()) do
        if part:IsA("BasePart") then
            local pos, onScreen = Utility.WorldToScreen(part.Position)
            if onScreen then
                screenPositions[#screenPositions + 1] = pos
            end
        end
    end
    
    if #screenPositions == 0 then
        ESP.SetVisibility(player, false)
        return
    end
    
    -- Calculate bounding box
    minX, minY = math.huge, math.huge
    maxX, maxY = -math.huge, -math.huge
    
    for _, pos in ipairs(screenPositions) do
        minX = math.min(minX, pos.X)
        minY = math.min(minY, pos.Y)
        maxX = math.max(maxX, pos.X)
        maxY = math.max(maxY, pos.Y)
    end
    
    -- Account for health bar width
    minX = minX - 7
    maxX = maxX + 7
    
    -- Head position for dot and distance calculation
    local head = character:FindFirstChild("Head")
    local headPosition, headOnScreen
    if head then
        headPosition, headOnScreen = Utility.WorldToScreen(head.Position)
    end
    
    -- Apply ESP elements
    local esp = Settings.ESP.Players[player]
    
    -- Calculate box color
    local boxColor
    if Settings.ESP.Rainbow then
        boxColor = Utility.GetRainbowColor()
    else
        boxColor = Settings.ESP.BoxColor
    end
    
    -- Box
    esp.Box.Visible = Settings.ESP.Enabled and Settings.ESP.Boxes
    esp.Box.Position = Vector2.new(minX, minY)
    esp.Box.Size = Vector2.new(maxX - minX, maxY - minY)
    esp.Box.Color = boxColor
    
    -- Name
    if Settings.ESP.Enabled and Settings.ESP.Names then
        esp.Name.Visible = true
        esp.Name.Position = Vector2.new((minX + maxX) / 2, minY - 20)
        esp.Name.Text = player.Name
    else
        esp.Name.Visible = false
    end
    
    -- Distance
    if Settings.ESP.Enabled and Settings.ESP.Distance then
        esp.Distance.Visible = true
        esp.Distance.Position = Vector2.new((minX + maxX) / 2, maxY + 5)
        esp.Distance.Text = string.format("%.1f m", distance)
    else
        esp.Distance.Visible = false
    end
    
    -- Snapline
    if Settings.ESP.Enabled and Settings.ESP.Snaplines then
        esp.Snapline.Visible = true
        esp.Snapline.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
        esp.Snapline.To = Vector2.new((minX + maxX) / 2, maxY)
        esp.Snapline.Color = boxColor
    else
        esp.Snapline.Visible = false
    end
    
    -- Health bar
    if Settings.ESP.Enabled and Settings.ESP.Health and humanoid then
        local healthPercentage = humanoid.Health / humanoid.MaxHealth
        local healthBarHeight = (maxY - minY) * healthPercentage
        
        esp.HealthBarBackground.Visible = true
        esp.HealthBarBackground.Position = Vector2.new(minX - 6, minY)
        esp.HealthBarBackground.Size = Vector2.new(4, maxY - minY)
        
        esp.HealthBar.Visible = true
        esp.HealthBar.Position = Vector2.new(minX - 6, minY + (maxY - minY) * (1 - healthPercentage))
        esp.HealthBar.Size = Vector2.new(4, healthBarHeight)
        esp.HealthBar.Color = Utility.GetHealthColor(humanoid.Health, humanoid.MaxHealth)
    else
        esp.HealthBarBackground.Visible = false
        esp.HealthBar.Visible = false
    end
    
    -- Head dot
    if headOnScreen and head then
        esp.HeadDot.Visible = Settings.ESP.Enabled
        esp.HeadDot.Position = headPosition
        esp.HeadDot.Color = boxColor
    else
        esp.HeadDot.Visible = false
    end
end

-- Update all ESP
function ESP.UpdateAll()
    if not Settings.ESP.Enabled then
        for player, _ in pairs(Settings.ESP.Players) do
            ESP.SetVisibility(player, false)
        end
        return
    end
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            ESP.Update(player)
        end
    end
end

-- Aimbot Functions
local Aimbot = {}

-- Find closest player to mouse cursor
function Aimbot.GetClosestPlayerToMouse()
    local closestPlayer = nil
    local shortestDistance = math.huge
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and Utility.IsAlive(player) then
            -- Skip teammates if team check is enabled
            if Settings.Aimbot.TeamCheck and Utility.IsTeammate(player) then
                continue
            end
            
            local character = Utility.GetCharacter(player)
            if not character then continue end
            
            local targetPart = character:FindFirstChild(Settings.Aimbot.TargetPart)
            if not targetPart then continue end
            
            -- Check distance from local player
            local distance = Utility.GetDistance(targetPart.Position, Camera.CFrame.Position)
            if distance > Settings.Aimbot.MaxDistance then
                continue
            end
            
            -- Calculate target position with prediction
            local predictedPosition = Utility.GetPartPosition(player, Settings.Aimbot.TargetPart, true)
            if not predictedPosition then continue end
            
            -- Convert to screen position
            local screenPosition, onScreen = Utility.WorldToScreen(predictedPosition)
            if not onScreen then continue end
            
            -- Check if within FOV
            local screenDistance = (screenPosition - screenCenter).Magnitude
            if screenDistance > Settings.Aimbot.FOV then
                continue
            end
            
            if screenDistance < shortestDistance then
                closestPlayer = player
                shortestDistance = screenDistance
            end
        end
    end

    return closestPlayer
end

-- Perfect aim function for silent aim
function Aimbot.PerfectAim(targetPart)
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local targetPosition = Camera:WorldToViewportPoint(targetPart.Position)
    local targetVector = Vector2.new(targetPosition.X, targetPosition.Y)
    
    local distanceFromCenter = (targetVector - screenCenter).Magnitude
    
    if distanceFromCenter > 5 then
        mousemoverel(targetVector.X - screenCenter.X, targetVector.Y - screenCenter.Y)
    end
end

-- Lock camera to head function for visible aim
function Aimbot.LockToHead(targetPart)
    local targetPosition = Camera:WorldToViewportPoint(targetPart.Position)
    if targetPosition.Z > 0 then
        local cameraPosition = Camera.CFrame.Position
        Camera.CFrame = CFrame.new(cameraPosition, targetPart.Position)
    end
end

-- Update aimbot
function Aimbot.Update()
    -- Update FOV circle
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    FOVCircle.Radius = Settings.Aimbot.FOV
    FOVCircle.Visible = Settings.Aimbot.ShowFOV and Settings.Aimbot.Enabled
    
    -- If aimbot is disabled, don't process further
    if not Settings.Aimbot.Enabled then
        return
    end
    
    -- Only aim when right mouse button is held
    if IsRightMouseDown then
        if not TargetPlayer then
            TargetPlayer = Aimbot.GetClosestPlayerToMouse()
        end
        
        if TargetPlayer and TargetPlayer.Character then
            local targetPart = TargetPlayer.Character:FindFirstChild(Settings.Aimbot.TargetPart)
            if targetPart then
                -- Apply hit chance
                if Settings.Aimbot.SilentAim then
                    local hitChance = math.random(1, 100)
                    if hitChance <= Settings.Aimbot.HitChance then
                        Aimbot.PerfectAim(targetPart)
                    end
                else
                    Aimbot.LockToHead(targetPart)
                end
            end
        end
    else
        TargetPlayer = nil
    end
end

-- Apply FullBright settings
function ApplyFullBright()
    if Settings.Misc.FullBright then
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = false
        Lighting.Ambient = Color3.fromRGB(178, 178, 178)
    else
        Lighting.Brightness = OriginalLighting.Brightness
        Lighting.ClockTime = OriginalLighting.ClockTime
        Lighting.FogEnd = OriginalLighting.FogEnd
        Lighting.GlobalShadows = OriginalLighting.GlobalShadows
        Lighting.Ambient = OriginalLighting.Ambient
    end
end

-- Update NoClip
function UpdateNoClip()
    if not Settings.Misc.NoClip then return end
    
    local character = Utility.GetCharacter(LocalPlayer)
    if not character then return end
    
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") and part.CanCollide then
            part.CanCollide = false
        end
    end
end

-- Setup AutoClick
function SetupAutoClick()
    if AutoClickConnection then
        AutoClickConnection:Disconnect()
        AutoClickConnection = nil
    end
    
    if Settings.Misc.AutoClick then
        AutoClickConnection = RunService.Heartbeat:Connect(function()
            if IsLeftMouseDown then
                mouse1click()
                wait(Settings.Misc.AutoClickRate)
            end
        end)
    end
end

-- Create UI
local function CreateUI()
    -- Create ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "RivalsEnhancedGUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = CoreGui
    
    -- Create Main Frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 400, 0, 500)
    MainFrame.Position = UDim2.new(0.5, -200, 0.5, -250)
    MainFrame.BackgroundColor3 = Colors.Background
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui
    
    -- Add UI Enhancement Elements
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 10)
    UICorner.Parent = MainFrame
    
    local DropShadow = Instance.new("ImageLabel")
    DropShadow.Name = "DropShadow"
    DropShadow.BackgroundTransparency = 1
    DropShadow.Position = UDim2.new(0, -15, 0, -15)
    DropShadow.Size = UDim2.new(1, 30, 1, 30)
    DropShadow.Image = "rbxassetid://6014261993"
    DropShadow.ImageColor3 = Colors.DropShadow
    DropShadow.ImageTransparency = 0.5
    DropShadow.ZIndex = 0
    DropShadow.Parent = MainFrame
    
    -- Create Header with player info
    local Header = Instance.new("Frame")
    Header.Name = "Header"
    Header.Size = UDim2.new(1, 0, 0, 70)
    Header.BackgroundColor3 = Colors.Primary
    Header.BorderSizePixel = 0
    Header.Parent = MainFrame
    
    local HeaderCorner = Instance.new("UICorner")
    HeaderCorner.CornerRadius = UDim.new(0, 10)
    HeaderCorner.Parent = Header
    
    local HeaderFix = Instance.new("Frame")
    HeaderFix.Name = "HeaderFix"
    HeaderFix.Size = UDim2.new(1, 0, 0, 10)
    HeaderFix.Position = UDim2.new(0, 0, 1, -10)
    HeaderFix.BackgroundColor3 = Colors.Primary
    HeaderFix.BorderSizePixel = 0
    HeaderFix.ZIndex = 2
    HeaderFix.Parent = Header
    
    -- Title
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Name = "TitleLabel"
    TitleLabel.Size = UDim2.new(1, -80, 0, 30)
    TitleLabel.Position = UDim2.new(0, 80, 0, 5)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = "RIVALS ENHANCED"
    TitleLabel.TextColor3 = Colors.Accent
    TitleLabel.TextSize = 22
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = Header
    
    -- Version
    local VersionLabel = Instance.new("TextLabel")
    VersionLabel.Name = "VersionLabel"
    VersionLabel.Size = UDim2.new(1, -80, 0, 20)
    VersionLabel.Position = UDim2.new(0, 80, 0, 35)
    VersionLabel.BackgroundTransparency = 1
    VersionLabel.Text = "Version 3.5 | Ultra Edition"
    VersionLabel.TextColor3 = Colors.TextDark
    VersionLabel.TextSize = 14
    VersionLabel.Font = Enum.Font.Gotham
    VersionLabel.TextXAlignment = Enum.TextXAlignment.Left
    VersionLabel.Parent = Header
    
    -- User Avatar
    local AvatarFrame = Instance.new("Frame")
    AvatarFrame.Name = "AvatarFrame"
    AvatarFrame.Size = UDim2.new(0, 60, 0, 60)
    AvatarFrame.Position = UDim2.new(0, 10, 0, 5)
    AvatarFrame.BackgroundColor3 = Colors.Secondary
    AvatarFrame.BorderSizePixel = 0
    AvatarFrame.ZIndex = 2
    AvatarFrame.Parent = Header
    
    local AvatarCorner = Instance.new("UICorner")
    AvatarCorner.CornerRadius = UDim.new(1, 0)
    AvatarCorner.Parent = AvatarFrame
    
    local AvatarImage = Instance.new("ImageLabel")
    AvatarImage.Name = "AvatarImage"
    AvatarImage.Size = UDim2.new(1, -4, 1, -4)
    AvatarImage.Position = UDim2.new(0, 2, 0, 2)
    AvatarImage.BackgroundTransparency = 1
    AvatarImage.Image = Utility.GetPlayerAvatar(LocalPlayer.UserId, 60)
    AvatarImage.ZIndex = 3
    AvatarImage.Parent = AvatarFrame
    
    local AvatarCorner2 = Instance.new("UICorner")
    AvatarCorner2.CornerRadius = UDim.new(1, 0)
    AvatarCorner2.Parent = AvatarImage
    
    -- Username
    local UsernameLabel = Instance.new("TextLabel")
    UsernameLabel.Name = "UsernameLabel"
    UsernameLabel.Size = UDim2.new(0, 200, 0, 20)
    UsernameLabel.Position = UDim2.new(1, -210, 0, 25)
    UsernameLabel.BackgroundTransparency = 1
    UsernameLabel.Text = "@" .. LocalPlayer.Name
    UsernameLabel.TextColor3 = Colors.Text
    UsernameLabel.TextSize = 16
    UsernameLabel.Font = Enum.Font.GothamBold
    UsernameLabel.TextXAlignment = Enum.TextXAlignment.Right
    UsernameLabel.Parent = Header
    
    -- Navigation Sidebar
    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0, 100, 1, -70)
    Sidebar.Position = UDim2.new(0, 0, 0, 70)
    Sidebar.BackgroundColor3 = Colors.Secondary
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = MainFrame
    
    -- Create Content Frame
    local ContentContainer = Instance.new("Frame")
    ContentContainer.Name = "ContentContainer"
    ContentContainer.Size = UDim2.new(1, -100, 1, -70)
    ContentContainer.Position = UDim2.new(0, 100, 0, 70)
    ContentContainer.BackgroundColor3 = Colors.Background
    ContentContainer.BorderSizePixel = 0
    ContentContainer.ClipsDescendants = true
    ContentContainer.Parent = MainFrame
    
    -- Create pages
    local Pages = {
        Aimbot = Instance.new("ScrollingFrame"),
        ESP = Instance.new("ScrollingFrame"),
        Misc = Instance.new("ScrollingFrame"),
        Config = Instance.new("ScrollingFrame")
    }
    
    -- Setup pages
    for name, frame in pairs(Pages) do
        frame.Name = name .. "Page"
        frame.Size = UDim2.new(1, 0, 1, 0)
        frame.BackgroundTransparency = 1
        frame.BorderSizePixel = 0
        frame.ScrollBarThickness = 4
        frame.ScrollBarImageColor3 = Colors.Accent
        frame.Visible = false
        frame.Parent = ContentContainer
        
        -- Add padding
        local Padding = Instance.new("UIPadding")
        Padding.PaddingTop = UDim.new(0, 15)
        Padding.PaddingBottom = UDim.new(0, 15)
        Padding.PaddingLeft = UDim.new(0, 15)
        Padding.PaddingRight = UDim.new(0, 15)
        Padding.Parent = frame
        
        -- Add list layout
        local ListLayout = Instance.new("UIListLayout")
        ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
        ListLayout.Padding = UDim.new(0, 10)
        ListLayout.Parent = frame
    end
    
    -- Make Aimbot page visible by default
    Pages.Aimbot.Visible = true
    
    -- Create Nav Buttons
    local NavButtons = {}
    local ButtonData = {
        {Name = "Aimbot", Icon = "rbxassetid://7733715400"},
        {Name = "ESP", Icon = "rbxassetid://7733774602"},
        {Name = "Misc", Icon = "rbxassetid://7734053495"},
        {Name = "Config", Icon = "rbxassetid://7733956866"}
    }
    
    for i, data in ipairs(ButtonData) do
        local Button = Instance.new("TextButton")
        Button.Name = data.Name .. "Button"
        Button.Size = UDim2.new(1, 0, 0, 80)
        Button.Position = UDim2.new(0, 0, 0, 10 + (i-1) * 90)
        Button.BackgroundColor3 = data.Name == "Aimbot" and Colors.Accent or Colors.Secondary
        Button.BorderSizePixel = 0
        Button.Text = ""
        Button.AutoButtonColor = false
        Button.Parent = Sidebar
        
        local Icon = Instance.new("ImageLabel")
        Icon.Name = "Icon"
        Icon.Size = UDim2.new(0, 32, 0, 32)
        Icon.Position = UDim2.new(0.5, -16, 0.3, -16)
        Icon.BackgroundTransparency = 1
        Icon.Image = data.Icon
        Icon.ImageColor3 = data.Name == "Aimbot" and Colors.Text or Colors.TextDark
        Icon.Parent = Button
        
        local Label = Instance.new("TextLabel")
        Label.Name = "Label"
        Label.Size = UDim2.new(1, 0, 0, 20)
        Label.Position = UDim2.new(0, 0, 0.7, -10)
        Label.BackgroundTransparency = 1
        Label.Text = data.Name
        Label.TextColor3 = data.Name == "Aimbot" and Colors.Text or Colors.TextDark
        Label.TextSize = 14
        Label.Font = Enum.Font.GothamBold
        Label.Parent = Button
        
        -- Store button and its elements for later use
        NavButtons[data.Name] = {
            Button = Button,
            Icon = Icon,
            Label = Label
        }
        
        -- Button click behavior
        Button.MouseButton1Click:Connect(function()
            -- Hide all pages and reset button colors
            for name, page in pairs(Pages) do
                page.Visible = false
                NavButtons[name].Button.BackgroundColor3 = Colors.Secondary
                NavButtons[name].Icon.ImageColor3 = Colors.TextDark
                NavButtons[name].Label.TextColor3 = Colors.TextDark
            end
            
            -- Show selected page and set button color
            Pages[data.Name].Visible = true
            Button.BackgroundColor3 = Colors.Accent
            Icon.ImageColor3 = Colors.Text
            Label.TextColor3 = Colors.Text
        end)
    end
    
    -- Function to create a section title
    local function CreateSectionTitle(parent, text, order)
        local TitleFrame = Instance.new("Frame")
        TitleFrame.Name = text .. "TitleFrame"
        TitleFrame.Size = UDim2.new(1, 0, 0, 30)
        TitleFrame.BackgroundTransparency = 1
        TitleFrame.LayoutOrder = order
        TitleFrame.Parent = parent
        
        local TitleLabel = Instance.new("TextLabel")
        TitleLabel.Name = "TitleLabel"
        TitleLabel.Size = UDim2.new(1, 0, 1, 0)
        TitleLabel.BackgroundTransparency = 1
        TitleLabel.Text = text
        TitleLabel.TextColor3 = Colors.Accent
        TitleLabel.TextSize = 16
        TitleLabel.Font = Enum.Font.GothamBold
        TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
        TitleLabel.Parent = TitleFrame
        
        local Underline = Instance.new("Frame")
        Underline.Name = "Underline"
        Underline.Size = UDim2.new(1, 0, 0, 2)
        Underline.Position = UDim2.new(0, 0, 1, 0)
        Underline.BackgroundColor3 = Colors.Accent
        Underline.BorderSizePixel = 0
        Underline.Parent = TitleFrame
        
        return TitleFrame
    end
    
    -- Function to create a toggle button
    local function CreateToggle(parent, text, category, setting, order)
        local ToggleFrame = Instance.new("Frame")
        ToggleFrame.Name = text .. "Toggle"
        ToggleFrame.Size = UDim2.new(1, 0, 0, 40)
        ToggleFrame.BackgroundColor3 = Colors.Primary
        ToggleFrame.BorderSizePixel = 0
        ToggleFrame.LayoutOrder = order
        ToggleFrame.Parent = parent
        
        local UICorner = Instance.new("UICorner")
        UICorner.CornerRadius = UDim.new(0, 8)
        UICorner.Parent = ToggleFrame
        
        local ToggleLabel = Instance.new("TextLabel")
        ToggleLabel.Name = "ToggleLabel"
        ToggleLabel.Size = UDim2.new(1, -60, 1, 0)
        ToggleLabel.Position = UDim2.new(0, 10, 0, 0)
        ToggleLabel.BackgroundTransparency = 1
        ToggleLabel.Text = text
        ToggleLabel.TextColor3 = Colors.Text
        ToggleLabel.TextSize = 15
        ToggleLabel.Font = Enum.Font.Gotham
        ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
        ToggleLabel.Parent = ToggleFrame
        
        local ToggleButton = Instance.new("TextButton")
        ToggleButton.Name = "ToggleButton"
        ToggleButton.Size = UDim2.new(0, 50, 0, 24)
        ToggleButton.Position = UDim2.new(1, -60, 0.5, -12)
        ToggleButton.BackgroundColor3 = Settings[category][setting] and Colors.Accent or Colors.Tertiary
        ToggleButton.BorderSizePixel = 0
        ToggleButton.Text = ""
        ToggleButton.AutoButtonColor = false
        ToggleButton.Parent = ToggleFrame
        
        local ToggleButtonCorner = Instance.new("UICorner")
        ToggleButtonCorner.CornerRadius = UDim.new(1, 0)
        ToggleButtonCorner.Parent = ToggleButton
        
        local ToggleCircle = Instance.new("Frame")
        ToggleCircle.Name = "ToggleCircle"
        ToggleCircle.Size = UDim2.new(0, 20, 0, 20)
        ToggleCircle.Position = Settings[category][setting] and 
                             UDim2.new(1, -22, 0.5, -10) or 
                             UDim2.new(0, 2, 0.5, -10)
        ToggleCircle.BackgroundColor3 = Colors.Text
        ToggleCircle.BorderSizePixel = 0
        ToggleCircle.Parent = ToggleButton
        
        local ToggleCircleCorner = Instance.new("UICorner")
        ToggleCircleCorner.CornerRadius = UDim.new(1, 0)
        ToggleCircleCorner.Parent = ToggleCircle
        
        -- Toggle functionality
        ToggleButton.MouseButton1Click:Connect(function()
            -- Toggle the setting
            Settings[category][setting] = not Settings[category][setting]
            
            -- Animate toggle
            local targetPosition = Settings[category][setting] and 
                                 UDim2.new(1, -22, 0.5, -10) or 
                                 UDim2.new(0, 2, 0.5, -10)
            local targetColor = Settings[category][setting] and 
                              Colors.Accent or 
                              Colors.Tertiary
            
            Utility.Tween(ToggleCircle, {Position = targetPosition}, 0.2)
            Utility.Tween(ToggleButton, {BackgroundColor3 = targetColor}, 0.2)
            
            -- Immediately apply the setting change based on category and setting
            if category == "ESP" then
                if setting == "Enabled" then
                    -- Toggle ESP visibility for all players
                    if not Settings.ESP.Enabled then
                        for player, _ in pairs(Settings.ESP.Players) do
                            ESP.SetVisibility(player, false)
                        end
                    end
                elseif setting == "Boxes" or setting == "Names" or setting == "Distance" or 
                       setting == "Health" or setting == "Snaplines" or setting == "Rainbow" or
                       setting == "TeamCheck" then
                    -- Force update ESP
                    for _, player in ipairs(Players:GetPlayers()) do
                        if player ~= LocalPlayer then
                            ESP.Update(player)
                        end
                    end
                end
            elseif category == "Aimbot" then
                if setting == "Enabled" then
                    -- Toggle aimbot
                    FOVCircle.Visible = Settings.Aimbot.Enabled and Settings.Aimbot.ShowFOV
                elseif setting == "ShowFOV" then
                    -- Toggle FOV circle visibility
                    FOVCircle.Visible = Settings.Aimbot.Enabled and Settings.Aimbot.ShowFOV
                end
            elseif category == "Misc" then
                if setting == "NoClip" then
                    NoClipEnabled = Settings.Misc.NoClip
                    Notifications:Show("NoClip", "NoClip is now " .. (Settings.Misc.NoClip and "Enabled" or "Disabled"), 2)
                elseif setting == "FullBright" then
                    -- Apply FullBright immediately
                    ApplyFullBright()
                elseif setting == "AutoClick" then
                    -- Toggle AutoClick
                    SetupAutoClick()
                end
            end
        end)
        
        -- Hover effect
        ToggleFrame.MouseEnter:Connect(function()
            Utility.Tween(ToggleFrame, {BackgroundColor3 = Colors.Tertiary}, 0.2)
        end)
        
        ToggleFrame.MouseLeave:Connect(function()
            Utility.Tween(ToggleFrame, {BackgroundColor3 = Colors.Primary}, 0.2)
        end)
        
        return ToggleFrame
    end
    
    -- Function to create a slider
    local function CreateSlider(parent, text, category, setting, min, max, increment, order)
        local SliderFrame = Instance.new("Frame")
        SliderFrame.Name = text .. "Slider"
        SliderFrame.Size = UDim2.new(1, 0, 0, 60)
        SliderFrame.BackgroundColor3 = Colors.Primary
        SliderFrame.BorderSizePixel = 0
        SliderFrame.LayoutOrder = order
        SliderFrame.Parent = parent
        
        local UICorner = Instance.new("UICorner")
        UICorner.CornerRadius = UDim.new(0, 8)
        UICorner.Parent = SliderFrame
        
        local SliderLabel = Instance.new("TextLabel")
        SliderLabel.Name = "SliderLabel"
        SliderLabel.Size = UDim2.new(1, -100, 0, 20)
        SliderLabel.Position = UDim2.new(0, 10, 0, 5)
        SliderLabel.BackgroundTransparency = 1
        SliderLabel.Text = text
        SliderLabel.TextColor3 = Colors.Text
        SliderLabel.TextSize = 15
        SliderLabel.Font = Enum.Font.Gotham
        SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
        SliderLabel.Parent = SliderFrame
        
        local ValueLabel = Instance.new("TextLabel")
        ValueLabel.Name = "ValueLabel"
        ValueLabel.Size = UDim2.new(0, 80, 0, 20)
        ValueLabel.Position = UDim2.new(1, -90, 0, 5)
        ValueLabel.BackgroundTransparency = 1
        ValueLabel.Text = tostring(Settings[category][setting])
        ValueLabel.TextColor3 = Colors.Text
        ValueLabel.TextSize = 15
        ValueLabel.Font = Enum.Font.Gotham
        ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
        ValueLabel.Parent = SliderFrame
        
        local SliderBackground = Instance.new("Frame")
        SliderBackground.Name = "SliderBackground"
        SliderBackground.Size = UDim2.new(1, -20, 0, 6)
        SliderBackground.Position = UDim2.new(0, 10, 0, 35)
        SliderBackground.BackgroundColor3 = Colors.Tertiary
        SliderBackground.BorderSizePixel = 0
        SliderBackground.Parent = SliderFrame
        
        local SliderBackgroundCorner = Instance.new("UICorner")
        SliderBackgroundCorner.CornerRadius = UDim.new(1, 0)
        SliderBackgroundCorner.Parent = SliderBackground
        
        -- Calculate fill percentage based on current value
        local value = Settings[category][setting]
        local percentage = (value - min) / (max - min)
        
        local SliderFill = Instance.new("Frame")
        SliderFill.Name = "SliderFill"
        SliderFill.Size = UDim2.new(percentage, 0, 1, 0)
        SliderFill.BackgroundColor3 = Colors.Accent
        SliderFill.BorderSizePixel = 0
        SliderFill.Parent = SliderBackground
        
        local SliderFillCorner = Instance.new("UICorner")
        SliderFillCorner.CornerRadius = UDim.new(1, 0)
        SliderFillCorner.Parent = SliderFill
        
        local SliderButton = Instance.new("TextButton")
        SliderButton.Name = "SliderButton"
        SliderButton.Size = UDim2.new(0, 16, 0, 16)
        SliderButton.Position = UDim2.new(percentage, 0, 0.5, -8)
        SliderButton.BackgroundColor3 = Colors.Text
        SliderButton.BorderSizePixel = 0
        SliderButton.Text = ""
        SliderButton.ZIndex = 2
        SliderButton.Parent = SliderBackground
        
        local SliderButtonCorner = Instance.new("UICorner")
        SliderButtonCorner.CornerRadius = UDim.new(1, 0)
        SliderButtonCorner.Parent = SliderButton
        
        -- Slider functionality
        local isDragging = false
        
        SliderButton.MouseButton1Down:Connect(function()
            isDragging = true
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                isDragging = false
            end
        end)
        
        SliderBackground.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                isDragging = true
                
                -- Update on initial click
                local mousePos = UserInputService:GetMouseLocation()
                local framePos = SliderBackground.AbsolutePosition
                local frameSize = SliderBackground.AbsoluteSize
                
                local relativePos = math.clamp((mousePos.X - framePos.X) / frameSize.X, 0, 1)
                local newValue = min + (max - min) * relativePos
                
                -- Round to increment
                newValue = math.floor(newValue / increment + 0.5) * increment
                newValue = math.clamp(newValue, min, max)
                
                -- Update UI
                SliderFill.Size = UDim2.new(relativePos, 0, 1, 0)
                SliderButton.Position = UDim2.new(relativePos, 0, 0.5, -8)
                ValueLabel.Text = tostring(newValue)
                
                -- Update setting
                Settings[category][setting] = newValue
                
                -- Apply setting change immediately
                if category == "Aimbot" and setting == "FOV" then
                    FOVCircle.Radius = newValue
                elseif category == "Misc" and setting == "AutoClickRate" then
                    SetupAutoClick()
                end
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement and isDragging then
                local mousePos = UserInputService:GetMouseLocation()
                local framePos = SliderBackground.AbsolutePosition
                local frameSize = SliderBackground.AbsoluteSize
                
                local relativePos = math.clamp((mousePos.X - framePos.X) / frameSize.X, 0, 1)
                local newValue = min + (max - min) * relativePos
                
                -- Round to increment
                newValue = math.floor(newValue / increment + 0.5) * increment
                newValue = math.clamp(newValue, min, max)
                
                -- Update UI
                SliderFill.Size = UDim2.new(relativePos, 0, 1, 0)
                SliderButton.Position = UDim2.new(relativePos, 0, 0.5, -8)
                ValueLabel.Text = tostring(newValue)
                
                -- Update setting
                Settings[category][setting] = newValue
                
                -- Apply setting change immediately
                if category == "Aimbot" and setting == "FOV" then
                    FOVCircle.Radius = newValue
                elseif category == "Misc" and setting == "AutoClickRate" then
                    SetupAutoClick()
                end
            end
        end)
        
        -- Hover effect
        SliderFrame.MouseEnter:Connect(function()
            Utility.Tween(SliderFrame, {BackgroundColor3 = Colors.Tertiary}, 0.2)
        end)
        
        SliderFrame.MouseLeave:Connect(function()
            Utility.Tween(SliderFrame, {BackgroundColor3 = Colors.Primary}, 0.2)
        end)
        
        return SliderFrame
    end
    
    -- Function to create a dropdown
    local function CreateDropdown(parent, text, category, setting, options, order)
        local DropdownFrame = Instance.new("Frame")
        DropdownFrame.Name = text .. "Dropdown"
        DropdownFrame.Size = UDim2.new(1, 0, 0, 40)
        DropdownFrame.BackgroundColor3 = Colors.Primary
        DropdownFrame.BorderSizePixel = 0
        DropdownFrame.LayoutOrder = order
        DropdownFrame.Parent = parent
        
        local UICorner = Instance.new("UICorner")
        UICorner.CornerRadius = UDim.new(0, 8)
        UICorner.Parent = DropdownFrame
        
        local DropdownLabel = Instance.new("TextLabel")
        DropdownLabel.Name = "DropdownLabel"
        DropdownLabel.Size = UDim2.new(0.5, -10, 1, 0)
        DropdownLabel.Position = UDim2.new(0, 10, 0, 0)
        DropdownLabel.BackgroundTransparency = 1
        DropdownLabel.Text = text
        DropdownLabel.TextColor3 = Colors.Text
        DropdownLabel.TextSize = 15
        DropdownLabel.Font = Enum.Font.Gotham
        DropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
        DropdownLabel.Parent = DropdownFrame
        
        local SelectedOption = Instance.new("TextButton")
        SelectedOption.Name = "SelectedOption"
        SelectedOption.Size = UDim2.new(0.5, -20, 0, 30)
        SelectedOption.Position = UDim2.new(0.5, 10, 0.5, -15)
        SelectedOption.BackgroundColor3 = Colors.Tertiary
        SelectedOption.BorderSizePixel = 0
        SelectedOption.Text = Settings[category][setting]
        SelectedOption.TextColor3 = Colors.Text
        SelectedOption.TextSize = 14
        SelectedOption.Font = Enum.Font.Gotham
        SelectedOption.Parent = DropdownFrame
        
        local SelectedOptionCorner = Instance.new("UICorner")
        SelectedOptionCorner.CornerRadius = UDim.new(0, 6)
        SelectedOptionCorner.Parent = SelectedOption
        
        local OptionIcon = Instance.new("ImageLabel")
        OptionIcon.Name = "OptionIcon"
        OptionIcon.Size = UDim2.new(0, 16, 0, 16)
        OptionIcon.Position = UDim2.new(1, -20, 0.5, -8)
        OptionIcon.BackgroundTransparency = 1
        OptionIcon.Image = "rbxassetid://7734053466"
        OptionIcon.Rotation = 0
        OptionIcon.Parent = SelectedOption
        
        -- Create dropdown menu (hidden by default)
        local DropdownMenu = Instance.new("Frame")
        DropdownMenu.Name = "DropdownMenu"
        DropdownMenu.Size = UDim2.new(0.5, -20, 0, #options * 30)
        DropdownMenu.Position = UDim2.new(0.5, 10, 0, 40)
        DropdownMenu.BackgroundColor3 = Colors.Tertiary
        DropdownMenu.BorderSizePixel = 0
        DropdownMenu.Visible = false
        DropdownMenu.ZIndex = 10
        DropdownMenu.Parent = DropdownFrame
        
        local DropdownMenuCorner = Instance.new("UICorner")
        DropdownMenuCorner.CornerRadius = UDim.new(0, 6)
        DropdownMenuCorner.Parent = DropdownMenu
        
        -- Create options
        for i, option in ipairs(options) do
            local OptionButton = Instance.new("TextButton")
            OptionButton.Name = option .. "Option"
            OptionButton.Size = UDim2.new(1, 0, 0, 30)
            OptionButton.Position = UDim2.new(0, 0, 0, (i-1) * 30)
            OptionButton.BackgroundColor3 = Colors.Tertiary
            OptionButton.BackgroundTransparency = 0.5
            OptionButton.BorderSizePixel = 0
            OptionButton.Text = option
            OptionButton.TextColor3 = Colors.Text
            OptionButton.TextSize = 14
            OptionButton.Font = Enum.Font.Gotham
            OptionButton.ZIndex = 11
            OptionButton.Parent = DropdownMenu
            
            -- Option selection
            OptionButton.MouseButton1Click:Connect(function()
                Settings[category][setting] = option
                SelectedOption.Text = option
                DropdownMenu.Visible = false
                Utility.Tween(OptionIcon, {Rotation = 0}, 0.2)
                
                -- Apply setting immediately
                if category == "Aimbot" and setting == "TargetPart" then
                    -- TargetPart setting will take effect on next aimbot update
                end
            end)
            
            -- Hover effect
            OptionButton.MouseEnter:Connect(function()
                Utility.Tween(OptionButton, {BackgroundTransparency = 0.2}, 0.2)
            end)
            
            OptionButton.MouseLeave:Connect(function()
                Utility.Tween(OptionButton, {BackgroundTransparency = 0.5}, 0.2)
            end)
        end
        
        -- Toggle dropdown menu
        SelectedOption.MouseButton1Click:Connect(function()
            DropdownMenu.Visible = not DropdownMenu.Visible
            Utility.Tween(OptionIcon, {Rotation = DropdownMenu.Visible and 180 or 0}, 0.2)
        end)
        
        -- Close dropdown when clicking elsewhere
        UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                local mousePos = UserInputService:GetMouseLocation()
                if DropdownMenu.Visible then
                    local dropdownPos = DropdownMenu.AbsolutePosition
                    local dropdownSize = DropdownMenu.AbsoluteSize
                    local buttonPos = SelectedOption.AbsolutePosition
                    local buttonSize = SelectedOption.AbsoluteSize
                    
                    local inDropdown = mousePos.X >= dropdownPos.X and 
                                     mousePos.X <= dropdownPos.X + dropdownSize.X and 
                                     mousePos.Y >= dropdownPos.Y and 
                                     mousePos.Y <= dropdownPos.Y + dropdownSize.Y
                                     
                    local inButton = mousePos.X >= buttonPos.X and 
                                   mousePos.X <= buttonPos.X + buttonSize.X and 
                                   mousePos.Y >= buttonPos.Y and 
                                   mousePos.Y <= buttonPos.Y + buttonSize.Y
                    
                    if not inDropdown and not inButton then
                        DropdownMenu.Visible = false
                        Utility.Tween(OptionIcon, {Rotation = 0}, 0.2)
                    end
                end
            end
        end)
        
        -- Hover effect
        DropdownFrame.MouseEnter:Connect(function()
            Utility.Tween(DropdownFrame, {BackgroundColor3 = Colors.Tertiary}, 0.2)
        end)
        
        DropdownFrame.MouseLeave:Connect(function()
            Utility.Tween(DropdownFrame, {BackgroundColor3 = Colors.Primary}, 0.2)
        end)
        
        return DropdownFrame
    end
    
    -- Function to create a button
    local function CreateButton(parent, text, callback, order)
        local ButtonFrame = Instance.new("Frame")
        ButtonFrame.Name = text .. "Button"
        ButtonFrame.Size = UDim2.new(1, 0, 0, 40)
        ButtonFrame.BackgroundColor3 = Colors.Primary
        ButtonFrame.BorderSizePixel = 0
        ButtonFrame.LayoutOrder = order
        ButtonFrame.Parent = parent
        
        local UICorner = Instance.new("UICorner")
        UICorner.CornerRadius = UDim.new(0, 8)
        UICorner.Parent = ButtonFrame
        
        local Button = Instance.new("TextButton")
        Button.Name = "Button"
        Button.Size = UDim2.new(1, 0, 1, 0)
        Button.BackgroundTransparency = 1
        Button.Text = text
        Button.TextColor3 = Colors.Text
        Button.TextSize = 16
        Button.Font = Enum.Font.GothamBold
        Button.Parent = ButtonFrame
        
        -- Add hover and click effects
        ButtonFrame.MouseEnter:Connect(function()
            Utility.Tween(ButtonFrame, {BackgroundColor3 = Colors.Accent}, 0.2)
        end)
        
        ButtonFrame.MouseLeave:Connect(function()
            Utility.Tween(ButtonFrame, {BackgroundColor3 = Colors.Primary}, 0.2)
        end)
        
        Button.MouseButton1Down:Connect(function()
            Utility.Tween(ButtonFrame, {BackgroundColor3 = Colors.AccentDark}, 0.1)
        end)
        
        Button.MouseButton1Up:Connect(function()
            Utility.Tween(ButtonFrame, {BackgroundColor3 = Colors.Accent}, 0.1)
        end)
        
        Button.MouseButton1Click:Connect(callback)
        
        return ButtonFrame
    end
    
    -- Function to create a text box
    local function CreateTextBox(parent, text, placeholder, callback, order)
        local TextBoxFrame = Instance.new("Frame")
        TextBoxFrame.Name = text .. "TextBox"
        TextBoxFrame.Size = UDim2.new(1, 0, 0, 40)
        TextBoxFrame.BackgroundColor3 = Colors.Primary
        TextBoxFrame.BorderSizePixel = 0
        TextBoxFrame.LayoutOrder = order
        TextBoxFrame.Parent = parent
        
        local UICorner = Instance.new("UICorner")
        UICorner.CornerRadius = UDim.new(0, 8)
        UICorner.Parent = TextBoxFrame
        
        local TextLabel = Instance.new("TextLabel")
        TextLabel.Name = "TextLabel"
        TextLabel.Size = UDim2.new(0.4, -10, 1, 0)
        TextLabel.Position = UDim2.new(0, 10, 0, 0)
        TextLabel.BackgroundTransparency = 1
        TextLabel.Text = text
        TextLabel.TextColor3 = Colors.Text
        TextLabel.TextSize = 15
        TextLabel.Font = Enum.Font.Gotham
        TextLabel.TextXAlignment = Enum.TextXAlignment.Left
        TextLabel.Parent = TextBoxFrame
        
        local TextBoxContainer = Instance.new("Frame")
        TextBoxContainer.Name = "TextBoxContainer"
        TextBoxContainer.Size = UDim2.new(0.6, -20, 0, 30)
        TextBoxContainer.Position = UDim2.new(0.4, 10, 0.5, -15)
        TextBoxContainer.BackgroundColor3 = Colors.Tertiary
        TextBoxContainer.BorderSizePixel = 0
        TextBoxContainer.Parent = TextBoxFrame
        
        local TextBoxContainerCorner = Instance.new("UICorner")
        TextBoxContainerCorner.CornerRadius = UDim.new(0, 6)
        TextBoxContainerCorner.Parent = TextBoxContainer
        
        local TextBox = Instance.new("TextBox")
        TextBox.Name = "TextBox"
        TextBox.Size = UDim2.new(1, -10, 1, 0)
        TextBox.Position = UDim2.new(0, 5, 0, 0)
        TextBox.BackgroundTransparency = 1
        TextBox.Text = ""
        TextBox.PlaceholderText = placeholder
        TextBox.TextColor3 = Colors.Text
        TextBox.PlaceholderColor3 = Colors.TextDark
        TextBox.TextSize = 14
        TextBox.Font = Enum.Font.Gotham
        TextBox.TextXAlignment = Enum.TextXAlignment.Left
        TextBox.ClearTextOnFocus = false
        TextBox.Parent = TextBoxContainer
        
        -- Focus effects
        TextBox.Focused:Connect(function()
            Utility.Tween(TextBoxContainer, {BackgroundColor3 = Colors.Accent}, 0.2)
        end)
        
        TextBox.FocusLost:Connect(function(enterPressed)
            Utility.Tween(TextBoxContainer, {BackgroundColor3 = Colors.Tertiary}, 0.2)
            if enterPressed and callback then
                callback(TextBox.Text)
            end
        end)
        
        -- Hover effect
        TextBoxFrame.MouseEnter:Connect(function()
            Utility.Tween(TextBoxFrame, {BackgroundColor3 = Colors.Tertiary}, 0.2)
        end)
        
        TextBoxFrame.MouseLeave:Connect(function()
            Utility.Tween(TextBoxFrame, {BackgroundColor3 = Colors.Primary}, 0.2)
        end)
        
        return TextBoxFrame, TextBox
    end
    
    -- Populate Aimbot Page
    local order = 0
    
    CreateSectionTitle(Pages.Aimbot, "General Settings", order)
    order = order + 10
    
    CreateToggle(Pages.Aimbot, "Enabled", "Aimbot", "Enabled", order)
    order = order + 10
    
    CreateToggle(Pages.Aimbot, "Team Check", "Aimbot", "TeamCheck", order)
    order = order + 10
    
    CreateToggle(Pages.Aimbot, "Show FOV", "Aimbot", "ShowFOV", order)
    order = order + 10
    
    CreateToggle(Pages.Aimbot, "Silent Aim", "Aimbot", "SilentAim", order)
    order = order + 10
    
    CreateSlider(Pages.Aimbot, "FOV Radius", "Aimbot", "FOV", 10, 500, 10, order)
    order = order + 10
    
    CreateSectionTitle(Pages.Aimbot, "Targeting Settings", order)
    order = order + 10
    
    CreateDropdown(Pages.Aimbot, "Target Part", "Aimbot", "TargetPart", {"Head", "HumanoidRootPart", "Torso", "UpperTorso", "LowerTorso"}, order)
    order = order + 10
    
    CreateSlider(Pages.Aimbot, "Max Distance", "Aimbot", "MaxDistance", 50, 1000, 50, order)
    order = order + 10
    
    CreateSectionTitle(Pages.Aimbot, "Prediction Settings", order)
    order = order + 10
    
    CreateToggle(Pages.Aimbot, "Auto Prediction", "Aimbot", "AutoPrediction", order)
    order = order + 10
    
    CreateSlider(Pages.Aimbot, "Prediction Multiplier", "Aimbot", "PredictionMultiplier", 0.1, 5, 0.1, order)
    order = order + 10
    
    CreateSlider(Pages.Aimbot, "Hit Chance", "Aimbot", "HitChance", 0, 100, 5, order)
    order = order + 10
    
    -- Populate ESP Page
    order = 0
    
    CreateSectionTitle(Pages.ESP, "General Settings", order)
    order = order + 10
    
    CreateToggle(Pages.ESP, "Enabled", "ESP", "Enabled", order)
    order = order + 10
    
    CreateToggle(Pages.ESP, "Team Check", "ESP", "TeamCheck", order)
    order = order + 10
    
    CreateToggle(Pages.ESP, "Rainbow Colors", "ESP", "Rainbow", order)
    order = order + 10
    
    CreateSlider(Pages.ESP, "Max Distance", "ESP", "MaxDistance", 100, 2000, 100, order)
    order = order + 10
    
    CreateSectionTitle(Pages.ESP, "Visual Elements", order)
    order = order + 10
    
    CreateToggle(Pages.ESP, "Boxes", "ESP", "Boxes", order)
    order = order + 10
    
    CreateToggle(Pages.ESP, "Names", "ESP", "Names", order)
    order = order + 10
    
    CreateToggle(Pages.ESP, "Distance", "ESP", "Distance", order)
    order = order + 10
    
    CreateToggle(Pages.ESP, "Health", "ESP", "Health", order)
    order = order + 10
    
    CreateToggle(Pages.ESP, "Snaplines", "ESP", "Snaplines", order)
    order = order + 10
    
    -- Populate Misc Page
    order = 0
    
    CreateSectionTitle(Pages.Misc, "Movement", order)
    order = order + 10
    
    CreateToggle(Pages.Misc, "No Clip", "Misc", "NoClip", order)
    order = order + 10
    
    CreateToggle(Pages.Misc, "Free Cam", "Misc", "FreeCam", order)
    order = order + 10
    
    CreateSectionTitle(Pages.Misc, "Visuals", order)
    order = order + 10
    
    CreateToggle(Pages.Misc, "Full Bright", "Misc", "FullBright", order)
    order = order + 10
    
    CreateSectionTitle(Pages.Misc, "Tools", order)
    order = order + 10
    
    CreateToggle(Pages.Misc, "Auto Click", "Misc", "AutoClick", order)
    order = order + 10
    
    CreateSlider(Pages.Misc, "Click Rate", "Misc", "AutoClickRate", 0.01, 0.5, 0.01, order)
    order = order + 10
    
    -- Populate Config Page
    order = 0
    
    CreateSectionTitle(Pages.Config, "Configuration Manager", order)
    order = order + 10
    
    -- Create config name input
    local ConfigNameBox, ConfigNameInput = CreateTextBox(Pages.Config, "Config Name", "Enter config name...", nil, order)
    order = order + 10
    
    -- Create config buttons
    local SaveConfigButton = CreateButton(Pages.Config, "Save Config", function()
        if ConfigNameInput.Text ~= "" then
            Config:SaveConfig(ConfigNameInput.Text)
        else
            Notifications:Show("Config Error", "Please enter a config name", 3, "Error")
        end
    end, order)
    order = order + 10
    
    local LoadConfigButton = CreateButton(Pages.Config, "Load Selected Config", function()
        Config:LoadConfig(Settings.Config.CurrentConfig)
    end, order)
    order = order + 10
    
    local DeleteConfigButton = CreateButton(Pages.Config, "Delete Selected Config", function()
        Config:DeleteConfig(Settings.Config.CurrentConfig)
    end, order)
    order = order + 10
    
    -- Create config list dropdown
    Config:Initialize() -- Initialize default config
    local configNames = Config:GetConfigNames()
    local ConfigListDropdown = CreateDropdown(Pages.Config, "Active Config", "Config", "CurrentConfig", configNames, order)
    order = order + 10
    
    CreateSectionTitle(Pages.Config, "Auto Save Configuration", order)
    order = order + 10
    
    CreateToggle(Pages.Config, "Auto Save", "Config", "SaveEnabled", order)
    order = order + 10
    
    -- Setup Dragging Functionality
    local dragging, dragInput, dragStart, startPos
    
    local function updateDrag(input)
        local delta = input.Position - dragStart
        local targetPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, 
                                  startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        Utility.Tween(MainFrame, {Position = targetPos}, 0.1)
    end
    
    Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    Header.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            updateDrag(input)
        end
    end)
    
    -- Initialize with animation
    MainFrame.Position = UDim2.new(0.5, -200, 1.2, 0)
    ScreenGui.Enabled = true
    
    task.spawn(function()
        wait(0.1) -- Short delay
        Utility.Tween(MainFrame, {
            Position = UDim2.new(0.5, -200, 0.5, -250)
        }, 0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    end)
    
    return ScreenGui
end

-- Initialization
local function Initialize()
    -- Initialize Config
    Config:Initialize()
    
    -- Create welcome notifications
    Notifications:Show("Rivals Enhanced v3.5", "Loading Ultra Edition...", 2)
    
    -- Initialize UI
    CreateUI()
    
    -- Initialize ESP for existing players
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            ESP.InitializePlayer(player)
        end
    end
    
    -- Player Events
    Players.PlayerAdded:Connect(function(player)
        if player ~= LocalPlayer then
            ESP.InitializePlayer(player)
        end
    end)
    
    Players.PlayerRemoving:Connect(function(player)
        ESP.CleanupPlayer(player)
    end)
    
    -- Input Events
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            IsLeftMouseDown = true
        elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
            IsRightMouseDown = true
        elseif input.KeyCode == Enum.KeyCode.Insert then
            GuiVisible = not GuiVisible
            for _, gui in pairs(CoreGui:GetChildren()) do
                if gui.Name == "RivalsEnhancedGUI" then
                    if GuiVisible then
                        gui.Enabled = true
                        for _, frame in pairs(gui:GetDescendants()) do
                            if frame.Name == "MainFrame" then
                                Utility.Tween(frame, {
                                    Position = UDim2.new(0.5, -200, 0.5, -250)
                                }, 0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
                            end
                        end
                    else
                        for _, frame in pairs(gui:GetDescendants()) do
                            if frame.Name == "MainFrame" then
                                Utility.Tween(frame, {
                                    Position = UDim2.new(0.5, -200, 1.2, 0)
                                }, 0.6, Enum.EasingStyle.Back, Enum.EasingDirection.In).Completed:Connect(function()
                                    if not GuiVisible then
                                        gui.Enabled = false
                                    end
                                end)
                            end
                        end
                    end
                end
            end
        elseif input.KeyCode == Enum.KeyCode.End then
            Cleanup()
        elseif input.KeyCode == Enum.KeyCode.P then
            Settings.Misc.NoClip = not Settings.Misc.NoClip
            NoClipEnabled = Settings.Misc.NoClip
            Notifications:Show("NoClip", "NoClip is now " .. (Settings.Misc.NoClip and "Enabled" or "Disabled"), 2)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            IsLeftMouseDown = false
        elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
            IsRightMouseDown = false
            TargetPlayer = nil
        end
    end)
    
    -- Update loop
    local renderConnection = RunService.RenderStepped:Connect(function()
        FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        
        ESP.UpdateAll()
        Aimbot.Update()
        UpdateNoClip()
    end)
    
    table.insert(RunningConnections, renderConnection)
    
    -- Show welcome notification
    wait(1) -- Short delay to ensure UI is visible
    Notifications:Show("Rivals Enhanced v3.5", "Ultra Edition loaded successfully!", 2)
    Notifications:Show("Controls", "INSERT: Toggle UI | END: Close | P: Toggle NoClip", 3)
    
    return true
end

-- Cleanup function
local function Cleanup()
    for _, connection in ipairs(RunningConnections) do
        if connection then
            connection:Disconnect()
        end
    end
    
    -- Cleanup ESP
    for player, _ in pairs(Settings.ESP.Players) do
        ESP.CleanupPlayer(player)
    end
    
    -- Remove FOV circle
    if FOVCircle then
        FOVCircle:Remove()
    end
    
    -- Cleanup AutoClick
    if AutoClickConnection then
        AutoClickConnection:Disconnect()
        AutoClickConnection = nil
    end
    
    -- Restore lighting settings
    Lighting.Brightness = OriginalLighting.Brightness
    Lighting.ClockTime = OriginalLighting.ClockTime
    Lighting.FogEnd = OriginalLighting.FogEnd
    Lighting.GlobalShadows = OriginalLighting.GlobalShadows
    Lighting.Ambient = OriginalLighting.Ambient
    
    -- Cleanup GUI
    for _, gui in pairs(CoreGui:GetChildren()) do
        if gui.Name == "RivalsEnhancedGUI" then
            gui:Destroy()
        end
    end
    
    -- Show exit notification
    Notifications:Show("Rivals Enhanced", "Safely unloaded", 2)
end

-- Start the script
Initialize()
