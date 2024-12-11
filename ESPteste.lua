local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local localPlayer = Players.LocalPlayer

local espInstances = {}

local function createESP(player)
    if espInstances[player] then return end

    local character = player.Character or player.CharacterAdded:Wait()
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

    local box = Instance.new("BoxHandleAdornment")
    box.Adornee = humanoidRootPart
    box.Size = Vector3.new(4, 6, 4)
    box.AlwaysOnTop = true
    box.ZIndex = 5
    box.Color3 = player.Team == localPlayer.Team and Color3.new(0, 0, 1) or Color3.new(1, 0, 0)
    box.Transparency = 0.3
    box.Parent = humanoidRootPart

    local billboard = Instance.new("BillboardGui")
    billboard.Adornee = humanoidRootPart
    billboard.Size = UDim2.new(4, 0, 1, 0)
    billboard.AlwaysOnTop = true
    billboard.MaxDistance = 100

    local textLabel = Instance.new("TextLabel", billboard)
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.TextColor3 = player.Team == localPlayer.Team and Color3.new(0, 0, 1) or Color3.new(1, 0, 0)
    textLabel.TextScaled = true
    textLabel.Font = Enum.Font.SourceSansBold
    textLabel.Text = string.format("%s - %d HP", player.Name, math.floor(character:WaitForChild("Humanoid").Health))

    billboard.Parent = humanoidRootPart

    local humanoid = character:WaitForChild("Humanoid")
    humanoid:GetPropertyChangedSignal("Health"):Connect(function()
        textLabel.Text = string.format("%s - %d HP", player.Name, math.floor(humanoid.Health))
    end)

    espInstances[player] = { box = box, billboard = billboard }

    player.CharacterRemoving:Connect(function()
        box:Destroy()
        billboard:Destroy()
        espInstances[player] = nil
    end)
end

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        createESP(player)
    end)
end)

Players.PlayerRemoving:Connect(function(player)
    if espInstances[player] then
        espInstances[player].box:Destroy()
        espInstances[player].billboard:Destroy()
        espInstances[player] = nil
    end
end)

for _, player in ipairs(Players:GetPlayers()) do
    if player ~= localPlayer and player.Character then
        createESP(player)
    end
end
