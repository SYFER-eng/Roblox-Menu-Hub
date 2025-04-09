-- FullbrightGUI.lua
-- A draggable GUI with fullbright toggle functionality
-- Press Insert to show/hide the GUI
-- Press End to unload the script
-- Toggle button controls fullbright effect

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer
local gui = nil
local dragging = false
local dragInput = nil
local dragStart = nil
local startPos = nil
local fullbrightEnabled = false
local originalBrightness = Lighting.Brightness
local originalAmbient = Lighting.Ambient
local originalOutdoorAmbient = Lighting.OutdoorAmbient
local originalClockTime = Lighting.ClockTime
local isVisible = true
local brightnessLevel = 1.2 -- Default brightness level

-- Store the original lighting values for reverting
local function storeOriginalLightingSettings()
    originalBrightness = Lighting.Brightness
    originalAmbient = Lighting.Ambient
    originalOutdoorAmbient = Lighting.OutdoorAmbient
    originalClockTime = Lighting.ClockTime
end

-- Apply fullbright settings based on slider value
local function enableFullbright()
    Lighting.Brightness = brightnessLevel
    Lighting.Ambient = Color3.fromRGB(150, 150, 150)
    Lighting.OutdoorAmbient = Color3.fromRGB(150, 150, 150)
    Lighting.ClockTime = 12
    fullbrightEnabled = true
end

-- Update brightness based on slider value
local function updateBrightness(value)
    brightnessLevel = value
    if fullbrightEnabled then
        Lighting.Brightness = brightnessLevel
    end
end

-- Revert to original lighting settings
local function disableFullbright()
    Lighting.Brightness = originalBrightness
    Lighting.Ambient = originalAmbient
    Lighting.OutdoorAmbient = originalOutdoorAmbient
    Lighting.ClockTime = originalClockTime
    fullbrightEnabled = false
end

-- Toggle fullbright on/off
local function toggleFullbright()
    if fullbrightEnabled then
        disableFullbright()
    else
        enableFullbright()
    end
    
    -- Update button appearance
    if gui and gui:FindFirstChild("MainFrame") and gui.MainFrame:FindFirstChild("ToggleButton") then
        local toggleButton = gui.MainFrame.ToggleButton
        toggleButton.BackgroundColor3 = fullbrightEnabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(200, 200, 200)
    end
end

-- Function to create the GUI
local function createGUI()
    -- Create ScreenGui
    gui = Instance.new("ScreenGui")
    gui.Name = "FullbrightGUI"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Create main frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 200, 0, 130) -- Increased height to accommodate the slider
    mainFrame.Position = UDim2.new(0.5, -100, 0.1, 0)
    mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    mainFrame.BorderSizePixel = 2
    mainFrame.BorderColor3 = Color3.fromRGB(100, 100, 100)
    mainFrame.Active = true
    mainFrame.Draggable = false -- We'll handle dragging manually
    mainFrame.Parent = gui
    
    -- Create title bar
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 25)
    titleBar.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame
    
    -- Create title text
    local titleText = Instance.new("TextLabel")
    titleText.Name = "TitleText"
    titleText.Size = UDim2.new(1, -10, 1, 0)
    titleText.Position = UDim2.new(0, 5, 0, 0)
    titleText.BackgroundTransparency = 1
    titleText.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleText.TextSize = 14
    titleText.Font = Enum.Font.SourceSansBold
    titleText.Text = "Fullbright GUI"
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.Parent = titleBar
    
    -- Create toggle button
    local toggleButton = Instance.new("TextButton")
    toggleButton.Name = "ToggleButton"
    toggleButton.Size = UDim2.new(0, 150, 0, 30)
    toggleButton.Position = UDim2.new(0.5, -75, 0.3, 0)
    toggleButton.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
    toggleButton.BorderColor3 = Color3.fromRGB(100, 100, 100)
    toggleButton.BorderSizePixel = 1
    toggleButton.TextColor3 = Color3.fromRGB(0, 0, 0)
    toggleButton.TextSize = 14
    toggleButton.Font = Enum.Font.SourceSansBold
    toggleButton.Text = "Toggle Fullbright"
    toggleButton.Parent = mainFrame
    
    -- Create brightness label
    local brightnessLabel = Instance.new("TextLabel")
    brightnessLabel.Name = "BrightnessLabel"
    brightnessLabel.Size = UDim2.new(0, 150, 0, 20)
    brightnessLabel.Position = UDim2.new(0.5, -75, 0.55, 0)
    brightnessLabel.BackgroundTransparency = 1
    brightnessLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    brightnessLabel.TextSize = 12
    brightnessLabel.Font = Enum.Font.SourceSans
    brightnessLabel.Text = "Brightness: " .. brightnessLevel
    brightnessLabel.Parent = mainFrame
    
    -- Create slider background
    local sliderBackground = Instance.new("Frame")
    sliderBackground.Name = "SliderBackground"
    sliderBackground.Size = UDim2.new(0, 150, 0, 10)
    sliderBackground.Position = UDim2.new(0.5, -75, 0.65, 0)
    sliderBackground.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    sliderBackground.BorderColor3 = Color3.fromRGB(100, 100, 100)
    sliderBackground.BorderSizePixel = 1
    sliderBackground.Parent = mainFrame
    
    -- Create slider fill (to show current value)
    local sliderFill = Instance.new("Frame")
    sliderFill.Name = "SliderFill"
    sliderFill.Size = UDim2.new(brightnessLevel / 3, 0, 1, 0) -- Scale based on value (max is 3)
    sliderFill.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
    sliderFill.BorderSizePixel = 0
    sliderFill.Parent = sliderBackground
    
    -- Create slider handle
    local sliderHandle = Instance.new("TextButton")
    sliderHandle.Name = "SliderHandle"
    sliderHandle.Size = UDim2.new(0, 15, 0, 15)
    sliderHandle.Position = UDim2.new(brightnessLevel / 3, -7.5, 0, -2.5)
    sliderHandle.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
    sliderHandle.BorderColor3 = Color3.fromRGB(100, 100, 100)
    sliderHandle.BorderSizePixel = 1
    sliderHandle.Text = ""
    sliderHandle.Parent = sliderBackground
    
    -- Slider functionality
    local draggingSlider = false
    
    -- Function to update slider based on position
    local function updateSlider(mouseX)
        local sliderPos = sliderBackground.AbsolutePosition.X
        local sliderWidth = sliderBackground.AbsoluteSize.X
        local relativeX = mouseX - sliderPos
        
        -- Clamp the position to be within the slider
        relativeX = math.max(0, math.min(relativeX, sliderWidth))
        
        -- Calculate the value (0.1 to 3)
        local newBrightness = (relativeX / sliderWidth) * 3
        newBrightness = math.max(0.1, math.min(newBrightness, 3)) -- Ensure between 0.1 and 3
        newBrightness = math.floor(newBrightness * 10) / 10 -- Round to 1 decimal place
        
        -- Update UI elements
        brightnessLabel.Text = "Brightness: " .. newBrightness
        sliderHandle.Position = UDim2.new(newBrightness / 3, -7.5, 0, -2.5)
        sliderFill.Size = UDim2.new(newBrightness / 3, 0, 1, 0)
        
        -- Update the brightness level
        updateBrightness(newBrightness)
    end
    
    sliderHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingSlider = true
        end
    end)
    
    sliderHandle.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingSlider = false
        end
    end)
    
    sliderBackground.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingSlider = true
            updateSlider(input.Position.X)
        end
    end)
    
    sliderBackground.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingSlider = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if draggingSlider and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateSlider(input.Position.X)
        end
    end)
    
    -- Create keyboard shortcut info
    local shortcutInfo = Instance.new("TextLabel")
    shortcutInfo.Name = "ShortcutInfo"
    shortcutInfo.Size = UDim2.new(1, 0, 0, 20)
    shortcutInfo.Position = UDim2.new(0, 0, 1, -20)
    shortcutInfo.BackgroundTransparency = 1
    shortcutInfo.TextColor3 = Color3.fromRGB(200, 200, 200)
    shortcutInfo.TextSize = 10
    shortcutInfo.Font = Enum.Font.SourceSans
    shortcutInfo.Text = "Insert: Toggle GUI | End: Unload"
    shortcutInfo.Parent = mainFrame
    
    -- Parent the GUI to PlayerGui
    gui.Parent = player:WaitForChild("PlayerGui")
    
    -- Connect toggle button click event
    toggleButton.MouseButton1Click:Connect(toggleFullbright)
    
    -- Set up dragging functionality
    local function updateDrag(input)
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    titleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            updateDrag(input)
        end
    end)
    
    return gui
end

-- Toggle GUI visibility
local function toggleGUI()
    if gui then
        isVisible = not isVisible
        gui.Enabled = isVisible
    end
end

-- Unload the script and clean up
local function unloadScript()
    if fullbrightEnabled then
        disableFullbright()
    end
    
    if gui then
        gui:Destroy()
        gui = nil
    end
    
    -- Disconnect input events
    for _, connection in pairs(connections) do
        connection:Disconnect()
    end
    
    -- Notify user
    local notification = Instance.new("ScreenGui")
    notification.Name = "UnloadNotification"
    
    local notifText = Instance.new("TextLabel")
    notifText.Size = UDim2.new(0, 200, 0, 50)
    notifText.Position = UDim2.new(0.5, -100, 0.1, 0)
    notifText.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    notifText.BorderSizePixel = 2
    notifText.BorderColor3 = Color3.fromRGB(100, 100, 100)
    notifText.TextColor3 = Color3.fromRGB(255, 255, 255)
    notifText.TextSize = 14
    notifText.Font = Enum.Font.SourceSansBold
    notifText.Text = "Fullbright GUI Unloaded"
    notifText.Parent = notification
    
    notification.Parent = player:WaitForChild("PlayerGui")
    
    -- Remove notification after 2 seconds
    task.delay(2, function()
        notification:Destroy()
    end)
    
    script:Destroy() -- Self-destruct
end

-- Store connections for cleanup
connections = {}

-- Initialize
storeOriginalLightingSettings()
gui = createGUI()

-- Set up keyboard shortcuts
local function onInputBegan(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.Insert then
        toggleGUI()
    elseif input.KeyCode == Enum.KeyCode.End then
        unloadScript()
    end
end

table.insert(connections, UserInputService.InputBegan:Connect(onInputBegan))

-- Print initialization message to output
print("Fullbright GUI loaded. Press Insert to toggle visibility, End to unload.")
