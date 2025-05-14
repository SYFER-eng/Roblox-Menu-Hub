-- UI Library Module
-- Provides functions for creating UI elements

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local UILibrary = {}
local Config = nil
local GuiObjects = {}

-- Initialize function
function UILibrary.Initialize(ConfigModule)
    Config = ConfigModule
end

-- Helper Functions
function UILibrary.Create(class, properties)
    local instance = Instance.new(class)
    
    for property, value in pairs(properties or {}) do
        if property ~= "Parent" then -- Set parent last
            instance[property] = value
        end
    end
    
    if properties.Parent then
        instance.Parent = properties.Parent
    end
    
    return instance
end

function UILibrary.Tween(instance, properties, duration, style, dir)
    if not Config.UI.Animation.Enabled then
        for prop, value in pairs(properties) do
            instance[prop] = value
        end
        return
    end
    
    duration = duration or Config.UI.Animation.Speed
    style = style or Enum.EasingStyle.Quad
    dir = dir or Enum.EasingDirection.Out
    
    local info = TweenInfo.new(duration, style, dir)
    local tween = TweenService:Create(instance, info, properties)
    tween:Play()
    return tween
end

function UILibrary.CreateShadow(frame, transparency, distance)
    transparency = transparency or 0.7
    distance = distance or 4
    
    local shadow = UILibrary.Create("Frame", {
        Name = frame.Name .. "Shadow",
        Parent = frame.Parent,
        ZIndex = frame.ZIndex - 1,
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = transparency,
        Position = UDim2.new(
            frame.Position.X.Scale, frame.Position.X.Offset + distance,
            frame.Position.Y.Scale, frame.Position.Y.Offset + distance
        ),
        Size = frame.Size
    })
    
    UILibrary.Create("UICorner", {
        Parent = shadow,
        CornerRadius = frame:FindFirstChild("UICorner") and 
                       frame.UICorner.CornerRadius or
                       UDim.new(0, 0)
    })
    
    return shadow
end

-- UI Components
function UILibrary.CreateWindow(title, size)
    -- Check if ScreenGui already exists and remove it
    local GuiName = "AimbotESPMenu_" .. HttpService:GenerateGUID(false):sub(1, 8)
    
    pcall(function()
        if CoreGui:FindFirstChild(GuiName) then
            CoreGui[GuiName]:Destroy()
        end
    end)
    
    -- Create main GUI container
    local ScreenGui = UILibrary.Create("ScreenGui", {
        Name = GuiName,
        Parent = CoreGui,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false,
        DisplayOrder = 100
    })
    
    GuiObjects.ScreenGui = ScreenGui
    
    -- Create main window frame
    size = size or UDim2.new(0, 550, 0, 400)
    local MainWindow = UILibrary.Create("Frame", {
        Name = "MainWindow",
        Parent = ScreenGui,
        BackgroundColor3 = Config.UI.Theme.Background,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, -size.X.Offset/2, 0.5, -size.Y.Offset/2),
        Size = size,
        Active = true,
        ClipsDescendants = true
    })
    
    GuiObjects.MainWindow = MainWindow
    
    -- Create shadow
    local Shadow = UILibrary.CreateShadow(MainWindow, 0.7, 6)
    GuiObjects.Shadow = Shadow
    
    -- Apply corner rounding
    UILibrary.Create("UICorner", {
        Parent = MainWindow,
        CornerRadius = UDim.new(0, 8)
    })
    
    -- Create title bar
    local TitleBar = UILibrary.Create("Frame", {
        Name = "TitleBar",
        Parent = MainWindow,
        BackgroundColor3 = Config.UI.Theme.Accent,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 35)
    })
    
    UILibrary.Create("UICorner", {
        Parent = TitleBar,
        CornerRadius = UDim.new(0, 8)
    })
    
    -- Fix rounded corners for title bar
    UILibrary.Create("Frame", {
        Parent = TitleBar,
        BackgroundColor3 = Config.UI.Theme.Accent,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0.5, 0),
        Size = UDim2.new(1, 0, 0.5, 0)
    })
    
    -- Add version/title text
    UILibrary.Create("TextLabel", {
        Name = "Title",
        Parent = TitleBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 15, 0, 0),
        Size = UDim2.new(1, -120, 1, 0),
        Font = Enum.Font.SourceSansBold,
        Text = title .. " v" .. Config.Version,
        TextColor3 = Config.UI.Theme.Text,
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    -- Close button
    local CloseButton = UILibrary.Create("TextButton", {
        Name = "CloseButton",
        Parent = TitleBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -35, 0, 0),
        Size = UDim2.new(0, 35, 1, 0),
        Font = Enum.Font.SourceSansBold,
        Text = "✕",
        TextColor3 = Config.UI.Theme.Text,
        TextSize = 20
    })
    
    CloseButton.MouseButton1Click:Connect(function()
        UILibrary.Tween(MainWindow, {Position = UDim2.new(0.5, -size.X.Offset/2, 1.5, 0)}, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        UILibrary.Tween(Shadow, {Position = UDim2.new(0.5, -size.X.Offset/2 + 6, 1.5, 6)}, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        
        task.wait(0.5)
        ScreenGui:Destroy()
        Config.UI.Enabled = false
    end)
    
    -- Minimize button
    local MinimizeButton = UILibrary.Create("TextButton", {
        Name = "MinimizeButton",
        Parent = TitleBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -70, 0, 0),
        Size = UDim2.new(0, 35, 1, 0),
        Font = Enum.Font.SourceSansBold,
        Text = "—",
        TextColor3 = Config.UI.Theme.Text,
        TextSize = 20
    })
    
    local minimized = false
    MinimizeButton.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            UILibrary.Tween(MainWindow, {Size = UDim2.new(0, size.X.Offset, 0, 35)})
            UILibrary.Tween(Shadow, {Size = UDim2.new(0, size.X.Offset, 0, 35)})
        else
            UILibrary.Tween(MainWindow, {Size = size})
            UILibrary.Tween(Shadow, {Size = size})
        end
    end)
    
    -- Make window draggable
    if Config.UI.Draggable then
        local dragging
        local dragInput
        local dragStart
        local startPos
        
        local function update(input)
            local delta = input.Position - dragStart
            UILibrary.Tween(MainWindow, {Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)}, 0.1)
            UILibrary.Tween(Shadow, {Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X + 6, startPos.Y.Scale, startPos.Y.Offset + delta.Y + 6)}, 0.1)
        end
        
        TitleBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                dragStart = input.Position
                startPos = MainWindow.Position
                
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                    end
                end)
            end
        end)
        
        TitleBar.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement then
                dragInput = input
            end
        end)
        
        RunService.RenderStepped:Connect(function()
            if dragging and dragInput then
                update(dragInput)
            end
        end)
    end
    
    -- Tab container
    local TabContainer = UILibrary.Create("Frame", {
        Name = "TabContainer",
        Parent = MainWindow,
        BackgroundColor3 = Config.UI.Theme.DarkElement,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 35),
        Size = UDim2.new(0, 130, 1, -35)
    })
    
    -- Content frame
    local ContentFrame = UILibrary.Create("Frame", {
        Name = "ContentFrame",
        Parent = MainWindow,
        BackgroundColor3 = Config.UI.Theme.Background,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 130, 0, 35),
        Size = UDim2.new(1, -130, 1, -35)
    })
    
    -- Tab Buttons container
    local TabButtonsContainer = UILibrary.Create("ScrollingFrame", {
        Name = "TabButtonsContainer",
        Parent = TabContainer,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = Config.UI.Theme.LightElement,
        ScrollingEnabled = true,
        VerticalScrollBarInset = Enum.ScrollBarInset.Always
    })
    
    -- Tab layout
    local TabButtonLayout = UILibrary.Create("UIListLayout", {
        Parent = TabButtonsContainer,
        Padding = UDim.new(0, 2),
        SortOrder = Enum.SortOrder.LayoutOrder
    })
    
    -- Update canvas size when children are added/removed
    TabButtonLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        TabButtonsContainer.CanvasSize = UDim2.new(0, 0, 0, TabButtonLayout.AbsoluteContentSize.Y + 10)
    end)
    
    local Window = {
        GUI = ScreenGui,
        MainWindow = MainWindow,
        Shadow = Shadow,
        TitleBar = TitleBar,
        TabContainer = TabContainer,
        ContentFrame = ContentFrame,
        TabButtonsContainer = TabButtonsContainer,
        Tabs = {}
    }
    
    return Window
end

-- Show a notification
function UILibrary.ShowNotification(title, message, duration)
    duration = duration or 3
    
    -- Create notification GUI if needed
    local NotificationGui
    pcall(function()
        if CoreGui:FindFirstChild("AimbotESPNotifications") then
            NotificationGui = CoreGui:FindFirstChild("AimbotESPNotifications")
        else
            NotificationGui = UILibrary.Create("ScreenGui", {
                Name = "AimbotESPNotifications",
                Parent = CoreGui,
                ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
                ResetOnSpawn = false,
                DisplayOrder = 100
            })
            
            local NotifList = UILibrary.Create("Frame", {
                Name = "NotificationList",
                Parent = NotificationGui,
                BackgroundTransparency = 1,
                Position = UDim2.new(1, -330, 0, 20),
                Size = UDim2.new(0, 320, 1, -40),
                ClipsDescendants = false
            })
            
            local ListLayout = UILibrary.Create("UIListLayout", {
                Parent = NotifList,
                Padding = UDim.new(0, 10),
                SortOrder = Enum.SortOrder.LayoutOrder,
                VerticalAlignment = Enum.VerticalAlignment.Top
            })
        end
    end)
    
    if not NotificationGui then return end
    
    -- Get notification list
    local NotifList = NotificationGui:FindFirstChild("NotificationList")
    if not NotifList then return end
    
    -- Create notification frame
    local Notification = UILibrary.Create("Frame", {
        Name = "Notification_" .. HttpService:GenerateGUID(false):sub(1, 8),
        Parent = NotifList,
        BackgroundColor3 = Config.UI.Theme.Background,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 0), -- Will be adjusted based on content
        BackgroundTransparency = 0.1,
        LayoutOrder = #NotifList:GetChildren() * -1 -- Newest at top
    })
    
    UILibrary.Create("UICorner", {
        Parent = Notification,
        CornerRadius = UDim.new(0, 8)
    })
    
    -- Create shadow
    UILibrary.CreateShadow(Notification, 0.7, 4)
    
    -- Title
    local Title = UILibrary.Create("TextLabel", {
        Name = "Title",
        Parent = Notification,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 15, 0, 10),
        Size = UDim2.new(1, -25, 0, 24),
        Font = Enum.Font.SourceSansBold,
        Text = title,
        TextColor3 = Config.UI.Theme.Accent,
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    -- Message
    local Message = UILibrary.Create("TextLabel", {
        Name = "Message",
        Parent = Notification,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 15, 0, 40),
        Size = UDim2.new(1, -30, 0, 0),
        Font = Enum.Font.SourceSans,
        Text = message,
        TextColor3 = Config.UI.Theme.Text,
        TextSize = 16,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top
    })
    
    -- Calculate height based on text
    local textHeight = math.max(40, Message.TextBounds.Y)
    Message.Size = UDim2.new(1, -30, 0, textHeight)
    Notification.Size = UDim2.new(1, 0, 0, textHeight + 55)
    
    -- Progress bar
    local ProgressBar = UILibrary.Create("Frame", {
        Name = "ProgressBar",
        Parent = Notification,
        BackgroundColor3 = Config.UI.Theme.Accent,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 1, -4),
        Size = UDim2.new(1, 0, 0, 4)
    })
    
    UILibrary.Create("UICorner", {
        Parent = ProgressBar,
        CornerRadius = UDim.new(0, 2)
    })
    
    -- Animation
    Notification.Position = UDim2.new(1, 330, 0, 0)
    UILibrary.Tween(Notification, {Position = UDim2.new(0, 0, 0, 0)}, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    
    -- Progress bar animation
    UILibrary.Tween(ProgressBar, {Size = UDim2.new(0, 0, 0, 4)}, duration)
    
    -- Remove after duration
    task.delay(duration, function()
        UILibrary.Tween(Notification, {Position = UDim2.new(1, 330, 0, 0)}, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In).Completed:Connect(function()
            Notification:Destroy()
        end)
    end)
    
    return Notification
end

-- Clean up function
function UILibrary.Cleanup()
    for _, obj in pairs(GuiObjects) do
        if obj and obj.Destroy then
            obj:Destroy()
        end
    end
    
    GuiObjects = {}
end

return UILibrary