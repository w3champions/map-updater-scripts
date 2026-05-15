import {Timer} from "w3ts";
import {pauseClockW3C} from "./player_features/clock";

const COUNTDOWN_START = 5;
const COUNTDOWN_SOUND = CreateSound("Sound\\Interface\\BattleNetTick.wav", false, false, false, 10, 10, "",);

export function enableStartGameCountdown() {
    pauseGameW3C(true);

    for (let count = COUNTDOWN_START; count >= 0; count--) {
        // This is a workaround for Lua.
        // Passing `count` directly to the callback results in passing a reference that will be 0 at execution time.
        const cc = count;
        Timer.create().start(COUNTDOWN_START - count, false, () => onCountdown(cc));
    }
}

function onCountdown(count: number) {
    if (count === 0) {
        pauseGameW3C(false);
        ClearTextMessages();
        return;
    }

    print(`|cff00ff00[W3C]:|r Starting in ${count}...`);
    StartSound(COUNTDOWN_SOUND);
}

function pauseGameW3C(pause: boolean) {
    PauseAllUnitsBJ(pause);
    SuspendTimeOfDay(pause);
    pauseClockW3C(pause);
}
