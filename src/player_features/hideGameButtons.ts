export function hideGameButtons() {
    let hideGameButtons = CreateTrigger();
    TriggerRegisterTimerEventSingle(hideGameButtons, 0.00);
    TriggerAddAction(hideGameButtons, () => {
        // Get all BlzGetFrameByName handles outside of local scope to prevent async issues
		const escMenuSaveLoadContainer: framehandle = BlzGetFrameByName('EscMenuSaveLoadContainer', 0);
		const saveGameFileEditBox: framehandle = BlzGetFrameByName('SaveGameFileEditBox', 0);
		const exitButton: framehandle = BlzGetFrameByName('ExitButton', 0);
		const confirmQuitQuitButton: framehandle = BlzGetFrameByName('ConfirmQuitQuitButton', 0);
		const confirmQuitMessageText: framehandle = BlzGetFrameByName('ConfirmQuitMessageText', 0);

		if (!IsPlayerObserver(GetLocalPlayer())) {
			BlzFrameSetVisible(escMenuSaveLoadContainer, false);
			BlzFrameSetEnable(saveGameFileEditBox, false);
			BlzFrameSetVisible(exitButton, false);
			BlzFrameSetEnable(confirmQuitQuitButton, false);
			BlzFrameSetText(confirmQuitMessageText, 'Please use Quit Mission instead.');
		}
    });
}
