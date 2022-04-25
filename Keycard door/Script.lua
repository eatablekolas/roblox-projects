-- made by eatablekolas

--// Services \\--
local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")
local RunS = game:GetService("RunService")
local TS = game:GetService("TweenService")

--// Remote events \\--
local DoorLockedEvent = RepS:WaitForChild("DoorLocked")
local DoorOpeningEvent = RepS:WaitForChild("DoorOpening")
local InputSwitchEvent = RepS:WaitForChild("InputSwitch")

--// Door elements \\--
local DoorRoot = script.Parent.Door.PrimaryPart
local DoorMain = script.Parent.Door.Main
local ProximityPrompt = script.Parent.Door.DoorBox.ProximityPrompt
local CardBlockL = script.Parent.CardBlockL
local CardBlockR = script.Parent.CardBlockR

--// Constants \\--
local AUTO_CLOSE = true
local AUTO_CLOSE_TIME = 10

Texts = {
	Open = "O P E N";
	Close = "C L O S E";
}

CFrames = {
	CharacterOffset = CFrame.new(-1.6881485, 1.00040436, 1.93951416, 1, 0, 0, 0, 1, 0, 0, 0, 1);
	Closed = DoorRoot.CFrame;
	OpenRight = DoorRoot.CFrame * CFrame.Angles(0, math.rad(90), 0);
	OpenLeft = DoorRoot.CFrame * CFrame.Angles(0, math.rad(-90), 0);
	-- "OpenRight" because that's how it's opened with the handle being on the player's right, same goes for "OpenLeft"
}

Colors = {
	Red = Color3.fromRGB(255, 0, 0);
	Green = Color3.fromRGB(0, 255, 0);
}

--// Variables \\--
local debounce = false
local state = "Closed"

--// Functions \\--
local function WaitFrames(amount)
	for i=1, amount do
		RunS.Heartbeat:Wait()
	end
end

local function SwitchDiodeColor(color)
	CardBlockL.Diode.Color = color
	CardBlockR.Diode.Color = color
end

ProximityPrompt.Triggered:Connect(function(player)
	local character = player.Character or player.CharacterAdded:Wait()
	if not character:FindFirstChild("Keycard") and not player.Backpack:FindFirstChild("Keycard") and state == "Closed" then
		DoorLockedEvent:FireClient(player)
		return
	elseif player.Backpack:FindFirstChild("Keycard") and state == "Closed" then
		player.Backpack.Keycard.Parent = character
	end
	
	debounce = true
	ProximityPrompt.Enabled = false
	
	local XDistance = DoorMain.CFrame:ToObjectSpace(character.PrimaryPart.CFrame).X
	local targetCFrame
	if state == "Open" then
		targetCFrame = CFrames.Closed
		ProximityPrompt.ActionText = Texts.Open
		state = "Closed"
	else
		local referenceBlock
		if XDistance > 0 then
			targetCFrame = CFrames.OpenLeft
			referenceBlock = CardBlockL
		else
			targetCFrame = CFrames.OpenRight
			referenceBlock = CardBlockR
		end
		
		local humanoid = character:WaitForChild("Humanoid")
		local targetCharacterCFrame = referenceBlock.PrimaryPart.CFrame * CFrames.CharacterOffset
		InputSwitchEvent:FireClient(player, false)
		humanoid:MoveTo(targetCharacterCFrame.Position)
		humanoid.MoveToFinished:Wait()
		character:SetPrimaryPartCFrame(targetCharacterCFrame)
		character.PrimaryPart.Anchored = true
		DoorOpeningEvent:FireClient(player, referenceBlock)
		
		WaitFrames(30)
		if character:FindFirstChild("Keycard") then
			character.Keycard.Parent = player.Backpack
		end
		InputSwitchEvent:FireClient(player, true)
		character.PrimaryPart.Anchored = false
		SwitchDiodeColor(Colors.Green)
		ProximityPrompt.ActionText = Texts.Close
		state = "Open"
		
		if AUTO_CLOSE then
			spawn(function()
				for i=1, AUTO_CLOSE_TIME do
					if state == "Closed" then return end
					wait(1)
				end
				
				debounce = true
				ProximityPrompt.Enabled = false
				
				targetCFrame = CFrames.Closed
				ProximityPrompt.ActionText = Texts.Open
				state = "Closed"
				
				local tween = TS:Create(DoorRoot, TweenInfo.new(), {CFrame = targetCFrame})
				tween:Play()
				
				tween.Completed:Wait()
				SwitchDiodeColor(Colors.Red)
				debounce = false
				ProximityPrompt.Enabled = true
			end)
		end
	end
	
	local tween = TS:Create(DoorRoot, TweenInfo.new(), {CFrame = targetCFrame})
	tween:Play()
	
	tween.Completed:Wait()
	if state == "Closed" then SwitchDiodeColor(Colors.Red) end
	debounce = false
	ProximityPrompt.Enabled = true
end)