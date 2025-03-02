--// Load Teleport Cheat
loadstring(game:HttpGet("https://raw.githubusercontent.com/SYFER-eng/Roblox-Menu-Hub/refs/heads/main/Loading/Tp.lua", true))()

--// Local Variables for Player and Services
local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local tweenService = game:GetService("TweenService")
local userInputService = game:GetService("UserInputService")
local runService = game:GetService("RunService")

local menuVisible = true --// Toggle visibility of the menu
local isDragging = false --// Check if the menu is being dragged
local dragStart = nil --// Starting position of the drag
local startPos = nil --// The position the drag starts from

--// Color Definitions for the GUI
local COLORS = {
    BACKGROUND = Color3.fromRGB(20, 20, 25),
    ACCENT = Color3.fromRGB(175, 74, 235),
    TEXT = Color3.fromRGB(255, 255, 255),
    HIGHLIGHT = Color3.fromRGB(160, 120, 240),
    DARK_ACCENT = Color3.fromRGB(100, 80, 160),
    TAB_ACCENT = Color3.fromRGB(147, 112, 219)
}

--// Function to create a rainbow color effect
local function getRainbowColor(offset)
    local tick = tick() + (offset or 0)
    return Color3.fromHSV(tick % 5 / 5, 1, 1)  --// Color cycling effect based on time
end

--// Create ScreenGui to display the menu
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "Syfer-eng's Teloport Cheat"
screenGui.Parent = game:GetService("CoreGui") --// Set to CoreGui to make the menu appear
screenGui.ResetOnSpawn = false --// Prevent reset of the menu on respawn

--// Main Window for the menu (container for everything)
local mainWindow = Instance.new("Frame")
mainWindow.Size = UDim2.new(0, 800, 0, 500)
mainWindow.Position = UDim2.new(0.5, -400, 0.5, -250)
mainWindow.BackgroundColor3 = COLORS.BACKGROUND
mainWindow.BorderSizePixel = 0
mainWindow.Active = true --// Makes the window interactive
mainWindow.Draggable = true --// Allows dragging the window
mainWindow.ClipsDescendants = true --// Ensures content doesn't go outside the window
mainWindow.Parent = screenGui --// Parent the window to ScreenGui

--// Adding Shadow Effect to the menu window
local shadow = Instance.new("ImageLabel")
shadow.Size = UDim2.new(1.02, 0, 1.02, 0)
shadow.Position = UDim2.new(-0.01, 0, -0.01, 0)
shadow.BackgroundTransparency = 1
shadow.Image = "rbxassetid://297774371"
shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
shadow.ImageTransparency = 0.7
shadow.Parent = mainWindow

--// Corner radius for the main window (rounds corners)
local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 10)
mainCorner.Parent = mainWindow

--// Function to add a purple gradient background
local function addPurpleGradient(parent)
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, COLORS.BACKGROUND),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 25, 35))
    })
    gradient.Rotation = 45
    gradient.Parent = parent
end

addPurpleGradient(mainWindow) --// Apply gradient to the main window

--// Title Label for the top of the menu
local title = Instance.new("TextLabel")
title.Size = UDim2.new(0.4, 0, 0.06, 0)
title.Position = UDim2.new(0.3, 0, 0.02, 0)
title.BackgroundTransparency = 1
title.Text = "Syfer-eng │ Teloport"
title.TextColor3 = COLORS.TEXT
title.TextSize = 24
title.Font = Enum.Font.GothamBold
title.Parent = mainWindow

--// Text stroke effect for the title
local titleStroke = Instance.new("UIStroke")
titleStroke.Color = Color3.fromRGB(0, 0, 0)
titleStroke.Thickness = 1
titleStroke.Parent = title

--// Tab Container (container for the tabs at the top of the menu)
local tabContainer = Instance.new("Frame")
tabContainer.Size = UDim2.new(1, 0, 0.1, 0)
tabContainer.Position = UDim2.new(0, 0, 0.1, 0)
tabContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
tabContainer.BorderSizePixel = 0
tabContainer.Parent = mainWindow

--// Content Container (container for the content inside the menu)
local contentContainer = Instance.new("Frame")
contentContainer.Size = UDim2.new(1, 0, 0.9, 0)
contentContainer.Position = UDim2.new(0, 0, 0.1, 0)
contentContainer.BackgroundTransparency = 1
contentContainer.Parent = mainWindow

--// Function to enhance button visuals with hover effects
local function enhanceButton(button, isTab)
    button.BackgroundColor3 = isTab and COLORS.TAB_ACCENT or COLORS.ACCENT
    button.TextColor3 = COLORS.TEXT
    
    --// Add text stroke effect
    local textStroke = Instance.new("UIStroke")
    textStroke.Color = Color3.fromRGB(0, 0, 0)
    textStroke.Thickness = 1
    textStroke.Parent = button
    
    --// Add highlight effect when mouse hovers
    local highlight = Instance.new("UIStroke")
    highlight.Color = COLORS.HIGHLIGHT
    highlight.Thickness = 2
    highlight.Transparency = 0.5
    highlight.Parent = button
    
    button.MouseEnter:Connect(function()
        tweenService:Create(highlight, TweenInfo.new(0.3), {
            Transparency = 0,
            Color = COLORS.HIGHLIGHT
        }):Play()
    end)
    
    button.MouseLeave:Connect(function()
        tweenService:Create(highlight, TweenInfo.new(0.3), {
            Transparency = 0.5,
            Color = isTab and COLORS.TAB_ACCENT or COLORS.ACCENT
        }):Play()
    end)
end

--// Teleport Tab Button (Button for teleport functionality)
local tpTab = Instance.new("TextButton")
tpTab.Size = UDim2.new(0.5, 0, 1, 0)
tpTab.Position = UDim2.new(0, 0, 0, 0)
tpTab.BackgroundColor3 = COLORS.TAB_ACCENT
tpTab.Text = "Teleport"
tpTab.TextColor3 = COLORS.TEXT
tpTab.TextSize = 18
tpTab.Font = Enum.Font.GothamBold
tpTab.Parent = tabContainer
enhanceButton(tpTab, true)

--// Unload Tab Button (Button to unload the cheat menu)
local unloadTab = Instance.new("TextButton")
unloadTab.Size = UDim2.new(0.5, 0, 1, 0)
unloadTab.Position = UDim2.new(0.5, 0, 0, 0)
unloadTab.BackgroundColor3 = COLORS.DARK_ACCENT
unloadTab.Text = "Unload"
unloadTab.TextColor3 = COLORS.TEXT
unloadTab.TextSize = 18
unloadTab.Font = Enum.Font.GothamBold
unloadTab.Parent = tabContainer
enhanceButton(unloadTab, true)

--// Teleport Content Section (content for teleport functionality)
local tpContent = Instance.new("Frame")
tpContent.Size = UDim2.new(1, 0, 1, 0)
tpContent.BackgroundTransparency = 1
tpContent.Visible = true
tpContent.Parent = contentContainer

--// Player List Scrolling Frame (Scrollable list of players to teleport to)
local playerList = Instance.new("ScrollingFrame")
playerList.Size = UDim2.new(0.9, 0, 0.7, 0)
playerList.Position = UDim2.new(0.05, 0, 0.12, 0)
playerList.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
playerList.BorderSizePixel = 0
playerList.ScrollBarThickness = 6
playerList.Parent = tpContent

--// Reload Button (Button to reload the player list)
local reloadButton = Instance.new("TextButton")
reloadButton.Size = UDim2.new(0.3, 0, 0.06, 0)
reloadButton.Position = UDim2.new(0.35, 0, 0.92, 0)
reloadButton.BackgroundColor3 = COLORS.ACCENT
reloadButton.Text = "Reload List"
reloadButton.TextColor3 = COLORS.TEXT
reloadButton.TextSize = 16
reloadButton.Font = Enum.Font.GothamBold
reloadButton.Parent = tpContent
enhanceButton(reloadButton, false)

--// Unload Content Section (content for unload functionality)
local unloadContent = Instance.new("Frame")
unloadContent.Size = UDim2.new(1, 0, 1, 0)
unloadContent.BackgroundTransparency = 1
unloadContent.Visible = false
unloadContent.Parent = contentContainer

--// Unload Button (Button to unload the menu)
local unloadButton = Instance.new("TextButton")
unloadButton.Size = UDim2.new(0.3, 0, 0.1, 0)
unloadButton.Position = UDim2.new(0.35, 0, 0.45, 0)
unloadButton.BackgroundColor3 = COLORS.TAB_ACCENT
unloadButton.Text = "Unload Menu"
unloadButton.TextColor3 = COLORS.TEXT
unloadButton.TextSize = 18
unloadButton.Font = Enum.Font.GothamBold
unloadButton.Parent = unloadContent
enhanceButton(unloadButton, true)

--// Apply Corner Radius to elements
local function addCorners(button)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = button
end

addCorners(playerList)
addCorners(reloadButton)
addCorners(unloadButton)
addCorners(tpTab)
addCorners(unloadTab)

--// Create Player Button (Button for each player in the player list)
local function createPlayerButton(plr)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0.95, 0, 0, 40)
    button.BackgroundColor3 = COLORS.ACCENT
    button.Text = plr.DisplayName .. " (" .. plr.Name .. ")"
    button.TextColor3 = COLORS.TEXT
    button.TextSize = 16
    button.Font = Enum.Font.GothamSemibold
    button.Parent = playerList
    enhanceButton(button, false)
    addCorners(button)
    
    --// Teleport Logic: Teleport the player when the button is clicked
    button.MouseButton1Click:Connect(function()
        if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = plr.Character.HumanoidRootPart.CFrame
        end
    end)
    
    return button
end

--// Update the Player List (refresh the list of players)
local function updatePlayerList()
    for _, child in ipairs(playerList:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy() --// Destroy old player buttons
        end
    end
    
    local yOffset = 5 --// Starting Y offset for positioning buttons
    for _, plr in ipairs(game.Players:GetPlayers()) do
        if plr ~= player then
            local button = createPlayerButton(plr)
            button.Position = UDim2.new(0.025, 0, 0, yOffset)
            yOffset = yOffset + 45 --// Increase Y offset for the next player button
        end
    end
    
    playerList.CanvasSize = UDim2.new(0, 0, 0, yOffset) --// Adjust canvas size for scrolling
end

--// Reload Button Logic (refresh the list when clicked)
reloadButton.MouseButton1Click:Connect(function()
    reloadButton.BackgroundColor3 = COLORS.DARK_ACCENT
    updatePlayerList() --// Reload the player list
    wait(0.1)
    reloadButton.BackgroundColor3 = COLORS.ACCENT
end)

--// Unload Button Logic (unload the menu when clicked)
unloadButton.MouseButton1Click:Connect(function()
    screenGui:Destroy() --// Destroy the screen GUI to unload the cheat
end)

--// Automatically Update Player List (run periodically)
spawn(function()
    while wait(1) do
        if tpContent.Visible then
            updatePlayerList() --// Update the player list if the TP tab is visible
        end
    end
end)

--// Player Added/Removed Updates (rebuild player list when players join/leave)
game.Players.PlayerAdded:Connect(updatePlayerList)
game.Players.PlayerRemoving:Connect(updatePlayerList)

--// Toggle Menu (toggle visibility with Insert key)
userInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.Insert then
        menuVisible = not menuVisible
        screenGui.Enabled = menuVisible --// Toggle visibility of the menu
    end
end)

--// Initialize the GUI (make it visible and update player list)
mainWindow.Visible = true
updatePlayerList()

--// Tab Switching Logic (switch between teleport and unload tabs)
tpTab.MouseButton1Click:Connect(function()
    tpContent.Visible = true
    unloadContent.Visible = false
    tpTab.BackgroundColor3 = COLORS.TAB_ACCENT
    unloadTab.BackgroundColor3 = COLORS.DARK_ACCENT
end)

unloadTab.MouseButton1Click:Connect(function()
    tpContent.Visible = false
    unloadContent.Visible = true
    tpTab.BackgroundColor3 = COLORS.DARK_ACCENT
    unloadTab.BackgroundColor3 = COLORS.TAB_ACCENT
end)

--// Default to Teleport Tab on Start (hide unload content initially)
tpContent.Visible = true
unloadContent.Visible = false
tpTab.BackgroundColor3 = COLORS.TAB_ACCENT
unloadTab.BackgroundColor3 = COLORS.DARK_ACCENT
