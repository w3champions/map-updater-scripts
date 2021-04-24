import { enableBadPing } from "player_features/badping";
import { enableBuildingCancelTrigger } from "observer_features/buildingCancel";
import { enableItemSoldBoughtTrigger } from "observer_features/itemSoldBought";
import { enableListOfCreepKills } from "observer_features/listofCreepKills";
import { enableShowCommandsTrigger } from "showCommands";
import { enableUnitDenyTrigger } from "player_features/unitDeny";
import { addScriptHook, W3TS_HOOK } from "w3ts/hooks";
import { enableWorkerCount } from "player_features/workercount";
import { enableCameraZoom } from "player_features/zoom";
import { initMatchEndTimers } from "tournamentMatch";
import { getGameMode, MapGameMode } from "utils";
import { anonymizePlayerNames } from "player_features/anonymizeNames";

function init() {
  enableShowCommandsTrigger();
  enableCameraZoom();
  enableWorkerCount();
  enableUnitDenyTrigger();

  // Observer-Only Features
  enableItemSoldBoughtTrigger();
  enableListOfCreepKills();
  enableBuildingCancelTrigger();

  // If the map has the InitializeTimer trigger (tourney maps), set a 30 min timer.
  if (gg_trg_InitializeTimers != null) {
    initMatchEndTimers(1500, 300);
  } else {
    enableBadPing();
  }

  // FFA Game Mode - Anonymize player names
  if (getGameMode() == MapGameMode.FFA) {
    anonymizePlayerNames();
  }
}


addScriptHook(W3TS_HOOK.MAIN_AFTER, init);
