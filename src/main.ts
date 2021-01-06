import { enableBadPing } from "badping";
import { enableShowCommandsTrigger } from "showCommands";
import { addScriptHook, W3TS_HOOK } from "w3ts/hooks";
import { enableWorkerCount } from "workercount";
import { enableCameraZoom } from "zoom";

function init() {
  enableShowCommandsTrigger();
  enableCameraZoom();
  enableBadPing();
  enableWorkerCount();
}

addScriptHook(W3TS_HOOK.MAIN_AFTER, init);