-- LocalScript inside StarterPlayer -> StarterPlayerScripts

-- Create the GUI
local player = game.Players.LocalPlayer
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Create the popup frame
local popup = Instance.new("Frame")
popup.Size = UDim2.new(0, 300, 0, 100)
popup.Position = UDim2.new(1, -310, 1, -120)  -- Bottom right corner
popup.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
popup.BorderSizePixel = 0
popup.Parent = screenGui

-- Create the label inside the popup
local label = Instance.new("TextLabel")
label.Size = UDim2.new(1, 0, 1, 0)
label.Text = "Your message here!"
label.TextColor3 = Color3.fromRGB(255, 255, 255)
label.TextScaled = true
label.BackgroundTransparency = 1
label.Parent = popup

-- Tween to slide off the screen after 2 seconds
local tweenService = game:GetService("TweenService")

-- Create the TweenInfo for animation
local slideOutTweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

-- Animation goal: Slide off the screen
local slideOutGoal = {Position = UDim2.new(1, 10, 1, -120)}

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
