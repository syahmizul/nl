local pGetModuleHandle_sig = ffi.cast("uint32_t",utils.opcode_scan("engine.dll", "FF 15 ? ? ? ? 85 C0 74 0B"))
local pGetModuleHandle = ffi.cast("uint32_t**", ffi.cast("uint32_t", pGetModuleHandle_sig) + 2)[0][0]
local fnGetModuleHandle = ffi.cast("uint32_t(__stdcall*)(const char*)", pGetModuleHandle)

local clientStatePtr = ffi.cast("uint32_t*",fnGetModuleHandle("engine.dll") + 0x59F194)[0]
print(ffi.cast("uint32_t*",(clientStatePtr + 264))[0])
