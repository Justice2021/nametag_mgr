# Name-tag--Manager Mod for Minetest
Allows multiple mods to modify name-tag attributes, without conflicting.

## Usage
Update all mods which call player.set_nametag_attributes() to:
- Register themselves: nametag_mgr.ensure_modifier("&lt;mod>", "&lt;pfx>", "&lt;sfx>")
- Add groups, colors: nametag_mgr.ensure_modifier_group("&lt;mod>", "&lt;grp>"[, "&lt;color>"])
- Set a players' group: nametag_mgr.set_player_modifier_group("&lt;plyr>", "&lt;mod>", "&lt;grp>")
- No longer call set_nametag_attributes().
