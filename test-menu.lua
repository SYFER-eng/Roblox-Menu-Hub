-- 🌙 ULTIMATE OVERLAY SCRIPT - DOMINATES ALL ROBLOX UI
-- Every element overlays EVERYTHING in Roblox for external executors

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Camera = workspace.CurrentCamera

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local mouse = player:GetMouse()

-- Variables
local ESPObjects = {}
local connections = {}
local isMenuOpen = false
local isDragging = false
local dragStart = nil
local startPos = nil
local currentTarget = nil
local rainbowHue = 0
local pulseTime = 0

-- Enhanced Settings
local Settings = {
    AimbotEnabled = false,
    TeamCheck = true,
    AimPart = "Head",
    FOVSize = 120,
    Smoothness = 8,
    PredictMovement = false,
    VisibleCheck = true,
    ESPEnabled = true,
    BoxESP = true,
    BoneESP = true,
    NameESP = true,
    DistanceESP = true,
    HealthESP = true,
    TracerESP = false,
    HeadESP = true,
    SkeletonESP = false,
    ShowFOV = true,
    RainbowESP = false,
    PulseESP = false,
    ESPColor = Color3.fromRGB(100, 200, 255),
    ESPThickness = 2,
    ESPTransparency = 0.8,
    CrosshairEnabled = true,
    CrosshairColor = Color3.fromRGB(0, 255, 100),
    CrosshairStyle = "Plus",
    CrosshairSize = 12,
    CrosshairGap = 4,
    CrosshairPulse = true,
    MaxDistance = 1500,
    UpdateRate = 60
}

-- Night Theme Colors
local Theme = {
    Background = Color3.fromRGB(15, 15, 20),
    Secondary = Color3.fromRGB(25, 25, 35),
    Accent = Color3.fromRGB(100, 150, 255),
    Success = Color3.fromRGB(100, 255, 150),
    Warning = Color3.fromRGB(255, 200, 100),
    Danger = Color3.fromRGB(255, 100, 120),
    Text = Color3.fromRGB(255, 255, 255),
    TextDim = Color3.fromRGB(180, 180, 190)
}

-- MAXIMUM OVERLAY PRIORITY VALUES
local MAX_ZINDEX = 2147483647
local MAX_DISPLAY_ORDER = 2147483647

-- Create ULTIMATE OVERLAY ScreenGui
pcall(function()
    if playerGui:FindFirstChild("ULTIMATE_OVERLAY_GUI") then
        playerGui.ULTIMATE_OVERLAY_GUI:Destroy()
    end
end)

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ULTIMATE_OVERLAY_GUI"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Enabled = true
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
screenGui.DisplayOrder = MAX_DISPLAY_ORDER
screenGui.Parent = playerGui

-- 🎯 ULTIMATE OVERLAY CROSSHAIR
local crosshairContainer = Instance.new("Frame")
crosshairContainer.Name = "ULTIMATE_CROSSHAIR"
crosshairContainer.Size = UDim2.new(0, 60, 0, 60)
crosshairContainer.Position = UDim2.new(0.5, -30, 0.5, -30)
crosshairContainer.BackgroundTransparency = 1
crosshairContainer.Visible = Settings.CrosshairEnabled
crosshairContainer.ZIndex = MAX_ZINDEX
crosshairContainer.Parent = screenGui

local crosshairParts = {}

local function createUltimateOverlayCrosshair()
    for _, part in pairs(crosshairParts) do
        if part then part:Destroy() end
    end
    crosshairParts = {}
    
    -- Center dot with MAXIMUM overlay
    local centerDot = Instance.new("Frame")
    centerDot.Name = "OVERLAY_CENTER_DOT"
    centerDot.Size = UDim2.new(0, 3, 0, 3)
    centerDot.Position = UDim2.new(0.5, -1.5, 0.5, -1.5)
    centerDot.BackgroundColor3 = Settings.CrosshairColor
    centerDot.BorderSizePixel = 0
    centerDot.ZIndex = MAX_ZINDEX
    centerDot.Parent = crosshairContainer
    
    local dotCorner = Instance.new("UICorner")
    dotCorner.CornerRadius = UDim.new(0.5, 0)
    dotCorner.Parent = centerDot
    
    local dotGlow = Instance.new("UIStroke")
    dotGlow.Color = Settings.CrosshairColor
    dotGlow.Thickness = 2
    dotGlow.Transparency = 0.5
    dotGlow.Parent = centerDot
    
    -- Crosshair lines with MAXIMUM overlay
    local lines = {
        {UDim2.new(0, 2, 0, Settings.CrosshairSize), UDim2.new(0.5, -1, 0.5, -Settings.CrosshairSize - Settings.CrosshairGap)},
        {UDim2.new(0, 2, 0, Settings.CrosshairSize), UDim2.new(0.5, -1, 0.5, Settings.CrosshairGap)},
        {UDim2.new(0, Settings.CrosshairSize, 0, 2), UDim2.new(0.5, -Settings.CrosshairSize - Settings.CrosshairGap, 0.5, -1)},
        {UDim2.new(0, Settings.CrosshairSize, 0, 2), UDim2.new(0.5, Settings.CrosshairGap, 0.5, -1)}
    }
    
    for i, lineData in pairs(lines) do
        local line = Instance.new("Frame")
        line.Name = "OVERLAY_CROSSHAIR_LINE_" .. i
        line.Size = lineData[1]
        line.Position = lineData[2]
        line.BackgroundColor3 = Settings.CrosshairColor
        line.BorderSizePixel = 0
        line.ZIndex = MAX_ZINDEX
        line.Parent = crosshairContainer
        
        local lineStroke = Instance.new("UIStroke")
        lineStroke.Color = Color3.fromRGB(0, 0, 0)
        lineStroke.Thickness = 1
        lineStroke.Transparency = 0.3
        lineStroke.Parent = line
        
        table.insert(crosshairParts, line)
    end
    
    table.insert(crosshairParts, centerDot)
end

-- 🎯 ULTIMATE OVERLAY FOV CIRCLE
local fovCircle = Instance.new("Frame")
fovCircle.Name = "ULTIMATE_FOV_CIRCLE"
fovCircle.Size = UDim2.new(0, Settings.FOVSize * 2, 0, Settings.FOVSize * 2)
fovCircle.Position = UDim2.new(0.5, -Settings.FOVSize, 0.5, -Settings.FOVSize)
fovCircle.BackgroundTransparency = 1
fovCircle.Visible = Settings.ShowFOV
fovCircle.ZIndex = MAX_ZINDEX - 1
fovCircle.Parent = screenGui

local fovCorner = Instance.new("UICorner")
fovCorner.CornerRadius = UDim.new(0.5, 0)
fovCorner.Parent = fovCircle

local fovStroke = Instance.new("UIStroke")
fovStroke.Color = Theme.Accent
fovStroke.Transparency = 0.6
fovStroke.Thickness = 2
fovStroke.Parent = fovCircle

-- 🌙 ULTIMATE OVERLAY MENU
local menuFrame = Instance.new("Frame")
menuFrame.Name = "ULTIMATE_OVERLAY_MENU"
menuFrame.Size = UDim2.new(0, 450, 0, 380)
menuFrame.Position = UDim2.new(0.5, -225, 0.5, -190)
menuFrame.BackgroundColor3 = Theme.Background
menuFrame.BorderSizePixel = 0
menuFrame.Visible = false
menuFrame.ZIndex = MAX_ZINDEX
menuFrame.Active = true
menuFrame.Parent = screenGui

-- Add ultra shadow
local shadow = Instance.new("ImageLabel")
shadow.Name = "ULTRA_SHADOW"
shadow.Size = UDim2.new(1, 30, 1, 30)
shadow.Position = UDim2.new(0, -15, 0, -15)
shadow.BackgroundTransparency = 1
shadow.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
shadow.ImageTransparency = 0.7
shadow.ZIndex = MAX_ZINDEX - 2
shadow.Parent = menuFrame

local menuCorner = Instance.new("UICorner")
menuCorner.CornerRadius = UDim.new(0, 12)
menuCorner.Parent = menuFrame

-- Animated border with max overlay
local borderStroke = Instance.new("UIStroke")
borderStroke.Color = Theme.Accent
borderStroke.Thickness = 2
borderStroke.Transparency = 0.3
borderStroke.Parent = menuFrame

-- Gradient background
local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Theme.Background),
    ColorSequenceKeypoint.new(1, Theme.Secondary)
}
gradient.Rotation = 135
gradient.Parent = menuFrame

-- 🎨 ULTIMATE OVERLAY TITLE BAR
local titleBar = Instance.new("Frame")
titleBar.Name = "ULTIMATE_TITLE_BAR"
titleBar.Size = UDim2.new(1, 0, 0, 45)
titleBar.Position = UDim2.new(0, 0, 0, 0)
titleBar.BackgroundColor3 = Theme.Accent
titleBar.BorderSizePixel = 0
titleBar.ZIndex = MAX_ZINDEX
titleBar.Parent = menuFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 12)
titleCorner.Parent = titleBar

local titleFix = Instance.new("Frame")
titleFix.Size = UDim2.new(1, 0, 0, 22)
titleFix.Position = UDim2.new(0, 0, 1, -22)
titleFix.BackgroundColor3 = Theme.Accent
titleFix.BorderSizePixel = 0
titleFix.ZIndex = MAX_ZINDEX
titleFix.Parent = titleBar

local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "ULTIMATE_TITLE"
titleLabel.Size = UDim2.new(1, -50, 1, 0)
titleLabel.Position = UDim2.new(0, 15, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "🌙 ULTIMATE OVERLAY v4.0"
titleLabel.TextColor3 = Theme.Text
titleLabel.TextSize = 16
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.ZIndex = MAX_ZINDEX
titleLabel.Parent = titleBar

-- Close button with ULTIMATE overlay
local closeButton = Instance.new("TextButton")
closeButton.Name = "ULTIMATE_CLOSE"
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -38, 0, 7.5)
closeButton.BackgroundColor3 = Theme.Danger
closeButton.Text = "×"
closeButton.TextColor3 = Theme.Text
closeButton.TextSize = 18
closeButton.Font = Enum.Font.GothamBold
closeButton.BorderSizePixel = 0
closeButton.ZIndex = MAX_ZINDEX
closeButton.Parent = titleBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 6)
closeCorner.Parent = closeButton

-- 📑 ULTIMATE OVERLAY TAB SYSTEM
local tabContainer = Instance.new("Frame")
tabContainer.Name = "ULTIMATE_TAB_CONTAINER"
tabContainer.Size = UDim2.new(1, 0, 0, 35)
tabContainer.Position = UDim2.new(0, 0, 0, 45)
tabContainer.BackgroundColor3 = Theme.Secondary
tabContainer.BorderSizePixel = 0
tabContainer.ZIndex = MAX_ZINDEX
tabContainer.Parent = menuFrame

local tabs = {}
local tabNames = {"⚔️ Combat", "👁️ ESP", "🎯 Visuals", "⚙️ Settings"}
local tabContents = {}

-- Create ULTIMATE OVERLAY tabs
for i, name in ipairs(tabNames) do
    local tab = Instance.new("TextButton")
    tab.Name = "ULTIMATE_TAB_" .. i
    tab.Size = UDim2.new(1/4, 0, 1, 0)
    tab.Position = UDim2.new((i-1)/4, 0, 0, 0)
    tab.BackgroundColor3 = i == 1 and Theme.Accent or Color3.fromRGB(30, 30, 40)
    tab.Text = name
    tab.TextColor3 = Theme.Text
    tab.TextSize = 12
    tab.Font = Enum.Font.Gotham
    tab.BorderSizePixel = 0
    tab.ZIndex = MAX_ZINDEX
    tab.Parent = tabContainer
    
    tabs[i] = tab
    
    -- Content frame with ULTIMATE overlay
    local content = Instance.new("ScrollingFrame")
    content.Name = "ULTIMATE_CONTENT_" .. i
    content.Size = UDim2.new(1, -10, 1, -90)
    content.Position = UDim2.new(0, 5, 0, 85)
    content.BackgroundTransparency = 1
    content.ScrollBarThickness = 4
    content.ScrollBarImageColor3 = Theme.Accent
    content.CanvasSize = UDim2.new(0, 0, 0, 600)
    content.Visible = i == 1
    content.ZIndex = MAX_ZINDEX
    content.Parent = menuFrame
    
    tabContents[i] = content
end

-- 🎛️ ULTIMATE OVERLAY UI COMPONENTS
local function createUltimateOverlayToggle(parent, text, yPos, defaultValue, callback)
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Size = UDim2.new(1, 0, 0, 35)
    toggleFrame.Position = UDim2.new(0, 0, 0, yPos)
    toggleFrame.BackgroundColor3 = Theme.Secondary
    toggleFrame.BorderSizePixel = 0
    toggleFrame.ZIndex = MAX_ZINDEX
    toggleFrame.Parent = parent
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 6)
    toggleCorner.Parent = toggleFrame
    
    local toggleLabel = Instance.new("TextLabel")
    toggleLabel.Size = UDim2.new(1, -60, 1, 0)
    toggleLabel.Position = UDim2.new(0, 10, 0, 0)
    toggleLabel.BackgroundTransparency = 1
    toggleLabel.Text = text
    toggleLabel.TextColor3 = Theme.Text
    toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
    toggleLabel.TextSize = 12
    toggleLabel.Font = Enum.Font.Gotham
    toggleLabel.ZIndex = MAX_ZINDEX
    toggleLabel.Parent = toggleFrame
    
    local toggleButton = Instance.new("TextButton")
    toggleButton.Size = UDim2.new(0, 40, 0, 20)
    toggleButton.Position = UDim2.new(1, -45, 0.5, -10)
    toggleButton.BackgroundColor3 = defaultValue and Theme.Success or Color3.fromRGB(50, 50, 60)
    toggleButton.Text = ""
    toggleButton.BorderSizePixel = 0
    toggleButton.ZIndex = MAX_ZINDEX
    toggleButton.Parent = toggleFrame
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 10)
    buttonCorner.Parent = toggleButton
    
    local toggleIndicator = Instance.new("Frame")
    toggleIndicator.Size = UDim2.new(0, 16, 0, 16)
    toggleIndicator.Position = defaultValue and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
    toggleIndicator.BackgroundColor3 = Theme.Text
    toggleIndicator.BorderSizePixel = 0
    toggleIndicator.ZIndex = MAX_ZINDEX
    toggleIndicator.Parent = toggleButton
    
    local indicatorCorner = Instance.new("UICorner")
    indicatorCorner.CornerRadius = UDim.new(0, 8)
    indicatorCorner.Parent = toggleIndicator
    
    local isToggled = defaultValue
    
    toggleButton.MouseButton1Click:Connect(function()
        isToggled = not isToggled
        
        local targetPos = isToggled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
        local targetColor = isToggled and Theme.Success or Color3.fromRGB(50, 50, 60)
        
        TweenService:Create(toggleIndicator, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = targetPos}):Play()
        TweenService:Create(toggleButton, TweenInfo.new(0.25), {BackgroundColor3 = targetColor}):Play()
        
        local scaleUp = TweenService:Create(toggleButton, TweenInfo.new(0.1), {Size = UDim2.new(0, 44, 0, 22)})
        local scaleDown = TweenService:Create(toggleButton, TweenInfo.new(0.1), {Size = UDim2.new(0, 40, 0, 20)})
        
        scaleUp:Play()
        scaleUp.Completed:Connect(function() scaleDown:Play() end)
        
        callback(isToggled)
    end)
    
    return toggleButton
end

local function createUltimateOverlaySlider(parent, text, yPos, maxValue, minValue, defaultValue, callback)
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Size = UDim2.new(1, 0, 0, 50)
    sliderFrame.Position = UDim2.new(0, 0, 0, yPos)
    sliderFrame.BackgroundColor3 = Theme.Secondary
    sliderFrame.BorderSizePixel = 0
    sliderFrame.ZIndex = MAX_ZINDEX
    sliderFrame.Parent = parent
    
    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(0, 6)
    sliderCorner.Parent = sliderFrame
    
    local sliderLabel = Instance.new("TextLabel")
    sliderLabel.Size = UDim2.new(1, 0, 0, 25)
    sliderLabel.Position = UDim2.new(0, 10, 0, 0)
    sliderLabel.BackgroundTransparency = 1
    sliderLabel.Text = text .. ": " .. defaultValue
    sliderLabel.TextColor3 = Theme.Text
    sliderLabel.TextXAlignment = Enum.TextXAlignment.Left
    sliderLabel.TextSize = 12
    sliderLabel.Font = Enum.Font.Gotham
    sliderLabel.ZIndex = MAX_ZINDEX
    sliderLabel.Parent = sliderFrame
    
    local sliderTrack = Instance.new("Frame")
    sliderTrack.Size = UDim2.new(1, -20, 0, 6)
    sliderTrack.Position = UDim2.new(0, 10, 1, -15)
    sliderTrack.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    sliderTrack.BorderSizePixel = 0
    sliderTrack.ZIndex = MAX_ZINDEX
    sliderTrack.Parent = sliderFrame
    
    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(0, 3)
    trackCorner.Parent = sliderTrack
    
    local sliderFill = Instance.new("Frame")
    local percentage = (defaultValue - minValue) / (maxValue - minValue)
    sliderFill.Size = UDim2.new(percentage, 0, 1, 0)
    sliderFill.Position = UDim2.new(0, 0, 0, 0)
    sliderFill.BackgroundColor3 = Theme.Accent
    sliderFill.BorderSizePixel = 0
    sliderFill.ZIndex = MAX_ZINDEX
    sliderFill.Parent = sliderTrack
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 3)
    fillCorner.Parent = sliderFill
    
    local sliderButton = Instance.new("TextButton")
    sliderButton.Size = UDim2.new(0, 14, 0, 14)
    sliderButton.Position = UDim2.new(percentage, -7, 0.5, -7)
    sliderButton.BackgroundColor3 = Theme.Text
    sliderButton.Text = ""
    sliderButton.BorderSizePixel = 0
    sliderButton.ZIndex = MAX_ZINDEX
    sliderButton.Parent = sliderTrack
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0.5, 0)
    buttonCorner.Parent = sliderButton
    
    local currentValue = defaultValue
    local dragging = false
    
    sliderButton.MouseButton1Down:Connect(function()
        dragging = true
        TweenService:Create(sliderButton, TweenInfo.new(0.1), {Size = UDim2.new(0, 18, 0, 18)}):Play()
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
            TweenService:Create(sliderButton, TweenInfo.new(0.1), {Size = UDim2.new(0, 14, 0, 14)}):Play()
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mousePos = UserInputService:GetMouseLocation()
            local relativePos = (mousePos.X - sliderTrack.AbsolutePosition.X) / sliderTrack.AbsoluteSize.X
            relativePos = math.clamp(relativePos, 0, 1)
            
            currentValue = math.floor(minValue + (maxValue - minValue) * relativePos)
            sliderLabel.Text = text .. ": " .. currentValue
            
            TweenService:Create(sliderButton, TweenInfo.new(0.05), {Position = UDim2.new(relativePos, -7, 0.5, -7)}):Play()
            TweenService:Create(sliderFill, TweenInfo.new(0.05), {Size = UDim2.new(relativePos, 0, 1, 0)}):Play()
            
            callback(currentValue)
        end
    end)
    
    return sliderButton
end

-- 📋 Create ULTIMATE OVERLAY Content
local yOffset = 5

-- Combat Tab Content
createUltimateOverlayToggle(tabContents[1], "🎯 Aimbot", yOffset, Settings.AimbotEnabled, function(value)
    Settings.AimbotEnabled = value
end)
yOffset = yOffset + 40

createUltimateOverlayToggle(tabContents[1], "👥 Team Check", yOffset, Settings.TeamCheck, function(value)
    Settings.TeamCheck = value
end)
yOffset = yOffset + 40

createUltimateOverlaySlider(tabContents[1], "🎯 FOV Size", yOffset, 300, 30, Settings.FOVSize, function(value)
    Settings.FOVSize = value
    fovCircle.Size = UDim2.new(0, value * 2, 0, value * 2)
    fovCircle.Position = UDim2.new(0.5, -value, 0.5, -value)
end)
yOffset = yOffset + 55

createUltimateOverlaySlider(tabContents[1], "⚡ Smoothness", yOffset, 20, 1, Settings.Smoothness, function(value)
    Settings.Smoothness = value
end)
yOffset = yOffset + 55

createUltimateOverlayToggle(tabContents[1], "🔮 Predict Movement", yOffset, Settings.PredictMovement, function(value)
    Settings.PredictMovement = value
end)
yOffset = yOffset + 40

createUltimateOverlayToggle(tabContents[1], "👁️ Visible Check", yOffset, Settings.VisibleCheck, function(value)
    Settings.VisibleCheck = value
end)

-- ESP Tab Content
yOffset = 5

createUltimateOverlayToggle(tabContents[2], "👁️ ESP Enable", yOffset, Settings.ESPEnabled, function(value)
    Settings.ESPEnabled = value
end)
yOffset = yOffset + 40

createUltimateOverlayToggle(tabContents[2], "📦 Box ESP", yOffset, Settings.BoxESP, function(value)
    Settings.BoxESP = value
end)
yOffset = yOffset + 40

createUltimateOverlayToggle(tabContents[2], "🏷️ Name ESP", yOffset, Settings.NameESP, function(value)
    Settings.NameESP = value
end)
yOffset = yOffset + 40

createUltimateOverlayToggle(tabContents[2], "📏 Distance ESP", yOffset, Settings.DistanceESP, function(value)
    Settings.DistanceESP = value
end)
yOffset = yOffset + 40

createUltimateOverlayToggle(tabContents[2], "❤️ Health ESP", yOffset, Settings.HealthESP, function(value)
    Settings.HealthESP = value
end)
yOffset = yOffset + 40

createUltimateOverlayToggle(tabContents[2], "🎯 Head ESP", yOffset, Settings.HeadESP, function(value)
    Settings.HeadESP = value
end)
yOffset = yOffset + 40

createUltimateOverlayToggle(tabContents[2], "📍 Tracer ESP", yOffset, Settings.TracerESP, function(value)
    Settings.TracerESP = value
end)
yOffset = yOffset + 40

createUltimateOverlaySlider(tabContents[2], "📏 Max Distance", yOffset, 2000, 500, Settings.MaxDistance, function(value)
    Settings.MaxDistance = value
end)

-- Visuals Tab Content
yOffset = 5

createUltimateOverlayToggle(tabContents[3], "⭕ Show FOV", yOffset, Settings.ShowFOV, function(value)
    Settings.ShowFOV = value
    fovCircle.Visible = value
end)
yOffset = yOffset + 40

createUltimateOverlayToggle(tabContents[3], "🌈 Rainbow ESP", yOffset, Settings.RainbowESP, function(value)
    Settings.RainbowESP = value
end)
yOffset = yOffset + 40

createUltimateOverlayToggle(tabContents[3], "💓 Pulse ESP", yOffset, Settings.PulseESP, function(value)
    Settings.PulseESP = value
end)
yOffset = yOffset + 40

createUltimateOverlaySlider(tabContents[3], "🎨 ESP Thickness", yOffset, 5, 1, Settings.ESPThickness, function(value)
    Settings.ESPThickness = value
end)

-- Settings Tab Content
yOffset = 5

createUltimateOverlayToggle(tabContents[4], "🎯 Crosshair", yOffset, Settings.CrosshairEnabled, function(value)
    Settings.CrosshairEnabled = value
    crosshairContainer.Visible = value
end)
yOffset = yOffset + 40

createUltimateOverlayToggle(tabContents[4], "💓 Crosshair Pulse", yOffset, Settings.CrosshairPulse, function(value)
    Settings.CrosshairPulse = value
end)
yOffset = yOffset + 40

createUltimateOverlaySlider(tabContents[4], "📏 Crosshair Size", yOffset, 25, 5, Settings.CrosshairSize, function(value)
    Settings.CrosshairSize = value
    createUltimateOverlayCrosshair()
end)

-- Tab switching with ULTIMATE animations
for i, tab in ipairs(tabs) do
    tab.MouseButton1Click:Connect(function()
        for j, otherTab in ipairs(tabs) do
            TweenService:Create(otherTab, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(30, 30, 40)}):Play()
            tabContents[j].Visible = false
        end
        TweenService:Create(tab, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Accent}):Play()
        tabContents[i].Visible = true
    end)
end

-- 🎮 ULTIMATE ESP SYSTEM
local function getRainbowColor()
    rainbowHue = (rainbowHue + 0.005) % 1
    return Color3.fromHSV(rainbowHue, 0.8, 1)
end

local function getPulseAlpha()
    pulseTime = pulseTime + 0.1
    return 0.5 + 0.3 * math.sin(pulseTime)
end

local function createUltimateESP(targetPlayer)
    if targetPlayer == player or ESPObjects[targetPlayer] then return end
    
    local esp = {}
    
    -- Box ESP
    local box = Drawing.new("Square")
    box.Visible = false
    box.Color = Settings.ESPColor
    box.Thickness = Settings.ESPThickness
    box.Transparency = Settings.ESPTransparency
    box.Filled = false
    esp.Box = box
    
    -- Name ESP
    local nameLabel = Drawing.new("Text")
    nameLabel.Visible = false
    nameLabel.Color = Settings.ESPColor
    nameLabel.Size = 14
    nameLabel.Center = true
    nameLabel.Outline = true
    nameLabel.OutlineColor = Color3.fromRGB(0, 0, 0)
    nameLabel.Font = 2
    nameLabel.Text = targetPlayer.Name
    esp.Name = nameLabel
    
    -- Distance ESP
    local distanceLabel = Drawing.new("Text")
    distanceLabel.Visible = false
    distanceLabel.Color = Settings.ESPColor
    distanceLabel.Size = 12
    distanceLabel.Center = true
    distanceLabel.Outline = true
    distanceLabel.OutlineColor = Color3.fromRGB(0, 0, 0)
    distanceLabel.Font = 2
    esp.Distance = distanceLabel
    
    -- Health ESP
    local healthBar = Drawing.new("Square")
    healthBar.Visible = false
    healthBar.Color = Color3.fromRGB(0, 255, 0)
    healthBar.Thickness = 1
    healthBar.Transparency = 1
    healthBar.Filled = true
    esp.Health = healthBar
    
    -- Tracer ESP
    local tracer = Drawing.new("Line")
    tracer.Visible = false
    tracer.Color = Settings.ESPColor
    tracer.Thickness = 1
    tracer.Transparency = 0.7
    esp.Tracer = tracer
    
    -- Head ESP
    local headCircle = Drawing.new("Circle")
    headCircle.Visible = false
    headCircle.Color = Settings.ESPColor
    headCircle.Thickness = 2
    headCircle.Transparency = 0.8
    headCircle.Filled = false
    esp.Head = headCircle
    
    ESPObjects[targetPlayer] = esp
end

local function updateUltimateESP()
    if not Settings.ESPEnabled then return end
    
    for targetPlayer, esp in pairs(ESPObjects) do
        if targetPlayer and targetPlayer.Parent and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local character = targetPlayer.Character
            local humanoidRootPart = character.HumanoidRootPart
            local humanoid = character:FindFirstChild("Humanoid")
            local head = character:FindFirstChild("Head")
            
            if Settings.TeamCheck and targetPlayer.Team == player.Team then
                esp.Box.Visible = false
                esp.Name.Visible = false
                esp.Distance.Visible = false
                esp.Health.Visible = false
                esp.Tracer.Visible = false
                esp.Head.Visible = false
                continue
            end
            
            local distance = (humanoidRootPart.Position - Camera.CFrame.Position).Magnitude
            if distance > Settings.MaxDistance then
                esp.Box.Visible = false
                esp.Name.Visible = false
                esp.Distance.Visible = false
                esp.Health.Visible = false
                esp.Tracer.Visible = false
                esp.Head.Visible = false
                continue
            end
            
            local screenPos, onScreen = Camera:WorldToViewportPoint(humanoidRootPart.Position)
            
            if onScreen then
                local headPos = Camera:WorldToViewportPoint(humanoidRootPart.Position + Vector3.new(0, 2.5, 0))
                local legPos = Camera:WorldToViewportPoint(humanoidRootPart.Position - Vector3.new(0, 2.5, 0))
                
                local height = math.abs(headPos.Y - legPos.Y)
                local width = height * 0.6
                
                local currentColor = Settings.ESPColor
                if Settings.RainbowESP then
                    currentColor = getRainbowColor()
                end
                
                local currentTransparency = Settings.ESPTransparency
                if Settings.PulseESP then
                    currentTransparency = getPulseAlpha()
                end
                
                -- Box ESP
                if Settings.BoxESP then
                    esp.Box.Size = Vector2.new(width, height)
                    esp.Box.Position = Vector2.new(screenPos.X - width/2, headPos.Y)
                    esp.Box.Color = currentColor
                    esp.Box.Transparency = currentTransparency
                    esp.Box.Thickness = Settings.ESPThickness
                    esp.Box.Visible = true
                else
                    esp.Box.Visible = false
                end
                
                -- Name ESP
                if Settings.NameESP then
                    esp.Name.Position = Vector2.new(screenPos.X, headPos.Y - 20)
                    esp.Name.Color = currentColor
                    esp.Name.Visible = true
                else
                    esp.Name.Visible = false
                end
                
                -- Distance ESP
                if Settings.DistanceESP then
                    esp.Distance.Text = math.floor(distance) .. "m"
                    esp.Distance.Position = Vector2.new(screenPos.X, legPos.Y + 20)
                    esp.Distance.Color = currentColor
                    esp.Distance.Visible = true
                else
                    esp.Distance.Visible = false
                end
                
                -- Health ESP
                if Settings.HealthESP and humanoid then
                    local healthPercent = humanoid.Health / humanoid.MaxHealth
                    local healthHeight = height * healthPercent
                    
                    esp.Health.Size = Vector2.new(4, healthHeight)
                    esp.Health.Position = Vector2.new(screenPos.X - width/2 - 8, headPos.Y + (height - healthHeight))
                    esp.Health.Color = Color3.fromRGB(255 * (1 - healthPercent), 255 * healthPercent, 0)
                    esp.Health.Visible = true
                else
                    esp.Health.Visible = false
                end
                
                -- Tracer ESP
                if Settings.TracerESP then
                    local screenSize = Camera.ViewportSize
                    esp.Tracer.From = Vector2.new(screenSize.X / 2, screenSize.Y)
                    esp.Tracer.To = Vector2.new(screenPos.X, screenPos.Y)
                    esp.Tracer.Color = currentColor
                    esp.Tracer.Visible = true
                else
                    esp.Tracer.Visible = false
                end
                
                -- Head ESP
                if Settings.HeadESP and head then
                    local headScreenPos = Camera:WorldToViewportPoint(head.Position)
                    esp.Head.Position = Vector2.new(headScreenPos.X, headScreenPos.Y)
                    esp.Head.Radius = width / 4
                    esp.Head.Color = currentColor
                    esp.Head.Visible = true
                else
                    esp.Head.Visible = false
                end
            else
                esp.Box.Visible = false
                esp.Name.Visible = false
                esp.Distance.Visible = false
                esp.Health.Visible = false
                esp.Tracer.Visible = false
                esp.Head.Visible = false
            end
        else
            if esp.Box then esp.Box:Remove() end
            if esp.Name then esp.Name:Remove() end
            if esp.Distance then esp.Distance:Remove() end
            if esp.Health then esp.Health:Remove() end
            if esp.Tracer then esp.Tracer:Remove() end
            if esp.Head then esp.Head:Remove() end
            ESPObjects[targetPlayer] = nil
        end
    end
end

-- 🎯 ULTIMATE AIMBOT
local function getClosestPlayer()
    if not Settings.AimbotEnabled then return nil end
    
    local closestPlayer = nil
    local shortestDistance = Settings.FOVSize
    local mousePos = UserInputService:GetMouseLocation()
    
    for _, targetPlayer in pairs(Players:GetPlayers()) do
        if targetPlayer ~= player and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            if Settings.TeamCheck and targetPlayer.Team == player.Team then continue end
            
            local character = targetPlayer.Character
            local aimPart = character:FindFirstChild(Settings.AimPart) or character:FindFirstChild("HumanoidRootPart")
            
            if aimPart then
                local targetPos = aimPart.Position
                
                if Settings.PredictMovement and aimPart.AssemblyLinearVelocity then
                    local velocity = aimPart.AssemblyLinearVelocity
                    local distance = (targetPos - Camera.CFrame.Position).Magnitude
                    local timeToTarget = distance / 1000
                    targetPos = targetPos + (velocity * timeToTarget)
                end
                
                local screenPos, onScreen = Camera:WorldToViewportPoint(targetPos)
                
                if onScreen then
                    local distance = math.sqrt((screenPos.X - mousePos.X)^2 + (screenPos.Y - mousePos.Y)^2)
                    
                    if Settings.VisibleCheck then
                        local raycast = workspace:Raycast(Camera.CFrame.Position, (targetPos - Camera.CFrame.Position).Unit * 1000)
                        if raycast and raycast.Instance and not raycast.Instance:IsDescendantOf(character) then
                            continue
                        end
                    end
                    
                    if distance < shortestDistance then
                        shortestDistance = distance
                        closestPlayer = targetPlayer
                    end
                end
            end
        end
    end
    
    return closestPlayer
end

local function aimAt(targetPlayer)
    if not targetPlayer or not targetPlayer.Character then return end
    
    local character = targetPlayer.Character
    local aimPart = character:FindFirstChild(Settings.AimPart) or character:FindFirstChild("HumanoidRootPart")
    
    if aimPart then
        local targetPosition = aimPart.Position
        
        if Settings.PredictMovement and aimPart.AssemblyLinearVelocity then
            local velocity = aimPart.AssemblyLinearVelocity
            local distance = (targetPosition - Camera.CFrame.Position).Magnitude
            local timeToTarget = distance / 1000
            targetPosition = targetPosition + (velocity * timeToTarget)
        end
        
        local camera = Camera
        local currentCFrame = camera.CFrame
        local targetCFrame = CFrame.lookAt(currentCFrame.Position, targetPosition)
        
        local lerpFactor = math.min(1 / Settings.Smoothness, 1)
        local lerpedCFrame = currentCFrame:Lerp(targetCFrame, lerpFactor)
        camera.CFrame = lerpedCFrame
    end
end

-- 🎮 ULTIMATE INPUT HANDLING
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.Insert then
        isMenuOpen = not isMenuOpen
        
        if isMenuOpen then
            menuFrame.Position = UDim2.new(0.5, -225, 0, -400)
            menuFrame.Visible = true
            TweenService:Create(menuFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Position = UDim2.new(0.5, -225, 0.5, -190)
            }):Play()
        else
            local slideOut = TweenService:Create(menuFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                Position = UDim2.new(0.5, -225, 1, 50)
            })
            slideOut:Play()
            slideOut.Completed:Connect(function()
                menuFrame.Visible = false
            end)
        end
    end
end)

-- RIGHT MOUSE BUTTON AIMBOT
mouse.Button2Down:Connect(function()
    if Settings.AimbotEnabled and not isMenuOpen then
        currentTarget = getClosestPlayer()
    end
end)

mouse.Button2Up:Connect(function()
    currentTarget = nil
end)

-- Enhanced dragging
titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        isDragging = true
        dragStart = input.Position
        startPos = menuFrame.Position
        TweenService:Create(menuFrame, TweenInfo.new(0.1), {Size = UDim2.new(0, 460, 0, 390)}):Play()
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        local newPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        TweenService:Create(menuFrame, TweenInfo.new(0.05), {Position = newPos}):Play()
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        isDragging = false
        TweenService:Create(menuFrame, TweenInfo.new(0.1), {Size = UDim2.new(0, 450, 0, 380)}):Play()
    end
end)

-- Close button
closeButton.MouseButton1Click:Connect(function()
    TweenService:Create(closeButton, TweenInfo.new(0.1), {Size = UDim2.new(0, 35, 0, 35)}):Play()
    wait(0.1)
    TweenService:Create(closeButton, TweenInfo.new(0.1), {Size = UDim2.new(0, 30, 0, 30)}):Play()
    
    isMenuOpen = false
    local slideOut = TweenService:Create(menuFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
        Position = UDim2.new(0.5, -225, 1, 50)
    })
    slideOut:Play()
    slideOut.Completed:Connect(function()
        menuFrame.Visible = false
    end)
end)

closeButton.MouseEnter:Connect(function()
    TweenService:Create(closeButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(255, 120, 140)}):Play()
end)

closeButton.MouseLeave:Connect(function()
    TweenService:Create(closeButton, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Danger}):Play()
end)

-- 🔄 ULTIMATE UPDATE LOOP
connections.RenderStepped = RunService.RenderStepped:Connect(function()
    updateUltimateESP()
    
    if currentTarget and Settings.AimbotEnabled then
        aimAt(currentTarget)
    end
    
    -- Crosshair pulse
    if Settings.CrosshairPulse then
        local pulse = 0.8 + 0.2 * math.sin(tick() * 4)
        for _, part in pairs(crosshairParts) do
            if part then
                part.BackgroundTransparency = 1 - pulse
            end
        end
    else
        for _, part in pairs(crosshairParts) do
            if part then
                part.BackgroundTransparency = 0
                part.BackgroundColor3 = Settings.CrosshairColor
            end
        end
    end
    
    -- FOV pulse
    local fovPulse = 0.6 + 0.1 * math.sin(tick() * 2)
    fovStroke.Transparency = fovPulse
    
    -- Border pulse
    local borderPulse = 0.2 + 0.1 * math.sin(tick() * 3)
    borderStroke.Transparency = borderPulse
end)

-- Player connections
connections.PlayerAdded = Players.PlayerAdded:Connect(function(newPlayer)
    newPlayer.CharacterAdded:Connect(function()
        wait(1)
        createUltimateESP(newPlayer)
    end)
end)

connections.PlayerRemoving = Players.PlayerRemoving:Connect(function(leftPlayer)
    if ESPObjects[leftPlayer] then
        local esp = ESPObjects[leftPlayer]
        if esp.Box then esp.Box:Remove() end
        if esp.Name then esp.Name:Remove() end
        if esp.Distance then esp.Distance:Remove() end
        if esp.Health then esp.Health:Remove() end
        if esp.Tracer then esp.Tracer:Remove() end
        if esp.Head then esp.Head:Remove() end
        ESPObjects[leftPlayer] = nil
    end
end)

-- Initialize
for _, existingPlayer in pairs(Players:GetPlayers()) do
    if existingPlayer ~= player and existingPlayer.Character then
        createUltimateESP(existingPlayer)
    end
end

createUltimateOverlayCrosshair()

-- Cleanup
local function cleanup()
    for _, connection in pairs(connections) do
        if connection then connection:Disconnect() end
    end
    
    for _, esp in pairs(ESPObjects) do
        if esp.Box then esp.Box:Remove() end
        if esp.Name then esp.Name:Remove() end
        if esp.Distance then esp.Distance:Remove() end
        if esp.Health then esp.Health:Remove() end
        if esp.Tracer then esp.Tracer:Remove() end
        if esp.Head then esp.Head:Remove() end
    end
    
    if screenGui then screenGui:Destroy() end
end

if _G.CleanupFunction then
    _G.CleanupFunction()
end
_G.CleanupFunction = cleanup

-- ULTIMATE WELCOME MESSAGE
spawn(function()
    wait(1)
    print("🌙 ULTIMATE OVERLAY SCRIPT v4.0 LOADED!")
    print("🚀 EVERYTHING OVERLAYS ALL ROBLOX UI!")
    print("🎮 Press INSERT to toggle ULTIMATE menu")
    print("🖱️ Hold RIGHT MOUSE BUTTON to aim")
    print("✨ Maximum overlay priority activated!")
    print("🎯 READY TO DOMINATE ROBLOX!")
end)
