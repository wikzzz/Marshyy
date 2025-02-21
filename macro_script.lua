local player = game.Players.LocalPlayer
local userInput = game:GetService("UserInputService")
local virtualInput = game:GetService("VirtualInputManager")

local macroRunning = false  
local stopping = false      

-- UI Setup
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player:FindFirstChild("PlayerGui")

local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 120, 0, 50)
button.Position = UDim2.new(0.1, 0, 0.1, 0)
button.BackgroundColor3 = Color3.fromRGB(30, 144, 255)
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.Text = "Start Macro"
button.Font = Enum.Font.SourceSansBold
button.TextSize = 20
button.Parent = screenGui
button.Draggable = true
button.Active = true
button.Selectable = true

-- Function to equip an item from inventory
local function equipItem(itemName)
    if not macroRunning then return end  
    local backpack = player:FindFirstChild("Backpack")

    if backpack then
        for _, item in pairs(backpack:GetChildren()) do
            if item:IsA("Tool") and item.Name == itemName then
                player.Character.Humanoid:EquipTool(item)
                wait(0.5)
                return
            end
        end
    end
    print("Item not found:", itemName)
end

-- Function to simulate pressing 'E' key
local function pressE(times)
    for i = 1, times do
        if not macroRunning then return end
        virtualInput:SendKeyEvent(true, Enum.KeyCode.E, false, game)
        wait(0.1)
        virtualInput:SendKeyEvent(false, Enum.KeyCode.E, false, game)
        wait(0.2)
    end
end

-- Function to wait for an on-screen message
local function waitForMessage(targetMessage)
    while macroRunning do
        local gui = player:FindFirstChild("PlayerGui")
        if gui then
            for _, obj in pairs(gui:GetDescendants()) do
                if obj:IsA("TextLabel") and obj.Text == targetMessage then
                    return true
                end
            end
        end
        wait(0.5)
    end
    return false
end

-- Function to detect the current step
local function detectCurrentStep()
    local gui = player:FindFirstChild("PlayerGui")
    if gui then
        for _, obj in pairs(gui:GetDescendants()) do
            if obj:IsA("TextLabel") then
                if obj.Text == "Dump the sugar block from the bag into the pot." then
                    return "Sugar"
                elseif obj.Text == "Pour some gelatin into the pot." then
                    return "Gelatin"
                elseif obj.Text == "Bag the solution into the empty bag." then
                    return "EmptyBag"
                elseif obj.Text == "Turn on the water." or obj.Text == "Fill the pot with water." then
                    return "Water"
                end
            end
        end
    end

    return "Start"
end

-- Function to handle macro automation
local function toggleMacro()
    macroRunning = not macroRunning
    button.Text = macroRunning and "Stop Macro" or "Start Macro"

    while macroRunning do
        stopping = false
        local currentStep = detectCurrentStep()

        -- If in Water Stage, equip Water and press E
        if currentStep == "Water" then
            equipItem("Water")
            wait(1)
            pressE(1)
            wait(1)
            currentStep = "Sugar"
        end

        -- If at Start, equip Water and press E
        if currentStep == "Start" then
            equipItem("Water")
            wait(1)
            pressE(1)
            wait(1)
            currentStep = "Sugar"
        end

        -- Sugar Step
        if currentStep == "Sugar" and waitForMessage("Dump the sugar block from the bag into the pot.") then
            equipItem("Sugar Block Bag")
            pressE(1)
            wait(1)
            currentStep = "Gelatin"
        end

        -- Gelatin Step
        if currentStep == "Gelatin" and waitForMessage("Pour some gelatin into the pot.") then
            equipItem("Gelatin")
            wait(1)
            pressE(1)
            wait(1)
            currentStep = "EmptyBag"
        end

        -- Empty Bag Step
        if currentStep == "EmptyBag" and waitForMessage("Bag the solution into the empty bag.") then
            equipItem("Empty Bag")
            wait(1)
            pressE(1)
            wait(1)
            currentStep = "Completed"
        end

        -- Completed Step - Equip Water Again
        if currentStep == "Completed" then
            print("Cycle complete! Restarting in 2 seconds...")
            wait(2)
            equipItem("Water") -- Equip Water Again
            wait(1)
            pressE(1) -- Use Water
            wait(1)
            currentStep = "Start"
        end

        -- Stop if macro is turned off
        if not macroRunning then
            stopping = true
            return
        end
    end

    stopping = true
end

-- Connect button click to macro toggle
button.MouseButton1Click:Connect(toggleMacro)
