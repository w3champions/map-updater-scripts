import { enableBadPing } from "badping";
import { enableBuildingCancelTrigger } from "observer_only/buildingCancel";
import { enableItemSoldBoughtTrigger } from "observer_only/itemSoldBought";
import { enableShowCommandsTrigger } from "showCommands";
import { enableUnitDenyTrigger } from "unitDeny";
import { addScriptHook, W3TS_HOOK } from "w3ts/hooks";
import { enableWorkerCount } from "workercount";
import { enableCameraZoom } from "zoom";
import { initMatchEndTimers } from "tournamentMatch";
// import { MeleeDoVictoryEnum} from "w3ts/index";

function init() {
  enableShowCommandsTrigger();
  enableCameraZoom();
  enableBadPing();
  enableWorkerCount();
  enableUnitDenyTrigger();

  // Observer-Only Features
  enableItemSoldBoughtTrigger();
  //enableLastHitOnCreepTrigger();
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

function getPlayerCount() {
  let count = 0;
  for (let i = 0; i < bj_MAX_PLAYERS; i++) {
    if (GetPlayerSlotState(Player(i)) == PLAYER_SLOT_STATE_PLAYING && !IsPlayerObserver(Player(i))) {
      count += 1;
    }
  }
  return count;
}

addScriptHook(W3TS_HOOK.MAIN_AFTER, init);
