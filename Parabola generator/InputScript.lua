local CreateFunc = script.Parent.Parent.Create
local GenerateButton = script.Parent.Generate
local Boxes = {script.Parent.aBox, script.Parent.bBox, script.Parent.cBox, script.Parent.dBox}
local ErrorInfo = script.Parent.Error
local GeneratingInfo = script.Parent.Generating

local ErrorDisappearTime

GenerateButton.MouseButton1Click:Connect(function()
	local Data = {}
	
	for _, box in pairs(Boxes) do
		if box.Text == "" then
			if box.Name == "dBox" then
				Data[box.Name:sub(1, 1)] = 0
			else
				Data[box.Name:sub(1, 1)] = 1
			end
			continue
		end
		if tonumber(box.Text) == nil then
			ErrorInfo.Text = "'" .. box.Name:sub(1, 1) .. "' is not a number!"
			ErrorInfo.Visible = true
			ErrorDisappearTime = tick() + 3
			wait(3)
			if tick() >= ErrorDisappearTime then
				ErrorInfo.Visible = false
			end
			return
		else
			Data[box.Name:sub(1, 1)] = tonumber(box.Text)
		end
	end
	
	CreateFunc:Invoke(Data["a"], Data["b"], Data["c"], Data["d"])
end)