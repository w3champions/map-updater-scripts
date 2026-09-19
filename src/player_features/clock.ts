import {File, MapPlayer, Trigger} from "w3ts/index";

function Sec2Timer(i: number): string {
    let timeString = "Time: "
    const timeMin = math.floor(i / 60)
    const timeSec = i - (timeMin * 60)
    if (timeMin < 100)
        timeString = timeString + " "

    if (timeMin < 10)
        timeString = timeString + "0"

    timeString = timeString + timeMin + ":"
    if (timeSec < 10)
        timeString = timeString + "0"

    timeString = timeString + timeSec
    return timeString
}

let GameTimeSec: number = 0
let isClockEnabled: boolean = true
let clockTimer: timer = CreateTimer()

function startClockTimer() {
    TimerStart(clockTimer, 1, true, () => {
        let timerTextFrame = BlzGetFrameByName("GameTime", 0)
        GameTimeSec = GameTimeSec + 1
        // Prevents the timer from going beyond 99:59
        if (GameTimeSec >= 60000) // 1000 minutes in seconds
            GameTimeSec = 59999 // Cap at 999:59

        BlzFrameSetText(timerTextFrame, Sec2Timer(GameTimeSec))
    });
}

export function enableClock() {
    let FH = BlzCreateFrameByType("TEXT", "GameTime", 
        BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), "", 0)
    BlzFrameSetAbsPoint(FH, FRAMEPOINT_CENTER, 0.465, 0.563)
    BlzFrameSetScale(FH, 1.0)
    BlzFrameSetText(FH, "Time:  00:00")
    BlzFrameSetTextColor(FH, BlzConvertColor(255, 205, 205, 50))

    // if the clock is disabled, hide the frame

    let toggleClock = CreateTrigger();
    for (let i = 0; i < bj_MAX_PLAYERS; i++) {
        let isLocalPlayer = MapPlayer.fromHandle(Player(i)).name == MapPlayer.fromLocal().name;
        if (isLocalPlayer) {
            const fileText = File.read("w3cClock.txt")

            if (fileText) {
                isClockEnabled = (fileText == "true");
            }
        }
        BlzFrameSetVisible(FH, isClockEnabled)
        TriggerRegisterPlayerChatEvent(toggleClock, Player(i), "-clock", true);
    }

    startClockTimer();

    TriggerAddAction(toggleClock, () => {
        let triggerPlayer = MapPlayer.fromEvent()
        let localPlayer = MapPlayer.fromLocal()

        // Making sure that enable/disable only if the local player is the one who called the command
        if (triggerPlayer.name != localPlayer.name)
            return

        isClockEnabled = !isClockEnabled
        DisplayTextToPlayer(triggerPlayer.handle, 0, 0, `\n|cff00ff00[W3C]:|r Game time clock is now |cffffff00 ` + (isClockEnabled ? `ENABLED` : `DISABLED`) + `|r.`)

        BlzFrameSetVisible(BlzGetFrameByName("GameTime", 0), isClockEnabled)

        File.write("w3cClock.txt", isClockEnabled.toString());
    });
}

export function pauseClockW3C(pause: boolean) {
    if (pause) {
        PauseTimer(clockTimer);
    } else {
        //Can't use native `ResumeTimer()` because it has a bug and stops the timer after 2 seconds
        //See https://lep.nrw/jassbot/doc/ResumeTimer
        //Instead we're restarting the clock. Might affect TimerGetRemaining() function, but it is not used
        startClockTimer();
    }
}
