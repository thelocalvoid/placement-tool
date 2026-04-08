




Enum = {}


--* ///////////// GTA 5 CONTROL INDICES /////////////
Enum.CameraControlKeys = {
    W = 87,
    A = 65,
    S = 83,
    D = 68,
    E = 69,
    G = 47,
    H = 304,
    N = 306,
    Q = 81,
    R = 45,
    T = 309,
    V = 236,

    ONE = 157,
    TWO = 158,
    THREE = 160,
    FOUR = 164,
    FIVE = 165,

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
    },
    DEV_WEATHERFX = {
        name = "DEV_WEATHERFX",
        light_dir_mult = { 0.000, 0.250 },
        light_directional_amb_col_r = { 0.878, 1.000 },
        light_directional_amb_col_g = { 0.671, 1.000 },
        light_directional_amb_col_b = { 0.384, 1.000 },
        light_directional_amb_intensity = { 0.500, 0.000 },
        light_directional_amb_intensity_mult = { 1.000, 0.000 },
        light_directional_amb_bounce_enabled = { 1.000, 0.000 },
        light_natural_amb_down_col_r = { 0.875, 1.000 },
        light_natural_amb_down_col_g = { 0.671, 1.000 },
        light_natural_amb_down_col_b = { 0.380, 1.000 },
        light_natural_amb_down_intensity = { 0.250, 0.000 },
        light_natural_amb_up_col_r = { 0.514, 0.667 },
        light_natural_amb_up_col_g = { 0.737, 0.667 },
        light_natural_amb_up_col_b = { 1.000, 0.667 },
        light_natural_amb_up_intensity = { 0.750, 0.000 },
        light_natural_amb_up_intensity_mult = { 1.000, 0.000 },
        light_natural_push = { 0.000, 0.000 },
        light_ambient_bake_ramp = { 10.000, 0.000 },
        light_artificial_ext_up_col_r = { 1.000, 1.000 },
        light_artificial_ext_up_col_g = { 1.000, 1.000 },
        light_artificial_ext_up_col_b = { 1.000, 1.000 },
        light_artificial_ext_up_intensity = { 1.000, 0.000 },
        ped_light_col_r = { 1.000, 1.000 },
        ped_light_col_g = { 0.827, 1.000 },
        ped_light_col_b = { 0.557, 1.000 },
        ped_light_mult = { 1.000, 1.000 },
        ssao_inten = { 4.000, 0.000 },
        light_direction_override = { 0.900, 0.000 },
        light_direction_override_overrides_sun = { 1.000, 0.000 },
        sun_direction_x = { -0.375, 0.000 },
        sun_direction_y = { 0.275, 0.000 },
        sun_direction_z = { 1.000, 0.000 },
        moon_direction_x = { -0.375, 0.000 },
        moon_direction_y = { 0.275, 0.000 },
        moon_direction_z = { 1.000, 0.000 },
        postfx_bright_pass_thresh = { 100.0, 0.000 },
        sky_moon_disc_size = { 0.000, 0.000 },
        sprite_brightness = { 0.000, 0.000 },
        sprite_size = { 0.000, 0.300 },
        fog_density = { -2.000, -9.700 },
        fog_haze_alpha = { 1.000, -4.350 },
        fogray_intensity = { 1.000, 0.000 },
        fogray_density = { 2.350, -2.450 },
        reflection_lod_range_start = { 0.000, 0.000 },
        reflection_lod_range_end = { 0.000, 0.000 },
        reflection_slod_range_start = { 0.000, 0.000 },
        reflection_slod_range_end = { 0.000, 0.000 },
        reflection_tweak_interior_amb = { 16.000, 0.000 },
        reflection_tweak_emissive = { 4.000, 0.000 },
        temperature = { 20.000, 0.000 },
        natural_ambient_multiplier = { 0.000, 0.000 },
        artificial_int_ambient_multiplier = { 0.600, 0.000 },
        no_weather_fx = { 1.000, 1.000 },
        lodlight_range_mult = {0.000, 0.000},
        dof_enable_hq = {1.0, 0.0},
        dof_hq_farplane_out = {100000.0, 0.0},
    },
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
