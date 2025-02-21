-- GameSense Style UI Library for Roblox
-- Author: Your Name
-- Version: 1.0.0

local Library = {
    flags = {},
    tabs = {},
    options = {},
    drawings = {},
    hidden = false,
    connections = {},
    theme = {
        accent = Color3.fromRGB(124, 193, 21),
        background = Color3.fromRGB(17, 17, 17),
        foreground = Color3.fromRGB(25, 25, 25),
        light_contrast = Color3.fromRGB(30, 30, 30),
        dark_contrast = Color3.fromRGB(20, 20, 20),
        text = Color3.fromRGB(255, 255, 255),
        dark_text = Color3.fromRGB(175, 175, 175),
    }
}

-- Utility Functions
local function Lerp(a, b, t)
    return a + (b - a) * t
end

local function CreateDrawing(type, properties)
    local drawing = Drawing.new(type)
    for property, value in pairs(properties) do
        drawing[property] = value
    end
    table.insert(Library.drawings, drawing)
    return drawing
end

local function CreateConnection(signal, callback)
    local connection = signal:Connect(callback)
    table.insert(Library.connections, connection)
    return connection
end

-- Window Creation
function Library:CreateWindow(title, size)
    local Window = {
        title = title or "GameSense",
        size = size or Vector2.new(600, 400),
        position = Vector2.new(50, 50),
        current_tab = nil,
        dragging = false,
        drag_start = Vector2.new(),
        tabs = {}
    }

    -- Create main window frame
    Window.main = CreateDrawing("Square", {
        Size = Window.size,
        Position = Window.position,
        Filled = true,
        Color = Library.theme.background,
        Visible = true,
        Transparency = 1
    })

    -- Create title bar
    Window.title_bar = CreateDrawing("Square", {
        Size = Vector2.new(Window.size.X, 30),
        Position = Window.position,
        Filled = true,
        Color = Library.theme.foreground,
        Visible = true,
        Transparency = 1
    })

    -- Create title text
    Window.title_text = CreateDrawing("Text", {
        Text = Window.title,
        Position = Window.position + Vector2.new(10, 8),
        Color = Library.theme.text,
        Size = 13,
        Font = 2,
        Visible = true,
        Transparency = 1
    })

    -- Window dragging functionality
    CreateConnection(game:GetService("UserInputService").InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local mouse = game:GetService("UserInputService"):GetMouseLocation()
            if mouse.Y - Window.position.Y <= 30 then
                Window.dragging = true
                Window.drag_start = mouse - Window.position
            end
        end
    end)

    CreateConnection(game:GetService("UserInputService").InputEnded, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            Window.dragging = false
        end
    end)

    CreateConnection(game:GetService("RunService").RenderStepped, function()
        if Window.dragging then
            local mouse = game:GetService("UserInputService"):GetMouseLocation()
            Window.position = mouse - Window.drag_start
            
            -- Update all window elements
            Window.main.Position = Window.position
            Window.title_bar.Position = Window.position
            Window.title_text.Position = Window.position + Vector2.new(10, 8)
            
            -- Update tab positions
            for _, tab in pairs(Window.tabs) do
                tab:UpdatePosition(Window.position)
            end
        end
    end)

    -- Tab Creation
    function Window:CreateTab(name)
        local Tab = {
            name = name,
            elements = {},
            visible = false
        }

        -- Create tab button
        local tab_width = 80
        local tab_x = Window.position.X + (#Window.tabs * (tab_width + 5))
        
        Tab.button = CreateDrawing("Square", {
            Size = Vector2.new(tab_width, 25),
            Position = Vector2.new(tab_x, Window.position.Y + 35),
            Filled = true,
            Color = Library.theme.foreground,
            Visible = true,
            Transparency = 1
        })

        Tab.button_text = CreateDrawing("Text", {
            Text = name,
            Position = Vector2.new(tab_x + (tab_width/2), Window.position.Y + 41),
            Center = true,
            Color = Library.theme.dark_text,
            Size = 13,
            Font = 2,
            Visible = true,
            Transparency = 1
        })

        -- Tab content area
        Tab.container = CreateDrawing("Square", {
            Size = Vector2.new(Window.size.X - 20, Window.size.Y - 70),
            Position = Vector2.new(Window.position.X + 10, Window.position.Y + 70),
            Filled = true,
            Color = Library.theme.foreground,
            Visible = false,
            Transparency = 1
        })

        function Tab:UpdatePosition(window_pos)
            local tab_x = window_pos.X + ((#Window.tabs-1) * (tab_width + 5))
            Tab.button.Position = Vector2.new(tab_x, window_pos.Y + 35)
            Tab.button_text.Position = Vector2.new(tab_x + (tab_width/2), window_pos.Y + 41)
            Tab.container.Position = Vector2.new(window_pos.X + 10, window_pos.Y + 70)
        end

        -- Tab switching
        CreateConnection(game:GetService("UserInputService").InputBegan, function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                local mouse = game:GetService("UserInputService"):GetMouseLocation()
                if mouse.X >= Tab.button.Position.X and
                   mouse.X <= Tab.button.Position.X + Tab.button.Size.X and
                   mouse.Y >= Tab.button.Position.Y and
                   mouse.Y <= Tab.button.Position.Y + Tab.button.Size.Y then
                    -- Hide current tab
                    if Window.current_tab then
                        Window.current_tab.visible = false
                        Window.current_tab.container.Visible = false
                        Window.current_tab.button.Color = Library.theme.foreground
                        Window.current_tab.button_text.Color = Library.theme.dark_text
                    end
                    
                    -- Show selected tab
                    Tab.visible = true
                    Tab.container.Visible = true
                    Tab.button.Color = Library.theme.accent
                    Tab.button_text.Color = Library.theme.text
                    Window.current_tab = Tab
                end
            end
        end)

        -- Element Creation Functions
        function Tab:CreateToggle(name, default, callback)
            local Toggle = {
                name = name,
                state = default or false,
                callback = callback
            }

            local y_offset = 10 + (#Tab.elements * 25)

            Toggle.container = CreateDrawing("Square", {
                Size = Vector2.new(Tab.container.Size.X - 20, 20),
                Position = Vector2.new(Tab.container.Position.X + 10, Tab.container.Position.Y + y_offset),
                Filled = true,
                Color = Library.theme.light_contrast,
                Visible = Tab.visible,
                Transparency = 1
            })

            Toggle.text = CreateDrawing("Text", {
                Text = name,
                Position = Vector2.new(Toggle.container.Position.X + 5, Toggle.container.Position.Y + 3),
                Color = Library.theme.text,
                Size = 13,
                Font = 2,
                Visible = Tab.visible,
                Transparency = 1
            })

            Toggle.indicator = CreateDrawing("Square", {
                Size = Vector2.new(12, 12),
                Position = Vector2.new(Toggle.container.Position.X + Toggle.container.Size.X - 22, Toggle.container.Position.Y + 4),
                Filled = true,
                Color = Toggle.state and Library.theme.accent or Library.theme.dark_contrast,
                Visible = Tab.visible,
                Transparency = 1
            })

            CreateConnection(game:GetService("UserInputService").InputBegan, function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 and Tab.visible then
                    local mouse = game:GetService("UserInputService"):GetMouseLocation()
                    if mouse.X >= Toggle.container.Position.X and
                       mouse.X <= Toggle.container.Position.X + Toggle.container.Size.X and
                       mouse.Y >= Toggle.container.Position.Y and
                       mouse.Y <= Toggle.container.Position.Y + Toggle.container.Size.Y then
                        Toggle.state = not Toggle.state
                        Toggle.indicator.Color = Toggle.state and Library.theme.accent or Library.theme.dark_contrast
                        if Toggle.callback then
                            Toggle.callback(Toggle.state)
                        end
                    end
                end
            end)

            table.insert(Tab.elements, Toggle)
            return Toggle
        end

        function Tab:CreateSlider(name, min, max, default, callback)
            local Slider = {
                name = name,
                min = min or 0,
                max = max or 100,
                value = default or min,
                callback = callback,
                dragging = false
            }

            local y_offset = 10 + (#Tab.elements * 25)

            Slider.container = CreateDrawing("Square", {
                Size = Vector2.new(Tab.container.Size.X - 20, 20),
                Position = Vector2.new(Tab.container.Position.X + 10, Tab.container.Position.Y + y_offset),
                Filled = true,
                Color = Library.theme.light_contrast,
                Visible = Tab.visible,
                Transparency = 1
            })

            Slider.text = CreateDrawing("Text", {
                Text = name,
                Position = Vector2.new(Slider.container.Position.X + 5, Slider.container.Position.Y + 3),
                Color = Library.theme.text,
                Size = 13,
                Font = 2,
                Visible = Tab.visible,
                Transparency = 1
            })

            Slider.value_text = CreateDrawing("Text", {
                Text = tostring(Slider.value),
                Position = Vector2.new(Slider.container.Position.X + Slider.container.Size.X - 30, Slider.container.Position.Y + 3),
                Color = Library.theme.text,
                Size = 13,
                Font = 2,
                Visible = Tab.visible,
                Transparency = 1
            })

            Slider.slide_bar = CreateDrawing("Square", {
                Size = Vector2.new(150, 4),
                Position = Vector2.new(Slider.container.Position.X + 70, Slider.container.Position.Y + 8),
                Filled = true,
                Color = Library.theme.dark_contrast,
                Visible = Tab.visible,
                Transparency = 1
            })

            Slider.slide_fill = CreateDrawing("Square", {
                Size = Vector2.new((Slider.value - Slider.min) / (Slider.max - Slider.min) * 150, 4),
                Position = Vector2.new(Slider.container.Position.X + 70, Slider.container.Position.Y + 8),
                Filled = true,
                Color = Library.theme.accent,
                Visible = Tab.visible,
                Transparency = 1
            })

            CreateConnection(game:GetService("UserInputService").InputBegan, function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 and Tab.visible then
                    local mouse = game:GetService("UserInputService"):GetMouseLocation()
                    if mouse.X >= Slider.slide_bar.Position.X and
                       mouse.X <= Slider.slide_bar.Position.X + Slider.slide_bar.Size.X and
                       mouse.Y >= Slider.container.Position.Y and
                       mouse.Y <= Slider.container.Position.Y + Slider.container.Size.Y then
                        Slider.dragging = true
                    end
                end
            end)

            CreateConnection(game:GetService("UserInputService").InputEnded, function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    Slider.dragging = false
                end
            end)

            CreateConnection(game:GetService("RunService").RenderStepped, function()
                if Slider.dragging then
                    local mouse = game:GetService("UserInputService"):GetMouseLocation()
                    local percent = math.clamp((mouse.X - Slider.slide_bar.Position.X) / Slider.slide_bar.Size.X, 0, 1)
                    Slider.value = math.floor(Lerp(Slider.min, Slider.max, percent))
                    Slider.slide_fill.Size = Vector2.new(percent * 150, 4)
                    Slider.value_text.Text = tostring(Slider.value)
                    if Slider.callback then
                        Slider.callback(Slider.value)
                    end
                end
            end)

            table.insert(Tab.elements, Slider)
            return Slider
        end

        function Tab:CreateDropdown(name, options, default, callback)
            local Dropdown = {
                name = name,
                options = options or {},
                value = default or options[1],
                callback = callback,
                open = false
            }

            local y_offset = 10 + (#Tab.elements * 25)

            Dropdown.container = CreateDrawing("Square", {
                Size = Vector2.new(Tab.container.Size.X - 20, 20),
                Position = Vector2.new(Tab.container.Position.X + 10, Tab.container.Position.Y + y_offset),
                Filled = true,
                Color = Library.theme.light_contrast,
                Visible = Tab.visible,
                Transparency = 1
            })

            Dropdown.text = CreateDrawing("Text", {
                Text = name,
                Position = Vector2.new(Dropdown.container.Position.X + 5, Dropdown.container.Position.Y + 3),
                Color = Library.theme.text,
                Size = 13,
                Font = 2,
                Visible = Tab.visible,
                Transparency = 1
            })

            Dropdown.selected = CreateDrawing("Text", {
                Text = Dropdown.value,
                Position = Vector2.new(Dropdown.container.Position.X + 150, Dropdown.container.Position.Y + 3),
                Color = Library.theme.dark_text,
                Size = 13,
                Font = 2,
                Visible = Tab.visible,
                Transparency = 1
            })

            Dropdown.arrow = CreateDrawing("Text", {
                Text = "▼",
                Position = Vector2.new(Dropdown.container.Position.X + Dropdown.container.Size.X - 20, Dropdown.container.Position.Y + 3),
                Color = Library.theme.dark_text,
                Size = 13,
                Font = 2,
                Visible = Tab.visible,
                Transparency = 1
            })

            -- Create dropdown list
            Dropdown.list = CreateDrawing("Square", {
                Size = Vector2.new(Dropdown.container.Size.X, #options * 20),
                Position = Vector2.new(Dropdown.container.Position.X, Dropdown.container.Position.Y + 25),
                Filled = true,
                Color = Library.theme.light_contrast,
                Visible = false,
                Transparency = 1
            })

            Dropdown.options_text = {}
            for i, option in ipairs(options) do
                local option_text = CreateDrawing("Text", {
                    Text = option,
                    Position = Vector2.new(Dropdown.list.Position.X + 5, Dropdown.list.Position.Y + ((i-1) * 20) + 3),
                    Color = Library.theme.dark_text,
                    Size = 13,
                    Font = 2,
                    Visible = false,
                    Transparency = 1
                })
                table.insert(Dropdown.options_text, option_text)
            end

            CreateConnection(game:GetService("UserInputService").InputBegan, function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 and Tab.visible then
                    local mouse = game:GetService("UserInputService"):GetMouseLocation()
                    
                    -- Check if clicking the dropdown header
                    if mouse.X >= Dropdown.container.Position.X and
                       mouse.X <= Dropdown.container.Position.X + Dropdown.container.Size.X and
                       mouse.Y >= Dropdown.container.Position.Y and
                       mouse.Y <= Dropdown.container.Position.Y + Dropdown.container.Size.Y then
                        Dropdown.open = not Dropdown.open
                        Dropdown.list.Visible = Dropdown.open
                        for _, text in ipairs(Dropdown.options_text) do
                            text.Visible = Dropdown.open
                        end
                    end
                    
                    -- Check if clicking an option
                    if Dropdown.open then
                        for i, option in ipairs(options) do
                            if mouse.X >= Dropdown.list.Position.X and
                               mouse.X <= Dropdown.list.Position.X + Dropdown.list.Size.X and
                               mouse.Y >= Dropdown.list.Position.Y + ((i-1) * 20) and
                               mouse.Y <= Dropdown.list.Position.Y + (i * 20) then
                                Dropdown.value = option
                                Dropdown.selected.Text = option
                                Dropdown.open = false
                                Dropdown.list.Visible = false
                                for _, text in ipairs(Dropdown.options_text) do
                                    text.Visible = false
                                end
                                if Dropdown.callback then
                                    Dropdown.callback(option)
                                end
                                break
                            end
                        end
                    end
                end
            end)

            table.insert(Tab.elements, Dropdown)
            return Dropdown
        end

        table.insert(Window.tabs, Tab)
        return Tab
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
