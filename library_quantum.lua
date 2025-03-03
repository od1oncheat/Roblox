-- RobloxAdvancedLibrary v1.1
-- Comprehensive library for Roblox game development
-- Created by AI Assistant

local Library = {}
Library.__index = Library

-- Constants
local MENU_KEY = Enum.KeyCode.M
local DEFAULT_TWEEN_TIME = 0.3
local DEFAULT_EASE_STYLE = Enum.EasingStyle.Quad
local DEFAULT_EASE_DIR = Enum.EasingDirection.Out

-- UI Components
local GUI = {
    MainFrame = nil,
    MenuButton = nil,
    Notifications = {},
    Windows = {},
    ActiveWindow = nil
}

-- Utility Functions
local function CreateInstance(className, properties)
    local instance = Instance.new(className)
    for k, v in pairs(properties or {}) do
        instance[k] = v
    end
    return instance
end

local function Tween(object, properties, duration, style, direction)
    local tweenInfo = TweenInfo.new(
        duration or DEFAULT_TWEEN_TIME,
        style or DEFAULT_EASE_STYLE,
        direction or DEFAULT_EASE_DIR
    )
    local tween = game:GetService("TweenService"):Create(object, tweenInfo, properties)
    tween:Play()
    return tween
end

-- Core Systems

-- Player Management System
Library.PlayerSystem = {
    Cache = {},
    
    Initialize = function(self)
        game.Players.PlayerAdded:Connect(function(player)
            self:OnPlayerJoin(player)
        end)
        
        game.Players.PlayerRemoving:Connect(function(player)
            self:OnPlayerLeave(player)
        end)
        
        for _, player in ipairs(game.Players:GetPlayers()) do
            self:OnPlayerJoin(player)
        end
    end,
    
    OnPlayerJoin = function(self, player)
        self.Cache[player.UserId] = {
            Stats = {},
            Inventory = {},
            LastPosition = nil
        }
        
        -- Initialize player stats
        self:InitializeStats(player)
    end,
    
    OnPlayerLeave = function(self, player)
        self.Cache[player.UserId] = nil
    end,
    
    InitializeStats = function(self, player)
        local stats = {
            Level = 1,
            Experience = 0,
            Health = 100,
            Energy = 100,
            Coins = 0
        }
        
        self.Cache[player.UserId].Stats = stats
    end
}

-- Inventory System
Library.InventorySystem = {
    MaxSlots = 30,
    
    CreateInventory = function(self, player)
        local inventory = {
            Items = {},
            Equipment = {
                Weapon = nil,
                Armor = nil,
                Accessory = nil
            }
        }
        
        return inventory
    end,
    
    AddItem = function(self, player, itemData)
        local playerCache = Library.PlayerSystem.Cache[player.UserId]
        if not playerCache then return false end
        
        if #playerCache.Inventory.Items >= self.MaxSlots then
            return false
        end
        
        table.insert(playerCache.Inventory.Items, itemData)
        return true
    end,
    
    RemoveItem = function(self, player, itemIndex)
        local playerCache = Library.PlayerSystem.Cache[player.UserId]
        if not playerCache then return false end
        
        if itemIndex > #playerCache.Inventory.Items then
            return false
        end
        
        table.remove(playerCache.Inventory.Items, itemIndex)
        return true
    end
}

-- Extended Combat System
Library.CombatSystem = {
    DamageMultipliers = {
        HeadShot = 2,
        Critical = 1.5,
        BackStab = 1.8,
        ArmorPenetration = 1.3,
        ElementalBonus = 1.4
    },
    
    StatusEffects = {
        Burning = {damage = 5, duration = 5, tick = 1},
        Frozen = {slowdown = 0.5, duration = 3},
        Poisoned = {damage = 3, duration = 8, tick = 0.5},
        Stunned = {duration = 2},
        Bleeding = {damage = 2, duration = 6, tick = 0.5}
    },
    
    ActiveEffects = {},
    
    CalculateDamage = function(self, attacker, defender, weapon, hitPart)
        local base = weapon.Damage or 10
        local multiplier = 1
        
        -- Existing multipliers
        if hitPart and hitPart.Name == "Head" then
            multiplier = multiplier * self.DamageMultipliers.HeadShot
        end
        
        if math.random() < (weapon.CriticalChance or 0.1) then
            multiplier = multiplier * self.DamageMultipliers.Critical
        end
        
        -- New multipliers
        if weapon.ArmorPenetration then
            multiplier = multiplier * self.DamageMultipliers.ArmorPenetration
        end
        
        -- Check for backstab
        local attackerCFrame = attacker.PrimaryPart and attacker.PrimaryPart.CFrame
        local defenderCFrame = defender.PrimaryPart and defender.PrimaryPart.CFrame
        if attackerCFrame and defenderCFrame then
            local angle = math.abs(attackerCFrame.LookVector:Dot(defenderCFrame.LookVector))
            if angle > 0.7 then
                multiplier = multiplier * self.DamageMultipliers.BackStab
            end
        end
        
        -- Elemental damage
        if weapon.Element and defender.Weakness == weapon.Element then
            multiplier = multiplier * self.DamageMultipliers.ElementalBonus
        end
        
        return base * multiplier
    end,
    
    ApplyStatusEffect = function(self, target, effectName)
        local effect = self.StatusEffects[effectName]
        if not effect then return end
        
        local humanoid = target:FindFirstChild("Humanoid")
        if not humanoid then return end
        
        -- Create new effect instance
        local effectInstance = {
            Target = target,
            Type = effectName,
            TimeLeft = effect.duration,
            LastTick = tick()
        }
        
        -- Add to active effects
        if not self.ActiveEffects[target] then
            self.ActiveEffects[target] = {}
        end
        table.insert(self.ActiveEffects[target], effectInstance)
        
        -- Start effect loop
        spawn(function()
            while effectInstance.TimeLeft > 0 do
                wait(0.1)
                effectInstance.TimeLeft = effectInstance.TimeLeft - 0.1
                
                if effect.tick and tick() - effectInstance.LastTick >= effect.tick then
                    effectInstance.LastTick = tick()
                    
                    if effect.damage then
                        humanoid.Health = math.max(0, humanoid.Health - effect.damage)
                    end
                    
                    if effect.slowdown then
                        humanoid.WalkSpeed = humanoid.WalkSpeed * effect.slowdown
                    end
                end
            end
            
            -- Remove effect
            local index = table.find(self.ActiveEffects[target], effectInstance)
            if index then
                table.remove(self.ActiveEffects[target], index)
            end
            
            -- Reset effects
            if effect.slowdown then
                humanoid.WalkSpeed = 16
            end
        end)
    end,
    
    ApplyDamage = function(self, target, damage)
        local humanoid = target:FindFirstChild("Humanoid")
        if not humanoid then return end
        
        humanoid.Health = math.max(0, humanoid.Health - damage)
    end
}

-- Extended Quest System
Library.QuestSystem = {
    Quests = {},
    ActiveQuests = {},
    QuestChains = {},
    DailyQuests = {},
    WeeklyQuests = {},
    
    QuestTypes = {
        KILL = "KILL",
        COLLECT = "COLLECT",
        EXPLORE = "EXPLORE",
        CRAFT = "CRAFT",
        ACHIEVE = "ACHIEVE"
    },
    
    CreateQuest = function(self, questData)
        local quest = {
            Id = questData.Id,
            Title = questData.Title,
            Description = questData.Description,
            Type = questData.Type,
            Objectives = questData.Objectives,
            Rewards = questData.Rewards,
            PreRequisites = questData.PreRequisites,
            MinLevel = questData.MinLevel or 1,
            TimeLimit = questData.TimeLimit,
            Progress = {},
            Completed = false,
            StartTime = nil
        }
        
        for _, objective in ipairs(quest.Objectives) do
            quest.Progress[objective.Id] = 0
        end
        
        self.Quests[quest.Id] = quest
        return quest
    end,
    
    CreateQuestChain = function(self, chainData)
        local chain = {
            Id = chainData.Id,
            Title = chainData.Title,
            Quests = chainData.Quests,
            CurrentIndex = 1
        }
        
        self.QuestChains[chain.Id] = chain
        return chain
    end,
    
    GenerateDailyQuests = function(self)
        self.DailyQuests = {}
        
        -- Generate 3 random daily quests
        for i = 1, 3 do
            local quest = self:CreateRandomQuest("Daily")
            self.DailyQuests[quest.Id] = quest
        end
    end,
    
    CreateRandomQuest = function(self, questType)
        local templates = {
            {
                Type = self.QuestTypes.KILL,
                Title = "Defeat Enemies",
                Description = "Defeat %d %s",
                Targets = {"Zombies", "Skeletons", "Goblins", "Bandits"},
                CountRange = {5, 15}
            },
            {
                Type = self.QuestTypes.COLLECT,
                Title = "Gather Resources",
                Description = "Collect %d %s",
                Targets = {"Wood", "Stone", "Herbs", "Crystals"},
                CountRange = {10, 20}
            },
            {
                Type = self.QuestTypes.EXPLORE,
                Title = "Explore Locations",
                Description = "Discover %d new locations",
                CountRange = {2, 5}
            }
        }
        
        local template = templates[math.random(#templates)]
        local target = template.Targets and template.Targets[math.random(#template.Targets)]
        local count = math.random(template.CountRange[1], template.CountRange[2])
        
        return self:CreateQuest({
            Id = questType .. "_" .. tick(),
            Title = template.Title,
            Description = string.format(template.Description, count, target or ""),
            Type = template.Type,
            Objectives = {
                {
                    Id = "main",
                    Required = count,
                    Target = target
                }
            },
            Rewards = self:GenerateRandomRewards(questType)
        })
    end,
    
    GenerateRandomRewards = function(self, questType)
        local rewards = {}
        
        -- Base rewards
        table.insert(rewards, {
            Type = "Experience",
            Amount = questType == "Daily" and math.random(100, 300) or math.random(300, 800)
        })
        
        table.insert(rewards, {
            Type = "Coins",
            Amount = questType == "Daily" and math.random(50, 150) or math.random(150, 400)
        })
        
        -- Random chance for item reward
        if math.random() < 0.3 then
            table.insert(rewards, {
                Type = "Item",
                Item = {
                    Name = "Mystery Box",
                    Rarity = questType == "Daily" and "Common" or "Rare"
                }
            })
        end
        
        return rewards
    end,
    
    AssignQuest = function(self, player, questId)
        local quest = self.Quests[questId]
        if not quest then return false end
        
        if not self.ActiveQuests[player.UserId] then
            self.ActiveQuests[player.UserId] = {}
        end
        
        self.ActiveQuests[player.UserId][questId] = table.clone(quest)
        return true
    end,
    
    UpdateProgress = function(self, player, questId, objectiveId, progress)
        local playerQuests = self.ActiveQuests[player.UserId]
        if not playerQuests then return end
        
        local quest = playerQuests[questId]
        if not quest then return end
        
        quest.Progress[objectiveId] = progress
        
        -- Check if quest is completed
        local completed = true
        for _, objective in ipairs(quest.Objectives) do
            if quest.Progress[objective.Id] < objective.Required then
                completed = false
                break
            end
        end
        
        if completed then
            quest.Completed = true
            self:CompleteQuest(player, questId)
        end
    end,
    
    CompleteQuest = function(self, player, questId)
        local quest = self.ActiveQuests[player.UserId][questId]
        if not quest then return end
        
        -- Grant rewards
        for _, reward in ipairs(quest.Rewards) do
            if reward.Type == "Experience" then
                -- Add experience
                Library.PlayerSystem.Cache[player.UserId].Stats.Experience += reward.Amount
            elseif reward.Type == "Item" then
                -- Add item to inventory
                Library.InventorySystem:AddItem(player, reward.Item)
            end
        end
        
        -- Remove quest from active quests
        self.ActiveQuests[player.UserId][questId] = nil
    end
}

-- UI System
Library.UISystem = {
    Initialize = function(self)
        GUI.MainFrame = CreateInstance("ScreenGui", {
            Name = "LibraryGUI",
            Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
        })
        
        self:CreateMenuButton()
        self:SetupInputHandler()
    end,
    
    CreateMenuButton = function(self)
        GUI.MenuButton = CreateInstance("TextButton", {
            Name = "MenuButton",
            Text = "Menu (M)",
            Size = UDim2.new(0, 100, 0, 30),
            Position = UDim2.new(1, -110, 0, 10),
            BackgroundColor3 = Color3.fromRGB(40, 40, 40),
            TextColor3 = Color3.fromRGB(255, 255, 255),
            Parent = GUI.MainFrame
        })
        
        GUI.MenuButton.MouseButton1Click:Connect(function()
            self:ToggleMenu()
        end)
    end,
    
    SetupInputHandler = function(self)
        game:GetService("UserInputService").InputBegan:Connect(function(input)
            if input.KeyCode == MENU_KEY then
                self:ToggleMenu()
            end
        end)
    end,
    
    ToggleMenu = function(self)
        if not GUI.ActiveWindow then
            self:OpenMainMenu()
        else
            self:CloseActiveWindow()
        end
    end,
    
    OpenMainMenu = function(self)
        local mainMenu = CreateInstance("Frame", {
            Name = "MainMenu",
            Size = UDim2.new(0, 300, 0, 400),
            Position = UDim2.new(0.5, -150, 0.5, -200),
            BackgroundColor3 = Color3.fromRGB(30, 30, 30),
            Parent = GUI.MainFrame
        })
        
        -- Add menu items
        local menuItems = {
            {Name = "Inventory", Color = Color3.fromRGB(60, 120, 180)},
            {Name = "Stats", Color = Color3.fromRGB(180, 60, 60)},
            {Name = "Quests", Color = Color3.fromRGB(60, 180, 60)},
            {Name = "Settings", Color = Color3.fromRGB(180, 180, 60)}
        }
        
        for i, item in ipairs(menuItems) do
            local button = CreateInstance("TextButton", {
                Name = item.Name .. "Button",
                Text = item.Name,
                Size = UDim2.new(0.8, 0, 0, 40),
                Position = UDim2.new(0.1, 0, 0.1 + (i-1) * 0.15, 0),
                BackgroundColor3 = item.Color,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                Parent = mainMenu
            })
            
            button.MouseButton1Click:Connect(function()
                self:OpenWindow(item.Name)
            end)
        end
        
        GUI.ActiveWindow = mainMenu
        Tween(mainMenu, {Position = UDim2.new(0.5, -150, 0.5, -200)})
    end,
    
    CloseActiveWindow = function(self)
        if GUI.ActiveWindow then
            local window = GUI.ActiveWindow
            GUI.ActiveWindow = nil
            
            Tween(window, {Position = UDim2.new(0.5, -150, 1.5, 0)}).Completed:Connect(function()
                window:Destroy()
            end)
        end
    end,
    
    OpenWindow = function(self, windowName)
        self:CloseActiveWindow()
        
        local window = CreateInstance("Frame", {
            Name = windowName .. "Window",
            Size = UDim2.new(0, 400, 0, 500),
            Position = UDim2.new(0.5, -200, 1.5, 0),
            BackgroundColor3 = Color3.fromRGB(30, 30, 30),
            Parent = GUI.MainFrame
        })
        
        -- Add window content based on type
        if windowName == "Inventory" then
            self:PopulateInventoryWindow(window)
        elseif windowName == "Stats" then
            self:PopulateStatsWindow(window)
        elseif windowName == "Quests" then
            self:PopulateQuestsWindow(window)
        elseif windowName == "Settings" then
            self:PopulateSettingsWindow(window)
        end
        
        GUI.ActiveWindow = window
        Tween(window, {Position = UDim2.new(0.5, -200, 0.5, -250)})
    end,
    
    PopulateInventoryWindow = function(self, window)
        local inventory = Library.PlayerSystem.Cache[game.Players.LocalPlayer.UserId].Inventory
        
        -- Create inventory slots grid
        for i = 1, Library.InventorySystem.MaxSlots do
            local slot = CreateInstance("Frame", {
                Name = "Slot" .. i,
                Size = UDim2.new(0, 50, 0, 50),
                Position = UDim2.new(0.1 + ((i-1)%6) * 0.13, 0, 0.1 + math.floor((i-1)/6) * 0.13, 0),
                BackgroundColor3 = Color3.fromRGB(40, 40, 40),
                Parent = window
            })
            
            if inventory.Items[i] then
                -- Add item representation
                local itemLabel = CreateInstance("TextLabel", {
                    Text = inventory.Items[i].Name,
                    Size = UDim2.new(1, 0, 1, 0),
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    Parent = slot
                })
            end
        end
    end,
    
    PopulateStatsWindow = function(self, window)
        local stats = Library.PlayerSystem.Cache[game.Players.LocalPlayer.UserId].Stats
        
        local statsList = {
            {Name = "Level", Value = stats.Level},
            {Name = "Experience", Value = stats.Experience},
            {Name = "Health", Value = stats.Health},
            {Name = "Energy", Value = stats.Energy},
            {Name = "Coins", Value = stats.Coins}
        }
        
        for i, stat in ipairs(statsList) do
            local statFrame = CreateInstance("Frame", {
                Name = stat.Name .. "Frame",
                Size = UDim2.new(0.8, 0, 0, 40),
                Position = UDim2.new(0.1, 0, 0.1 + (i-1) * 0.15, 0),
                BackgroundColor3 = Color3.fromRGB(40, 40, 40),
                Parent = window
            })
            
            CreateInstance("TextLabel", {
                Text = stat.Name .. ": " .. stat.Value,
                Size = UDim2.new(1, 0, 1, 0),
                TextColor3 = Color3.fromRGB(255, 255, 255),
                Parent = statFrame
            })
        end
    end,
    
    PopulateQuestsWindow = function(self, window)
        local activeQuests = Library.QuestSystem.ActiveQuests[game.Players.LocalPlayer.UserId] or {}
        
        local questsList = CreateInstance("ScrollingFrame", {
            Size = UDim2.new(0.9, 0, 0.9, 0),
            Position = UDim2.new(0.05, 0, 0.05, 0),
            BackgroundTransparency = 1,
            Parent = window
        })
        
        local yOffset = 0
        for questId, quest in pairs(activeQuests) do
            local questFrame = CreateInstance("Frame", {
                Size = UDim2.new(1, 0, 0, 100),
                Position = UDim2.new(0, 0, 0, yOffset),
                BackgroundColor3 = Color3.fromRGB(40, 40, 40),
                Parent = questsList
            })
            
            CreateInstance("TextLabel", {
                Text = quest.Title,
                Size = UDim2.new(1, 0, 0, 30),
                TextColor3 = Color3.fromRGB(255, 255, 255),
                Parent = questFrame
            })
            
            yOffset = yOffset + 110
        end
    end,
    
    PopulateSettingsWindow = function(self, window)
        local settings = {
            {Name = "Sound Volume", Type = "Slider", Value = 0.5},
            {Name = "Music Volume", Type = "Slider", Value = 0.3},
            {Name = "Graphics Quality", Type = "Dropdown", Options = {"Low", "Medium", "High"}},
            {Name = "Show FPS", Type = "Toggle", Value = true}
        }
        
        for i, setting in ipairs(settings) do
            local settingFrame = CreateInstance("Frame", {
                Size = UDim2.new(0.8, 0, 0, 50),
                Position = UDim2.new(0.1, 0, 0.1 + (i-1) * 0.15, 0),
                BackgroundColor3 = Color3.fromRGB(40, 40, 40),
                Parent = window
            })
            
            CreateInstance("TextLabel", {
                Text = setting.Name,
                Size = UDim2.new(0.4, 0, 1, 0),
                TextColor3 = Color3.fromRGB(255, 255, 255),
                Parent = settingFrame
            })
            
            if setting.Type == "Slider" then
                -- Add slider implementation
            elseif setting.Type == "Dropdown" then
                -- Add dropdown implementation
            elseif setting.Type == "Toggle" then
                -- Add toggle implementation
            end
        end
    end
}

-- Animation System
Library.AnimationSystem = {
    Animations = {},
    
    LoadAnimation = function(self, animationId)
        local animation = Instance.new("Animation")
        animation.AnimationId = animationId
        return animation
    end,
    
    PlayAnimation = function(self, character, animationId, fadeTime, weight, priority)
        local humanoid = character:FindFirstChild("Humanoid")
        if not humanoid then return end
        
        local animator = humanoid:FindFirstChild("Animator")
        if not animator then
            animator = Instance.new("Animator")
            animator.Parent = humanoid
        end
        
        local animation = self.Animations[animationId] or self:LoadAnimation(animationId)
        self.Animations[animationId] = animation
        
        local animTrack = animator:LoadAnimation(animation)
        animTrack:Play(fadeTime, weight, priority)
        return animTrack
    end
}

-- Notification System
Library.NotificationSystem = {
    ShowNotification = function(self, message, duration)
        duration = duration or 3
        
        local notification = CreateInstance("Frame", {
            Size = UDim2.new(0, 200, 0, 50),
            Position = UDim2.new(1, 10, 0.8, 0),
            BackgroundColor3 = Color3.fromRGB(40, 40, 40),
            Parent = GUI.MainFrame
        })
        
        CreateInstance("TextLabel", {
            Text = message,
            Size = UDim2.new(1, 0, 1, 0),
            TextColor3 = Color3.fromRGB(255, 255, 255),
            Parent = notification
        })
        
        table.insert(GUI.Notifications, notification)
        self:UpdateNotificationPositions()
        
        Tween(notification, {Position = UDim2.new(0.8, 0, 0.8 - (#GUI.Notifications-1) * 0.1, 0)})
        
        delay(duration, function()
            local index = table.find(GUI.Notifications, notification)
            if index then
                table.remove(GUI.Notifications, index)
            end
            
            Tween(notification, {Position = UDim2.new(1.2, 0, notification.Position.Y.Scale, 0)}).Completed:Connect(function()
                notification:Destroy()
                self:UpdateNotificationPositions()
            end)
        end)
    end,
    
    UpdateNotificationPositions = function(self)
        for i, notification in ipairs(GUI.Notifications) do
            Tween(notification, {Position = UDim2.new(0.8, 0, 0.8 - (i-1) * 0.1, 0)})
        end
    end
}

-- Sound System
Library.SoundSystem = {
    Sounds = {},
    
    PlaySound = function(self, soundId, properties)
        local sound = Instance.new("Sound")
        sound.SoundId = soundId
        
        for k, v in pairs(properties or {}) do
            sound[k] = v
        end
        
        sound.Parent = workspace
        sound:Play()
        
        sound.Ended:Connect(function()
            sound:Destroy()
        end)
        
        return sound
    end
}

-- Initialize Library
function Library:Initialize()
    self.PlayerSystem:Initialize()
    self.UISystem:Initialize()
    
    -- Example notification
    self.NotificationSystem:ShowNotification("Library initialized successfully!")
end

return Library
