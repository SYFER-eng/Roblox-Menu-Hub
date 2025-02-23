-- Create the popup UI
local player = game.Players.LocalPlayer
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Popup Frame
local popup = Instance.new("Frame")
popup.Size = UDim2.new(0, 350, 0, 120)
popup.Position = UDim2.new(1, -360, 1, -150)  -- Bottom right corner
popup.BackgroundColor3 = Color3.fromRGB(44, 44, 44)
popup.BackgroundTransparency = 0.2
popup.BorderSizePixel = 0
popup.BorderRadius = UDim.new(0, 16)
popup.Parent = screenGui

-- Gradient Effect for the Popup
local uiGradient = Instance.new("UIGradient")
uiGradient.Parent = popup
uiGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(73, 73, 73)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(44, 44, 44)),
}
uiGradient.Rotation = 45

-- Text Label Inside Popup
local label = Instance.new("TextLabel")
label.Size = UDim2.new(0.8, 0, 1, 0)
label.Position = UDim2.new(0.15, 0, 0, 0)
label.Text = "Congratulations! You've earned a badge!"
label.TextColor3 = Color3.fromRGB(255, 255, 255)
label.TextScaled = true
label.BackgroundTransparency = 1
label.TextXAlignment = Enum.TextXAlignment.Left
label.Parent = popup

-- Award Icon
local icon = Instance.new("ImageLabel")
icon.Size = UDim2.new(0, 40, 0, 40)
icon.Position = UDim2.new(0, 10, 0, 10)
icon.Image = "rbxassetid://3451687344"  -- Example image asset ID (you can change it)
icon.BackgroundTransparency = 1
icon.Parent = popup

-- Tweening for Slide-Out Effect
local tweenService = game:GetService("TweenService")

local slideOutTweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local slideOutGoal = {Position = UDim2.new(1, 10, 1, -150)}

local slideOutTween = tweenService:Create(popup, slideOutTweenInfo, slideOutGoal)

-- Function to Show the Popup and Auto-Close After 2 Seconds
local function showPopup()
    -- Wait for 2 seconds
    wait(2)
    -- Start the tween for sliding off
    slideOutTween:Play()
    -- Wait for the tween to finish
    wait(slideOutTweenInfo.Time)
    -- Remove the popup after animation
    popup:Destroy()
end

-- Show the popup and automatically close it after 2 seconds
showPopup()
