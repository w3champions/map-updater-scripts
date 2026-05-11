import * as W3CEvents from "../lua/w3cEvents";

export function trackPlayerState() {
    W3CEvents.track("PlayerState", getAllPlayerState, 1);
}

function getAllPlayerState(): W3CEvents.EventPayload[] {
    const events: W3CEvents.EventPayload[] = [];
    for (let i = 0; i < bj_MAX_PLAYERS; i++) {
        const player = Player(i);
        if (GetPlayerSlotState(player) === PLAYER_SLOT_STATE_PLAYING) {
            events.push(getPlayerState(player));
        }
    }

    return events;
}

function getPlayerState(player: player): W3CEvents.EventPayload {
    return {
        player: GetPlayerId(player),
        gold: GetPlayerState(player, PLAYER_STATE_RESOURCE_GOLD),
        gold_upkeep: GetPlayerState(player, PLAYER_STATE_GOLD_UPKEEP_RATE),
        wood: GetPlayerState(player, PLAYER_STATE_RESOURCE_LUMBER),
        wood_upkeep: GetPlayerState(player, PLAYER_STATE_LUMBER_UPKEEP_RATE),
        food_cap: GetPlayerState(player, PLAYER_STATE_RESOURCE_FOOD_CAP),
        food_used: GetPlayerState(player, PLAYER_STATE_RESOURCE_FOOD_USED),
    };
}
