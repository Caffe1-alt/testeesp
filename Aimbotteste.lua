local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local localPlayer = Players.LocalPlayer

local aimInterval = 0.05
local maxDistance = 600

local lastUpdate = 0

local function isAlly(player)
    return player.Team == localPlayer.Team
end

local function getClosestEnemy()
    local closestEnemy = nil
    local closestDistance = math.huge

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= localPlayer and not isAlly(player) and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local rootPart = player.Character.HumanoidRootPart
            local distance = (rootPart.Position - localPlayer.Character.HumanoidRootPart.Position).Magnitude

            if distance <= maxDistance then
                local direction = (rootPart.Position - localPlayer.Character.HumanoidRootPart.Position).Unit * distance
                local rayParams = RaycastParams.new()
                rayParams.FilterDescendantsInstances = {localPlayer.Character}
                rayParams.FilterType = Enum.RaycastFilterType.Blacklist

                local result = Workspace:Raycast(localPlayer.Character.HumanoidRootPart.Position, direction, rayParams)

                if result and result.Instance:IsDescendantOf(player.Character) and distance < closestDistance then
                    closestEnemy = rootPart
                    closestDistance = distance
                end
            end
        end
    end

    return closestEnemy
end

local function aimAtTarget(target)
    local camera = Workspace.CurrentCamera
    if target then
        camera.CFrame = CFrame.new(camera.CFrame.Position, target.Position)
    end
end

local function monitorAimBot()
    RunService.RenderStepped:Connect(function()
        if tick() - lastUpdate >= aimInterval then
            lastUpdate = tick()

            local closestEnemy = getClosestEnemy()
            if closestEnemy then
                aimAtTarget(closestEnemy)
            end
        end
    end)
end

task.delay(5, function()
    monitorAimBot()
end)
