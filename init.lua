-- Initialization {
	local storage = minetest.get_mod_storage()

	nametag_mgr = {}

	nametag_mgr.modifiers = minetest.deserialize(storage:get_string("nametag_mgr_modifiers"))
	if not nametag_mgr.modifiers   -- No modifiers yet?
		nametag_mgr.modifiers = {}   -- Initialize to an empty list.
		storage:set_string("nametag_mgr_modifiers", minetest.serialize(nametag_mgr))   -- Save in storage.
	end
-- } Initialization

function nametag_mgr.update_player(playerName)
	local player = minetest.get_player_by_name(playerName)
	local nametag = ""
	for modifierName, modifier in ipairs(nametag_mgr.modifiers) do
		local text = player:get_attribute("nametag-modifier-" .. modifierName .. '-text')
		if text then
			local prefix = modifier.prefix
			if prefix then nametag ..= prefix end
			
			nametag ..= text
			
			local suffix = properties.suffix
			if suffix then nametag ..= suffix end
		end
	end
	player:set_nametag_attributes({text = nametag})
end

function nametag_mgr.set_player_modifier_text(playerName, modifierName, text)
	local player = minetest.get_player_by_name(playerName)
	player:set_attribute("nametag-modifier-" .. modifierName .. "-text", text)
	nametag_mgr.update_player(playerName)
end

minetest.register_on_joinplayer(function(player)   -- TODO: Update. Still contains coop_factions version.
    if not player:get_attribute("faction") then
        player:set_attribute("faction", "neutral")
    end

    if type(minetest.deserialize(player:get_attribute("faction"))) == "table" then
       player:set_attribute("faction", "neutral")
    end

    local nick = player:get_attribute("faction")

    if not factions.player_factions[player:get_player_name()] then
        factions.player_factions[player:get_player_name()] = nick
        storage:set_string("player_factions", minetest.serialize(factions.player_factions))
    end

    local x = minetest.deserialize(storage:get_string("faction_color"))

    if not x then
        x = {}

        x[player:get_attribute("faction")] = {
            r = 255,
            b = 255,
            g = 255
        }

        storage:set_string("faction_color", minetest.serialize(x))
    end
    if minetest.settings:get_bool("allow_starting_faction") then
        local colors = x[player:get_attribute("faction")]
        local privs = minetest.get_player_privs(player:get_player_name())
        privs.start_faction = true
        minetest.set_player_privs(player:get_player_name(), privs)
    end

    if nick then
        player:set_nametag_attributes({text = "(" .. nick .. ")" .. " " .. player:get_player_name(), color = colors})
    end
end) 

local function rgb_to_hex(rgb)   -- TODO: Will we need this?
    local hexadecimal = '#'
    for key, fval in ipairs({'r', 'g', 'b'}) do
        local value = tonumber(rgb[fval])
        local hex = ''
        while(value > 0) do
            local index = math.fmod(value, 16) + 1
            value = math.floor(value / 16)
            hex = string.sub('0123456789ABCDEF', index, index) .. hex            
        end

        if(string.len(hex) == 0)then
            hex = '00'

        elseif(string.len(hex) == 1)then
            hex = '0' .. hex
        end

        hexadecimal = hexadecimal .. hex
    end
    return hexadecimal
end

minetest.register_on_chat_message(function(name, message)   -- TODO: Update. Still contains coop_factions version.
    if (minetest.settings:get_bool("no_chat_intercept")) then
        return false
    end
    if (minetest.get_player_by_name(name)) then
        local x = minetest.deserialize(storage:get_string("faction_color"))
        local player = minetest.get_player_by_name(name)
        if not x then
            x = {}

            x[player:get_attribute("faction")] = {
                r = 255,
                b = 255,
                g = 255
            }

            storage:set_string("faction_color", minetest.serialize(x))
        end

        local colors = x[player:get_attribute("faction")]
        minetest.chat_send_all(minetest.get_color_escape_sequence(rgb_to_hex(colors)) .. " [" .. minetest.get_player_by_name(name):get_attribute("faction") .. "]  <".. name .. "> " ..message)
        return true
    else
        return false
    end
end)
