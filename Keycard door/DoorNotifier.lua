-- made by eatablekolas

--// Services \\--
local CAS = game:GetService("ContextActionService")
local Players = game:GetService("Players")
local PPS = game:GetService("ProximityPromptService")
local RepS = game:GetService("ReplicatedStorage")
local TS = game:GetService("TweenService")

--// Remote events \\--
local DoorLockedEvent = RepS:WaitForChild("DoorLocked")
local DoorOpeningEvent = RepS:WaitForChild("DoorOpening")
local InputSwitchEvent = RepS:WaitForChild("InputSwitch")

--// Player elements \\--
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local Animator = Humanoid:WaitForChild("Animator")
local Camera = workspace.CurrentCamera

--// GUI elements \\--
local Notification = script.Parent.Notification
local Prompt = script.Parent.Prompt

--// Animations \\--
local SwipeAnim = Animator:LoadAnimation(script.Swipe)

--// Constants \\--
local POPUP_DURATION = 1
local POPUP_TWEEN_TIME = 1
local CAMERA_OFFSET = CFrame.new(1.59999847, 0, 1.20001221, 0, 0, 1, 0, 1, 0, -1, 0, 0);
local CAMERA_TWEEN_TIME = .5

local Positions = {
	Visible = UDim2.fromScale(0.5, 0.9);
	Hidden = UDim2.fromScale(0.5, 1.5);
}

--// Variables \\--
local debounce = false
local startTime

PPS.PromptShown:Connect(function(prompt)
	if prompt.Style ~= Enum.ProximityPromptStyle.Custom or prompt.Parent.Name ~= "DoorBox" then return end
	
	Prompt.ActionLabel.TextLabel.Text = prompt.ActionText
	Prompt.Adornee = prompt.Parent
	Prompt.Enabled = true
	
	prompt.PromptHidden:Wait()
	Prompt.Enabled = false
end)

DoorLockedEvent.OnClientEvent:Connect(function()
	if not debounce then
		Notification:TweenPosition(
			Positions.Visible, 
			Enum.EasingDirection.Out,
			Enum.EasingStyle.Quad,
			POPUP_TWEEN_TIME,
			false,
			function()
				startTime = tick()

				while wait(1) do
					if tick() > startTime + POPUP_DURATION then 
						Notification:TweenPosition(
							Positions.Hidden, 
							Enum.EasingDirection.In,
							Enum.EasingStyle.Quad,
							POPUP_TWEEN_TIME,
							false,
							nil
						)

						return
					end
				end
			end
		)
	else
		startTime = tick()
	end
end)

DoorOpeningEvent.OnClientEvent:Connect(function(cardBlock)
	SwipeAnim:Play()
	
	local originCFrame = Camera.CFrame
	Camera.CameraType = Enum.CameraType.Scriptable
	Camera.CFrame = cardBlock.PrimaryPart.CFrame * CAMERA_OFFSET
	
	SwipeAnim.Stopped:Wait()
	
	local cameraTween = TS:Create(Camera, TweenInfo.new(CAMERA_TWEEN_TIME), {CFrame = originCFrame})
	cameraTween:Play()
	cameraTween.Completed:Wait()
	Camera.CameraType = Enum.CameraType.Custom
end)

InputSwitchEvent.OnClientEvent:Connect(function(on)
	if not on then
		CAS:BindAction(
			"DisableInput",
			function() return Enum.ContextActionResult.Sink end,
			false,
			unpack(Enum.PlayerActions:GetEnumItems())
		)
	else
		CAS:UnbindAction("DisableInput")
	end
end)