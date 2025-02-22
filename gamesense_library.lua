-- UI Library with Enhanced Features
local Library = {}
Library.__index = Library

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

-- Theme System
local Themes = {
    Default = {
        Background = Color3.fromRGB(25, 25, 25),
        Secondary = Color3.fromRGB(30, 30, 30),
        TopBar = Color3.fromRGB(35, 35, 35),
        TextColor = Color3.fromRGB(255, 255, 255),
        AccentColor = Color3.fromRGB(60, 120, 255)
    },
    Dark = {
        Background = Color3.fromRGB(20, 20, 20),
        Secondary = Color3.fromRGB(25, 25, 25),
        TopBar = Color3.fromRGB(30, 30, 30),
        TextColor = Color3.fromRGB(240, 240, 240),
        AccentColor = Color3.fromRGB(90, 90, 255)
    },
    Light = {
        Background = Color3.fromRGB(240, 240, 240),
        Secondary = Color3.fromRGB(250, 250, 250),
        TopBar = Color3.fromRGB(225, 225, 225),
        TextColor = Color3.fromRGB(40, 40, 40),
        AccentColor = Color3.fromRGB(0, 120, 255)
    }
}

-- Utility Functions
local function CreateTween(instance, properties, duration, style, direction)
    local tweenInfo = TweenInfo.new(duration or 0.3, style or Enum.EasingStyle.Quad, direction or Enum.EasingDirection.Out)
    local tween = TweenService:Create(instance, tweenInfo, properties)
    return tween
end

function Library.new(title, size, toggleKey)
    local self = setmetatable({}, Library)
    self.ToggleKey = toggleKey or Enum.KeyCode.RightControl
    self.Theme = Themes.Default
    self.CurrentKeybinds = {}
    
    -- Create the main GUI structure
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "UILibrary"
    self.ScreenGui.Parent = CoreGui
    
    -- Main Frame
    self.MainFrame = Instance.new("Frame")
    self.MainFrame.Name = "MainFrame"
    self.MainFrame.Size = size or UDim2.new(0, 500, 0, 350)
    self.MainFrame.Position = UDim2.new(0.5, -250, 0.5, -175)
    self.MainFrame.BackgroundColor3 = self.Theme.Background
    self.MainFrame.BorderSizePixel = 0
    self.MainFrame.Parent = self.ScreenGui
    
    -- Round corners
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 8)
    UICorner.Parent = self.MainFrame
    
    -- Title Bar
    self.TitleBar = Instance.new("Frame")
    self.TitleBar.Name = "TitleBar"
    self.TitleBar.Size = UDim2.new(1, 0, 0, 30)
    self.TitleBar.BackgroundColor3 = self.Theme.TopBar
    self.TitleBar.BorderSizePixel = 0
    self.TitleBar.Parent = self.MainFrame
    
    local TitleUICorner = Instance.new("UICorner")
    TitleUICorner.CornerRadius = UDim.new(0, 8)
    TitleUICorner.Parent = self.TitleBar
    
    self.TitleLabel = Instance.new("TextLabel")
    self.TitleLabel.Name = "Title"
    self.TitleLabel.Text = title or "UI Library"
    self.TitleLabel.Size = UDim2.new(1, -100, 1, 0)
    self.TitleLabel.Position = UDim2.new(0, 10, 0, 0)
    self.TitleLabel.BackgroundTransparency = 1
    self.TitleLabel.TextColor3 = self.Theme.TextColor
    self.TitleLabel.TextSize = 16
    self.TitleLabel.Font = Enum.Font.SourceSansBold
    self.TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    self.TitleLabel.Parent = self.TitleBar
    
    -- Minimize Button
    self.MinimizeButton = Instance.new("TextButton")
    self.MinimizeButton.Name = "MinimizeButton"
    self.MinimizeButton.Size = UDim2.new(0, 30, 0, 30)
    self.MinimizeButton.Position = UDim2.new(1, -70, 0, 0)
    self.MinimizeButton.BackgroundTransparency = 1
    self.MinimizeButton.Text = "+"
    self.MinimizeButton.TextColor3 = self.Theme.TextColor
    self.MinimizeButton.TextSize = 20
    self.MinimizeButton.Font = Enum.Font.SourceSansBold
    self.MinimizeButton.Parent = self.TitleBar
    
    -- Close Button
    self.CloseButton = Instance.new("TextButton")
    self.CloseButton.Name = "CloseButton"
    self.CloseButton.Size = UDim2.new(0, 30, 0, 30)
    self.CloseButton.Position = UDim2.new(1, -30, 0, 0)
    self.CloseButton.BackgroundTransparency = 1
    self.CloseButton.Text = "×"
    self.CloseButton.TextColor3 = self.Theme.TextColor
    self.CloseButton.TextSize = 20
    self.CloseButton.Font = Enum.Font.SourceSansBold
    self.CloseButton.Parent = self.TitleBar
    
    -- Tab Container
    self.TabContainer = Instance.new("Frame")
    self.TabContainer.Name = "TabContainer"
    self.TabContainer.Size = UDim2.new(0, 120, 1, -30)
    self.TabContainer.Position = UDim2.new(0, 0, 0, 30)
    self.TabContainer.BackgroundColor3 = self.Theme.Secondary
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
    self.Minimized = false
    self.Hidden = false
    
    -- Toggle Key
    UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == self.ToggleKey then
            self.Hidden = not self.Hidden
            CreateTween(self.MainFrame, {Position = self.Hidden and UDim2.new(1.5, 0, 0.5, -175) or UDim2.new(0.5, -250, 0.5, -175)}):Play()
        end
    end)
    
    -- Minimize Button Logic
    self.MinimizeButton.MouseButton1Click:Connect(function()
        self.Minimized = not self.Minimized
        if self.Minimized then
            CreateTween(self.MainFrame, {Size = UDim2.new(0, 400, 0, 30)}):Play()
            self.TabContainer.Visible = false
            self.TabContent.Visible = false
            self.MinimizeButton.Text = "-"
        else
            CreateTween(self.MainFrame, {Size = size or UDim2.new(0, 500, 0, 350)}):Play()
            self.TabContainer.Visible = true
            self.TabContent.Visible = true
            self.MinimizeButton.Text = "+"
        end
    end)
    
    -- Close Button Logic
    self.CloseButton.MouseButton1Click:Connect(function()
        self.Hidden = true
        CreateTween(self.MainFrame, {Position = UDim2.new(1.5, 0, 0.5, -175)}):Play()
    end)
    
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
    
    -- Create Settings Tab automatically
    self.SettingsTab = self:CreateTab("Settings")
    self:CreateCombo(self.SettingsTab, "Theme", {"Default", "Dark", "Light"}, function(selected)
        self:SetTheme(selected)
    end)
    
    -- Keybind Manager
    self:CreateLabel(self.SettingsTab, "Keybinds")
    self.KeybindContainer = Instance.new("Frame")
    self.KeybindContainer.Size = UDim2.new(1, -10, 0, 200)
    self.KeybindContainer.BackgroundTransparency = 1
    self.KeybindContainer.Parent = self.SettingsTab.Content
    
    return self
end

function Library:SetTheme(themeName)
    local newTheme = Themes[themeName]
    if not newTheme then return end
    
    self.Theme = newTheme
    
    -- Update UI colors
    self.MainFrame.BackgroundColor3 = newTheme.Background
    self.TitleBar.BackgroundColor3 = newTheme.TopBar
    self.TabContainer.BackgroundColor3 = newTheme.Secondary
    
    -- Update all elements' colors
    for _, tab in pairs(self.Tabs) do
        for _, element in pairs(tab.Content:GetChildren()) do
            if element:IsA("Frame") then
                element.BackgroundColor3 = newTheme.Secondary
                for _, child in pairs(element:GetDescendants()) do
                    if child:IsA("TextLabel") or child:IsA("TextButton") then
                        child.TextColor3 = newTheme.TextColor
                    end
                end
            end
        end
    end
end

function Library:SetKeybind(name, key, callback)
    self.CurrentKeybinds[name] = {
        Key = key,
        Callback = callback
    }
    
    -- Create keybind display in settings
    local keybindFrame = Instance.new("Frame")
    keybindFrame.Size = UDim2.new(1, 0, 0, 30)
    keybindFrame.BackgroundColor3 = self.Theme.Secondary
    keybindFrame.Parent = self.KeybindContainer
    
    local label = Instance.new("TextLabel")
    label.Text = name
    label.Size = UDim2.new(0.5, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = self.Theme.TextColor
    label.Parent = keybindFrame
    
    local keyButton = Instance.new("TextButton")
    keyButton.Text = key.Name
    keyButton.Size = UDim2.new(0.5, 0, 1, 0)
    keyButton.Position = UDim2.new(0.5, 0, 0, 0)
    keyButton.BackgroundColor3 = self.Theme.Secondary
    keyButton.TextColor3 = self.Theme.TextColor
    keyButton.Parent = keybindFrame
    
    -- Keybind changing logic
    local changing = false
    keyButton.MouseButton1Click:Connect(function()
        changing = true
        keyButton.Text = "Press any key..."
        
        local connection
        connection = UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Keyboard then
                self.CurrentKeybinds[name].Key = input.KeyCode
                keyButton.Text = input.KeyCode.Name
                changing = false
                connection:Disconnect()
            end
        end)
    end)
end

function Library:CreateTab(tabName)
    local tab = Instance.new("Frame")
    tab.Name = tabName
    tab.Size = UDim2.new(0, 100, 0, 30)
    tab.BackgroundColor3 = self.Theme.Secondary
    tab.Parent = self.TabContainer
    
    local TabUICorner = Instance.new("UICorner")
    TabUICorner.CornerRadius = UDim.new(0, 6)
    TabUICorner.Parent = tab
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -10, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = tabName
    label.TextColor3 = self.Theme.TextColor
    label.TextSize = 14
    label.Font = Enum.Font.SourceSans
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = tab
    
    -- Tab Content
    tab.Content = Instance.new("Frame")
    tab.Content.Name = "Content"
    tab.Content.Size = UDim2.new(1, -10, 1, -40)
    tab.Content.BackgroundTransparency = 1
    tab.Content.Parent = self.TabContent
    
    -- Store the tab
    self.Tabs[tabName] = tab
    
    -- Update Active Tab
    if not self.ActiveTab then
        self.ActiveTab = tab
        tab.Content.Visible = true
    else
        tab.Content.Visible = false
    end
    
    -- Handle Tab switching
    tab.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            for _, t in pairs(self.Tabs) do
                t.Content.Visible = false
            end
            tab.Content.Visible = true
            self.ActiveTab = tab
        end
    end)
    
    return tab
end

function Library:CreateButton(tab, text, callback)
    local button = Instance.new("TextButton")
    button.Text = text
    button.Size = UDim2.new(1, -10, 0, 30)
    button.BackgroundColor3 = self.Theme.Secondary
    button.TextColor3 = self.Theme.TextColor
    button.Parent = tab.Content
    
    -- Add a UICorner to the button
    local ButtonUICorner = Instance.new("UICorner")
    ButtonUICorner.CornerRadius = UDim.new(0, 6)
    ButtonUICorner.Parent = button
    
    -- Connect the callback function
    button.MouseButton1Click:Connect(function()
        if callback then
            callback()
        end
    end)
    
    return button
end

function Library:CreateToggle(tab, text, callback)
    local toggle = Instance.new("Frame")
    toggle.Name = text
    toggle.Size = UDim2.new(1, -10, 0, 30)
    toggle.BackgroundColor3 = self.Theme.Secondary
    toggle.Parent = tab.Content
    
    local ToggleUICorner = Instance.new("UICorner")
    ToggleUICorner.CornerRadius = UDim.new(0, 6)
    ToggleUICorner.Parent = toggle
    
    local label = Instance.new("TextLabel")
    label.Text = text
    label.Size = UDim2.new(1, -40, 1, 0)
    label.Position = UDim2.new(0, 35, 0, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = self.Theme.TextColor
    label.TextSize = 14
    label.Font = Enum.Font.SourceSans
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = toggle
    
    local box = Instance.new("Frame")
    box.Size = UDim2.new(0, 20, 0, 20)
    box.Position = UDim2.new(0, 5, 0.5, -10)
    box.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    box.Parent = toggle
    
    local BoxUICorner = Instance.new("UICorner")
    BoxUICorner.CornerRadius = UDim.new(0, 4)
    BoxUICorner.Parent = box
    
    local check = Instance.new("Frame")
    check.Size = UDim2.new(0.8, 0, 0.8, 0)
    check.Position = UDim2.new(0.1, 0, 0.1, 0)
    check.BackgroundColor3 = Color3.fromRGB(60, 120, 255)
    check.BackgroundTransparency = 1
    check.Parent = box
    
    local CheckUICorner = Instance.new("UICorner")
    CheckUICorner.CornerRadius = UDim.new(0, 3)
    CheckUICorner.Parent = check
    
    local enabled = false
    toggle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            enabled = not enabled
            CreateTween(check, {BackgroundTransparency = enabled and 0 or 1}):Play()
            if callback then callback(enabled) end
        end
    end)
    
    return toggle
end

function Library:CreateSlider(tab, text, min, max, default, callback)
    local slider = Instance.new("Frame")
    slider.Name = text
    slider.Size = UDim2.new(1, -10, 0, 30)
    slider.BackgroundColor3 = self.Theme.Secondary
    slider.Parent = tab.Content
    
    local SliderUICorner = Instance.new("UICorner")
    SliderUICorner.CornerRadius = UDim.new(0, 6)
    SliderUICorner.Parent = slider
    
    local label = Instance.new("TextLabel")
    label.Text = text
    label.Size = UDim2.new(1, -40, 1, 0)
    label.Position = UDim2.new(0, 35, 0, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = self.Theme.TextColor
    label.TextSize = 14
    label.Font = Enum.Font.SourceSans
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = slider
    
    local sliderBar = Instance.new("Frame")
    sliderBar.Size = UDim2.new(0, 150, 0, 10)
    sliderBar.Position = UDim2.new(0, 35, 0.5, -5)
    sliderBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    sliderBar.Parent = slider
    
    local SliderBarUICorner = Instance.new("UICorner")
    SliderBarUICorner.CornerRadius = UDim.new(0, 3)
    SliderBarUICorner.Parent = sliderBar
    
    local value = Instance.new("TextLabel")
    value.Text = tostring(default)
    value.Size = UDim2.new(0, 50, 0, 20)
    value.Position = UDim2.new(0, 190, 0, 5)
    value.BackgroundTransparency = 1
    value.TextColor3 = self.Theme.TextColor
    value.TextSize = 14
    value.Font = Enum.Font.SourceSans
    value.TextXAlignment = Enum.TextXAlignment.Left
    value.Parent = slider
    
    local sliderHandle = Instance.new("Frame")
    sliderHandle.Size = UDim2.new(0, 10, 0, 10)
    sliderHandle.Position = UDim2.new(0, (default - min) / (max - min) * 150, 0, -2.5)
    sliderHandle.BackgroundColor3 = Color3.fromRGB(60, 120, 255)
    sliderHandle.Parent = sliderBar
    
    local SliderHandleUICorner = Instance.new("UICorner")
    SliderHandleUICorner.CornerRadius = UDim.new(0, 2)
    SliderHandleUICorner.Parent = sliderHandle
    
    local dragging = false
    local dragInput
    local dragStart
    local startPos
    
    sliderBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = sliderHandle.Position
        end
    end)
    
    sliderBar.InputEnded:Connect(function(input)
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
            local newX = math.clamp(startPos.X.Offset + delta.X, 0, 150)
            sliderHandle.Position = UDim2.new(0, newX, 0, startPos.Y.Offset)
            local newValue = min + (max - min) * (newX / 150)
            value.Text = tostring(math.floor(newValue))
            if callback then
                callback(newValue)
            end
        end
    end)
    
    return slider
end

function Library:CreateTextBox(tab, text, placeholder, callback)
    local textbox = Instance.new("Frame")
    textbox.Name = text
    textbox.Size = UDim2.new(1, -10, 0, 45)
    textbox.BackgroundColor3 = self.Theme.Secondary
    textbox.Parent = tab.Content
    
    local TextBoxUICorner = Instance.new("UICorner")
    TextBoxUICorner.CornerRadius = UDim.new(0, 6)
    TextBoxUICorner.Parent = textbox
    
    local label = Instance.new("TextLabel")
    label.Text = text
    label.Size = UDim2.new(1, -10, 0, 20)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = self.Theme.TextColor
    label.TextSize = 14
    label.Font = Enum.Font.SourceSans
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = textbox
    
    local input = Instance.new("TextBox")
    input.Size = UDim2.new(1, -20, 0, 20)
    input.Position = UDim2.new(0, 10, 0, 20)
    input.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    input.Text = ""
    input.PlaceholderText = placeholder or "Enter text..."
    input.TextColor3 = self.Theme.TextColor
    input.PlaceholderColor3 = Color3.fromRGB(180, 180, 180)
    input.TextSize = 14
    input.Font = Enum.Font.SourceSans
    input.Parent = textbox
    
    local InputUICorner = Instance.new("UICorner")
    InputUICorner.CornerRadius = UDim.new(0, 4)
    InputUICorner.Parent = input
    
    input.FocusLost:Connect(function(enterPressed)
        if enterPressed and callback then
            callback(input.Text)
        end
    end)
    
    return textbox
end

function Library:CreateLabel(tab, text)
    local label = Instance.new("TextLabel")
    label.Text = text
    label.Size = UDim2.new(1, -10, 0, 25)
    label.BackgroundTransparency = 1
    label.TextColor3 = self.Theme.TextColor
    label.TextSize = 14
    label.Font = Enum.Font.SourceSans
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = tab.Content
    
    return label
end

function Library:CreateColorPicker(tab, text, default, callback)
    local colorPicker = Instance.new("Frame")
    colorPicker.Name = text
    colorPicker.Size = UDim2.new(1, -10, 0, 50)
    colorPicker.BackgroundColor3 = self.Theme.Secondary
    colorPicker.Parent = tab.Content
    
    local ColorPickerUICorner = Instance.new("UICorner")
    ColorPickerUICorner.CornerRadius = UDim.new(0, 6)
    ColorPickerUICorner.Parent = colorPicker
    
    local label = Instance.new("TextLabel")
    label.Text = text
    label.Size = UDim2.new(1, -60, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = self.Theme.TextColor
    label.TextSize = 14
    label.Font = Enum.Font.SourceSans
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = colorPicker
    
    local preview = Instance.new("Frame")
    preview.Size = UDim2.new(0, 40, 0, 40)
    preview.Position = UDim2.new(1, -50, 0.5, -20)
    preview.BackgroundColor3 = default or Color3.fromRGB(255, 255, 255)
    preview.Parent = colorPicker
    
    local PreviewUICorner = Instance.new("UICorner")
    PreviewUICorner.CornerRadius = UDim.new(0, 4)
    PreviewUICorner.Parent = preview
    
    -- Add color picker functionality here
    -- This is a simplified version - you might want to add a proper color wheel
    preview.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            -- Toggle color picker UI
            if callback then callback(preview.BackgroundColor3) end
        end
    end)
    
    return colorPicker
end

function Library:CreateCheckbox(tab, text, callback)
    local checkbox = Instance.new("Frame")
    checkbox.Name = text
    checkbox.Size = UDim2.new(1, -10, 0, 30)
    checkbox.BackgroundColor3 = self.Theme.Secondary
    checkbox.Parent = tab.Content
    
    local CheckboxUICorner = Instance.new("UICorner")
    CheckboxUICorner.CornerRadius = UDim.new(0, 6)
    CheckboxUICorner.Parent = checkbox
    
    local label = Instance.new("TextLabel")
    label.Text = text
    label.Size = UDim2.new(1, -40, 1, 0)
    label.Position = UDim2.new(0, 35, 0, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = self.Theme.TextColor
    label.TextSize = 14
    label.Font = Enum.Font.SourceSans
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = checkbox
    
    local box = Instance.new("Frame")
    box.Size = UDim2.new(0, 20, 0, 20)
    box.Position = UDim2.new(0, 5, 0.5, -10)
    box.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    box.Parent = checkbox
    
    local BoxUICorner = Instance.new("UICorner")
    BoxUICorner.CornerRadius = UDim.new(0, 4)
    BoxUICorner.Parent = box
    
    local check = Instance.new("Frame")
    check.Size = UDim2.new(0.8, 0, 0.8, 0)
    check.Position = UDim2.new(0.1, 0, 0.1, 0)
    check.BackgroundColor3 = Color3.fromRGB(60, 120, 255)
    check.BackgroundTransparency = 1
    check.Parent = box
    
    local CheckUICorner = Instance.new("UICorner")
    CheckUICorner.CornerRadius = UDim.new(0, 3)
    CheckUICorner.Parent = check
    
    local checked = false
    checkbox.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            checked = not checked
            CreateTween(check, {BackgroundTransparency = checked and 0 or 1}):Play()
            if callback then callback(checked) end
        end
    end)
    
    return checkbox
end

function Library:CreateCombo(tab, text, options, callback)
    local combo = Instance.new("Frame")
    combo.Name = text
    combo.Size = UDim2.new(1, -10, 0, 30)
    combo.BackgroundColor3 = self.Theme.Secondary
    combo.Parent = tab.Content
    
    local ComboUICorner = Instance.new("UICorner")
    ComboUICorner.CornerRadius = UDim.new(0, 6)
    ComboUICorner.Parent = combo
    
    local label = Instance.new("TextLabel")
    label.Text = text
    label.Size = UDim2.new(0.5, -5, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = self.Theme.TextColor
    label.TextSize = 14
    label.Font = Enum.Font.SourceSans
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = combo
    
    local dropButton = Instance.new("TextButton")
    dropButton.Text = options[1] or "Select"
    dropButton.Size = UDim2.new(0.5, -5, 1, -6)
    dropButton.Position = UDim2.new(0.5, 0, 0, 3)
    dropButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    dropButton.TextColor3 = self.Theme.TextColor
    dropButton.TextSize = 14
    dropButton.Font = Enum.Font.SourceSans
    dropButton.Parent = combo
    
    local DropButtonUICorner = Instance.new("UICorner")
    DropButtonUICorner.CornerRadius = UDim.new(0, 4)
    DropButtonUICorner.Parent = dropButton
    
    local dropFrame = Instance.new("Frame")
    dropFrame.Size = UDim2.new(1, 0, 0, #options * 25)
    dropFrame.Position = UDim2.new(0, 0, 1, 5)
    dropFrame.BackgroundColor3 = self.Theme.Secondary
    dropFrame.Visible = false
    dropFrame.ZIndex = 10
    dropFrame.Parent = combo
    
    local DropFrameUICorner = Instance.new("UICorner")
    DropFrameUICorner.CornerRadius = UDim.new(0, 6)
    DropFrameUICorner.Parent = dropFrame
    
    for i, option in ipairs(options) do
        local optionButton = Instance.new("TextButton")
        optionButton.Text = option
        optionButton.Size = UDim2.new(1, -10, 0, 20)
        optionButton.Position = UDim2.new(0, 5, 0, (i-1) * 25 + 2)
        optionButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        optionButton.TextColor3 = self.Theme.TextColor
        optionButton.TextSize = 14
        optionButton.Font = Enum.Font.SourceSans
        optionButton.ZIndex = 11
        optionButton.Parent = dropFrame
        
        local OptionButtonUICorner = Instance.new("UICorner")
        OptionButtonUICorner.CornerRadius = UDim.new(0, 4)
        OptionButtonUICorner.Parent = optionButton
        
        optionButton.MouseButton1Click:Connect(function()
            dropButton.Text = option
            dropFrame.Visible = false
            if callback then callback(option) end
        end)
    end
    
    dropButton.MouseButton1Click:Connect(function()
        dropFrame.Visible = not dropFrame.Visible
    end)
    
    return combo
end

function Library:Notify(title, message, duration)
    local notification = Instance.new("Frame")
    notification.Size = UDim2.new(0, 200, 0, 50)
    notification.Position = UDim2.new(0, 10, 1, -60)
    notification.BackgroundTransparency = 1
    notification.Parent = self.ScreenGui
    
    local label = Instance.new("TextLabel")
    label.Text = title
    label.Size = UDim2.new(1, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.TextColor3 = self.Theme.TextColor
    label.TextSize = 14
    label.Font = Enum.Font.SourceSansBold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = notification
    
    local messageLabel = Instance.new("TextLabel")
    messageLabel.Text = message
    messageLabel.Size = UDim2.new(1, 0, 0, 30)
    messageLabel.Position = UDim2.new(0, 0, 0, 20)
    messageLabel.BackgroundTransparency = 1
    messageLabel.TextColor3 = self.Theme.TextColor
    messageLabel.TextSize = 14
    messageLabel.Font = Enum.Font.SourceSans
    messageLabel.TextXAlignment = Enum.TextXAlignment.Left
    messageLabel.Parent = notification
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundTransparency = 1
    frame.Parent = notification
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 6)
    UICorner.Parent = frame
    
    local backgroundColor = Instance.new("Frame")
    backgroundColor.Size = UDim2.new(1, 0, 1, 0)
    backgroundColor.BackgroundTransparency = 0.8
    backgroundColor.BackgroundColor3 = self.Theme.Secondary
    backgroundColor.Parent = frame
    
    wait(duration)
    notification:Destroy()
end

return Library
