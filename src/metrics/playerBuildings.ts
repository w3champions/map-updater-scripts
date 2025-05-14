import * as W3CMetrics from "../lua/w3cMetrics"

export function trackBuildings() {
    const trigger = CreateTrigger();

    for (let i = 0; i < bj_MAX_PLAYERS; i++) {
        if (GetPlayerSlotState(Player(i)) == PLAYER_SLOT_STATE_PLAYING) {
            TriggerRegisterPlayerUnitEvent(trigger, Player(i), EVENT_PLAYER_UNIT_CONSTRUCT_START);
            TriggerRegisterPlayerUnitEvent(trigger, Player(i), EVENT_PLAYER_UNIT_CONSTRUCT_CANCEL);
            TriggerRegisterPlayerUnitEvent(trigger, Player(i), EVENT_PLAYER_UNIT_CONSTRUCT_FINISH);
        }
    }
    TriggerAddCondition(trigger, Condition(isStructure));
    TriggerAddAction(trigger, trackConstructEvents);
}

function isStructure() {
    const unit = GetTriggerUnit();
    return IsUnitType(unit, UNIT_TYPE_STRUCTURE);
}

function trackConstructEvents() {
    const playerId = GetPlayerId(GetTriggerPlayer());
    const structure = GetTriggerUnit();
    const eventId = GetTriggerEventId();

    let eventType = "";
    if (eventId === EVENT_PLAYER_UNIT_CONSTRUCT_FINISH) {
        eventType = "StructureBuilt";
    } else if (eventId === EVENT_PLAYER_UNIT_CONSTRUCT_START) {
        eventType = "StructureStart";
    } else if (eventId === EVENT_PLAYER_UNIT_CONSTRUCT_CANCEL) {
        eventType = "StructureCancel";
    }

    let payload: W3CMetrics.EventPayload = {
        player: playerId,
        value: null
    };

    let state = {};
    state["name"] = GetUnitName(structure);
    state["typeId"] = GetUnitTypeId(structure);

    payload.value = state;

    W3CMetrics.event(eventType, payload);
}