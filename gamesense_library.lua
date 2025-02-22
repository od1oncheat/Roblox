-- UI Library
local Library = {}
Library.__index = Library

-- Utility Functions
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local function CreateTween(instance, properties, duration, style, direction)
    local tweenInfo = TweenInfo.new(duration or 0.3, style or Enum.EasingStyle.Quad, direction or Enum.EasingDirection.Out)
    local tween = TweenService:Create(instance, tweenInfo, properties)
    return tween
end

-- Main Library Functions
function Library.new(title, size)
    local self = setmetatable({}, Library)
    
    -- Main GUI
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "UILibrary"
    self.ScreenGui.Parent = game.CoreGui
    
    -- Main Frame
    self.MainFrame = Instance.new("Frame")
    self.MainFrame.Name = "MainFrame"
    self.MainFrame.Size = size or UDim2.new(0, 500, 0, 350)
    self.MainFrame.Position = UDim2.new(0.5, -250, 0.5, -175)
    self.MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    self.MainFrame.BorderSizePixel = 0
    self.MainFrame.Parent = self.ScreenGui
    
    -- Round corners
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 8)
    UICorner.Parent = self.MainFrame
    
    -- Title
    self.TitleBar = Instance.new("Frame")
    self.TitleBar.Name = "TitleBar"
    self.TitleBar.Size = UDim2.new(1, 0, 0, 30)
    self.TitleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    self.TitleBar.BorderSizePixel = 0
    self.TitleBar.Parent = self.MainFrame
    
    local TitleUICorner = Instance.new("UICorner")
    TitleUICorner.CornerRadius = UDim.new(0, 8)
    TitleUICorner.Parent = self.TitleBar
    
    self.TitleLabel = Instance.new("TextLabel")
    self.TitleLabel.Name = "Title"
    self.TitleLabel.Text = title or "UI Library"
    self.TitleLabel.Size = UDim2.new(1, -10, 1, 0)
    self.TitleLabel.Position = UDim2.new(0, 10, 0, 0)
    self.TitleLabel.BackgroundTransparency = 1
    self.TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    self.TitleLabel.TextSize = 16
    self.TitleLabel.Font = Enum.Font.SourceSansBold
    self.TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    self.TitleLabel.Parent = self.TitleBar
    
    -- Tab Container
    self.TabContainer = Instance.new("Frame")
    self.TabContainer.Name = "TabContainer"
    self.TabContainer.Size = UDim2.new(0, 120, 1, -30)
    self.TabContainer.Position = UDim2.new(0, 0, 0, 30)
    self.TabContainer.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    self.TabContainer.BorderSizePixel = 0
    self.TabContainer.Parent = self.MainFrame
    
    local TabUICorner = Instance.new("UICorner")
    TabUICorner.CornerRadius = UDim.new(0, 8)
    TabUICorner.Parent = self.TabContainer
    
    -- Tab Content
    self.TabContent = Instance.new("Frame")
    self.TabContent.Name = "TabContent"
    self.TabContent.Size = UDim2.new(1, -130, 1, -40)
    self.TabContent.Position = UDim2.new(0, 125, 0, 35)
    self.TabContent.BackgroundTransparency = 1
    self.TabContent.Parent = self.MainFrame
    
    self.Tabs = {}
    self.ActiveTab = nil
    
    -- Make GUI draggable
    local dragging
    local dragInput
    local dragStart
    local startPos
    
    self.TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = self.MainFrame.Position
        end
    end)
    
    self.TitleBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    game:GetService("RunService").RenderStepped:Connect(function()
        if dragging and dragInput then
            local delta = dragInput.Position - dragStart
            self.MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    return self
end

function Library:CreateTab(name)
    local tab = {}
    
    -- Tab Button
    tab.Button = Instance.new("TextButton")
    tab.Button.Name = name
    tab.Button.Size = UDim2.new(1, -10, 0, 30)
    tab.Button.Position = UDim2.new(0, 5, 0, 5 + (#self.Tabs * 35))
    tab.Button.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    tab.Button.Text = name
    tab.Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    tab.Button.TextSize = 14
    tab.Button.Font = Enum.Font.SourceSans
    tab.Button.Parent = self.TabContainer
    
    local TabButtonUICorner = Instance.new("UICorner")
    TabButtonUICorner.CornerRadius = UDim.new(0, 6)
    TabButtonUICorner.Parent = tab.Button
    
    -- Tab Content Frame
    tab.Content = Instance.new("ScrollingFrame")
    tab.Content.Name = name .. "Content"
    tab.Content.Size = UDim2.new(1, 0, 1, 0)
    tab.Content.BackgroundTransparency = 1
    tab.Content.BorderSizePixel = 0
    tab.Content.ScrollBarThickness = 4
    tab.Content.Visible = false
    tab.Content.Parent = self.TabContent
    
    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Padding = UDim.new(0, 5)
    UIListLayout.Parent = tab.Content
    
    -- Tab Selection Logic
    tab.Button.MouseButton1Click:Connect(function()
        if self.ActiveTab then
            self.ActiveTab.Content.Visible = false
            CreateTween(self.ActiveTab.Button, {BackgroundColor3 = Color3.fromRGB(45, 45, 45)}):Play()
        end
        self.ActiveTab = tab
        tab.Content.Visible = true
        CreateTween(tab.Button, {BackgroundColor3 = Color3.fromRGB(60, 60, 60)}):Play()
    end)
    
    -- Select first tab by default
    if #self.Tabs == 0 then
        self.ActiveTab = tab
        tab.Content.Visible = true
        tab.Button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    end
    
    table.insert(self.Tabs, tab)
    return tab
end

function Library:CreateButton(tab, text, callback)
    local button = Instance.new("TextButton")
    button.Name = text
    button.Size = UDim2.new(1, -10, 0, 30)
    button.Position = UDim2.new(0, 5, 0, 5)
    button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    button.Text = text
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 14
    button.Font = Enum.Font.SourceSans
    button.Parent = tab.Content
    
    local ButtonUICorner = Instance.new("UICorner")
    ButtonUICorner.CornerRadius = UDim.new(0, 6)
    ButtonUICorner.Parent = button
    
    button.MouseButton1Click:Connect(function()
        CreateTween(button, {BackgroundColor3 = Color3.fromRGB(70, 70, 70)}):Play()
        if callback then callback() end
        wait(0.2)
        CreateTween(button, {BackgroundColor3 = Color3.fromRGB(50, 50, 50)}):Play()
    end)
    
    return button
end

function Library:CreateToggle(tab, text, callback)
    local toggle = Instance.new("Frame")
    toggle.Name = text
    toggle.Size = UDim2.new(1, -10, 0, 30)
    toggle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    toggle.Parent = tab.Content
    
    local ToggleUICorner = Instance.new("UICorner")
    ToggleUICorner.CornerRadius = UDim.new(0, 6)
    ToggleUICorner.Parent = toggle
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -50, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 14
    label.Font = Enum.Font.SourceSans
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = toggle
    
    local switch = Instance.new("Frame")
    switch.Size = UDim2.new(0, 40, 0, 20)
    switch.Position = UDim2.new(1, -45, 0.5, -10)
    switch.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
    switch.Parent = toggle
    
    local SwitchUICorner = Instance.new("UICorner")
    SwitchUICorner.CornerRadius = UDim.new(1, 0)
    SwitchUICorner.Parent = switch
    
    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.Position = UDim2.new(0, 2, 0.5, -8)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.Parent = switch
    
    local KnobUICorner = Instance.new("UICorner")
    KnobUICorner.CornerRadius = UDim.new(1, 0)
    KnobUICorner.Parent = knob
    
    local toggled = false
    toggle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            toggled = not toggled
            local pos = toggled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
            local color = toggled and Color3.fromRGB(60, 200, 60) or Color3.fromRGB(200, 60, 60)
            CreateTween(knob, {Position = pos}):Play()
            CreateTween(switch, {BackgroundColor3 = color}):Play()
            if callback then callback(toggled) end
        end
    end)
    
    return toggle
end

function Library:CreateSlider(tab, text, min, max, default, callback)
    local slider = Instance.new("Frame")
    slider.Name = text
    slider.Size = UDim2.new(1, -10, 0, 45)
    slider.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    slider.Parent = tab.Content
    
    local SliderUICorner = Instance.new("UICorner")
    SliderUICorner.CornerRadius = UDim.new(0, 6)
    SliderUICorner.Parent = slider
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -10, 0, 20)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 14
    label.Font = Enum.Font.SourceSans
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = slider
    
    local value = Instance.new("TextLabel")
    value.Size = UDim2.new(0, 30, 0, 20)
    value.Position = UDim2.new(1, -40, 0, 0)
    value.BackgroundTransparency = 1
    value.Text = tostring(default)
    value.TextColor3 = Color3.fromRGB(255, 255, 255)
    value.TextSize = 14
    value.Font = Enum.Font.SourceSans
    value.Parent = slider
    
    local sliderBar = Instance.new("Frame")
    sliderBar.Size = UDim2.new(1, -20, 0, 4)
    sliderBar.Position = UDim2.new(0, 10, 0, 30)
    sliderBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    sliderBar.Parent = slider
    
    local SliderBarUICorner = Instance.new("UICorner")
    SliderBarUICorner.CornerRadius = UDim.new(1, 0)
    SliderBarUICorner.Parent = sliderBar
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min)/(max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(60, 120, 255)
    fill.Parent = sliderBar
    
    local FillUICorner = Instance.new("UICorner")
    FillUICorner.CornerRadius = UDim.new(1, 0)
    FillUICorner.Parent = fill
    
    local function update(input)
        local pos = math.clamp((input.Position.X - sliderBar.AbsolutePosition.X) / sliderBar.AbsoluteSize.X, 0, 1)
        local val = math.floor(min + ((max - min) * pos))
        value.Text = tostring(val)
        fill.Size = UDim2.new(pos, 0, 1, 0)
        if callback then callback(val) end
    end
    
    sliderBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local connection
            connection = UserInputService.InputChanged:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseMovement then
                    update(input)
                end
            end)
            
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    connection:Disconnect()
                end
            end)
            
            update(input)
        end
    end)
    
    return slider
end

function Library:Notify(title, text, duration)
    duration = duration or 3
    
    local notification = Instance.new("Frame")
    notification.Name = "Notification"
    notification.Size = UDim2.new(0, 200, 0, 60)
    notification.Position = UDim2.new(1, -220, 1, -80)
    notification.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    notification.BackgroundTransparency = 0
    notification.Parent = self.ScreenGui
    
    local NotifUICorner = Instance.new("UICorner")
    NotifUICorner.CornerRadius = UDim.new(0, 8)
    NotifUICorner.Parent = notification
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -10, 0, 25)
    titleLabel.Position = UDim2.new(0, 5, 0, 5)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = 16
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.Parent = notification
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, -10, 0, 20)
    textLabel.Position = UDim2.new(0, 5, 0, 30)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = text
    textLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    textLabel.TextSize = 14
    textLabel.Font = Enum.Font.SourceSans
    textLabel.Parent = notification
    
    CreateTween(notification, {Position = UDim2.new(1, -220, 1, -80)}):Play()
    wait(duration)
    CreateTween(notification, {Position = UDim2.new(1.5, 0, 1, -80)}):Play()
    wait(0.5)
    notification:Destroy()
end

return Library
