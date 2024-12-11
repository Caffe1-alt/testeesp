local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local localPlayer = Players.LocalPlayer

local espInstances = {}

local function getTeamColor(player)
    if player.Team == localPlayer.Team then
        return Color3.new(0, 0, 1)
    else
        return Color3.new(1, 0, 0)
    end
end

local function createESP(player)
    if espInstances[player] then return end

    local function setupCharacter(character)
        local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

        local box = Instance.new("BoxHandleAdornment")
        box.Adornee = humanoidRootPart
        box.Size = Vector3.new(4, 6, 4)
        box.AlwaysOnTop = true
        box.ZIndex = 5
        box.Transparency = 0.3
        box.Color3 = getTeamColor(player)
        box.Parent = humanoidRootPart

        local billboard = Instance.new("BillboardGui")
        billboard.Adornee = humanoidRootPart
        billboard.Size = UDim2.new(4, 0, 1, 0)
        billboard.AlwaysOnTop = true
        billboard.MaxDistance = 100

        local textLabel = Instance.new("TextLabel", billboard)
        textLabel.Size = UDim2.new(1, 0, 1, 0)
        textLabel.BackgroundTransparency = 1
        textLabel.TextColor3 = getTeamColor(player)
        textLabel.TextScaled = true
        textLabel.Font = Enum.Font.SourceSansBold
        textLabel.Text = string.format("%s - %d HP", player.Name, 100)

        billboard.Parent = humanoidRootPart

        local humanoid = character:WaitForChild("Humanoid")
        humanoid:GetPropertyChangedSignal("Health"):Connect(function()
            textLabel.Text = string.format("%s - %d HP", player.Name, math.floor(humanoid.Health))
        end)

        espInstances[player] = { box = box, billboard = billboard }

        player:GetPropertyChangedSignal("Team"):Connect(function()
            box.Color3 = getTeamColor(player)
            textLabel.TextColor3 = getTeamColor(player)
        end)
    end

    if player.Character then
        setupCharacter(player.Character)
    end

    player.CharacterAdded:Connect(function(character)
        setupCharacter(character)
    end)

    player.CharacterRemoving:Connect(function()
        if espInstances[player] then
            espInstances[player].box:Destroy()
            espInstances[player].billboard:Destroy()
            espInstances[player] = nil
        end
    end)
end

local function updateESPColors()
    for player, instance in pairs(espInstances) do
        if player and player.Team then
            local newColor = getTeamColor(player)
            if instance.box then
                instance.box.Color3 = newColor
            end
            if instance.billboard then
                instance.billboard.TextLabel.TextColor3 = newColor
            end
        end
    end
end

local function monitorTeamChanges()
    localPlayer:GetPropertyChangedSignal("Team"):Connect(function()
        updateESPColors()
    end)

    Players.PlayerAdded:Connect(function(player)
        task.delay(10, function()
            if player ~= localPlayer and player.Team then
                createESP(player)
            end
        end)
    end)
end

Players.PlayerAdded:Connect(function(player)
    task.delay(10, function()
        if player ~= localPlayer then
            createESP(player)
        end
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
    if player ~= localPlayer then
        createESP(player)
    end
end

task.delay(5, function()
    monitorTeamChanges()
end)
