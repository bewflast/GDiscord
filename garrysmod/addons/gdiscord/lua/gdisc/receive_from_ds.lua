local GDiscord_colors = {
    ['discord_lable'] = Color(245, 125, 126),
    ['author'] = Color(249, 174, 71),
    ['content'] = Color(255, 255, 255)
}

local function GDiscord_print_message(len, ply)

    local author = net.ReadString()
    local content = net.ReadString()
    chat.AddText( GDiscord_colors['discord_lable'], "[DISCORD] ", GDiscord_colors['author'], author, GDiscord_colors['content'], ": " .. content )

end

net.Receive("GDiscord_receive_message", GDiscord_print_message)