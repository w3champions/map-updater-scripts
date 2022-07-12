import { MapPlayer, getElapsedTime } from "w3ts/index";

let drawPlayers = [];
let requiredDrawPlayers = 0;
export function enableDraw() {
    let drawTrigger = CreateTrigger();
    let leaveDrawTrigger = CreateTrigger();
    let drawPlayers = [];
    let playerCount = 0;
    for (let i = 0; i < bj_MAX_PLAYERS; i++) {
        if (GetPlayerSlotState(Player(i)) == PLAYER_SLOT_STATE_PLAYING) {
            playerCount++;
            TriggerRegisterPlayerChatEvent(drawTrigger, Player(i), "-draw", true);
            TriggerRegisterPlayerEventLeave(leaveDrawTrigger, Player(i));
            // DisplayTextToPlayer(Player(i), 0, 0, `|cff00ff00[W3C]:|r To cancel this game due to bad ping, all players must use|cffffff00 -draw|r.\nThis command expires in 2 minutes.`);
        }
    }

    if (playerCount >= 4) {
        requiredDrawPlayers = playerCount - 1;
    } else {
        requiredDrawPlayers = playerCount;
    }

    TriggerAddAction(drawTrigger, () => {
        let triggerPlayer = MapPlayer.fromEvent();

        if (getElapsedTime() > 120) {
            DisplayTextToPlayer(triggerPlayer.handle, 0, 0, `|cff00ff00[W3C]:|r The|cffffff00 -draw|r command is disabled after two minutes of gameplay.`);
            return;
        }

        if (drawPlayers.indexOf(triggerPlayer.name) == -1) {
            drawPlayers.push(triggerPlayer.name);
            let remainingPlayers = requiredDrawPlayers - drawPlayers.length;

            if (drawPlayers.length == 1) {
                print(`|cff00ff00[W3C]:|r|cffFF4500 ${triggerPlayer.name}|r is proposing to cancel this game. \nType|cffffff00 -draw|r to cancel the game. ${remainingPlayers} player(s) remaining.`);
            } else if (drawPlayers.length < requiredDrawPlayers) {
                print(`|cff00ff00[W3C]:|r|cffFF4500 ${triggerPlayer.name}|r votes to cancel this game. ${remainingPlayers} player(s) remaining.`);
            }
        }

        if (drawPlayers.length == requiredDrawPlayers) {
            for (let i = 0; i < bj_MAX_PLAYERS; i++) {
                RemovePlayerPreserveUnitsBJ(Player(i), PLAYER_GAME_RESULT_NEUTRAL, false);
            }
        }
    });
	
    TriggerAddAction(leaveDrawTrigger, () => {
        let triggerPlayer = MapPlayer.fromEvent();

        if (getElapsedTime() > 120) {
            return;
        }

        requiredDrawPlayers = requiredDrawPlayers - 1;
		
        if (drawPlayers.indexOf(triggerPlayer.name) != -1) {
            drawPlayers.splice(drawPlayers.indexOf(triggerPlayer.name), 1);
        }

        if (drawPlayers.length != 0 && drawPlayers.length == requiredDrawPlayers) {
            for (let i = 0; i < bj_MAX_PLAYERS; i++) {
                RemovePlayerPreserveUnitsBJ(Player(i), PLAYER_GAME_RESULT_NEUTRAL, false);
            }
        }
    });
}