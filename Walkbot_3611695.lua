_DEBUG = true
local Vector3D = {
    x,y,z
}
Vector3D.__index = Vector3D

---Makes a new Vector3D with the arguments as the components,or zero-ed if not provided.
---@param x float
---@param y float
---@param z float
---@return Vector3D
function Vector3D:new(x,y,z)
    local Object = {}
    setmetatable(Object,self)
    Object.x = x or 0.00
    Object.y = y or 0.00
    Object.z = z or 0.00
    return Object
end

---Makes a new Vector3D from another type
---@param CustomVector Vector3D
---@return table
function Vector3D:NewCustom(CustomVector)
    local Object = {}
    setmetatable(Object,self)
    Object.x = CustomVector.x or 0.00
    Object.y = CustomVector.y or 0.00
    Object.z = CustomVector.z or 0.00
    return Object
end

-- Makes a copy of itself and returns it
function Vector3D:Copy()
    local CopyVector = Vector3D:new()
    CopyVector.x = self.x
    CopyVector.y = self.y
    CopyVector.z = self.z
    return CopyVector
end

-- Copies another Vector3D's/any Vector type with the same component name members.
function Vector3D:CopyOther(v)
    self.x = v.x
    self.y = v.y
    self.z = v.z
end

-- Sets the vector's components from the arguments.
function Vector3D:SetMembers(x,y,z)
  self.x = x
  self.y = y
  self.z = z
end

-- Sets the x component of the vector
function Vector3D:SetX(x)
  self.x = x
end

function Vector3D:SetY(y)
    self.y = y
end

function Vector3D:SetZ(z)
    self.z = z
end

function Vector3D:GetX()
    return self.x
end

function Vector3D:GetY()
    return self.y
end

function Vector3D:GetZ()
    return self.z
end

function Vector3D:Zero()
    self.x = 0
    self.y = 0
    self.z = 0
end

function Vector3D:IsDifference2D(v,limit)

    if(math.abs(self.x - v.x) >= limit) or (math.abs(self.y - v.y) >= limit) then
        return true
    end

    return false
end


function Vector3D:IsDifference3D(v,limit,z_limit)

    if(math.abs(self.x - v.x) >= limit) or (math.abs(self.y - v.y) >= limit) or (math.abs(self.z - v.z) >= (z_limit or limit)) then
        return true
    end
    return false
end

function Vector3D:SetMemberFromFloatType(FloatVariable)
	self.x = FloatVariable[0]
	self.y = FloatVariable[1]
	self.z = FloatVariable[2]
end

function Vector3D:PrintValue()
    print("x : " .. self.x .. " y : " .. self.y .. " z : " .. self.z)
end

function Vector3D:PrintValueClean()
    print(self.x .. " " .. self.y .. " " .. self.z)
end

function Vector3D:__add(v)
    local SolvedVector = Vector3D:new()
    SolvedVector.x = self.x + v.x
    SolvedVector.y = self.y + v.y
    SolvedVector.z = self.z + v.z
    return SolvedVector
end

function Vector3D:__sub(v)
    local SolvedVector = Vector3D:new()
    SolvedVector.x = self.x - v.x
    SolvedVector.y = self.y - v.y
    SolvedVector.z = self.z - v.z
    return SolvedVector
end

function Vector3D:__mul(v)
    local SolvedVector = Vector3D:new()
    SolvedVector.x = self.x * v.x
    SolvedVector.y = self.y * v.y
    SolvedVector.z = self.z * v.z
    return SolvedVector
end

function Vector3D:__div(v)
    local SolvedVector = Vector3D:new()
    SolvedVector.x = self.x / v.x
    SolvedVector.y = self.y / v.y
    SolvedVector.z = self.z / v.z
    return SolvedVector
end

function Vector3D:__mod(v)
    local SolvedVector = Vector3D:new()
    SolvedVector.x = self.x % v.x
    SolvedVector.y = self.y % v.y
    SolvedVector.z = self.z % v.z
    return SolvedVector
end

function Vector3D:__pow(v)
    local SolvedVector = Vector3D:new()
    SolvedVector.x = self.x ^ v.x
    SolvedVector.y = self.y ^ v.y
    SolvedVector.z = self.z ^ v.z
    return SolvedVector
end

function Vector3D:__eq(v)
    if self.x ~= v.x then return false end
    if self.y ~= v.y then return false end
    if self.z ~= v.z then return false end
    return true
end

function Vector3D:__lt(v) -- <
    if self.x >= v.x then return false end
    if self.y >= v.y then return false end
    if self.z >= v.z then return false end
    return true
end

function Vector3D:__le(v)  -- <=
    if self.x > v.x then return false end
    if self.y > v.y then return false end
    if self.z > v.z then return false end
    return true
end

function Vector3D:Length()
    return math.sqrt( self.x*self.x + self.y*self.y + self.z*self.z )
end

function Vector3D:LengthSqr()
    return ( self.x*self.x + self.y*self.y + self.z*self.z )
end

function Vector3D:Length2D()
    return math.sqrt(self.x*self.x + self.y*self.y)
end

function Vector3D:Dot(v)
    return ( self.x * v.x + self.y * v.y + self.z * v.z )
end

--- Adds with a single float number instead of another Vector3D
--- @param fl number
--- @return userdata
function Vector3D:AddSingle(fl)
    local SolvedVector = Vector3D:new()
    SolvedVector.x = self.x + fl
    SolvedVector.y = self.y + fl
    SolvedVector.z = self.z + fl
    return self
end

--- Subtracts with a single float number instead of another Vector3D
--- @param fl number
--- @return userdata
function Vector3D:SubtractSingle(fl)
    local SolvedVector = Vector3D:new()
    SolvedVector.x = self.x - fl
    SolvedVector.y = self.y - fl
    SolvedVector.z = self.z - fl
    return SolvedVector
end

--- Multiplies with a single float number instead of another Vector3D
--- @param fl number
--- @return userdata
function Vector3D:MultiplySingle(fl)
    local SolvedVector = Vector3D:new()
    SolvedVector.x = self.x * fl
    SolvedVector.y = self.y * fl
    SolvedVector.z = self.z * fl
    return SolvedVector
end

--- Divides with a single float number instead of another Vector3D
--- @param fl number
--- @return userdata
function Vector3D:DivideSingle(fl)
    local SolvedVector = Vector3D:new()
    SolvedVector.x = self.x / fl
    SolvedVector.y = self.y / fl
    SolvedVector.z = self.z / fl
    return SolvedVector
end

function Vector3D:Normalized()

    local res = self:Copy()
    local l = res:Length()
    if ( l ~= 0.0 ) then
        res = res:DivideSingle(l)
    else
        res.x = 0
        res.y = 0
        res.z = 0
    end
    return res
end

function Vector3D:DistTo(vOther)

    local delta = Vector3D:new()

    delta.x = self.x - vOther.x
    delta.y = self.y - vOther.y
    delta.z = self.z - vOther.z

    return delta:Length()
end

function Vector3D:DistTo2D(vOther)

    local delta = Vector3D:new()

    delta.x = self.x - vOther.x
    delta.y = self.y - vOther.y

    return delta:Length2D()
end

function Vector3D:DistToManhattanVer(vOther)

    local delta = Vector3D:new()

    delta.x = math.abs(self.x - vOther.x)
    delta.y = math.abs(self.y - vOther.y)
    delta.z = math.abs(self.z - vOther.z)

    return delta.x + delta.y + delta.z
end

function Vector3D:DistToSqr(vOther)

    local delta = Vector3D:new()

    delta.x = self.x - vOther.x
    delta.y = self.y - vOther.y
    delta.z = self.z - vOther.z

    return delta:LengthSqr()
end

-- Global/Static/Helper functions
function Vector3D:IsValid(vector)
    if vector.x ~= vector.x or vector.y ~= vector.y or vector.z ~= vector.z then
        return false
    end

    return true
end

local Angle = {
    x,y,z
}
Angle.__index = Angle

function Angle:new(x,y,z)
    local Object = {}
    setmetatable(Object,self)
    Object.x = x or 0.00
    Object.y = y or 0.00
    Object.z = z or 0.00
    return Object
end

function Angle:NewCustom(CustomAngle)
    local Object = {}
    setmetatable(Object,self)
    Object.x = CustomAngle.pitch or CustomAngle.x or 0.00
    Object.y = CustomAngle.yaw or CustomAngle.y or 0.00
    Object.z = CustomAngle.roll or CustomAngle.z or 0.00
    return Object
end

--- Makes a copy of itself
function Angle:Copy()
    local CopyVector = Angle:new()
    CopyVector.x = self.x
    CopyVector.y = self.y
    CopyVector.z = self.z
    return CopyVector
end

--- Copies another Vector's members
function Angle:CopyOther(v)
    self.x = v.x
    self.y = v.y
    self.z = v.z
end

function Angle:SetMembers(x, y, z)
    self.x = x
    self.y = y
    self.z = z
end

function Angle:SetX(x)
    self.x = x
end

function Angle:SetY(y)
    self.y = y
end

function Angle:SetZ(z)
    self.z = z
end

function Angle:GetX(x)
    return self.x
end

function Angle:GetY(y)
    return self.y
end

function Angle:GetZ(z)
    return self.z
end

function Angle:Zero()
    self.x = 0.00
    self.y = 0.00
    self.z = 0.00
end

function Angle:PrintValue()
    print("x : " .. self.x .. " y : " .. self.y .. " z : " .. self.z)
end

-- For copy pasting into setpos command
function Angle:PrintValueClean()
    print(self.x .. " " .. self.y .. " " .. self.z)
end

function Angle:__add(v)
    local SolvedVector = Angle:new()
    SolvedVector.x = self.x + v.x
    SolvedVector.y = self.y + v.y
    SolvedVector.z = self.z + v.z
    return SolvedVector
end

function Angle:__sub(v)
    local SolvedVector = Angle:new()
    SolvedVector.x = self.x - v.x
    SolvedVector.y = self.y - v.y
    SolvedVector.z = self.z - v.z
    return SolvedVector
end

function Angle:__mul(v)
    local SolvedVector = Angle:new()
    SolvedVector.x = self.x * v.x
    SolvedVector.y = self.y * v.y
    SolvedVector.z = self.z * v.z
    return SolvedVector
end

function Angle:__div(v)
    local SolvedVector = Angle:new()
    SolvedVector.x = self.x / v.x
    SolvedVector.y = self.y / v.y
    SolvedVector.z = self.z / v.z
    return SolvedVector
end

function Angle:__mod(v)
    local SolvedVector = Angle:new()
    SolvedVector.x = self.x % v.x
    SolvedVector.y = self.y % v.y
    SolvedVector.z = self.z % v.z
    return SolvedVector
end

function Angle:__pow(v)
    local SolvedVector = Angle:new()
    SolvedVector.x = self.x ^ v.x
    SolvedVector.y = self.y ^ v.y
    SolvedVector.z = self.z ^ v.z
    return SolvedVector
end

function Angle:__eq(v)
    if self.x ~= v.x then return false end
    if self.y ~= v.y then return false end
    if self.z ~= v.z then return false end
    return true
end

function Angle:__lt(v) -- <
    if self.x >= v.x then return false end
    if self.y >= v.y then return false end
    if self.z >= v.z then return false end
    return true
end

function Angle:__le(v)  -- <=
    if self.x > v.x then return false end
    if self.y > v.y then return false end
    if self.z > v.z then return false end
    return true
end

function Angle:Length()
    return math.sqrt( self.x*self.x + self.y*self.y + self.z*self.z )
end

function Angle:LengthSqr()
    return ( self.x*self.x + self.y*self.y + self.z*self.z )
end

--- Adds with a single float number instead of another Vector
--- @param fl number
--- @return userdata
function Angle:AddSingle(fl)
    self.x = self.x + fl
    self.y = self.y + fl
    self.z = self.z + fl
    return self
end

--- Subtracts with a single float number instead of another Vector
--- @param fl number
--- @return userdata
function Angle:SubtractSingle(fl)
    self.x = self.x - fl
    self.y = self.y - fl
    self.z = self.z - fl
    return self
end

--- Multiplies with a single float number instead of another Vector
--- @param fl number
--- @return userdata
function Angle:MultiplySingle(fl)
    self.x = self.x * fl
    self.y = self.y * fl
    self.z = self.z * fl
    return self
end

--- Divides with a single float number instead of another Vector
--- @param fl number
--- @return userdata
function Angle:DivideSingle(fl)
    self.x = self.x / fl
    self.y = self.y / fl
    self.z = self.z / fl
    return self
end


function Angle:NormalizeTo180()


    self.x = math.fmod(self.x,178)

    if (self.x > 89) then
		self.x = 89
    elseif (self.x < -89) then
		self.x = -89
    end

    self.y = math.fmod(self.y,360)
    if (self.y > 180) then
		self.y = self.y - 360
    elseif (self.y < -180) then
		self.y = self.y + 360
    end

    self.z = 0.0

end

function Angle:NormalizeTo360()
    self.x = math.fmod(self.x,178)

    if (self.x > 89) then
		self.x = 89
    elseif (self.x < -89) then
		self.x = -89
    end

    self.y = math.fmod(self.y,360)

    if (self.y < 0) then
		self.y = self.y + 360
    end

    self.z = 0.0


end


function Angle:Normalized()

    local res = self:Copy()
    local fl = res:Length()
    if ( fl ~= 0.0 ) then
        res = res:DivideSingle(fl)
    else
        res.x = 0.00
        res.y = 0.00
        res.z = 0.00
    end
    return res
end

-- Global/Static/Helper functions
function Angle:IsValid(angle)
    if angle.x ~= angle.x or angle.y ~= angle.y or angle.z ~= angle.z then
        return false
    end

    return true
end

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

    self:XMScalarSinCos(sp,cp,math.rad(angles.x or angles.pitch))
    self:XMScalarSinCos(sy,cy,math.rad(angles.y or angles.yaw))

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

    self:XMScalarSinCos(sp,cp,math.rad(angles.x or angles.pitch))
    self:XMScalarSinCos(sy,cy,math.rad(angles.y or angles.yaw))
    self:XMScalarSinCos(sr,cr,math.rad(angles.z or angles.roll))


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

function Math:SmoothAngle( from , to , percent ,smoothmethod,shouldRandomize)

    percent = percent or 25

    if shouldRandomize then
        percent = math.random(percent)
        -- print(percent)
    end

    from:NormalizeTo180()
    to:NormalizeTo180()
	local VecDelta = from - to


    VecDelta:NormalizeTo180()
    -- VecDelta:PrintValueClean()
    -- print(math.abs(VecDelta.x))
    -- print(math.abs(VecDelta.y))
    if smoothmethod == 1 then
        VecDelta.x = VecDelta.x * ( percent / 100.0 )
	    VecDelta.y = VecDelta.y * ( percent / 100.0 )
    else
        VecDelta.x = Math:Clamp(VecDelta.x,-(percent / 10),(percent / 10))
	    VecDelta.y = Math:Clamp(VecDelta.y,-(percent / 10),(percent / 10))
    end


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
    local endPos = eyePos + (myDir:MultiplySingle(8192))
    local dist = Math:dist_Segment_to_Segment(eyePos, endPos, capsuleA, capsuleB)
    return dist < radius;
end

function Math:VectorTransform(in1,in2,out)
    out.x = in1:Dot(Vector3D:new(in2[0][0],in2[0][1],in2[0][2])) + in2[0][3]
    out.y = in1:Dot(Vector3D:new(in2[1][0],in2[1][1],in2[1][2])) + in2[1][3]
    out.z = in1:Dot(Vector3D:new(in2[2][0],in2[2][1],in2[2][2])) + in2[2][3]
end

local pGetModuleHandle_sig = ffi.cast("uint32_t",utils.opcode_scan("engine.dll", "FF 15 ? ? ? ? 85 C0 74 0B"))
local pGetModuleHandle = ffi.cast("uint32_t**", ffi.cast("uint32_t", pGetModuleHandle_sig) + 2)[0][0]
local fnGetModuleHandle = ffi.cast("uint32_t(__stdcall*)(const char*)", pGetModuleHandle)

local function GetVirtualFunction(address,index)
    local vtable = ffi.cast("uint32_t**",address)[0]
    return ffi.cast("uint32_t",vtable[index])
 end
 local GetStudioModel = utils.get_vfunc("engine.dll","VModelInfoClient004",32,"uint32_t (__thiscall*) (void* ThisPointer,uint32_t model)" )

ffi.cdef
[[

    typedef float matrix3x4_t[3][4];

    typedef uint32_t    (__thiscall* GetModel_FN)   (uint32_t EntityAddress);
    typedef bool        (__thiscall* SetupBones_FN)  (uint32_t EntityAddress,matrix3x4_t *pBoneToWorldOut, int nMaxBones, int boneMask, float currentTime);
]]

local function ClientRenderable__GetModel(EntityAddress)
    local EntityAddress = ffi.cast("uint32_t",EntityAddress)
    local renderable = ffi.cast("uint32_t*",EntityAddress + 0x4 )
    if not EntityAddress or not renderable[0] then
        return nil
    end

    local GetModel_VFunc = ffi.cast("GetModel_FN",GetVirtualFunction(renderable,8))
    return GetModel_VFunc(ffi.cast("uint32_t",renderable))

end

local function ClientRenderable__SetupBones(EntityAddress,pBoneToWorldOut, nMaxBones, boneMask, currentTime)
    local EntityAddress = ffi.cast("uint32_t",EntityAddress)
    local renderable = ffi.cast("uint32_t*",EntityAddress + 0x4 )
    if not EntityAddress or not renderable[0] then
        return nil
    end
    -- print("client.dll : ",fnGetModuleHandle("client.dll"))
    -- print("SetupBones : " , tonumber(GetVirtualFunction(renderable,13)))
    local SetupBones_VFunc = ffi.cast("SetupBones_FN",GetVirtualFunction(renderable,13))
    return SetupBones_VFunc(ffi.cast("uint32_t",renderable),pBoneToWorldOut, nMaxBones, boneMask, currentTime)

end

local function GetHitboxSet(studiohdr,i)
    local studiohdr_ptr = ffi.cast("uint32_t*",studiohdr)
    local studiohdr_raw = ffi.cast("uint32_t",studiohdr)

    if i > ffi.cast("int32_t*",studiohdr_raw + 0x00AC)[0] then
        return nil
    end
    local hitboxsetindex = ffi.cast("int32_t*",studiohdr_raw + 0x00B0 )[0]
    return ffi.cast("uint32_t",studiohdr_raw + hitboxsetindex + (i * 12))
end

local function GetHitbox(hitboxset,i)
    local hitboxset_ptr = ffi.cast("uint32_t*",hitboxset)
    local hitboxset_raw = ffi.cast("uint32_t",hitboxset)

    if i > ffi.cast("int32_t*",hitboxset_raw + 0x4)[0] then
        return nil
    end
    local hitboxsetindex = ffi.cast("int32_t*",hitboxset_raw + 0x8 )[0]

    return ffi.cast("uint32_t",hitboxset_raw + hitboxsetindex + (i * 68))
end

local function GetStudioBox(EntityAddress,hitbox_id)
    local boneMatrix = ffi.new("matrix3x4_t[128]")

    if ClientRenderable__SetupBones(EntityAddress,boneMatrix,128,0x00000100,0.0) then
        local studio_model = GetStudioModel(ClientRenderable__GetModel(EntityAddress))
        if studio_model then
            local hitbox = GetHitbox(GetHitboxSet(studio_model,0),hitbox_id)
            if hitbox then
                return hitbox
            end
        end
    end
    return nil
end

local function GetHitboxBounds(EntityAddress,hitbox_id)
    local boneMatrix = ffi.new("matrix3x4_t[128]")
    if ClientRenderable__SetupBones(EntityAddress,boneMatrix,128,0x00000100,0.0) then
        local studio_model = GetStudioModel(ClientRenderable__GetModel(EntityAddress))
        if studio_model then
            local hitbox = GetHitbox(GetHitboxSet(studio_model,0),hitbox_id)
            if hitbox then

                local hitbox_local_min = Vector3D:new(ffi.cast("float*",hitbox + 8)[0],ffi.cast("float*",hitbox + 12)[0],ffi.cast("float*",hitbox + 16)[0])
                local hitbox_local_max = Vector3D:new(ffi.cast("float*",hitbox + 20)[0],ffi.cast("float*",hitbox + 24)[0],ffi.cast("float*",hitbox + 28)[0])

                local hitbox_world_min = Vector3D:new()
                local hitbox_world_max = Vector3D:new()

                Math:VectorTransform(hitbox_local_min,boneMatrix[ffi.cast("int*",hitbox)[0]],hitbox_world_min)
                Math:VectorTransform(hitbox_local_max,boneMatrix[ffi.cast("int*",hitbox)[0]],hitbox_world_max)

                local hitbox_radius = ffi.cast("float*",hitbox + 48)[0]

                return { hitbox_world_min,hitbox_world_max,hitbox_radius }
            end
        end
    end
    return nil
end

local HalfHumanWidth        =   16
local HalfHumanHeight       =   35.5
local HumanHeight           =   71
local HumanEyeHeight        =   62
local HumanCrouchHeight     =   55
local HumanCrouchEyeHeight  =   37

local Advapi32 = ffi.load("Advapi32.dll")
ffi.cdef[[
	uint32_t 	CreateFileA     (const char*,uint32_t,uint32_t,uint32_t,uint32_t,uint32_t,uint32_t);
	bool 		CloseHandle     (uint32_t);
	uint32_t	GetFileSize     (uint32_t,uint32_t);
	bool		ReadFile        (uint32_t,char *,uint32_t,uint32_t*,uint32_t);
	uint32_t    SetFilePointer  (uint32_t,int32_t,uint32_t,uint32_t);
	uint32_t    GetLastError    ();
    uint32_t    GetFileAttributesA(const char* lpFileName);
    int         GetFileSecurityA(const char* lpFileName,uint32_t RequestedInformation,uint32_t* pSecurityDescriptor,uint32_t nLength,uint32_t* lpnLengthNeeded);
    uint32_t    GetCurrentProcess();
    uint32_t    GetCurrentThread();
    int         OpenProcessToken(uint32_t ProcessHandle,uint32_t DesiredAccess,uint32_t* TokenHandle);
    int         OpenThreadToken(uint32_t ThreadHandle,uint32_t DesiredAccess,int OpenAsSelf,uint32_t* TokenHandle);
    int         ImpersonateLoggedOnUser(uint32_t hToken);
    typedef struct
    {
        uint32_t  nLength;
        uint32_t* lpSecurityDescriptor;
        int   bInheritHandle;
    } SECURITY_ATTRIBUTES, *PSECURITY_ATTRIBUTES, *LPSECURITY_ATTRIBUTES;

]]



ffi.cdef [[
	typedef bool (__thiscall* IsBreakableEntity_FN) (uint32_t EntityAddress);
]]
local IsBreakableEntity = ffi.cast("IsBreakableEntity_FN",utils.opcode_scan("client.dll", "55 8B EC 51 56 8B F1 85 F6 74 68 83 BE"))

ffi.cdef [[
	typedef bool        (__thiscall* IsDrawingLoadingImage_FN)          (uint32_t this);
    typedef bool        (__thiscall* IsClientLocalToActiveServer_FN)    (uint32_t this);
]]
local g_EngineClient = ffi.cast("uint32_t",utils.create_interface("engine.dll","VEngineClient014"))

local function IsDrawingLoadingImage()
    return ffi.cast("IsDrawingLoadingImage_FN",GetVirtualFunction(g_EngineClient , 28))(g_EngineClient)
end

local function IsClientLocalToActiveServer()
    return ffi.cast("IsClientLocalToActiveServer_FN",GetVirtualFunction(g_EngineClient , 197))(g_EngineClient)
end

local g_GameUI = ffi.cast("uint32_t",utils.create_interface("client.dll","GameUI011"))
local g_GameState = ffi.cast("int*",g_GameUI + 0x1E4)

local function GetGameState()
    return g_GameState[0]
end

local clientStatePtr = ffi.cast("uint32_t*",fnGetModuleHandle("engine.dll") + 0x59F194)[0]

local function GetSignOnState()
    local SignOnState = ffi.cast("uint32_t*",(clientStatePtr + 264))[0]
    return SignOnState
end

ffi.cdef[[
    typedef bool(__thiscall* HasC4_FN )(uint32_t this);
]]

local oHasC4 = ffi.cast("HasC4_FN",utils.opcode_scan("client.dll","56 8B F1 85 F6 74 31"))
local function HasC4(PlayerPointer)
    if PlayerPointer then
        return oHasC4(PlayerPointer)
    else
        return false
    end

end

ffi.cdef[[

    typedef struct{
        float x,y,z;
    } Vector;
    typedef bool(__cdecl* LineGoesThroughSmoke_FN)(Vector, Vector);
]]

local LineGoesThroughSmoke = ffi.cast("LineGoesThroughSmoke_FN",utils.opcode_scan("client.dll","55 8B EC 83 EC 08 8B 15 ? ? ? ? 0F 57 C0"))

--alternatives : convar game_type and game_mode
local g_GameTypes = ffi.cast("uint32_t",utils.create_interface("matchmaking.dll","VENGINE_GAMETYPES_VERSION002"))

local IGameTypes = {}
IGameTypes.__index = IGameTypes
setmetatable(IGameTypes,IGameTypes)

ffi.cdef[[
    typedef int (__thiscall* GetCurrentGameType_FN) (uint32_t this);
    typedef int (__thiscall* GetCurrentGameMode_FN) (uint32_t this);
]]

function IGameTypes:GetCurrentGameType()
    return ffi.cast("GetCurrentGameType_FN",GetVirtualFunction(g_GameTypes,8))(g_GameTypes)
end

function IGameTypes:GetCurrentGameMode()
    return ffi.cast("GetCurrentGameMode_FN",GetVirtualFunction(g_GameTypes,9))(g_GameTypes)
end




local function DumpTable(o)
    if type(o) == 'table' then
        local s = '{ '
        for k,v in pairs(o) do
            if type(k) ~= 'number' then k = '"'..k..'"' end
            s = s .. '['..k..'] = ' .. DumpTable(v) .. ','
        end
        return s .. '} '
    else
        return tostring(o)
    end
end

local FileBuffer = {
    Position = 0,
    Buffer = 0,
    Size = 0
}

function FileBuffer:Create(DefaultPosition,Buffer,Size)
    local newTable = {}
    setmetatable(newTable,self)
    self.__index = self
    newTable.Position = DefaultPosition or 0
    newTable.Buffer = Buffer or 0
    newTable.Size = Size or 0
    return newTable
end


function FileBuffer:Read(SizeToRead)
    local TempVariable = ffi.typeof("unsigned char[?]")(SizeToRead,"")
    local BufferPointer = ffi.cast("uint32_t",self.Buffer)
    local BufferPointerOffsetByPosition = BufferPointer + self.Position
    ffi.copy(TempVariable, ffi.cast("const void*",BufferPointerOffsetByPosition),SizeToRead)

    self.Position = self.Position + SizeToRead
    return TempVariable
end
local Walkbot_MenuGroup = ui.create("Walkbot", "Walkbot")
Walkbot_MenuGroup:label("The settings below are advanced and it's optional to change them.")

local IterationPerTick_Slider = Walkbot_MenuGroup:slider("Path finding iteration per ticks",1,1000,1,1)
IterationPerTick_Slider:set_tooltip("Increasing this will make the path finding faster,at the cost of your FPS.")

local Difference2DLimit = Walkbot_MenuGroup:slider("Distance to node limit",1.0,500.0,20.0,1)
Difference2DLimit:set_tooltip("Increasing this will make the path finding faster,at the cost of your FPS.")

local Z_Limit = Walkbot_MenuGroup:slider("Distance to node Z-limit",1.0, 500.0,50.0,1.0)
Z_Limit:set_tooltip("Same as above,but this controls the z limit.This needs to be more loose since its hard to accurately get to the z position of the node.")

local ThresholdTime = Walkbot_MenuGroup:slider("Obstacle avoid time limit",1,60,1,1)
ThresholdTime:set_tooltip("How long you want each method to avoid obstacles to last,in seconds.")

local ThresholdTimeReset = Walkbot_MenuGroup:slider("Obstacle avoid cycle reset time limit",1,60,1,1)
ThresholdTimeReset:set_tooltip("Time after moving to reset the obstacle avoiding cycle so the next time we're stuck,we will loop from the first method again,in seconds.")

local TimeToMove = Walkbot_MenuGroup:slider("Enemy Last Seen Threshold",0.0,60.0,1.0,1.0)
TimeToMove:set_tooltip("How long you should stay slow walking / scoped / crouching since the last time you saw an enemy.")

local Target_Dormant = Walkbot_MenuGroup:switch("Target Dormant Player",true)
Target_Dormant:set_tooltip("Targets non-networked players.")

local Target_TeamMate = Walkbot_MenuGroup:switch("Follow Teammate",false)
Target_TeamMate:set_tooltip("Targets team-mate,as they usually know where to go,rather than randomly going places.Best used for MM.")

local Aimbot_MenuGroup = ui.create("Aimbot", "Aimbot")

local Aimbot_Enable = Aimbot_MenuGroup:switch("Enable",false)
Aimbot_Enable:set_tooltip("Global switch for the aimbot.")

local Aimbot_SilentAim = Aimbot_MenuGroup:switch("Silent Aim",false)
Aimbot_SilentAim:set_tooltip("Prevents the aiming angles from applying to your engine angles.")

local Aimbot_SmokeCheck = Aimbot_MenuGroup:switch("Smoke Check",true)
Aimbot_SmokeCheck:set_tooltip("Prevents shooting if enemy is behind smoke.")

local BodyAim_Switch = Aimbot_MenuGroup:switch("Prefer body aim",true)
BodyAim_Switch:set_tooltip("Prioritizes aiming for the body.If not possible,aim for the head.")

local Aimbot_Speed = Aimbot_MenuGroup:slider("Speed",1,100,20,1)
Aimbot_Speed:set_tooltip("Controls the speed of the aimbot.")

local Aimbot_Randomize_Speed = Aimbot_MenuGroup:switch("Randomize Speed",false)
Aimbot_Randomize_Speed:set_tooltip("Will randomize the speed with the above value as the limit.")

local Aimbot_Smoothing_Method_Combo_Table = {
    "Constant",
    "Linear"
}
local Aimbot_Smoothing_Method = Aimbot_MenuGroup:combo("Smoothing Method",Aimbot_Smoothing_Method_Combo_Table)
Aimbot_Smoothing_Method:set_tooltip("Linear : the aimbot will have varying speeds.It will try to turn faster if the angle to target is bigger.Looks more obvious.\n\nConstant : it will turn at a constant speed regardless of how far the target angle is.Looks more robotic and slower but is more consistent.")

local Aimbot_Default_Target_Combo_Table = {
    "None",
    "Node",
    "Random",
    "Closest enemy"
}
local Aimbot_Default_Target = Aimbot_MenuGroup:combo("Default Target",Aimbot_Default_Target_Combo_Table)
Aimbot_Default_Target:set_tooltip("Default aiming direction if there's no enemy.\n\nNone: Won't update the angle,will only aim at the last angle.\n\nNode: Aims at the next node in the path.\n\nRandom: Aims at a random angle.\n\nClosest enemy: Aims at the nearest enemy,will make you aim through walls.")


-- local Aimbot_Hitchance = Menu.SliderInt("Aimbot","Aimbot","Hitchance",50,1,100,"Enforces more accuracy to the aimbot's shots.")
local Aimbot_Hitchance = Aimbot_MenuGroup:slider("Hitchance",1,100,50,1)
Aimbot_Hitchance:set_tooltip("Enforces more accuracy to the aimbot's shots.")

local Aimbot_Hitchance_Method_Combo_Table = {
    "Runtime Random Trace",
    "Runtime Uniform Trace",
    "Pre-calculated Random Trace",
    "Capsule Intersection"
}
local Aimbot_Hitchance_Method = Aimbot_MenuGroup:combo("Hitchance Trace Method",Aimbot_Hitchance_Method_Combo_Table)
Aimbot_Hitchance_Method:set_tooltip("Runtime Random Trace : Pattern of traces is randomly generated on runtime using UserCmd's seed.\n\nRuntime Uniform Trace : The pattern of the traces are uniform/evenly distributed in a circle shape.\n\nPre-calculated Random Trace : Randomness is only calculated once during script startup and is used every time.\n\nCapsule Intersection : Uses simple math to check for intersection instead of engine's tracing,fastest method.")

local Aimbot_Enforce_Hitbox = Aimbot_MenuGroup:switch("Force Shoot Center Hitbox",false)
Aimbot_Enforce_Hitbox:set_tooltip("By default,the aimbot will shoot with whatever angle it is at.With this enabled,the aimbot will forcefully shoot the center of the hitbox,making the shot more accurate.This might make your aimbot look more obvious.")

local Aimbot_AutoScope_Switch = Aimbot_MenuGroup:switch("Auto Scope",true)
Aimbot_AutoScope_Switch:set_tooltip("Automatically scopes in your weapon.")

local Aimbot_AutoUnscope_Switch = Aimbot_MenuGroup:switch("Auto Unscope",true)
Aimbot_AutoUnscope_Switch:set_tooltip("Automatically unscopes your weapon.")

local Aimbot_AutoCrouch_Switch = Aimbot_MenuGroup:switch("Auto Crouch",false)
Aimbot_AutoCrouch_Switch:set_tooltip("Buggy : Fails in some situation.Mostly fails in situations where crouching will make the enemy non visible which will result in an instant uncrouch and then it will loop between crouching and uncrouching causing you to \"jitter crouch\" ")

local Aimbot_AutoReload_Switch = Aimbot_MenuGroup:switch("Auto Reload",true)
Aimbot_AutoReload_Switch:set_tooltip("Automatically reloads your weapon.")

local Aimbot_AutoReload = Aimbot_MenuGroup:slider("Auto Reload Threshold",1,100,25,1)
Aimbot_AutoReload:set_tooltip("If your active weapon's ammo goes below this amount in percentage,it will automatically reload your weapon.")

local Misc_MenuGroup = ui.create("Misc", "Misc")

local AutoQueue_Switch = Misc_MenuGroup:switch("Auto Queue",true)
AutoQueue_Switch:set_tooltip("Automatically queues for you.")

local AutoReconnect_Switch = Misc_MenuGroup:switch("Auto reconnect",true)
AutoReconnect_Switch:set_tooltip("Automatically reconnects to an ongoing match.")

local AutoDisconnect_Switch = Misc_MenuGroup:switch("Auto Disconnect",true)
AutoDisconnect_Switch:set_tooltip("Automatically disconnects upon match end.")

local AutoWeaponSwitch_Switch = Misc_MenuGroup:switch("Auto switch to best weapon",true)
AutoWeaponSwitch_Switch:set_tooltip("Automatically switches to the best weapon in your weapon slots.")

local Precomputed_Seeds = {}

-- Render stuff from other callbacks here.
-- Needs to be transformed to screen position.

local Render_Queue = {

}
-- returns table of items that needs to be bought
local function CustomTableIndexFunction(t,i)
    for _,v in ipairs(t) do
        if v[1] == i then
            return v[2]
        end
    end
end

local function AutoBuyGenerateOptionName(OptionTable)
    local GeneratedTable = {}
    for _,v in ipairs(OptionTable) do
        table.insert(GeneratedTable,v[1])
    end
    return GeneratedTable
end

local function GetIndexFromSelectedCombo(t,index)
    for i = 1,#t do
        if index == t[i] then
            return i - 1
        end
    end
end

local primaryWeapons = {
    {"None",            {nil}       },
    {"AutoSniper",      {"scar20"}  },
    {"Scout",           {"ssg08"}   },
    {"AWP",             {"awp"}     },
    {"M249",            {"m249"}    },
    {"AUG | SG553",     {"aug"}     },
    {"AK  |  M4",       {"m4a1"}    },
    {"Famas  |  Galil", {"galilar"} },
    {"P90",             {"p90"}     },
    {"UMP-45",          {"ump45"}   },
    {"XM1014",          {"xm1014"}  },
    {"Bizon",           {"bizon"}   },
    {"Mag7/Sawed-Off",  {"mag7"}    },
    {"Negev",           {"negev"}   },
    {"MP7/MP5",         {"mp7"}     },
    {"MP9/Mac-10",      {"mp9"}     },
    {"Nova",            {"nova"}    }
}

primaryWeapons.__index = CustomTableIndexFunction
setmetatable(primaryWeapons,primaryWeapons)

local secondaryWeapons = {
    {"None",                        {nil}       },
    {"Dual Elites",                 {"elite"}   },
    {"Desert Eagle | R8 Revolver",  {"deagle"}  },
    {"Five Seven | Tec 9",          {"tec9" }   },
    {"P250",                        {"p250"}    }
}
secondaryWeapons.__index = CustomTableIndexFunction
setmetatable(secondaryWeapons,secondaryWeapons)

local equipments = {
    {"Kevlar Vest",                 {"vest"}                    },
    {"Kevlar Vest + Helmet",        {"vest", "vesthelm" }       },
    {"Grenade",                     {"hegrenade"}               },
    {"Flashbang",                   {"flashbang"}               },
    {"Smoke Grenade",               {"smokegrenade"}            },
    {"Decoy Grenade",               {"decoy"}                   },
    {"Molotov | Incindeary Grenade",{"molotov", "incgrenade" }  }
}
equipments.__index = CustomTableIndexFunction
setmetatable(equipments,equipments)

local AutoBuy_MenuGroup = ui.create("Auto Buy", "Auto Buy")
local AutoBuy_Switch = AutoBuy_MenuGroup:switch("Enable",false)
local AutoBuy_PrimaryWeapon = AutoBuy_MenuGroup:combo("Primary Weapon",AutoBuyGenerateOptionName(primaryWeapons))
local AutoBuy_SecondaryWeapon = AutoBuy_MenuGroup:combo("Secondary Weapon",AutoBuyGenerateOptionName(secondaryWeapons))
local AutoBuy_Equipment = AutoBuy_MenuGroup:selectable("Equipment",AutoBuyGenerateOptionName(equipments))



local function AutoBuy()
    local final_command = ""

    for k,v in ipairs(primaryWeapons[AutoBuy_PrimaryWeapon:get()]) do
        if v then
            final_command = final_command  .. "buy \"" .. v .. "\" ;"
        end
    end



    local secondaryWeapon_command = "buy"
    for k,v in ipairs(secondaryWeapons[AutoBuy_SecondaryWeapon:get()]) do
        if v then
            final_command = final_command  .. "buy \"" .. v .. "\" ;"
        end
    end


    local equipment_command = "buy"
    for k,v in ipairs(AutoBuy_Equipment:get()) do
        for i,j in ipairs(equipments[v])do
            if j then
                final_command = final_command  .. "buy \"" .. j .. "\" ;"
            end
        end
    end
    -- print(final_command)
    utils.console_exec(final_command)
end

local buttons = {
    IN_ATTACK = 1,
    IN_JUMP = 2,
    IN_DUCK = 4,
    IN_FORWARD = 8,
    IN_BACK = 16,
    IN_USE = 32,
    IN_CANCEL = 64,
    IN_LEFT = 128,
    IN_RIGHT = 256,
    IN_MOVELEFT = 512,
    IN_MOVERIGHT = 1024,
    IN_ATTACK2 = 2048,
    IN_RUN = 4096,
    IN_RELOAD = 8192,
    IN_ALT1 = 16384,
    IN_ALT2 = 32768,
    IN_SCORE = 65536,
    IN_SPEED = 131072,
    IN_WALK = 262144,
    IN_ZOOM = 524288,
    IN_WEAPON1 = 1048576,
    IN_WEAPON2 = 2097152,
    IN_BULLRUSH = 4194304,
    IN_GRENADE1 = 8388608,
    IN_GRENADE2 = 16777216,
    IN_LOOKSPIN = 33554432

}

local e_hitboxes = {
    HEAD	        = 0,
    NECK	        = 1,
    PELVIS	        = 2,
    BODY	        = 3,
    THORAX	        = 4,
    CHEST	        = 5,
    UPPER_CHEST	    = 6,
    RIGHT_THIGH	    = 7,
    LEFT_THIGH	    = 8,
    RIGHT_CALF	    = 9,
    LEFT_CALF	    = 10,
    RIGHT_FOOT	    = 11,
    LEFT_FOOT	    = 12,
    RIGHT_HAND	    = 13,
    LEFT_HAND	    = 14,
    RIGHT_UPPER_ARM	= 15,
    RIGHT_FOREARM	= 16,
    LEFT_UPPER_ARM	= 17,
    LEFT_FOREARM    = 18
}

local Hitboxes_Normal = {
	e_hitboxes.HEAD			    ,
	e_hitboxes.NECK	            ,

	e_hitboxes.UPPER_CHEST	    ,
	e_hitboxes.CHEST	        ,
	e_hitboxes.THORAX	        ,
	e_hitboxes.BODY	            ,
	e_hitboxes.PELVIS	        ,

    e_hitboxes.LEFT_FOOT        ,
    e_hitboxes.RIGHT_FOOT       ,
    e_hitboxes.LEFT_HAND        ,
    e_hitboxes.RIGHT_HAND       ,
    e_hitboxes.LEFT_CALF        ,
    e_hitboxes.RIGHT_CALF       ,
    e_hitboxes.LEFT_FOREARM     ,
    e_hitboxes.RIGHT_FOREARM    ,
    e_hitboxes.LEFT_THIGH       ,
    e_hitboxes.RIGHT_THIGH      ,
    e_hitboxes.LEFT_UPPER_ARM   ,
    e_hitboxes.RIGHT_UPPER_ARM  ,

}

local Hitboxes_BodyAim = {

    e_hitboxes.PELVIS	        ,
    e_hitboxes.THORAX	        ,
    e_hitboxes.BODY	            ,
    e_hitboxes.CHEST	        ,
	e_hitboxes.UPPER_CHEST	    ,


	e_hitboxes.LEFT_FOOT        ,
    e_hitboxes.RIGHT_FOOT       ,
    e_hitboxes.LEFT_HAND        ,
    e_hitboxes.RIGHT_HAND       ,
    e_hitboxes.LEFT_CALF        ,
    e_hitboxes.RIGHT_CALF       ,
    e_hitboxes.LEFT_FOREARM     ,
    e_hitboxes.RIGHT_FOREARM    ,
    e_hitboxes.LEFT_THIGH       ,
    e_hitboxes.RIGHT_THIGH      ,
    e_hitboxes.LEFT_UPPER_ARM   ,
    e_hitboxes.RIGHT_UPPER_ARM  ,


	e_hitboxes.NECK	            ,
	e_hitboxes.HEAD

}

local CSWeaponType =
{
	WEAPONTYPE_KNIFE            = 0,
	WEAPONTYPE_PISTOL           = 1,
	WEAPONTYPE_SUBMACHINEGUN    = 2,
	WEAPONTYPE_RIFLE            = 3,
	WEAPONTYPE_SHOTGUN          = 4,
	WEAPONTYPE_SNIPER_RIFLE     = 5,
	WEAPONTYPE_MACHINEGUN       = 6,
	WEAPONTYPE_C4               = 7,
	WEAPONTYPE_PLACEHOLDER      = 8,
	WEAPONTYPE_GRENADE          = 9,
	WEAPONTYPE_UNKNOWN          = 10
};

local MAX_NAV_TEAMS = 2

local NavAttributeType = {
    NAV_MESH_INVALID		= 0,
    NAV_MESH_CROUCH			= 0x0000001, -- must crouch to use this node/area
    NAV_MESH_JUMP			= 0x0000002, -- must jump to traverse this area (only used during generation)
    NAV_MESH_PRECISE		= 0x0000004, -- do not adjust for obstacles, just move along area
    NAV_MESH_NO_JUMP		= 0x0000008, -- inhibit discontinuity jumping
    NAV_MESH_STOP			= 0x0000010, -- must stop when entering this area
    NAV_MESH_RUN			= 0x0000020, -- must run to traverse this area
    NAV_MESH_WALK			= 0x0000040, -- must walk to traverse this area
    NAV_MESH_AVOID			= 0x0000080, -- avoid this area unless alternatives are too dangerous
    NAV_MESH_TRANSIENT		= 0x0000100, -- area may become blocked, and should be periodically checked
    NAV_MESH_DONT_HIDE		= 0x0000200, -- area should not be considered for hiding spot generation
    NAV_MESH_STAND			= 0x0000400, -- bots hiding in this area should stand
    NAV_MESH_NO_HOSTAGES	= 0x0000800, -- hostages shouldn't use this area
	NAV_MESH_STAIRS			= 0x0001000, -- this area represents stairs, do not attempt to climb or jump them - just walk up
	NAV_MESH_NO_MERGE		= 0x0002000, -- don't merge this area with adjacent areas
    NAV_MESH_OBSTACLE_TOP	= 0x0004000, -- this nav area is the climb point on the tip of an obstacle
    NAV_MESH_CLIFF			= 0x0008000, -- this nav area is adjacent to a drop of at least CliffHeight

    NAV_MESH_FIRST_CUSTOM	= 0x00010000, -- apps may define custom app-specific bits starting with this value
    NAV_MESH_LAST_CUSTOM	= 0x04000000, -- apps must not define custom app-specific bits higher than with this value

    NAV_MESH_HAS_ELEVATOR	= 0x40000000, -- area is in an elevator's path
	NAV_MESH_NAV_BLOCKER	= 0x80000000  -- area is blocked by nav blocker ( Alas, needed to hijack a bit in the attributes to get within a cache line [7/24/2008 tom])
}

local NavDirType = {
    NORTH = 0,
    EAST = 1,
    SOUTH = 2,
    WEST = 3,

    NUM_DIRECTIONS = 4
}

local NavCornerType = {
    NORTH_WEST = 0,
    NORTH_EAST = 1,
    SOUTH_EAST = 2,
    SOUTH_WEST = 3,

    NUM_CORNERS = 4
}

local function AddDirectionVector(v,dir,amount)
    if dir == NavDirType.NORTH then
        v.y = v.y - amount
        return
    elseif dir == NavDirType.SOUTH then
        v.y = v.y + amount
        return
    elseif dir == NavDirType.EAST then
        v.x = v.x + amount
        return
    elseif dir == NavDirType.WEST then
        v.x = v.x - amount
        return
    end
end

local Ray = {
    from    = Vector3D:new(0.0,0.0,0.0),
    to      = Vector3D:new(0.0,0.0,0.0)
}

function Ray:new(from,to)
    local newTable = {}
    setmetatable(newTable,self)
    self.__index = self
    newTable.from = from or Vector3D:new(0.0,0.0,0.0)
    newTable.to = to or Vector3D:new(0.0,0.0,0.0)
    return newTable
end

local NavConnect = {
    id = 0,
    area = 0,
    length = 0.0
}

function NavConnect:new()
    local newTable = {}
    setmetatable(newTable,self)
    self.__index = self
    newTable.id = 0
    newTable.area = 0
    newTable.length = 0.0
    return newTable
end

local HidingSpot = {
    ENUM = {
        IN_COVER = 0x01,    -- in a corner with good hard cover nearby
        GOOD_SNIPER_SPOT = 0x02, -- had at least one decent sniping corridor
        IDEAL_SNIPER_SPOT = 0x04, -- can see either very far, or a large area, or both
        EXPOSED = 0x08 -- spot in the open, usually on a ledge or cliff
    },

    m_pos = Vector3D:new(0.0,0.0,0.0),
    m_id = 0,
    m_flags = 0
}

function HidingSpot:new()
    local newTable = {}
    setmetatable(newTable,self)
    self.__index = self
    newTable.m_pos = Vector3D:new(0.0,0.0,0.0)
    newTable.m_id = 0
    newTable.m_flags = 0
    return newTable
end

local SpotEncounter = {
    from = NavConnect:new(),
    fromDir = NavDirType.NUM_DIRECTIONS,
    to = NavConnect:new(),
    toDir = NavDirType.NUM_DIRECTIONS,
    path = Ray:new(), -- the path segment
    spots = {} -- list of spots to look at, in order of occurrence
}

function SpotEncounter:new()
    local newTable = {}
    setmetatable(newTable,self)
    self.__index = self
    newTable.from = NavConnect:new()
    newTable.fromDir = NavDirType.NUM_DIRECTIONS
    newTable.to = NavConnect:new()
    newTable.toDir = NavDirType.NUM_DIRECTIONS
    newTable.path = Ray:new()
    newTable.spots = {}
    return newTable
end

local SpotOrder = {
    t = 0.0, -- parametric distance along ray where this spot first has LOS to our path
    spot = 0, -- the spot to look at
    id = 0 -- spot ID for save/load
}

function SpotOrder:new()
    local newTable = {}
    setmetatable(newTable,self)
    self.__index = self
    newTable.t = 0.0
    newTable.spot = 0
    newTable.id = 0
    return newTable
end

local CNavLadder = {
    ENUM_LadderDirectionType = {
        LADDER_UP = 0,
        LADDER_DOWN = 1,

        NUM_LADDER_DIRECTIONS = 2
    },
    m_id = 0,

    m_top = Vector3D:new(0.0,0.0,0.0),
    m_bottom = Vector3D:new(0.0,0.0,0.0),

    m_normal = Vector3D:new(0.0,0.0,0.0),

    m_length = 0.0,
    m_width = 0.0,

    m_topForwardArea = {},					    -- the area at the top of the ladder
    m_topLeftArea = {},
    m_topRightArea = {},
    m_topBehindArea = {},						-- area at top of ladder "behind" it - only useful for descending
    m_bottomArea = {}							-- the area at the bottom of the ladder
}

function CNavLadder:new()
    local newTable = {}
    setmetatable(newTable,self)
    self.__index = self

    newTable.m_top = Vector3D:new(0.0,0.0,0.0)
    newTable.m_bottom = Vector3D:new(0.0,0.0,0.0)
    newTable.m_normal = Vector3D:new(0.0,0.0,0.0)

    newTable.m_length = 0.0
    newTable.m_width = 0.0

    newTable.m_topForwardArea = {}					    -- the area at the top of the ladder
    newTable.m_topLeftArea = {}
    newTable.m_topRightArea = {}
    newTable.m_topBehindArea = {}					    -- area at top of ladder "behind" it - only useful for descending
    newTable.m_bottomArea = {}							-- the area at the bottom of the ladder
    return newTable
end

function CNavLadder:SetDir(dir)
    self.m_dir = dir

    self.m_normal = Vector3D:new(0.0,0.0,0.0)
    AddDirectionVector(self.m_normal,self.m_dir,1.0)

end

--nvm,not needed
--local OneWayLink = {
--    destArea = nil,
--    area = nil,
--    backD = 0
--}
--
--function OneWayLink:new()
--    local newTable = {}
--    setmetatable(newTable,self)
--    self.__index = self
--    newTable.destArea = nil
--    newTable.area = nil
--    newTable.backD = 0
--    return newTable
--end

local NavLadderConnect = {
    id = 0,
    ladder = 0
}

function NavLadderConnect:new()
    local newTable = {}
    setmetatable(newTable,self)
    self.__index = self
    newTable.id = 0
    newTable.ladder = 0
    return newTable
end

local AreaBindInfo = {
    area = 0,
    id = 0,
    attributes = 0
}

function AreaBindInfo:new()
    local newTable = {}
    setmetatable(newTable,self)
    self.__index = self
    newTable.area = 0
    newTable.id = 0
    newTable.attributes = 0
    return newTable
end

local CNavArea = {
    m_id = 0,
    m_nwCorner = Vector3D:new(0.00,0.00,0.00), --North-west corner
    m_seCorner = Vector3D:new(0.00,0.00,0.00), --South-east corner

    m_invDxCorners = 0.0, -- TODO: What is this?
    m_invDzCorners = 0.0, -- TODO: What is this?

    m_neY = 0.0, -- Height of the north-east corner
    m_swY = 0.0, -- Height of the south-west corner

    m_center = Vector3D:new(0.00,0.00,0.00), -- Center
    m_attributeFlags = 0, -- Flags for this area, see NavAttributeType
    m_connect = {}, -- Connected areas for each direction
    m_ladder = { {},{} }, -- Connected ladders
    m_visibleAreaCount = 0, -- Areas visible from this area
    m_lightIntensity = {}, -- 0.0 -> 1.0
    m_uiVisibleAreaCount = 0,
    m_inheritVisibilityFrom = AreaBindInfo:new(),
    m_potentiallyVisibleAreas = {},
    m_hidingSpots = {},
    m_spotEncounters = {},
    m_earliestOccupyTime = {} -- Minimum time to reach this area from the teams spawn
    --m_incomingConnect = {} -- a list of adjacent areas for each direction that connect TO us, but we have no connection back to them
}

function CNavArea:new()
    local newTable = {}
    setmetatable(newTable,self)
    self.__index = self

    newTable.m_id = 0
    newTable.m_nwCorner = Vector3D:new(0.00,0.00,0.00)
    newTable.m_seCorner = Vector3D:new(0.00,0.00,0.00)
    newTable.m_invDxCorners = 0.0
    newTable.m_invDzCorners = 0.0
    newTable.m_neY = 0.0
    newTable.m_swY = 0.0
    newTable.m_center = Vector3D:new(0.00,0.00,0.00)
    newTable.m_attributeFlags = 0
    newTable.m_connect = {}
    newTable.m_ladder = { {},{} }
    newTable.m_visibleAreaCount = 0
    newTable.m_lightIntensity = {}
    newTable.m_uiVisibleAreaCount = 0
    newTable.m_inheritVisibilityFrom = AreaBindInfo:new()
    newTable.m_potentiallyVisibleAreas = {}
    newTable.m_hidingSpots = {}
    newTable.m_spotEncounters = {}
    newTable.m_earliestOccupyTime = {}

    return newTable
end

function CNavArea:__eq(AnotherArea)
    return self.m_id == AnotherArea.m_id
end

function CNavArea:LoadFromFile(Buffer)
    local FunctionName = "CNavArea:LoadFromFile :"

    self.m_id = ffi.cast("uint32_t*",Buffer:Read(4))[0]
    self.m_attributeFlags = ffi.cast("uint8_t*",Buffer:Read(4))[0]

    self.m_nwCorner:SetMemberFromFloatType(ffi.cast("float*",Buffer:Read(12)))

    self.m_seCorner:SetMemberFromFloatType(ffi.cast("float*",Buffer:Read(12)))

    self.m_center.x = (self.m_nwCorner.x + self.m_seCorner.x) / 2.0
    self.m_center.y = (self.m_nwCorner.y + self.m_seCorner.y) / 2.0
    self.m_center.z = (self.m_nwCorner.z + self.m_seCorner.z) / 2.0

    if ((self.m_seCorner.x - self.m_nwCorner.x) > 0.0 and (self.m_seCorner.y - self.m_nwCorner.y) > 0.0) then
        self.m_invDxCorners = 1.0 / ( self.m_seCorner.x - self.m_nwCorner.x );
        self.m_invDzCorners = 1.0 / ( self.m_seCorner.z - self.m_nwCorner.z );

    else
        self.m_invDxCorners = 0.0
        self.m_invDzCorners = 0.0
    end

    self.m_neY = ffi.cast("float*",Buffer:Read(4))[0]
    self.m_swY = ffi.cast("float*",Buffer:Read(4))[0]

    for s = 1,NavDirType.NUM_DIRECTIONS do
        local uiCount = ffi.cast("uint32_t*",Buffer:Read(4))[0]
        for ui = 1,uiCount do
            local nc = NavConnect:new()
            nc.id = ffi.cast("uint32_t*",Buffer:Read(4))[0]
            if(nc.id ~= self.m_id) then
                table.insert(self.m_connect,nc)
            end
        end
    end

    local hidingSpotCount = ffi.cast("uint8_t*",Buffer:Read(1))[0]
    for c = 1,hidingSpotCount do
        local hs = HidingSpot:new()

        hs.m_id = ffi.cast("uint32_t*",Buffer:Read(4))[0]
        hs.m_pos:SetMemberFromFloatType(ffi.cast("float*",Buffer:Read(12)))
        hs.m_flags = ffi.cast("uint8_t*",Buffer:Read(1))[0]

        table.insert(self.m_hidingSpots,hs)
    end

    local uiEncounterSpotCount = ffi.cast("uint32_t*",Buffer:Read(4))[0]
    for ui = 1,uiEncounterSpotCount do
        local se = SpotEncounter:new()

        se.from.id = ffi.cast("uint32_t*",Buffer:Read(4))[0]
        se.fromDir = ffi.cast("uint8_t*",Buffer:Read(1))[0]

        se.to.id = ffi.cast("uint32_t*",Buffer:Read(4))[0]
        se.toDir = ffi.cast("uint8_t*",Buffer:Read(1))[0]

        local spotCount = ffi.cast("uint8_t*",Buffer:Read(1))[0]
        for c = 1,spotCount do
            local order = SpotOrder:new()

            order.id = ffi.cast("uint32_t*",Buffer:Read(4))[0]
            order.t = ffi.cast("float*",Buffer:Read(1))[0]
            table.insert(se.spots,order)
        end
        table.insert(self.m_spotEncounters,se)
    end


    local entry = ffi.cast("uint16_t*",Buffer:Read(2))[0]

    for s = 1,CNavLadder.ENUM_LadderDirectionType.NUM_LADDER_DIRECTIONS do
        local uiCount = ffi.cast("uint32_t*",Buffer:Read(4))[0]

        for ui = 1,uiCount do
            local bSkip = false
            local connect = NavLadderConnect:new()

            connect.id = ffi.cast("uint32_t*",Buffer:Read(4))[0]
            for _,ladder in ipairs(self.m_ladder[s]) do
                if ladder.id == connect.id then
                    b_Skip = true
                    break
                end
            end

            if not bSkip then
                table.insert(self.m_ladder[s],connect)
            end

        end
    end

    for s = 1,MAX_NAV_TEAMS do
        self.m_earliestOccupyTime[s] = ffi.cast("float*",Buffer:Read(4))[0]
    end

    for s = 1,NavCornerType.NUM_CORNERS do
        self.m_lightIntensity[s] = ffi.cast("float*",Buffer:Read(4))[0]
    end

    self.m_uiVisibleAreaCount = ffi.cast("uint32_t*",Buffer:Read(4))[0]

    for ui = 1,self.m_uiVisibleAreaCount do
        local info = AreaBindInfo:new()

        info.id = ffi.cast("uint32_t*",Buffer:Read(4))[0]
        info.attributes = ffi.cast("uint8_t*",Buffer:Read(1))[0]

        table.insert(self.m_potentiallyVisibleAreas,info)
    end

    self.m_inheritVisibilityFrom.id = ffi.cast("uint32_t*",Buffer:Read(4))[0]

    local unknownCount = ffi.cast("uint8_t*",Buffer:Read(1))[0]
    for c = 1,unknownCount do
        Buffer:Read(0x0E)
    end

    return true
end



local INavFile = {
    m_isLoaded = false,
    m_magic = 0, -- 4 bytes
    m_version = 0, -- 4 bytes
    m_subVersion = 0, -- 4 bytes
    m_saveBspSize = 0, -- 4 bytes
    m_isAnalyzed = 0, -- 1 byte
    m_usPlaceCount = 0, -- 2 bytes
    m_vStrPlaceNames = {}, -- dynamic
    m_hasUnnamedAreas = 0, -- 1 byte
    m_areas = {}, -- dynamic
    m_ladders = {}, -- dynamic
    m_uiAreaCount = 0 -- 4 bytes
}

function INavFile:Reset()
    self.m_isLoaded = false
    self.m_magic = 0
    self.m_version = 0
    self.m_subVersion = 0
    self.m_saveBspSize = 0
    self.m_isAnalyzed = 0
    self.m_usPlaceCount = 0
    self.m_vStrPlaceNames = {}
    self.m_hasUnnamedAreas = 0
    self.m_areas = {}
    self.m_ladders = {}
    self.m_uiAreaCount = 0
end

function INavFile:GetNavAreaByID(id)
    for _,Area in ipairs(self.m_areas) do
        if Area.m_id == id then
            return Area
        end
    end
    return nil
end

function INavFile:GetRandomNavArea()
    return self.m_areas[math.random(#self.m_areas)]
end

function INavFile:GetLadderByID(id)
    for _,Ladder in ipairs(self.m_ladders) do
        if Ladder.m_id == id then
            return Ladder
        end
    end
end

function CNavArea:GetHidingSpotByID(id)
    for _,spot in ipairs(self.m_hidingSpots) do
        if spot.m_id == id then
            return spot
        end
    end
end

function CNavLadder:Load(Buffer)
    self.m_id = ffi.cast("uint32_t*",Buffer:Read(4))[0]

    self.m_width = ffi.cast("float*",Buffer:Read(4))[0]

    self.m_top:SetMemberFromFloatType(ffi.cast("float*",Buffer:Read(12)))
    self.m_bottom:SetMemberFromFloatType(ffi.cast("float*",Buffer:Read(12)))

    self.m_length = ffi.cast("float*",Buffer:Read(4))[0]
    self.m_dir = ffi.cast("uint32_t*",Buffer:Read(4))[0]
    CNavLadder:SetDir(self.m_dir)

    local id = ffi.cast("uint32_t*",Buffer:Read(4))[0]
    self.m_topForwardArea = INavFile:GetNavAreaByID(id)

    id = ffi.cast("uint32_t*",Buffer:Read(4))[0]
    self.m_topLeftArea = INavFile:GetNavAreaByID(id)

    id = ffi.cast("uint32_t*",Buffer:Read(4))[0]
    self.m_topRightArea = INavFile:GetNavAreaByID(id)

    id = ffi.cast("uint32_t*",Buffer:Read(4))[0]
    self.m_topBehindArea = INavFile:GetNavAreaByID(id)

    id = ffi.cast("uint32_t*",Buffer:Read(4))[0]
    self.m_bottomArea = INavFile:GetNavAreaByID(id)
end

function CNavArea:PostLoad()
    for dir = 1,CNavLadder.ENUM_LadderDirectionType.NUM_LADDER_DIRECTIONS do

        for _,connect in ipairs(self.m_ladder[dir]) do
            local id = connect.id

            connect.ladder = INavFile:GetLadderByID(id)
        end
    end

    -- Not taking direction in account,SDK version has nested loop here,refer line 624
    for _,connect in ipairs(self.m_connect) do
        local id = connect.id
        connect.area = INavFile:GetNavAreaByID(id)
        connect.length = (connect.area.m_center - self.m_center):Length()
    end

    for _,spotEncounter in ipairs(self.m_spotEncounters) do
        spotEncounter.from.area = INavFile:GetNavAreaByID(spotEncounter.from.id)
        spotEncounter.to.area = INavFile:GetNavAreaByID(spotEncounter.to.id)

        -- TODO: Check out what portal here means and if its really needed
        --[[if (e->from.area && e->to.area)
        {
        // compute path
        float halfWidth;
        ComputePortal( e->to.area, e->toDir, &e->path.to, &halfWidth );
        ComputePortal( e->from.area, e->fromDir, &e->path.from, &halfWidth );

        const float eyeHeight = HalfHumanHeight;
        e->path.from.z = e->from.area->GetZ( e->path.from ) + eyeHeight;
        e->path.to.z = e->to.area->GetZ( e->path.to ) + eyeHeight;
        }]]

        for _,order in ipairs(spotEncounter.spots) do
            order.spot = self:GetHidingSpotByID(order.id)
        end
    end
end

--Bind IDs to their elements
function INavFile:PostLoad()
    for _,Area in ipairs(self.m_areas) do
        Area:PostLoad()
    end

    -- Hiding spots post load here
end

function INavFile:Load(Buffer)
    local FunctionName = "INavFile:Load"

    self.m_magic = ffi.cast("uint32_t*",Buffer:Read(4))[0]
    if(self.m_magic ~= 0xFEEDFACE) then
        print_raw("\a3244A8[\aBAAE3FWalkbot\a3244A8]\aFF0000".. FunctionName .. " : File could not be verified against magic")
        return false
    end

    self.m_version = ffi.cast("uint32_t*",Buffer:Read(4))[0]
    if(self.m_version ~= 16) then
        print_raw("\a3244A8[\aBAAE3FWalkbot\a3244A8]\aFF0000".. FunctionName .. " : File version mismatch")
        return false
    end

    self.m_subVersion = ffi.cast("uint32_t*",Buffer:Read(4))[0]
    self.m_saveBspSize = ffi.cast("uint32_t*",Buffer:Read(4))[0]
    self.m_isAnalyzed = ffi.cast("uint8_t*",Buffer:Read(1))[0]
    self.m_usPlaceCount = ffi.cast("uint16_t*",Buffer:Read(2))[0]

    for us = 1,self.m_usPlaceCount do
        local usLength = ffi.cast("uint16_t*",Buffer:Read(2))[0]
        local szName = Buffer:Read(usLength)
        table.insert(self.m_vStrPlaceNames,ffi.string(szName))
    end

    self.m_hasUnnamedAreas = ffi.cast("uint8_t*",Buffer:Read(1))[0]
    self.m_uiAreaCount = ffi.cast("uint32_t*",Buffer:Read(4))[0]

    for ui = 1,self.m_uiAreaCount do

        local area = CNavArea:new()
        area:LoadFromFile(Buffer)

        table.insert(self.m_areas,area)

    end

    local LadderCount = ffi.cast("uint32_t*",Buffer:Read(4))[0]
    for ui = 1,LadderCount do

        local Ladder = CNavLadder:new()
        Ladder:Load(Buffer)
        table.insert(self.m_ladders,Ladder)
    end

    INavFile:PostLoad()

    return true
end

local PossibleSolutions = {
    "Give full access permissions to every user on your PC to the .nav file.",
    "Make sure the .nav file can be read at all. (e.g navigate to it and read it yourself using Notepad)",
    "Contact me on Discord if it's still not solved : SilverHawk21#0001"
}

local function LoadMap(MapName)
    local MapConcattedWithDirectory = common.get_game_directory() .. "\\maps\\" .. MapName .. ".nav"

    local TokenHandle = ffi.new("uint32_t[1]")
    ffi.C.OpenProcessToken(ffi.C.GetCurrentProcess(),0xF01FF,TokenHandle)
    Advapi32.ImpersonateLoggedOnUser(TokenHandle[0])


    local fileHandle = ffi.C.CreateFileA(MapConcattedWithDirectory,0x80000000,0x00000001,0,3,0x80,0)


    if fileHandle == 0xFFFFFFFF then
        print_raw("\a3244A8[\aBAAE3FWalkbot\a3244A8]\aFF0000 CreateFileA returned an invalid handle.")
        print_raw("\a3244A8[\aBAAE3FWalkbot\a3244A8]\aFF0000 GetLastError : " .. ffi.C.GetLastError() .. " . Report this error code to me on Discord : SilverHawk21#0001 for further assist.")
        print_raw("\a3244A8[\aBAAE3FWalkbot\a3244A8]\aFF0000 Try the solutions below : ")
        for _,Solutions in ipairs(PossibleSolutions) do
            print_raw("\a3244A8[\aBAAE3FWalkbot\a3244A8]\aFF0000 ".. Solutions)
        end

        ffi.C.CloseHandle(fileHandle)
        INavFile.m_isLoaded = false
        return
    end

    local fileAttribute = ffi.C.GetFileAttributesA(MapConcattedWithDirectory)
    if (fileAttribute == 0xFFFFFFFF or bit.band(fileAttribute,16) ~= 0 ) then
        print_raw("\a3244A8[\aBAAE3FWalkbot\a3244A8]\aFF0000 .nav file for this map doesn't exist or file path is a directory.")
        ffi.C.CloseHandle(fileHandle)
        INavFile.m_isLoaded = false
        return
    end

    local filesize = ffi.C.GetFileSize(fileHandle,0)

    if( filesize == 0 )then
        print_raw("\a3244A8[\aBAAE3FWalkbot\a3244A8]\aFF0000 .nav file is empty.")
        ffi.C.CloseHandle(fileHandle)
        INavFile.m_isLoaded = false
        return
    end

    local buffer = ffi.typeof("unsigned char[?]")(filesize + 1)
    local NumberOfBytesRead = ffi.new("uint32_t[1]",{})

    ffi.C.ReadFile(fileHandle,buffer,filesize, NumberOfBytesRead,0)
    ffi.C.CloseHandle(fileHandle)

    local CustomBuffer = FileBuffer:Create(0,buffer,filesize)
    INavFile:Reset()
    if(not INavFile:Load(CustomBuffer))then
        print_raw("\a3244A8[\aBAAE3FWalkbot\a3244A8]\aFF0000 .nav file is invalid.Try re-generating it again.")
        INavFile.m_isLoaded = false
        return
    end
    INavFile.m_isLoaded = true
end

-- LoadMap("de_dust2")

local AreaNode = {
    parent = nil,
    area = nil,
    g = 0.0, -- Distance From Starting Node
    h = 0.0, -- Distance From End Node
    f = 0.0  -- Sum of g and h
}

function AreaNode:new()
    local newTable = {}
    setmetatable(newTable,self)
    self.__index = self
    newTable.parent = nil
    newTable.area = nil
    newTable.g = 0.0
    newTable.h = 0.0
    newTable.f = 0.0

    return newTable
end

function AreaNode:__eq(AnotherNode)
    return self.area.m_id == AnotherNode.area.m_id
end



local function FindLowestScoreInList(List)
    local f = math.huge
    local LowestScoreNode = nil
    for _,Node in ipairs(List) do
        if(Node.f < f) then
            f = Node.f
            LowestScoreNode = Node
        end
    end
    return LowestScoreNode
end

local function RemoveNodeFromList(List,Node)
    for i = 1,#List do
        local NodeIter = List[i]
        if(NodeIter == Node) then
            table.remove(List,i)
            break
        end
    end
end

local function GetNodeInList(List, Node)
    for i = 1,#List do
        local NodeIter = List[i]
        if(NodeIter == Node) then
            return NodeIter
        end
    end
    return nil
end

local function GetAreaInList(List, Area)
    for i = 1,#List do
        local NodeIter = List[i]
        if(NodeIter.area == Area) then
            return NodeIter
        end
    end
    return nil
end

local function IsNodeInList(List,Node)
    for i = 1,#List do
        local NodeIter = List[i]
        if(NodeIter == Node) then
            return true
        end
    end
    return false
end

local function IsAreaInList(List,Area)
    for i = 1,#List do
        local NodeIter = List[i]
        if(NodeIter.area == Area) then
            return true
        end
    end
    return false
end



local OpenList = {}
local ClosedList = {}

local function FindNearestAreaToPlayer(AreaList,player)

    local player_position = Vector3D:NewCustom(player:get_origin())

    local Latest_Distance = math.huge
    local Nearest_Area = nil
    for _,Area in ipairs(AreaList) do
        if( #Area.m_connect == 0 )then
            goto continue
        end

        if(bit.band(Area.m_attributeFlags,NavAttributeType.NAV_MESH_JUMP) ~= 0) then -- avoid area with jump attributes
            goto continue
        end

        if IsAreaInList(ClosedList,Area) then
            goto continue
        end

        local Distance = Area.m_center:DistToSqr(player_position)
        if(Distance < Latest_Distance) then
            Latest_Distance = Distance
            Nearest_Area = Area
        end
        ::continue::
    end
    return Nearest_Area
end

local LastFoundPlayer = nil
local function FindNearestPlayer(FromPlayer)
    local PlayerList = entity.get_players(not(Target_TeamMate:get()),Target_Dormant:get())

    local NearestDistance = math.huge
    local NearestPlayer = nil

    local FromPlayerRenderOrigin = FromPlayer:get_origin()
    local FromPlayerPos = Vector3D:new(FromPlayerRenderOrigin.x,FromPlayerRenderOrigin.y,FromPlayerRenderOrigin.z)

    for _,Player in pairs(PlayerList) do
        if Player ~= FromPlayer then
            if Player:is_alive() and Player ~= LastFoundPlayer and Player.m_fImmuneToGunGameDamageTime == 0 then

                local PlayerOrigin = Player:get_origin()
                local PlayerPos = Vector3D:new(PlayerOrigin.x,PlayerOrigin.y,PlayerOrigin.z)

                local DistanceToFromPlayer = PlayerPos:DistToSqr(FromPlayerPos) -- squared
                if( DistanceToFromPlayer < NearestDistance) then
                    NearestDistance = DistanceToFromPlayer
                    NearestPlayer = Player
                end
            end

        end
    end
    -- print("NearestPlayer : " ,NearestPlayer)
    -- print("LastFoundPlayer : " ,LastFoundPlayer)
    LastFoundPlayer = NearestPlayer

    return NearestPlayer
end


local function IsVisible(FromPlayer,ToPlayer)
    local FromPlayer_EyePos = FromPlayer:get_eye_position()
    local FromPlayer_EyePos_FFI = ffi.new("Vector",{FromPlayer_EyePos.x,FromPlayer_EyePos.y,FromPlayer_EyePos.z})
    if not BodyAim_Switch:get() then
        for _,hitbox in ipairs(Hitboxes_Normal) do

            local ToPlayer_TargetPos = ToPlayer:get_hitbox_position(hitbox)
            local ToPlayer_TargetPos_FFI = ffi.new("Vector",{ToPlayer_TargetPos.x,ToPlayer_TargetPos.y,ToPlayer_TargetPos.z})

            local IsThroughSmoke = LineGoesThroughSmoke(FromPlayer_EyePos_FFI,ToPlayer_TargetPos_FFI)

            local trace_result = utils.trace_line(FromPlayer_EyePos, ToPlayer_TargetPos, FromPlayer, 0x46004003)
            if (trace_result.entity and trace_result.entity:get_index() == ToPlayer:get_index() and not(IsThroughSmoke and Aimbot_SmokeCheck:get()) ) then
                return hitbox
            end
        end
    else
        for _,hitbox in ipairs(Hitboxes_BodyAim) do

            local ToPlayer_TargetPos = ToPlayer:get_hitbox_position(hitbox)
            local ToPlayer_TargetPos_FFI = ffi.new("Vector",{ToPlayer_TargetPos.x,ToPlayer_TargetPos.y,ToPlayer_TargetPos.z})

            local IsThroughSmoke = LineGoesThroughSmoke(FromPlayer_EyePos_FFI,ToPlayer_TargetPos_FFI)

            local trace_result = utils.trace_line(FromPlayer_EyePos, ToPlayer_TargetPos, FromPlayer, 0x46004003)
            if (trace_result.entity and trace_result.entity:get_index() == ToPlayer:get_index() and not(IsThroughSmoke and Aimbot_SmokeCheck:get()) ) then
                return hitbox
            end
        end
    end

    return -1

end

local function Aimbot__FindNearestPlayer(FromPlayer)

    local NearestDistance = math.huge
    local NearestPlayer = nil
    local BestHitbox = nil
    local FromPlayerEyePos = FromPlayer:get_eye_position()
    local FromPlayerPos = Vector3D:NewCustom(FromPlayerEyePos)


    entity.get_players(true,false,function(Player)

        if Player ~= FromPlayer then
            local TempHitboxChoice = IsVisible(FromPlayer,Player)

            if Player:is_alive() and Player:is_enemy()  and TempHitboxChoice > -1 and Player.m_fImmuneToGunGameDamageTime == 0 then

                local PlayerOrigin = Player:get_origin()
                local PlayerPos = Vector3D:NewCustom(PlayerOrigin)

                local DistanceToFromPlayer = PlayerPos:DistTo2D(FromPlayerPos) -- squared
                if( DistanceToFromPlayer < NearestDistance) then
                    NearestDistance = DistanceToFromPlayer
                    NearestPlayer = Player
                    BestHitbox = TempHitboxChoice
                end
            end

        end



    end)

    return  { NearestPlayer , BestHitbox }
end

local function DefaultTarget__FindNearestPlayer(FromPlayer)

    local NearestDistance = math.huge
    local NearestPlayer = nil

    local FromPlayerEyePos = FromPlayer:get_eye_position()
    local FromPlayerPos = Vector3D:NewCustom(FromPlayerEyePos)


    entity.get_players(true,true,function(Player)

        if Player ~= FromPlayer then

            if Player:is_alive() and Player:is_enemy() and Player.m_fImmuneToGunGameDamageTime == 0 then

                local PlayerOrigin = Player:get_origin()
                local PlayerPos = Vector3D:NewCustom(PlayerOrigin)

                local DistanceToFromPlayer = PlayerPos:DistTo2D(FromPlayerPos)
                if( DistanceToFromPlayer < NearestDistance) then
                    NearestDistance = DistanceToFromPlayer
                    NearestPlayer = Player
                end
            end

        end



    end)

    return NearestPlayer
end
local StartingNode = nil
local EndArea = nil
local CurrentNode = nil
local Path = {}



local function TriggerPrepareToFindAnotherNode()
    OpenList = { }
    ClosedList = { }
    CurrentNode = nil
    Path = { }
end

local function PrepareToFindAnotherNode()

    math.randomseed(globals.tickcount)

    local local_player = entity.get_local_player()

    if not local_player then return end

    StartingNode = AreaNode:new()
    StartingNode.area = FindNearestAreaToPlayer(INavFile.m_areas,local_player)

    if StartingNode.area == nil then return end

    local ChosenPlayer = FindNearestPlayer(local_player)


    if (ChosenPlayer ~= nil) then
        print_raw("\a3244A8[\aBAAE3FWalkbot\a3244A8]\a85BA3F Targetting player : " .. ChosenPlayer:get_name())
        EndArea = FindNearestAreaToPlayer(INavFile.m_areas,ChosenPlayer)
    else
        EndArea = INavFile:GetRandomNavArea()

        for i = 1 ,1000 do
            EndArea = INavFile:GetRandomNavArea()
            if EndArea ~= nil and #EndArea.m_connect > 1 and (bit.band(EndArea.m_attributeFlags,NavAttributeType.NAV_MESH_JUMP) == 0) then
                break
            end
        end
    end

    if EndArea == nil then return end


    StartingNode.parent = StartingNode
    StartingNode.g = StartingNode.area.m_center:DistToManhattanVer(StartingNode.area.m_center)
    StartingNode.h = StartingNode.area.m_center:DistToManhattanVer(EndArea.m_center)
    StartingNode.f = StartingNode.g + StartingNode.h

    table.insert(OpenList,StartingNode)
end


local function FindPath()
    local IterationsAllowed = IterationPerTick_Slider:get()

    for i = 1,IterationsAllowed do
        CurrentNode = FindLowestScoreInList(OpenList)

        if(CurrentNode == nil) then
            TriggerPrepareToFindAnotherNode()
            break
        end

        if(CurrentNode.area == EndArea) then
            if(#Path == 0 )then

                table.insert(Path,CurrentNode)

                local ParentNode = CurrentNode.parent

                for v=1,10000 do
                    if ParentNode == StartingNode then break end
                    table.insert(Path,ParentNode)
                    ParentNode = ParentNode.parent
                end
                table.insert(Path,ParentNode)

            end
            break
        end

        RemoveNodeFromList(OpenList,CurrentNode)
        table.insert(ClosedList,CurrentNode)

        for _,Connect in ipairs(CurrentNode.area.m_connect) do
            local NeighborNode = AreaNode:new()
            NeighborNode.area = Connect.area

            if(IsNodeInList(ClosedList,NeighborNode))then
                goto continue
            end

            if(IsNodeInList(OpenList,NeighborNode))then
                --print("Already in list.")
                local AlreadyExistingNode = GetNodeInList(OpenList,NeighborNode)
                local UpdatedGScoreToCurrentNode = CurrentNode.g + CurrentNode.area.m_center:DistToManhattanVer(AlreadyExistingNode.area.m_center)
                local UpdatedHScoreToCurrentNode = AlreadyExistingNode.area.m_center:DistToManhattanVer(EndArea.m_center)
                local UpdatedFScoreToCurrentNode = UpdatedGScoreToCurrentNode + UpdatedHScoreToCurrentNode

                if(UpdatedFScoreToCurrentNode < AlreadyExistingNode.g) then
                    --print("Updating a node in the open list.")
                    AlreadyExistingNode.parent = CurrentNode
                    AlreadyExistingNode.g = UpdatedGScoreToCurrentNode
                    AlreadyExistingNode.h = UpdatedHScoreToCurrentNode
                    AlreadyExistingNode.f = UpdatedFScoreToCurrentNode
                end
                goto continue
            end

            if (not IsNodeInList(OpenList,NeighborNode) and not IsNodeInList(ClosedList,NeighborNode)) then
                NeighborNode.parent = CurrentNode
                NeighborNode.g = CurrentNode.g + CurrentNode.area.m_center:DistToManhattanVer(NeighborNode.area.m_center)
                NeighborNode.h = NeighborNode.area.m_center:DistToManhattanVer(EndArea.m_center)
                NeighborNode.f = NeighborNode.g + NeighborNode.h
                table.insert(OpenList,NeighborNode)
                goto continue
            end

            ::continue::
        end
    end

end




local function CheckIfArrivedAtNode(cmd)
    local local_player = entity.get_local_player()
    local local_player_pos = local_player:get_origin()

    local NodeToMoveTo = Path[#Path]
    if(NodeToMoveTo ~= nil)then
        if(not NodeToMoveTo.area.m_center:IsDifference3D(local_player_pos,Difference2DLimit:get(),Z_Limit:get())) then
            table.remove(Path,#Path)
            if(#Path == 0) then
                TriggerPrepareToFindAnotherNode()
            end
        end
    end
end


local MovingTicks = 1
local NotMovingTicks = 1


local CycleAttempt = 1
local CycleMethods = 5

local function BreakBreakablesAndOpenOpenable(cmd,position)
    local local_player = entity.get_local_player()
    local LocalEyePos = local_player:get_eye_position()
    local LocalEyePosCustom = Vector3D:NewCustom(LocalEyePos)


    -- ======================For Testing======================

    -- local camera_forward = Vector3D:new()
    -- Math:AngleVectors(render.camera_angles(),camera_forward)


    -- camera_forward = camera_forward:MultiplySingle(8192.0)
    -- camera_forward = camera_forward + LocalEyePosCustom
    -- local door_min = vector( -15, -15, -15);
    -- local door_max = vector( 15, 15, 15 );
    -- local VectorToUseCustom = vector(camera_forward.x,camera_forward.y,camera_forward.z)
    -- local traced_custom = utils.trace_hull(LocalEyePos, VectorToUseCustom,door_min,door_max,local_player,0x600400B)

    -- if traced_custom.entity then
    --     print("Class ID",traced_custom.entity:get_classid())
    --     print("m_iName",traced_custom.entity.m_iName)
    --     print("classname",traced_custom.entity:get_classname())

    -- end

    -- ======================For Testing======================


    -- local PositionAngle = Math:CalcAngle(LocalEyePos,position)

    -- if not PositionAngle then return end

    -- local forward = Vector3D:new()
    -- Math:AngleVectors(PositionAngle,forward)


    local mins = vector( -5, -5, -5);
    local maxs = vector( 5, 5, 5 );

    -- forward = forward:MultiplySingle(8192.0)
    -- forward = forward + LocalEyePosCustom

    -- local VectorToUse = vector(forward.x,forward.y,forward.z)
    -- local traced = utils.trace_hull(LocalEyePos, VectorToUse,mins,maxs,local_player,0x46004003)

    for yaw = 0,360,45 do
        local NewAngle = Angle:new(0,yaw,0)
        local ForwardVector = Vector3D:new(0,0,0)
        Math:AngleVectors(NewAngle,ForwardVector)

        ForwardVector = ForwardVector:MultiplySingle(8192)
        ForwardVector = ForwardVector + LocalEyePosCustom
        ForwardVector.z = ForwardVector.z - HalfHumanHeight

        local trace_result = utils.trace_hull(vector(LocalEyePos.x,LocalEyePos.y,LocalEyePos.z - HalfHumanHeight),vector(ForwardVector.x,ForwardVector.y,ForwardVector.z),mins,maxs,local_player,0x46004003)

        if not(trace_result and trace_result.entity and trace_result.entity[0]) then goto continue end

        if trace_result.entity and trace_result.entity[0] then



            -- table.insert(Render_Queue,render.world_to_screen(origin))

            local AngleToVectorUse = Math:CalcAngle(LocalEyePosCustom,ForwardVector)

            if AngleToVectorUse == nil then goto continue end
            AngleToVectorUse:NormalizeTo180()
            if Math:VectorDistance(LocalEyePosCustom,trace_result.end_pos) >= 50 then goto continue end
            if trace_result.entity:get_classid() == 143 then
                cmd.forwardmove = 0.0
                cmd.sidemove = 0.0
                cmd.upmove = 0.0

                cmd.view_angles.x = 0.0
                cmd.view_angles.y = AngleToVectorUse.y

                if (globals.tickcount * globals.tickinterval) % 1 == 0  then
                    print_raw("\a3244A8[\aBAAE3FWalkbot\a3244A8]\a21ccbe Opening found door.")
                    cmd.buttons = bit.bor(cmd.buttons,buttons.IN_USE)
                end

            elseif IsBreakableEntity(ffi.cast("uint32_t",trace_result.entity[0])) then
                print_raw("\a3244A8[\aBAAE3FWalkbot\a3244A8]\a21ccbe Shooting breakable.")
                cmd.forwardmove = 0.0
                cmd.sidemove = 0.0
                cmd.upmove = 0.0

                cmd.view_angles.x = AngleToVectorUse.x
                cmd.view_angles.y = AngleToVectorUse.y

                cmd.buttons = bit.bor(cmd.buttons,buttons.IN_ATTACK)
            end


        end
        -- table.insert(Render_Queue,render.world_to_screen(vector(LocalEyePos.x,LocalEyePos.y,LocalEyePos.z - HalfHumanHeight)))
        table.insert(Render_Queue,render.world_to_screen(trace_result.end_pos))

        ::continue::
    end

    -- if traced.entity and traced.entity[0] then

    --     local entityMin = traced.entity.m_vecMins
    --     local entityMax = traced.entity.m_vecMaxs
    --     local EntityCenterOffset = ( entityMax - entityMin ) * 0.5

    --     local origin = traced.entity:get_origin()
    --     origin = origin + EntityCenterOffset

    --     local OriginAngle = Angle:new()
    --     Math:VectorAngles(origin,OriginAngle)

    --     OriginAngle:NormalizeTo180()
    --     OriginAngle:PrintValueClean()

    --     -- table.insert(Render_Queue,render.world_to_screen(origin))

    --     local AngleToVectorUse = Math:CalcAngle(LocalEyePosCustom,origin)

    --     if AngleToVectorUse == nil then return end
    --     AngleToVectorUse:NormalizeTo180()

    --     if traced.entity:get_classid() == 143 then
    --         cmd.forwardmove = 0.0
    --         cmd.sidemove = 0.0
    --         cmd.upmove = 0.0

    --         cmd.view_angles.x = AngleToVectorUse.x
    --         cmd.view_angles.y = AngleToVectorUse.y

    --         cmd.buttons = bit.bor(cmd.buttons,buttons.IN_USE)
    --     elseif IsBreakableEntity(ffi.cast("uint32_t",traced.entity[0])) then
    --         cmd.forwardmove = 0.0
    --         cmd.sidemove = 0.0
    --         cmd.upmove = 0.0

    --         cmd.view_angles.x = AngleToVectorUse.x
    --         cmd.view_angles.y = AngleToVectorUse.y

    --         cmd.buttons = bit.bor(cmd.buttons,buttons.IN_ATTACK)
    --     end


    -- end

    -- local EntityList = entity.get_entities(nil,false)
    -- for _,Entity in ipairs(EntityList) do

    --     local entityMin = Entity.m_vecMins
    --     local entityMax = Entity.m_vecMaxs

    --     if not (entityMin and entityMax) then
    --         goto continue
    --     end

    --     local EntityCenterOffset = ( entityMax.z - entityMin.z ) * 0.5

    --     local EntityOrigin = Entity:get_origin()
    --     EntityOrigin.z = EntityOrigin.z + EntityCenterOffset
    --     local trace_result = utils.trace_hull(LocalEyePos,EntityOrigin,mins,maxs,local_player,0x46004003)

    --     if not (trace_result and trace_result.entity and trace_result.entity[0] and trace_result.entity:is_visible()) then
    --         goto continue
    --     end

    --     local AngleToEntity = Math:CalcAngle(LocalEyePosCustom,EntityOrigin)
    --     if not AngleToEntity then goto continue end

    --     if trace_result.entity:get_classid() == 143 then
    --         print(trace_result.fraction)
    --         print("Found door")
    --         cmd.forwardmove = 0.0
    --         cmd.sidemove = 0.0
    --         cmd.upmove = 0.0

    --         cmd.view_angles.x = AngleToEntity.x
    --         cmd.view_angles.y = AngleToEntity.y

    --         cmd.buttons = bit.bor(cmd.buttons,buttons.IN_USE)
    --     elseif IsBreakableEntity(ffi.cast("uint32_t",trace_result.entity[0])) then
    --         print(trace_result.fraction)
    --         print("Found breakable")
    --         cmd.forwardmove = 0.0
    --         cmd.sidemove = 0.0
    --         cmd.upmove = 0.0

    --         cmd.view_angles.x = AngleToEntity.x
    --         cmd.view_angles.y = AngleToEntity.y

    --         cmd.buttons = bit.bor(cmd.buttons,buttons.IN_ATTACK)
    --     end

    --     ::continue::
    -- end





end



local function ObstacleAvoid(cmd)

    local local_player = entity.get_local_player()
    local local_player_pos = Vector3D:NewCustom(local_player:get_origin())
    local local_player_weapon = local_player:get_player_weapon()

    local max_speed = 230.0
    if local_player_weapon then
        max_speed = local_player_weapon:get_max_speed()
    end
    local local_player_speed = Vector3D:new(local_player.m_vecVelocity.x,local_player.m_vecVelocity.y,local_player.m_vecVelocity.z):Length2D()


    if(local_player_speed >= 0.10 * max_speed) then
        MovingTicks = (MovingTicks + 1) % 6400

        if((MovingTicks * globals.tickinterval) % ThresholdTimeReset:get() == 0) then
            CycleAttempt = 0
        end
        NotMovingTicks = 1
    else
        NotMovingTicks = (NotMovingTicks + 1) % 6400
        MovingTicks = 1
    end

    if ((globals.tickcount * globals.tickinterval) % ThresholdTimeReset:get() == 0) then
        CycleAttempt = CycleAttempt % CycleMethods + 1
    end


    local NodeToMoveTo = Path[#Path]



    if(NotMovingTicks > 1) then
        if NodeToMoveTo then
            BreakBreakablesAndOpenOpenable(cmd,NodeToMoveTo.area.m_center)
        end
        if( CycleAttempt == 1 )then -- Check attribute flags of areas
            if(bit.band(NodeToMoveTo.area.m_attributeFlags,NavAttributeType.NAV_MESH_JUMP) ~= 0) then
                cmd.buttons = bit.bor(cmd.buttons,buttons.IN_JUMP) -- Jump
            end

            if(bit.band(NodeToMoveTo.area.m_attributeFlags,NavAttributeType.NAV_MESH_CROUCH) ~= 0) then
                cmd.buttons = bit.bor(cmd.buttons,buttons.IN_DUCK) -- Crouch
            end
        elseif ( CycleAttempt == 2 ) then -- Jump and crouch
            cmd.buttons = bit.bor(cmd.buttons,buttons.IN_JUMP)
            cmd.buttons = bit.bor(cmd.buttons,buttons.IN_DUCK)
        elseif ( CycleAttempt == 3 ) then -- Just jump
            cmd.buttons = bit.bor(cmd.buttons,buttons.IN_JUMP)
        elseif ( CycleAttempt == 4 ) then -- Just crouch
            cmd.buttons = bit.bor(cmd.buttons,buttons.IN_DUCK)
        elseif ( CycleAttempt == 5) then -- Find another end area and new starting node
            local PathReference = Path -- save old path before clearing
            TriggerPrepareToFindAnotherNode()
            ClosedList = PathReference -- prevent from using old path

            CycleAttempt = 0 -- when path is found and CycleAttempt is still 5,it will attempt to find another end area,causing an infinite loop of finding paths and generating new end area.
        end
    else
        if( bit.band(NodeToMoveTo.area.m_attributeFlags,NavAttributeType.NAV_MESH_JUMP) ~= 0) then
            cmd.buttons = bit.bor(cmd.buttons,buttons.IN_JUMP) -- Jump
        end

        if( bit.band(NodeToMoveTo.area.m_attributeFlags,NavAttributeType.NAV_MESH_CROUCH) ~= 0) then
            cmd.buttons = bit.bor(cmd.buttons,buttons.IN_DUCK) -- Crouch
        end

    end
end



local function PrecomputeSeed()


	for seed=1,255 do

		local random_values = { }

		utils.random_seed(bit.band(seed,0xff) + 1)

		table.insert(random_values,utils.random_float(0.0,1.0))
		table.insert(random_values,utils.random_float(0.0,Math.PI_2))
		table.insert(random_values,utils.random_float(0.0,1.0))
		table.insert(random_values,utils.random_float(0.0,Math.PI_2))


		table.insert(Precomputed_Seeds,random_values)
	end

end

local function CalculateSpread(weapon,seed,inaccuracy,spread,UsePrecomputedSeeds,cmdSeed)
    if not weapon or weapon.m_iClip1 == 0 then
        return vector(0.00,0.00,0.00)
    end

    local r1,r2,r3,r4

    if UsePrecomputedSeeds then
        r1 = Precomputed_Seeds[seed][1]
        r2 = Precomputed_Seeds[seed][2]
        r3 = Precomputed_Seeds[seed][3]
        r4 = Precomputed_Seeds[seed][4]
    else
        utils.random_seed(bit.band(cmdSeed,0xff) + 1)

        r1 = utils.random_float(0.0,1.0)
        r2 = utils.random_float(0.0,Math.PI_2)
        r3 = utils.random_float(0.0,1.0)
        r4 = utils.random_float(0.0,Math.PI_2)
    end


	local c1 = math.cos(r2)
	local c2 = math.cos(r4)
	local s1 = math.sin(r2)
	local s2 = math.sin(r4)

	return Vector3D:new(
		(c1 * (r1 * inaccuracy)) + (c2 * (r3 * spread)),
		(s1 * (r1 * inaccuracy)) + (s2 * (r3 * spread)),
		0.0
    )

end

local function CheckHitchancePrecomputed(angleToTarget,TargetEntity)
    local local_player  = entity.get_local_player()
    local weapon        = local_player:get_player_weapon()

    local lp_eyepos     = local_player:get_eye_position()

    local forward             = Vector3D:new()
    local right                 = Vector3D:new()
    local up                    = Vector3D:new()

    Math:AngleVectorsExtra(angleToTarget,forward,right,up)

    local spread            = weapon:get_spread()
    local inaccuracy    = weapon:get_inaccuracy()

    local needed_hits   =  math.ceil((Aimbot_Hitchance:get() / 100) * 255)
    local total_hits        = 0

    for i = 1,255 do
        local wep_spread = CalculateSpread(weapon,i,inaccuracy,spread,true,nil)

        local dir = Vector3D:new(
            forward.x + (right.x * wep_spread.x) + (up.x * wep_spread.y),
            forward.y + (right.y * wep_spread.x) + (up.y * wep_spread.y),
            forward.z + (right.z * wep_spread.x) + (up.z * wep_spread.y)
        )

        local EndVec = Vector3D:new(
            lp_eyepos.x + (dir.x * 8192.0),
            lp_eyepos.y + (dir.y * 8192.0),
            lp_eyepos.z + (dir.z * 8192.0)
        )

        local trace_result = utils.trace_line(lp_eyepos, vector(EndVec.x, EndVec.y, EndVec.z), local_player, 0x46004003)

        if (trace_result.entity and trace_result.entity:get_index() == TargetEntity:get_index()) then
            total_hits = total_hits + 1
        end

        if (total_hits >= needed_hits) then
            return true
        end


    end
    return false
end

local function CheckHitchanceIntersect(EntityAddress,angleToTarget,hitbox_id)

    local local_player  = entity.get_local_player()
    local weapon        = local_player:get_player_weapon()

    local hitboxbounds = GetHitboxBounds(EntityAddress,hitbox_id)

    local start         = Vector3D:NewCustom(local_player:get_eye_position())

    local spread            =   weapon:get_spread()
    local inaccuracy        =   weapon:get_inaccuracy()

    local spreadAngle       = math.deg(spread + inaccuracy)


    local needed_hits       =  math.ceil((Aimbot_Hitchance:get() / 100) * 255)
    local total_hits        = 0

    for i = 1,255 do

        local ratio         = (i / 255)
        local multiplier    = ratio * spreadAngle
        local spreadDir     = math.sqrt(ratio) * Math.PI * 30
        local spreadAngle   = Angle:new( math.cos(spreadDir) * multiplier, math.sin(spreadDir) * multiplier, 0 )
        local shotAngle     = Angle:NewCustom(angleToTarget) + spreadAngle
        local forward       = Vector3D:new()
        Math:AngleVectors(shotAngle,forward)

        if hitboxbounds and hitboxbounds[1] and hitboxbounds[2] and hitboxbounds[3] then
            if Math:DoesIntersectCapsule(start,forward,hitboxbounds[1],hitboxbounds[2],hitboxbounds[3]) then
                total_hits = total_hits + 1
            end
        end

        if (total_hits >= needed_hits) then
            return true
        end
    end

    return false

end

local function CheckHitchanceRandom(cmd,angleToTarget,TargetEntity)
    local local_player  = entity.get_local_player()
    local weapon        = local_player:get_player_weapon()

    local lp_eyepos     = local_player:get_eye_position()

    local forward             = Vector3D:new()
    local right                 = Vector3D:new()
    local up                    = Vector3D:new()

    Math:AngleVectorsExtra(angleToTarget,forward,right,up)

    local spread            = weapon:get_spread()
    local inaccuracy        = weapon:get_inaccuracy()

    local needed_hits   =  math.ceil((Aimbot_Hitchance:get() / 100) * 255)
    local total_hits        = 0

    for i = 1,255 do
        local wep_spread = CalculateSpread(weapon,i,inaccuracy,spread,false,cmd.random_seed)

        local dir = Vector3D:new(
            forward.x + (right.x * wep_spread.x) + (up.x * wep_spread.y),
            forward.y + (right.y * wep_spread.x) + (up.y * wep_spread.y),
            forward.z + (right.z * wep_spread.x) + (up.z * wep_spread.y)
        )

        local EndVec = Vector3D:new(
            lp_eyepos.x + (dir.x * 8192.0),
            lp_eyepos.y + (dir.y * 8192.0),
            lp_eyepos.z + (dir.z * 8192.0)
        )

        local trace_result = utils.trace_line(lp_eyepos, vector(EndVec.x, EndVec.y, EndVec.z), local_player, 0x46004003)

        if (trace_result.entity and trace_result.entity:get_index() == TargetEntity:get_index()) then
            total_hits = total_hits + 1
        end

        if (total_hits >= needed_hits) then
            return true
        end


    end
    return false
end


local function CheckHitchanceUniform (angle,TargetEntity)

    local local_player  = entity.get_local_player()
    local weapon        = local_player:get_player_weapon()

    local start         = Vector3D:NewCustom(local_player:get_eye_position())

    local spread            =   weapon:get_spread()
    local inaccuracy        =   weapon:get_inaccuracy()

    local spreadAngle       = math.deg(spread + inaccuracy)


    local needed_hits       =  math.ceil((Aimbot_Hitchance:get() / 100) * 255)
    local total_hits        = 0

    for i = 1,255 do

        local ratio         = (i / 255)
        local multiplier    = ratio * spreadAngle
        local spreadDir     = math.sqrt(ratio) * Math.PI * 30
        local spreadAngle   = Angle:new( math.cos(spreadDir) * multiplier, math.sin(spreadDir) * multiplier, 0 )
        local shotAngle     = angle + spreadAngle
        local forward       = Vector3D:new()
        Math:AngleVectors(shotAngle,forward)
        forward = forward:MultiplySingle(8192.0)
        local endpos        = (start + forward)
        local trace_result  = utils.trace_line(local_player:get_eye_position(), vector(endpos.x, endpos.y, endpos.z), local_player, 0x46004003)

        if (trace_result.entity and trace_result.entity:get_index() == TargetEntity:get_index()) then
            total_hits = total_hits + 1
        end

        if (total_hits >= needed_hits) then
            return true
        end
    end

    -- print(total_hits)
    return false
end
local function CanLocalPlayerShoot()
    local local_player = entity.get_local_player()
    local local_weapon = local_player:get_player_weapon()

    if not ( local_weapon and local_player ) then
        return false
    end

    local weapon__clip1                 = local_weapon.m_iClip1
    local weapon__m_flNextPrimaryAttack = local_weapon.m_flNextPrimaryAttack
    local local_player__m_nTickBase     = local_player.m_nTickBase
    local local_player__m_flNextAttack  = local_player.m_flNextAttack

    if(local_weapon:get_weapon_reload() ~= -1 or weapon__clip1 <= 0)then
        return false
    end

    local flServerTime = local_player__m_nTickBase * globals.tickinterval

    if(local_player__m_flNextAttack > flServerTime) then
        return false
    end

    return (weapon__m_flNextPrimaryAttack <= flServerTime)
end

local function CanHit_Angle(StartPos,CurrentAngle,PlayerSkip,TargetEntity)

    local VectorFromAngle = Vector3D:new()
    Math:AngleVectors(CurrentAngle,VectorFromAngle)
    VectorFromAngle = VectorFromAngle:MultiplySingle(8192.0)
    VectorFromAngle = VectorFromAngle + StartPos

    local VectorFromAngle_Converted = vector(VectorFromAngle.x,VectorFromAngle.y,VectorFromAngle.z)
    local trace_result = utils.trace_line(StartPos, VectorFromAngle_Converted, PlayerSkip, 0x46004003)

    return (trace_result.entity and trace_result.entity:get_index() == TargetEntity:get_index())

end



local function BeMoreAccurate(cmd)

    local local_player = entity.get_local_player()

    if not local_player then return end

    local local_weapon = local_player:get_player_weapon()

    if not local_weapon or local_weapon:get_weapon_reload() ~= -1 then
        return
    end

    local get_speed = 33

    local min_speed = math.sqrt((cmd.forwardmove * cmd.forwardmove) + (cmd.sidemove * cmd.sidemove) + (cmd.upmove * cmd.upmove))

    if min_speed <= 0.0 then return end

    if Aimbot_AutoCrouch_Switch:get() then
        cmd.buttons = bit.bor(cmd.buttons,buttons.IN_DUCK)
    end

    cmd.buttons = bit.band(cmd.buttons,bit.bnot(buttons.IN_JUMP))

    if bit.band(cmd.buttons,buttons.IN_DUCK) ~= 0 then
        get_speed = get_speed * 2.94117647
    end

    if min_speed <= get_speed then
        return
    end

    local kys = get_speed / min_speed


    cmd.forwardmove = cmd.forwardmove * kys
    cmd.sidemove = cmd.sidemove * kys
    cmd.upmove = cmd.upmove * kys

    if  Aimbot_AutoScope_Switch:get()                                                           and
        local_weapon                                                                            and
        local_weapon.m_zoomLevel                    == 0                                        and
        local_weapon:get_weapon_info().weapon_type  == CSWeaponType.WEAPONTYPE_SNIPER_RIFLE     and
        bit.band(cmd.buttons,buttons.IN_ATTACK2)    == 0                                        and
        bit.band(cmd.buttons,buttons.IN_ATTACK)     == 0
    then
        cmd.buttons = bit.bor(cmd.buttons,buttons.IN_ATTACK2)
    end

end

local TimeSinceLastSeenEnemy = 0

local function MoveToTarget(cmd)

    local local_player = entity.get_local_player()
    local local_player_pos = local_player:get_origin()
    local local_weapon = local_player:get_player_weapon()
    local view_angles = Angle:NewCustom(render.camera_angles())

    local NodeToMoveTo = Path[#Path]

    local AngleToNode = Math:CalcAngle(local_player_pos,NodeToMoveTo.area.m_center)

    if AngleToNode == nil then return end

    view_angles.x = 0.0
    AngleToNode.x = 0.0
    view_angles.z = 0.0
    AngleToNode.z = 0.0
    AngleToNode = (view_angles - AngleToNode)



    local forward = Vector3D:new()


    Math:AngleVectors(AngleToNode,forward)

    forward = forward:MultiplySingle(450)


    cmd.forwardmove = forward.x
    cmd.sidemove = forward.y


    if (TimeSinceLastSeenEnemy * globals.tickinterval) < TimeToMove:get() or TimeSinceLastSeenEnemy == 0 then
        BeMoreAccurate(cmd)
    end
end
local RecoilScale = cvar.weapon_recoil_scale

local LatestTargetAngle = Angle:new()
local LatestAngle = Angle:NewCustom(render.camera_angles())
local TargetInfo = nil

local function PrepareTargetAngle(cmd)

    local local_player = entity.get_local_player()
    local local_player_pos = local_player:get_eye_position()
    local local_weapon = local_player:get_player_weapon()

    local NodeToMoveTo = Path[#Path]

    local TargetPlayerAndHitbox = Aimbot__FindNearestPlayer(local_player)

    if Vector3D:IsValid(local_player_pos) then
        if TargetPlayerAndHitbox[1] and TargetPlayerAndHitbox[2] then
            -- BeMoreAccurate(cmd)
            TargetInfo = TargetPlayerAndHitbox
            TimeSinceLastSeenEnemy = 0
            local local_aimpunch = Angle:NewCustom(local_player.m_aimPunchAngle)
            local_aimpunch = local_aimpunch:MultiplySingle(RecoilScale:float())

            local TargetHitbox = TargetPlayerAndHitbox[1]:get_hitbox_position(TargetPlayerAndHitbox[2])

            if Vector3D:IsValid(TargetHitbox) then
                local AngleToTarget = Math:CalcAngle(local_player_pos,TargetHitbox)
                if (AngleToTarget ~= nil) then
                    LatestTargetAngle = AngleToTarget - local_aimpunch
                end
            end
        else
            TargetInfo = nil
            if (TimeSinceLastSeenEnemy * globals.tickinterval) > TimeToMove:get() then
                -- print(Aimbot_Default_Target:get())
                if Aimbot_Default_Target:get() == "Node" then

                    if NodeToMoveTo then
                        if Vector3D:IsValid(NodeToMoveTo.area.m_center) then
                            local AngleToTarget = Math:CalcAngle(local_player_pos,NodeToMoveTo.area.m_center)
                            if (AngleToTarget ~= nil) then
                                LatestTargetAngle = AngleToTarget
                                LatestTargetAngle.x = 0.00
                                LatestTargetAngle.z = 0.00
                            end
                        end
                    end
                elseif Aimbot_Default_Target:get() == "Random" then

                    local difference = math.abs((LatestAngle.y - LatestTargetAngle.y + 540) % 360 - 180)
                    if (difference <= 1) and ((globals.tickcount * globals.tickinterval ) % 1 == 0) then
                        LatestTargetAngle.x = 0.0
                        LatestTargetAngle.y = math.random(-180,180)
                        LatestTargetAngle.z = 0.00
                    end
                elseif Aimbot_Default_Target:get() == "Closest enemy" then

                    local NearestPlayer = DefaultTarget__FindNearestPlayer(local_player)
                    if not NearestPlayer then return end
                    local AngleToThreat = Math:CalcAngle(local_player_pos,NearestPlayer:get_origin())
                    if not AngleToThreat then return end

                    AngleToThreat:NormalizeTo180()
                    LatestTargetAngle.x = 0.0
                    LatestTargetAngle.y = AngleToThreat.y
                    LatestTargetAngle.z = 0.00
                end
            end
        end
    end
end


local function Aimbot(cmd)
    local local_player = entity.get_local_player()
    local local_player_pos = local_player:get_eye_position()
    local local_weapon  = local_player:get_player_weapon()

    local local_aimpunch = Angle:NewCustom(local_player.m_aimPunchAngle)
    local_aimpunch = local_aimpunch:MultiplySingle(RecoilScale:float())


    LatestAngle = Math:SmoothAngle(LatestAngle,LatestTargetAngle,Aimbot_Speed:get(),GetIndexFromSelectedCombo(Aimbot_Smoothing_Method_Combo_Table,Aimbot_Smoothing_Method:get()),Aimbot_Randomize_Speed:get())
    LatestAngle:NormalizeTo180()

    cmd.view_angles.x = LatestAngle.x
    cmd.view_angles.y = LatestAngle.y

    if TargetInfo and TargetInfo[1][0] and TargetInfo[2] then

        local Hitchance_Method = GetIndexFromSelectedCombo(Aimbot_Hitchance_Method_Combo_Table,Aimbot_Hitchance_Method:get())

        if TargetInfo[1] and CanLocalPlayerShoot() and CanHit_Angle(local_player_pos,Angle:NewCustom(cmd.view_angles),local_player,TargetInfo[1]) and bit.band(cmd.buttons,buttons.IN_ATTACK2) == 0 then
            if Hitchance_Method == 1 then
                if CheckHitchanceRandom(cmd,LatestAngle,TargetInfo[1]) then
                    if Aimbot_Enforce_Hitbox:get() then
                        cmd.view_angles.x = LatestTargetAngle.x
                        cmd.view_angles.y = LatestTargetAngle.y
                    end
                    cmd.buttons = bit.bor(cmd.buttons,buttons.IN_ATTACK)
                end
            elseif Hitchance_Method == 2 then
                if CheckHitchanceUniform(LatestAngle,TargetInfo[1]) then
                    if Aimbot_Enforce_Hitbox:get() then
                        cmd.view_angles.x = LatestTargetAngle.x
                        cmd.view_angles.y = LatestTargetAngle.y
                    end
                    cmd.buttons = bit.bor(cmd.buttons,buttons.IN_ATTACK)
                end
            elseif Hitchance_Method == 3 then
                if CheckHitchancePrecomputed(LatestAngle,TargetInfo[1]) then
                    if Aimbot_Enforce_Hitbox:get() then
                        cmd.view_angles.x = LatestTargetAngle.x
                        cmd.view_angles.y = LatestTargetAngle.y
                    end
                    cmd.buttons = bit.bor(cmd.buttons,buttons.IN_ATTACK)
                end
            else
                if CheckHitchanceIntersect(ffi.cast("uint32_t",TargetInfo[1][0]),LatestAngle,TargetInfo[2]) then
                    if Aimbot_Enforce_Hitbox:get() then
                        cmd.view_angles.x = LatestTargetAngle.x
                        cmd.view_angles.y = LatestTargetAngle.y
                    end
                    cmd.buttons = bit.bor(cmd.buttons,buttons.IN_ATTACK)
                end
            end

        end

    end

    if (TimeSinceLastSeenEnemy * globals.tickinterval > TimeToMove:get()) then
        if Aimbot_AutoUnscope_Switch:get() and local_weapon and local_weapon.m_zoomLevel ~= 0 and bit.band(cmd.buttons,buttons.IN_ATTACK) == 0 then
            cmd.buttons = bit.bor(cmd.buttons,buttons.IN_ATTACK2)
        end
        if Aimbot_AutoReload_Switch:get() and local_weapon and local_weapon:get_weapon_reload() == -1 and bit.band(cmd.buttons,buttons.IN_ATTACK) == 0 then
            local clip = local_weapon.m_iClip1
            local max_clip = local_weapon:get_weapon_info().max_clip1
            local current_clip_percentage = clip / max_clip

            if(current_clip_percentage < ( Aimbot_AutoReload:get() / 100 ) ) then
                cmd.buttons = bit.bor(cmd.buttons,buttons.IN_RELOAD)
            end
        end
    end

end



--local iteration = 0
PrecomputeSeed()
local LastMapName = nil

local function ErrorHandler(error)
    print("ERROR : " , error)
end

events.createmove:set(function(cmd)

    if ( bit.band(cmd.buttons,buttons.IN_ATTACK,buttons.IN_ATTACK2) ~= 0 ) then
        return
    end

    TimeSinceLastSeenEnemy = math.max(1,(TimeSinceLastSeenEnemy + 1) % 230400)

    local game_rules = entity.get_game_rules()
    local m_bWarmupPeriod = game_rules.m_bWarmupPeriod
    local m_bFreezePeriod = game_rules.m_bFreezePeriod

    local player = entity.get_local_player()
    local active_weapon = player:get_player_weapon()

    local player_resource = player:get_resource()
    local m_iPlayerC4 = player_resource.m_iPlayerC4

    if not(player and player:is_alive())then
        return
    end
    local slot_string = nil
    local weapon_level = 0
    if (globals.tickcount * globals.tickinterval) % 1 == 0 then
        if (player[0] and HasC4 and HasC4(ffi.cast("uint32_t",player[0]))) then
            if(active_weapon and active_weapon.get_classid and active_weapon:get_classid() == 34)then
                utils.console_exec("drop;")
            else
                utils.console_exec("slot5;")
            end
        else
            if AutoWeaponSwitch_Switch.get and AutoWeaponSwitch_Switch:get() then

                local weapon_list = player:get_player_weapon(true)
                for _,weapon_entity in pairs(weapon_list)do

                    if not( weapon_entity and weapon_entity.get_weapon_info) then goto continue end

                    local weapon_type = weapon_entity:get_weapon_info().weapon_type

                    if not weapon_type then goto continue end

                    if
                    (
                        (
                            weapon_type == CSWeaponType.WEAPONTYPE_RIFLE            or
                            weapon_type == CSWeaponType.WEAPONTYPE_SNIPER_RIFLE     or
                            weapon_type == CSWeaponType.WEAPONTYPE_SUBMACHINEGUN    or
                            weapon_type == CSWeaponType.WEAPONTYPE_MACHINEGUN       or
                            weapon_type == CSWeaponType.WEAPONTYPE_SHOTGUN
                        )
                        and weapon_level < 3
                    )
                    then
                        slot_string = "slot1"
                        weapon_level = 3

                    elseif weapon_type == CSWeaponType.WEAPONTYPE_PISTOL and ( weapon_level < 2 ) then
                        slot_string = "slot2"
                        weapon_level = 2

                    elseif weapon_type == CSWeaponType.WEAPONTYPE_KNIFE and ( weapon_level < 1 )then
                        slot_string = "slot3"
                        weapon_level = 1

                    end
                    ::continue::
                end
                if slot_string ~= nil then
                    utils.console_exec(slot_string)
                end

            end
        end
    end



    if (globals.tickcount * globals.tickinterval) % 1 == 0 then
        if (common.get_map_data().shortname ~= LastMapName) then
            print_raw("\a3244A8[\aBAAE3FWalkbot\a3244A8]\a21ccbe Map changed.")
            INavFile.m_isLoaded = false
            TriggerPrepareToFindAnotherNode()
        end
    end

    if (not INavFile.m_isLoaded) then
        print_raw("\a3244A8[\aBAAE3FWalkbot\a3244A8]\a21ccbe LoadMap : " .. common.get_map_data().shortname)
        LoadMap(common.get_map_data().shortname)
        LastMapName = common.get_map_data().shortname
        return
    end

    if INavFile.m_isLoaded and not( not utils.net_channel().is_loopback and m_bWarmupPeriod) then -- m_bWarmupPeriod doesnt get set correctly on local server
        if Aimbot_Enable.get and Aimbot_Enable:get() and bit.band(cmd.buttons,buttons.IN_ATTACK) == 0 then
            -- PrepareTargetAngle(cmd)
            -- Aimbot(cmd)
            xpcall(PrepareTargetAngle, ErrorHandler,cmd)
            xpcall(Aimbot, ErrorHandler,cmd)
        end

        if not m_bFreezePeriod  then
            if(#Path == 0) then
                if (#OpenList == 0) then
                    xpcall(PrepareToFindAnotherNode, ErrorHandler)
                    -- PrepareToFindAnotherNode()
                else
                    xpcall(FindPath, ErrorHandler)
                    -- FindPath()
                    cmd.forwardmove = 0.0
                    cmd.sidemove = 0.0
                    cmd.upmove = 0.0
                end
            else

                xpcall(MoveToTarget, ErrorHandler,cmd)
                -- MoveToTarget(cmd)

                if TimeSinceLastSeenEnemy * globals.tickinterval > TimeToMove:get() then
                    xpcall(ObstacleAvoid, ErrorHandler,cmd)
                    -- ObstacleAvoid(cmd)
                end
                xpcall( CheckIfArrivedAtNode, ErrorHandler,cmd)
                -- CheckIfArrivedAtNode(cmd)
            end

        end


    end




    -- Prevent IN_ATTACK and IN_ATTACK2 in same tick
    if ( bit.band(cmd.buttons,buttons.IN_ATTACK,buttons.IN_ATTACK2) ~= 0 ) then
        cmd.buttons = bit.band(cmd.buttons,bit.bnot(buttons.IN_ATTACK)) -- dont shoot,prioritize scoping first
    end

    cmd.forwardmove = Math:Clamp(cmd.forwardmove,-450,450)
    cmd.sidemove = Math:Clamp(cmd.sidemove,-450,450)

    cmd.view_angles.x = Math:Clamp(cmd.view_angles.x ,-89,89)
    cmd.view_angles.y = Math:Clamp(cmd.view_angles.y ,-180,180)
    cmd.view_angles.z = 0.0
    if not Aimbot_SilentAim:get() then
        render.camera_angles(cmd.view_angles)
    end

end)


local AutoQueuePanorama = panorama.loadstring([[
    function queueMatchmaking()
        {
            if (!LobbyAPI.BIsHost())
            {
                LobbyAPI.CreateSession();
            }
            if
            (
                !(
                    GameStateAPI.IsConnectedOrConnectingToServer() ||
                    LobbyAPI.GetMatchmakingStatusString() ||
                    ( CompetitiveMatchAPI.GetCooldownSecondsRemaining() > 0 && LobbyAPI.GetSessionSettings().game.type == "classic" && LobbyAPI.GetSessionSettings().game.mode == "competitive" && LobbyAPI.GetSessionSettings().options.server == "official") ||
                    CompetitiveMatchAPI.HasOngoingMatch()  ||
                    GameStateAPI.IsLocalPlayerPlayingMatch() ||
                    GameStateAPI.IsLocalPlayerWatchingOwnDemo()
                )
            )
            {
                $.Msg("StartMatchmaking");
                LobbyAPI.StartMatchmaking("", "", "", "");
            }

        }

        queueMatchmaking();
]])


local function AutoQueue()
    if(AutoQueue_Switch:get() and not IsDrawingLoadingImage() and not IsClientLocalToActiveServer() and not globals.is_connected and not globals.is_in_game and GetGameState() == 3 and GetSignOnState() == 0) then
        AutoQueuePanorama()

    end
end

local AlreadyAttemptedToReconnect = false
local function AutoReconnect()
    if not AlreadyAttemptedToReconnect then
        if(AutoReconnect_Switch:get() and not IsDrawingLoadingImage() and not IsClientLocalToActiveServer() and not globals.is_connected and not globals.is_in_game and GetGameState() == 3 and GetSignOnState() == 0) then
            if (panorama.CompetitiveMatchAPI.HasOngoingMatch() and not panorama.GameStateAPI.IsConnectedOrConnectingToServer() ) then
                panorama.CompetitiveMatchAPI.ActionReconnectToOngoingMatch()
                AlreadyAttemptedToReconnect = true

            end
        end
    end
end
events.post_render:set(function()
    local local_player = entity.get_local_player()



    if (globals.tickcount * globals.tickinterval) % 1 == 0 then
        if local_player and not (local_player.m_iTeamNum == 2 or local_player.m_iTeamNum == 3 ) and (IGameTypes:GetCurrentGameMode() == 2 and IGameTypes:GetCurrentGameType() == 1) then
            print_raw("\a3244A8[\aBAAE3FWalkbot\a3244A8]\a21ccbe Joining team.")
            utils.console_exec("jointeam 3 2 1;")
        end
    end
    if (globals.tickcount * globals.tickinterval) % 1 == 0 then
        AutoReconnect()
        AutoQueue()
    end
end)

events.render:set(
    function()

        for _,Renderable in ipairs(Render_Queue) do
            render.circle(Renderable, color(255,255,255,255), 10, 0,  1.0)
        end
        Render_Queue = {}

        if #Path == 0 then
            if(CurrentNode ~= nil) then
                local localPath = {}
                table.insert(localPath,CurrentNode)
                local ParentNode = CurrentNode.parent

                local IterationLimit = 10000
                local Iterations = 1
                while ParentNode ~= StartingNode and Iterations < IterationLimit do
                    table.insert(localPath,ParentNode)
                    ParentNode = ParentNode.parent
                    Iterations = Iterations + 1
                end

                table.insert(localPath,ParentNode)

                for i = 1,#localPath do
                    local FirstNode = localPath[i]
                    local FirstNodePosition = FirstNode.area.m_center
                    local FirstNodeVector = vector(FirstNodePosition.x, FirstNodePosition.y, FirstNodePosition.z)
                    local FirstNodeScreenPos = render.world_to_screen(FirstNodeVector)

                    local SecondNode = localPath[i+1]
                    if(SecondNode ~= nil)then
                        local SecondNodePosition = SecondNode.area.m_center
                        local SecondNodeVector = vector(SecondNodePosition.x, SecondNodePosition.y, SecondNodePosition.z)
                        local SecondNodeScreenPos = render.world_to_screen(SecondNodeVector)

                        render.line(FirstNodeScreenPos, SecondNodeScreenPos,color(255,0,0,255))
                    end

                end
            end

        else
            for i = 1,#Path do
                local FirstNode = Path[i]
                local FirstNodePosition = FirstNode.area.m_center
                local FirstNodeVector = vector(FirstNodePosition.x, FirstNodePosition.y, FirstNodePosition.z)
                local FirstNodeScreenPos = render.world_to_screen(FirstNodeVector)

                local SecondNode = Path[i+1]
                if(SecondNode ~= nil)then
                    local SecondNodePosition = SecondNode.area.m_center
                    local SecondNodeVector = vector(SecondNodePosition.x, SecondNodePosition.y, SecondNodePosition.z)
                    local SecondNodeScreenPos = render.world_to_screen(SecondNodeVector)
                    render.line(FirstNodeScreenPos, SecondNodeScreenPos,color(0,255,0,255))
                end
            end
        end
    end
)



events.cs_win_panel_match:set(function(event)
    if AutoDisconnect_Switch:get() then
        utils.console_exec("disconnect;")
    end
end)

events.cs_game_disconnected:set(function(event)
    AlreadyAttemptedToReconnect = false
    INavFile.m_isLoaded = false
    TriggerPrepareToFindAnotherNode()

end)

events.player_spawn:set(function(event)
    local local_player = entity.get_local_player()

    if not local_player then
        return
    end

    local player_info = local_player:get_player_info()
    local UserID = player_info.userid
    if (event.userid == UserID) then
        local tickrate = 1.0 / globals.tickinterval
        TimeSinceLastSeenEnemy = tickrate * TimeToMove:get()
        TriggerPrepareToFindAnotherNode()
        if AutoBuy_Switch:get() then
            AutoBuy()
        end
    end

end)


-- Slow/Lazy Area loading,need to make sure header infos are seeked into the position first.
--local iteration = 0
--Cheat.RegisterCallback("draw", function()
--    if iteration < INavFile.m_uiAreaCount and math.floor(GlobalVars.realtime % 2) == 0 then
--        print("Iteration : ",iteration)
--        local area = CNavArea:new()
--        area:LoadFromFile(CustomBuffer)
--        iteration = iteration + 1
--    end
--end)
