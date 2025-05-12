import { Unit } from "w3ts";
import * as W3CMetrics from "../lua/w3cMetrics"
import { Players } from "w3ts/globals";

W3CMetrics.init("WC");

export function setupMetrics() {
    let localPlayer = GetLocalPlayer();
    W3CMetrics.track("PlayerState", () => getPlayerState(localPlayer), 5.0);
}

function getPlayerState(player): W3CMetrics.EventPayload {
    let payload: W3CMetrics.EventPayload = { player: null, value: null };

    payload.player = GetPlayerId(player);

    let state = {}
    state["gold"] = GetPlayerState(player, PLAYER_STATE_RESOURCE_GOLD);
    state["gold_upkeep"] = GetPlayerState(player, PLAYER_STATE_GOLD_UPKEEP_RATE);
    state["wood"] = GetPlayerState(player, PLAYER_STATE_RESOURCE_LUMBER);
    state["wood_upkeep"] = GetPlayerState(player, PLAYER_STATE_LUMBER_UPKEEP_RATE);
    state["food_cap"] = GetPlayerState(player, PLAYER_STATE_RESOURCE_FOOD_CAP);
    state["food_used"] = GetPlayerState(player, PLAYER_STATE_RESOURCE_FOOD_USED);

    payload.value = state;

    return payload;
}

export function setupMetricEvents() {
    setupPlayerUnitDeathEvents();
    setupUnitTrainedEvents();
    setupConstructEvents();
    setupHeroDamage();
}

function setupHeroDamage() {
    let localPlayer = GetLocalPlayer();
    let localPlayerId = GetPlayerId(localPlayer);

    let trigger = CreateTrigger();
    let event = TriggerRegisterPlayerUnitEvent(trigger, localPlayer, EVENT_PLAYER_UNIT_DAMAGING);
    TriggerAddAction(trigger, () => {
        let source = GetEventDamageSource();
        let dmg = GetEventDamage();

        if (IsUnitType(source, UNIT_TYPE_HERO)) {
            let name = GetUnitName(source);
            let payload: W3CMetrics.EventPayload = {
                player: localPlayerId,
                value: {
                    name,
                    dmg
                }
            }
            W3CMetrics.event("HeroDamage", payload);
        }
    });
}

function setupPlayerUnitDeathEvents() {
    let localPlayer = GetLocalPlayer();
    let localPlayerId = GetPlayerId(localPlayer);

    let neutral = GetPlayerNeutralAggressive();

    let trigger = CreateTrigger();
    //let event = TriggerRegisterPlayerUnitEvent(trigger, localPlayer, EVENT_PLAYER_UNIT_DEATH);
    let neutralEvent = TriggerRegisterAnyUnitEventBJ(trigger, EVENT_PLAYER_UNIT_DEATH);
    TriggerAddAction(trigger, () => {
        let unit = GetDyingUnit();
        if (unit === undefined) {
            return;
        }
        if (GetOwningPlayer(unit) === localPlayer) {
                let payload: W3CMetrics.EventPayload = {
                    player: localPlayerId,
                    value: null
                };

                let state = {};
                state["name"] = GetUnitName(unit);

                payload.value = state;

                if (IsUnitType(unit, UNIT_TYPE_STRUCTURE)) {
                    W3CMetrics.event("StructureDeath", payload);
                } else if (IsUnitType(unit, UNIT_TYPE_PEON)) {
                    W3CMetrics.event("WorkerDeath", payload);
                } else {
                    W3CMetrics.event("UnitDeath", payload);
                }
        } else if (GetOwningPlayer(unit) === Players[PLAYER_NEUTRAL_AGGRESSIVE].handle) {
                let payload: W3CMetrics.EventPayload = {
                    player: localPlayerId,
                    value: null
                };

                let state = {};
                state["name"] = GetUnitName(unit);

                payload.value = state;
                
                W3CMetrics.event("UnitDeath", payload);
        }
    });
}

function setupConstructEvents() {
    let localPlayer = GetLocalPlayer();
    let localPlayerId = GetPlayerId(localPlayer);

    let trigger = CreateTrigger();
    let event = TriggerRegisterPlayerUnitEvent(trigger, localPlayer, EVENT_PLAYER_UNIT_CONSTRUCT_FINISH);
    TriggerAddAction(trigger, () => structureEvent(localPlayerId));
}

function structureEvent(localPlayerId: number) {
    let structure = GetConstructedStructure();
    let eventId = GetTriggerEventId();
    let name = "";
    if (eventId === EVENT_PLAYER_UNIT_CONSTRUCT_FINISH) {
        name = "StructureBuilt";
    } else if (eventId === EVENT_PLAYER_UNIT_CONSTRUCT_START) {
        name = "StructureStart";
    } else if (eventId === EVENT_PLAYER_UNIT_CONSTRUCT_CANCEL) {
        name = "StructureCancel";
    }

    if (structure !== undefined) {
        let payload: W3CMetrics.EventPayload = {
            player: localPlayerId,
            value: null
        };

        let state = {};
        state["name"] = GetUnitName(structure);
        state["typeId"] = GetUnitTypeId(structure);

        payload.value = state;

        if (IsUnitType(structure, UNIT_TYPE_STRUCTURE)) {
            W3CMetrics.event(name, payload);
        }
    }
}

function setupUnitTrainedEvents() {
    let localPlayer = GetLocalPlayer();
    let localPlayerId = GetPlayerId(localPlayer);

    let trigger = CreateTrigger();
    let event = TriggerRegisterPlayerUnitEvent(trigger, localPlayer, EVENT_PLAYER_UNIT_TRAIN_FINISH);
    TriggerAddAction(trigger, () => {
        let unit = GetTrainedUnit();
        if (unit !== undefined) {
            let payload: W3CMetrics.EventPayload = {
                player: localPlayerId,
                value: null
            };

            let state = {};
            state["name"] = GetUnitName(unit);
            state["typeId"] = GetUnitTypeId(unit);

            payload.value = state;

            if (IsUnitType(unit, UNIT_TYPE_HERO)) {
                W3CMetrics.event("HeroTrained", payload);
            } else {
                W3CMetrics.event("UnitTrained", payload);
            }
        }
    });
}