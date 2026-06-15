import * as W3CEvents from "../lua/w3cEvents";

// So we can override blizzard functions
declare const _G: Record<string, any>;

let installed = false;
let gameEnded = false;

let originalCheckForLosersAndVictors: () => void;

export function trackGameEnd() {
  const gameTrigger = CreateTrigger();

  TriggerRegisterGameEvent(gameTrigger, EVENT_GAME_END_LEVEL);
  TriggerRegisterGameEvent(gameTrigger, EVENT_GAME_VICTORY);
  TriggerAddAction(gameTrigger, () => {
    if (gameEnded) {
      return;
    }
    W3CEvents.shutdown();
    gameEnded = true;
  })
}

/**
 * Needs to be installed before main using 
 * addScriptHook(W3TS_HOOK.MAIN_BEFORE, installGameEndHook);
 *
 * This overwrites the Blizzard `MeleeCheckForLosersAndVictors` with a
 * custom function that clears the event buffer first.
 */
export function installGameEndHook() {
  if (installed) {
    return;
  }

  originalCheckForLosersAndVictors = _G.MeleeCheckForLosersAndVictors as () => void;
  _G.MeleeCheckForLosersAndVictors = () => W3CEvents.end_game(originalCheckForLosersAndVictors);

  installed = true;
}
