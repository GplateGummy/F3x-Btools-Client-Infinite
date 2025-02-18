local ImportModule = {}
local BtoolsFunctions = loadstring(game:HttpGet("https://raw.githubusercontent.com/GplateGummy/F3x-Btools-Client-Infinite/refs/heads/main/Function-Module.Lua"))()
local Utils = {}

function Utils.GetNumberFromString(String)
	local Number = String:match("%d+")
	return Number and tonumber(Number) or nil
end

function Utils.GetNormalIdFromIndex(Index)
	local NormalIdMap = {
		[0] = Enum.NormalId.Right,
		[1] = Enum.NormalId.Top,
		[2] = Enum.NormalId.Back,
		[3] = Enum.NormalId.Left,
		[4] = Enum.NormalId.Bottom,
		[5] = Enum.NormalId.Front
	}
	return NormalIdMap[Index]
end

function Utils.FindTableOccurrence(Haystack, Needle)
	for Index, Value in pairs(Haystack) do
		if Value == Needle then
			return Index
		end
	end
	return nil
end

function Utils.Slice(Table, Start, End)
	local Slice = {}
	for Index = Start, End do
		table.insert(Slice, Table[Index])
	end
	return Slice
end

function Utils.ToVector3(X, Y, Z)
	return Vector3.new(X or 0, Y or 0, Z or 0)
end

function Utils.ToCFrame(CFrameString)
	if typeof(CFrameString) == "CFrame" then
		return CFrameString
	end
	return CFrame.new(unpack(CFrameString))
end

function Utils.ToColor3(R, G, B)
	return Color3.new(R or 1, G or 1, B or 1)
end

function Utils.FindLPIConveyor(PowerValue)
	local SpBricks = game:GetService("Workspace"):FindFirstChild("Sp bricks")
	if SpBricks then
		local SpBricks2 = SpBricks:FindFirstChild("Sp bricks")
		if SpBricks2 then
			for _, Part in ipairs(SpBricks2:GetChildren()) do
				if Part.Name ~= "River" then
					continue
				end
				if not Part:FindFirstChild("Power") then
					continue
				end
				if Part:FindFirstChild("Value") ~= PowerValue then
					continue
				end
				return Part
			end
		end
	end
end

local Types = {
	Part = 0,
	WedgePart = 1,
	CornerWedgePart = 2,
	VehicleSeat = 3,
	Seat = 4,
	TrussPart = 5,
	SpecialMesh = 6,
	Texture = 7,
	Decal = 8,
	PointLight = 9,
	SpotLight = 10,
	SurfaceLight = 11,
	Smoke = 12,
	Fire = 13,
	Sparkles = 14,
	Model = 15,
	Folder = 18
}

local PartTypeMap = {
	[Types.Part] = "Normal",
	[Types.WedgePart] = "Wedge",
	[Types.CornerWedgePart] = "Corner",
	[Types.VehicleSeat] = "Vehicle Seat",
	[Types.Seat] = "Seat",
	[Types.TrussPart] = "Truss"
}

local DefaultNames = {
	Part = "Part",
	WedgePart = "Wedge",
	CornerWedgePart = "CornerWedge",
	VehicleSeat = "VehicleSeat",
	Seat = "Seat",
	TrussPart = "Truss",
	SpecialMesh = "Mesh",
	Texture = "Texture",
	Decal = "Decal",
	PointLight = "PointLight",
	SpotLight = "SpotLight",
	SurfaceLight = "SurfaceLight",
	Smoke = "Smoke",
	Fire = "Fire",
	Sparkles = "Sparkles",
	Model = "Model",
	Folder = "Folder"
}

local HttpService = game:GetService("HttpService")
local ExportBaseUrl = "http://www.f3xteam.com/bt/export/%s"

local function ImportCreationData(CreationId)
	local CreationData
	local Success, ErrorMessage = pcall(function()
		local Response = game:HttpGet(ExportBaseUrl:format(CreationId))
		CreationData = HttpService:JSONDecode(Response)
	end)

	if Success and CreationData then
		return CreationData
	else
		warn("Failed To Import Creation Data: " .. (ErrorMessage or "Unknown Error"))
		return nil
	end
end

function ImportModule.Import(ImportCode, DelayPerPart, DebugModeEnabled)
	ImportCode = ImportCode or "----"
	DelayPerPart = DelayPerPart or 0.03
	DelayPerPart = math.max(DelayPerPart, 0.01)

	local Data = ImportCreationData(ImportCode)
	if not Data then return nil end

	if Data.Version ~= 3 then
		warn("Unsupported Version: " .. tostring(Data.Version))
		return nil
	end

	local Instances = {}
	local Effects = {}

	local function CreatePartWithProperties(Datum, Index)
		local PartType = PartTypeMap[Datum[1]] or "Normal"

		if Datum[1] == Types.Part and Datum[33] then
			if Datum[33] == 0 then
				PartType = "Ball"
			elseif Datum[33] == 1 then
				PartType = "Normal"
			elseif Datum[33] == 2 then
				PartType = "Cylinder"
			elseif Datum[33] == 3 then
				PartType = "Wedge"
			end
		end

		local Cframe = Utils.ToCFrame(Utils.Slice(Datum, 7, 18))
		local Item = nil

		if game.PlaceId == 391104146 and Datum[29] == 5 and Datum[28] == 1 and Datum[31] == 4 then -- FrontSurface = Universal, BottomSurface = Glue, LeftSurface = Inlet
			local Conveyor = Utils.FindLPIConveyor(50)
			if Conveyor then
				Item = BtoolsFunctions.Clone(Conveyor, game:GetService("Workspace"))
			end
		else
			Item = BtoolsFunctions.CreatePart(Cframe, game:GetService("Workspace"), PartType)
		end

		if Item then
			local Size = Utils.ToVector3(unpack(Utils.Slice(Datum, 4, 6)))
			BtoolsFunctions.Resize(Item, Size, Cframe)
			BtoolsFunctions.Color(Item, Utils.ToColor3(Datum[19], Datum[20], Datum[21]))
			BtoolsFunctions.SetMaterial(Item, Datum[22])
			BtoolsFunctions.SetAnchor(Item, Datum[23] == 1)
			BtoolsFunctions.SetCollision(Item, Datum[24] == 1)
			BtoolsFunctions.SetReflectance(Item, Datum[25])
			BtoolsFunctions.SetTransparency(Item, Datum[26])

			local SurfacesData = {
				Top = Datum[27],
				Bottom = Datum[28],
				Front = Datum[29],
				Back = Datum[30],
				Left = Datum[31],
				Right = Datum[32]
			}

			BtoolsFunctions.Surface(Item, SurfacesData)

			local name = (Datum[3] == "") and DefaultNames[Item.ClassName] or Datum[3]
			BtoolsFunctions.SetName(Item, name)

			Instances[Index] = Item

			return Item
		end
		return nil
	end

	for Index, Datum in ipairs(Data.Items) do
		if Datum[1] <= Types.TrussPart then
			coroutine.wrap(function()
				CreatePartWithProperties(Datum, Index)
			end)()
			task.wait(DelayPerPart)
		elseif Datum[1] >= Types.SpecialMesh and Datum[1] <= Types.Sparkles then
			table.insert(Effects, {Index = Index, Data = Datum})
		end
	end

	task.wait(1.5 + DelayPerPart)

	for _, Effect in ipairs(Effects) do
		if Effect.Data[1] == Types.Model then continue end
		if Effect.Data[1] == Types.Folder then continue end

		local TargetPart = Instances[Effect.Data[2]]
		if TargetPart then
			if Effect.Data[1] == Types.SpecialMesh then
				BtoolsFunctions.AddMesh(TargetPart)
				BtoolsFunctions.SetMesh(
					TargetPart,
					Effect.Data[5],
					Effect.Data[6],
					Utils.ToVector3(unpack(Utils.Slice(Effect.Data, 10, 12)))
				)
			end

			if Effect.Data[1] == Types.Decal or Effect.Data[1] == Types.Texture then
				local EffectType = Effect.Data[1] == Types.Texture and "Texture" or "Decal"
				BtoolsFunctions.CreateTexture(TargetPart, EffectType, Effect.Data[6])

				if Utils.GetNumberFromString(Effect.Data[4]) and Utils.GetNormalIdFromIndex(Effect.Data[6]) then
					BtoolsFunctions.SetTexture(
						TargetPart,
						Utils.GetNumberFromString(Effect.Data[4]),
						EffectType,
						Utils.GetNormalIdFromIndex(Effect.Data[6])
					)
				end

				if Effect.Data[1] == Types.Texture then
					BtoolsFunctions.SetTextureStudsPerTile(TargetPart, Effect.Data[6], "StudsPerTileU", Effect.Data[7])
					BtoolsFunctions.SetTextureStudsPerTile(TargetPart, Effect.Data[6], "StudsPerTileV", Effect.Data[8])
				end
			end

			if Effect.Data[1] == Types.PointLight
				or Effect.Data[1] == Types.SpotLight
				or Effect.Data[1] == Types.SurfaceLight
			then
				BtoolsFunctions.CreateEffect(TargetPart, Utils.FindTableOccurrence(Types, Effect.Data[1]))
				BtoolsFunctions.ChangeEffect(TargetPart, Utils.FindTableOccurrence(Types, Effect.Data[1]), {
					["Brightness"] = Effect.Data[4],
					["Color"] = Color3.new(unpack(Utils.Slice(Effect.Data, 5, 7))),
					["Enabled"] = Effect.Data[8] == 1,
					["Shadows"] = Effect.Data[9] == 1
				})
			end

			if Effect.Data[1] == Types.PointLight then
				BtoolsFunctions.ChangeEffect(TargetPart, "PointLight", {
					["Range"] = Effect.Data[10]
				})
			end

			if Effect.Data[1] == Types.SpotLight or Effect.Data[1] == Types.SurfaceLight then
				BtoolsFunctions.ChangeEffect(TargetPart, Utils.FindTableOccurrence(Types, Effect.Data[1]), {
					["Range"] = Effect.Data[10],
					["Angle"] = Effect.Data[11],
					["Face"] = Effect.Data[12]
				})
			end

			if Effect.Data[1] == Types.Smoke then
				BtoolsFunctions.CreateEffect(TargetPart, "Smoke")
				BtoolsFunctions.ChangeEffect(TargetPart, "Smoke", {
					["Enabled"] = Effect.Data[4] == 1,
					["Color"] = Color3.new(unpack(Utils.Slice(Effect.Data, 5, 7))),
					["Size"] = Effect.Data[8],
					["RiseVelocity"] = Effect.Data[9],
					["Opacity"] = Effect.Data[10]
				})
			end

			if Effect.Data[1] == Types.Fire then
				BtoolsFunctions.CreateEffect(TargetPart, "Fire")
				BtoolsFunctions.ChangeEffect(TargetPart, "Fire", {
					["Enabled"] = Effect.Data[4] == 1,
					["Color"] = Color3.new(unpack(Utils.Slice(Effect.Data, 5, 7))),
					["SecondaryColor"] = Color3.new(unpack(Utils.Slice(Effect.Data, 8, 10))),
					["Heat"] = Effect.Data[11],
					["Size"] = Effect.Data[12]
				})
			end

			if Effect.Data[1] == Types.Sparkles then
				BtoolsFunctions.CreateEffect(TargetPart, "Sparkles")
				BtoolsFunctions.ChangeEffect(TargetPart, "Sparkles", {
					["Enabled"] = Effect.Data[4] == 1,
					["SparkleColor"] = Color3.new(unpack(Utils.Slice(Effect.Data, 5, 7)))
				})
			end
		else
			if DebugModeEnabled then
				warn("Could not find target part for effect at index:", Effect.Index, "effect data:", HttpService:JSONEncode(Effect.Data))

			end
		end
	end
end

return ImportModule
