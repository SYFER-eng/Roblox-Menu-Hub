-- Place blocks when you click and clear them when you press the "End" key

local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local blocks = {}

-- Function to place a block at the mouse position
function placeBlock(position)
    local block = Instance.new("Part")
    block.Size = Vector3.new(4, 1, 4)
    block.Position = position
    block.Anchored = true
    block.Color = Color3.fromRGB(255, 0, 0)  -- Red block color
    block.Parent = workspace
    
    table.insert(blocks, block)  -- Keep track of placed blocks
end

-- Connect mouse click event
mouse.Button1Down:Connect(function()
    local mousePosition = mouse.Hit.p
    placeBlock(mousePosition)
end)

-- Clear blocks when "End" key is pressed
local userInputService = game:GetService("UserInputService")

userInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end  -- Ignore if the game already processed the input
    
    if input.KeyCode == Enum.KeyCode.End then
        -- Destroy all placed blocks
        for _, block in pairs(blocks) do
            block:Destroy()
        end
        blocks = {}  -- Clear the block list
    end
end)
