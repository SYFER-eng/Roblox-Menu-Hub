local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local tweenService = game:GetService("TweenService")
local userInputService = game:GetService("UserInputService")
local runService = game:GetService("RunService")

-- GUI Creation
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "Syfer-eng Menu Templet"
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

-- Add Corner Radius to Main Window
local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 10)
mainCorner.Parent = mainWindow

-- Add Gradient to Main Window
local function addGradient(parent)
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(240, 240, 240))
    })
    gradient.Rotation = 45
    gradient.Parent = parent
end

addGradient(mainWindow)

-- Tabs on the Left (Centered Vertically)
local tabContainer = Instance.new("Frame")
tabContainer.Size = UDim2.new(0, 200, 1, 0)  -- Full height
tabContainer.Position = UDim2.new(0, 0, 0, 0)
tabContainer.BackgroundColor3 = Color3.fromRGB(0, 0, 0)  -- Pitch black background
tabContainer.BorderSizePixel = 0
tabContainer.Parent = mainWindow

-- Center the tabs vertically in the tab container
local totalTabs = 3
local tabHeight = 50
local spacing = 20  -- Increased space between tabs
local totalHeight = totalTabs * tabHeight + (totalTabs - 1) * spacing
local startY = (tabContainer.AbsoluteSize.Y - totalHeight) / 2  -- Centered position

local function createTab(name, positionY)
    local tabButton = Instance.new("TextButton")
    tabButton.Size = UDim2.new(1, 0, 0, tabHeight)
    tabButton.Position = UDim2.new(0, 0, 0, positionY)
    tabButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)  -- Darker background for tabs
    tabButton.BorderSizePixel = 0
    tabButton.Text = name
    tabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    tabButton.TextSize = 20
    tabButton.Font = Enum.Font.GothamBold  -- Modern font
    tabButton.Parent = tabContainer
    
    -- Round the corners of each tab button
    local tabCorner = Instance.new("UICorner")
    tabCorner.CornerRadius = UDim.new(0, 15)  -- Rounded corners
    tabCorner.Parent = tabButton
    
    -- Hover effects
    tabButton.MouseEnter:Connect(function()
        tweenService:Create(tabButton, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(50, 50, 50)  -- Darker on hover
        }):Play()
    end)
    tabButton.MouseLeave:Connect(function()
        tweenService:Create(tabButton, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(30, 30, 30)  -- Return to normal color
        }):Play()
    end)

    return tabButton
end

-- Create Tabs (Center them vertically)
local tab1 = createTab("Tab 1", startY)
local tab2 = createTab("Tab 2", startY + tabHeight + spacing)
local tab3 = createTab("Tab 3", startY + (tabHeight + spacing) * 2)

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
        
        game:GetService("RunService").Heartbeat:Connect(function()
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
                
                bodyVelocity.Velocity = moveDirection * 50  -- Adjusted speed to 50
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

-- Unload Script Logic
game:GetService("RunService").Heartbeat:Connect(function()
    if flying then
        stopFlying()
    end
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

-- Toggle Flying with Insert key
userInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.Insert then
        if flying then
            stopFlying()
        else
            startFlying()
        end
    end
end)

-- Initialize GUI State
mainWindow.Visible = true














local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local tweenService = game:GetService("TweenService")
local userInputService = game:GetService("UserInputService")
local runService = game:GetService("RunService")

-- GUI Creation
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "Syfer-eng Menu Templet"
screenGui.Parent = game:GetService("CoreGui")
screenGui.ResetOnSpawn = false

-- Main Window
local mainWindow = Instance.new("Frame")
mainWindow.Size = UDim2.new(0, 800, 0, 500)
mainWindow.Position = UDim2.new(0.5, -400, 0.5, -250)
mainWindow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
mainWindow.BorderSizePixel = 0
mainWindow.Active = true
mainWindow.Draggable = true
mainWindow.ClipsDescendants = true
mainWindow.Parent = screenGui

-- Add Cool Animated Gradient Background
local function addAnimatedGradient(parent)
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(55, 0, 128)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 40, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(55, 0, 128))
    })
    gradient.Rotation = 45
    gradient.Parent = parent

    -- Animate the Gradient
    local tweenInfo = TweenInfo.new(10, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, true)
    local tween = tweenService:Create(gradient, tweenInfo, {Rotation = 360})
    tween:Play()
end

addAnimatedGradient(mainWindow)

-- Add Corner Radius to Main Window
local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(1, 10)
mainCorner.Parent = mainWindow

-- Create Tabs
local tabList = Instance.new("Frame")
tabList.Size = UDim2.new(0, 200, 1)
tabList.Position = UDim2.new(0, 0, 0, 0)
tabList.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
tabList.BorderSizePixel = 0
tabList.Parent = mainWindow

-- Create Pages
local pageContainer = Instance.new("Frame")
pageContainer.Size = UDim2.new(1, -200, 1, 0)
pageContainer.Position = UDim2.new(0, 200, 0, 1)
pageContainer.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
pageContainer.BorderSizePixel = 0
pageContainer.Visible = false
pageContainer.Parent = mainWindow

-- Create Tab Buttons with Hover Effects and Centered
local function createTabButton(name, index, totalTabs)
    local tabButton = Instance.new("TextButton")
    tabButton.Size = UDim2.new(1, -20, 0, 50)  -- Button width and height
    tabButton.Position = UDim2.new(0.5, -90, 0, (index - 1) * (70 + 20))  -- Centering and spacing buttons
    tabButton.Text = name
    tabButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)  -- Black color by default
    tabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    tabButton.Font = Enum.Font.GothamBold
    tabButton.TextSize = 18
    tabButton.BorderSizePixel = 0
    tabButton.Parent = tabList

    -- Rounded Corners
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)  -- Rounded edges
    corner.Parent = tabButton

    -- Button Hover Effects
    tabButton.MouseEnter:Connect(function()
        local tween = tweenService:Create(tabButton, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            BackgroundColor3 = Color3.fromRGB(0, 0, 0)  -- Turn to black when hovered
        })
        tween:Play()
    end)

    tabButton.MouseLeave:Connect(function()
        local tween = tweenService:Create(tabButton, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            BackgroundColor3 = Color3.fromRGB(0, 0, 0)  -- Stay black when not hovered (no change)
        })
        tween:Play()
    end)

    -- Button Click Effect: Turn purple on click, then return to black after 1 second
    tabButton.MouseButton1Click:Connect(function()
        local tweenClick = tweenService:Create(tabButton, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            BackgroundColor3 = Color3.fromRGB(233, 40, 233)  -- Purple color on click
        })
        tweenClick:Play()

        -- After 1 second, change back to black
        wait(1)
        local tweenBack = tweenService:Create(tabButton, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            BackgroundColor3 = Color3.fromRGB(0, 0, 0)  -- Back to black
        })
        tweenBack:Play()
    end)

    tabButton.MouseButton1Click:Connect(function()
        -- Switch pages when a tab is clicked
        for _, page in pairs(pageContainer:GetChildren()) do
            page.Visible = false
        end
        pageContainer.Visible = true
        pageContainer:FindFirstChild(name).Visible = true
    end)
end

-- Create 3 tab buttons (spread out and centered)
createTabButton("Page 1", 1, 3)
createTabButton("Page 2", 2, 3)
createTabButton("Page 3", 3, 3)

-- Create Placeholder Buttons for Each Page
local function createButtonWithEffects(pageName, buttonText, positionY)
    local page = Instance.new("Frame")
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    page.BorderSizePixel = 0
    page.Visible = false
    page.Name = pageName
    page.Parent = pageContainer

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 200, 0, 50)
    button.Position = UDim2.new(0.5, -100, 0, positionY)
    button.Text = buttonText
    button.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Font = Enum.Font.GothamBold
    button.TextSize = 18
    button.BorderSizePixel = 0
    button.Parent = page

    -- Add a Purple Glow Border
    local border = Instance.new("UICorner")
    border.CornerRadius = UDim.new(0, 12)
    border.Parent = button

    -- Button Hover Animation
    button.MouseEnter:Connect(function()
        local tween = tweenService:Create(button, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            BackgroundColor3 = Color3.fromRGB(233, 40, 233), -- Purple color hover
            TextColor3 = Color3.fromRGB(255, 255, 255)
        })
        tween:Play()
    end)

    button.MouseLeave:Connect(function()
        local tween = tweenService:Create(button, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            BackgroundColor3 = Color3.fromRGB(0, 0, 0),
            TextColor3 = Color3.fromRGB(255, 255, 255)
        })
        tween:Play()
    end)
end

-- Page 1: Create Buttons
createButtonWithEffects("Page 1", "Button 1 for Page 1", 50)
createButtonWithEffects("Page 1", "Button 2 for Page 1", 150)
createButtonWithEffects("Page 1", "Button 3 for Page 1", 250)

-- Page 2: Create Buttons
createButtonWithEffects("Page 2", "Button 1 for Page 2", 50)
createButtonWithEffects("Page 2", "Button 2 for Page 2", 150)
createButtonWithEffects("Page 2", "Button 3 for Page 2", 250)

-- Page 3: Create Buttons
createButtonWithEffects("Page 3", "Button 1 for Page 3", 50)
createButtonWithEffects("Page 3", "Button 2 for Page 3", 150)
createButtonWithEffects("Page 3", "Button 3 for Page 3", 250)

-- Comet Effect
local function createComet()
    -- Create the comet itself
    local comet = Instance.new("Frame")
    comet.Size = UDim2.new(0, 8, 0, 8)  -- Small circle representing the comet
    comet.BackgroundColor3 = Color3.fromRGB(255, 255, 255)  -- White color for the comet
    comet.BorderSizePixel = 0
    comet.Position = UDim2.new(0, math.random(-50, 0), 0, math.random(0, mainWindow.AbsoluteSize.Y))
    comet.Parent = mainWindow

    -- Add a trail behind the comet
    for i = 1, 5 do
        local trail = Instance.new("Frame")
        trail.Size = UDim2.new(0, 20 - (i * 4), 0, 3 - (i * 0.4))  -- Decreasing size
        trail.Position = UDim2.new(0, -(20 - (i * 4)), 0, 0.5)  -- Trail behind comet
        trail.BackgroundColor3 = Color3.fromRGB(1, 1, 1)  -- White color
        trail.BackgroundTransparency = 0.2 * i  -- Make it more transparent for each segment
        trail.BorderSizePixel = 0
        trail.Parent = comet

        -- Add a subtle glow to each trail
        local glow = Instance.new("ImageLabel")
        glow.Size = UDim2.new(1.2, 0, 1.2, 0)
        glow.Position = UDim2.new(-0.1, 0, -0.1, 0)
        glow.BackgroundTransparency = 1
        glow.Image = "rbxassetid://7331079227"  -- Image for the glow
        glow.ImageColor3 = Color3.fromRGB(1, 1, 1)  -- White glow color
        glow.ImageTransparency = 0.5 + (0.1 * i)  -- Gradual transparency for the glow
        glow.Parent = trail
    end

    -- Comet movement animation
    local startX = comet.Position.X.Offset
    local startY = comet.Position.Y.Offset
    local endX = mainWindow.AbsoluteSize.X + 50
    local endY = startY + math.random(100, 200)

    local tweenInfo = TweenInfo.new(
        math.random(8, 12) / 10,  -- Random speed between 8-12 seconds
        Enum.EasingStyle.Linear
    )

    local tween = tweenService:Create(comet, tweenInfo, {
        Position = UDim2.new(0, endX, 0, endY),
        BackgroundTransparency = 1  -- Fade out comet as it moves
    })
    
    tween:Play()

    -- Remove the comet after animation completes
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

-- Initialize the menu and make the first page visible
pageContainer.Visible = true
pageContainer:FindFirstChild("Page 1").Visible = true
