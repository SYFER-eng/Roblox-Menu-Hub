local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local camera = workspace.CurrentCamera
local enabled = false
local espEnabled = false
local connections = {}

local espFolder = Instance.new("Folder")
espFolder.Name = "ESP"
espFolder.Parent = game.CoreGui

local function createGunESP(gun)
    local existingESP = espFolder:FindFirstChild("Gun_ESP")
    if existingESP then existingESP:Destroy() end
    
    local esp = Instance.new("BillboardGui")
    local text = Instance.new("TextLabel")
    local highlight = Instance.new("Highlight")
    
    esp.Name = "Gun_ESP"
    esp.AlwaysOnTop = true
    esp.Size = UDim2.new(0, 200, 0, 50)
    esp.StudsOffset = Vector3.new(0, 0, 0)
    esp.Adornee = gun
    esp.MaxDistance = 500
    
    text.Name = "GunText"
    text.BackgroundTransparency = 1
    text.Size = UDim2.new(1, 0, 1, 0)
    text.Font = Enum.Font.SourceSansBold
    text.TextSize = 20
    text.TextStrokeTransparency = 0
    text.Text = "Gun"
    text.TextColor3 = Color3.new(0, 0, 1)
    text.TextStrokeColor3 = Color3.new(0, 0, 0.5)
    
    highlight.FillColor = Color3.new(0, 0, 1)
    highlight.OutlineTransparency = 0.5
    highlight.FillTransparency = 0.5
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    
    text.Parent = esp
    esp.Parent = espFolder
    highlight.Parent = gun
    
    return esp, highlight
end

local function findDroppedGun()
    for _, item in ipairs(workspace:GetChildren()) do
        if item.Name == "Gun" then
            return item
        end
    end
    return nil
end

local function setupSilentAim()
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local args = {...}
        local method = getnamecallmethod()
        
        if method == "FireServer" and self.Name == "ShootGun" then
            local target = getClosestPlayerToCursor()
            if target and target.Character and target.Character:FindFirstChild("Head") then
                args[1] = target.Character.Head.Position
            end
        end
        
        return oldNamecall(self, unpack(args))
    end)
end

local function showNotification(message, duration)
    StarterGui:SetCore("SendNotification", {
        Title = "MM2 Script",
        Text = message,
        Duration = duration or 2,
        Icon = "rbxassetid://6031071053"
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

local function getClosestPlayerToCursor()
    local murderer = getMurderer()
    local sheriff = getSheriff()
    local target = murderer or sheriff
    
    if target and target.Character and target.Character:FindFirstChild("Head") then
        return target
    end
    return nil
end

local function smoothLookAt(target)
    if not target or not target.Character or not Character or not Character.PrimaryPart then return end
    
    local targetHead = target.Character:FindFirstChild("Head")
    if not targetHead then return end
    
    local targetPos = targetHead.Position
    local characterPos = Character.PrimaryPart.Position
    
    local newCFrame = CFrame.new(
        characterPos,
        Vector3.new(targetPos.X, characterPos.Y, targetPos.Z)
    )
    
    Character:SetPrimaryPartCFrame(newCFrame)
end

local function attack()
    local tool = Character:FindFirstChildOfClass("Tool")
    if tool then
        tool:Activate()
    end
end

local function createESP(player, role)
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
    elseif role == "Sheriff" then
        text.TextColor3 = Color3.new(0, 0, 1)
        highlight.FillColor = Color3.new(0, 0, 1)
        text.TextStrokeColor3 = Color3.new(0, 0, 0.5)
    else
        text.TextColor3 = Color3.new(1, 1, 1)
        highlight.FillColor = Color3.new(1, 1, 1)
        text.TextStrokeColor3 = Color3.new(0.5, 0.5, 0.5)
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
    local droppedGun = findDroppedGun()
    
    if LocalPlayer == murderer then
        -- Murderer view
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player ~= sheriff then
                createESP(player, "Player")
            end
        end
        if sheriff then
            createESP(sheriff, "Sheriff")
        end
        if droppedGun then
            createGunESP(droppedGun)
        end
    elseif LocalPlayer == sheriff then
        -- Sheriff view
        if murderer then
            createESP(murderer, "Murderer")
        end
    else
        -- Innocent view
        if murderer then
            createESP(murderer, "Murderer")
        end
        if sheriff then
            createESP(sheriff, "Sheriff")
        end
    end
end

local function teleportBehind()
    if not Character or not Character.PrimaryPart then return end
    
    local murderer = getMurderer()
    local sheriff = getSheriff()
    
    local target = murderer or sheriff
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        local targetRoot = target.Character.HumanoidRootPart
        local targetCFrame = targetRoot.CFrame
        
        local behindPosition = targetCFrame * CFrame.new(0, 0, 3)
        Character.PrimaryPart.CFrame = behindPosition
        smoothLookAt(target)
        attack()
        
        task.wait(0.1)
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
    table.insert(connections, RunService.Heartbeat:Connect(function()
        if enabled then
            local target = getClosestPlayerToCursor()
            if target then
                teleportBehind()
            end
        end
        if espEnabled then
            updateESP()
        end
    end))

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
setupSilentAim()
showNotification("Script Loaded! P = Target, L = ESP, End = Unload", 3)
