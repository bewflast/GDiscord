require("gwsockets")
util.AddNetworkString("GDiscord_receive_message")

GDiscord.is_connected = false 
GDiscord.wsock = nil

GDiscord.setup_connection = function()
    GDiscord.wsock = GWSockets.createWebSocket("ws://" .. GDiscord.config['websocket_ip'] .. ":" .. GDiscord.config['websocket_port'])

    function GDiscord.wsock:onMessage(raw)

        local message = string.Split(raw, GDiscord.config['receive_separator'])
        net.Start("GDiscord_receive_message")
            net.WriteString(message[1])
            net.WriteString(message[2])
        net.Broadcast()

    end

    function GDiscord.wsock:onError(txt)

		print("GDiscord disconnected. Error: ", txt)
		GDiscord.is_connected = false
		GDiscord.wsock:close()

	end

	function GDiscord.wsock:onConnected()

		print("GDiscord connected!")
		GDiscord.is_connected = true

	end

	function GDiscord.wsock:onDisconnected()

		print("GDiscord disconnected.")
		GDiscord.is_connected = false
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