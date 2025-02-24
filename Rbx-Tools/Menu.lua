-- Load the Syfer Menu Library
local SyferLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/SYFER-eng/Roblox-Menu-Hub/refs/heads/main/Rbx-Tools/Lib.lua",true))()

-- Initialize Menu
local menu = SyferLib:CreateMenu()

-- ESP Tab Implementation
local espPage = menu:FindFirstChild("ESP")
SyferLib:CreateToggle(espPage, "Enable ESP", function(enabled)
    SyferLib.Settings.ESP.Enabled = enabled
end)

SyferLib:CreateToggle(espPage, "Box ESP", function(enabled)
    SyferLib.Settings.ESP.Boxes = enabled
end)

SyferLib:CreateToggle(espPage, "Name ESP", function(enabled)
    SyferLib.Settings.ESP.Names = enabled
end)

SyferLib:CreateToggle(espPage, "Distance ESP", function(enabled)
    SyferLib.Settings.ESP.Distance = enabled
end)

SyferLib:CreateToggle(espPage, "Health ESP", function(enabled)
    SyferLib.Settings.ESP.Health = enabled
end)

SyferLib:CreateToggle(espPage, "Snaplines", function(enabled)
    SyferLib.Settings.ESP.Snaplines = enabled
end)

SyferLib:CreateToggle(espPage, "Team Check", function(enabled)
    SyferLib.Settings.ESP.TeamCheck = enabled
end)

SyferLib:CreateToggle(espPage, "Rainbow Mode", function(enabled)
    SyferLib.Settings.ESP.Rainbow = enabled
end)

-- Aimbot Tab Implementation
local aimbotPage = menu:FindFirstChild("Aimbot")
SyferLib:CreateToggle(aimbotPage, "Enable Aimbot", function(enabled)
    SyferLib.Settings.Aimbot.Enabled = enabled
end)

SyferLib:CreateToggle(aimbotPage, "Show FOV", function(enabled)
    SyferLib.Settings.Aimbot.ShowFOV = enabled
end)

SyferLib:CreateToggle(aimbotPage, "Team Check", function(enabled)
    SyferLib.Settings.Aimbot.TeamCheck = enabled
end)

SyferLib:CreateSlider(aimbotPage, "FOV Size", 10, 800, 100, function(value)
    SyferLib.Settings.Aimbot.FOV = value
end)

SyferLib:CreateSlider(aimbotPage, "Smoothness", 1, 10, 1, function(value)
    SyferLib.Settings.Aimbot.Smoothness = value
end)

SyferLib:CreateDropdown(aimbotPage, "Target Part", {"Head", "HumanoidRootPart", "Torso"}, function(selected)
    SyferLib.Settings.Aimbot.TargetPart = selected
end)

-- Combat Tab Implementation
local combatPage = menu:FindFirstChild("Combat")
SyferLib:CreateToggle(combatPage, "Silent Aim", function(enabled)
    SyferLib.Settings.Combat.SilentAim = enabled
end)

SyferLib:CreateToggle(combatPage, "Trigger Bot", function(enabled)
    SyferLib.Settings.Combat.TriggerBot = enabled
end)

SyferLib:CreateSlider(combatPage, "Hit Chance", 0, 100, 100, function(value)
    SyferLib.Settings.Combat.HitChance = value
end)

SyferLib:CreateSlider(combatPage, "Damage Multiplier", 1, 10, 1, function(value)
    SyferLib.Settings.Combat.DamageMultiplier = value
end)

-- Visual Tab Implementation
local visualPage = menu:FindFirstChild("Visual")
SyferLib:CreateToggle(visualPage, "Full Bright", function(enabled)
    SyferLib.Settings.Visual.FullBright = enabled
end)

SyferLib:CreateToggle(visualPage, "No Fog", function(enabled)
    SyferLib.Settings.Visual.NoFog = enabled
end)

SyferLib:CreateSlider(visualPage, "FOV Changer", 70, 120, 90, function(value)
    SyferLib.Settings.Visual.FOV = value
end)

-- Misc Tab Implementation
local miscPage = menu:FindFirstChild("Misc")
SyferLib:CreateToggle(miscPage, "Speed Hack", function(enabled)
    SyferLib.Settings.Misc.SpeedHack = enabled
end)

SyferLib:CreateToggle(miscPage, "Infinite Jump", function(enabled)
    SyferLib.Settings.Misc.InfiniteJump = enabled
end)

SyferLib:CreateToggle(miscPage, "No Clip", function(enabled)
    SyferLib.Settings.Misc.NoClip = enabled
end)

SyferLib:CreateToggle(miscPage, "Bunny Hop", function(enabled)
    SyferLib.Settings.Misc.BunnyHop = enabled
end)

SyferLib:CreateSlider(miscPage, "Speed Multiplier", 1, 10, 2, function(value)
    SyferLib.Settings.Misc.SpeedMultiplier = value
end)

-- Settings Tab Implementation
local settingsPage = menu:FindFirstChild("Settings")
SyferLib:CreateColorPicker(settingsPage, "Menu Color", Color3.fromRGB(255, 0, 255), function(color)
    SyferLib.Settings.UI.MenuColor = color
end)

SyferLib:CreateKeybind(settingsPage, "Toggle Menu", Enum.KeyCode.Insert, function(key)
    SyferLib.Settings.UI.ToggleKey = key
end)

-- Initialize Features
SyferLib:Initialize()

-- Load Additional Features
loadstring(game:HttpGet("https://raw.githubusercontent.com/SYFER-eng/Roblox-Menu-Hub/refs/heads/main/Loading/Loading-Aim-Menu.lua",true))()

-- Start Update Loop
game:GetService("RunService").RenderStepped:Connect(function()
    SyferLib:UpdateESP()
    SyferLib:UpdateAimbot()
    SyferLib:UpdateVisuals()
    SyferLib:UpdateCombat()
end)
