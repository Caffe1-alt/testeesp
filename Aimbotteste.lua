local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local localPlayer = Players.LocalPlayer

local aimInterval = 0.1
local lastAimTime = 0

local function isVisible(targetPart)
    local origin = Workspace.CurrentCamera.CFrame.Position
    local direction = (targetPart.Position - origin).Unit * 1000
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {localPlayer.Character, targetPart.Parent}
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist

    local result = Workspace:Raycast(origin, direction, raycastParams)
    return not result or result.Instance:IsDescendantOf(targetPart.Parent)
end

local function getClosestEnemy()
    local closestEnemy = nil
    local shortestDistance = math.huge

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= localPlayer and player.Team ~= localPlayer.Team and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local humanoidRootPart = player.Character.HumanoidRootPart
            local distance = (humanoidRootPart.Position - localPlayer.Character.HumanoidRootPart.Position).Magnitude

            if distance < shortestDistance and isVisible(humanoidRootPart) then
                shortestDistance = distance
                closestEnemy = player
            end
        end
    end

    return closestEnemy
end

local function aimAtTarget(target)
    local camera = Workspace.CurrentCamera
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
