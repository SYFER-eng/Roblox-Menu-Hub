-- Number of parts per dog statue (adjust as needed)
local blockSize = 4
local spawnInterval = 1 -- Time interval between block spawns (in seconds)

-- Function to create a block at a given position
local function createBlock(position, size, color)
    local part = Instance.new("Part")
    part.Size = size  -- Set the block size
    part.Position = position  -- Set the position
    part.Anchored = true       -- Anchor the block so it doesn't fall
    part.Color = color or Color3.fromRGB(math.random(100, 255), math.random(100, 255), math.random(100, 255))  -- Random or provided color
    part.Parent = game.Workspace  -- Add to Workspace, so it appears for all players
end

-- Function to create the dog statue at the position of the player when the script starts
local function createDogStatue(player)
    -- Get the initial position of the player's HumanoidRootPart (position at script run)
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local initialPosition = player.Character.HumanoidRootPart.Position
        
        -- Create Dog Body (main body of the dog)
        createBlock(initialPosition + Vector3.new(0, 3, 0), Vector3.new(8, 4, 12), Color3.fromRGB(160, 82, 45))  -- Brown body
        createBlock(initialPosition + Vector3.new(0, 2, -6), Vector3.new(8, 4, 2), Color3.fromRGB(160, 82, 45))  -- Tail side block
        
        -- Create Dog Head (smaller block for the head)
        createBlock(initialPosition + Vector3.new(0, 7, 5), Vector3.new(6, 4, 6), Color3.fromRGB(160, 82, 45))  -- Brown head
        
        -- Create Dog Legs (4 blocks)
        createBlock(initialPosition + Vector3.new(3, 1, 3), Vector3.new(2, 6, 2), Color3.fromRGB(139, 69, 19))  -- Front right leg
        createBlock(initialPosition + Vector3.new(-3, 1, 3), Vector3.new(2, 6, 2), Color3.fromRGB(139, 69, 19))  -- Front left leg
        createBlock(initialPosition + Vector3.new(3, 1, -3), Vector3.new(2, 6, 2), Color3.fromRGB(139, 69, 19))  -- Back right leg
        createBlock(initialPosition + Vector3.new(-3, 1, -3), Vector3.new(2, 6, 2), Color3.fromRGB(139, 69, 19))  -- Back left leg
        
        -- Create Dog Tail (a wedge for a simple tail)
        createBlock(initialPosition + Vector3.new(0, 3, -8), Vector3.new(2, 2, 4), Color3.fromRGB(139, 69, 19))  -- Tail
        
        -- Create Dog Ears (using wedges to represent ears)
        createBlock(initialPosition + Vector3.new(2, 9, 7), Vector3.new(2, 2, 4), Color3.fromRGB(139, 69, 19))  -- Right ear
        createBlock(initialPosition + Vector3.new(-2, 9, 7), Vector3.new(2, 2, 4), Color3.fromRGB(139, 69, 19))  -- Left ear
        
        -- Create Dog Nose (using a small sphere)
        local nose = Instance.new("Part")
        nose.Shape = Enum.PartType.Ball
        nose.Size = Vector3.new(1, 1, 1)  -- Small sphere for the nose
        nose.Position = initialPosition + Vector3.new(0, 8, 9)  -- Nose position on the head
        nose.Anchored = true
        nose.Color = Color3.fromRGB(0, 0, 0)  -- Black nose
        nose.Parent = game.Workspace
        
        -- Create Dog Eyes (two small spheres for the eyes)
        local leftEye = Instance.new("Part")
        leftEye.Shape = Enum.PartType.Ball
        leftEye.Size = Vector3.new(1, 1, 1)  -- Small sphere for left eye
        leftEye.Position = initialPosition + Vector3.new(-2, 9, 7)  -- Position for the left eye
        leftEye.Anchored = true
        leftEye.Color = Color3.fromRGB(0, 0, 0)  -- Black color for eyes
        leftEye.Parent = game.Workspace

        local rightEye = Instance.new("Part")
        rightEye.Shape = Enum.PartType.Ball
        rightEye.Size = Vector3.new(1, 1, 1)  -- Small sphere for right eye
        rightEye.Position = initialPosition + Vector3.new(2, 9, 7)  -- Position for the right eye
        rightEye.Anchored = true
        rightEye.Color = Color3.fromRGB(0, 0, 0)  -- Black color for eyes
        rightEye.Parent = game.Workspace
        
        -- Debugging: Output part creation
        print("Dog statue created at: " .. tostring(initialPosition))
    else
        warn(player.Name .. " does not have a valid character or HumanoidRootPart!")
    end
end

-- Function to start the statue creation process
local function startStatueCreation()
    -- Find the player who will spawn the statue
    local player = game.Players.LocalPlayer  -- Adjust this line if you're running this on the server side

    -- Create the dog statue at the player's position
    createDogStatue(player)
end

-- Start the statue creation when the script is run
startStatueCreation()
