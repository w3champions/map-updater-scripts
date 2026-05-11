# W3CEvents Metrics Reference

All events are emitted through the W3CEvents synchronization system defined in `src/lua/w3cEvents.lua`. Payloads are binary-encoded, checksummed, and sent via `BlzSendSyncData`.

## Shared Default Fields

Unless otherwise noted, every event automatically includes these fields:

| Field | Type | Description |
| --- | --- | --- |
| `player` | int | Player id (0-based) the event is attributed to — see each event for what "attributed to" means |
| `time` | int | Seconds elapsed since game start |
| `sequence` | int | Monotonic event counter for ordering events within a flush window |

## Name Fields

All `name`, `hero`, `item`, `ability`, `skill`, `building`, `unit`, and similar string fields contain English names resolved at compile time from a static dictionary built from `war3-objectdata-th` constants. Runtime localization natives (`GetUnitName`, `GetItemName`, `GetObjectName`) are not used. Unknown type ids fall back to their 4-character FourCC string (e.g. `"hpea"`).

---

## Match Setup

### PlayerDetails

Emitted once per playing player at map initialization.

Does **not** include shared default fields — all fields are explicit.

| Field | Type | Description |
| --- | --- | --- |
| `player` | int | Player id |
| `sequence` | int | Event sequence number |
| `name` | string | Player display name |
| `race` | string | `"human"`, `"orc"`, `"undead"`, `"nightelf"`, or `"other"` |
| `team` | int | Team index |
| `startLocationId` | int | Start location slot index |
| `startX` | float | X coordinate of start location |
| `startY` | float | Y coordinate of start location |

**Source:** `metrics.ts` `initMetrics()`

---

## Economy

### PlayerState

Emitted every 5 seconds for each playing player. Snapshot of current resource values — deltas must be computed by the analytics service between consecutive snapshots.

**`player`** = resource owner

| Field | Type | Description |
| --- | --- | --- |
| `gold` | int | Current gold |
| `gold_upkeep` | int | Gold upkeep rate |
| `wood` | int | Current lumber |
| `wood_upkeep` | int | Lumber upkeep rate |
| `food_cap` | int | Food capacity |
| `food_used` | int | Food used |

**Source:** `playerState.ts`

---

## Unit Production

### UnitStarted / UnitCancelled / UnitTrained

Emitted when a unit training begins, is cancelled, or completes.

**`player`** = owner of the training building

| Field | Type | Description |
| --- | --- | --- |
| `name` | string | English unit name |
| `typeId` | int | Unit type id |
| `unitType` | string | `"hero"` or `"unit"` |
| `x` | float | On `UnitStarted`/`UnitCancelled`: position of the training building. On `UnitTrained`: position of the trained unit |
| `y` | float | See `x` |

**Source:** `playerUnits.ts` — `EVENT_PLAYER_UNIT_TRAIN_START/CANCEL/FINISH`

> **Validation needed:** Whether `GetTriggerUnit()` on TRAIN_FINISH and TRAIN_CANCEL identifies the training structure or the trained unit is unconfirmed. Current implementation uses `GetTrainedUnit()` for FINISH/CANCEL, which gives the unit position, not the building position.

---

## Buildings and Upgrades

### StructureStart / StructureCancel / StructureBuilt

Emitted when a building begins construction, is cancelled, or finishes.

**`player`** = building owner

| Field | Type | Description |
| --- | --- | --- |
| `name` | string | English building name |
| `typeId` | int | Structure type id |
| `unitType` | string | Always `"structure"` |
| `x` | float | Building position |
| `y` | float | Building position |

**Source:** `playerBuildings.ts` — `EVENT_PLAYER_UNIT_CONSTRUCT_START/CANCEL/FINISH`

### UpgradeStart / UpgradeCancel / UpgradeComplete

Emitted when a building upgrade begins, is cancelled, or finishes. Same fields as structure events.

**`player`** = building owner

| Field | Type | Description |
| --- | --- | --- |
| `name` | string | English name of the upgraded building |
| `typeId` | int | Structure type id after upgrade |
| `unitType` | string | Always `"structure"` |
| `x` | float | Building position |
| `y` | float | Building position |

**Source:** `playerBuildings.ts` — `EVENT_PLAYER_UNIT_UPGRADE_START/CANCEL/FINISH`

---

## Research

### ResearchStart / ResearchCancel / ResearchComplete

Emitted when a player begins, cancels, or completes a research/upgrade.

**`player`** = researching player

| Field | Type | Description |
| --- | --- | --- |
| `name` | string | English research name |
| `researchId` | int | Research type id |
| `building` | string | English name of the researching building |
| `buildingTypeId` | int | Researching building type id |
| `buildingX` | float | Researching building position |
| `buildingY` | float | Researching building position |

**Source:** `research.ts` — `EVENT_PLAYER_UNIT_RESEARCH_START/CANCEL/FINISH`

---

## Hero Progression

### HeroLevel

Emitted when a hero gains a level.

**`player`** = hero owner

| Field | Type | Description |
| --- | --- | --- |
| `hero` | string | English hero name |
| `heroTypeId` | int | Hero type id |
| `level` | int | New hero level |
| `x` | float | Hero position |
| `y` | float | Hero position |

**Source:** `heroes.ts` — `EVENT_PLAYER_HERO_LEVEL`

### HeroSkill

Emitted when a hero learns or levels up a skill.

**`player`** = hero owner

| Field | Type | Description |
| --- | --- | --- |
| `hero` | string | English hero name |
| `heroTypeId` | int | Hero type id |
| `heroLevel` | int | Hero level at time of skill learn |
| `skill` | string | English ability name |
| `skillId` | int | Learned ability id |
| `skillLevel` | int | New skill level |
| `x` | float | Hero position |
| `y` | float | Hero position |

**Source:** `heroes.ts` — `EVENT_PLAYER_HERO_SKILL`

### HeroXp

Emitted after a unit death when a hero's XP changes. Delayed 0.1 seconds to capture XP granted after the kill. Emitted for each hero of the killing player that gained XP.

**`player`** = hero owner

| Field | Type | Description |
| --- | --- | --- |
| `name` | string | English hero name |
| `heroTypeId` | int | Hero type id |
| `xp` | int | Total XP after the gain |
| `source` | string | `"creep"` (killed a neutral unit) or `"opponent"` (killed a player unit) |
| `sourcePlayer` | int | Player id of the killed unit's owner, or `-1` for creeps |

**Source:** `unitDeaths.ts` — delayed after `EVENT_PLAYER_UNIT_DEATH`

### HeroReviveStart / HeroReviveCancel / HeroReviveFinish

Emitted at each stage of hero revival at an altar or tavern.

**`player`** = hero owner

| Field | Type | Description |
| --- | --- | --- |
| `hero` | string | English hero name |
| `heroTypeId` | int | Hero type id |
| `x` | float | On `Start`/`Cancel`: position of the revive structure. On `Finish`: hero spawn position |
| `y` | float | See `x` |

**Source:** `heroRevive.ts` — `EVENT_PLAYER_HERO_REVIVE_START/CANCEL/FINISH`

> **Validation needed:** Whether `GetTriggerUnit()` returns the reviving structure (altar/tavern) or the hero for START and CANCEL events is unconfirmed. The `x`/`y` position on START/CANCEL uses `GetTriggerUnit()` as the position source.

---

## Hero Items

All hero item events share a common base: `hero`, `heroTypeId`, `item`, `itemTypeId`, `x`, `y`.

### HeroItemPickup

Emitted when a hero picks up an item (from the ground, a crate, or a creep drop).

**`player`** = hero owner

| Field | Type | Description |
| --- | --- | --- |
| `hero` | string | English hero name |
| `heroTypeId` | int | Hero type id |
| `item` | string | English item name |
| `itemTypeId` | int | Item type id |
| `slot` | int | Inventory slot index (0-based) |
| `x` | float | Hero position |
| `y` | float | Hero position |

**Source:** `heroes.ts` — `EVENT_PLAYER_UNIT_PICKUP_ITEM`

### HeroItemDrop

Emitted when a hero drops an item onto the ground.

**`player`** = hero owner

| Field | Type | Description |
| --- | --- | --- |
| `hero` | string | English hero name |
| `heroTypeId` | int | Hero type id |
| `item` | string | English item name |
| `itemTypeId` | int | Item type id |
| `x` | float | Hero position |
| `y` | float | Hero position |

**Source:** `heroes.ts` — `EVENT_PLAYER_UNIT_DROP_ITEM`

### HeroItemBought

Emitted when a hero buys an item from a shop.

**`player`** = hero owner (buyer)

| Field | Type | Description |
| --- | --- | --- |
| `hero` | string | English hero name |
| `heroTypeId` | int | Hero type id |
| `item` | string | English item name |
| `itemTypeId` | int | Item type id |
| `x` | float | Hero position |
| `y` | float | Hero position |
| `shopName` | string | English name of the selling shop unit |
| `shopTypeId` | int | Shop unit type id |
| `shopX` | float | Shop position |
| `shopY` | float | Shop position |

**Source:** `heroes.ts` — `EVENT_PLAYER_UNIT_SELL_ITEM` via `GetSellingUnit()`

### HeroItemSold

Emitted when a hero pawns (sells) an item to a shop.

**`player`** = hero owner (seller)

| Field | Type | Description |
| --- | --- | --- |
| `hero` | string | English hero name |
| `heroTypeId` | int | Hero type id |
| `item` | string | English item name |
| `itemTypeId` | int | Item type id |
| `x` | float | Hero position |
| `y` | float | Hero position |
| `shopName` | string | English name of the buying shop unit |
| `shopTypeId` | int | Shop unit type id |
| `shopX` | float | Shop position |
| `shopY` | float | Shop position |

**Source:** `heroes.ts` — `EVENT_PLAYER_UNIT_PAWN_ITEM` via `GetBuyingUnit()`

> **Validation needed:** Whether `GetBuyingUnit()` correctly identifies the pawn shop in `EVENT_PLAYER_UNIT_PAWN_ITEM` context is unconfirmed. Shop fields may be zero/empty if the native does not apply here.

### HeroItemUse

Emitted when a hero activates a charged or usable item.

**`player`** = hero owner

| Field | Type | Description |
| --- | --- | --- |
| `hero` | string | English hero name |
| `heroTypeId` | int | Hero type id |
| `item` | string | English item name |
| `itemTypeId` | int | Item type id |
| `heroX` | float | Hero position at cast time |
| `heroY` | float | Hero position at cast time |
| `targetX` | float | Target position (or target unit's position) |
| `targetY` | float | Target position (or target unit's position) |
| `targetTypeId` | int | Target unit type id, or `0` if no unit target |
| `target` | string | English name of target unit, or `""` if no unit target |
| `targetPlayer` | int | Target unit owner player id, or `-1` if no unit target |

**Source:** `heroes.ts` — `EVENT_PLAYER_UNIT_USE_ITEM`

---

## Deaths

### StructureDeath / WorkerDeath / UnitDeath / CreepDeny

Emitted when a player-owned structure, worker, or unit dies. `CreepDeny` fires when a neutral unit kills another neutral unit.

**`player`** = dying unit's owner (for `CreepDeny`: the denying neutral's player id)

| Field | Type | Description |
| --- | --- | --- |
| `name` | string | English name of the dying unit |
| `typeId` | int | Dying unit type id |
| `level` | int | Unit level (hero level for heroes) |
| `isHero` | bool | Whether the dying unit is a hero |
| `pointValue` | int | Unit point value (object-editor bounty proxy) |
| `x` | float | Position at time of death |
| `y` | float | Position at time of death |
| `killerPlayer` | int | Killer's player id, or `-1` if killed by environment/no unit |
| `killerTypeId` | int | Killer unit type id, or `0` if no killer unit |
| `killerUnitName` | string | Static English name for the killer unit type, or empty if no killer unit |
| `killerX` | float | Killer unit position at time of kill, or `0` |
| `killerY` | float | Killer unit position at time of kill, or `0` |

**Source:** `unitDeaths.ts` — `EVENT_PLAYER_UNIT_DEATH`

### CreepKill

Emitted when a player-owned unit kills a neutral (creep) unit.

**`player`** = killing player

| Field | Type | Description |
| --- | --- | --- |
| `name` | string | English name of the killed creep |
| `typeId` | int | Creep type id |
| `level` | int | Creep level |
| `pointValue` | int | Creep point value |
| `x` | float | Creep position at death |
| `y` | float | Creep position at death |
| `killingUnit` | string | English name of the killing unit |
| `killingTypeId` | int | Killing unit type id |
| `killerX` | float | Killing unit position at time of kill |
| `killerY` | float | Killing unit position at time of kill |

**Source:** `unitDeaths.ts` — `EVENT_PLAYER_UNIT_DEATH` (filtered to neutral dying units)

---

## Unit Lifecycle

### UnitSummoned

Emitted when a player-owned unit summons another unit. Neutral summoners are filtered out.

**`player`** = summoning player

| Field | Type | Description |
| --- | --- | --- |
| `summoner` | string | English name of the summoning unit |
| `summonerTypeId` | int | Summoner type id |
| `summonerX` | float | Summoner position |
| `summonerY` | float | Summoner position |
| `summoned` | string | English name of the summoned unit |
| `summonedTypeId` | int | Summoned unit type id |
| `summonedX` | float | Summoned unit spawn position |
| `summonedY` | float | Summoned unit spawn position |

**Source:** `unitLifecycle.ts` — `EVENT_PLAYER_UNIT_SUMMON`

### UnitOwnerChanged

Emitted when a unit changes ownership (e.g. Banshee charm, Doom enslave). Only emits when at least one side (old or new owner) is a playing player.

**`player`** = new owner

| Field | Type | Description |
| --- | --- | --- |
| `unit` | string | English unit name |
| `typeId` | int | Unit type id |
| `x` | float | Unit position at time of change |
| `y` | float | Unit position at time of change |
| `previousOwner` | int | Previous owner player id |
| `newOwner` | int | New owner player id (same as `player`) |

**Source:** `unitLifecycle.ts` — `EVENT_PLAYER_UNIT_CHANGE_OWNER`

### UnitSold

Emitted when a player purchases a unit from a shop (mercenary camp, lab, tavern, neutral building). Only emits when the buyer is a playing player.

**`player`** = buyer

| Field | Type | Description |
| --- | --- | --- |
| `soldUnit` | string | English name of the purchased unit |
| `soldTypeId` | int | Purchased unit type id |
| `soldX` | float | Purchased unit spawn position |
| `soldY` | float | Purchased unit spawn position |
| `shopName` | string | English name of the selling shop unit |
| `shopTypeId` | int | Shop unit type id |
| `shopX` | float | Shop position |
| `shopY` | float | Shop position |
| `buyerPlayer` | int | Buyer player id (same as `player`) |

**Source:** `unitLifecycle.ts` — `EVENT_PLAYER_UNIT_SELL`

---

## Ability Usage

### SpellEvent

Emitted when a **hero** casts an ability. Only fires for heroes of playing players. Unit spell tracking is deferred pending event volume testing.

**`player`** = casting player

| Field | Type | Description |
| --- | --- | --- |
| `caster` | string | English hero name |
| `casterTypeId` | int | Hero type id |
| `casterX` | float | Hero position at cast time |
| `casterY` | float | Hero position at cast time |
| `abilityId` | int | Ability id |
| `ability` | string | English ability name |
| `targetTypeId` | int | Target unit type id, or `0` if no unit target |
| `target` | string | English name of target unit, or `""` if no unit target |
| `targetPlayer` | int | Target unit owner player id, or `-1` if no unit target |
| `targetX` | float | Spell target position |
| `targetY` | float | Spell target position |

**Source:** `spellEvents.ts` — `EVENT_PLAYER_UNIT_SPELL_CAST` (hero condition)

---

## Economy and Mining

### WorkerMineSnapshot

Emitted every 5 seconds for each (player, mine) pair where the player has at least one worker within 500 game units of the mine. Gold mine positions are extracted from the map file at compile time.

Worker count uses `GroupEnumUnitsInRange` with a filter callback (no `FirstOfGroup`) — the count is deterministic because synchronized unit positions guarantee every client finds the same set of workers. The undead haunted mine transformation (`ngol` → `ugol`) is handled by re-discovering the mine unit handle when the previously cached handle becomes invalid.

**`player`** = worker owner

| Field | Type | Description |
| --- | --- | --- |
| `mineTypeId` | int | Mine unit type id at emission time (e.g. `ugol` if haunted) |
| `mineName` | string | English mine name (`"Gold Mine"` or `"Haunted Gold Mine"`) |
| `mineX` | float | Mine map position (compile-time constant) |
| `mineY` | float | Mine map position (compile-time constant) |
| `resourceAmount` | int | Current gold remaining in the mine |
| `workerCount` | int | Number of this player's workers within 500 units of the mine |

**Source:** `workerMineSnapshot.ts` — `W3CEvents.track` every 5 seconds

---

## Combat

### CombatStart

Emitted the instant the first player-vs-player damage occurs after a gap of 5 or more seconds with no PvP damage between the same two players. Gives an exact fight start timestamp.

**`player`** = attacking player

| Field | Type | Description |
| --- | --- | --- |
| `targetPlayer` | int | Player being attacked |
| `sourceCategory` | string | `"hero"`, `"unit"`, or `"worker"` |
| `sourceTypeId` | int | Attacking unit type id |
| `sourceName` | string | Static English name for the attacking unit type |
| `sourceX` | float | Attacker position |
| `sourceY` | float | Attacker position |
| `targetCategory` | string | `"hero"`, `"unit"`, `"worker"`, or `"structure"` |
| `targetTypeId` | int | Attacked unit type id |
| `targetName` | string | Static English name for the attacked unit type |
| `targetX` | float | Target position |
| `targetY` | float | Target position |

**Source:** `combatSummary.ts` — `EVENT_PLAYER_UNIT_DAMAGED` (first PvP damage after gap)

### CombatEnd

Emitted approximately 1 second after the last player-vs-player damage between a given pair of players. Checked by a 1-second polling timer. Gives an approximate fight end timestamp (±1 second of actual last damage).

**`player`** = attacking player (same as the `CombatStart` that opened this fight)

| Field | Type | Description |
| --- | --- | --- |
| `targetPlayer` | int | Player that was being attacked |

**Source:** `combatSummary.ts` — 1-second polling timer

### CombatSummary

Emitted every 5 seconds. Records delta damage (since the previous tick, not cumulative) grouped by source player × target player × source unit category × target unit category × source unit type × target unit type. Multiple rows per tick are normal when fights involve mixed armies and heroes.

Replaces `HeroDamage`. The analytics service can reconstruct lifetime unit or hero damage totals by summing `CombatSummary` rows filtered to the relevant source or target type id.

**`player`** = attacking player (source)

| Field | Type | Description |
| --- | --- | --- |
| `targetPlayer` | int | Player whose units took damage; `-1` for creep/neutral targets |
| `sourceCategory` | string | `"hero"`, `"unit"`, or `"worker"` |
| `targetCategory` | string | `"hero"`, `"unit"`, `"worker"`, `"structure"`, or `"creep"` |
| `sourceTypeId` | int | Attacking unit type id |
| `sourceName` | string | Static English name for the attacking unit type |
| `targetTypeId` | int | Target unit type id |
| `targetName` | string | Static English name for the target unit type |
| `damage` | float | Total damage dealt in this 5-second window |
| `eventCount` | int | Number of individual damage events in this window |
| `sourceX` | float | Centroid of attacking unit positions (weighted by damage event count) |
| `sourceY` | float | Centroid of attacking unit positions |
| `targetX` | float | Centroid of target unit positions |
| `targetY` | float | Centroid of target unit positions |

**Source:** `combatSummary.ts` — `W3CEvents.track` every 5 seconds

**Fight detection:** Pair `CombatStart`/`CombatEnd` events by `(player, targetPlayer)` to get fight windows. Filter `CombatSummary` rows to those windows for damage breakdown and position centroids. Cross-reference death events within the window for casualties.

---

## Game End

### W3CGameEnd

Emitted once per playing player when the game ends, via `W3CEvents.end_game`. This event is handled internally by W3CEvents and uses its own schema (not included in `metricSchemas`).

| Field | Type | Description |
| --- | --- | --- |
| `player` | int | Player id |
| `time` | int | Game time at end |
| `sequence` | int | Event sequence number |
| `player_won` | bool | Whether this player won |

**Source:** `gameEnd.ts` — `EVENT_PLAYER_VICTORY`, `EVENT_PLAYER_DEFEAT`, `EVENT_GAME_END_LEVEL`, `EVENT_GAME_VICTORY`

---

## Implementation Notes

### Emission Cadence

| Type | Interval | Events |
| --- | --- | --- |
| Periodic (every 5s) | `W3CEvents.track(..., 1)` | `PlayerState`, `CombatSummary`, `WorkerMineSnapshot` |
| Event-driven | Trigger callbacks | All other events |
| Hybrid | 1-second polling timer | `CombatEnd` |

### Sync Safety

All payload values are derived from synchronized game state only. Local-only data (`GetLocalPlayer()`, local camera, local selection, local visibility) is never emitted. Name fields are resolved at compile time from a static English dictionary — `GetUnitName`, `GetItemName`, and `GetObjectName` are not called at runtime.

`WorkerMineSnapshot` uses `GroupEnumUnitsInRange` with a filter callback to count workers. The count is deterministic because synchronized unit positions guarantee every client finds the same set of units, even if the internal enumeration order differs between clients.

### Source Files

| File | Responsibility |
| --- | --- |
| `schemas.ts` | All schema definitions |
| `metrics.ts` | Initialization, `PlayerDetails` emission, tracker wiring |
| `playerState.ts` | `PlayerState` |
| `playerUnits.ts` | `UnitStarted`, `UnitCancelled`, `UnitTrained` |
| `playerBuildings.ts` | `StructureStart/Cancel/Built`, `UpgradeStart/Cancel/Complete` |
| `research.ts` | `ResearchStart/Cancel/Complete` |
| `heroes.ts` | `HeroLevel`, `HeroSkill`, all `HeroItem*` events |
| `heroRevive.ts` | `HeroReviveStart/Cancel/Finish` |
| `unitDeaths.ts` | `StructureDeath`, `WorkerDeath`, `UnitDeath`, `CreepKill`, `CreepDeny`, `HeroXp` |
| `unitLifecycle.ts` | `UnitSummoned`, `UnitOwnerChanged`, `UnitSold` |
| `spellEvents.ts` | `SpellEvent` |
| `workerMineSnapshot.ts` | `WorkerMineSnapshot` |
| `combatSummary.ts` | `CombatStart`, `CombatEnd`, `CombatSummary` |
| `gameEnd.ts` | `W3CGameEnd` |
| `objectNames.ts` | Compile-time English name lookup tables |
