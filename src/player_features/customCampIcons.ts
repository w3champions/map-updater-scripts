import { File, MapPlayer } from "w3ts/index";

let CustomIcons = {};
let MadeIcons = [];
let areCustomCampIconsEnabled = true;

export function enableCustomCampIcons() {
    CustomIcons[FourCC("ngad")] = "UI/MiniMap/MiniMap-Laboratory.mdx";

    CustomIcons[FourCC("nmer")] = "UI/MiniMap/MiniMap-Mercenary.mdx";
    CustomIcons[FourCC("nmr2")] = "UI/MiniMap/MiniMap-Mercenary.mdx";
    CustomIcons[FourCC("nmr3")] = "UI/MiniMap/MiniMap-Mercenary.mdx";
    CustomIcons[FourCC("nmr4")] = "UI/MiniMap/MiniMap-Mercenary.mdx";
    CustomIcons[FourCC("nmr5")] = "UI/MiniMap/MiniMap-Mercenary.mdx";
    CustomIcons[FourCC("nmr5")] = "UI/MiniMap/MiniMap-Mercenary.mdx";
    CustomIcons[FourCC("nmr6")] = "UI/MiniMap/MiniMap-Mercenary.mdx";
    CustomIcons[FourCC("nmr7")] = "UI/MiniMap/MiniMap-Mercenary.mdx";
    CustomIcons[FourCC("nmr8")] = "UI/MiniMap/MiniMap-Mercenary.mdx";
    CustomIcons[FourCC("nmr9")] = "UI/MiniMap/MiniMap-Mercenary.mdx";
    CustomIcons[FourCC("nmr0")] = "UI/MiniMap/MiniMap-Mercenary.mdx";
    CustomIcons[FourCC("nmra")] = "UI/MiniMap/MiniMap-Mercenary.mdx";
    CustomIcons[FourCC("nmrb")] = "UI/MiniMap/MiniMap-Mercenary.mdx";
    CustomIcons[FourCC("nmrc")] = "UI/MiniMap/MiniMap-Mercenary.mdx";
    CustomIcons[FourCC("nmrd")] = "UI/MiniMap/MiniMap-Mercenary.mdx";
    CustomIcons[FourCC("nmre")] = "UI/MiniMap/MiniMap-Mercenary.mdx";
    CustomIcons[FourCC("nmrf")] = "UI/MiniMap/MiniMap-Mercenary.mdx";

    CustomIcons[FourCC("ngme")] = "UI/MiniMap/MiniMap-Shop.mdx";
    CustomIcons[FourCC("nmrk")] = "UI/MiniMap/MiniMap-Shop.mdx";

    CustomIcons[FourCC("ntav")] = "UI/MiniMap/MiniMap-Tavern.mdx";

    let toggleCustomIcons = CreateTrigger();
    for (let i = 0; i < bj_MAX_PLAYERS; i++) {
        let isLocalPlayer = MapPlayer.fromHandle(Player(i)).name == MapPlayer.fromLocal().name;
        if (isLocalPlayer) {
            const fileText = File.read("w3cCampIcons.txt")

            if (fileText) {
                areCustomCampIconsEnabled = (fileText == "true");
            }
        }
            TriggerRegisterPlayerChatEvent(toggleCustomIcons, Player(i), "-minimap", true);
    }

    ForGroup(GetUnitsInRectAll(GetPlayableMapRect()), () => {
        if (CustomIcons[GetUnitTypeId(GetEnumUnit())] != null) {
            let x = Math.floor(GetUnitX(GetEnumUnit()) / 128) * 128;
            let y = Math.floor(GetUnitY(GetEnumUnit()) / 128) * 128;
            let icon = CreateMinimapIcon(x, y, 255, 255, 255,
            CustomIcons[GetUnitTypeId(GetEnumUnit())], FOG_OF_WAR_FOGGED);
            SetMinimapIconVisible(icon, areCustomCampIconsEnabled);
            MadeIcons.push(icon);
        }
    });

    TriggerAddAction(toggleCustomIcons, () => {
        let triggerPlayer = MapPlayer.fromEvent()
        let localPlayer = MapPlayer.fromLocal()

        // Making sure that enable/disable only if the local player is the one who called the command
        if (triggerPlayer.name != localPlayer.name)
            return

            areCustomCampIconsEnabled = !areCustomCampIconsEnabled
        DisplayTextToPlayer(triggerPlayer.handle, 0, 0, `\n|cff00ff00[W3C]:|r Custom Neutral Building Icons are now |cffffff00 ` + (areCustomCampIconsEnabled ? `ENABLED` : `DISABLED`) + `|r.`)

        MadeIcons.forEach(icon => {
            SetMinimapIconVisible(icon, areCustomCampIconsEnabled);
        });
        File.write("w3cCampIcons.txt", areCustomCampIconsEnabled.toString());
    });
}