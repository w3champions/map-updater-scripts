export function enableShowCommandsTrigger() {
    let showCommandsTrigger = CreateTrigger();

    for (let i = 0; i < bj_MAX_PLAYERS; i++) {
        TriggerRegisterPlayerChatEvent(showCommandsTrigger, Player(i), "-commands", true);
        DisplayTextToPlayer(Player(i), 0, 0, `|cff00ff00[W3C]:|r To see available W3C commands, type|cffffff00 -commands|r.`);
    }

    TriggerAddAction(showCommandsTrigger, () => {
        print("\n");
        DisplayTextToPlayer(GetTriggerPlayer(), 25, 0, `|cff00ff00[W3C Commands]:|r`);
        DisplayTextToPlayer(GetTriggerPlayer(), 25, 0, `  |cffffff00•|r To cancel this game due to bad ping, all players must use|cffffff00 -badping|r.\n      This command expires 2 minutes into the game.`);
        DisplayTextToPlayer(GetTriggerPlayer(), 0, 0,  `  |cffffff00•|r Type|cffffff00 -zoom <VALUE>|r to change your zoom level. Default: 1650\n      Minimum zoom: 1650 | Maximum zoom: 3000`);
        DisplayTextToPlayer(GetTriggerPlayer(), 0, 0,  `  |cffffff00•|r Type|cffffff00 -deny|r to either enable or disable showing |cffffff00 !|r when a player's unit is denied`);
    });
}