local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local tweenService = game:GetService("TweenService")
local userInputService = game:GetService("UserInputService")
local runService = game:GetService("RunService")

-- GUI Creation
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MenuLibrary"
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

-- Shadow for Main Window
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

-- Tab Button Function
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
local tab1 = createTab("Tab 1", UDim2.new(0, 0, 0, 0))
local tab2 = createTab("Tab 2", UDim2.new(0, 0, 0, 50))
local tab3 = createTab("Tab 3", UDim2.new(0, 0, 0, 100))

-- Content Frames
local tab1Frame = Instance.new("Frame")
tab1Frame.Size = UDim2.new(0, 600, 1, 0)
tab1Frame.Position = UDim2.new(0, 200, 0, 0)
tab1Frame.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
tab1Frame.Visible = true
tab1Frame.Parent = mainWindow

local tab2Frame = Instance.new("Frame")
tab2Frame.Size = UDim2.new(0, 600, 1, 0)
tab2Frame.Position = UDim2.new(0, 200, 0, 0)
tab2Frame.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
tab2Frame.Visible = false
tab2Frame.Parent = mainWindow

local tab3Frame = Instance.new("Frame")
tab3Frame.Size = UDim2.new(0, 600, 1, 0)
tab3Frame.Position = UDim2.new(0, 200, 0, 0)
tab3Frame.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
tab3Frame.Visible = false
tab3Frame.Parent = mainWindow

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

addGradient(tab1Frame)
addGradient(tab2Frame)
addGradient(tab3Frame)

-- Button Example in Tab 1
local button1 = Instance.new("TextButton")
button1.Size = UDim2.new(0, 200, 0, 50)
button1.Position = UDim2.new(0.5, -100, 0.5, -25)
button1.BackgroundColor3 = Color3.fromRGB(50, 255, 50)
button1.Text = "Button 1"
button1.TextColor3 = Color3.fromRGB(255, 255, 255)
button1.Font = Enum.Font.GothamBold
button1.TextSize = 18
button1.Parent = tab1Frame

local button1Corner = Instance.new("UICorner")
button1Corner.CornerRadius = UDim.new(0, 8)
button1Corner.Parent = button1

-- Button Example in Tab 2
local button2 = Instance.new("TextButton")
button2.Size = UDim2.new(0, 200, 0, 50)
button2.Position = UDim2.new(0.5, -100, 0.5, -25)
button2.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
button2.Text = "Button 2"
button2.TextColor3 = Color3.fromRGB(255, 255, 255)
button2.Font = Enum.Font.GothamBold
button2.TextSize = 18
button2.Parent = tab2Frame

local button2Corner = Instance.new("UICorner")
button2Corner.CornerRadius = UDim.new(0, 8)
button2Corner.Parent = button2

-- Button Example in Tab 3
local button3 = Instance.new("TextButton")
button3.Size = UDim2.new(0, 200, 0, 50)
button3.Position = UDim2.new(0.5, -100, 0.5, -25)
button3.BackgroundColor3 = Color3.fromRGB(50, 50, 255)
button3.Text = "Button 3"
button3.TextColor3 = Color3.fromRGB(255, 255, 255)
button3.Font = Enum.Font.GothamBold
button3.TextSize = 18
button3.Parent = tab3Frame

local button3Corner = Instance.new("UICorner")
button3Corner.CornerRadius = UDim.new(0, 8)
button3Corner.Parent = button3

-- Tab Switching Logic with Animations
local function showTab(tabFrame)
    local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    local goal = {Position = UDim2.new(0, 200, 0, 0)}
    tweenService:Create(tabFrame, tweenInfo, goal):Play()
end

tab1.MouseButton1Click:Connect(function()
    tab1Frame.Visible = true
    tab2Frame.Visible = false
    tab3Frame.Visible = false
    showTab(tab1Frame)
end)

tab2.MouseButton1Click:Connect(function()
    tab1Frame.Visible = false
    tab2Frame.Visible = true
    tab3Frame.Visible = false
    showTab(tab2Frame)
end)

tab3.MouseButton1Click:Connect(function()
    tab1Frame.Visible = false
    tab2Frame.Visible = false
    tab3Frame.Visible = true
    showTab(tab3Frame)
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
    local goal = {Position = UDim2.new(0, endX, 0, endY)}
    tweenService:Create(comet, tweenInfo, goal):Play()
    
    comet:Destroy()
end

-- Create Random Comets Every Few Seconds
runService.Heartbeat:Connect(function()
    if math.random() < 0.02 then
        createComet()
    end
end)

-- Toggle GUI Visibility with Insert key
userInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.Insert then
        screenGui.Enabled = not screenGui.Enabled
    end
end)

-- Initialize GUI State
tab1Frame.Visible = true
tab2Frame.Visible = false
tab3Frame.Visible = false
mainWindow.Visible = true
