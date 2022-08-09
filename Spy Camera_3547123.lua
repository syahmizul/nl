local pGetModuleHandle_sig = Utils.PatternScan("engine.dll", " FF 15 ? ? ? ? 85 C0 74 0B") or error("Couldn't find signature #1")
local pGetProcAddress_sig = Utils.PatternScan("engine.dll", " FF 15 ? ? ? ? A3 ? ? ? ? EB 05") or error("Couldn't find signature #2")

local jmp_ecx = Utils.PatternScan("engine.dll", " FF E1")

local pGetProcAddress = ffi.cast("uint32_t**", ffi.cast("uint32_t", pGetProcAddress_sig) + 2)[0][0]
local fnGetProcAddress = ffi.cast("uint32_t(__stdcall*)(uint32_t, const char*)", pGetProcAddress)

local pGetModuleHandle = ffi.cast("uint32_t**", ffi.cast("uint32_t", pGetModuleHandle_sig) + 2)[0][0]
local fnGetModuleHandle = ffi.cast("uint32_t(__stdcall*)(const char*)", pGetModuleHandle)

local function GetVirtualFunction(address,index)
	local vtable = ffi.cast("uint32_t**",address)[0]
	return ffi.cast("uint32_t",vtable[index])
end

local function proc_bind(module_name, function_name, typedef)
    local ctype = ffi.typeof(typedef)
    local module_handle = fnGetModuleHandle(module_name)
    local proc_address = fnGetProcAddress(module_handle, function_name)
    local call_fn = ffi.cast(ctype, proc_address)

    return call_fn
end

local function vtable_bind(module, interface, index, type)
    local addr = ffi.cast("void***", Utils.CreateInterface(module, interface)) or error(interface .. " is nil.")
    return ffi.cast(ffi.typeof(type), addr[0][index]), addr
end



local function __thiscall(func, this) -- bind wrapper for __thiscall functions
    return function(...)
        return func(this, ...)
    end
end

local nativeVirtualProtect =
    proc_bind(
    "kernel32.dll",
    "VirtualProtect",
    "int(__stdcall*)(void* lpAddress, unsigned long dwSize, unsigned long flNewProtect, unsigned long* lpflOldProtect)"
)
local nativeVirtualAlloc =
    proc_bind(
    "kernel32.dll",
    "VirtualAlloc",
    "void*(__stdcall*)(void* lpAddress, unsigned long dwSize, unsigned long  flAllocationType, unsigned long flProtect)"
)
local nativeVirtualFree =
    proc_bind(
    "kernel32.dll",
    "VirtualFree",
    "int(__stdcall*)(void* lpAddress, unsigned long dwSize, unsigned long dwFreeType)"
)

local function copy(dst, src, len)
    --if 1==1 then print(dst,src,len) return  end
    return ffi.copy(ffi.cast("void*", dst), ffi.cast("const void*", src), len)
end

local buff = {free = {}}

local function VirtualProtect(lpAddress, dwSize, flNewProtect, lpflOldProtect)
    return nativeVirtualProtect(ffi.cast("void*", lpAddress), dwSize, flNewProtect, lpflOldProtect)
end

local function VirtualAlloc(lpAddress, dwSize, flAllocationType, flProtect, blFree)
    local alloc = nativeVirtualAlloc(lpAddress, dwSize, flAllocationType, flProtect)
    if blFree then
        table.insert(buff.free, alloc)
    end
    return ffi.cast("intptr_t", alloc)
end

--local buffer = VirtualAlloc(nil, 10, 0x3000, 0x40, true)

--Directly change a function at an address in a VMT
local direct_hook = {}
function direct_hook.new(vt)
    local new_hook = {}
    local org_func = {}
    local old_prot = ffi.new("unsigned long[1]")
    local old_func = ffi.cast("intptr_t*", vt)[0]
    local address = vt
    new_hook.hookMethod = function(cast, func)
        VirtualProtect(address, 4, 0x4, old_prot)
        ffi.cast("intptr_t*",address)[0] = ffi.cast("intptr_t", ffi.cast(cast, func(ffi.cast(cast, old_func))))
        VirtualProtect(address, 4, old_prot[0], old_prot)
        return
    end
    new_hook.unHook = function()
        VirtualProtect(address, 4, 0x4, old_prot)
        ffi.cast("intptr_t*",address)[0] = old_func
        VirtualProtect(address, 4, old_prot[0], old_prot)
    end
    return new_hook
end
--VMT HOOKS
local vmt_hook = {hooks = {}}
function vmt_hook.new(vt)
    local new_hook = {}
    local org_func = {}
    local old_prot = ffi.new("unsigned long[1]")
    local virtual_table = ffi.cast("intptr_t**", vt)[0]
    new_hook.this = virtual_table
    new_hook.hookMethod = function(cast, func, method)
        org_func[method] = virtual_table[method]
        VirtualProtect(virtual_table + method, 4, 0x4, old_prot)
        virtual_table[method] = ffi.cast("intptr_t", ffi.cast(cast, func(ffi.cast(cast, org_func[method]))))
        VirtualProtect(virtual_table + method, 4, old_prot[0], old_prot)
        return
    end
	new_hook.GetOriginal = function(method)
		return org_func[method]
	end
    new_hook.unHookMethod = function(method)
        VirtualProtect(virtual_table + method, 4, 0x4, old_prot)
        virtual_table[method] = org_func[method]
        VirtualProtect(virtual_table + method, 4, old_prot[0], old_prot)
        org_func[method] = nil
    end
    new_hook.unHookAll = function()
        for method, func in pairs(org_func) do
            new_hook.unHookMethod(method)
        end
    end
    table.insert(vmt_hook.hooks, new_hook.unHookAll)
    return new_hook
end
--VMT HOOKS
--JMP HOOKS
local jmp_hook = {hooks = {}}
function jmp_hook.new(cast, callback, hook_addr, size, trampoline, org_bytes_tramp)
    local size = size or 5
    local trampoline = trampoline or false
    local new_hook, mt = {}, {}
    local detour_addr
    local old_prot = ffi.new("unsigned long[1]")
    local org_bytes = ffi.new("uint8_t[?]", size)
    copy(org_bytes, hook_addr, size)
    if trampoline then                                                                                                   --  stolen bytes needs to be copied to not corrupt the stack.
        local alloc_addr = VirtualAlloc(nil, size + 5, 0x3000, 0x40, true) -- allocate with additional 5 bytes for stolen bytes + jmp instruction + relative address
        detour_addr = tonumber(ffi.cast("intptr_t", ffi.cast(cast, callback(ffi.cast(cast,alloc_addr)))))
        print("Alloc address",tonumber(ffi.cast("intptr_t",alloc_addr)))
        print("Detour address",detour_addr)
        local trampoline_bytes = ffi.new("uint8_t[?]", size + 5, 0x90) -- Sets all instruction to NOPs
        -- if we provide custom instructions to place instead of the stolen bytes
        if org_bytes_tramp then
            local i = 0
            for byte in string.gmatch(org_bytes_tramp,"(%x%x)") do
                trampoline_bytes[i] = tonumber(byte, 16)
                i = i + 1
            end
        else
            -- else,just copy the stolen bytes.
            copy(trampoline_bytes, org_bytes, size)
        end
        -- jmp instruction
        trampoline_bytes[size] = 0xE9
        -- Calculate relative address from our allocated address to jump
        ffi.cast("int32_t*", trampoline_bytes + size + 1)[0] = hook_addr - tonumber(alloc_addr) - size + (size - 5)

        --copy the stolen bytes + jmp instructions to the allocated space in the binary
        copy(alloc_addr, trampoline_bytes, size + 5)
        new_hook.call = ffi.cast(cast, alloc_addr)
        mt = {
            __call = function(self, ...)
                return self.call(...)
            end
        }
    else
        detour_addr = tonumber(ffi.cast("intptr_t", ffi.cast(cast, callback(ffi.cast(cast,hook_addr)))))
        new_hook.call = ffi.cast(cast, hook_addr)
        mt = {
            __call = function(self, ...)
                self.stop()
                local res = self.call(...)
                self.start()
                return res
            end
        }
    end
    local hook_bytes = ffi.new("uint8_t[?]", size, 0x90)
    hook_bytes[0] = 0xE9
    ffi.cast("int32_t*", hook_bytes + 1)[0] = (detour_addr-hook_addr - 5)
    new_hook.status = false
    local function set_status(bool)
        new_hook.status = bool
        VirtualProtect(hook_addr, size, 0x40, old_prot)
        copy(hook_addr, bool and hook_bytes or org_bytes, size)
        VirtualProtect(hook_addr, size, old_prot[0], old_prot)
    end
    new_hook.stop = function()
        set_status(false)
    end
    new_hook.start = function()
        set_status(true)
    end
    if org_bytes[0] == 0xE9 or org_bytes[0] == 0xE8 then
        print("[WARNING] A primordial trampoline hook has been detected (uint8: " .. org_bytes[0] .. "), therefore you are not allowed to hook this address")
        for i=0,size do
            print("0x",string.upper(string.format("%x",tonumber(ffi.cast("uintptr_t",hook_addr))+i))," = 0x",string.upper(string.format("%x", org_bytes[i])))
        end
        print("[WARNING] You may still hook this address with vmt hook if it belongs to a vtable, however you will risk vac detection and low trust factor.")
        assert("hooking"=="gay")
    else
        new_hook.start()
    end
    table.insert(jmp_hook.hooks, new_hook)
    return setmetatable(new_hook, mt)
end
--JMP HOOKS
local hook = { vmt = vmt_hook , jmp = jmp_hook , direct = direct_hook }

local Vector3 = {
    x,y,z
}
Vector3.__index = Vector3

function Vector3:new()
    local Object = {}
    setmetatable(Object,self)
    self.x = 0.00
    self.y = 0.00
    self.z = 0.00
    return Object
end

--- Makes a copy of itself
function Vector3:Copy()
    local CopyVector = Vector3:new()
    CopyVector.x = self.x
    CopyVector.y = self.y
    CopyVector.z = self.z
    return CopyVector
end

--- Copies another Vector's members
function Vector3:CopyOther(v)
    self.x = v.x
    self.y = v.y
    self.z = v.z
end

function Vector3:SetMembers(x,y,z)
  self.x = x
  self.y = y
  self.z = z
end

function Vector3:SetX(x)
  self.x = x
end

function Vector3:SetY(y)
    self.y = y
end

function Vector3:SetZ(z)
    self.z = z
end

function Vector3:GetX()
    return self.x
end

function Vector3:GetY()
    return self.y
end

function Vector3:GetZ()
    return self.z
end

function Vector3:Zero()
    self.x = 0
    self.y = 0
    self.z = 0
end

function Vector3:__add(v)
    local SolvedVector = Vector3:new()
    SolvedVector.x = self.x + v.x
    SolvedVector.y = self.y + v.y
    SolvedVector.z = self.z + v.z
    return SolvedVector
end

function Vector3:__sub(v)
    local SolvedVector = Vector3:new()
    SolvedVector.x = self.x - v.x
    SolvedVector.y = self.y - v.y
    SolvedVector.z = self.z - v.z
    return SolvedVector
end

function Vector3:__mul(v)
    local SolvedVector = Vector3:new()
    SolvedVector.x = self.x * v.x
    SolvedVector.y = self.y * v.y
    SolvedVector.z = self.z * v.z
    return SolvedVector
end

function Vector3:__div(v)
    local SolvedVector = Vector3:new()
    SolvedVector.x = self.x / v.x
    SolvedVector.y = self.y / v.y
    SolvedVector.z = self.z / v.z
    return SolvedVector
end

function Vector3:__mod(v)
    local SolvedVector = Vector3:new()
    SolvedVector.x = self.x % v.x
    SolvedVector.y = self.y % v.y
    SolvedVector.z = self.z % v.z
    return SolvedVector
end

function Vector3:__pow(v)
    local SolvedVector = Vector3:new()
    SolvedVector.x = self.x ^ v.x
    SolvedVector.y = self.y ^ v.y
    SolvedVector.z = self.z ^ v.z
    return SolvedVector
end

function Vector3:__eq(v)
    if self.x ~= v.x then return false end
    if self.y ~= v.y then return false end
    if self.z ~= v.z then return false end
    return true
end

function Vector3:__lt(v) -- <
    if self.x >= v.x then return false end
    if self.y >= v.y then return false end
    if self.z >= v.z then return false end
    return true
end

function Vector3:__le(v)  -- <=
    if self.x > v.x then return false end
    if self.y > v.y then return false end
    if self.z > v.z then return false end
    return true
end

function Vector3:Length()
    return math.sqrt( self.x*self.x + self.y*self.y + self.z*self.z )
end

function Vector3:LengthSqr()
    return ( self.x*self.x + self.y*self.y + self.z*self.z )
end

function Vector3:Length2D()
    return math.sqrt(self.x*self.x + self.y*self.y)
end

function Vector3:Dot(v)
    return ( self.x * v.x + self.y * v.y + self.z * v.z )
end

--- Adds with a single float number instead of another Vector
--- @param fl number
--- @return userdata
function Vector3:AddSingle(fl)
    local SolvedVector = Vector3:new()
    SolvedVector.x = self.x + fl
    SolvedVector.y = self.y + fl
    SolvedVector.z = self.z + fl
    return self
end

--- Subtracts with a single float number instead of another Vector
--- @param fl number
--- @return userdata
function Vector3:SubtractSingle(fl)
    local SolvedVector = Vector3:new()
    SolvedVector.x = self.x - fl
    SolvedVector.y = self.y - fl
    SolvedVector.z = self.z - fl
    return SolvedVector
end

--- Multiplies with a single float number instead of another Vector
--- @param fl number
--- @return userdata
function Vector3:MultiplySingle(fl)
    local SolvedVector = Vector3:new()
    SolvedVector.x = self.x * fl
    SolvedVector.y = self.y * fl
    SolvedVector.z = self.z * fl
    return SolvedVector
end

--- Divides with a single float number instead of another Vector
--- @param fl number
--- @return userdata
function Vector3:DivideSingle(fl)
    local SolvedVector = Vector3:new()
    SolvedVector.x = self.x / fl
    SolvedVector.y = self.y / fl
    SolvedVector.z = self.z / fl
    return SolvedVector
end

function Vector3:Normalized()

    local res = self:Copy()
    local l = res:Length()
    if ( l ~= 0.0 ) then
        res = res:DivideSingle(fl)
    else
        res.x = 0
        res.y = 0
        res.z = 0
    end
    return res
end

function Vector3:DistTo(vOther)

    local delta = Vector3:new()

    delta.x = self.x - vOther.x
    delta.y = self.y - vOther.y
    delta.z = self.z - vOther.z

    return delta:Length()
end

function Vector3:DistToSqr(vOther)

    local delta = Vector3:new()

    delta.x = self.x - vOther.x
    delta.y = self.y - vOther.y
    delta.z = self.z - vOther.z

    return delta:LengthSqr()
end

local Vector2D = {
    x,y
}
Vector2D.__index = Vector2D

function Vector2D:new()
    local Object = {}
    setmetatable(Object,self)
    self.x = 0.00
    self.y = 0.00
    return Object
end

--- Makes a copy of itself
function Vector2D:Copy()
    local CopyVector = Vector2D:new()
    CopyVector.x = self.x
    CopyVector.y = self.y
    return CopyVector
end

--- Copies another Vector's members
function Vector2D:CopyOther(v)
    self.x = v.x
    self.y = v.y
end

function Vector2D:SetMembers(x, y)
    self.x = x
    self.y = y
end

function Vector2D:SetX(x)
    self.x = x
end

function Vector2D:SetY(y)
    self.y = y
end

function Vector2D:GetX()
    return self.x
end

function Vector2D:GetY()
    return self.y
end


function Vector2D:Zero()
    self.x = 0
    self.y = 0
end

function Vector2D:__add(v)
    local SolvedVector = Vector2D:new()
    SolvedVector.x = self.x + v.x
    SolvedVector.y = self.y + v.y
    return SolvedVector
end

function Vector2D:__sub(v)
    local SolvedVector = Vector2D:new()
    SolvedVector.x = self.x - v.x
    SolvedVector.y = self.y - v.y
    return SolvedVector
end

function Vector2D:__mul(v)
    local SolvedVector = Vector2D:new()
    SolvedVector.x = self.x * v.x
    SolvedVector.y = self.y * v.y
    return SolvedVector
end

function Vector2D:__div(v)
    local SolvedVector = Vector2D:new()
    SolvedVector.x = self.x / v.x
    SolvedVector.y = self.y / v.y
    return SolvedVector
end

function Vector2D:__mod(v)
    local SolvedVector = Vector2D:new()
    SolvedVector.x = self.x % v.x
    SolvedVector.y = self.y % v.y
    return SolvedVector
end

function Vector2D:__pow(v)
    local SolvedVector = Vector2D:new()
    SolvedVector.x = self.x ^ v.x
    SolvedVector.y = self.y ^ v.y
    return SolvedVector
end

function Vector2D:__eq(v)
    if self.x ~= v.x then return false end
    if self.y ~= v.y then return false end
    return true
end

function Vector2D:__lt(v) -- <
    if self.x >= v.x then return false end
    if self.y >= v.y then return false end
    return true
end

function Vector2D:__le(v)  -- <=
    if self.x > v.x then return false end
    if self.y > v.y then return false end
    return true
end

function Vector2D:Length()
    return math.sqrt( self.x*self.x + self.y*self.y )
end

function Vector2D:LengthSqr()
    return ( self.x*self.x + self.y*self.y )
end

--function Vector2D:Length2D()
--    return math.sqrt(self.x*self.x + self.y*self.y)
--end

function Vector2D:Dot(v)
    return ( self.x * v.x + self.y * v.y )
end

--- Adds with a single float number instead of another Vector
--- @param fl number
--- @return userdata
function Vector2D:AddSingle(fl)
    self.x = self.x + fl
    self.y = self.y + fl
    return self
end

--- Subtracts with a single float number instead of another Vector
--- @param fl number
--- @return userdata
function Vector2D:SubtractSingle(fl)
    self.x = self.x - fl
    self.y = self.y - fl
    return self
end

--- Multiplies with a single float number instead of another Vector
--- @param fl number
--- @return userdata
function Vector2D:MultiplySingle(fl)
    self.x = self.x * fl
    self.y = self.y * fl
    return self
end

--- Divides with a single float number instead of another Vector
--- @param fl number
--- @return userdata
function Vector2D:DivideSingle(fl)
    self.x = self.x / fl
    self.y = self.y / fl
    return self
end

function Vector2D:Normalized()

    local res = self:Copy()
    local l = res:Length()
    if ( l ~= 0.0 ) then
        res = res:DivideSingle(fl)
    else
        res.x = 0
        res.y = 0
    end
    return res
end

function Vector2D:DistTo(vOther)

    local delta = Vector2D:new()

    delta.x = self.x - vOther.x
    delta.y = self.y - vOther.y

    return delta:Length()
end

function Vector2D:DistToSqr(vOther)

    local delta = Vector2D:new()

    delta.x = self.x - vOther.x
    delta.y = self.y - vOther.y

    return delta:LengthSqr()
end

local QAngle = {
    x,y,z
}
QAngle.__index = QAngle

function QAngle:new()
    local Object = {}
    setmetatable(Object,self)
    self.x = 0.00
    self.y = 0.00
    self.z = 0.00
    return Object
end

--- Makes a copy of itself
function QAngle:Copy()
    local CopyVector = QAngle:new()
    CopyVector.x = self.x
    CopyVector.y = self.y
    CopyVector.z = self.z
    return CopyVector
end

--- Copies another Vector's members
function QAngle:CopyOther(v)
    self.x = v.x
    self.y = v.y
    self.z = v.z
end

--- Copies Neverlose's QAngle type members
function QAngle:NLCopy(v)
    self.x = v.pitch
    self.y = v.yaw
    self.z = v.roll
end

function QAngle:SetMembers(x, y, z)
    self.x = x
    self.y = y
    self.z = z
end

function QAngle:SetX(x)
    self.x = x
end

function QAngle:SetY(y)
    self.y = y
end

function QAngle:SetZ(z)
    self.z = z
end

function QAngle:GetX(x)
    return self.x
end

function QAngle:GetY(y)
    return self.y
end

function QAngle:GetZ(z)
    return self.z
end

function QAngle:Zero()
    self.x = 0.00
    self.y = 0.00
    self.z = 0.00
end

function QAngle:__add(v)
    local SolvedVector = QAngle:new()
    SolvedVector.x = self.x + v.x
    SolvedVector.y = self.y + v.y
    SolvedVector.z = self.z + v.z
    return SolvedVector
end

function QAngle:__sub(v)
    local SolvedVector = QAngle:new()
    SolvedVector.x = self.x - v.x
    SolvedVector.y = self.y - v.y
    SolvedVector.z = self.z - v.z
    return SolvedVector
end

function QAngle:__mul(v)
    local SolvedVector = QAngle:new()
    SolvedVector.x = self.x * v.x
    SolvedVector.y = self.y * v.y
    SolvedVector.z = self.z * v.z
    return SolvedVector
end

function QAngle:__div(v)
    local SolvedVector = QAngle:new()
    SolvedVector.x = self.x / v.x
    SolvedVector.y = self.y / v.y
    SolvedVector.z = self.z / v.z
    return SolvedVector
end

function QAngle:__mod(v)
    local SolvedVector = QAngle:new()
    SolvedVector.x = self.x % v.x
    SolvedVector.y = self.y % v.y
    SolvedVector.z = self.z % v.z
    return SolvedVector
end

function QAngle:__pow(v)
    local SolvedVector = QAngle:new()
    SolvedVector.x = self.x ^ v.x
    SolvedVector.y = self.y ^ v.y
    SolvedVector.z = self.z ^ v.z
    return SolvedVector
end

function QAngle:__eq(v)
    if self.x ~= v.x then return false end
    if self.y ~= v.y then return false end
    if self.z ~= v.z then return false end
    return true
end

function QAngle:__lt(v) -- <
    if self.x >= v.x then return false end
    if self.y >= v.y then return false end
    if self.z >= v.z then return false end
    return true
end

function QAngle:__le(v)  -- <=
    if self.x > v.x then return false end
    if self.y > v.y then return false end
    if self.z > v.z then return false end
    return true
end

function QAngle:Length()
    return math.sqrt( self.x*self.x + self.y*self.y + self.z*self.z )
end

function QAngle:LengthSqr()
    return ( self.x*self.x + self.y*self.y + self.z*self.z )
end

--function QAngle:Length2D()
--    return math.sqrt(self.x*self.x + self.y*self.y)
--end

--function QAngle:Dot(v)
--    return ( self.x * v.x + self.y * v.y + self.z * v.z )
--end

--- Adds with a single float number instead of another Vector
--- @param fl number
--- @return userdata
function QAngle:AddSingle(fl)
    self.x = self.x + fl
    self.y = self.y + fl
    self.z = self.z + fl
    return self
end

--- Subtracts with a single float number instead of another Vector
--- @param fl number
--- @return userdata
function QAngle:SubtractSingle(fl)
    self.x = self.x - fl
    self.y = self.y - fl
    self.z = self.z - fl
    return self
end

--- Multiplies with a single float number instead of another Vector
--- @param fl number
--- @return userdata
function QAngle:MultiplySingle(fl)
    self.x = self.x * fl
    self.y = self.y * fl
    self.z = self.z * fl
    return self
end

--- Divides with a single float number instead of another Vector
--- @param fl number
--- @return userdata
function QAngle:DivideSingle(fl)
    self.x = self.x / fl
    self.y = self.y / fl
    self.z = self.z / fl
    return self
end

function QAngle:Normalized()

    local res = self:Copy()
    local l = res:Length()
    if ( l ~= 0.0 ) then
        res = res:DivideSingle(fl)
    else
        res.x = 0.00
        res.y = 0.00
        res.z = 0.00
    end
    return res
end

local IMaterialSystem = {
    address = 0
    -- Functions = {
    --     GetRenderContext = ffi.cast("uint32_t(__thiscall*)(uint32_t)",Utils.PatternScan("materialsystem.dll","56 57 8B F9 B9 ? ? ? ? FF 15 ? ? ? ? 8B F0 85 F6 75 12"))
    -- }
}

ffi.cdef[[
	typedef uint32_t	(__thiscall* CreateMaterial_FN)						(uint32_t,const char *,uint32_t);	
    typedef uint32_t    (__thiscall* GetBackBufferFormat_FN)                (uint32_t);
    typedef void        (__thiscall* BeginRenderTargetAllocation_FN)        (uint32_t);
    typedef void        (__thiscall* EndRenderTargetAllocation_FN)          (uint32_t);
    typedef uint32_t    (__thiscall* GetRenderContext_FN)                   (uint32_t);
    typedef uint32_t    (__thiscall* CreateNamedRenderTargetTextureEx_FN)   (uint32_t, const char* , int , int , int ,int , int ,uint8_t , int);
	typedef uint32_t	(__thiscall* FindMaterial_FN)						(uint32_t,char const* , const char * , bool, const char *);
    typedef uint32_t    (__thiscall* FindTexture_FN)                        (uint32_t,char const*,const char*,bool,int);
    typedef bool        (__thiscall* IsTextureLoaded_FN)                    (uint32_t,char const*);
]]

function IMaterialSystem:new (address)
    local Object = {}
    setmetatable(Object,self)
    self.__index = self
    self.address = address
    return Object
end

function IMaterialSystem:CreateMaterial(pMaterialName,pVMTKeyValues)
    return ffi.cast("CreateMaterial_FN",GetVirtualFunction(self.address,83))(self.address,pMaterialName,pVMTKeyValues)
end

function IMaterialSystem:FindMaterial(pMaterialName,pTextureGroupName)
    return ffi.cast("FindMaterial_FN",GetVirtualFunction(self.address,84))(self.address,pMaterialName,pTextureGroupName or ffi.cast("const char*",0),true,ffi.cast("const char*",0))
end

function IMaterialSystem:FindTexture(pTextureName,pTextureGroupName)
    return ffi.cast("FindTexture_FN",GetVirtualFunction(self.address,91))(self.address,pTextureName,pTextureGroupName or ffi.cast("const char*",0),true,0)
end

function IMaterialSystem:IsTextureLoaded(pTextureName)
    return ffi.cast("IsTextureLoaded_FN",GetVirtualFunction(self.address,92))(self.address,pTextureName)
end

function IMaterialSystem:GetBackBufferFormat ()
    -- print("GetBackBufferFormat: ",GetVirtualFunction(self.address,36))
    return ffi.cast("GetBackBufferFormat_FN",GetVirtualFunction(self.address,36))(self.address)
end

function IMaterialSystem:BeginRenderTargetAllocation ()
    -- print("BeginRenderTargetAllocation: ",GetVirtualFunction(self.address,94))
    ffi.cast("BeginRenderTargetAllocation_FN",GetVirtualFunction(self.address,94))(self.address)
end

function IMaterialSystem:EndRenderTargetAllocation ()
    -- print("EndRenderTargetAllocation: ",GetVirtualFunction(self.address,95))
    ffi.cast("EndRenderTargetAllocation_FN",GetVirtualFunction(self.address,95))(self.address)
end

function IMaterialSystem:GetRenderContext ()
    --print("GetRenderContext: ",GetVirtualFunction(self.address,115))
    return ffi.cast("GetRenderContext_FN",GetVirtualFunction(self.address,115))(self.address)
    -- return self.Functions.GetRenderContext(self.address)
end

function IMaterialSystem:CreateNamedRenderTargetTextureEx (name, w, h, sizeMode, format, depth, textureFlags, renderTargetFlags)
    -- print("CreateNamedRenderTargetTextureEx",GetVirtualFunction(self.address,97))
    return ffi.cast("CreateNamedRenderTargetTextureEx_FN",GetVirtualFunction(self.address,97))(
            self.address,
            name,
            w, h,
            sizeMode,
            format,
            depth,
            textureFlags,
            renderTargetFlags
    )
end

function IMaterialSystem:ForceBeginRenderTargetAllocation ()
    local m_bGameStarted = ffi.cast("bool*",ffi.cast("uint32_t",self.address) + 0x2C18)
    local oldState = m_bGameStarted[0]
    m_bGameStarted[0] = false
    self:BeginRenderTargetAllocation()
    m_bGameStarted[0] = oldState
end

function IMaterialSystem:ForceEndRenderTargetAllocation ()
    local m_bGameStarted = ffi.cast("bool*",ffi.cast("uint32_t",self.address) + 0x2C18)
    local oldState = m_bGameStarted[0]
    m_bGameStarted[0] = false
    self:EndRenderTargetAllocation()
    m_bGameStarted[0] = oldState
end

function IMaterialSystem:CreateFullFrameRenderTarget (name)
    return self:CreateNamedRenderTargetTextureEx(name,1,1,4,self:GetBackBufferFormat(),0,12,1)
end

local IMatRenderContext = {
    address = 0
    --Functions =
    --{
    --    Release = ffi.cast("int(__thiscall*)(uint32_t)",Utils.PatternScan("materialsystem.dll","56 8D 71 04 83 C8 FF F0 0F C1 46 ? 48 75 17 8B 06 8B CE 8B 40 04 FF D0")),
    --    SetRenderTarget = ffi.cast("void(__thiscall*)(uint32_t,uint32_t)",Utils.PatternScan("materialsystem.dll","55 8B EC FF 75 08 8B 01 6A 00 FF 90 ? ? ? ? 5D C2 04 00")),
    --    PushRenderTargetAndViewport = ffi.cast("void(__thiscall*)(uint32_t)",Utils.PatternScan("materialsystem.dll","56 8B F1 E8 ? ? ? ? 68 ? ? ? ? FF B6 ? ? ? ? 8D 8E ? ? ? ? E8 ? ? ? ? 5E C3")),
    --    PopRenderTargetAndViewport = ffi.cast("void(__thiscall*)(uint32_t)",Utils.PatternScan("materialsystem.dll","56 8B F1 83 7E 4C 00 74 14 8B 06 6A 00 FF 50 10 FF 4E 4C 8B CE 8B 06 FF 90 ? ? ? ? 68 ? ? ? ? FF B6 ? ? ? ? 8D 8E ? ? ? ? E8 ? ? ? ? 5E C3")),
    --    DrawScreenSpaceRectangle = ffi.cast("void(__thiscall*)(uint32_t, uint32_t, int, int, int, int, float, float, float, float, int, int, uint32_t, int, int )",Utils.PatternScan("materialsystem.dll","55 8B EC 51 53 56 57 8B F9 8B 4D 08 8B 01 FF 90 ? ? ? ? 8D 97 ? ? ? ?"))
    --}

}

ffi.cdef[[
    typedef int         (__thiscall* Release_FN)                        (uint32_t);
    typedef void        (__thiscall* SetRenderTarget_FN)                (uint32_t,uint32_t);
    typedef uint32_t    (__thiscall* GetRenderTarget_FN)                (uint32_t);
    typedef void        (__thiscall* DrawScreenSpaceRectangle_FN)       (uint32_t, uint32_t, int, int, int, int, float, float, float, float, int, int, uint32_t, int, int );
    typedef void        (__thiscall* PushRenderTargetAndViewport_FN)    (uint32_t);
    typedef void        (__thiscall* PopRenderTargetAndViewport_FN)     (uint32_t);
]]

function IMatRenderContext:new(address)
    local Object = {}
    setmetatable(Object,self)
    self.__index = self
    self.address = address
    return Object
end

function IMatRenderContext:Release ()
    --print("Release",GetVirtualFunction(self.address,1))
    --return self.Functions.Release(self.address)
    return ffi.cast("Release_FN",GetVirtualFunction(self.address,1))(self.address)
end

function IMatRenderContext:SetRenderTarget (texture)
    --print("SetRenderTarget: ",GetVirtualFunction(self.address, 6))
    --self.Functions.SetRenderTarget(self.address,texture)
    ffi.cast("SetRenderTarget_FN",GetVirtualFunction(self.address, 6))(self.address,texture)
end

function IMatRenderContext:GetRenderTarget ()
    --print("GetRenderTarget: ",GetVirtualFunction(self.address, 7))
    return ffi.cast("GetRenderTarget_FN",GetVirtualFunction(self.address, 7))(self.address)
end

function IMatRenderContext:PushRenderTargetAndViewport ()
    --print("PushRenderTargetAndViewport: ",GetVirtualFunction(self.address, 119))
    ffi.cast("PushRenderTargetAndViewport_FN",GetVirtualFunction(self.address, 119))(self.address)
    -- self.Functions.PushRenderTargetAndViewport(self.address)
end

function IMatRenderContext:PopRenderTargetAndViewport ()
    --print("PopRenderTargetAndViewport: ",GetVirtualFunction(self.address, 120))
    ffi.cast("PopRenderTargetAndViewport_FN",GetVirtualFunction(self.address, 120))(self.address)
    -- self.Functions.PopRenderTargetAndViewport(self.address)
end

function IMatRenderContext:DrawScreenSpaceRectangle(pMaterial,
                                                    destX, destY, width, height,
                                                    srcTextureX0, srcTextureY0, srcTextureX1, srcTextureY1,
                                                    srcTextureWidth, srcTextureHeight,
                                                    pClientRenderable, nXDice, nYDice)

    --print("DrawScreenSpaceRectangle",GetVirtualFunction(self.address,114))
    ffi.cast("DrawScreenSpaceRectangle_FN",GetVirtualFunction(self.address,114))(
            self.address, pMaterial,
            destX, destY,
            width, height,
            srcTextureX0, srcTextureY0,
            srcTextureX1, srcTextureY1,
            srcTextureWidth, srcTextureHeight,
            pClientRenderable,
            nXDice, nYDice)
    --self.Functions.DrawScreenSpaceRectangle(
    --        self.address, pMaterial,
    --        destX, destY,
    --        width, height,
    --        srcTextureX0, srcTextureY0,
    --        srcTextureX1, srcTextureY1,
    --        srcTextureWidth, srcTextureHeight,
    --        pClientRenderable,
    --        nXDice, nYDice)
end

local ITexture = {
    address = 0
    -- Functions = {
    --     GetActualWidth = ffi.cast("int(__thiscall*)(uint32_t)",Utils.PatternScan("materialsystem.dll","0F B7 41 36 C3")),
    --     GetActualHeight = ffi.cast("int(__thiscall*)(uint32_t)",Utils.PatternScan("materialsystem.dll","0F B7 41 38 C3"))
    -- }
}

ffi.cdef [[
    typedef int         (__thiscall* GetActualWidth_FN)             (uint32_t);
    typedef int         (__thiscall* GetActualHeight_FN)            (uint32_t);
	typedef void		(__thiscall* IncrementReferenceCount_FN)	(uint32_t);
	typedef void		(__thiscall* DecrementReferenceCount_FN)	(uint32_t);
    typedef void        (__thiscall* DeleteIfUnreferenced_FN)       (uint32_t);  
]]

function ITexture:new(address)
    local Object = {}
    setmetatable(Object,self)
    self.__index = self
    self.address = address
    return Object
end

function ITexture:GetActualWidth()
    --print("GetActualWidth",GetVirtualFunction(self.address,3))
    return ffi.cast("GetActualWidth_FN",GetVirtualFunction(self.address,3))(self.address)
    -- return self.Functions.GetActualWidth(self.address)
end

function ITexture:GetActualHeight()
    --print("GetActualHeight",GetVirtualFunction(self.address,4))
    return ffi.cast("GetActualHeight_FN",GetVirtualFunction(self.address,4))(self.address)
    -- return self.Functions.GetActualHeight(self.address)
end

function ITexture:IncrementReferenceCount()
    return ffi.cast("IncrementReferenceCount_FN",GetVirtualFunction(self.address,10))(self.address)
end

function ITexture:DecrementReferenceCount()
    return ffi.cast("DecrementReferenceCount_FN",GetVirtualFunction(self.address,11))(self.address)
end

function ITexture:DeleteIfUnreferenced()
    return ffi.cast("DeleteIfUnreferenced_FN",GetVirtualFunction(self.address,25))(self.address)
end

local IMaterial = {
    address = 0
    -- Functions = {
    --     GetActualWidth = ffi.cast("int(__thiscall*)(uint32_t)",Utils.PatternScan("materialsystem.dll","0F B7 41 36 C3")),
    --     GetActualHeight = ffi.cast("int(__thiscall*)(uint32_t)",Utils.PatternScan("materialsystem.dll","0F B7 41 38 C3"))
    -- }
}

ffi.cdef [[
    typedef const char* (__thiscall* GetName_FN)     				(uint32_t);
	typedef void		(__thiscall* IncrementReferenceCount_FN)	(uint32_t);
	typedef void		(__thiscall* DecrementReferenceCount_FN)	(uint32_t);
    typedef void		(__thiscall* DeleteIfUnreferenced_FN)	    (uint32_t);
]]

function IMaterial:new(address)
    local Object = {}
    setmetatable(Object,self)
    self.__index = self
    self.address = address
    return Object
end

function IMaterial:GetName()
    return ffi.cast("GetName_FN",GetVirtualFunction(self.address,0))(self.address)
end

function IMaterial:IncrementReferenceCount()
    return ffi.cast("IncrementReferenceCount_FN",GetVirtualFunction(self.address,12))(self.address)
end

function IMaterial:DecrementReferenceCount()
    return ffi.cast("DecrementReferenceCount_FN",GetVirtualFunction(self.address,13))(self.address)
end

function IMaterial:DeleteIfUnreferenced()
    return ffi.cast("DeleteIfUnreferenced_FN",GetVirtualFunction(self.address,50))(self.address)
end

local Math = { }
Math.__index = Math

function Math:VectorDistance(v1,v2)
    local x = v1.x - v2.x
    local y = v1.y - v2.y
    local z = v1.z - v2.z
    return math.sqrt(x*x + y*y + z*z)
end

function Math:CalcAngle(src,dst)
    local vAngle = QAngle:new()
    local delta = Vector3:new()
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
    local ang = Vector3:new()
    local aim = Vector3:new()

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
    if val < min then
        val = min
    elseif max < val then
        val = max
    end
    return val
end

function Math:IsInBounds(mouse_pos,first_point,second_point)
    if((mouse_pos.x >= first_point.x and mouse_pos.x <= second_point.x) and (mouse_pos.y >= first_point.y and mouse_pos.y <= second_point.y)) then
        return true
    end
    return false
end

ffi.cdef[[

typedef struct {
    float x,y,z;
} Vector;

typedef struct {
    float x,y;
} Vector2D;

typedef struct {
    float pitch,yaw,roll;
} QAngle;

typedef struct {
    int				x,y,width,height;
	struct vrect_t *pNext;
} vrect_t;

typedef struct
{
	int x;
    int oldX;
    int y;
    int oldY;
    int width;
    int oldWidth;
    int height;
    int oldHeight;

    bool m_bOrtho;
    float m_OrthoLeft;
    float m_OrthoTop;
    float m_OrthoRight;
    float m_OrthoBottom;


    char pad1[0x7C];


    float fov;
    float fovViewmodel;
    Vector origin;
    QAngle angles;

    float zNear;
    float zFar;
    float zNearViewmodel;
    float zFarViewmodel;

    float m_flAspectRatio;
    float m_flNearBlurDepth;
    float m_flNearFocusDepth;
    float m_flFarFocusDepth;
    float m_flFarBlurDepth;
    float m_flNearBlurRadius;
    float m_flFarBlurRadius;
    int m_nDoFQuality;
    int m_nMotionBlurMode;

    float m_flShutterTime;
    Vector m_vShutterOpenPosition;
    QAngle m_shutterOpenAngles;
    Vector m_vShutterClosePosition;
    QAngle m_shutterCloseAngles;

    float m_flOffCenterTop;
    float m_flOffCenterBottom;
    float m_flOffCenterLeft;
    float m_flOffCenterRight;

    bool m_bOffCenter : 1;
    bool m_bRenderToSubrectOfLargerScreen : 1;
    bool m_bDoBloomAndToneMapping : 1;
    bool m_bDoDepthOfField : 1;
    bool m_bHDRTarget : 1;
    bool m_bDrawWorldNormal : 1;
    bool m_bCullFrontFaces : 1;
    bool m_bCacheFullSceneState : 1;
    bool m_bRenderFlashlightDepthTranslucents : 1;
    char pad2[0x40];
} CViewSetup;

]]

--local function MakeCopyOfViewSetup(viewSetup)
--    local newSetup = ffi.new("CViewSetup")
--    --newSetup.vTable = viewSetup.vTable
--    newSetup.iX = viewSetup.iX
--    newSetup.iUnscaledX = viewSetup.iUnscaledX
--    newSetup.iY = viewSetup.iY
--    newSetup.iUnscaledY = viewSetup.iUnscaledY
--    newSetup.iWidth = viewSetup.iWidth
--    newSetup.iUnscaledWidth = viewSetup.iUnscaledWidth
--    newSetup.iHeight = viewSetup.iHeight
--    newSetup.iUnscaledHeight = viewSetup.iUnscaledHeight
--    newSetup.bOrtho = viewSetup.bOrtho
--    newSetup.flOrthoLeft = viewSetup.flOrthoLeft
--    newSetup.flOrthoTop = viewSetup.flOrthoTop
--    newSetup.flOrthoRight = viewSetup.flOrthoRight
--    newSetup.flOrthoBottom = viewSetup.flOrthoBottom
--    newSetup.pad0 = viewSetup.pad0
--    newSetup.flFOV = viewSetup.flFOV
--    newSetup.flViewModelFOV = viewSetup.flViewModelFOV
--    newSetup.vecOrigin = viewSetup.vecOrigin
--    newSetup.angView = viewSetup.angView
--    newSetup.flNearZ = viewSetup.flNearZ
--    newSetup.flFarZ = viewSetup.flFarZ
--    newSetup.flNearViewmodelZ = viewSetup.flNearViewmodelZ
--    newSetup.flFarViewmodelZ = viewSetup.flFarViewmodelZ
--    newSetup.flAspectRatio = viewSetup.flAspectRatio
--    newSetup.flNearBlurDepth = viewSetup.flNearBlurDepth
--    newSetup.flNearFocusDepth = viewSetup.flNearFocusDepth
--    newSetup.flFarFocusDepth = viewSetup.flFarFocusDepth
--    newSetup.flFarBlurDepth = viewSetup.flFarBlurDepth
--    newSetup.flNearBlurRadius = viewSetup.flNearBlurRadius
--    newSetup.flFarBlurRadius = viewSetup.flFarBlurRadius
--    newSetup.flDoFQuality = viewSetup.flDoFQuality
--    newSetup.nMotionBlurMode = viewSetup.nMotionBlurMode
--    newSetup.flShutterTime = viewSetup.flShutterTime
--    newSetup.vecShutterOpenPosition = viewSetup.vecShutterOpenPosition
--    newSetup.vecShutterOpenAngles = viewSetup.vecShutterOpenAngles
--    newSetup.vecShutterClosePosition = viewSetup.vecShutterClosePosition
--    newSetup.vecShutterCloseAngles = viewSetup.vecShutterCloseAngles
--    newSetup.flOffCenterTop = viewSetup.flOffCenterTop
--    newSetup.flOffCenterBottom = viewSetup.flOffCenterBottom
--    newSetup.flOffCenterLeft = viewSetup.flOffCenterLeft
--    newSetup.flOffCenterRight = viewSetup.flOffCenterRight
--    newSetup.bOffCenter = viewSetup.bOffCenter
--    newSetup.bRenderToSubrectOfLargerScreen = viewSetup.bRenderToSubrectOfLargerScreen
--    newSetup.bDoBloomAndToneMapping = viewSetup.bDoBloomAndToneMapping
--    newSetup.bDoDepthOfField = viewSetup.bDoDepthOfField
--    newSetup.bHDRTarget = viewSetup.bHDRTarget
--    newSetup.bDrawWorldNormal = viewSetup.bDrawWorldNormal
--    newSetup.bCullFontFaces = viewSetup.bCullFontFaces
--    newSetup.bCacheFullSceneState = viewSetup.bCacheFullSceneState
--    newSetup.bCSMView = viewSetup.bCSMView
--    return newSetup
--end


local GlobalSwitch = Menu.Switch("Spy Camera", "Enable Spy Cam", true, "Toggles the script.")

local CSpyCam =
{
	m_SpyTexture,
	m_SpyMaterial,
    m_nTargetEntity,
    m_vecPosition,
	m_vecSize

}

local AspectRatio_Values =
{
    0.0,
    1.77,
    1.33,
    0.5625
}

local AspectRatio_Selection = Menu.Combo("Spy Camera", "Aspect Ratio", {"Auto", "16:9 (Widescreen)", "4:3 (TV)" , "9:16 (Smartphone)"}, 0, "Changes the aspect ratio of the view")
local Dormant_Switch = Menu.Switch("Spy Camera", "Include dormant players", true, "Will include dormant players while iterating through the player list.")
local font_size = 15
local main_font = Render.InitFont("Verdana", font_size)

local UIValues =
{
    m_iWindowPos = Vector2.new(0,0),
    m_iWindowSize = Vector2.new(400,300),
    m_iHeaderSize = Vector2.new(400,20),
    m_szHeaderText = "SpyCam",
    m_iColor = Menu.ColorEdit("Spy Camera", "Window Color", Color.new(1.0, 1.0, 1.0, 1.0), "Changes the color of the spy cam window."),
    m_iHeaderTextColor = Menu.ColorEdit("Spy Camera", "Header Text Color", Color.new(0.0, 0.0, 0.0, 1.0), "Changes the color of the spy cam header text."),
    m_iPressed = -1,
    m_iHeldDelta = Vector2.new(0,0)
}



local Globals = {
    g_CHLClient = ffi.cast("uint32_t",Utils.CreateInterface("client.dll","VClient018")),
    g_ViewRender = ffi.cast("uint32_t**",ffi.cast("uint32_t",Utils.PatternScan("client.dll","A1 ? ? ? ? B9 ? ? ? ? C7 05 ? ? ? ? ? ? ? ? FF 10")) + 1)[0],
    g_pMaterialSystem = IMaterialSystem:new(ffi.cast("uint32_t",Utils.CreateInterface("materialsystem.dll","VMaterialSystem080"))),
	g_Input = ffi.cast("uint32_t",ffi.cast("uint32_t**",ffi.cast("uint32_t",Utils.PatternScan("client.dll","B9 ? ? ? ? F3 0F 11 04 24 FF 50 10")) + 1)[0]),
    g_fnRemoveEffects = ffi.cast("int (__thiscall*) (int, int)",Utils.PatternScan("client.dll","55 8B EC 53 8B 5D 08 8B C3 56 8B")),
    g_fnKeyValueFromString = ffi.cast("uint32_t (__fastcall*) (const char*,const char*,uint32_t)",Utils.PatternScan("client.dll","55 8B EC 81 EC ? ? ? ? 85 D2 53 56 57 BE ? ? ? ? 8B D9 8B FE 0F 45 FA FF 15 ? ? ? ?")),
    g_fnUpdateVisibilityAllEntities = ffi.cast("void(*)()",Utils.PatternScan("client.dll","53 56 66 8B 35 ? ? ? ? BB ? ? ? ? 57 90 66 3B F3 74 24 A1 ? ? ? ? 0F B7 CE 8B 3C C8 66 8B 74 C8 ?")),
    g_EntityList = ffi.cast("uint32_t",Utils.CreateInterface("client.dll","VClientEntityList003")), -- TODO: create interface table IClientEntityList
    g_ChamsMaterial = nil
}
Globals.g_ClientMode = ffi.cast("uint32_t",ffi.cast("uint32_t***",((ffi.cast("uint32_t**",Globals.g_CHLClient)[0])[10] + 0x5))[0][0])

ffi.cdef[[
    typedef uint32_t (__thiscall* GetClientEntity_FN) (uint32_t,int);
]]

Globals.g_fnGetClientEntity = function (index) return ffi.cast("GetClientEntity_FN",GetVirtualFunction(Globals.g_EntityList,3)) (Globals.g_EntityList,index) end
--local function onSpyCamMaterialLoaded(mat)
--     print("Spy cam material loaded.")
--     MatSystem.OverrideMaterial("LocalHands", mat)
--end
local Chams_Switch = Menu.Switch("Spy Camera", "Custom local player chams", false, "Because the default ones doesn't draw through walls.", function(val)
    if Globals.g_ChamsMaterial ~= nil then
        if val then
            MatSystem.OverrideMaterial("Localplayer", Globals.g_ChamsMaterial)
        else
            MatSystem.RemoveOverrideMaterial("Localplayer", Globals.g_ChamsMaterial)
        end    
    end
end)

local function onMaterialLoaded(mat)
    Globals.g_ChamsMaterial = mat
    if Chams_Switch:Get() then
        MatSystem.OverrideMaterial("Localplayer", Globals.g_ChamsMaterial)
    end
end

function CSpyCam:Init()

    -- Globals.g_pMaterialSystem:ForceBeginRenderTargetAllocation()
    -- Globals.g_pMaterialSystem:ForceEndRenderTargetAllocation()
    if Globals.g_pMaterialSystem:IsTextureLoaded("spycam_texture") then
        print("Spy cam texture already loaded.")
        self.m_SpyTexture = Globals.g_pMaterialSystem:FindTexture("spycam_texture","RenderTargets")
    else
        print("Spy cam texture not loaded,creating one..")
        self.m_SpyTexture = Globals.g_pMaterialSystem:CreateFullFrameRenderTarget("spycam_texture")
    end
    

    MatSystem.CreateMaterial("wireframe_material",  
    [[
        "VertexLitGeneric"
        {
            "$additive"         "1" 
            "$envmap"           "models/effects/cube_white" 
            "$envmapfresnel"    "1" 
            "$alpha"            "0.8"
            "$ignorez"          "1"
        }
    ]], onMaterialLoaded)

    self.m_SpyMaterial = Globals.g_pMaterialSystem:CreateMaterial("spycam_material",Globals.g_fnKeyValueFromString("UnlitGeneric","$basetexture spycam_texture",0))
    
	-- IMaterial:new(self.m_SpyMaterial):IncrementReferenceCount()
    -- ITexture:new(self.m_SpyTexture):IncrementReferenceCount()
    self.m_nTargetEntity = -1

    self.m_vecPosition = Vector2D:new()
    self.m_vecPosition:SetMembers(UIValues.m_iWindowPos.x,UIValues.m_iWindowPos.y + UIValues.m_iHeaderSize.y)

    self.m_vecSize = Vector2D:new()
    self.m_vecSize:SetMembers(UIValues.m_iWindowSize.x,UIValues.m_iWindowSize.y)


end

function CSpyCam:UpdateEntities()
    local local_player = EntityList.GetLocalPlayer()
    local enemies_only = EntityList.GetPlayers()
    local local_eye_pos = local_player:GetEyePosition()


    
    local entity_index = -1
    local latestFOV = 180.0
    for _,player in pairs(enemies_only) do
        if not player:IsTeamMate() and player:IsAlive() and ((player:IsDormant() and Dormant_Switch:Get()) or not player:IsDormant()) then
            local enemy_eye_pos = player:GetEyePosition()
            local enemy_angle = Math:CalcAngle(local_eye_pos,enemy_eye_pos)
			local engine_angle = QAngle:new()
			engine_angle:NLCopy(EngineClient.GetViewAngles())
            local fov_to_enemy = Math:GetFOV(engine_angle, enemy_angle)

            if(fov_to_enemy <= latestFOV) then
                latestFOV = fov_to_enemy
                entity_index = player:EntIndex()
            end
        end
    end
    self.m_nTargetEntity = entity_index
end

function CSpyCam:RenderUI()

    local header_loc = Vector2.new(UIValues.m_iWindowPos.x + UIValues.m_iHeaderSize.x,UIValues.m_iWindowPos.y + UIValues.m_iHeaderSize.y)
    Render.BoxFilled(UIValues.m_iWindowPos,UIValues.m_iWindowPos + UIValues.m_iHeaderSize,UIValues.m_iColor:GetColor() )

    local text_size = Render.CalcTextSize(UIValues.m_szHeaderText,font_size,main_font)
	Render.Text(UIValues.m_szHeaderText, Vector2.new(UIValues.m_iWindowPos.x + UIValues.m_iHeaderSize.x/2 - text_size.x/2 , UIValues.m_iWindowPos.y + UIValues.m_iHeaderSize.y/2 - text_size.y/2), UIValues.m_iHeaderTextColor:GetColor(), font_size,main_font)

    local spy_cam_loc = Vector2.new(UIValues.m_iWindowPos.x,UIValues.m_iWindowPos.y + UIValues.m_iHeaderSize.y)
    Render.Box(spy_cam_loc, spy_cam_loc + UIValues.m_iWindowSize, UIValues.m_iColor:GetColor())

    CSpyCam.m_vecPosition:SetMembers(spy_cam_loc.x,spy_cam_loc.y)
    CSpyCam.m_vecSize:SetMembers(UIValues.m_iWindowSize.x,UIValues.m_iWindowSize.y)
end

function CSpyCam:Input()

    local start_bound = UIValues.m_iWindowPos
    local end_bound = Vector2.new(UIValues.m_iWindowPos.x + UIValues.m_iWindowSize.x ,UIValues.m_iWindowPos.y + UIValues.m_iHeaderSize.y + UIValues.m_iWindowSize.y)

    local mouse_pos = Cheat.GetMousePos()

    local menu_size = Render.GetMenuSize()
    local menu_pos = Render.GetMenuPos()

    local menu_end_bound = Vector2.new(menu_pos.x + menu_size.x,menu_pos.y + menu_size.y)

    local resize_bounds = Vector2.new(15,15)
    local end_bound_resize = Vector2.new(end_bound.x + resize_bounds.x,end_bound.y + resize_bounds.y)

    local poly_table = {Vector2.new(end_bound.x, end_bound.y + resize_bounds.y),Vector2.new( end_bound.x + resize_bounds.x, end_bound.y ),Vector2.new(end_bound.x + resize_bounds.x, end_bound.y + resize_bounds.y)}

	Render.PolyFilled(Color.new(1.0, 1.0, 1.0, 1.0), unpack(poly_table))
    if not Cheat.IsKeyDown(0x1) then
        UIValues.m_iPressed = -1
    end

    if Cheat.IsMenuVisible() and Math:IsInBounds(mouse_pos,menu_pos,menu_end_bound) and Cheat.IsKeyDown(0x1) then -- menu takes priority
        return
    end

    --- How it works (future self reference) :
    --- Use the normal bounding checking ( Math:IsInBounds(mouse_pos,start_bound,end_bound) and input.is_key_held(e_keys.MOUSE_LEFT) )
    --- AND Make sure we're not dragging anything else ( UIValues.m_iPressed == -1 )
    --- If the above conditions are met,execute the operations.
    --- Then inside,set the context number.
    --- Next frame,the context number is set and we only need the second expression (input.is_key_held(e_keys.MOUSE_LEFT) and UIValues.m_iPressed == ContextNum)
    --- Only reset the context number if the mouse key is released,making us able to drag any item smoothly even if it's not in bound.(Fixes resizing too fast)


    if(Math:IsInBounds(mouse_pos,start_bound,end_bound) and Cheat.IsKeyDown(0x1) and UIValues.m_iPressed == -1) then
        UIValues.m_iHeldDelta.x = mouse_pos.x - UIValues.m_iWindowPos.x
        UIValues.m_iHeldDelta.y = mouse_pos.y - UIValues.m_iWindowPos.y
    end

    if (Math:IsInBounds(mouse_pos,start_bound,end_bound) and Cheat.IsKeyDown(0x1) and UIValues.m_iPressed == -1) or (Cheat.IsKeyDown(0x1) and UIValues.m_iPressed == 1)  then
        UIValues.m_iPressed = 1
        -- UIValues.m_iWindowPos.x = mouse_pos.x - UIValues.m_iWindowSize.x/2
        -- UIValues.m_iWindowPos.y = mouse_pos.y - UIValues.m_iWindowSize.y/2

        UIValues.m_iWindowPos.x = mouse_pos.x - UIValues.m_iHeldDelta.x
        UIValues.m_iWindowPos.y = mouse_pos.y - UIValues.m_iHeldDelta.y

        local screen_size = EngineClient.GetScreenSize()
        UIValues.m_iWindowPos.x = Math:Clamp(UIValues.m_iWindowPos.x,0,screen_size.x - UIValues.m_iWindowSize.x)
        UIValues.m_iWindowPos.y = Math:Clamp(UIValues.m_iWindowPos.y,0,screen_size.y - UIValues.m_iWindowSize.y)
        return
    end


    if (Math:IsInBounds(mouse_pos,end_bound,end_bound_resize) and Cheat.IsKeyDown(0x1) and UIValues.m_iPressed == -1) or (Cheat.IsKeyDown(0x1) and UIValues.m_iPressed == 2) then
        UIValues.m_iPressed = 2

        UIValues.m_iWindowSize.x = math.abs(mouse_pos.x - UIValues.m_iWindowPos.x) - resize_bounds.x/2
        UIValues.m_iWindowSize.y = math.abs(mouse_pos.y - (UIValues.m_iWindowPos.y + UIValues.m_iHeaderSize.y)) - resize_bounds.y/2

        UIValues.m_iHeaderSize.x = UIValues.m_iWindowSize.x

        Render.PolyFilled(Color.new(0.0, 1.0, 0.0, 1.0), unpack(poly_table))

        
        return
    end

end

function CSpyCam:Render()

    if(self.m_nTargetEntity == -1)then
        return
    end
    local ctx = IMatRenderContext:new(Globals.g_pMaterialSystem:GetRenderContext())

    local texture = ITexture:new(self.m_SpyTexture)

    ctx:DrawScreenSpaceRectangle(self.m_SpyMaterial,
            self.m_vecPosition.x,self.m_vecPosition.y,
            self.m_vecSize.x,self.m_vecSize.y,
            0,0,
            self.m_vecSize.x,self.m_vecSize.y,
            texture:GetActualWidth(),texture:GetActualHeight(),
            0,
            1,1)
    ctx:Release()


end

function CSpyCam:CalcView(view,entity)
    local local_player = EntityList.GetLocalPlayer()

    local local_eye_pos = local_player:GetEyePosition()
    local origin = entity:GetEyePosition() -- to pass to trace.line
    local custom_origin = Vector3:new() -- to calculate with
    custom_origin:SetMembers(origin.x,origin.y,origin.z)

    local angle = Math:CalcAngle(custom_origin,local_eye_pos)
    local angle_inverse = angle:Copy()

    angle_inverse.x = angle_inverse.x * -1.0
    angle_inverse.y = angle_inverse.y + 180.0

    local inverse_vector = Vector3:new()
    Math:AngleVectors(angle_inverse,inverse_vector)

    local ray_end = (custom_origin + (inverse_vector:MultiplySingle(130.0)))
    local trace_result = EngineTrace.TraceRay(origin,Vector.new(ray_end.x, ray_end.y, ray_end.z),entity,0x0001400B)
    local ray_casted = (custom_origin + (inverse_vector:MultiplySingle(130.0 * trace_result.fraction)))


    local new_angle = Math:CalcAngle(ray_casted,local_eye_pos)

    view.origin = ffi.new("Vector",{ray_casted.x,ray_casted.y,ray_casted.z + 10.0})
    view.angles = ffi.new("QAngle",{ new_angle.x,new_angle.y,new_angle.z })
end

ffi.cdef[[
	typedef void(__thiscall* RenderView_FN) (uint32_t,CViewSetup &, int , int);
]]

local mat_postprocess = CVar.FindVar("mat_postprocess_enable")

function CSpyCam:OnViewRender(ecx,view,original)
    if(self.m_nTargetEntity == -1)then
        return
    end

    local entity = EntityList.GetPlayer(self.m_nTargetEntity)

    local spyView = ffi.new("CViewSetup[1]",{})
    ffi.copy(spyView,view,0x18C)
    spyView = spyView[0]

    spyView.x = 0
    spyView.oldX = 0
    spyView.y = 0
    spyView.oldY = 0
    spyView.width = self.m_vecSize.x
    spyView.oldWidth = self.m_vecSize.x
    spyView.height = self.m_vecSize.y
    spyView.oldHeight = self.m_vecSize.y
    spyView.m_flAspectRatio = AspectRatio_Values[AspectRatio_Selection:Get() + 1]

    -- spyView.m_flNearBlurDepth = 0.0
    -- spyView.m_flNearFocusDepth = 0.0
    -- spyView.m_flFarBlurDepth = 0.0
    -- spyView.m_flFarFocusDepth = 0.0
    -- spyView.m_flNearBlurRadius = 0.0
    -- spyView.m_flFarBlurRadius = 0.0;
    -- spyView.m_nMotionBlurMode = 1

    -- spyView.zNear = 100.0
    -- spyView.zNearViewmodel = 100.0
    -- spyView.zFar = 28377.9199
    -- spyView.zFarViewmodel = 28377.9199

    -- spyView.fov = 100.0
    self:CalcView(spyView,entity)
    mat_postprocess:SetString("0")
    local renderCtx = IMatRenderContext:new(Globals.g_pMaterialSystem:GetRenderContext())

    renderCtx:PushRenderTargetAndViewport()
    renderCtx:SetRenderTarget(self.m_SpyTexture)

    --ffi.cast("RenderView_FN",GetVirtualFunction(Globals.g_CHLClient,28))(ecx,view,35,0)
    local old = ffi.cast("bool*", Globals.g_Input+0xa9)[0]
    ffi.cast("bool*", Globals.g_Input+0xa9)[0] = true
    Globals.g_fnUpdateVisibilityAllEntities()
    
    original(ecx,spyView,spyView,35,4)
    ffi.cast("bool*", Globals.g_Input+0xa9)[0] = old
    

    renderCtx:PopRenderTargetAndViewport()
    renderCtx:Release()
    Globals.g_fnUpdateVisibilityAllEntities()

end

function OnPaintTraverse()
    local local_player = EntityList.GetLocalPlayer()
    if GlobalSwitch:Get() and EngineClient.IsConnected() and EngineClient.IsInGame() and local_player and local_player:IsAlive() then
        CSpyCam:UpdateEntities()
        CSpyCam:Render()
    end
end

function OnDraw()
    if GlobalSwitch:Get() and (Cheat.IsMenuVisible() or CSpyCam.m_nTargetEntity ~= -1 )then
        CSpyCam:RenderUI()
        CSpyCam:Input()
    end
end

function myerrorhandler( err )
    print( "ERROR:", err )
end

 function hkRenderView(original) -- 6
     function RenderView(ecx, viewSetup, viewHUD, nClearFlags, nWhatToDraw)

        --local view = ffi.cast("CViewSetup*",ffi.cast("uint32_t**",Utils.PatternScan("client.dll","8B 0D 6C ?? ?? ?? D9 1D ?? ?? ?? ??") + 2)[0][0])
        local local_player = EntityList.GetLocalPlayer()
        if viewSetup and EngineClient.IsConnected() and EngineClient.IsInGame() and local_player and local_player:IsAlive() then
            xpcall(CSpyCam.OnViewRender,myerrorhandler,CSpyCam,ecx,viewSetup,original)
        end

        return original(ecx, viewSetup, viewHUD, nClearFlags, nWhatToDraw)

     end
     return RenderView
 end

--function hkRenderView(original) -- 27
--    function RenderView(ecx,rect)
--
--        local local_player = EntityList.GetLocalPlayer()
--
--        local view_ptr = ffi.cast("uint32_t**",fnGetModuleHandle("client.dll") + 0x1B0AE0)[0][0]
--        local view = ffi.cast("CViewSetup*",view_ptr)
--
--        if not(not view or not EngineClient.IsConnected() or not EngineClient.IsInGame() or not local_player or not local_player:IsAlive()) then
--            xpcall(CSpyCam.OnViewRender,myerrorhandler,CSpyCam,ecx,view,original)
--        end
--
--        return original(ecx,rect)
--
--    end
--    return RenderView
--end

CSpyCam:Init()

local nativeIPanelGetName=__thiscall(vtable_bind("vgui2.dll", "VGUI_Panel009",36,"const char* (__thiscall*)(void*,int)"))

function PaintTraverseHook(originalFunction)
    local originalFunction=originalFunction
    local topPanel=nil

    function PaintTraverse(this,panel,forceRepaint,allowForce)
        if topPanel==nil then
            local name=ffi.string(nativeIPanelGetName(panel))
            if name=="FocusOverlayPanel" then
                topPanel=panel
            end
        end

        if panel==topPanel then
            OnPaintTraverse()
        end
        return originalFunction(this,panel,forceRepaint,allowForce)
    end
    return PaintTraverse
end

local ViewRender_Hook = hook.vmt.new(Globals.g_ViewRender)
ViewRender_Hook.hookMethod("void(__thiscall*)(uint32_t,CViewSetup*,CViewSetup*,int,int)", hkRenderView,6)

--local RenderView_Hook = hook.vmt.new(Globals.g_CHLClient) -- not used
--RenderView_Hook.hookMethod("void(__thiscall*)(uint32_t,uint32_t)", hkRenderView,27)

local IPanel = hook.vmt.new(Utils.CreateInterface("vgui2.dll", "VGUI_Panel009"))
IPanel.hookMethod("void(__thiscall*)(void*,int,bool,bool)",PaintTraverseHook,41)

-- function hkEyeAngles(original)
--     local original = original
--     function EyeAngles(ecx,edx)

        
--         return original(ecx,edx)

--     end
--     return EyeAngles
-- end

-- local EyeAngleHook = direct_hook.new(fnGetModuleHandle("client.dll") + 0xBCAC48)
-- EyeAngleHook.hookMethod("const QAngle& (__fastcall*) (uint32_t,uint32_t)",hkEyeAngles)

local function on_shutdown()
    ViewRender_Hook.unHookAll()
	IPanel.unHookAll()
    -- EyeAngleHook.unHook()

    -- local material = IMaterial:new(CSpyCam.m_SpyMaterial)
    -- material:DecrementReferenceCount()
    -- material:DeleteIfUnreferenced()
    -- local texture = ITexture:new(CSpyCam.m_SpyTexture)
    -- texture:DecrementReferenceCount()
    -- texture:DeleteIfUnreferenced()
	--RenderView_Hook.unHookAll()
end


-- pvs fix
Cheat.RegisterCallback("frame_stage", function(stage)
    if stage ~= 5 then return end
    
    for i = 1,GlobalVars.maxClients do
        
        local entity = Globals.g_fnGetClientEntity(i)
        
        if entity ~= 0 then 
            ffi.cast("int*",entity + 0xA30)[0] = GlobalVars.framecount
            ffi.cast("int*",entity + 0xA28)[0] = 0
        end

    end

end)

Cheat.RegisterCallback("draw", OnDraw)
Cheat.RegisterCallback("destroy", on_shutdown)