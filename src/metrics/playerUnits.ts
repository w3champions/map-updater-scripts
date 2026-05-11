import * as W3CEvents from "../lua/w3cEvents";
import { getUnitName } from "./objectNames";

export function trackPlayerUnitTrained() {
    const trigger = CreateTrigger();

    for (let i = 0; i < bj_MAX_PLAYERS; i++) {
        if (GetPlayerSlotState(Player(i)) == PLAYER_SLOT_STATE_PLAYING) {
            TriggerRegisterPlayerUnitEvent(trigger, Player(i), EVENT_PLAYER_UNIT_TRAIN_START);
            TriggerRegisterPlayerUnitEvent(trigger, Player(i), EVENT_PLAYER_UNIT_TRAIN_CANCEL);
            TriggerRegisterPlayerUnitEvent(trigger, Player(i), EVENT_PLAYER_UNIT_TRAIN_FINISH);
        }
    }

    TriggerAddAction(trigger, trackPlayerTraining);
};

function trackPlayerTraining() {
    const eventId = GetTriggerEventId();
    const player = GetTriggerPlayer();
    const id = GetPlayerId(player);

    let typeId = 0;
    let unitType = "unit";
    let unit = GetTriggerUnit();

    if (eventId === EVENT_PLAYER_UNIT_TRAIN_START) {
        typeId = GetTrainedUnitType();
        unitType = IsHeroUnitId(typeId) ? "hero" : "unit";
    } else {
        unit = GetTrainedUnit();
        typeId = GetUnitTypeId(unit);
        unitType = IsUnitType(unit, UNIT_TYPE_HERO) ? "hero" : "unit";
    }

    const eventType =
        eventId === EVENT_PLAYER_UNIT_TRAIN_START
            ? "UnitStarted"
            : eventId === EVENT_PLAYER_UNIT_TRAIN_CANCEL
            ? "UnitCancelled"
            : "UnitTrained";

    W3CEvents.event(eventType, {
        player: id,
        name: getUnitName(typeId),
        typeId,
        unitType,
        x: GetUnitX(unit),
        y: GetUnitY(unit),
    });
}
