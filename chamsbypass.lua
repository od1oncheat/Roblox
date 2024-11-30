local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local highlightColor = Color3.fromRGB(255, 255, 255) -- Начальный цвет подсветки (белый)

-- Создаем GUI для выбора цвета
local screenGui = Instance.new("ScreenGui")
local rgbInput = Instance.new("TextBox")
local applyButton = Instance.new("TextButton")

-- Настройки GUI
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Настройки TextBox для ввода RGB
rgbInput.Size = UDim2.new(0, 200, 0, 40)
rgbInput.Position = UDim2.new(0, 10, 0, 10)
rgbInput.PlaceholderText = "Введите RGB (например, 255,0,0)"
rgbInput.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
rgbInput.Parent = screenGui

-- Настройки кнопки применения цвета
applyButton.Size = UDim2.new(0, 200, 0, 40)
applyButton.Position = UDim2.new(0, 10, 0, 60)
applyButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
applyButton.Text = "Применить цвет"
applyButton.Parent = screenGui

-- Функция для создания эффекта Glow
local function createGlow(character)
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        local highlight = Instance.new("Highlight")
        highlight.Parent = character
        highlight.FillColor = highlightColor -- Цвет подсветки
        highlight.OutlineColor = Color3.fromRGB(0, 0, 0) -- Цвет обводки (черный)
        highlight.OutlineTransparency = 0 -- Прозрачность обводки
        highlight.FillTransparency = 0.5 -- Прозрачность заливки
        highlight.Adornee = character

        -- Обновляем Highlight, чтобы он следовал за персонажем
        RunService.RenderStepped:Connect(function()
            if character and character.Parent then
                highlight.Adornee = character
            else
                highlight:Destroy() -- Удаляем Highlight, если персонаж уничтожен
            end
        end)
    end
end

-- Подключение к событиям для создания Glow для всех игроков
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        if player ~= LocalPlayer then -- Проверяем, что это не локальный игрок
            createGlow(character)
        end
    end)
end)

-- Создание Glow для уже существующих игроков
for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer and player.Character then
        createGlow(player.Character)
    end
end

-- Обработчик нажатия на кнопку применения цвета
applyButton.MouseButton1Click:Connect(function()
    local rgbValues = rgbInput.Text:split(",")
    if #rgbValues == 3 then
        local r = tonumber(rgbValues[1])
        local g = tonumber(rgbValues[2])
        local b = tonumber(rgbValues[3])
        
        if r and g and b and r >= 0 and r <= 255 and g >= 0 and g <= 255 and b >= 0 and b <= 255 then
            highlightColor = Color3.new(r / 255, g / 255, b / 255) -- Преобразуем в Color3
            rgbInput.Text = "" -- Очищаем текстовое поле
            -- Обновляем цвет подсветки для всех игроков
            for _, player in ipairs(Players:GetPlayers()) do
                if player.Character then
                    local highlight = player.Character:FindFirstChildOfClass("Highlight")
                    if highlight then
                        highlight.FillColor = highlightColor -- Обновляем цвет подсветки
                    end
                end
            end
        else
            print("Некорректные значения RGB! Убедитесь, что значения находятся в диапазоне 0-255.")
        end
    else
        print("Введите три значения RGB, разделенные запятыми!")
    end
end)
