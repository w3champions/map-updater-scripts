import { enableDraw } from "player_features/draw";
import { enableBuildingCancelTrigger } from "observer_features/buildingCancel";
import { enableItemSoldBoughtTrigger } from "observer_features/itemSoldBought";
import { enableListOfCreepKills } from "observer_features/listOfCreepKills";
import { enableShowCommandsTrigger } from "showCommands";
import { enableUnitDenyTrigger } from "player_features/unitDeny";
import { addScriptHook, W3TS_HOOK } from "w3ts/hooks";
import { enableWorkerCount } from "player_features/workercount";
import { enableCameraZoom } from "player_features/zoom";
import { initMatchEndTimers } from "tournamentMatch";
import { getGameMode, MapGameMode } from "utils";
import { anonymizePlayerNames } from "player_features/anonymizeNames";
import { enableForfeit } from "player_features/forfeit";
import { enableCustomMinimapIcons } from "player_features/customMinimapIcons";
import { hideGameButtons } from "player_features/hideGameButtons";
import { enableClock } from "player_features/clock";

function init() {
  enableShowCommandsTrigger();
  enableCameraZoom();
  enableWorkerCount();
  enableUnitDenyTrigger();
  enableCustomMinimapIcons();
  enableClock();

  // Observer-Only Features
  enableItemSoldBoughtTrigger();
  enableListOfCreepKills();
  enableBuildingCancelTrigger();

  // If the map has the InitializeTimers trigger (tournament maps), set a 30 min timer.
  if (gg_trg_InitializeTimers != null) {
    initMatchEndTimers(1500, 300);
  } else {
    enableDraw();
  }

  // FFA Game Mode - Anonymize player names
  if (getGameMode() == MapGameMode.FFA) {
    anonymizePlayerNames();
  } else if (getGameMode() == MapGameMode.FOUR_VS_FOUR) {
    enableForfeit();
  }

  hideGameButtons();
}


addScriptHook(W3TS_HOOK.MAIN_AFTER, init);
