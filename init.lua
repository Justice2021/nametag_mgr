local storage = minetest.get_mod_storage()

nametag_mgr = {}

local function get_modifiers()   -- Load, with on-demand creation.
	local serializedModifiers = storage:get_string("nametag_mgr.modifiers")
	local modifiers = minetest.deserialize(serializedModifiers)
	if not modifiers then
		modifiers = {}
	end
	return modifiers
end

local function set_modifiers(modifiers)   -- Save.
	local serializedModifiers = minetest.serialize(modifiers)
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
end

function nametag_mgr.ensure_modifier_group(modifierName, groupName, color)
	local modifiers = get_modifiers()   -- Load.
	local groups = modifiers[modifierName].groups
	if not groups then groups = {} end
	if not color then color = "#FFFFFF" end
	groups[groupName] = color
	modifiers[modifierName].groups = groups
	set_modifiers(modifiers)   -- Save.
end

function nametag_mgr.set_player_modifier_group(playerName, modifierName, group)
	local player = minetest.get_player_by_name(playerName)
	player:set_attribute("nametag-modifier-"..modifierName.."-group", group)
end

minetest.register_on_chat_message(function(playerName, message)
	if (minetest.settings:get_bool("no_chat_intercept")) then return false end

	local player = minetest.get_player_by_name(playerName)
	if not player then return false end 

	local modifiers = get_modifiers()   -- Load.
	local nameTag = ""
	for modifierName, modifier in pairs(modifiers) do
		local group = player:get_attribute("nametag-modifier-"..modifierName.."-group")
		if group then
			local color = modifier.groups[group]
			local changedColor = false
			if color then
				nameTag = nameTag..minetest.get_color_escape_sequence(color)
				changedColor = true
			end
			local prefix = modifier.prefix
			if prefix then nameTag = nameTag..prefix end

			nameTag = nameTag..group

			local suffix = modifier.suffix
			if suffix then nameTag = nameTag..suffix end
            
			if changedColor then nameTag = nameTag..minetest.get_color_escape_sequence("#ffffff") end
		end
	end

	nameTag = playerName..nameTag..": "

	minetest.chat_send_all(nameTag..message)
	return true
end)
