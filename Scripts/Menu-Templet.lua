local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local tweenService = game:GetService("TweenService")
local userInputService = game:GetService("UserInputService")
local runService = game:GetService("RunService")
local menuVisible = true

-- Color Scheme
local COLORS = {
    BACKGROUND = Color3.fromRGB(20, 20, 25),
    ACCENT = Color3.fromRGB(175, 74, 235),
    TEXT = Color3.fromRGB(255, 255, 255),
    HIGHLIGHT = Color3.fromRGB(160, 120, 240),
    DARK_ACCENT = Color3.fromRGB(100, 80, 160),
    TAB_ACCENT = Color3.fromRGB(147, 112, 219)
}

-- Rainbow Color Function
local function getRainbowColor(offset)
    local tick = tick() + (offset or 0)
    return Color3.fromHSV(tick % 5 / 5, 1, 1)
end

-- GUI Creation
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "Placeholder Menu"
screenGui.Parent = game:GetService("CoreGui")
screenGui.ResetOnSpawn = false

-- Main Window
local mainWindow = Instance.new("Frame")
mainWindow.Size = UDim2.new(0, 800, 0, 500)
mainWindow.Position = UDim2.new(0.5, -400, 0.5, -250)
mainWindow.BackgroundColor3 = COLORS.BACKGROUND
mainWindow.BorderSizePixel = 0
mainWindow.Active = true
mainWindow.Draggable = true
mainWindow.ClipsDescendants = true
mainWindow.Parent = screenGui

-- Add Shadow
local shadow = Instance.new("ImageLabel")
shadow.Size = UDim2.new(1.02, 0, 1.02, 0)
shadow.Position = UDim2.new(-0.01, 0, -0.01, 0)
shadow.BackgroundTransparency = 1
shadow.Image = "rbxassetid://297774371"
shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
shadow.ImageTransparency = 0.7
shadow.Parent = mainWindow

-- Add Corner Radius to Main Window
local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 10)
mainCorner.Parent = mainWindow

-- Add Purple Gradient
local function addPurpleGradient(parent)
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, COLORS.BACKGROUND),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 25, 35))
    })
    gradient.Rotation = 45
    gradient.Parent = parent
end

addPurpleGradient(mainWindow)

-- Add Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(0.4, 0, 0.06, 0)
title.Position = UDim2.new(0.3, 0, 0.02, 0)
title.BackgroundTransparency = 1
title.Text = "Placeholder Menu"
title.TextColor3 = COLORS.TEXT
title.TextSize = 24
title.Font = Enum.Font.GothamBold
title.Parent = mainWindow

-- Add Text Stroke to Title
local titleStroke = Instance.new("UIStroke")
titleStroke.Color = Color3.fromRGB(0, 0, 0)
titleStroke.Thickness = 1
titleStroke.Parent = title

-- Create Tab Container
local tabContainer = Instance.new("Frame")
tabContainer.Size = UDim2.new(1, 0, 0.1, 0)
tabContainer.Position = UDim2.new(0, 0, 0.1, 0)
tabContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
tabContainer.BorderSizePixel = 0
tabContainer.Parent = mainWindow

-- Create Content Container
local contentContainer = Instance.new("Frame")
contentContainer.Size = UDim2.new(1, 0, 0.9, 0)
contentContainer.Position = UDim2.new(0, 0, 0.1, 0)
contentContainer.BackgroundTransparency = 1
contentContainer.Parent = mainWindow

-- Button Enhancement Function
local function enhanceButton(button, isTab)
    button.BackgroundColor3 = isTab and COLORS.TAB_ACCENT or COLORS.ACCENT
    button.TextColor3 = COLORS.TEXT
    
    local textStroke = Instance.new("UIStroke")
    textStroke.Color = Color3.fromRGB(0, 0, 0)
    textStroke.Thickness = 1
    textStroke.Parent = button
    
    local highlight = Instance.new("UIStroke")
    highlight.Color = COLORS.HIGHLIGHT
    highlight.Thickness = 2
    highlight.Transparency = 0.5
    highlight.Parent = button
    
    button.MouseEnter:Connect(function()
        tweenService:Create(highlight, TweenInfo.new(0.3), {
            Transparency = 0,
            Color = COLORS.HIGHLIGHT
        }):Play()
    end)
    
    button.MouseLeave:Connect(function()
        tweenService:Create(highlight, TweenInfo.new(0.3), {
            Transparency = 0.5,
            Color = isTab and COLORS.TAB_ACCENT or COLORS.ACCENT
        }):Play()
    end)
end

-- Create Placeholder Tabs
local tpTab = Instance.new("TextButton")
tpTab.Size = UDim2.new(0.5, 0, 1, 0)
tpTab.Position = UDim2.new(0, 0, 0, 0)
tpTab.BackgroundColor3 = COLORS.TAB_ACCENT
tpTab.Text = "Placeholder"
tpTab.TextColor3 = COLORS.TEXT
tpTab.TextSize = 18
tpTab.Font = Enum.Font.GothamBold
tpTab.Parent = tabContainer
enhanceButton(tpTab, true)

-- Create Unload Tab
local unloadTab = Instance.new("TextButton")
unloadTab.Size = UDim2.new(0.5, 0, 1, 0)
unloadTab.Position = UDim2.new(0.5, 0, 0, 0)
unloadTab.BackgroundColor3 = COLORS.DARK_ACCENT
unloadTab.Text = "Unload"
unloadTab.TextColor3 = COLORS.TEXT
unloadTab.TextSize = 18
unloadTab.Font = Enum.Font.GothamBold
unloadTab.Parent = tabContainer
enhanceButton(unloadTab, true)

-- Create Placeholder Content
local tpContent = Instance.new("Frame")
tpContent.Size = UDim2.new(1, 0, 1, 0)
tpContent.BackgroundTransparency = 1
tpContent.Visible = true
tpContent.Parent = contentContainer

-- Create Unload Content
local unloadContent = Instance.new("Frame")
unloadContent.Size = UDim2.new(1, 0, 1, 0)
unloadContent.BackgroundTransparency = 1
unloadContent.Visible = false
unloadContent.Parent = contentContainer

-- Create Unload Button
local unloadButton = Instance.new("TextButton")
unloadButton.Size = UDim2.new(0.3, 0, 0.1, 0)
unloadButton.Position = UDim2.new(0.35, 0, 0.45, 0)
unloadButton.BackgroundColor3 = COLORS.TAB_ACCENT
unloadButton.Text = "Unload"
unloadButton.TextColor3 = COLORS.TEXT
unloadButton.TextSize = 18
unloadButton.Font = Enum.Font.GothamBold
unloadButton.Parent = unloadContent
enhanceButton(unloadButton, true)

-- Add Corner Radius to elements
local function addCorners(button)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = button
end

addCorners(unloadButton)
addCorners(tpTab)
addCorners(unloadTab)

-- Tab Switching Logic
tpTab.MouseButton1Click:Connect(function()
    tweenService:Create(tpContent, TweenInfo.new(0.3), {Position = UDim2.new(0, 0, 0, 0)}):Play()
    tweenService:Create(unloadContent, TweenInfo.new(0.3), {Position = UDim2.new(1, 0, 0, 0)}):Play()
    tpContent.Visible = true
    unloadContent.Visible = false
    tpTab.BackgroundColor3 = COLORS.TAB_ACCENT
    unloadTab.BackgroundColor3 = COLORS.DARK_ACCENT
end)

unloadTab.MouseButton1Click:Connect(function()
    tweenService:Create(tpContent, TweenInfo.new(0.3), {Position = UDim2.new(-1, 0, 0, 0)}):Play()
    tweenService:Create(unloadContent, TweenInfo.new(0.3), {Position = UDim2.new(0, 0, 0, 0)}):Play()
    tpContent.Visible = false
    unloadContent.Visible = true
    tpTab.BackgroundColor3 = COLORS.DARK_ACCENT
    unloadTab.BackgroundColor3 = COLORS.TAB_ACCENT
end)

-- Create Rainbow Comet Effect
local function createRainbowComet()
    local comet = Instance.new("ImageLabel")
    comet.Size = UDim2.new(0, 40, 0, 40)
    comet.Position = UDim2.new(math.random(), 0, math.random(), 0)
    comet.BackgroundTransparency = 1
    comet.Image = "rbxassetid://4456604994"  -- Image ID for comet-like texture
    comet.ImageColor3 = getRainbowColor(math.random())  -- Randomize initial color
    comet.Parent = mainWindow

    -- Move comet across the screen
    local startPosition = comet.Position
    local endPosition = UDim2.new(math.random(), 0, math.random(), 0)
    local goalSize = UDim2.new(0, 80, 0, 80)  -- Increase the size for a more dramatic effect

    -- Animating the comet's movement and color change
    local cometTween = tweenService:Create(comet, TweenInfo.new(5, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, true), {
        Position = endPosition,
        Size = goalSize
    })

    local colorTween = tweenService:Create(comet, TweenInfo.new(5, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, true), {
        ImageColor3 = getRainbowColor(math.random())
    })

    cometTween:Play()
    colorTween:Play()

    -- Destroy comet after some time
    game.Debris:AddItem(comet, 5)
end

-- Continuously create rainbow comets
runService.Heartbeat:Connect(function()
    if math.random() < 0.1 then  -- Controls how often the comets appear
        createRainbowComet()
    end
end)

-- Unload Button Logic (Does nothing)
unloadButton.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- Toggle Menu Visibility
userInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.Insert then
        menuVisible = not menuVisible
        screenGui.Enabled = menuVisible
    end
end)

-- Initialize GUI
mainWindow.Visible = true
