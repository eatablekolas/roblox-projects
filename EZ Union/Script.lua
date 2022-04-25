-- Colors: 
-- Gray - 166, 166, 166
-- Green - 0, 166, 0

local CHS = game:GetService("ChangeHistoryService")
local Selection = game:GetService("Selection")

local toolbar = plugin:CreateToolbar("EZ Union")
local ezUnionButton = toolbar:CreateButton("Menu", "Open EZ Union menu", "rbxassetid://1507949215")

local gui = script.Parent.ScreenGui

local on = false
local clonedGui

local MESSAGE_TIMEOUT = 2
local DEFAULT_MESSAGE = "Pick the models and press the button!"
local NO_SELECTION_MESSAGE = "No models picked!"
local MULTIPLE_PARENTS_MESSAGE = "All models must have the same parent!"
local NOT_MODEL_MESSAGE = "One of the picked objects is not a model!"

ezUnionButton.Click:Connect(function()
	if not on then
		clonedGui = gui:Clone()
		clonedGui.Parent = game.CoreGui
		on = true
		
		local check = false
		local mode = "safe"
		
		clonedGui.Frame.Check.MouseButton1Click:Connect(function()
			if not check then
				check = true
				clonedGui.Frame.Check.BackgroundColor3 = Color3.fromRGB(0, 166, 0)
			else
				check = false
				clonedGui.Frame.Check.BackgroundColor3 = Color3.fromRGB(166, 166, 166)
			end
		end)
		
		clonedGui.Frame.Safe.MouseButton1Click:Connect(function()
			if mode ~= "safe" then
				mode = "safe"
				clonedGui.Frame.Safe.BackgroundColor3 = Color3.fromRGB(0, 166, 0)
				clonedGui.Frame.Instant.BackgroundColor3 = Color3.fromRGB(166, 166, 166)
			end
		end)
		
		clonedGui.Frame.Instant.MouseButton1Click:Connect(function()
			if mode ~= "instant" then
				mode = "instant"
				clonedGui.Frame.Safe.BackgroundColor3 = Color3.fromRGB(166, 166, 166)
				clonedGui.Frame.Instant.BackgroundColor3 = Color3.fromRGB(0, 166, 0)
			end
		end)
		
		clonedGui.Frame.Union.MouseButton1Click:Connect(function()
			local selectedObjects = Selection:Get()
			
			local function CheckSelection()
				if #selectedObjects <= 0 then
					clonedGui.Frame.Message.Text = NO_SELECTION_MESSAGE
					wait(MESSAGE_TIMEOUT)
					clonedGui.Frame.Message.Text = DEFAULT_MESSAGE
					return true
				else
					return false
				end
			end
			
			local function CheckParents()
				local parent
				for _, object in pairs(selectedObjects) do
					if parent == nil then
						parent = object.Parent
					elseif object.Parent ~= parent then
						clonedGui.Frame.Message.Text = MULTIPLE_PARENTS_MESSAGE
						wait(MESSAGE_TIMEOUT)
						clonedGui.Frame.Message.Text = DEFAULT_MESSAGE
						return true
					end
				end
				return false
			end
			
			local function CheckIfModels()
				for _, model in pairs(selectedObjects) do
					if model.ClassName ~= "Model" then
						clonedGui.Frame.Message.Text = NOT_MODEL_MESSAGE
						wait(MESSAGE_TIMEOUT)
						clonedGui.Frame.Message.Text = DEFAULT_MESSAGE
						return true
					end
				end
				return false
			end
			
			if CheckSelection() or CheckParents() or CheckIfModels() then return end
			
			if mode == "safe" then
				for _, model in pairs(selectedObjects) do
					for _, part in pairs(model:GetChildren()) do
						if (part.ClassName == "Part" or part.ClassName == "WedgePart" or part.ClassName == "CornerWedgePart")
						and (not check or (check and (part.Name == "Part" or part.Name == "Wedge"))) then
							local material = string.sub(tostring(part.Material), 15)
							part.Name = material
						end
					end
				end
			elseif mode == "instant" then
				local passedMaterials = {}
				
				local function ValidatePart(part)
					if #part:GetChildren() == 0
					and (part.ClassName == "Part" or part.ClassName == "WedgePart" or part.ClassName == "CornerWedgePart")
					and (not check or (check and (part.Name == "Part" or part.Name == "Wedge" or part.Name == "CornerWedge"))) then 
						return true
					else
						return false
					end
				end
				
				local function UnionParts(model, part1)
					table.insert(passedMaterials, #passedMaterials + 1, part1.Material)
					
					local otherParts = {}
					local success
					local newUnion
					
					for _, part2 in pairs(model:GetChildren()) do
						if ValidatePart(part2) and part2 ~= part1 and part2.Material == part1.Material then
							otherParts[#otherParts + 1] = part2
						end
					end
					
					if #otherParts > 0 then
						success, newUnion = pcall(function()
							return part1:UnionAsync(otherParts)
						end)
					end
					
					if success and newUnion then
						newUnion.Anchored = true
						newUnion.Parent = model
						part1:Destroy()
						for i, v in pairs(otherParts) do
							v:Destroy()
						end
					end
				end
				
				for _, model in pairs(selectedObjects) do
					for _, part1 in pairs(model:GetChildren()) do
						if ValidatePart(part1) then
							if #passedMaterials == 0 then
								UnionParts(model, part1)
							else
								for _, material in pairs(passedMaterials) do
									if material ~= part1.Material then
										UnionParts(model, part1)
									end
								end
							end
						end
					end
				end
			end
			
			CHS:SetWaypoint("Finished an EZ union")
		end)
	else
		clonedGui:Destroy()
		on = false
	end
end)