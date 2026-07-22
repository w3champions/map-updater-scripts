import {Timer} from "w3ts";
import {pauseClockW3C} from "./player_features/clock";
import {Units} from "@objectdata/units";

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
    interface NeutralBuildingData {
        unitTypeId: number;
        x: number;
        y: number;
        facing: number;
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

        buildings.push({
            unitTypeId,
            x: GetUnitX(unit),
            y: GetUnitY(unit),
            facing: GetUnitFacing(unit),
        });

        RemoveUnit(unit);
    });

    DestroyGroup(group);

    for (const building of buildings) {
        CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE), building.unitTypeId, building.x, building.y, building.facing);
    }
}
