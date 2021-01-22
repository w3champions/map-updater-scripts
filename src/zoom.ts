import { MapPlayer, File, Camera } from "w3ts/index";

let currentZoomLevel = 1650;

export function enableCameraZoom() {
    let zoomTrigger = CreateTrigger();
    let obsResetZoomTrigger = CreateTrigger();

    for (let i = 0; i < bj_MAX_PLAYERS; i++) {
        let localPlayer = MapPlayer.fromLocal().handle;
        let isLocalPlayer = MapPlayer.fromHandle(Player(i)).name == MapPlayer.fromLocal().name;

        if (isLocalPlayer) {
            const fileText = File.read("w3cZoomFFA.txt");
            currentZoomLevel = Number(fileText);
            if (fileText && currentZoomLevel > 0) {
                setCameraZoom(currentZoomLevel, MapPlayer.fromLocal().handle);
            } else {
                if (IsPlayerObserver(localPlayer)) {
                    currentZoomLevel = 1950;
                    setCameraZoom(1950, localPlayer);
                }
            }

            // if (IsPlayerObserver(localPlayer)) {
            //     TriggerRegisterTimerEvent(obsResetZoomTrigger, 15, true);
            //     TriggerAddAction(obsResetZoomTrigger, observerResetZoom);
            // }
        }
        TriggerRegisterPlayerChatEvent(zoomTrigger, Player(i), "-zoom", false);
    }

    TriggerAddAction(zoomTrigger, () => {
        let triggerPlayer = MapPlayer.fromEvent();
        let localPlayer = MapPlayer.fromLocal();

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

function observerResetZoom() {
    setCameraZoom(currentZoomLevel, MapPlayer.fromLocal().handle, false);
}

function setCameraZoom(zoomLevel: number, player: player, shouldDisplayText: boolean = true) {
    const maxZoom = 3000;
    const minZoom = 1650;

    if (zoomLevel > maxZoom) {
        zoomLevel = maxZoom;
    } else if (zoomLevel < minZoom) {
        zoomLevel = minZoom;
    }

    if (player == MapPlayer.fromLocal().handle) {
        if (shouldDisplayText) {
            DisplayTextToPlayer(player, 0, 0, `|cff00ff00[W3C]:|r Zoom is set to|cffffff00 ${zoomLevel}|r.`);
        }
        Camera.setField(CAMERA_FIELD_TARGET_DISTANCE, zoomLevel, 0.0);
    }
}
