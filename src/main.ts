import { enableBadPing } from "badping";
import { enableBuildingCancelTrigger } from "observer_only/buildingCancel";
import { enableItemSoldBoughtTrigger } from "observer_only/itemSoldBought";
import { enableListOfCreepKills } from "observer_only/listofCreepKills";
import { enableShowCommandsTrigger } from "showCommands";
import { enableUnitDenyTrigger } from "unitDeny";
import { addScriptHook, W3TS_HOOK } from "w3ts/hooks";
import { enableWorkerCount } from "workercount";
import { enableCameraZoom } from "zoom";
import { initMatchEndTimers } from "tournamentMatch";
import { getPlayerCount } from "utils";

function init() {
  enableShowCommandsTrigger();
  enableCameraZoom();
  enableBadPing();
  enableWorkerCount();
  enableUnitDenyTrigger();

  // Observer-Only Features
  enableItemSoldBoughtTrigger();
  enableListOfCreepKills();
  enableBuildingCancelTrigger();

  // If the map has the InitializeTimer trigger (ffa maps), set a 90 min timer
  if (gg_trg_InitializeTimers != null && getPlayerCount() > 2) {
    initMatchEndTimers(5100, 300);
  }
  // If the map has the InitializeTimer trigger (tourney maps), set a 30 min timer.
  else if (gg_trg_InitializeTimers != null) {
    initMatchEndTimers(1500, 300);
  }
}


addScriptHook(W3TS_HOOK.MAIN_AFTER, init);
