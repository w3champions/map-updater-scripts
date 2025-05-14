import * as W3CMetrics from "../lua/w3cMetrics"

import { trackPlayerState } from "./playerState";
import { trackPlayerHeroDamage } from "./playerHeroDamage";
import { trackUnitDeaths } from "./unitDeaths";
import { trackPlayerUnitTrained } from "./playerUnits";
import { trackBuildings } from "./playerBuildings";
import { trackHeroes } from "./heros";
import { trackResearch } from "./research";

export function initMetrics(prefix) {
    W3CMetrics.init(prefix);
    const players = {};
    for (let i = 0; i < bj_MAX_PLAYERS; i++) {
        const player = Player(i);
        if (GetPlayerSlotState(player) === PLAYER_SLOT_STATE_PLAYING) {
            const name = GetPlayerName(player);
            const id = GetPlayerId(player);
            players[id] = { name };
        }
    }

    W3CMetrics.event("PlayerDetails", players);
}

export function setupTrackMetrics() {
    trackPlayerState();
    trackPlayerHeroDamage();
}

export function setupEventMetrics() {
    trackUnitDeaths();
    trackPlayerUnitTrained();
    trackBuildings();
    trackHeroes();
    trackResearch();
}
