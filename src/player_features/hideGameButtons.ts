export function hideGameButtons() {
    let hideGameButtons = CreateTrigger();
    TriggerRegisterTimerEventSingle(hideGameButtons, 0.00);
    TriggerAddAction(hideGameButtons, () => {
        BlzFrameSetVisible(BlzGetFrameByName("EscMenuSaveLoadContainer", 0), false);
        BlzFrameSetEnable(BlzGetFrameByName("SaveGameFileEditBox" , 0), false);
        BlzFrameSetVisible(BlzGetFrameByName("ExitButton" , 0), false);
        BlzFrameSetEnable(BlzGetFrameByName("ConfirmQuitQuitButton" , 0), false);
        BlzFrameSetText(BlzGetFrameByName("ConfirmQuitMessageText", 0), "Please use Quit Mission instead.");
    });
}
