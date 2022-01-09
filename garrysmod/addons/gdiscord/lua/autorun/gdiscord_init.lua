if SERVER then
    
    AddCSLuaFile("gdisc/receive_from_ds.lua")

    include("gdisc/gdisc_config.lua")
    include("gdisc/g_chat.lua")
    include("gdisc/d_chat.lua")

end

include("gdisc/receive_from_ds.lua")