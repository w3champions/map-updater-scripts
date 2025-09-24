# Short summary

Creep loot information is taken from inside a map file (`war3mapUnits.doo`).

The indicator is a WC3 Special Effect, which we manually move every 0.01 seconds.
To properly position indicator over the health bar, we use per-model height data extracted from in-game files
([unit-model-height-data.json](../../../scripts/loot-indicator/model-heights/unit-model-height-data.json),
for more details see https://github.com/Psimage/wc3-drop-indicator-poc)

Preview UI is a WC3 Frame drawn on top of Command Bar.
To display possible loot drops, we use runtime item info, combined with item data extracted from in-game files 
(unavailable at runtime, [extracted-items-data.json](../../../scripts/loot-indicator/items-db/extracted-items-data.json))

# Thanks to

Coff, Mayday, Tasyen, ModdieMads, Kenshin, TriggerHappy, Luashine, Tordes, Starbuck!

And a lot of other people from W3Champions and Hive communities!
