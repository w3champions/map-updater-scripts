import * as W3CEvents from "../lua/w3cEvents";

import { trackPlayerState } from "./playerState";
import { trackPlayerHeroDamage } from "./playerHeroDamage";
import { trackUnitDeaths } from "./unitDeaths";
import { trackPlayerUnitTrained } from "./playerUnits";
import { trackBuildings } from "./playerBuildings";
import { trackHeroes } from "./heroes";
import { trackResearch } from "./research";
import { metricSchemas } from "./schemas";

export function initMetrics() {
    W3CEvents.initialize();
    W3CEvents.register_all_schemas([...metricSchemas]);

    for (let i = 0; i < bj_MAX_PLAYERS; i++) {
        const player = Player(i);
        if (GetPlayerSlotState(player) === PLAYER_SLOT_STATE_PLAYING) {
            W3CEvents.event("PlayerDetails", {
                player: GetPlayerId(player),
                name: GetPlayerName(player),
            });
        }
    }

    W3CEvents.flush(true);
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
