export function anonymizePlayerNames() {
    let localPlayerId = GetPlayerId(GetLocalPlayer());

    for (let i = 0; i < bj_MAX_PLAYERS; i++) {
        if (GetPlayerSlotState(Player(i)) == PLAYER_SLOT_STATE_PLAYING && !IsPlayerObserver(Player(i)) && i != localPlayerId) {
            SetPlayerName(Player(i), (GetLocalizedString("PLAYER") + " " + I2S(GetPlayerTeam(Player(i)) + 1)));
        }
    }
}