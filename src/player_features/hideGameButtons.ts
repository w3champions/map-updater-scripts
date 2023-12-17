export function hideGameButtons() {
    let hideGameButtons = CreateTrigger();
    TriggerRegisterTimerEventSingle(hideGameButtons, 0.00);
    TriggerAddAction(hideGameButtons, () => {
        BlzFrameSetVisible(BlzGetFrameByName("SaveGameButton", 0), false);
        BlzFrameSetVisible(BlzGetFrameByName("LoadGameButton", 0), false);
    });
}