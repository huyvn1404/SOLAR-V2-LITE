
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remote = ReplicatedStorage:FindFirstChild("SolarCombatEvent")

if not Remote then
    Remote = Instance.new("RemoteEvent")
    Remote.Name = "SolarCombatEvent"
    Remote.Parent = ReplicatedStorage
end

local NORMAL_RANGE = 30
local DAMAGE = 10
local COOLDOWN = 0.5

local lastAttack = {}

local function getTargetInfo(target)
    if typeof(target) ~= "Instance" then
        return nil
    end

    local targets = workspace:FindFirstChild("Targets")
    if not targets or not target:IsDescendantOf(targets) then
        return nil
    end

    if not target:IsA("Model") then
        return nil
    end

    local humanoid = target:FindFirstChildOfClass("Humanoid")
    local root = target:FindFirstChild("HumanoidRootPart")

    if not humanoid or not root or humanoid.Health <= 0 then
        return nil
    end

    return humanoid, root
end

Remote.OnServerEvent:Connect(function(player, action, target)
    if action ~= "Attack" then
        return
    end

    local now = os.clock()

    if lastAttack[player] and now - lastAttack[player] < COOLDOWN then
        return
    end

    local character = player.Character
    local playerRoot = character and character:FindFirstChild("HumanoidRootPart")

    if not playerRoot then
        return
    end

    local humanoid, targetRoot = getTargetInfo(target)

    if not humanoid then
        return
    end

    -- Server validates range; client cannot bypass this.
    local distance = (playerRoot.Position - targetRoot.Position).Magnitude

    if distance > NORMAL_RANGE then
        return
    end

    lastAttack[player] = now
    humanoid:TakeDamage(DAMAGE)
end)

Players.PlayerRemoving:Connect(function(player)
    lastAttack[player] = nil
end)
