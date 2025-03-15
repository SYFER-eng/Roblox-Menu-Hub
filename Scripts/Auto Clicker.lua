local autoClickEnabled = false
local UIS = game:GetService("UserInputService")
local clickDelay = 0.001 -- 1ms delay (though actual performance may vary)

-- Function to simulate mouse click
local function click()
    -- Different methods to click based on executor capabilities
    if mouse1click then
        mouse1click()
    elseif mouse1press and mouse1release then
        mouse1press()
        mouse1release()
    else
        -- Fallback method
        game:GetService("VirtualUser"):Button1Down(Vector2.new(0, 0))
        game:GetService("VirtualUser"):Button1Up(Vector2.new(0, 0))
    end
end

-- Toggle function
local function toggleAutoClick()
    autoClickEnabled = not autoClickEnabled
    
    if autoClickEnabled then
        print("Auto Clicker: ON")
        
        -- Start the clicking loop
        spawn(function()
            while autoClickEnabled do
                click()
                wait(clickDelay)
            end
        end)
    else
        print("Auto Clicker: OFF")
    end
end

-- Listen for P key press
UIS.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.P then
        toggleAutoClick()
    end
end)

-- Notification to user
local function notify(text)
    if game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Auto Clicker",
        Text = text,
        Duration = 2
    }) then
        -- Notification sent successfully
    else
        -- Fallback to print if notification fails
        print("Auto Clicker: " .. text)
    end
end

-- Show initial message
notify("Press P to toggle auto clicker")
