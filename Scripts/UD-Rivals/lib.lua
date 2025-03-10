-- Create ScreenGui for the menu
local MenuGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local ToggleList = Instance.new("Frame")
local UIListLayout = Instance.new("UIListLayout")

-- Menu styling
MenuGui.Name = "RivalsMenu"
MenuGui.Parent = CoreGui
MenuGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

MainFrame.Name = "MainFrame"
MainFrame.Parent = MenuGui
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderColor3 = Color3.fromRGB(255, 0, 255)
MainFrame.Position = UDim2.new(0.8, 0, 0.3, 0)
MainFrame.Size = UDim2.new(0, 200, 0, 300)
MainFrame.Active = true
MainFrame.Draggable = true

Title.Name = "Title"
Title.Parent = MainFrame
Title.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Font = Enum.Font.SourceSansBold
Title.Text = "Rivals Menu"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16

ToggleList.Name = "ToggleList"
ToggleList.Parent = MainFrame
ToggleList.BackgroundTransparency = 1
ToggleList.Position = UDim2.new(0, 0, 0, 35)
ToggleList.Size = UDim2.new(1, 0, 1, -35)

UIListLayout.Parent = ToggleList
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 5)

-- Function to create toggle buttons
local function CreateToggle(name, default)
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Name = name
    ToggleButton.Parent = ToggleList
    ToggleButton.BackgroundColor3 = default and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    ToggleButton.Size = UDim2.new(0.9, 0, 0, 25)
    ToggleButton.Position = UDim2.new(0.05, 0, 0, 0)
    ToggleButton.Font = Enum.Font.SourceSans
    ToggleButton.Text = name
    ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleButton.TextSize = 14
    
    ToggleButton.MouseButton1Click:Connect(function()
        Toggles[name] = not Toggles[name]
        ToggleButton.BackgroundColor3 = Toggles[name] and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    end)
end

-- Create toggles for each feature
CreateToggle("ESP", Toggles.ESP)
CreateToggle("Aimbot", Toggles.Aimbot)
CreateToggle("Boxes", Toggles.Boxes)
CreateToggle("Names", Toggles.Names)
CreateToggle("Distance", Toggles.Distance)
CreateToggle("Snaplines", Toggles.Snaplines)
CreateToggle("Health", Toggles.Health)

-- Add keybind display
local KeybindInfo = Instance.new("TextLabel")
KeybindInfo.Name = "KeybindInfo"
KeybindInfo.Parent = MainFrame
KeybindInfo.BackgroundTransparency = 1
KeybindInfo.Position = UDim2.new(0, 0, 1, 5)
KeybindInfo.Size = UDim2.new(1, 0, 0, 60)
KeybindInfo.Font = Enum.Font.SourceSans
KeybindInfo.Text = "Right Click - Lock Target\nEnd - Cleanup\nNumpad 1-7 - Toggle Features"
KeybindInfo.TextColor3 = Color3.fromRGB(255, 255, 255)
KeybindInfo.TextSize = 12
