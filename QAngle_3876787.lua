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

return Angle

