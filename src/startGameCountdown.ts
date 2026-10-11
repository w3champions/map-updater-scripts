import {Timer} from "w3ts";
import {pauseClockW3C} from "./player_features/clock";

const COUNTDOWN_START = 5;
const COUNTDOWN_SOUND = CreateSound("Sound\\Interface\\BattleNetTick.wav", false, false, false, 10, 10, "",);

export function enableStartGameCountdown() {
    pauseGameW3C(true);

    for (let count = COUNTDOWN_START; count >= 0; count--) {
        // This is a workaround for Lua.
        // Passing `count` directly to the callback results in passing a reference that will be 0 at execution time.
        const cc = count;
        Timer.create().start(COUNTDOWN_START - count, false, () => onCountdown(cc));
    }
}

function onCountdown(count: number) {
    if (count === 0) {
        ClearTextMessages();
        recreateNeutralStockBuildings();
        pauseGameW3C(false);
        return;
    }

    print(`|cff00ff00[W3C]:|r Starting in ${count}...`);
    StartSound(COUNTDOWN_SOUND);
}

function pauseGameW3C(pause: boolean) {
    PauseAllUnitsBJ(pause);
    SuspendTimeOfDay(pause);
    pauseClockW3C(pause);
}

// Recreating tavern/shop/merc resets initial stock cooldown delay for heroes/items/units in them
function recreateNeutralStockBuildings() {
    const group = CreateGroup();

    GroupEnumUnitsOfPlayer(group, Player(PLAYER_NEUTRAL_PASSIVE), null);

    ForGroup(group, () => {
        const unit = GetEnumUnit();
        const unitTypeId = GetUnitTypeId(unit);

        if (!NEUTRAL_STOCK_BUILDINGS.has(unitTypeId)) {
            return;
        }

        const unitX = GetUnitX(unit);
        const unitY = GetUnitY(unit);
        const unitFacing = GetUnitFacing(unit);

        RemoveUnit(unit);

        const newUnit = CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE), unitTypeId, unitX, unitY, unitFacing);
        const teamColorPlayer = NEUTRAL_STOCK_BUILDINGS.get(unitTypeId);
        if (teamColorPlayer >= 0) {
            SetUnitColor(newUnit, GetPlayerColor(Player(teamColorPlayer)));
        }
    });

    DestroyGroup(group);
}

// Key: unitTypeId, Value: teamColorPlayer (-1 means inherit color from the owner. >=0 is a player number, e.g., Player 1 (Red) is 0)
// teamColorPlayer corresponds to "Art - Team Color" (utco) property of an object.
//
// By default, team color of a building is inherited from the owner, but some buildings override that (e.g. Tavern is Red, not Grey).
// TeamColor property is not respected when creating a unit from a script (it only works when placing a unit from an editor).
// Also, there is no `GetUnitColor()` like API, that is why we have to store it here.
const NEUTRAL_STOCK_BUILDINGS = new Map<number, number>([
    // [FourCC("ngol"), -1 ], // Gold Mine
    [FourCC("ngme"), -1], // Goblin Merchant
    // [FourCC("nfoh"), -1 ], // Fountain of Health
    // [FourCC("nmoo"), -1 ], // Fountain of Mana
    [FourCC("ngad"), -1], // Goblin Laboratory
    // [FourCC("nwgt"), -1 ], // Way Gate
    [FourCC("ndrk"), -1], // Black Dragon Roost
    [FourCC("ndru"), -1], // Blue Dragon Roost
    [FourCC("ndrz"), -1], // Bronze Dragon Roost
    [FourCC("ndrg"), -1], // Green Dragon Roost
    [FourCC("ndro"), -1], // Nether Dragon Roost
    [FourCC("ndrr"), -1], // Red Dragon Roost
    [FourCC("nmer"), 0], // Mercenary Camp (Lordaeron Summer)
    [FourCC("nmr2"), 12], // Mercenary Camp (Lordaeron Fall)
    [FourCC("nmr3"), 1], // Mercenary Camp (Lordaeron Winter)
    [FourCC("nmr4"), 11], // Mercenary Camp (Barrens)
    [FourCC("nmr5"), 10], // Mercenary Camp (Ashenvale)
    [FourCC("nmr6"), 6], // Mercenary Camp (Felwood)
    [FourCC("nmr7"), 3], // Mercenary Camp (Northrend)
    [FourCC("nmr8"), 9], // Mercenary Camp (Cityscape)
    [FourCC("nmr9"), 8], // Mercenary Camp (Dalaran)
    [FourCC("nmr0"), 5], // Mercenary Camp (Village)
    [FourCC("nmra"), 0], // Mercenary Camp (Dungeon)
    [FourCC("nmrb"), 0], // Mercenary Camp (Underground)
    [FourCC("ntav"), 0], // Tavern
    // TODO: Scared to recreate marketplace (there is some initialization code in the maps with them?)
    // [FourCC("nmrk"), 0 ], // Marketplace
    [FourCC("nmrc"), 1], // Mercenary Camp (Sunken Ruins)
    [FourCC("nmrd"), 9], // Mercenary Camp (Icecrown Glacier)
    [FourCC("nshp"), -1], // Goblin Shipyard
    [FourCC("nmre"), 12], // Mercenary Camp (Outland)
    [FourCC("nmrf"), 3], // Mercenary Camp (Black Citadel)
]);
