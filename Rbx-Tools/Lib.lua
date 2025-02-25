-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

-- Initialize SyferLib
local SyferLib = {}

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

-- UI Creation Functions
function SyferLib:CreateButton(parent, text, callback)
    local Button = Instance.new("TextButton")
    Button.Name = text
    Button.Size = UDim2.new(0.9, 0, 0, 40)
    Button.Position = UDim2.new(0.05, 0, 0, 0)
    Button.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    Button.Text = text
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.Font = Enum.Font.GothamSemibold
    Button.TextSize = 14
    Button.Parent = parent
    Button.ZIndex = 1000000

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 6)
    UICorner.Parent = Button

    Button.MouseButton1Click:Connect(callback)
    return Button
end

function SyferLib:CreateToggle(parent, text, callback)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Name = text .. "Toggle"
    ToggleFrame.Size = UDim2.new(0.9, 0, 0, 40)
    ToggleFrame.Position = UDim2.new(0.05, 0, 0, 0)
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    ToggleFrame.Parent = parent
    ToggleFrame.ZIndex = 1000000

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 6)
    UICorner.Parent = ToggleFrame

    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Size = UDim2.new(1, 0, 1, 0)
    ToggleButton.BackgroundTransparency = 1
    ToggleButton.Text = text
    ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleButton.Font = Enum.Font.GothamSemibold
    ToggleButton.TextSize = 14
    ToggleButton.Parent = ToggleFrame
    ToggleButton.ZIndex = 1000001

    local ToggleIndicator = Instance.new("Frame")
    ToggleIndicator.Size = UDim2.new(0, 20, 0, 20)
    ToggleIndicator.Position = UDim2.new(0.95, -25, 0.5, -10)
    ToggleIndicator.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    ToggleIndicator.Parent = ToggleFrame
    ToggleIndicator.ZIndex = 1000002

    local UICorner2 = Instance.new("UICorner")
    UICorner2.CornerRadius = UDim.new(0, 4)
    UICorner2.Parent = ToggleIndicator

    local enabled = false
    ToggleButton.MouseButton1Click:Connect(function()
        enabled = not enabled
        ToggleIndicator.BackgroundColor3 = enabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
        callback(enabled)
    end)

    return ToggleFrame
end

function SyferLib:CreateSlider(parent, text, min, max, default, callback)
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Name = text .. "Slider"
    SliderFrame.Size = UDim2.new(0.9, 0, 0, 60)
    SliderFrame.Position = UDim2.new(0.05, 0, 0, 0)
    SliderFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    SliderFrame.Parent = parent
    SliderFrame.ZIndex = 1000000

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 6)
    UICorner.Parent = SliderFrame

    local SliderTitle = Instance.new("TextLabel")
    SliderTitle.Size = UDim2.new(1, 0, 0, 30)
    SliderTitle.BackgroundTransparency = 1
    SliderTitle.Text = text
    SliderTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    SliderTitle.Font = Enum.Font.GothamSemibold
    SliderTitle.TextSize = 14
    SliderTitle.Parent = SliderFrame
    SliderTitle.ZIndex = 1000001

    local SliderBar = Instance.new("Frame")
    SliderBar.Size = UDim2.new(0.9, 0, 0, 4)
    SliderBar.Position = UDim2.new(0.05, 0, 0.7, 0)
    SliderBar.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    SliderBar.Parent = SliderFrame
    SliderBar.ZIndex = 1000001

    local UICorner2 = Instance.new("UICorner")
    UICorner2.CornerRadius = UDim.new(1, 0)
    UICorner2.Parent = SliderBar

    local SliderButton = Instance.new("TextButton")
    SliderButton.Size = UDim2.new(0, 16, 0, 16)
    SliderButton.Position = UDim2.new((default - min)/(max - min), -8, 0.5, -8)
    SliderButton.BackgroundColor3 = Color3.fromRGB(255, 0, 255)
    SliderButton.Text = ""
    SliderButton.Parent = SliderBar
    SliderButton.ZIndex = 1000002

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
    ValueLabel.ZIndex = 1000001

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
        
        pcall(function()
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

        -- Create Title
        local Title = Instance.new("TextLabel")
        Title.Name = "Title"
        Title.Size = UDim2.new(1, 0, 0, 40)
        Title.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
        Title.Text = "•Ｓｙｆｅｒ－ｅｎｇ＇ｓ Ｍｅｎｕ•"
        Title.TextColor3 = Color3.fromRGB(255, 255, 255)
        Title.TextSize = 22
        Title.Font = Enum.Font.GothamBold
        Title.Parent = MainFrame

        local UIGradient = Instance.new("UIGradient")
        UIGradient.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(138, 43, 226))
        }
        UIGradient.Parent = Title

        -- Create Navigation Frame
        local Navigation = Instance.new("Frame")
        Navigation.Name = "Navigation"
        Navigation.Size = UDim2.new(1, 0, 0, 40)
        Navigation.Position = UDim2.new(0, 0, 0, 40)
        Navigation.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
        Navigation.Parent = MainFrame

        return ScreenGui, MainFrame, Navigation
    end

    -- Create Pages
    function SyferLib:CreatePage(name)
        local Page = Instance.new("ScrollingFrame")
        Page.Name = name
        Page.Size = UDim2.new(1, -20, 1, -90)
        Page.Position = UDim2.new(0, 10, 0, 80)
        Page.BackgroundTransparency = 1
        Page.BorderSizePixel = 0
        Page.ScrollBarThickness = 4
        Page.ScrollBarImageColor3 = Color3.fromRGB(255, 0, 255)
        Page.ZIndex = 1000000

        local UIListLayout = Instance.new("UIListLayout")
        UIListLayout.Parent = Page
        UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
        UIListLayout.Padding = UDim.new(0, 5)

        UIListLayout.Changed:Connect(function()
            Page.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 10)
        end)

        return Page
    end

    -- Initialize Menu
    function SyferLib:Initialize()
        local ScreenGui, MainFrame, Navigation = self:CreateMainGUI()
        
        -- Create pages
        local Pages = {
            Main = self:CreatePage("Main"),
            ESP = self:CreatePage("ESP"),
            Aimbot = self:CreatePage("Aimbot"),
            Combat = self:CreatePage("Combat"),
            Visual = self:CreatePage("Visual"),
            Misc = self:CreatePage("Misc"),
            Settings = self:CreatePage("Settings")
        }

        -- Parent pages to MainFrame
        for _, page in pairs(Pages) do
            page.Parent = MainFrame
            page.Visible = false
        end
        Pages.Main.Visible = true

        -- Create navigation buttons
        local PageOrder = {"Main", "ESP", "Aimbot", "Combat", "Visual", "Misc", "Settings"}
        local NavButtons = {}

        for i, pageName in ipairs(PageOrder) do
            local btn = self:CreateButton(Navigation, pageName, function()
                for _, page in pairs(Pages) do
                    page.Visible = false
                end
                Pages[pageName].Visible = true

                for _, button in pairs(NavButtons) do
                    button.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
                end
                NavButtons[pageName].BackgroundColor3 = Color3.fromRGB(255, 0, 255)
            end)
            
            btn.Size = UDim2.new(1/#PageOrder, -4, 1, -4)
            btn.Position = UDim2.new((i-1)/#PageOrder, 2, 0, 2)
            NavButtons[pageName] = btn
        end

        -- Set initial active button
        NavButtons.Main.BackgroundColor3 = Color3.fromRGB(255, 0, 255)

        -- Create Features
        self:CreateMainFeatures(Pages)
        self:InitializeESP()
        self:InitializeAimbot()

        -- Handle menu toggle
        UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if not gameProcessed and input.KeyCode == self.Settings.UI.ToggleKey then
                MainFrame.Visible = not MainFrame.Visible
            end
        end)

        return {
            ScreenGui = ScreenGui,
            MainFrame = MainFrame,
            Pages = Pages,
            NavButtons = NavButtons
        }
    end

    -- Return the library
    return SyferLib
