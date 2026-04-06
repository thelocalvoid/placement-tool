




Enum = {}


--* ///////////// GTA 5 CONTROL INDICES /////////////
Enum.CameraControlKeys = {
    W = 87,
    A = 65,
    S = 83,
    D = 68,
    Q = 81,
    E = 69,
    V = 236,
    R = 45,
    T = 309,
    N = 306,
    G = 47,
    H = 304,
    SHIFT = 16,
    BACKSPACE = 194,
    SPACE = 22,
    ESC = 200,
    TAB = 37,
    EQUALS = 83,
    MINUS = 84,
    VK_SPACE = 32,
    VK_DELETE = 46,
    LMB = 24,
    RMB = 25,
}
--* ///////////// GTA 5 CONTROL PAD CATEGORIES /////////////
Enum.PadType = {
  PLAYER_CONTROL = 0,
  CAMERA_CONTROL = 1,
  FRONTEND_CONTROL = 2
}

--* ///////////// GTA 5 ROTATION ORDERS /////////////
--* e.g ZYX = Rotate around the z-axis, then y-axis and finally x-axis.
Enum.RotationOrder = {
    ROT_ZYX = 0,
    ROT_YZX = 1,
    ROT_ZXY = 2,
    ROT_XZY = 3,
    ROT_YXZ = 4,
    ROT_XYZ = 5,
}

Enum.MousePointerStyle = {
    ARROW = 1,
	ARROW_DIMMED = 2,
	HAND_OPEN = 3,
	HAND_GRAB = 4,
	HAND_MIDDLE_FINGER = 5,
	ARROW_LEFT = 6,
	ARROW_RIGHT = 7,
	ARROW_UP = 8,
	ARROW_DOWN = 9,
	ARROW_TRIMMING = 10,
	ARROW_PLUS = 11,
	ARROW_MINUS = 12,
}

--* ///////////// TIMECYCLE PRESETS /////////////
Enum.TimeCycles = {
    REMOVE_FOG_DOF_FARCLIP = {
        name = "REMOVE_FOG_DOF_FARCLIP",
        dof_enable_hq = {1.0, 0.0},
        dof_hq_farplane_out = {100000.0, 0.0},
        fog_haze_alpha = {0.0, 0.0},
        fog_alpha = {0.0, 0.0},
        far_clip = {15000.0, 15000.0},
    }
}

--* ///////////// CAMERA PRESETS /////////////
Enum.ClientCameraStates = {
    GAMEPLAY = 1,
    FREECAM = 2,
    MAP2D = 3,
    MAP3D = 4,
}

Enum.ToolStates = {
    BUILD = 1,
    MOVE = 2,
    CREATE = 3,
    EDIT = 4,
    OBJECT = 5,
    SUBDIVIDE = 6,
    DELETE = 7,
    ROTATION_OVERRIDE = 8,
}
Enum.ToolStateNames = {
    [1] = "ADD POINT",
    [2] = "GRAB TOOL",
    [3] = "CREATE LINE",
    [4] = "EDITING",
    [5] = "OBJECT",
    [6] = "SUBDIVIDE",
    [7] = "REMOVE POINT",
    [8] = "HEADING OVERRIDE",
}

Enum.LineDrawType = {
    UNSELECTED = 0,
    SELECTED = 1,
    PREVIEW = 2,
    EDITSELECT = 3,
    EDITHEAD = 4,

}
Enum.LineDrawColors = {
    [Enum.LineDrawType.PREVIEW] = vector4(255,0,255,255),
    [Enum.LineDrawType.SELECTED] = vector4(0,255,0,255),
    [Enum.LineDrawType.UNSELECTED] = vector4(255,255,0,255),
    [Enum.LineDrawType.EDITSELECT] = vector4(255,255,0,255),
    [Enum.LineDrawType.EDITHEAD] = vector4(0,255,255,255),
}

Enum.PreviewModes = {
    NONE = 0,
    LINE = 1,
    LINEANDPOINT = 2,
    POINT = 3,
    SUBDPREVIEW = 4,
    Values = {
        [0] = {[1] = false, [2] = false, [3] = false},
        [1] = {[1] = true, [2] = false, [3] = false},
        [2] = {[1] = true, [2] = true, [3] = false},
        [3] = {[1] = false, [2] = true, [3] = false},
        [4] = {[1] = true, [2] = true, [3] = true},
    }
}
