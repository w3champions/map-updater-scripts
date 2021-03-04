export function enableShowCommandsTrigger() {
    let showCommandsTrigger = CreateTrigger();

    for (let i = 0; i < bj_MAX_PLAYERS; i++) {
        TriggerRegisterPlayerChatEvent(showCommandsTrigger, Player(i), "-commands", true);
        DisplayTextToPlayer(Player(i), 0, 0, `|cff00ff00[W3C]:|r To see available W3C commands, type|cffffff00 -commands|r.\n               `);
    }

    TriggerAddAction(showCommandsTrigger, () => {
        DisplayTimedTextToPlayer(GetTriggerPlayer(), 0, 0, 10, `\n|cff00ff00[W3C Commands]:|r\n` +
            `  |cffffff00•|r For FLO details, type|cffffff00 !flo|r (FLO games only). \n` +
            `  |cffffff00•|r Type|cffffff00 -badping|r to cancel game. Expires after 2 minutes.\n` +
            `  |cffffff00•|r Type|cffffff00 -zoom <VALUE>|r to set zoom level. (1650 - 3000)\n` +
            `  |cffffff00•|r Type|cffffff00 -z|r or press|cffffff00 F5|r to reset zoom to preferred value.\n` +
            `  |cffffff00•|r Type|cffffff00 -deny|r to show/hide|cffffff00 !|r when a player's unit is denied.\n` +
            `  |cffffff00•|r Type|cffffff00 -workercount|r to show/hide goldmine worker count.`);
    });
}