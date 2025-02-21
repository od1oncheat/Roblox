-- Orion-Inspired UI Library for Roblox
-- Advanced animations, rounded corners, and smooth interactions
-- Version 2.0.0

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local TextService = game:GetService("TextService")

local Library = {
    Registry = {},
    Connections = {},
    Elements = {},
    Theme = {
        Primary = Color3.fromRGB(24, 24, 36),
        Secondary = Color3.fromRGB(32, 32, 48),
        Accent = Color3.fromRGB(88, 140, 255),
        TextColor = Color3.fromRGB(255, 255, 255),
        DimText = Color3.fromRGB(175, 175, 175),
        Stroke = Color3.fromRGB(60, 60, 80),
        Background = Color3.fromRGB(16, 16, 24),
        Hover = Color3.fromRGB(40, 40, 60),
        SliderBackground = Color3.fromRGB(48, 48, 68),
    },
    Flags = {},
    Easing = {
        Linear = Enum.EasingStyle.Linear,
        Quad = Enum.EasingStyle.Quad,
        Cubic = Enum.EasingStyle.Cubic,
        Quart = Enum.EasingStyle.Quart,
        Quint = Enum.EasingStyle.Quint,
        Sine = Enum.EasingStyle.Sine,
        Back = Enum.EasingStyle.Back,
        Bounce = Enum.EasingStyle.Bounce,
    },
    Settings = {
        DragSpeed = 0.06,
        AnimationDuration = 0.2,
        EasingStyle = Enum.EasingStyle.Quad,
        RippleEnabled = true,
        RippleDuration = 0.4,
        SmoothScrolling = true,
        BlurEffect = true,
        TooltipDelay = 0.4,
    }
}

-- Utility Functions
local function CreateTween(instance, properties, duration, style, direction)
    local tween = TweenService:Create(
        instance,
        TweenInfo.new(
            duration or Library.Settings.AnimationDuration,
            style or Library.Settings.EasingStyle,
            direction or Enum.EasingDirection.Out
        ),
        properties
    )
    return tween
end

local function CreateRipple(parent)
    if not Library.Settings.RippleEnabled then return end
    
    local ripple = Instance.new("Frame")
    ripple.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ripple.BackgroundTransparency = 0.7
    ripple.BorderSizePixel = 0
    ripple.AnchorPoint = Vector2.new(0.5, 0.5)
    ripple.Size = UDim2.new(0, 0, 0, 0)
    ripple.Position = UDim2.new(0.5, 0, 0.5, 0)
    ripple.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = ripple

    local targetSize = UDim2.new(2, 0, 2, 0)
    local tween = CreateTween(ripple, {
        Size = targetSize,
        BackgroundTransparency = 1
    }, Library.Settings.RippleDuration, Enum.EasingStyle.Quad)

    tween:Play()
    tween.Completed:Connect(function()
        ripple:Destroy()
    end)
end

local function ApplyTextBounds(textLabel)
    local textSize = TextService:GetTextSize(
        textLabel.Text,
        textLabel.TextSize,
        textLabel.Font,
        Vector2.new(math.huge, textLabel.TextSize)
    )
    textLabel.Size = UDim2.new(0, textSize.X, 0, textSize.Y)
end

local function CreateStroke(parent, color, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or Library.Theme.Stroke
    stroke.Thickness = thickness or 1.5
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = parent
    return stroke
end

local function CreateShadow(parent, elevation)
    local shadow = Instance.new("ImageLabel")
    shadow.Image = "rbxassetid://7912134082"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.7
    shadow.BackgroundTransparency = 1
    shadow.Size = UDim2.new(1, elevation * 2, 1, elevation * 2)
    shadow.Position = UDim2.new(0, -elevation, 0, -elevation)
    shadow.ZIndex = parent.ZIndex - 1
    shadow.Parent = parent
    return shadow
end

-- Window Creation
function Library:CreateWindow(title, config)
    config = config or {}
    
    local Window = {
        Minimized = false,
        Tabs = {},
        ActiveTab = nil,
        Dragging = false,
        DragStart = Vector2.new(),
        StartPosition = UDim2.new()
    }

    -- Create main window frame
    Window.Main = Instance.new("Frame")
    Window.Main.Name = "OrionLibrary"
    Window.Main.Size = UDim2.new(0, 600, 0, 400)
    Window.Main.Position = UDim2.new(0.5, -300, 0.5, -200)
    Window.Main.BackgroundColor3 = Library.Theme.Background
    Window.Main.BorderSizePixel = 0
    Window.Main.Parent = CoreGui

    -- Apply corner radius
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = Window.Main

    -- Create window shadow
    CreateShadow(Window.Main, 15)

    -- Create title bar
    Window.TitleBar = Instance.new("Frame")
    Window.TitleBar.Name = "TitleBar"
    Window.TitleBar.Size = UDim2.new(1, 0, 0, 40)
    Window.TitleBar.BackgroundColor3 = Library.Theme.Primary
    Window.TitleBar.BorderSizePixel = 0
    Window.TitleBar.Parent = Window.Main

    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 8)
    titleCorner.Parent = Window.TitleBar

    -- Create title text
    Window.Title = Instance.new("TextLabel")
    Window.Title.Text = title or "Orion Library"
    Window.Title.TextColor3 = Library.Theme.TextColor
    Window.Title.TextSize = 16
    Window.Title.Font = Enum.Font.GothamBold
    Window.Title.Position = UDim2.new(0, 15, 0, 0)
    Window.Title.Size = UDim2.new(1, -30, 1, 0)
    Window.Title.BackgroundTransparency = 1
    Window.Title.TextXAlignment = Enum.TextXAlignment.Left
    Window.Title.Parent = Window.TitleBar

    -- Create control buttons
    Window.Controls = Instance.new("Frame")
    Window.Controls.Name = "Controls"
    Window.Controls.Size = UDim2.new(0, 100, 1, 0)
    Window.Controls.Position = UDim2.new(1, -100, 0, 0)
    Window.Controls.BackgroundTransparency = 1
    Window.Controls.Parent = Window.TitleBar

    -- Create minimize button
    Window.MinimizeBtn = Instance.new("TextButton")
    Window.MinimizeBtn.Size = UDim2.new(0, 30, 0, 30)
    Window.MinimizeBtn.Position = UDim2.new(0, 5, 0.5, -15)
    Window.MinimizeBtn.BackgroundColor3 = Library.Theme.Secondary
    Window.MinimizeBtn.Text = "-"
    Window.MinimizeBtn.TextColor3 = Library.Theme.TextColor
    Window.MinimizeBtn.TextSize = 20
    Window.MinimizeBtn.Font = Enum.Font.GothamBold
    Window.MinimizeBtn.Parent = Window.Controls

    local minimizeCorner = Instance.new("UICorner")
    minimizeCorner.CornerRadius = UDim.new(0, 6)
    minimizeCorner.Parent = Window.MinimizeBtn

    -- Create close button
    Window.CloseBtn = Instance.new("TextButton")
    Window.CloseBtn.Size = UDim2.new(0, 30, 0, 30)
    Window.CloseBtn.Position = UDim2.new(1, -35, 0.5, -15)
    Window.CloseBtn.BackgroundColor3 = Library.Theme.Secondary
    Window.CloseBtn.Text = "×"
    Window.CloseBtn.TextColor3 = Library.Theme.TextColor
    Window.CloseBtn.TextSize = 20
    Window.CloseBtn.Font = Enum.Font.GothamBold
    Window.CloseBtn.Parent = Window.Controls

    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 6)
    closeCorner.Parent = Window.CloseBtn

    -- Create tab container
    Window.TabContainer = Instance.new("Frame")
    Window.TabContainer.Name = "TabContainer"
    Window.TabContainer.Size = UDim2.new(1, -20, 1, -60)
    Window.TabContainer.Position = UDim2.new(0, 10, 0, 50)
    Window.TabContainer.BackgroundTransparency = 1
    Window.TabContainer.Parent = Window.Main

    -- Create tab buttons
    Window.TabButtons = Instance.new("Frame")
    Window.TabButtons.Name = "TabButtons"
    Window.TabButtons.Size = UDim2.new(0, 140, 1, 0)
    Window.TabButtons.BackgroundColor3 = Library.Theme.Secondary
    Window.TabButtons.BorderSizePixel = 0
    Window.TabButtons.Parent = Window.TabContainer

    local tabButtonsCorner = Instance.new("UICorner")
    tabButtonsCorner.CornerRadius = UDim.new(0, 6)
    tabButtonsCorner.Parent = Window.TabButtons

    -- Create tab button list
    Window.TabButtonList = Instance.new("ScrollingFrame")
    Window.TabButtonList.Name = "TabButtonList"
    Window.TabButtonList.Size = UDim2.new(1, -10, 1, -10)
    Window.TabButtonList.Position = UDim2.new(0, 5, 0, 5)
    Window.TabButtonList.BackgroundTransparency = 1
    Window.TabButtonList.ScrollBarThickness = 2
    Window.TabButtonList.ScrollBarImageColor3 = Library.Theme.Accent
    Window.TabButtonList.Parent = Window.TabButtons

    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 5)
    listLayout.Parent = Window.TabButtonList

    -- Create tab content
    Window.TabContent = Instance.new("Frame")
    Window.TabContent.Name = "TabContent"
    Window.TabContent.Size = UDim2.new(1, -160, 1, 0)
    Window.TabContent.Position = UDim2.new(0, 150, 0, 0)
    Window.TabContent.BackgroundColor3 = Library.Theme.Secondary
    Window.TabContent.BorderSizePixel = 0
    Window.TabContent.Parent = Window.TabContainer

    local contentCorner = Instance.new("UICorner")
    contentCorner.CornerRadius = UDim.new(0, 6)
    contentCorner.Parent = Window.TabContent

    -- Window dragging
    Window.TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            Window.Dragging = true
            Window.DragStart = input.Position
            Window.StartPosition = Window.Main.Position
        end
    end)

    Window.TitleBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            Window.Dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if Window.Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - Window.DragStart
            local targetPosition = UDim2.new(
                Window.StartPosition.X.Scale,
                Window.StartPosition.X.Offset + delta.X,
                Window.StartPosition.Y.Scale,
                Window.StartPosition.Y.Offset + delta.Y
            )
            
            local smoothDelta = Library.Settings.DragSpeed
            Window.Main.Position = Window.Main.Position:Lerp(targetPosition, smoothDelta)
        end
    end)

    -- Minimize functionality
    Window.MinimizeBtn.MouseButton1Click:Connect(function()
        Window.Minimized = not Window.Minimized
        
        CreateRipple(Window.MinimizeBtn)
        
        if Window.Minimized then
            CreateTween(Window.Main, {
                Size = UDim2.new(0, 600, 0, 40)
            }):Play()
            
            CreateTween(Window.TabContainer, {
                Transparency = 1
            }):Play()
        else
            CreateTween(Window.Main, {
                Size = UDim2.new(0, 600, 0, 400)
            }):Play()
            
            CreateTween(Window.TabContainer, {
                Transparency = 0
            }):Play()
        end
    end)

    -- Close functionality
    Window.CloseBtn.MouseButton1Click:Connect(function()
        CreateRipple(Window.CloseBtn)
        
        -- Fade out animation
        local fadeTween = CreateTween(Window.Main, {
            Transparency = 1
        }, 0.2)
        
        fadeTween:Play()
        fadeTween.Completed:Connect(function()
            Window.Main:Destroy()
            Library:Cleanup()
        end)
    end)

    -- Tab Creation
    function Window:CreateTab(name, icon)
        local Tab = {
            Name = name,
            Icon = icon,
            Elements = {}
        }

        -- Create tab button
        Tab.Button = Instance.new("TextButton")
        Tab.Button.Name = name
        Tab.Button.Size = UDim2.new(1, -10, 0, 36)
        Tab.Button.BackgroundColor3 = Library.Theme.Primary
        Tab.Button.Text = ""
        Tab.Button.AutoButtonColor = false
        Tab.Button.Parent = Window.TabButtonList

        local buttonCorner = Instance.new("UICorner")
        buttonCorner.CornerRadius = UDim.new(0, 6)
        buttonCorner.Parent = Tab.Button

        -- Create icon (if provided)
        if icon then
            Tab.Icon = Instance.new("ImageLabel")
            Tab.Icon.Size = UDim2.new(0, 20, 0, 20)
            Tab.Icon.Position = UDim2.new(0, 8, 0.5, -10)
            Tab.Icon.BackgroundTransparency = 1
            Tab.Icon.Image = icon
            Tab.Icon.Parent = Tab.Button
            
            Tab.Title = Instance.new("TextLabel")
            Tab.Title.Text = name
            Tab.Title.Position = UDim2.new(0, 36, 0, 0)
            Tab.Title.Size = UDim2.new(1, -44, 1, 0)
            Tab.Title.BackgroundTransparency = 1
            Tab.Title.TextColor3 = Library.Theme.DimText
            Tab.Title.TextSize = 14
            Tab.Title.Font = Enum.Font.GothamMedium
            Tab.Title.TextXAlignment = Enum.TextXAlignment.Left
            Tab.Title.Parent = Tab.Button
        else
            Tab.Title = Instance.new("TextLabel")
            Tab.Title.Text = name
            Tab.Title.Position = UDim2.new(0, 12, 0, 0)
            Tab.Title.Size = UDim2.new(1, -24, 1, 0)
            Tab.Title.BackgroundTransparency = 1
            Tab.Title.TextColor3 = Library.Theme.DimText
            Tab.Title.TextSize = 14
            Tab.Title.Font = Enum.Font.GothamMedium
            Tab.Title.TextXAlignment = Enum.TextXAlignment.Left
            Tab.Title.Parent = Tab.Button
        end

        -- Create tab content
        Tab.Content = Instance.new("ScrollingFrame")
        Tab.Content.Name = name
        Tab.Content.Size = UDim2.new(1, -20, 1, -20)
        Tab.Content.Position = UDim2.new(0, 10, 0, 10)
        Tab.Content.BackgroundTransparency = 1
        Tab.Content.BorderSizePixel = 0
        Tab.Content.ScrollBarThickness = 2
        Tab.Content.ScrollBarImageColor3 = Library.Theme.Accent
        Tab.Content.Visible = false
        Tab.Content.Parent = Window.TabContent

        local contentList = Instance.new("UIListLayout")
        contentList.Padding = UDim.new(0, 10)
        contentList.Parent = Tab.Content

        -- Tab button hover effect
        Tab.Button.MouseEnter:Connect(function()
            if Window.ActiveTab ~= Tab then
                CreateTween(Tab.Button, {
                    BackgroundColor3 = Library.Theme.Hover
                }):Play()
            end
        end)

        Tab.Button.MouseLeave:Connect(function()
            if Window.ActiveTab ~= Tab then
                CreateTween(Tab.Button, {
                    BackgroundColor3 = Library.Theme.Primary
                }):Play()
            end
        end)

        -- Tab button click
        Tab.Button.MouseButton1Click:Connect(function()
            Window:SelectTab(Tab)
        end)

        -- Element Creation Functions
        function Tab:CreateSection(name)
            local Section = {
                Name = name,
                Elements = {}
            }

            Section.Container = Instance.new("Frame")
            Section.Container.Name = name
            Section.Container.Size = UDim2.new(1, 0, 0, 36)
            Section.Container.BackgroundTransparency = 1
            Section.Container.Parent = Tab.Content

            Section.Title = Instance.new("TextLabel")
            Section.Title.Text = name
            Section.Title.Size = UDim2.new(1, 0, 0, 26)
            Section.Title.Position = UDim2.new(0, 0, 0, 0)
            Section.Title.BackgroundTransparency = 1
            Section.Title.TextColor3 = Library.Theme.TextColor
            Section.Title.TextSize = 15
            Section.Title.Font = Enum.Font.GothamBold
            Section.Title.TextXAlignment = Enum.TextXAlignment.Left
            Section.Title.Parent = Section.Container

            return Section
        end

        function Tab:CreateToggle(info)
            info = info or {}
            info.Name = info.Name or "Toggle"
            info.Default = info.Default or false
            info.Flag = info.Flag or info.Name
            info.Callback = info.Callback or function() end

            local Toggle = {
                Name = info.Name,
                Type = "Toggle",
                Value = info.Default,
                Callback = info.Callback
            }

            Toggle.Container = Instance.new("Frame")
            Toggle.Container.Size = UDim2.new(1, 0, 0, 32)
            Toggle.Container.BackgroundColor3 = Library.Theme.Primary
            Toggle.Container.Parent = Tab.Content

            local containerCorner = Instance.new("UICorner")
            containerCorner.CornerRadius = UDim.new(0, 6)
            containerCorner.Parent = Toggle.Container

            Toggle.Title = Instance.new("TextLabel")
            Toggle.Title.Text = info.Name
            Toggle.Title.Size = UDim2.new(1, -60, 1, 0)
            Toggle.Title.Position = UDim2.new(0, 12, 0, 0)
            Toggle.Title.BackgroundTransparency = 1
            Toggle.Title.TextColor3 = Library.Theme.TextColor
            Toggle.Title.TextSize = 14
            Toggle.Title.Font = Enum.Font.GothamMedium
            Toggle.Title.TextXAlignment = Enum.TextXAlignment.Left
            Toggle.Title.Parent = Toggle.Container

            Toggle.Button = Instance.new("TextButton")
            Toggle.Button.Size = UDim2.new(0, 40, 0, 20)
            Toggle.Button.Position = UDim2.new(1, -52, 0.5, -10)
            Toggle.Button.BackgroundColor3 = Library.Theme.Secondary
            Toggle.Button.AutoButtonColor = false
            Toggle.Button.Text = ""
            Toggle.Button.Parent = Toggle.Container

            local buttonCorner = Instance.new("UICorner")
            buttonCorner.CornerRadius = UDim.new(1, 0)
            buttonCorner.Parent = Toggle.Button

            Toggle.Indicator = Instance.new("Frame")
            Toggle.Indicator.Size = UDim2.new(0, 16, 0, 16)
            Toggle.Indicator.Position = UDim2.new(0, 2, 0.5, -8)
            Toggle.Indicator.BackgroundColor3 = Library.Theme.TextColor
            Toggle.Indicator.Parent = Toggle.Button

            local indicatorCorner = Instance.new("UICorner")
            indicatorCorner.CornerRadius = UDim.new(1, 0)
            indicatorCorner.Parent = Toggle.Indicator

            -- Animation function
            function Toggle:Set(value)
                Toggle.Value = value
                Library.Flags[info.Flag] = value
                
                local pos = value and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
                local color = value and Library.Theme.Accent or Library.Theme.Secondary
                
                CreateTween(Toggle.Indicator, {
                    Position = pos
                }):Play()
                
                CreateTween(Toggle.Button, {
                    BackgroundColor3 = color
                }):Play()
                
                info.Callback(value)
            end

            -- Initialize
            Toggle:Set(info.Default)

            -- Toggle button functionality
            Toggle.Button.MouseButton1Click:Connect(function()
                Toggle:Set(not Toggle.Value)
                CreateRipple(Toggle.Button)
            end)

            -- Hover effect
            Toggle.Button.MouseEnter:Connect(function()
                CreateTween(Toggle.Container, {
                    BackgroundColor3 = Library.Theme.Hover
                }):Play()
            end)

            Toggle.Button.MouseLeave:Connect(function()
                CreateTween(Toggle.Container, {
                    BackgroundColor3 = Library.Theme.Primary
                }):Play()
            end)

            return Toggle
        end

        function Tab:CreateSlider(info)
            info = info or {}
            info.Name = info.Name or "Slider"
            info.Min = info.Min or 0
            info.Max = info.Max or 100
            info.Default = info.Default or info.Min
            info.Increment = info.Increment or 1
            info.Flag = info.Flag or info.Name
            info.Callback = info.Callback or function() end

            local Slider = {
                Name = info.Name,
                Type = "Slider",
                Value = info.Default,
                Min = info.Min,
                Max = info.Max,
                Increment = info.Increment,
                Callback = info.Callback
            }

            Slider.Container = Instance.new("Frame")
            Slider.Container.Size = UDim2.new(1, 0, 0, 50)
            Slider.Container.BackgroundColor3 = Library.Theme.Primary
            Slider.Container.Parent = Tab.Content

            local containerCorner = Instance.new("UICorner")
            containerCorner.CornerRadius = UDim.new(0, 6)
            containerCorner.Parent = Slider.Container

            Slider.Title = Instance.new("TextLabel")
            Slider.Title.Text = info.Name
            Slider.Title.Size = UDim2.new(1, -12, 0, 30)
            Slider.Title.Position = UDim2.new(0, 12, 0, 0)
            Slider.Title.BackgroundTransparency = 1
            Slider.Title.TextColor3 = Library.Theme.TextColor
            Slider.Title.TextSize = 14
            Slider.Title.Font = Enum.Font.GothamMedium
            Slider.Title.TextXAlignment = Enum.TextXAlignment.Left
            Slider.Title.Parent = Slider.Container

            Slider.ValueLabel = Instance.new("TextLabel")
            Slider.ValueLabel.Size = UDim2.new(0, 50, 0, 30)
            Slider.ValueLabel.Position = UDim2.new(1, -62, 0, 0)
            Slider.ValueLabel.BackgroundTransparency = 1
            Slider.ValueLabel.TextColor3 = Library.Theme.TextColor
            Slider.ValueLabel.TextSize = 14
            Slider.ValueLabel.Font = Enum.Font.GothamMedium
            Slider.ValueLabel.Parent = Slider.Container

            Slider.SliderBar = Instance.new("Frame")
            Slider.SliderBar.Size = UDim2.new(1, -24, 0, 4)
            Slider.SliderBar.Position = UDim2.new(0, 12, 0, 38)
            Slider.SliderBar.BackgroundColor3 = Library.Theme.Secondary
            Slider.SliderBar.Parent = Slider.Container

            local barCorner = Instance.new("UICorner")
            barCorner.CornerRadius = UDim.new(1, 0)
            barCorner.Parent = Slider.SliderBar

            Slider.SliderFill = Instance.new("Frame")
            Slider.SliderFill.Size = UDim2.new(0.5, 0, 1, 0)
            Slider.SliderFill.BackgroundColor3 = Library.Theme.Accent
            Slider.SliderFill.Parent = Slider.SliderBar

            local fillCorner = Instance.new("UICorner")
            fillCorner.CornerRadius = UDim.new(1, 0)
            fillCorner.Parent = Slider.SliderFill

            Slider.SliderButton = Instance.new("TextButton")
            Slider.SliderButton.Size = UDim2.new(0, 16, 0, 16)
            Slider.SliderButton.Position = UDim2.new(0.5, -8, 0.5, -8)
            Slider.SliderButton.BackgroundColor3 = Library.Theme.Accent
            Slider.SliderButton.AutoButtonColor = false
            Slider.SliderButton.Text = ""
            Slider.SliderButton.Parent = Slider.SliderFill

            local buttonCorner = Instance.new("UICorner")
            buttonCorner.CornerRadius = UDim.new(1, 0)
            buttonCorner.Parent = Slider.SliderButton

            -- Slider functionality
            local dragging = false

            function Slider:Set(value)
                value = math.clamp(value, Slider.Min, Slider.Max)
                value = math.floor(value / Slider.Increment + 0.5) * Slider.Increment
                value = tonumber(string.format("%.2f", value))

                Slider.Value = value
                Library.Flags[info.Flag] = value

                local percent = (value - Slider.Min) / (Slider.Max - Slider.Min)
                CreateTween(Slider.SliderFill, {
                    Size = UDim2.new(percent, 0, 1, 0)
                }):Play()

                Slider.ValueLabel.Text = tostring(value)
                Slider.Callback(value)
            end

            -- Initialize
            Slider:Set(info.Default)

            -- Slider interaction
            Slider.SliderButton.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                end
            end)

            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                end
            end)

            UserInputService.InputChanged:Connect(function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    local mousePos = UserInputService:GetMouseLocation()
                    local relativePos = mousePos - Slider.SliderBar.AbsolutePosition
                    local percent = math.clamp(relativePos.X / Slider.SliderBar.AbsoluteSize.X, 0, 1)
                    local value = Slider.Min + (Slider.Max - Slider.Min) * percent
                    Slider:Set(value)
                end
            end)

            -- Hover effect
            Slider.Container.MouseEnter:Connect(function()
                CreateTween(Slider.Container, {
                    BackgroundColor3 = Library.Theme.Hover
                }):Play()
            end)

            Slider.Container.MouseLeave:Connect(function()
                CreateTween(Slider.Container, {
                    BackgroundColor3 = Library.Theme.Primary
                }):Play()
            end)

            return Slider
        end

        function Tab:CreateDropdown(info)
            info = info or {}
            info.Name = info.Name or "Dropdown"
            info.Options = info.Options or {}
            info.Default = info.Default or ""
            info.Flag = info.Flag or info.Name
            info.Callback = info.Callback or function() end

            local Dropdown = {
                Name = info.Name,
                Type = "Dropdown",
                Value = info.Default,
                Options = info.Options,
                Open = false,
                Callback = info.Callback
            }

            Dropdown.Container = Instance.new("Frame")
            Dropdown.Container.Size = UDim2.new(1, 0, 0, 32)
            Dropdown.Container.BackgroundColor3 = Library.Theme.Primary
            Dropdown.Container.Parent = Tab.Content

            
            table.insert(Window.Tabs, Tab)
            return Tab
        end

    end

    function Window:SelectTab(tab)
        if Window.ActiveTab then
            Window.ActiveTab.Button.BackgroundColor3 = Library.Theme.Primary
            Window.ActiveTab.Title.TextColor3 = Library.Theme.DimText
            Window.ActiveTab.Content.Visible = false
        end

        tab.Button.BackgroundColor3 = Library.Theme.Accent
        tab.Title.TextColor3 = Library.Theme.TextColor
        tab.Content.Visible = true
        Window.ActiveTab = tab
    end

    return Window
end

-- Cleanup function
function Library:Cleanup()
    for _, drawing in ipairs(Library.drawings) do
        drawing:Remove()
    end
    for _, connection in ipairs(Library.connections) do
        connection:Disconnect()
    end
    Library.drawings = {}
    Library.connections = {}
end

return Library
