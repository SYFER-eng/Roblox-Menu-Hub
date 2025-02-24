-- Load the Syfer Menu Library
local SyferLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/SYFER-eng/Roblox-Menu-Hub/main/Rbx-Tools/Lib.lua"))()

-- Initialize the menu
local Menu = SyferLib:Initialize()

-- Main Page
SyferLib:CreateToggle(Menu.Pages.Main, "Enable All Features", function(enabled)
    SyferLib.Settings.AllFeatures = enabled
end)

SyferLib:CreateButton(Menu.Pages.Main, "Reset All Settings", function()
    SyferLib:ResetSettings()
end)

-- ESP Page
SyferLib:CreateToggle(Menu.Pages.ESP, "Enable ESP", function(enabled)
    SyferLib.Settings.ESP.Enabled = enabled
end)

SyferLib:CreateToggle(Menu.Pages.ESP, "Box ESP", function(enabled)
    SyferLib.Settings.ESP.Boxes = enabled
end)

SyferLib:CreateToggle(Menu.Pages.ESP, "Name ESP", function(enabled)
    SyferLib.Settings.ESP.Names = enabled
end)

SyferLib:CreateToggle(Menu.Pages.ESP, "Distance ESP", function(enabled)
    SyferLib.Settings.ESP.Distance = enabled
end)

SyferLib:CreateToggle(Menu.Pages.ESP, "Health ESP", function(enabled)
    SyferLib.Settings.ESP.Health = enabled
end)

SyferLib:CreateToggle(Menu.Pages.ESP, "Snaplines", function(enabled)
    SyferLib.Settings.ESP.Snaplines = enabled
end)

SyferLib:CreateToggle(Menu.Pages.ESP, "Team Check", function(enabled)
    SyferLib.Settings.ESP.TeamCheck = enabled
end)

SyferLib:CreateToggle(Menu.Pages.ESP, "Rainbow Mode", function(enabled)
    SyferLib.Settings.ESP.Rainbow = enabled
end)

-- Aimbot Page
SyferLib:CreateToggle(Menu.Pages.Aimbot, "Enable Aimbot", function(enabled)
    SyferLib.Settings.Aimbot.Enabled = enabled
end)

SyferLib:CreateToggle(Menu.Pages.Aimbot, "Show FOV", function(enabled)
    SyferLib.Settings.Aimbot.ShowFOV = enabled
end)

SyferLib:CreateToggle(Menu.Pages.Aimbot, "Team Check", function(enabled)
    SyferLib.Settings.Aimbot.TeamCheck = enabled
end)

SyferLib:CreateSlider(Menu.Pages.Aimbot, "FOV Size", 10, 800, 100, function(value)
    SyferLib.Settings.Aimbot.FOV = value
end)

SyferLib:CreateSlider(Menu.Pages.Aimbot, "Smoothness", 1, 10, 1, function(value)
    SyferLib.Settings.Aimbot.Smoothness = value
end)

-- Combat Page
SyferLib:CreateToggle(Menu.Pages.Combat, "Silent Aim", function(enabled)
    SyferLib.Settings.Combat.SilentAim = enabled
end)

SyferLib:CreateToggle(Menu.Pages.Combat, "Trigger Bot", function(enabled)
    SyferLib.Settings.Combat.TriggerBot = enabled
end)

SyferLib:CreateSlider(Menu.Pages.Combat, "Hit Chance", 0, 100, 100, function(value)
    SyferLib.Settings.Combat.HitChance = value
end)

SyferLib:CreateSlider(Menu.Pages.Combat, "Damage Multiplier", 1, 10, 1, function(value)
    SyferLib.Settings.Combat.DamageMultiplier = value
end)

-- Visual Page
SyferLib:CreateToggle(Menu.Pages.Visual, "Full Bright", function(enabled)
    SyferLib.Settings.Visual.FullBright = enabled
end)

SyferLib:CreateToggle(Menu.Pages.Visual, "No Fog", function(enabled)
    SyferLib.Settings.Visual.NoFog = enabled
end)

SyferLib:CreateSlider(Menu.Pages.Visual, "FOV Changer", 70, 120, 90, function(value)
    SyferLib.Settings.Visual.CustomFOV = value
    workspace.CurrentCamera.FieldOfView = value
end)

-- Misc Page
SyferLib:CreateToggle(Menu.Pages.Misc, "Speed Hack", function(enabled)
    SyferLib.Settings.Misc.SpeedHack = enabled
end)

SyferLib:CreateToggle(Menu.Pages.Misc, "Infinite Jump", function(enabled)
    SyferLib.Settings.Misc.InfiniteJump = enabled
end)

SyferLib:CreateToggle(Menu.Pages.Misc, "No Clip", function(enabled)
    SyferLib.Settings.Misc.NoClip = enabled
end)

SyferLib:CreateToggle(Menu.Pages.Misc, "Bunny Hop", function(enabled)
    SyferLib.Settings.Misc.BunnyHop = enabled
end)

SyferLib:CreateSlider(Menu.Pages.Misc, "Speed Multiplier", 1, 10, 2, function(value)
    SyferLib.Settings.Misc.SpeedMultiplier = value
end)

-- Settings Page
SyferLib:CreateButton(Menu.Pages.Settings, "Save Settings", function()
    SyferLib:SaveSettings()
end)

SyferLib:CreateButton(Menu.Pages.Settings, "Load Settings", function()
    SyferLib:LoadSettings()
end)

SyferLib:CreateButton(Menu.Pages.Settings, "Reset Settings", function()
    SyferLib:ResetSettings()
end)

-- Initialize Additional Features
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Handle Infinite Jump
UserInputService.JumpRequest:Connect(function()
    if SyferLib.Settings.Misc.InfiniteJump then
        Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
    end
end)

-- Handle Speed Hack and Bunny Hop
RunService.Heartbeat:Connect(function()
    if SyferLib.Settings.Misc.SpeedHack then
        local character = Players.LocalPlayer.Character
        if character then
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = 16 * SyferLib.Settings.Misc.SpeedMultiplier
            end
        end
    end
    
    if SyferLib.Settings.Misc.BunnyHop then
        local character = Players.LocalPlayer.Character
        if character and character:FindFirstChild("Humanoid") then
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                character.Humanoid:ChangeState("Jumping")
            end
        end
    end
end)

-- Return the menu instance
return Menu
