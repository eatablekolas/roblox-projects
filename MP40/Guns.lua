-- made by eatablekolas (with some help from EgoMoose's tutorial)

--// Services \\--
local RepS = game:GetService("ReplicatedStorage")

--// Replicated elements \\--
local Remotes = RepS:WaitForChild("Remotes")

--// Constants \\--
local neckC0 = CFrame.new(0, 0.8, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
local waistC0 = CFrame.new(0, 0.2, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
local rShoulderC0 = CFrame.new(1, 0.5, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
local lShoulderC0 = CFrame.new(-1, 0.5, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)

local RANGE = 100
local DAMAGE = 10
local CRIT_MULT = 3

--// Functions \\--
local function HasGun(player)
	if player.Character:FindFirstChildOfClass("Model") and player.Character:FindFirstChildOfClass("Model"):FindFirstChild("FirePart") then 
		return true
	end
	return false
end

Remotes.Setup.OnServerEvent:Connect(function(player, weapon)
	local weapon = weapon:Clone()
	local joint = Instance.new("Motor6D")
	joint.C0 = joint.C0 + Vector3.new(0.1, 0.3, 0.2)
	joint.Part0 = player.Character.RightHand
	joint.Part1 = weapon.Handle
	joint.Parent = weapon.Handle
	weapon.Parent = player.Character
end)

Remotes.Tilt.OnServerEvent:Connect(function(player, theta)
	local neck = player.Character.Head.Neck
	local waist = player.Character.UpperTorso.Waist
	local rShoulder = player.Character.RightUpperArm.RightShoulder
	local lShoulder = player.Character.LeftUpperArm.LeftShoulder
	
	neck.C0 = neckC0 * CFrame.fromEulerAnglesYXZ(theta*0.5, 0, 0)
	waist.C0 = waistC0 * CFrame.fromEulerAnglesYXZ(theta*0.5, 0, 0)
	rShoulder.C0 = rShoulderC0 * CFrame.fromEulerAnglesYXZ(theta*0.5, 0, 0)
	lShoulder.C0 = lShoulderC0 * CFrame.fromEulerAnglesYXZ(theta*0.5, 0, 0)
end)

Remotes.Shoot.OnServerEvent:Connect(function(player, unitRay)
	if not HasGun(player) then return end
	
	local ray = Ray.new(unitRay.Origin, unitRay.Direction * RANGE)
	local part = workspace:FindPartOnRay(ray, player.Character)
	if part and part.Parent:FindFirstChildOfClass("Humanoid") then
		local multiplier = part.Name == "Head" and CRIT_MULT or 1
		part.Parent.Humanoid:TakeDamage(DAMAGE * multiplier)
	end
	
	local firePart = player.Character:FindFirstChildOfClass("Model").FirePart
	firePart.FlashFX.Enabled = true
	firePart.FlashGui.Enabled = true
	wait(.1)
	firePart.FlashFX.Enabled = false
	firePart.FlashGui.Enabled = false
end)