export function enableShowCommandsTrigger() {
    let showCommandsTrigger = CreateTrigger();

    for (let i = 0; i < bj_MAX_PLAYERS; i++) {
        TriggerRegisterPlayerChatEvent(showCommandsTrigger, Player(i), "-commands", true);
        DisplayTextToPlayer(Player(i), 0, 0, `|cff00ff00[W3C]:|r To see available W3C commands, type|cffffff00 -commands|r.\n               For FLO details, type|cffffff00 -flo|r (FLO games only).`);
    }

    TriggerAddAction(showCommandsTrigger, () => {
        DisplayTextToPlayer(GetTriggerPlayer(), 0, 0, `\n|cff00ff00[W3C Commands]:|r\n` +
                                                      `  |cffffff00•|r To cancel game due to bad ping, all players must use|cffffff00 -badping|r.\n      This command expires 2 minutes into the game.\n` +
                                                      `  |cffffff00•|r Type|cffffff00 -zoom <VALUE>|r to change your zoom level.\n       Default Value: 1650 | Minimum: 1650 | Maximum: 3000\n` + 
                                                      `  |cffffff00•|r Type|cffffff00 -deny|r to either enable (or disable) showing |cffffff00 !|r when\n      a player's unit is denied`);
    });
}