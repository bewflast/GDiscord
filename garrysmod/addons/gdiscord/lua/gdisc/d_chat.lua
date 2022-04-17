require("gwsockets")
util.AddNetworkString("GDiscord_receive_message")

local netStart = net.Start
local netBroadcast = net.Broadcast
local netWriteString = net.WriteString
local JSONToTable = util.JSONToTable

GDiscord.setup_connection = function()
	
    GDiscord.wsock = GWSockets.createWebSocket(GDiscord.config['discord_gateway_link'])

    function GDiscord.wsock:onMessage(data)
		local recv = JSONToTable(data)
        if recv["op"] == 10 then 

			GDiscord.other['hb_interval'] = recv["d"]["heartbeat_interval"] / 10000
			timer.Simple(GDiscord.other['hb_interval'], function ()
				GDiscord.wsock:write(GDiscord.payloads['auth'])
				timer.Create("DS gateway heartbeat", GDiscord.other['hb_interval'], 0, function()
					GDiscord.wsock:write(GDiscord.payloads['heartbeat'])
				end)
			end)
	
		elseif recv['op'] == 0 and recv['t'] == "MESSAGE_CREATE" and recv['d']['channel_id'] == GDiscord.config['channel_id'] and not recv['d']['author']['bot'] then

			netStart("GDiscord_receive_message")
				netWriteString(recv["d"]["author"]["username"])
				netWriteString(recv["d"]["content"])
			netBroadcast()

		end
    end

    function GDiscord.wsock:onError(txt)

		print("GDiscord disconnected. Error: ", txt)
		GDiscord.is_connected = false
		timer.Remove("DS gateway heartbeat")
		GDiscord.wsock:close()

	end

	function GDiscord.wsock:onConnected()

		print("GDiscord connected!")
		GDiscord.is_connected = true

	end

	function GDiscord.wsock:onDisconnected()

		print("GDiscord disconnected.")
		GDiscord.is_connected = false
		timer.Remove("DS gateway heartbeat")
		GDiscord.wsock:close()

	end

	GDiscord.wsock:open()
end

local function checkWSocket()
    if not GDiscord.is_connected then
        GDiscordInit()
    end
end


function GDiscordInit()

	timer.Remove("CheckGDiscordConnection")

	if GDiscord.wsock then 
		GDiscord.wsock:close()
	else 
		GDiscord.wsock = nil 
	end

	GDiscord.payloads = {}

	GDiscord.other = { 
		['hb_interval'] = nil, 
		['session_id'] = nil, 
		['seq'] = 0 
	}

	GDiscord.payloads['auth'] = string.format([[
		{
			"op": 2,
			"d": {
				"token": "%s",
				"properties": {
					"$os": "windows",
					"$browser": "chrome",
					"$device": "pc"
				}
			}
		}
	]], GDiscord.config['bot_token'])

	GDiscord.payloads['heartbeat'] = [[
		{
			"op": 1,
			"d": "null"
		}
	]]

	GDiscord.payloads['resume'] = string.format([[
		{
			"op": 6,
			"d": {
			"token": "%s",
			"session_id": "%s",
			"seq": %d
			}
		}
	]], GDiscord.config['bot_token'], GDiscord.other['session_id'], GDiscord.other['seq'])

    timer.Create("CheckGDiscordConnection", 5, 0, function() checkWSocket() end)
	GDiscord.setup_connection()
	hook.Remove("InitPostEntity", "InitGDiscord")
end

hook.Add("InitPostEntity", "InitGDiscord", GDiscordInit)