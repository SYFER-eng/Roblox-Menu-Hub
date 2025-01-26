if game:GetService("CoreGui"):FindFirstChild("CoolUI") then
    game:GetService("CoreGui"):FindFirstChild("CoolUI"):Destroy()
end

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CoolUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

if RunService:IsStudio() then
    ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
else
    ScreenGui.Parent = game:GetService("CoreGui")
end

local blur = Instance.new("BlurEffect")
blur.Size = 0
pcall(function()
    blur.Parent = game:GetService("Lighting")
end)

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 300, 0, 400)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local UIGradient = Instance.new("UIGradient")
UIGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 40, 60)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(25, 25, 35))
})
UIGradient.Rotation = 45
UIGradient.Parent = MainFrame

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 15)
UICorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Text = "♢ Syfer-eng │ TP Menu ♢"
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Position = UDim2.new(0, 0, 0, 10)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 24
Title.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(255, 255, 255)
UIStroke.Thickness = 2
UIStroke.Transparency = 0.5
UIStroke.Parent = Title

local PlayerList = Instance.new("ScrollingFrame")
PlayerList.Size = UDim2.new(0.9, 0, 0.5, 0)
PlayerList.Position = UDim2.new(0.05, 0, 0.2, 0)
PlayerList.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
PlayerList.BorderSizePixel = 0
PlayerList.ScrollBarThickness = 4
PlayerList.ClipsDescendants = true
PlayerList.Parent = MainFrame

local ListCorner = UICorner:Clone()
ListCorner.Parent = PlayerList

local ButtonsContainer = Instance.new("Frame")
ButtonsContainer.Size = UDim2.new(0.9, 0, 0.2, 0)
ButtonsContainer.Position = UDim2.new(0.05, 0, 0.75, 0)
ButtonsContainer.BackgroundTransparency = 1
ButtonsContainer.Parent = MainFrame

local function createMenuButton(name, position, color)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0.48, 0, 0, 35)
    button.Position = position
    button.BackgroundColor3 = color
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Text = name
    button.Font = Enum.Font.GothamSemibold
    button.TextSize = 14
    button.AutoButtonColor = false
    button.Parent = ButtonsContainer
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 8)
    buttonCorner.Parent = button
    
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.3), {
            BackgroundColor3 = Color3.fromRGB(
                math.min(color.R * 255 + 20, 255),
                math.min(color.G * 255 + 20, 255),
                math.min(color.B * 255 + 20, 255)
            )
        }):Play()
    end)
    
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.3), {
            BackgroundColor3 = color
        }):Play()
    end)
    
    return button
end

local function updatePlayerList()
    for _, child in pairs(PlayerList:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    
    local yOffset = 5
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= Players.LocalPlayer then
            local button = Instance.new("TextButton")
            button.Size = UDim2.new(0.95, 0, 0, 35)
            button.Position = UDim2.new(0.025, 0, 0, yOffset)
            button.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
            button.TextColor3 = Color3.fromRGB(200, 200, 255)
            button.Text = player.Name
            button.Font = Enum.Font.GothamSemibold
            button.TextSize = 16
            button.AutoButtonColor = false
            button.Parent = PlayerList
            
            local buttonCorner = UICorner:Clone()
            buttonCorner.Parent = button
            
            button.MouseEnter:Connect(function()
                TweenService:Create(button, TweenInfo.new(0.3), {
                    BackgroundColor3 = Color3.fromRGB(60, 60, 90),
                    TextColor3 = Color3.fromRGB(255, 255, 255)
                }):Play()
            end)
            
            button.MouseLeave:Connect(function()
                TweenService:Create(button, TweenInfo.new(0.3), {
                    BackgroundColor3 = Color3.fromRGB(40, 40, 60),
                    TextColor3 = Color3.fromRGB(200, 200, 255)
                }):Play()
            end)
            
            button.MouseButton1Click:Connect(function()
                if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local localPlayer = Players.LocalPlayer
                    if localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        localPlayer.Character.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame
                    end
                end
            end)
            
            yOffset = yOffset + 40
        end
    end
    
    PlayerList.CanvasSize = UDim2.new(0, 0, 0, yOffset + 5)
end

local refreshButton = createMenuButton("Refresh", UDim2.new(0, 0, 0, 0), Color3.fromRGB(45, 125, 70))
refreshButton.MouseButton1Click:Connect(updatePlayerList)

local closeButton = createMenuButton("Close", UDim2.new(0.52, 0, 0, 0), Color3.fromRGB(180, 60, 60))
closeButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
end)



Players.PlayerAdded:Connect(updatePlayerList)
Players.PlayerRemoving:Connect(updatePlayerList)
updatePlayerList()

local dragging, dragInput, dragStart, startPos = false, nil, nil, nil

MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)

MainFrame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

RunService.RenderStepped:Connect(function()
    if dragging and dragInput then
        local delta = dragInput.Position - dragStart
        MainFrame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.Insert then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

MainFrame.Visible = true
