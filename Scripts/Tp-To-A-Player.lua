loadstring(game:HttpGet("https://raw.githubusercontent.com/SYFER-eng/Roblox-Menu-Hub/refs/heads/main/Loading/Tp.lua",true))()
local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local tweenService = game:GetService("TweenService")
local userInputService = game:GetService("UserInputService")
local runService = game:GetService("RunService")
local menuVisible = true
local isDragging = false
local dragStart = nil
local startPos = nil

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
screenGui.Name = "Syfer-eng's Teloport Cheat"
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
title.Text = "Syfer-eng │ Teloport"
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

-- Create TP Tab
local tpTab = Instance.new("TextButton")
tpTab.Size = UDim2.new(0.5, 0, 1, 0)
tpTab.Position = UDim2.new(0, 0, 0, 0)
tpTab.BackgroundColor3 = COLORS.TAB_ACCENT
tpTab.Text = "Teleport"
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

-- Create TP Content
local tpContent = Instance.new("Frame")
tpContent.Size = UDim2.new(1, 0, 1, 0)
tpContent.BackgroundTransparency = 1
tpContent.Visible = true
tpContent.Parent = contentContainer

-- Create Player List
local playerList = Instance.new("ScrollingFrame")
playerList.Size = UDim2.new(0.9, 0, 0.7, 0)
playerList.Position = UDim2.new(0.05, 0, 0.12, 0)
playerList.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
playerList.BorderSizePixel = 0
playerList.ScrollBarThickness = 6
playerList.Parent = tpContent

-- Create Reload Button
local reloadButton = Instance.new("TextButton")
reloadButton.Size = UDim2.new(0.3, 0, 0.06, 0)
reloadButton.Position = UDim2.new(0.35, 0, 0.92, 0)
reloadButton.BackgroundColor3 = COLORS.ACCENT
reloadButton.Text = "Reload List"
reloadButton.TextColor3 = COLORS.TEXT
reloadButton.TextSize = 16
reloadButton.Font = Enum.Font.GothamBold
reloadButton.Parent = tpContent
enhanceButton(reloadButton, false)

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
unloadButton.Text = "Unload Menu"
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

addCorners(playerList)
addCorners(reloadButton)
addCorners(unloadButton)
addCorners(tpTab)
addCorners(unloadTab)

-- Function to create player button
local function createPlayerButton(plr)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0.95, 0, 0, 40)
    button.BackgroundColor3 = COLORS.ACCENT
    button.Text = plr.Name
    button.TextColor3 = COLORS.TEXT
    button.TextSize = 16
    button.Font = Enum.Font.GothamSemibold
    button.Parent = playerList
    enhanceButton(button, false)
    addCorners(button)
    
    button.MouseButton1Click:Connect(function()
        if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = plr.Character.HumanoidRootPart.CFrame
        end
    end)
    
    return button
end

-- Function to update player list
local function updatePlayerList()
    for _, child in ipairs(playerList:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    
    local yOffset = 5
    for _, plr in ipairs(game.Players:GetPlayers()) do
        if plr ~= player then
            local button = createPlayerButton(plr)
            button.Position = UDim2.new(0.025, 0, 0, yOffset)
            yOffset = yOffset + 45
        end
    end
    
    playerList.CanvasSize = UDim2.new(0, 0, 0, yOffset)
end

-- Flying Logic
local flying = false
local bodyVelocity

local function startFlying()
    if not flying then
        flying = true
        bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.MaxForce = Vector3.new(400000, 400000, 400000)
        bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        bodyVelocity.Parent = player.Character.HumanoidRootPart
        
        runService.Heartbeat:Connect(function()
            if flying then
                local moveDirection = Vector3.new(0, 0, 0)
                if userInputService:IsKeyDown(Enum.KeyCode.W) then
                    moveDirection = moveDirection + player.Character.HumanoidRootPart.CFrame.LookVector
                end
                if userInputService:IsKeyDown(Enum.KeyCode.A) then
                    moveDirection = moveDirection - player.Character.HumanoidRootPart.CFrame.RightVector
                end
                if userInputService:IsKeyDown(Enum.KeyCode.S) then
                    moveDirection = moveDirection - player.Character.HumanoidRootPart.CFrame.LookVector
                end
                if userInputService:IsKeyDown(Enum.KeyCode.D) then
                    moveDirection = moveDirection + player.Character.HumanoidRootPart.CFrame.RightVector
                end
                if userInputService:IsKeyDown(Enum.KeyCode.Space) then
                    moveDirection = moveDirection + Vector3.new(0, 1, 0)
                end
                if userInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                    moveDirection = moveDirection - Vector3.new(0, 1, 0)
                end
                
                bodyVelocity.Velocity = moveDirection * 50
            end
        end)
    end
end

local function stopFlying()
    if flying then
        flying = false
        if bodyVelocity then
            bodyVelocity:Destroy()
        end
    end
end

-- Rainbow Comet Effect
local function createComet()
    local comet = Instance.new("Frame")
    comet.Size = UDim2.new(0, 4, 0, 4)
    comet.BorderSizePixel = 0
    comet.Parent = mainWindow
    
    local startColor = getRainbowColor()
    comet.BackgroundColor3 = startColor
    
    for i = 1, 5 do
        local trail = Instance.new("Frame")
        trail.Size = UDim2.new(0, 25 - (i * 4), 0, 3 - (i * 0.4))
        trail.Position = UDim2.new(0, -(25 - (i * 4)), 0, 0.5)
        trail.BackgroundColor3 = startColor
        trail.BackgroundTransparency = 0.2 * i
        trail.BorderSizePixel = 0
        trail.Parent = comet
        
        local glow = Instance.new("ImageLabel")
        glow.Size = UDim2.new(1.2, 0, 1.2, 0)
        glow.Position = UDim2.new(-0.1, 0, -0.1, 0)
        glow.BackgroundTransparency = 1
        glow.Image = "rbxassetid://7331079227"
        glow.ImageColor3 = startColor
        glow.ImageTransparency = 0.5 + (0.1 * i)
        glow.Parent = trail
        
        spawn(function()
            while trail.Parent do
                trail.BackgroundColor3 = getRainbowColor(i * 0.1)
                glow.ImageColor3 = getRainbowColor(i * 0.1)
                wait(0.1)
            end
        end)
    end
    
    local startX = math.random(-50, 0)
    local startY = math.random(0, mainWindow.AbsoluteSize.Y)
    comet.Position = UDim2.new(0, startX, 0, startY)
    local endX = mainWindow.AbsoluteSize.X + 50
    local endY = startY + math.random(100, 200)
    
    local tweenInfo = TweenInfo.new(
        math.random(8, 12) / 10,
        Enum.EasingStyle.Linear
    )
    
    spawn(function()
        while comet.Parent do
            comet.BackgroundColor3 = getRainbowColor()
            wait(0.1)
        end
    end)
    
    local tween = tweenService:Create(comet, tweenInfo, {
        Position = UDim2.new(0, endX, 0, endY),
        BackgroundTransparency = 1
    })
    
    tween:Play()
    tween.Completed:Connect(function()
        comet:Destroy()
    end)
end

-- Spawn Rainbow Comets
spawn(function()
    while wait(0.2) do
        if mainWindow.Visible then
            createComet()
        end
    end
end)

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

-- Reload Button Logic
reloadButton.MouseButton1Click:Connect(function()
    reloadButton.BackgroundColor3 = COLORS.DARK_ACCENT
    updatePlayerList()
    wait(0.1)
    reloadButton.BackgroundColor3 = COLORS.ACCENT
end)

-- Unload Button Logic
unloadButton.MouseButton1Click:Connect(function()
    if flying then
        stopFlying()
    end
    screenGui:Destroy()
end)

-- Auto Update Player List
spawn(function()
    while wait(1) do
        if tpContent.Visible then
            updatePlayerList()
        end
    end
end)

-- Player Join/Leave Updates
game.Players.PlayerAdded:Connect(updatePlayerList)
game.Players.PlayerRemoving:Connect(updatePlayerList)

-- Flying Toggle
userInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.Insert then
        menuVisible = not menuVisible
        screenGui.Enabled = menuVisible
    end
end)

-- Initialize GUI
mainWindow.Visible = true
updatePlayerList()
