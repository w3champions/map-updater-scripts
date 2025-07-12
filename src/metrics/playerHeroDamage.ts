import { Players } from "w3ts/globals";
import * as W3CMetrics from "../lua/w3cMetrics"

type HeroDamageStats = {
    creepDone: number;
    creepTaken: number;
    structureDone: number;
    structureTaken: number;
    heroDone: number;
    heroTaken: number;
    workerDone: number;
    workerTaken: number;
    unitDone: number;
    unitTaken: number;
};

const heroDamageMap: Record<number, Record<string, HeroDamageStats>> = {};

type UnitCategory = "creep" | "structure" | "hero" | "worker" | "unit" | "neutral" | "unknown";

export function trackPlayerHeroDamage() {
    const heroDamageDone = CreateTrigger();
    TriggerRegisterAnyUnitEventBJ(heroDamageDone, EVENT_PLAYER_UNIT_DAMAGED);
    TriggerAddCondition(heroDamageDone, Condition(checkIsPlayerHeroSource))
    TriggerAddAction(heroDamageDone, onUnitDamaged);

    const heroDamageTaken = CreateTrigger();
    TriggerRegisterAnyUnitEventBJ(heroDamageTaken, EVENT_PLAYER_UNIT_DAMAGED);
    TriggerAddCondition(heroDamageTaken, Condition(checkIsPlayerHeroTarget));
    TriggerAddAction(heroDamageTaken, onHeroDamaged);

    W3CMetrics.track("HeroDamage", () => heroDamageMap, 5.0);
}

function checkIsPlayerHeroSource() {
    const source = GetEventDamageSource();
    const player = GetOwningPlayer(source);
    if (player != Players[PLAYER_NEUTRAL_AGGRESSIVE].handle) {
        return IsUnitType(source, UNIT_TYPE_HERO)
    } else {
        return false
    }
}

function checkIsPlayerHeroTarget() {
    const target = GetTriggerUnit();
    const player = GetOwningPlayer(target);
    if (player === Players[PLAYER_NEUTRAL_AGGRESSIVE].handle) {
        return false;
    }

    return IsUnitType(target, UNIT_TYPE_HERO);
}

function onUnitDamaged() {
    const source = GetEventDamageSource();
    const heroName = GetUnitName(source);
    const target = GetTriggerUnit();
    const damage = GetEventDamage();
    const unitType = classifyDamageTarget(target);
    const player = GetPlayerId(GetOwningPlayer(source));

    heroDamageMap[player] ??= {};

    if (!heroDamageMap[player][heroName]) {
        heroDamageMap[player][heroName] = {
            creepDone: 0,
            creepTaken: 0,
            structureDone: 0,
            structureTaken: 0,
            heroDone: 0,
            heroTaken: 0,
            workerDone: 0,
            workerTaken: 0,
            unitDone: 0,
            unitTaken: 0,
        };
    }

    heroDamageMap[player][heroName][`${unitType}Done`] += damage;
}

function onHeroDamaged() {
    const source = GetEventDamageSource();
    const hero = GetTriggerUnit();
    const damage = GetEventDamage();
    const heroName = GetUnitName(hero);
    const unitType = classifyDamageTarget(source);
    const player = GetPlayerId(GetOwningPlayer(hero));


    heroDamageMap[player] ??= {};

    if (!heroDamageMap[player][heroName]) {
        heroDamageMap[player][heroName] = {
            creepDone: 0,
            creepTaken: 0,
            structureDone: 0,
            structureTaken: 0,
            heroDone: 0,
            heroTaken: 0,
            workerDone: 0,
            workerTaken: 0,
            unitDone: 0,
            unitTaken: 0,
        };
    }

    heroDamageMap[player][heroName][`${unitType}Taken`] += damage;

}

function classifyDamageTarget(target: unit): UnitCategory {
    const owner = GetOwningPlayer(target);

    if (owner === Players[PLAYER_NEUTRAL_AGGRESSIVE].handle) return "creep";

    if (IsUnitType(target, UNIT_TYPE_STRUCTURE)) return "structure";
    if (IsUnitType(target, UNIT_TYPE_HERO)) return "hero";
    if (IsUnitType(target, UNIT_TYPE_PEON)) return "worker";

    const unitId = GetUnitTypeId(target);
    if (unitId === FourCC("acol") || unitId === FourCC("drll")) return "worker";

    return "unit";
}
