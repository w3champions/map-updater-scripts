import { enableBadPing } from "badping";
import { enableCreepLastHitTrigger } from "creepLastHit";
import { enableItemSoldTrigger } from "itemSold";
import { enableShowCommandsTrigger } from "showCommands";
import { enableUnitDenyTrigger } from "unitDeny";
import { addScriptHook, W3TS_HOOK } from "w3ts/hooks";
import { enableWorkerCount } from "workercount";
import { enableCameraZoom } from "zoom";

function init() {
  enableShowCommandsTrigger();
  enableCameraZoom();
  enableBadPing();
  enableWorkerCount();
  enableUnitDenyTrigger();
  enableItemSoldTrigger();
  enableCreepLastHitTrigger();
}

addScriptHook(W3TS_HOOK.MAIN_AFTER, init);
