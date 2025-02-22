-- UI Library
local Library = {}
Library.__index = Library

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

-- Utility Functions
local function CreateTween(instance, properties, duration, style, direction)
    local tweenInfo = TweenInfo.new(duration or 0.3, style or Enum.EasingStyle.Quad, direction or Enum.EasingDirection.Out)
    local tween = TweenService:Create(instance, tweenInfo, properties)
    return tween
end

-- Main Library Functions
function Library.new(title, size, toggleKey)
    local self = setmetatable({}, Library)
    toggleKey = toggleKey or Enum.KeyCode.RightControl
    
    -- Main GUI
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "UILibrary"
    self.ScreenGui.Parent = CoreGui
    
    -- Main Frame
    self.MainFrame = Instance.new("Frame")
    self.MainFrame.Name = "MainFrame"
    self.MainFrame.Size = size or UDim2.new(0, 500, 0, 350)
    self.MainFrame.Position = UDim2.new(0.5, -250, 0.5, -175)
    self.MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
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
    self.TitleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
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
    self.TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
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
    self.MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
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
    self.CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    self.CloseButton.TextSize = 20
    self.CloseButton.Font = Enum.Font.SourceSansBold
    self.CloseButton.Parent = self.TitleBar
    
    -- Tab Container
    self.TabContainer = Instance.new("Frame")
    self.TabContainer.Name = "TabContainer"
    self.TabContainer.Size = UDim2.new(0, 120, 1, -30)
    self.TabContainer.Position = UDim2.new(0, 0, 0, 30)
    self.TabContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
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
        if input.KeyCode == toggleKey then
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
    
    return self
end

-- Continue with existing functions like CreateTab, CreateButton, CreateToggle, CreateSlider...

function Library:CreateTextBox(tab, text, placeholder, callback)
    local textbox = Instance.new("Frame")
    textbox.Name = text
    textbox.Size = UDim2.new(1, -10, 0, 45)
    textbox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    textbox.Parent = tab.Content
    
    local TextBoxUICorner = Instance.new("UICorner")
    TextBoxUICorner.CornerRadius = UDim.new(0, 6)
    TextBoxUICorner.Parent = textbox
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -10, 0, 20)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
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
    input.TextColor3 = Color3.fromRGB(255, 255, 255)
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
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
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
    colorPicker.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    colorPicker.Parent = tab.Content
    
    local ColorPickerUICorner = Instance.new("UICorner")
    ColorPickerUICorner.CornerRadius = UDim.new(0, 6)
    ColorPickerUICorner.Parent = colorPicker
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -60, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
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
    checkbox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    checkbox.Parent = tab.Content
    
    local CheckboxUICorner = Instance.new("UICorner")
    CheckboxUICorner.CornerRadius = UDim.new(0, 6)
    CheckboxUICorner.Parent = checkbox
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -40, 1, 0)
    label.Position = UDim2.new(0, 35, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
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
    combo.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    combo.Parent = tab.Content
    
    local ComboUICorner = Instance.new("UICorner")
    ComboUICorner.CornerRadius = UDim.new(0, 6)
    ComboUICorner.Parent = combo
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.5, -5, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 14
    label.Font = Enum.Font.SourceSans
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = combo
    
    local dropButton = Instance.new("TextButton")
    dropButton.Size = UDim2.new(0.5, -5, 1, -6)
    dropButton.Position = UDim2.new(0.5, 0, 0, 3)
    dropButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    dropButton.Text = options[1] or "Select"
    dropButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    dropButton.TextSize = 14
    dropButton.Font = Enum.Font.SourceSans
    dropButton.Parent = combo
    
    local DropButtonUICorner = Instance.new("UICorner")
    DropButtonUICorner.CornerRadius = UDim.new(0, 4)
    DropButtonUICorner.Parent = dropButton
    
    local dropFrame = Instance.new("Frame")
    dropFrame.Size = UDim2.new(1, 0, 0, #options * 25)
    dropFrame.Position = UDim2.new(0, 0, 1, 5)
    dropFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
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
        optionButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        optionButton.Text = option
        optionButton.TextColor3 = Color3.fromRGB(255, 255, 255)
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

return Library
