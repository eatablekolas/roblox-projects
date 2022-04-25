-- made by eatablekolas (with some help from EgoMoose's tutorial)

--// Services \\--
local GuiS = game:GetService("GuiService")
local RepS = game:GetService("ReplicatedStorage")
local RunS = game:GetService("RunService")
local TS = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")

--// Replicated elements \\--
local Guns = RepS:WaitForChild("Guns")
local Remotes = RepS:WaitForChild("Remotes")

--// Player elements \\--
local Player = script.Parent.Parent.Parent
local Camera = workspace.CurrentCamera
local Mouse = Player:GetMouse()

--// Character elements \\--
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

--// GUI elements \\--
local Crosshair = script.Parent.Crosshair
local Ammo = script.Parent.Ammo

--// Constants \\--
local Sizes = {
	Aim = UDim2.fromOffset(2, 2);
	Hip =  UDim2.fromOffset(75, 75);
}

local FOVs = {
	Origin = Camera.FieldOfView;
	Zoomed = 50;
}

-- 1. The shot at which the pattern should end
-- 2. How high the camera will go due to recoil
-- 3. How high the camera will go after recoil
-- 4. How fast the recoil will move
-- 5. Horizontal recoil ratio

local RECOIL_PATTERN = {
	{6, 12, -1, 0.77, -0.1},
	{12, 12, -1, 0.77, 0.1},
	{20, 12, -1, 0.77, -0.1},
	{32, 12, -1, 0.77, 0.1}
}

local ZOOM_TIME = 0.1 -- Time it takes to zoom in
local MAX_AMMO = 96 -- The max amount of ammo a player can hold
local MAX_MAG_AMMO = 32 -- The capacity of a magazine
local RECOIL_RESET = 0.5 -- Time it takes for recoil pattern to reset
local CROSSHAIR_RATIO = 5
local CROSSHAIR_LIMIT = 5

--// Variables \\--
local Animations = {
	Hip = Humanoid:LoadAnimation(script.Hip);
	Shoot = Humanoid:LoadAnimation(script.Shoot);
	--Aim = Humanoid:LoadAnimation(script.Aim);
	Reload = Humanoid:LoadAnimation(script.Reload);
}

local lastAnim = Animations.Hip
local ammo = MAX_AMMO
local mag_ammo = MAX_MAG_AMMO
local curShots = 0
local lastClick = tick()
local shooting = false
local aiming = false
local reloading = false

--// Functions \\--
local function IsExisting(player)
	if player.Character and player.Character:FindFirstChild("Humanoid") then
		return true
	end
	return false
end

local function IsDead(player)
	if Player.Character.Humanoid.Health <= 0 then
		return true
	end
	return false
end

local function Lerp(a, b, t) -- Gets a number between two points using an alpha
	return a * (1 - t) + (b * t)
end

local function OnCharacterAdded(char)
	Character = char
	Humanoid = char:WaitForChild("Humanoid")
	
	Animations.Hip = Humanoid:LoadAnimation(script.Hip)
	--Animations.Aim = Humanoid:LoadAnimation(script.Aim)
	Animations.Reload = Humanoid:LoadAnimation(script.Reload)
	
	Remotes.Setup:FireServer(Guns.MP40)
	lastAnim:Play()
end

local function RefreshAmmoFrame()
	Ammo.Mag.Text = mag_ammo
	Ammo.Total.Text = "/" .. ammo
end

local function Recoil()
	curShots = (tick() - lastClick > RECOIL_RESET and 1 or curShots + 1) -- Either reset or or increase the current shot we're at
	lastClick = tick()
	for i, v in pairs(RECOIL_PATTERN) do
		if curShots <= v[1] then -- Found the current recoil we're at
			spawn(function()
				local num = 0
				while math.abs(num - v[2]) > 0.01 do
					num = Lerp(num, v[2], v[4])
					
					local shots = curShots - 1 < CROSSHAIR_LIMIT and curShots - 1 or CROSSHAIR_LIMIT
					local guiNum = (num - 1) * shots  * CROSSHAIR_RATIO
					local size = UDim2.fromOffset(75 + guiNum, 75 + guiNum)
					Crosshair:TweenSize(size, Enum.EasingDirection.Out, Enum.EasingStyle.Quad, ZOOM_TIME, true)
					
					local rec = num / 10
					Camera.CFrame = Camera.CFrame * CFrame.Angles(math.rad(rec), math.rad(rec * v[5]), 0)
					RunS.RenderStepped:Wait()
				end
				while math.abs(num - v[3]) > 0.01 do
					num = Lerp(num, v[3], v[4])
					
					local size = Crosshair.Size - UDim2.fromOffset(1, 1)
					Crosshair:TweenSize(size, Enum.EasingDirection.Out, Enum.EasingStyle.Quad, ZOOM_TIME, true)
					
					local rec = num / 10
					Camera.CFrame = Camera.CFrame * CFrame.Angles(math.rad(rec), math.rad(rec * v[5]), 0)
					RunS.RenderStepped:Wait()
				end
			end)
			
			spawn(function()
				repeat RunS.RenderStepped:Wait() until tick() - lastClick > RECOIL_RESET
				local size = aiming and Sizes.Aim or Sizes.Hip
				Crosshair:TweenSize(size, Enum.EasingDirection.Out, Enum.EasingStyle.Quad, ZOOM_TIME, true)
			end)
			
			break
		end
	end
end

local connection
local function Shoot(shoot)
	local function Shot()
		local viewportPoint = Camera.ViewportSize / 2
		local guiInset = GuiS:GetGuiInset().Y / 2
		local xOffset = 0
		local yOffset = 0
		if Crosshair.Size.X.Offset > 2 then
			xOffset = math.random(-(Crosshair.Size.X.Offset / 2 - Crosshair.Up.Size.Y.Offset), Crosshair.Size.X.Offset / 2 - Crosshair.Up.Size.Y.Offset)
			yOffset = math.random(-(Crosshair.Size.Y.Offset / 2 - Crosshair.Up.Size.Y.Offset), Crosshair.Size.Y.Offset / 2 - Crosshair.Up.Size.Y.Offset)
		end
		local unitRay = Camera:ScreenPointToRay(viewportPoint.X + xOffset, viewportPoint.Y - guiInset + yOffset)
		Remotes.Shoot:FireServer(unitRay)
		Recoil()
		mag_ammo = mag_ammo - 1
		Ammo.Mag.Text = mag_ammo
	end
	
	lastAnim:Stop()
	lastAnim = shoot and Animations.Shoot or Animations.Hip
	lastAnim:Play()
	
	if shoot then
		Shot()
		connection = lastAnim.DidLoop:Connect(function()
			if not Player.Character or not Player.Character:FindFirstChild("Humanoid") or Humanoid.Health <= 0 or mag_ammo <= 0 then
				connection:Disconnect()
				lastAnim:Stop()
				lastAnim = Animations.Hip
				lastAnim:Play()
				return
			end
			Shot()
		end)
	else
		if connection then connection:Disconnect() end
	end
end

local function AimDownSights(aiming)
	--lastAnim:Stop()
	--lastAnim = aiming and Animations.Aim or Animations.Hip
	--lastAnim:Play()
	
	local state = aiming and "Aim" or "Hip"
	local fov = aiming and "Zoomed" or "Origin"
	Crosshair:TweenSize(Sizes[state], Enum.EasingDirection.Out, Enum.EasingStyle.Quad, ZOOM_TIME, true)
	TS:Create(Camera, TweenInfo.new(ZOOM_TIME), {FieldOfView = FOVs[fov]}):Play()
end

local function Reload()
	lastAnim:Stop()
	lastAnim = Animations.Reload
	lastAnim.Looped = false
	lastAnim:Play()
	lastAnim.Stopped:Wait()
	
	if ammo >= MAX_MAG_AMMO - mag_ammo then
		ammo = ammo - (MAX_MAG_AMMO - mag_ammo)
		mag_ammo = MAX_MAG_AMMO
	else
		mag_ammo = mag_ammo + ammo
		ammo = 0
	end
	RefreshAmmoFrame()
end

--

if Player.Character then OnCharacterAdded(Player.Character) end
Player.CharacterAdded:Connect(OnCharacterAdded)

UIS.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 and not reloading and mag_ammo > 0 then
		shooting = true
		Shoot(true)
	elseif input.UserInputType == Enum.UserInputType.MouseButton2 and not reloading then
		aiming = true
		AimDownSights(true)
	elseif input.KeyCode == Enum.KeyCode.R and not reloading and ammo > 0 and mag_ammo ~= MAX_MAG_AMMO then
		reloading = true
		if aiming then AimDownSights(false) end
		if shooting then Shoot(false) end
		Reload()
		lastAnim = Animations.Hip
		lastAnim:Play()
		reloading = false
	end
end)

UIS.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 and not reloading then
		shooting = false
		Shoot(false)
	elseif input.UserInputType == Enum.UserInputType.MouseButton2 and not reloading then
		aiming = false
		AimDownSights(false)
	end
end)

RunS.RenderStepped:Connect(function()
	if not IsExisting(Player) or IsDead(Player) then return end
	Remotes.Tilt:FireServer(math.asin(Camera.CFrame.LookVector.y))
end)