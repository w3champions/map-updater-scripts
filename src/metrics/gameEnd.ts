import * as W3CEvents from "../lua/w3cEvents";

const resultsByPlayerId: Record<number, boolean> = {};
let ended = false;

export type GameEndResultResolver = (player: player) => boolean;

export function trackGameEnd() {
    // Game-end metrics must be emitted before WC3 victory/defeat is applied.
    // Late EVENT_PLAYER_VICTORY/DEFEAT/LEAVE triggers cannot satisfy that ordering.
}

export function flushGameEndBefore(onComplete: () => void, wonResolver?: GameEndResultResolver) {
    endGameWithKnownResults(onComplete, wonResolver);
}

function endGameWithKnownResults(onComplete?: () => void, wonResolver?: GameEndResultResolver) {
    if (ended) {
        if (onComplete) {
            onComplete();
        }
        return;
    }

    const results: W3CEvents.W3CEventsGameEndPlayer[] = [];
    for (let i = 0; i < bj_MAX_PLAYERS; i++) {
        const player = Player(i);
        if (GetPlayerSlotState(player) !== PLAYER_SLOT_STATE_PLAYING || IsPlayerObserver(player)) {
            continue;
        }

        const id = GetPlayerId(player);
        results.push({ player: id, won: wonResolver ? wonResolver(player) : resultsByPlayerId[id] === true });
    }

    ended = true;
    W3CEvents.end_game(results, onComplete);
}
