-- Utilities Module
-- Contains common functions used by other modules

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Utilities = {}
local Config = nil
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- Initialize function
function Utilities.Initialize(ConfigModule)
    Config = ConfigModule
    
    -- Additional setup if needed
    RunService.Heartbeat:Connect(function()
        if Config.Anti.AntiAFK then
            Utilities.PreventAFK()
        end
    end)
end

-- Player Utility Functions
function Utilities.IsAlive(player)
    local character = player.Character
    return character and 
           character:FindFirstChild("Humanoid") and 
           character.Humanoid.Health > 0 and
           character:FindFirstChild("HumanoidRootPart")
end

function Utilities.IsTeammate(player)
    if not Config.Aimbot.TeamCheck then return false end
    
    -- Check various team implementations in different games
    -- Standard Roblox teams
    if player.Team and LocalPlayer.Team then
        return player.Team == LocalPlayer.Team
    end
    
    -- Some games use team colors
    if player.TeamColor and LocalPlayer.TeamColor then
        return player.TeamColor == LocalPlayer.TeamColor
    end
    
    -- Some games store team data in player attributes
    if player:GetAttribute("Team") and LocalPlayer:GetAttribute("Team") then
        return player:GetAttribute("Team") == LocalPlayer:GetAttribute("Team")
    end
    
    -- Check for team in character
    local playerChar = player.Character
    local localChar = LocalPlayer.Character
    
    if playerChar and localChar then
        -- Some games use team value in character
        if playerChar:FindFirstChild("Team") and localChar:FindFirstChild("Team") then
            return playerChar.Team.Value == localChar.Team.Value
        end
        
        -- Some games use different colored parts
        if playerChar:FindFirstChild("TeamColor") and localChar:FindFirstChild("TeamColor") then
            return playerChar.TeamColor.Value == localChar.TeamColor.Value
        end
    end
    
    return false
end

function Utilities.IsVisible(part)
    if not Config.Aimbot.VisibilityCheck then return true end
    
    local origin = Camera.CFrame.Position
    local direction = (part.Position - origin).Unit
    local ray = Ray.new(origin, direction * Config.Aimbot.MaxDistance)
    
    local ignoreList = {LocalPlayer.Character, Camera}
    
    -- Some games use a specific raycast method
    local Raycast = workspace.Raycast
    if typeof(Raycast) == "function" then
        local result = Raycast(workspace, origin, direction * Config.Aimbot.MaxDistance, RaycastParams.new())
        if result then
            return result.Instance:IsDescendantOf(part.Parent)
        end
        return true
    end
    
    -- Standard raycast method
    local hit, position = workspace:FindPartOnRayWithIgnoreList(ray, ignoreList)
    
    if hit then
        return hit:IsDescendantOf(part.Parent)
    end
    
    return true
end

function Utilities.GetPlayerTeamColor(player)
    -- Try to get team color in various ways
    if player.Team then
        return player.TeamColor.Color
    elseif player.Character and player.Character:FindFirstChild("TeamColor") then
        return player.Character.TeamColor.Value
    else
        -- Fallback to ESP color setting
        return Config.ESP.BoxColor
    end
end

function Utilities.GetClosestPlayerToCursor(fovCheck)
    fovCheck = fovCheck or true
    
    local closestPlayer = nil
    local shortestDistance = Config.Aimbot.MaxDistance
    local shortestFovDistance = Config.Aimbot.FOV
    
    local mousePos = UserInputService:GetMouseLocation()
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and 
           Utilities.IsAlive(player) and 
           not Utilities.IsTeammate(player) then
            
            local character = player.Character
            
            -- Determine target part based on settings or priority
            local targetPart = nil
            
            if Config.Aimbot.TargetPart == "Random" then
                local validParts = {}
                for part, enabled in pairs(Config.Aimbot.HitParts) do
                    if enabled and character:FindFirstChild(part) then
                        table.insert(validParts, character[part])
                    end
                end
                
                if #validParts > 0 then
                    targetPart = validParts[math.random(1, #validParts)]
                end
            else
                targetPart = character:FindFirstChild(Config.Aimbot.TargetPart)
            end
            
            if not targetPart then
                -- Fallback to HumanoidRootPart if specified part doesn't exist
                targetPart = character:FindFirstChild("HumanoidRootPart")
                if not targetPart then
                    continue
                end
            end
            
            if Config.Aimbot.WallCheck and not Utilities.IsVisible(targetPart) then
                continue
            end
            
            -- Get 2D screen position of target
            local screenPoint, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
            
            if onScreen then
                local distanceFromMouse = (Vector2.new(screenPoint.X, screenPoint.Y) - mousePos).Magnitude
                local worldDistance = (targetPart.Position - Camera.CFrame.Position).Magnitude
                
                if worldDistance <= Config.Aimbot.MaxDistance then
                    -- FOV check
                    if not fovCheck or distanceFromMouse <= shortestFovDistance then
                        -- Prioritization based on settings
                        local takePriority = false
                        
                        if Config.Aimbot.TargetPriority == "Distance" then
                            if distanceFromMouse < shortestFovDistance then
                                takePriority = true
                                shortestFovDistance = distanceFromMouse
                            end
                        elseif Config.Aimbot.TargetPriority == "Health" then
                            local humanoid = character:FindFirstChild("Humanoid")
                            if humanoid and humanoid.Health < shortestDistance then
                                takePriority = true
                                shortestDistance = humanoid.Health
                            end
                        elseif Config.Aimbot.TargetPriority == "Level" then
                            -- This would need to be adapted to the specific game
                            local level = player:GetAttribute("Level") or 0
                            if level > shortestDistance then
                                takePriority = true
                                shortestDistance = level
                            end
                        end
                        
                        if takePriority or not closestPlayer then
                            closestPlayer = player
                        end
                    end
                end
            end
        end
    end
    
    return closestPlayer
end

function Utilities.PredictTargetPosition(targetPart, strength)
    if not targetPart or not Config.Aimbot.Prediction.Enabled then return targetPart.Position end
    
    strength = strength or Config.Aimbot.Prediction.Strength
    
    -- Get character and humanoid
    local character = targetPart.Parent
    if not character then return targetPart.Position end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return targetPart.Position end
    
    -- Calculate velocity
    local velocityMultiplier = 0.1 * strength
    local prediction = targetPart.Position + (targetPart.Velocity * velocityMultiplier)
    
    return prediction
end

function Utilities.AimAt(position)
    if Config.Aimbot.SilentAim then
        -- Implementation depends on the game and exploit capabilities
        -- This is a placeholder for silent aim
        return
    end
    
    -- Standard aimbot
    local targetCFrame = CFrame.lookAt(Camera.CFrame.Position, position)
    local smoothness = Config.Aimbot.Smoothness
    
    if smoothness > 0 then
        Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, 1 - smoothness)
    else
        Camera.CFrame = targetCFrame
    end
end

function Utilities.TriggerClick()
    -- Simulate mouse click through different possible methods
    if Config.Aimbot.AutoFire then
        pcall(function()
            if mouse1press and mouse1release then
                mouse1press()
                task.wait(0.05)
                mouse1release()
            elseif Input and Input.MouseButton1Down and Input.MouseButton1Up then
                Input.MouseButton1Down()
                task.wait(0.05)
                Input.MouseButton1Up()
            else
                mouse1click()
            end
        end)
    end
end

-- Helper Functions
function Utilities.Round(number, decimals)
    local power = 10 ^ (decimals or 0)
    return math.floor(number * power + 0.5) / power
end

function Utilities.GetDistanceFromCamera(position)
    return (position - Camera.CFrame.Position).Magnitude
end

function Utilities.ClampColor(color)
    return Color3.new(
        math.clamp(color.R, 0, 1),
        math.clamp(color.G, 0, 1),
        math.clamp(color.B, 0, 1)
    )
end

function Utilities.BrightenColor(color, amount)
    amount = amount or 0.2
    return Utilities.ClampColor(Color3.new(
        color.R + amount,
        color.G + amount,
        color.B + amount
    ))
end

function Utilities.DarkenColor(color, amount)
    amount = amount or 0.2
    return Utilities.ClampColor(Color3.new(
        color.R - amount,
        color.G - amount,
        color.B - amount
    ))
end

function Utilities.LerpColor(a, b, t)
    t = math.clamp(t, 0, 1)
    return Color3.new(
        a.R + (b.R - a.R) * t,
        a.G + (b.G - a.G) * t,
        a.B + (b.B - a.B) * t
    )
end

function Utilities.GetColorBasedOnHealth(health, maxHealth)
    local healthRatio = health / maxHealth
    
    if healthRatio > 0.75 then
        return Color3.fromRGB(0, 255, 0) -- Green
    elseif healthRatio > 0.5 then
        return Color3.fromRGB(255, 255, 0) -- Yellow
    elseif healthRatio > 0.25 then
        return Color3.fromRGB(255, 125, 0) -- Orange
    else
        return Color3.fromRGB(255, 0, 0) -- Red
    end
end

function Utilities.PreventAFK()
    -- Anti-AFK implementation
    pcall(function()
        for _, v in pairs(getconnections(LocalPlayer.Idled)) do
            v:Disable()
        end
    end)
end

return Utilities