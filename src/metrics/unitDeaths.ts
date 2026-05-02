import * as W3CEvents from "../lua/w3cEvents";
import { Players } from "w3ts/globals";

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
            if (hero == null) {
                break;
            }

            GroupRemoveUnit(group, hero);
            if (!IsUnitType(hero, UNIT_TYPE_HERO)) {
                continue;
            }

            const handleId = GetHandleId(hero);
            const xp = GetHeroXP(hero);
            const previousXp = lastKnownHeroXpByHandle[handleId];
            lastKnownHeroXpByHandle[handleId] = xp;

            if (previousXp === xp || (previousXp == null && xp <= 0)) {
                continue;
            }

            const xpPayload: W3CEvents.EventPayload = {
                player: playerId,
                name: GetUnitName(hero),
                heroTypeId: GetUnitTypeId(hero),
                xp,
                source,
                sourcePlayer,
            };
            W3CEvents.event("HeroXp", xpPayload);
        }

        DestroyGroup(group);
    });
}

function trackPlayerUnitDeath() {
    const unit = GetDyingUnit();
    const player = GetOwningPlayer(unit);
    if (player === Players[PLAYER_NEUTRAL_AGGRESSIVE].handle) {
        return;
    }

    const id = GetPlayerId(player);

    const payload: W3CEvents.EventPayload = {
        player: id,
        name: GetUnitName(unit),
        dyingUnitX: GetUnitX(unit),
        dyingUnitY: GetUnitY(unit),
    };

    if (IsUnitType(unit, UNIT_TYPE_STRUCTURE)) {
        W3CEvents.event("StructureDeath", payload);
    } else if (IsUnitType(unit, UNIT_TYPE_PEON)) {
        W3CEvents.event("WorkerDeath", payload);
    } else {
        W3CEvents.event("UnitDeath", payload);
    }

    const killingUnit = GetKillingUnit();
    const killingPlayer = GetOwningPlayer(killingUnit);
    emitChangedHeroXpAfterDelay(killingPlayer, "opponent", id);
}

function trackCreepKill() {
    const unit = GetDyingUnit();
    if (GetOwningPlayer(unit) !== Players[PLAYER_NEUTRAL_AGGRESSIVE].handle) {
        return;
    }

    const killingUnit = GetKillingUnit();
    const killingPlayer = GetOwningPlayer(killingUnit);
    const killingPlayerId = GetPlayerId(killingPlayer);
    const unitName = GetUnitName(unit);

    const payload: W3CEvents.EventPayload = {
        player: killingPlayerId,
        name: unitName,
        dyingUnitX: GetUnitX(unit),
        dyingUnitY: GetUnitY(unit),
    };

    if (killingPlayer !== Players[PLAYER_NEUTRAL_AGGRESSIVE].handle) {
        payload.killingUnit = GetUnitName(killingUnit);
        W3CEvents.event("CreepKill", payload);
    } else {
        W3CEvents.event("CreepDeny", payload);
    }

    emitChangedHeroXpAfterDelay(killingPlayer, "creep");
}
