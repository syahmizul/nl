local Vector3D = require("nl/Vector")
local Angle = require("nl/QAngle")
local Math = {
    PI = 3.14159265358979323846,
    PI_2 = 3.14159265358979323846 * 2.0,
    SMALL_NUM = -2147483648
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

    if not Vector3D:IsValid(delta) then return nil end

    local hyp = math.sqrt(delta.x * delta.x + delta.y * delta.y)

    if hyp ~= hyp then return nil end

    vAngle.x = math.atan(delta.z/hyp) * 57.295779513082
    vAngle.y = math.atan(delta.y/delta.x) * 57.295779513082
    vAngle.z = 0.0

    if not Angle:IsValid(vAngle) then return nil end

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
    

    if (angles.y > 180.0) then
        angles.y = 180.0
    elseif (angles.y < -180.0) then
        angles.y = -180.0
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
    return math.max(min,math.min(val,max))
end

function Math:IsInBounds(PointToCheck, first_point, second_point)
    if((PointToCheck.x >= first_point.x and PointToCheck.x <= second_point.x) and (PointToCheck.y >= first_point.y and PointToCheck.y <= second_point.y)) then
        return true
    end
    return false
end

function Math:SmoothAngle( from , to , percent )

    percent = percent or 25

    from:NormalizeTo180()
    to:NormalizeTo180()
	local VecDelta = from - to


    VecDelta:NormalizeTo180()
    
	VecDelta.x = VecDelta.x * ( percent / 100.0 )
	VecDelta.y = VecDelta.y * ( percent / 100.0 )


    VecDelta:NormalizeTo180()



    local DeltaLast = (from - VecDelta)
    DeltaLast:NormalizeTo180()


	return DeltaLast 
end

function Math:dist_Segment_to_Segment(s1, s2, k1, k2)
    local   u = s2 - s1;
    local    v = k2 - k1;
    local   w = s1 - k1;
    local    a = u:Dot(u)
    local    b = u:Dot(v)
    local    c = v:Dot(v)
    local    d = u:Dot(w)
    local    e = v:Dot(w)
    local    D = a*c - b*b;  
    local    sc, sN
    local   sD = D       
    local   tc, tN
    local   tD = D

    if (D < Math.SMALL_NUM) then
        sN = 0.0;        
        sD = 1.0;        
        tN = e;
        tD = c;
    else                 
        sN = (b*e - c*d);
        tN = (a*e - b*d);
        if (sN < 0.0) then      
            sN = 0.0;
            tN = e;
            tD = c;
        elseif (sN > sD) then
            sN = sD;
            tN = e + b;
            tD = c;
        end
    end

    if (tN < 0.0) then     
        tN = 0.0;

        if (-d < 0.0) then
            sN = 0.0;
        elseif (-d > a) then
            sN = sD;
        else 
            sN = -d;
            sD = a;
        end
    elseif (tN > tD) then
        tN = tD;

        if ((-d + b) < 0.0) then
            sN = 0;
        elseif ((-d + b) > a) then
            sN = sD;
        else 
            sN = (-d + b);
            sD = a;
        end
    end

    if ( math.abs(sN) < Math.SMALL_NUM )then 
        sc = 0.0
    else
        sc = sN / sD
    end

    if ( math.abs(tN) < Math.SMALL_NUM )then 
        tc = 0.0
    else
        tc = tN / tD
    end

    local dP = w + (u:MultiplySingle(sc)) - (v:MultiplySingle(tc));

    return dP:Length()   
end

function Math:DoesIntersectCapsule(eyePos, myDir, capsuleA, capsuleB, radius)
    local endPos = eyePos + (myDir:MultiplySingle(8192.0));
    local dist = Math:dist_Segment_to_Segment(eyePos, endPos, capsuleA, capsuleB)
    
    return dist < radius;
end

return Math


