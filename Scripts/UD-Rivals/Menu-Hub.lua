-- Initial Setup
if not game:IsLoaded() then
    game.Loaded:Wait()
end

-- Services
local gui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local buttonStates = {}

-- Create Blur Effect
local BlurEffect = Instance.new("BlurEffect")
BlurEffect.Size = 0
BlurEffect.Enabled = false
BlurEffect.Parent = Lighting

-- Create Basic UI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RivalsEnhancedGUI"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Enabled = false

if syn then
    syn.protect_gui(ScreenGui)
end

if gethui then
    ScreenGui.Parent = gethui()
elseif not RunService:IsStudio() then
    ScreenGui.Parent = gui
else
    ScreenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
end

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 300, 0, 600)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -300)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

-- Add UI Enhancement Elements
local UIGradient = Instance.new("UIGradient")
UIGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 30)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 20))
})
UIGradient.Rotation = 45
UIGradient.Parent = MainFrame

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

local DropShadow = Instance.new("ImageLabel")
DropShadow.Name = "DropShadow"
DropShadow.BackgroundTransparency = 1
DropShadow.Position = UDim2.new(0, -15, 0, -15)
DropShadow.Size = UDim2.new(1, 30, 1, 30)
DropShadow.Image = "rbxassetid://6014261993"
DropShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
DropShadow.ImageTransparency = 0.5
DropShadow.Parent = MainFrame

-- Create Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 30)
TitleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleText = Instance.new("TextLabel")
TitleText.Name = "Title"
TitleText.Size = UDim2.new(1, 0, 1, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "Rivals Enhanced"
TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleText.TextSize = 16
TitleText.Font = Enum.Font.GothamBold
TitleText.Parent = TitleBar

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = TitleBar

-- Function to create buttons
local function CreateButton(name, position)
    local Button = Instance.new("TextButton")
    Button.Name = name
    Button.Size = UDim2.new(0, 280, 0, 40)
    Button.Position = position
    Button.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Button.Text = name
    Button.TextSize = 16
    Button.Font = Enum.Font.GothamBold
    Button.Parent = MainFrame
    Button.AutoButtonColor = false

    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 6)
    ButtonCorner.Parent = Button

    local enabled = buttonStates[name] or false
    Button.TextColor3 = enabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)

    Button.MouseButton1Click:Connect(function()
        enabled = not enabled
        buttonStates[name] = enabled
        Button.TextColor3 = enabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    end)

    return Button
end

-- Create buttons
local buttons = {
    CreateButton("Speed Hack", UDim2.new(0, 10, 0, 40)),
    CreateButton("Jump Hack", UDim2.new(0, 10, 0, 90)),
    CreateButton("ESP", UDim2.new(0, 10, 0, 140)),
    CreateButton("Aimbot", UDim2.new(0, 10, 0, 190)),
    CreateButton("Wallhack", UDim2.new(0, 10, 0, 240)),
    CreateButton("No Clip", UDim2.new(0, 10, 0, 290)),
    CreateButton("God Mode", UDim2.new(0, 10, 0, 340)),
    CreateButton("Infinite Jump", UDim2.new(0, 10, 0, 390))
}

-- Dragging functionality
local isDragging = false
local dragStart = nil
local startPos = nil

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        isDragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement and isDragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        isDragging = false
    end
end)
local lastPosition = UDim2.new(0.5, -150, 0.5, -300)
-- Toggle GUI visibility with Insert key
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.Insert then
        if ScreenGui.Enabled then
            lastPosition = MainFrame.Position
            TweenService:Create(MainFrame, TweenInfo.new(0.3), {
                Position = UDim2.new(0.5, -150, 1.5, 0)
            }):Play()
            
            TweenService:Create(BlurEffect, TweenInfo.new(0.3), {
                Size = 0
            }):Play()
            
            task.wait(0.3)
            ScreenGui.Enabled = false
            BlurEffect.Enabled = false
        else
            ScreenGui.Enabled = true
            BlurEffect.Enabled = true
            
            MainFrame.Position = UDim2.new(0.5, -150, 1.5, 0)
            TweenService:Create(MainFrame, TweenInfo.new(0.3), {
                Position = lastPosition
            }):Play()
            
            TweenService:Create(BlurEffect, TweenInfo.new(0.3), {
                Size = 20
            }):Play()
        end
    end
end)
