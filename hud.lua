




local function controlString(key, text)
    return string.format("~y~[%s]~w~ %s", key, text)
end

local strings = {
    control_switchto_build =     controlString( "T",         "ADD TOOL" ),
    control_switchto_grab =      controlString( "G",         "GRAB TOOL" ),
    control_switchto_remove =    controlString( "R",         "REMOVE TOOL" ),
    control_switchto_subdivide = controlString( "V",         "SUBDIVIDE TOOL" ),
    control_switchto_heading =   controlString( "H",         "HEADING OVERRIDE TOOL" ),
    
    control_switchto_edit =      controlString( "TAB",       "EDIT MODE" ),
    control_switchto_object =    controlString( "TAB",       "OBJECT MODE" ),
    control_switchto_escape =    controlString( "ESC",       "-> EDIT -> OBJECT" ),
    
    control_switchto_create =    controlString( "N",         "CREATE TOOL" ),
    control_switchto_delete =    controlString( "DEL",       "DELETE SELECTED LINE" ),
    
    control_select_line =        controlString( "CLICK",     "SELECT LINE" ),
    control_create_line =        controlString( "CLICK",     "CREATE NEW LINE" ),
    control_create_point =       controlString( "CLICK",     "ADD POINT" ),
    control_delete_point =       controlString( "CLICK",     "DELETE POINT" ),
    control_drag_point =         controlString( "CLICK",     "PICKUP/DROP POINT" ),
    control_rotate_point =       controlString( "CLICK",     "SET POINT HEADING" ),
    control_cancel =             controlString( "RCLICK",    "CANCEL ACTION" ),
    control_remove_heading =     controlString( "BACKSPACE", "REMOVE HEADING OVERRIDE" ),
}

HudElements = {
    Modes = {
        [Enum.ToolStates.OBJECT] = function ()
            local list = {}
            list[1] = (CurrentlySelectedPropLine ~= -1) and strings.control_switchto_edit or ""
            list[2] = strings.control_switchto_create
            list[3] = strings.control_select_line
            list[4] = (CurrentlySelectedPropLine ~= -1) and strings.control_switchto_delete or ""
            return list
        end,
        [Enum.ToolStates.CREATE] = function ()
            local list = {}
            list[1] = ""
            list[2] = strings.control_switchto_escape
            list[3] = ""
            list[4] = strings.control_create_line
            return list
        end,
        [Enum.ToolStates.EDIT] = function ()
            local list = {}
            list[1] = strings.control_switchto_object
            list[2] = strings.control_switchto_escape
            list[3] = strings.control_switchto_build
            list[4] = strings.control_switchto_grab
            list[5] = strings.control_switchto_remove
            list[6] = strings.control_switchto_subdivide
            list[7] = strings.control_switchto_heading
            return list
        end,
        [Enum.ToolStates.BUILD] = function ()
            local list = {}
            list[1] = strings.control_switchto_edit
            list[2] = strings.control_switchto_escape
            list[3] = strings.control_switchto_grab
            list[4] = strings.control_switchto_remove
            list[5] = strings.control_switchto_subdivide
            list[6] = strings.control_switchto_heading
            list[7] = ""
            list[8] = strings.control_create_point
            return list
        end,
        [Enum.ToolStates.MOVE] = function ()
            local list = {}
            list[1] = strings.control_switchto_edit
            list[2] = strings.control_switchto_escape
            list[3] = strings.control_switchto_build
            list[4] = strings.control_switchto_remove
            list[5] = strings.control_switchto_subdivide
            list[6] = strings.control_switchto_heading
            list[7] = ""
            list[8] = strings.control_drag_point
            list[9] = strings.control_cancel
            return list
        end,
        [Enum.ToolStates.DELETE] = function ()
            local list = {}
            list[1] = strings.control_switchto_edit
            list[2] = strings.control_switchto_escape
            list[3] = strings.control_switchto_build
            list[4] = strings.control_switchto_grab
            list[5] = strings.control_switchto_subdivide
            list[6] = strings.control_switchto_heading
            list[7] = ""
            list[8] = strings.control_delete_point
            return list
        end,
        [Enum.ToolStates.SUBDIVIDE] = function ()
            local list = {}
            list[1] = strings.control_switchto_edit
            list[2] = strings.control_switchto_escape
            list[3] = strings.control_switchto_build
            list[4] = strings.control_switchto_grab
            list[5] = strings.control_switchto_remove
            list[6] = strings.control_switchto_heading
            list[7] = ""
            list[8] = strings.control_create_point
            return list
        end,
        [Enum.ToolStates.ROTATION_OVERRIDE] = function ()
            local list = {}
            list[1] = strings.control_switchto_edit
            list[2] = strings.control_switchto_escape
            list[3] = strings.control_switchto_build
            list[4] = strings.control_switchto_grab
            list[5] = strings.control_switchto_remove
            list[6] = strings.control_switchto_subdivide
            list[7] = ""
            list[8] = strings.control_rotate_point
            list[9] = strings.control_remove_heading
            list[10] = strings.control_cancel
            return list
        end,
    },
}