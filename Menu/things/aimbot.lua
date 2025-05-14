-- Aimbot Module
-- Handles aimbot functionality

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local AimbotModule = {}
local Config = nil
local Utilities = nil
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

local AimbotState = {
    Active = false,
    Target = nil,
    FOVCircle = nil
}

-- Initialize function
function AimbotModule.Initialize(ConfigModule, UtilitiesModule)
    Config = ConfigModule
    Utilities = UtilitiesModule
    
    -- Create FOV circle
    AimbotModule.CreateFOVCircle()
    
    -- Setup input handling
    UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
        if gameProcessedEvent then return end
        
        if input.KeyCode == Config.Aimbot.TriggerKey then
            if Config.Aimbot.LockMode == "Toggle" then
                AimbotState.Active = not AimbotState.Active
            else
                AimbotState.Active = true
            end
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input, gameProcessedEvent)
        if gameProcessedEvent then return end
        
        if input.KeyCode == Config.Aimbot.TriggerKey and Config.Aimbot.LockMode == "Hold" then
            AimbotState.Active = false
        end
    end)
end

-- Create FOV circle for visual targeting reference
function AimbotModule.CreateFOVCircle()
    -- Check if Drawing module exists
    if not Drawing then
        warn("Drawing module not available. FOV circle cannot be created.")
        return
    end
    
    -- Remove existing circle if any
    if AimbotState.FOVCircle then
        AimbotState.FOVCircle:Remove()
    end
    
    -- Create new circle
    AimbotState.FOVCircle = Drawing.new("Circle")
    AimbotState.FOVCircle.Visible = Config.Aimbot.ShowFOV and Config.Aimbot.Enabled
    AimbotState.FOVCircle.Color = Config.Aimbot.FOVColor
    AimbotState.FOVCircle.Thickness = 1
    AimbotState.FOVCircle.Transparency = Config.Aimbot.FOVTransparency
    AimbotState.FOVCircle.NumSides = Config.Aimbot.FOVSides
    AimbotState.FOVCircle.Radius = Config.Aimbot.FOV
    AimbotState.FOVCircle.Filled = false
    AimbotState.FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
end

-- Update FOV circle properties
function AimbotModule.UpdateFOVCircle()
    if not AimbotState.FOVCircle then
        AimbotModule.CreateFOVCircle()
        return
    end
    
    AimbotState.FOVCircle.Visible = Config.Aimbot.ShowFOV and Config.Aimbot.Enabled
    AimbotState.FOVCircle.Color = Config.Aimbot.FOVColor
    AimbotState.FOVCircle.Transparency = Config.Aimbot.FOVTransparency
    AimbotState.FOVCircle.NumSides = Config.Aimbot.FOVSides
    AimbotState.FOVCircle.Radius = Config.Aimbot.FOV
    AimbotState.FOVCircle.Position = UserInputService:GetMouseLocation()
end

-- Update function called every frame
function AimbotModule.Update(deltaTime)
    -- Update FOV circle
    AimbotModule.UpdateFOVCircle()
    
    -- Don't proceed if aimbot is disabled or not active
    if not Config.Aimbot.Enabled or not AimbotState.Active then
        AimbotState.Target = nil
        return
    end
    
    -- Get closest player to cursor
    local target = Utilities.GetClosestPlayerToCursor(true)
    
    if target and target.Character then
        -- Assign target
        AimbotState.Target = target
        
        -- Get target part
        local targetPart = target.Character:FindFirstChild(Config.Aimbot.TargetPart)
        if not targetPart then
            targetPart = target.Character:FindFirstChild("HumanoidRootPart") or
                         target.Character:FindFirstChild("Torso") or
                         target.Character:FindFirstChild("UpperTorso")
            
            if not targetPart then
                AimbotState.Target = nil
                return
            end
        end
        
        -- Check if we can hit
        if Config.Aimbot.HitChance < 100 then
            local hitRoll = math.random(1, 100)
            if hitRoll > Config.Aimbot.HitChance then
                -- Randomly miss based on hit chance
                return
            end
        end
        
        -- Predict target position
        local targetPosition = Utilities.PredictTargetPosition(targetPart, Config.Aimbot.Prediction.Strength)
        
        -- Aim at the target
        Utilities.AimAt(targetPosition)
        
        -- Auto fire if enabled
        if Config.Aimbot.AutoFire then
            -- Only fire if target is visible
            if Utilities.IsVisible(targetPart) then
                Utilities.TriggerClick()
            end
        end
    else
        -- No target found
        AimbotState.Target = nil
    end
end

-- Toggle aimbot programmatically
function AimbotModule.Toggle(state)
    Config.Aimbot.Enabled = state
    
    -- Update FOV circle visibility
    if AimbotState.FOVCircle then
        AimbotState.FOVCircle.Visible = Config.Aimbot.ShowFOV and Config.Aimbot.Enabled
    end
    
    return Config.Aimbot.Enabled
end

-- Set target part
function AimbotModule.SetTargetPart(part)
    if part and typeof(part) == "string" then
        Config.Aimbot.TargetPart = part
        return true
    end
    return false
end

-- Set FOV
function AimbotModule.SetFOV(radius)
    if radius and typeof(radius) == "number" then
        Config.Aimbot.FOV = radius
        if AimbotState.FOVCircle then
            AimbotState.FOVCircle.Radius = radius
        end
        return true
    end
    return false
end

-- Cleanup resources
function AimbotModule.Cleanup()
    if AimbotState.FOVCircle then
        AimbotState.FOVCircle:Remove()
        AimbotState.FOVCircle = nil
    end
    
    AimbotState.Active = false
    AimbotState.Target = nil
end

-- Get current state
function AimbotModule.GetState()
    return {
        Active = AimbotState.Active,
        HasTarget = AimbotState.Target ~= nil,
        TargetName = AimbotState.Target and AimbotState.Target.Name or nil
    }
end

return AimbotModule