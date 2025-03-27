local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local enabled = false
local espEnabled = false
local connections = {}

-- Create ESP folder in CoreGui
local espFolder = Instance.new("Folder")
espFolder.Name = "ESP"
espFolder.Parent = game.CoreGui

local function showNotification(message, duration)
    StarterGui:SetCore("SendNotification", {
        Title = "MM2 Script",
        Text = message,
        Duration = duration or 2,
        Icon = "rbxassetid://83497866000186"
    })
end

local function getMurderer()
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character and player.Backpack then
            if player.Character:FindFirstChild("Knife") or player.Backpack:FindFirstChild("Knife") then
                return player
            end
        end
    end
    return nil
end

local function getSheriff()
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character and player.Backpack then
            if player.Character:FindFirstChild("Gun") or player.Backpack:FindFirstChild("Gun") then
                return player
            end
        end
    end
    return nil
end

local function attack()
    local tool = Character:FindFirstChildOfClass("Tool")
    if tool then
        tool:Activate()
    end
end

local function facePlayer(targetCFrame)
    if Character and Character.PrimaryPart then
        Character:SetPrimaryPartCFrame(CFrame.new(Character.PrimaryPart.Position, Vector3.new(targetCFrame.X, Character.PrimaryPart.Position.Y, targetCFrame.Z)))
    end
end

local function createESP(player, role)
    -- Remove existing ESP for this player
    local existingESP = espFolder:FindFirstChild(player.Name .. "_ESP")
    if existingESP then existingESP:Destroy() end
    
    if not player.Character or not player.Character:FindFirstChild("Head") then return end
    
    local esp = Instance.new("BillboardGui")
    local text = Instance.new("TextLabel")
    local highlight = Instance.new("Highlight")
    
    esp.Name = player.Name .. "_ESP"
    esp.AlwaysOnTop = true
    esp.Size = UDim2.new(0, 200, 0, 50)
    esp.StudsOffset = Vector3.new(0, 2, 0)
    esp.Adornee = player.Character.Head
    esp.MaxDistance = 500
    
    text.Name = "RoleText"
    text.BackgroundTransparency = 1
    text.Size = UDim2.new(1, 0, 1, 0)
    text.Font = Enum.Font.SourceSansBold
    text.TextSize = 20
    text.TextStrokeTransparency = 0
    text.Text = player.Name .. "\n[" .. role .. "]"
    
    if role == "Murderer" then
        text.TextColor3 = Color3.new(1, 0, 0)
        highlight.FillColor = Color3.new(1, 0, 0)
        text.TextStrokeColor3 = Color3.new(0.5, 0, 0)
    else
        text.TextColor3 = Color3.new(0, 0, 1)
        highlight.FillColor = Color3.new(0, 0, 1)
        text.TextStrokeColor3 = Color3.new(0, 0, 0.5)
    end
    
    highlight.OutlineTransparency = 0.5
    highlight.FillTransparency = 0.5
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    
    text.Parent = esp
    esp.Parent = espFolder
    highlight.Parent = player.Character
    
    return esp, highlight
end

local function clearESP()
    espFolder:ClearAllChildren()
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character then
            local highlight = player.Character:FindFirstChild("Highlight")
            if highlight then highlight:Destroy() end
        end
    end
end

local function updateESP()
    if not espEnabled then return end
    clearESP()
    
    local murderer = getMurderer()
    local sheriff = getSheriff()
    
    if murderer then
        createESP(murderer, "Murderer")
    end
    if sheriff then
        createESP(sheriff, "Sheriff")
    end
end

local function teleportBehind()
    if not Character or not Character.PrimaryPart then return end
    
    local murderer = getMurderer()
    local sheriff = getSheriff()
    
    local target = murderer or sheriff
    if target and target.Character and target.Character:FindFirstChild("Head") then
        local targetHead = target.Character.Head
        local targetCFrame = targetHead.CFrame
        
        local humanoid = Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.PlatformStand = true
        end
        
        local rootPart = Character.PrimaryPart
        rootPart.Velocity = Vector3.new(0, 0, 0)
        rootPart.RotVelocity = Vector3.new(0, 0, 0)
        
        Character:SetPrimaryPartCFrame(
            targetCFrame * 
            CFrame.new(0, 0, 2.5) * 
            CFrame.new(0, 0.5, 0)
        )
        
        facePlayer(targetCFrame.Position)
        attack()
        
        if humanoid then
            humanoid.PlatformStand = false
        end
    end
end

local function toggleESP()
    espEnabled = not espEnabled
    if espEnabled then
        showNotification("ESP: ON ✅", 2)
        updateESP()
    else
        showNotification("ESP: OFF ❌", 2)
        clearESP()
    end
end

local function toggleTP()
    enabled = not enabled
    if enabled then
        showNotification("Target Script: ON ✅", 2)
    else
        showNotification("Target Script: OFF ❌", 2)
    end
end

local function setupConnections()
    -- ESP Update Loop
    table.insert(connections, RunService.RenderStepped:Connect(function()
        if espEnabled then
            updateESP()
        end
    end))
    
    -- Teleport Loop
    table.insert(connections, RunService.Heartbeat:Connect(function()
        if enabled then
            teleportBehind()
            wait(0.5)
        end
    end))

    -- Key Bindings
    table.insert(connections, UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed then
            if input.KeyCode == Enum.KeyCode.P then
                toggleTP()
            elseif input.KeyCode == Enum.KeyCode.L then
                toggleESP()
            elseif input.KeyCode == Enum.KeyCode.End then
                unloadScript()
            end
        end
    end))

    -- Character Added
    table.insert(connections, LocalPlayer.CharacterAdded:Connect(function(newCharacter)
        Character = newCharacter
        wait(1)
        if espEnabled then
            updateESP()
        end
    end))
end

function unloadScript()
    enabled = false
    espEnabled = false
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
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character then
            local highlight = player.Character:FindFirstChild("Highlight")
            if highlight then
                highlight:Destroy()
            end
        end
    end
    
    showNotification("Script Successfully Unloaded! 👋", 3)
    
    Character = nil
    connections = nil
    espFolder = nil
end

setupConnections()
showNotification("Script Loaded! P = Target, L = ESP, End = Unload", 3)
