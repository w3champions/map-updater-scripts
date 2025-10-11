enum GameStatus {
	ONLINE_OR_LAN,
	OFFLINE,
	REPLAY
}

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
			const gameStatus = getGameStatus();

			if (gameStatus === GameStatus.ONLINE_OR_LAN) {
				BlzFrameSetVisible(escMenuSaveLoadContainer, false);
				BlzFrameSetEnable(saveGameFileEditBox, false);
				BlzFrameSetVisible(exitButton, false);
				BlzFrameSetEnable(confirmQuitQuitButton, false);
				BlzFrameSetText(confirmQuitMessageText, 'Please use Quit Mission instead.');
			}
		}
	});
}

function getGameStatus() {
	// Based on https://www.hiveworkshop.com/threads/gamestatus-replay-detection.293181/
	// Note: Will remove a small radius of black fog at a player's start location - May be undesired on some custom maps
	let i = 0;

	for (; i < 12; i++) {
		if (GetPlayerController(Player(i)) === MAP_CONTROL_USER && GetPlayerSlotState(Player(i)) === PLAYER_SLOT_STATE_PLAYING) {
			break;
		}
	}

	const sl = GetPlayerStartLocation(Player(i));
	const x = GetStartLocationX(sl);
	const y = GetStartLocationY(sl);
	// nvul is vulture, has low sight range
	const unit = CreateUnit(Player(i), FourCC('nvul'), x, y, 0);
	SelectUnitForPlayerSingle(unit, Player(i));
	const isUnitSelected = IsUnitSelected(unit, Player(i));
	RemoveUnit(unit);

	if (isUnitSelected) {
		if (ReloadGameCachesFromDisk()) {
			return GameStatus.OFFLINE;
		} else {
			return GameStatus.REPLAY;
		}
	}

	return GameStatus.ONLINE_OR_LAN;
}