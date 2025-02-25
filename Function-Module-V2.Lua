local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local function GetServerEndpoint()
	local BToolsKeywords = { "F3X", "BTools", "Building", "Building Tools" }
	local EndpointKeywords = { "serverend", "endpoint", "ServerEndPoint\226\128\140","\226\128\140" }
	local SyncAPIKeywords = { "sync", "api", "syncapi" }

	local function MatchesKeywords(ToolName, Keywords)
		local LowercaseName = ToolName:lower()
		for _, Keyword in ipairs(Keywords) do
			if LowercaseName:find(Keyword:lower()) then
				return true
			end
		end
		return false
	end

	local function FindSyncAPI(Parent)
		for _, Child in ipairs(Parent:GetChildren()) do
			if Child:IsA("BindableFunction") and MatchesKeywords(Child.Name, SyncAPIKeywords) then
				return Child
			end
		end

		return nil
	end

	local function FindServerEndpoint(Parent)
		for _, Child in ipairs(Parent:GetChildren()) do
			if Child:IsA("RemoteFunction") and MatchesKeywords(Child.Name, EndpointKeywords) then
				return Child
			end
		end

		return nil
	end

	for _, Tool in ipairs(LocalPlayer.Backpack:GetChildren()) do
		if Tool:IsA("Tool") and MatchesKeywords(Tool.Name, BToolsKeywords) then
			local SyncAPI = FindSyncAPI(Tool)
			if SyncAPI then
				local ServerEndpoint = FindServerEndpoint(SyncAPI)
				if ServerEndpoint then
					return ServerEndpoint
				end
			end
		end
	end

	if LocalPlayer.Character then
		for _, Tool in ipairs(LocalPlayer.Character:GetChildren()) do
			if Tool:IsA("Tool") and MatchesKeywords(Tool.Name, BToolsKeywords) then
				local SyncAPI = FindSyncAPI(Tool)
				if SyncAPI then
					local ServerEndpoint = FindServerEndpoint(SyncAPI)
					if ServerEndpoint then
						return ServerEndpoint
					end
				end
			end
		end
	end

	return nil
end

local ServerEndpoint = GetServerEndpoint()

local function VaildParts(Parts)
	if not Parts then
		return false
	end

	if typeof(Parts) ~= "table" and typeof(Parts) ~= "Instance" then
		return false
	end

	if typeof(Parts) == "table" and #Parts <= 0 then
		return false
	end

	return true
end

local function OriginzeParts(Parts)
	local NewPartsTable = {}

	if typeof(Parts) == "table" then
		for _, Part in pairs(Parts) do
			if typeof(Part) ~= "Instance" then continue end
			if not Part:IsA("BasePart") then continue end
			if Part:IsA("Terrain") then continue end
			if not Part:IsDescendantOf(game.Workspace) then continue end
			table.insert(NewPartsTable, Part)
		end
	end

	if typeof(Parts) == "Instance" then
		NewPartsTable = {Parts}
	end

	return NewPartsTable
end

local function VaildGroups(Groups)
	if not Groups then
		return false
	end

	if typeof(Groups) ~= "table" and typeof(Groups) ~= "Instance" then
		return false
	end

	if typeof(Groups) == "table" and #Groups <= 0 then
		return false
	end

	return true
end

local function OriginzeGroups(Groups)
	local NewPartsTable = {}

	if typeof(Groups) == "table" then
		for _, Part in pairs(Groups) do
			if typeof(Part) ~= "Instance" then continue end
			if not Part:IsA("Model") and not Part:IsA("Folder") then continue end
			if not Part:IsDescendantOf(game.Workspace) then continue end
			table.insert(NewPartsTable, Part)
		end
	end

	if typeof(Groups) == "Instance" then
		NewPartsTable = {Groups}
	end

	return NewPartsTable
end

local BtoolsFunctionsModule = {}

BtoolsFunctionsModule = {
	["ExecuteArgs"] = function(Args)
		if not Args then return end
		if typeof(Args) ~= "table" then return end

		if game.PlaceId == 17352689487 then
			local NewArgs = {}

			for ArgIndex, ArgValue in ipairs(Args) do
				if ArgIndex ~= 1 then
					NewArgs[ArgIndex] = ArgValue
				else
					NewArgs[ArgIndex] = ArgValue .. "1"
				end
			end

			Args = NewArgs
		end

		if not ServerEndpoint then
			ServerEndpoint = GetServerEndpoint()
		end

		if ServerEndpoint then
			local Result = nil
			local Success, ErrorMessage = pcall(function()
				Result = ServerEndpoint:InvokeServer(unpack(Args))
			end)

			if not Success then
				warn("Failed to invoke server: " .. ErrorMessage)
			end

			if Result then
				if typeof(Result) == "Instance" then
					return Result
				end
			end
		end
	end,
	["Construct"] = {
		["Clone"] = function(Parts, CustomParent)
			if not VaildParts(Parts) then return end
			Parts = OriginzeParts(Parts)

			local CloneParent = Parts[1].Parent

			if CustomParent and typeof(CustomParent) == "Instance" then
				CloneParent = CustomParent
			end

			local CloneArgs = {
				[1] = "Clone",
				[2] = Parts,
				[3] = CloneParent
			}

			BtoolsFunctionsModule["ExecuteArgs"](CloneArgs)
		end,
		["CreatePart"] = function(PartType, CustomCFrame, CustomParent)
			if not PartType then return end
			if typeof(PartType) ~= "string" then return end
			if not table.find({"Normal", "Truss", "Corner", "Wedge", "Cylinder", "Ball", "Seat", "Vehicle Seat", "Spawn"}, PartType) then return end

			local PartCFrame = CFrame.new(0, 15, 0)

			if CustomCFrame and typeof(CustomCFrame) == "CFrame" then
				PartCFrame = CustomCFrame
			end

			if CustomCFrame and typeof(CustomCFrame) == "Vector3" then
				PartCFrame = CFrame.new(CustomCFrame)
			end

			local PartParent = game:GetService("Workspace")

			if CustomParent and typeof(CustomParent) == "Instance" then
				PartParent = CustomParent
			end

			local CreationArgs = {
				[1] = "CreatePart",
				[2] = PartType,
				[3] = PartCFrame,
				[4] = PartParent
			}

			local CreatedPart = BtoolsFunctionsModule["ExecuteArgs"](CreationArgs)

			if CreatedPart then
				return CreatedPart
			end

			local StartTime = os.clock()

			repeat
				for _, Child in ipairs(PartParent:GetChildren()) do
					if Child:IsA("BasePart") 
						and (Child.Position - PartCFrame.Position).Magnitude < 0.01 then
						CreatedPart = Child
						break
					end
				end
				if CreatedPart then
					break
				end
				task.wait(0.01)
			until os.clock() - StartTime >= 0.2

			return CreatedPart
		end,
		["CreateWelds"] = function(Parts, ConstraintsPart)
			if not ConstraintsPart then return end
			if typeof(ConstraintsPart) ~= "Instance" then return end

			if not VaildParts(Parts) then return end
			Parts = OriginzeParts(Parts)

			local WeldCreationArgs = {
				[1] = "CreateWelds",
				[2] = Parts,
				[3] = ConstraintsPart
			}

			BtoolsFunctionsModule["ExecuteArgs"](WeldCreationArgs)
		end,
	},
	["Hierarchy"] = {
		["CreateGroup"] = function(GroupType, Parts, CustomParent)
			if not GroupType then return end
			if typeof(GroupType) ~= "string" then return end
			if not table.find({"Model", "Folder"}, GroupType) then return end

			if not VaildParts(Parts) then return end
			Parts = OriginzeParts(Parts)

			local GroupParent = Parts[1].Parent

			if CustomParent and typeof(CustomParent) == "Instance" then
				GroupParent = CustomParent
			end

			local GroupCreationArgs = {
				[1] = "CreateGroup",
				[2] = GroupType,
				[3] = GroupParent,
				[4] = Parts
			}

			BtoolsFunctionsModule["ExecuteArgs"](GroupCreationArgs)
		end,
		["Ungroup"] = function(Groups)
			if not VaildGroups(Groups) then return end
			Groups = OriginzeGroups(Groups)

			local UngroupArgs = {
				[1] = "Ungroup",
				[2] = Groups
			}

			BtoolsFunctionsModule["ExecuteArgs"](UngroupArgs)
		end,
		["SetParent"] = function(Parts, NewParent)
			if not VaildParts(Parts) then return end
			Parts = OriginzeParts(Parts)

			if not NewParent then return end
			if typeof(NewParent) ~= "Instance" then return end

			local SetParentArgs = {
				[1] = "SetParent",
				[2] = Parts,
				[3] = NewParent
			}

			BtoolsFunctionsModule["ExecuteArgs"](SetParentArgs)
		end,
		["SetName"] = function(Parts, NewName)
			if not VaildParts(Parts) then return end
			Parts = OriginzeParts(Parts)

			if not NewName then return end
			if typeof(NewName) ~= "string" then return end

			local SetNameArgs = {
				[1] = "SetName",
				[2] = Parts,
				[3] = NewName
			}

			BtoolsFunctionsModule["ExecuteArgs"](SetNameArgs)
		end,
	},
	["Transform"] = {
		["Move"] = function(Parts, PartCFrame)
			if not PartCFrame then return end
			if typeof(PartCFrame) ~= "CFrame" then return end

			if not VaildParts(Parts) then return end
			Parts = OriginzeParts(Parts)

			local Changes = {}

			for _, Part in ipairs(Parts) do
				table.insert(Changes, {
					Part = Part,
					CFrame = PartCFrame
				})
			end

			local MoveArgs = {
				[1] = "SyncMove",
				[2] = Changes
			}

			BtoolsFunctionsModule["ExecuteArgs"](MoveArgs)
		end,
		["Resize"] = function(Parts, PartSize, PartCFrame)
			if not PartCFrame then return end
			if typeof(PartCFrame) ~= "CFrame" then return end

			if not PartSize then return end
			if typeof(PartSize) ~= "Vector3" then return end

			if not VaildParts(Parts) then return end
			Parts = OriginzeParts(Parts)

			local Changes = {}

			for _, Part in ipairs(Parts) do
				table.insert(Changes, {
					Part = Part,
					Size = PartSize,
					CFrame = PartCFrame
				})
			end

			local MoveArgs = {
				[1] = "SyncResize",
				[2] = Changes
			}

			BtoolsFunctionsModule["ExecuteArgs"](MoveArgs)
		end,
		["Rotate"] = function(Parts, PartCFrame)
			if not PartCFrame then return end
			if typeof(PartCFrame) ~= "CFrame" then return end

			if not VaildParts(Parts) then return end
			Parts = OriginzeParts(Parts)

			local Changes = {}

			for _, Part in ipairs(Parts) do
				table.insert(Changes, {
					Part = Part,
					CFrame = PartCFrame
				})
			end

			local RotateArgs = {
				[1] = "SyncRotate",
				[2] = Changes
			}

			BtoolsFunctionsModule["ExecuteArgs"](RotateArgs)
		end
	},
	["Behavior"] = {
		["SetAnchor"] = function(Parts, Anchor)
			if not Anchor then return end
			if typeof(Anchor) ~= "boolean" then return end

			if not VaildParts(Parts) then return end
			Parts = OriginzeParts(Parts)

			local Changes = {}

			for _, Part in ipairs(Parts) do
				table.insert(Changes, {
					Part = Part,
					Anchored = Anchor
				})
			end

			local AnchorArgs = {
				[1] = game.PlaceId == 17352689487 and "SyncBehavior" or "SyncAnchor",
				[2] = Changes
			}

			BtoolsFunctionsModule["ExecuteArgs"](AnchorArgs)
		end,
		["SetCollision"] = function(Parts, Collision)
			if not Collision then return end
			if typeof(Collision) ~= "boolean" then return end

			if not VaildParts(Parts) then return end
			Parts = OriginzeParts(Parts)

			local Changes = {}

			for _, Part in ipairs(Parts) do
				table.insert(Changes, {
					Part = Part,
					CanCollide = Collision
				})
			end

			local CollisionArgs = {
				[1] = game.PlaceId == 17352689487 and "SyncBehavior" or "SyncCollision",
				[2] = Changes
			}

			BtoolsFunctionsModule["ExecuteArgs"](CollisionArgs)
		end
	},
	["Effects"] = {
		["Create"] = {
			["Light"] = function(Parts, LightType)
				if not LightType then return end
				if typeof(LightType) ~= "string" then return end
				if not table.find({"SpotLight", "SurfaceLight", "PointLight"}, LightType) then return end

				if not VaildParts(Parts) then return end
				Parts = OriginzeParts(Parts)

				local Changes = {}

				for _, Part in ipairs(Parts) do
					table.insert(Changes, {
						Part = Part,
						LightType = LightType
					})
				end

				local LightCreationArgs = {
					[1] = "CreateLights",
					[2] = Changes
				}

				BtoolsFunctionsModule["ExecuteArgs"](LightCreationArgs)
			end,
			["Decorate"] = function(Parts, DecorationType)
				if not DecorationType then return end
				if typeof(DecorationType) ~= "string" then return end
				if not table.find({"Sparkles", "Fire", "Smoke"}, DecorationType) then return end

				if not VaildParts(Parts) then return end
				Parts = OriginzeParts(Parts)

				local Changes = {}

				for _, Part in ipairs(Parts) do
					table.insert(Changes, {
						Part = Part,
						DecorationType = DecorationType
					})
				end

				local DecorateCreationArgs = {
					[1] = "CreateDecorations",
					[2] = Changes
				}

				BtoolsFunctionsModule["ExecuteArgs"](DecorateCreationArgs)
			end,
			["Mesh"] = function(Parts)
				if not VaildParts(Parts) then return end
				Parts = OriginzeParts(Parts)

				local Changes = {}

				for _, Part in ipairs(Parts) do
					table.insert(Changes, {
						Part = Part
					})
				end

				local MeshCreationArgs = {
					[1] = "CreateMeshes",
					[2] = Changes
				}

				BtoolsFunctionsModule["ExecuteArgs"](MeshCreationArgs)
			end,
			["Texture"] = function(Parts, TextureType, TextureFace)
				if not TextureType then return end
				if typeof(TextureType) ~= "string" then return end
				if not table.find({"Decal", "Texture"}, TextureType) then return end

				if not TextureFace then return end
				if typeof(TextureFace) ~= "EnumItem" then return end
				if not table.find(Enum.NormalId:GetEnumItems(), TextureFace) then return end

				if not VaildParts(Parts) then return end
				Parts = OriginzeParts(Parts)

				local Changes = {}

				for _, Part in ipairs(Parts) do
					table.insert(Changes, {
						Part = Part,
						TextureType = TextureType,
						Face = TextureFace
					})
				end

				local TextureCreationArgs = {
					[1] = "CreateTextures",
					[2] = Changes
				}

				BtoolsFunctionsModule["ExecuteArgs"](TextureCreationArgs)
			end
		},
		["Modify"] = {
			["Light"] = function(Parts, LightType, Properties)
				if not LightType then return end
				if typeof(LightType) ~= "string" then return end
				if not table.find({"SpotLight", "SurfaceLight", "PointLight"}, LightType) then return end

				if not Properties then return end
				if typeof(Properties) ~= "table" then return end

				for Property, _ in pairs(Properties) do
					if typeof(Property) ~= "string" then return end
					if not table.find({"Color", "Range", "Face", "Brightness", "Angle"}, Property) then return end
				end

				if not VaildParts(Parts) then return end
				Parts = OriginzeParts(Parts)

				local Changes = {}

				for _, Part in ipairs(Parts) do
					local PartChange = {
						Part = Part,
						LightType = LightType
					}

					for PropertyName, PropertyValue in pairs(Properties) do
						if PartChange[PropertyName] then continue end
						PartChange[PropertyName] = PropertyValue
					end

					table.insert(Changes, PartChange)
				end

				local LightingModifyArgs = {
					[1] = "SyncLighting",
					[2] = Changes
				}

				BtoolsFunctionsModule["ExecuteArgs"](LightingModifyArgs)
			end,
			["Decorate"] = function(Parts, DecorationType, Properties)
				if not DecorationType then return end
				if typeof(DecorationType) ~= "string" then return end
				if not table.find({"Sparkles", "Fire", "Smoke"}, DecorationType) then return end

				if not Properties then return end
				if typeof(Properties) ~= "table" then return end

				for Property, _ in pairs(Properties) do
					if typeof(Property) ~= "string" then return end
					if not table.find({"Color", "Opacity", "RiseVelocity", "Size", "Heat", "SecondaryColor", "SparkleColor"}, Property) then return end
				end

				if not VaildParts(Parts) then return end
				Parts = OriginzeParts(Parts)

				local Changes = {}

				for _, Part in ipairs(Parts) do
					local PartChange = {
						Part = Part,
						DecorationType = DecorationType
					}

					for PropertyName, PropertyValue in pairs(Properties) do
						if PartChange[PropertyName] then continue end
						PartChange[PropertyName] = PropertyValue
					end

					table.insert(Changes, PartChange)
				end

				local DecorationModifyArgs = {
					[1] = "SyncDecorate",
					[2] = Changes
				}

				BtoolsFunctionsModule["ExecuteArgs"](DecorationModifyArgs)
			end,
			["Mesh"] = function(Parts, Properties)
				if not Properties then return end
				if typeof(Properties) ~= "table" then return end

				for Property, _ in pairs(Properties) do
					if typeof(Property) ~= "string" then return end
					if not table.find({"VertexColor", "MeshType", "Scale", "Offset", "MeshId", "TextureId"}, Property) then return end
				end

				if not VaildParts(Parts) then return end
				Parts = OriginzeParts(Parts)

				local Changes = {}

				for _, Part in ipairs(Parts) do
					local PartChange = {
						Part = Part
					}

					for PropertyName, PropertyValue in pairs(Properties) do
						if PartChange[PropertyName] then continue end
						PartChange[PropertyName] = PropertyValue
					end

					table.insert(Changes, PartChange)
				end

				local MeshModifyArgs = {
					[1] = "SyncMesh",
					[2] = Changes
				}

				BtoolsFunctionsModule["ExecuteArgs"](MeshModifyArgs)
			end,
			["Texture"] = function(Parts, TextureType, TextureFace, Properties)
				if not TextureType then return end
				if typeof(TextureType) ~= "string" then return end
				if not table.find({"Decal", "Texture"}, TextureType) then return end

				if not TextureFace then return end
				if typeof(TextureFace) ~= "EnumItem" then return end
				if not table.find(Enum.NormalId:GetEnumItems(), TextureFace) then return end

				if not Properties then return end
				if typeof(Properties) ~= "table" then return end

				for Property, _ in pairs(Properties) do
					if typeof(Property) ~= "string" then return end
					if not table.find({"StudsPerTileV", "StudsPerTileU", "Transparency", "Texture"}, Property) then return end
				end

				if not VaildParts(Parts) then return end
				Parts = OriginzeParts(Parts)

				local Changes = {}

				for _, Part in ipairs(Parts) do
					local PartChange = {
						Part = Part,
						TextureType = TextureType,
						Face = TextureFace
					}

					for PropertyName, PropertyValue in pairs(Properties) do
						if PartChange[PropertyName] then continue end
						PartChange[PropertyName] = PropertyValue
					end

					table.insert(Changes, PartChange)
				end

				local TextureModifyArgs = {
					[1] = "SyncTexture",
					[2] = Changes
				}

				BtoolsFunctionsModule["ExecuteArgs"](TextureModifyArgs)
			end,
		},
	},
	["Visual"] = {
		["SetColor"] = function(Parts, Color)
			if not Color then return end
			if typeof(Color) ~= "Color3" then return end

			if not VaildParts(Parts) then return end
			Parts = OriginzeParts(Parts)

			local Changes = {}

			for _, Part in ipairs(Parts) do
				if Part:IsA("UnionOperation") then
					table.insert(Changes, {
						Part = Part,
						Color = Color,
						UnionColoring = true
					})
				else
					table.insert(Changes, {
						Part = Part,
						Color = Color
					})
				end
			end

			local ColorArgs = {
				[1] = "SyncColor",
				[2] = Changes
			}

			BtoolsFunctionsModule["ExecuteArgs"](ColorArgs)
		end,
		["SetSurface"] = function(Parts, Surfaces)		
			if not Surfaces then return end
			if typeof(Surfaces) ~= "table" then return end

			for SurfaceName, SurfaceType in pairs(Surfaces) do
				if typeof(SurfaceType) ~= "EnumItem" then return end
				if not table.find(Enum.SurfaceType:GetEnumItems(), SurfaceType) then return end
				if typeof(SurfaceName) ~= "string" then return end
				if not table.find({"Top", "Bottom", "Front", "Back", "Left", "Right"}, SurfaceName) then return end 
			end

			if not VaildParts(Parts) then return end
			Parts = OriginzeParts(Parts)

			local Changes = {}

			for _, Part in ipairs(Parts) do
				table.insert(Changes, {
					Part = Part,
					Surfaces = Surfaces
				})
			end

			local SurfaceArgs = {
				[1] = "SyncSurface",
				[2] = Changes
			}

			BtoolsFunctionsModule["ExecuteArgs"](SurfaceArgs)
		end,
		["SetMaterial"] = function(Parts, Material)
			if not Material then return end
			if typeof(Material) ~= "EnumItem" then return end
			if not table.find(Enum.Material:GetEnumItems(), Material) then return end

			if not VaildParts(Parts) then return end
			Parts = OriginzeParts(Parts)

			local Changes = {}

			for _, Part in ipairs(Parts) do
				table.insert(Changes, {
					Part = Part,
					Material = Material
				})
			end

			local MaterialArgs = {
				[1] = "SyncMaterial",
				[2] = Changes
			}

			BtoolsFunctionsModule["ExecuteArgs"](MaterialArgs)
		end
	},
	["Destroy"] = {
		["Remove"] = function(Parts)
			if not VaildParts(Parts) then return end
			Parts = OriginzeParts(Parts)

			local RemovePartsArgs = {
				[1] = "Remove",
				[2] = Parts
			}

			BtoolsFunctionsModule["ExecuteArgs"](RemovePartsArgs)
		end,
		["RemoveWelds"] = function(Parts)
			if not VaildParts(Parts) then return end
			Parts = OriginzeParts(Parts)

			local Welds = {}

			for _, Part in ipairs(Parts) do
				for _, Child in ipairs(Part:GetChildren()) do
					if not Child:IsA("Weld") then continue end
					table.insert(Welds, Child)
				end
			end

			local RemoveWeldArgs = {
				[1] = "RemoveWelds",
				[2] = Welds
			}

			BtoolsFunctionsModule["ExecuteArgs"](RemoveWeldArgs)
		end,
	}
}

return BtoolsFunctionsModule
