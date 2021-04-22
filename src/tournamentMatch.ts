import { Timer } from "w3ts/index";

export function endTournamentMatch() {
    print("Ending match");
    let highestScore = 0
    let winningTeam = -1;

    for (let i = 0; i < bj_MAX_PLAYERS; i++) {
        let playerScore = 0;
        let units = GetUnitsOfPlayerAll(Player(i));
        let team = GetPlayerTeam(Player(i));
        let firstUnit = FirstOfGroup(units);

        while (firstUnit != null) {
            if (IsUnitAliveBJ(firstUnit)) {
                let unitId = GetUnitTypeId(firstUnit);

                let heroXP = 0;
                if (IsHeroUnitId(unitId)) {
                    heroXP = 200 + GetHeroXP(firstUnit);
                    playerScore += heroXP;
                } else {
                    //Exclude Zeppelin from counting towards playerScore
                    if (unitId != 1853515120) {
                        playerScore += (GetUnitGoldCost(unitId) + GetUnitWoodCost(unitId));
                    }
                }
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

export function initMatchEndTimers(revealDuration, matchEndDuration) {
    let minutes = (revealDuration + matchEndDuration) / 60;
    DisplayTextToForce(GetPlayersAll(), `|cff00ff00[W3C]:|r This match has a max game length of ${minutes} minutes.`)
    let timer = new Timer()
    timer.start(revealDuration, false, () => {
        FogMaskEnableOff()
        FogEnableOff()
        let matchEndTimer = new Timer();
        CreateTimerDialogBJ(matchEndTimer.handle, "Match ends in:")
        matchEndTimer.start(matchEndDuration, false, () => {
            endTournamentMatch();
        })
        DisplayTextToForce(GetPlayersAll(), "This match will end in 5 minutes.")
    });
}