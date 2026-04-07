local function makeString(key, text)
    return string.format("~y~[%s]~w~ %s", key, text)
end

local strings = {
    control_switchto_build =     "[T] ADD TOOL",
    control_switchto_grab =      "[G] GRAB TOOL",
    control_switchto_remove =    "[R] REMOVE TOOL",
    control_switchto_subdivide = "[V] SUBDIVIDE TOOL",
    control_switchto_heading =   "[H] HEADING OVERRIDE TOOL",

    control_switchto_edit =      "[TAB] EDIT MODE",
    control_switchto_object =    "[TAB] OBJECT MODE",
    control_switchto_escape =    "[ESC] -> EDIT -> OBJECT",

    control_switchto_create =    "[N] CREATE TOOL",
}

local strings = {
    control_switchto_build =     makeString("T", "ADD TOOL"),
    control_switchto_grab =      makeString("G", "GRAB TOOL"),
    control_switchto_remove =    makeString("R", "REMOVE TOOL"),
    control_switchto_subdivide = makeString("V", "SUBDIVIDE TOOL"),
    control_switchto_heading =   makeString("H", "HEADING OVERRIDE TOOL"),

    control_switchto_edit =      makeString("TAB", "EDIT MODE"),
    control_switchto_object =    makeString("TAB", "OBJECT MODE"),
    control_switchto_escape =    makeString("ESC", "-> EDIT -> OBJECT"),

    control_switchto_create =    makeString("N", "CREATE TOOL"),
    control_switchto_delete =    makeString("DEL", "DELETE SELECTED LINE"),
}

HudElements = {
    Modes = {
        [Enum.ToolStates.OBJECT] = function ()
            local list = {}
            list[1] = (CurrentlySelectedPropLine ~= -1) and strings.control_switchto_edit or ""
            list[2] = strings.control_switchto_create
            list[3] = (CurrentlySelectedPropLine ~= -1) and strings.control_switchto_delete or ""
            return list
        end,
        [Enum.ToolStates.CREATE] = function ()
            local list = {}
            list[1] = (CurrentlySelectedPropLine ~= -1) and strings.control_switchto_edit or ""
            list[2] = strings.control_switchto_escape
            list[3] = strings.control_switchto_create
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
            return list
        end,
    },
}