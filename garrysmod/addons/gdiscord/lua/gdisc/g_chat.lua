require('chttp')

local CHTTP = CHTTP
local strsub = string.sub
local strfind = string.find
local strtrim = string.Trim
local tabtoJSON = util.TableToJSON

GDiscord.players_avatars_cache = {}

GDiscord.sendToDS = function(params)
    CHTTP({
        method = 'POST',
        url = GDiscord.config['discord_webhook'] .. '?wait=true',
        body = tabtoJSON(params),
        headers = postheader,
        type = "application/json; charset=utf-8"
    })
end

GDiscord.hook_connect = function(data)

    local name = data.name		
    local sid = util.SteamIDTo64(data.networkid)		
    local id = data.userid			
    local bot = data.bot		
    local reason = data.reason
    local time = os.date( "%H:%M:%S - %d/%m/%Y" , os.time() )

    if sid == "0" then return end -- if bot ne rabotaet ;(( 
    
    http.Fetch("https://steamcommunity.com/profiles/" .. sid .. "?xml=1", function(body) 
        local aXMLpos1, aXMLpos2 = strfind(body, "avatarFull"), strfind(body, "/avatarFull")  
        GDiscord.players_avatars_cache[sid] = strsub(body, aXMLpos1 + 20, aXMLpos2 - 5)
        local params = 
        {
            ['allowed_mentions'] = { ['parse'] = {} },
            ['username'] = name,
            ['avatar_url'] = GDiscord.players_avatars_cache[sid],
            ['embeds'] = 
            { 

                {
                    title = "Игрок заходит на сервер",
                    description = time .. "\n=====================\n[" .. data.networkid .. "](http://steamcommunity.com/profiles/" .. sid .. ')',                      
                    color = 6465586,
                    footer = 
                    {
                        text = name,
                        icon_url = GDiscord.players_avatars_cache[sid]
                    }
                } 
            }
        }
        GDiscord.sendToDS(params)
    end)


end

GDiscord.hook_disconnect = function( data )

    local name = data.name		
    local sid = util.SteamIDTo64(data.networkid)		
    local id = data.userid			
    local bot = data.bot		
    local reason = data.reason
    local time = os.date( "%H:%M:%S - %d/%m/%Y" , os.time() )
    local params = 
        {
            ['allowed_mentions'] = { ['parse'] = {} },
            ['username'] = name,
            ['avatar_url'] = GDiscord.players_avatars_cache[sid],
            ['embeds'] = 
            { 

                {
                    title = "Игрок вышел",
                    description = time .. "\n=====================\n[" .. data.networkid .. "](http://steamcommunity.com/profiles/" .. sid .. ')\n=====================\nПричина: ' .. reason,                      
                    color = 13048860,
                    footer = 
                    {
                        text = name,
                        icon_url = GDiscord.players_avatars_cache[sid]
                    }
                } 
            }
        }
    GDiscord.sendToDS(params)
    table.RemoveByValue(GDiscord.players_avatars_cache, GDiscord.players_avatars_cache[sid])

end

GDiscord.hook_chat = function(ply, text)

    local params = 
    {
        ['allowed_mentions'] = { ['parse'] = {} },
        ['username'] = '[' .. team.GetName( ply:Team() ) .. '] ' .. ply:Nick(),
        ['avatar_url'] = GDiscord.players_avatars_cache[ply:SteamID64()],
        ['content'] = '> — ' .. strtrim(text, " "),
    }

    GDiscord.sendToDS(params)

end

gameevent.Listen("player_connect")
hook.Add("player_connect", "GDiscord_connectHook", GDiscord.hook_connect)

gameevent.Listen("player_disconnect")
hook.Add("player_disconnect", "GDiscord_disconnectHook", GDiscord.hook_disconnect)

hook.Add("PlayerSay", "GDiscord_chatHook", GDiscord.hook_chat)
