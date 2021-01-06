import { MapPlayer, playerColors } from "w3ts/index";

export function getPlayerRGBCode(whichPlayer: MapPlayer) {
    return playerColors[GetHandleId(whichPlayer.color)];
}