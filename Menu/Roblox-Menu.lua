local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- Create all instances
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local UICorner = Instance.new("UICorner")
local Title = Instance.new("TextLabel")
local ButtonHolder = Instance.new("ScrollingFrame")
local UIListLayout = Instance.new("UIListLayout")
local Shadow = Instance.new("ImageLabel")
local UIGradient = Instance.new("UIGradient")

-- Scripts configuration
local scripts = {
    {name = "Aim Menu", loadstring = "loadstring(game:HttpGet('https://raw.githubusercontent.com/SYFER-eng/Roblox-Menu-Hub/refs/heads/main/Scripts/AimMenu.lua'))()"},
    {name = "Speed Hacks", loadstring = "loadstring(game:HttpGet('https://raw.githubusercontent.com/SYFER-eng/Roblox-Menu-Hub/refs/heads/main/Scripts/Roblox-Speed-Hack.lua'))()"},
    {name = "Fly Hack", loadstring = "loadstring(game:HttpGet('https://raw.githubusercontent.com/SYFER-eng/Roblox-Menu-Hub/refs/heads/main/Scripts/Fly-Hack.lua'))()"},
    {name = "Script 4", loadstring = "loadstring(game:HttpGet('https://example.com/script4.lua'))()"}
}

-- Setup ScreenGui
ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true  -- Ensures this GUI isn't affected by default UI

-- Function to Create and Apply Tweens
local function createTween(target, tweenInfo, goal)
    local tween = TweenService:Create(target, tweenInfo, goal)
    tween:Play()
    return tween
end

-- Function to create Button with hover and click effects
local function createScriptButton(scriptData)
    local button = Instance.new("TextButton")
    button.Name = "ScriptButton"
    button.Parent = ButtonHolder
    button.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    button.Size = UDim2.new(1, 0, 0, 50)
    button.Font = Enum.Font.GothamBold
    button.Text = scriptData.name
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 16
    
    -- Apply Gradient
    local buttonGradient = Instance.new("UIGradient")
    buttonGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(60, 60, 180)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(45, 45, 150))
    })
    buttonGradient.Parent = button

    -- Apply Corner
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 8)
    buttonCorner.Parent = button

    -- Button Hover Effect
    button.MouseEnter:Connect(function()
        createTween(button, TweenInfo.new(0.3), {
            BackgroundColor3 = Color3.fromRGB(70, 70, 200),
            TextSize = 18
        })
    end)
    
    button.MouseLeave:Connect(function()
        createTween(button, TweenInfo.new(0.3), {
            BackgroundColor3 = Color3.fromRGB(45, 45, 45),
            TextSize = 16
        })
    end)
    
    -- Button Click Handler with Ripple Effect
    button.MouseButton1Click:Connect(function()
        loadstring(scriptData.loadstring)()

        -- Create ripple effect
        local ripple = Instance.new("Frame")
        ripple.Parent = button
        ripple.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ripple.BackgroundTransparency = 0.6
        ripple.Position = UDim2.new(0, 0, 0, 0)
        ripple.Size = UDim2.new(0, 0, 1, 0)

        local rippleTween = createTween(ripple, TweenInfo.new(0.5), {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1
        })
        
        rippleTween.Completed:Connect(function()
            ripple:Destroy()
        end)
    end)
end

-- Create Script Buttons for each script
for _, scriptData in ipairs(scripts) do
    createScriptButton(scriptData)
end

-- **Fixed Dragging for MainFrame**: The drag logic for the entire `MainFrame`, not the `TopButton`.
local dragging = false
local dragStart
local startPos

MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)

MainFrame.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        -- Update position based on mouse movement (delta)
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

MainFrame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- Setup MainFrame
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
MainFrame.Size = UDim2.new(0, 317, 0, 400)
MainFrame.ClipsDescendants = true
MainFrame.ZIndex = 999999  -- Ensure the menu is above all other UI elements

-- Setup Gradient
UIGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(45, 45, 180)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 30, 120))
})
UIGradient.Parent = MainFrame

-- Setup Shadow
Shadow.Name = "Shadow"
Shadow.Parent = MainFrame
Shadow.BackgroundTransparency = 1
Shadow.Position = UDim2.new(0, -15, 0, -15)
Shadow.Size = UDim2.new(1, 30, 1, 30)
Shadow.Image = "rbxassetid://6015897843"
Shadow.ImageColor3 = Color3.new(0, 0, 0)
Shadow.ImageTransparency = 0.5
Shadow.ZIndex = -1

-- Setup UICorner
UICorner.Parent = MainFrame
UICorner.CornerRadius = UDim.new(0, 10)

-- Setup Title
Title.Name = "Title"
Title.Parent = MainFrame
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 0, 0, 10)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Font = Enum.Font.GothamBold
Title.Text = "Syfer-eng │ Script Hub"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 24

-- Setup ButtonHolder
ButtonHolder.Name = "ButtonHolder"
ButtonHolder.Parent = MainFrame
ButtonHolder.BackgroundTransparency = 1
ButtonHolder.Position = UDim2.new(0, 10, 0, 60)
ButtonHolder.Size = UDim2.new(1, -20, 1, -70)
ButtonHolder.ScrollBarThickness = 6
ButtonHolder.ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255)

-- Setup UIListLayout
UIListLayout.Parent = ButtonHolder
UIListLayout.Padding = UDim.new(0, 10)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- **Close Button at Top Right of the Menu**
local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.Parent = MainFrame
closeButton.BackgroundTransparency = 1  -- No background
closeButton.Size = UDim2.new(0, 30, 0, 30)  -- Smaller size (30x30)
closeButton.Font = Enum.Font.GothamBold
closeButton.Text = "X"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.TextSize = 18  -- Smaller text size

-- Position the button at the top-right of the screen
closeButton.Position = UDim2.new(1, -35, 0, 5)  -- 5px padding from the top-right corner
closeButton.ZIndex = 999999  -- Ensure this button is on top of everything else

-- Close Button Click Handler
closeButton.MouseButton1Click:Connect(function()
    -- Fade out the GUI with an animation before unloading
    local tweenInfo = TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.InOut)
    createTween(MainFrame, tweenInfo, {
        BackgroundTransparency = 1
    })

    -- Wait for the animation to finish
    wait(tweenInfo.Time)

    -- Destroy the ScreenGui and all its children
    ScreenGui:Destroy()

    -- Optionally, you can print to console that the script has been unloaded
    print("Script has been unloaded and GUI removed.")
end)

-- **New Button at Bottom to Toggle Menu Visibility with PgDn/PageDown**
local toggleButton = Instance.new("TextButton")
toggleButton.Name = "ToggleButton"
toggleButton.Parent = MainFrame
toggleButton.BackgroundTransparency = 1  -- No background
toggleButton.Size = UDim2.new(0, 200, 0, 40)  -- Smaller size (200x40)
toggleButton.Font = Enum.Font.GothamBold
toggleButton.Text = "Press PgDn/Page Down To Hide"
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.TextSize = 14  -- Smaller text size

-- Position the button at the bottom of the screen
toggleButton.Position = UDim2.new(0.5, -100, 1, -60)  -- Center the button horizontally and 60px from the bottom
toggleButton.ZIndex = 999999  -- Ensure this button is on top of everything else

-- Page Down Key Toggle Functionality (Hide/Unhide)
local menuVisible = true

UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.PageDown then
        local tweenInfo = TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.InOut)
        local targetTransparency = menuVisible and 1 or 0  -- Fade out if visible, fade in if hidden
        
        -- Create the fade animation for the menu
        createTween(MainFrame, tweenInfo, {
            BackgroundTransparency = targetTransparency
        })

        -- Toggle the visibility after animation
        menuVisible = not menuVisible
        MainFrame.Visible = menuVisible  -- Toggle actual visibility (to stop interaction when hidden)
    end
end)
