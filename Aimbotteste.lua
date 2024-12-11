local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local localPlayer = Players.LocalPlayer

local aimInterval = 0.1
local lastAimTime = 0

local function getClosestEnemy()
    local closestEnemy = nil
    local shortestDistance = math.huge

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= localPlayer and player.Team ~= localPlayer.Team and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local distance = (player.Character.HumanoidRootPart.Position - localPlayer.Character.HumanoidRootPart.Position).Magnitude
            if distance < shortestDistance then
                shortestDistance = distance
                closestEnemy = player
            end
        end
    end

    return closestEnemy
end

local function aimAtTarget(target)
    local camera = workspace.CurrentCamera
    local targetPart = target.Character and target.Character:FindFirstChild("HumanoidRootPart")

    if targetPart then
        camera.CFrame = CFrame.new(camera.CFrame.Position, targetPart.Position)
    end
end

RunService.RenderStepped:Connect(function()
    if tick() - lastAimTime >= aimInterval then
        lastAimTime = tick()

        local closestEnemy = getClosestEnemy()
        if closestEnemy then
            aimAtTarget(closestEnemy)
        end
    end
end)
