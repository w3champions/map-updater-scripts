import { MapPlayer, getElapsedTime } from "w3ts/index";

let noChatPlayers = [];
let requiredNoChatPlayers = 0;
export function enableNoChat() {
    let nochatTrigger = CreateTrigger();
    let leaveNochatTrigger = CreateTrigger();
    let noChatPlayers = [];
    let playerCount = 0;
    for (let i = 0; i < bj_MAX_PLAYERS; i++) {
        if (GetPlayerSlotState(Player(i)) == PLAYER_SLOT_STATE_PLAYING) {
            playerCount++;
            TriggerRegisterPlayerChatEvent(nochatTrigger, Player(i), "-nochat", true);
            TriggerRegisterPlayerEventLeave(leaveNochatTrigger, Player(i));
            DisplayTextToPlayer(Player(i), 0, 0, `|cff00ff00[W3C]:|r To disable chat, players must use|cffffff00 -nochat|r.\nThis command expires in 2 minutes.`);
        }
    }

    requiredNoChatPlayers = playerCount >= 3 ? playerCount - 2 : playerCount;

    TriggerAddAction(nochatTrigger, () => {
        let triggerPlayer = MapPlayer.fromEvent();

        if (getElapsedTime() > 120) {
            DisplayTextToPlayer(triggerPlayer.handle, 0, 0, `|cff00ff00[W3C]:|r The|cffffff00 -nochat|r command is disabled after two minutes of gameplay.`);
            return;
        }

        if (noChatPlayers.indexOf(triggerPlayer.name) == -1) {
            noChatPlayers.push(triggerPlayer.name);
            let remainingPlayers = requiredNoChatPlayers - noChatPlayers.length;

            if (noChatPlayers.length == 1) {
                print(`|cff00ff00[W3C]:|r|cffFF4500 A player is proposing to disable chat. \nType|cffffff00 -nochat|r to disable chat. ${remainingPlayers} player(s) remaining.`);
            } else if (noChatPlayers.length < requiredNoChatPlayers) {
                print(`|cff00ff00[W3C]:|r|cffFF4500 ${triggerPlayer.name}|r votes to disable chat. ${remainingPlayers} player(s) remaining.`);
            }
        }

        if (noChatPlayers.length == requiredNoChatPlayers) {
            disableChat();
        }
    });
	
    TriggerAddAction(leaveNochatTrigger, () => {
        let triggerPlayer = MapPlayer.fromEvent();

        if (getElapsedTime() > 120) {
            return;
        }

        requiredNoChatPlayers = requiredNoChatPlayers - 1;
		
        if (noChatPlayers.indexOf(triggerPlayer.name) != -1) {
            noChatPlayers.splice(noChatPlayers.indexOf(triggerPlayer.name), 1);
        }

        if (noChatPlayers.length != 0 && noChatPlayers.length == requiredNoChatPlayers) {
            disableChat();
        }
    });
}

function disableChatMenuActions(){
  BlzFrameSetEnable(BlzGetFrameByName("UpperButtonBarChatButton", 0), false);
}

function disableChatMenu(){
  let disableChatMenuTrigger = CreateTrigger();
  TriggerRegisterTimerEventPeriodic(disableChatMenuTrigger, 0.10);
  BlzFrameSetVisible(BlzGetOriginFrame(ORIGIN_FRAME_SYSTEM_BUTTON, 2), false);
  TriggerAddAction(disableChatMenuTrigger, disableChatMenuActions);
}

function disableChat() {

  const chatDisalbeMessage = `|cff00ff00[W3C]:|r|cffFF4500 Chat has been disabled!`
  
  const enterKeyPressedTrigger = CreateTrigger()
  TriggerAddAction(enterKeyPressedTrigger, () => {
	const player = GetTriggerPlayer();
    let dialog = DialogCreate();
	DialogSetMessage(dialog, "Chat has been disabled!")
    DialogAddButton(dialog, "OK", 0);
    DialogDisplay(player, dialog, true);
  })
  
  const hideChatTrigger = CreateTrigger()
  TriggerAddAction(hideChatTrigger, () => {
    BlzFrameSetVisible(BlzGetOriginFrame(ORIGIN_FRAME_CHAT_MSG, 0), false);
  })
  
  for (let i = 0; i < bj_MAX_PLAYER_SLOTS - 1; i++) {
	for (let j = 0; j < 16; j++) {
	  BlzTriggerRegisterPlayerKeyEvent(enterKeyPressedTrigger, Player(i), OSKEY_RETURN, j, true)
	  TriggerRegisterPlayerChatEvent(hideChatTrigger, Player(i), "", false)
	}
  } 
  disableChatMenu();
  print(chatDisalbeMessage);
}