local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local blocks = {}

local hoverDistance = 10 -- Radius of the base of the witch's hat
local hoverHeight = 5 -- Height of the witch's hat
local blockCount = 500000000000000 -- Number of blocks to form the witch's hat
local blockSize = Vector3.new(2, 1, 2) -- Size of each block
local hoverSpeed = 1 -- Speed of hovering (rotate speed)

local launchStrength = 100 -- Base strength of the launch (horizontal force)
local launchVerticalStrength = 75 -- Strength applied to the vertical direction (optional)

-- Function to place blocks in a witch's hat shape
function placeWitchesHat()
    -- Clear previous blocks if any
    for _, block in pairs(blocks) do
        block:Destroy()
    end
    blocks = {} -- Reset block list

    -- Loop to create blocks in a cone shape (witch's hat)
    for i = 1, blockCount do
        local block = Instance.new("Part")
        block.Size = blockSize
        block.Color = Color3.fromRGB(255, 0, 0)  -- Red color for the block
        block.Anchored = true
        block.CanCollide = false  -- Disable collision for smooth movement
        block.Parent = workspace

        -- Calculate position in a cone shape
        local angle = (i / blockCount) * math.pi * 2 -- Spread the blocks evenly around the cone
        local radius = hoverDistance * (1 - (i / blockCount)) -- Decrease the radius as we go up the cone
        local xOffset = math.cos(angle) * radius
        local zOffset = math.sin(angle) * radius
        local yOffset = hoverHeight - (i / blockCount) * hoverHeight -- Decrease y to form the hat's tip

        local position = player.Character.HumanoidRootPart.Position + Vector3.new(xOffset, yOffset, zOffset)

        block.Position = position

        -- Make the block hover in a circular pattern around the player
        hoverBlock(block)

        -- Keep track of placed blocks
        table.insert(blocks, block)
    end
end

-- Function to make the block hover in a circular pattern
function hoverBlock(block)
    local runService = game:GetService("RunService")
    local angle = math.random(1, 360) -- Random starting angle for circular movement
    local startTime = tick()  -- Store the initial time for smoother movement

    -- Use RunService.Heartbeat only once to avoid memory leaks
    runService.Heartbeat:Connect(function()
        local elapsed = tick() - startTime  -- Track elapsed time for smooth rotation
        angle = angle + hoverSpeed * elapsed  -- Adjust speed based on time to keep it consistent

        if angle >= 360 then
            angle = angle - 360
        end

        -- Calculate the new position based on the angle
        local xOffset = math.cos(math.rad(angle)) * hoverDistance
        local zOffset = math.sin(math.rad(angle)) * hoverDistance
        local newPosition = player.Character.HumanoidRootPart.Position + Vector3.new(xOffset, hoverHeight, zOffset)

        -- Update the block position smoothly
        block.Position = newPosition
    end)
end

-- Function to launch a player when clicked
function launchPlayer(targetPlayer)
    local character = targetPlayer.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        local humanoidRootPart = character.HumanoidRootPart

        -- Calculate direction from you to the clicked player
        local direction = (humanoidRootPart.Position - player.Character.HumanoidRootPart.Position).unit
        
        -- Add a vertical component for more dynamic launch
        local launchDirection = direction * launchStrength
        launchDirection = Vector3.new(launchDirection.X, launchDirection.Y + launchVerticalStrength, launchDirection.Z)

        -- Create a BodyVelocity to apply the launch force
        local bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.MaxForce = Vector3.new(5000, 5000, 5000)  -- Maximum force in all directions
        bodyVelocity.Velocity = launchDirection
        bodyVelocity.Parent = humanoidRootPart

        -- Remove the force after a short time to avoid continuous movement
        game.Debris:AddItem(bodyVelocity, 0.1)  -- Removes the BodyVelocity after 0.1 seconds
    end
end

-- Event when a key is pressed to spawn the witch's hat
local userInputService = game:GetService("UserInputService")

userInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end  -- Ignore if the game already processed the input

    -- Spawn blocks in a witch's hat shape when "C" key is pressed
    if input.KeyCode == Enum.KeyCode.C then
        placeWitchesHat()
    end
end)

-- Event when you click on a player to launch them
mouse.Button1Down:Connect(function()
    local target = mouse.Target
    if target and target.Parent and target.Parent:FindFirstChild("Humanoid") then
        local targetPlayer = game.Players:GetPlayerFromCharacter(target.Parent)
        if targetPlayer then
            launchPlayer(targetPlayer)
        end
    end
end)
