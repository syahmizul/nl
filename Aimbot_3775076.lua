ffi.cdef[[

	void XMScalarSinCos(float *pSin,float *pCos,float Value);
	float XMConvertToRadians(float fDegrees);
	float XMConvertToDegrees(float fRadians);
	
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
]]

local function GetVirtualFunction(address,index)
    local vtable = ffi.cast("uint32_t**",address)[0]
    return ffi.cast("uint32_t",vtable[index])
 end

local IEngineTrace = ffi.cast("uint32_t",Utils.CreateInterface("engine.dll","EngineTraceClient004"))
local ClipRayToEntity = ffi.cast("void(__thiscall*)(uint32_t thisptr,const Ray_t &ray, uint32_t fMask, uint32_t EntityAddress, CGameTrace *pTrace)",GetVirtualFunction(IEngineTrace , 3))


local IUniformRandomStream = ffi.cast("uint32_t",Utils.CreateInterface("engine.dll","VEngineRandom001"))
local SetSeed = ffi.cast("void(__thiscall*)(uint32_t,int iSeed)",GetVirtualFunction(IUniformRandomStream , 0))
local RandomFloat = ffi.cast("float(__thiscall*)(uint32_t,float flMinVal, float flMaxVal)",GetVirtualFunction(IUniformRandomStream , 1))
local RandomInt = ffi.cast("int(__thiscall*)(uint32_t,int flMinVal, int flMaxVal)",GetVirtualFunction(IUniformRandomStream , 2))

local UpdateAccuracyPenalty = ffi.cast("void(__thiscall*)(uint32_t)",Utils.PatternScan("client.dll","55 8B EC 83 E4 F8 83 EC 18 56 57 8B F9 8B 8F 40 32 00 00 83 F9 FF 74 27"))

local M_PI = 3.14159265358979323846
local PI_2 = M_PI * 2.0

ffi.cdef [[
    typedef uint32_t(__thiscall* GetClientEntity_FN)(uint32_t this,uint32_t entNum);
]]

local g_EntityList = ffi.cast("uint32_t",Utils.CreateInterface("client.dll","VClientEntityList003"))
local function GetClientEntity(entNum)
    return ffi.cast("GetClientEntity_FN",GetVirtualFunction(g_EntityList , 3))(g_EntityList,entNum)
end

local enable = Menu.Switch("Aimbot", "Enable",false,"Global switch for the aimbot.")
local fov = Menu.SliderFloat("Aimbot", "Field of view", 3.0,1.0, 180.0,"If the enemy is within your field of view within this range,the aimbot will activate.")
local smooth = Menu.SliderFloat("Aimbot", "Smoothness", 10.0,1.0, 100.0,"Make your aim more legitimate or more blatant.")
local hit_chance = Menu.SliderFloat("Aimbot", "Hit Chance", 25.0,1.0,100.0,"Make your aim more legitimate or more blatant.")
local prefer_baim = Menu.Switch("Aimbot", "Prefer Body Aim",true,"If body hitboxes are visible,it will be prioritized first.If no hitboxes EXCEPT the head is visible,then it will go for head.")

local trace_mask = 0x46004003
local recoil_scale = 2.0
local Computed_Seeds = { }

local e_hitboxes = {
    HEAD = 0,
    NECK = 1,
    PELVIS = 2,
    BODY = 3,
    THORAX = 4,
    CHEST = 5,
    UPPER_CHEST = 6,
    RIGHT_THIGH = 7,
    LEFT_THIGH = 8,
    RIGHT_CALF = 9,
    LEFT_CALF = 10,
    RIGHT_FOOT = 11,
    LEFT_FOOT = 12,
    RIGHT_HAND = 13,
    LEFT_HAND = 14,
    RIGHT_UPPER_ARM = 15,
    RIGHT_FOREARM = 16,
    LEFT_UPPER_ARM = 17,
    LEFT_FOREARM = 18
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

local function AngleVectors(Angle) 
	local sr = ffi.new("float[1]",{})
	local sp = ffi.new("float[1]",{})
	local sy = ffi.new("float[1]",{})
	
	local cr = ffi.new("float[1]",{})
	local cp = ffi.new("float[1]",{})
	local cy = ffi.new("float[1]",{})
	
	local forward = ffi.new("Vector",{})
	local right = ffi.new("Vector",{})
	local up = ffi.new("Vector",{})
	
	sp[0] = math.sin(math.rad(Angle.x))
	cp[0] = math.cos(math.rad(Angle.x))
	
	sy[0] = math.sin(math.rad(Angle.y))
	cy[0] = math.cos(math.rad(Angle.y))
	
	sr[0] = math.sin(math.rad(Angle.z))
	cr[0] = math.cos(math.rad(Angle.z))
	
	forward.x = (cp[0] * cy[0])
	forward.y = (cp[0] * sy[0])
	forward.z = (-sp[0])
	right.x = (-1 * sr[0] * sp[0] * cy[0] + -1 * cr[0] * -sy[0])
	right.y = (-1 * sr[0] * sp[0] * sy[0] + -1 * cr[0] *  cy[0])
	right.z = (-1 * sr[0] * cp[0])
	up.x = (cr[0] * sp[0] * cy[0] + -sr[0]*-sy[0])
	up.y = (cr[0] * sp[0] * sy[0] + -sr[0]*cy[0])
	up.z = (cr[0] * cp[0])
	
	return { forward, right, up }
end

local function AngleVectorsForward(Angle) 
	local sr = ffi.new("float[1]",{})
	local sp = ffi.new("float[1]",{})
	local sy = ffi.new("float[1]",{})
	
	local cr = ffi.new("float[1]",{})
	local cp = ffi.new("float[1]",{})
	local cy = ffi.new("float[1]",{})
	
	local forward = ffi.new("Vector",{})

	sp[0] = math.sin(math.rad(Angle.x))
	cp[0] = math.cos(math.rad(Angle.x))
	
	sy[0] = math.sin(math.rad(Angle.y))
	cy[0] = math.cos(math.rad(Angle.y))
	
	sr[0] = math.sin(math.rad(Angle.z))
	cr[0] = math.cos(math.rad(Angle.z))
	
	forward.x = (cp[0] * cy[0])
	forward.y = (cp[0] * sy[0])
	forward.z = (-sp[0])

	return forward
end

local function NormalizeVector(Vector)
	local NewVector = ffi.new("Vector",{Vector.x,Vector.y,Vector.z})
	local l = math.sqrt(NewVector.x * NewVector.x + NewVector.y * NewVector.y + NewVector.z * NewVector.z)
	
	if l ~= 0.0 then
		NewVector.x = NewVector.x / l
		NewVector.y = NewVector.y / l
		NewVector.z = NewVector.z / l
	else
		NewVector.x = 0.0
		NewVector.y = 0.0
		NewVector.z = 0.0
	end
	return NewVector
end

local function NormalizeAngles(Angle)

	while (Angle.x > 89.0) do
		Angle.x = Angle.x - 180.0;
    end
  
	while (Angle.x < -89.0) do
		Angle.x = Angle.x + 180.0;
    end
  
	while (Angle.y  > 180.0) do
		Angle.y = Angle.y - 360.0;
    end
  
	while (Angle.y  < -180.0) do
		Angle.y = Angle.y + 360.0;
    end
  
	Angle.z = 0.0;
		
	return ffi.new("Vector",{Angle.x,Angle.y,Angle.z})
end

local function VectorSubstract(Vec1,Vec2) -- Vector
	local NewVector = ffi.new("Vector",{})
	NewVector.x = Vec1.x - Vec2.x
	NewVector.y = Vec1.y - Vec2.y
	NewVector.z = Vec1.z - Vec2.z
	return NewVector
end

local function VectorSubstract2(Vec1,Vec2) -- VectorAligned
	local NewVector = ffi.new("VectorAligned",{})
	NewVector.v.x = Vec1.x - Vec2.x
	NewVector.v.y = Vec1.y - Vec2.y
	NewVector.v.z = Vec1.z - Vec2.z
	
	return NewVector
end

local function VectorLengthSqr2(Vector) -- float
	return (Vector.v.x * Vector.v.x + Vector.v.y * Vector.v.y + Vector.v.z * Vector.v.z)
end

local function CalculateSpread(weapon,seed,inaccuracy,spread)

	if not weapon or weapon:GetProp("DT_BaseCombatWeapon", "m_iClip1") <= 0 then -- no spread
		return ffi.new("Vector",{})
	end
	
	-- SetSeed(IUniformRandomStream , ffi.new("int",bit.band(seed,0xff) + 1))
	
	-- r1 = RandomFloat(IUniformRandomStream , 0.0,1.0)
	-- r2 = RandomFloat(IUniformRandomStream , 0.0,PI_2)
	-- r3 = RandomFloat(IUniformRandomStream , 0.0,1.0)
	-- r4 = RandomFloat(IUniformRandomStream , 0.0,PI_2)
	
	-- print(DumpTable(Computed_Seeds))
	
	local r1 = Computed_Seeds[seed+1][1]
	local r2 = Computed_Seeds[seed+1][2]
	local r3 = Computed_Seeds[seed+1][3]
	local r4 = Computed_Seeds[seed+1][4]
	
	
	
	-- print("random nums:",r1,r2,r3,r4)
	
	local c1 = math.cos(r2)
	local c2 = math.cos(r4)
	local s1 = math.sin(r2)
	local s2 = math.sin(r4)
	
	return ffi.new("Vector",{
		(c1 * (r1 * inaccuracy)) + (c2 * (r3 * spread)),
		(s1 * (r1 * inaccuracy)) + (s2 * (r3 * spread)),
		0.0
	})
end

local function FindVisibleHitbox(localplayer,targetPlayer)
	local Hitbox_Order = nil
	local eye_pos = localplayer:GetEyePosition()
	if not prefer_baim:Get() then
		Hitbox_Order = Hitboxes_Normal
	else
		Hitbox_Order = Hitboxes_BodyAim
	end
	
	for _,hitbox in ipairs(Hitbox_Order) do 
		local Hitbox_Pos = targetPlayer:GetHitboxCenter(hitbox)
		
		local trace_result = EngineTrace.TraceRay(eye_pos, Hitbox_Pos, localplayer,trace_mask)
		if trace_result.hit_entity then
			if trace_result.hit_entity:EntIndex() == targetPlayer:EntIndex() then
				return { Hitbox_Pos , hitbox }
			end
		end
	end
end

local function CalcAngle(src,dst)
	local vAngle = ffi.new("Vector",{})
	local delta  = ffi.new("Vector",{src.x - dst.x,src.y - dst.y,src.z - dst.z})
	local hyp	 = math.sqrt(delta.x*delta.x + delta.y * delta.y)
	
	vAngle.x = math.atan(delta.z / hyp) * 57.295779513082
	vAngle.y = math.atan(delta.y / delta.x) * 57.295779513082
	vAngle.z = 0.0
	
	if (delta.x >= 0.0) then
		vAngle.y = vAngle.y + 180.0
	end
	
	vAngle = NormalizeAngles(vAngle)
	return vAngle
end



local function GetFOV(viewAngle,aimAngle)
	local aim = ffi.new("Vector",AngleVectorsForward(viewAngle))
	local ang = ffi.new("Vector",AngleVectorsForward(aimAngle))
	
	local res = math.deg(math.acos((aim.x * ang.x + aim.y * ang.y + aim.z * ang.z )/(aim.x * aim.x + aim.y * aim.y + aim.z * aim.z)))

	if res ~= res then
		res = 0.0
	end
	return res
end

local function SmoothAngle( from , to , percent )
	local VecDelta = ffi.new("Vector",VectorSubstract(from,to))
	VecDelta = NormalizeAngles(VecDelta)
	VecDelta.x = VecDelta.x * ( percent / 100.0 )
	VecDelta.y = VecDelta.y * ( percent / 100.0 )
	
	return ffi.new("Vector",VectorSubstract(from,VecDelta))
end

local function GetNearestEnemyToFOV()
	local PlayerList = EntityList.GetPlayers()
	local local_player = EntityList.GetLocalPlayer()
	local local_eyepos = local_player:GetEyePosition()
	local engine_angle = EngineClient.GetViewAngles()
  
    local AngBetEnt = 180.0
  
	local nearest_entity = nil
	
	for _,player in ipairs(PlayerList) do
			
        if not player:IsAlive() or player:IsDormant() or not FindVisibleHitbox(local_player,player) then
            goto continue
        end
        
        local enemy_eyepos = player:GetEyePosition()
        
        local angleToTarget = CalcAngle(local_eyepos,enemy_eyepos)
        local TempAngle = GetFOV(engine_angle,angleToTarget)

        if ( TempAngle <= fov:Get() and TempAngle <= AngBetEnt) then
            AngBetEnt = TempAngle
            nearest_entity = player
        end
        
		::continue::
	end
  return nearest_entity
end

local function CanLocalPlayerFire()
    local local_player = EntityList.GetLocalPlayer()
    local local_weapon = local_player:GetActiveWeapon()
    local OwnerFromHandle = EntityList.GetClientEntityFromHandle(local_weapon:GetProp("m_hOwnerEntity"))

    if not OwnerFromHandle then 
        return false
    end

    if(OwnerFromHandle:IsPlayer())then
        OwnerFromHandle = OwnerFromHandle:GetPlayer()
    else
        return false
    end
    local m_iClip1 = local_weapon:GetProp("m_iClip1")
    local m_flNextPrimaryAttack = local_weapon:GetProp("m_flNextPrimaryAttack")
    local m_flNextAttack = OwnerFromHandle:GetProp("m_flNextAttack")
    local m_nTickBase = OwnerFromHandle:GetProp("m_nTickBase")

    if local_weapon:IsReloading() or m_iClip1 <= 0 then
        return false
    end

    local flServerTime = m_nTickBase * GlobalVars.interval_per_tick
    
    if m_flNextAttack > flServerTime then
        return false
    end

    return m_flNextPrimaryAttack <= flServerTime 
end

local function IsValidHitGroup(index)

	if ((index >= 0 and index <= 7) or index == 10) then
		return true
	end
	
	return false
end

local function InitializeRay(Ray,VecStart,VecEnd)
    Ray.m_Delta = VectorSubstract2(VecEnd,VecStart)
    Ray.m_IsSwept = (VectorLengthSqr2(Ray.m_Delta) ~= 0)

    -- m_Extents.Init();
    local extents = Ray.m_Extents.v
    extents.x = 0.0
    extents.y = 0.0
    extents.z = 0.0
    
    Ray.m_pWorldAxisTransform = 0
    Ray.m_IsRay = true

    -- // Offset m_Start to be in the center of the box...
    
    local startoffset = Ray.m_StartOffset.v
    startoffset.x = 0.0
    startoffset.y = 0.0
    startoffset.z = 0.0

    Ray.m_Start.v = ffi.new("Vector",{VecStart.x,VecStart.y,VecStart.z})
end

local HITCHANCE_MAX = 100.0
local SEED_MAX		= 255

local function CheckHitchance(cmd,targetPlayer,hitbox_id)
	local lp 		= EntityList.GetLocalPlayer()
	local lp_weapon = lp:GetActiveWeapon()
	local lp_eyepos = lp:GetEyePosition()
	
	local va 		= cmd.viewangles
	local Vectors 	= AngleVectors(ffi.new("Vector",{va.x,va.y,va.z})) --forward,right,up
	
	if lp_weapon then
		UpdateAccuracyPenalty(GetClientEntity(lp_weapon:EntIndex()))
	end
	
	local inaccuracy 	= lp_weapon:GetInaccuracy()
	local spread 		= lp_weapon:GetSpread()
	
	-- print(DumpTable(Vectors))
	
	local total_hits = 0
	local needed_hits = math.ceil((hit_chance:Get() * SEED_MAX)/HITCHANCE_MAX)
	for seed=0,SEED_MAX do
		
		local wep_spread = CalculateSpread(lp_weapon,seed,inaccuracy,spread)
		local dir = NormalizeVector(ffi.new("Vector",
		{
			Vectors[1].x + (Vectors[2].x * wep_spread.x) + (Vectors[3].x * wep_spread.y),
			Vectors[1].y + (Vectors[2].y * wep_spread.x) + (Vectors[3].y * wep_spread.y),
			Vectors[1].z + (Vectors[2].z * wep_spread.x) + (Vectors[3].z * wep_spread.y)
		}))
		
		local EndVec = ffi.new("Vector",
		{
			lp_eyepos.x + (dir.x * 8192.0),
			lp_eyepos.y + (dir.y * 8192.0),
			lp_eyepos.z + (dir.z * 8192.0)
		})
		local Ray = ffi.new("Ray_t",{})
		local Trace = ffi.new("CGameTrace[1]",{})
		
		InitializeRay(Ray,lp_eyepos,EndVec)
		ClipRayToEntity(IEngineTrace,Ray,trace_mask,targetPlayer:get_address(),Trace)
		-- print("Trace Hitbox",Trace[0].hitbox)
		-- print("hitbox_id",hitbox_id)
		if Trace[0].hit_entity == targetPlayer:get_address() and IsValidHitGroup(Trace[0].hitgroup) then
			total_hits = total_hits + 1
		end
		
		--we made it.
		if (total_hits >= needed_hits) then
			return true
		end
		
		-- we cant make it anymore.
		if ((SEED_MAX - seed + total_hits) < needed_hits) then
			return false
		end	
	end
	
	return false
end

local function Triggerbot(cmd,target,hitbox_id)
	if CanLocalPlayerFire() then
		if CheckHitchance(cmd,target,hitbox_id) then
			cmd.buttons = bit.bor(cmd.buttons,1)
		end
	end
end


local function RunAimbot(cmd)
	local local_player = EntityList.GetLocalPlayer()
	
	if not local_player or not EngineClient.IsInGame() or not EngineClient.IsConnected() or not local_player:IsAlive() or not enable:Get() then
		return
	end
  
  local target = GetNearestEnemyToFOV()
  
  if not target then
    return
  end
  
  local target_hitbox = FindVisibleHitbox(local_player,target)
  local hitbox_id = target_hitbox[2]
  local engine_angle = EngineClient.GetViewAngles()
  local target_angle = CalcAngle(local_player:get_eye_position(),target_hitbox[1])
  
  
  local m_aimPunchAngle = ffi.cast("Vector*",ffi.cast("uint32_t",local_player:get_address() + 0x303C))[0]
  -- print("m_aimPunchAngle.x" , m_aimPunchAngle.x)
  -- print("m_aimPunchAngle.y" , m_aimPunchAngle.y)
  target_angle.x = target_angle.x - ( m_aimPunchAngle.x * recoil_scale )
  target_angle.y = target_angle.y - ( m_aimPunchAngle.y * recoil_scale )
  
  Triggerbot(cmd,target,hitbox_id)
  
  target_angle = SmoothAngle(engine_angle,target_angle,math.abs(smooth:get() - 101.0))
  
  local resulting_angle = QAngle.new(target_angle.x,target_angle.y,target_angle.z) 
  cmd.viewangles = resulting_angle
  EngineClient.SetViewAngles(resulting_angle)
  
  
end

local function PrecomputeSeed()
	
	
	for seed=0,SEED_MAX do
	
		local random_values = { }
	
		SetSeed(IUniformRandomStream , ffi.new("int",bit.band(seed,0xff) + 1))
	
		table.insert(random_values,RandomFloat(IUniformRandomStream , 0.0,1.0))
		table.insert(random_values,RandomFloat(IUniformRandomStream , 0.0,PI_2))
		table.insert(random_values,RandomFloat(IUniformRandomStream , 0.0,1.0))
		table.insert(random_values,RandomFloat(IUniformRandomStream , 0.0,PI_2))
		
		
		table.insert(Computed_Seeds,random_values)
	end
	
end


PrecomputeSeed()
Cheat.RegisterCallback("pre_prediction", RunAimbot)