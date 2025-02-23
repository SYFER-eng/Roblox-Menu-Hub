local player = game.Players.LocalPlayer
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Main popup frame with blur effect
local blurEffect = Instance.new("BlurEffect")
blurEffect.Size = 10
blurEffect.Parent = game.Lighting

local popup = Instance.new("Frame")
popup.Size = UDim2.new(0, 300, 0, 100)
popup.Position = UDim2.new(1, 10, 1, -150) 
popup.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
popup.BackgroundTransparency = 0.1
popup.BorderSizePixel = 0
popup.Parent = screenGui

-- Sleek corner rounding
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 20)
corner.Parent = popup

-- Cool glow effect
local glow = Instance.new("ImageLabel")
local glowSize = 20
glow.Size = UDim2.new(1, glowSize * 2, 1, glowSize * 2)
glow.Position = UDim2.new(0, -glowSize, 0, -glowSize)
glow.Image = "rbxassetid://5028857084"
glow.ImageColor3 = Color3.fromRGB(255, 0, 255) -- Purple glow
glow.BackgroundTransparency = 1
glow.ImageTransparency = 0.8
glow.Parent = popup

-- Animated gradient
local uiGradient = Instance.new("UIGradient")
uiGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(75, 0, 130)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(138, 43, 226)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(75, 0, 130))
}
uiGradient.Parent = popup

-- Animated gradient rotation
local gradientRotation = 0
game:GetService("RunService").RenderStepped:Connect(function()
    gradientRotation = (gradientRotation + 1) % 360
    uiGradient.Rotation = gradientRotation
end)

-- Stylish text
local label = Instance.new("TextLabel")
label.Size = UDim2.new(0.75, 0, 1, 0)
label.Position = UDim2.new(0.18, 0, 0, 0)
label.Text = "Aimbot Script Loaded Successfully!"
label.TextColor3 = Color3.fromRGB(255, 255, 255)
label.Font = Enum.Font.GothamBold
label.TextSize = 18
label.TextWrapped = true
label.TextXAlignment = Enum.TextXAlignment.Left
label.BackgroundTransparency = 1
label.Parent = popup

-- Cool icon with pulse effect
local icon = Instance.new("ImageLabel")
icon.Size = UDim2.new(0, 40, 0, 40)
icon.Position = UDim2.new(0, 10, 0.5, -20)
icon.Image = "https://github.com/SYFER-eng/Syfer-eng.github.io/blob/main/Picture/Png/icons8-kuromi-512.png?raw=true"
icon.BackgroundTransparency = 1
icon.ScaleType = Enum.ScaleType.Fit
icon.Parent = popup

-- Stroke effect
local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(255, 0, 255)
stroke.Thickness = 2
stroke.Parent = popup

local tweenService = game:GetService("TweenService")

-- Enhanced animations
local slideInTween = tweenService:Create(popup, 
    TweenInfo.new(0.7, Enum.EasingStyle.Back, Enum.EasingDirection.Out), 
    {Position = UDim2.new(1, -320, 1, -120)}
)

local slideOutTween = tweenService:Create(popup, 
    TweenInfo.new(0.7, Enum.EasingStyle.Back, Enum.EasingDirection.In), 
    {Position = UDim2.new(1, 10, 1, -120)}
)

-- Pulse animation for icon
local function pulseIcon()
    local pulseTween = tweenService:Create(icon,
        TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, -1, true),
        {Size = UDim2.new(0, 45, 0, 45)}
    )
    pulseTween:Play()
end

-- Execute animations
slideInTween:Play()
pulseIcon()

wait(2)

slideOutTween:Play()
wait(0.7)
blurEffect:Destroy()
screenGui:Destroy()
