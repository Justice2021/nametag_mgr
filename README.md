# Name-tag Manager Mod for Minetest
A mod that allows multiple mods which modify name-tag attributes to peacefully coexist. (No more "dueling banjos".)

## Usage:
Update all mods which call player.set_nametag_attributes() to:
	(1) Register their order, prefix, and suffix, by calling configure_nametag(mod_name: string, order: number, prefix, suffix); and
	(2) Call player.set_nametag_attribute(mod_name, text, color), instead of player.set_nametag_attributes().

## Caveats
- (None yet.)
