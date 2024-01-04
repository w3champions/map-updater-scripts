export function hideGameButtons() {
    let hideGameButtons = CreateTrigger();
    TriggerRegisterTimerEventSingle(hideGameButtons, 0.00);
    TriggerAddAction(hideGameButtons, () => {
        BlzFrameSetVisible(BlzGetFrameByName("EscMenuSaveLoadContainer", 0), false);
        BlzFrameSetEnable(BlzGetFrameByName("SaveGameFileEditBox" , 0), false);
    });
}
