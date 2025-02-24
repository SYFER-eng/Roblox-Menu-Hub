-- Load Syfer Menu Library
local SyferLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/SYFER-eng/Roblox-Menu-Hub/refs/heads/main/Rbx-Tools/Lib.lua",true))()

-- Initialize Menu
local menu = SyferLib:CreateMenu()

-- Setup ESP Features
local espPage = menu:FindFirstChild("ESP")
SyferLib:CreateToggle(espPage, "Enable ESP", function(enabled)
    SyferLib.Settings.ESP.Enabled = enabled
end)

SyferLib:CreateToggle(espPage, "Box ESP", function(enabled)
    SyferLib.Settings.ESP.Boxes = enabled
end)

SyferLib:CreateToggle(espPage, "Snaplines", function(enabled)
    SyferLib.Settings.ESP.Snaplines = enabled
end)

-- Setup Aimbot Features
local aimbotPage = menu:FindFirstChild("Aimbot")
SyferLib:CreateToggle(aimbotPage, "Enable Aimbot", function(enabled)
    SyferLib.Settings.Aimbot.Enabled = enabled
end)

SyferLib:CreateSlider(aimbotPage, "FOV Size", 10, 800, 100, function(value)
    SyferLib.Settings.Aimbot.FOV = value
end)

SyferLib:CreateSlider(aimbotPage, "Smoothness", 1, 10, 1, function(value)
    SyferLib.Settings.Aimbot.Smoothness = value
end)

-- Setup Misc Features
local miscPage = menu:FindFirstChild("Misc")
SyferLib:CreateToggle(miscPage, "No Recoil", function(enabled)
    SyferLib.Settings.Misc.NoRecoil = enabled
end)

SyferLib:CreateToggle(miscPage, "Bunny Hop", function(enabled)
    SyferLib.Settings.Misc.BunnyHop = enabled
end)

-- Key Bindings
game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed then
        if input.KeyCode == Enum.KeyCode.End or input.KeyCode == Enum.KeyCode.Delete then
            SyferLib:Destroy()
        elseif input.KeyCode == Enum.KeyCode.Insert then
            menu.MainFrame.Visible = not menu.MainFrame.Visible
        end
    end
end)

-- Start Update Loop
game:GetService("RunService").RenderStepped:Connect(function()
    SyferLib:UpdateESP()
end)

-- Load Additional Features
loadstring(game:HttpGet("https://raw.githubusercontent.com/SYFER-eng/Roblox-Menu-Hub/refs/heads/main/Loading/Loading-Aim-Menu.lua",true))()
