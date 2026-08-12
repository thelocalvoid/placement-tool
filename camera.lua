




CurrentCameraControlFunction = function() end
local CurrentCameraControllerFunction
local cameraControlThreadSwitch = 0
local cameraControlThreadStatus = 0


-- * ////////////// CAMERA STATS //////////////
local usingCustomCamera = false
local currentCamera = -1
local currentCameraPos = vector3(0.0,0.0,0.0)
local currentCameraFov = 50.0


-- * ////////////// MOUSE TUNING //////////////
--* SMOOTHING
local mouseSmoothingFunction
-- Raw (1)
local ms1_mouseSensitivity = 0.15
local ms1_modifier = 45
-- Exponential (2)
local ms2_smoothedPitch = 0 -- Variable
local ms2_smoothedYaw = 0 -- Variable
local ms2_smoothingStrength = 0.15 -- lower = smoother, higher = more responsive
-- Velocity Based (3)
local ms3_PitchVel = 0.0 -- Variable
local ms3_YawVel = 0.0 -- Variable
local ms3_accel = 0.2 -- lower = slower acceleration, higher = faster acceleration
local ms3_damping = 0.8 -- lower = faster decelerating, higher = slower decelerating


-- * ////////////// MOVEMENT TUNING //////////////
local usingController = false

local defaultVelocity = 50.0
local velocity = defaultVelocity

local minBaseVelocity = 0.005
local maxBaseVelocity = 2.0
local scrollVelocityStep = 0.005

local velocityScale = 1.0
local velocityScaleMin = 0.05
local velocityScaleMax = 10.0
local velocityScaleStep = 0.2

local boostedVelocityMultiplier = 2.0
local DefaultVelocityMultiplier = 1.0

-- *  SMOOTHING
local movementSmoothingFunction

local vs3_FBVel = 0.0
local vs3_LRVel = 0.0
local vs3_UDVel = 0.0
local vs3_accel = 0.1 -- lower = slower acceleration, higher = faster acceleration
local vs3_damping = 0.9 -- lower = faster decelerating, higher = slower decelerating



-- * ////////////// SMOOTHING FUNCTIONS //////////////
--* Mouse smoothing options
local MouseSmoothingFunctions = {
    {
        name = "Raw Input (1)",
        func = function (UD, LR)
            
            
            return ((ms1_mouseSensitivity * ms1_modifier) * UD), ((ms1_mouseSensitivity * ms1_modifier) * LR)
        end
    },
    {
        name = "Exponential Smoothing (2)",
        func = function (UD, LR, keyboard)
            ms2_smoothedPitch = ms2_smoothedPitch + (UD - ms2_smoothedPitch) * ms2_smoothingStrength
            ms2_smoothedYaw = ms2_smoothedYaw + (LR - ms2_smoothedYaw) * ms2_smoothingStrength

            -- print(ms2_smoothedPitch * (((1-keyboard) * 2.5) + ((keyboard) * 6)), ms2_smoothedYaw * (((1-keyboard) * 2.5) + ((keyboard) * 6)))
            -- (((1-keyboard) * 2.5) + ((keyboard) * 6))
            return ms2_smoothedPitch * (((1-keyboard) * 2.5) + ((keyboard) * 9)), ms2_smoothedYaw * (((1-keyboard) * 2.5) + ((keyboard) * 9))
        end
    },
    {
        name = "Velocity Based Smoothing (3)",
        func = function (UD, LR, keyboard)
            ms3_PitchVel = ms3_PitchVel + (UD * ms3_accel)
            ms3_YawVel = ms3_YawVel + (LR * ms3_accel)

            ms3_PitchVel = ms3_PitchVel * ms3_damping
            ms3_YawVel = ms3_YawVel * ms3_damping

            return ms3_PitchVel * (((1-keyboard) * 2.5) + ((keyboard) * 6)), ms3_YawVel * (((1-keyboard) * 2.5) + ((keyboard) * 6))

        end
    }

}
--* Movement smoothing options
local MovementSmoothFunctions = {
    [1] = {
        name = "Raw Input",
        func = function (FB, LR, UD)
            return FB, LR, UD

        end
    },
    [3] = {
        name = "Velocity Based Smoothing",
        func = function (FB, LR, UD)
            vs3_FBVel = vs3_FBVel + (FB * vs3_accel)
            vs3_LRVel = vs3_LRVel + (LR * vs3_accel)
            vs3_UDVel = vs3_UDVel + (UD * vs3_accel)

            vs3_FBVel = vs3_FBVel * vs3_damping
            vs3_LRVel = vs3_LRVel * vs3_damping
            vs3_UDVel = vs3_UDVel * vs3_damping

            return vs3_FBVel, vs3_LRVel, vs3_UDVel

        end
    }
}


-- * ////////////// MOVEMENT FUNCTIONS //////////////
-- * Functions for forward and horizontal movement
local LateralFunctions = {
    [1] = {
        name = "lateralRelativeToWorld",
        func = function (_, _, fDot, rDot)
            local worldFwd = vector3(0.0,1.0,0.0)
            local worldRight = vector3(1.0,0.0,0.0)
            return ((worldFwd * fDot) + (worldRight * rDot))
        end
    },
    [2] = {
        name = "lateralRelativeToCam",
        func = function (camFwd, camRight, fDot, rDot)
            return ((camFwd * fDot) + (camRight * rDot))
        end
    },
    [3] = {
        name = "lateralRelativeToCamHeading",
        func = function (camFwd, camRight, fDot, rDot)
            local fXY = vector3(camFwd.x, camFwd.y, 0.0)
            local dist = math.sqrt(fXY.x * fXY.x + fXY.y * fXY.y)
            local fLevel = fXY * (1 / dist)

            return ((fLevel * fDot) + (camRight * rDot))
        end
    },
}

-- * Functions for vertical movement
local VerticalFunctions = {
    [1] = {
        name = "updownRelativeToWorld",
        func = function (_, uDot)
            local worldUp = vector3(0.0,0.0,1.0)
            return worldUp * uDot
        end
    },
    [2] = {
        name = "updownRelativeToCam",
        func = function (camUp, uDot)
            return camUp * uDot
        end
    },
}



mouseSmoothingFunction = MouseSmoothingFunctions[2].func -- Exponential (2) by default

movementSmoothingFunction = MovementSmoothFunctions[3].func

local verticalFunction = VerticalFunctions[1].func

local lateralFunction = LateralFunctions[3].func

local translate = function (camFwd, camRight, camUp, fDot, rDot, uDot)
    return (lateralFunction(camFwd, camRight, fDot, rDot) + verticalFunction(camUp, uDot))
end


-- see CreateCustomTimeCycles()

-- TO CHECK WHEN ADDING CAMERA TYPE
-- eCameraTypeControls
-- GetVectorsFor
-- executeBefore, executeAfter
-- Consider UpdateCamera()
-- And register a command

-- Stores camera positions, rotations and other similar data
local cameraStateData = {

}


-- * ////////////// FOCUS //////////////
local focusSet = false

function SetFocusPosition(vec3)
    SetFocusPosAndVel(vec3.x, vec3.y, vec3.z, 0.0, 0.0, 0.0)
end

local function constrainToMapBounds(coords, mode)

    local newCoords = coords

    local xAbs = math.abs(newCoords.x)
    if xAbs > 5000 then 
        newCoords = vector3(((newCoords.x / xAbs) * 5000.0), newCoords.y, newCoords.z)
    end

    local yAbs = math.abs(newCoords.y)
    if yAbs > 9000 then 
        newCoords = vector3(newCoords.x, ((newCoords.y / yAbs) * 9000.0), newCoords.z)
    end

    if newCoords.z < -500 then
        newCoords = vector3(newCoords.x, newCoords.y, -500.0) 
    elseif newCoords.z > (4000 + (mode * 10000)) then
        newCoords = vector3(newCoords.x, newCoords.y, 4000.0) 
    end

    return newCoords
end


local CameraTypeControls = {

    [Enum.ClientCameraStates.GAMEPLAY] = function (delta)
        
    end,
    [Enum.ClientCameraStates.MAP2D] = function (delta)

        HideHudAndRadarThisFrame()

        local r, f, u, pos = GetCamMatrix(CurrentCameraId)
        local n = vector3(0.0,1.0,0.0)
        local e = vector3(1.0,0.0,0.0)

        local velocityMultiplier = IsDisabledControlPressed(Enum.PadType.PLAYER_CONTROL, 21) and boostedVelocityMultiplier or DefaultVelocityMultiplier


        local zTop = GetHeightmapTopZForPosition(pos.x, pos.y)
        local zBottom = GetHeightmapBottomZForPosition(pos.x, pos.y)
        local dist = zTop - zBottom
        local zMiddle = zBottom + dist/2

        -- print(zMiddle)

        local zNew = pos.z
        zNew = IsDisabledControlJustPressed(Enum.PadType.PLAYER_CONTROL, 16) and zNew + 500 or zNew
        zNew = IsDisabledControlJustPressed(Enum.PadType.PLAYER_CONTROL, 17) and zNew - 500 or zNew

        if zNew > 9000 then
            zNew = 9000
        end
        if zNew - 300.0 < zBottom then
            zNew = zBottom + 300
            -- print("CLIPPED")
        end

        local zoomPercent = (zNew --[[  - 300 - zBottom ]]) / (9000 --[[  - 300 - zBottom ]])
        -- print(zoomPercent)


        local wPower = IsRawKeyDown(Enum.CameraControlKeys.W) and 1 or 0
        local sPower = IsRawKeyDown(Enum.CameraControlKeys.S) and 1 or 0
        local NDot = wPower - sPower

        local aPower = IsRawKeyDown(Enum.CameraControlKeys.A) and 1 or 0
        local dPower = IsRawKeyDown(Enum.CameraControlKeys.D) and 1 or 0
        local EDot = dPower - aPower

        local newFov = 5.0 + (20 * (zoomPercent * zoomPercent)) -- base on zoom
        
        local finalVelocity = (50.0 + (2500 * (zoomPercent * zoomPercent * zoomPercent))) * velocityMultiplier-- based on zoom

        local nVelocity = n * NDot
        local eVelocity = e * EDot

        -- local newPos = vector3(pos.x, pos.y, zNew) --! temp

        local newPosXY = pos + (nVelocity + eVelocity) * (finalVelocity * delta)
        local newPos = vector3(newPosXY.x, newPosXY.y, zNew)

        newPos = constrainToMapBounds(newPos, 1)

        ClientCamCoords = vec3(newPos.x, newPos.y, newPos.z)
        SetCamCoord(CurrentCameraId, newPos.x, newPos.y, newPos.z)
        SetCamFov(CurrentCameraId, newFov)
        -- local scale = GetLodscale()

        -- local lod = 30.0 - (24.0 * (zoomPercent * zoomPercent))

        -- OverrideLodscaleThisFrame(lod) -- ! MAY CAUSE CRASHES
        
        SetFocusPosAndVel(newPos.x, newPos.y, (zoomPercent * newPos.z) + ((1.0 - zoomPercent) * zMiddle), 0.0, 0.0, 0.0)

        
        -- print(zNew)
        -- print(lod)
        -- print(scale)
        -- print(newFov)
        -- print(finalVelocity)

    end,
    [Enum.ClientCameraStates.MAP3D] = function (delta)

        local velocityMultiplier = IsDisabledControlPressed(Enum.PadType.PLAYER_CONTROL, 21) and boostedVelocityMultiplier or DefaultVelocityMultiplier
        local RCLICK = IsDisabledControlPressed(Enum.PadType.PLAYER_CONTROL, 25)

        local wPower = IsRawKeyDown(Enum.CameraControlKeys.W) and 1 or 0
        local sPower = IsRawKeyDown(Enum.CameraControlKeys.S) and 1 or 0
        local fDot = wPower - sPower

        local aPower = IsRawKeyDown(Enum.CameraControlKeys.A) and 1 or 0
        local dPower = IsRawKeyDown(Enum.CameraControlKeys.D) and 1 or 0
        local rDot = dPower - aPower

        local ePower = IsRawKeyDown(Enum.CameraControlKeys.E) and 1 or 0
        local qPower = IsRawKeyDown(Enum.CameraControlKeys.Q) and 1 or 0
        local uDot = ePower - qPower


        
        HideHudAndRadarThisFrame()
        local r, f, u, pos = GetCamMatrix(CurrentCameraId)

        local fXY = vector3(f.x, f.y, 0.0)
        local dist = math.sqrt(fXY.x * fXY.x + fXY.y * fXY.y)
        local fLevel = fXY * (1 / dist)

        local up = vector3(0.0, 0.0, 1.0)

        local camRot = GetCamRot(CurrentCameraId, Enum.RotationOrder.ROT_ZXY)
        local yaw = camRot.z

        local finalVelocity = (velocity * velocityScale) * velocityMultiplier

        local fVelocity = fLevel * fDot
        local hVelocity = r * rDot
        local vVelocity = up * uDot

        local newPos = pos + (fVelocity + hVelocity + vVelocity) * (finalVelocity * delta)

        newPos = constrainToMapBounds(newPos, 0)

        ClientCamCoords = vec3(newPos.x, newPos.y, newPos.z)
        SetCamCoord(CurrentCameraId, newPos.x, newPos.y, newPos.z)

        if RCLICK then
            -- * ROTATION

            -- UP +
            -- DOWN -
            -- RIGHT +
            -- LEFT -
            -- (IF INVERTED)
            local mouseUDNormal = GetDisabledControlNormal(Enum.PadType.CAMERA_CONTROL, 2) * -1
            local mouseLRNormal = GetDisabledControlNormal(Enum.PadType.CAMERA_CONTROL, 1) * -1

            -- print(mouseLRNormal, mouseUDNormal)

            local currentRot = GetCamRot(CurrentCameraId, Enum.RotationOrder.ROT_ZXY)

            local PitchDelta, YawDelta = mouseSmoothingFunction(mouseUDNormal, mouseLRNormal, 1)

            local rotX = currentRot.x
            local newPitch = rotX + PitchDelta
            local rotZ = currentRot.z
            local newYaw = rotZ + YawDelta
            
            -- Clamp new pitch value to avoid flipping bug
            if newPitch > 89.9 then
                newPitch = 89.9
            end
            if newPitch < -89.9 then
                newPitch = -89.9
            end

            -- Hardcode y value to 0.0 - We don't want rolling of the camera
            SetCamRot(CurrentCameraId, newPitch, 0.0, newYaw, Enum.RotationOrder.ROT_ZXY)
        end

        local velocityScaleDelta = 0
        velocityScaleDelta = IsDisabledControlJustPressed(Enum.PadType.PLAYER_CONTROL, 16) and velocityScaleDelta - 1 or velocityScaleDelta
        velocityScaleDelta = IsDisabledControlJustPressed(Enum.PadType.PLAYER_CONTROL, 17) and velocityScaleDelta + 1 or velocityScaleDelta

        velocityScale = velocityScale * (1 + (velocityScaleStep * velocityScaleDelta))
        if velocityScale > velocityScaleMax then
            velocityScale = velocityScaleMax
        end
        if velocityScale < velocityScaleMin then
            velocityScale = velocityScaleMin
        end

        SetFocusPosAndVel(newPos.x, newPos.y, newPos.z, 0.0, 0.0, 0.0)
        
    end,
}

CurrentCameraControlFunction = CameraTypeControls[ClientCameraStateOnClose]


-- * ////////////// TIMECYCLES //////////////
local function CreateCustomTimeCycles()
    for key, tc in pairs(Enum.TimeCycles) do
        local TCModIndex = CreateTimecycleModifier(tc.name)
        for varName, varValues in pairs(tc) do
            SetTimecycleModifierVar(tc.name, varName, varValues[1], varValues[2])
        end
    end
end

CreateCustomTimeCycles()


-- * ////////////// CAMERA TRANSITIONING //////////////

local GetNewVectorsForMap2d = function (lastCoords, lastRotation, lastCameraType)

    local newCoords = vector3(lastCoords.x, lastCoords.y, 2001.0) -- !TEMP
    local newRotation = vector3(-90.0, 0.0, 0.0)
    local newFov = 1.0

    return newCoords, newRotation, newFov
end
local GetStartVectorsForMap3d = function (lastCoords, lastRotation, lastCameraType)

    local lastTopZ = GetHeightmapTopZForPosition(lastCoords.x, lastCoords.y)
    local newCoords = vector3(lastCoords.x - (50.0 * 0.7777777), lastCoords.y - (50.0 * 0.7777777), lastTopZ + (50.0 * 0.7777777))
    local newRotation = vector3(-45.5, 0.0, -45.0)
    local newFov = 50.0

    return newCoords, newRotation, newFov
end

local GetVectorsFor = {
    [Enum.ClientCameraStates.MAP2D] = GetNewVectorsForMap2d,
    [Enum.ClientCameraStates.MAP3D] = GetStartVectorsForMap3d,

}



local executeBefore = {
    [Enum.ClientCameraStates.GAMEPLAY] = function ()
        
    end,
    [Enum.ClientCameraStates.MAP2D] = function ()
        -- SetExtraTimecycleModifier(Enum.TimeCycles.REMOVE_FOG_DOF_FARCLIP.name)
    end,
    [Enum.ClientCameraStates.MAP3D] = function ()
        
    end,
}

local executeAfter = {
    
    [Enum.ClientCameraStates.GAMEPLAY] = function ()
        
    end,
    [Enum.ClientCameraStates.MAP2D] = function ()
        -- ClearExtraTimecycleModifier()
    end,
    [Enum.ClientCameraStates.MAP3D] = function ()
        
    end,
}


-- * ////////////// CAMERA RENDER FUNCTIONS //////////////

local RemoveLastCamera = function(lastCam)
    DestroyCam(lastCam)

    CurrentCameraId = -1

    ClearFocus()
    RenderScriptCams(false, false, 0, false, false)
end

local CreateAndRenderCamera = function(coords, rotation, fov)
    local cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)

    SetCamCoord(cam, coords.x, coords.y, coords.z)
    SetCamRot(cam, rotation.x, rotation.y, rotation.z, Enum.RotationOrder.ROT_ZXY)
    SetCamFov(cam, fov)
    SetFocusPosAndVel(coords.x, coords.y, coords.z, 0.0, 0.0, 0.0)

    -- print(coords, rotation, fov)

    CurrentCameraId = cam
    currentCameraFov = fov

    RenderScriptCams(true, false, 0, false, false)

end

local UpdateCamera = function(newCameraType, lastCameraType)

    local afterFunction = executeAfter[lastCameraType]
    if afterFunction then
        afterFunction()
    end

    local gameplayCamType = Enum.ClientCameraStates.GAMEPLAY

    local lastCam = CurrentCameraId
    local lastCoords
    local lastRotation
    local lastFov

    if lastCameraType == gameplayCamType then
        
        lastCoords = GetEntityCoords(PlayerPedId())
        lastRotation = GetGameplayCamRot(Enum.RotationOrder.ROT_ZXY)
        lastFov = GetGameplayCamFov()
    else
        lastCoords = GetCamCoord(lastCam)
        lastRotation = GetCamRot(lastCam, Enum.RotationOrder.ROT_ZXY)
        lastFov = GetCamFov(lastCam)
    end

    RemoveLastCamera(lastCam)
    
    -- escape if gameplaycam
    if newCameraType == gameplayCamType then
        EnableAllControlActions(Enum.PadType.PLAYER_CONTROL)
        return
    end

    -- determine coords and rotation

    local newCoords, newRotation, newFov = GetVectorsFor[newCameraType](lastCoords, lastRotation, lastCameraType)

    local beforeFunction = executeBefore[newCameraType]
    if beforeFunction then
        beforeFunction()
    end

    CreateAndRenderCamera(newCoords, newRotation, newFov or lastFov)

end

-- * ////////////// CONTROL THREAD MANAGEMENT //////////////

local buildState = Enum.ToolStates.BUILD
local createState = Enum.ToolStates.CREATE
local moveState = Enum.ToolStates.MOVE

local CameraControlThreadFunction = function ()
    cameraControlThreadStatus = 1
    while cameraControlThreadSwitch == 1 do
        -- usingController = (IsUsingKeyboard(0) == false)

        DisableAllControlActions(Enum.PadType.PLAYER_CONTROL)
        DisableAllControlActions(Enum.PadType.CAMERA_CONTROL)

        if IsDisabledControlJustPressed(Enum.PadType.PLAYER_CONTROL, Enum.CameraControlKeys.LMB) then
            local screenX = GetDisabledControlNormal(0, 239)
            local screenY = GetDisabledControlNormal(0, 240)
            local world, normal = GetWorldCoordFromScreenCoord(screenX, screenY)
            LastClickWorldCoords = world
            LastClickScreenCoords = vector2(screenX, screenY)

            if ToolState == Enum.ToolStates.CREATE then
                -- Start a new line at world pos
            end
        end
        
        if IsDisabledControlPressed(Enum.PadType.PLAYER_CONTROL, Enum.CameraControlKeys.LMB) then
            -- Check mouse position
            local screenX = GetDisabledControlNormal(0, 239)
            local screenY = GetDisabledControlNormal(0, 240)
            -- if mouse position is over tool, then use tool
            -- if mouse is over blank space, switch to move state
            -- ! Temporarily use to do line stuff

            local world, normal = GetWorldCoordFromScreenCoord(screenX, screenY)
        end

        -- if usingController then
        --     ControllerCameraControls()
        -- else
            CurrentCameraControlFunction()
        -- end
        
        Wait(0)
    end
    EnableAllControlActions(Enum.PadType.PLAYER_CONTROL)
    EnableAllControlActions(Enum.PadType.CAMERA_CONTROL)
    cameraControlThreadStatus = 0
end

local StartCameraControlThread = function ()
    cameraControlThreadSwitch =  1
    CreateThread(CameraControlThreadFunction) 
end

local KillCameraControlThread = function ()
    cameraControlThreadSwitch = 0
end

-- local UpdateCameraControls = function (newCameraType)
    
--     CurrentCameraControlFunction = CameraTypeControls[newCameraType]

--     if newCameraType == Enum.ClientCameraStates.GAMEPLAY then
--         -- Disable custom controls
--         KillCameraControlThread()
--     else
--         -- Enable Custom Controls
--         if cameraControlThreadSwitch ~= 1 then
--             StartCameraControlThread()
--         end
--     end

-- end

-- * ////////////// CAMERA STATE HANDLER //////////////

local UpdateCameraState = function(cameraState)

    print("UpdateCameraState")
    local lastCameraState = ClientCameraState
    ClientCameraState = cameraState

    UpdateCamera(ClientCameraState, lastCameraState)
end

function SetCameraState(cameraType)
    print("SetCameraState")
    local lastCameraState = ClientCameraState

    if cameraState == lastCameraState then return end
    UpdateCameraState(cameraType)
    CurrentCameraControlFunction = CameraTypeControls[cameraType]
end


-- TODO: Add option for Q&E as relative to world, rather than relative to camera


-- ADDITIONAL TODO: FOV Option? Alt + scroll?
-- . Backspace to return to gameplay cam pos and rot?
-- . Space to teleport ped to lookat pos
-- ? UI? speed, fov, position, rotation? Border to show camera mode?
-- . ClearFocus on resourceStop
-- . DEFINE CAMERA MAP BOUNDS, avoid client flying to far off and getting lost/bugging

--* ////////////// HANDLES LOCAL EVENTS FROM MAIN.LUA //////////////
--* Mostly function calls
---@diagnostic disable-next-line: redundant-parameter
RegisterNetEvent("postplace-kjghKJHGgasd:func", function (data)
    local action = data.action
    if not DoesClientHavePerms() then
        return
    end
    if ToolEnabled then
        if action == "ppt_2dmap" then
            SetCameraState(Enum.ClientCameraStates.MAP2D)
        elseif action == "ppt_3dmap" then
            SetCameraState(Enum.ClientCameraStates.MAP3D)
        elseif action == "ppt_3dfreecam" then
            SetCameraState(Enum.ClientCameraStates.FREECAM)
        end

    end
end)



