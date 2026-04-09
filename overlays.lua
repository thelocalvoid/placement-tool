-- Lines = {}
-- Spheres = {}
-- Rects = {}
-- ? Now stored in main.lua

local sphereCounter = 0
local lineCounter = 0
local rectCounter = 0

local linesToDraw = {}
local spheresToDraw = {}
local rectsToDraw = {}


local maxLines = 10000
local maxSpheres = 10000
local maxRects = 10000

local screenWidth
local screenHeight
local aspectRatio

function lerpClamped(x, min, max)
    local t = (x - min) / (max - min)
    return math.max(0, math.min(1, t))
end

local function calculateScale(dist, distMin, distMax, scaleMin, scaleMax)
    local scale = 1.0 - lerpClamped(dist, distMin, distMax)
    -- print(dist)
    scale = math.min(scale, scaleMax)
    scale = math.max(scale, scaleMin)
    return scale
end

local lineColors = Enum.LineDrawColors

local function drawSpheres()
    for key, entry in pairs(spheresToDraw) do
        -- print(entry.id)
        DrawSphere(entry.x, entry.y, entry.z, entry.radius, entry.r, entry.g, entry.b, entry.a)
    end
end
local function drawRects()
    -- for key, entry in pairs(rectsToDraw) do
    --     DrawRect(entry.x, entry.y, entry.width, entry.height, entry.r, entry.g, entry.b, entry.a)
    -- end
    local currentlyEditing = (ToolState == Enum.ToolStates.EDIT or ToolState == Enum.ToolStates.BUILD)
    -- print("overlays.lua",ClientCamCoords)
    for key, entry in pairs(rectsToDraw) do

        local rectType = entry.rectType
        if entry.parentLine ~= CurrentlySelectedPropLine then
            rectType = Enum.LineDrawType.UNSELECTED
        else
            if currentlyEditing then
                if entry.parentPoint == CurrentHeadOfLine then
                    rectType = Enum.LineDrawType.EDITHEAD
                end 
                if EditSelection == entry.parentPoint then
                    
                    rectType = Enum.LineDrawType.EDITSELECT
                end
            end
        end

        local dist = #(ClientCamCoords.xy - vector2(entry.x, entry.y))
        local scale = calculateScale(dist, 25, 100, 0.16666, 1.0)
        local onscreen,  x, y = GetScreenCoordFromWorldCoord(entry.x, entry.y, entry.z)
        if onscreen then
            DrawRect(x , y , (entry.width / screenWidth) * scale, (entry.height / screenHeight) * scale, lineColors[rectType])
            Rects[entry.id].ScreenCoords = vec(x,y)
            Rects[entry.id].ScreenSize = (entry.width / screenWidth) * scale
        end
    end
end


local function drawLines()

    local verticalOffset = vector3(0.0,0.0,0.1)

    for key, entry in pairs(linesToDraw) do

        local lineType = entry.lineType
        if entry.lineParent ~= CurrentlySelectedPropLine then
            lineType = Enum.LineDrawType.UNSELECTED
        end

        -- ! EXPERIMENTAL
        -- * This removes the 3d nature of the lines, displaying  them directly infront of the camera
        -- # SEEMS TO WORK PRETTY WELL
        local startDiff = entry.lineStart - ClientCamCoords
        local endDiff = entry.lineEnd - ClientCamCoords
        local newStart = ClientCamCoords + (startDiff / #startDiff)
        local newEnd = ClientCamCoords + (endDiff / #endDiff)

        ---@diagnostic disable-next-line: missing-parameter, param-type-mismatch
        DrawLine(newStart, newEnd, lineColors[lineType])
        -- ! -----------

        -- DrawLine(entry.lineStart + verticalOffset, entry.lineEnd + verticalOffset, lineColors[lineType])
    end
end

local function filterLines()
    
end
local function filterSpheres()
    
end
local function filterRects()
    
end

 -- TODO: Move this to query based, as this is a waste of render time (unnecessary recalculation)
local function filterEntries()
    if #Lines > maxLines then
        linesToDraw = filterLines()
    else
        linesToDraw = Lines
    end
    if #Spheres > maxSpheres then
        spheresToDraw = filterSpheres()
    else
        spheresToDraw = Spheres
    end
    if #Rects > maxRects then
        rectsToDraw = filterRects()
    else
        rectsToDraw = Rects
    end
end

local previewColor = Enum.LineDrawColors[Enum.LineDrawType.PREVIEW]

local function drawPreviews()
    if PreviewPoint then
        local point = Previews.Point
        -- print("overlays.lua", "previewing Point")
        DrawSphere(CursorWorldPos.x, CursorWorldPos.y, CursorWorldPos.z, 0.5, previewColor.x,previewColor.y,previewColor.z, 1.0)
        if PreviewLine then
            local line = Previews.Line
            local startPos = line.startPos
        -- print("overlays.lua", "previewing Line")
            DrawLine(startPos.x, startPos.y, startPos.z+0.25, CursorWorldPos.x, CursorWorldPos.y, CursorWorldPos.z + 0.25, previewColor.x,previewColor.y,previewColor.z, 255)
            if PreviewLine2 then
                line = Previews.Line2
                startPos = line.startPos
                DrawLine(startPos.x, startPos.y, startPos.z+0.25, CursorWorldPos.x, CursorWorldPos.y, CursorWorldPos.z + 0.25, previewColor.x,previewColor.y,previewColor.z, 255)
            end
        end
    end
end

local toolStateNames = Enum.ToolStateNames

local function drawCurrentToolState()
    BeginTextCommandDisplayText('STRING')
    local text = toolStateNames[ToolState].. " MODE"
    AddTextComponentSubstringPlayerName(text)
    SetTextOutline()
    SetTextCentre(true)
    EndTextCommandDisplayText(0.5, 0.8)
end


local function drawControls()
    local verticalOffset = 0.0175
    for index, string in ipairs(ToolControls) do
        -- print(string)
        BeginTextCommandDisplayText('STRING')
        AddTextComponentSubstringPlayerName(string)
        SetTextOutline()
        SetTextScale(0.24, 0.25)
        EndTextCommandDisplayText(0.01, 0.4 + (index * verticalOffset))
    end
end

local function draw2dElements()
    drawCurrentToolState()
    -- drawTooltip()
    drawControls()
end

local function FormatDistance(dist)
        -- 1.53467m
    dist = math.floor(dist*1000) / 1000
    -- 1.534m

    return "".. (dist) .. "m"
end

local function drawDistance(lineNum, color)
    local lineData = DistPreviews[lineNum]
        ---@diagnostic disable-next-line: missing-parameter, unused-function, param-type-mismatch
    SetDrawOrigin(lineData.pos, 0)
    BeginTextCommandDisplayText('STRING')
        ---@diagnostic disable-next-line: missing-parameter, unused-function, param-type-mismatch
    local dist = #(ClientCamCoords.xy - lineData.pos.xy)
    local scale = calculateScale(dist, 0, 150, 0.25, 0.8)
    local text = FormatDistance(lineData.dist)
    SetTextScale(0.0, scale)
    SetTextColour(175, 0, 175, 255)
    AddTextComponentSubstringPlayerName(text)
    SetTextCentre(true)
    EndTextCommandDisplayText(0.0, 0.0)
end 
local function drawDistances()
    if PreviewLine then
        drawDistance(1, previewColor)
        if PreviewLine2 then
            drawDistance(2, previewColor)
        end
        ClearDrawOrigin()
    end
end

function Render()
    aspectRatio = GetAspectRatio(false) -- ? try switching to true
    screenWidth, screenHeight = GetActualScreenResolution()
    -- print(screenWidth, screenHeight)
    filterEntries()

    drawRects()
    drawLines()
    drawSpheres()

    drawPreviews()
    draw2dElements()
    drawDistances()

end
-- CreateThread(function (threadId)
--     while true do
--         render()
--         Wait(0)
--     end
-- end)
-- ? now in control-handler.lua thread

function AddSphere(pos)
    sphereCounter = sphereCounter + 1
    local id = sphereCounter
    local newSphere = {
        id = id,
        x = pos.x,
        y = pos.y,
        z = pos.z,
        radius = 0.5,
        r = 0,
        g = 255,
        b = 0,
        a = 1.0
    }
    Spheres[id] = newSphere
    -- print("AddSphere", "id", id)
    return id
end

function AddRect(pos, rectType, parentLine, parentPoint)
    rectCounter = rectCounter + 1
    local id = rectCounter
    local newRect = {
        id = id,
        x = pos.x,
        y = pos.y,
        z = pos.z,
        width = 24,
        height = 24,
        r = 0,
        g = 255,
        b = 0,
        a = 255,
        parentLine = parentLine,
        rectType = rectType,
        parentPoint = parentPoint,
    }
    Rects[id] = newRect
    -- print("AddRect", "id", id)
    return id
end

function AddLine(coords, lineType, parent)
    -- print("Add overlay Line", coords.startCoords, coords.endCoords)
    lineCounter = lineCounter + 1
    local id = lineCounter
    local newLine = {
        id = id,
        lineParent = parent,
        lineType = lineType,
        lineStart = coords.startCoords,
        lineEnd = coords.endCoords,
    }
    Lines[id] = newLine
    -- print("New overlay sline", "id", id)
    return id, Lines[id]
end

function UpdateLines(first, second)
    Lines[first.id].lineStart = first.lineStart or Lines[first.id].lineStart
    Lines[first.id].lineEnd = first.lineEnd
    if second then
        Lines[second.id].lineStart = second.lineStart
        Lines[second.id].lineEnd = second.lineEnd or Lines[second.id].lineEnd
    end
end

function SetPreview(mode)
    PreviewLine, PreviewPoint, PreviewLine2 = table.unpack(Enum.PreviewModes.Values[mode])
end

-- TODO: Add Parent lines for unselect effect