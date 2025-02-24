-- First, load the welcome message and initial setup
print("Welcome To Syfer-eng's World!")
loadstring(game:HttpGet("https://raw.githubusercontent.com/SYFER-eng/Roblox-Menu-Hub/refs/heads/main/Loading/Loading-Aim-Menu.lua",true))()

[Previous menu code from your first message]

-- Add the radar code right after the menu initialization
[Radar code from my last message]

-- Add these radar-specific settings to your existing Settings table
Settings.Radar = {
    Enabled = false,
    TeamCheck = true,
    HealthColor = true,
    Scale = 1
}

-- Add radar controls to the Misc page
CreateToggle(Pages.Misc, "Show Radar", function(enabled)
    Settings.Radar.Enabled = enabled
    RadarBackground.Visible = enabled
    RadarBorder.Visible = enabled
    LocalPlayerDot.Visible = enabled
    
    if enabled then
        for _, v in pairs(Players:GetChildren()) do
            if v.Name ~= Player.Name then
                PlaceDot(v)
            end
        end
    end
end)

CreateToggle(Pages.Misc, "Radar Team Check", function(enabled)
    Settings.Radar.TeamCheck = enabled
    RadarInfo.Team_Check = enabled
end)

CreateToggle(Pages.Misc, "Radar Health Colors", function(enabled)
    Settings.Radar.HealthColor = enabled
    RadarInfo.Health_Color = enabled
end)

CreateSlider(Pages.Misc, "Radar Scale", 1, 10, 1, function(value)
    Settings.Radar.Scale = value
    RadarInfo.Scale = value
end)

-- Initialize everything
InitializeUI()
