ffi.cdef[[
	uint32_t 	CreateFileA     (const char*,uint32_t,uint32_t,uint32_t,uint32_t,uint32_t,uint32_t);
	bool 		CloseHandle     (uint32_t);
	uint32_t	GetFileSize     (uint32_t,uint32_t);
	bool		ReadFile        (uint32_t,char *,uint32_t,uint32_t*,uint32_t);
	uint32_t        SetFilePointer  (uint32_t,int32_t,uint32_t,uint32_t);
	uint32_t        GetLastError    ();
        uint32_t        GetFileAttributesA(const char* lpFileName);
]]
function LoadMap()
	local MapName = "de_dust2" -- change this if u want
	local MapConcattedWithDirectory = EngineClient.GetGameDirectory() .. "\\maps\\" .. MapName .. ".nav"
	print("MapConcattedWithDirectory : ",MapConcattedWithDirectory)
	local fileHandle = ffi.C.CreateFileA(MapConcattedWithDirectory,0x10000000,0x1,0,4,0x80,0)
	print("GetLastError",ffi.C.GetLastError())
	print("FileHandle :",fileHandle)
	if (ffi.C.GetFileAttributesA(MapConcattedWithDirectory) == 0xFFFFFFFF ) then
		print(".nav file for this map doesn't exist.")
		ffi.C.CloseHandle(fileHandle)
		return
	end

	local filesize = ffi.C.GetFileSize(fileHandle,0)
	print("File Size : ",filesize)
	if( filesize == 0 )then
	   print(".nav file is empty.")
	   ffi.C.CloseHandle(fileHandle)
	   return
	end

	local buffer = ffi.typeof("unsigned char[?]")(filesize + 1)
	local NumberOfBytesRead = ffi.new("uint32_t[1]",{})

	ffi.C.ReadFile(fileHandle,buffer,filesize, NumberOfBytesRead,0)
	ffi.C.CloseHandle(fileHandle)
end

LoadMap()