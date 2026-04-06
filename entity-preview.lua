




local poolCap = 64

local entityPools = {
    -- ["reflect_post"] = {
    --     {
    --         entityId = 0,
    --     },
    -- },
}

local entitiesInUse = {}

local IdToIndex = {

}

local function spawnEntityObject(objectName)

    if not HasModelLoaded(objectName) then
        -- If the model isnt loaded we request the loading of the model and wait that the model is loaded
        RequestModel(objectName)

        while not HasModelLoaded(objectName) do
            Citizen.Wait(1)
        end
    end

    -- At this moment the model its loaded, so now we can create the object
    local obj = CreateObject(objectName, vector3(0.0, 0.0, 0.0), false, false, false)
    
        SetEntityCoords(obj, 0.0,0.0,0.0, false, false, false, false)
        SetEntityCollision(obj, false, false)
    return obj
end

local function createEntityPool(name)
    local pool = {}
    for i = 1, 50, 1 do
        table.insert(pool, {entityId = spawnEntityObject(name)}) 
    end
    return pool
end

local function createExtraEntity(name)
    local entityTable = {
        entityId = spawnEntityObject(name)
    }
    return entityTable
end

local function takeEntityFromPool(name)
    -- either get from pool
    local entityTable = table.remove(entityPools[name])
        -- or create new, if none left in pool
    if not entityTable then
        entityTable = createExtraEntity(name)
    end

    SetEntityCollision(entityId, true, true)
    -- SetEntityAlpha(entityId, 255, true)

    local entityId = entityTable.entityId
    local inUseIndex = #entitiesInUse + 1
    IdToIndex[""..entityId] = inUseIndex
    entitiesInUse[inUseIndex] = entityTable
    -- print("Entity Taken")
    -- print(""..entityId)
    -- print("InUseIndex:", inUseIndex)
    -- print("Taking:", entityId, "With Index:", inUseIndex, name)

    return entityId, entityTable
end

local function destroyEntity(entity)
    DeleteObject(entity)
end

function ReturnEntityToPool(name, entityId)
    -- print("RETURN FUNC")
    -- print(name, entityId)
    local index = IdToIndex[""..entityId]
    -- print("Returning:", entityId, "With Index:", index, name)
    -- print(""..entityId)
    -- print(index)
    local entityTable = entitiesInUse[index]

    if #entityPools[name] >= poolCap then
        --Destroy if excess
        destroyEntity(entityTable.entityId)
        entityTable = nil

    else
        SetEntityCoords(entityId, 0.0,0.0,0.0, false, false, false, false)
        SetEntityCollision(entityId, false, false)
        table.insert(entityPools[name], entityTable)
    end
    entitiesInUse[index] = nil
    IdToIndex[""..entityId] = nil
end

function AddEntityPool(name)
    if not entityPools[name] then
        entityPools[name] = createEntityPool(name)
    end
end



-- Loop through proplines
-- filter out distant points
-- 

local cm_Dist_vec3 = CMath.Vec3.Distance

local pointsInRange = {}
local timeToCompleteDistChecks = 2000

local maxDistThreshold = 128

function SetPointsPropPositionAndQuat(Point)
    local entity = Point.previewEntityId
    if entity ~= 0 then
        local entPos = Point.propPosition
        local entQuat = Point.propQuaternion
        SetEntityCoords(entity, entPos, false, false, false, false)
        -- print("Quat:", entQuat)
        SetEntityQuaternion(entity, entQuat)
    end

end

CreateThread(function (threadId)
    while true do
        --start new batch
        if not ToolEnabled then
            for index, Point in ipairs(pointsInRange) do
                    --remove entity
                    local Line = PropLines[Point.parentId]
                    ReturnEntityToPool(Line.prop, Point.previewEntityId)
                    Point.previewEntityId = 0
            end
            pointsInRange = {}
        else
            pointsInRange = {}
            for key1, Line in pairs(PropLines) do
                for key2, Point in pairs(Line.points) do
                    
                    local dist = cm_Dist_vec3(ClientCamCoords, Point.PosAndRotData.pointPosition)
                    -- print(dist)
                    if dist < maxDistThreshold then

                        if Point.previewEntityId == 0 then
                            local batchIndex = #pointsInRange+1
                            --add entity
                            Point.previewEntityId = takeEntityFromPool(Line.prop)
                            -- print("Preview Id set to", Point.previewEntityId)
                            SetPointsPropPositionAndQuat(Point)
                            
                            pointsInRange[batchIndex] = Point
                        else
                            local batchIndex = #pointsInRange+1
                            pointsInRange[batchIndex] = Point
                        end
                        
                    else
                        if Point.previewEntityId ~= 0 then
                            --remove entity
                            -- print(Line.prop, Point.previewEntityId)
                            ReturnEntityToPool(Line.prop, Point.previewEntityId)
                            Point.previewEntityId = 0
                        end
                    end

                    Wait(16)
                end
            end
        end
        
        Wait(0)
    end
end)

--[[
    when you add, move, delete, set override
]]