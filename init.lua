local storage = minetest.get_mod_storage()

nametag_mgr = {}

-- Magic strings, so called {
	local modsKey = "nametag_mgr.mods"
	local white = "#FFFFFF"
	local groupAttributePrefix = "nametag-mod-"
	local groupAttributeSuffix = "-group"
-- } Magic strings, so called

local function get_mods()   -- Load mods that have registered themselves with us, with on-demand creation.
	local serializedMods = storage:get_string(modsKey)
	local mods = minetest.deserialize(serializedMods)
	if not mods then return {} end
	return mods
end

local function set_mods(mods)   -- Save mods that have registered themselves with us.
	local serializedMods = minetest.serialize(mods)
	storage:set_string(modsKey, serializedMods)
end

function nametag_mgr.register_mod(modName, prefix, suffix)
	local mods = get_mods()   -- Load.
	local mod = mods[modName]
	if mod then
		mod.prefix = prefix
		mod.suffix = suffix
	else mod = {prefix = prefix, suffix = suffix, groups = {}} end
	mods[modName] = mod
	set_mods(mods)   -- Save.
end

function nametag_mgr.register_mod_group(modName, groupName, colour)
	local mods = get_mods()   -- Load.
	local groups = mods[modName].groups
	if not groups then groups = {} end   -- Initialize to empty group list for this mod.
	if not colour then colour = white end   -- Default group colour to white.
	groups[groupName] = colour   -- Set this group's colour.
	mods[modName].groups = groups   -- Reassign this groups list into the mod.
	set_mods(mods)   -- Save.
end

function nametag_mgr.set_player_mod_group(player, modName, groupName)
	if type(player) == "string" then player = minetest.get_player_by_name(player) end
	if not player then return false, "Player not found." end
	player:set_attribute(groupAttributePrefix..modName..groupAttributeSuffix, groupName)
	return true
end

minetest.register_on_chat_message(function(playerName, message)
	if (minetest.settings:get_bool("no_chat_intercept")) then return false end

	local player = minetest.get_player_by_name(playerName)
	if not player then return false end   -- This shouldn't be possible, but just in case...

	local mods = get_mods()   -- Load.
	local nameTag = ""
	for modName, mod in pairs(mods) do
		local group = player:get_attribute(groupAttributePrefix..modName..groupAttributeSuffix)
		if group then
			local colour = mod.groups[group]
			local changedColour = false
			if colour then
				nameTag = nameTag..minetest.get_color_escape_sequence(colour)
				changedColour = true
			end
			local prefix = mod.prefix
			if prefix then nameTag = nameTag..prefix end

			nameTag = nameTag..group

			local suffix = mod.suffix
			if suffix then nameTag = nameTag..suffix end

			if changedColour then nameTag = nameTag..minetest.get_color_escape_sequence(white) end
		end
	end

	nameTag = playerName..nameTag..": "

	minetest.chat_send_all(nameTag..message)
	return true
end)
