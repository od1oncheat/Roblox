-- UI Library with Themes and Settings
local Library = {}
Library.__index = Library

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

-- Theme Definitions
Library.Themes = {
    Default = {
        MainBackground = Color3.fromRGB(25, 25, 25),
        TabContainer = Color3.fromRGB(30, 30, 30),
        TitleBar = Color3.fromRGB(35, 35, 35),
        ElementBackground = Color3.fromRGB(40, 40, 40),
        ElementInput = Color3.fromRGB(30, 30, 30),
        AccentColor = Color3.fromRGB(60, 120, 255),
        TextColor = Color3.fromRGB(255, 255, 255)
    },
    Dark = {
        MainBackground = Color3.fromRGB(20, 20, 20),
        TabContainer = Color3.fromRGB(25, 25, 25),
        TitleBar = Color3.fromRGB(30, 30, 30),
        ElementBackground = Color3.fromRGB(35, 35, 35),
        ElementInput = Color3.fromRGB(25, 25, 25),
        AccentColor = Color3.fromRGB(90, 90, 255),
        TextColor = Color3.fromRGB(240, 240, 240)
    },
    Light = {
        MainBackground = Color3.fromRGB(240, 240, 240),
        TabContainer = Color3.fromRGB(230, 230, 230),
        TitleBar = Color3.fromRGB(220, 220, 220),
        ElementBackground = Color3.fromRGB(210, 210, 210),
        ElementInput = Color3.fromRGB(200, 200, 200),
        AccentColor = Color3.fromRGB(0, 120, 255),
        TextColor = Color3.fromRGB(40, 40, 40)
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
    self.toggleKey = toggleKey or Enum.KeyCode.RightControl
    self.theme = Library.Themes.Default
    self.keybinds = {}
    
    -- Main GUI
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "UILibrary"
    self.ScreenGui.Parent = CoreGui
    
    -- Main Frame
    self.MainFrame = Instance.new("Frame")
    self.MainFrame.Name = "MainFrame"
    self.MainFrame.Size = size or UDim2.new(0, 500, 0, 350)
    self.MainFrame.Position = UDim2.new(0.5, -250, 0.5, -175)
    self.MainFrame.BackgroundColor3 = self.theme.MainBackground
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
    self.TitleBar.BackgroundColor3 = self.theme.TitleBar
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
    self.TitleLabel.TextColor3 = self.theme.TextColor
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
    self.MinimizeButton.TextColor3 = self.theme.TextColor
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
    self.CloseButton.TextColor3 = self.theme.TextColor
    self.CloseButton.TextSize = 20
    self.CloseButton.Font = Enum.Font.SourceSansBold
    self.CloseButton.Parent = self.TitleBar
    
    -- Tab Container
    self.TabContainer = Instance.new("Frame")
    self.TabContainer.Name = "TabContainer"
    self.TabContainer.Size = UDim2.new(0, 120, 1, -30)
    self.TabContainer.Position = UDim2.new(0, 0, 0, 30)
    self.TabContainer.BackgroundColor3 = self.theme.TabContainer
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
        if input.KeyCode == self.toggleKey then
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
    
    -- Create Settings tab automatically
    self.SettingsTab = self:CreateTab("Settings")
    
    -- Add theme selector to Settings tab
    local themeNames = {}
    for themeName, _ in pairs(Library.Themes) do
        table.insert(themeNames, themeName)
    end
    
    self:CreateCombo(self.SettingsTab, "Theme", themeNames, function(selected)
        self:SetTheme(selected)
    end)
    
    return self
end

function Library:SetTheme(themeName)
    local newTheme = Library.Themes[themeName]
    if not newTheme then return end
    
    self.theme = newTheme
    
    -- Update UI colors
    self.MainFrame.BackgroundColor3 = newTheme.MainBackground
    self.TitleBar.BackgroundColor3 = newTheme.TitleBar
    self.TabContainer.BackgroundColor3 = newTheme.TabContainer
    
    -- Update all elements' colors
    for _, tab in pairs(self.Tabs) do
        for _, element in pairs(tab.Content:GetChildren()) do
            if element:IsA("Frame") then
                element.BackgroundColor3 = newTheme.ElementBackground
                
                -- Update specific element types
                if element:FindFirstChild("Input") then
                    element.Input.BackgroundColor3 = newTheme.ElementInput
                end
                
                -- Update text colors
                for _, v in pairs(element:GetDescendants()) do
                    if v:IsA("TextLabel") or v:IsA("TextButton") or v:IsA("TextBox") then
                        v.TextColor3 = newTheme.TextColor
                    end
                end
            end
        end
    end
end

function Library:CreateKeybind(tab, text, default, callback)
    local keybind = Instance.new("Frame")
    keybind.Name = text
    keybind.Size = UDim2.new(1, -10, 0, 30)
    keybind.BackgroundColor3 = self.theme.ElementBackground
    keybind.Parent = tab.Content
    
    local KeybindUICorner = Instance.new("UICorner")
    KeybindUICorner.CornerRadius = UDim.new(0, 6)
    KeybindUICorner.Parent = keybind
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, -5, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = self.theme.TextColor
    label.TextSize = 14
    label.Font = Enum.Font.SourceSans
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = keybind
    
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0.3, -5, 1, -6)
    button.Position = UDim2.new(0.7, 0, 0, 3)
    button.BackgroundColor3 = self.theme.ElementInput
    button.Text = default and default.Name or "None"
    button.TextColor3 = self.theme.TextColor
    button.TextSize = 14
    button.Font = Enum.Font.SourceSans
    button.Parent = keybind
    
    local ButtonUICorner = Instance.new("UICorner")
    ButtonUICorner.CornerRadius = UDim.new(0, 4)
    ButtonUICorner.Parent = button
    
    local listening = false
    button.MouseButton1Click:Connect(function()
        listening = true
        button.Text = "..."
        
        local connection
        connection = UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Keyboard then
                button.Text = input.KeyCode.Name
                if callback then callback(input.KeyCode) end
                listening = false
                connection:Disconnect()
            end
        end)
    end)
    
    return keybind
end

function Library:CreateTab(tabName)
    local tab = Instance.new("Frame")
    tab.Name = tabName
    tab.Size = UDim2.new(0, 100, 0, 30)
    tab.BackgroundColor3 = self.theme.ElementBackground
    tab.Parent = self.TabContainer
    
    local TabUICorner = Instance.new("UICorner")
    TabUICorner.CornerRadius = UDim.new(0, 6)
    TabUICorner.Parent = tab
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -10, 0, 20)
    label.Position = UDim2.new(0, 5, 0, 5)
    label.BackgroundTransparency = 1
    label.Text = tabName
    label.TextColor3 = self.theme.TextColor
    label.TextSize = 14
    label.Font = Enum.Font.SourceSans
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = tab
    
    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Size = UDim2.new(1, -10, 1, -40)
    content.BackgroundTransparency = 1
    content.Parent = self.TabContent
    
    tab.MouseButton1Click:Connect(function()
        for _, otherTab in pairs(self.TabContainer:GetChildren()) do
            if otherTab:IsA("Frame") then
                otherTab.BackgroundColor3 = self.theme.ElementBackground
            end
        end
        tab.BackgroundColor3 = self.theme.AccentColor
        self.ActiveTab = content
        for _, otherContent in pairs(self.TabContent:GetChildren()) do
            if otherContent:IsA("Frame") and otherContent ~= content then
                otherContent.Visible = false
            end
        end
        content.Visible = true
    end)
    
    table.insert(self.Tabs, {Tab = tab, Content = content})
    
    if not self.ActiveTab then
        self.ActiveTab = content
        tab.BackgroundColor3 = self.theme.AccentColor
        content.Visible = true
    end
    
    return {Tab = tab, Content = content}
end

function Library:CreateButton(tab, text, callback)
    local button = Instance.new("TextButton")
    button.Name = text
    button.Size = UDim2.new(1, -10, 0, 30)
    button.BackgroundColor3 = self.theme.ElementBackground
    button.Text = text
    button.TextColor3 = self.theme.TextColor
    button.TextSize = 14
    button.Font = Enum.Font.SourceSans
    button.Parent = tab.Content
    
    local ButtonUICorner = Instance.new("UICorner")
    ButtonUICorner.CornerRadius = UDim.new(0, 6)
    ButtonUICorner.Parent = button
    
    button.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)
    
    return button
end

function Library:CreateToggle(tab, text, callback)
    local toggle = Instance.new("Frame")
    toggle.Name = text
    toggle.Size = UDim2.new(1, -10, 0, 30)
    toggle.BackgroundColor3 = self.theme.ElementBackground
    toggle.Parent = tab.Content
    
    local ToggleUICorner = Instance.new("UICorner")
    ToggleUICorner.CornerRadius = UDim.new(0, 6)
    ToggleUICorner.Parent = toggle
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -40, 1, 0)
    label.Position = UDim2.new(0, 35, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = self.theme.TextColor
    label.TextSize = 14
    label.Font = Enum.Font.SourceSans
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = toggle
    
    local box = Instance.new("Frame")
    box.Size = UDim2.new(0, 20, 0, 20)
    box.Position = UDim2.new(0, 5, 0.5, -10)
    box.BackgroundColor3 = self.theme.ElementInput
    box.Parent = toggle
    
    local BoxUICorner = Instance.new("UICorner")
    BoxUICorner.CornerRadius = UDim.new(0, 4)
    BoxUICorner.Parent = box
    
    local check = Instance.new("Frame")
    check.Size = UDim2.new(0.8, 0, 0.8, 0)
    check.Position = UDim2.new(0.1, 0, 0.1, 0)
    check.BackgroundColor3 = self.theme.AccentColor
    check.BackgroundTransparency = 1
    check.Parent = box
    
    local CheckUICorner = Instance.new("UICorner")
    CheckUICorner.CornerRadius = UDim.new(0, 3)
    CheckUICorner.Parent = check
    
    local checked = false
    toggle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            checked = not checked
            CreateTween(check, {BackgroundTransparency = checked and 0 or 1}):Play()
            if callback then callback(checked) end
        end
    end)
    
    return toggle
end

function Library:CreateSlider(tab, text, min, max, default, callback)
    local slider = Instance.new("Frame")
    slider.Name = text
    slider.Size = UDim2.new(1, -10, 0, 30)
    slider.BackgroundColor3 = self.theme.ElementBackground
    slider.Parent = tab.Content
    
    local SliderUICorner = Instance.new("UICorner")
    SliderUICorner.CornerRadius = UDim.new(0, 6)
    SliderUICorner.Parent = slider
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, -5, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = self.theme.TextColor
    label.TextSize = 14
    label.Font = Enum.Font.SourceSans
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = slider
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0.3, -5, 1, 0)
    valueLabel.Position = UDim2.new(0.7, 0, 0, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(default)
    valueLabel.TextColor3 = self.theme.TextColor
    valueLabel.TextSize = 14
    valueLabel.Font = Enum.Font.SourceSans
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Parent = slider
    
    local sliderBar = Instance.new("Frame")
    sliderBar.Size = UDim2.new(1, -20, 0, 10)
    sliderBar.Position = UDim2.new(0, 10, 1, -15)
    sliderBar.BackgroundColor3 = self.theme.ElementInput
    sliderBar.Parent = slider
    
    local SliderBarUICorner = Instance.new("UICorner")
    SliderBarUICorner.CornerRadius = UDim.new(0, 4)
    SliderBarUICorner.Parent = sliderBar
    
    local sliderHandle = Instance.new("Frame")
    sliderHandle.Size = UDim2.new(0, 10, 1, 0)
    sliderHandle.Position = UDim2.new((default - min) / (max - min), 0, 0, 0)
    sliderHandle.BackgroundColor3 = self.theme.AccentColor
    sliderHandle.Parent = sliderBar
    
    local SliderHandleUICorner = Instance.new("UICorner")
    SliderHandleUICorner.CornerRadius = UDim.new(0, 4)
    SliderHandleUICorner.Parent = sliderHandle
    
    local dragging = false
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
            dragStart = input.Position
        end
    end)
    
    game:GetService("RunService").RenderStepped:Connect(function()
        if dragging then
            local delta = dragStart.X - startPos.X
            local newValue = min + (max - min) * math.clamp((sliderHandle.Position.X.Offset + delta) / (sliderBar.Size.X.Offset - sliderHandle.Size.X.Offset), 0, 1)
            valueLabel.Text = tostring(math.floor(newValue + 0.5))
            sliderHandle.Position = UDim2.new((newValue - min) / (max - min), 0, 0, 0)
            if callback then callback(newValue) end
        end
    end)
    
    return slider
end

function Library:CreateTextBox(tab, text, placeholder, callback)
    local textbox = Instance.new("Frame")
    textbox.Name = text
    textbox.Size = UDim2.new(1, -10, 0, 45)
    textbox.BackgroundColor3 = self.theme.ElementBackground
    textbox.Parent = tab.Content
    
    local TextBoxUICorner = Instance.new("UICorner")
    TextBoxUICorner.CornerRadius = UDim.new(0, 6)
    TextBoxUICorner.Parent = textbox
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -10, 0, 20)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = self.theme.TextColor
    label.TextSize = 14
    label.Font = Enum.Font.SourceSans
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = textbox
    
    local input = Instance.new("TextBox")
    input.Size = UDim2.new(1, -20, 0, 20)
    input.Position = UDim2.new(0, 10, 0, 20)
    input.BackgroundColor3 = self.theme.ElementInput
    input.Text = ""
    input.PlaceholderText = placeholder or "Enter text..."
    input.TextColor3 = self.theme.TextColor
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
    label.Size = UDim2.new(1, -10, 0, 25)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = self.theme.TextColor
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
    colorPicker.BackgroundColor3 = self.theme.ElementBackground
    colorPicker.Parent = tab.Content
    
    local ColorPickerUICorner = Instance.new("UICorner")
    ColorPickerUICorner.CornerRadius = UDim.new(0, 6)
    ColorPickerUICorner.Parent = colorPicker
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -60, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = self.theme.TextColor
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
    checkbox.BackgroundColor3 = self.theme.ElementBackground
    checkbox.Parent = tab.Content
    
    local CheckboxUICorner = Instance.new("UICorner")
    CheckboxUICorner.CornerRadius = UDim.new(0, 6)
    CheckboxUICorner.Parent = checkbox
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -40, 1, 0)
    label.Position = UDim2.new(0, 35, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = self.theme.TextColor
    label.TextSize = 14
    label.Font = Enum.Font.SourceSans
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = checkbox
    
    local box = Instance.new("Frame")
    box.Size = UDim2.new(0, 20, 0, 20)
    box.Position = UDim2.new(0, 5, 0.5, -10)
    box.BackgroundColor3 = self.theme.ElementInput
    box.Parent = checkbox
    
    local BoxUICorner = Instance.new("UICorner")
    BoxUICorner.CornerRadius = UDim.new(0, 4)
    BoxUICorner.Parent = box
    
    local check = Instance.new("Frame")
    check.Size = UDim2.new(0.8, 0, 0.8, 0)
    check.Position = UDim2.new(0.1, 0, 0.1, 0)
    check.BackgroundColor3 = self.theme.AccentColor
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
    combo.BackgroundColor3 = self.theme.ElementBackground
    combo.Parent = tab.Content
    
    local ComboUICorner = Instance.new("UICorner")
    ComboUICorner.CornerRadius = UDim.new(0, 6)
    ComboUICorner.Parent = combo
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.5, -5, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = self.theme.TextColor
    label.TextSize = 14
    label.Font = Enum.Font.SourceSans
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = combo
    
    local dropButton = Instance.new("TextButton")
    dropButton.Size = UDim2.new(0.5, -5, 1, -6)
    dropButton.Position = UDim2.new(0.5, 0, 0, 3)
    dropButton.BackgroundColor3 = self.theme.ElementInput
    dropButton.Text = options[1] or "Select"
    dropButton.TextColor3 = self.theme.TextColor
    dropButton.TextSize = 14
    dropButton.Font = Enum.Font.SourceSans
    dropButton.Parent = combo
    
    local DropButtonUICorner = Instance.new("UICorner")
    DropButtonUICorner.CornerRadius = UDim.new(0, 4)
    DropButtonUICorner.Parent = dropButton
    
    local dropFrame = Instance.new("Frame")
    dropFrame.Size = UDim2.new(1, 0, 0, #options * 25)
    dropFrame.Position = UDim2.new(0, 0, 1, 5)
    dropFrame.BackgroundColor3 = self.theme.ElementBackground
    dropFrame.Visible = false
    dropFrame.ZIndex = 10
    dropFrame.Parent = combo
    
    local DropFrameUICorner = Instance.new("UICorner")
    DropFrameUICorner.CornerRadius = UDim.new(0, 6)
    DropFrameUICorner.Parent = dropFrame
    
    for i, option in ipairs(options) do
        local optionButton = Instance.new("TextButton")
        optionButton.Size = UDim2.new(1, -10, 0, 20)
        optionButton.Position = UDim2.new(0, 5, 0, (i-1) * 25 + 2)
        optionButton.BackgroundColor3 = self.theme.ElementInput
        optionButton.Text = option
        optionButton.TextColor3 = self.theme.TextColor
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
    notification.Name = "Notification"
    notification.Size = UDim2.new(0, 300, 0, 50)
    notification.Position = UDim2.new(0.5, -150, 1, -60)
    notification.BackgroundColor3 = self.theme.ElementBackground
    notification.Parent = self.ScreenGui
    
    local NotificationUICorner = Instance.new("UICorner")
    NotificationUICorner.CornerRadius = UDim.new(0, 6)
    NotificationUICorner.Parent = notification
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(0.4, -5, 1, 0)
    titleLabel.Position = UDim2.new(0, 10, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = self.theme.TextColor
    titleLabel.TextSize = 14
    titleLabel.Font = Enum.Font.SourceSans
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = notification
    
    local messageLabel = Instance.new("TextLabel")
    messageLabel.Size = UDim2.new(0.6, -5, 1, 0)
    messageLabel.Position = UDim2.new(0.4, 0, 0, 0)
    messageLabel.BackgroundTransparency = 1
    messageLabel.Text = message
    messageLabel.TextColor3 = self.theme.TextColor
    messageLabel.TextSize = 14
    messageLabel.Font = Enum.Font.SourceSans
    messageLabel.TextXAlignment = Enum.TextXAlignment.Left
    messageLabel.Parent = notification
    
    wait(duration)
    notification:Destroy()
end

return Library
