import { MapPlayer, File, Camera } from "w3ts/index";

export function enableCameraZoom() {
    let zoomTrigger = CreateTrigger();

    for (let i = 0; i < bj_MAX_PLAYERS; i++) {
        let isLocalPlayer = MapPlayer.fromHandle(Player(i)).name == MapPlayer.fromLocal().name;

        // If the player is not an observer, then read from the file.
        if (isLocalPlayer) {
            const fileText = File.read("w3cZoomFFA.txt");

            if (fileText && Number(fileText) > 0) {
                setCameraZoom(Number(fileText), MapPlayer.fromLocal().handle);
            } else {
                // print("\n");
                // print("|cff00ff00[W3C] Tip:|r Type|cffffff00 -zoom <VALUE>|r to change your zoom level. Default: 1650 \n Minimum zoom: 1650 | Maximum zoom: 3000");
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
