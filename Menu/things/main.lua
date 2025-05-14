-- Advanced Aimbot & ESP Menu for Roblox
-- Compatible with popular external executors
-- Created for educational purposes only

-- Services
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Load Modules
local Config = loadstring(game:HttpGet("https://raw.githubusercontent.com/username/reponame/main/config.lua"))()
local Utilities = loadstring(game:HttpGet("https://raw.githubusercontent.com/username/reponame/main/utilities.lua"))()
local UILibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/username/reponame/main/ui_library.lua"))()
local AimbotModule = loadstring(game:HttpGet("https://raw.githubusercontent.com/username/reponame/main/aimbot.lua"))()
local ESPModule = loadstring(game:HttpGet("https://raw.githubusercontent.com/username/reponame/main/esp.lua"))()
local GUIModule = loadstring(game:HttpGet("https://raw.githubusercontent.com/username/reponame/main/gui.lua"))()

-- Check if already loaded to prevent multiple instances
if _G.AimbotESPLoaded then
    warn("Aimbot & ESP Menu is already running!")
    return
end

-- Initialize
local function Initialize()
    -- Set global flag to prevent multiple instances
    _G.AimbotESPLoaded = true
    
    -- Initialize modules with dependencies
    Utilities.Initialize(Config)
    UILibrary.Initialize(Config)
    AimbotModule.Initialize(Config, Utilities)
    ESPModule.Initialize(Config, Utilities)
    
    -- Create GUI with all modules as dependencies
    local gui = GUIModule.CreateGUI(Config, Utilities, UILibrary, AimbotModule, ESPModule)
    
    -- Setup input handling for menu toggle
    UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
        if gameProcessedEvent then return end
        
        if input.KeyCode == Config.UI.MenuKey then
            Config.UI.Enabled = not Config.UI.Enabled
            GUIModule.ToggleGUI(Config.UI.Enabled)
        end
    end)
    
    -- Main update loop
    RunService.RenderStepped:Connect(function(deltaTime)
        if Config.UI.Enabled then
            if Config.Aimbot.Enabled then
                AimbotModule.Update(deltaTime)
            end
            
            if Config.ESP.Enabled then
                ESPModule.Update(deltaTime)
            end
        end
    end)
    
    -- Show welcome notification
    UILibrary.ShowNotification(
        "Aimbot & ESP Loaded", 
        "Press " .. Config.UI.MenuKey.Name .. " to toggle menu.\nPress " .. Config.Aimbot.TriggerKey.Name .. " to activate aimbot.",
        5
    )
end

-- Run the initialization
pcall(function()
    Initialize()
end)

-- Cleanup function for when script is unloaded
local function Cleanup()
    if _G.AimbotESPLoaded then
        AimbotModule.Cleanup()
        ESPModule.Cleanup()
        GUIModule.Cleanup()
        _G.AimbotESPLoaded = false
    end
end

-- Set cleanup handler
if shared.AimbotESPCleanupConnection then
    shared.AimbotESPCleanupConnection:Disconnect()
end
shared.AimbotESPCleanupConnection = game.Close:Connect(Cleanup)

return {
    Config = Config,
    Utilities = Utilities,
    Cleanup = Cleanup
}