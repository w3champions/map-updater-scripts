export function enableShowCommandsTrigger() {
    let showCommandsTrigger = CreateTrigger();

    for (let i = 0; i < bj_MAX_PLAYERS; i++) {
        TriggerRegisterPlayerChatEvent(showCommandsTrigger, Player(i), "-commands", true);
        DisplayTextToPlayer(Player(i), 0, 0, `|cff00ff00[W3C]:|r To see available W3C commands, type|cffffff00 -commands|r.\n               `);
    }

    TriggerAddAction(showCommandsTrigger, () => {
        DisplayTimedTextToPlayer(GetTriggerPlayer(), 0, 0, 10, `\n|cff00ff00[W3C Commands]:|r\n` +
            `  |cffffff00•|r Type|cffffff00 !flo|r for FLO details. (FLO games only)\n` +
            `  |cffffff00•|r Type|cffffff00 -draw|r to cancel game. Expires after 2 min. Disabled in tournaments.\n` +
            `  |cffffff00•|r Type|cffffff00 -gg|r to surrender (4v4 only). Can be initiated every 3 min.\n` +
            `     Completing the vote grants immunity to being reported for leaving early.\n` +
            `     Game counts as a loss. 3/4 votes required.\n` +
            `  |cffffff00•|r Type|cffffff00 -zoom <VALUE>|r to set zoom level. (1650 - 3000)\n` +
            `  |cffffff00•|r Type|cffffff00 -z|r or press|cffffff00 F5|r to reset zoom to preferred value.\n` +
            `  |cffffff00•|r Type|cffffff00 -deny|r to show/hide|cffffff00 !|r when a player's unit is denied.\n` +
            `  |cffffff00•|r Type|cffffff00 -workercount|r to show/hide goldmine worker count.`);
    });
}