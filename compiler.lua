


-- local exmaple = 
-- [[
-- <?xml version="1.0" encoding="UTF-8"?>
-- <CMapData>
--  <name>hei_cs2_03_strm_1</name>
--  <parent />
--  <flags value="0" />
--  <contentFlags value="65" />
--  <streamingExtentsMin x="1903.26489" y="4844.69043" z="-131.74942" />   ///////////////// EXTENTS +/- LODDIST
--  <streamingExtentsMax x="2456.111" y="5334.76074" z="228.25058" />      ///////////////// EXTENTS +/- LODDIST
--  <entitiesExtentsMin x="1982.85217" y="4983.753" z="18.1131058" />      ///////////////// MODEL DIMENSIONS
--  <entitiesExtentsMax x="2372.549" y="5238.763" z="84.98944" />          ///////////////// MODEL DIMENSIONS
--  <entities>
--   <Item type="CEntityDef">
--    <archetypeName>prop_fncwood_17c</archetypeName>
--    <flags value="1572873" />
--    <guid value="3368619257" /> ///////////////// DYNAMIC
--    <position x="2107.95557" y="5212.16" z="55.7679825" /> ///////////////// DYNAMIC
--    <rotation x="-0.0335520059" y="-0.00207600021" z="0.989615142" w="0.139757022" /> ///////////////// DYNAMIC
--    <scaleXY value="1" />
--    <scaleZ value="1" />
--    <parentIndex value="-1" />
--    <lodDist value="80" /> ///////////////// DYNAMIC
--    <childLodDist value="0" />
--    <lodLevel>LODTYPES_DEPTH_ORPHANHD</lodLevel>
--    <numChildren value="0" />
--    <priorityLevel>PRI_REQUIRED</priorityLevel>
--    <extensions />
--    <ambientOcclusionMultiplier value="255" />
--    <artificialAmbientOcclusion value="255" />
--    <tintValue value="0" />
--   </Item>
--  </entities>
--  <containerLods itemType="rage__fwContainerLodDef" />
--  <boxOccluders itemType="BoxOccluder" />
--  <occludeModels itemType="OccludeModel" />
--  <physicsDictionaries />
--  <instancedData>
--   <ImapLink />
--   <PropInstanceList itemType="rage__fwPropInstanceListDef" />
--   <GrassInstanceList itemType="rage__fwGrassInstanceListDef" />
--  </instancedData>
--  <timeCycleModifiers itemType="CTimeCycleModifier" />
--  <carGenerators itemType="CCarGen" />
--  <LODLightsSOA>
--   <direction itemType="FloatXYZ" />
--   <falloff />
--   <falloffExponent />
--   <timeAndStateFlags />
--   <hash />
--   <coneInnerAngle />
--   <coneOuterAngleOrCapExt />
--   <coronaIntensity />
--  </LODLightsSOA>
--  <DistantLODLightsSOA>
--   <position itemType="FloatXYZ" />
--   <RGBI />
--   <numStreetLights value="0" />
--   <category value="0" />
--  </DistantLODLightsSOA>
--  <block>
--   <version value="0" />
--   <flags value="0" />
--   <name></name>
--   <exportedBy></exportedBy>
--   <owner></owner>
--   <time></time>
--  </block>
-- </CMapData>
-- ]]



local function eulerToQuat(x, y, z) -- THANK YOU CHATGPT

    if type(x) == "vector3" then
        y = x.y
        z = x.z
        x = x.x
    else
        if type(x) ~="number" then
            -- print("tried to convert invalid vector value to quaternion")
            return
        end
    end

    -- convert degrees → radians
    local radX = math.rad(x)
    local radY = math.rad(y)
    local radZ = math.rad(z)

    -- half angles
    local cx = math.cos(radX * 0.5)
    local sx = math.sin(radX * 0.5)
    local cy = math.cos(radY * 0.5)
    local sy = math.sin(radY * 0.5)
    local cz = math.cos(radZ * 0.5)
    local sz = math.sin(radZ * 0.5)

    -- XYZ rotation order
    local qw = cx * cy * cz + sx * sy * sz
    local qx = sx * cy * cz - cx * sy * sz
    local qy = cx * sy * cz + sx * cy * sz
    local qz = cx * cy * sz - sx * sy * cz

    return qx, qy, qz, qw
end

local function formatLine(linePattern, ...)
    -- print(...)
    local str = string.format(linePattern, table.unpack({...}))
    -- print(str)
    return str
end

local entityStructure = {
    '  <Item type="CEntityDef">\n',
    '   <archetypeName>%s</archetypeName>\n',   -- %s
    '   <flags value="%d" />\n',                 -- %d
    '   <guid value="0" />\n',
    '   <position x="%f" y="%f" z="%f" />\n',     -- %f, %f, %f
    '   <rotation x="%f" y="%f" z="%f" w="%f" />\n', -- %f, %f, %f, %f
    '   <scaleXY value="1" />\n',
    '   <scaleZ value="1" />\n',
    '   <parentIndex value="-1" />\n',
    '   <lodDist value="%d" />\n',              -- %d
    '   <childLodDist value="0" />\n',
    '   <lodLevel>LODTYPES_DEPTH_ORPHANHD</lodLevel>\n',
    '   <numChildren value="0" />\n',
    '   <priorityLevel>PRI_REQUIRED</priorityLevel>\n',
    '   <extensions />\n',
    '   <ambientOcclusionMultiplier value="255" />\n',
    '   <artificialAmbientOcclusion value="255" />\n',
    '   <tintValue value="0" />\n',
    '  </Item>\n',
}



local function formatEntity(data)
    
    -- !//1 w has been switched with z for exporting reasons, if rotation issues occur, try changing x or y
    -- !2 x, y, and z have been inverted
    -- ?Inverting seems to work well so far
    local entityDataSort = {
        [2] =  {data.archetypeName},
        [3] =  {data.flags},
        [5] =  {data.pos.x, data.pos.y, data.pos.z},
        [6] =  {-data.rot.x, -data.rot.y, -data.rot.z, data.rot.w}, 
        [10] = {data.lodDist},
    }

    local str = ""

    for index, value in ipairs(entityStructure) do
        if entityDataSort[index] then
            str = str .. formatLine(value, table.unpack(entityDataSort[index]))
        else
            str = str .. value
        end
    end

    return str
end


--[[ Find Grids with points
Calculate average points per grid
e

Find grids that have less than half of the average points, designate as "excess"

If excess grids do not have non-excess neighbours, mark complete grid
	If excess grid does have  ]]


local mapwidth  = 16384
local gridSize  = 512
local gridsPerLayer = mapwidth / gridSize

-- local exampleOfAGrid = {
--     fileData =  {
--         ymapName = "",
--         flags = 0,
--         contentflags = 0,
--         streamingExtentsMin = vector3(),
--         streamingExtentsMax = vector3(),
--         entitiesExtentsMin = vector3(),
--         entitiesExtentsMax = vector3(),
--     },
--     entityData = {
--             {
--             compilerId = 0,
--             archetypeName = "",
--             flags = 0,
--             pos = vector3(),
--             rot = vector4(),
--             lodDist = 0.0,
--         },
--     },
-- }

local function createEmptyGrid(name)
    local gridData = {
        fileData = {
            ymapName = name,
            flags = 0,
            contentflags = 65,
        },
        entityData = {},
    }
    return gridData
end



local function getEntityLodDist(entity)
    return GetEntityLodDist(entity)
end
local function getEntityMaxRadius(hash)
    local highest = 0
    local min, max = GetModelDimensions(hash)
    return math.max(math.abs(min.x), math.abs(min.y), math.abs(min.z), max.x, max.y, max.z)

end

local function addEntityToDataCache(entityName)
    local cacheEntry = {}

    local entity = CreateObject(entityName, 0.0,0.0,0.0, false, false, false)

    cacheEntry.lodDist = getEntityLodDist(entity)
    cacheEntry.maxRadius = getEntityMaxRadius(GetEntityModel(entity))

    return cacheEntry
end

local function findExtent(pos, maxRadius, gridMin, gridMax)
    
    if pos + maxRadius > gridMax then
        gridMax = pos + maxRadius
    end
    if pos - maxRadius < gridMin then
        gridMin = pos - maxRadius
    end
    return gridMin, gridMax
end

local function sortPointsIntoGrids(propLineData, ymapNamePrefix)
    local grids = {}
    local propDataCache = {}
    local counter = 0

    for lineIndex, lineData in pairs(propLineData) do

        local propData = lineData.propData
        if not propDataCache[lineData.prop] then
            propDataCache[lineData.prop] = addEntityToDataCache(lineData.prop)
        end

        local gridData

        for pointIndex, point in pairs(lineData.points) do

            counter = counter + 1

            local propPosition = point.propPosition
            local propQuaternion = point.propQuaternion

            local gridX = math.floor((propPosition.x + 8192) / gridSize)
            local gridY = math.floor((propPosition.y + 8192) / gridSize)

            local gridNumber = gridX + (gridY * gridsPerLayer)
            
            if not grids[gridNumber] then
                local suffix = string.format("%.0f", math.floor(gridNumber))
                grids[gridNumber] = createEmptyGrid(ymapNamePrefix.."_"..suffix)
            end
            gridData = grids[gridNumber]
            gridData.entityData[#gridData.entityData+1] = {
                compilerId = counter,
                archetypeName = lineData.prop,
                flags = 1572873,
                lodDist = propDataCache[lineData.prop].lodDist,
                pos = propPosition,
                quat = propQuaternion, --!TEMP PLACEHOLDER
                maxRadius = propDataCache[lineData.prop].maxRadius,
            }


        end



    end

    for key, value in pairs(grids) do

        local startExtent = value.entityData[1].pos
        
        local gridMinX, gridMinY, gridMinZ = table.unpack(startExtent)
        local gridMaxX, gridMaxY, gridMaxZ = table.unpack(startExtent)
        local lodDist = 0

        for key, entity in ipairs(value.entityData) do

            local pos = entity.pos
            local maxRadius = entity.maxRadius

            if entity.lodDist > lodDist then
                lodDist = entity.lodDist
            end

            gridMinX, gridMaxX = findExtent(pos.x, maxRadius, gridMinX, gridMaxX)
            gridMinY, gridMaxY = findExtent(pos.y, maxRadius, gridMinY, gridMaxY)
            gridMinZ, gridMaxZ = findExtent(pos.z, maxRadius, gridMinZ, gridMaxZ)

        end

        value.fileData.entitiesExtentsMin = vector3(gridMinX, gridMinY, gridMinZ)
        value.fileData.entitiesExtentsMax = vector3(gridMaxX, gridMaxY, gridMaxZ)
        value.fileData.streamingExtentsMin = vector3(gridMinX - lodDist, gridMinY - lodDist, gridMinZ - lodDist)
        value.fileData.streamingExtentsMax = vector3(gridMaxX + lodDist, gridMaxY + lodDist, gridMaxZ + lodDist)

    end

    return grids

end

local function OptimizeGridData(grids)
    return grids
end

local function SortPointDataToEntityFormat(entity)
    entity.archetypeName = entity.archetypeName
    entity.rot = entity.quat
    entity.pos = entity.pos
    entity.flags = entity.flags or 1572873
    entity.lodDist = entity.lodDist

    return formatEntity(entity)


end

-- local headerExample = [[
-- <?xml version="1.0" encoding="UTF-8"?>
-- <CMapData>
--  <name>hei_cs2_03_strm_1</name>
--  <parent />
--  <flags value="0" />
--  <contentFlags value="65" />
--  <streamingExtentsMin x="1903.26489" y="4844.69043" z="-131.74942" />   ///////////////// EXTENTS +/- LODDIST
--  <streamingExtentsMax x="2456.111" y="5334.76074" z="228.25058" />      ///////////////// EXTENTS +/- LODDIST
--  <entitiesExtentsMin x="1982.85217" y="4983.753" z="18.1131058" />      ///////////////// MODEL DIMENSIONS
--  <entitiesExtentsMax x="2372.549" y="5238.763" z="84.98944" />          ///////////////// MODEL DIMENSIONS
-- ]]

local headerStructure = {
    '<?xml version="1.0" encoding="UTF-8"?>\n',
    '<CMapData>\n',
    ' <name>%s</name>\n',             -- %s
    ' <parent />\n',
    ' <flags value="%d" />\n',        -- %d
    ' <contentFlags value="%d" />\n', -- %d
    ' <streamingExtentsMin x="%f" y="%f" z="%f" />\n',   -- %f, %f, %f
    ' <streamingExtentsMax x="%f" y="%f" z="%f" />\n',   -- %f, %f, %f
    ' <entitiesExtentsMin x="%f" y="%f" z="%f" />\n',    -- %f, %f, %f
    ' <entitiesExtentsMax x="%f" y="%f" z="%f" />\n',    -- %f, %f, %f
}

local function formatHeader(data)
    local headerDataSort = {
        [3] =  {data.ymapName},
        [5] =  {data.flags} or 0,
        [6] =  {data.contentflags} or 65,
        [7] =  {data.streamingExtentsMin.x, data.streamingExtentsMin.y, data.streamingExtentsMin.z},
        [8] =  {data.streamingExtentsMax.x, data.streamingExtentsMax.y, data.streamingExtentsMax.z},
        [9] =  {data.entitiesExtentsMin.x, data.entitiesExtentsMin.y, data.entitiesExtentsMin.z},
        [10] = {data.entitiesExtentsMax.x, data.entitiesExtentsMax.y, data.entitiesExtentsMax.z},
    }
    local str = ""

    for index, value in ipairs(headerStructure) do
        if headerDataSort[index] then
            str = str .. formatLine(value, table.unpack(headerDataSort[index]))
        else
            str = str .. value
        end
    end

    return str
end

local function CreateYmapHeader(data)
    local entitiesString = ""

    entitiesString = entitiesString .. formatHeader(data)

    return entitiesString
end


-- local footerExample = [[
-- ' <containerLods itemType="rage__fwContainerLodDef" />\n',
-- ' <boxOccluders itemType="BoxOccluder" />\n',
-- '  <occludeModels itemType="OccludeModel" />\n',
-- '  <physicsDictionaries />\n',
-- '  <instancedData>\n',
-- '   <ImapLink />\n',
-- '   <PropInstanceList itemType="rage__fwPropInstanceListDef" />\n',
-- '   <GrassInstanceList itemType="rage__fwGrassInstanceListDef" />\n',
-- '  </instancedData>\n',
-- '  <timeCycleModifiers itemType="CTimeCycleModifier" />\n',
-- '  <carGenerators itemType="CCarGen" />\n',
-- '  <LODLightsSOA>\n',
-- '   <direction itemType="FloatXYZ" />\n',
-- '   <falloff />\n',
-- '   <falloffExponent />\n',
-- '   <timeAndStateFlags />\n',
-- '   <hash />\n',
-- '   <coneInnerAngle />\n',
-- '   <coneOuterAngleOrCapExt />\n',
-- '   <coronaIntensity />\n',
-- '  </LODLightsSOA>\n',
-- '  <DistantLODLightsSOA>\n',
-- '   <position itemType="FloatXYZ" />\n',
-- '   <RGBI />\n',
-- '   <numStreetLights value="0" />\n',
-- '   <category value="0" />\n',
-- '  </DistantLODLightsSOA>\n',
-- '  <block>\n',
-- '   <version value="0" />\n',
-- '   <flags value="0" />\n',
-- '   <name></name>\n',
-- '   <exportedBy></exportedBy>\n',
-- '   <owner></owner>\n',
-- '   <time></time>\n',
-- '  </block>\n',
-- ' </CMapData>\n',
-- ]]


local footerStructure = {
    ' <containerLods itemType="rage__fwContainerLodDef" />\n',
    ' <boxOccluders itemType="BoxOccluder" />\n',
    '  <occludeModels itemType="OccludeModel" />\n',
    '  <physicsDictionaries />\n',
    '  <instancedData>\n',
    '   <ImapLink />\n',
    '   <PropInstanceList itemType="rage__fwPropInstanceListDef" />\n',
    '   <GrassInstanceList itemType="rage__fwGrassInstanceListDef" />\n',
    '  </instancedData>\n',
    '  <timeCycleModifiers itemType="CTimeCycleModifier" />\n',
    '  <carGenerators itemType="CCarGen" />\n',
    '  <LODLightsSOA>\n',
    '   <direction itemType="FloatXYZ" />\n',
    '   <falloff />\n',
    '   <falloffExponent />\n',
    '   <timeAndStateFlags />\n',
    '   <hash />\n',
    '   <coneInnerAngle />\n',
    '   <coneOuterAngleOrCapExt />\n',
    '   <coronaIntensity />\n',
    '  </LODLightsSOA>\n',
    '  <DistantLODLightsSOA>\n',
    '   <position itemType="FloatXYZ" />\n',
    '   <RGBI />\n',
    '   <numStreetLights value="0" />\n',
    '   <category value="0" />\n',
    '  </DistantLODLightsSOA>\n',
    '  <block>\n',
    '   <version value="0" />\n',
    '   <flags value="0" />\n',
    '   <name></name>\n',
    '   <exportedBy></exportedBy>\n',
    '   <owner></owner>\n',
    '   <time></time>\n',
    '  </block>\n',
    ' </CMapData>\n',
}

local function formatFooter(data)
    local footerDataSort = {
        
    }
    local str = ""

    for index, value in ipairs(footerStructure) do
        if footerDataSort[index] then
            str = str .. formatLine(value, table.unpack(footerDataSort[index]))
        else
            str = str .. value
        end
    end

    return str
end

local function CreateYmapFooter(data)
    local entitiesString = ""

    entitiesString = entitiesString .. formatFooter(data)

    return entitiesString
end

local function ConvertPointsIntoEntityData(entityData)
    local entitiesString = " <entities>\n"

    for pointIndex, point in pairs(entityData) do
        entitiesString = entitiesString .. SortPointDataToEntityFormat(point)
    end

    entitiesString = entitiesString .. " </entities>\n"

    return entitiesString
end

local function ConvertGridDataIntoYmapData(ymapGrids, prefix)
    local compiledYmapData = {}
    for gridIndex, ymapGrid in pairs(ymapGrids) do
        local ymapName = ymapGrid.fileData.ymapName
        local contentsString = ""

        --ADD HEADER
        contentsString = contentsString .. CreateYmapHeader(ymapGrid.fileData)

        --ADD ENTITIES
        contentsString = contentsString .. ConvertPointsIntoEntityData(ymapGrid.entityData)

        --ADD FOOTER
        contentsString = contentsString .. CreateYmapFooter()

        compiledYmapData[#compiledYmapData+1] = {
            fileName = ymapName .. ".ymap.xml",
            contents = contentsString
        }
    end
    return compiledYmapData
end

function CompileEntitiesToYmap(propLineData, ymapNamePrefix)
    local ymapData = {}
    local retreivingData

    -- Determine which data should go into which ymap
    local gridYmaps = sortPointsIntoGrids(propLineData, ymapNamePrefix)
    -- Optimizing Grouping (FUTURE)              
    -- TODO: Optimize
    gridYmaps = OptimizeGridData(gridYmaps)
    -- Convert prop line points to prop data
    -- compile into xml formatted strings
    local ymapXmlData = ConvertGridDataIntoYmapData(gridYmaps)

    return ymapXmlData
end