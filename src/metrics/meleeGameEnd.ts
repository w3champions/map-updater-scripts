import { flushGameEndBefore } from "./gameEnd";

declare const _G: Record<string, any>;

let installed = false;
let applyingGameEnd = false;
let pendingGameEnd = false;

function tableGet<T>(table: object, key: number): T {
    return (rawget as any)(table, key) as T;
}

function isMeleeDefeated(playerId: number, defeatedOverrides?: LuaTable<number, boolean>) {
    const override = defeatedOverrides ? defeatedOverrides.get(playerId) : undefined;
    if (override !== undefined) {
        return override === true;
    }

    return tableGet<boolean>(bj_meleeDefeated, playerId) === true;
}

function isMeleeVictoried(playerId: number) {
    return tableGet<boolean>(bj_meleeVictoried, playerId) === true;
}

function playerIsOpponent(playerId: number, opponentId: number, defeatedOverrides?: LuaTable<number, boolean>) {
    const thePlayer = Player(playerId);
    const theOpponent = Player(opponentId);

    if (playerId === opponentId) {
        return false;
    }

    if (GetPlayerSlotState(theOpponent) !== PLAYER_SLOT_STATE_PLAYING) {
        return false;
    }

    if (isMeleeDefeated(opponentId, defeatedOverrides)) {
        return false;
    }

    if (GetPlayerAlliance(thePlayer, theOpponent, ALLIANCE_PASSIVE)) {
        if (GetPlayerAlliance(theOpponent, thePlayer, ALLIANCE_PASSIVE)) {
            if (GetPlayerState(thePlayer, PLAYER_STATE_ALLIED_VICTORY) === 1) {
                if (GetPlayerState(theOpponent, PLAYER_STATE_ALLIED_VICTORY) === 1) {
                    return false;
                }
            }
        }
    }

    return true;
}

function checkForVictors(defeatedOverrides?: LuaTable<number, boolean>) {
    const victoriousPlayers = CreateForce();

    for (let playerId = 0; playerId < bj_MAX_PLAYERS; playerId++) {
        if (isMeleeDefeated(playerId, defeatedOverrides)) {
            continue;
        }

        for (let opponentId = 0; opponentId < bj_MAX_PLAYERS; opponentId++) {
            if (playerIsOpponent(playerId, opponentId, defeatedOverrides)) {
                return { victoriousPlayers: CreateForce(), gameOver: false };
            }
        }

        ForceAddPlayer(victoriousPlayers, Player(playerId));
    }

    return { victoriousPlayers, gameOver: forceHasPlayers(victoriousPlayers) };
}

function forceHasPlayers(whichForce: force) {
    let hasPlayers = false;
    ForForce(whichForce, () => {
        hasPlayers = true;
    });
    return hasPlayers;
}

function wonResolverFromForce(victoriousPlayers: force) {
    const winningPlayerIds = new LuaTable<number, boolean>();

    ForForce(victoriousPlayers, () => {
        winningPlayerIds.set(GetPlayerId(GetEnumPlayer()), true);
    });

    return (player: player) => winningPlayerIds.get(GetPlayerId(player)) === true;
}

function runOriginalAfterFlush(originalFunction: () => void) {
    applyingGameEnd = true;
    originalFunction();
    applyingGameEnd = false;
    pendingGameEnd = false;
}

function checkForLosersAndVictorsBeforeFlush(originalCheckForLosersAndVictors: () => void) {
    if (applyingGameEnd) {
        originalCheckForLosersAndVictors();
        return;
    }

    if (pendingGameEnd || bj_meleeGameOver) {
        return;
    }

    if (GetIntegerGameState(GAME_STATE_DISCONNECTED) !== 0) {
        originalCheckForLosersAndVictors();
        return;
    }

    const defeatedOverrides = new LuaTable<number, boolean>();

    for (let playerId = 0; playerId < bj_MAX_PLAYERS; playerId++) {
        const player = Player(playerId);

        if (!isMeleeDefeated(playerId) && !isMeleeVictoried(playerId)) {
            if (MeleeGetAllyStructureCount(player) <= 0) {
                defeatedOverrides.set(playerId, true);
            }
        }
    }

    const { victoriousPlayers, gameOver } = checkForVictors(defeatedOverrides);
    if (!gameOver || !forceHasPlayers(victoriousPlayers)) {
        originalCheckForLosersAndVictors();
        return;
    }

    pendingGameEnd = true;
    flushGameEndBefore(
        () => runOriginalAfterFlush(originalCheckForLosersAndVictors),
        wonResolverFromForce(victoriousPlayers),
    );
}

export function installMeleeGameEndHooks() {
    if (installed) {
        return;
    }

    installed = true;

    const originalCheckForLosersAndVictors = _G.MeleeCheckForLosersAndVictors as () => void;

    _G.MeleeCheckForLosersAndVictors = () => checkForLosersAndVictorsBeforeFlush(originalCheckForLosersAndVictors);
}
