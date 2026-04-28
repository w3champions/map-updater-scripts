import * as W3CEvents from "../lua/w3cEvents";
import { Players } from "w3ts/globals";

export function trackUnitDeaths() {
    const trigger = CreateTrigger();
    TriggerRegisterAnyUnitEventBJ(trigger, EVENT_PLAYER_UNIT_DEATH);
    TriggerAddAction(trigger, trackPlayerUnitDeath);
    TriggerAddAction(trigger, trackCreepKill);
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
    const killingPlayerId = GetPlayerId(killingPlayer);

    if (IsUnitType(killingUnit, UNIT_TYPE_HERO)) {
        const timer = CreateTimer();
        TimerStart(timer, 0.1, false, () => {
            DestroyTimer(timer);
            const xp = GetHeroXP(killingUnit);
            const heroName = GetUnitName(killingUnit);
            const xpPayload: W3CEvents.EventPayload = {
                player: killingPlayerId,
                name: heroName,
                xp,
                source: "opponent",
            };
            W3CEvents.event("HeroXp", xpPayload);
        })
    }
}

function trackCreepKill() {
    const unit = GetDyingUnit();
    if (GetOwningPlayer(unit) !== Players[PLAYER_NEUTRAL_AGGRESSIVE].handle) {
        return;
    }

    const killingUnit = GetKillingUnit();
    const killingPlayer = GetOwningPlayer(killingUnit);

    const player = GetTriggerPlayer();
    const id = GetPlayerId(player);
    const unitName = GetUnitName(unit);

    const payload: W3CEvents.EventPayload = {
        player: id,
        name: unitName,
    };

    if (killingPlayer === player) {
        W3CEvents.event("CreepKill", payload);
    } else if (killingPlayer === Players[PLAYER_NEUTRAL_AGGRESSIVE].handle) {
        W3CEvents.event("CreepDeny", payload);
    }

    if (IsUnitType(killingUnit, UNIT_TYPE_HERO)) {
        const timer = CreateTimer();
        TimerStart(timer, 0.1, false, () => {
            DestroyTimer(timer);
            const xp = GetHeroXP(killingUnit);
            const heroName = GetUnitName(killingUnit);
            const xpPayload: W3CEvents.EventPayload = {
                player: id,
                name: heroName,
                xp,
                source: "creep",
            };
            W3CEvents.event("HeroXp", xpPayload);
        });
    }
}
