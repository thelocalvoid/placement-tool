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
local maxRects = 500 -- Rects are limited by gta to 500 per frame

local screenWidth
local screenHeight
local aspectRatio

local secondFrame = false

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

local secondFrameRectCache = {}
local currentlyEditing = false

local function drawRects()

    if not secondFrame then
        currentlyEditing = (ToolState == Enum.ToolStates.EDIT or ToolState == Enum.ToolStates.BUILD)

        for key, entry in pairs(rectsToDraw) do

            local id = entry.id



            local dist = #(ClientCamCoords.xy - vector2(entry.x, entry.y))
            local scale = calculateScale(dist, 25, 100, 0.16666, 1.0)
            local onscreen,  x, y = GetScreenCoordFromWorldCoord(entry.x, entry.y, entry.z)

            secondFrameRectCache[id].scale = scale
            secondFrameRectCache[id].onscreen = onscreen
            secondFrameRectCache[id].x = x
            secondFrameRectCache[id].y = y

            if onscreen then

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

                DrawRect(x , y , (entry.width / screenWidth) * scale, (entry.height / screenHeight) * scale, lineColors[rectType])
                Rects[id].ScreenCoords = vec(x,y)
                Rects[id].ScreenSize = (entry.width / screenWidth) * scale
            end
        end

    else
        for key, entry in pairs(rectsToDraw) do

            local id = entry.id
            local rectCache = secondFrameRectCache[id]

            if rectCache.onscreen then
                
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
                
                DrawRect(rectCache.x , rectCache.y , (entry.width / screenWidth) * rectCache.scale, (entry.height / screenHeight) * rectCache.scale, lineColors[rectType])

            end

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

    secondFrame = not secondFrame

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
    secondFrameRectCache[id] = {}
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


-- local profile_rectsToDraw = {}
-- local cache = {}

-- local function createRandomRects(n)
--     for i = 1, n, 1 do
--         profile_rectsToDraw[i] = {
--             id = i,
--             rectType = 1,
--             parentLine = -1,
--             parentPoint = i,
--             x = math.random(0.0,1000.0),
--             y = math.random(00.0,1000.0),
--             z = math.random(00.0,1000.0),
--             width = 32,
--             height = 32,
--         }
--         cache[i] = {}
--     end
-- end
-- createRandomRects(1000)

-- local LocalClientCamCoords = vector3(0.0,-1000.0,0.0)
-- local LOCAL_screenHeight = 1080
-- local LOCAL_screenWidth = 1920

-- local secondFrame = false
-- local lDrawRect = DrawRect
-- local lGetScreenCoords = GetScreenCoordFromWorldCoord

-- local function drawRects_profilefunc()

--     local currentlyEditing = true

--     if secondFrame then
--         for key, entry in pairs(profile_rectsToDraw) do



--             local rectCache = cache[key]
--             if rectCache.onscreen then

--                 local rectType = entry.rectType
--                 if entry.parentLine ~= CurrentlySelectedPropLine then
--                     rectType = Enum.LineDrawType.UNSELECTED
--                 else
--                     if currentlyEditing then
--                         if entry.parentPoint == CurrentHeadOfLine then
--                             rectType = Enum.LineDrawType.EDITHEAD
--                         end 
--                         if EditSelection == entry.parentPoint then
                            
--                             rectType = Enum.LineDrawType.EDITSELECT
--                         end
--                     end
--                 end
--                 DrawRect(rectCache.x , rectCache.y , (entry.width / LOCAL_screenWidth) * rectCache.scale, (entry.height / LOCAL_screenHeight) * rectCache.scale, lineColors[rectType])
--                 -- Rects[entry.id].ScreenCoords = vec(x,y)
--                 -- Rects[entry.id].ScreenSize = (entry.width / LOCAL_screenWidth) * scale
--             end
--         end
--     else
--         local countOnScreen = 0
--         for key, entry in pairs(profile_rectsToDraw) do



--             local dist = #(LocalClientCamCoords.xy - vector2(entry.x, entry.y))
--             local scale = calculateScale(dist, 25, 100, 0.16666, 1.0)
--             local onscreen,  x, y = GetScreenCoordFromWorldCoord(entry.x + 0.5, entry.y + 0.5, entry.z + 0.5)

--             -- print(x, y, entry.x, entry.y, entry.z)

--             cache[key].scale = scale
--             cache[key].onscreen = onscreen
--             cache[key].x = x
--             cache[key].y = y

--             if onscreen then

--                 countOnScreen = countOnScreen + 1

--                 local rectType = entry.rectType
--                 if entry.parentLine ~= CurrentlySelectedPropLine then
--                     rectType = Enum.LineDrawType.UNSELECTED
--                 else
--                     if currentlyEditing then
--                         if entry.parentPoint == CurrentHeadOfLine then
--                             rectType = Enum.LineDrawType.EDITHEAD
--                         end 
--                         if EditSelection == entry.parentPoint then
                            
--                             rectType = Enum.LineDrawType.EDITSELECT
--                         end
--                     end
--                 end
--                 DrawRect(x , y , (entry.width / LOCAL_screenWidth) * scale, (entry.height / LOCAL_screenHeight) * scale, lineColors[rectType])
--                 -- Rects[entry.id].ScreenCoords = vec(x,y)
--                 -- Rects[entry.id].ScreenSize = (entry.width / LOCAL_screenWidth) * scale
--             end
--         end
--         print(countOnScreen)
--     end

--     secondFrame = not secondFrame
-- end

-- local function profile_rectDraw()
--     Wait(0)
--     local start = GetGameTimer()
--     for i = 1, 10000, 1 do
--         drawRects_profilefunc()
--     end
--     local end1 = GetGameTimer()
--     Wait(0)
--     local end2 = GetGameTimer()
--     return end1 - start, end2 - start

-- end

-- local function profilethread_rectDraw()
--     for i = 1, 2000, 1 do
--         drawRects_profilefunc()
--         Wait(0)
--     end

-- end

-- RegisterCommand("profile_rectDraw", function ()

--     profilethread_rectDraw()
--     print("Done")
-- end)