local storage = minetest.get_mod_storage()

nametag_mgr = {debugging = false}

local function debug(message)
    if not nametag_mgr.debugging then return end
    minetest.chat_send_all("nametag_mgr debug: "..message)
end

local function get_modifiers()   -- Load, with on-demand creation.
    local serializedModifiers = storage:get_string("nametag_mgr.modifiers")
    debug("Serialized modifiers loaded: "..serializedModifiers)
	local modifiers = minetest.deserialize(serializedModifiers)
	if not modifiers then
        debug("No modifiers found. Initializing to empty list.")
        modifiers = {}
    end
	return modifiers
end

local function set_modifiers(modifiers)   -- Save.
    local serializedModifiers = minetest.serialize(modifiers)
    debug("Saving serializedModifiers: "..serializedModifiers)
	storage:set_string("nametag_mgr.modifiers", serializedModifiers)
end

function nametag_mgr.ensure_modifier(modifierName, prefix, suffix)
	local modifiers = get_modifiers()   -- Load.
    local modifier = modifiers[modifierName]
    if not modifier then
        modifier = {prefix = "", suffix = "", groups = {}}
    end
	modifier.prefix = prefix
    modifier.suffix = suffix
    modifiers[modifierName] = modifier
	set_modifiers(modifiers)   -- Save.
    debug("Ensured modifier, "..modifierName..', with prefix, "'..prefix..'", and suffix, "'..suffix..'".')
end

function nametag_mgr.ensure_modifier_group(modifierName, groupName, color)
	local modifiers = get_modifiers()   -- Load.
    local groups = modifiers[modifierName].groups
    if not groups then groups = {} end
    if not color then color = "#FFFFFF" end
    groups[groupName] = color
    modifiers[modifierName].groups = groups
	set_modifiers(modifiers)   -- Save.
    debug("Added group, "..groupName..", to modifier, "..modifierName..", with color, "..color..".")
end

function nametag_mgr.set_player_modifier_group(playerName, modifierName, group)
	local player = minetest.get_player_by_name(playerName)
	player:set_attribute("nametag-modifier-"..modifierName.."-group", group)
    debug("Set "..playerName.."'s "..modifierName.." group to "..group..".")
end

minetest.register_on_chat_message(function(playerName, message)
    if (minetest.settings:get_bool("no_chat_intercept")) then
        debug("Skipping chat interception.")
        return false
    end
    debug("Intercepting chat.")

    debug("Chatting player: "..playerName)
    local player = minetest.get_player_by_name(playerName)
    if not player then
        debug("Player not found with get_player_by_name.")
        return false
    end
    debug("Player found with get_player_by_name.")

	local modifiers = get_modifiers()   -- Load.
    local nameTag = ""
    for modifierName, modifier in pairs(modifiers) do
        debug("Checking modifier, "..modifierName..":")
        for key, value in pairs(modifier) do
            if type(value) == "table" then value = "(table)" end
            debug("    "..key..": "..value)
        end
        local group = player:get_attribute("nametag-modifier-"..modifierName.."-group")
        if group then
            debug("Player, "..playerName.."'s "..modifierName.." group: "..group)

            local color = modifier.groups[group]
            local changedColor = false
            if color then
                debug("color: "..color)
                nameTag = nameTag..minetest.get_color_escape_sequence(color)
                changedColor = true
            else
                debug("No color.")
            end

            local prefix = modifier.prefix
            if prefix then nameTag = nameTag..prefix end

            nameTag = nameTag..group

            local suffix = modifier.suffix
            if suffix then nameTag = nameTag..suffix end
            
            if changedColor then nameTag = nameTag..minetest.get_color_escape_sequence("#ffffff") end
        else
            debug("Player, "..playerName..", does not have a "..modifierName.." modifier.")
        end
    end

    debug("nameTag: "..nameTag)
    nameTag = playerName..nameTag..": "

    debug("Sending chat message.")
    minetest.chat_send_all(nameTag..message)
    return true
end)
