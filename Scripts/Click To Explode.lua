local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local blocks = {}


function placeBlock(position)
    local block = Instance.new("Part")
    block.Size = Vector3.new(4, 1, 4)
    block.Position = position
    block.Anchored = true
    block.Color = Color3.fromRGB(255, 0, 0)
    block.Parent = workspace
    

    blowUpBlock(block)


    table.insert(blocks, block)
end


function blowUpBlock(block)

    local explosion = Instance.new("Explosion")
    explosion.Position = block.Position
    explosion.BlastRadius = 15
    explosion.BlastPressure = 1000000
    explosion.Hit:Connect(function(hit)

        if hit and hit:IsA("Part") and hit.Parent and hit ~= block then

            local newBlock = Instance.new("Part")
            newBlock.Size = hit.Size
            newBlock.Position = hit.Position
            newBlock.Anchored = true
            newBlock.Color = Color3.fromRGB(255, 0, 0)
            newBlock.Parent = workspace
            

            hit:Destroy()
        end
    end)
    explosion.Parent = workspace


    block:Destroy()


    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://3995434918"
    sound.Position = block.Position
    sound.Parent = block
    sound:Play()
end


local userInputService = game:GetService("UserInputService")

userInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.End then

        for _, block in pairs(blocks) do
            block:Destroy()
        end
        blocks = {}
    end
end)


mouse.Button1Down:Connect(function()
    local mousePosition = mouse.Hit.p
    placeBlock(mousePosition)
end)
