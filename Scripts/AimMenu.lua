local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Settings
local Settings = {
    Aimbot = {
        Enabled = false,
        Smoothness = 0.5,
        FOV = 400,
        TeamCheck = false,
        WallCheck = false,
        TargetPart = "Head",
        PredictionEnabled = false
    },
    ESP = {
        Enabled = false,
        BoxESP = false,
        SkeletonESP = false,
        NameESP = false,
        HealthESP = false,
        DistanceESP = false,
        HeadDotESP = false,
        TracerESP = false,
        TeamColors = false,
        BoxFill = false
    },
    Misc = {
        SpeedHack = false,
        JumpHack = false,
        NoClip = false,
        GodMode = false
    }
}

-- Create ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "EnhancedCombatSystem"
ScreenGui.Parent = game:GetService("CoreGui")

-- Create Toggle Function
local function createToggle(parent, name, setting, settingPath, position)
    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(0.9, 0, 0, 30)
    toggle.Position = position
    toggle.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    toggle.Text = name .. ": OFF"
    toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggle.Parent = parent

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 4)
    UICorner.Parent = toggle

    toggle.MouseButton1Click:Connect(function()
        Settings[settingPath][setting] = not Settings[settingPath][setting]
        toggle.Text = name .. ": " .. (Settings[settingPath][setting] and "ON" or "OFF")
        toggle.BackgroundColor3 = Settings[settingPath][setting]
            and Color3.fromRGB(60, 60, 60)
            or Color3.fromRGB(35, 35, 35)
    end)
    return toggle
end

-- Create Menus
local function CreateMenus()
    local menus = {
        Combat = {
            title = "Combat",
            position = UDim2.new(0.1, 0, 0.2, 0),
            size = UDim2.new(0, 200, 0, 300),
            color = Color3.fromRGB(255, 50, 50)
        },
        Visuals = {
            title = "Visuals",
            position = UDim2.new(0.4, 0, 0.2, 0),
            size = UDim2.new(0, 200, 0, 300),
            color = Color3.fromRGB(50, 255, 50)
        },
        Misc = {
            title = "Misc",
            position = UDim2.new(0.7, 0, 0.2, 0),
            size = UDim2.new(0, 200, 0, 300),
            color = Color3.fromRGB(50, 50, 255)
        }
    }

    for name, data in pairs(menus) do
        local menu = Instance.new("Frame")
        menu.Name = name
        menu.Size = data.size
        menu.Position = data.position
        menu.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        menu.BorderSizePixel = 0
        menu.Active = true
        menu.Draggable = true
        menu.Parent = ScreenGui

        -- Add shadow
        local shadow = Instance.new("ImageLabel")
        shadow.Name = "Shadow"
        shadow.AnchorPoint = Vector2.new(0.5, 0.5)
        shadow.BackgroundTransparency = 1
        shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
        shadow.Size = UDim2.new(1, 30, 1, 30)
        shadow.Image = "rbxassetid://5554236805"
        shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
        shadow.ImageTransparency = 0.6
        shadow.Parent = menu

        -- Title Bar
        local titleBar = Instance.new("Frame")
        titleBar.Size = UDim2.new(1, 0, 0, 30)
        titleBar.BackgroundColor3 = data.color
        titleBar.Parent = menu

        local UICorner = Instance.new("UICorner")
        UICorner.CornerRadius = UDim.new(0, 4)
        UICorner.Parent = titleBar

        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(1, 0, 1, 0)
        title.BackgroundTransparency = 1
        title.Text = data.title
        title.TextColor3 = Color3.new(1, 1, 1)
        title.Font = Enum.Font.GothamBold
        title.Parent = titleBar

        -- Content Frame
        local content = Instance.new("ScrollingFrame")
        content.Size = UDim2.new(1, 0, 1, -30)
        content.Position = UDim2.new(0, 0, 0, 30)
        content.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        content.BorderSizePixel = 0
        content.ScrollBarThickness = 4
        content.Parent = menu

        -- Add specific toggles for each menu
        if name == "Combat" then
            createToggle(content, "Aimbot", "Enabled", "Aimbot", UDim2.new(0.05, 0, 0, 10))
            createToggle(content, "Team Check", "TeamCheck", "Aimbot", UDim2.new(0.05, 0, 0, 50))
            createToggle(content, "Wall Check", "WallCheck", "Aimbot", UDim2.new(0.05, 0, 0, 90))
            createToggle(content, "Prediction", "PredictionEnabled", "Aimbot", UDim2.new(0.05, 0, 0, 130))
        elseif name == "Visuals" then
            createToggle(content, "ESP", "Enabled", "ESP", UDim2.new(0.05, 0, 0, 10))
            createToggle(content, "Boxes", "BoxESP", "ESP", UDim2.new(0.05, 0, 0, 50))
            createToggle(content, "Skeleton", "SkeletonESP", "ESP", UDim2.new(0.05, 0, 0, 90))
            createToggle(content, "Names", "NameESP", "ESP", UDim2.new(0.05, 0, 0, 130))
            createToggle(content, "Health", "HealthESP", "ESP", UDim2.new(0.05, 0, 0, 170))
            createToggle(content, "Head Dot", "HeadDotESP", "ESP", UDim2.new(0.05, 0, 0, 210))
            createToggle(content, "Tracers", "TracerESP", "ESP", UDim2.new(0.05, 0, 0, 250))
        elseif name == "Misc" then
            createToggle(content, "Speed", "SpeedHack", "Misc", UDim2.new(0.05, 0, 0, 10))
            createToggle(content, "Jump", "JumpHack", "Misc", UDim2.new(0.05, 0, 0, 50))
            createToggle(content, "NoClip", "NoClip", "Misc", UDim2.new(0.05, 0, 0, 90))
            createToggle(content, "God Mode", "GodMode", "Misc", UDim2.new(0.05, 0, 0, 130))
        end
    end
end

-- ESP Objects Cache
local ESPObjects = {}

-- Create Bone ESP
local function CreateBoneESP(player)
    local bones = {
        Head = Drawing.new("Line"),
        UpperTorso = Drawing.new("Line"),
        LowerTorso = Drawing.new("Line"),
        LeftUpperArm = Drawing.new("Line"),
        LeftLowerArm = Drawing.new("Line"),
        RightUpperArm = Drawing.new("Line"),
        RightLowerArm = Drawing.new("Line"),
        LeftUpperLeg = Drawing.new("Line"),
        LeftLowerLeg = Drawing.new("Line"),
        RightUpperLeg = Drawing.new("Line"),
        RightLowerLeg = Drawing.new("Line")
    }

    for _, bone in pairs(bones) do
        bone.Thickness = 1
        bone.Color = Color3.new(1, 1, 1)
        bone.Transparency = 1
        bone.Visible = false
    end

    return bones
end

-- Create ESP Object
local function CreateESPObject(player)
    local espObject = {
        Box = Drawing.new("Square"),
        BoxFill = Drawing.new("Square"),
        BoxOutline = Drawing.new("Square"),
        Name = Drawing.new("Text"),
        Distance = Drawing.new("Text"),
        Health = Drawing.new("Line"),
        HealthBackground = Drawing.new("Line"),
        HeadDot = Drawing.new("Circle"),
        Bones = CreateBoneESP(player),
        Tracer = Drawing.new("Line")
    }

    -- Box Setup
    espObject.BoxOutline.Thickness = 3
    espObject.BoxOutline.Color = Color3.new(0, 0, 0)

    espObject.Box.Thickness = 1
    espObject.Box.Color = Color3.new(1, 1, 1)

    espObject.BoxFill.Filled = true
    espObject.BoxFill.Transparency = 0.5

    -- Name Setup
    espObject.Name.Size = 14
    espObject.Name.Center = true
    espObject.Name.Outline = true
    espObject.Name.Font = 2

    -- Distance Setup
    espObject.Distance.Size = 13
    espObject.Distance.Center = true
    espObject.Distance.Outline = true

    -- Health Setup
    espObject.HealthBackground.Thickness = 4
    espObject.HealthBackground.Color = Color3.new(0, 0, 0)
    espObject.Health.Thickness = 2

    -- Head Dot Setup
    espObject.HeadDot.Radius = 3
    espObject.HeadDot.Filled = true

    -- Tracer Setup
    espObject.Tracer.Thickness = 1
    espObject.Tracer.Color = Color3.new(1, 1, 1)

    ESPObjects[player] = espObject
    return espObject
end

-- Update ESP
local function UpdateESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local espObject = ESPObjects[player] or CreateESPObject(player)
            local character = player.Character
            local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
            local humanoid = character:FindFirstChild("Humanoid")
            local head = character:FindFirstChild("Head")

            if Settings.ESP.Enabled and humanoidRootPart and humanoid and head then
                local rootPos, onScreen = Camera:WorldToViewportPoint(humanoidRootPart.Position)

                if onScreen then
                    local distance = (Camera.CFrame.Position - humanoidRootPart.Position).Magnitude
                    local scaleFactor = 1 / (distance / 100)

                    -- Box ESP
                    if Settings.ESP.BoxESP then
                        local boxSize = Vector2.new(2000 * scaleFactor, 3200 * scaleFactor)
                        espObject.Box.Size = boxSize
                        espObject.Box.Position = Vector2.new(rootPos.X - boxSize.X / 2, rootPos.Y - boxSize.Y / 2)
                        espObject.Box.Visible = true
                        espObject.BoxOutline.Size = boxSize
                        espObject.BoxOutline.Position = espObject.Box.Position
                        espObject.BoxOutline.Visible = true
                    end

                    -- Skeleton ESP
                    if Settings.ESP.SkeletonESP then
                        for boneName, bone in pairs(espObject.Bones) do
                            local part = character:FindFirstChild(boneName)
                            if part then
                                local pos = Camera:WorldToViewportPoint(part.Position)
                                bone.From = Vector2.new(pos.X, pos.Y)
                                bone.To = Vector2.new(rootPos.X, rootPos.Y)
                                bone.Visible = true
                            end
                        end
                    end

                    -- Health ESP
                    if Settings.ESP.HealthESP then
                        local healthPercent = humanoid.Health / humanoid.MaxHealth
                        espObject.Health.Color = Color3.fromHSV(healthPercent * 0.3, 1, 1)
                        local healthBarPos = Vector2.new(rootPos.X - espObject.Box.Size.X / 2 - 5, rootPos.Y - espObject.Box.Size.Y / 2)
                        espObject.Health.From = healthBarPos
                        espObject.Health.To = Vector2.new(healthBarPos.X, healthBarPos.Y + espObject.Box.Size.Y * healthPercent)
                        espObject.Health.Visible = true
                        espObject.HealthBackground.From = healthBarPos
                        espObject.HealthBackground.To = Vector2.new(healthBarPos.X, healthBarPos.Y + espObject.Box.Size.Y)
                        espObject.HealthBackground.Visible = true
                    end

                    -- Name & Distance ESP
                    if Settings.ESP.NameESP then
                        espObject.Name.Position = Vector2.new(rootPos.X, rootPos.Y - espObject.Box.Size.Y / 2 - 15)
                        espObject.Name.Text = string.format("%s [%d studs]", player.Name, math.floor(distance))
                        espObject.Name.Visible = true
                    end

                    -- Head Dot ESP
                    if Settings.ESP.HeadDotESP then
                        local headPos = Camera:WorldToViewportPoint(head.Position)
                        espObject.HeadDot.Position = Vector2.new(headPos.X, headPos.Y)
                        espObject.HeadDot.Visible = true
                    end

                    -- Tracer ESP
                    if Settings.ESP.TracerESP then
                        espObject.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                        espObject.Tracer.To = Vector2.new(rootPos.X, rootPos.Y)
                        espObject.Tracer.Visible = true
                    end
                else
                    -- Hide ESP when off screen
                    for _, drawing in pairs(espObject) do
                        if type(drawing) ~= "table" then
                            drawing.Visible = false
                        end
                    end
                    for _, bone in pairs(espObject.Bones) do
                        bone.Visible = false
                    end
                end
            end
        end
    end
end

-- Aimbot Update
local function AimbotUpdate()
    if Settings.Aimbot.Enabled and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local closest = nil
        local maxDist = Settings.Aimbot.FOV
        local mousePos = UserInputService:GetMouseLocation()

        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                if not Settings.Aimbot.TeamCheck or player.Team ~= LocalPlayer.Team then
                    local character = player.Character
                    local humanoid = character:FindFirstChild("Humanoid")
                    local head = character:FindFirstChild("Head")

                    if humanoid and humanoid.Health > 0 and head then
                        local vector, onScreen = Camera:WorldToViewportPoint(head.Position)
                        if onScreen then
                            local distance = (Vector2.new(mousePos.X, mousePos.Y) - Vector2.new(vector.X, vector.Y)).Magnitude
                            if distance < maxDist then
                                maxDist = distance
                                closest = head
                            end
                        end
                    end
                end
            end
        end

        if closest then
            local targetPos = Camera:WorldToViewportPoint(closest.Position)
            mousemoverel(
                (targetPos.X - mousePos.X) * Settings.Aimbot.Smoothness,
                (targetPos.Y - mousePos.Y) * Settings.Aimbot.Smoothness
            )
        end
    end
end

-- Initialize Menus
CreateMenus()

-- Main Update Loop
RunService.RenderStepped:Connect(function()
    UpdateESP()
    AimbotUpdate()
end)

-- Toggle Menu Visibility
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Insert then
        ScreenGui.Enabled = not ScreenGui.Enabled
    end
end)

-- Clean up ESP objects
Players.PlayerRemoving:Connect(function(player)
    if ESPObjects[player] then
        for _, drawing in pairs(ESPObjects[player]) do
            if type(drawing) ~= "table" then
                drawing:Remove()
            else
                for _, bone in pairs(drawing) do
                    bone:Remove()
                end
            end
        end
        ESPObjects[player] = nil
    end
end)
