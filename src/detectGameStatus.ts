export enum GameStatus {
    ONLINE_OR_LAN,
    OFFLINE,
    REPLAY
}

let gameStatus: GameStatus;

export function detectGameStatusAndCache() {
    gameStatus = detectGameStatus();
}

export function getGameStatus() {
    return gameStatus;
}

export function isReplay() {
    return getGameStatus() === GameStatus.REPLAY;
}

// Based on https://www.hiveworkshop.com/threads/gamestatus-replay-detection.293181/
// Note: Will remove a small radius of black fog at a player's start location - May be undesired on some custom maps
function detectGameStatus() {
    let i = 0;

    for (; i < bj_MAX_PLAYERS; i++) {
        if (GetPlayerController(Player(i)) === MAP_CONTROL_USER && GetPlayerSlotState(Player(i)) === PLAYER_SLOT_STATE_PLAYING) {
            break;
        }
    }

    const sl = GetPlayerStartLocation(Player(i));
    const x = GetStartLocationX(sl);
    const y = GetStartLocationY(sl);
    // nvul is vulture, has low sight range
    const unit = CreateUnit(Player(i), FourCC('nvul'), x, y, 0);
    SelectUnitForPlayerSingle(unit, Player(i));
    const isUnitSelected = IsUnitSelected(unit, Player(i));
    RemoveUnit(unit);

    if (isUnitSelected) {
        if (ReloadGameCachesFromDisk()) {
            return GameStatus.OFFLINE;
        } else {
            return GameStatus.REPLAY;
        }
    }

    return GameStatus.ONLINE_OR_LAN;
}
