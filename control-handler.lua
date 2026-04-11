




-- * ////////////// UTILITY FUNCTIONS //////////////

local function isPosInBoundsOfPoint(rectPos, maxDist, cursorPos)

    local xDiff = math.abs(cursorPos.x - rectPos.x)
    local yDiff = math.abs(cursorPos.y - rectPos.y)

    maxDist = maxDist + 0.001

    return (xDiff <= maxDist and yDiff <= maxDist)
end 

local function isCursorOverAnyPoint(cursorPos)
    for key, value in pairs(Rects) do
        local bounds = {}
        local coords = value.ScreenCoords
        local Size = value.ScreenSize
        
        if isPosInBoundsOfPoint(coords, Size/2, cursorPos) then
            return true, value
        end
    end
    return false, value
end

local function isCursorOverAPointInSelectedLine(cursorPos)
    for key, value in pairs(Rects) do
        if value.parentLine == CurrentlySelectedPropLine then
            local bounds = {}
            local coords = value.ScreenCoords
            local Size = value.ScreenSize
            
            if isPosInBoundsOfPoint(coords, Size/2, cursorPos) then
                return true, value
            end
        end

    end
    return false, value
end



-- * ////////////// TOOL STATE CHANGE //////////////

local execBeforeModeSwitch = {
    [Enum.ToolStates.ROTATION_OVERRIDE] = function (beforeData)
        if EditSelection ~= -1 then

            if beforeData.removeOverride then
                SetPointRotationOverride(CurrentlySelectedPropLine, EditSelection, RotateReturnDir, true)
            else
                SetPointRotationOverride(CurrentlySelectedPropLine, EditSelection, RotateReturnDir, RotateReturnWasntOverridden)
            end

            EditSelection = -1
        end
        return
    end,
    [Enum.ToolStates.MOVE] = function (beforeData)
        if EditSelection ~= -1 then

            EditPoint(CurrentlySelectedPropLine, EditSelection, MoveReturnPos, MoveReturnNormal)
            EditSelection = -1
        end
        return
    end
}
local execAfterModeSwitch = {
    [Enum.ToolStates.EDIT] = function (afterData)
        SetPreview(Enum.PreviewModes.NONE)
        SetMouseCursorStyle(Enum.MousePointerStyle.ARROW)
        return
    end,
    [Enum.ToolStates.BUILD] = function (afterData)
        SetPreview(Enum.PreviewModes.LINEANDPOINT)

        if afterData.setPreviewStartToLastClick then
            Previews.Line.startPos = LastClickWorldCoords
        else
            Previews.Line.startPos = PropLines[CurrentlySelectedPropLine].points[PropLines[CurrentlySelectedPropLine].headOfLine].pos
        end

        return
    end,
    [Enum.ToolStates.MOVE] = function (afterData)
        SetPreview(Enum.PreviewModes.NONE)
        return
    end,
    [Enum.ToolStates.DELETE] = function (afterData)
        SetPreview(Enum.PreviewModes.NONE)
        return
    end,
    [Enum.ToolStates.ROTATION_OVERRIDE] = function (afterData)
        SetPreview(Enum.PreviewModes.NONE)
        return
    end,
    [Enum.ToolStates.OBJECT] = function (afterData)
        SetPreview(Enum.PreviewModes.NONE)
        if not afterData.tabpress then
            CurrentlySelectedPropLine = -1
        end
        return
    end,
    [Enum.ToolStates.CREATE] = function (afterData)
        SetPreview(Enum.PreviewModes.POINT)
        CurrentlySelectedPropLine = -1
        return
    end
}

local function switchToolState(newToolState, beforeData, afterData)

    local oldToolState = ToolState
    local execBeforeModeSwitch = execBeforeModeSwitch[oldToolState]
    local execAfterModeSwitch = execAfterModeSwitch[newToolState]

    --* Exit previous state
    if execBeforeModeSwitch then
        execBeforeModeSwitch(beforeData)
    end

    --* Set new state
    ToolState = newToolState
    ToolControls = HudElements.Modes[newToolState]()

    --* Config for new state
    if execAfterModeSwitch then
        execAfterModeSwitch(afterData)
    end


    print("Switched mode to:", Enum.ToolStateNames[newToolState])
end



-- * ////////////// TOOL STATE CONTROLS //////////////

local cm_Dir_vec3 = CMath.Vec3.Direction
local cm_Norm_vec3 = CMath.Vec3.Normalize

local toolStateControls = {
    [Enum.ToolStates.OBJECT] = function () -- ## OBJECT MODE
        SetMouseCursorStyle(Enum.MousePointerStyle.ARROW)
        
        local screenX = GetDisabledControlNormal(0, 239)
        local screenY = GetDisabledControlNormal(0, 240)
        local world, normal = GetWorldCoordFromScreenCoord(screenX, screenY)

        if IsRawKeyPressed(Enum.CameraControlKeys.VK_DELETE) then
            -- print("delete pressed")
            if CurrentlySelectedPropLine ~= -1 then
                RemoveLine(CurrentlySelectedPropLine)
                print("Deleted line:", CurrentlySelectedPropLine)
                CurrentlySelectedPropLine = -1
                ToolControls = HudElements.Modes[ToolState]()
            end
        end

        local hover, rect = isCursorOverAnyPoint(vector2(screenX, screenY))

        if hover then
            SetMouseCursorStyle(Enum.MousePointerStyle.ARROW_DIMMED)
        else
            SetMouseCursorStyle(Enum.MousePointerStyle.ARROW)
        end
        
        if IsDisabledControlJustPressed(Enum.PadType.PLAYER_CONTROL, Enum.CameraControlKeys.N) then

            switchToolState(Enum.ToolStates.CREATE, {}, {})
            
        elseif IsDisabledControlJustPressed(Enum.PadType.PLAYER_CONTROL, Enum.CameraControlKeys.LMB) then

            -- print("CLICKED")
            LastClickScreenCoords = vector2(screenX, screenY)

            if hover then
                local pointId = rect.parentPoint
                CurrentlySelectedPropLine = rect.parentLine

                CurrentHeadOfLine = PropLines[CurrentlySelectedPropLine].headOfLine
                print("Selected line:", CurrentlySelectedPropLine)
            else
                CurrentlySelectedPropLine = -1
                print("Deselected lines")
            end
            ToolControls = HudElements.Modes[ToolState]()
        elseif IsDisabledControlJustPressed(Enum.PadType.PLAYER_CONTROL, Enum.CameraControlKeys.TAB) then

            
            if CurrentlySelectedPropLine ~= -1 then
            
                switchToolState(Enum.ToolStates.EDIT, {}, {})
            
            end

        end
    end,
    [Enum.ToolStates.EDIT] = function () -- ## EDIT MODE
        SetMouseCursorStyle(Enum.MousePointerStyle.ARROW)
        
        local screenX = GetDisabledControlNormal(0, 239)
        local screenY = GetDisabledControlNormal(0, 240)
        local world, normal = GetWorldCoordFromScreenCoord(screenX, screenY)
        
        if IsDisabledControlJustPressed(Enum.PadType.PLAYER_CONTROL, Enum.CameraControlKeys.ESC) then

            switchToolState(Enum.ToolStates.OBJECT, {}, {})
            ToolControls = HudElements.Modes[ToolState]()
            
        elseif IsDisabledControlJustPressed(Enum.PadType.PLAYER_CONTROL, Enum.CameraControlKeys.TAB) then

            switchToolState(Enum.ToolStates.OBJECT, {}, {tabpress = true})
            
        elseif IsDisabledControlJustPressed(Enum.PadType.PLAYER_CONTROL, Enum.CameraControlKeys.T) then

            switchToolState(Enum.ToolStates.BUILD, {}, {})
            
        elseif IsDisabledControlJustPressed(Enum.PadType.PLAYER_CONTROL, Enum.CameraControlKeys.G) then

            switchToolState(Enum.ToolStates.MOVE, {}, {})
            
        elseif IsDisabledControlJustPressed(Enum.PadType.PLAYER_CONTROL, Enum.CameraControlKeys.V) then

            switchToolState(Enum.ToolStates.SUBDIVIDE, {}, {})
            
        elseif IsDisabledControlJustPressed(Enum.PadType.PLAYER_CONTROL, Enum.CameraControlKeys.R) then

            switchToolState(Enum.ToolStates.DELETE, {}, {})
            
        elseif IsDisabledControlJustPressed(Enum.PadType.PLAYER_CONTROL, Enum.CameraControlKeys.H) then

            switchToolState(Enum.ToolStates.ROTATION_OVERRIDE, {}, {})
            
        end
        
    end,
    [Enum.ToolStates.CREATE] = function () -- ## CREATE MODE
        

        local screenX = GetDisabledControlNormal(0, 239)
        local screenY = GetDisabledControlNormal(0, 240)
        local world, normal = GetWorldCoordFromScreenCoord(screenX, screenY)
        
        if IsDisabledControlJustPressed(Enum.PadType.PLAYER_CONTROL, Enum.CameraControlKeys.ESC) then

            switchToolState(Enum.ToolStates.OBJECT, {}, {})
            
        end
        
        if CursorWorldImpact then
            SetMouseCursorStyle(Enum.MousePointerStyle.ARROW_PLUS)
            SetPreview(Enum.PreviewModes.POINT)
        else
            SetMouseCursorStyle(Enum.MousePointerStyle.ARROW_DIMMED)
            SetPreview(Enum.PreviewModes.NONE)
        end

        if IsDisabledControlJustPressed(Enum.PadType.PLAYER_CONTROL, Enum.CameraControlKeys.LMB) then

            -- print("CLICKED")

            LastClickScreenCoords = vector2(screenX, screenY)

            if CursorWorldImpact then

                
                -- Start a new line at world pos
                LastClickWorldCoords = CursorWorldPos

                AddTextEntry("ppt_create_choose_entity", "Enter an archetype name:")

                DisplayOnscreenKeyboard(0, "ppt_create_choose_entity", "", "", "", "", "", 256) -- Show the text input box

                while UpdateOnscreenKeyboard() == 0 do Wait(0) end -- Wait for the user to stop editing

                -- This block of code is reached after the user is done editing

                local inputUpdate = UpdateOnscreenKeyboard()

                local input = ""
                if inputUpdate == 1 then -- User hit OK in the text input box
                    input = GetOnscreenKeyboardResult()
                    print("You wrote this in the input box:", input)
                    
                    if not IsModelInCdimage(input) then -- !trying IsModelInCdimage instead of IsModelValid
                        print("Input was invalid, please enter valid archetype name")
                        return
                    else

                        RequestModel(input)
                        while not HasModelLoaded(input) do
                            Wait(0)
                        end

                        if IsModelAVehicle(input) or IsModelAPed(input) then
                            print("Archetype name is a ped or a vehicle - Not allowed")
                            return
                        end

                        SetModelAsNoLongerNeeded(input)
                        print("Success!")
                    end
                elseif inputUpdate == 2 then
                    print("You canceled the input!")
                    return
                else -- -1 or 3
                    print("An error has occurred")
                    return
                end

                local entityNameChosen = input

                -- print("Create new line")
                StartNewLine(entityNameChosen, LastClickWorldCoords, CursorGroundNormal)
                
                print("New Line Created:",CurrentlySelectedPropLine)

                switchToolState(Enum.ToolStates.BUILD, {}, {setPreviewStartToLastClick = true})
            

                PropNameHistory[entityNameChosen] = entityNameChosen
            else
                print("OUT OF RANGE")
                SetMouseCursorStyle(Enum.MousePointerStyle.ARROW_DIMMED)
            end

        end
    end,
    [Enum.ToolStates.BUILD] = function () -- ## ADD MODE
        
        local screenX = GetDisabledControlNormal(0, 239)
        local screenY = GetDisabledControlNormal(0, 240)
        local world, normal = GetWorldCoordFromScreenCoord(screenX, screenY)

        if CursorWorldImpact then
            CalculateDistOfPreviewLine(1)
            SetPreview(Enum.PreviewModes.LINEANDPOINT)
            SetMouseCursorStyle(Enum.MousePointerStyle.ARROW_PLUS)
        else
            SetPreview(Enum.PreviewModes.NONE)
            SetMouseCursorStyle(Enum.MousePointerStyle.ARROW_DIMMED)
        end

        if IsDisabledControlJustPressed(Enum.PadType.PLAYER_CONTROL, Enum.CameraControlKeys.ESC) then

            switchToolState(Enum.ToolStates.EDIT, {}, {})
            
        elseif IsDisabledControlJustPressed(Enum.PadType.PLAYER_CONTROL, Enum.CameraControlKeys.R) then

            switchToolState(Enum.ToolStates.DELETE, {}, {})
            
        elseif IsDisabledControlJustPressed(Enum.PadType.PLAYER_CONTROL, Enum.CameraControlKeys.V) then

            switchToolState(Enum.ToolStates.SUBDIVIDE, {}, {})
            
        elseif IsDisabledControlJustPressed(Enum.PadType.PLAYER_CONTROL, Enum.CameraControlKeys.G) then

            switchToolState(Enum.ToolStates.MOVE, {}, {})
            
        elseif IsDisabledControlJustPressed(Enum.PadType.PLAYER_CONTROL, Enum.CameraControlKeys.H) then

            switchToolState(Enum.ToolStates.ROTATION_OVERRIDE, {}, {})
            
        end

        if IsDisabledControlJustPressed(Enum.PadType.PLAYER_CONTROL, Enum.CameraControlKeys.LMB) then
            -- print("CLICKED")

            LastClickScreenCoords = vector2(screenX, screenY)
            if CursorWorldImpact then

                LastClickWorldCoords = CursorWorldPos
                Previews.Line.startPos = LastClickWorldCoords

                local youngerSibling = PropLines[CurrentlySelectedPropLine].headOfLine
                -- print("control-handler.lua:Build",PropLines)
                -- print("control-handler.lua:Build",PropLines[CurrentlySelectedPropLine])
                -- print("control-handler.lua:Build",PropLines[CurrentlySelectedPropLine].pointCount)
                -- print("control-handler.lua:Build",youngerSibling)
                AddPointToLine(CurrentlySelectedPropLine, LastClickWorldCoords, CursorGroundNormal, youngerSibling)
                -- print(CurrentlySelectedPropLine, LastClickWorldCoords, youngerSibling)
                Previews.Line.startPos = LastClickWorldCoords
                print("Added point to line:", CurrentlySelectedPropLine)
            else
                print("OUT OF RANGE")
            end
        end
    end,
    [Enum.ToolStates.MOVE] = function () -- ## MOVE MODE
    
        local screenX = GetDisabledControlNormal(0, 239)
        local screenY = GetDisabledControlNormal(0, 240)
        local world, normal = GetWorldCoordFromScreenCoord(screenX, screenY)

        -- print(EditSelection)
        if EditSelection ~= -1 then
                
            if CursorWorldImpact then
                CalculateDistOfPreviewLine(3)
                SetMouseCursorStyle(Enum.MousePointerStyle.HAND_GRAB)
                
                -- print(CurrentlySelectedPropLine, EditSelection, CursorWorldPos)
                --* PREVIEW POSITION
                EditPoint(CurrentlySelectedPropLine, EditSelection, CursorWorldPos, CursorGroundNormal)
                -- print("MOVED POINT:",EditSelection)
                if IsDisabledControlJustPressed(Enum.PadType.PLAYER_CONTROL, Enum.CameraControlKeys.LMB) then
                    --* APPLY NEW POSITION
                    EditSelection = -1
                    SetMouseCursorStyle(Enum.MousePointerStyle.ARROW)
                    -- print(EditSelection)
                elseif IsDisabledControlJustPressed(Enum.PadType.PLAYER_CONTROL, Enum.CameraControlKeys.RMB) then
                    --* CANCEL MOVE
                    EditPoint(CurrentlySelectedPropLine, EditSelection, MoveReturnPos, MoveReturnNormal)
                    EditSelection = -1
                    SetMouseCursorStyle(Enum.MousePointerStyle.ARROW)
                    -- print(EditSelection)
                end
                
            else
                -- print("OUT OF RANGE")
                SetMouseCursorStyle(Enum.MousePointerStyle.ARROW_DIMMED)
            end
        else
            SetPreview(Enum.PreviewModes.NONE)
            local hover, rect = isCursorOverAPointInSelectedLine(vector2(screenX, screenY))
            
            if hover then
                SetMouseCursorStyle(Enum.MousePointerStyle.HAND_OPEN)
            else
                SetMouseCursorStyle(Enum.MousePointerStyle.ARROW)
            end

            if IsDisabledControlJustPressed(Enum.PadType.PLAYER_CONTROL, Enum.CameraControlKeys.LMB) then

                LastClickScreenCoords = vector2(screenX, screenY)

                if hover then

                    EditSelection = rect.parentPoint

                    --* START MOVING POINT
                    -- print(EditSelection)
                    MoveReturnPos, MoveReturnNormal = GetMoveReturnDataForPoint(CurrentlySelectedPropLine, EditSelection)
                    -- print(EditSelection)
                    SetMouseCursorStyle(Enum.MousePointerStyle.HAND_GRAB)

                    

                    local point = PropLines[CurrentlySelectedPropLine].points[EditSelection]

                    if point.olderSibling ~= -1 and point.youngerSibling ~= -1 then
                        Previews.Line.startPos = PropLines[CurrentlySelectedPropLine].points[point.youngerSibling].PosAndRotData.pointPosition
                        Previews.Line2.startPos = PropLines[CurrentlySelectedPropLine].points[point.olderSibling].PosAndRotData.pointPosition
                        SetPreview(Enum.PreviewModes.SUBDPREVIEW)
                    elseif point.olderSibling ~= -1 then
                        Previews.Line.startPos = PropLines[CurrentlySelectedPropLine].points[point.olderSibling].PosAndRotData.pointPosition
                        SetPreview(Enum.PreviewModes.LINEANDPOINT)
                    elseif point.youngerSibling ~= -1 then
                        Previews.Line.startPos = PropLines[CurrentlySelectedPropLine].points[point.youngerSibling].PosAndRotData.pointPosition
                        SetPreview(Enum.PreviewModes.LINEANDPOINT)
                    end

                    
                else
                    print("Missed")
                end
            end
        end

        if IsDisabledControlJustPressed(Enum.PadType.PLAYER_CONTROL, Enum.CameraControlKeys.ESC) then

            switchToolState(Enum.ToolStates.EDIT, {}, {})
            
        elseif IsDisabledControlJustPressed(Enum.PadType.PLAYER_CONTROL, Enum.CameraControlKeys.R) then

            switchToolState(Enum.ToolStates.DELETE, {}, {})
            
        elseif IsDisabledControlJustPressed(Enum.PadType.PLAYER_CONTROL, Enum.CameraControlKeys.V) then

            switchToolState(Enum.ToolStates.SUBDIVIDE, {}, {})
            
        elseif IsDisabledControlJustPressed(Enum.PadType.PLAYER_CONTROL, Enum.CameraControlKeys.T) then

            switchToolState(Enum.ToolStates.BUILD, {}, {})
            
        elseif IsDisabledControlJustPressed(Enum.PadType.PLAYER_CONTROL, Enum.CameraControlKeys.H) then

            switchToolState(Enum.ToolStates.ROTATION_OVERRIDE, {}, {})
            
        end
    end,
    [Enum.ToolStates.SUBDIVIDE] = function () -- ## SUBDIVIDE MODE

        SetMouseCursorStyle(Enum.MousePointerStyle.ARROW)
        local screenX = GetDisabledControlNormal(0, 239)
        local screenY = GetDisabledControlNormal(0, 240)
        local world, normal = GetWorldCoordFromScreenCoord(screenX, screenY)

        if CursorWorldImpact then
            SetPreview(Enum.PreviewModes.POINT)
            local closestPair = GetPointPairPosIsInside(CursorWorldPos)
            if closestPair ~= -1 then
                
                SetMouseCursorStyle(Enum.MousePointerStyle.ARROW_PLUS)
                SetPreview(Enum.PreviewModes.SUBDPREVIEW)
                CalculateDistOfPreviewLine(3)

                local olderSibling = closestPair.lastPoint
                local youngerSibling = closestPair.firstPoint

                Previews.Line.startPos = youngerSibling.pos
                Previews.Line2.startPos = olderSibling.pos

                if IsDisabledControlJustPressed(Enum.PadType.PLAYER_CONTROL, Enum.CameraControlKeys.LMB) then
                    -- print("CLICKED")

                    LastClickScreenCoords = vector2(screenX, screenY)
                    LastClickWorldCoords = CursorWorldPos

                    AddPointInBetween(CurrentlySelectedPropLine, LastClickWorldCoords, CursorGroundNormal, youngerSibling.id, olderSibling.id)
                end
            end
        
                
            if IsDisabledControlJustPressed(Enum.PadType.PLAYER_CONTROL, Enum.CameraControlKeys.ESC) then

                switchToolState(Enum.ToolStates.EDIT, {}, {})
                
            elseif IsDisabledControlJustPressed(Enum.PadType.PLAYER_CONTROL, Enum.CameraControlKeys.T) then

                switchToolState(Enum.ToolStates.BUILD, {}, {})
                
            elseif IsDisabledControlJustPressed(Enum.PadType.PLAYER_CONTROL, Enum.CameraControlKeys.R) then

                switchToolState(Enum.ToolStates.DELETE, {}, {})
                
            elseif IsDisabledControlJustPressed(Enum.PadType.PLAYER_CONTROL, Enum.CameraControlKeys.H) then

                switchToolState(Enum.ToolStates.ROTATION_OVERRIDE, {}, {})
                
            elseif IsDisabledControlJustPressed(Enum.PadType.PLAYER_CONTROL, Enum.CameraControlKeys.G) then

                switchToolState(Enum.ToolStates.MOVE, {}, {})

            end

        else
            SetPreview(Enum.PreviewModes.NONE)

            if IsDisabledControlJustPressed(Enum.PadType.PLAYER_CONTROL, Enum.CameraControlKeys.LMB) then
                print("OUT OF RANGE")
            end
        end

    end,
    [Enum.ToolStates.DELETE] = function () -- ## DELETE MODE
    
        local screenX = GetDisabledControlNormal(0, 239)
        local screenY = GetDisabledControlNormal(0, 240)
        local world, normal = GetWorldCoordFromScreenCoord(screenX, screenY)



        local hover, rect = isCursorOverAPointInSelectedLine(vector2(screenX, screenY))

        if hover then
            SetMouseCursorStyle(Enum.MousePointerStyle.ARROW_MINUS)
        else
            SetMouseCursorStyle(Enum.MousePointerStyle.ARROW)
        end

        if IsDisabledControlJustPressed(Enum.PadType.PLAYER_CONTROL, Enum.CameraControlKeys.LMB) then

            LastClickScreenCoords = vector2(screenX, screenY)
            if hover then

                RemovePoint(CurrentlySelectedPropLine, rect.parentPoint)
                
            else
                print("missed")
            end
        end
        if IsDisabledControlJustPressed(Enum.PadType.PLAYER_CONTROL, Enum.CameraControlKeys.ESC) then
            -- print("Escape Pressed")
            switchToolState(Enum.ToolStates.EDIT, {}, {})

        elseif IsDisabledControlJustPressed(Enum.PadType.PLAYER_CONTROL, Enum.CameraControlKeys.V) then

            switchToolState(Enum.ToolStates.SUBDIVIDE, {}, {})

        elseif IsDisabledControlJustPressed(Enum.PadType.PLAYER_CONTROL, Enum.CameraControlKeys.T) then
            
            switchToolState(Enum.ToolStates.BUILD, {}, {})
            
        elseif IsDisabledControlJustPressed(Enum.PadType.PLAYER_CONTROL, Enum.CameraControlKeys.G) then

            switchToolState(Enum.ToolStates.MOVE, {}, {})
            
        elseif IsDisabledControlJustPressed(Enum.PadType.PLAYER_CONTROL, Enum.CameraControlKeys.H) then

            switchToolState(Enum.ToolStates.ROTATION_OVERRIDE, {}, {})

        end
    end,
    [Enum.ToolStates.ROTATION_OVERRIDE] = function () -- ## ROTATION OVERRIDE MODE
    
        SetMouseCursorStyle(Enum.MousePointerStyle.ARROW)
        local screenX = GetDisabledControlNormal(0, 239)
        local screenY = GetDisabledControlNormal(0, 240)
        local world, normal = GetWorldCoordFromScreenCoord(screenX, screenY)

        -- print(EditSelection)
        if EditSelection ~= -1 then
            if CursorWorldImpact then
                SetMouseCursorStyle(Enum.MousePointerStyle.HAND_GRAB)

                SetPreview(Enum.PreviewModes.LINEANDPOINT)

                -- print(CurrentlySelectedPropLine, EditSelection, CursorWorldPos)

                local point = PropLines[CurrentlySelectedPropLine].points[EditSelection]
                local dir = cm_Dir_vec3(point.PosAndRotData.pointPosition, CursorWorldPos)

                SetPointRotationOverride(CurrentlySelectedPropLine, EditSelection, dir)
                -- print("MOVED POINT:",EditSelection)
                if IsDisabledControlJustPressed(Enum.PadType.PLAYER_CONTROL, Enum.CameraControlKeys.LMB) then
                    EditSelection = -1
                    SetPreview(Enum.PreviewModes.NONE)
                    SetMouseCursorStyle(Enum.MousePointerStyle.ARROW)
                    -- print(EditSelection)
                elseif IsDisabledControlJustPressed(Enum.PadType.PLAYER_CONTROL, Enum.CameraControlKeys.RMB) then
                    SetPointRotationOverride(CurrentlySelectedPropLine, EditSelection, RotateReturnDir, RotateReturnWasntOverridden)
                    EditSelection = -1
                    SetPreview(Enum.PreviewModes.NONE)
                    SetMouseCursorStyle(Enum.MousePointerStyle.ARROW)
                    -- print(EditSelection)
                end
                
            else
                print("OUT OF RANGE")
                SetMouseCursorStyle(Enum.MousePointerStyle.ARROW_DIMMED)
            end
        else
            local hover, rect = isCursorOverAPointInSelectedLine(vector2(screenX, screenY))
            
            if hover then
                SetMouseCursorStyle(Enum.MousePointerStyle.HAND_OPEN)
            else
                SetMouseCursorStyle(Enum.MousePointerStyle.ARROW)
            end

            if IsDisabledControlJustPressed(Enum.PadType.PLAYER_CONTROL, Enum.CameraControlKeys.LMB) then

                LastClickScreenCoords = vector2(screenX, screenY)
                if hover then
                    EditSelection = rect.parentPoint
                    -- print(EditSelection)
                    RotateReturnWasntOverridden, RotateReturnDir = GetRotateReturnDataForPoint(CurrentlySelectedPropLine, EditSelection)

                    SetMouseCursorStyle(Enum.MousePointerStyle.HAND_GRAB)
                    Previews.Line.startPos = PropLines[CurrentlySelectedPropLine].points[EditSelection].PosAndRotData.pointPosition
                    SetPreview(Enum.PreviewModes.LINEANDPOINT)

                    -- print(EditSelection)
                    
                else
                    print("missed")
                end
            end
        end

        if IsDisabledControlJustPressed(Enum.PadType.PLAYER_CONTROL, Enum.CameraControlKeys.ESC) then
            -- print("Escape Pressed")

            switchToolState(Enum.ToolStates.EDIT, {}, {})

        elseif IsDisabledControlJustPressed(Enum.PadType.PLAYER_CONTROL, Enum.CameraControlKeys.BACKSPACE) then

            SetPointRotationOverride(CurrentlySelectedPropLine, EditSelection, RotateReturnDir, true)

            if EditSelection ~= -1 then

                SetPointRotationOverride(CurrentlySelectedPropLine, EditSelection, RotateReturnDir, true)

                EditSelection = -1
                SetPreview(Enum.PreviewModes.NONE)
                SetMouseCursorStyle(Enum.MousePointerStyle.ARROW)
            end

        elseif IsDisabledControlJustPressed(Enum.PadType.PLAYER_CONTROL, Enum.CameraControlKeys.R) then

            switchToolState(Enum.ToolStates.DELETE, {}, {})

        elseif IsDisabledControlJustPressed(Enum.PadType.PLAYER_CONTROL, Enum.CameraControlKeys.V) then

            switchToolState(Enum.ToolStates.SUBDIVIDE, {}, {})

        elseif IsDisabledControlJustPressed(Enum.PadType.PLAYER_CONTROL, Enum.CameraControlKeys.T) then
            
            switchToolState(Enum.ToolStates.BUILD, {}, {})
            
        elseif IsDisabledControlJustPressed(Enum.PadType.PLAYER_CONTROL, Enum.CameraControlKeys.G) then

            switchToolState(Enum.ToolStates.MOVE, {}, {})
            
        end
    end,
}



-- * ////////////// ENVIRONMENT //////////////
--* Set time, clouds, timecycle
local function setDevWeatherThisFrame()
    NetworkOverrideClockTime(0, 0, 0)
end
local function startDevWeather()
    SetDistantCarsEnabled(false)
    SetCloudsAlpha(0.0)
    SetOverrideWeather("CLEAR")
    SetExtraTimecycleModifier(Enum.TimeCycles.DEV_WEATHERFX.name)
end
local function stopDevWeather()
    SetDistantCarsEnabled(true)
    SetCloudsAlpha(1.0)
    ClearOverrideWeather()
    ClearExtraTimecycleModifier()
    NetworkClearClockTimeOverride()
end



-- * ////////////// CONTROL THREAD MANAGEMENT //////////////

local controlThreadSwitch = 0
local controlThreadStatus = 0

local buildState = Enum.ToolStates.BUILD
local createState = Enum.ToolStates.CREATE
local moveState = Enum.ToolStates.MOVE

local stateBeforeMove = 0

local ControlThreadFunction = function ()
    controlThreadStatus = 1
    print("Thread Started")
    SetCameraState(ClientCameraStateOnClose)
    
    print("Loop Entered")
    -- print(SetPreview)
    -- print(Enum.PreviewModes.POINT)
    -- print(Enum.PreviewModes)
    SetPreview(Enum.PreviewModes.POINT)
    ToolControls = HudElements.Modes[ToolState]()
    startDevWeather()
    
    while controlThreadSwitch == 1 do
        setDevWeatherThisFrame()
        -- usingController = (IsUsingKeyboard(0) == false)

        DisableAllControlActions(Enum.PadType.PLAYER_CONTROL)
        DisableAllControlActions(Enum.PadType.CAMERA_CONTROL)

        SetMouseCursorThisFrame()
        
        local screenX = GetDisabledControlNormal(0, 239)
        local screenY = GetDisabledControlNormal(0, 240)
        local world, normal = GetWorldCoordFromScreenCoord(screenX, screenY)

        -- DrawLine(world+vector3(10.0,0.0,0.0), testEnd, 255, 0, 0, 255)
        --     DrawSphere(testEnd, 0.5, 0, 0, 255, 1.0)


        --# Deemed unnecessary
        -- if IsDisabledControlPressed(Enum.PadType.PLAYER_CONTROL, Enum.CameraControlKeys.RMB) then
        --     -- Check mouse position
        --     stateBeforeMove = (ToolState ~= Enum.ToolStates.MOVE) and ToolState or stateBeforeMove
        --     ToolState = Enum.ToolStates.MOVE
        -- else
        --     ToolState = (ToolState == Enum.ToolStates.MOVE) and stateBeforeMove or ToolState
        -- end

        toolStateControls[ToolState]()




        -- if usingController then
        --     ControllerCameraControls()
        -- else
        CurrentCameraControlFunction(GetFrameTime())
        Render()

        -- print("control-handler.lua",ClientCamCoords)
        -- end
        
        
        Wait(0)
    end
    stopDevWeather()
    print("Loop Exited")
    EnableAllControlActions(Enum.PadType.PLAYER_CONTROL)
    EnableAllControlActions(Enum.PadType.CAMERA_CONTROL)
    controlThreadStatus = 0

    ClientCameraStateOnClose = ClientCameraState
    ClientCameraState = Enum.ClientCameraStates.GAMEPLAY
    SetCameraState(ClientCameraState)
    print("Thread Ended")
end

local StartControlThread = function (startCameraType)
    controlThreadSwitch =  1
    -- ClientCameraState = startCameraType
    CreateThread(ControlThreadFunction) 
end

local KillControlThread = function ()
    controlThreadSwitch = 0
end


--* ////////////// HANDLES LOCAL EVENTS FROM MAIN.LUA //////////////
--* Mostly function calls
RegisterNetEvent("postplace-kjghKJHGgasd:func", function (data)
    local action = data.action
    -- print("control-handler.lua", action)
    if not DoesClientHavePerms() then
        return
    end
    -- print("Does have perms")
    if action == "ppt_opentool" then
        -- . Add shit here
        if controlThreadSwitch ~= 1 then
            StartControlThread(ClientCameraStateOnClose)
        end
        ToolEnabled = true
    elseif action == "ppt_closetool" then
        -- . Add shit here
        KillControlThread()
        ToolEnabled = false
    end
end)



-- * ////////////// LINE COMMANDS //////////////

RegisterCommand("SetLineWobble", function (source, args)
    if CurrentlySelectedPropLine == -1 then
        return
    end
    local choice = tonumber(args[1])
    if type(choice) == "number" then
        SetLineRotationVariation(CurrentlySelectedPropLine, choice)
    else
        print("PLEASE ENTER VALID NUMBER")
    end

end, false)

RegisterCommand("SetLineRotationOffset", function (source, args)
    if CurrentlySelectedPropLine == -1 then
        return
    end
    local choice = tonumber(args[1])
    if type(choice) == "number" then
        SetLineRotationOffset(CurrentlySelectedPropLine, choice)
    else
        print("PLEASE ENTER VALID NUMBER")
    end

end, false)

RegisterCommand("SetLineVerticalOffset", function (source, args)
    if CurrentlySelectedPropLine == -1 then
        return
    end
    local choice = tonumber(args[1])
    if type(choice) == "number" then
        SetLineVerticalOffset(CurrentlySelectedPropLine, choice)
    else
        print("PLEASE ENTER VALID NUMBER")
    end

end, false)

RegisterCommand("SetLineReverse", function (source, args)
    if CurrentlySelectedPropLine == -1 then
        return
    end
    local choice = args[1]

    if choice == "1" then
        choice = "true"
    elseif choice == "0" then
        choice = "false"
    end
    
    choice = string.lower(choice)
    if choice == "true" or choice == "false" then
        local bool = choice == "true" and true or false
        SetLineReverseRotation(CurrentlySelectedPropLine, bool)
    else
        print("PLEASE ENTER VALID RESPONSE ( 1/0 or true/false )")
    end

end, false)

RegisterCommand("SetLineRandomRotation", function (source, args)
    if CurrentlySelectedPropLine == -1 then
        return
    end
    local choice = args[1]

    if choice == "1" then
        choice = "true"
    elseif choice == "0" then
        choice = "false"
    end
    
    choice = string.lower(choice)
    if choice == "true" or choice == "false" then
        local bool = choice == "true" and true or false
        SetLineRandomRotation(CurrentlySelectedPropLine, bool)
    else
        print("PLEASE ENTER VALID RESPONSE ( 1/0 or true/false )")
    end

end, false)

RegisterCommand("SetLineAlignToNormal", function (source, args)
    if CurrentlySelectedPropLine == -1 then
        return
    end
    local choice = args[1]

    if choice == "1" then
        choice = "true"
    elseif choice == "0" then
        choice = "false"
    end
    
    choice = string.lower(choice)
    if choice == "true" or choice == "false" then
        local bool = choice == "true" and true or false
        SetLineAlignToNormal(CurrentlySelectedPropLine, bool)
    else
        print("PLEASE ENTER VALID RESPONSE ( 1/0 or true/false )")
    end

end, false)


-- TODO: Show line settings (LineAlignToNormal = false, SetLineRandomRotation = true, etc)