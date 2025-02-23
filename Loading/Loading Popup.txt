-- LocalScript inside StarterPlayer -> StarterPlayerScripts

-- Create the GUI
local player = game.Players.LocalPlayer
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Create the popup frame (with rounded corners and background style)
local popup = Instance.new("Frame")
popup.Size = UDim2.new(0, 350, 0, 120)
popup.Position = UDim2.new(1, -360, 1, -150)  -- Bottom right corner
popup.BackgroundColor3 = Color3.fromRGB(44, 44, 44)  -- Dark background
popup.BackgroundTransparency = 0.2
popup.BorderSizePixel = 0
popup.BorderRadius = UDim.new(0, 16)  -- Rounded corners
popup.Parent = screenGui

-- Create a slight gradient effect for the background (like Roblox awards)
local uiGradient = Instance.new("UIGradient")
uiGradient.Parent = popup
uiGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(73, 73, 73)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(44, 44, 44)),
}
uiGradient.Rotation = 45

-- Create the label inside the popup (award message)
local label = Instance.new("TextLabel")
label.Size = UDim2.new(0.8, 0, 1, 0)
label.Position = UDim2.new(0.15, 0, 0, 0)
label.Text = "Congratulations! You've earned a badge!"
label.TextColor3 = Color3.fromRGB(255, 255, 255)
label.TextScaled = true
label.BackgroundTransparency = 1
label.TextXAlignment = Enum.TextXAlignment.Left
label.Parent = popup

-- Create the icon for the award (like a trophy or star)
local icon = Instance.new("ImageLabel")
icon.Size = UDim2.new(0, 40, 0, 40)
icon.Position = UDim2.new(0, 10, 0, 10)
icon.Image = "rbxassetid://3451687344"  -- Example icon (change the asset ID as needed)
icon.BackgroundTransparency = 1
icon.Parent = popup

-- Tween to slide off the screen after 2 seconds
local tweenService = game:GetService("TweenService")

-- Create the TweenInfo for the animation
local slideOutTweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

-- Animation goal: Slide off the screen
local slideOutGoal = {Position = UDim2.new(1, 10, 1, -150)}

-- Create the tween
local slideOutTween = tweenService:Create(popup, slideOutTweenInfo, slideOutGoal)

-- Function to show and auto-close the popup
local function showPopup()
    -- Wait for 2 seconds to automatically close
    wait(2)
    -- Start the slide-out tween
    slideOutTween:Play()
    -- Wait until the tween finishes (1 second duration)
    wait(slideOutTweenInfo.Time)
    -- Remove the popup from the screen after the animation
    popup:Destroy()
end

-- Show the popup and handle the closing automatically
showPopup()
