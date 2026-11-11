
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Remote = RS:WaitForChild("SolarCombatEvent")

-- SETTINGS
local Settings = {
    Speed = 32,
    JumpPower = 100,
    FlySpeed = 45
}

local State = {
    Fly = false,
    Lock = false,
    Speed = false,
    HighJump = false,
    InfiniteJump = false
}

local Default = {
    Speed = 16,
    JumpPower = 50
}

-- CHARACTER
local Character
local Humanoid
local Root

local function updateCharacter()
    Character = Player.Character
    if not Character then return end

    Humanoid = Character:WaitForChild("Humanoid")
    Root = Character:WaitForChild("HumanoidRootPart")

    Default.Speed = Humanoid.WalkSpeed
    Default.JumpPower = Humanoid.JumpPower
end

updateCharacter()

Player.CharacterAdded:Connect(function()
    task.wait(0.5)
    updateCharacter()

    State.Fly = false
    State.Lock = false

    if Humanoid then
        Humanoid.WalkSpeed = Default.Speed
        Humanoid.JumpPower = Default.JumpPower
    end

    Camera.CameraSubject = Humanoid
end)

-- TARGET
local function getNearestTarget(maxRange)
    local folder = workspace:FindFirstChild("Targets")
    if not folder or not Root then return nil end

    local nearest = nil
    local shortest = maxRange

    for _, model in ipairs(folder:GetChildren()) do
        if model:IsA("Model") then
            local hum = model:FindFirstChildOfClass("Humanoid")
            local targetRoot = model:FindFirstChild("HumanoidRootPart")

            if hum and targetRoot and hum.Health > 0 then
                local distance =
                    (Root.Position - targetRoot.Position).Magnitude

                if distance < shortest then
                    shortest = distance
                    nearest = model
                end
            end
        end
    end

    return nearest
end

-- GUI
local Gui = Instance.new("ScreenGui")
Gui.Name = "SOLAR_V2"
Gui.ResetOnSpawn = false
Gui.Parent = Player:WaitForChild("PlayerGui")

local Main = Instance.new("Frame")
Main.Size = UDim2.fromOffset(260, 360)
Main.Position = UDim2.new(0.5, -130, 0.5, -180)
Main.BackgroundColor3 = Color3.fromRGB(24, 20, 38)
Main.Parent = Gui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 12)
Corner.Parent = Main

local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(155, 90, 255)
Stroke.Thickness = 1.5
Stroke.Parent = Main

-- HEADER
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 42)
Header.BackgroundColor3 = Color3.fromRGB(48, 30, 75)
Header.Parent = Main

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 12)
HeaderCorner.Parent = Header

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -85, 1, 0)
Title.Position = UDim2.fromOffset(12, 0)
Title.BackgroundTransparency = 1
Title.Text = "☾  SOLAR V2 LITE"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextSize = 15
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local Minimize = Instance.new("TextButton")
Minimize.Size = UDim2.fromOffset(35, 30)
Minimize.Position = UDim2.new(1, -42, 0, 6)
Minimize.Text = "—"
Minimize.TextSize = 18
Minimize.TextColor3 = Color3.new(1, 1, 1)
Minimize.BackgroundColor3 = Color3.fromRGB(105, 65, 155)
Minimize.Parent = Header

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 8)
MinCorner.Parent = Minimize

-- CONTENT
local Content = Instance.new("ScrollingFrame")
Content.Position = UDim2.fromOffset(10, 50)
Content.Size = UDim2.new(1, -20, 1, -60)
Content.BackgroundTransparency = 1
Content.BorderSizePixel = 0
Content.ScrollBarThickness = 3
Content.CanvasSize = UDim2.new(0, 0, 0, 0)
Content.Parent = Main

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0, 7)
Layout.SortOrder = Enum.SortOrder.LayoutOrder
Layout.Parent = Content

Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    Content.CanvasSize = UDim2.new(
        0, 0, 0, Layout.AbsoluteContentSize.Y + 10
    )
end)

local function makeButton(text, callback)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, -5, 0, 38)
    Button.BackgroundColor3 = Color3.fromRGB(55, 39, 78)
    Button.TextColor3 = Color3.new(1, 1, 1)
    Button.TextSize = 13
    Button.Font = Enum.Font.GothamMedium
    Button.Text = text
    Button.Parent = Content

    local C = Instance.new("UICorner")
    C.CornerRadius = UDim.new(0, 8)
    C.Parent = Button

    Button.Activated:Connect(callback)

    return Button
end

local function updateButton(button, name, enabled)
    button.Text = name .. " : " .. (enabled and "ON" or "OFF")
    button.BackgroundColor3 = enabled
        and Color3.fromRGB(105, 65, 155)
        or Color3.fromRGB(55, 39, 78)
end

-- FLY
local FlyButton

FlyButton = makeButton("Fly : OFF", function()
    State.Fly = not State.Fly
    updateButton(FlyButton, "Fly", State.Fly)

    if Humanoid then
        Humanoid.PlatformStand = false
    end
end)

-- LOCK CAMERA
local LockButton

LockButton = makeButton("LockCam : OFF", function()
    State.Lock = not State.Lock
    updateButton(LockButton, "LockCam", State.Lock)

    if not State.Lock and Humanoid then
        Camera.CameraSubject = Humanoid
    end
end)

-- HIGH JUMP
local JumpButton

JumpButton = makeButton("HighJump : OFF", function()
    State.HighJump = not State.HighJump
    updateButton(JumpButton, "HighJump", State.HighJump)

    if Humanoid then
        Humanoid.UseJumpPower = true
        Humanoid.JumpPower = State.HighJump
            and Settings.JumpPower
            or Default.JumpPower
    end
end)

-- SPEED
local SpeedButton

SpeedButton = makeButton("Speed : OFF", function()
    State.Speed = not State.Speed
    updateButton(SpeedButton, "Speed", State.Speed)

    if Humanoid then
        Humanoid.WalkSpeed = State.Speed
            and Settings.Speed
            or Default.Speed
    end
end)

-- INFINITE JUMP
local InfiniteButton

InfiniteButton = makeButton("InfiniteJump : OFF", function()
    State.InfiniteJump = not State.InfiniteJump
    updateButton(InfiniteButton, "InfiniteJump", State.InfiniteJump)
end)

UIS.JumpRequest:Connect(function()
    if State.InfiniteJump and Humanoid then
        Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- ATTACK
makeButton("ATTACK NEAREST TARGET", function()
    local target = getNearestTarget(30)

    if target then
        Remote:FireServer("Attack", target)
    end
end)

-- RESET
makeButton("RESET SETTINGS", function()
    State.Fly = false
    State.Lock = false
    State.Speed = false
    State.HighJump = false
    State.InfiniteJump = false

    if Humanoid then
        Humanoid.WalkSpeed = Default.Speed
        Humanoid.JumpPower = Default.JumpPower
        Humanoid.PlatformStand = false
        Camera.CameraSubject = Humanoid
    end

    updateButton(FlyButton, "Fly", false)
    updateButton(LockButton, "LockCam", false)
    updateButton(JumpButton, "HighJump", false)
    updateButton(SpeedButton, "Speed", false)
    updateButton(InfiniteButton, "InfiniteJump", false)
end)

-- MINIMIZE ICON
local Restore = Instance.new("TextButton")
Restore.Size = UDim2.fromOffset(48, 48)
Restore.Position = UDim2.new(0, 15, 0.5, -24)
Restore.BackgroundColor3 = Color3.fromRGB(105, 65, 155)
Restore.Text = "☾"
Restore.TextSize = 27
Restore.TextColor3 = Color3.new(1, 1, 1)
Restore.Visible = false
Restore.Parent = Gui

local RestoreCorner = Instance.new("UICorner")
RestoreCorner.CornerRadius = UDim.new(1, 0)
RestoreCorner.Parent = Restore

Minimize.Activated:Connect(function()
    Main.Visible = false
    Restore.Visible = true
end)

Restore.Activated:Connect(function()
    Main.Visible = true
    Restore.Visible = false
end)

-- DRAG HEADER
local dragging = false
local dragStart
local startPosition

Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

        dragging = true
        dragStart = input.Position
        startPosition = Main.Position
    end
end)

UIS.InputChanged:Connect(function(input)
    if dragging and (
        input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch
    ) then

        local delta = input.Position - dragStart

        Main.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- MOVEMENT & CAMERA UPDATE
local jumpUntil = 0

UIS.JumpRequest:Connect(function()
    if State.Fly then
        jumpUntil = os.clock() + 0.25
    end
end)

RunService.RenderStepped:Connect(function(dt)
    if not Character or not Humanoid or not Root then
        return
    end

    -- LOCK CAMERA
    if State.Lock then
        local target = getNearestTarget(500)

        if target then
            local targetHumanoid =
                target:FindFirstChildOfClass("Humanoid")

            if targetHumanoid then
                Camera.CameraSubject = targetHumanoid
            end
        else
            Camera.CameraSubject = Humanoid
        end
    end

    -- FLY
    if State.Fly then
        local move = Humanoid.MoveDirection
        local vertical = 0

        if UIS:IsKeyDown(Enum.KeyCode.Space) then
            vertical = 1
        elseif UIS:IsKeyDown(Enum.KeyCode.LeftControl) then
            vertical = -1
        elseif os.clock() < jumpUntil then
            vertical = 1
        end

        local direction = move + Vector3.new(0, vertical, 0)

        if direction.Magnitude > 0 then
            Root.CFrame = Root.CFrame
                + direction.Unit * Settings.FlySpeed * dt
        end
    end
end)

print("SOLAR V2 LITE CLIENT LOADED")
