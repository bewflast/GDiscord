require("gwsockets")
util.AddNetworkString("GDiscord_receive_message")

GDiscord.is_connected = false 
GDiscord.wsock = nil

local auth_payload = string.format([[
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

local hb_payload = [[
	{
		"op": 1,
		"d": "null"
	}
]]

local hb_interval = nil

GDiscord.setup_connection = function()
	
    GDiscord.wsock = GWSockets.createWebSocket(GDiscord.config['discord_gateway_link'])

    function GDiscord.wsock:onMessage(data)
		local recv = util.JSONToTable(data)
        if recv["op"] == 10 then 

			hb_interval = recv["d"]["heartbeat_interval"] / 10000
			timer.Simple(hb_interval, function ()
				GDiscord.wsock:write(auth_payload)
				timer.Create("DS gateway heartbeat", hb_interval, 0, function()
					print('sent heartbeat!')
					GDiscord.wsock:write(hb_payload)
				end)
			end)
	
		elseif recv['op'] == 0 and recv['t'] == "MESSAGE_CREATE" and recv['d']['channel_id'] == GDiscord.config['channel_id'] and not recv['d']['author']['bot'] then

			net.Start("GDiscord_receive_message")
				net.WriteString(recv["d"]["author"]["username"])
				net.WriteString(recv["d"]["content"])
        	net.Broadcast()

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
        GDiscord.setup_connection()
    end
end

hook.Add("InitPostEntity", "InitGDiscord", function() 
    timer.Create("CheckGDiscordConnection", 5, 0, function() checkWSocket() end) 
 end)