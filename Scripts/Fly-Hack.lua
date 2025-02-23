loadstring(game:HttpGet("https://raw.githubusercontent.com/SYFER-eng/Roblox-Menu-Hub/refs/heads/main/Loading/Fly.lua",true))()
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

local controlsFrame = Instance.new("Frame")
controlsFrame.Size = UDim2.new(0, 600, 1, 0)
controlsFrame.Position = UDim2.new(0, 200, 0, 0)
controlsFrame.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
controlsFrame.Visible = false
controlsFrame.Parent = mainWindow

local unloadFrame = Instance.new("Frame")
unloadFrame.Size = UDim2.new(0, 600, 1, 0)
unloadFrame.Position = UDim2.new(0, 200, 0, 0)
unloadFrame.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
unloadFrame.Visible = false
unloadFrame.Parent = mainWindow

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
addGradient(controlsFrame)
addGradient(unloadFrame)

-- Fly Control Button
local flyButton = Instance.new("TextButton")
flyButton.Size = UDim2.new(0, 200, 0, 50)
flyButton.Position = UDim2.new(0.5, -100, 0.3, -25)
flyButton.BackgroundColor3 = Color3.fromRGB(50, 255, 50)
flyButton.Text = "Start Fly"
flyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
flyButton.Font = Enum.Font.GothamBold
flyButton.TextSize = 18
flyButton.Parent = flyFrame

local flyCorner = Instance.new("UICorner")
flyCorner.CornerRadius = UDim.new(0, 8)
flyCorner.Parent = flyButton

-- Speed Slider Container
local sliderContainer = Instance.new("Frame")
sliderContainer.Size = UDim2.new(0, 400, 0, 60)
sliderContainer.Position = UDim2.new(0.5, -200, 0.7, -30)
sliderContainer.BackgroundTransparency = 1
sliderContainer.Parent = flyFrame

-- Speed Label
local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(1, 0, 0, 20)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "Flying Speed: 100"
speedLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
speedLabel.Font = Enum.Font.GothamBold
speedLabel.TextSize = 14
speedLabel.Parent = sliderContainer

-- Slider Background
local sliderBg = Instance.new("Frame")
sliderBg.Size = UDim2.new(1, 0, 0, 10)
sliderBg.Position = UDim2.new(0, 0, 0, 30)
sliderBg.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
sliderBg.Parent = sliderContainer

local sliderBgCorner = Instance.new("UICorner")
sliderBgCorner.CornerRadius = UDim.new(0, 5)
sliderBgCorner.Parent = sliderBg

-- Slider Fill
local sliderFill = Instance.new("Frame")
sliderFill.Size = UDim2.new(0.5, 0, 1, 0)
sliderFill.BackgroundColor3 = Color3.fromRGB(50, 255, 50)
sliderFill.Parent = sliderBg

local sliderFillCorner = Instance.new("UICorner")
sliderFillCorner.CornerRadius = UDim.new(0, 5)
sliderFillCorner.Parent = sliderFill

-- Slider Knob
local sliderKnob = Instance.new("TextButton")
sliderKnob.Size = UDim2.new(0, 20, 0, 20)
sliderKnob.Position = UDim2.new(0.5, -10, 0, -5)
sliderKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
sliderKnob.Text = ""
sliderKnob.Parent = sliderBg

local sliderKnobCorner = Instance.new("UICorner")
sliderKnobCorner.CornerRadius = UDim.new(1, 0)
sliderKnobCorner.Parent = sliderKnob

-- Controls Text
local controlsText = Instance.new("TextLabel")
controlsText.Size = UDim2.new(1, 0, 1, 0)
controlsText.Position = UDim2.new(0, 0, 0, 0)
controlsText.BackgroundTransparency = 1
controlsText.Text = "Controls:\n\nW - Move Forward\nA - Move Left\nS - Move Backward\nD - Move Right\nSpace - Move Up\nLeftCtrl - Move Down\nInsert - Toggle GUI"
controlsText.TextColor3 = Color3.fromRGB(0, 0, 0)
controlsText.Font = Enum.Font.Gotham
controlsText.TextSize = 20
controlsText.TextWrapped = true
controlsText.TextYAlignment = Enum.TextYAlignment.Top
controlsText.Parent = controlsFrame

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

-- Comet Effect
local function createComet()
    local comet = Instance.new("Frame")
    comet.Size = UDim2.new(0, 4, 0, 4)
    comet.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    comet.BorderSizePixel = 0
    comet.Parent = mainWindow
    
    local startX = math.random(-50, 0)
    local startY = math.random(0, mainWindow.AbsoluteSize.Y)
    comet.Position = UDim2.new(0, startX, 0, startY)
    
    local endX = mainWindow.AbsoluteSize.X + 50
    local endY = startY + math.random(-200, 200)
    
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

-- Spawn Comets
spawn(function()
    while wait(0.2) do
        if mainWindow.Visible then
            createComet()
        end
    end
end)

-- Slider Logic
local isDragging = false
local MAX_SPEED = 100
local minSpeed = 20

sliderKnob.MouseButton1Down:Connect(function()
    isDragging = true
end)

userInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        isDragging = false
    end
end)

userInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement and isDragging then
        local mousePos = userInputService:GetMouseLocation()
        local sliderPos = sliderBg.AbsolutePosition
        local sliderSize = sliderBg.AbsoluteSize
        
        local relativeX = math.clamp((mousePos.X - sliderPos.X) / sliderSize.X, 0, 1)
        sliderFill.Size = UDim2.new(relativeX, 0, 1, 0)
        sliderKnob.Position = UDim2.new(relativeX, -10, 0, -5)
        
        MAX_SPEED = minSpeed + (relativeX * (500 - minSpeed))
        speedLabel.Text = string.format("Flying Speed: %d", MAX_SPEED)
    end
end)

-- Enhanced Flying Logic
local flying = false
local bodyVelocity
local gyro
local currentSpeed = 0

local function getRoot()
    local character = player.Character
    if character then
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid and humanoid.SeatPart then
            return humanoid.SeatPart
        end
        return character:FindFirstChild("HumanoidRootPart")
    end
    return nil
end

local function startFlying()
    if not flying then
        flying = true
        
        local root = getRoot()
        if root then
            bodyVelocity = Instance.new("BodyVelocity")
            bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            bodyVelocity.Velocity = Vector3.new(0, 0, 0)
            bodyVelocity.Parent = root
            
            gyro = Instance.new("BodyGyro")
            gyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
            gyro.D = 50
            gyro.P = 5000
            gyro.Parent = root
            
            if player.Character:FindFirstChild("Humanoid") then
                player.Character.Humanoid.PlatformStand = true
            end
        end
        
        runService.RenderStepped:Connect(function(delta)
            if flying then
                local root = getRoot()
                if root then
                    gyro.CFrame = workspace.CurrentCamera.CFrame
                    
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
                    
                    if moveDirection.Magnitude > 0 then
                        moveDirection = moveDirection.Unit
                        currentSpeed = math.min(currentSpeed + 2, MAX_SPEED)
                    else
                        currentSpeed = math.max(currentSpeed - 4, 0)
                    end
                    
                    bodyVelocity.Velocity = moveDirection * currentSpeed
                end
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
        
        local humanoid = player.Character and player.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.PlatformStand = false
        end
    end
end

-- Button Functionality
flyButton.MouseButton1Click:Connect(function()
    if flying then
        stopFlying()
        flyButton.Text = "Start Fly"
        flyButton.BackgroundColor3 = Color3.fromRGB(50, 255, 50)
    else
        startFlying()
        flyButton.Text = "Stop Fly"
        flyButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    end
end)

-- Tab Switching Logic
flyTab.MouseButton1Click:Connect(function()
    flyFrame.Visible = true
    controlsFrame.Visible = false
    unloadFrame.Visible = false
end)

controlsTab.MouseButton1Click:Connect(function()
    flyFrame.Visible = false
    controlsFrame.Visible = true
    unloadFrame.Visible = false
end)

unloadTab.MouseButton1Click:Connect(function()
    flyFrame.Visible = false
    controlsFrame.Visible = false
    unloadFrame.Visible = true
end)

-- Unload Script Logic
unloadButton.MouseButton1Click:Connect(function()
    if flying then
        stopFlying()
    end
    screenGui:Destroy()
end)

-- Toggle GUI Visibility with Insert
userInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.Insert then
        screenGui.Enabled = not screenGui.Enabled
    end
end)

-- Initialize GUI State
flyFrame.Visible = true
controlsFrame.Visible = false
unloadFrame.Visible = false
mainWindow.Visible = true
