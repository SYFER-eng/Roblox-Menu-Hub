-- Popup Library (Place this code in a separate file for external use)
local PopupLibrary = {}

function PopupLibrary.ShowPopup()
    -- Create the popup UI
    local player = game.Players.LocalPlayer
    local screenGui = Instance.new("ScreenGui")
    screenGui.Parent = player:WaitForChild("PlayerGui")

    -- Popup Frame
    local popup = Instance.new("Frame")
    popup.Size = UDim2.new(0, 400, 0, 150)
    popup.Position = UDim2.new(1, -420, 1, -180)  -- Bottom right corner
    popup.BackgroundColor3 = Color3.fromRGB(44, 44, 44)
    popup.BackgroundTransparency = 0.3
    popup.BorderSizePixel = 0
    popup.BorderRadius = UDim.new(0, 16)
    popup.Parent = screenGui

    -- Shadow Effect (to create a floating effect)
    local shadow = Instance.new("ImageLabel")
    shadow.Size = UDim2.new(1, 10, 1, 10)
    shadow.Position = UDim2.new(0, 0, 0, 10)
    shadow.Image = "rbxassetid://303317706"  -- Shadow image asset
    shadow.ImageTransparency = 0.8
    shadow.BackgroundTransparency = 1
    shadow.Parent = popup

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
    label.Size = UDim2.new(0.75, 0, 1, 0)
    label.Position = UDim2.new(0.18, 0, 0, 0)
    label.Text = "Congratulations! You've earned a badge!"
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 24
    label.TextWrapped = true
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1
    label.Parent = popup

    -- Award Icon
    local icon = Instance.new("ImageLabel")
    icon.Size = UDim2.new(0, 50, 0, 50)
    icon.Position = UDim2.new(0, 10, 0, 10)
    icon.Image = "rbxassetid://3451687344"  -- Example image asset ID (you can change it)
    icon.BackgroundTransparency = 1
    icon.ScaleType = Enum.ScaleType.Fit
    icon.Parent = popup

    -- Tweening for Slide-In Effect
    local tweenService = game:GetService("TweenService")
    local slideInTweenInfo = TweenInfo.new(1, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out)

    local slideInGoal = {Position = UDim2.new(1, -420, 1, -180)}
    local slideInTween = tweenService:Create(popup, slideInTweenInfo, slideInGoal)

    -- Tween for Slide-Out Effect
    local slideOutTweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local slideOutGoal = {Position = UDim2.new(1, 10, 1, -150)}
    local slideOutTween = tweenService:Create(popup, slideOutTweenInfo, slideOutGoal)

    -- Function to Scale the Icon Effect
    local function scaleIconEffect()
        local iconTween = tweenService:Create(icon, TweenInfo.new(0.5, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {Size = UDim2.new(0, 60, 0, 60)})
        iconTween:Play()
        iconTween.Completed:Connect(function()
            -- Reset icon size after scaling
            wait(0.3)
            local resetIconTween = tweenService:Create(icon, TweenInfo.new(0.5), {Size = UDim2.new(0, 50, 0, 50)})
            resetIconTween:Play()
        end)
    end

    -- Function to Show the Popup and Auto-Close After 2 Seconds
    local function showPopup()
        -- Show popup by sliding in
        slideInTween:Play()

        -- Scale the icon to simulate the "appearing" effect
        scaleIconEffect()

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
end

return PopupLibrary
