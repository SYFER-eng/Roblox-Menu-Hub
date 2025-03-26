local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

-- Create fancy UI elements
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local UICorner = Instance.new("UICorner")
local PlayerList = Instance.new("ScrollingFrame")
local UIListLayout = Instance.new("UIListLayout")
local TopBar = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local CloseButton = Instance.new("TextButton")

-- Cool styling
MainFrame.Size = UDim2.new(0, 350, 0, 500)
MainFrame.Position = UDim2.new(0.8, 0, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.BorderSizePixel = 0
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

-- Stylish top bar
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local topBarCorner = UICorner:Clone()
topBarCorner.Parent = TopBar

Title.Size = UDim2.new(0.8, 0, 1, 0)
Title.Position = UDim2.new(0.1, 0, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "Player Logger Pro"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.Parent = TopBar

-- Fancy close button
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(0.92, 0, 0.1, 0)
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Parent = TopBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0.5, 0)
closeCorner.Parent = CloseButton

-- Enhanced scrolling list
PlayerList.Size = UDim2.new(1, -20, 1, -60)
PlayerList.Position = UDim2.new(0, 10, 0, 50)
PlayerList.BackgroundTransparency = 1
PlayerList.ScrollBarThickness = 4
PlayerList.Parent = MainFrame

UIListLayout.Parent = PlayerList
UIListLayout.Padding = UDim.new(0, 10)

local function createPlayerEntry(player)
    local entry = Instance.new("Frame")
    entry.Size = UDim2.new(1, 0, 0, 90)
    entry.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    
    local entryCorner = UICorner:Clone()
    entryCorner.CornerRadius = UDim.new(0, 8)
    entryCorner.Parent = entry
    
    local pic = Instance.new("ImageLabel")
    pic.Size = UDim2.new(0, 75, 0, 75)
    pic.Position = UDim2.new(0, 8, 0, 8)
    pic.BackgroundTransparency = 1
    
    local picCorner = UICorner:Clone()
    picCorner.CornerRadius = UDim.new(0, 8)
    picCorner.Parent = pic
    
    -- Get player thumbnail with glow effect
    local userId = player.UserId
    local thumbType = Enum.ThumbnailType.HeadShot
    local thumbSize = Enum.ThumbnailSize.Size420x420
    local content = Players:GetUserThumbnailAsync(userId, thumbType, thumbSize)
    pic.Image = content
    pic.Parent = entry
    
    local info = Instance.new("TextLabel")
    info.Size = UDim2.new(0.65, 0, 1, 0)
    info.Position = UDim2.new(0.32, 0, 0, 0)
    info.BackgroundTransparency = 1
    info.TextColor3 = Color3.new(1, 1, 1)
    info.TextXAlignment = Enum.TextXAlignment.Left
    info.Font = Enum.Font.GothamSemibold
    info.TextSize = 14
    info.Text = string.format("Username: %s\nUser ID: %s\nDisplay Name: %s", 
        player.Name,
        tostring(userId),
        player.DisplayName)
    info.Parent = entry
    
    -- Cool hover effect
    entry.MouseEnter:Connect(function()
        TweenService:Create(entry, TweenInfo.new(0.3), {
            BackgroundColor3 = Color3.fromRGB(45, 45, 50)
        }):Play()
    end)
    
    entry.MouseLeave:Connect(function()
        TweenService:Create(entry, TweenInfo.new(0.3), {
            BackgroundColor3 = Color3.fromRGB(35, 35, 40)
        }):Play()
    end)
    
    return entry
end

-- Draggable functionality
local dragging
local dragInput
local dragStart
local startPos

local function updateDrag(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
        startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)

TopBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

TopBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        updateDrag(input)
    end
end)

-- Close button functionality
CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Main logging function
local function startLogger()
    ScreenGui.Parent = game:GetService("CoreGui")
    MainFrame.Parent = ScreenGui
    
    for _, player in pairs(Players:GetPlayers()) do
        local entry = createPlayerEntry(player)
        entry.Parent = PlayerList
    end
    
    Players.PlayerAdded:Connect(function(player)
        local entry = createPlayerEntry(player)
        entry.Parent = PlayerList
    end)
    
    Players.PlayerRemoving:Connect(function(player)
        for _, entry in pairs(PlayerList:GetChildren()) do
            if entry:FindFirstChild("info") and entry.info.Text:match(player.Name) then
                entry:Destroy()
            end
        end
    end)
end

startLogger()
