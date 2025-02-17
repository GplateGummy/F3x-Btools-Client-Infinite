local ImportModule = {}
local BtoolsFunctions = loadstring(game:HttpGet("https://raw.githubusercontent.com/GplateGummy/F3x-Btools-Client-Infinite/refs/heads/main/Function-Module.Lua"))()
local Utils = {}

function Utils.GetNumberFromString(String)
    local Number = String:match("%d+")
    return Number and tonumber(Number) or nil
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

function Utils.ToCFrame(Cframe)
    if typeof(Cframe) == "CFrame" then
        return Cframe
    end
    return CFrame.new(unpack(Cframe))
end

function Utils.ToColor3(R, G, B)
    return Color3.new(R or 1, G or 1, B or 1)
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
    Model = 15
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
    Model = "Model"
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

function ImportModule.Import(ImportCode, DelayPerPart)
    ImportCode = ImportCode or "----"
    DelayPerPart = DelayPerPart or 0.03
    DelayPerPart = math.max(DelayPerPart, 0.01)

    local Data = ImportCreationData(ImportCode)
    if not Data then return nil end

    if Data.Version ~= 3 then
        warn("Unsupported Version: " .. tostring(CreationData.Version))
        return nil
    end

    local Build = {}
    local Instances = {}
    local Effects = {}

    local function CreatePartWithProperties(Datum, Index)
        return coroutine.wrap(function()
            local PartType = PartTypeMap[Datum[1]] or "Normal"
            
            if Datum[1] == Types.Part and Datum[33] then
                if Datum[33] == 1 then
                    PartType = "Normal"
                elseif Datum[33] == 2 then
                    PartType = "Cylinder"
                elseif Datum[33] == 0 then
                    PartType = "Ball"
                elseif Datum[33] == 3 then
                    PartType = "Wedge"
                end
            end

            local Cframe = Utils.ToCFrame(Utils.Slice(Datum, 7, 18))
            local Item = BtoolsFunctions.CreatePart(Cframe, game:GetService("Workspace"), PartType)

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
                table.insert(Build, Item)
                
                return Item
            end
        end)
    end

    for Index, Datum in ipairs(Data.Items) do
        if Datum[1] <= Types.TrussPart then
            CreatePartWithProperties(Datum, Index)()
            task.wait(DelayPerPart)
        elseif Datum[1] >= Types.SpecialMesh and Datum[1] <= Types.Decal then
            table.insert(Effects, Datum)
        end
    end

    for _, Effect in ipairs(Effects) do
        local TargetPart = Instances[Effect[2]]
        if TargetPart then
            if Effect[1] == Types.SpecialMesh then
                BtoolsFunctions.SetMesh(TargetPart, Effect[5], Effect[6], Utils.ToVector3(unpack(Utils.Slice(Effect, 10, 12))))
            elseif Effect[1] == Types.Decal or Effect[1] == Types.Texture then
                BtoolsFunctions.CreateTexture(TargetPart, Effect[1] == Types.Texture and "Texture" or "Decal", Effect[6])
                BtoolsFunctions.SetTexture(TargetPart, Utils.GetNumberFromString(Effect[4]), Effect[1] == Types.Texture and "Texture" or "Decal", Effect[6])

                if Effect[1] == Types.Texture then
                    BtoolsFunctions.SetTextureStudsPerTile(TargetPart, Effect[6], "StudsPerTileU", Effect[7])
                    BtoolsFunctions.SetTextureStudsPerTile(TargetPart, Effect[6], "StudsPerTileV", Effect[8])
                end
            end
        end
    end

    return Build
end

return ImportModule
