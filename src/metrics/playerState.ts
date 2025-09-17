import * as W3CMetrics from "../lua/w3cMetrics"

export function trackPlayerState() {
    for (let i = 0; i < bj_MAX_PLAYERS; i++) {
        const player = Player(i);
        if (GetPlayerSlotState(player) === PLAYER_SLOT_STATE_PLAYING) {
            W3CMetrics.track("PlayerState", () => getPlayerState(player), 5.0)
        }
    }
}

function getPlayerState(player: player): W3CMetrics.EventPayload {
    let id = GetPlayerId(player);
    let payload: W3CMetrics.EventPayload = { player: id, value: null }

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