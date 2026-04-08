




-- * ////////////// TOOL DATA //////////////
ToolEnabled = false
ToolState = Enum.ToolStates.CREATE -- BUILD or MOVE
LastClickScreenCoords = vector2(0.0,0.0)
LastClickWorldCoords = vector3(0.0,0.0,0.0)
ToolControls = {}


-- * ////////////// CAMERA DATA //////////////
CurrentCameraId = 0
ClientCamCoords = vector3(0.0,0.0,0.0)

ClientCameraState = Enum.ClientCameraStates.GAMEPLAY
ClientCameraStateOnClose = Enum.ClientCameraStates.MAP3D


-- * ////////////// USER DATA //////////////
CursorWorldPos = vector3(0.0,0.0,0.0)
CursorGroundNormal = vector3(0.0,0.0,0.0)
CursorWorldImpact = false
HasPerms = false

PropNameHistory = {}
ActionHistory = {}


-- * ////////////// OVERLAY DATA //////////////
Lines = {}
Spheres = {}
Rects = {}
PreviewLine = false
PreviewLine2 = true
PreviewPoint = true
Previews = {
    Line = {startPos = vector3(0.0,0.0,0.0), color = { 0, 0, 255, 255},},
    Line2 = {startPos = vector3(0.0,0.0,0.0), color = { 0, 0, 255, 255},},
    Point = {pos = vector3(0.0,0.0,0.0), color = {0, 0, 255, 1.0}, radius = 0.75},
}
DistPreviews = {
    [1] = {pos = vector3(0.0,0.0,0.0), dist = 0},
    [2] = {pos = vector3(0.0,0.0,0.0), dist = 0},
}

function CalculateDistOfPreviewLine(lineNum)
    local difference = vector3(0.0,0.0,0.0)
    if lineNum == 1 then
        difference = CursorWorldPos - Previews.Line.startPos
    elseif lineNum == 2 then
        difference = CursorWorldPos - Previews.Line2.startPos
    end

    DistPreviews[lineNum] = {
        pos = CursorWorldPos,
        dist = #difference
    }
end


-- * ////////////// PROP LINE DATA //////////////
CurrentlySelectedPropLine = -1
CurrentHeadOfLine = -1
EditSelection = -1
PropLines = {}

MoveReturnPos = vector3(0.0,0.0,0.0)
MoveReturnNormal = vector3(0.0,0.0,0.0)
RotateReturnWasntOverridden = true
RotateReturnDir = vector3(0.0,0.0,0.0)


-- * ////////////// PERM VERIFICATION //////////////
local PENDING_CHECK = false
local PASSKEY = "AA"

local accepted = {["i"] = true, ["o"] = true}
local acceptedb = {["e"] = true}

local function valid(key)
    local r = 0
    local b = 0
    local wordI = 1
    for word in string.gmatch(key, "[^-]+") do
        local k = 0
        for i = 1, #word do
            local char = word:sub(i, i)
            if accepted[char] then
                k = k + 1
            end
        end
        wordI = wordI + 1
        if wordI == 5 then
            -- print("last Word")
            if acceptedb[word:sub(#word, #word)] then
                b = 1
            end
        end
        if k > 0 then
            r = r + 1
        end
        -- print(word, "K:"..k)
    end

    if r == 2 and b == 1 then
        return true
    else
        return false
    end

end
--* Checks if client is apart of any approved ACL groups
function DoesClientHavePerms()
    return HasPerms
end

--* Checks if client is apart of any approved ACL groups
function ShouldClientHavePerms()
    -- print("Start")
    if not PENDING_CHECK then
        PENDING_CHECK = true
        TriggerServerEvent("postplace-kghASKG5as:ace", PedToNet(PlayerPedId()))
    end
    while PENDING_CHECK do
        Wait(10)
        -- print(PASSKEY)
    end
    -- print(PASSKEY)
    local result = valid(PASSKEY)
    -- print(result)
    return result
end

RegisterNetEvent("postplace-kghASKG5as:acer", function (key)
    PASSKEY = key
    -- print(key)
    PENDING_CHECK = false
end)



--* ////////////// HANDLES COMMAND EVENTS //////////////
--* Commands are registered in Commands.lua - a server-side script (handles ace permissions)
RegisterNetEvent("postplace-goiufgSDGFI:com", function (func, data)
    local functionEventName = "postplace-kjghKJHGgasd:func"
    -- print("main.lua", func)
    if func == "ppt_opentool" then        -- * ppt_opentool
        TriggerEvent(functionEventName, {action = func})
    elseif func == "ppt_closetool" then   -- * ppt_closetool
        TriggerEvent(functionEventName, {action = func})
    elseif func == "ppt_2dmap" then   -- * ppt_2dmap
        TriggerEvent(functionEventName, {action = func})
    elseif func == "ppt_3dmap" then   -- * ppt_3dorbit
        TriggerEvent(functionEventName, {action = func})
    elseif func == "ppt_3dfreecam" then   -- * ppt_3dfreecam
        TriggerEvent(functionEventName, {action = func})
    end
end)

HasPerms = ShouldClientHavePerms()


--* ////////////// CURSOR WORLD POS THREAD //////////////

CreateThread(function (threadId)
    while true do
        local screenX = GetDisabledControlNormal(0, 239)
        local screenY = GetDisabledControlNormal(0, 240)
        local world, normal = GetWorldCoordFromScreenCoord(screenX, screenY)
        
        local offset = normal * 1000
        local testEnd = world + offset

        local shapeTest = StartShapeTestLosProbe(ClientCamCoords.x, ClientCamCoords.y, ClientCamCoords.z, testEnd.x, testEnd.y, testEnd.z, 1, 0, 0)
        local retval, hit, endCoords, surfaceNormal, entityHit = GetShapeTestResult(shapeTest)
        while true do
            retval, hit, endCoords, surfaceNormal, entityHit = GetShapeTestResult(shapeTest)
            if retval ~= 1 then
                CursorWorldImpact = (hit == 1)
                if CursorWorldImpact then
                    CursorWorldPos = endCoords
                    CursorGroundNormal = surfaceNormal
                    DrawLine(endCoords, endCoords + surfaceNormal, 255, 255, 0, 255)
                end
                break
            end
            Wait(0)
        end
        Wait(0)
    end
end)


--* ////////////// RESOURCE CLEAN UP //////////////

RegisterNetEvent("onResourceStop", function (resName)
    if resName == GetCurrentResourceName() then
        ClearFocus()
        SetDistantCarsEnabled(true)
        SetCloudsAlpha(1.0)
        ClearOverrideWeather()
        ClearExtraTimecycleModifier()
        NetworkClearClockTimeOverride()
    end
end)