import { File, Camera, MapPlayer } from "w3ts";
import { addScriptHook, W3TS_HOOK } from "w3ts/hooks";

function init() {
  enableCameraZoom();
  enableBadPing();
}

function enableBadPing() {
  let badPingTrigger = CreateTrigger();
  let players = [];
  let playerCount = 0;

  for (let i = 0; i < bj_MAX_PLAYERS; i++) {
    if (GetPlayerSlotState(Player(i)) == PLAYER_SLOT_STATE_PLAYING) {
      playerCount++;
      TriggerRegisterPlayerChatEvent(badPingTrigger, Player(i), "-badping", false);
      DisplayTextToPlayer(Player(i), 0, 0, `|cff00ff00[W3C]:|r If you would like to cancel this game due to bad ping, type |cffffff00 -badping|r. `);
    }
  }

  TriggerAddAction(badPingTrigger, () => {
    let triggerPlayer = MapPlayer.fromEvent();

    if (players.indexOf(triggerPlayer.name) == -1) {
      players.push(triggerPlayer.name);
      let remainingPlayers = playerCount - players.length;

      if (players.length == 0) {
        print(`|cff00ff00[W3C]:|r|cffFF4500 ${triggerPlayer.name}|r is proposing to cancel this game. ${remainingPlayers} vote(s) needed. Type |cffffff00 -badping|r to cancel the game.`);
      } else if (players.length < playerCount) {
        print(`|cff00ff00[W3C]:|r|cffFF4500 ${triggerPlayer.name}|r votes to cancel this game. ${remainingPlayers} vote(s) needed.`);
      }
    }

    if (players.length == playerCount) {
      for (let i = 0; i < bj_MAX_PLAYERS; i++) {
        RemovePlayerPreserveUnitsBJ(Player(i), PLAYER_GAME_RESULT_NEUTRAL, false);
      }
    }
  });
}

function enableCameraZoom() {
  let zoomTrigger = CreateTrigger();

  for (let i = 0; i < bj_MAX_PLAYERS; i++) {
    let isLocalPlayer = MapPlayer.fromHandle(Player(i)).name == MapPlayer.fromLocal().name;

    // If the player is an observer, we will set a static zoom level.
    // As of right now, observer chat events are not picked up by the ChatEvent hook from above.
    /*** DESYNC ISSUES CURRENTLY WITH OBSERVERS ***/
    // if (isLocalPlayer && IsPlayerObserver(Player(i))) {
    //   setCameraZoom(1950, Player(i));
    //   return;
    // }

    // Else if the player is not an observer, then read from the file.
    if (isLocalPlayer) {
      const fileText = File.read("w3cZoomFFA.txt");

      if (fileText && Number(fileText) > 0) {
        setCameraZoom(Number(fileText), MapPlayer.fromLocal().handle);
      } else {
        print("\n");
        print("|cff00ff00[W3C] Tip:|r Type|cffffff00 -zoom <VALUE>|r to change your zoom level. Default: 1650 \n Minimum zoom: 1650 | Maximum zoom: 3000");
      }
    }
    TriggerRegisterPlayerChatEvent(zoomTrigger, Player(i), "-zoom", false);
  }

  TriggerAddAction(zoomTrigger, () => {
    let triggerPlayer = MapPlayer.fromEvent();
    let localPlayer = MapPlayer.fromLocal();;

    // Making sure that we only set our zoom level only if the local player is the one who called the command
    if (triggerPlayer.name != localPlayer.name) {
      return;
    }

    let zoomLevel = GetEventPlayerChatString().split('-zoom')[1].trim();
    let zoomNumber: number = Number(zoomLevel);
    setCameraZoom(zoomNumber, triggerPlayer.handle);
    File.write("w3cZoomFFA.txt", zoomNumber.toString());
  });
}

function setCameraZoom(zoomLevel: number, player: player) {
  const maxZoom = 3000;
  const minZoom = 1650;

  if (zoomLevel > maxZoom) {
    zoomLevel = maxZoom;
  } else if (zoomLevel < minZoom) {
    zoomLevel = minZoom;
  }

  if (player == MapPlayer.fromLocal().handle) {
    DisplayTextToPlayer(player, 0, 0, `|cff00ff00[W3C]:|r Zoom is set to|cffffff00 ${zoomLevel}|r.`);
    Camera.setField(CAMERA_FIELD_TARGET_DISTANCE, zoomLevel, 0.0);
  }
}

addScriptHook(W3TS_HOOK.MAIN_AFTER, init);