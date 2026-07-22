import {color, Timer} from "w3ts";
import {pauseClockW3C} from "./player_features/clock";
import {Units} from "@objectdata/units";

const COUNTDOWN_START = 10;
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
    interface NeutralBuildingData {
        unitTypeId: number;
        x: number;
        y: number;
        facing: number;
        color: number;
    }

    function isNeutralStockBuilding(unitTypeId: number): boolean {
        return unitTypeId === FourCC(Units.Tavern)
            || unitTypeId === FourCC(Units.GoblinMerchant)
            || unitTypeId === FourCC(Units.Marketplace)
            || unitTypeId === FourCC(Units.GoblinLaboratory)
            || unitTypeId === FourCC(Units.MercenaryCampAshenvale)
            || unitTypeId === FourCC(Units.MercenaryCampBarrens)
            || unitTypeId === FourCC(Units.MercenaryCampBlackCitadel)
            || unitTypeId === FourCC(Units.MercenaryCampCityscape)
            || unitTypeId === FourCC(Units.MercenaryCampDalaran)
            || unitTypeId === FourCC(Units.MercenaryCampDungeon)
            || unitTypeId === FourCC(Units.MercenaryCampFelwood)
            || unitTypeId === FourCC(Units.MercenaryCampIcecrownGlacier)
            || unitTypeId === FourCC(Units.MercenaryCampLordaeronFall)
            || unitTypeId === FourCC(Units.MercenaryCampLordaeronSummer)
            || unitTypeId === FourCC(Units.MercenaryCampLordaeronWinter)
            || unitTypeId === FourCC(Units.MercenaryCampNorthrend)
            || unitTypeId === FourCC(Units.MercenaryCampOutland)
            || unitTypeId === FourCC(Units.MercenaryCampSunkenRuins)
            || unitTypeId === FourCC(Units.MercenaryCampUnderground)
            || unitTypeId === FourCC(Units.MercenaryCampVillage);
        //FIXME: add missing building (dragon roosts, etc)
        //Check for "Tech tree - Units Sold or Items Sold" Fields
    }

    const buildings: NeutralBuildingData[] = [];
    const group = CreateGroup();

    GroupEnumUnitsOfPlayer(group, Player(PLAYER_NEUTRAL_PASSIVE), null);

    ForGroup(group, () => {
        const unit = GetEnumUnit();
        const unitTypeId = GetUnitTypeId(unit);

        if (!isNeutralStockBuilding(unitTypeId)) {
            return;
        }

        //"Art - Team Color" property of an object.
        // if -1 then inherit from the owner.
        // >=0 player number to inherit color from. For example, 0 for Player 1 (Red)
        //FIXME: this does not work, make a static table
        const teamColorPlayer = BlzGetUnitIntegerField(unit, ConvertUnitIntegerField(FourCC('utco')))
        print(teamColorPlayer)
        buildings.push({
            unitTypeId,
            x: GetUnitX(unit),
            y: GetUnitY(unit),
            facing: GetUnitFacing(unit),
            color: teamColorPlayer,
        });

        RemoveUnit(unit);
    });

    DestroyGroup(group);

    for (const building of buildings) {
        const unit = CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE), building.unitTypeId, building.x, building.y, building.facing);
        if(building.color >= 0 && building.color < bj_MAX_PLAYERS) {
            // SetUnitColor(unit, GetPlayerColor(Player(building.color)));
        }
    }
}

/** All Neutral Passive Buildings:
 * ngol (Gold Mine)
 * ngme (Goblin Merchant)
 * nfoh (Fountain of Health)
 * nmoo (Fountain of Mana)
 * ngad (Goblin Laboratory)
 * nwgt (Way Gate)
 * ndrk (Black Dragon Roost)
 * ndru (Blue Dragon Roost)
 * ndrz (Bronze Dragon Roost)
 * ndrg (Green Dragon Roost)
 * ndro (Nether Dragon Roost)
 * ndrr (Red Dragon Roost)
 * nmer (Mercenary Camp (Lordaeron Summer))
 * nmr2 (Mercenary Camp (Lordaeron Fall))
 * nmr3 (Mercenary Camp (Lordaeron Winter))
 * nmr4 (Mercenary Camp (Barrens))
 * nmr5 (Mercenary Camp (Ashenvale))
 * nmr6 (Mercenary Camp (Felwood))
 * nmr7 (Mercenary Camp (Northrend))
 * nmr8 (Mercenary Camp (Cityscape))
 * nmr9 (Mercenary Camp (Dalaran))
 * nmr0 (Mercenary Camp (Village))
 * nmra (Mercenary Camp (Dungeon))
 * nmrb (Mercenary Camp (Underground))
 * ntav (Tavern)
 * nmrk (Marketplace)
 * nmrc (Mercenary Camp (Sunken Ruins))
 * nmrd (Mercenary Camp (Icecrown Glacier))
 * nshp (Goblin Shipyard)
 * nmre (Mercenary Camp (Outland))
 * nmrf (Mercenary Camp (Black Citadel))
 */
