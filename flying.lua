local player = game.Players.LocalPlayer

local gui, frame, toggle
local flying = false

local upForce, downForce
local currentChar, root, hum

-- Ground check
local function isGrounded()
	if not root then return true end

	local params = RaycastParams.new()
	params.FilterDescendantsInstances = {currentChar}
	params.FilterType = Enum.RaycastFilterType.Exclude

	local result = workspace:Raycast(root.Position, Vector3.new(0, -3, 0), params)
	return result ~= nil
end

-- Cleanup forces
local function cleanup()
	flying = false

	if upForce then upForce:Destroy() upForce = nil end
	if downForce then downForce:Destroy() downForce = nil end
end

-- Setup character references
local function setupCharacter(char)
	currentChar = char
	root = char:WaitForChild("HumanoidRootPart")
	hum = char:WaitForChild("Humanoid")

	cleanup()
end

-- Fly up
local function flyLoop()
	while flying and root do
		if not upForce then
			upForce = Instance.new("BodyVelocity")
			upForce.MaxForce = Vector3.new(0, 1e6, 0)
			upForce.Parent = root
		end

		upForce.Velocity = Vector3.new(0, 8, 0)
		task.wait(0.1)
	end
end

-- Land smoothly
local function land()
	if upForce then upForce:Destroy() upForce = nil end

	if not root then return end

	downForce = Instance.new("BodyVelocity")
	downForce.MaxForce = Vector3.new(0, 1e6, 0)
	downForce.Parent = root

	while root and not isGrounded() do
		downForce.Velocity = Vector3.new(0, -10, 0)
		task.wait(0.05)
	end

	if downForce then downForce:Destroy() downForce = nil end
end

-- GUI creation (once)
local function createGui()
	gui = Instance.new("ScreenGui")
	gui.Name = "SmoothFlyGUI"
	gui.ResetOnSpawn = false
	gui.Parent = player:WaitForChild("PlayerGui")

	frame = Instance.new("Frame", gui)
	frame.Size = UDim2.new(0, 200, 0, 90)
	frame.Position = UDim2.new(0.1, 0, 0.3, 0)
	frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	frame.Active = true
	frame.Draggable = true

	local title = Instance.new("TextLabel", frame)
	title.Size = UDim2.new(1, 0, 0, 30)
	title.Text = "Smooth Fly"
	title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	title.TextColor3 = Color3.new(1, 1, 1)

	toggle = Instance.new("TextButton", frame)
	toggle.Size = UDim2.new(1, -20, 0, 40)
	toggle.Position = UDim2.new(0, 10, 0, 40)
	toggle.Text = "OFF"
	toggle.BackgroundColor3 = Color3.fromRGB(200, 50, 50)

	toggle.MouseButton1Click:Connect(function()
		if flying then
			flying = false
			toggle.Text = "OFF"
			toggle.BackgroundColor3 = Color3.fromRGB(200, 50, 50)

			task.spawn(land)
		else
			flying = true
			toggle.Text = "ON"
			toggle.BackgroundColor3 = Color3.fromRGB(50, 200, 50)

			task.spawn(flyLoop)
		end
	end)
end

-- Character respawn handling
player.CharacterAdded:Connect(function(char)
	task.wait(0.2)
	setupCharacter(char)
end)

-- Init
createGui()
setupCharacter(player.Character or player.CharacterAdded:Wait())
