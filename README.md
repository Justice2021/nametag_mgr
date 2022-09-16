# Name-tag--Manager Mod for Minetest
Allows multiple mods to modify name-tag attributes, without conflicting.

## Usage
Update all mods which call player.set_nametag_attributes() as follows:
- Register itself: nametag_mgr.register_mod("&lt;mod>", "&lt;pfx>", "&lt;sfx>")
- Add groups, colors: nametag_mgr.register_mod_group("&lt;mod>", "&lt;grp>"[, "&lt;color>"])
- Set a players' group: nametag_mgr.set_player_mod_group("&lt;plyr>", "&lt;mod>", "&lt;grp>")
- Remove calls to set_nametag_attributes(), and let nametag_mgr manage the colors.
