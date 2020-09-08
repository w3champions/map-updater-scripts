import { File, Camera, MapPlayer } from "w3ts";
import { addScriptHook, W3TS_HOOK } from "w3ts/hooks";

function cameraZoomInit() {
  let zoomTrigger = CreateTrigger();

  for (let i = 0; i < bj_MAX_PLAYERS; i++) {
    TriggerRegisterPlayerChatEvent(zoomTrigger, Player(i), "-zoom", false);
  }

  // If the local player is an observer, we will set a static zoom level.
  // As of right now, observer chat events are not picked up by the ChatEvent hook from above.
  if(IsPlayerObserver(GetLocalPlayer())){
    setCameraZoom(1950);
    return;
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
    setCameraZoom(zoomNumber);
    File.write("w3cZoomFFA.txt", zoomNumber.toString());
  });

  const fileText = File.read("w3cZoomFFA.txt");

  if (fileText && Number(fileText) > 0) {
    setCameraZoom(Number(fileText));
  } else {
    print("\n");
    print("|cff00ff00[W3C] Tip:|r Type|cffffff00 -zoom <VALUE>|r to change your zoom level. Default: 1650 \n Minimum zoom: 1650 | Maximum zoom: 3000")
  }
}

function setCameraZoom(zoomLevel: number) {
  const maxZoom = 3000;
  const minZoom = 1650;

  if (zoomLevel > maxZoom) {
    zoomLevel = maxZoom;
  } else if (zoomLevel < minZoom) {
    zoomLevel = minZoom;
  }

  Camera.setField(CAMERA_FIELD_TARGET_DISTANCE, zoomLevel, 0.0);
  print(`|cff00ff00[W3C]:|r Zoom is set to|cffffff00 ${zoomLevel}|r.`);
}

addScriptHook(W3TS_HOOK.MAIN_AFTER, cameraZoomInit);