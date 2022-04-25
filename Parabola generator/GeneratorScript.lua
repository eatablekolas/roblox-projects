-- Generating the layout

local CenterLine = script.Parent.CenterLine
local MiddleLine = script.Parent.MiddleLine
local InsideLine = script.Parent.InsideLine

local function ReverseGuiObject(guiObj)
	guiObj.AnchorPoint = Vector2.new(guiObj.AnchorPoint.Y, guiObj.AnchorPoint.X)
	guiObj.Size = UDim2.new(guiObj.Size.Y.Scale, guiObj.Size.Y.Offset, guiObj.Size.X.Scale, guiObj.Size.X.Offset)
	guiObj.Position = UDim2.new(guiObj.Position.Y.Scale, guiObj.Position.Y.Offset, guiObj.Position.X.Scale, guiObj.Position.X.Offset)
end

local function MakeLines(guiObj, pos)
	local xLine = guiObj:Clone()
	xLine.Position = pos
	xLine.Visible = true
	xLine.Parent = script.Parent

	local yLine = xLine:Clone()
	ReverseGuiObject(yLine)
	yLine.Parent = script.Parent
end

MakeLines(CenterLine, CenterLine.Position)

for i=0.25, 0.75, 0.5 do
	MakeLines(MiddleLine, UDim2.fromScale(0, i))
end

for i=0.05, 1, 0.05 do
	MakeLines(InsideLine, UDim2.fromScale(0, i))
end

-- Generating parabolas

local CreateFunction = script.Parent.Parent.Create
local ParabolaWorkspace = script.Parent.ParabolaWorkspace
local DotExample = script.Parent.DotExample

local function f(x, a, b, c, d)
	return a * x^3 + b * x^2 + c * x + d
end

local function CoordsToPosition(x, y)
	return UDim2.fromOffset(x * 25, -y * 25)
end

local function CreateParabola(a, b, c, d)
	ParabolaWorkspace:ClearAllChildren()
	for x=-10, 10, 1/200 do
		local Dot = DotExample:Clone()
		Dot.Name = "Dot"
		Dot.Position = CoordsToPosition(x, f(x, a, b, c, d))
		Dot.Visible = true
		Dot.Parent = ParabolaWorkspace
	end
end

CreateFunction.OnInvoke = function(a, b, c, d)
	local s, e = pcall(function()
		CreateParabola(a, b, c, d)
	end)
	if s then
		return true
	else
		return e
	end
end