import * as W3CEvents from "../lua/w3cEvents";

// So we can override blizzard functions
declare const _G: Record<string, any>;

let installed = false;
let pendingGameEnd = false;

let originalCheckForLosersAndVictors: () => void;

function endGame(originalGameEnd: () => void) {
  if (pendingGameEnd) {
    return;
  }

  pendingGameEnd = true;

  W3CEvents.end_game(originalGameEnd)
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
  _G.MeleeCheckForLosersAndVictors = endGame(originalCheckForLosersAndVictors);

  installed = true;

}
