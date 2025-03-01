print("Welcome To Syfer-eng's World!")-- Services
loadstring(game:HttpGet("https://raw.githubusercontent.com/SYFER-eng/Roblox-Menu-Hub/refs/heads/main/Loading/Loading-Aim-Menu.lua",true))()
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

-- Settings
Settings = {
    Esq = {
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
    Eam Helper = {
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
BottomText.TextColor3 = Color3.fromRGB(255, 0, 255) -- Updated to bright magenta
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
    Esq = CreatePage("Esq"),
    Eam Helper = CreatePage("Eam Helper"),
    Misc = CreatePage("Misc")
}

-- Setup Navigation
local NavButtons = {}
local PageOrder = {"Esq", "Eam Helper", "Misc"}

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
            if Settings.Eam Helper.TeamCheck and player.Team == Players.LocalPlayer.Team then
                continue
            end

            local character = player.Character
            if character then
                local targetPart = character:FindFirstChild(Settings.Eam Helper.TargetPart)
                if targetPart then
                    local pos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(targetPart.Position)
                    if onScreen then
                        local distance = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
                        if distance <= Settings.Eam Helper.FOV then
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

-- Function to make the player's character face the target
local function MakePlayerLookAtTarget(target)
    if target and target.Character then
        local targetPart = target.Character:FindFirstChild(Settings.Eam Helper.TargetPart)
        if targetPart then
            -- Get the target position and the player's humanoid root part position
            local targetPosition = targetPart.Position
            local playerCharacter = Players.LocalPlayer.Character
            local playerHumanoidRootPart = playerCharacter:FindFirstChild("HumanoidRootPart")
            
            -- Ensure the player character exists and the humanoid root part is found
            if playerHumanoidRootPart then
                -- Calculate the direction vector to the target
                local direction = (targetPosition - playerHumanoidRootPart.Position).unit
                
                -- Create a new CFrame to make the character rotate toward the target
                local newCFrame = CFrame.lookAt(playerHumanoidRootPart.Position, targetPosition)
                
                -- Update the character's HumanoidRootPart to look at the target
                playerHumanoidRootPart.CFrame = newCFrame
            end
        end
    end
end

-- Function to detect right mouse button press and hold
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.UserInputType == Enum.UserInputType.MouseButton2 then
        aiming = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        aiming = false
    end
end)

-- Main loop to continuously aim and make your player look at the closest player when aiming
RunService.RenderStepped:Connect(function()
    if aiming and Settings.Eam Helper.Enabled then
        local closestPlayer = GetClosestPlayer()
        if closestPlayer then
            MakePlayerLookAtTarget(closestPlayer)
        end
    end
end)

-- ESP Implementation
local function CreateSnapline(player)
    local Line = Drawing.new("Line")
    Line.Thickness = 2 -- Increased thickness for glow effect
    Line.Color = Color3.fromRGB(255, 0, 255) -- Default color before rainbow toggle
    Line.Transparency = 1
    Line.Visible = false
    Line.ZIndex = 999998
    Settings.Esq.Tracers[player] = Line
end

-- ESP Implementation
local function CreateEsq(player)
    local Esq = {
        Box = Drawing.new("Square"),
        Name = Drawing.new("Text"),
        Distance = Drawing.new("Text"),
        Snapline = Drawing.new("Line")
    }

    Esq.Box.Visible = false
    Esq.Box.Color = Settings.Esq.BoxColor
    Esq.Box.Thickness = 2
    Esq.Box.Filled = false
    Esq.Box.Transparency = 1

    Esq.Name.Visible = false
    Esq.Name.Color = Color3.new(1, 1, 1)
    Esq.Name.Size = 14
    Esq.Name.Center = true
    Esq.Name.Outline = true

    Esq.Distance.Visible = false
    Esq.Distance.Color = Color3.new(1, 1, 1)
    Esq.Distance.Size = 12
    Esq.Distance.Center = true
    Esq.Distance.Outline = true

    Esq.Snapline.Visible = false
    Esq.Snapline.Color = Settings.Esq.BoxColor
    Esq.Snapline.Thickness = 1
    Esq.Snapline.Transparency = 1

    Settings.Esq.Players[player] = Esq
end

local function UpdateEsq()
    for player, Esq in pairs(Settings.Esq.Players) do
        if player.Character and player ~= Players.LocalPlayer and player.Character:FindFirstChild("HumanoidRootPart") then
            local humanoidRootPart = player.Character.HumanoidRootPart
            local head = player.Character:FindFirstChild("Head")
            local screenPos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(humanoidRootPart.Position)
            
            if onScreen and Settings.Esq.Enabled then
                if Settings.Esq.TeamCheck and player.Team == Players.LocalPlayer.Team then
                    Esq.Box.Visible = false
                    Esq.Name.Visible = false
                    Esq.Distance.Visible = false
                    Esq.Snapline.Visible = false
                    continue
                end

                -- Update Box ESP
                if Settings.Esq.Boxes then
                    local size = (workspace.CurrentCamera:WorldToViewportPoint(humanoidRootPart.Position + Vector3.new(3, 6, 0)).Y - workspace.CurrentCamera:WorldToViewportPoint(humanoidRootPart.Position + Vector3.new(-3, -3, 0)).Y) / 2
                    Esq.Box.Size = Vector2.new(size * 0.7, size * 1)
                    Esq.Box.Position = Vector2.new(screenPos.X - Esq.Box.Size.X / 2, screenPos.Y - Esq.Box.Size.Y / 2)
                    Esq.Box.Color = Settings.Esq.Rainbow and Color3.fromHSV(tick() % 5 / 5, 1, 1) or Settings.Esq.BoxColor
                    Esq.Box.Visible = true
                else
                    Esq.Box.Visible = false
                end

                -- Update Snaplines
                if Settings.Esq.Snaplines then
                    Esq.Snapline.From = Vector2.new(workspace.CurrentCamera.ViewportSize.X / 2, workspace.CurrentCamera.ViewportSize.Y)
                    Esq.Snapline.To = Vector2.new(screenPos.X, screenPos.Y)
                    Esq.Snapline.Color = Settings.Esq.Rainbow and Color3.fromHSV(tick() % 5 / 5, 1, 1) or Settings.Esq.BoxColor
                    Esq.Snapline.Visible = true
                else
                    Esq.Snapline.Visible = false
                end

                -- Update Names
                if Settings.Esq.Names and head then
                    Esq.Name.Position = Vector2.new(screenPos.X, screenPos.Y - Esq.Box.Size.Y / 2 - 15)
                    Esq.Name.Text = player.Name
                    Esq.Name.Visible = true
                else
                    Esq.Name.Visible = false
                end

                -- Update Distance
                if Settings.Esq.Distance then
                    local distance = math.floor((humanoidRootPart.Position - workspace.CurrentCamera.CFrame.Position).Magnitude)
                    Esq.Distance.Position = Vector2.new(screenPos.X, screenPos.Y + Esq.Box.Size.Y / 2 + 5)
                    Esq.Distance.Text = tostring(distance) .. " studs"
                    Esq.Distance.Visible = true
                else
                    Esq.Distance.Visible = false
                end
            else
                Esq.Box.Visible = false
                Esq.Name.Visible = false
                Esq.Distance.Visible = false
                Esq.Snapline.Visible = false
            end
        else
            Esq.Box.Visible = false
            Esq.Name.Visible = false
            Esq.Distance.Visible = false
            Esq.Snapline.Visible = false
        end
    end
end

-- Initialize UI Elements
local function InitializeUI()
    -- ESP Page
    CreateToggle(Pages.Esq, "Enable Esq", function(enabled)
        Settings.Esq.Enabled = enabled
    end)
    
    CreateToggle(Pages.Esq, "Box Esq", function(enabled)
        Settings.Esq.Boxes = enabled
    end)
    
    CreateToggle(Pages.Esq, "Snaplines", function(enabled)
        Settings.Esq.Snaplines = enabled
    end)
    
    CreateToggle(Pages.Esq, "Team Check", function(enabled)
        Settings.Esq.TeamCheck = enabled
    end)
    
    CreateToggle(Pages.Esq, "Rainbow Mode", function(enabled)
        Settings.Esq.Rainbow = enabled
    end)

    -- Aimbot Page
    CreateToggle(Pages.Eam Helper, "Enable Eam Helper", function(enabled)
        Settings.Eam Helper.Enabled = enabled
    end)

    CreateToggle(Pages.Eam Helper, "Show FOV", function(enabled)
        Settings.Eam Helper.ShowFOV = enabled
        FOVCircle.Visible = enabled
    end)

    CreateToggle(Pages.Eam Helper, "Team Check", function(enabled)
        Settings.Eam Helper.TeamCheck = enabled
    end)

    CreateSlider(Pages.Eam Helper, "Smoothness", 1, 10, 1, function(value)
        Settings.Eam Helper.Smoothness = value
    end)

    CreateSlider(Pages.Eam Helper, "FOV Size", 10, 800, 100, function(value)
        Settings.Eam Helper.FOV = value
        FOVCircle.Radius = value
    end)

    -- Misc Page
    CreateToggle(Pages.Misc, "No Recoil", function(enabled)
        Settings.Misc.NoRecoil = enabled
    end)

    CreateToggle(Pages.Misc, "Bunny Hop", function(enabled)
        Settings.Misc.BunnyHop = enabled
    end)
end

-- Initialize ESP for existing players
for _, player in pairs(Players:GetPlayers()) do
    if player ~= Players.LocalPlayer then
        CreateEsq(player)
    end
end

-- Handle new players
Players.PlayerAdded:Connect(function(player)
    if player ~= Players.LocalPlayer then
        CreateEsq(player)
    end
end)

-- Cleanup when players leave
Players.PlayerRemoving:Connect(function(player)
    if Settings.Esq.Players[player] then
        Settings.Esq.Players[player]:Remove()
        Settings.Esq.Players[player] = nil
    end
    if Settings.Esq.Tracers[player] then
        Settings.Esq.Tracers[player]:Remove()
        Settings.Esq.Tracers[player] = nil
    end
end)

-- Main Update Loop
RunService.RenderStepped:Connect(function()
    UpdateEsq() -- Make sure this is called every frame
    if Settings.Eam Helper.Enabled and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local target = GetClosestPlayer()
        if target and target.Character then
            local targetPart = target.Character:FindFirstChild(Settings.Eam Helper.TargetPart)
            if targetPart then
                local targetPos = targetPart.Position
                local smoothness = Settings.Eam Helper.Smoothness
                
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

    if Settings.Eam Helper.ShowFOV then
        UpdateEsq()
        FOVCircle.Position = UserInputService:GetMouseLocation()
        FOVCircle.Radius = Settings.Eam Helper.FOV
        FOVCircle.Visible = true
    else
        FOVCircle.Visible = false
    end
end)

local function DisableAllFeatures()
    -- ESP Settings
    Settings.Esq.Enabled = false
    Settings.Esq.Boxes = false
    Settings.Esq.Names = false
    Settings.Esq.Distance = false
    Settings.Esq.Snaplines = false
    Settings.Esq.TeamCheck = false
    Settings.Esq.Rainbow = false
    
    -- Aimbot Settings
    Settings.Eam Helper.Enabled = false
    Settings.Eam Helper.TeamCheck = false
    Settings.Eam Helper.ShowFOV = false
    FOVCircle.Visible = false
    
    -- Misc Settings
    Settings.Misc.NoRecoil = false
    Settings.Misc.BunnyHop = false
    
    -- Clean up ESP drawings
    for _, Esq in pairs(Settings.Esq.Players) do
        Esq.Box.Visible = false
        Esq.Name.Visible = false
        Esq.Distance.Visible = false
        Esq.Snapline.Visible = false
    end
    
    -- Remove the GUI
    if ScreenGui then
        ScreenGui:Destroy()
    end
end

-- Add key detection for End and Delete keys
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed then
        if input.KeyCode == Enum.KeyCode.End or input.KeyCode == Enum.KeyCode.Delete then
            DisableAllFeatures()
        end
    end
end)

-- Initialize the UI
InitializeUI()

-- Show first page by default
Pages.Esq.Visible = true
NavButtons.Esq.BackgroundColor3 = Color3.fromRGB(255, 0, 255)

-- Toggle GUI visibility
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.Insert then
        MainFrame.Visible = not MainFrame.Visible
    end
end)
