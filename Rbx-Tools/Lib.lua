-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

-- Initialize SyferLib
local SyferLib = {
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
        },
        Combat = {
            SilentAim = false,
            TriggerBot = false,
            HitChance = 100,
            DamageMultiplier = 1
        },
        Visual = {
            FullBright = false,
            NoFog = false,
            CustomFOV = 90,
            ESPColor = Color3.fromRGB(255, 0, 255)
        },
        Misc = {
            SpeedHack = false,
            InfiniteJump = false,
            NoClip = false,
            BunnyHop = false,
            SpeedMultiplier = 2
        },
        UI = {
            MenuColor = Color3.fromRGB(255, 0, 255),
            ToggleKey = Enum.KeyCode.Insert
        }
    }
}

-- Enhanced UI Creation Functions
function SyferLib:CreateButton(parent, text, callback)
    local Button = Instance.new("TextButton")
    Button.Name = text .. "_Button"
    Button.Size = UDim2.new(0.9, 0, 0, 40)
    Button.Position = UDim2.new(0.05, 0, 0, 0)
    Button.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    Button.Text = text
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.Font = Enum.Font.GothamSemibold
    Button.TextSize = 14
    Button.Parent = parent
    Button.AutoButtonColor = false
    Button.ZIndex = 1000

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 6)
    UICorner.Parent = Button

    local UIStroke = Instance.new("UIStroke")
    UIStroke.Color = Color3.fromRGB(255, 0, 255)
    UIStroke.Thickness = 1
    UIStroke.Parent = Button

    Button.MouseEnter:Connect(function()
        TweenService:Create(Button, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(40, 40, 45)
        }):Play()
    end)

    Button.MouseLeave:Connect(function()
        TweenService:Create(Button, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(30, 30, 35)
        }):Play()
    end)

    Button.MouseButton1Click:Connect(function()
        callback()
        TweenService:Create(Button, TweenInfo.new(0.1), {
            BackgroundColor3 = Color3.fromRGB(50, 50, 55)
        }):Play()
        wait(0.1)
        TweenService:Create(Button, TweenInfo.new(0.1), {
            BackgroundColor3 = Color3.fromRGB(30, 30, 35)
        }):Play()
    end)

    return Button
end

function SyferLib:CreateToggle(parent, text, callback)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Name = text .. "_Toggle"
    ToggleFrame.Size = UDim2.new(0.9, 0, 0, 40)
    ToggleFrame.Position = UDim2.new(0.05, 0, 0, 0)
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    ToggleFrame.Parent = parent
    ToggleFrame.ZIndex = 1000

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 6)
    UICorner.Parent = ToggleFrame

    local UIStroke = Instance.new("UIStroke")
    UIStroke.Color = Color3.fromRGB(255, 0, 255)
    UIStroke.Thickness = 1
    UIStroke.Parent = ToggleFrame

    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Size = UDim2.new(1, 0, 1, 0)
    ToggleButton.BackgroundTransparency = 1
    ToggleButton.Text = text
    ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleButton.Font = Enum.Font.GothamSemibold
    ToggleButton.TextSize = 14
    ToggleButton.Parent = ToggleFrame
    ToggleButton.ZIndex = 1001

    local ToggleIndicator = Instance.new("Frame")
    ToggleIndicator.Size = UDim2.new(0, 20, 0, 20)
    ToggleIndicator.Position = UDim2.new(0.95, -25, 0.5, -10)
    ToggleIndicator.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    ToggleIndicator.Parent = ToggleFrame
    ToggleIndicator.ZIndex = 1002

    local UICorner2 = Instance.new("UICorner")
    UICorner2.CornerRadius = UDim.new(0, 4)
    UICorner2.Parent = ToggleIndicator

    local enabled = false
    ToggleButton.MouseButton1Click:Connect(function()
        enabled = not enabled
        TweenService:Create(ToggleIndicator, TweenInfo.new(0.2), {
            BackgroundColor3 = enabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
        }):Play()
        callback(enabled)
    end)

    return ToggleFrame
end

function SyferLib:CreateSlider(parent, text, min, max, default, callback)
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Name = text .. "_Slider"
    SliderFrame.Size = UDim2.new(0.9, 0, 0, 60)
    SliderFrame.Position = UDim2.new(0.05, 0, 0, 0)
    SliderFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    SliderFrame.Parent = parent
    SliderFrame.ZIndex = 1000

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 6)
    UICorner.Parent = SliderFrame

    local UIStroke = Instance.new("UIStroke")
    UIStroke.Color = Color3.fromRGB(255, 0, 255)
    UIStroke.Thickness = 1
    UIStroke.Parent = SliderFrame

    local SliderTitle = Instance.new("TextLabel")
    SliderTitle.Size = UDim2.new(1, 0, 0, 30)
    SliderTitle.BackgroundTransparency = 1
    SliderTitle.Text = text
    SliderTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    SliderTitle.Font = Enum.Font.GothamSemibold
    SliderTitle.TextSize = 14
    SliderTitle.Parent = SliderFrame
    SliderTitle.ZIndex = 1001

    local SliderBar = Instance.new("Frame")
    SliderBar.Size = UDim2.new(0.9, 0, 0, 4)
    SliderBar.Position = UDim2.new(0.05, 0, 0.7, 0)
    SliderBar.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    SliderBar.Parent = SliderFrame
    SliderBar.ZIndex = 1001

    local UICorner2 = Instance.new("UICorner")
    UICorner2.CornerRadius = UDim.new(1, 0)
    UICorner2.Parent = SliderBar

    local SliderButton = Instance.new("TextButton")
    SliderButton.Size = UDim2.new(0, 16, 0, 16)
    SliderButton.Position = UDim2.new((default - min)/(max - min), -8, 0.5, -8)
    SliderButton.BackgroundColor3 = Color3.fromRGB(255, 0, 255)
    SliderButton.Text = ""
    SliderButton.Parent = SliderBar
    SliderButton.ZIndex = 1002

    local UICorner3 = Instance.new("UICorner")
    UICorner3.CornerRadius = UDim.new(1, 0)
    UICorner3.Parent = SliderButton

    local ValueLabel = Instance.new("TextLabel")
    ValueLabel.Size = UDim2.new(0, 50, 0, 20)
    ValueLabel.Position = UDim2.new(0.9, 0, 0, 5)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Text = tostring(default)
    ValueLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    ValueLabel.Font = Enum.Font.GothamSemibold
    ValueLabel.TextSize = 14
    ValueLabel.Parent = SliderFrame
    ValueLabel.ZIndex = 1001

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
            local barPos = SliderBar.AbsolutePosition
            local barSize = SliderBar.AbsoluteSize
            local percent = math.clamp((mousePos.X - barPos.X) / barSize.X, 0, 1)
            local value = math.floor(min + (max - min) * percent)
            ValueLabel.Text = tostring(value)
            SliderButton.Position = UDim2.new(percent, -8, 0.5, -8)
            callback(value)
        end
    end)

    return SliderFrame
end

    -- Create Main GUI
    function SyferLib:CreateMainGUI()
        local ScreenGui = Instance.new("ScreenGui")
        ScreenGui.Name = "SyferMenu"
        ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
        ScreenGui.ResetOnSpawn = false
        
        pcall(function()
            if syn then
                syn.protect_gui(ScreenGui)
            end
            ScreenGui.Parent = CoreGui
        end)

        local MainFrame = Instance.new("Frame")
        MainFrame.Name = "MainFrame"
        MainFrame.Size = UDim2.new(0, 750, 0, 450)
        MainFrame.Position = UDim2.new(0.5, -375, 0.5, -225)
        MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        MainFrame.BorderSizePixel = 0
        MainFrame.Active = true
        MainFrame.Draggable = true
        MainFrame.Parent = ScreenGui

        local UICorner = Instance.new("UICorner")
        UICorner.CornerRadius = UDim.new(0, 10)
        UICorner.Parent = MainFrame

        -- Create Title Bar
        local TitleBar = Instance.new("Frame")
        TitleBar.Name = "TitleBar"
        TitleBar.Size = UDim2.new(1, 0, 0, 40)
        TitleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
        TitleBar.Parent = MainFrame

        local TitleText = Instance.new("TextLabel")
        TitleText.Size = UDim2.new(1, 0, 1, 0)
        TitleText.BackgroundTransparency = 1
        TitleText.Text = "Syfer Menu"
        TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
        TitleText.Font = Enum.Font.GothamBold
        TitleText.TextSize = 18
        TitleText.Parent = TitleBar

        local UIGradient = Instance.new("UIGradient")
        UIGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(138, 43, 226))
        })
        UIGradient.Parent = TitleBar

        -- Create Tab Container
        local TabContainer = Instance.new("Frame")
        TabContainer.Name = "TabContainer"
        TabContainer.Size = UDim2.new(1, 0, 0, 40)
        TabContainer.Position = UDim2.new(0, 0, 0, 40)
        TabContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
        TabContainer.Parent = MainFrame

        -- Create Content Container
        local ContentContainer = Instance.new("Frame")
        ContentContainer.Name = "ContentContainer"
        ContentContainer.Size = UDim2.new(1, 0, 1, -80)
        ContentContainer.Position = UDim2.new(0, 0, 0, 80)
        ContentContainer.BackgroundTransparency = 1
        ContentContainer.Parent = MainFrame

        return ScreenGui, MainFrame, TabContainer, ContentContainer
    end

    -- Initialize Menu
    function SyferLib:Initialize()
        local ScreenGui, MainFrame, TabContainer, ContentContainer = self:CreateMainGUI()
        
        -- Create Pages
        local Pages = {
            Main = self:CreatePage("Main"),
            ESP = self:CreatePage("ESP"),
            Aimbot = self:CreatePage("Aimbot"),
            Combat = self:CreatePage("Combat"),
            Visual = self:CreatePage("Visual"),
            Misc = self:CreatePage("Misc"),
            Settings = self:CreatePage("Settings")
        }

        -- Parent pages to ContentContainer
        for name, page in pairs(Pages) do
            page.Parent = ContentContainer
            page.Visible = name == "Main"
        end

        -- Create navigation buttons
        local buttonOrder = {"Main", "ESP", "Aimbot", "Combat", "Visual", "Misc", "Settings"}
        local buttonWidth = 1 / #buttonOrder

        for i, name in ipairs(buttonOrder) do
            local button = Instance.new("TextButton")
            button.Size = UDim2.new(buttonWidth, -4, 1, -8)
            button.Position = UDim2.new(buttonWidth * (i-1), 2, 0, 4)
            button.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
            button.Text = name
            button.TextColor3 = Color3.fromRGB(255, 255, 255)
            button.Font = Enum.Font.GothamSemibold
            button.TextSize = 14
            button.Parent = TabContainer
            button.ZIndex = 1000

            local UICorner = Instance.new("UICorner")
            UICorner.CornerRadius = UDim.new(0, 6)
            UICorner.Parent = button

            button.MouseButton1Click:Connect(function()
                for _, page in pairs(Pages) do
                    page.Visible = page == Pages[name]
                end
            end)
        end

        -- Initialize ESP and Aimbot features
        self:InitializeESP()
        self:InitializeAimbot()

        -- Return menu instance
        return {
            ScreenGui = ScreenGui,
            MainFrame = MainFrame,
            Pages = Pages
        }
    end

    return SyferLib
