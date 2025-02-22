-- RixUILib.lua
local Library = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

function Library:CreateWindow(config)
    config = config or {}
    local WindowName = config.WindowName or "RixUI Library"
    local WindowSize = config.WindowSize or UDim2.new(0, 500, 0, 300)
    
    -- Main GUI Creation
    local MainGui = Instance.new("ScreenGui")
    local Main = Instance.new("Frame")
    local UICorner = Instance.new("UICorner")
    local TopBar = Instance.new("Frame")
    local Title = Instance.new("TextLabel")
    local TabContainer = Instance.new("Frame")
    local TabList = Instance.new("Frame")
    local TabContent = Instance.new("Frame")
    
    MainGui.Name = "RixUI"
    MainGui.Parent = game.CoreGui
    
    Main.Name = "Main"
    Main.Parent = MainGui
    Main.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Main.Position = UDim2.new(0.5, -WindowSize.X.Offset/2, 0.5, -WindowSize.Y.Offset/2)
    Main.Size = WindowSize
    
    UICorner.CornerRadius = UDim.new(0, 10)
    UICorner.Parent = Main
    
    TopBar.Name = "TopBar"
    TopBar.Parent = Main
    TopBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    TopBar.Size = UDim2.new(1, 0, 0, 30)
    
    local TopBarCorner = Instance.new("UICorner")
    TopBarCorner.CornerRadius = UDim.new(0, 10)
    TopBarCorner.Parent = TopBar
    
    Title.Name = "Title"
    Title.Parent = TopBar
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0, 10, 0, 0)
    Title.Size = UDim2.new(1, -20, 1, 0)
    Title.Font = Enum.Font.GothamBold
    Title.Text = WindowName
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 14
    
    TabContainer.Name = "TabContainer"
    TabContainer.Parent = Main
    TabContainer.BackgroundTransparency = 1
    TabContainer.Position = UDim2.new(0, 0, 0, 35)
    TabContainer.Size = UDim2.new(1, 0, 1, -35)
    
    TabList.Name = "TabList"
    TabList.Parent = TabContainer
    TabList.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    TabList.Position = UDim2.new(0, 5, 0, 5)
    TabList.Size = UDim2.new(0, 120, 1, -10)
    
    local TabListCorner = Instance.new("UICorner")
    TabListCorner.CornerRadius = UDim.new(0, 8)
    TabListCorner.Parent = TabList
    
    TabContent.Name = "TabContent"
    TabContent.Parent = TabContainer
    TabContent.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    TabContent.Position = UDim2.new(0, 130, 0, 5)
    TabContent.Size = UDim2.new(1, -135, 1, -10)
    
    local TabContentCorner = Instance.new("UICorner")
    TabContentCorner.CornerRadius = UDim.new(0, 8)
    TabContentCorner.Parent = TabContent
    
    -- Make window draggable
    local dragging
    local dragInput
    local dragStart
    local startPos
    
    local function update(input)
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    
    TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = Main.Position
        end
    end)
    
    TopBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
    
    -- Tab System
    local TabSystem = {}
    local Tabs = {}
    local SelectedTab = nil
    
    function TabSystem:CreateTab(name)
        local Tab = {}
        
        -- Tab Button
        local TabButton = Instance.new("TextButton")
        TabButton.Name = name
        TabButton.Parent = TabList
        TabButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        TabButton.Size = UDim2.new(1, -10, 0, 30)
        TabButton.Position = UDim2.new(0, 5, 0, #Tabs * 35 + 5)
        TabButton.Font = Enum.Font.GothamSemibold
        TabButton.Text = name
        TabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
        TabButton.TextSize = 14
        TabButton.AutoButtonColor = false
        
        local TabButtonCorner = Instance.new("UICorner")
        TabButtonCorner.CornerRadius = UDim.new(0, 6)
        TabButtonCorner.Parent = TabButton
        
        -- Tab Content
        local TabFrame = Instance.new("ScrollingFrame")
        TabFrame.Name = name
        TabFrame.Parent = TabContent
        TabFrame.BackgroundTransparency = 1
        TabFrame.Size = UDim2.new(1, -10, 1, -10)
        TabFrame.Position = UDim2.new(0, 5, 0, 5)
        TabFrame.ScrollBarThickness = 2
        TabFrame.Visible = false
        TabFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
        
        local UIListLayout = Instance.new("UIListLayout")
        UIListLayout.Parent = TabFrame
        UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
        UIListLayout.Padding = UDim.new(0, 5)
        
        TabButton.MouseButton1Click:Connect(function()
            if SelectedTab then
                TweenService:Create(SelectedTab.Button, TweenInfo.new(0.2), {
                    BackgroundColor3 = Color3.fromRGB(45, 45, 45),
                    TextColor3 = Color3.fromRGB(200, 200, 200)
                }):Play()
                SelectedTab.Frame.Visible = false
            end
            
            SelectedTab = {Button = TabButton, Frame = TabFrame}
            
            TweenService:Create(TabButton, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(60, 60, 60),
                TextColor3 = Color3.fromRGB(255, 255, 255)
            }):Play()
            TabFrame.Visible = true
        end)
        
        -- Create Elements Functions
        function Tab:CreateButton(text, callback)
            local Button = Instance.new("TextButton")
            Button.Name = text
            Button.Parent = TabFrame
            Button.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            Button.Size = UDim2.new(1, -10, 0, 30)
            Button.Font = Enum.Font.GothamSemibold
            Button.Text = text
            Button.TextColor3 = Color3.fromRGB(200, 200, 200)
            Button.TextSize = 14
            Button.AutoButtonColor = false
            
            local ButtonCorner = Instance.new("UICorner")
            ButtonCorner.CornerRadius = UDim.new(0, 6)
            ButtonCorner.Parent = Button
            
            Button.MouseButton1Click:Connect(function()
                callback()
                TweenService:Create(Button, TweenInfo.new(0.1), {
                    BackgroundColor3 = Color3.fromRGB(60, 60, 60)
                }):Play()
                wait(0.1)
                TweenService:Create(Button, TweenInfo.new(0.1), {
                    BackgroundColor3 = Color3.fromRGB(45, 45, 45)
                }):Play()
            end)
        end
        
        function Tab:CreateToggle(text, default, callback)
            local Toggle = Instance.new("Frame")
            Toggle.Name = text
            Toggle.Parent = TabFrame
            Toggle.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            Toggle.Size = UDim2.new(1, -10, 0, 30)
            
            local ToggleCorner = Instance.new("UICorner")
            ToggleCorner.CornerRadius = UDim.new(0, 6)
            ToggleCorner.Parent = Toggle
            
            local ToggleButton = Instance.new("TextButton")
            ToggleButton.Name = "ToggleButton"
            ToggleButton.Parent = Toggle
            ToggleButton.BackgroundTransparency = 1
            ToggleButton.Size = UDim2.new(1, 0, 1, 0)
            ToggleButton.Font = Enum.Font.GothamSemibold
            ToggleButton.Text = text
            ToggleButton.TextColor3 = Color3.fromRGB(200, 200, 200)
            ToggleButton.TextSize = 14
            
            local ToggleIndicator = Instance.new("Frame")
            ToggleIndicator.Name = "Indicator"
            ToggleIndicator.Parent = Toggle
            ToggleIndicator.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
            ToggleIndicator.Position = UDim2.new(1, -40, 0.5, -10)
            ToggleIndicator.Size = UDim2.new(0, 20, 0, 20)
            
            local ToggleIndicatorCorner = Instance.new("UICorner")
            ToggleIndicatorCorner.CornerRadius = UDim.new(0, 4)
            ToggleIndicatorCorner.Parent = ToggleIndicator
            
            local enabled = default or false
            
            local function updateToggle()
                if enabled then
                    TweenService:Create(ToggleIndicator, TweenInfo.new(0.2), {
                        BackgroundColor3 = Color3.fromRGB(50, 255, 50)
                    }):Play()
                else
                    TweenService:Create(ToggleIndicator, TweenInfo.new(0.2), {
                        BackgroundColor3 = Color3.fromRGB(255, 50, 50)
                    }):Play()
                end
                callback(enabled)
            end
            
            ToggleButton.MouseButton1Click:Connect(function()
                enabled = not enabled
                updateToggle()
            end)
            
            updateToggle()
        end
        
        function Tab:CreateSlider(text, min, max, default, callback)
            local Slider = Instance.new("Frame")
            Slider.Name = text
            Slider.Parent = TabFrame
            Slider.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            Slider.Size = UDim2.new(1, -10, 0, 50)
            
            local SliderCorner = Instance.new("UICorner")
            SliderCorner.CornerRadius = UDim.new(0, 6)
            SliderCorner.Parent = Slider
            
            local SliderTitle = Instance.new("TextLabel")
            SliderTitle.Name = "Title"
            SliderTitle.Parent = Slider
            SliderTitle.BackgroundTransparency = 1
            SliderTitle.Position = UDim2.new(0, 10, 0, 5)
            SliderTitle.Size = UDim2.new(1, -20, 0, 20)
            SliderTitle.Font = Enum.Font.GothamSemibold
            SliderTitle.Text = text
            SliderTitle.TextColor3 = Color3.fromRGB(200, 200, 200)
            SliderTitle.TextSize = 14
            SliderTitle.TextXAlignment = Enum.TextXAlignment.Left
            
            local SliderValue = Instance.new("TextLabel")
            SliderValue.Name = "Value"
            SliderValue.Parent = Slider
            SliderValue.BackgroundTransparency = 1
            SliderValue.Position = UDim2.new(1, -50, 0, 5)
            SliderValue.Size = UDim2.new(0, 40, 0, 20)
            SliderValue.Font = Enum.Font.GothamSemibold
            SliderValue.Text = tostring(default)
            SliderValue.TextColor3 = Color3.fromRGB(200, 200, 200)
            SliderValue.TextSize = 14
            
            local SliderBar = Instance.new("Frame")
            SliderBar.Name = "Bar"
            SliderBar.Parent = Slider
            SliderBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
            SliderBar.Position = UDim2.new(0, 10, 0, 35)
            SliderBar.Size = UDim2.new(1, -20, 0, 5)
            
            local SliderBarCorner = Instance.new("UICorner")
            SliderBarCorner.CornerRadius = UDim.new(0, 3)
            SliderBarCorner.Parent = SliderBar
            
            local SliderFill = Instance.new("Frame")
            SliderFill.Name = "Fill"
            SliderFill.Parent = SliderBar
            SliderFill.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
            SliderFill.Size = UDim2.new((default - min)/(max - min), 0, 1, 0)
            
            local SliderFillCorner = Instance.new("UICorner")
            SliderFillCorner.CornerRadius = UDim.new(0, 3)
            SliderFillCorner.Parent = SliderFill
            
            local SliderButton = Instance.new("TextButton")
            SliderButton.Name = "Button"
            SliderButton.Parent = SliderBar
            SliderButton.BackgroundTransparency = 1
            SliderButton.Size = UDim2.new(1, 0, 1, 0)
            SliderButton.Text = ""
            
            local dragging = false
            
            SliderButton.MouseButton1Down:Connect(function()
                dragging = true
            end)
            
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                end
            end)
            
            UserInputService.InputChanged:Connect(function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    local mousePos = UserInputService:GetMouseLocation()
                    local relativePos = mousePos.X - SliderBar.AbsolutePosition.X
                    local percentage = math.clamp(relativePos / SliderBar.AbsoluteSize.X, 0, 1)
                    local value = math.floor(min + ((max - min) * percentage))
                    
                    SliderFill.Size = UDim2.new(percentage, 0, 1, 0)
                    SliderValue.Text = tostring(value)
                    callback(value)
                end
            end)
        end
        
        table.insert(Tabs, Tab)
        if #Tabs == 1 then
            TabButton.MouseButton1Click:Fire()
        end
        
        return Tab
    end
    
    -- Notification System
    function Library:Notify(title, text, duration)
        duration = duration or 3
        
        local Notification = Instance.new("Frame")
        Notification.Name = "Notification"
        Notification.Parent = MainGui
        Notification.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        Notification.Position = UDim2.new(1, -320, 1, -90)
        Notification.Size = UDim2.new(0, 300, 0, 80)
        Notification.BackgroundTransparency = 1
        
        local NotificationCorner = Instance.new("UICorner")
        NotificationCorner.CornerRadius = UDim.new(0, 10)
        NotificationCorner.Parent = Notification
        
        local NotificationTitle = Instance.new("TextLabel")
        NotificationTitle.Name = "Title"
        NotificationTitle.Parent = Notification
        NotificationTitle.BackgroundTransparency = 1
        NotificationTitle.Position = UDim2.new(0, 10, 0, 5)
        NotificationTitle.Size = UDim2.new(1, -20, 0, 25)
        NotificationTitle.Font = Enum.Font.GothamBold
        NotificationTitle.Text = title
        NotificationTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
        NotificationTitle.TextSize = 14
        NotificationTitle.TextTransparency = 1
        
        local NotificationText = Instance.new("TextLabel")
        NotificationText.Name = "Text"
        NotificationText.Parent = Notification
        NotificationText.BackgroundTransparency = 1
        NotificationText.Position = UDim2.new(0, 10, 0, 35)
        NotificationText.Size = UDim2.new(1, -20, 0, 35)
        NotificationText.Font = Enum.Font.Gotham
        NotificationText.Text = text
        NotificationText.TextColor3 = Color3.fromRGB(200, 200, 200)
        NotificationText.TextSize = 14
        NotificationText.TextWrapped = true
        NotificationText.TextTransparency = 1
        
        -- Animation
        TweenService:Create(Notification, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {
            BackgroundTransparency = 0,
            Position = UDim2.new(1, -320, 1, -100)
        }):Play()
        
        TweenService:Create(NotificationTitle, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {
            TextTransparency = 0
        }):Play()
        
        TweenService:Create(NotificationText, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {
            TextTransparency = 0
        }):Play()
        
        wait(duration)
        
        TweenService:Create(Notification, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {
            BackgroundTransparency = 1,
            Position = UDim2.new(1, -320, 1, -90)
        }):Play()
        
        TweenService:Create(NotificationTitle, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {
            TextTransparency = 1
        }):Play()
        
        TweenService:Create(NotificationText, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {
            TextTransparency = 1
        }):Play()
        
        wait(0.5)
        Notification:Destroy()
    end
    
    return TabSystem
end

return Library
