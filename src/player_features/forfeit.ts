import { MapPlayer } from "w3ts/index";

export function enableForfeit() {
    let forfeitTrigger = CreateTrigger();
    let leaveTrigger = CreateTrigger();
    let expireForfeitTrigger = [CreateTrigger(), CreateTrigger()];
    let expiryTimers = [CreateTimer(), CreateTimer()]
    let requiredForfeitPlayers = [3,3];
    let forfeitPlayers = [[],[]];
    let expiryTime = 180;
    for (let i = 0; i < bj_MAX_PLAYERS; i++) {
        if (GetPlayerSlotState(Player(i)) == PLAYER_SLOT_STATE_PLAYING) {
            TriggerRegisterPlayerChatEvent(forfeitTrigger, Player(i), "-gg", true);
            TriggerRegisterPlayerEventLeave(leaveTrigger, Player(i));
        }
    }
    for (let i = 0; i < 2; i++) {
        TriggerRegisterTimerExpireEvent(expireForfeitTrigger[i], expiryTimers[i]);
    }

    TriggerAddAction(forfeitTrigger, () => {
        let triggerPlayer = MapPlayer.fromEvent();

        let team = triggerPlayer.team;

        if (forfeitPlayers[team].indexOf(triggerPlayer.name) == -1) {
            forfeitPlayers[team].push(triggerPlayer.name);
            let remainingPlayers = requiredForfeitPlayers[team] - forfeitPlayers[team].length;
            
            if (forfeitPlayers[team].length == 1) {
                if (GetPlayerTeam(GetLocalPlayer()) == team) {
                    print(`|cff00ff00[W3C]:|r|cffFF4500 ${triggerPlayer.name}|r is proposing to forfeit this game. \nType|cffffff00 -gg|r to vote. ${remainingPlayers} player(s) remaining.`);
                }
                TimerStart(expiryTimers[team], expiryTime, false, null);
            } else if (GetPlayerTeam(GetLocalPlayer()) == team && forfeitPlayers[team].length < requiredForfeitPlayers[team]) {
                print(`|cff00ff00[W3C]:|r|cffFF4500 ${triggerPlayer.name}|r voted to forfeit this game. ${remainingPlayers} player(s) remaining.`);
            }
        }

        if (forfeitPlayers[team].length == requiredForfeitPlayers[team]) {
            for (let i = 0; i < bj_MAX_PLAYERS; i++) {
                if (GetPlayerTeam(Player(i)) == team) {
                    RemovePlayerPreserveUnitsBJ(Player(i), PLAYER_GAME_RESULT_DEFEAT, false);
                }
            }
        }
    });
	
    TriggerAddAction(leaveTrigger, () => {
        let triggerPlayer = MapPlayer.fromEvent();

        let team = triggerPlayer.team;

        requiredForfeitPlayers[team] = requiredForfeitPlayers[team] - 1;
		
        if (forfeitPlayers[team].indexOf(triggerPlayer.name) != -1) {
            forfeitPlayers[team].splice(forfeitPlayers[team].indexOf(triggerPlayer.name), 1);
        }

        if (forfeitPlayers[team].length == requiredForfeitPlayers[team]) {
            for (let i = 0; i < bj_MAX_PLAYERS; i++) {
                if (GetPlayerTeam(Player(i)) == team) {
                    RemovePlayerPreserveUnitsBJ(Player(i), PLAYER_GAME_RESULT_DEFEAT, false);
                }
            }
        }
    });

    for (let i = 0; i < 2; i++) 
    (index => {
    TriggerAddAction(expireForfeitTrigger[index], () => {
        forfeitPlayers[index].splice(0, forfeitPlayers[index].length);
        if (GetPlayerTeam(GetLocalPlayer()) == index) {
            print(`|cff00ff00[W3C]|r: Forfeiting expired.`)
        }
    });
    })(i);
}