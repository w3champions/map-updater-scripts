import { MapPlayer, Unit } from "w3ts/index";
import { Players } from "w3ts/globals/index";

export function getPlayerHexCode(player: MapPlayer) {
    return 'cff' + getPlayerRGBCode(player).map(x => {
        const hex = R2I(x / 100 * 255).toString(16)
        return hex.length === 1 ? '0' + hex : hex
    }).join('')
}

export function getPlayerNameWithoutNumber(player: MapPlayer) {
    const i = player.name.indexOf('#')
    if (i == -1)
        return player.name
    else
        return player.name.substr(0, i)
}

export function determineGameMode() {
    let teams = {};

    for (let i = 0; i < bj_MAX_PLAYERS; i++) {
        if (GetPlayerSlotState(Player(i)) == PLAYER_SLOT_STATE_PLAYING && !IsPlayerObserver(Player(i))) {
            let team = GetPlayerTeam(Player(i));
            if (!teams[team]) {
                teams[team] = 1;
            } else {
                teams[team] = teams[team] + 1;
            }
        }
    }

    const totalTeams = Object.keys(teams).length;
    const playersOnTeams = teams[Object.keys(teams)[0]];

    switch (totalTeams) {
        case 2: {
            if (playersOnTeams == 1) {
                return MapGameMode.ONE_VS_ONE;
            }
            else if (playersOnTeams == 2) {
                return MapGameMode.TWO_VS_TWO;
            }
            else if (playersOnTeams == 3) {
                return MapGameMode.THREE_VS_THREE;
            }
            else if (playersOnTeams == 4) {
                return MapGameMode.FOUR_VS_FOUR;
            } else {
                return MapGameMode.UNKNOWN;
            }
        }
        case 3:
        case 4:
            return MapGameMode.FFA;
        default:
            return MapGameMode.UNKNOWN
    }
}

export enum MapGameMode {
    ONE_VS_ONE = 1,
    TWO_VS_TWO = 2,
    THREE_VS_THREE = 3,
    FOUR_VS_FOUR = 4,
    FFA = 5,
    UNKNOWN = 100
}

export function getPlayerRGBCode(player: MapPlayer) {
    let color = player.color

    if (GetAllyColorFilterState() == 2) {
        if (MapPlayer.fromLocal().isObserver() == false) {
            if (player == Players[PLAYER_NEUTRAL_AGGRESSIVE]) return [50, 50, 50]  // Creeps: Grey
            else if (player == MapPlayer.fromLocal()) return [0.00, 25.88, 100.00]  // Self:   PLAYER_COLOR_BLUE
            else if (player.isPlayerAlly(MapPlayer.fromLocal())) return [10.59, 90.59, 72.94]  // Ally:   PLAYER_COLOR_CYAN
            else return [100.00, 1.18, 1.18]  // Enemy:  PLAYER_COLOR_RED
        } else {
            for (let i = 0; i < bj_MAX_PLAYERS; i++) {
                if (player.isPlayerAlly(MapPlayer.fromIndex(i))) {
                    color = MapPlayer.fromIndex(i).color
                    break;
                }
            }
        }
    }

    if (color == PLAYER_COLOR_RED) return [100.00, 1.18, 1.18]
    else if (color == PLAYER_COLOR_BLUE) return [0.00, 25.88, 100.00]
    else if (color == PLAYER_COLOR_CYAN) return [10.59, 90.59, 72.94]
    else if (color == PLAYER_COLOR_PURPLE) return [33.33, 0.00, 50.59]
    else if (color == PLAYER_COLOR_YELLOW) return [99.61, 98.82, 0.00]
    else if (color == PLAYER_COLOR_ORANGE) return [99.61, 53.73, 5.10]
    else if (color == PLAYER_COLOR_GREEN) return [12.94, 74.90, 0.00]
    else if (color == PLAYER_COLOR_PINK) return [89.41, 36.08, 68.63]
    else if (color == PLAYER_COLOR_LIGHT_GRAY) return [57.65, 58.43, 58.82]
    else if (color == PLAYER_COLOR_LIGHT_BLUE) return [49.41, 74.90, 94.51]
    else if (color == PLAYER_COLOR_AQUA) return [6.27, 38.43, 27.84]
    else if (color == PLAYER_COLOR_BROWN) return [30.98, 16.86, 1.96]
    else if (color == PLAYER_COLOR_MAROON) return [61.18, 0.00, 0.00]
    else if (color == PLAYER_COLOR_NAVY) return [0.00, 0.00, 76.47]
    else if (color == PLAYER_COLOR_TURQUOISE) return [0.00, 92.16, 100.00]
    else if (color == PLAYER_COLOR_VIOLET) return [74.12, 0.00, 100.00]
    else if (color == PLAYER_COLOR_WHEAT) return [92.55, 80.78, 52.94]
    else if (color == PLAYER_COLOR_PEACH) return [96.86, 64.71, 54.51]
    else if (color == PLAYER_COLOR_MINT) return [74.90, 100.00, 50.59]
    else if (color == PLAYER_COLOR_LAVENDER) return [85.88, 72.16, 92.16]
    else if (color == PLAYER_COLOR_COAL) return [30.98, 31.37, 33.33]
    else if (color == PLAYER_COLOR_SNOW) return [92.55, 94.12, 100.00]
    else if (color == PLAYER_COLOR_EMERALD) return [0.00, 47.06, 11.76]
    else if (color == PLAYER_COLOR_PEANUT) return [64.71, 43.53, 20.39]
    else return [50, 50, 50]
}

export function showMessageOverUnit(textUnit: Unit, colourPlayer: MapPlayer, message: string, fontSize: number, showToLocalPlayer: boolean) {
    const localPlayer = MapPlayer.fromLocal();
    const color = getPlayerRGBCode(colourPlayer)

    let tag: texttag = CreateTextTagUnitBJ(message, textUnit.handle, -80.00, fontSize, color[0], color[1], color[2], 0)
    SetTextTagPermanentBJ(tag, false)
    SetTextTagVelocityBJ(tag, 20, 90)
    SetTextTagLifespanBJ(tag, 2.00)
    SetTextTagFadepointBJ(tag, 1.50)

    // Only show if showToLocalPlayer is TRUE & local player actually has vision of the dying unit
    // (that way players won't see denies in fog of war)
    SetTextTagVisibility(tag, showToLocalPlayer && ((textUnit.isVisible(localPlayer) && !textUnit.isFogged(localPlayer) && !textUnit.isMasked(localPlayer)) || localPlayer.isObserver()));
}

export function getPlayerCount() {
    let count = 0;
    for (let i = 0; i < bj_MAX_PLAYERS; i++) {
        if (GetPlayerSlotState(Player(i)) == PLAYER_SLOT_STATE_PLAYING && !IsPlayerObserver(Player(i))) {
            count += 1;
        }
    }
    return count;
}