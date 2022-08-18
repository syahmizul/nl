-- ffi.cdef[[
    -- typedef int             (__thiscall* Read_FN)               (uint32_t,void*,int,uint32_t);
    -- typedef int             (__thiscall* Write_FN)              (uint32_t,void*,int,uint32_t);

    -- typedef uint32_t        (__thiscall* Open_FN)               (uint32_t,const char*,const char *,const char *);
    -- typedef void            (__thiscall* Close_FN)              (uint32_t,uint32_t);

    -- typedef void            (__thiscall* Seek_FN)               (uint32_t,uint32_t,int,int);
    -- typedef unsigned int    (__thiscall* Tell_FN)               (uint32_t,uint32_t);
    -- typedef unsigned int    (__thiscall* Size_FN)               (uint32_t,uint32_t);
    -- typedef unsigned int	(__thiscall* Size2_FN)              (uint32_t,const char *, const char *);

    -- typedef void            (__thiscall* Flush_FN)              (uint32_t,uint32_t);
    -- typedef bool            (__thiscall* Precache_FN)           (uint32_t,const char *, const char *);

    -- typedef bool            (__thiscall* FileExists_FN)         (uint32_t,const char *, const char *);
    -- typedef bool            (__thiscall* IsFileWritable_FN)     (uint32_t,const char *, const char *);
    -- typedef bool            (__thiscall* SetFileWritable_FN)    (uint32_t,const char *,bool, const char *);

    -- typedef long            (__thiscall* GetFileTime_FN)        (uint32_t,const char *, const char *);

-- ]]

-- local IBaseFileSystem = {
    -- address = 0
-- }

-- function IBaseFileSystem:new (address)
    -- local Object = {}
    -- setmetatable(Object,self)
    -- self.__index = self
    -- self.address = address
    -- return Object
-- end

-- function IBaseFileSystem:Read(pOutput,size,fileHandle)
    -- return ffi.cast("Read_FN",GetVirtualFunction(self.address,0))(self.address,pOutput,size,fileHandle)
-- end

-- function IBaseFileSystem:Write(pInput,size,fileHandle)
    -- return ffi.cast("Write_FN",GetVirtualFunction(self.address,1))(self.address,pInput,size,fileHandle)
-- end

-- function IBaseFileSystem:Open(pFileName,pOptions,pathID)
    -- return ffi.cast("Open_FN",GetVirtualFunction(self.address,2))(self.address,pFileName,pOptions,pathID or ffi.cast("const char*",0))
-- end

-- function IBaseFileSystem:Close(fileHandle)
    -- ffi.cast("Close_FN",GetVirtualFunction(self.address,3))(self.address,fileHandle)
-- end

-- function IBaseFileSystem:Seek(fileHandle,pos,seekType)
    -- ffi.cast("Seek_FN",GetVirtualFunction(self.address,4))(self.address,fileHandle,pos,seekType)
-- end

-- function IBaseFileSystem:Tell(fileHandle)
    -- return ffi.cast("Tell_FN",GetVirtualFunction(self.address,5))(self.address,fileHandle)
-- end
-- use file handle
-- function IBaseFileSystem:SizeHandle(fileHandle)
    -- return ffi.cast("Size_FN",GetVirtualFunction(self.address,6))(self.address,fileHandle)
-- end

-- use file name 
-- function IBaseFileSystem:SizeFileName(pFileName,pPathID)
    -- return ffi.cast("Size2_FN",GetVirtualFunction(self.address,7))(self.address,pFileName,pPathID or ffi.cast("const char*",0))
-- end

-- function IBaseFileSystem:Flush(fileHandle)
    -- ffi.cast("Flush_FN",GetVirtualFunction(self.address,8))(self.address,fileHandle)
-- end

-- function IBaseFileSystem:Precache(pFileName,pPathID)
    -- return ffi.cast("Precache_FN",GetVirtualFunction(self.address,9))(self.address,pFileName,pPathID or ffi.cast("const char*",0))
-- end

-- function IBaseFileSystem:FileExists(pFileName,pPathID)
    -- return ffi.cast("FileExists_FN",GetVirtualFunction(self.address,10))(self.address,pFileName,pPathID or ffi.cast("const char*",0))
-- end

-- function IBaseFileSystem:IsFileWritable(pFileName,pPathID)
    -- return ffi.cast("IsFileWritable_FN",GetVirtualFunction(self.address,11))(self.address,pFileName,pPathID or ffi.cast("const char*",0))
-- end

-- function IBaseFileSystem:SetFileWritable(pFileName,writable,pPathID)
    -- return ffi.cast("SetFileWritable_FN",GetVirtualFunction(self.address,12))(self.address,pFileName,writable,pPathID or ffi.cast("const char*",0))
-- end

-- function IBaseFileSystem:GetFileTime(pFileName,pPathID)
    -- return ffi.cast("GetFileTime_FN",GetVirtualFunction(self.address,13))(self.address,pFileName,pPathID or ffi.cast("const char*",0))
-- end

-- local g_FileSystem = IBaseFileSystem:new(ffi.cast("uint32_t",Utils.CreateInterface("filesystem_stdio.dll", "VBaseFileSystem011")))
-- local FileHandle = g_FileSystem:Open("ar_shoots_story.txt", "r", "GAME")
-- if(tonumber(FileHandle) > 0) then

    -- local FileText = ffi.new("char[1024]", {})
    -- g_FileSystem:Read(ffi.cast("void*",FileText),1024,FileHandle)
    -- g_FileSystem:Close(FileHandle)

    -- print("FILETEXT",ffi.string(FileText,1024))
-- else
    -- print("File not found!")
-- end
-- Valve file API above^^

local Vector3D = require("nl/Vector")
local Angle = require("nl/QAngle")
local Math = require("nl/Math")

local function GetVirtualFunction(address,index)
    local vtable = ffi.cast("uint32_t**",address)[0]
    return ffi.cast("uint32_t",vtable[index])
 end

ffi.cdef[[
	uint32_t 	CreateFileA     (const char*,uint32_t,uint32_t,uint32_t,uint32_t,uint32_t,uint32_t);
	bool 		CloseHandle     (uint32_t);
	uint32_t	GetFileSize     (uint32_t,uint32_t);
	bool		ReadFile        (uint32_t,char *,uint32_t,uint32_t*,uint32_t);
	uint32_t    SetFilePointer  (uint32_t,int32_t,uint32_t,uint32_t);
	uint32_t    GetLastError    ();
    uint32_t    GetFileAttributesA(const char* lpFileName);
]]

ffi.cdef[[
	typedef struct
	{
		float x,y,z;
	} Vector;

	typedef struct
	{
		Vector v;
		float w;
	} VectorAligned;

	typedef struct
	{
		Vector normal;
		float dist;
		uint8_t type;   // for fast side tests
		uint8_t signbits;  // signx + (signy<<1) + (signz<<1)
		uint8_t pad[2];

	} cplane_t;

	typedef struct
	{
		const char     *name;
		short          surfaceProps;
		unsigned short flags;         // BUGBUG: These are declared per surface, not per material, but this database is per-material now
	} csurface_t;

	typedef struct
	{


		// these members are aligned!!
		Vector         startpos;            // start position
		Vector         endpos;              // final position
		cplane_t       plane;               // surface normal at impact

		float          fraction;            // time completed, 1.0 = didn't hit anything
		int            contents;            // contents on other side of surface hit
		uint16_t dispFlags;           // displacement flags for marking surfaces with data

		bool           allsolid;            // if true, plane is not valid
		bool           startsolid;          // if true, the initial point was in a solid area
	} CBaseTrace;


	typedef struct
	{
		CBaseTrace 			BaseTrace;
		float               fractionleftsolid;  // time we left a solid, only valid if we started in solid
		csurface_t          surface;            // surface hit (impact surface)
		int                 hitgroup;           // 0 == generic, non-zero is specific body part
		short               physicsbone;        // physics bone hit by trace in studio
		uint16_t     		worldSurfaceIndex;  // Index of the msurface2_t, if applicable
		uint32_t      		hit_entity;
		int                 hitbox;                       // box hit by trace in studio
	} CGameTrace;

	typedef struct
	{
		VectorAligned  m_Start;  // starting point, centered within the extents
		VectorAligned  m_Delta;  // direction + length of the ray
		VectorAligned  m_StartOffset; // Add this to m_Start to Get the actual ray start
		VectorAligned  m_Extents;     // Describes an axis aligned box extruded along a ray
		uint32_t m_pWorldAxisTransform;
		bool m_IsRay;  // are the extents zero?
		bool m_IsSwept;     // is delta != 0?
	} Ray_t;

	typedef struct
	{
	    uint32_t vTable;
	    uint32_t pSkip;
	} ITraceFilter;
]]

ffi.cdef [[
    typedef void(__thiscall* TraceRay_FN)(uint32_t this,const Ray_t &ray, uint32_t fMask,ITraceFilter* filter, CGameTrace *pTrace);
]]

local function InitializeRay(Ray,VecStart,VecEnd)
    Ray.m_Delta = VecEnd - VecStart
    Ray.m_IsSwept = (Vector3D:new(Ray.m_Delta.v.x,Ray.m_Delta.v.y,Ray.m_Delta.v.z):LengthSqr() ~= 0)

    -- m_Extents.Init();
    local extents = Ray.m_Extents.v
    extents.x = 0.0
    extents.y = 0.0
    extents.z = 0.0

    Ray.m_pWorldAxisTransform = 0
    Ray.m_IsRay = true

    -- // Offset m_Start to be in the center of the box...

    local StartOffset = Ray.m_StartOffset.v
    StartOffset.x = 0.0
    StartOffset.y = 0.0
    StartOffset.z = 0.0

    Ray.m_Start.v = ffi.new("Vector",{VecStart.x,VecStart.y,VecStart.z})
end


local pGetModuleHandle_sig = ffi.cast("uint32_t",Utils.PatternScan("engine.dll", " FF 15 ? ? ? ? 85 C0 74 0B"))
local pGetModuleHandle = ffi.cast("uint32_t**", ffi.cast("uint32_t", pGetModuleHandle_sig) + 2)[0][0]
local fnGetModuleHandle = ffi.cast("uint32_t(__stdcall*)(const char*)", pGetModuleHandle)


local g_EngineTrace = ffi.cast("uint32_t",Utils.CreateInterface("engine.dll","EngineTraceClient004"))
local function TraceRay(ray,mask,filter,trace)
    ffi.cast("TraceRay_FN",GetVirtualFunction(g_EngineTrace , 5)) (g_EngineTrace,ray,mask,filter,trace)
end

ffi.cdef [[
	typedef bool (__thiscall* IsBreakableEntity_FN) (uint32_t EntityAddress);
]]
local IsBreakableEntity = ffi.cast("IsBreakableEntity_FN",Utils.PatternScan("client.dll", "55 8B EC 51 56 8B F1 85 F6 74 68 83 BE"))

ffi.cdef [[
    typedef uint32_t(__thiscall* GetClientEntity_FN)(uint32_t this,uint32_t entNum);
]]

local g_EntityList = ffi.cast("uint32_t",Utils.CreateInterface("client.dll","VClientEntityList003"))
local function GetClientEntity(entNum)
    return ffi.cast("GetClientEntity_FN",GetVirtualFunction(g_EntityList , 3))(g_EntityList,entNum)
end

ffi.cdef [[
	typedef bool        (__thiscall* IsDrawingLoadingImage_FN)          (uint32_t this);
    typedef bool        (__thiscall* IsTransitioningToLoad_FN)          (uint32_t this);
    typedef bool        (__thiscall* IsClientLocalToActiveServer_FN)    (uint32_t this);
    typedef char const* (__thiscall* GetLevelNameShort_FN)              (uint32_t this);
]]
local g_EngineClient = ffi.cast("uint32_t",Utils.CreateInterface("engine.dll","VEngineClient014"))

local function IsDrawingLoadingImage()
    return ffi.cast("IsDrawingLoadingImage_FN",GetVirtualFunction(g_EngineClient , 28))(g_EngineClient)
end

local function IsTransitioningToLoad()
    return ffi.cast("IsTransitioningToLoad_FN",GetVirtualFunction(g_EngineClient , 182))(g_EngineClient)
end

local function GetLevelNameShort()
    return ffi.cast("GetLevelNameShort_FN",GetVirtualFunction(g_EngineClient , 53))(g_EngineClient)
end

local function IsClientLocalToActiveServer()
    return ffi.cast("IsClientLocalToActiveServer_FN",GetVirtualFunction(g_EngineClient , 197))(g_EngineClient)
end

local g_GameUI = ffi.cast("uint32_t",Utils.CreateInterface("client.dll","GameUI011"))
local g_GameState = ffi.cast("int*",g_GameUI + 0x1E4)

local function GetGameState ()
    return g_GameState[0]
end

local clientStatePtr = ffi.cast("uint32_t*",fnGetModuleHandle("engine.dll") + 5820380)[0]

local function GetSignOnState()
    local SignOnState = ffi.cast("uint32_t*",(clientStatePtr + 264))[0]
    return SignOnState
end

local g_EngineVGUI = ffi.cast("uint32_t",Utils.CreateInterface("engine.dll","VEngineVGui001"))

local scr_disabled_for_loading = ffi.cast("bool*",fnGetModuleHandle("engine.dll") + 0x62A115)

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

-- TODO: Stream next time,probably won't work with big maps / complex nav mesh
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
    --print("BufferPointer",tonumber(BufferPointer))
    --print("BufferPointerOffsetByPosition",BufferPointerOffsetByPosition)
    --
    --if(ffi.cast("uint32_t*",TempVariable)[0] == 0xFEEDFACE) then
    --    print("SAME")
    --end
    --print(self.Buffer[self.Position])
    self.Position = self.Position + SizeToRead
    return TempVariable
end

Menu.Text("Walkbot","The settings below are advanced and it's optional to change them.")
local IterationPerTick_Slider = Menu.SliderInt("Walkbot","Path finding iteration per ticks",1,1,1000,"Increasing this will make the path finding faster,at the cost of your FPS.")
local Difference2DLimit = Menu.SliderFloat("Walkbot", "Distance to node limit", 20.0, 1.0, 500.0, "If the distance to the current node goes BELOW this number,THEN you are considered to arrive at the node,and you will start moving to the next node in the path.")
local Z_Limit = Menu.SliderFloat("Walkbot", "Distance to node Z-limit", 50.0, 1.0, 500.0, "Same as above,but this controls the z limit.This needs to be more loose since its hard to accurately get to the z position of the node.")
local ThresholdTime = Menu.SliderInt("Walkbot", "Obstacle avoid time limit", 1, 1, 60, "How long you want each method to avoid obstacles to last,in seconds.") -- time to switch between avoidance methods
local ThresholdTimeReset = Menu.SliderInt("Walkbot", "Obstacle avoid cycle reset time limit", 1, 1, 60, "Time after moving to reset the obstacle avoiding cycle so the next time we're stuck,we will loop from the first method again,in seconds.")  -- time after moving to reset CycleAttempt to 0 again so the next time we're stuck,we will loop from the first method again,in seconds.
local TimeToMove = Menu.SliderFloat("Walkbot", "Enemy Last Seen Threshold", 1.00, 0.01, 10.00, "After this amount of time since the last time we saw an enemy,we will resume moving again.")

local Aimbot_Enable = Menu.Switch("Aimbot","Enable",false,"Global switch for the aimbot.")
local Aimbot_SilentAim = Menu.Switch("Aimbot","Silent Aim",false,"Prevents the aiming angles from applying to your engine angles.")
local BodyAim_Switch = Menu.Switch("Aimbot","Prefer body aim",true,"Prioritizes aiming for the body.If not possible,aim for the head.")
local Aimbot_Speed = Menu.SliderInt("Aimbot","Speed",10,1,100,"Controls the speed of the aimbot.")
local Aimbot_Hitchance = Menu.SliderInt("Aimbot","Hitchance",50,1,100,"Enforces more accuracy to the aimbot's shots.")
local Aimbot_Enforce_Hitbox = Menu.Switch("Aimbot","Force Shoot Center Hitbox",false,"By default,the aimbot will shoot with whatever angle it is at.With this enabled,the aimbot will forcefully shoot the center of the hitbox,making the shot more accurate.This might make your aimbot look more obvious.")

local Aimbot_AutoReload_Switch = Menu.Switch("Aimbot","Enable Auto Reload",true,"")
local Aimbot_AutoReload = Menu.SliderInt("Aimbot","Auto Reload Threshold",25,1,100,"If your active weapon's ammo goes below this amount in percentage,it will automatically reload your weapon.")

local AutoQueue_Switch = Menu.Switch("Misc", "Auto queue", true, "Automatically queues for you.")
local AutoReconnect_Switch = Menu.Switch("Misc", "Auto reconnect", true, "Automatically reconnects to an ongoing match.")
local AutoDisconnect_Switch = Menu.Switch("Misc", "Auto disconnect", true, "Automatically disconnects upon match end.")
local AutoWeaponSwitch_Switch = Menu.Switch("Misc", "Auto switch to best weapon", true, "Automatically switches to the best weapon in your weapon slots.")

local Precomputed_Seeds = {}

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
	e_hitboxes.PELVIS	        
}

local Hitboxes_BodyAim = {
	
	e_hitboxes.UPPER_CHEST	    ,
	e_hitboxes.CHEST	        ,
	e_hitboxes.THORAX	        ,
	e_hitboxes.BODY	            ,
	e_hitboxes.PELVIS	        ,
	
	e_hitboxes.NECK	            ,
	e_hitboxes.HEAD			    
	
}


--CustomBuffer:Read(4)

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

    -- Cant call trace functions outside of match
    --local from = (self.m_top + self.m_bottom):MultiplySingle(0.5) + self.m_normal:MultiplySingle(5.0)
    --local to = from - self.m_normal:MultiplySingle(32.0)
    --
    --local Ray = ffi.new("Ray_t",{})
    --InitializeRay(Ray,from,to)
    --
    --local trace = ffi.new("CGameTrace*",{})
    --TraceRay(Ray,0x2400B,0,trace)
    --
    --if(trace.BaseTrace.fraction ~= 1.0) then
    --
    --end
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

    --self.m_center:PrintValue()

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
        --print("PostLoad Iteration NAVLADDERCONNECT : ",dir)
        for _,connect in ipairs(self.m_ladder[dir]) do
            local id = connect.id
            --print(id)
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
    local FunctionName = "INavFile:Load :"

    self.m_magic = ffi.cast("uint32_t*",Buffer:Read(4))[0]
    if(self.m_magic ~= 0xFEEDFACE) then
        print(FunctionName,"File could not be verified against magic")
        return false
    end

    self.m_version = ffi.cast("uint32_t*",Buffer:Read(4))[0]
    if(self.m_version ~= 16) then
        print(FunctionName,"File version mismatch")
        return false
    end

    self.m_subVersion = ffi.cast("uint32_t*",Buffer:Read(4))[0]
    self.m_saveBspSize = ffi.cast("uint32_t*",Buffer:Read(4))[0]
    self.m_isAnalyzed = ffi.cast("uint8_t*",Buffer:Read(1))[0]
    self.m_usPlaceCount = ffi.cast("uint16_t*",Buffer:Read(2))[0]
    --print("Place count : ",self.m_usPlaceCount)
    --print("Table count",#self.m_vStrPlaceNames)
    for us = 1,self.m_usPlaceCount do
        local usLength = ffi.cast("uint16_t*",Buffer:Read(2))[0]
        local szName = Buffer:Read(usLength)
        table.insert(self.m_vStrPlaceNames,ffi.string(szName))
    end
    --print("Table count",#self.m_vStrPlaceNames)
    --for k,v in ipairs(self.m_vStrPlaceNames) do
    --    print(k,v)
    --end
    self.m_hasUnnamedAreas = ffi.cast("uint8_t*",Buffer:Read(1))[0]
    self.m_uiAreaCount = ffi.cast("uint32_t*",Buffer:Read(4))[0]
    --print("Area count",self.m_uiAreaCount)
    for ui = 1,self.m_uiAreaCount do
        --print("Iteration : ",ui)
        local area = CNavArea:new()
        area:LoadFromFile(Buffer)
        --print(area.m_id)
        --area.m_center:PrintValueClean()
        table.insert(self.m_areas,area)

    end

    local LadderCount = ffi.cast("uint32_t*",Buffer:Read(4))[0]
    for ui = 1,LadderCount do
        --print("Iteration : ",ui)
        local Ladder = CNavLadder:new()
        Ladder:Load(Buffer)
        table.insert(self.m_ladders,Ladder)
    end

    INavFile:PostLoad()

    return true
end
local function LoadMap(MapName)

    local MapConcattedWithDirectory = EngineClient.GetGameDirectory() .. "\\maps\\" .. MapName .. ".nav"

    local fileHandle = ffi.C.CreateFileA(MapConcattedWithDirectory,0x10000000,0x1,0,4,0x80,0)

    if (ffi.C.GetFileAttributesA(MapConcattedWithDirectory) == 0xFFFFFFFF ) then
        print(".nav file for this map doesn't exist.")
        ffi.C.CloseHandle(fileHandle)
        INavFile.m_isLoaded = false
        return
    end

    local filesize = ffi.C.GetFileSize(fileHandle,0)

    if( filesize == 0 )then
        print(".nav file is empty.")
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
        print(".nav file is invalid")
        INavFile.m_isLoaded = false
        return
    end
    INavFile.m_isLoaded = true
end


--local Test_Area = INavFile:GetNavAreaByID(2599)
--print(#Test_Area.m_connect)
--for _,Area in ipairs(Test_Area.m_connect) do
--    print(Area.id)
--end
--Cheat.RegisterCallback("draw", function()
--    local local_player = EntityList.GetLocalPlayer()
--    local origin = local_player:GetRenderOrigin()
--    for _,Area in ipairs(INavFile.m_areas) do
--        local world_position = Area.m_center
--        local Neverlose_Vector = Vector.new(world_position.x, world_position.y, world_position.z)
--
--
--        if(origin:DistTo(Neverlose_Vector) <= 500.0) then
--            local screen_pos = Render.WorldToScreen(Neverlose_Vector)
--            Render.Circle(screen_pos, 2.0, 30, Color.new(1.0, 1.0, 1.0, 1.0))
--        end
--
--
--    end
--end)

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

local function FindNearestAreaToPlayer(AreaList,player)

    local player_position = Vector3D:new()
    player_position:CopyOther(player:GetRenderOrigin())

    local Latest_Distance = math.huge
    local Nearest_Area = nil
    for _,Area in ipairs(AreaList) do
        --Area.m_center:PrintValueClean()
        
        if( #Area.m_connect == 0 )then
            goto continue
        end

        if(bit.band(Area.m_attributeFlags,NavAttributeType.NAV_MESH_JUMP) ~= 0) then -- avoid area with jump attributes
            goto continue  
        end

        local Distance = Area.m_center:DistToSqr(player_position)
        if(Distance <= Latest_Distance) then
            Latest_Distance = Distance
            Nearest_Area = Area
        end
        ::continue::
    end
    return Nearest_Area
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
        --print("i : ",i)
        local NodeIter = List[i]
        if(NodeIter == Node) then
            --print("Removed node ",NodeIter.area.m_id)
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

local function IsNodeInList(List,Node)
    for i = 1,#List do
        local NodeIter = List[i]
        if(NodeIter == Node) then
            return true
        end
    end
    return false
end

local OpenList = {}
local ClosedList = {}

--local StartingNode = AreaNode:new()
--StartingNode.area = FindNearestAreaToPlayer(INavFile.m_areas)
--
--local EndArea = INavFile:GetNavAreaByID(1281)
--
--StartingNode.parent = StartingNode
--StartingNode.g = StartingNode.area.m_center:DistToManhattanVer(StartingNode.area.m_center)
--StartingNode.h = StartingNode.area.m_center:DistToManhattanVer(EndArea.m_center)
--StartingNode.f = StartingNode.g + StartingNode.h

--table.insert(OpenList,StartingNode)

local LastFoundPlayer = nil
local function FindNearestPlayer(FromPlayer)
    local PlayerList = EntityList.GetPlayers()

    local NearestDistance = math.huge
    local NearestPlayer = nil

    local FromPlayerRenderOrigin = FromPlayer:GetRenderOrigin()
    local FromPlayerPos = Vector3D:new(FromPlayerRenderOrigin.x,FromPlayerRenderOrigin.y,FromPlayerRenderOrigin.z)

    for _,Player in ipairs(PlayerList) do
        if Player ~= FromPlayer and Player:IsPlayer() then
            local BasePlayer = Player:GetPlayer()
            local NetworkState = BasePlayer:GetNetworkState() 
            if BasePlayer:IsAlive() and not BasePlayer:IsTeamMate() and BasePlayer:EntIndex() ~= LastFoundPlayer and (NetworkState == 1 or NetworkState == 0) then

                local PlayerOrigin = BasePlayer:GetRenderOrigin()
                local PlayerPos = Vector3D:new(PlayerOrigin.x,PlayerOrigin.y,PlayerOrigin.z)

                local DistanceToFromPlayer = PlayerPos:DistToSqr(FromPlayerPos) -- squared
                if( DistanceToFromPlayer < NearestDistance) then
                    NearestDistance = DistanceToFromPlayer
                    NearestPlayer = BasePlayer
                end
            end
            
        end
    end

    if(NearestPlayer ~= nil)then
        LastFoundPlayer = NearestPlayer:EntIndex()
    else
        if LastFoundPlayer ~= nil then
            local BasePlayer_LastFoundPlayer = EntityList.GetPlayer(LastFoundPlayer)
            if BasePlayer_LastFoundPlayer then 
                local NetworkState = BasePlayer_LastFoundPlayer:GetNetworkState()
                if BasePlayer_LastFoundPlayer:IsPlayer() and BasePlayer_LastFoundPlayer:IsAlive() and not BasePlayer_LastFoundPlayer:IsTeamMate() and (NetworkState == 1 or NetworkState == 0) then
                    NearestPlayer = BasePlayer_LastFoundPlayer
                end
            end
            
        end
    end
    return NearestPlayer
end



local function IsVisible(FromPlayer,ToPlayer)
    local FromPlayer_EyePos = FromPlayer:GetEyePosition()

    if not BodyAim_Switch:Get() then
        for _,hitbox in ipairs(Hitboxes_Normal) do 
    
            local ToPlayer_TargetPos = ToPlayer:GetHitboxCenter(hitbox)
    
            local trace_result = EngineTrace.TraceRay(FromPlayer_EyePos, ToPlayer_TargetPos, FromPlayer, 0x46004003)
            if(trace_result.hit_entity and trace_result.hit_entity:EntIndex() == ToPlayer:EntIndex())then 
                return hitbox
            end
        end
    else
        for _,hitbox in ipairs(Hitboxes_BodyAim) do 
    
            local ToPlayer_TargetPos = ToPlayer:GetHitboxCenter(hitbox)
    
            local trace_result = EngineTrace.TraceRay(FromPlayer_EyePos, ToPlayer_TargetPos, FromPlayer, 0x46004003)
            if(trace_result.hit_entity and trace_result.hit_entity:EntIndex() == ToPlayer:EntIndex())then 
                return hitbox
            end
        end
    end
    
    return -1

    -- print(trace_result.fraction)
    -- print(trace_result.hit_entity:EntIndex())
    
end

local function Aimbot__FindNearestPlayer(FromPlayer)
    local PlayerList = EntityList.GetPlayers()

    local NearestDistance = math.huge
    local NearestPlayer = nil
    local BestHitbox = nil
    local FromPlayerEyePos = FromPlayer:GetEyePosition()
    local FromPlayerPos = Vector3D:new(FromPlayerEyePos.x,FromPlayerEyePos.y,FromPlayerEyePos.z)

    for _,Player in ipairs(PlayerList) do
        if Player ~= FromPlayer and Player:IsPlayer() then
            local BasePlayer = Player:GetPlayer()
            local TempHitboxChoice = IsVisible(FromPlayer,BasePlayer)
            
            if BasePlayer:IsAlive() and not BasePlayer:IsTeamMate() and not BasePlayer:IsDormant() and TempHitboxChoice > -1 then

                local PlayerOrigin = BasePlayer:GetProp("m_vecOrigin")
                local PlayerPos = Vector3D:new(PlayerOrigin.x,PlayerOrigin.y,PlayerOrigin.z)

                local DistanceToFromPlayer = PlayerPos:DistToSqr(FromPlayerPos) -- squared
                if( DistanceToFromPlayer < NearestDistance) then
                    NearestDistance = DistanceToFromPlayer
                    NearestPlayer = BasePlayer
                    BestHitbox = TempHitboxChoice
                end
            end
            
        end
    end

    return  { NearestPlayer , BestHitbox } 
end

local StartingNode = nil
local EndArea = nil
local CurrentNode = nil
local Path = {}

local NodeToSkip = {}
local PlayersToSkip = {}
local function PrepareToFindAnotherNode()

    math.randomseed(GlobalVars.tickcount)

    OpenList = { }
    ClosedList = { }
    CurrentNode = nil
    Path = { }

    local local_player = EntityList.GetLocalPlayer()

    StartingNode = AreaNode:new()
    StartingNode.area = FindNearestAreaToPlayer(INavFile.m_areas,local_player)


    local ChosenPlayer = FindNearestPlayer(local_player)


    
    if (ChosenPlayer ~= nil) then
        print("Targetting player : " , ChosenPlayer:GetName())
        EndArea = FindNearestAreaToPlayer(INavFile.m_areas,ChosenPlayer)
    else
        EndArea = INavFile:GetNavAreaByID(math.random(1,#INavFile.m_areas))

        while (EndArea == nil or #EndArea.m_connect < 1 or (bit.band(EndArea.m_attributeFlags,NavAttributeType.NAV_MESH_JUMP) ~= 0)) do
            EndArea = INavFile:GetNavAreaByID(math.random(1,#INavFile.m_areas))
            -- print(math.random(1,#INavFile.m_areas))
        end
    end

    -- print(#INavFile.m_areas)
    -- print(StartingNode.area.m_id)
    -- print(EndArea.m_id)
    -- EndArea.m_center:PrintValueClean()
    StartingNode.parent = StartingNode
    StartingNode.g = StartingNode.area.m_center:DistToManhattanVer(StartingNode.area.m_center)
    StartingNode.h = StartingNode.area.m_center:DistToManhattanVer(EndArea.m_center)
    StartingNode.f = StartingNode.g + StartingNode.h

    --if #OpenList == 0 then
    --print("Prepared a starting node and end area.Path finding will start at next tick.")
    --print(#OpenList)
    table.insert(OpenList,StartingNode)
    --end
    NodeToSkip = {}
    PlayersToSkip = {}
end

local NeedToResetLists = true

--local StartTime = GlobalVars.realtime
local function FindPath()
    local IterationsAllowed = IterationPerTick_Slider:Get()
    local CurrentIteration = 0

    while(CurrentIteration < IterationsAllowed) do 
        CurrentNode = FindLowestScoreInList(OpenList)

        if(CurrentNode == nil) then
            OpenList = { }
            ClosedList = { }
            CurrentNode = nil
            Path = { }
            NeedToResetLists = true

            CurrentIteration = IterationsAllowed
            break
        end

        if(CurrentNode.area == EndArea) then
            if(#Path == 0 )then
                --print(GlobalVars.realtime - StartTime)
                --print("Found path.")
                table.insert(Path,CurrentNode)

                local ParentNode = CurrentNode.parent
                while ParentNode ~= StartingNode do
                    table.insert(Path,ParentNode)
                    ParentNode = ParentNode.parent
                end
                table.insert(Path,ParentNode)
                --print("Path Start ID: ",Path[#Path].area.m_id)
            end
            CurrentIteration = IterationsAllowed
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
        CurrentIteration = CurrentIteration + 1
    end
end




local function CheckIfArrivedAtNode(cmd)
    local local_player = EntityList.GetLocalPlayer()
    local local_player_pos = local_player:GetRenderOrigin()

    local NodeToMoveTo = Path[#Path]
    if(NodeToMoveTo ~= nil)then
        if(not NodeToMoveTo.area.m_center:IsDifference3D(local_player_pos,Difference2DLimit:Get(),Z_Limit:Get())) then
            --print("arrived at path")
            table.remove(Path,#Path)
            if(#Path == 0) then
                NeedToResetLists = true
            end
        end
    end
end

local function FixMovement(EngineAngle,cmd,fOldForward,fOldSidemove)
    local deltaView
    local f1
    local f2

    if(EngineAngle.yaw < 0.0)then
        f1 = 360.0 + EngineAngle.yaw
    else
        f1 = EngineAngle.yaw
    end

    if (cmd.viewangles.yaw < 0.0)then
        f2 = 360.0 + cmd.viewangles.yaw
    else
        f2 = cmd.viewangles.yaw
    end

    if (f2 < f1)then
        deltaView = math.abs(f2 - f1)
    else
        deltaView = 360.0 - math.abs(f1 - f2)
    end

    deltaView = 360.0 - deltaView

    cmd.forwardmove = ( math.cos(math.rad(deltaView)) * fOldForward ) + ( math.cos(math.rad(deltaView + 90)) * fOldSidemove )
    cmd.sidemove = ( math.sin(math.rad(deltaView)) * fOldForward ) + ( math.sin(math.rad(deltaView + 90)) * fOldSidemove )
end


local jumped_last_tick = false
local should_fake_jump = false
local function Bhop(cmd)

    cmd.buttons = bit.bor(cmd.buttons,2)
    return

    -- local local_player = EntityList.GetLocalPlayer()
    -- local m_nMoveType = ffi.cast("int*",GetClientEntity(local_player:EntIndex()) + 0x25C)[0] 
    -- local m_fFlags = local_player:GetProp("m_fFlags")
    -- print(m_fFlags)
    -- if(m_nMoveType == 9 or m_nMoveType == 8) then
    --     return
    -- end

    -- if(bit.band(m_fFlags,1024) == 1024) then
    --     return
    -- end   

    -- if(not jumped_last_tick and should_fake_jump) then
    --     print("Jump")
    --     should_fake_jump = false;
    --     cmd.buttons = bit.bor(cmd.buttons,2)
    -- elseif(bit.band(cmd.buttons,2) == 2 ) then

    --     if(bit.band(m_fFlags,1) == 1 ) then
    --         jumped_last_tick = true
    --         should_fake_jump = true
    --     else
    --         cmd.buttons = bit.band(cmd.buttons,bit.bnot(2))
    --         jumped_last_tick = false
    --     end

    -- else
    --     jumped_last_tick = false
    --     should_fake_jump = false
    -- end
end

local MovingTicks = 1
local NotMovingTicks = 1

-- TODO : Use curtime / realtime instead of tickcount and get a better name for these namings and better descriptions
-- TODO : Use better methods of keeping track of time instead of using these modulo operations

local CycleAttempt = 1 
local CycleMethods = 8
-- local LastLocation = nil
local function ObstacleAvoid(cmd)
    local tickrate = 1.0 / GlobalVars.interval_per_tick

    local local_player = EntityList.GetLocalPlayer()
    local local_player_pos = Vector3D:new()
    local local_player_weapon = local_player:GetActiveWeapon()
    local_player_pos:CopyOther(local_player:GetRenderOrigin())
    
    local max_speed = 230.0
    if local_player_weapon then
        max_speed = local_player_weapon:GetMaxSpeed()
    end
    local local_player_speed = Vector3D:new(local_player:GetProp("m_vecVelocity[0]"),local_player:GetProp("m_vecVelocity[1]"),local_player:GetProp("m_vecVelocity[2]")):Length2D()

    -- if(LastLocation ~= nil) then
    --     --print(LastLocation:DistTo2D(local_player_pos))
    --     -- if(not LastLocation:IsDifference2D(local_player_pos,3.0)) then
        
    --     LastLocation = local_player_pos
    -- else
    --     LastLocation = local_player_pos
    -- end

    -- print(local_player_speed >= 0.34 * max_speed)
    if(local_player_speed >= 0.10 * max_speed) then
        MovingTicks = (MovingTicks + 1) % 6400
        if(MovingTicks % tickrate * ThresholdTimeReset:Get() == 0) then
            CycleAttempt = 0
        end
        NotMovingTicks = 1
    else
        NotMovingTicks = (NotMovingTicks + 1) % 6400
        MovingTicks = 1
    end

    if (GlobalVars.tickcount % (tickrate * ThresholdTime:Get()) == 0) then
        CycleAttempt = CycleAttempt % CycleMethods + 1
    end

    -- print(CycleAttempt)
    -- print("MovingTicks : " .. MovingTicks)
    -- print("NotMovingTicks : " .. NotMovingTicks)
    local NodeToMoveTo = Path[#Path]
    if(NotMovingTicks > 1) then
        --TODO : make a table and just loop through them by indexing using CycleAttempt
        if( CycleAttempt == 1 )then -- Check attribute flags of areas
            if(bit.band(NodeToMoveTo.area.m_attributeFlags,NavAttributeType.NAV_MESH_JUMP) ~= 0) then
                Bhop(cmd) -- Jump
            end

            if(bit.band(NodeToMoveTo.area.m_attributeFlags,NavAttributeType.NAV_MESH_CROUCH) ~= 0) then
                cmd.buttons = bit.bor(cmd.buttons,4) -- Crouch
            end
        elseif ( CycleAttempt == 2 ) then -- Jump and crouch
            Bhop(cmd)
            cmd.buttons = bit.bor(cmd.buttons,4)
        elseif ( CycleAttempt == 3 ) then -- Just jump
            Bhop(cmd)
        elseif ( CycleAttempt == 4 ) then -- Just crouch
            cmd.buttons = bit.bor(cmd.buttons,4)
        elseif ( CycleAttempt == 5 ) then -- IN_USE what's in front of us
            local LocalEyePos = local_player:GetEyePosition()
            local LocalEyePosCustom = Vector3D:new()
            LocalEyePosCustom:CopyOther(LocalEyePos)

            -- local VectorToUseCustom = NodeToMoveTo.area.m_center
            -- local VectorToUse = Vector.new(VectorToUseCustom.x,VectorToUseCustom.y,VectorToUseCustom.z)

            -- local traced = EngineTrace.TraceRay(LocalEyePos, VectorToUse, local_player, 0x46004003)

            -- local TracedEndPosCustom = Vector3D:new(traced.endpos.x,traced.endpos.y,traced.endpos.z)
            local AngleToVectorUse = Math:CalcAngle(LocalEyePosCustom,NodeToMoveTo.area.m_center)

            if AngleToVectorUse == nil then return end
            
            AngleToVectorUse:NormalizeTo180()

            cmd.forwardmove = 0.0
            cmd.sidemove = 0.0
            cmd.viewangles.pitch = AngleToVectorUse.x
            cmd.viewangles.yaw = AngleToVectorUse.y

            cmd.buttons = bit.bor(cmd.buttons,32)

            
            
        elseif ( CycleAttempt == 6) then -- Shoot what's in front of us    
            local LocalEyePos = local_player:GetEyePosition()
            local LocalEyePosCustom = Vector3D:new()
            LocalEyePosCustom:CopyOther(LocalEyePos)

            local VectorToUseCustom = NodeToMoveTo.area.m_center
            local VectorToUse = Vector.new(VectorToUseCustom.x,VectorToUseCustom.y,VectorToUseCustom.z)

            local traced = EngineTrace.TraceRay(LocalEyePos, VectorToUse, local_player, 0x46004003)

            if(traced.hit_entity and traced.hit_entity:IsPlayer()) then
                if(traced.hit_entity:GetPlayer():IsTeamMate()) then
                    return
                end
            end

            local TracedEndPosCustom = Vector3D:new(traced.endpos.x,traced.endpos.y,traced.endpos.z)
            local AngleToVectorUse = Math:CalcAngle(LocalEyePosCustom,NodeToMoveTo.area.m_center)

            if AngleToVectorUse == nil then return end

            AngleToVectorUse:NormalizeTo180()
            
            cmd.forwardmove = 0.0
            cmd.sidemove = 0.0
            cmd.viewangles.pitch = AngleToVectorUse.x
            cmd.viewangles.yaw = AngleToVectorUse.y

            cmd.buttons = bit.bor(cmd.buttons,1)

        elseif ( CycleAttempt == 7) then
            -- do nothing
        elseif ( CycleAttempt == 8) then -- Find another end area and new starting node
            Path = {}
            CycleAttempt = 0 -- when path is found and CycleAttempt is still 8,it will attempt to find another end area,causing an infinite loop of finding paths and generating new end area.
            NeedToResetLists = true
        end
    else
        if( bit.band(NodeToMoveTo.area.m_attributeFlags,NavAttributeType.NAV_MESH_JUMP) ~= 0) then
            Bhop(cmd) -- Jump
        end

        if( bit.band(NodeToMoveTo.area.m_attributeFlags,NavAttributeType.NAV_MESH_CROUCH) ~= 0) then
            cmd.buttons = bit.bor(cmd.buttons,4) -- Crouch
        end
    end
end

local TimeSinceLastSeenEnemy = 0

local function MoveToTarget(cmd)
    local tickrate = 1.0 / GlobalVars.interval_per_tick

    local local_player = EntityList.GetLocalPlayer()
    local local_player_pos = local_player:GetRenderOrigin()
    local local_weapon = local_player:GetActiveWeapon()
    
    -- for k,weapon_handle in ipairs(weapon_list)do
    --     local weapon= EntityList.GetClientEntityFromHandle(weapon_handle):GetWeapon()
    --     if(weapon:IsRifle() or weapon:IsSniper())then
    --         EngineClient.ExecuteClientCmd("slot1")
    --         break
    --     elseif condition then
    --         -- :IsPistol()
    --     end
    -- end

    local view_angles = Angle:MakeNewAngleFromNLAngle(EngineClient.GetViewAngles())
    -- local cmd_view_angles = Angle:MakeNewAngleFromNLAngle(cmd.viewangles)
    local NodeToMoveTo = Path[#Path]

    local AngleToNode = Math:CalcAngle(local_player_pos,NodeToMoveTo.area.m_center)

    if AngleToNode == nil then return end

    view_angles.x = 0.0
    AngleToNode.x = 0.0
    view_angles.z = 0.0
    AngleToNode.z = 0.0
    AngleToNode = (view_angles - AngleToNode) -- AngleToNode - view_angles if the game's angles is clock wise



    local forward = Vector3D:new()


    Math:AngleVectors(AngleToNode,forward)
    -- print(TimeSinceLastSeenEnemy)
    if TimeSinceLastSeenEnemy >= tickrate * TimeToMove:Get() then
        forward = forward:MultiplySingle(450)
        if local_player:GetProp("m_bIsScoped") then
            cmd.buttons = bit.bor(cmd.buttons,2048)
        end
    else
        if local_weapon and not local_weapon:IsReloading() then
            -- print("Stopping to max weapon speed")
            local weapon_max_speed = local_weapon:GetMaxSpeed()
            local weapon_speed_max_accuracy = weapon_max_speed * 0.25
            forward = forward:MultiplySingle(weapon_speed_max_accuracy)
        else
            forward = forward:MultiplySingle(450)
        end
    end
    


    cmd.forwardmove = forward.x
    cmd.sidemove = forward.y

end

local function PrecomputeSeed()
	
	
	for seed=1,255 do
	
		local random_values = { }
	
		Utils.RandomSeed(bit.band(seed,0xff) + 1)
	
		table.insert(random_values,Utils.RandomFloat(0.0,1.0))
		table.insert(random_values,Utils.RandomFloat(0.0,Math.PI_2))
		table.insert(random_values,Utils.RandomFloat(0.0,1.0))
		table.insert(random_values,Utils.RandomFloat(0.0,Math.PI_2))
		
		
		table.insert(Precomputed_Seeds,random_values)
	end
	
end

local function CalculateSpread(weapon,seed,inaccuracy,spread)
    if not weapon or weapon:GetProp("m_iClip1") == 0 then
        return Vector3D:new()
    end

    local r1 = Precomputed_Seeds[seed][1]
	local r2 = Precomputed_Seeds[seed][2]
	local r3 = Precomputed_Seeds[seed][3]
	local r4 = Precomputed_Seeds[seed][4]

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

local function CheckHitchance(angleToTarget,entity)
    local local_player  = EntityList.GetLocalPlayer()
    local weapon        = local_player:GetActiveWeapon() 

    local lp_eyepos     = local_player:GetEyePosition()
    
    local forward             = Vector3D:new()
    local right                 = Vector3D:new()
    local up                    = Vector3D:new()

    Math:AngleVectorsExtra(angleToTarget,forward,right,up)

    local spread            = weapon:GetSpread(weapon)
    local inaccuracy    = weapon:GetInaccuracy(weapon)  

    local needed_hits   =  math.ceil((Aimbot_Hitchance:Get() / 100) * 255)
    local total_hits        = 0

    for i = 1,255 do
        local wep_spread = CalculateSpread(weapon,i,inaccuracy,spread)

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

        local trace_result = EngineTrace.TraceRay(lp_eyepos, Vector.new(EndVec.x, EndVec.y, EndVec.z), local_player, 0x46004003)

        if (trace_result.hit_entity and trace_result.hit_entity:EntIndex() == entity:EntIndex()) then
            total_hits = total_hits + 1
        end

        if (total_hits >= needed_hits) then
            return true
        end


    end
    return false
end

local function CanLocalPlayerShoot()
    local local_player = EntityList.GetLocalPlayer()
    local local_weapon = local_player:GetActiveWeapon()
    local local_player_from_weapon_handle = EntityList.GetClientEntityFromHandle(local_weapon:GetProp("m_hOwnerEntity")):GetPlayer()

    if not ( local_player_from_weapon_handle or local_weapon or local_player ) then
        return false
    end

    local weapon__clip1                 = local_weapon:GetProp("m_iClip1")
    local weapon__m_flNextPrimaryAttack = local_weapon:GetProp("m_flNextPrimaryAttack")
    local local_player__m_nTickBase     = local_player_from_weapon_handle:GetProp("m_nTickBase")
    local local_player__m_flNextAttack  = local_player_from_weapon_handle:GetProp("m_flNextAttack")

    if(local_weapon:IsReloading() or weapon__clip1 <= 0)then
        return false
    end

    local flServerTime = local_player__m_nTickBase * GlobalVars.interval_per_tick

    if(local_player__m_flNextAttack > flServerTime)then
        return false
    end

    return (weapon__m_flNextPrimaryAttack <= flServerTime)
end

local function CanHit_Angle(StartPos,CurrentAngle,PlayerSkip)

    local VectorFromAngle = Vector3D:new()
    Math:AngleVectors(CurrentAngle,VectorFromAngle)
    VectorFromAngle = VectorFromAngle:MultiplySingle(8192.0)
    VectorFromAngle = VectorFromAngle + StartPos
    
    local VectorFromAngle_Converted = Vector.new(VectorFromAngle.x,VectorFromAngle.y,VectorFromAngle.z)
    local trace_result = EngineTrace.TraceRay(StartPos, VectorFromAngle_Converted, PlayerSkip, 0x46004003)

    return (trace_result.hit_entity and trace_result.hit_entity:IsPlayer() and not trace_result.hit_entity:GetPlayer():IsTeamMate())

end

local function BeMoreAccurate(cmd)

    -- local local_player = EntityList.GetLocalPlayer()
    -- -- local velocity_prop = local_player:GetProp("m_vecVelocity[0]")
    -- local velocity = Vector3D:new(local_player:GetProp("m_vecVelocity[0]"),local_player:GetProp("m_vecVelocity[1]"),local_player:GetProp("m_vecVelocity[2]"))
    -- -- velocity:CopyOther(velocity_prop)

    -- local direction = Angle:new()
    -- Math:VectorAngles(velocity,direction)

    -- local forward_vector = Vector3D:new()
    -- Math:AngleVectors(direction,forward_vector)

    -- local speed = velocity:Length()

    -- direction.y = cmd.viewangles.yaw - direction.y

    -- local negated_direction = forward_vector:MultiplySingle(-speed)

    -- cmd.forwardmove = negated_direction.x
    -- cmd.sidemove = negated_direction.y

    local local_player = EntityList.GetLocalPlayer()
    local local_weapon = local_player:GetActiveWeapon()

    if local_weapon and not local_weapon:IsReloading() then
        -- print("Stopping to max weapon speed")
        local weapon_max_speed = local_weapon:GetMaxSpeed()
        local weapon_speed_max_accuracy = weapon_max_speed * 0.25
        cmd.forwardmove = Math:Clamp(cmd.forwardmove,-(weapon_speed_max_accuracy),weapon_speed_max_accuracy)
        cmd.sidemove = Math:Clamp(cmd.sidemove,-(weapon_speed_max_accuracy),weapon_speed_max_accuracy)
    else
        cmd.forwardmove = Math:Clamp(cmd.forwardmove,-450,450)
        cmd.sidemove = Math:Clamp(cmd.sidemove,-450,450)
    end

    cmd.buttons = bit.band(cmd.buttons,-3)
    
    -- print("stopping")
end

local RecoilScale = CVar.FindVar("weapon_recoil_scale")



local LatestTargetAngle = Angle:new()
local LatestAngle = Angle:MakeNewAngleFromNLAngle(EngineClient.GetViewAngles())


local function Aimbot(cmd)

    if not Aimbot_Enable:Get() then 
        TimeSinceLastSeenEnemy = math.max(1,(TimeSinceLastSeenEnemy + 1) % 6400)
        return 
    end
    local tickrate = 1.0 / GlobalVars.interval_per_tick

    TimeSinceLastSeenEnemy = math.max(1,(TimeSinceLastSeenEnemy + 1) % 6400)
    local NodeToMoveTo = Path[#Path]

    local local_player = EntityList.GetLocalPlayer()
    local local_player_pos = local_player:GetEyePosition()
    local local_weapon = local_player:GetActiveWeapon()

    if Aimbot_AutoReload_Switch:Get() and local_weapon and not local_weapon:IsReloading() then
        local clip = local_weapon:GetProp("DT_BaseCombatWeapon", "m_iClip1")
        local max_clip = local_weapon:GetMaxClip()

        local current_clip_percentage = clip / max_clip

        if(current_clip_percentage < ( Aimbot_AutoReload:Get() / 100 ) ) then
            cmd.buttons = bit.bor(cmd.buttons,8192)
        end
    end

    
    local local_aimpunch = Angle:MakeNewAngleFromNLVector(local_player:GetProp("m_aimPunchAngle"))
    local_aimpunch = local_aimpunch:MultiplySingle(RecoilScale:GetFloat())

    local TargetPlayerAndHitbox = Aimbot__FindNearestPlayer(local_player)

    if TargetPlayerAndHitbox[1] ~= nil and TargetPlayerAndHitbox[2] ~= nil and Vector3D:IsValid(local_player_pos) then 
        TimeSinceLastSeenEnemy = 0
        BeMoreAccurate(cmd)
        if local_weapon:GetProp("m_zoomLevel") == 0 and local_weapon:IsSniper() and bit.band(cmd.buttons,2048) == 0 then
            cmd.buttons = bit.bor(cmd.buttons,2048)
        end

        local TargetHitbox = TargetPlayerAndHitbox[1]:GetHitboxCenter(TargetPlayerAndHitbox[2])
        
        if Vector3D:IsValid(TargetHitbox) then
            local AngleToTarget = Math:CalcAngle(local_player_pos,TargetHitbox)
            if(AngleToTarget ~= nil)then 
                LatestTargetAngle = AngleToTarget - local_aimpunch
            end
        end
    else
        if NodeToMoveTo and TimeSinceLastSeenEnemy >= tickrate * TimeToMove:Get() then
            if Vector3D:IsValid(NodeToMoveTo.area.m_center)then
                local AngleToTarget = Math:CalcAngle(local_player_pos,NodeToMoveTo.area.m_center)

                if(AngleToTarget ~= nil)then 
                    LatestTargetAngle = AngleToTarget
                    LatestTargetAngle.x = 0.00
                    LatestTargetAngle.z = 0.00
                end
            end
            
        end
        -- LatestTargetAngle = Angle:MakeNewAngleFromNLAngle(EngineClient.GetViewAngles())
    end
    
    LatestAngle = Math:SmoothAngle(LatestAngle,LatestTargetAngle,Aimbot_Speed:Get())
    -- LatestAngle:PrintValueClean()
    LatestAngle:NormalizeTo180()
    
    -- print(Math:GetFOV(LatestAngle,AngleToTarget))
    -- if Math:GetFOV(LatestAngle,LatestTargetAngle) <= Aimbot_Shoot_Range:Get() then
    --     cmd.buttons = bit.bor(cmd.buttons,1)
    -- end
    
    cmd.viewangles.pitch = LatestAngle.x
    cmd.viewangles.yaw = LatestAngle.y
    


    if TargetPlayerAndHitbox[1] and CanLocalPlayerShoot() and CheckHitchance(LatestAngle,TargetPlayerAndHitbox[1] ) and bit.band(cmd.buttons,2048) == 0 then
        if Aimbot_Enforce_Hitbox:Get() then
            cmd.viewangles.pitch = LatestTargetAngle.x
            cmd.viewangles.yaw = LatestTargetAngle.y
        end
        cmd.buttons = bit.bor(cmd.buttons,1)
    end

    
    -- EngineClient.SetViewAngles(QAngle.new(cmd.viewangles.pitch,cmd.viewangles.yaw,0.0))
    -- if LatestAngle.y ~= LatestAngle.y then
    --     print("ADWOIJNIIIIIININININININININININININNAODINAWIODNAW")
    -- end
    -- LatestAngle:PrintValueClean()
    
    -- cmd.buttons = bit.bor(cmd.buttons,1)
end

-- TODO : Breakable test for doors or vents blocking our way.For now,we're not checking for breakable and just bruteforce it in the cycle attempt.

-- Cheat.RegisterCallback("pre_prediction", function(cmd)
--     -- local local_player = EntityList.GetLocalPlayer()
--     -- local local_player_index = local_player:EntIndex()
--     -- local local_eye_pos = Vector3D:new()
--     -- local_eye_pos:CopyOther(local_player:GetEyePosition())


--     -- local ShootVector = Vector3D:new()
--     -- ShootVector:CopyOther(Cheat.AngleToForward(EngineClient.GetViewAngles()))

--     -- ShootVector = ShootVector:MultiplySingle(8096) + local_eye_pos

--     -- local ray = ffi.new("Ray_t")
--     -- InitializeRay(ray,local_eye_pos,ShootVector)

--     -- local trace = ffi.new("CGameTrace*")

--     -- local filter = ffi.new("ITraceFilter*")
--     -- filter.pSkip = GetClientEntity(local_player_index)
--     -- TraceRay(ray,0x46004003,filter,trace)

--     local local_player = EntityList.GetLocalPlayer()
--     local local_player_index = local_player:EntIndex()
--     local local_eye_pos = local_player:GetEyePosition()

--     local local_eye_pos_custom = Vector3D:new()
--     local_eye_pos_custom:CopyOther(local_eye_pos)

--     local ShootVector = Cheat.AngleToForward(EngineClient.GetViewAngles())
--     local ShootVectorCustom = Vector3D:new()
--     ShootVectorCustom:CopyOther(ShootVector)

--     ShootVectorCustom = ShootVectorCustom:MultiplySingle(8096) + local_eye_pos_custom

--     ShootVector = Vector.new(ShootVectorCustom.x,ShootVectorCustom.y,ShootVectorCustom.z)


--     -- local ray = ffi.new("Ray_t")
--     -- InitializeRay(ray,local_eye_pos,ShootVector)

--     -- local trace = ffi.new("CGameTrace*")

--     -- local filter = ffi.new("ITraceFilter*")
--     -- filter.pSkip = GetClientEntity(local_player_index)

--     local traced = EngineTrace.TraceRay(local_eye_pos, ShootVector, local_player, 0x46004003)
--     -- print(traced.hit_entity:EntIndex())
--     -- print(traced.hit_entity:GetClassName())
--     -- print(IsBreakableEntity(GetClientEntity(traced.hit_entity:EntIndex())))
--     -- print(GetClientEntity(traced.hit_entity:EntIndex()))
--     -- print(traced.hit_entity)
-- end)

--local iteration = 0
PrecomputeSeed()
local LastMapName = nil
-- local ShouldStop = false

Cheat.RegisterCallback("pre_prediction", function(cmd)
    local tickrate = 1.0 / GlobalVars.interval_per_tick
   --FindPath()
    local game_rules = EntityList.GetGameRules()
    local m_bWarmupPeriod = game_rules:GetProp("m_bWarmupPeriod")
    local m_bFreezePeriod = game_rules:GetProp("m_bFreezePeriod")
    -- local m_bIsValveDS = game_rules:GetProp("m_bIsValveDS")

    local player_resource = EntityList.GetPlayerResource()
    local m_iPlayerC4 = player_resource:GetProp("m_iPlayerC4")

    local entity = EntityList.GetClientEntity(EngineClient.GetLocalPlayer())
    local player = entity:GetPlayer()
    local active_weapon = player:GetActiveWeapon()

    if not(entity or player or player:IsAlive())then
        return
    end

    local slot_string = nil
    local weapon_level = 0
    if GlobalVars.tickcount % tickrate == 0 then 
        if (m_iPlayerC4 == player:EntIndex()) then
            if(active_weapon:GetClassId() == 34)then
                EngineClient.ExecuteClientCmd("drop")
            else
                EngineClient.ExecuteClientCmd("slot5")
            end
        else
            if AutoWeaponSwitch_Switch:Get() then 
                local weapon_list = player:GetProp("m_hMyWeapons")
                for _,handle in ipairs(weapon_list)do
                    if handle == -1 then 
                        -- print("Invalid handle")
                        goto continue 
                    end
                    local weapon_entity = EntityList.GetClientEntityFromHandle(handle)
                    local weapon_index = weapon_entity:EntIndex()
                    local weapon = EntityList.GetWeapon(weapon_index)

                    if not weapon or not weapon:IsWeapon() then 
                        goto continue 
                    end
                    if weapon:IsRifle() or weapon:IsSniper() and ( weapon_level < 3 ) then
                        slot_string = "slot1"
                        weapon_level = 3
                        -- print("Changing to rifle/sniper")
                    elseif weapon:IsPistol() and ( weapon_level < 2 ) then
                        slot_string = "slot2"
                        weapon_level = 2
                        -- print("Changing to pistol")
                    elseif weapon:IsKnife() and ( weapon_level < 1 )then
                        slot_string = "slot3"
                        weapon_level = 1
                        -- print("Changing to knife")
                    end
                    ::continue::
                end
                if slot_string ~= nil then
                    EngineClient.ExecuteClientCmd(slot_string)
                end
            end
        end
    end
  
    

    if (GlobalVars.tickcount % tickrate == 0) then
        if (EngineClient.GetLevelNameShort() ~= LastMapName) then
            print("Map changed.")
            INavFile.m_isLoaded = false
            OpenList = { }
            ClosedList = { }
            CurrentNode = nil
            Path = { }
            NeedToResetLists = true
        end
    end

    if (not INavFile.m_isLoaded) then
        print("LoadMap : " .. EngineClient.GetLevelNameShort())
        LoadMap(EngineClient.GetLevelNameShort())
        LastMapName = EngineClient.GetLevelNameShort()
        return
    end

    if GlobalVars.tickcount % 1 == 0 and INavFile.m_isLoaded and not(GlobalVars.m_bRemoteClient and m_bWarmupPeriod) then -- m_bWarmupPeriod doesnt get set correctly on local server
        --print("Iteration : ",iteration)
        if not m_bFreezePeriod then 
            if(#Path == 0) then
                if(NeedToResetLists)then
                    --print("PATH 0")
                    PrepareToFindAnotherNode()
                    NeedToResetLists = false
                else
                    FindPath()
                    cmd.forwardmove = 0.0
                    cmd.sidemove = 0.0
                    cmd.upmove = 0.0
                end
            else
                --print("ELSE PATH 0")
                MoveToTarget(cmd)
                if TimeSinceLastSeenEnemy >= tickrate * TimeToMove:Get() then
                    ObstacleAvoid(cmd)
                end
                CheckIfArrivedAtNode(cmd)
            end
        end
        
        if not (bit.band(cmd.buttons,1) ~= 0)then 
            Aimbot(cmd)
        end
    end
    -- FixMovement(EngineClient.GetViewAngles(),cmd,cmd.forwardmove,cmd.sidemove)
    -- print("Clamping")

    -- Prevent IN_ATTACK and IN_ATTACK2 in same tick
    if ( bit.band(cmd.buttons,2048) ~= 0 ) then
        cmd.buttons = bit.band(cmd.buttons,-2)
    end

    cmd.forwardmove = Math:Clamp(cmd.forwardmove,-450,450)
    cmd.sidemove = Math:Clamp(cmd.sidemove,-450,450)

    cmd.viewangles.pitch = Math:Clamp(cmd.viewangles.pitch ,-89,89)
    cmd.viewangles.yaw = Math:Clamp(cmd.viewangles.yaw ,-180,180)
    cmd.viewangles.roll = 0.0
    if not Aimbot_SilentAim:Get() then
        EngineClient.SetViewAngles(cmd.viewangles)
    end
end)


local AutoQueuePanorama = Panorama.LoadString([[
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
                    CompetitiveMatchAPI.GetCooldownSecondsRemaining() > 0 || 
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
local panorama = Panorama.Open()

local function AutoQueue()
    if(AutoQueue_Switch:Get() and not IsDrawingLoadingImage() and not IsClientLocalToActiveServer() and not EngineClient.IsConnected() and not EngineClient.IsInGame() and GetGameState() == 3 and GetSignOnState() == 0) then
        AutoQueuePanorama()
        
        -- if ( not panorama.LobbyAPI.BIsHost()) then
        --     panorama.LobbyAPI.CreateSession()
        -- end
        
        -- if (not panorama.GameStateAPI.IsConnectedOrConnectingToServer() and panorama.LobbyAPI.GetMatchmakingStatusString() == "" and panorama.CompetitiveMatchAPI.GetCooldownSecondsRemaining() == 0 and not panorama.CompetitiveMatchAPI.HasOngoingMatch() ) then
        --     -- print("::::::::::::::::::::::::::::::::::::::StartMatchmaking::::::::::::::::::::::::::::::::::::::")
        --     panorama.LobbyAPI.StartMatchmaking("", "", "", "")
        -- end
    end
end

local AlreadyAttemptedToReconnect = false
local function AutoReconnect()
    if not AlreadyAttemptedToReconnect then
        if(AutoReconnect_Switch:Get() and not IsDrawingLoadingImage() and not IsClientLocalToActiveServer() and not EngineClient.IsConnected() and not EngineClient.IsInGame() and GetGameState() == 3 and GetSignOnState() == 0) then
            if (panorama.CompetitiveMatchAPI.HasOngoingMatch() and not panorama.GameStateAPI.IsConnectedOrConnectingToServer() ) then
                panorama.CompetitiveMatchAPI.ActionReconnectToOngoingMatch()
                AlreadyAttemptedToReconnect = true
                -- print("::::::::::::::::::::::::::::::::::::::ActionReconnectToOngoingMatch::::::::::::::::::::::::::::::::::::::")
            end
        end
    end
end
Cheat.RegisterCallback("frame_stage", function(stage)
    if stage ~= 6 then return end
    local tickrate = 1.0 / GlobalVars.interval_per_tick
    if( GlobalVars.tickcount % tickrate * 5 == 0 ) then
        AutoReconnect()
        AutoQueue()
    end
    
end)

Cheat.RegisterCallback("draw", function()

    -- print(GetGameState())
    -- print(IsDrawingLoadingImage())
    -- print(IsDrawingLoadingImage())
    -- local m_bShowProgressDialog = ffi.cast("bool*",g_EngineVGUI + 0x58)[0]
    -- print(m_bShowProgressDialog)
    -- print(IsTransitioningToLoad())  
    -- if scr_disabled_for_loading[0] == true then 
    --     print("scr_disabled_for_loading :::::::::::::::: " , scr_disabled_for_loading[0])
    -- end
    
    -- print(IsClientLocalToActiveServer())
    -- if math.ceil(GlobalVars.curtime) % 2 == 0 then 
    -- AutoReconnect()
    -- AutoQueue()
    -- end
    
    
    --print(#Path)
    if #Path == 0 then
        --if(CurrentNode ~= nil)then
        --    local CurrentNodePosition = CurrentNode.area.m_center
        --    local NeverLose_Vector = Vector.new(CurrentNodePosition.x, CurrentNodePosition.y, CurrentNodePosition.z)
        --    Render.Circle3D(NeverLose_Vector, 10.0, 10.0, Color.new(1.0, 1.0, 1.0))
        --    Render.Text("Current Node", Render.WorldToScreen(NeverLose_Vector), Color.new(1.0, 1.0, 1.0, 1.0), 20)
        --end

        if(CurrentNode ~= nil) then
            local localPath = {}
            table.insert(localPath,CurrentNode)
            local ParentNode = CurrentNode.parent
            while ParentNode ~= StartingNode do
                table.insert(localPath,ParentNode)
                ParentNode = ParentNode.parent
            end
            table.insert(localPath,ParentNode)

            for i = 1,#localPath do
                local FirstNode = localPath[i]
                local FirstNodePosition = FirstNode.area.m_center
                local FirstNodeVector = Vector.new(FirstNodePosition.x, FirstNodePosition.y, FirstNodePosition.z)
                local FirstNodeScreenPos = Render.WorldToScreen(FirstNodeVector)

                local SecondNode = localPath[i+1]
                if(SecondNode ~= nil)then
                    local SecondNodePosition = SecondNode.area.m_center
                    local SecondNodeVector = Vector.new(SecondNodePosition.x, SecondNodePosition.y, SecondNodePosition.z)
                    local SecondNodeScreenPos = Render.WorldToScreen(SecondNodeVector)
                    Render.Line(FirstNodeScreenPos, SecondNodeScreenPos, Color.new(1.0, 1.0, 1.0, 1.0))
                end

            end
        end

        --for key,Node in ipairs(OpenList)do
        --    local NodePosition = Node.area.m_center
        --    Render.Circle3D(Vector.new(NodePosition.x, NodePosition.y, NodePosition.z), 10.0, 10.0, Color.new(0.0, 1.0, 0.0))
        --end
        --
        --for key,Node in ipairs(ClosedList)do
        --    local NodePosition = Node.area.m_center
        --    Render.Circle3D(Vector.new(NodePosition.x, NodePosition.y, NodePosition.z), 10.0, 10.0, Color.new(1.0, 0.0, 0.0))
        --end
    else
        for i = 1,#Path do
            local FirstNode = Path[i]
            local FirstNodePosition = FirstNode.area.m_center
            local FirstNodeVector = Vector.new(FirstNodePosition.x, FirstNodePosition.y, FirstNodePosition.z)
            local FirstNodeScreenPos = Render.WorldToScreen(FirstNodeVector)

            local SecondNode = Path[i+1]
            if(SecondNode ~= nil)then
                local SecondNodePosition = SecondNode.area.m_center
                local SecondNodeVector = Vector.new(SecondNodePosition.x, SecondNodePosition.y, SecondNodePosition.z)
                local SecondNodeScreenPos = Render.WorldToScreen(SecondNodeVector)
                Render.Line(FirstNodeScreenPos, SecondNodeScreenPos, Color.new(1.0, 1.0, 1.0, 1.0))
            end
        end
        --for key,Node in ipairs(Path)do
        --    local NodePosition = Node.area.m_center
        --    Render.Circle3D(Vector.new(NodePosition.x, NodePosition.y, NodePosition.z), 10.0, 10.0, Color.new(1.0, 1.0, 1.0))
        --end
    end
end)

Cheat.RegisterCallback("events", function(event)
    local tickrate = 1.0 / GlobalVars.interval_per_tick
    -- print(event:GetName())

    -- if (event:GetName() == "round_prestart") then
    --     ShouldStop = true
    --     goto continue
	-- end
 
    -- if (event:GetName() == "round_end") then
    --     IsWarmup = false
    --     goto continue
    -- end

	-- if (event:GetName() == "round_freeze_end") then
	-- 	ShouldStop = false
    --     goto continue
    -- end
 
	-- if (event:GetName() == "round_end") then
	-- 	ShouldStop = true
    --     goto continue
    -- end
    if (event:GetName() == "cs_win_panel_match") and (AutoDisconnect_Switch:Get() or false) then
        EngineClient.ExecuteClientCmd("disconnect")
        goto continue
    end
    if (event:GetName() == "cs_game_disconnected") then
        -- print("cs_game_disconnected")

        AlreadyAttemptedToReconnect = false

        INavFile.m_isLoaded = false
        OpenList = { }
        ClosedList = { }
        CurrentNode = nil
        Path = { }
        NeedToResetLists = true
        goto continue
    end
    if (event:GetName() == "player_spawn") then
        TimeSinceLastSeenEnemy = tickrate * TimeToMove:Get()
        local local_player = EntityList.GetLocalPlayer()
        if local_player == nil then
            return
        end
        local player_info = local_player:GetPlayerInfo()
        local UserID = player_info.userId
        if (event:GetInt("userid", -1) == UserID) then
            OpenList = { }
            ClosedList = { }
            CurrentNode = nil
            Path = { }
            NeedToResetLists = true
        end
    -- elseif (event:GetName() == "nextlevel_changed")then
    --     print("nextlevel_changed")
    --     INavFile.m_isLoaded = false
    --     OpenList = { }
    --     ClosedList = { }
    --     CurrentNode = nil
    --     Path = { }
    --     NeedToResetLists = true
        goto continue
    end
    ::continue::
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
