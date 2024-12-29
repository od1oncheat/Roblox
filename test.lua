local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()

-- Create startup notification
OrionLib:MakeNotification({
    Name = "Project EAX",
    Content = "Welcome to Project EAX",
    Image = "rbxassetid://4483345998",
    Time = 5
})

-- Create main window
local Window = OrionLib:MakeWindow({
    Name = "Project EAX", 
    HidePremium = false,
    SaveConfig = true, 
    ConfigFolder = "ProjectEAX"
})

-- Services
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

-- Variables
local selectedPlayer = nil
local controllingPlayer = false
local originalCameraSubject = nil
local originalCharacter = nil
local espEnabled = false
local espColor = Color3.fromRGB(255, 0, 0)
local espType = "full"
local espBoxes = {}
local espCorners = {}
local espCircles = {}
local esp3DBoxes = {}
local chamsEnabled = false
local chamsColor = Color3.fromRGB(255, 0, 0)
local chamsOutlineColor = Color3.fromRGB(255, 255, 255)
local chamsMaterial = "Flat"
local chamsHighlights = {}
local espNicknames = {}
local nicknameEnabled = false 
local nicknameColor = Color3.fromRGB(255, 255, 255)
local nicknameSize = 14
local showHealth = false
local healthStyle = "color"
local healthColor = Color3.fromRGB(0, 255, 0)
local healthBars = {}
local healthEffects = {}
local healthBarPosition = "bottom"
local distanceEnabled = false
local distanceColor = Color3.fromRGB(255, 255, 255)
local distanceSize = 14
local distancePosition = "bottom"
local distanceTexts = {}

-- Main control tab
local MainTab = Window:MakeTab({
    Name = "Player Control",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

-- ESP tab
local ESPTab = Window:MakeTab({
    Name = "2D ESP", 
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

-- Chams tab
local ChamsTab = Window:MakeTab({
    Name = "Chams",
    Icon = "rbxassetid://4483345998", 
    PremiumOnly = false
})

-- Function to create box
local function CreateBox()
    local box = Drawing.new("Square")
    box.Visible = false
    box.Color = espColor
    box.Thickness = 1
    box.Transparency = 1
    box.Filled = false
    return box
end

-- Function to create corners
local function CreateCorners()
    local corners = {}
    for i = 1, 8 do
        local line = Drawing.new("Line")
        line.Visible = false
        line.Color = espColor
        line.Thickness = 1
        line.Transparency = 1
        corners[i] = line
    end
    return corners
end

-- Function to create circle
local function CreateCircle()
    local circle = Drawing.new("Circle")
    circle.Visible = false
    circle.Color = espColor
    circle.Thickness = 1
    circle.Transparency = 1
    circle.NumSides = 32
    return circle
end

-- Function to create 3D box
local function Create3DBox()
    local lines = {}
    for i = 1, 12 do
        local line = Drawing.new("Line")
        line.Visible = false
        line.Color = espColor
        line.Thickness = 1
        line.Transparency = 1
        lines[i] = line
    end
    return lines
end

-- Function to create nickname text
local function CreateNickname()
    local text = Drawing.new("Text")
    text.Visible = false
    text.Color = nicknameColor
    text.Size = nicknameSize
    text.Center = true
    text.Outline = true
    text.OutlineColor = Color3.new(0, 0, 0)
    return text
end

-- Function to create health bar
local function CreateHealthBar()
    local bar = Drawing.new("Line")
    bar.Visible = false 
    bar.Color = healthColor
    bar.Thickness = 3
    bar.Transparency = 1
    return bar
end

-- Function to create distance text
local function CreateDistanceText()
    local text = Drawing.new("Text")
    text.Visible = false
    text.Color = distanceColor
    text.Size = distanceSize
    text.Center = true
    text.Outline = true
    text.OutlineColor = Color3.new(0, 0, 0)
    return text
end

-- Create player dropdown
local playerDropdown = MainTab:AddDropdown({
    Name = "Select Player",
    Default = "",
    Options = {},
    Callback = function(Value)
        selectedPlayer = Value
    end    
})

-- Function to update player list
local function UpdatePlayerList()
    local playerList = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            table.insert(playerList, player.Name)
        end
    end
    playerDropdown:Refresh(playerList, true)
end

-- Update list when players join/leave
Players.PlayerAdded:Connect(UpdatePlayerList)
Players.PlayerRemoving:Connect(UpdatePlayerList)
UpdatePlayerList()

-- Function to control target player
local function ControlPlayer(targetPlayer)
    local targetCharacter = targetPlayer.Character
    if not targetCharacter then return end
    
    local targetHumanoid = targetCharacter:FindFirstChild("Humanoid")
    local targetRoot = targetCharacter:FindFirstChild("HumanoidRootPart")
    
    if not (targetHumanoid and targetRoot) then return end
    
    workspace.CurrentCamera.CameraSubject = targetHumanoid
    
    local connection = RunService.Heartbeat:Connect(function()
        if not controllingPlayer then
            connection:Disconnect()
            return
        end
        
        local moveDirection = Vector3.new(0, 0, 0)
        local camera = workspace.CurrentCamera
        
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            moveDirection = moveDirection + camera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            moveDirection = moveDirection - camera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            moveDirection = moveDirection + camera.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            moveDirection = moveDirection - camera.CFrame.RightVector
        end
        
        moveDirection = Vector3.new(moveDirection.X, 0, moveDirection.Z)
        if moveDirection.Magnitude > 0 then
            moveDirection = moveDirection.Unit
            targetHumanoid:Move(moveDirection)
        end
        
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            targetHumanoid.Jump = true
        end
        
        local lookVector = camera.CFrame.LookVector
        targetRoot.CFrame = CFrame.new(targetRoot.Position, 
            targetRoot.Position + Vector3.new(lookVector.X, 0, lookVector.Z))
    end)
    
    local function onButton1Down()
        if controllingPlayer then
            local tool = targetCharacter:FindFirstChildOfClass("Tool")
            if tool and tool:FindFirstChild("Activate") then
                tool:Activate()
            end
        end
    end
    
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            onButton1Down()
        end
    end)
end

-- Possession buttons
MainTab:AddButton({
    Name = "Possess Player",
    Callback = function()
        if selectedPlayer then
            local targetPlayer = Players:FindFirstChild(selectedPlayer)
            if targetPlayer and targetPlayer.Character then
                controllingPlayer = true
                
                originalCharacter = LocalPlayer.Character
                if originalCharacter then
                    for _, part in pairs(originalCharacter:GetDescendants()) do
                        if part:IsA("BasePart") or part:IsA("Decal") then
                            part.Transparency = 1
                        end
                    end
                    originalCharacter.Humanoid.WalkSpeed = 0
                    originalCharacter.HumanoidRootPart.Anchored = true
                end
                
                ControlPlayer(targetPlayer)
                
                OrionLib:MakeNotification({
                    Name = "Project EAX",
                    Content = "Successfully possessed " .. selectedPlayer,
                    Image = "rbxassetid://4483345998",
                    Time = 5
                })
            end
        end
    end
})

MainTab:AddButton({
    Name = "Stop Possession",
    Callback = function()
        controllingPlayer = false
        
        if originalCharacter then
            for _, part in pairs(originalCharacter:GetDescendants()) do
                if part:IsA("BasePart") or part:IsA("Decal") then
                    part.Transparency = 0
                end
            end
            originalCharacter.Humanoid.WalkSpeed = 16
            originalCharacter.HumanoidRootPart.Anchored = false
            workspace.CurrentCamera.CameraSubject = originalCharacter.Humanoid
        end
        
        OrionLib:MakeNotification({
            Name = "Project EAX",
            Content = "Possession ended",
            Image = "rbxassetid://4483345998",
            Time = 5
        })
    end
})

-- ESP Functions
ESPTab:AddLabel("Box ESP Settings")
ESPTab:AddToggle({
    Name = "2D ESP",
    Default = false,
    Callback = function(Value)
        espEnabled = Value
        if not Value then
            for _, box in pairs(espBoxes) do
                box.Visible = false
            end
            for _, corners in pairs(espCorners) do
                for _, line in pairs(corners) do
                    line.Visible = false
                end
            end
            for _, circle in pairs(espCircles) do
                circle.Visible = false
            end
            for _, box3d in pairs(esp3DBoxes) do
                for _, line in pairs(box3d) do
                    line.Visible = false
                end
            end
        end
    end
})

ESPTab:AddColorpicker({
    Name = "ESP Color",
    Default = Color3.fromRGB(255, 0, 0),
    Callback = function(Value)
        espColor = Value
        for _, box in pairs(espBoxes) do
            box.Color = Value
        end
        for _, corners in pairs(espCorners) do
            for _, line in pairs(corners) do
                line.Color = Value
            end
        end
        for _, circle in pairs(espCircles) do
            circle.Color = Value
        end
        for _, box3d in pairs(esp3DBoxes) do
            for _, line in pairs(box3d) do
                line.Color = Value
            end
        end
    end
})

ESPTab:AddDropdown({
    Name = "ESP Style",
    Default = "full",
    Options = {"full", "corner", "circle", "3d"},
    Callback = function(Value)
        espType = Value
    end
})

ESPTab:AddLabel("")
ESPTab:AddLabel("Nickname ESP Settings")
ESPTab:AddToggle({
    Name = "Show Nicknames",
    Default = false,
    Callback = function(Value)
        nicknameEnabled = Value
        if not Value then
            for _, text in pairs(espNicknames) do
                text.Visible = false
            end
        end
    end
})

ESPTab:AddColorpicker({
    Name = "Nickname Color",
    Default = Color3.fromRGB(255, 255, 255),
    Callback = function(Value)
        nicknameColor = Value
        for _, text in pairs(espNicknames) do
            text.Color = Value
        end
    end
})

ESPTab:AddSlider({
    Name = "Nickname Size",
    Min = 10,
    Max = 24,
    Default = 14,
    Color = Color3.fromRGB(255, 255, 255),
    Increment = 1,
    Callback = function(Value)
        nicknameSize = Value
        for _, text in pairs(espNicknames) do
            text.Size = Value
        end
    end
})

ESPTab:AddLabel("")
ESPTab:AddLabel("Health ESP Settings")
ESPTab:AddToggle({
    Name = "Show Health",
    Default = false,
    Callback = function(Value)
        showHealth = Value
        if not Value then
            for _, bar in pairs(healthBars) do
                bar.Visible = false
            end
        end
    end
})

ESPTab:AddDropdown({
    Name = "Health Bar Position",
    Default = "bottom",
    Options = {"left", "right", "top", "bottom"},
    Callback = function(Value)
        healthBarPosition = Value
    end
})

ESPTab:AddDropdown({
    Name = "Health Style",
    Default = "color",
    Options = {"color", "gradient", "rainbow", "glow"},
    Callback = function(Value)
        healthStyle = Value
        
        -- Clear existing effects
        for _, effect in pairs(healthEffects) do
            effect:Disconnect()
        end
        healthEffects = {}
        
        -- Set up new effects based on style
        if Value == "rainbow" or Value == "glow" then
            for player, bar in pairs(healthBars) do
                local effect = RunService.RenderStepped:Connect(function()
                    if not bar.Visible then return end
                    
                    if Value == "rainbow" then
                        local hue = tick() % 5 / 5
                        local color = Color3.fromHSV(hue, 1, 1)
                        bar.Color = color
                    elseif Value == "glow" then
                        local pulse = (math.sin(tick() * 2) + 1) / 2
                        bar.Transparency = 0.2 + (pulse * 0.4)
                        bar.Thickness = 3 + (pulse * 2)
                        local glowColor = healthColor:Lerp(Color3.new(1,1,1), pulse * 0.3)
                        bar.Color = glowColor
                    end
                end)
                healthEffects[player] = effect
            end
        end
    end
})

ESPTab:AddColorpicker({
    Name = "Health Color",
    Default = Color3.fromRGB(0, 255, 0),
    Callback = function(Value)
        healthColor = Value
        for _, bar in pairs(healthBars) do
            if healthStyle == "color" then
                bar.Color = Value
            end
        end
    end
})

ESPTab:AddLabel("")
ESPTab:AddLabel("Distance Settings")
ESPTab:AddToggle({
    Name = "Show Distance",
    Default = false,
    Callback = function(Value)
        distanceEnabled = Value
        if not Value then
            for _, text in pairs(distanceTexts) do
                text.Visible = false
            end
        end
    end
})

ESPTab:AddColorpicker({
    Name = "Distance Color",
    Default = Color3.fromRGB(255, 255, 255),
    Callback = function(Value)
        distanceColor = Value
        for _, text in pairs(distanceTexts) do
            text.Color = Value
        end
    end
})

ESPTab:AddSlider({
    Name = "Distance Text Size",
    Min = 10,
    Max = 24,
    Default = 14,
    Color = Color3.fromRGB(255, 255, 255),
    Increment = 1,
    Callback = function(Value)
        distanceSize = Value
        for _, text in pairs(distanceTexts) do
            text.Size = Value
        end
    end
})

ESPTab:AddDropdown({
    Name = "Distance Position",
    Default = "bottom",
    Options = {"left", "right", "top", "bottom"},
    Callback = function(Value)
        distancePosition = Value
    end
})

-- Chams Functions
ChamsTab:AddToggle({
    Name = "Chams",
    Default = false,
    Callback = function(Value)
        chamsEnabled = Value
        for _, highlight in pairs(chamsHighlights) do
            if highlight and highlight.Parent then
                highlight.Enabled = Value
            end
        end
    end    
})

ChamsTab:AddColorpicker({
    Name = "Chams Color", 
    Default = Color3.fromRGB(255, 0, 0),
    Callback = function(Value)
        chamsColor = Value
        for _, highlight in pairs(chamsHighlights) do
            if highlight and highlight.Parent then
                highlight.FillColor = Value
            end
        end
    end
})

ChamsTab:AddColorpicker({
    Name = "Chams Outline Color",
    Default = Color3.fromRGB(255, 255, 255), 
    Callback = function(Value)
        chamsOutlineColor = Value
        for _, highlight in pairs(chamsHighlights) do
            if highlight and highlight.Parent then
                highlight.OutlineColor = Value
            end
        end
    end
})

ChamsTab:AddDropdown({
    Name = "Chams Material",
    Default = "Flat",
    Options = {"Flat", "Outline", "Metallic", "Glow"},
    Callback = function(Value)
        chamsMaterial = Value
        for _, highlight in pairs(chamsHighlights) do
            if highlight and highlight.Parent then
                if Value == "Flat" then
                    highlight.FillTransparency = 0.5
                    highlight.OutlineTransparency = 1
                elseif Value == "Outline" then
                    highlight.FillTransparency = 1
                    highlight.OutlineTransparency = 0
                elseif Value == "Metallic" then
                    highlight.FillTransparency = 0.2
                    highlight.OutlineTransparency = 0.3
                    
                    -- Enhanced metallic effect
                    if not highlight:FindFirstChild("MetallicEffect") then
                        local effect = Instance.new("BindableEvent")
                        effect.Name = "MetallicEffect"
                        effect.Parent = highlight
                        
                        RunService.RenderStepped:Connect(function()
                            if chamsMaterial == "Metallic" then
                                local time = tick()
                                local shimmer = math.abs(math.sin(time * 2))
                                local wave = math.abs(math.sin(time * 1.5 + math.cos(time * 0.5)))
                                highlight.FillTransparency = 0.2 + (shimmer * 0.15)
                                highlight.OutlineTransparency = 0.3 + (wave * 0.2)
                                highlight.FillColor = chamsColor:Lerp(Color3.new(1, 1, 1), shimmer * 0.2)
                            end
                        end)
                    end
                elseif Value == "Glow" then
                    highlight.FillTransparency = 0.4
                    highlight.OutlineTransparency = 0.1
                    
                    -- Enhanced glow effect
                    if not highlight:FindFirstChild("GlowEffect") then
                        local effect = Instance.new("BindableEvent")
                        effect.Name = "GlowEffect"
                        effect.Parent = highlight
                        
                        RunService.RenderStepped:Connect(function()
                            if chamsMaterial == "Glow" then
                                local time = tick()
                                local pulse = math.abs(math.sin(time))
                                local wave = math.abs(math.sin(time * 0.8))
                                
                                highlight.FillTransparency = 0.4 + (pulse * 0.3)
                                highlight.OutlineTransparency = 0.1 + (wave * 0.4)
                                
                                -- Create a glowing aura effect
                                local glowColor = chamsColor:Lerp(Color3.new(1, 1, 1), wave * 0.3)
                                highlight.OutlineColor = glowColor
                            end
                        end)
                    end
                end
            end
        end
    end
})

-- Function to create chams
local function CreateChams(player)
    if not chamsHighlights[player] then
        local highlight = Instance.new("Highlight")
        highlight.FillColor = chamsColor
        highlight.OutlineColor = chamsOutlineColor
        
        -- Set initial material properties
        if chamsMaterial == "Flat" then
            highlight.FillTransparency = 0.5
            highlight.OutlineTransparency = 1
        elseif chamsMaterial == "Outline" then
            highlight.FillTransparency = 1
            highlight.OutlineTransparency = 0
        elseif chamsMaterial == "Metallic" then
            highlight.FillTransparency = 0.2
            highlight.OutlineTransparency = 0.3
        elseif chamsMaterial == "Glow" then
            highlight.FillTransparency = 0.4
            highlight.OutlineTransparency = 0.1
        end
        
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.Enabled = chamsEnabled
        highlight.Parent = player.Character
        chamsHighlights[player] = highlight
        
        -- Add initial effects if needed
        if chamsMaterial == "Metallic" or chamsMaterial == "Glow" then
            local effectEvent = Instance.new("BindableEvent")
            effectEvent.Name = chamsMaterial .. "Effect"
            effectEvent.Parent = highlight
        end
    end
end

-- ESP Update Loop
RunService.RenderStepped:Connect(function()
    if espEnabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                if not espBoxes[player] then
                    espBoxes[player] = CreateBox()
                    espCorners[player] = CreateCorners()
                    espCircles[player] = CreateCircle()
                    esp3DBoxes[player] = Create3DBox()
                end
                
                if not espNicknames[player] then
                    espNicknames[player] = CreateNickname()
                end
                
                local character = player.Character
                local hrp = character:FindFirstChild("HumanoidRootPart")
                local vector, onScreen = workspace.CurrentCamera:WorldToViewportPoint(hrp.Position)
                
                if onScreen then
                    local topPoint = nil
                    local bottomPoint = nil
                    
                    for _, part in pairs(character:GetChildren()) do
                        if part:IsA("BasePart") then
                            local partTop = part.Position + Vector3.new(0, part.Size.Y/2, 0)
                            local partBottom = part.Position - Vector3.new(0, part.Size.Y/2, 0)
                            
                            if topPoint == nil or partTop.Y > topPoint.Y then
                                topPoint = partTop
                            end
                            if bottomPoint == nil or partBottom.Y < bottomPoint.Y then
                                bottomPoint = partBottom
                            end
                        end
                    end
                    
                    local topPos = workspace.CurrentCamera:WorldToViewportPoint(topPoint)
                    local bottomPos = workspace.CurrentCamera:WorldToViewportPoint(bottomPoint)
                    local height = math.abs(topPos.Y - bottomPos.Y)
                    local width = height * 0.5
                    
                    espBoxes[player].Visible = false
                    for _, line in pairs(espCorners[player]) do
                        line.Visible = false
                    end
                    espCircles[player].Visible = false
                    for _, line in pairs(esp3DBoxes[player]) do
                        line.Visible = false
                    end
                    
                    if espType == "full" then
                        espBoxes[player].Visible = true
                        espBoxes[player].Size = Vector2.new(width, height)
                        espBoxes[player].Position = Vector2.new(vector.X - width/2, topPos.Y)
                    
                    elseif espType == "corner" then
                        espCorners[player][1].From = Vector2.new(vector.X - width/2, topPos.Y)
                        espCorners[player][1].To = Vector2.new(vector.X - width/2 + width * 0.2, topPos.Y)
                        espCorners[player][2].From = Vector2.new(vector.X - width/2, topPos.Y)
                        espCorners[player][2].To = Vector2.new(vector.X - width/2, topPos.Y + height * 0.2)
                        
                        espCorners[player][3].From = Vector2.new(vector.X + width/2, topPos.Y)
                        espCorners[player][3].To = Vector2.new(vector.X + width/2 - width * 0.2, topPos.Y)
                        espCorners[player][4].From = Vector2.new(vector.X + width/2, topPos.Y)
                        espCorners[player][4].To = Vector2.new(vector.X + width/2, topPos.Y + height * 0.2)
                        
                        espCorners[player][5].From = Vector2.new(vector.X - width/2, bottomPos.Y)
                        espCorners[player][5].To = Vector2.new(vector.X - width/2 + width * 0.2, bottomPos.Y)
                        espCorners[player][6].From = Vector2.new(vector.X - width/2, bottomPos.Y)
                        espCorners[player][6].To = Vector2.new(vector.X - width/2, bottomPos.Y - height * 0.2)
                        
                        espCorners[player][7].From = Vector2.new(vector.X + width/2, bottomPos.Y)
                        espCorners[player][7].To = Vector2.new(vector.X + width/2 - width * 0.2, bottomPos.Y)
                        espCorners[player][8].From = Vector2.new(vector.X + width/2, bottomPos.Y)
                        espCorners[player][8].To = Vector2.new(vector.X + width/2, bottomPos.Y - height * 0.2)
                        
                        for _, line in pairs(espCorners[player]) do
                            line.Visible = true
                        end
                    
                    elseif espType == "circle" then
                        espCircles[player].Visible = true
                        espCircles[player].Position = Vector2.new(vector.X, vector.Y)
                        espCircles[player].Radius = height/2
                    
                    elseif espType == "3d" then
                        local char = player.Character
                        local size = char:GetExtentsSize()
                        local cf = char:GetPivot()
                        
                        local corners = {
                            cf * CFrame.new(-size.X/2, -size.Y/2, -size.Z/2),
                            cf * CFrame.new(size.X/2, -size.Y/2, -size.Z/2),
                            cf * CFrame.new(-size.X/2, size.Y/2, -size.Z/2),
                            cf * CFrame.new(size.X/2, size.Y/2, -size.Z/2),
                            cf * CFrame.new(-size.X/2, -size.Y/2, size.Z/2),
                            cf * CFrame.new(size.X/2, -size.Y/2, size.Z/2),
                            cf * CFrame.new(-size.X/2, size.Y/2, size.Z/2),
                            cf * CFrame.new(size.X/2, size.Y/2, size.Z/2)
                        }
                        
                        local points = {}
                        for _, corner in pairs(corners) do
                            local point = workspace.CurrentCamera:WorldToViewportPoint(corner.Position)
                            table.insert(points, Vector2.new(point.X, point.Y))
                        end
                        
                        local lines = esp3DBoxes[player]
                        lines[1].From = points[1]
                        lines[1].To = points[2]
                        lines[2].From = points[2]
                        lines[2].To = points[6]
                        lines[3].From = points[6]
                        lines[3].To = points[5]
                        lines[4].From = points[5]
                        lines[4].To = points[1]
                        
                        lines[5].From = points[3]
                        lines[5].To = points[4]
                        lines[6].From = points[4]
                        lines[6].To = points[8]
                        lines[7].From = points[8]
                        lines[7].To = points[7]
                        lines[8].From = points[7]
                        lines[8].To = points[3]
                        
                        lines[9].From = points[1]
                        lines[9].To = points[3]
                        lines[10].From = points[2]
                        lines[10].To = points[4]
                        lines[11].From = points[6]
                        lines[11].To = points[8]
                        lines[12].From = points[5]
                        lines[12].To = points[7]
                        
                        for _, line in pairs(lines) do
                            line.Visible = true
                        end
                    end
                    
                    if nicknameEnabled then
                        espNicknames[player].Visible = true
                        espNicknames[player].Text = player.Name
                        espNicknames[player].Position = Vector2.new(vector.X, topPos.Y - 20)
                    else
                        espNicknames[player].Visible = false
                    end
                    
                    if showHealth then
                        if not healthBars[player] then
                            healthBars[player] = CreateHealthBar()
                        end
                        
                        local humanoid = character:FindFirstChild("Humanoid")
                        if humanoid then
                            local health = humanoid.Health
                            local maxHealth = humanoid.MaxHealth
                            local healthPercent = health/maxHealth
                            
                            local barWidth = width * 0.8
                            local barHeight = 3
                            local barPos, barEndPos
                            
                            if healthBarPosition == "bottom" then
                                barPos = Vector2.new(vector.X - barWidth/2, bottomPos.Y + 5)
                                barEndPos = Vector2.new(barPos.X + (barWidth * healthPercent), bottomPos.Y + 5)
                            elseif healthBarPosition == "top" then
                                barPos = Vector2.new(vector.X - barWidth/2, topPos.Y - 5)
                                barEndPos = Vector2.new(barPos.X + (barWidth * healthPercent), topPos.Y - 5)
                            elseif healthBarPosition == "left" then
                                barWidth = height * 0.8
                                barPos = Vector2.new(vector.X - width/2 - 5, topPos.Y + (height - barWidth)/2)
                                barEndPos = Vector2.new(vector.X - width/2 - 5, barPos.Y + (barWidth * healthPercent))
                            elseif healthBarPosition == "right" then
                                barWidth = height * 0.8
                                barPos = Vector2.new(vector.X + width/2 + 5, topPos.Y + (height - barWidth)/2)
                                barEndPos = Vector2.new(vector.X + width/2 + 5, barPos.Y + (barWidth * healthPercent))
                            end
                            
                            healthBars[player].Visible = true
                            healthBars[player].From = barPos
                            healthBars[player].To = barEndPos
                            
                            if healthStyle == "gradient" then
                                local gradientColor = Color3.fromRGB(
                                    math.floor(255 * (1-healthPercent)), 
                                    math.floor(255 * healthPercent),
                                    0
                                )
                                healthBars[player].Color = gradientColor
                            elseif healthStyle == "color" then
                                healthBars[player].Color = healthColor
                            end
                        end
                    else
                        if healthBars[player] then
                            healthBars[player].Visible = false
                        end
                    end
                    
                    if distanceEnabled then
                        if not distanceTexts[player] then
                            distanceTexts[player] = CreateDistanceText()
                        end
                        
                        local distance = math.floor((LocalPlayer.Character.HumanoidRootPart.Position - character.HumanoidRootPart.Position).Magnitude)
                        distanceTexts[player].Text = tostring(distance) .. " studs"
                        distanceTexts[player].Visible = true
                        
                        local textPos
                        if distancePosition == "bottom" then
                            textPos = Vector2.new(vector.X, bottomPos.Y + (showHealth and 20 or 5))
                        elseif distancePosition == "top" then
                            textPos = Vector2.new(vector.X, topPos.Y - (nicknameEnabled and 40 or 20))
                        elseif distancePosition == "left" then
                            textPos = Vector2.new(vector.X - width/2 - 40, vector.Y)
                        elseif distancePosition == "right" then
                            textPos = Vector2.new(vector.X + width/2 + 40, vector.Y)
                        end
                        
                        distanceTexts[player].Position = textPos
                    else
                        if distanceTexts[player] then
                            distanceTexts[player].Visible = false
                        end
                    end
                end
            end
        end
    end
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            if chamsEnabled then
                CreateChams(player)
            else
                if chamsHighlights[player] then
                    chamsHighlights[player].Enabled = false
                end
            end
        end
    end
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local vector, onScreen = workspace.CurrentCamera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
            if not onScreen then
                espBoxes[player].Visible = false
                for _, line in pairs(espCorners[player]) do
                    line.Visible = false
                end
                espCircles[player].Visible = false
                for _, line in pairs(esp3DBoxes[player]) do
                    line.Visible = false
                end
                espNicknames[player].Visible = false
                if healthBars[player] then
                    healthBars[player].Visible = false
                end
                if distanceTexts[player] then
                    distanceTexts[player].Visible = false
                end
            end
        end
    end
end)

-- Cleanup ESP elements when character is removed
Players.PlayerRemoving:Connect(function(player)
    if espBoxes[player] then
        espBoxes[player]:Remove()
        espBoxes[player] = nil
        
        for _, line in pairs(espCorners[player]) do
            line:Remove()
        end
        espCorners[player] = nil
        
        espCircles[player]:Remove()
        espCircles[player] = nil
        
        for _, line in pairs(esp3DBoxes[player]) do
            line:Remove()
        end
        esp3DBoxes[player] = nil
    end
    
    if chamsHighlights[player] then
        chamsHighlights[player]:Destroy()
        chamsHighlights[player] = nil
    end
    
    if espNicknames[player] then
        espNicknames[player]:Remove()
        espNicknames[player] = nil
    end
    
    if healthBars[player] then
        healthBars[player]:Remove()
        healthBars[player] = nil
    end
    
    if distanceTexts[player] then
        distanceTexts[player]:Remove()
        distanceTexts[player] = nil
    end
    
    if healthEffects[player] then
        healthEffects[player]:Disconnect()
        healthEffects[player] = nil
    end
end)

-- Also add character cleanup
Players.PlayerAdded:Connect(function(player)
    player.CharacterRemoving:Connect(function()
        if espBoxes[player] then
            espBoxes[player].Visible = false
            for _, line in pairs(espCorners[player]) do
                line.Visible = false
            end
            espCircles[player].Visible = false
            for _, line in pairs(esp3DBoxes[player]) do
                line.Visible = false
            end
        end
        
        if chamsHighlights[player] then
            chamsHighlights[player]:Destroy()
            chamsHighlights[player] = nil
        end
        
        if espNicknames[player] then
            espNicknames[player]:Remove()
            espNicknames[player] = nil
        end
        
        if healthBars[player] then
            healthBars[player].Visible = false
        end
        
        if distanceTexts[player] then
            distanceTexts[player].Visible = false
        end
    end)
    
    player.CharacterAdded:Connect(function(character)
        if chamsEnabled then
            CreateChams(player)
        end
    end)
end)

-- Initialize library
OrionLib:Init()
