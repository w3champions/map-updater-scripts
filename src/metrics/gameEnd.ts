import * as W3CEvents from "../lua/w3cEvents";

const resultsByPlayerId: Record<number, boolean> = {};
let ended = false;

export function trackGameEnd() {
    const playerTrigger = CreateTrigger();
    const gameTrigger = CreateTrigger();

    for (let i = 0; i < bj_MAX_PLAYERS; i++) {
        const player = Player(i);
        if (GetPlayerSlotState(player) !== PLAYER_SLOT_STATE_PLAYING || IsPlayerObserver(player)) {
            continue;
        }

        TriggerRegisterPlayerEvent(playerTrigger, player, EVENT_PLAYER_VICTORY);
        TriggerRegisterPlayerEvent(playerTrigger, player, EVENT_PLAYER_DEFEAT);
        TriggerRegisterPlayerEventLeave(playerTrigger, player);
    }

    TriggerRegisterGameEvent(gameTrigger, EVENT_GAME_END_LEVEL);
    TriggerRegisterGameEvent(gameTrigger, EVENT_GAME_VICTORY);

    TriggerAddAction(playerTrigger, () => {
        if (ended) {
            return;
        }

        const playerId = GetPlayerId(GetTriggerPlayer());
        resultsByPlayerId[playerId] = GetTriggerEventId() === EVENT_PLAYER_VICTORY;
        endGameWithKnownResults();
    });

    TriggerAddAction(gameTrigger, () => {
        if (ended) {
            return;
        }

        endGameWithKnownResults();
    });
}

function endGameWithKnownResults() {
    const results: W3CEvents.W3CEventsGameEndPlayer[] = [];
    for (let i = 0; i < bj_MAX_PLAYERS; i++) {
        const player = Player(i);
        if (GetPlayerSlotState(player) !== PLAYER_SLOT_STATE_PLAYING || IsPlayerObserver(player)) {
            continue;
        }

        const id = GetPlayerId(player);
        results.push({ player: id, won: resultsByPlayerId[id] === true });
    }

    ended = true;
    W3CEvents.end_game(results);
}
