import * as W3CEvents from "../lua/w3cEvents";

import { trackPlayerState } from "./playerState";
import { trackCombatSummary } from "./combatSummary";
import { trackUnitDeaths } from "./unitDeaths";
import { trackPlayerUnitTrained } from "./playerUnits";
import { trackBuildings } from "./playerBuildings";
import { trackHeroes } from "./heroes";
import { trackResearch } from "./research";
import { trackUnitLifecycle } from "./unitLifecycle";
import { trackHeroRevive } from "./heroRevive";
import { trackSpellEvents } from "./spellEvents";
import { trackWorkerMineSnapshot } from "./workerMineSnapshot";
import { metricSchemas } from "./schemas";
import { trackGameEnd } from "./gameEnd";

function playerRaceStr(player: player): string {
    const r = GetPlayerRace(player);
    if (r === RACE_HUMAN) return "human";
    if (r === RACE_ORC) return "orc";
    if (r === RACE_UNDEAD) return "undead";
    if (r === RACE_NIGHTELF) return "nightelf";
    return "other";
}

export function initMetrics() {
    W3CEvents.initialize();
    W3CEvents.register_all_schemas([...metricSchemas]);

    for (let i = 0; i < bj_MAX_PLAYERS; i++) {
        const player = Player(i);
        if (GetPlayerSlotState(player) === PLAYER_SLOT_STATE_PLAYING) {
            const playerId = GetPlayerId(player);
            const startLocationId = GetPlayerStartLocation(player);
            W3CEvents.event("PlayerDetails", {
                player: playerId,
                name: GetPlayerName(player),
                race: playerRaceStr(player),
                team: GetPlayerTeam(player),
                startLocationId,
                startX: GetStartLocationX(startLocationId),
                startY: GetStartLocationY(startLocationId),
            });
        }
    }
}

export function setupTrackMetrics() {
    trackPlayerState();
    trackCombatSummary();
    trackWorkerMineSnapshot();
}

export function setupEventMetrics() {
    trackUnitDeaths();
    trackPlayerUnitTrained();
    trackBuildings();
    trackHeroes();
    trackResearch();
    trackUnitLifecycle();
    trackHeroRevive();
    trackSpellEvents();
    trackGameEnd();
}
