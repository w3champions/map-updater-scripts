import * as W3CEvents from "../lua/w3cEvents";
import { Players } from "w3ts/globals";
import { getUnitName } from "./objectNames";

const lastKnownHeroXpByHandle: Record<number, number> = {};

export function trackUnitDeaths() {
    const trigger = CreateTrigger();
    TriggerRegisterAnyUnitEventBJ(trigger, EVENT_PLAYER_UNIT_DEATH);
    TriggerAddAction(trigger, trackPlayerUnitDeath);
    TriggerAddAction(trigger, trackCreepKill);
}

function emitChangedHeroXpAfterDelay(player: player, source: string, sourcePlayer = -1) {
    if (player === Players[PLAYER_NEUTRAL_AGGRESSIVE].handle) {
        return;
    }

    const timer = CreateTimer();
    TimerStart(timer, 0.1, false, () => {
        DestroyTimer(timer);
        const playerId = GetPlayerId(player);
        const group = CreateGroup();
        GroupEnumUnitsOfPlayer(group, player, null);

        while (true) {
            const hero = FirstOfGroup(group);
            if (hero == null) break;

            GroupRemoveUnit(group, hero);
            if (!IsUnitType(hero, UNIT_TYPE_HERO)) continue;

            const handleId = GetHandleId(hero);
            const xp = GetHeroXP(hero);
            const previousXp = lastKnownHeroXpByHandle[handleId];
            lastKnownHeroXpByHandle[handleId] = xp;

            if (previousXp === xp || (previousXp == null && xp <= 0)) continue;

            const heroTypeId = GetUnitTypeId(hero);
            W3CEvents.event("HeroXp", {
                player: playerId,
                name: getUnitName(heroTypeId),
                heroTypeId,
                xp,
                source,
                sourcePlayer,
            });
        }

        DestroyGroup(group);
    });
}

function killerFields(unit: unit | null) {
    if (unit == null) {
        return { killerPlayer: -1, killerTypeId: 0, killerX: 0, killerY: 0 };
    }
    return {
        killerPlayer: GetPlayerId(GetOwningPlayer(unit)),
        killerTypeId: GetUnitTypeId(unit),
        killerX: GetUnitX(unit),
        killerY: GetUnitY(unit),
    };
}

function trackPlayerUnitDeath() {
    const unit = GetDyingUnit();
    const player = GetOwningPlayer(unit);
    if (player === Players[PLAYER_NEUTRAL_AGGRESSIVE].handle) {
        return;
    }

    const id = GetPlayerId(player);
    const typeId = GetUnitTypeId(unit);
    const killer = GetKillingUnit();

    const payload: W3CEvents.EventPayload = {
        player: id,
        name: getUnitName(typeId),
        typeId,
        level: GetUnitLevel(unit),
        isHero: IsUnitType(unit, UNIT_TYPE_HERO),
        pointValue: GetUnitPointValue(unit),
        x: GetUnitX(unit),
        y: GetUnitY(unit),
        ...killerFields(killer),
    };

    if (IsUnitType(unit, UNIT_TYPE_STRUCTURE)) {
        W3CEvents.event("StructureDeath", payload);
    } else if (IsUnitType(unit, UNIT_TYPE_PEON)) {
        W3CEvents.event("WorkerDeath", payload);
    } else {
        W3CEvents.event("UnitDeath", payload);
    }

    if (killer != null) {
        emitChangedHeroXpAfterDelay(GetOwningPlayer(killer), "opponent", id);
    }
}

function trackCreepKill() {
    const unit = GetDyingUnit();
    if (GetOwningPlayer(unit) !== Players[PLAYER_NEUTRAL_AGGRESSIVE].handle) {
        return;
    }

    const killingUnit = GetKillingUnit();
    const killingPlayer = GetOwningPlayer(killingUnit);
    const killingPlayerId = GetPlayerId(killingPlayer);
    const dyingTypeId = GetUnitTypeId(unit);
    const killingTypeId = GetUnitTypeId(killingUnit);

    const base: W3CEvents.EventPayload = {
        player: killingPlayerId,
        name: getUnitName(dyingTypeId),
        typeId: dyingTypeId,
        level: GetUnitLevel(unit),
        pointValue: GetUnitPointValue(unit),
        x: GetUnitX(unit),
        y: GetUnitY(unit),
    };

    if (killingPlayer !== Players[PLAYER_NEUTRAL_AGGRESSIVE].handle) {
        W3CEvents.event("CreepKill", {
            ...base,
            killingUnit: getUnitName(killingTypeId),
            killingTypeId,
            killerX: GetUnitX(killingUnit),
            killerY: GetUnitY(killingUnit),
        });
    } else {
        // CreepDeny uses namedDeathFields, fill killer fields with the denying creep
        W3CEvents.event("CreepDeny", {
            ...base,
            isHero: false,
            killerPlayer: killingPlayerId,
            killerTypeId: killingTypeId,
            killerX: GetUnitX(killingUnit),
            killerY: GetUnitY(killingUnit),
        });
    }

    emitChangedHeroXpAfterDelay(killingPlayer, "creep");
}
