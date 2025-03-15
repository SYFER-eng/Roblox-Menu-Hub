-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

-- Epic animated notification sequence
spawn(function()
    local function createNotification(title, text, duration)
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = duration,
            Icon = "rbxassetid://13647654264"
        })
        wait(duration)
    end
    createNotification("Syfer-eng's Rival Enhanced", "Features Loaded!", 2)
    createNotification("💫 Ready!", "Press INSERT to toggle UI", 3)
end)

-- Variables
local localPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera
local targetPlayer = nil
local isLeftMouseDown = false 
local isRightMouseDown = false
local autoClickConnection = nil
local noClipEnabled = false

-- Settings
local AimSettings = {
    SilentAim = false,
    HitChance = 100,
    TargetPart = "Head"
}

local Toggles = {
    ESP = false,
    Aimbot = false,
    Boxes = false,
    Names = false,
    Distance = false,
    Snaplines = false,
    Health = false
}

local Settings = {
    ESP = {
        Enabled = false,
        Boxes = false,
        Names = false,
        Distance = false,
        Health = false,
        Snaplines = false,
        TeamCheck = false,
        Rainbow = false,
        BoxColor = Color3.fromRGB(255, 0, 255),
        Players = {},
        MaxDistance = 1000,
        HealthBarSize = Vector2.new(2, 20)
    },
    Aimbot = {
        Enabled = false,
        TeamCheck = false,
        Smoothness = 0.2,
        FOV = 150,
        TargetPart = "Head",
        ShowFOV = false,
        PredictionMultiplier = 1.5,
        AutoPrediction = false,
        TriggerBot = false,
        TriggerDelay = 0.1,
        MaxDistance = 250
    },
    Misc = {
        NoClip = false
    }
}

-- Define toggle keys for quick access
local toggleKeys = {
    [Enum.KeyCode.F1] = function()
        -- Toggle Aimbot
        local toggle = AimbotPage:FindFirstChild("EnabledToggle")
        if toggle then
            toggle.Button.MouseButton1Click:Fire()
        end
    end,
    [Enum.KeyCode.F2] = function()
        -- Toggle ESP
        local toggle = ESPPage:FindFirstChild("EnabledToggle")
        if toggle then
            toggle.Button.MouseButton1Click:Fire()
        end
    end,
    [Enum.KeyCode.F3] = function()
        -- Toggle NoClip
        Settings.Misc.NoClip = not Settings.Misc.NoClip
        noClipEnabled = Settings.Misc.NoClip
        createNotification("NoClip", "NoClip is now " .. (noClipEnabled and "Enabled" or "Disabled"), 2)
    end
}

-- Create Enhanced UI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RivalsEnhancedGUI"
ScreenGui.Parent = CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 500, 0, 400) -- Wider UI
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -200) -- Adjusted position for wider UI
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

-- Add UI Enhancement Elements
local UIGradient = Instance.new("UIGradient")
UIGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 30)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 20))
})
UIGradient.Rotation = 45
UIGradient.Parent = MainFrame

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10) -- Slightly larger corner radius
UICorner.Parent = MainFrame

local DropShadow = Instance.new("ImageLabel")
DropShadow.Name = "DropShadow"
DropShadow.BackgroundTransparency = 1
DropShadow.Position = UDim2.new(0, -15, 0, -15)
DropShadow.Size = UDim2.new(1, 30, 1, 30)
DropShadow.Image = "rbxassetid://6014261993"
DropShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
DropShadow.ImageTransparency = 0.5
DropShadow.Parent = MainFrame

-- Create Title Bar with accent color
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 40) -- Taller title bar
TitleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleAccent = Instance.new("Frame")
TitleAccent.Name = "TitleAccent"
TitleAccent.Size = UDim2.new(1, 0, 0, 2)
TitleAccent.Position = UDim2.new(0, 0, 1, -2)
TitleAccent.BackgroundColor3 = Color3.fromRGB(255, 0, 255) -- Accent color
TitleAccent.BorderSizePixel = 0
TitleAccent.Parent = TitleBar

local TitleText = Instance.new("TextLabel")
TitleText.Name = "Title"
TitleText.Size = UDim2.new(1, 0, 1, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "Rivals Enhanced"
TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleText.TextSize = 18 -- Larger text
TitleText.Font = Enum.Font.GothamBold
TitleText.Parent = TitleBar

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = TitleBar

-- Create Tab System
local TabButtons = Instance.new("Frame")
TabButtons.Name = "TabButtons"
TabButtons.Size = UDim2.new(0.3, 0, 1, -50) -- Left sidebar for tabs
TabButtons.Position = UDim2.new(0, 10, 0, 50)
TabButtons.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
TabButtons.BorderSizePixel = 0
TabButtons.Parent = MainFrame

local TabButtonsCorner = Instance.new("UICorner")
TabButtonsCorner.CornerRadius = UDim.new(0, 8)
TabButtonsCorner.Parent = TabButtons

local TabContainer = Instance.new("Frame")
TabContainer.Name = "TabContainer"
TabContainer.Size = UDim2.new(0.67, 0, 1, -60) -- Content area
TabContainer.Position = UDim2.new(0.32, 0, 0, 50)
TabContainer.BackgroundTransparency = 1
TabContainer.Parent = MainFrame

-- Create Tabs
local AimbotTab = Instance.new("TextButton")
local ESPTab = Instance.new("TextButton")
local MiscTab = Instance.new("TextButton") -- Added Misc tab

-- Enhanced Dragging Functionality
local dragging, dragInput, dragStart, startPos

local function updateDrag(input)
    local delta = input.Position - dragStart
    local targetPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    
    local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    TweenService:Create(MainFrame, tweenInfo, {Position = targetPos}):Play()
end

-- Setup Tab Buttons with improved styling
local function CreateTabButton(name, position)
    local tab = Instance.new("TextButton")
    tab.Name = name.."Tab"
    tab.Size = UDim2.new(0.9, 0, 0, 40)
    tab.Position = position
    tab.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    tab.Text = name
    tab.TextColor3 = Color3.fromRGB(255, 255, 255)
    tab.Font = Enum.Font.GothamBold
    tab.TextSize = 16
    tab.Parent = TabButtons
    tab.AutoButtonColor = false
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = tab
    
    local accent = Instance.new("Frame")
    accent.Name = "Accent"
    accent.Size = UDim2.new(0, 4, 1, -10)
    accent.Position = UDim2.new(0, 0, 0, 5)
    accent.BackgroundColor3 = Color3.fromRGB(255, 0, 255)
    accent.BorderSizePixel = 0
    accent.Visible = false
    accent.Parent = tab
    
    local accentCorner = Instance.new("UICorner")
    accentCorner.CornerRadius = UDim.new(0, 2)
    accentCorner.Parent = accent
    
    return tab
end

AimbotTab = CreateTabButton("Aimbot", UDim2.new(0.05, 0, 0, 10))
ESPTab = CreateTabButton("ESP", UDim2.new(0.05, 0, 0, 60))
MiscTab = CreateTabButton("Misc", UDim2.new(0.05, 0, 0, 110))

-- Create Pages with improved styling
local AimbotPage = Instance.new("ScrollingFrame")
AimbotPage.Name = "AimbotPage"
AimbotPage.Size = UDim2.new(1, -20, 1, -20)
AimbotPage.Position = UDim2.new(0, 10, 0, 10)
AimbotPage.BackgroundTransparency = 1
AimbotPage.ScrollBarThickness = 4
AimbotPage.ScrollBarImageColor3 = Color3.fromRGB(255, 0, 255)
AimbotPage.Visible = true
AimbotPage.Parent = TabContainer
AimbotPage.CanvasSize = UDim2.new(0, 0, 0, 0) -- Will be updated dynamically

local ESPPage = Instance.new("ScrollingFrame")
ESPPage.Name = "ESPPage"
ESPPage.Size = UDim2.new(1, -20, 1, -20)
ESPPage.Position = UDim2.new(0, 10, 0, 10)
ESPPage.BackgroundTransparency = 1
ESPPage.ScrollBarThickness = 4
ESPPage.ScrollBarImageColor3 = Color3.fromRGB(255, 0, 255)
ESPPage.Visible = false
ESPPage.Parent = TabContainer
ESPPage.CanvasSize = UDim2.new(0, 0, 0, 0) -- Will be updated dynamically

local MiscPage = Instance.new("ScrollingFrame")
MiscPage.Name = "MiscPage"
MiscPage.Size = UDim2.new(1, -20, 1, -20)
MiscPage.Position = UDim2.new(0, 10, 0, 10)
MiscPage.BackgroundTransparency = 1
MiscPage.ScrollBarThickness = 4
MiscPage.ScrollBarImageColor3 = Color3.fromRGB(255, 0, 255)
MiscPage.Visible = false
MiscPage.Parent = TabContainer
MiscPage.CanvasSize = UDim2.new(0, 0, 0, 0) -- Will be updated dynamically

-- Create Enhanced Toggle Button Function with modern design
local function CreateToggle(parent, name, category, setting)
    local ToggleFrame = Instance.new("Frame")
    local ToggleButton = Instance.new("TextButton")
    local ToggleStatus = Instance.new("Frame")
    local ToggleInner = Instance.new("Frame")
    
    ToggleFrame.Name = name .. "Toggle"
    ToggleFrame.Size = UDim2.new(0.95, 0, 0, 50) -- Taller toggle
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    ToggleFrame.Parent = parent
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 8)
    UICorner.Parent = ToggleFrame
    
    ToggleButton.Name = "Button"
    ToggleButton.Size = UDim2.new(1, 0, 1, 0)
    ToggleButton.BackgroundTransparency = 1
    ToggleButton.Text = ""
    ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleButton.TextSize = 16
    ToggleButton.Font = Enum.Font.GothamBold
    ToggleButton.Parent = ToggleFrame
    
    local ToggleLabel = Instance.new("TextLabel")
    ToggleLabel.Name = "Label"
    ToggleLabel.Size = UDim2.new(0.7, 0, 1, 0)
    ToggleLabel.Position = UDim2.new(0.05, 0, 0, 0)
    ToggleLabel.BackgroundTransparency = 1
    ToggleLabel.Text = name
    ToggleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleLabel.TextSize = 16
    ToggleLabel.Font = Enum.Font.GothamSemibold
    ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
    ToggleLabel.Parent = ToggleFrame
    
    ToggleStatus.Name = "Status"
    ToggleStatus.Size = UDim2.new(0, 50, 0, 24)
    ToggleStatus.Position = UDim2.new(0.9, -25, 0.5, -12)
    ToggleStatus.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    ToggleStatus.Parent = ToggleFrame
    
    local StatusCorner = Instance.new("UICorner")
    StatusCorner.CornerRadius = UDim.new(1, 0)
    StatusCorner.Parent = ToggleStatus
    
    -- Initialize all toggles as OFF (red)
    Settings[category][setting] = false
    Toggles[name] = false
    
    ToggleInner.Name = "Inner"
    ToggleInner.Size = UDim2.new(0, 20, 0, 20)
    ToggleInner.Position = UDim2.new(0, 2, 0.5, -10) -- Left position (OFF)
    ToggleInner.BackgroundColor3 = Color3.fromRGB(255, 50, 50) -- Red color (OFF)
    ToggleInner.Parent = ToggleStatus
    
    local InnerCorner = Instance.new("UICorner")
    InnerCorner.CornerRadius = UDim.new(1, 0)
    InnerCorner.Parent = ToggleInner
    
    -- Add hover effect
    local hovering = false
    
    ToggleButton.MouseEnter:Connect(function()
        hovering = true
        TweenService:Create(ToggleFrame, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(45, 45, 45)}):Play()
    end)
    
    ToggleButton.MouseLeave:Connect(function()
        hovering = false
        TweenService:Create(ToggleFrame, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(35, 35, 35)}):Play()
    end)
    
    ToggleButton.MouseButton1Click:Connect(function()
        Settings[category][setting] = not Settings[category][setting]
        Toggles[name] = Settings[category][setting]
        
        -- This is the key part - update the actual functionality when toggle changes
        if category == "ESP" then
            if setting == "Enabled" then
                Settings.ESP.Enabled = Toggles[name]
                Toggles.ESP = Toggles[name]
            elseif setting == "Boxes" then
                Settings.ESP.Boxes = Toggles[name]
                Toggles.Boxes = Toggles[name]
            elseif setting == "Names" then
                Settings.ESP.Names = Toggles[name]
                Toggles.Names = Toggles[name]
            elseif setting == "Distance" then
                Settings.ESP.Distance = Toggles[name]
                Toggles.Distance = Toggles[name]
            elseif setting == "Snaplines" then
                Settings.ESP.Snaplines = Toggles[name]
                Toggles.Snaplines = Toggles[name]
            elseif setting == "Health" then
                Settings.ESP.Health = Toggles[name]
                Toggles.Health = Toggles[name]
            end
        elseif category == "Aimbot" then
            if setting == "Enabled" then
                Settings.Aimbot.Enabled = Toggles[name]
                Toggles.Aimbot = Toggles[name]
            elseif setting == "ShowFOV" then
                Settings.Aimbot.ShowFOV = Toggles[name]
                FOVCircle.Visible = Toggles[name]
            end
        elseif category == "Misc" then
            if setting == "NoClip" then
                Settings.Misc.NoClip = Toggles[name]
                noClipEnabled = Toggles[name]
            end
        end
        
        -- Provide feedback with notification for important toggles
        if setting == "Enabled" or setting == "NoClip" then
            createNotification(name, name .. " is now " .. (Toggles[name] and "Enabled" or "Disabled"), 1)
        end
        
        local targetPosition = Settings[category][setting] and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)
        local targetColor = Settings[category][setting] and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 50, 50)
        
        TweenService:Create(ToggleInner, TweenInfo.new(0.2), {
            Position = targetPosition,
            BackgroundColor3 = targetColor
        }):Play()
    end)
    
    return ToggleFrame
end

-- Create FOV Circle with enhanced visuals
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2
FOVCircle.NumSides = 90
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
    
    local distanceFromCenter = (targetVector - screenCenter).Magnitude
    
    if distanceFromCenter > 5 then
        mousemoverel(targetPosition.X - screenCenter.X, targetPosition.Y - screenCenter.Y)
    end
end

-- Enhanced ESP Function
local function CreateESP(player)
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
    esp.Box.Transparency = 1
    
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

-- Enhanced Get Closest Player Function
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

-- Enhanced Update ESP Function
local function UpdateESP()
    -- Only run if ESP is enabled
    if not Settings.ESP.Enabled then
        -- Hide all ESP elements when disabled
        for _, esp in pairs(Settings.ESP.Players) do
            for _, drawing in pairs(esp) do
                drawing.Visible = false
            end
        end
        return
    end
    
    for player, esp in pairs(Settings.ESP.Players) do
        if player.Character and player ~= localPlayer then
            local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
            local humanoid = player.Character:FindFirstChild("Humanoid")
            local head = player.Character:FindFirstChild("Head")
            
            if humanoidRootPart and humanoid and head then
                local pos, onScreen = camera:WorldToViewportPoint(humanoidRootPart.Position)
                local headPos = camera:WorldToViewportPoint(head.Position)
                local distance = (humanoidRootPart.Position - camera.CFrame.Position).Magnitude
                
                -- Team check logic
                local passedTeamCheck = true
                if Settings.ESP.TeamCheck then
                    passedTeamCheck = player.Team ~= localPlayer.Team
                end
                
                if onScreen and distance <= Settings.ESP.MaxDistance and passedTeamCheck then
                    -- Dynamic ESP Size based on distance
                    local scaleFactor = 1 / (distance * 0.05)
                    local size = (camera:WorldToViewportPoint(humanoidRootPart.Position + Vector3.new(2, 3, 0)).Y - camera:WorldToViewportPoint(humanoidRootPart.Position + Vector3.new(-2, -3, 0)).Y) / 2
                    
                    -- Box ESP
                    esp.Box.Size = Vector2.new(size * 1.5, size * 3)
                    esp.Box.Position = Vector2.new(pos.X - esp.Box.Size.X / 2, pos.Y - esp.Box.Size.Y / 2)
                    esp.Box.Color = Settings.ESP.Rainbow and Color3.fromHSV(tick() % 5 / 5, 1, 1) or Settings.ESP.BoxColor
                    esp.Box.Visible = Settings.ESP.Boxes
                    
                    -- Health Bar
                    local healthBarHeight = esp.Box.Size.Y * (humanoid.Health / humanoid.MaxHealth)
                    esp.HealthBarBackground.Size = Vector2.new(Settings.ESP.HealthBarSize.X, esp.Box.Size.Y)
                    esp.HealthBarBackground.Position = Vector2.new(esp.Box.Position.X - esp.HealthBarBackground.Size.X * 2, esp.Box.Position.Y)
                    esp.HealthBarBackground.Visible = Settings.ESP.Health
                    
                    esp.HealthBar.Size = Vector2.new(Settings.ESP.HealthBarSize.X, healthBarHeight)
                    esp.HealthBar.Position = Vector2.new(esp.Box.Position.X - esp.HealthBar.Size.X * 2, esp.Box.Position.Y + esp.Box.Size.Y - healthBarHeight)
                    esp.HealthBar.Color = Color3.fromRGB(255 - (255 * (humanoid.Health / humanoid.MaxHealth)), 255 * (humanoid.Health / humanoid.MaxHealth), 0)
                    esp.HealthBar.Visible = Settings.ESP.Health
                    
                    -- Name ESP
                    esp.Name.Position = Vector2.new(pos.X, esp.Box.Position.Y - 20)
                    esp.Name.Text = string.format("%s", player.Name)
                    esp.Name.Size = math.clamp(16 * scaleFactor, 12, 16)
                    esp.Name.Visible = Settings.ESP.Names
                    
                    -- Distance ESP
                    esp.Distance.Position = Vector2.new(pos.X, esp.Box.Position.Y + esp.Box.Size.Y + 10)
                    esp.Distance.Text = string.format("[%d studs]", distance)
                    esp.Distance.Size = math.clamp(14 * scaleFactor, 10, 14)
                    esp.Distance.Visible = Settings.ESP.Distance
                    
                    -- Snapline ESP
                    esp.Snapline.From = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)
                    esp.Snapline.To = Vector2.new(pos.X, pos.Y)
                    esp.Snapline.Color = esp.Box.Color
                    esp.Snapline.Visible = Settings.ESP.Snaplines
                    
                    -- Head Dot ESP
                    esp.HeadDot.Position = Vector2.new(headPos.X, headPos.Y)
                    esp.HeadDot.Color = esp.Box.Color
                    esp.HeadDot.Visible = Settings.ESP.Boxes
                else
                    -- Hide ESP when not on screen
                    for _, drawing in pairs(esp) do
                        drawing.Visible = false
                    end
                end
            end
        end
    end
end

-- Create Slider Function with enhanced visuals
local function CreateSlider(parent, name, category, setting, min, max, default)
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Name = name .. "Slider"
    SliderFrame.Size = UDim2.new(0.95, 0, 0, 60)
    SliderFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    SliderFrame.Parent = parent
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 8)
    UICorner.Parent = SliderFrame
    
    local SliderLabel = Instance.new("TextLabel")
    SliderLabel.Name = "Label"
    SliderLabel.Size = UDim2.new(1, 0, 0, 25)
    SliderLabel.Position = UDim2.new(0, 0, 0, 5)
    SliderLabel.BackgroundTransparency = 1
    SliderLabel.Text = name
    SliderLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    SliderLabel.TextSize = 16
    SliderLabel.Font = Enum.Font.GothamSemibold
    SliderLabel.Parent = SliderFrame
    
    local SliderValue = Instance.new("TextLabel")
    SliderValue.Name = "Value"
    SliderValue.Size = UDim2.new(0, 50, 0, 25)
    SliderValue.Position = UDim2.new(1, -60, 0, 5)
    SliderValue.BackgroundTransparency = 1
    SliderValue.Text = tostring(default)
    SliderValue.TextColor3 = Color3.fromRGB(255, 255, 255)
    SliderValue.TextSize = 16
    SliderValue.Font = Enum.Font.GothamSemibold
    SliderValue.Parent = SliderFrame
    
    local SliderBG = Instance.new("Frame")
    SliderBG.Name = "Background"
    SliderBG.Size = UDim2.new(0.9, 0, 0, 6)
    SliderBG.Position = UDim2.new(0.05, 0, 0.7, 0)
    SliderBG.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    SliderBG.BorderSizePixel = 0
    SliderBG.Parent = SliderFrame
    
    local SliderBGCorner = Instance.new("UICorner")
    SliderBGCorner.CornerRadius = UDim.new(0, 3)
    SliderBGCorner.Parent = SliderBG
    
    local SliderFill = Instance.new("Frame")
    SliderFill.Name = "Fill"
    SliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    SliderFill.BackgroundColor3 = Color3.fromRGB(255, 0, 255)
    SliderFill.BorderSizePixel = 0
    SliderFill.Parent = SliderBG
    
    local SliderFillCorner = Instance.new("UICorner")
    SliderFillCorner.CornerRadius = UDim.new(0, 3)
    SliderFillCorner.Parent = SliderFill
    
    local SliderButton = Instance.new("TextButton")
    SliderButton.Name = "Button"
    SliderButton.Size = UDim2.new(1, 0, 1, 0)
    SliderButton.BackgroundTransparency = 1
    SliderButton.Text = ""
    SliderButton.Parent = SliderBG
    
    -- Initialize the slider value
    Settings[category][setting] = default
    
    -- Update slider function
    local function updateSlider(input)
        local sizeX = math.clamp((input.Position.X - SliderBG.AbsolutePosition.X) / SliderBG.AbsoluteSize.X, 0, 1)
        SliderFill.Size = UDim2.new(sizeX, 0, 1, 0)
        
        local value = math.floor(min + ((max - min) * sizeX))
        SliderValue.Text = tostring(value)
        Settings[category][setting] = value
        
        -- Update FOV Circle if this is the FOV slider
        if setting == "FOV" then
            FOVCircle.Radius = value
        end
    end
    
    -- Slider interaction
    local dragging = false
    
    SliderButton.MouseButton1Down:Connect(function()
        dragging = true
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateSlider(input)
        end
    end)
    
    return SliderFrame
end

-- Create Dropdown Function with enhanced visuals
local function CreateDropdown(parent, name, category, setting, options, default)
    local DropdownFrame = Instance.new("Frame")
    DropdownFrame.Name = name .. "Dropdown"
    DropdownFrame.Size = UDim2.new(0.95, 0, 0, 50)
    DropdownFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    DropdownFrame.Parent = parent
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 8)
    UICorner.Parent = DropdownFrame
    
    local DropdownLabel = Instance.new("TextLabel")
    DropdownLabel.Name = "Label"
    DropdownLabel.Size = UDim2.new(0.5, 0, 1, 0)
    DropdownLabel.Position = UDim2.new(0.05, 0, 0, 0)
    DropdownLabel.BackgroundTransparency = 1
    DropdownLabel.Text = name
    DropdownLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    DropdownLabel.TextSize = 16
    DropdownLabel.Font = Enum.Font.GothamSemibold
    DropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
    DropdownLabel.Parent = DropdownFrame
    
    local DropdownButton = Instance.new("TextButton")
    DropdownButton.Name = "Button"
    DropdownButton.Size = UDim2.new(0.4, 0, 0.7, 0)
    DropdownButton.Position = UDim2.new(0.55, 0, 0.15, 0)
    DropdownButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    DropdownButton.Text = default
    DropdownButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    DropdownButton.TextSize = 14
    DropdownButton.Font = Enum.Font.GothamSemibold
    DropdownButton.Parent = DropdownFrame
    
    local DropdownButtonCorner = Instance.new("UICorner")
    DropdownButtonCorner.CornerRadius = UDim.new(0, 6)
    DropdownButtonCorner.Parent = DropdownButton
    
    local DropdownMenu = Instance.new("Frame")
    DropdownMenu.Name = "Menu"
    DropdownMenu.Size = UDim2.new(0.4, 0, 0, #options * 30)
    DropdownMenu.Position = UDim2.new(0.55, 0, 1, 5)
    DropdownMenu.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    DropdownMenu.Visible = false
    DropdownMenu.ZIndex = 10
    DropdownMenu.Parent = DropdownFrame
    
    local DropdownMenuCorner = Instance.new("UICorner")
    DropdownMenuCorner.CornerRadius = UDim.new(0, 6)
    DropdownMenuCorner.Parent = DropdownMenu
    
    -- Initialize the dropdown value
    Settings[category][setting] = default
    
    -- Create dropdown options
    for i, option in ipairs(options) do
        local OptionButton = Instance.new("TextButton")
        OptionButton.Name = option
        OptionButton.Size = UDim2.new(1, 0, 0, 30)
        OptionButton.Position = UDim2.new(0, 0, 0, (i-1) * 30)
        OptionButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        OptionButton.Text = option
        OptionButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        OptionButton.TextSize = 14
        OptionButton.Font = Enum.Font.GothamSemibold
        OptionButton.ZIndex = 11
        OptionButton.Parent = DropdownMenu
        
        local OptionButtonCorner = Instance.new("UICorner")
        OptionButtonCorner.CornerRadius = UDim.new(0, 6)
        OptionButtonCorner.Parent = OptionButton
        
        -- Option button hover effect
        OptionButton.MouseEnter:Connect(function()
            TweenService:Create(OptionButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(60, 60, 60)}):Play()
        end)
        
        OptionButton.MouseLeave:Connect(function()
            TweenService:Create(OptionButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(50, 50, 50)}):Play()
        end)
        
        OptionButton.MouseButton1Click:Connect(function()
            DropdownButton.Text = option
            Settings[category][setting] = option
            DropdownMenu.Visible = false
            
            -- Update target part for aimbot
            if setting == "TargetPart" then
                AimSettings.TargetPart = option
            end
        end)
    end
    
    -- Toggle dropdown menu
    DropdownButton.MouseButton1Click:Connect(function()
        DropdownMenu.Visible = not DropdownMenu.Visible
    end)
    
    -- Close dropdown when clicking elsewhere
    UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local mousePos = UserInputService:GetMouseLocation()
            if DropdownMenu.Visible then
                local menuPos = DropdownMenu.AbsolutePosition
                local menuSize = DropdownMenu.AbsoluteSize
                
                if mousePos.X < menuPos.X or mousePos.X > menuPos.X + menuSize.X or
                   mousePos.Y < menuPos.Y or mousePos.Y > menuPos.Y + menuSize.Y then
                    if mousePos.X < DropdownButton.AbsolutePosition.X or mousePos.X > DropdownButton.AbsolutePosition.X + DropdownButton.AbsoluteSize.X or
                       mousePos.Y < DropdownButton.AbsolutePosition.Y or mousePos.Y > DropdownButton.AbsolutePosition.Y + DropdownButton.AbsoluteSize.Y then
                        DropdownMenu.Visible = false
                    end
                end
            end
        end
    end)
    
    return DropdownFrame
end

-- Create UI Elements
local function PopulateAimbotPage()
    local enabledToggle = CreateToggle(AimbotPage, "Enabled", "Aimbot", "Enabled")
    enabledToggle.Position = UDim2.new(0, 0, 0, 10)
    
    local teamCheckToggle = CreateToggle(AimbotPage, "Team Check", "Aimbot", "TeamCheck")
    teamCheckToggle.Position = UDim2.new(0, 0, 0, 70)
    
    local showFOVToggle = CreateToggle(AimbotPage, "Show FOV", "Aimbot", "ShowFOV")
    showFOVToggle.Position = UDim2.new(0, 0, 0, 130)
    
    local triggerBotToggle = CreateToggle(AimbotPage, "Trigger Bot", "Aimbot", "TriggerBot")
    triggerBotToggle.Position = UDim2.new(0, 0, 0, 190)
    
    local smoothnessSlider = CreateSlider(AimbotPage, "Smoothness", "Aimbot", "Smoothness", 0, 1, 0.2)
    smoothnessSlider.Position = UDim2.new(0, 0, 0, 250)
    
    local fovSlider = CreateSlider(AimbotPage, "FOV", "Aimbot", "FOV", 10, 500, 150)
    fovSlider.Position = UDim2.new(0, 0, 0, 320)
    
    local predictionSlider = CreateSlider(AimbotPage, "Prediction", "Aimbot", "PredictionMultiplier", 0, 5, 1.5)
    predictionSlider.Position = UDim2.new(0, 0, 0, 390)
    
    local targetPartDropdown = CreateDropdown(AimbotPage, "Target Part", "Aimbot", "TargetPart", {"Head", "HumanoidRootPart", "Torso"}, "Head")
    targetPartDropdown.Position = UDim2.new(0, 0, 0, 460)
    
    local maxDistanceSlider = CreateSlider(AimbotPage, "Max Distance", "Aimbot", "MaxDistance", 50, 1000, 250)
    maxDistanceSlider.Position = UDim2.new(0, 0, 0, 520)
    
    -- Update canvas size to accommodate all elements
    AimbotPage.CanvasSize = UDim2.new(0, 0, 0, 590)
end

local function PopulateESPPage()
    local enabledToggle = CreateToggle(ESPPage, "Enabled", "ESP", "Enabled")
    enabledToggle.Position = UDim2.new(0, 0, 0, 10)
    
    local boxesToggle = CreateToggle(ESPPage, "Boxes", "ESP", "Boxes")
    boxesToggle.Position = UDim2.new(0, 0, 0, 70)
    
    local namesToggle = CreateToggle(ESPPage, "Names", "ESP", "Names")
    namesToggle.Position = UDim2.new(0, 0, 0, 130)
    
    local distanceToggle = CreateToggle(ESPPage, "Distance", "ESP", "Distance")
    distanceToggle.Position = UDim2.new(0, 0, 0, 190)
    
    local snaplinesToggle = CreateToggle(ESPPage, "Snaplines", "ESP", "Snaplines")
    snaplinesToggle.Position = UDim2.new(0, 0, 0, 250)
    
    local healthToggle = CreateToggle(ESPPage, "Health", "ESP", "Health")
    healthToggle.Position = UDim2.new(0, 0, 0, 310)
    
    local teamCheckToggle = CreateToggle(ESPPage, "Team Check", "ESP", "TeamCheck")
    teamCheckToggle.Position = UDim2.new(0, 0, 0, 370)
    
    local rainbowToggle = CreateToggle(ESPPage, "Rainbow", "ESP", "Rainbow")
    rainbowToggle.Position = UDim2.new(0, 0, 0, 430)
    
    local maxDistanceSlider = CreateSlider(ESPPage, "Max Distance", "ESP", "MaxDistance", 100, 5000, 1000)
    maxDistanceSlider.Position = UDim2.new(0, 0, 0, 490)
    
    -- Update canvas size to accommodate all elements
    ESPPage.CanvasSize = UDim2.new(0, 0, 0, 560)
end

local function PopulateMiscPage()
    local noClipToggle = CreateToggle(MiscPage, "NoClip", "Misc", "NoClip")
    noClipToggle.Position = UDim2.new(0, 0, 0, 10)
    
    -- Add more misc features here
    
    -- Update canvas size
    MiscPage.CanvasSize = UDim2.new(0, 0, 0, 70)
end

-- Populate the pages
PopulateAimbotPage()
PopulateESPPage()
PopulateMiscPage()

-- Tab switching logic
local function SwitchTab(tab)
    -- Hide all pages
    AimbotPage.Visible = false
    ESPPage.Visible = false
    MiscPage.Visible = false
    
    -- Hide all tab accents
    AimbotTab.Accent.Visible = false
    ESPTab.Accent.Visible = false
    MiscTab.Accent.Visible = false
    
    -- Show selected tab and page
    if tab == "Aimbot" then
        AimbotPage.Visible = true
        AimbotTab.Accent.Visible = true
    elseif tab == "ESP" then
        ESPPage.Visible = true
        ESPTab.Accent.Visible = true
    elseif tab == "Misc" then
        MiscPage.Visible = true
        MiscTab.Accent.Visible = true
    end
end

-- Connect tab buttons
AimbotTab.MouseButton1Click:Connect(function()
    SwitchTab("Aimbot")
end)

ESPTab.MouseButton1Click:Connect(function()
    SwitchTab("ESP")
end)

MiscTab.MouseButton1Click:Connect(function()
    SwitchTab("Misc")
end)

-- Set default tab
SwitchTab("Aimbot")

-- Make the UI draggable
TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)

TitleBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

TitleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
        updateDrag(input)
    end
end)

-- Create Close Button
local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -40, 0, 5)
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 18
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Parent = TitleBar

local CloseButtonCorner = Instance.new("UICorner")
CloseButtonCorner.CornerRadius = UDim.new(0, 6)
CloseButtonCorner.Parent = CloseButton

CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
    
    -- Clean up all drawings
    FOVCircle:Remove()
    for _, esp in pairs(Settings.ESP.Players) do
        for _, drawing in pairs(esp) do
            drawing:Remove()
        end
    end
    
    -- Disconnect all connections
    if autoClickConnection then
        autoClickConnection:Disconnect()
    end
end)

-- Create Minimize Button
local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Name = "MinimizeButton"
MinimizeButton.Size = UDim2.new(0, 30, 0, 30)
MinimizeButton.Position = UDim2.new(1, -80, 0, 5)
MinimizeButton.BackgroundColor3 = Color3.fromRGB(50, 50, 255)
MinimizeButton.Text = "-"
MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeButton.TextSize = 18
MinimizeButton.Font = Enum.Font.GothamBold
MinimizeButton.Parent = TitleBar

local MinimizeButtonCorner = Instance.new("UICorner")
MinimizeButtonCorner.CornerRadius = UDim.new(0, 6)
MinimizeButtonCorner.Parent = MinimizeButton

local minimized = false
MinimizeButton.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        TabContainer.Visible = false
        TabButtons.Visible = false
        MainFrame:TweenSize(UDim2.new(0, 500, 0, 50), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.5, true)
        MinimizeButton.Text = "+"
    else
        MainFrame:TweenSize(UDim2.new(0, 500, 0, 400), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.5, true)
        wait(0.5)
        TabContainer.Visible = true
        TabButtons.Visible = true
        MinimizeButton.Text = "-"
    end
end)

-- Create a function to show/hide the UI
local function ToggleUI()
    ScreenGui.Enabled = not ScreenGui.Enabled
end

-- Connect key press events
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed then
        -- Toggle UI with INSERT key
        if input.KeyCode == Enum.KeyCode.Insert then
            ToggleUI()
        end
        
        -- Close UI with END key
        if input.KeyCode == Enum.KeyCode.End then
            CloseButton.MouseButton1Click:Fire()
        end
        
        -- Check for toggle keys
        if toggleKeys[input.KeyCode] then
            toggleKeys[input.KeyCode]()
        end
        
        -- Track mouse buttons for auto clicker
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isLeftMouseDown = true
        elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
            isRightMouseDown = true
            -- Set target player when right mouse is pressed
            targetPlayer = GetClosestPlayerToMouse()
        end
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if not gameProcessed then
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isLeftMouseDown = false
        elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
            isRightMouseDown = false
            targetPlayer = nil
        end
    end
end)

-- Create ESP for all players
for _, player in ipairs(Players:GetPlayers()) do
    if player ~= localPlayer then
        CreateESP(player)
    end
end

-- Create ESP for new players
Players.PlayerAdded:Connect(function(player)
    if player ~= localPlayer then
        CreateESP(player)
    end
end)

-- Remove ESP for players who leave
Players.PlayerRemoving:Connect(function(player)
    if Settings.ESP.Players[player] then
        for _, drawing in pairs(Settings.ESP.Players[player]) do
            drawing:Remove()
        end
        Settings.ESP.Players[player] = nil
    end
end)

-- NoClip functionality
RunService.Stepped:Connect(function()
    if noClipEnabled and localPlayer.Character then
        for _, part in pairs(localPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

-- Main loop for aimbot and ESP
RunService.RenderStepped:Connect(function()
    -- Update FOV Circle position
    FOVCircle.Position = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
    FOVCircle.Visible = Settings.Aimbot.ShowFOV
    FOVCircle.Radius = Settings.Aimbot.FOV
    
    -- Update ESP
    UpdateESP()
    
    -- Aimbot logic
    if Settings.Aimbot.Enabled and isRightMouseDown then
        local target = GetClosestPlayerToMouse()
        if target and target.Character and target.Character:FindFirstChild(Settings.Aimbot.TargetPart) then
            local targetPart = target.Character[Settings.Aimbot.TargetPart]
            
            -- Apply prediction if target is moving
            local velocity = target.Character.HumanoidRootPart.Velocity
            local predictionOffset = velocity * Settings.Aimbot.PredictionMultiplier * 0.1
            local targetPosition = targetPart.Position + predictionOffset
            
            -- Convert 3D position to 2D screen position
            local screenPosition, onScreen = camera:WorldToViewportPoint(targetPosition)
            
            if onScreen then
                local screenCenter = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
                local aimPosition = Vector2.new(screenPosition.X, screenPosition.Y)
                local mousePosition = UserInputService:GetMouseLocation()
                
                -- Calculate distance and apply smoothing
                local distance = (aimPosition - mousePosition).Magnitude
                local smoothness = Settings.Aimbot.Smoothness
                
                if distance > 5 then
                    local aimDelta = (aimPosition - mousePosition) * smoothness
                    mousemoverel(aimDelta.X, aimDelta.Y)
                end
                
                -- TriggerBot functionality
                if Settings.Aimbot.TriggerBot then
                    local ray = camera:ScreenPointToRay(screenCenter.X, screenCenter.Y)
                    local raycastParams = RaycastParams.new()
                    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
                    raycastParams.FilterDescendantsInstances = {localPlayer.Character}
                    
                    local raycastResult = workspace:Raycast(ray.Origin, ray.Direction * 1000, raycastParams)
                    if raycastResult and raycastResult.Instance:IsDescendantOf(target.Character) then
                        mouse1click()
                    end
                end
            end
        end
    end
    
    -- Silent Aim logic
    if AimSettings.SilentAim and isLeftMouseDown then
        local target = GetClosestPlayerToMouse()
        if target and target.Character and target.Character:FindFirstChild(AimSettings.TargetPart) then
            -- Implement hit chance
            if math.random(1, 100) <= AimSettings.HitChance then
                perfectAim(target.Character[AimSettings.TargetPart])
            end
        end
    end
end)

-- Create notification function
function createNotification(title, text, duration)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = title,
        Text = text,
        Duration = duration,
        Icon = "rbxassetid://13647654264"
    })
end
