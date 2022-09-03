_DEBUG = true

local Vector3D = {
    x,y,z
}
Vector3D.__index = Vector3D

function Vector3D:new(x,y,z)
    local Object = {}
    setmetatable(Object,self)
    Object.x = x or 0.00
    Object.y = y or 0.00
    Object.z = z or 0.00
    return Object
end

function Vector3D:NewCustom(CustomVector)
    local Object = {}
    setmetatable(Object,self)
    Object.x = CustomVector.x or 0.00
    Object.y = CustomVector.y or 0.00
    Object.z = CustomVector.z or 0.00
    return Object
end

--- Makes a copy of itself
function Vector3D:Copy()
    local CopyVector = Vector3D:new()
    CopyVector.x = self.x
    CopyVector.y = self.y
    CopyVector.z = self.z
    return CopyVector
end

--- Copies another Vector3D's members
function Vector3D:CopyOther(v)
    self.x = v.x
    self.y = v.y
    self.z = v.z
end

function Vector3D:SetMembers(x,y,z)
  self.x = x
  self.y = y
  self.z = z
end

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

--if the difference is higher than tolerance,THEN theres a difference
-- limit is like a radius
function Vector3D:IsDifference2D(v,limit)
    
    if(math.abs(self.x - v.x) >= limit) or (math.abs(self.y - v.y) >= limit) then
        -- print("IsDifference true")
        return true
    end
    -- print(math.abs(self.x - v.x))
    -- print(math.abs(self.y - v.y))
    -- print("IsDifference false")
    return false
end

-- z limit should be more loose since we have less control over the z position
function Vector3D:IsDifference3D(v,limit,z_limit)
    
    if(math.abs(self.x - v.x) >= limit) or (math.abs(self.y - v.y) >= limit) or (math.abs(self.z - v.z) >= (z_limit or limit)) then
        -- print("IsDifference true")
        return true
    end
    -- print(math.abs(self.x - v.x))
    -- print(math.abs(self.y - v.y))
    -- print(math.abs(self.z - v.z))
    -- print("IsDifference false")
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

-- For copy pasting into setpos command
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

return Vector3D