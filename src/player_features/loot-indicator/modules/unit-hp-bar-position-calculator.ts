import {MapPlayer, Rectangle, Unit} from "w3ts";
import {Units} from "@objectdata/units";
import {getUnitModelScale, id2FourCC} from "./util";

//TODO: missing classic HD (aka SD+, that reside in _addons\hd2.w3addon\units.w3mod:_hd.w3mod),
// but they are most likely have the same height as SD (probably differ in texture quality only)
export interface UnitModelHeight {
    sdHeight: number;
    hdHeight: number;
}

//TODO: convert key to number FourCC as it is primarily used with number FourCC?
const UNITS_MODEL_HEIGHT: Record<string, UnitModelHeight> = compiletime(() => {
    const fs = require("fs-extra");
    const heights = JSON.parse(fs.readFileSync("./scripts/loot-indicator/model-heights/unit-model-height-data.json", "utf8")) as Record<string, UnitModelHeight>;

    // Override some values

    // Flying dragons
    [
        'nbwm', 'nbdk', 'nbdr', //black dragons
        'nbzd', 'nbzk', 'nbzw', //bronze dragons
        'nadk', 'nadr', 'nadw', //blue dragons
        'ngrd', 'ngdk', 'ngrw', //green dragons
        'nrwm', 'nrdk', 'nrdr', //red dragons
    ].forEach((unitType => heights[unitType].sdHeight += 40));

    // Murlocks
    [
        'nmrm', 'nmrr', 'nmpg', 'nmrl', 'nmmu',
    ].forEach((unitType => heights[unitType].sdHeight += 16.5));

    // Eredar
    [
        'ners', 'nerw'
    ].forEach((unitType => heights[unitType].sdHeight += 40));

    // Murlocs
    [
        'nmfs'
    ].forEach((unitType => heights[unitType].sdHeight += 20));

    return heights
}) as Record<string, UnitModelHeight>;


//For local player only
let IS_REFORGED_UNIT_MODELS_ENABLED_LOCAL: boolean;

export function initIsReforgedUnitModelsEnabledLocal() {
    //We spawn a unit known to have different Scale for SD and HD mode
    const wb = Rectangle.getWorldBounds()!;
    const u = Unit.create(MapPlayer.fromIndex(PLAYER_NEUTRAL_AGGRESSIVE)!, FourCC(Units.BlueDrake), wb.minX, wb.minY)!;
    IS_REFORGED_UNIT_MODELS_ENABLED_LOCAL = getUnitModelScale(u) !== 1.2;
    u.destroy();
}

export function isReforgedUnitModelsEnabledLocal(): boolean {
    return IS_REFORGED_UNIT_MODELS_ENABLED_LOCAL;
}

function getUnitModelHeight(unitId: number): number {
    const model = UNITS_MODEL_HEIGHT[id2FourCC(unitId)];
    if(isReforgedUnitModelsEnabledLocal()) {
        return model.hdHeight;
    } else {
        return model.sdHeight;
    }
}

export function calcUnitHpBarPosition(u: Unit) {
    let x, y, z;
    let uScale = getUnitModelScale(u)
    //TODO: does not reflect dynamic model skin (e.g. will not return different value if unit was Hexed)
    let uHeight = getUnitModelHeight(u.skin);

    // For some collision sizes Unit's position is off with HP bar
    if (u.collisionSize != 32 && u.collisionSize != 47) {
        x = u.x - 16;
        y = u.y - 16;
    } else {
        x = u.x;
        y = u.y;
    }

    z = u.localZ + u.getflyHeight() + uHeight * uScale + 16.5;

    return {x, y, z};
}