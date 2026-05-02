import * as W3CEvents from "../lua/w3cEvents";

export function trackBuildings() {
    const trigger = CreateTrigger();

    for (let i = 0; i < bj_MAX_PLAYERS; i++) {
        if (GetPlayerSlotState(Player(i)) == PLAYER_SLOT_STATE_PLAYING) {
            TriggerRegisterPlayerUnitEvent(trigger, Player(i), EVENT_PLAYER_UNIT_CONSTRUCT_START);
            TriggerRegisterPlayerUnitEvent(trigger, Player(i), EVENT_PLAYER_UNIT_CONSTRUCT_CANCEL);
            TriggerRegisterPlayerUnitEvent(trigger, Player(i), EVENT_PLAYER_UNIT_CONSTRUCT_FINISH);
            TriggerRegisterPlayerUnitEvent(trigger, Player(i), EVENT_PLAYER_UNIT_UPGRADE_START);
            TriggerRegisterPlayerUnitEvent(trigger, Player(i), EVENT_PLAYER_UNIT_UPGRADE_CANCEL);
            TriggerRegisterPlayerUnitEvent(trigger, Player(i), EVENT_PLAYER_UNIT_UPGRADE_FINISH);
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
    } else if (eventId === EVENT_PLAYER_UNIT_UPGRADE_START) {
        eventType = "UpgradeStart";
    } else if (eventId === EVENT_PLAYER_UNIT_UPGRADE_CANCEL) {
        eventType = "UpgradeCancel";
    } else if (eventId === EVENT_PLAYER_UNIT_UPGRADE_FINISH) {
        eventType = "UpgradeComplete";
    }

    const payload: W3CEvents.EventPayload = {
        player: playerId,
        name: GetUnitName(structure),
        typeId: GetUnitTypeId(structure),
        unitType: "structure",
    };

    W3CEvents.event(eventType, payload);
}
