local UserInputService = game:GetService("UserInputService")
local ScriptHub = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local ScrollingFrame = Instance.new("ScrollingFrame")
local UIListLayout = Instance.new("UIListLayout")
local InfoText = Instance.new("TextLabel")

ScriptHub.Name = "ScriptHub"
ScriptHub.Parent = game:GetService("CoreGui")
ScriptHub.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScriptHub.DisplayOrder = 999999999

MainFrame.Name = "MainFrame"
MainFrame.Parent = ScriptHub
MainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
MainFrame.Position = UDim2.new(0.2, 0, 0.2, 0)
MainFrame.Size = UDim2.new(0, 400, 0, 500)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ZIndex = 999999999

local MainStroke = Instance.new("UIStroke")
MainStroke.Parent = MainFrame
MainStroke.Color = Color3.fromRGB(147, 0, 255)
MainStroke.Thickness = 1

Title.Name = "Title"
Title.Parent = MainFrame
Title.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Title.Size = UDim2.new(1, 0, 0, 45)
Title.Text = "✦ Script Hub ✦"
Title.TextColor3 = Color3.fromRGB(147, 0, 255)
Title.TextSize = 28
Title.Font = Enum.Font.GothamBold
Title.ZIndex = 999999999

local TitleStroke = Instance.new("UIStroke")
TitleStroke.Parent = Title
TitleStroke.Color = Color3.fromRGB(147, 0, 255)
TitleStroke.Thickness = 1

ScrollingFrame.Parent = MainFrame
ScrollingFrame.BackgroundTransparency = 1
ScrollingFrame.Position = UDim2.new(0, 0, 0.1, 0)
ScrollingFrame.Size = UDim2.new(1, 0, 0.9, 0)
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 2, 0)
ScrollingFrame.ScrollBarThickness = 6
ScrollingFrame.ZIndex = 999999999

InfoText.Name = "InfoText"
InfoText.Parent = MainFrame
InfoText.BackgroundTransparency = 1
InfoText.Position = UDim2.new(0, 0, 0.95, 0)
InfoText.Size = UDim2.new(1, 0, 0.05, 0)
InfoText.Text = "Press PgDn/Page Down To Hide The Menu"
InfoText.TextColor3 = Color3.fromRGB(147, 0, 255)
InfoText.TextSize = 16
InfoText.Font = Enum.Font.GothamSemibold
InfoText.ZIndex = 999999999

UIListLayout.Parent = ScrollingFrame
UIListLayout.Padding = UDim.new(0, 12)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local function CreateScriptButton(name, scriptUrl)
    local button = Instance.new("TextButton")
    button.Name = name
    button.Parent = ScrollingFrame
    button.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    button.Size = UDim2.new(0.9, 0, 0, 60)
    button.Text = name
    button.TextColor3 = Color3.fromRGB(147, 0, 255)
    button.TextSize = 22
    button.Font = Enum.Font.GothamSemibold
    button.ZIndex = 999999999
    
    local buttonStroke = Instance.new("UIStroke")
    buttonStroke.Parent = button
    buttonStroke.Color = Color3.fromRGB(147, 0, 255)
    buttonStroke.Thickness = 1.5
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.Parent = button
    buttonCorner.CornerRadius = UDim.new(0, 10)
    
    local textStroke = Instance.new("UIStroke")
    textStroke.Parent = button
    textStroke.Color = Color3.fromRGB(147, 0, 255)
    textStroke.Thickness = 0.8
    
    button.MouseEnter:Connect(function()
        game:GetService("TweenService"):Create(button, TweenInfo.new(0.3), {
            BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        }):Play()
        game:GetService("TweenService"):Create(buttonStroke, TweenInfo.new(0.3), {
            Thickness = 2
        }):Play()
    end)
    
    button.MouseLeave:Connect(function()
        game:GetService("TweenService"):Create(button, TweenInfo.new(0.3), {
            BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        }):Play()
        game:GetService("TweenService"):Create(buttonStroke, TweenInfo.new(0.3), {
            Thickness = 1
        }):Play()
    end)
    
    button.MouseButton1Click:Connect(function()
        loadstring(game:HttpGet(scriptUrl))()
    end)
end

CreateScriptButton("✧ Ạı̇ṃbọṭ", "https://raw.githubusercontent.com/SYFER-eng/Roblox-Menu-Hub/refs/heads/main/Scripts/AimMenu.lua")
CreateScriptButton("✧ Ṣрẹẹḍ", "https://raw.githubusercontent.com/SYFER-eng/Roblox-Menu-Hub/refs/heads/main/Scripts/Roblox-Speed-Hack.lua")
CreateScriptButton("✧ Fḷỵ", "https://raw.githubusercontent.com/SYFER-eng/Roblox-Menu-Hub/refs/heads/main/Scripts/Fly-Hack.lua")
CreateScriptButton("✧ Ṭẹḷọрọṛṭ", "https://raw.githubusercontent.com/SYFER-eng/Roblox-Menu-Hub/refs/heads/main/Scripts/Tp-To-A-Player.lua")

local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Parent = MainFrame
CloseButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
CloseButton.Position = UDim2.new(0.93, 0, 0, 0)
CloseButton.Size = UDim2.new(0.07, 0, 0.09, 0)
CloseButton.Text = "×"
CloseButton.TextColor3 = Color3.fromRGB(147, 0, 255)
CloseButton.TextSize = 30
CloseButton.Font = Enum.Font.GothamBold
CloseButton.ZIndex = 999999999

local closeStroke = Instance.new("UIStroke")
closeStroke.Parent = CloseButton
closeStroke.Color = Color3.fromRGB(147, 0, 255)
closeStroke.Thickness = 1

local closeCorner = Instance.new("UICorner")
closeCorner.Parent = CloseButton
closeCorner.CornerRadius = UDim.new(0, 8)

CloseButton.MouseEnter:Connect(function()
    game:GetService("TweenService"):Create(CloseButton, TweenInfo.new(0.3), {
        BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    }):Play()
end)

CloseButton.MouseLeave:Connect(function()
    game:GetService("TweenService"):Create(CloseButton, TweenInfo.new(0.3), {
        BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    }):Play()
end)

CloseButton.MouseButton1Click:Connect(function()
    ScriptHub:Destroy()
end)

-- Toggle visibility with Page Down key
local visible = true

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.PageDown and not gameProcessed then
        visible = not visible
        MainFrame.Visible = visible
    end
end)
