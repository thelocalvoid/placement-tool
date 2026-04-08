





local cm_Dot_vec3 = CMath.Vec3.Dot
local cm_Dir_vec3 = CMath.Vec3.Direction
local cm_Diff_vec3 = CMath.Vec3.Difference
local cm_Lerp_vec3 = CMath.Vec3.Lerp
local cm_Dist_vec3 = CMath.Vec3.Distance
local cm_Norm_vec3 = CMath.Vec3.Normalize
local cm_Cross_vec3 = CMath.Vec3.Cross

-- * ////////////// DATA CREATION //////////////

local function seededRandom(seed)
    seed = (1103515245 * seed + 12345) % 2^31
    return seed / 2^31
end



local seedRange = {min = 1000000, max = 5000000}

local function createNewPoint(id, parentLineId, position, pointGroundNormal, youngerSibling, olderSibling, rectId, lineObject)
    
    local seed = math.random(seedRange.min + id, seedRange.max + id)

    local point = {
        id = id,
        parentId = parentLineId,
        seed = seed,
        pos = position,
        youngerSibling = youngerSibling,
        olderSibling = olderSibling,
        
         -- combination of neighbours(considering if reversed) and offsetToRotationZ
        rectId = rectId,
        previewEntityId = 0,
        PosAndRotData = {
            pointPosition = position,
            pointGroundNormal = pointGroundNormal,
            baseLineHeadingDir = vector3(0.0,0.0,0.0),
            headingOverride = false,
            headingOverrideDir = vector3(0.0,0.0,0.0),
        },
        propPosition = vector3(0.0,0.0,0.0),
        propQuaternion = vector4(0.0,0.0,0.0,0.0),
    }
    if lineObject then
        point.lineObject = lineObject
        point.lineId = lineObject.id
    end

    local xVar = ((seededRandom(seed) * 2) - 1)
    local zVar = ((seededRandom(seed*5) * 2) - 1)
    point.PosAndRotData.rotationVariation = vector3(xVar, 0.0, zVar)

    return point
end



local function createNewLine(entityName, firstPos)
    local id = #PropLines+1
    local newLine = {
        id = id,
        propName = entityName,
        reverse = false,
        randomRotationZ = false,
        alignToGroundNormal = false, -- TODO: This now functions properly, i need to make a command to toggle
        offsetToRotationZ = 0,
        verticalOffset = 0,
        headOfLine = 1,
        maxWobbleDegrees = 0,
        pointCount = 1,
        points = {},
    }
    PropLines[id] = newLine

    -- Set current selected line
    CurrentlySelectedPropLine = id
    CurrentHeadOfLine = 1

    return newLine, id
    -- AddRect(firstPos)
end

function StartNewLine(entityName, firstPos, pointGroundNormal)
    
    AddEntityPool(entityName)
    local line, lineId = createNewLine(entityName, firstPos)

    local rectId = AddRect(firstPos, Enum.LineDrawType.SELECTED, #PropLines, 1)
    line.points[#line.points+1] = createNewPoint(1, lineId, firstPos, pointGroundNormal, -1, -1, rectId)
end

local function refreshOverlaysForPoint(lineId, pointId)
    local point = PropLines[lineId].points[pointId]

    if point.youngerSibling ~= -1 then
        local youngerSibling = PropLines[lineId].points[point.youngerSibling]
        point.lineObject.lineEnd = point.pos
        point.lineObject.lineStart = youngerSibling.pos
    end
    if point.olderSibling ~= -1 then
        local olderSibling = PropLines[lineId].points[point.olderSibling]
        olderSibling.lineObject.lineStart = point.pos
        olderSibling.lineObject.lineEnd = olderSibling.pos
    end

    local rect = Rects[point.rectId]
    local newPos = point.pos
    rect.x = newPos.x
    rect.y = newPos.y
    rect.z = newPos.z
end
local function SetYoungerPointOf(point, to)
    point.youngerSibling = to
end
local function SetOlderPointOf(point, to)
    point.olderSibling = to
end

local function updateLineHeadingDirForPoint(point)
    local lineId = point.parentId
    local youngerId = point.youngerSibling
    local olderId = point.olderSibling
    local older
    local younger

    if olderId ~= -1 and youngerId ~= -1 then
        younger = PropLines[lineId].points[youngerId]
        older = PropLines[lineId].points[olderId]

        local startCoords = younger.PosAndRotData.pointPosition
        local endCoords = older.PosAndRotData.pointPosition
        
        local diff = cm_Diff_vec3(startCoords, endCoords)
        local dir = cm_Norm_vec3(diff)
        
        point.PosAndRotData.baseLineHeadingDir = dir --vector3(dir.x,dir.y,0.0)

        
    else
        if olderId ~= -1 then
            older = PropLines[lineId].points[olderId]

            local startCoords = point.PosAndRotData.pointPosition
            local endCoords = older.PosAndRotData.pointPosition
        
            local diff = cm_Diff_vec3(startCoords, endCoords)
            local dir = cm_Norm_vec3(diff)
            point.PosAndRotData.baseLineHeadingDir = dir -- vector3(dir.x,dir.y,0.0)
            

        elseif youngerId ~= -1 then
            younger = PropLines[lineId].points[youngerId]

            local startCoords = younger.PosAndRotData.pointPosition
            local endCoords = point.PosAndRotData.pointPosition
        
            local diff = cm_Diff_vec3(startCoords, endCoords)
            local dir = cm_Norm_vec3(diff)

            point.PosAndRotData.baseLineHeadingDir = dir -- vector3(dir.x,dir.y,0.0)
            
        else
            point.PosAndRotData.baseLineHeadingDir = vector3(0.0, 1.0, 0.0)
        end
    end

end


local function rotateVectorAroundAxis(v, axis, angleRad)
    local cosA = math.cos(angleRad)
    local sinA = math.sin(angleRad)

    local crossAV = cm_Cross_vec3(axis, v)
    local dotAV = cm_Dot_vec3(axis, v)

    return {
        x = v.x * cosA + crossAV.x * sinA + axis.x * dotAV * (1 - cosA),
        y = v.y * cosA + crossAV.y * sinA + axis.y * dotAV * (1 - cosA),
        z = v.z * cosA + crossAV.z * sinA + axis.z * dotAV * (1 - cosA)
    }
end

local function rotateU_onPlanes(F, R, U, degFU, degRF)
    local radFU = math.rad(degFU)
    local radRF = math.rad(degRF)

    local cosFU = math.cos(radFU)
    local sinFU = math.sin(radFU)

    -- Step 1: rotate U in FU plane (around R)
    local U1 = {
        x = U.x * cosFU + F.x * sinFU,
        y = U.y * cosFU + F.y * sinFU,
        z = U.z * cosFU + F.z * sinFU
    }

    -- Step 2: rotate U1 around ORIGINAL U (RF plane)
    local U2 = rotateVectorAroundAxis(U1, U, radRF)

    return U2
end

local function applyRotationVariation(originalF, F, R, U, rotationVariation, maxWobbleDegrees)
    
    local degFU = rotationVariation.x * maxWobbleDegrees
    local degRF = rotationVariation.z * 360
    if maxWobbleDegrees ~= 0 then
        U = rotateU_onPlanes(F, R, U, degFU, degRF)

        F = cm_Norm_vec3(originalF)
        U = cm_Norm_vec3(U)
        R = cm_Norm_vec3(cm_Cross_vec3(F, U))
        -- re-orthoganise
        F = cm_Cross_vec3(U, R)
    end

    return F, R, U
end

local function rotateFRU_inFRPlane(F, R, U, degrees)
    local rad = math.rad(degrees)
    local cosT = math.cos(rad)
    local sinT = math.sin(rad)

    local F2 = {
        x = F.x * cosT + R.x * sinT,
        y = F.y * cosT + R.y * sinT,
        z = F.z * cosT + R.z * sinT
    }

    local R2 = {
        x = R.x * cosT - F.x * sinT,
        y = R.y * cosT - F.y * sinT,
        z = R.z * cosT - F.z * sinT
    }

    -- U unchanged
    return F2, R2, U
end

local function rotateMatrixHeading(matrix, degs) -- !may not work

    local F = matrix.F
    local R = matrix.R
    local U = matrix.U

    local rads = math.rad(degs)

    -- print(F, R, U)

    F =  F * math.cos(rads)  +  R * math.sin(rads)

    R = cm_Norm_vec3(cm_Cross_vec3(F, U))
    F = cm_Norm_vec3(cm_Cross_vec3(U, R))

    return F, R, U
end

local function randomUnit2D(seed)
    local angle = seededRandom(seed) * 360
    return {
        x = math.cos(angle),
        y = math.sin(angle)
    }
end


local function matrixToQuat(matrix)

    local F = matrix.F
    local R = matrix.R
    local U = matrix.U



    -- rotation matrix (column-major, GTA style)
    local m00, m01, m02 = R.x, F.x, U.x
    local m10, m11, m12 = R.y, F.y, U.y
    local m20, m21, m22 = R.z, F.z, U.z

    local trace = m00 + m11 + m22
    local x, y, z, w

    if trace > 0 then
        local s = math.sqrt(trace + 1.0) * 2
        w = 0.25 * s
        x = (m21 - m12) / s
        y = (m02 - m20) / s
        z = (m10 - m01) / s
    elseif (m00 > m11) and (m00 > m22) then
        local s = math.sqrt(1.0 + m00 - m11 - m22) * 2
        w = (m21 - m12) / s
        x = 0.25 * s
        y = (m01 + m10) / s
        z = (m02 + m20) / s
    elseif m11 > m22 then
        local s = math.sqrt(1.0 + m11 - m00 - m22) * 2
        w = (m02 - m20) / s
        x = (m01 + m10) / s
        y = 0.25 * s
        z = (m12 + m21) / s
    else
        local s = math.sqrt(1.0 + m22 - m00 - m11) * 2
        w = (m10 - m01) / s
        x = (m02 + m20) / s
        y = (m12 + m21) / s
        z = 0.25 * s
    end

    -- cm_Norm_vec3 quaternion (important)
    local len = math.sqrt(x*x + y*y + z*z + w*w)
    return vector4(
        x/len,
        y/len,
        z/len,
        w/len
        )
end


function CompilePositionAndRotation(point)

    local line = PropLines[point.parentId]
    local data = point.PosAndRotData
    
    local vertOffset = line.alignToGroundNormal and data.pointGroundNormal * line.verticalOffset or vector3(0.0,0.0,1.0) * line.verticalOffset
    local propPosition = data.pointPosition + vertOffset

    local propQuaternion = vector4(0.0,1.0,0.0,1.0)

    local originalU = line.alignToGroundNormal and data.pointGroundNormal or vector(0.0,0.0,1.0)
    local originalF = data.baseLineHeadingDir -- vector3(data.baseLineHeadingDir.x,data.baseLineHeadingDir.y,0.0)

    -- local startDiff = propPosition - ClientCamCoords
    -- local endDiff = propPosition + originalF - ClientCamCoords
    -- local newEnd = ClientCamCoords + (endDiff / #endDiff)
    -- local newStart = ClientCamCoords + (startDiff / #startDiff)
    -- DrawLine(newStart, newEnd, 255, 255, 0, 255)
    
    local R = vector3(0.0,0.0,0.0)

    -- print(F, R, U)

    F = cm_Norm_vec3(originalF)
    U = cm_Norm_vec3(originalU)
    R = cm_Cross_vec3(F, U)
    
    R = cm_Norm_vec3(R)
    -- re-orthoganise
    F = cm_Norm_vec3(cm_Cross_vec3(U, R))

    -- local endDiff = propPosition + F - ClientCamCoords
    -- local newStart = ClientCamCoords + (startDiff / #startDiff)
    -- local newEnd = ClientCamCoords + (endDiff / #endDiff)
    -- DrawLine(newStart, newEnd, 0, 255, 0, 255)
    -- local endDiff = propPosition + R - ClientCamCoords
    -- local newStart = ClientCamCoords + (startDiff / #startDiff)
    -- local newEnd = ClientCamCoords + (endDiff / #endDiff)
    -- DrawLine(newStart, newEnd, 255, 0, 0, 255)
    -- local endDiff = propPosition + U - ClientCamCoords
    -- local newStart = ClientCamCoords + (startDiff / #startDiff)
    -- local newEnd = ClientCamCoords + (endDiff / #endDiff)
    -- DrawLine(newStart, newEnd, 0, 0, 255, 255)

    
    -- print(currentMatrix.F, currentMatrix.R, currentMatrix.U)

    if data.headingOverride then
        
        F = data.headingOverrideDir -- vector3(data.headingOverrideDir.x, data.headingOverrideDir.y, 0.0)


        F = cm_Norm_vec3(F)
        U = cm_Norm_vec3(originalU)
        R = cm_Cross_vec3(F, U)
        
        R = cm_Norm_vec3(R)
        -- re-orthoganise
        F = cm_Norm_vec3(cm_Cross_vec3(U, R))

    elseif line.randomRotationZ then
        local degs = data.rotationVariation.z * 7868
        F, R, U = rotateFRU_inFRPlane(F, R, U, degs)

        -- TODO: Make this not relative to base heading

    else
        F, R, U = rotateFRU_inFRPlane(F, R, U, line.offsetToRotationZ)
    end

    -- turn the matrix into a quaternion
    

    F = cm_Norm_vec3(F)
    U = cm_Norm_vec3(U)
    R = cm_Norm_vec3(cm_Cross_vec3(F, U))
    -- re-orthoganise
    F = cm_Cross_vec3(U, R)

    -- print(currentMatrix.F)
    -- print(currentMatrix.R)
    -- print(currentMatrix.U)

    F, R, U = applyRotationVariation(originalF, F, R, U, data.rotationVariation, line.maxWobbleDegrees)
    
    if line.reverse and not data.headingOverride then
        R = -R
        F = -F
    end

    -- local endDiff = propPosition + F - ClientCamCoords
    -- local newStart = ClientCamCoords + (startDiff / #startDiff)
    -- local newEnd = ClientCamCoords + (endDiff / #endDiff)
    -- DrawLine(newStart, newEnd, 0, 255, 0, 255)
    -- local endDiff = propPosition + R - ClientCamCoords
    -- local newStart = ClientCamCoords + (startDiff / #startDiff)
    -- local newEnd = ClientCamCoords + (endDiff / #endDiff)
    -- DrawLine(newStart, newEnd, 255, 0, 0, 255)
    -- local endDiff = propPosition + U - ClientCamCoords
    -- local newStart = ClientCamCoords + (startDiff / #startDiff)
    -- local newEnd = ClientCamCoords + (endDiff / #endDiff)
    -- DrawLine(newStart, newEnd, 0, 0, 255, 255)


    propQuaternion = matrixToQuat({F=F, R=R, U=U})

    return propPosition, propQuaternion
end


-- * ////////////// ADD DATA FUNCTIONS //////////////

function AddPointToLine(lineId, position, pointGroundNormal, youngerSibling)
    local pointCount = PropLines[lineId].pointCount


    local count = 0
    for i = 1, 1000, 1 do
        count = i
        if not PropLines[lineId].points[i] then
            break
        end
    end

    local newId = count

    -- print("youngerSibling id",youngerSibling)
    -- print(newId, "youngerSibling entry", youngerSibling)
    local youngerSibling = PropLines[lineId].points[youngerSibling]
    -- print(newId, "youngerSibling", youngerSibling)
    -- print("youngerSibling",youngerSibling)
    -- print("youngerSibling pos",youngerSibling.pos)

    local rectId = AddRect(position, Enum.LineDrawType.SELECTED, lineId, newId)

    -- print(newId, "youngerSiblingId", youngerSibling.id)
    local overlayLineId, lineObject = AddLine({startCoords = youngerSibling.pos, endCoords = position},Enum.LineDrawType.SELECTED, lineId)
    local point = createNewPoint(newId, lineId, position, pointGroundNormal, youngerSibling.id, -1, rectId, lineObject)

    PropLines[lineId].points[newId] = point
    SetOlderPointOf(youngerSibling, newId)
    updateLineHeadingDirForPoint(youngerSibling)

    PropLines[lineId].pointCount = pointCount + 1
    PropLines[lineId].headOfLine = newId
    CurrentHeadOfLine = newId

    updateLineHeadingDirForPoint(point)
    point.propPosition, point.propQuaternion =  CompilePositionAndRotation(point)
    SetPointsPropPositionAndQuat(point)
    youngerSibling.propPosition, youngerSibling.propQuaternion =  CompilePositionAndRotation(youngerSibling)
    SetPointsPropPositionAndQuat(youngerSibling)

    -- print(#PropLines[lineId].points)

end

function AddPointInBetween(lineId, position, pointGroundNormal, youngerSiblingId, olderSiblingId)
    local pointCount = PropLines[lineId].pointCount

    local count = 0
    for i = 1, 1000, 1 do
        count = i
        if not PropLines[lineId].points[i] then
            break
        end
    end

    local newId = count
    local youngerSibling = PropLines[lineId].points[youngerSiblingId]
    local olderSibling = PropLines[lineId].points[olderSiblingId]

    local rectId = AddRect(position, Enum.LineDrawType.SELECTED, lineId, newId)
    local overlayLineId, lineObject = AddLine({startCoords = youngerSibling.pos, endCoords = position},Enum.LineDrawType.SELECTED, lineId)

    local point = createNewPoint(newId, lineId, position, pointGroundNormal, youngerSiblingId, olderSiblingId, rectId, lineObject)

    PropLines[lineId].points[newId] = point

    SetOlderPointOf(youngerSibling, newId)
    SetYoungerPointOf(olderSibling, newId)
    refreshOverlaysForPoint(lineId, newId)

    updateLineHeadingDirForPoint(youngerSibling)
    updateLineHeadingDirForPoint(olderSibling)
    updateLineHeadingDirForPoint(point)

    point.propPosition, point.propQuaternion =  CompilePositionAndRotation(point)
    SetPointsPropPositionAndQuat(point)
    youngerSibling.propPosition, youngerSibling.propQuaternion =  CompilePositionAndRotation(youngerSibling)
    SetPointsPropPositionAndQuat(youngerSibling)
    olderSibling.propPosition, olderSibling.propQuaternion =  CompilePositionAndRotation(olderSibling)
    SetPointsPropPositionAndQuat(olderSibling)

    PropLines[lineId].pointCount = pointCount + 1
end 


-- * ////////////// EDIT DATA FUNCTIONS //////////////



function EditPoint(lineId, pointId, newPosition, newGroundNormal)
    --update positsions here
    local line = PropLines[lineId]
    local point = line.points[pointId]
    point.pos = newPosition
    point.PosAndRotData.pointPosition = newPosition
    point.PosAndRotData.pointGroundNormal = newGroundNormal

    refreshOverlaysForPoint(lineId, pointId)
    
    local younger = line.points[point.youngerSibling]
    local older = line.points[point.olderSibling]

    if younger then
        updateLineHeadingDirForPoint(younger)
        younger.propPosition, younger.propQuaternion =  CompilePositionAndRotation(younger)
        SetPointsPropPositionAndQuat(younger)
    end
    if older then
        updateLineHeadingDirForPoint(older)
        older.propPosition, older.propQuaternion =  CompilePositionAndRotation(older)
        SetPointsPropPositionAndQuat(older)
    end

    updateLineHeadingDirForPoint(point)
    point.propPosition, point.propQuaternion =  CompilePositionAndRotation(point)
    SetPointsPropPositionAndQuat(point)
end

function SetPointRotationOverride(lineId, pointId, RotateDir, WasntOverriddenBefore)
    local line = PropLines[lineId]
    local point = line.points[pointId]
    if WasntOverriddenBefore then
        point.PosAndRotData.headingOverride = false
    else
        point.PosAndRotData.headingOverride = true
        point.PosAndRotData.headingOverrideDir = RotateDir
    end
    point.propPosition, point.propQuaternion =  CompilePositionAndRotation(point)
    SetPointsPropPositionAndQuat(point)
end



local function recompileLineProps(line)
    for key, point in pairs(line.points) do
        point.propPosition, point.propQuaternion =  CompilePositionAndRotation(point)
        SetPointsPropPositionAndQuat(point)
    end
end

--* ROT VARIATION
function SetLineRotationVariation(lineId, intensity)
    local line = PropLines[lineId]
    line.maxWobbleDegrees = intensity
    recompileLineProps(line)
end

--* ROT OFFSET
function SetLineRotationOffset(lineId, offset)
    local line = PropLines[lineId]
    line.offsetToRotationZ = offset
    recompileLineProps(line)
end

--* VERTICAL OFFSET
function SetLineVerticalOffset(lineId, offset)
    local line = PropLines[lineId]
    line.verticalOffset = offset
    recompileLineProps(line)
end


--* RANDOM
function SetLineRandomRotation(lineId, bool)
    local line = PropLines[lineId]
    line.randomRotationZ = bool
    recompileLineProps(line)
end

--* REVERSE
function SetLineReverseRotation(lineId, bool)
    local line = PropLines[lineId]
    line.reverse = bool
    recompileLineProps(line)
end


function OverridePointHeading(lineId, pointId, dirVec)
    local point = PropLines[lineId].points[pointId]
    point.PosAndRotData.headingOverrideDir = dirVec

    
    point.propPosition, point.propQuaternion =  CompilePositionAndRotation(lineId, pointId)
    SetPointsPropPositionAndQuat(point)
    
end


function RemovePoint(lineId, pointId)
    --update positsions here

    local line = PropLines[lineId]
    local point = line.points[pointId]

    
    local youngerId = point.youngerSibling
    local olderId = point.olderSibling

    if youngerId == -1 and olderId == -1 then
        print("CANNOT DELETE LAST POINT")
        return
    end
    -- print("Removing:", pointId, "from:", lineId)

    if point.previewEntityId ~= 0 then
        ReturnEntityToPool(line.propName, point.previewEntityId)
    end
    -- Delete rect
    if point.rectId then
        Rects[point.rectId] = nil
    end
    -- Delete Line
    if point.lineId then
        Lines[point.lineId] = nil
    end

    PropLines[lineId].points[pointId] = nil

    if olderId ~= -1 then
        local older = PropLines[lineId].points[olderId]
        older.youngerSibling = youngerId

        refreshOverlaysForPoint(lineId, olderId)
        updateLineHeadingDirForPoint(older)
        older.propPosition, older.propQuaternion =  CompilePositionAndRotation(older)
        SetPointsPropPositionAndQuat(older)
    end
    if youngerId ~= -1 then
        local younger = PropLines[lineId].points[youngerId]
        younger.olderSibling = olderId

        refreshOverlaysForPoint(lineId, youngerId)
        updateLineHeadingDirForPoint(younger)
        younger.propPosition, younger.propQuaternion =  CompilePositionAndRotation(younger)
        SetPointsPropPositionAndQuat(younger)
    else
        local older = PropLines[lineId].points[olderId]
        older.youngerSibling = youngerId

        refreshOverlaysForPoint(lineId, olderId)
        updateLineHeadingDirForPoint(older)
        older.propPosition, older.propQuaternion =  CompilePositionAndRotation(older)
        SetPointsPropPositionAndQuat(older)
        if older.lineId then
            Lines[older.lineId] = nil
            older.lineId = nil
            older.lineObject = nil
        end
    end
    if pointId == PropLines[lineId].headOfLine then
        PropLines[lineId].headOfLine = youngerId
    end

    
    
end

function RemoveLine(lineId)

    local line = PropLines[lineId]
    for key, value in pairs(line.points) do
        if value.previewEntityId ~= 0 then
            ReturnEntityToPool(line.propName, value.previewEntityId)
        end
        if value.rectId then
            Rects[value.rectId] = nil
        end
        if value.lineId then
            Lines[value.lineId] = nil
        end
    end

    PropLines[lineId] = nil
end


-- * ////////////// GET DATA FUNCTIONS //////////////

function GetMoveReturnDataForPoint(lineId, pointId)

    local data = PropLines[lineId].points[pointId].PosAndRotData
    return data.pointPosition, data.pointGroundNormal
    
end

function GetRotateReturnDataForPoint(lineId, pointId)

    local data = PropLines[lineId].points[pointId].PosAndRotData

    return not data.headingOverride, data.headingOverrideDir
    
end

local validPairs = {}

function GetPointPairPosIsInside(pos)

    -- print("Getting pairs")
    validPairs = {}

    local Points =       PropLines[CurrentlySelectedPropLine].points
    local lineHead =     PropLines[CurrentlySelectedPropLine].headOfLine
    -- print("Line Head:", lineHead)
    local currentPoint = Points[lineHead]

    while currentPoint.youngerSibling ~= -1 do
        -- print("Current Point:", currentPoint.id, currentPoint)
        local youngerSiblingId = currentPoint.youngerSibling
        -- print("Younger ID:", youngerSiblingId)
        local youngerSibling =   Points[youngerSiblingId]
        -- print("Younger Point:", youngerSibling.id, youngerSibling)

        -- Get Dot Product of both points

        -- Get first Dot Product
        local dir =   cm_Dir_vec3(youngerSibling.pos,   currentPoint.pos)
        local diff1 = cm_Diff_vec3(pos, currentPoint.pos)
        local dot1 =  cm_Dot_vec3(diff1, dir)
        -- test first dot product
        if dot1 >= 0 then
            -- print("Dot 1 success:", dot1)
            -- local onscreen,  x, y = GetScreenCoordFromWorldCoord(currentPoint.pos)
            -- if onscreen then
            --     DrawRect(x , y , (24 / screenWidth), (24 / screenHeight), 0, 255, 255, 255)
            -- end
            -- Get Second Dot Product
            local diff2 = cm_Diff_vec3(pos, youngerSibling.pos)
            local dot2 =  cm_Dot_vec3(diff2, -dir)
            -- test second dot product
            if dot2 >= 0 then
                -- print("Dot 2 success:", dot2)
                -- local onscreen,  x, y = GetScreenCoordFromWorldCoord(youngerSibling.pos)
                -- if onscreen then
                --     DrawRect(x , y , (24 / screenWidth), (24 / screenHeight), 0, 255, 255, 255)
                -- end
                -- If both are deemed inside, add to valid pairs
                local midpoint = cm_Lerp_vec3(youngerSibling.pos, currentPoint.pos, 0.5)
                validPairs[#validPairs+1] = {
                    lastPoint =    currentPoint,
                    firstPoint =   youngerSibling,
                    midpoint = midpoint,
                    distFromMidpoint = cm_Dist_vec3(midpoint, pos),
                }
            else
                -- print("Dot 2 fail:", dot2)
            end
        else
            -- print("Dot 1 fail:", dot1)
        end

        

        currentPoint = youngerSibling
    end


    -- if validPairs > 1 then determine closest pair?
    -- Maybe by testing dist to midpoint
    local closestPair = 1
    local closestDist = 10000000
    if #validPairs > 1 then
        for index, value in ipairs(validPairs) do
            if value.distFromMidpoint < closestDist then
                closestDist = value.distFromMidpoint
                closestPair = index
            end
        end
    end


    return validPairs[closestPair] or -1
end





--//TODO: Random rotation
--//TODO: Rotation facing line direction
--//TODO: Random rotation offset by point seed
--//TODO: Show Entity Preview
--//TODO: Rotation overide

--TODO: UNDO FEATURE
--//TODO: verticalOffset
--TODO: Enter entity flags

--TODO: Reopenable autosaves


--BUG: Nil line number? when delete then make new
--. Havent been able to replicate


--//BUG: Other line's points are included in the rect search when in move and override mode
--. Test solution
--. Success!

--BUG: Camera Load issues

--//BUG: End point will attach to other line
-- @post-placement-tool/control-handler.lua:170: attempt to index a nil value (field '?')^7
--170: CurrentHeadOfLine = PropLines[CurrentlySelectedPropLine].headOfLine
--. THEORY:  Rect lineparent is set to #PropLines+1 after line is created
--. Success!


--BUG: RANGE MARKERS ARE ODD IN SOME MODES


--NOTE: ADDED Cursor UX 