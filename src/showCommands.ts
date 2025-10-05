import { getGameMode, MapGameMode } from "./utils";

export function enableShowCommandsTrigger() {
    let showCommandsTrigger = CreateTrigger();
    let commands = `\n|cff00ff00[W3C Commands]:|r\n` +
    `  |cffffff00•|r Type|cffffff00 !flo|r for FLO details. (FLO games only)\n` +
    `  |cffffff00•|r Type|cffffff00 -draw|r to cancel game. Expires after 2 min. Disabled in tournaments.\n`;

    for (let i = 0; i < bj_MAX_PLAYERS; i++) {
        TriggerRegisterPlayerChatEvent(showCommandsTrigger, Player(i), "-commands", true);
        DisplayTextToPlayer(Player(i), 0, 0, `|cff00ff00[W3C]:|r To see available W3C commands, type|cffffff00 -commands|r.\n               `);
    }

    if (getGameMode() == MapGameMode.FOUR_VS_FOUR){
        commands += `  |cffffff00•|r Type|cffffff00 -gg|r to surrender (available from min 3). Can be initiated every 3 min.\n` +
        `     Completing the vote grants immunity to being reported for leaving early.\n` +
        `     Game counts as a loss. 3/4 votes required.\n`;
    }
    commands += `  |cffffff00•|r Type|cffffff00 -zoom <VALUE>|r to set zoom level. (1650 - 3000)\n` +
    `  |cffffff00•|r Type|cffffff00 -z|r or press|cffffff00 F5|r to reset zoom to preferred value.\n` +
    `  |cffffff00•|r Type|cffffff00 -deny|r to show/hide|cffffff00 !|r when a player's unit is denied.\n` +
    `  |cffffff00•|r Type|cffffff00 -workercount|r to show/hide goldmine worker count.\n` +
    `  |cffffff00•|r Type|cffffff00 -minimap|r to show/hide custom minimap icons.\n` +
    `  |cffffff00•|r Type|cffffff00 -clock|r to show/hide clock.\n` +
    `  |cffffff00•|r Type|cffffff00 -looticon|r to show/hide creep loot indicator.\n` +
    `  |cffffff00•|r Type|cffffff00 -lootpreview|r to show/hide creep loot preview on selection.`

    TriggerAddAction(showCommandsTrigger, () => {
        DisplayTimedTextToPlayer(GetTriggerPlayer(), 0, 0, 10, commands);
    });
}