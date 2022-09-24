ffi.cdef[[

    typedef struct SurfInfo SurfInfo;
    typedef struct client_textmessage_t client_textmessage_t;
    typedef struct CSentence CSentence;
    typedef struct CAudioSource CAudioSource;
    typedef struct 
    {
        float pitch,yaw,roll;
    } QAngle;

    typedef struct 
    {
        float x,y,z;
    } Vector;

    typedef struct
    {
        void*   fnHandle;               //0x0000 
        char    szName[260];            //0x0004 
        __int32 nLoadFlags;             //0x0108 
        __int32 nServerCount;           //0x010C 
        __int32 type;                   //0x0110 
        __int32 flags;                  //0x0114 
        Vector  vecMins;                //0x0118 
        Vector  vecMaxs;                //0x0124 
        float   radius;                 //0x0130 
        char    pad[0x1C];              //0x0134
    } model_t;

    typedef struct
    {
        __int64         unknown;            //0x0000 
        union
        {
            __int64       steamID64;          //0x0008 - SteamID64
            struct
            {
                __int32     xuid_low;
                __int32     xuid_high;
            };
        };
        char            szName[128];        //0x0010 - Player Name
        int             userId;             //0x0090 - Unique Server Identifier
        char            szSteamID[20];      //0x0094 - STEAM_X:Y:Z
        char            pad_0x00A8[0x10];   //0x00A8
        unsigned long   iSteamID;           //0x00B8 - SteamID 
        char            szFriendsName[128];
        bool            fakeplayer;
        bool            ishltv;
        unsigned int    customfiles[4];
        unsigned char   filesdownloaded;
    } player_info_t;


]]

ffi.cdef[[
    typedef int                     (__thiscall* GetIntersectingSurfaces_FN)        (void* ThisPointer, const model_t *model, const Vector &vCenter, const float radius, const bool bOnlyVisibleSurfaces, SurfInfo *pInfos, const int nMaxInfos);
    typedef Vector                  (__thiscall* GetLightForPoint_FN)               (void* ThisPointer, const Vector &pos, bool bClamp);
    typedef uint32_t                (__thiscall* TraceLineMaterialAndLighting_FN)   (void* ThisPointer, const Vector &start, const Vector &end, Vector &diffuseLightColor, Vector& baseColor);
    typedef const char*             (__thiscall* ParseFile_FN )                     (void* ThisPointer, const char *data, char *token, int maxlen);
    typedef bool                    (__thiscall* CopyFile_FN )                      (void* ThisPointer, const char *source, const char *destination);
    typedef void                    (__thiscall* GetScreenSize_FN)                  (void* ThisPointer, int& width, int& height);
    typedef void                    (__thiscall* ServerCmd_FN)                      (void* ThisPointer, const char *szCmdString, bool bReliable);
    typedef void                    (__thiscall* ClientCmd_FN)                      (void* ThisPointer, const char *szCmdString);
    typedef bool                    (__thiscall* GetPlayerInfo_FN)                  (void* ThisPointer, int ent_num, player_info_t *pinfo);
    typedef int                     (__thiscall* GetPlayerForUserID_FN)             (void* ThisPointer, int userID);
    typedef client_textmessage_t*   (__thiscall* TextMessageGet_FN)                 (void* ThisPointer, const char *pName);
    typedef bool                    (__thiscall* Con_IsVisible_FN)                  (void* ThisPointer);
    typedef int                     (__thiscall* GetLocalPlayer_FN)                 (void* ThisPointer);
    typedef const model_t*          (__thiscall* LoadModel_FN)                      (void* ThisPointer, const char *pName, bool bProp);
    typedef float                   (__thiscall* GetLastTimeStamp_FN)               (void* ThisPointer);
    typedef CSentence*              (__thiscall* GetSentence_FN)                    (void* ThisPointer, CAudioSource *pAudioSource);
    typedef float                   (__thiscall* GetSentenceLength_FN)              (void* ThisPointer, CAudioSource *pAudioSource);
    typedef bool                    (__thiscall* IsStreaming_FN)                    (void* ThisPointer, CAudioSource *pAudioSource);
    typedef void                    (__thiscall* GetViewAngles_FN)                  (void* ThisPointer, QAngle* va);
    typedef void                    (__thiscall* SetViewAngles_FN)                  (void* ThisPointer, QAngle* va);
    typedef int                     (__thiscall* GetMaxClients_FN)                  (void* ThisPointer);
    typedef const char*             (__thiscall* Key_LookupBinding_FN)              (void* ThisPointer, const char *pBinding);
    typedef const char*             (__thiscall* Key_BindingForKey_FN)              (void* ThisPointer, int &code);
]]

local IVEngineClient = {
    GetIntersectingSurfaces         = utils.get_vfunc("engine.dll", "VEngineClient014", 0,"int (__thiscall*)(void* ThisPointer, const model_t *model, const Vector &vCenter, const float radius, const bool bOnlyVisibleSurfaces, SurfInfo *pInfos, const int nMaxInfos)")
}
IVEngineClient.__index = IVEngineClient
setmetatable(IVEngineClient,IVEngineClient)




