import { enableBadPing } from "badping";
import { enableLastHitOnCreepTrigger } from "observer_only/lastHitOnCreep";
import { enableBuildingCancelTrigger } from "observer_only/buildingCancel";
import { enableItemSoldTrigger } from "observer_only/itemSold";
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

  // Observer-Only Features
  enableItemSoldTrigger();
  enableLastHitOnCreepTrigger();
  enableBuildingCancelTrigger();
}

addScriptHook(W3TS_HOOK.MAIN_AFTER, init);
