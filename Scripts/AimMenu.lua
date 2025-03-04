print("Welcome To Syfer-eng's World!")

-- Services
loadstring(game:HttpGet("https://raw.githubusercontent.com/SYFER-eng/Roblox-Menu-Hub/refs/heads/main/Loading/Loading-Aim-Menu.lua",true))()

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

-- Settings
Settings = {
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
    }
}

-- Create Main GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "❤ Syfer-eng's Menu ❤"
ScreenGui.DisplayOrder = 999999
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global

local success, result = pcall(function()
    ScreenGui.Parent = CoreGui
end)
if not success then
    ScreenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
end

-- Main Frame Setup
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 800, 0, 600) -- Increased width to 800 from 669
MainFrame.Position = UDim2.new(0.5, -400, 0.5, -300) -- Adjusted X position to center the wider menu
MainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ZIndex = 999999
MainFrame.Parent = ScreenGui

-- Particle Background
local ParticleBackground = Instance.new("Frame")
ParticleBackground.Name = "ParticleBackground"
ParticleBackground.Size = UDim2.new(1, 0, 1, 0)
ParticleBackground.BackgroundTransparency = 0
ParticleBackground.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
ParticleBackground.ZIndex = 999998
ParticleBackground.Parent = MainFrame

-- Create particle effects
for i = 1, 50 do
    local Particle = Instance.new("Frame")
    Particle.Size = UDim2.new(0, 2, 0, 2)
    Particle.BackgroundColor3 = Color3.fromRGB(255, 0, 255)
    Particle.BackgroundTransparency = 0.5
    Particle.Position = UDim2.new(math.random(), 0, math.random(), 0)
    Particle.Parent = ParticleBackground
    
    spawn(function()
        while true do
            local tween = TweenService:Create(Particle, 
                TweenInfo.new(math.random(2, 5)), 
                {Position = UDim2.new(math.random(), 0, math.random(), 0)})
            tween:Play()
            wait(math.random(2, 5))
        end
    end)
end


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
Title.Text = "• Ｓｙｆｅｒ－ｅｎｇ＇ｓ Ｍｅｎｕ •"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 22
Title.ZIndex = 999999
Title.Parent = MainFrame

local UIGradient_Title = Instance.new("UIGradient")
UIGradient_Title.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 0, 200))
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
Navigation.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
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
    -- Outer Glow Frame
    local GlowFrame = Instance.new("Frame")
    GlowFrame.Size = UDim2.new(0.92, 0, 0, 44)
    GlowFrame.Position = UDim2.new(0.04, 0, 0, -2)
    GlowFrame.BackgroundColor3 = Color3.fromRGB(255, 0, 255)
    GlowFrame.ZIndex = 999998
    GlowFrame.Parent = parent

    -- Glow Gradient
    local UIGradient_Glow = Instance.new("UIGradient")
    UIGradient_Glow.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 255)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(170, 0, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 255))
    }
    UIGradient_Glow.Rotation = 45
    UIGradient_Glow.Parent = GlowFrame

    -- Add glow effect
    local UIStroke = Instance.new("UIStroke")
    UIStroke.Color = Color3.fromRGB(255, 0, 255)
    UIStroke.Thickness = 2
    UIStroke.Parent = GlowFrame

    local UICorner_Glow = Instance.new("UICorner")
    UICorner_Glow.CornerRadius = UDim.new(0, 6)
    UICorner_Glow.Parent = GlowFrame

    local Toggle = Instance.new("Frame")
    Toggle.Size = UDim2.new(1, -2, 1, -2)
    Toggle.Position = UDim2.new(0, 1, 0, 1)
    Toggle.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    Toggle.ZIndex = 999999
    Toggle.Parent = GlowFrame

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

    -- Hover Effect
    Button.MouseEnter:Connect(function()
        Toggle.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
        UIGradient_Glow.Rotation = UIGradient_Glow.Rotation + 45
    end)

    Button.MouseLeave:Connect(function()
        Toggle.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
        UIGradient_Glow.Rotation = UIGradient_Glow.Rotation - 45
    end)

    local Status = Instance.new("Frame")
    Status.Size = UDim2.new(0, 10, 0, 10)
    Status.Position = UDim2.new(0.95, -5, 0.5, -5)
    Status.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    Status.ZIndex = 999999
    Status.Parent = Toggle

    local UICorner_Status = Instance.new("UICorner")
    UICorner_Status.CornerRadius = UDim.new(1, 0)
    UICorner_Status.Parent = Status

    -- Animate gradient
    spawn(function()
        while true do
            UIGradient_Glow.Rotation = UIGradient_Glow.Rotation + 1
            wait(0.1)
        end
    end)

    local enabled = false
    Button.MouseButton1Click:Connect(function()
        enabled = not enabled
        Status.BackgroundColor3 = enabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
        callback(enabled)
    end)
end
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
    Aimbot = CreatePage("Aimbot")
}

-- Setup Navigation
local NavButtons = {}
local PageOrder = {"ESP", "Aimbot"}

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

local function GetClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = math.huge
    local mousePos = UserInputService:GetMouseLocation()
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= Players.LocalPlayer then
            if Settings.Aimbot.TeamCheck and player.Team == Players.LocalPlayer.Team then
                continue
            end
            
            local character = player.Character
            if character then
                local targetPart = character:FindFirstChild(Settings.Aimbot.TargetPart)
                if targetPart then
                    local pos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(targetPart.Position)
                    if onScreen then
                        local distance = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
                        if distance <= Settings.Aimbot.FOV then
                            if distance < shortestDistance then
                                closestPlayer = player
                                shortestDistance = distance
                            end
                        end
                    end
                end
            end
        end
    end
    return closestPlayer
end

-- ESP Implementation
local function CreateESP(player)
    local esp = {
        Box = Drawing.new("Square"),
        Name = Drawing.new("Text"),
        Distance = Drawing.new("Text"),
        Snapline = Drawing.new("Line")
    }
    
    esp.Box.Visible = false
    esp.Box.Color = Settings.ESP.BoxColor
    esp.Box.Thickness = 2
    esp.Box.Filled = false
    esp.Box.Transparency = 1
    
    esp.Name.Visible = false
    esp.Name.Color = Color3.new(1, 1, 1)
    esp.Name.Size = 14
    esp.Name.Center = true
    esp.Name.Outline = true
    
    esp.Distance.Visible = false
    esp.Distance.Color = Color3.new(1, 1, 1)
    esp.Distance.Size = 12
    esp.Distance.Center = true
    esp.Distance.Outline = true
    
    esp.Snapline.Visible = false
    esp.Snapline.Color = Settings.ESP.BoxColor
    esp.Snapline.Thickness = 1
    esp.Snapline.Transparency = 1
    
    Settings.ESP.Players[player] = esp
end

local function UpdateESP()
    for player, esp in pairs(Settings.ESP.Players) do
        if player.Character and player ~= Players.LocalPlayer and player.Character:FindFirstChild("HumanoidRootPart") then
            local humanoidRootPart = player.Character.HumanoidRootPart
            local head = player.Character:FindFirstChild("Head")
            local screenPos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(humanoidRootPart.Position)
            
            if onScreen and Settings.ESP.Enabled then
                if Settings.ESP.TeamCheck and player.Team == Players.LocalPlayer.Team then
                    esp.Box.Visible = false
                    esp.Name.Visible = false
                    esp.Distance.Visible = false
                    esp.Snapline.Visible = false
                    continue
                end

                -- Box ESP
                if Settings.ESP.Boxes then
                    local size = (workspace.CurrentCamera:WorldToViewportPoint(humanoidRootPart.Position + Vector3.new(3, 6, 0)).Y - workspace.CurrentCamera:WorldToViewportPoint(humanoidRootPart.Position + Vector3.new(-3, -3, 0)).Y) / 2
                    esp.Box.Size = Vector2.new(size * 0.7, size * 1)
                    esp.Box.Position = Vector2.new(screenPos.X - esp.Box.Size.X / 2, screenPos.Y - esp.Box.Size.Y / 2)
                    esp.Box.Color = Settings.ESP.Rainbow and Color3.fromHSV(tick() % 5 / 5, 1, 1) or Settings.ESP.BoxColor
                    esp.Box.Visible = true
                else
                    esp.Box.Visible = false
                end

                -- Names ESP
                if Settings.ESP.Names and head then
                    esp.Name.Position = Vector2.new(screenPos.X, screenPos.Y - esp.Box.Size.Y / 2 - 15)
                    esp.Name.Text = player.Name
                    esp.Name.Visible = true
                else
                    esp.Name.Visible = false
                end

                -- Distance ESP
                if Settings.ESP.Distance then
                    local distance = math.floor((humanoidRootPart.Position - workspace.CurrentCamera.CFrame.Position).Magnitude)
                    esp.Distance.Position = Vector2.new(screenPos.X, screenPos.Y + esp.Box.Size.Y / 2 + 5)
                    esp.Distance.Text = tostring(distance) .. " studs"
                    esp.Distance.Visible = true
                else
                    esp.Distance.Visible = false
                end

                -- Snaplines
                if Settings.ESP.Snaplines then
                    esp.Snapline.From = Vector2.new(workspace.CurrentCamera.ViewportSize.X / 2, workspace.CurrentCamera.ViewportSize.Y)
                    esp.Snapline.To = Vector2.new(screenPos.X, screenPos.Y)
                    esp.Snapline.Color = Settings.ESP.Rainbow and Color3.fromHSV(tick() % 5 / 5, 1, 1) or Settings.ESP.BoxColor
                    esp.Snapline.Visible = true
                else
                    esp.Snapline.Visible = false
                end
            else
                esp.Box.Visible = false
                esp.Name.Visible = false
                esp.Distance.Visible = false
                esp.Snapline.Visible = false
            end
        end
    end
end

-- Initialize UI Elements
local function InitializeUI()
    -- ESP Page
    CreateToggle(Pages.ESP, "Enable ESP", function(enabled)
        Settings.ESP.Enabled = enabled
    end)
    
    CreateToggle(Pages.ESP, "Box ESP", function(enabled)
        Settings.ESP.Boxes = enabled
    end)
    
    CreateToggle(Pages.ESP, "Snaplines", function(enabled)
        Settings.ESP.Snaplines = enabled
    end)
    CreateToggle(Pages.ESP, "Team Check", function(enabled)
        Settings.ESP.TeamCheck = enabled
    end)
    
    CreateToggle(Pages.ESP, "Rainbow Mode", function(enabled)
        Settings.ESP.Rainbow = enabled
    end)

    -- Aimbot Page
    CreateToggle(Pages.Aimbot, "Enable Aimbot", function(enabled)
        Settings.Aimbot.Enabled = enabled
    end)

    CreateToggle(Pages.Aimbot, "Show FOV", function(enabled)
        Settings.Aimbot.ShowFOV = enabled
        FOVCircle.Visible = enabled
    end)

    CreateToggle(Pages.Aimbot, "Team Check", function(enabled)
        Settings.Aimbot.TeamCheck = enabled
    end)

    CreateSlider(Pages.Aimbot, "Smoothness", 1, 10, 1, function(value)
        Settings.Aimbot.Smoothness = value
    end)

    CreateSlider(Pages.Aimbot, "FOV Size", 10, 800, 100, function(value)
        Settings.Aimbot.FOV = value
        FOVCircle.Radius = value
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

-- Cleanup when players leave
Players.PlayerRemoving:Connect(function(player)
    if Settings.ESP.Players[player] then
        for _, drawing in pairs(Settings.ESP.Players[player]) do
            drawing:Remove()
        end
        Settings.ESP.Players[player] = nil
    end
end)

-- Main Update Loop
RunService.RenderStepped:Connect(function()
    UpdateESP()
    
    if Settings.Aimbot.Enabled and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local target = GetClosestPlayer()
        if target and target.Character then
            local targetPart = target.Character:FindFirstChild(Settings.Aimbot.TargetPart)
            if targetPart then
                local targetPos = targetPart.Position
                local smoothness = Settings.Aimbot.Smoothness
                local currentCFrame = workspace.CurrentCamera.CFrame
                local targetCFrame = CFrame.new(currentCFrame.Position, targetPos)
                
                if smoothness > 1 then
                    workspace.CurrentCamera.CFrame = currentCFrame:Lerp(targetCFrame, 1 / smoothness)
                else
                    workspace.CurrentCamera.CFrame = targetCFrame
                end
            end
        end
    end

    if Settings.Aimbot.ShowFOV then
        FOVCircle.Position = UserInputService:GetMouseLocation()
        FOVCircle.Visible = true
    else
        FOVCircle.Visible = false
    end
end)

-- Initialize the UI
InitializeUI()

-- Show first page by default
Pages.ESP.Visible = true
NavButtons.ESP.BackgroundColor3 = Color3.fromRGB(255, 0, 255)

-- Cleanup function for End/Delete keys
local function CleanupEverything()
    -- Turn off all settings
    for category, settings in pairs(Settings) do
        for setting, _ in pairs(settings) do
            if type(Settings[category][setting]) == "boolean" then
                Settings[category][setting] = false
            end
        end
    end

    -- Clean up ESP drawings
    for player, esp in pairs(Settings.ESP.Players) do
        for _, drawing in pairs(esp) do
            drawing:Remove()
        end
    end
    Settings.ESP.Players = {}

    -- Remove FOV Circle
    FOVCircle:Remove()

    -- Remove GUI
    ScreenGui:Destroy()

    -- Clear variables
    Settings = nil
    Pages = nil
    NavButtons = nil
end

-- Input handling for GUI toggle and cleanup
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed then
        if input.KeyCode == Enum.KeyCode.Insert then
            MainFrame.Visible = not MainFrame.Visible
        elseif input.KeyCode == Enum.KeyCode.End or input.KeyCode == Enum.KeyCode.Delete then
            CleanupEverything()
        end
    end
end)

-- Create Watermark
local Watermark = Instance.new("TextLabel")
Watermark.Text = "Made By Syfer-eng"
Watermark.Size = UDim2.new(1, 0, 0, 20)
Watermark.Position = UDim2.new(0, 0, 1, -25)
Watermark.BackgroundTransparency = 1
Watermark.TextColor3 = Color3.fromRGB(255, 0, 255)
Watermark.Font = Enum.Font.GothamBold
Watermark.TextSize = 16
Watermark.Parent = MainFrame

-- Create Footer Text
local Footer = Instance.new("TextLabel")
Footer.Text = "Press End Or Delete To Close"
Footer.Size = UDim2.new(1, 0, 0, 20)
Footer.Position = UDim2.new(0, 0, 1, -45) -- Positioned above the watermark
Footer.BackgroundTransparency = 1
Footer.TextColor3 = Color3.fromRGB(255, 0, 255)
Footer.Font = Enum.Font.GothamBold
Footer.TextSize = 14
Footer.Parent = MainFrame

-- Add a cool gradient to the text
local UIGradient_Footer = Instance.new("UIGradient")
UIGradient_Footer.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 255)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(200, 0, 200)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 255))
}
UIGradient_Footer.Parent = Footer

print("Syfer-eng's Menu Loaded Successfully!")
