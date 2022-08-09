local Vector3D = require("nl/Vector")
local Angle = require("nl/QAngle")
local Math = {
    PI = 3.14159265358979323846
 }
Math.__index = Math

function Math:VectorDistance(v1,v2)
    local x = v1.x - v2.x
    local y = v1.y - v2.y
    local z = v1.z - v2.z
    return math.sqrt(x*x + y*y + z*z)
end

function Math:CalcAngle(src,dst)
    local vAngle = Angle:new()
    local delta = Vector3D:new()
    delta:SetMembers(src.x - dst.x ,src.y - dst.y,src.z - dst.z)

    local hyp = math.sqrt(delta.x * delta.x + delta.y * delta.y)

    vAngle.x = math.atan(delta.z / hyp) * 57.295779513082
    vAngle.y = math.atan(delta.y / delta.x) * 57.295779513082
    vAngle.z = 0.0

    if (delta.x >= 0.0) then
        vAngle.y = vAngle.y + 180.0
    end

    return vAngle
end

function Math:GetFOV(viewAngle,aimAngle)
    local ang = Vector3D:new()
    local aim = Vector3D:new()

    self:AngleVectors(viewAngle,aim)
    self:AngleVectors(aimAngle,ang)

    local res = math.deg(math.acos(aim:Dot(ang) / aim:LengthSqr()))
    if res ~= res then
        res = 0.0
    end
    return res
end

function Math:ClampAngles(angles)
    if (angles.x > 89.0) then
        angles.x = 89.0
    elseif (angles.x < -89.0) then
        angles.x = -89.0
    end


    while(angles.y > 180.0) do
        angles.y = angles.y - 180.0
    end

    while(angles.y < -180.0) do
        angles.y = angles.y + 180.0
    end

    angles.z = 0
end

function Math:NormalizeAngles(angles)
    if (angles.x > 89.0) then
        angles.x = 89.0
    elseif (angles.x < -89.0) then
        angles.x = -89.0
    end

    if (angles.y > 180.0) then
        angles.y = 180.0
    elseif (angles.y < -180.0) then
        angles.y = -180.0
    end

    angles.z = 0
end

--- Returns Sine and Cosine of Value.
--- Sine and Cosine needs to be passed as reference / table.
function Math:XMScalarSinCos(pSin,pCos,Value)
    pSin[1] = math.sin(Value)
    pCos[1] = math.cos(Value)
end

function Math:AngleVectors(angles,forward)

    local sp = {}
    local sy = {}
    local cp = {}
    local cy = {}

    self:XMScalarSinCos(sp,cp,math.rad(angles.x))
    self:XMScalarSinCos(sy,cy,math.rad(angles.y))

    forward.x = cp[1] * cy[1]
    forward.y = cp[1] * sy[1]
    forward.z = -(sp[1])
end

function Math:AngleVectorsExtra(angles,forward,right,up)

    local sr = {}
    local sp = {}
    local sy = {}

    local cr = {}
    local cp = {}
    local cy = {}

    self:XMScalarSinCos(sp,cp,math.rad(angles.x))
    self:XMScalarSinCos(sy,cy,math.rad(angles.y))
    self:XMScalarSinCos(sr,cr,math.rad(angles.z))


    forward.x = cp[1] * cy[1]
    forward.y = cp[1] * sy[1]
    forward.z = -(sp[1])

    right.x = (-1 * sr[1] * sp[1] * cy[1] + -1 * cr[1] * -(sy[1]))
    right.y = (-1 * sr[1] * sp[1] * sy[1] + -1 * cr[1] *  cy[1])
    right.z = (-1 * sr[1] * cp[1])

    up.x = (cr[1] * sp[1] * cy[1] + -(sr[1]) * -sy[1])
    up.y = (cr[1] * sp[1] * sy[1] + -(sr[1]) * cy[1])
    up.z = (cr[1] * cp[1])
end

function Math:VectorAngles(forward,angles)
    local tmp,yaw,pitch

    if(forward.y == 0.0 and forward.x == 0.0) then
        yaw = 0.0
        if(forward.z > 0.0) then
            pitch = 270.0
        else
            pitch = 90.0
        end
    else
        yaw = math.atan(forward.y,forward.x) * 180.0 / 3.141592654
        if(yaw < 0.0) then
            yaw = yaw + 360.0
        end

        tmp = math.sqrt(forward.x * forward.x + forward.y * forward.y)
        pitch = math.atan(-forward.z,tmp) * 180.0 / 3.141592654
        if(pitch < 0.0)then
            pitch = pitch + 360.0
        end
    end

    angles.x = pitch
    angles.y = yaw
    angles.z = 0.0
end

function Math:Clamp(val, min, max)
    if min > val then
        val = min
    elseif val > max then
        val = max
    end
    return val
end

function Math:IsInBounds(PointToCheck, first_point, second_point)
    if((PointToCheck.x >= first_point.x and PointToCheck.x <= second_point.x) and (PointToCheck.y >= first_point.y and PointToCheck.y <= second_point.y)) then
        return true
    end
    return false
end

return Math


