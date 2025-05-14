-- Configuration Module
-- Contains all settings and defaults

local HttpService = game:GetService("HttpService")

local Config = {
    Version = "2.0.0",
    
    Aimbot = {
        Enabled = false,
        TargetPart = "Head", -- Head, Torso, HumanoidRootPart, Random
        TargetPriority = "Distance", -- Distance, Health, Level
        TeamCheck = true,
        VisibilityCheck = true,
        WallCheck = true,
        AliveCheck = true,
        Sensitivity = 0.5, -- 0 to 1
        MaxDistance = 1000,
        TriggerKey = Enum.KeyCode.E,
        LockMode = "Hold", -- "Hold" or "Toggle"
        Smoothness = 0.5, -- 0 to 1, higher = smoother
        FOV = 150, -- Field of View for targeting
        ShowFOV = true,
        FOVColor = Color3.fromRGB(255, 255, 255),
        FOVTransparency = 0.7,
        FOVSides = 60,
        Prediction = {
            Enabled = true,
            Strength = 0.5 -- 0 to 1
        },
        AutoFire = false,
        AutoReload = false,
        SilentAim = false,
        HitChance = 100, -- 1 to 100
        HitParts = {
            Head = true,
            Torso = true,
            Arms = false,
            Legs = false
        }
    },
    
    ESP = {
        Enabled = false,
        TeamCheck = true,
        TeamColor = true,
        AliveCheck = true,
        
        -- Box ESP
        BoxEnabled = true,
        BoxColor = Color3.fromRGB(255, 0, 0),
        BoxTransparency = 0.5,
        BoxOutline = true,
        BoxOutlineColor = Color3.fromRGB(0, 0, 0),
        BoxOutlineTransparency = 0.5,
        BoxFill = false,
        BoxFillColor = Color3.fromRGB(255, 0, 0),
        BoxFillTransparency = 0.1,
        
        -- Name ESP
        NameEnabled = true,
        NameColor = Color3.fromRGB(255, 255, 255),
        NameOutline = true,
        NameOutlineColor = Color3.fromRGB(0, 0, 0),
        NameFont = 2, -- 1-3
        NameSize = 14,
        
        -- Health ESP
        HealthEnabled = true,
        HealthColor = Color3.fromRGB(0, 255, 0),
        HealthOutline = true,
        HealthOutlineColor = Color3.fromRGB(0, 0, 0),
        HealthBarEnabled = true,
        HealthBarSide = "Left", -- Left, Right, Top, Bottom
        HealthTextEnabled = true,
        
        -- Distance ESP
        DistanceEnabled = true,
        DistanceColor = Color3.fromRGB(255, 255, 255),
        DistanceOutline = true,
        DistanceOutlineColor = Color3.fromRGB(0, 0, 0),
        DistanceFont = 2,
        DistanceSize = 13,
        
        -- Tracer ESP
        TracerEnabled = false,
        TracerColor = Color3.fromRGB(255, 255, 0),
        TracerTransparency = 0.5,
        TracerOutline = true,
        TracerOutlineColor = Color3.fromRGB(0, 0, 0),
        TracerOutlineTransparency = 0.5,
        TracerOrigin = "Bottom", -- Bottom, Top, Mouse, Center
        TracerThickness = 1,
        
        -- Skeleton ESP
        SkeletonEnabled = false,
        SkeletonColor = Color3.fromRGB(255, 255, 255),
        SkeletonTransparency = 0.5,
        
        -- Chams
        ChamsEnabled = false,
        ChamsColor = Color3.fromRGB(255, 0, 0),
        ChamsTransparency = 0.5,
        ChamsOutlineColor = Color3.fromRGB(0, 0, 0),
        ChamsOutlineTransparency = 0,
        
        -- Advanced settings
        RefreshRate = 10, -- Lower = more frequent updates but potentially more lag
        MaxDistance = 1000,
        FadeWithDistance = true,
    },
    
    UI = {
        Enabled = true,
        MenuKey = Enum.KeyCode.RightShift,
        Draggable = true,
        Theme = {
            Background = Color3.fromRGB(25, 25, 25),
            Accent = Color3.fromRGB(0, 120, 215),
            Accent2 = Color3.fromRGB(0, 180, 255),
            Text = Color3.fromRGB(255, 255, 255),
            DarkElement = Color3.fromRGB(40, 40, 40),
            LightElement = Color3.fromRGB(60, 60, 60),
            Error = Color3.fromRGB(255, 64, 64),
            Success = Color3.fromRGB(64, 255, 64),
            Warning = Color3.fromRGB(255, 200, 64)
        },
        Animation = {
            Speed = 0.2,
            Enabled = true
        },
        Blur = {
            Enabled = false,
            Strength = 10
        },
        Transparency = 0.9,
        SavedProfiles = {}
    },
    
    Anti = {
        AntiKick = false,
        AntiTeleport = false,
        AntiReport = false,
        AntiMessageLog = false,
        AntiRagdoll = false,
        AntiAFK = true,
        AntiSpeed = false
    },
    
    Performance = {
        OptimizeFrameRate = true,
        ReduceRenderDistance = false,
        RenderDistance = 1000,
        ReduceParticles = false,
        DisableShadows = false,
        DisableBlur = true,
        LowQualityESP = false
    }
}

-- Functions for saving and loading configurations
local ConfigSystem = {}

function ConfigSystem.GenerateGUID()
    return HttpService:GenerateGUID(false)
end

function ConfigSystem.SaveConfig(name)
    if not name or name == "" then
        name = "Config-" .. os.date("%Y%m%d-%H%M%S")
    end
    
    local configData = {
        Name = name,
        Date = os.date("%Y-%m-%d %H:%M:%S"),
        Version = Config.Version,
        Settings = {
            Aimbot = table.clone(Config.Aimbot),
            ESP = table.clone(Config.ESP),
            UI = table.clone(Config.UI),
            Anti = table.clone(Config.Anti),
            Performance = table.clone(Config.Performance)
        }
    }
    
    -- Add to saved profiles
    local profile = {
        Name = name,
        Date = configData.Date,
        Data = configData
    }
    
    Config.UI.SavedProfiles[name] = profile
    
    -- Try to save to file if possible
    pcall(function()
        if writefile then
            local json = HttpService:JSONEncode(configData)
            writefile("AimbotESP_" .. name .. ".json", json)
        end
    end)
    
    return true
end

function ConfigSystem.LoadConfig(name)
    local profile = Config.UI.SavedProfiles[name]
    
    if profile and profile.Data then
        Config.Aimbot = table.clone(profile.Data.Settings.Aimbot)
        Config.ESP = table.clone(profile.Data.Settings.ESP)
        Config.Anti = table.clone(profile.Data.Settings.Anti)
        Config.Performance = table.clone(profile.Data.Settings.Performance)
        
        -- Don't override UI.Enabled or MenuKey
        local enabled = Config.UI.Enabled
        local menuKey = Config.UI.MenuKey
        Config.UI = table.clone(profile.Data.Settings.UI)
        Config.UI.Enabled = enabled
        Config.UI.MenuKey = menuKey
        
        return true
    end
    
    -- Try to load from file if possible
    local success, result = pcall(function()
        if readfile then
            local content = readfile("AimbotESP_" .. name .. ".json")
            return HttpService:JSONDecode(content)
        end
    end)
    
    if success and result then
        Config.Aimbot = table.clone(result.Settings.Aimbot)
        Config.ESP = table.clone(result.Settings.ESP)
        Config.Anti = table.clone(result.Settings.Anti)
        Config.Performance = table.clone(result.Settings.Performance)
        
        -- Don't override UI.Enabled or MenuKey
        local enabled = Config.UI.Enabled
        local menuKey = Config.UI.MenuKey
        Config.UI = table.clone(result.Settings.UI)
        Config.UI.Enabled = enabled
        Config.UI.MenuKey = menuKey
        
        return true
    end
    
    return false
end

-- Add config system to main Config table
Config.System = ConfigSystem

return Config