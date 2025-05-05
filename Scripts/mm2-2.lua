-- MM2 ESP Script
-- Press L to toggle ESP, End to unload script
-- Press K to toggle gun-only mode, J to toggle role display

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

-- Configuration
local Config = {
    espEnabled = false,
    gunOnlyMode = false,
    showRoles = true,
    updateInterval = 0.5, -- Seconds between full ESP updates
    maxDistance = 2000,
    murdererColor = Color3.fromRGB(255, 0, 0),
    sheriffColor = Color3.fromRGB(0, 50, 255),
    innocentColor = Color3.fromRGB(50, 180, 50),
    unknownColor = Color3.fromRGB(204, 204, 26),
    gunColor = Color3.fromRGB(0, 100, 255)
}

local connections = {}
local espCache = {}
local lastFullUpdate = 0
local murderer, sheriff = nil, nil

-- Create ESP folder
local espFolder = Instance.new("Folder")
espFolder.Name = "MM2_ESP"
espFolder.Parent = game.CoreGui

-- Utility functions
local function isAlive(player)
    if not player or not player.Character then return false end
    local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
    return humanoid and humanoid.Health > 0
end

local function getDistance(player)
    if not player or not player.Character or not LocalPlayer.Character then return math.huge end
    local root1 = player.Character:FindFirstChild("HumanoidRootPart")
    local root2 = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root1 or not root2 then return math.huge end
    return (root1.Position - root2.Position).Magnitude
end

-- Role detection functions
local function hasKnife(player)
    if not isAlive(player) then return false end
    
    -- Check attributes first (most reliable)
    if player:GetAttribute("Role") == "Murderer" or player:GetAttribute("playerRole") == "Murderer" then
        return true
    end
    
    -- Check character for knife
    for _, item in pairs(player.Character:GetChildren()) do
        if item:IsA("Tool") and (item.Name == "Knife" or string.find(string.lower(item.Name), "knife")) then
            return true
        end
    end
    
    -- Check backpack for knife
    for _, item in pairs(player.Backpack:GetChildren()) do
        if item:IsA("Tool") and (item.Name == "Knife" or string.find(string.lower(item.Name), "knife")) then
            return true
        end
    end
    
    return false
end

local function hasGun(player)
    if not isAlive(player) then return false end
    
    -- Check attributes first (most reliable)
    if player:GetAttribute("Role") == "Sheriff" or player:GetAttribute("playerRole") == "Sheriff" then
        return true
    end
    
    -- Check character for gun
    for _, item in pairs(player.Character:GetChildren()) do
        if item:IsA("Tool") and (item.Name == "Gun" or string.find(string.lower(item.Name), "gun") or 
                                string.find(string.lower(item.Name), "revolver")) then
            return true
        end
    end
    
    -- Check backpack for gun
    for _, item in pairs(player.Backpack:GetChildren()) do
        if item:IsA("Tool") and (item.Name == "Gun" or string.find(string.lower(item.Name), "gun") or 
                                string.find(string.lower(item.Name), "revolver")) then
            return true
        end
    end
    
    return false
end

local function findDroppedGun()
    -- Common parent containers for the gun
    local potentialContainers = {
        workspace,
        workspace:FindFirstChild("Debris"),
        workspace:FindFirstChild("Dropped"),
        workspace:FindFirstChild("Items")
    }
    
    -- Search in all potential containers
    for _, container in pairs(potentialContainers) do
        if container then
            -- Direct children search
            for _, item in pairs(container:GetChildren()) do
                if item:IsA("BasePart") or item:IsA("Model") then
                    if item.Name == "Gun" or string.find(string.lower(item.Name), "gun") or 
                       string.find(string.lower(item.Name), "revolver") then
                        return item
                    end
                end
            end
            
            -- Deep search for specific games that nest the gun deeper
            for _, model in pairs(container:GetChildren()) do
                if model:IsA("Model") then
                    for _, item in pairs(model:GetDescendants()) do
                        if (item:IsA("BasePart") or item:IsA("Model")) and
                           (item.Name == "Gun" or string.find(string.lower(item.Name), "gun") or 
                            string.find(string.lower(item.Name), "revolver")) then
                            return item
                        end
                    end
                end
            end
        end
    end
    
    return nil
end

-- ESP creation functions
local function createGunESP(gun)
    local existingESP = espFolder:FindFirstChild("Gun_ESP")
    if existingESP then existingESP:Destroy() end
    
    -- Create ESP components
    local esp = Instance.new("BillboardGui")
    local gunBackground = Instance.new("Frame")
    local text = Instance.new("TextLabel")
    
    -- Configure main ESP billboard
    esp.Name = "Gun_ESP"
    esp.AlwaysOnTop = true
    esp.Size = UDim2.new(0, 200, 0, 50)
    esp.StudsOffset = Vector3.new(0, 1, 0)
    esp.Adornee = gun
    esp.MaxDistance = Config.maxDistance
    
    -- Configure gun background
    gunBackground.Name = "GunBackground"
    gunBackground.BackgroundColor3 = Config.gunColor
    gunBackground.BackgroundTransparency = 0.3
    gunBackground.Size = UDim2.new(0.6, 0, 0.7, 0)
    gunBackground.Position = UDim2.new(0.2, 0, 0.15, 0)
    gunBackground.BorderSizePixel = 0
    
    -- Configure gun text
    text.Name = "GunText"
    text.BackgroundTransparency = 1
    text.Size = UDim2.new(1, 0, 1, 0)
    text.Font = Enum.Font.SourceSansBold
    text.TextSize = 20
    text.TextStrokeTransparency = 0
    text.Text = "🔫 GUN"
    text.TextColor3 = Color3.fromRGB(102, 178, 255)
    text.TextStrokeColor3 = Color3.fromRGB(0, 25, 102)
    
    -- Set up the parent hierarchy
    text.Parent = gunBackground
    gunBackground.Parent = esp
    esp.Parent = espFolder
    
    -- Create highlight separately
    local highlight = Instance.new("Highlight")
    highlight.Name = "GunHighlight"
    highlight.FillColor = Config.gunColor
    highlight.OutlineColor3 = Color3.fromRGB(102, 153, 255)
    highlight.OutlineTransparency = 0.3
    highlight.FillTransparency = 0.5
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = gun
    
    -- Add pulsing effect to make gun more noticeable
    local tweenInfo = TweenInfo.new(
        0.8,                    -- Time
        Enum.EasingStyle.Sine,  -- EasingStyle
        Enum.EasingDirection.InOut, -- EasingDirection
        -1,                     -- RepeatCount (infinite)
        true,                   -- Reverses
        0                       -- DelayTime
    )
    
    local transparencyTween = TweenService:Create(
        highlight, 
        tweenInfo,
        {FillTransparency = 0.2}
    )
    
    transparencyTween:Play()
    
    return esp, highlight
end

local function createESP(player, role)
    if not player or not player.Character then return nil end
    
    -- Remove existing ESP if any
    local existingESP = espFolder:FindFirstChild(player.Name .. "_ESP")
    if existingESP then existingESP:Destroy() end
    
    -- Remove existing highlight if any
    if player.Character then
        local existingHighlight = player.Character:FindFirstChild("PlayerHighlight")
        if existingHighlight then existingHighlight:Destroy() end
    end
    
    if not isAlive(player) then return nil end
    
    local head = player.Character:FindFirstChild("Head") or 
                player.Character:FindFirstChild("HumanoidRootPart") or 
                player.Character.PrimaryPart
    
    if not head then return nil end
    
    -- Create ESP components
    local esp = Instance.new("BillboardGui")
    local roleBackground = Instance.new("Frame")
    local text = Instance.new("TextLabel")
    local roleLabel = Instance.new("TextLabel")
    local distance = Instance.new("TextLabel")
    
    -- Configure main ESP billboard
    esp.Name = player.Name .. "_ESP"
    esp.AlwaysOnTop = true
    esp.Size = UDim2.new(0, 200, 0, 75) -- Increased height for distance
    esp.StudsOffset = Vector3.new(0, 3, 0)
    esp.Adornee = head
    esp.MaxDistance = Config.maxDistance
    esp.ResetOnSpawn = false
    
    -- Configure role background
    roleBackground.Name = "RoleBackground"
    roleBackground.BackgroundTransparency = 0.3
    roleBackground.Size = UDim2.new(0.8, 0, 0.3, 0)
    roleBackground.Position = UDim2.new(0.1, 0, 0.55, 0)
    roleBackground.BorderSizePixel = 0
    
    -- Configure player name text
    text.Name = "PlayerText"
    text.BackgroundTransparency = 1
    text.Size = UDim2.new(1, 0, 0.5, 0)
    text.Position = UDim2.new(0, 0, 0, 0)
    text.Font = Enum.Font.SourceSansBold
    text.TextSize = 18
    text.TextStrokeTransparency = 0
    text.Text = player.Name
    
    -- Configure role text with icons for clearer visibility
    roleLabel.Name = "RoleText"
    roleLabel.BackgroundTransparency = 1
    roleLabel.Size = UDim2.new(1, 0, 1, 0)
    roleLabel.Font = Enum.Font.SourceSansBold
    roleLabel.TextSize = 16
    roleLabel.TextStrokeTransparency = 0
    
    -- Configure distance text
    distance.Name = "DistanceText"
    distance.BackgroundTransparency = 1
    distance.Size = UDim2.new(1, 0, 0.2, 0)
    distance.Position = UDim2.new(0, 0, 0.8, 0)
    distance.Font = Enum.Font.SourceSans
    distance.TextSize = 14
    distance.TextStrokeTransparency = 0.5
    distance.TextColor3 = Color3.fromRGB(255, 255, 255)
    distance.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    
    local playerDistance = math.floor(getDistance(player))
    distance.Text = playerDistance .. " studs"
    
    -- Create highlight separately
    local highlight = Instance.new("Highlight")
    highlight.Name = "PlayerHighlight"
    
    -- Set colors and text based on role
    if role == "Murderer" then
        roleLabel.Text = Config.showRoles and "🔪 MURDERER" or ""
        text.TextColor3 = Color3.fromRGB(255, 77, 77)
        text.TextStrokeColor3 = Color3.fromRGB(128, 0, 0)
        
        roleBackground.BackgroundColor3 = Config.murdererColor
        roleLabel.TextColor3 = Color3.fromRGB(255, 77, 77)
        roleLabel.TextStrokeColor3 = Color3.fromRGB(77, 0, 0)
        
        highlight.FillColor = Config.murdererColor
        highlight.OutlineColor3 = Color3.fromRGB(255, 128, 128)
        highlight.FillTransparency = 0.6
    elseif role == "Sheriff" then
        roleLabel.Text = Config.showRoles and "🔫 SHERIFF" or ""
        text.TextColor3 = Color3.fromRGB(0, 128, 255)
        text.TextStrokeColor3 = Color3.fromRGB(0, 51, 128)
        
        roleBackground.BackgroundColor3 = Config.sheriffColor
        roleLabel.TextColor3 = Color3.fromRGB(102, 178, 255)
        roleLabel.TextStrokeColor3 = Color3.fromRGB(0, 25, 102)
        
        highlight.FillColor = Config.sheriffColor
        highlight.OutlineColor3 = Color3.fromRGB(102, 153, 255)
        highlight.FillTransparency = 0.6
    elseif role == "Unknown" then
        roleLabel.Text = Config.showRoles and "❓ UNKNOWN" or ""
        text.TextColor3 = Color3.fromRGB(204, 204, 26)
        text.TextStrokeColor3 = Color3.fromRGB(102, 102, 0)
        
        roleBackground.BackgroundColor3 = Config.unknownColor
        roleLabel.TextColor3 = Color3.fromRGB(255, 255, 77)
        roleLabel.TextStrokeColor3 = Color3.fromRGB(77, 77, 0)
        
        highlight.FillColor = Config.unknownColor
        highlight.OutlineColor3 = Color3.fromRGB(255, 255, 77)
        highlight.FillTransparency = 0.7
    else
        roleLabel.Text = Config.showRoles and "👨 INNOCENT" or ""
        text.TextColor3 = Color3.fromRGB(230, 230, 230)
        text.TextStrokeColor3 = Color3.fromRGB(77, 77, 77)
        
        roleBackground.BackgroundColor3 = Config.innocentColor
        roleLabel.TextColor3 = Color3.fromRGB(204, 255, 204)
        roleLabel.TextStrokeColor3 = Color3.fromRGB(26, 102, 26)
        
        highlight.FillColor = Config.innocentColor
        highlight.OutlineColor3 = Color3.fromRGB(153, 255, 153)
        highlight.FillTransparency = 0.7
    end
    
    -- Configure highlight properties
    highlight.OutlineTransparency = 0.2
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    
    -- Set up the parent hierarchy
    text.Parent = esp
    roleBackground.Parent = esp
    roleLabel.Parent = roleBackground
    distance.Parent = esp
    esp.Parent = espFolder
    
    -- IMPORTANT: Make sure the highlight is properly parented to the character
    -- This is the key fix for the highlighting issue
    if player.Character then
        highlight.Parent = player.Character
        
        -- Add pulsing effect to important roles
        if role == "Murderer" or role == "Sheriff" then
            local tweenInfo = TweenInfo.new(
                0.8,
                Enum.EasingStyle.Sine,
                Enum.EasingDirection.InOut,
                -1,
                true,
                0
            )
            
            local transparencyTween = TweenService:Create(
                highlight, 
                tweenInfo,
                {FillTransparency = 0.3}
            )
            
            transparencyTween:Play()
        end
    end
    
    -- Store in cache
    espCache[player.UserId] = {
        esp = esp,
        highlight = highlight,
        role = role,
        distance = playerDistance
    }
    
    return esp, highlight
end

-- ESP Management functions
local function clearESP()
    -- Clear all ESP elements
    espFolder:ClearAllChildren()
    
    -- Remove all highlights from characters
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character then
            local highlight = player.Character:FindFirstChild("PlayerHighlight")
            if highlight then highlight:Destroy() end
            
            -- Also check for gun highlights
            local gunHighlight = player.Character:FindFirstChild("GunHighlight")
            if gunHighlight then gunHighlight:Destroy() end
        end
    end
    
    -- Check workspace for gun highlights
    for _, item in pairs(workspace:GetDescendants()) do
        if item:IsA("Highlight") and item.Name == "GunHighlight" then
            item:Destroy()
        end
    end
    
    espCache = {}
end

local function updatePlayerESP(player)
    if not Config.espEnabled or player == LocalPlayer or not isAlive(player) then return end
    
    local cache = espCache[player.UserId]
    local role = "Innocent"
    
    -- Determine player role
    if hasKnife(player) then
        role = "Murderer"
        murderer = player
    elseif hasGun(player) then
        role = "Sheriff"
        sheriff = player
    elseif murderer == nil and sheriff == nil then
        role = "Unknown"
    end
    
    -- Update or create ESP
    if cache then
        -- Update distance text
        local playerDistance = math.floor(getDistance(player))
        local distanceText = cache.esp:FindFirstChild("DistanceText")
        if distanceText then
            distanceText.Text = playerDistance .. " studs"
        end
        
        -- Only recreate ESP if role changed or player respawned
        if cache.role ~= role or not player.Character:FindFirstChild("PlayerHighlight") then
            createESP(player, role)
        end
    else
        createESP(player, role)
    end
end

local function performFullUpdate()
    if not Config.espEnabled then return end
    
    -- Reset role trackers
    murderer = nil
    sheriff = nil
    
    -- First pass to identify murderer and sheriff
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and isAlive(player) then
            if hasKnife(player) then
                murderer = player
            elseif hasGun(player) then
                sheriff = player
            end
        end
    end
    
    -- Second pass to update all ESPs with correct roles
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and isAlive(player) then
            updatePlayerESP(player)
        end
    end
    
    -- Handle dropped gun
    local droppedGun = findDroppedGun()
    if droppedGun then
        createGunESP(droppedGun)
    end
    
    lastFullUpdate = tick()
end

local function updateESP()
    if not Config.espEnabled then return end
    
    -- Perform incremental updates
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and isAlive(player) then
            -- In gun-only mode, only show murderer, sheriff, and gun
            if Config.gunOnlyMode then
                if player == murderer or player == sheriff then
                    updatePlayerESP(player)
                else
                    -- Remove ESP for innocents in gun-only mode
                    if espCache[player.UserId] then
                        if espCache[player.UserId].esp then
                            espCache[player.UserId].esp:Destroy()
                        end
                        if player.Character and espCache[player.UserId].highlight then
                            espCache[player.UserId].highlight:Destroy()
                        end
                        espCache[player.UserId] = nil
                    end
                end
            else
                updatePlayerESP(player)
            end
        end
    end
    
    -- Check if it's time for a full update
    if tick() - lastFullUpdate > Config.updateInterval then
        performFullUpdate()
    end
end

-- Notification system
local function showNotification(message, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "MM2 ESP",
            Text = message,
            Duration = duration or 2,
            Icon = "rbxassetid://6031071053"
        })
    end)
end

-- Toggle functions
local function toggleESP()
    Config.espEnabled = not Config.espEnabled
    
    if Config.espEnabled then
        showNotification("ESP: ON ✅", 2)
        performFullUpdate()
    else
        showNotification("ESP: OFF ❌", 2)
        clearESP()
    end
end

local function toggleGunOnlyMode()
    Config.gunOnlyMode = not Config.gunOnlyMode
    
    if Config.gunOnlyMode then
        showNotification("Gun-Only Mode: ON 🔫", 2)
    else
        showNotification("Gun-Only Mode: OFF 👥", 2)
    end
    
    if Config.espEnabled then
        performFullUpdate()
    end
end

local function toggleRoleDisplay()
    Config.showRoles = not Config.showRoles
    
    if Config.showRoles then
        showNotification("Role Display: ON 🏷️", 2)
    else
        showNotification("Role Display: OFF 🚫", 2)
    end
    
    if Config.espEnabled then
        performFullUpdate()
    end
end

-- Unload function
function unloadScript()
    Config.espEnabled = false
    clearESP()
    
    if espFolder then
        espFolder:Destroy()
    end
    
    for _, connection in ipairs(connections) do
        if connection then
            connection:Disconnect()
        end
    end
    
    table.clear(connections)
    
    -- Extra cleanup to ensure all highlights are removed
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character then
            for _, item in pairs(player.Character:GetChildren()) do
                if item:IsA("Highlight") then
                    item:Destroy()
                end
            end
        end
    end
    
    for _, item in pairs(workspace:GetDescendants()) do
        if item:IsA("Highlight") and (item.Name == "PlayerHighlight" or item.Name == "GunHighlight") then
            item:Destroy()
        end
    end
    
    showNotification("Script Successfully Unloaded! 👋", 3)
    
    Character = nil
    connections = nil
    espFolder = nil
    espCache = nil
    Config = nil
end

-- Setup connections
local function setupConnections()
    -- Update ESP on heartbeat (optimized to reduce performance impact)
    table.insert(connections, RunService.Heartbeat:Connect(function()
        if Config.espEnabled then
            updateESP()
        end
    end))
    
    -- Handle key inputs
    table.insert(connections, UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed then
            if input.KeyCode == Enum.KeyCode.L then
                toggleESP()
            elseif input.KeyCode == Enum.KeyCode.K then
                toggleGunOnlyMode()
            elseif input.KeyCode == Enum.KeyCode.J then
                toggleRoleDisplay()
            elseif input.KeyCode == Enum.KeyCode.End then
                unloadScript()
            end
        end
    end))
    
    -- Handle character respawns
    table.insert(connections, LocalPlayer.CharacterAdded:Connect(function(newCharacter)
        Character = newCharacter
        wait(1)
        if Config.espEnabled then
            performFullUpdate()
        end
    end))
    
    -- Handle player joining
    table.insert(connections, Players.PlayerAdded:Connect(function(player)
        wait(1)
        if Config.espEnabled then
            updatePlayerESP(player)
        end
    end))
    
    -- Handle player leaving
    table.insert(connections, Players.PlayerRemoving:Connect(function(player)
        if espCache[player.UserId] then
            if espCache[player.UserId].esp then
                espCache[player.UserId].esp:Destroy()
            end
            if espCache[player.UserId].highlight then
                espCache[player.UserId].highlight:Destroy()
            end
            espCache[player.UserId] = nil
        end
        
        -- If murderer or sheriff leaves, force a full update
        if player == murderer or player == sheriff then
            wait(0.5)
            performFullUpdate()
        end
    end))
    
    -- Handle character added for all players
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            table.insert(connections, player.CharacterAdded:Connect(function(character)
                wait(1)
                if Config.espEnabled then
                    updatePlayerESP(player)
                end
            end))
        end
    end
    
    -- Connect to new players' CharacterAdded event
    table.insert(connections, Players.PlayerAdded:Connect(function(player)
        table.insert(connections, player.CharacterAdded:Connect(function(character)
            wait(1)
            if Config.espEnabled then
                updatePlayerESP(player)
            end
        end))
    end))
end

-- Initialize the script
setupConnections()
showNotification("MM2 ESP Loaded! Controls:\nL = Toggle ESP\nK = Gun-Only Mode\nJ = Toggle Role Display\nEnd = Unload", 5)

-- Force initial update after a short delay to ensure everything is loaded
wait(1)
performFullUpdate()
