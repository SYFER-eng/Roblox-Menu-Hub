-- GUI Module
-- Creates and manages the user interface

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

local GUIModule = {}
local GUI = nil
local Tabs = {}

local Config = nil
local Utilities = nil
local UILibrary = nil
local AimbotModule = nil
local ESPModule = nil

-- Initialize function
function GUIModule.CreateGUI(ConfigModule, UtilitiesModule, UILibraryModule, AimbotModuleObj, ESPModuleObj)
    Config = ConfigModule
    Utilities = UtilitiesModule
    UILibrary = UILibraryModule
    AimbotModule = AimbotModuleObj
    ESPModule = ESPModuleObj
    
    -- Create main window
    GUI = UILibrary.CreateWindow("Advanced Aimbot & ESP", UDim2.new(0, 550, 0, 400))
    
    -- Create tabs
    local AimbotTab = GUIModule.CreateAimbotTab()
    local ESPTab = GUIModule.CreateESPTab()
    local SettingsTab = GUIModule.CreateSettingsTab()
    local PerformanceTab = GUIModule.CreatePerformanceTab()
    local AboutTab = GUIModule.CreateAboutTab()
    
    return GUI
end

-- Create Aimbot Tab
function GUIModule.CreateAimbotTab()
    local Tab = GUIModule.CreateTab("Aimbot", "🎯")
    Tabs.Aimbot = Tab
    
    -- Main settings section
    Tab:AddLabel("Main Settings")
    
    local AimbotEnabled = Tab:AddToggle("Enable Aimbot", Config.Aimbot.Enabled, function(value)
        Config.Aimbot.Enabled = value
        AimbotModule.Toggle(value)
    end)
    
    local TargetPart = Tab:AddDropdown("Target Part", {"Head", "Torso", "HumanoidRootPart", "Random"}, Config.Aimbot.TargetPart, function(value)
        Config.Aimbot.TargetPart = value
        AimbotModule.SetTargetPart(value)
    end)
    
    local TargetPriority = Tab:AddDropdown("Target Priority", {"Distance", "Health", "Level"}, Config.Aimbot.TargetPriority, function(value)
        Config.Aimbot.TargetPriority = value
    end)
    
    local LockMode = Tab:AddDropdown("Lock Mode", {"Hold", "Toggle"}, Config.Aimbot.LockMode, function(value)
        Config.Aimbot.LockMode = value
    end)
    
    Tab:AddLabel("Key: " .. Config.Aimbot.TriggerKey.Name)
    
    -- Checks section
    Tab:AddLabel("Target Checks")
    
    local TeamCheck = Tab:AddToggle("Team Check", Config.Aimbot.TeamCheck, function(value)
        Config.Aimbot.TeamCheck = value
    end)
    
    local VisibilityCheck = Tab:AddToggle("Visibility Check", Config.Aimbot.VisibilityCheck, function(value)
        Config.Aimbot.VisibilityCheck = value
    end)
    
    local WallCheck = Tab:AddToggle("Wall Check", Config.Aimbot.WallCheck, function(value)
        Config.Aimbot.WallCheck = value
    end)
    
    local AliveCheck = Tab:AddToggle("Alive Check", Config.Aimbot.AliveCheck, function(value)
        Config.Aimbot.AliveCheck = value
    end)
    
    -- Advanced settings
    Tab:AddLabel("Advanced Settings")
    
    local Smoothness = Tab:AddSlider("Smoothness", 0, 1, Config.Aimbot.Smoothness, 2, function(value)
        Config.Aimbot.Smoothness = value
    end)
    
    local FOV = Tab:AddSlider("FOV Size", 10, 600, Config.Aimbot.FOV, 0, function(value)
        Config.Aimbot.FOV = value
        AimbotModule.SetFOV(value)
    end)
    
    local ShowFOV = Tab:AddToggle("Show FOV Circle", Config.Aimbot.ShowFOV, function(value)
        Config.Aimbot.ShowFOV = value
    end)
    
    local Prediction = Tab:AddToggle("Use Prediction", Config.Aimbot.Prediction.Enabled, function(value)
        Config.Aimbot.Prediction.Enabled = value
    end)
    
    local PredictionStrength = Tab:AddSlider("Prediction Strength", 0, 1, Config.Aimbot.Prediction.Strength, 2, function(value)
        Config.Aimbot.Prediction.Strength = value
    end)
    
    -- Additional features
    Tab:AddLabel("Additional Features")
    
    local AutoFire = Tab:AddToggle("Auto Fire", Config.Aimbot.AutoFire, function(value)
        Config.Aimbot.AutoFire = value
    end)
    
    local SilentAim = Tab:AddToggle("Silent Aim", Config.Aimbot.SilentAim, function(value)
        Config.Aimbot.SilentAim = value
    end)
    
    local HitChance = Tab:AddSlider("Hit Chance", 1, 100, Config.Aimbot.HitChance, 0, function(value)
        Config.Aimbot.HitChance = value
    end)
    
    return Tab
end

-- Create ESP Tab
function GUIModule.CreateESPTab()
    local Tab = GUIModule.CreateTab("ESP", "👁️")
    Tabs.ESP = Tab
    
    -- Main settings section
    Tab:AddLabel("Main Settings")
    
    local ESPEnabled = Tab:AddToggle("Enable ESP", Config.ESP.Enabled, function(value)
        Config.ESP.Enabled = value
        ESPModule.Toggle(value)
    end)
    
    local TeamCheck = Tab:AddToggle("Team Check", Config.ESP.TeamCheck, function(value)
        Config.ESP.TeamCheck = value
    end)
    
    local TeamColor = Tab:AddToggle("Use Team Colors", Config.ESP.TeamColor, function(value)
        Config.ESP.TeamColor = value
    end)
    
    local MaxDistance = Tab:AddSlider("Max Distance", 100, 2000, Config.ESP.MaxDistance, 0, function(value)
        Config.ESP.MaxDistance = value
    end)
    
    -- Box settings
    Tab:AddLabel("Box ESP")
    
    local BoxEnabled = Tab:AddToggle("Show Boxes", Config.ESP.BoxEnabled, function(value)
        Config.ESP.BoxEnabled = value
    end)
    
    local BoxFill = Tab:AddToggle("Fill Boxes", Config.ESP.BoxFill, function(value)
        Config.ESP.BoxFill = value
    end)
    
    local BoxTransparency = Tab:AddSlider("Box Transparency", 0, 1, Config.ESP.BoxTransparency, 2, function(value)
        Config.ESP.BoxTransparency = value
    end)
    
    -- Name & health settings
    Tab:AddLabel("Info ESP")
    
    local NameEnabled = Tab:AddToggle("Show Names", Config.ESP.NameEnabled, function(value)
        Config.ESP.NameEnabled = value
    end)
    
    local HealthEnabled = Tab:AddToggle("Show Health", Config.ESP.HealthEnabled, function(value)
        Config.ESP.HealthEnabled = value
    end)
    
    local DistanceEnabled = Tab:AddToggle("Show Distance", Config.ESP.DistanceEnabled, function(value)
        Config.ESP.DistanceEnabled = value
    end)
    
    -- Tracer settings
    Tab:AddLabel("Tracer ESP")
    
    local TracerEnabled = Tab:AddToggle("Show Tracers", Config.ESP.TracerEnabled, function(value)
        Config.ESP.TracerEnabled = value
    end)
    
    local TracerOrigin = Tab:AddDropdown("Tracer Origin", {"Bottom", "Top", "Mouse", "Center"}, Config.ESP.TracerOrigin, function(value)
        Config.ESP.TracerOrigin = value
    end)
    
    -- Advanced settings
    Tab:AddLabel("Advanced ESP")
    
    local SkeletonEnabled = Tab:AddToggle("Show Skeleton", Config.ESP.SkeletonEnabled, function(value)
        Config.ESP.SkeletonEnabled = value
        if value then
            -- Reinitialize ESP to create skeleton objects
            ESPModule.InitializeESP()
        end
    end)
    
    local FadeWithDistance = Tab:AddToggle("Fade With Distance", Config.ESP.FadeWithDistance, function(value)
        Config.ESP.FadeWithDistance = value
    end)
    
    local RefreshRate = Tab:AddSlider("Refresh Rate", 1, 30, Config.ESP.RefreshRate, 0, function(value)
        Config.ESP.RefreshRate = value
    end)
    
    return Tab
end

-- Create Settings Tab
function GUIModule.CreateSettingsTab()
    local Tab = GUIModule.CreateTab("Settings", "⚙️")
    Tabs.Settings = Tab
    
    -- Theme settings
    Tab:AddLabel("Theme Settings")
    
    local Transparency = Tab:AddSlider("GUI Transparency", 0, 1, Config.UI.Transparency, 2, function(value)
        Config.UI.Transparency = value
        if GUI and GUI.MainWindow then
            GUI.MainWindow.BackgroundTransparency = 1 - value
        end
    end)
    
    local AnimationSpeed = Tab:AddSlider("Animation Speed", 0.1, 1, Config.UI.Animation.Speed, 2, function(value)
        Config.UI.Animation.Speed = value
    end)
    
    local AnimationEnabled = Tab:AddToggle("Enable Animations", Config.UI.Animation.Enabled, function(value)
        Config.UI.Animation.Enabled = value
    end)
    
    local BlurEnabled = Tab:AddToggle("Background Blur", Config.UI.Blur.Enabled, function(value)
        Config.UI.Blur.Enabled = value
        -- Implement blur
        pcall(function()
            if game:GetService("Lighting"):FindFirstChild("AimbotESPBlur") then
                game:GetService("Lighting"):FindFirstChild("AimbotESPBlur").Enabled = value
            else
                if value then
                    local blur = Instance.new("BlurEffect")
                    blur.Name = "AimbotESPBlur"
                    blur.Size = Config.UI.Blur.Strength
                    blur.Parent = game:GetService("Lighting")
                end
            end
        end)
    end)
    
    -- Anti settings
    Tab:AddLabel("Protection Settings")
    
    local AntiAFK = Tab:AddToggle("Anti-AFK", Config.Anti.AntiAFK, function(value)
        Config.Anti.AntiAFK = value
    end)
    
    local AntiKick = Tab:AddToggle("Anti-Kick", Config.Anti.AntiKick, function(value)
        Config.Anti.AntiKick = value
        if value then
            -- Basic anti-kick implementation
            pcall(function()
                local oldKick; oldKick = hookmetamethod(game, "__namecall", function(self, ...)
                    local method = getnamecallmethod()
                    if method == "Kick" and Config.Anti.AntiKick then
                        return nil
                    end
                    return oldKick(self, ...)
                end)
            end)
        end
    end)
    
    -- Config profiles
    Tab:AddLabel("Configuration Profiles")
    
    -- Get list of saved profiles
    local profileNames = {}
    for name, _ in pairs(Config.UI.SavedProfiles) do
        table.insert(profileNames, name)
    end
    if #profileNames == 0 then
        table.insert(profileNames, "Default")
    end
    
    -- Create profile dropdown
    local ProfileDropdown = Tab:AddDropdown("Select Profile", profileNames, profileNames[1], function(value)
        -- Do nothing on selection, loading is done via button
    end)
    
    -- Buttons for profile management
    local SaveButton = Tab:AddButton("Save Current Settings", function()
        local profileName = ProfileDropdown.Get()
        if Config.System.SaveConfig(profileName) then
            UILibrary.ShowNotification("Profile Saved", "Settings saved as '" .. profileName .. "'", 3)
            
            -- Update profile list
            local newProfileNames = {}
            for name, _ in pairs(Config.UI.SavedProfiles) do
                table.insert(newProfileNames, name)
            end
            
            -- Recreate the dropdown
            -- This would require a refresh mechanism
            -- For now, show notification to restart GUI
            UILibrary.ShowNotification("Restart Required", "Please reopen the GUI to see new profiles", 3)
        else
            UILibrary.ShowNotification("Error", "Failed to save profile", 3)
        end
    end)
    
    local LoadButton = Tab:AddButton("Load Selected Profile", function()
        local profileName = ProfileDropdown.Get()
        if Config.System.LoadConfig(profileName) then
            UILibrary.ShowNotification("Profile Loaded", "Settings loaded from '" .. profileName .. "'", 3)
            
            -- Update all UI elements to reflect loaded settings
            -- This would require a refresh mechanism
            -- For now, show notification to restart GUI
            UILibrary.ShowNotification("Restart Required", "Please reopen the GUI to apply loaded settings", 3)
        else
            UILibrary.ShowNotification("Error", "Failed to load profile", 3)
        end
    end)
    
    -- Reset all settings
    Tab:AddButton("Reset All Settings", function()
        -- Reset to default values
        Config.Aimbot.Enabled = false
        Config.Aimbot.TargetPart = "Head"
        Config.Aimbot.TeamCheck = true
        Config.Aimbot.VisibilityCheck = true
        Config.Aimbot.WallCheck = true
        Config.Aimbot.Smoothness = 0.5
        Config.Aimbot.FOV = 150
        Config.Aimbot.MaxDistance = 1000
        Config.Aimbot.Prediction.Enabled = true
        Config.Aimbot.Prediction.Strength = 0.5
        Config.Aimbot.ShowFOV = true
        
        Config.ESP.Enabled = false
        Config.ESP.TeamCheck = true
        Config.ESP.BoxEnabled = true
        Config.ESP.NameEnabled = true
        Config.ESP.HealthEnabled = true
        Config.ESP.DistanceEnabled = true
        Config.ESP.TracerEnabled = false
        Config.ESP.SkeletonEnabled = false
        Config.ESP.MaxDistance = 1000
        
        Config.Anti.AntiAFK = true
        Config.Anti.AntiKick = false
        
        -- Update UI elements
        UILibrary.ShowNotification("Settings Reset", "All settings have been reset to defaults", 3)
        UILibrary.ShowNotification("Restart Required", "Please reopen the GUI to apply reset settings", 3)
    end)
    
    return Tab
end

-- Create Performance Tab
function GUIModule.CreatePerformanceTab()
    local Tab = GUIModule.CreateTab("Performance", "⚡")
    Tabs.Performance = Tab
    
    -- Performance optimization settings
    Tab:AddLabel("Optimization Settings")
    
    local OptimizeFrameRate = Tab:AddToggle("Optimize Frame Rate", Config.Performance.OptimizeFrameRate, function(value)
        Config.Performance.OptimizeFrameRate = value
        if value then
            -- Implementation would depend on the game
            pcall(function()
                setfpscap(60)
            end)
        else
            pcall(function()
                setfpscap(0)
            end)
        end
    end)
    
    local ReduceParticles = Tab:AddToggle("Reduce Particles", Config.Performance.ReduceParticles, function(value)
        Config.Performance.ReduceParticles = value
        if value then
            pcall(function()
                for _, particle in pairs(game:GetDescendants()) do
                    if particle:IsA("ParticleEmitter") or
                       particle:IsA("Smoke") or
                       particle:IsA("Fire") or
                       particle:IsA("Sparkles") then
                        particle.Enabled = false
                    end
                end
            end)
        else
            UILibrary.ShowNotification("Info", "Restart the game to restore particles", 3)
        end
    end)
    
    local DisableShadows = Tab:AddToggle("Disable Shadows", Config.Performance.DisableShadows, function(value)
        Config.Performance.DisableShadows = value
        pcall(function()
            game:GetService("Lighting").GlobalShadows = not value
        end)
    end)
    
    local DisableBlur = Tab:AddToggle("Disable Blur Effects", Config.Performance.DisableBlur, function(value)
        Config.Performance.DisableBlur = value
        pcall(function()
            for _, item in pairs(game:GetService("Lighting"):GetChildren()) do
                if item:IsA("BlurEffect") or 
                   item:IsA("BloomEffect") or 
                   item:IsA("SunRaysEffect") then
                    item.Enabled = not value
                end
            end
        end)
    end)
    
    local LowQualityESP = Tab:AddToggle("Low Quality ESP", Config.Performance.LowQualityESP, function(value)
        Config.Performance.LowQualityESP = value
        if value then
            Config.ESP.BoxOutline = false
            Config.ESP.NameOutline = false
            Config.ESP.SkeletonEnabled = false
            Config.ESP.RefreshRate = 5
        else
            Config.ESP.BoxOutline = true
            Config.ESP.NameOutline = true
            Config.ESP.RefreshRate = 10
        end
    end)
    
    -- Render distance
    Tab:AddLabel("Render Settings")
    
    local ReduceRenderDistance = Tab:AddToggle("Reduce Render Distance", Config.Performance.ReduceRenderDistance, function(value)
        Config.Performance.ReduceRenderDistance = value
        if value then
            pcall(function()
                settings().Rendering.QualityLevel = 1
            end)
        else
            pcall(function()
                settings().Rendering.QualityLevel = 10
            end)
        end
    end)
    
    local RenderDistance = Tab:AddSlider("Render Distance", 100, 2000, Config.Performance.RenderDistance, 0, function(value)
        Config.Performance.RenderDistance = value
        pcall(function()
            workspace.FarClip = value
        end)
    end)
    
    -- Performance status
    Tab:AddLabel("Performance Status")
    
    -- FPS counter
    local fps = 0
    local frames = 0
    local lastUpdate = os.clock()
    
    local FPSLabel = Tab:AddLabel("FPS: Calculating...")
    
    local PingLabel = Tab:AddLabel("Ping: Calculating...")
    
    -- Update FPS and Ping periodically
    RunService.RenderStepped:Connect(function()
        frames = frames + 1
        
        local now = os.clock()
        if now - lastUpdate >= 1 then
            fps = frames
            frames = 0
            lastUpdate = now
            
            -- Update FPS counter
            FPSLabel.Set("FPS: " .. fps)
            
            -- Update ping
            local ping = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
            PingLabel.Set("Ping: " .. ping .. "ms")
        end
    end)
    
    return Tab
end

-- Create About Tab
function GUIModule.CreateAboutTab()
    local Tab = GUIModule.CreateTab("About", "ℹ️")
    Tabs.About = Tab
    
    Tab:AddLabel("Advanced Aimbot & ESP Menu")
    Tab:AddLabel("Version: " .. Config.Version)
    Tab:AddLabel("")
    
    Tab:AddLabel("Features:")
    Tab:AddLabel("• Aimbot with customizable settings")
    Tab:AddLabel("• ESP with multiple visualization options")
    Tab:AddLabel("• Target prioritization system")
    Tab:AddLabel("• FOV circle for visual targeting")
    Tab:AddLabel("• Performance optimization options")
    Tab:AddLabel("• Profile saving and loading")
    Tab:AddLabel("• Anti-detection features")
    
    Tab:AddLabel("")
    Tab:AddLabel("Disclaimer:")
    Tab:AddLabel("This script is for educational purposes only.")
    Tab:AddLabel("Using scripts like this in Roblox games may")
    Tab:AddLabel("violate Roblox's Terms of Service.")
    Tab:AddLabel("Use at your own risk.")
    
    Tab:AddButton("Join Discord", function()
        -- Placeholder function - would normally send to a Discord server
        UILibrary.ShowNotification("Discord", "Feature not available in this version", 3)
    end)
    
    return Tab
end

-- Create a new tab
function GUIModule.CreateTab(name, icon)
    if not GUI then return nil end
    
    icon = icon or ""
    local TabInterface = {}
    
    -- Tab button
    local TabButton = UILibrary.Create("TextButton", {
        Name = name .. "Tab",
        Parent = GUI.TabButtonsContainer,
        BackgroundColor3 = Config.UI.Theme.DarkElement,
        BorderSizePixel = 0,
        Size = UDim2.new(1, -10, 0, 40),
        Position = UDim2.new(0, 5, 0, 0),
        Font = Enum.Font.SourceSansBold,
        Text = icon .. " " .. name,
        TextColor3 = Config.UI.Theme.Text,
        TextSize = 16,
        LayoutOrder = #Tabs + 1
    })
    
    UILibrary.Create("UICorner", {
        Parent = TabButton,
        CornerRadius = UDim.new(0, 6)
    })
    
    -- Content page for this tab
    local ContentPage = UILibrary.Create("ScrollingFrame", {
        Name = name .. "Page",
        Parent = GUI.ContentFrame,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 4,
        ScrollingEnabled = true,
        ScrollBarImageColor3 = Config.UI.Theme.LightElement,
        Visible = #Tabs == 0 -- First tab is visible by default
    })
    
    -- Add padding
    UILibrary.Create("UIPadding", {
        Parent = ContentPage,
        PaddingLeft = UDim.new(0, 15),
        PaddingRight = UDim.new(0, 15),
        PaddingTop = UDim.new(0, 15),
        PaddingBottom = UDim.new(0, 15)
    })
    
    -- Element layout
    local ElementLayout = UILibrary.Create("UIListLayout", {
        Parent = ContentPage,
        Padding = UDim.new(0, 10),
        SortOrder = Enum.SortOrder.LayoutOrder
    })
    
    -- Update canvas size when elements are added
    ElementLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        ContentPage.CanvasSize = UDim2.new(0, 0, 0, ElementLayout.AbsoluteContentSize.Y + 20)
    end)
    
    -- Tab structure
    local Tab = {
        Name = name,
        Button = TabButton,
        Container = ContentPage,
        Elements = {}
    }
    
    -- Tab button click handler
    TabButton.MouseButton1Click:Connect(function()
        -- Deselect all tabs
        for _, t in pairs(Tabs) do
            UILibrary.Tween(t.Button, {BackgroundColor3 = Config.UI.Theme.DarkElement})
            t.Container.Visible = false
        end
        
        -- Select this tab
        UILibrary.Tween(TabButton, {BackgroundColor3 = Config.UI.Theme.Accent})
        ContentPage.Visible = true
    end)
    
    -- If this is the first tab, select it
    if #Tabs == 0 then
        UILibrary.Tween(TabButton, {BackgroundColor3 = Config.UI.Theme.Accent})
    end
    
    -- Add label element
    function TabInterface:AddLabel(text)
        local LabelElement = UILibrary.Create("TextLabel", {
            Name = "Label" .. #Tab.Elements,
            Parent = ContentPage,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -20, 0, 20),
            Font = Enum.Font.SourceSansBold,
            Text = text,
            TextColor3 = Config.UI.Theme.Text,
            TextSize = 16,
            TextXAlignment = Enum.TextXAlignment.Left,
            LayoutOrder = #Tab.Elements
        })
        
        table.insert(Tab.Elements, LabelElement)
        
        return {
            Set = function(newText)
                LabelElement.Text = newText
            end
        }
    end
    
    -- Add toggle element
    function TabInterface:AddToggle(text, default, callback)
        local ToggleFrame = UILibrary.Create("Frame", {
            Name = "Toggle" .. #Tab.Elements,
            Parent = ContentPage,
            BackgroundColor3 = Config.UI.Theme.LightElement,
            Size = UDim2.new(1, -20, 0, 40),
            LayoutOrder = #Tab.Elements
        })
        
        UILibrary.Create("UICorner", {
            Parent = ToggleFrame,
            CornerRadius = UDim.new(0, 6)
        })
        
        local Label = UILibrary.Create("TextLabel", {
            Name = "Label",
            Parent = ToggleFrame,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 10, 0, 0),
            Size = UDim2.new(1, -70, 1, 0),
            Font = Enum.Font.SourceSans,
            Text = text,
            TextColor3 = Config.UI.Theme.Text,
            TextSize = 16,
            TextXAlignment = Enum.TextXAlignment.Left
        })
        
        local ToggleButton = UILibrary.Create("Frame", {
            Name = "ToggleButton",
            Parent = ToggleFrame,
            BackgroundColor3 = default and Config.UI.Theme.Accent or Config.UI.Theme.DarkElement,
            Position = UDim2.new(1, -60, 0.5, -10),
            Size = UDim2.new(0, 50, 0, 24)
        })
        
        UILibrary.Create("UICorner", {
            Parent = ToggleButton,
            CornerRadius = UDim.new(1, 0)
        })
        
        local ToggleCircle = UILibrary.Create("Frame", {
            Name = "Circle",
            Parent = ToggleButton,
            BackgroundColor3 = Config.UI.Theme.Text,
            Position = default and UDim2.new(1, -22, 0.5, -9) or UDim2.new(0, 2, 0.5, -9),
            Size = UDim2.new(0, 18, 0, 18)
        })
        
        UILibrary.Create("UICorner", {
            Parent = ToggleCircle,
            CornerRadius = UDim.new(1, 0)
        })
        
        -- State and interaction
        local toggled = default
        
        local function UpdateToggle()
            toggled = not toggled
            UILibrary.Tween(ToggleButton, {BackgroundColor3 = toggled and Config.UI.Theme.Accent or Config.UI.Theme.DarkElement})
            UILibrary.Tween(ToggleCircle, {Position = toggled and UDim2.new(1, -22, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)})
            callback(toggled)
        end
        
        ToggleFrame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                UpdateToggle()
            end
        end)
        
        table.insert(Tab.Elements, ToggleFrame)
        
        return {
            Set = function(value)
                if toggled ~= value then
                    UpdateToggle()
                end
            end,
            Get = function()
                return toggled
            end
        }
    end
    
    -- Add slider element
    function TabInterface:AddSlider(text, min, max, default, decimals, callback)
        decimals = decimals or 1
        
        local SliderFrame = UILibrary.Create("Frame", {
            Name = "Slider" .. #Tab.Elements,
            Parent = ContentPage,
            BackgroundColor3 = Config.UI.Theme.LightElement,
            Size = UDim2.new(1, -20, 0, 60),
            LayoutOrder = #Tab.Elements
        })
        
        UILibrary.Create("UICorner", {
            Parent = SliderFrame,
            CornerRadius = UDim.new(0, 6)
        })
        
        local Label = UILibrary.Create("TextLabel", {
            Name = "Label",
            Parent = SliderFrame,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 10, 0, 5),
            Size = UDim2.new(0.5, 0, 0, 20),
            Font = Enum.Font.SourceSans,
            Text = text,
            TextColor3 = Config.UI.Theme.Text,
            TextSize = 16,
            TextXAlignment = Enum.TextXAlignment.Left
        })
        
        local ValueLabel = UILibrary.Create("TextLabel", {
            Name = "Value",
            Parent = SliderFrame,
            BackgroundTransparency = 1,
            Position = UDim2.new(1, -60, 0, 5),
            Size = UDim2.new(0, 50, 0, 20),
            Font = Enum.Font.SourceSans,
            Text = tostring(Utilities.Round(default, decimals)),
            TextColor3 = Config.UI.Theme.Text,
            TextSize = 16,
            TextXAlignment = Enum.TextXAlignment.Right
        })
        
        local SliderBG = UILibrary.Create("Frame", {
            Name = "SliderBG",
            Parent = SliderFrame,
            BackgroundColor3 = Config.UI.Theme.DarkElement,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 10, 0, 35),
            Size = UDim2.new(1, -20, 0, 8)
        })
        
        UILibrary.Create("UICorner", {
            Parent = SliderBG,
            CornerRadius = UDim.new(1, 0)
        })
        
        local SliderFill = UILibrary.Create("Frame", {
            Name = "Fill",
            Parent = SliderBG,
            BackgroundColor3 = Config.UI.Theme.Accent,
            BorderSizePixel = 0,
            Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
        })
        
        UILibrary.Create("UICorner", {
            Parent = SliderFill,
            CornerRadius = UDim.new(1, 0)
        })
        
        local SliderButton = UILibrary.Create("TextButton", {
            Name = "SliderButton",
            Parent = SliderBG,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Text = ""
        })
        
        -- Slider handle
        local SliderHandle = UILibrary.Create("Frame", {
            Name = "Handle",
            Parent = SliderFill,
            AnchorPoint = Vector2.new(1, 0.5),
            BackgroundColor3 = Config.UI.Theme.Text,
            Position = UDim2.new(1, 0, 0.5, 0),
            Size = UDim2.new(0, 16, 0, 16)
        })
        
        UILibrary.Create("UICorner", {
            Parent = SliderHandle,
            CornerRadius = UDim.new(1, 0)
        })
        
        -- Slider interactions
        local value = default
        
        local function UpdateSlider(input)
            local sizeX = math.clamp((input.Position.X - SliderBG.AbsolutePosition.X) / SliderBG.AbsoluteSize.X, 0, 1)
            UILibrary.Tween(SliderFill, {Size = UDim2.new(sizeX, 0, 1, 0)}, 0.1)
            
            local newValue = Utilities.Round(min + (max - min) * sizeX, decimals)
            value = newValue
            ValueLabel.Text = tostring(newValue)
            callback(newValue)
        end
        
        SliderButton.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                UpdateSlider(input)
                
                local connection
                connection = RunService.RenderStepped:Connect(function()
                    if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                        UpdateSlider({Position = Vector3.new(UserInputService:GetMouseLocation().X, 0, 0)})
                    else
                        connection:Disconnect()
                    end
                end)
            end
        end)
        
        table.insert(Tab.Elements, SliderFrame)
        
        return {
            Set = function(newValue)
                value = math.clamp(Utilities.Round(newValue, decimals), min, max)
                local sizeX = (value - min) / (max - min)
                UILibrary.Tween(SliderFill, {Size = UDim2.new(sizeX, 0, 1, 0)}, 0.1)
                ValueLabel.Text = tostring(value)
                callback(value)
            end,
            Get = function()
                return value
            end
        }
    end
    
    -- Add dropdown element
    function TabInterface:AddDropdown(text, options, default, callback)
        local DropdownFrame = UILibrary.Create("Frame", {
            Name = "Dropdown" .. #Tab.Elements,
            Parent = ContentPage,
            BackgroundColor3 = Config.UI.Theme.LightElement,
            Size = UDim2.new(1, -20, 0, 40),
            ClipsDescendants = true,
            LayoutOrder = #Tab.Elements
        })
        
        UILibrary.Create("UICorner", {
            Parent = DropdownFrame,
            CornerRadius = UDim.new(0, 6)
        })
        
        local Label = UILibrary.Create("TextLabel", {
            Name = "Label",
            Parent = DropdownFrame,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 10, 0, 0),
            Size = UDim2.new(0.5, -10, 0, 40),
            Font = Enum.Font.SourceSans,
            Text = text,
            TextColor3 = Config.UI.Theme.Text,
            TextSize = 16,
            TextXAlignment = Enum.TextXAlignment.Left
        })
        
        local SelectedValue = UILibrary.Create("TextLabel", {
            Name = "Selected",
            Parent = DropdownFrame,
            BackgroundTransparency = 1,
            Position = UDim2.new(0.5, 0, 0, 0),
            Size = UDim2.new(0.4, 0, 0, 40),
            Font = Enum.Font.SourceSans,
            Text = default,
            TextColor3 = Config.UI.Theme.Text,
            TextSize = 16,
            TextXAlignment = Enum.TextXAlignment.Right
        })
        
        local DropdownArrow = UILibrary.Create("TextLabel", {
            Name = "Arrow",
            Parent = DropdownFrame,
            BackgroundTransparency = 1,
            Position = UDim2.new(1, -35, 0, 0),
            Size = UDim2.new(0, 25, 0, 40),
            Font = Enum.Font.SourceSansBold,
            Text = "▼",
            TextColor3 = Config.UI.Theme.Text,
            TextSize = 16
        })
        
        local OptionsContainer = UILibrary.Create("Frame", {
            Name = "Options",
            Parent = DropdownFrame,
            BackgroundColor3 = Config.UI.Theme.DarkElement,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 0, 0, 40),
            Size = UDim2.new(1, 0, 0, #options * 30),
            Visible = false
        })
        
        UILibrary.Create("UICorner", {
            Parent = OptionsContainer,
            CornerRadius = UDim.new(0, 6)
        })
        
        local optionButtons = {}
        for i, option in ipairs(options) do
            local OptionButton = UILibrary.Create("TextButton", {
                Name = option,
                Parent = OptionsContainer,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0, (i-1) * 30),
                Size = UDim2.new(1, 0, 0, 30),
                Font = Enum.Font.SourceSans,
                Text = option,
                TextColor3 = Config.UI.Theme.Text,
                TextSize = 16
            })
            
            OptionButton.MouseButton1Click:Connect(function()
                SelectedValue.Text = option
                callback(option)
                
                -- Animate dropdown closing
                UILibrary.Tween(DropdownFrame, {Size = UDim2.new(1, -20, 0, 40)}, 0.3)
                OptionsContainer.Visible = false
                DropdownArrow.Text = "▼"
            end)
            
            table.insert(optionButtons, OptionButton)
        end
        
        -- Toggle dropdown
        local isOpen = false
        DropdownFrame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                isOpen = not isOpen
                
                if isOpen then
                    -- Animate dropdown opening
                    OptionsContainer.Visible = true
                    UILibrary.Tween(DropdownFrame, {Size = UDim2.new(1, -20, 0, 40 + #options * 30)}, 0.3)
                    DropdownArrow.Text = "▲"
                else
                    -- Animate dropdown closing
                    UILibrary.Tween(DropdownFrame, {Size = UDim2.new(1, -20, 0, 40)}, 0.3)
                    OptionsContainer.Visible = false
                    DropdownArrow.Text = "▼"
                end
            end
        end)
        
        table.insert(Tab.Elements, DropdownFrame)
        
        return {
            Set = function(option)
                if table.find(options, option) then
                    SelectedValue.Text = option
                    callback(option)
                end
            end,
            Get = function()
                return SelectedValue.Text
            end
        }
    end
    
    -- Add button element
    function TabInterface:AddButton(text, callback)
        local ButtonElement = UILibrary.Create("TextButton", {
            Name = "Button" .. #Tab.Elements,
            Parent = ContentPage,
            BackgroundColor3 = Config.UI.Theme.LightElement,
            Size = UDim2.new(1, -20, 0, 40),
            Font = Enum.Font.SourceSansBold,
            Text = text,
            TextColor3 = Config.UI.Theme.Text,
            TextSize = 16,
            LayoutOrder = #Tab.Elements
        })
        
        UILibrary.Create("UICorner", {
            Parent = ButtonElement,
            CornerRadius = UDim.new(0, 6)
        })
        
        -- Button interactions
        ButtonElement.MouseButton1Click:Connect(callback)
        
        ButtonElement.MouseEnter:Connect(function()
            UILibrary.Tween(ButtonElement, {BackgroundColor3 = Config.UI.Theme.Accent}, 0.2)
        end)
        
        ButtonElement.MouseLeave:Connect(function()
            UILibrary.Tween(ButtonElement, {BackgroundColor3 = Config.UI.Theme.LightElement}, 0.2)
        end)
        
        table.insert(Tab.Elements, ButtonElement)
        
        return ButtonElement
    end
    
    Tabs[name] = Tab
    return TabInterface
end

-- Toggle GUI visibility
function GUIModule.ToggleGUI(state)
    if state and GUI and GUI.GUI then
        GUI.GUI.Enabled = true
    elseif GUI and GUI.GUI then
        GUI.GUI.Enabled = false
    end
end

-- Clean up function
function GUIModule.Cleanup()
    if GUI and GUI.GUI then
        GUI.GUI:Destroy()
    end
    
    GUI = nil
    Tabs = {}
end

return GUIModule