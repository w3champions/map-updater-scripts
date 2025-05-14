import * as W3CMetrics from "../lua/w3cMetrics";

export function trackResearch() {
    const trigger = CreateTrigger();
    for (let i = 0; i < bj_MAX_PLAYERS; i++) {
        if (GetPlayerSlotState(Player(i)) === PLAYER_SLOT_STATE_PLAYING) {
            TriggerRegisterPlayerUnitEvent(trigger, Player(i),  EVENT_PLAYER_UNIT_RESEARCH_FINISH)
        }
    }

    TriggerAddAction(trigger, trackResearchFinished);
}

function trackResearchFinished() {
    const research = GetResearched();
    const playerId = GetPlayerId(GetTriggerPlayer());
    const name = GetObjectName(research);

    const payload: W3CMetrics.EventPayload = {
        player: playerId,
        value: {
            name
        }
    }

    W3CMetrics.event("ResearchDone", payload);
}