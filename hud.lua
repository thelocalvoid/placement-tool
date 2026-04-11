




local function controlString(key, text)
    return string.format("~y~[%s]~w~%s", key, text)
end

local strings = {
    control_switchto_build =     controlString( "T",         "&#9;ADD TOOL" ),
    control_switchto_grab =      controlString( "G",         "&#9;GRAB TOOL" ),
    control_switchto_remove =    controlString( "R",         "&#9;REMOVE TOOL" ),
    control_switchto_subdivide = controlString( "V",         "&#9;SUBDIVIDE TOOL" ),
    control_switchto_heading =   controlString( "H",         "&#9;HEADING OVERRIDE TOOL" ),
    
    control_switchto_edit =      controlString( "TAB",       "&#9;EDIT MODE" ),
    control_switchto_object =    controlString( "TAB",       "&#9;OBJECT MODE" ),
    control_switchto_escape =    controlString( "ESC",       "&#9;EDIT -> OBJECT" ),
    
    control_switchto_create =    controlString( "N",         "&#9;&#9;CREATE TOOL" ),
    control_switchto_delete =    controlString( "DEL",       "&#9;DELETE SELECTED LINE" ),
    
    control_select_line =        controlString( "LMB",       "&#9;SELECT LINE" ),
    control_create_line =        controlString( "LMB",       "&#9;CREATE NEW LINE" ),
    control_create_point =       controlString( "LMB",       "&#9;ADD POINT" ),
    control_delete_point =       controlString( "LMB",       "&#9;DELETE POINT" ),
    control_drag_point =         controlString( "LMB",       "&#9;PICKUP/DROP POINT" ),
    control_rotate_point =       controlString( "LMB",       "&#9;SET POINT HEADING" ),
    control_cancel =             controlString( "RMB",       "&#9;CANCEL ACTION" ),
    control_remove_heading =     controlString( "BKSP",      "&#9;REMOVE HEADING OVERRIDE" ),
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
            list[1] = ""
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
            list[1] = ""
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
            list[1] = ""
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
            list[1] = ""
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
            list[1] = ""
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
    -- Stats = {
    --     Project_NoSelection = {
    --         "Lines:   ~1~", -- total lines in project
    --         "Points:  ~1~", -- total points in project
    --         "Grids:   ~1~", -- total grids in use
    --     },
    --     Project_LineSelected = {
    --         "Lines:   ~1~", -- total lines in project
    --         "Points:  ~1~ / ~1~", -- points in selected line / total points in project
    --         "Grids:   ~1~ | ~1~", -- grid total | grid numbers used by this line
    --         "",
    --         "Line:    ~1~", -- line selected id
    --     },
    --     Project_EditMode = {
    --         "Lines:   ~1~", -- total lines in project
    --         "Points:  ~1~ / ~1~", -- points in selected line / total points in project
    --         "Grids:   ~1~ | ~1~", -- grid total | grid numbers used by this line
    --         "",
    --         "Line:    ~1~", -- line selected id
    --         "Point:   ~1~", -- point selected id
    --     },
    -- }
}

AddTextEntry( 'YmapTotLines',           'Lines:&#9;~1~'       )
AddTextEntry( 'YmapTotPoints',          'Points:&#9;~1~'       )
AddTextEntry( 'YmapTotGrids',           'Grids:&#9;~1~'       )
AddTextEntry( 'YmapPointsInSelect',     'Points:&#9;~1~ / ~1~' )
AddTextEntry( 'YmapGridsInSelect',      'Grids:&#9;~1~ / ~1~' )
AddTextEntry( 'YmapCurrLine',           'Line ID:&#9;~1~'    )
AddTextEntry( 'YmapCurrPoint',          'Point ID:&#9;~1~'    )


AddTextEntry( 'YmapLineRandomRot',      'LineRandomRotation:&#9;~a~')
AddTextEntry( 'YmapLineReverse',        'LineReverse:&#9;&#9;&#9;~a~')
AddTextEntry( 'YmapLineRotOffset',      'LineRotationOffset:&#9;~1~')
AddTextEntry( 'YmapLineAlignNorm',      'LineAlignToNormal:&#9;~a~')
AddTextEntry( 'YmapLineVertOffset',     'LineVerticalOffset:&#9;&#9;~1~')
AddTextEntry( 'YmapLineWobble',         'LineWobble:&#9;&#9;&#9;~1~')