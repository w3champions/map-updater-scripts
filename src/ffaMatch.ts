import { Timer } from "w3ts/index";

export function ffaMatch() {
	let playerCount = 0;
	let localPlayerId = GetPlayerId(GetLocalPlayer());
	let ffa = 0;
    for (let i = 0; i < bj_MAX_PLAYERS; i++){
        if (GetPlayerSlotState(Player(i)) == PLAYER_SLOT_STATE_PLAYING && !IsPlayerObserver(Player(i))){
            playerCount += 1;
			ffa += CountPlayersInForceBJ(GetPlayersAllies(Player(i)));
        }
    }
	if (playerCount > 2 && ffa == playerCount){
		for (let i = 0; i < bj_MAX_PLAYERS; i++){
			if (GetPlayerSlotState(Player(i)) == PLAYER_SLOT_STATE_PLAYING && !IsPlayerObserver(Player(i)) && i != localPlayerId){
				SetPlayerName( Player(i), ( GetLocalizedString("PLAYER") + " " + I2S(GetPlayerTeam(Player(i))+1) ) );
			}
		}
		initTimer(85*60, 5*60);	//set a 90 min timer
	}
}

function initTimer(revealDuration, matchEndDuration) {
    let minDeadline = (revealDuration + matchEndDuration) / 60;
	let minReminder = matchEndDuration/60;
	let revealTimer = new Timer();
	let matchEndTimer = new Timer();
	let playerCount = 0;
	let killTimersTrigger = CreateTrigger();
    DisplayTextToForce(GetPlayersAll(), `|cff00ff00[W3C]:|r This match has a max game length of ${minDeadline} minutes.`);
	DisplayTextToForce(GetPlayersAll(), `|cff00ff00[W3C]:|r If only 2 players are left by then, default win conditions will be restored.`);
	revealTimer.start(revealDuration, false, () => {	
		FogEnableOff();
		FogMaskEnableOff();
		CreateTimerDialogBJ(matchEndTimer.handle, "Match ends in:");
		matchEndTimer.start(matchEndDuration, false, () => {
			endMatch();
		});
		DisplayTextToForce(GetPlayersAll(), `This match will end in ${minReminder} minutes.`);
	});
	for (let i = 0; i < bj_MAX_PLAYERS; i++){
		TriggerRegisterPlayerEventDefeat(killTimersTrigger, Player(i));
		TriggerRegisterPlayerEventLeave(killTimersTrigger, Player(i));
	}
	TriggerAddAction( killTimersTrigger, () => {
		playerCount = 0;
		for (let i = 0; i < bj_MAX_PLAYERS; i++){
			if (GetPlayerSlotState(Player(i)) == PLAYER_SLOT_STATE_PLAYING && !IsPlayerObserver(Player(i))){
				playerCount += 1;
			}
		}
		if (playerCount == 2){
			revealTimer.pause();
			matchEndTimer.pause();
			DestroyTimerDialogBJ(GetLastCreatedTimerDialogBJ());
			FogEnableOn();
			FogMaskEnableOn();
			DisplayTextToForce(GetPlayersAll(), "Only 2 players are left. Default win conditions have been restored.");
		}
	});
}

function endMatch() {
    print("Ending match");
    let highestScore = 0;
    let winningTeam = -1;

    for (let i = 0; i < bj_MAX_PLAYERS; i++) {
        let playerScore = 0;
        let units = GetUnitsOfPlayerAll(Player(i));
        let team = GetPlayerTeam(Player(i));
        let firstUnit = FirstOfGroup(units);

        while (firstUnit != null) {
			let unitId = GetUnitTypeId(firstUnit);
			let heroXP = 0;
			if (IsHeroUnitId(unitId)) {
				heroXP = 200 + GetHeroXP(firstUnit);
				playerScore += heroXP;
			}

            GroupRemoveUnit(units, firstUnit);
            firstUnit = FirstOfGroup(units);
        }

        if (playerScore > highestScore) {
            highestScore = playerScore;
            winningTeam = team;
        }
    }

    for (let i = 0; i < bj_MAX_PLAYERS; i++) {
        if (GetPlayerController(Player(i)) == MAP_CONTROL_USER) {
            if (GetPlayerTeam(Player(i)) == winningTeam) {
                RemovePlayerPreserveUnitsBJ(Player(i), PLAYER_GAME_RESULT_VICTORY, false);
            } else {
                RemovePlayerPreserveUnitsBJ(Player(i), PLAYER_GAME_RESULT_DEFEAT, false);
            }
        }
    }
}