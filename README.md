# Name-tag Manager Mod for Minetest
A mod that allows multiple mods which modify name-tag attributes to peacefully coexist. (No more "dueling banjos".)

## Usage
Update all mods which call player.set_nametag_attributes() to:
- Register themselves, by adding a named, {prefix = ?, suffix = ?, color = ?} table to the "nametag_mgr_modifiers" storage string; and
- Call nametag_mgr.set_player_text(playerName, modifierName, text), instead of player.set_nametag_attributes().

## Caveats
- Only one nametag modifier (the last one added to the "nametag_mgr_modifiers" storage string) will win out on setting the nametag color.
