




-- * ////////////// GENERAL MATH FUNCTIONS //////////////

CMath = {}

function CMath.Clamp(v, min, max)
    return math.max(min, math.min(max, v))
end

function CMath.Lerp(a, b, t)
    return a + (b - a) * t
end
local Lerp = CMath.Lerp

CMath.Vec3 = {}

function CMath.Vec3.Dot(a, b)
    return a.x * b.x + a.y * b.y + a.z * b.z
end

function CMath.Vec3.Length(v)
    return math.sqrt(v.x*v.x + v.y*v.y + v.z*v.z)
end
local Length = CMath.Vec3.Length

function CMath.Vec3.Normalize(v)
    local len = Length(v)
    if len == 0 then return vector3(0.0,0.0,0.0) end
    return vector3(
        v.x / len,
        v.y / len,
        v.z / len
)
end
local Normalize = CMath.Vec3.Normalize

function CMath.Vec3.Distance(a, b)
    return Length({
        x = a.x - b.x,
        y = a.y - b.y,
        z = a.z - b.z
    })
end

function CMath.Vec3.Difference(a, b)
    return vector3(
        b.x - a.x,
        b.y - a.y,
        b.z - a.z
    )
end

function CMath.Vec3.Direction(a, b)
    return Normalize({
        x = b.x - a.x,
        y = b.y - a.y,
        z = b.z - a.z
    })
end

function CMath.Vec3.Lerp(a, b, t)
    return {
        x = Lerp(a.x, b.x, t),
        y = Lerp(a.y, b.y, t),
        z = Lerp(a.z, b.z, t)
    }
end

function CMath.Vec3.Cross(a, b)
    return vector3(
        a.y * b.z - a.z * b.y,
        a.z * b.x - a.x * b.z,
        a.x * b.y - a.y * b.x
    )
end