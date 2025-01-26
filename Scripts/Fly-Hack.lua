local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local tweenService = game:GetService("TweenService")
local userInputService = game:GetService("UserInputService")
local runService = game:GetService("RunService")

-- GUI Creation
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FlyHackPremium"
screenGui.Parent = game:GetService("CoreGui")
screenGui.ResetOnSpawn = false

-- Main Window
local mainWindow = Instance.new("Frame")
mainWindow.Size = UDim2.new(0, 800, 0, 500)
mainWindow.Position = UDim2.new(0.5, -400, 0.5, -250)
mainWindow.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
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

-- Tabs Container
local tabsContainer = Instance.new("Frame")
tabsContainer.Size = UDim2.new(0, 200, 1, 0)
tabsContainer.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
tabsContainer.Parent = mainWindow

-- Add Corner Radius to Main Window
local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 10)
mainCorner.Parent = mainWindow

-- Create Tab Button Function
local function createTab(name, position)
    local tab = Instance.new("TextButton")
    tab.Size = UDim2.new(1, 0, 0, 50)
    tab.Position = position
    tab.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    tab.Text = name
    tab.TextColor3 = Color3.fromRGB(255, 255, 255)
    tab.Font = Enum.Font.GothamBold
    tab.TextSize = 16
    tab.Parent = tabsContainer
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = tab
    
    return tab
end

-- Create Tabs
local flyTab = createTab("FLY HACK", UDim2.new(0, 0, 0, 0))
local controlsTab = createTab("CONTROLS", UDim2.new(0, 0, 0, 50))
local unloadTab = createTab("UNLOAD SCRIPT", UDim2.new(0, 0, 0, 100))

-- Content Frames
local flyFrame = Instance.new("Frame")
flyFrame.Size = UDim2.new(0, 600, 1, 0)
flyFrame.Position = UDim2.new(0, 200, 0, 0)
flyFrame.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
flyFrame.Visible = true
flyFrame.Parent = mainWindow

local unloadFrame = Instance.new("Frame")
unloadFrame.Size = UDim2.new(0, 600, 1, 0)
unloadFrame.Position = UDim2.new(0, 200, 0, 0)
unloadFrame.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
unloadFrame.Visible = false
unloadFrame.Parent = mainWindow

local controlsFrame = Instance.new("Frame")
controlsFrame.Size = UDim2.new(0, 600, 1, 0)
controlsFrame.Position = UDim2.new(0, 200, 0, 0)
controlsFrame.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
controlsFrame.Visible = false
controlsFrame.Parent = mainWindow

-- Add Gradient to Frames
local function addGradient(parent)
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(240, 240, 240))
    })
    gradient.Rotation = 45
    gradient.Parent = parent
end

addGradient(flyFrame)
addGradient(unloadFrame)
addGradient(controlsFrame)

-- Fly Control Button
local flyButton = Instance.new("TextButton")
flyButton.Size = UDim2.new(0, 200, 0, 50)
flyButton.Position = UDim2.new(0.5, -100, 0.5, -25)
flyButton.BackgroundColor3 = Color3.fromRGB(50, 255, 50)
flyButton.Text = "Start Fly"
flyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
flyButton.Font = Enum.Font.GothamBold
flyButton.TextSize = 18
flyButton.Parent = flyFrame

local flyCorner = Instance.new("UICorner")
flyCorner.CornerRadius = UDim.new(0, 8)
flyCorner.Parent = flyButton

-- Unload Button
local unloadButton = Instance.new("TextButton")
unloadButton.Size = UDim2.new(0, 200, 0, 50)
unloadButton.Position = UDim2.new(0.5, -100, 0.5, -25)
unloadButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
unloadButton.Text = "UNLOAD SCRIPT"
unloadButton.TextColor3 = Color3.fromRGB(255, 255, 255)
unloadButton.Font = Enum.Font.GothamBold
unloadButton.TextSize = 18
unloadButton.Parent = unloadFrame

local unloadCorner = Instance.new("UICorner")
unloadCorner.CornerRadius = UDim.new(0, 8)
unloadCorner.Parent = unloadButton

-- Controls Text
local controlsText = Instance.new("TextLabel")
controlsText.Size = UDim2.new(1, 0, 1, 0)
controlsText.Position = UDim2.new(0, 0, 0, 0)
controlsText.BackgroundTransparency = 1
controlsText.Text = "Controls:\n\nW - Move Forward\nA - Move Left\nS - Move Backward\nD - Move Right\nSpace - Move Up\nLeftCtrl - Move Down"
controlsText.TextColor3 = Color3.fromRGB(0, 0, 0)
controlsText.Font = Enum.Font.Gotham
controlsText.TextSize = 20
controlsText.TextWrapped = true
controlsText.TextYAlignment = Enum.TextYAlignment.Top
controlsText.Parent = controlsFrame

-- Enhanced Flying Logic
local flying = false
local bodyVelocity
local gyro
local MAX_SPEED = 100
local ACCELERATION = 2
local currentSpeed = 0

local function startFlying()
    if not flying then
        flying = true
        
        -- Create BodyVelocity
        bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        bodyVelocity.Parent = player.Character.HumanoidRootPart
        
        -- Create BodyGyro for stability
        gyro = Instance.new("BodyGyro")
        gyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        gyro.D = 50
        gyro.P = 5000
        gyro.Parent = player.Character.HumanoidRootPart
        
        -- Disable character animations
        player.Character.Humanoid.PlatformStand = true
        
        runService.RenderStepped:Connect(function(delta)
            if flying then
                -- Update gyro orientation
                gyro.CFrame = workspace.CurrentCamera.CFrame
                
                -- Calculate movement direction
                local moveDirection = Vector3.new(0, 0, 0)
                if userInputService:IsKeyDown(Enum.KeyCode.W) then
                    moveDirection = moveDirection + workspace.CurrentCamera.CFrame.LookVector
                end
                if userInputService:IsKeyDown(Enum.KeyCode.S) then
                    moveDirection = moveDirection - workspace.CurrentCamera.CFrame.LookVector
                end
                if userInputService:IsKeyDown(Enum.KeyCode.A) then
                    moveDirection = moveDirection - workspace.CurrentCamera.CFrame.RightVector
                end
                if userInputService:IsKeyDown(Enum.KeyCode.D) then
                    moveDirection = moveDirection + workspace.CurrentCamera.CFrame.RightVector
                end
                if userInputService:IsKeyDown(Enum.KeyCode.Space) then
                    moveDirection = moveDirection + Vector3.new(0, 1, 0)
                end
                if userInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                    moveDirection = moveDirection - Vector3.new(0, 1, 0)
                end
                
                -- Normalize movement direction
                if moveDirection.Magnitude > 0 then
                    moveDirection = moveDirection.Unit
                    currentSpeed = math.min(currentSpeed + ACCELERATION, MAX_SPEED)
                else
                    currentSpeed = math.max(currentSpeed - ACCELERATION * 2, 0)
                end
                
                -- Apply velocity with smooth acceleration
                bodyVelocity.Velocity = moveDirection * currentSpeed
            end
        end)
    end
end

local function stopFlying()
    if flying then
        flying = false
        currentSpeed = 0
        
        if bodyVelocity then
            bodyVelocity:Destroy()
        end
        if gyro then
            gyro:Destroy()
        end
        
        -- Re-enable character animations
        player.Character.Humanoid.PlatformStand = false
    end
end

-- Unload Script Logic
unloadButton.MouseButton1Click:Connect(function()
    if flying then
        stopFlying()
        flyButton.Text = "Start Fly"
    end
    
    local humanoid = player.Character and player.Character:FindFirstChild("Humanoid")
    if humanoid then
        humanoid.WalkSpeed = 16
    end
    
    screenGui:Destroy()
end)

-- Comet Effect
local function createComet()
    local comet = Instance.new("Frame")
    comet.Size = UDim2.new(0, 4, 0, 4)
    comet.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    comet.BorderSizePixel = 0
    comet.Parent = mainWindow
    
    for i = 1, 5 do
        local trail = Instance.new("Frame")
        trail.Size = UDim2.new(0, 25 - (i * 4), 0, 3 - (i * 0.4))
        trail.Position = UDim2.new(0, -(25 - (i * 4)), 0, 0.5)
        trail.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        trail.BackgroundTransparency = 0.2 * i
        trail.BorderSizePixel = 0
        trail.Parent = comet
        
        local glow = Instance.new("ImageLabel")
        glow.Size = UDim2.new(1.2, 0, 1.2, 0)
        glow.Position = UDim2.new(-0.1, 0, -0.1, 0)
        glow.BackgroundTransparency = 1
        glow.Image = "rbxassetid://7331079227"
        glow.ImageColor3 = Color3.fromRGB(0, 0, 0)
        glow.ImageTransparency = 0.5 + (0.1 * i)
        glow.Parent = trail
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
    
    local tween = tweenService:Create(comet, tweenInfo, {
        Position = UDim2.new(0, endX, 0, endY),
        BackgroundTransparency = 1
    })
    
    tween:Play()
    tween.Completed:Connect(function()
        comet:Destroy()
    end)
end

-- Spawn Comets Continuously
spawn(function()
    while wait(0.2) do
        if mainWindow.Visible then
            createComet()
        end
    end
end)

-- Button Functionality
flyButton.MouseButton1Click:Connect(function()
    if flying then
        stopFlying()
        flyButton.Text = "Start Fly"
    else
        startFlying()
        flyButton.Text = "Stop Fly"
    end
end)

-- Tab Switching Logic
flyTab.MouseButton1Click:Connect(function()
    flyFrame.Visible = true
    unloadFrame.Visible = false
    controlsFrame.Visible = false
end)

unloadTab.MouseButton1Click:Connect(function()
    flyFrame.Visible = false
    unloadFrame.Visible = true
    controlsFrame.Visible = false
end)

controlsTab.MouseButton1Click:Connect(function()
    flyFrame.Visible = false
    unloadFrame.Visible = false
    controlsFrame.Visible = true
end)

-- Toggle GUI Visibility with Insert
userInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.Insert then
        screenGui.Enabled = not screenGui.Enabled
    end
end)

-- Initialize GUI State
flyFrame.Visible = true
unloadFrame.Visible = false
controlsFrame.Visible = false
mainWindow.Visible = true
