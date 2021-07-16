import { MapPlayer, getElapsedTime } from "w3ts/index";

export function enableDraw() {
    let drawTrigger = CreateTrigger();
    let players = [];
    let playerCount = 0;
    for (let i = 0; i < bj_MAX_PLAYERS; i++) {
        if (GetPlayerSlotState(Player(i)) == PLAYER_SLOT_STATE_PLAYING) {
            playerCount++;
            TriggerRegisterPlayerChatEvent(drawTrigger, Player(i), "-draw", true);
            // DisplayTextToPlayer(Player(i), 0, 0, `|cff00ff00[W3C]:|r To cancel this game due to bad ping, all players must use|cffffff00 -draw|r.\nThis command expires in 2 minutes.`);
        }
    }

    let requiredPlayers = playerCount;

    if (playerCount == 4) {
        requiredPlayers = 3;
    }
    else if (playerCount == 8) {
        requiredPlayers = 6;
    }

    TriggerAddAction(drawTrigger, () => {
        let triggerPlayer = MapPlayer.fromEvent();

        if (getElapsedTime() > 120) {
            DisplayTextToPlayer(triggerPlayer.handle, 0, 0, `|cff00ff00[W3C]:|r The|cffffff00 -draw|r command is disabled after two minutes of gameplay.`);
            return;
        }

        if (players.indexOf(triggerPlayer.name) == -1) {
            players.push(triggerPlayer.name);
            let remainingPlayers = requiredPlayers - players.length;

            if (players.length == 1) {
                print(`|cff00ff00[W3C]:|r|cffFF4500 ${triggerPlayer.name}|r is proposing to cancel this game. \nType|cffffff00 -draw|r to cancel the game. ${remainingPlayers} player(s) remaining.`);
            } else if (players.length < requiredPlayers) {
                print(`|cff00ff00[W3C]:|r|cffFF4500 ${triggerPlayer.name}|r votes to cancel this game. ${remainingPlayers} player(s) remaining.`);
            }
        }

        if (players.length == requiredPlayers) {
            for (let i = 0; i < bj_MAX_PLAYERS; i++) {
                RemovePlayerPreserveUnitsBJ(Player(i), PLAYER_GAME_RESULT_NEUTRAL, false);
            }
        }
    });
}