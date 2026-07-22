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
        const teamColorPlayer = NEUTRAL_STOCK_BUILDINGS.get(unitTypeId).teamColorPlayer;
        if (teamColorPlayer >= 0) {
            SetUnitColor(newUnit, GetPlayerColor(Player(teamColorPlayer)));
        }
    });

    DestroyGroup(group);
}

// By default, team color of a building is inherited from the owner, but some buildings override that (e.g. Tavern is Red, not Grey).
// This is only true when creating a building from the map editor, but if creating via a script it always uses Owner color.
// The color information of a unit is not available at runtime (there is no GetUnitColor()), that is why we store it here.
// teamColorPlayer corresponds to "Art - Team Color" (utco) property of an object.
// -1 means inherit color from the owner. >=0 is a player number, e.g., Player 1 (Red) is 0.
const NEUTRAL_STOCK_BUILDINGS = new Map<number, { teamColorPlayer: number }>([
    // [FourCC("ngol"), { teamColorPlayer: -1 }], // Gold Mine
    [FourCC("ngme"), {teamColorPlayer: -1}], // Goblin Merchant
    // [FourCC("nfoh"), { teamColorPlayer: -1 }], // Fountain of Health
    // [FourCC("nmoo"), { teamColorPlayer: -1 }], // Fountain of Mana
    [FourCC("ngad"), {teamColorPlayer: -1}], // Goblin Laboratory
    // [FourCC("nwgt"), { teamColorPlayer: -1 }], // Way Gate
    [FourCC("ndrk"), {teamColorPlayer: -1}], // Black Dragon Roost
    [FourCC("ndru"), {teamColorPlayer: -1}], // Blue Dragon Roost
    [FourCC("ndrz"), {teamColorPlayer: -1}], // Bronze Dragon Roost
    [FourCC("ndrg"), {teamColorPlayer: -1}], // Green Dragon Roost
    [FourCC("ndro"), {teamColorPlayer: -1}], // Nether Dragon Roost
    [FourCC("ndrr"), {teamColorPlayer: -1}], // Red Dragon Roost
    [FourCC("nmer"), {teamColorPlayer: 0}], // Mercenary Camp (Lordaeron Summer)
    [FourCC("nmr2"), {teamColorPlayer: 12}], // Mercenary Camp (Lordaeron Fall)
    [FourCC("nmr3"), {teamColorPlayer: 1}], // Mercenary Camp (Lordaeron Winter)
    [FourCC("nmr4"), {teamColorPlayer: 11}], // Mercenary Camp (Barrens)
    [FourCC("nmr5"), {teamColorPlayer: 10}], // Mercenary Camp (Ashenvale)
    [FourCC("nmr6"), {teamColorPlayer: 6}], // Mercenary Camp (Felwood)
    [FourCC("nmr7"), {teamColorPlayer: 3}], // Mercenary Camp (Northrend)
    [FourCC("nmr8"), {teamColorPlayer: 9}], // Mercenary Camp (Cityscape)
    [FourCC("nmr9"), {teamColorPlayer: 8}], // Mercenary Camp (Dalaran)
    [FourCC("nmr0"), {teamColorPlayer: 5}], // Mercenary Camp (Village)
    [FourCC("nmra"), {teamColorPlayer: 0}], // Mercenary Camp (Dungeon)
    [FourCC("nmrb"), {teamColorPlayer: 0}], // Mercenary Camp (Underground)
    [FourCC("ntav"), {teamColorPlayer: 0}], // Tavern
    // TODO: Scared to recreate marketplace (there is some initialization code in the maps with them?)
    // [FourCC("nmrk"), { teamColorPlayer: 0 }], // Marketplace
    [FourCC("nmrc"), {teamColorPlayer: 1}], // Mercenary Camp (Sunken Ruins)
    [FourCC("nmrd"), {teamColorPlayer: 9}], // Mercenary Camp (Icecrown Glacier)
    [FourCC("nshp"), {teamColorPlayer: -1}], // Goblin Shipyard
    [FourCC("nmre"), {teamColorPlayer: 12}], // Mercenary Camp (Outland)
    [FourCC("nmrf"), {teamColorPlayer: 3}], // Mercenary Camp (Black Citadel)
]);
