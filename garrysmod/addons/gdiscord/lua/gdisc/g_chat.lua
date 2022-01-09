require('chttp')

GDiscord.players_avatars_cache = {}

GDiscord.sendToDS = function(params)
    CHTTP({
        method = 'POST',
        url = GDiscord.config['discord_webhook'] .. '?wait=true',
        body = util.TableToJSON(params),
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

    CHTTP ({
        failed = function(reason) end,
        success = function(code, body, headers)
            GDiscord.players_avatars_cache[sid] = util.JSONToTable(body)['response']['players'][1]['avatarfull']
        end,
        method = 'GET',
        url = "http://api.steampowered.com/ISteamUser/GetPlayerSummaries/v0002/?key=" .. GDiscord.config['steam_api_key'] .. '&steamids=' .. sid
    })

    timer.Simple(1.5, function()
    
        local params = 
        {
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

    local temp = {}
    for k,v in pairs(GDiscord.players_avatars_cache) do 
        if k != sid then 
            temp[k] = v                                   --dont ask me bout dat PLS
        end 
    end
    GDiscord.players_avatars_cache = temp
    temp = nil

end

GDiscord.hook_chat = function(ply, text)

    local params = 
    {
        ['allowed_mentions'] = { ['parse'] = {} },
        ['username'] = '[' .. team.GetName( ply:Team() ) .. '] ' .. ply:Nick(),
        ['avatar_url'] = GDiscord.players_avatars_cache[ply:SteamID64()],
        ['content'] = '> — ' .. string.Trim(text, " "),
    }

    GDiscord.sendToDS(params)

end

gameevent.Listen("player_connect")
hook.Add("player_connect", "GDiscord_connectHook", GDiscord.hook_connect)

gameevent.Listen("player_disconnect")
hook.Add("player_disconnect", "GDiscord_disconnectHook", GDiscord.hook_disconnect)

hook.Add("PlayerSay", "GDiscord_chatHook", GDiscord.hook_chat)
