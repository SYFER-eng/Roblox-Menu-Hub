-- Part 1: Core Setup, Services, and Main UI Framework

local SyferLib = {}

print("Welcome To Syfer-eng's World!")

-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

-- Settings
SyferLib.Settings = {
    ESP = {
        Enabled = false,
        Boxes = false,
        Names = false,
        Distance = false,
        Health = false,
        Snaplines = false,
        TeamCheck = false,
        Rainbow = false,
        BoxColor = Color3.fromRGB(255, 0, 255),
        Players = {},
        Tracers = {}
    },
    Aimbot = {
        Enabled = false,
        TeamCheck = false,
        Smoothness = 1,
        FOV = 100,
        TargetPart = "Head",
        ShowFOV = false
    },
    Misc = {
        NoRecoil = false,
        BunnyHop = false
    }
}

-- Create Main GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Syfer-eng's Menu"
ScreenGui.DisplayOrder = 999999
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global

-- Try to parent to CoreGui
local success, result = pcall(function()
    ScreenGui.Parent = CoreGui
end)

if not success then
    ScreenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
end

-- Main Frame Setup
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 749, 0, 520)
MainFrame.Position = UDim2.new(0.5, -334, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ZIndex = 999999
MainFrame.Parent = ScreenGui

local BottomText = Instance.new("TextLabel")
BottomText.Name = "BottomText"
BottomText.Size = UDim2.new(1, 0, 0, 20)
BottomText.Position = UDim2.new(0, 0, 1, -20)
BottomText.BackgroundTransparency = 1
BottomText.Text = "Press End Or Delete To Close The Menu"
BottomText.TextColor3 = Color3.fromRGB(255, 0, 255)
BottomText.Font = Enum.Font.GothamSemibold
BottomText.TextSize = 14
BottomText.ZIndex = 999999
BottomText.Parent = MainFrame

local UIGradient_Bottom = Instance.new("UIGradient")
UIGradient_Bottom.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 255))
}
UIGradient_Bottom.Parent = BottomText

-- UI Elements
local UICorner_Main = Instance.new("UICorner")
UICorner_Main.CornerRadius = UDim.new(0, 10)
UICorner_Main.Parent = MainFrame

-- Shadow Effect
local Shadow = Instance.new("ImageLabel")
Shadow.Name = "Shadow"
Shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Shadow.BackgroundTransparency = 1
Shadow.Position = UDim2.new(-0.0293, 0, -0.0244, 0)
Shadow.Size = UDim2.new(1.06, 0, 1.06, 0)
Shadow.ZIndex = 999998
Shadow.Image = "rbxassetid://5554236805"
Shadow.ImageColor3 = Color3.fromRGB(255, 0, 255)
Shadow.ImageTransparency = 0.4
Shadow.Parent = MainFrame
-- Title Setup
local Title = Instance.new("TextLabel")
Title.Name = "MenuTitle"
Title.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Font = Enum.Font.GothamBold
Title.Text = "•Ｓｙｆｅｒ－ｅｎｇ＇ｓ Ｍｅｎｕ•"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 22
Title.ZIndex = 999999
Title.Parent = MainFrame

local UIGradient_Title = Instance.new("UIGradient")
UIGradient_Title.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(138, 43, 226))
}
UIGradient_Title.Parent = Title

-- FOV Circle Setup
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2
FOVCircle.NumSides = 100
FOVCircle.Radius = 100
FOVCircle.Filled = false
FOVCircle.Visible = false
FOVCircle.ZIndex = 999
FOVCircle.Transparency = 1
FOVCircle.Color = Color3.fromRGB(255, 0, 255)

-- Navigation Setup
local Navigation = Instance.new("Frame")
Navigation.Size = UDim2.new(1, 0, 0, 50)
Navigation.Position = UDim2.new(0, 0, 0, 40)
Navigation.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Navigation.ZIndex = 999999
Navigation.Parent = MainFrame

local UICorner_Nav = Instance.new("UICorner")
UICorner_Nav.CornerRadius = UDim.new(0, 6)
UICorner_Nav.Parent = Navigation

-- Create Page Function
local function CreatePage(name)
    local Page = Instance.new("ScrollingFrame")
    Page.Name = name
    Page.Size = UDim2.new(1, 0, 1, -90)
    Page.Position = UDim2.new(0, 0, 0, 90)
    Page.BackgroundTransparency = 1
    Page.ScrollBarThickness = 2
    Page.ScrollBarImageColor3 = Color3.fromRGB(255, 0, 255)
    Page.ZIndex = 999999
    Page.Parent = MainFrame

    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.Parent = Page
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Padding = UDim.new(0, 5)

    return Page
end

-- Create Navigation Buttons
local function CreateNavButton(text, position)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(0.33, -4, 1, -4)
    Button.Position = position
    Button.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    Button.Text = text
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.Font = Enum.Font.GothamBold
    Button.TextSize = 14
    Button.Parent = Navigation
    Button.ZIndex = 999999

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 6)
    UICorner.Parent = Button

    return Button
end

-- Create Toggle Function
local function CreateToggle(parent, name, callback)
    local Toggle = Instance.new("Frame")
    Toggle.Size = UDim2.new(0.9, 0, 0, 40)
    Toggle.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    Toggle.Position = UDim2.new(0.05, 0, 0, 0)
    Toggle.ZIndex = 999999
    Toggle.Parent = parent

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 6)
    UICorner.Parent = Toggle

    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, 0, 1, 0)
    Button.BackgroundTransparency = 1
    Button.Text = name
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.Font = Enum.Font.GothamSemibold
    Button.TextSize = 14
    Button.ZIndex = 999999
    Button.Parent = Toggle

    local Status = Instance.new("Frame")
    Status.Size = UDim2.new(0, 10, 0, 10)
    Status.Position = UDim2.new(0.95, -5, 0.5, -5)
    Status.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    Status.ZIndex = 999999
    Status.Parent = Toggle

    local UICorner_Status = Instance.new("UICorner")
    UICorner_Status.CornerRadius = UDim.new(1, 0)
    UICorner_Status.Parent = Status

    local enabled = false
    Button.MouseButton1Click:Connect(function()
        enabled = not enabled
        Status.BackgroundColor3 = enabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
        callback(enabled)
    end)
end
-- Part 3: Core Features, ESP, Aimbot, and Event Handlers

-- Create Slider Function
local function CreateSlider(parent, name, min, max, default, callback)
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Size = UDim2.new(0.9, 0, 0, 45)
    SliderFrame.Position = UDim2.new(0.05, 0, 0, 0)
    SliderFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    SliderFrame.Parent = parent

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 6)
    UICorner.Parent = SliderFrame

    local Title = Instance.new("TextLabel")
    Title.Text = name
    Title.Size = UDim2.new(1, 0, 0, 20)
    Title.BackgroundTransparency = 1
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 14
    Title.Font = Enum.Font.GothamSemibold
    Title.Parent = SliderFrame

    local SliderBar = Instance.new("Frame")
    SliderBar.Size = UDim2.new(0.9, 0, 0, 5)
    SliderBar.Position = UDim2.new(0.05, 0, 0.7, 0)
    SliderBar.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    SliderBar.Parent = SliderFrame

    local UICorner_2 = Instance.new("UICorner")
    UICorner_2.CornerRadius = UDim.new(1, 0)
    UICorner_2.Parent = SliderBar

    local SliderButton = Instance.new("TextButton")
    SliderButton.Size = UDim2.new(0.1, 0, 1.5, 0)
    SliderButton.Position = UDim2.new((default - min)/(max - min), 0, -0.25, 0)
    SliderButton.BackgroundColor3 = Color3.fromRGB(255, 0, 255)
    SliderButton.Text = ""
    SliderButton.Parent = SliderBar

    local UICorner_3 = Instance.new("UICorner")
    UICorner_3.CornerRadius = UDim.new(1, 0)
    UICorner_3.Parent = SliderButton

    local Value = Instance.new("TextLabel")
    Value.Text = tostring(default)
    Value.Size = UDim2.new(1, 0, 0, 20)
    Value.Position = UDim2.new(0, 0, 0.3, 0)
    Value.BackgroundTransparency = 1
    Value.TextColor3 = Color3.fromRGB(255, 255, 255)
    Value.TextSize = 14
    Value.Font = Enum.Font.GothamSemibold
    Value.Parent = SliderFrame

    local dragging = false
    SliderButton.MouseButton1Down:Connect(function()
        dragging = true
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mousePos = UserInputService:GetMouseLocation()
            local sliderPos = SliderBar.AbsolutePosition
            local sliderSize = SliderBar.AbsoluteSize
            local percent = math.clamp((mousePos.X - sliderPos.X) / sliderSize.X, 0, 1)
            local value = min + (max - min) * percent
            value = math.floor(value)
            Value.Text = tostring(value)
            SliderButton.Position = UDim2.new(percent, 0, -0.25, 0)
            callback(value)
        end
    end)
end

-- Create Pages
local Pages = {
    ESP = CreatePage("ESP"),
    Aimbot = CreatePage("Aimbot"),
    Misc = CreatePage("Misc")
}

-- Setup Navigation
local NavButtons = {}
local PageOrder = {"ESP", "Aimbot", "Misc"}

for i, pageName in ipairs(PageOrder) do
    local btn = CreateNavButton(pageName, UDim2.new((i-1) * 0.33, 2, 0, 2))
    NavButtons[pageName] = btn

    btn.MouseButton1Click:Connect(function()
        for _, page in pairs(Pages) do
            page.Visible = false
        end
        Pages[pageName].Visible = true

        for _, button in pairs(NavButtons) do
            button.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
        end
        btn.BackgroundColor3 = Color3.fromRGB(255, 0, 255)
    end)
end

-- Initialize ESP for existing players
for _, player in pairs(Players:GetPlayers()) do
    if player ~= Players.LocalPlayer then
        CreateESP(player)
    end
end

-- Handle new players
Players.PlayerAdded:Connect(function(player)
    if player ~= Players.LocalPlayer then
        CreateESP(player)
    end
end)

-- Handle player removal
Players.PlayerRemoving:Connect(function(player)
    if Settings.ESP.Players[player] then
        Settings.ESP.Players[player]:Remove()
        Settings.ESP.Players[player] = nil
    end
end)

-- Main Update Loop
RunService.RenderStepped:Connect(function()
    UpdateESP()
    if Settings.Aimbot.Enabled and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local target = GetClosestPlayer()
        if target then
            MakePlayerLookAtTarget(target)
        end
    end
    
    if Settings.Aimbot.ShowFOV then
        FOVCircle.Position = UserInputService:GetMouseLocation()
        FOVCircle.Radius = Settings.Aimbot.FOV
        FOVCircle.Visible = true
    else
        FOVCircle.Visible = false
    end
end)

-- Key bindings for menu toggle and close
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed then
        if input.KeyCode == Enum.KeyCode.End or input.KeyCode == Enum.KeyCode.Delete then
            DisableAllFeatures()
        elseif input.KeyCode == Enum.KeyCode.Insert then
            MainFrame.Visible = not MainFrame.Visible
        end
    end
end)

return SyferLib
