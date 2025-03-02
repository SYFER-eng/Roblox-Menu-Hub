-- Function to create a block at a given position
local function createBlock(position, size, color, material)
    local part = Instance.new("Part")
    part.Size = size
    part.Position = position
    part.Anchored = true
    part.Color = color or Color3.fromRGB(math.random(100, 255), math.random(100, 255), math.random(100, 255))
    part.Material = material or Enum.Material.Plastic
    part.Parent = game.Workspace
    return part
end

-- Function to create the dog statue at the position of the player when the script starts
local function createDogStatue(player)
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local initialPosition = player.Character.HumanoidRootPart.Position
        
        -- Create Dog Body (main body of the dog)
        local body = createBlock(initialPosition + Vector3.new(0, 3, 0), Vector3.new(8, 4, 12), Color3.fromRGB(160, 82, 45), Enum.Material.Fabric)
        
        -- Create Dog Head (using blocks for a more detailed shape)
        local head = createBlock(initialPosition + Vector3.new(0, 7, 5), Vector3.new(6, 4, 6), Color3.fromRGB(160, 82, 45), Enum.Material.Fabric)
        
        -- Create Dog Snout (a smaller block for the snout)
        local snout = createBlock(initialPosition + Vector3.new(0, 7, 8), Vector3.new(4, 2, 4), Color3.fromRGB(160, 82, 45), Enum.Material.Fabric)
        
        -- Create Dog Legs (4 blocks)
        local frontRightLeg = createBlock(initialPosition + Vector3.new(3, 1, 3), Vector3.new(2, 6, 2), Color3.fromRGB(139, 69, 19), Enum.Material.Fabric)
        local frontLeftLeg = createBlock(initialPosition + Vector3.new(-3, 1, 3), Vector3.new(2, 6, 2), Color3.fromRGB(139, 69, 19), Enum.Material.Fabric)
        local backRightLeg = createBlock(initialPosition + Vector3.new(3, 1, -3), Vector3.new(2, 6, 2), Color3.fromRGB(139, 69, 19), Enum.Material.Fabric)
        local backLeftLeg = createBlock(initialPosition + Vector3.new(-3, 1, -3), Vector3.new(2, 6, 2), Color3.fromRGB(139, 69, 19), Enum.Material.Fabric)
        
        -- Create Dog Tail (a thin block for the tail)
        local tail = createBlock(initialPosition + Vector3.new(0, 3, -8), Vector3.new(2, 2, 4), Color3.fromRGB(139, 69, 19), Enum.Material.Fabric)
        
        -- Create Dog Ears (using thin blocks for ears)
        local rightEar = createBlock(initialPosition + Vector3.new(2, 9, 7), Vector3.new(2, 2, 4), Color3.fromRGB(139, 69, 19), Enum.Material.Fabric)
        local leftEar = createBlock(initialPosition + Vector3.new(-2, 9, 7), Vector3.new(2, 2, 4), Color3.fromRGB(139, 69, 19), Enum.Material.Fabric)
        
        -- Create Dog Nose (a small block for the nose)
        local nose = createBlock(initialPosition + Vector3.new(0, 8, 9), Vector3.new(1, 1, 1), Color3.fromRGB(0, 0, 0), Enum.Material.Plastic)
        
        -- Create Dog Eyes (two small blocks for the eyes)
        local leftEye = createBlock(initialPosition + Vector3.new(-2, 9, 7), Vector3.new(1, 1, 1), Color3.fromRGB(0, 0, 0), Enum.Material.Plastic)
        local rightEye = createBlock(initialPosition + Vector3.new(2, 9, 7), Vector3.new(1, 1, 1), Color3.fromRGB(0, 0, 0), Enum.Material.Plastic)
        
        -- Debugging: Output part creation
        print("Block-based dog statue created at: " .. tostring(initialPosition))
    else
        warn(player.Name .. " does not have a valid character or HumanoidRootPart!")
    end
end

-- Function to start the statue creation process
local function startStatueCreation()
    local player = game.Players.LocalPlayer
    createDogStatue(player)
end

-- Start the statue creation when the script is run
startStatueCreation()
