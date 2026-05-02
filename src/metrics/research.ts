import * as W3CEvents from "../lua/w3cEvents";

export function trackResearch() {
    const trigger = CreateTrigger();
    for (let i = 0; i < bj_MAX_PLAYERS; i++) {
        if (GetPlayerSlotState(Player(i)) === PLAYER_SLOT_STATE_PLAYING) {
            TriggerRegisterPlayerUnitEvent(trigger, Player(i), EVENT_PLAYER_UNIT_RESEARCH_START);
            TriggerRegisterPlayerUnitEvent(trigger, Player(i), EVENT_PLAYER_UNIT_RESEARCH_CANCEL);
            TriggerRegisterPlayerUnitEvent(trigger, Player(i), EVENT_PLAYER_UNIT_RESEARCH_FINISH);
        }
    }

    TriggerAddAction(trigger, trackResearchEvent);
}

function trackResearchEvent() {
    const research = GetResearched();
    const building = GetTriggerUnit();
    const eventId = GetTriggerEventId();
    const playerId = GetPlayerId(GetTriggerPlayer());

    const payload: W3CEvents.EventPayload = {
        player: playerId,
        name: GetObjectName(research),
        building: GetUnitName(building),
        buildingX: GetUnitX(building),
        buildingY: GetUnitY(building),
    };

    const eventName =
        eventId === EVENT_PLAYER_UNIT_RESEARCH_START
            ? "ResearchStart"
            : eventId === EVENT_PLAYER_UNIT_RESEARCH_CANCEL
            ? "ResearchCancel"
            : "ResearchComplete";

    W3CEvents.event(eventName, payload);
}
