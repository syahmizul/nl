local ffi = require "ffi"
local C = ffi.C

ffi.cdef "int       CreateDirectoryA(const char*, void*)"
ffi.cdef "void*     CreateFileA(const char*, uintptr_t, uintptr_t, void*, uintptr_t, uintptr_t, void*)"
ffi.cdef "uintptr_t GetFileSize(void*, uintptr_t*)"
ffi.cdef "int       ReadFile(void*, void*, uintptr_t, uintptr_t*, void*)"
ffi.cdef "int       WriteFile(void*, const void*, uintptr_t, uintptr_t*, void*)"
ffi.cdef "int       CloseHandle(void*)"

local ct = ffi.typeof("char[?]")
local c_invalid_handle_value = ffi.cast("void*", -1)

function package.loaded.readfile(filename)
    local fp = C.CreateFileA(filename, 0x80000000, 3, nil, 3, 128, nil)
    if c_invalid_handle_value ~= fp then
        local size = C.GetFileSize(fp, nil)
        local buf = ct(size + 1)
        C.ReadFile(fp, buf, size, nil, nil)
        C.CloseHandle(fp)
        return ffi.string(buf, size)
    end
end

function package.loaded.writefile(filename, str)
    local fp = C.CreateFileA(filename, 0x40000000, 3, nil, 2, 128, nil)
    if c_invalid_handle_value ~= fp then
        C.WriteFile(fp, str, #str, nil, nil)
        C.CloseHandle(fp)
        return true
    end
    return false
end

print("WHAT",require("readfile")("../Phasmophobia/baselib.dll"))