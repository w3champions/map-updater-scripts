import {Frame} from "w3ts";
import {getItemById} from "./items-db";
import {getAllItemIds, ItemDropSet, RandomItemGroupDrop} from "./unit-item-drops";

export class LootTableUI {
    static INSTANCE: LootTableUI;
    static readonly MAX_ITEMS = 4 * 3;

    private readonly mainParent!: Frame;
    private readonly itemBtnList: ItemBtn[] = [];
    private readonly allDropsBtn!: ItemBtn;

    static init() {
        LootTableUI.INSTANCE = new LootTableUI();
    }

    private constructor() {
        const tocFile = "loot-indicator\\ui\\ui.toc";
        if (!BlzLoadTOCFile(tocFile)) {
            print("Failed to load TOC for LootTableUI: " + tocFile)
            //Can you fail fast and log it? (e.g., to a war3 log file)
            //Because of return, it might crash a millisecond later and nobody will see the print
            return;
        }

        //ConsoleBottomBar scales based on "HUD scale" in-game option.
        //It is a parent for ORIGIN_FRAME_UBERTOOLTIP and all bottom part of the UI.
        //Parent for ConsoleBottomBar is ConsoleUI (aka ORIGIN_FRAME_SIMPLE_UI_PARENT) which does not scale.
        let bottomUiFrame = Frame.fromName("ConsoleBottomBar", 0);
        this.mainParent = Frame.createType("LI_Main_Parent", bottomUiFrame, 0, "SIMPLEFRAME", "")!;

        for (let i = 0; i < LootTableUI.MAX_ITEMS; i++) {
            const itemBtn = new ItemBtn(this.mainParent, i);
            itemBtn.btn.setAllPoints(Frame.fromOrigin(ORIGIN_FRAME_COMMAND_BUTTON, i)!)
            this.itemBtnList.push(itemBtn)
        }

        this.allDropsBtn = new ItemBtn(this.mainParent, LootTableUI.MAX_ITEMS)
        this.allDropsBtn.btn.clearPoints()
        this.allDropsBtn.btn.setSize(0.02, 0.02)
        this.allDropsBtn.btn.setPoint(FRAMEPOINT_BOTTOMRIGHT, Frame.fromOrigin(ORIGIN_FRAME_COMMAND_BUTTON, 11), FRAMEPOINT_BOTTOMRIGHT, 0, 0)
        this.allDropsBtn.btn.setLevel(7) //has to be above item icon
        this.allDropsBtn.setIcon("replaceabletextures\\commandbuttons\\btnchestofgold.dds")

        this.hide()
    }

    show(dropSets: ItemDropSet[]) {
        this.mainParent.setVisible(true)

        this.allDropsBtn.setTooltip(`|cffffff00Full loot table (${dropSets.length} drops)|r`, buildDropsInfoMsg(dropSets))

        let itemIds = getAllItemIds(dropSets);
        // Can't fit more than 12 right now.
        if (itemIds.length > LootTableUI.MAX_ITEMS) {
            itemIds = itemIds.slice(0, LootTableUI.MAX_ITEMS)
        }

        for (let i = 0; i < LootTableUI.MAX_ITEMS; i++) {
            const itemBtn = this.itemBtnList[i];
            const itemId = itemIds[i];

            if (itemId !== undefined) {
                itemBtn.btn.setVisible(true)

                const item = getItemById(itemId)!;
                itemBtn.setIcon(item.interfaceIcon)
                itemBtn.setTooltip(`|cffffff00${item.name}\n|cff00ff00[${item.classification}, Level ${item.level}]`,
                    item.extendedTooltip)
            } else {
                itemBtn.btn.setVisible(false)
            }
        }
    }

    hide() {
        this.mainParent.setVisible(false)
    }
}

class ItemBtn {
    btn: Frame;
    btnBackdrop: Frame;

    tooltip: Frame;
    tooltipBox: Frame;
    tooltipTitle: Frame;
    tooltipSeparator: Frame;
    tooltipDescription: Frame;

    constructor(owner: Frame, createContext: number) {
        //Buttons created on top of CommandBar have to be "SIMPLEBUTTON" to receive input (hover to show tooltip),
        //because non-SIMPLE frames have lower priority than SIMPLE, and the original CommandBar consists of SIMPLE frames.
        this.btn = Frame.createSimple("LI_ItemButton", owner, createContext)!;
        //NOTE: The draw order is not consistent. In rare cases our btn is drawn below the original one (but it does not matter for our case)
        this.btn.setLevel(6) //To draw above black background
        this.btnBackdrop = Frame.fromName("LI_ItemButton_Backdrop", createContext)!;

        this.tooltip = Frame.createSimple("LI_Tooltip", owner, 0)!;
        this.tooltipBox = Frame.fromName("LI_Tooltip_Box", 0)!;
        this.tooltipTitle = Frame.fromName("LI_Tooltip_Title", 0)!;
        this.tooltipSeparator = Frame.fromName("LI_Tooltip_Separator", 0)!;
        this.tooltipDescription = Frame.fromName("LI_Tooltip_Description", 0)!;

        //Wanted to make container box to be FIXED width and dynamic height (based on text).
        //It works, but I had to set FIXED width to "Description" and "Title" instead (and box size is relative to Description and Title)
        this.tooltipTitle.setWidth(0.285)
        this.tooltipTitle.setPoint(FRAMEPOINT_BOTTOMRIGHT, this.tooltipSeparator, FRAMEPOINT_TOPRIGHT, 0, 0.005)

        this.tooltipSeparator.setHeight(0.0005)
        this.tooltipSeparator.setPoint(FRAMEPOINT_BOTTOMLEFT, this.tooltipDescription, FRAMEPOINT_TOPLEFT, 0, 0.005)
        this.tooltipSeparator.setPoint(FRAMEPOINT_BOTTOMRIGHT, this.tooltipDescription, FRAMEPOINT_TOPRIGHT, 0, 0.005)

        this.tooltipDescription.setWidth(0.285)
        this.tooltipDescription.setPoint(FRAMEPOINT_BOTTOMRIGHT, owner, FRAMEPOINT_BOTTOMRIGHT, -0.01, 0.168)

        this.tooltipBox.setPoint(FRAMEPOINT_TOPLEFT, this.tooltipTitle, FRAMEPOINT_TOPLEFT, -0.005, 0.005)
        this.tooltipBox.setPoint(FRAMEPOINT_BOTTOMRIGHT, this.tooltipDescription, FRAMEPOINT_BOTTOMRIGHT, 0.005, -0.005)

        this.btn.setTooltip(this.tooltip)
        //Need to initially manually hide.
        //Need to hide both tooltip and tooltipBox frames likely because "tooltip" is a SIMPLEFRAME,
        // while "tooltipBox" is not ("BACKDROP" is a normal frame).
        // "SIMPLEBUTTON" only supports "SIMPLEFRAME" as a tooltip
        this.tooltip.setVisible(false)
        this.tooltipBox.setVisible(false)
    }

    setIcon(iconFilePath: string) {
        this.btnBackdrop.setTexture(iconFilePath, 0, false)
    }

    setTooltip(title: string, description: string) {
        this.tooltipTitle.setText(title);
        this.tooltipDescription.setText(description);
    }
}

/*
    == Drop 1 [Permanent, Level 1]
      Slipper of Agility
      Ring of Health
    == Drop 2 [Custom drop pool] //List of specific items
      Sentry Ward
      Ring of Health
    == Drop 3 [Custom drop pool] //Mix of specific items and GroupDrops
      Slipper of Agility
      Sentry Ward
      [Permanent, Level 1]
      - Ring of Health
      - Sentry Ward
      [Permanent, Level 2]
      - Ring of Health
 */
function buildDropsInfoMsg(sets: ItemDropSet[]): string {
    return sets.map((set, i) => {
        let m = `|cffffff00== Drop ${i + 1} `;

        //Short most common form
        if (set.itemDrops.length === 1 && set.itemDrops[0] instanceof RandomItemGroupDrop) {
            const drop = set.itemDrops[0] as RandomItemGroupDrop;
            m += `|cff00ff00[${drop.itemGroup.itemClass}, Level ${drop.itemGroup.itemLevel}]|r\n`
            m += set.itemDrops.flatMap(d => d.getDropItemIds())
                .map(id => `  ${getItemById(id)!.name}`)
                .join("\n")
        //A set that contains a list of specific items or multiple GroupDrops, or a mix of both
        } else {
            m += `|cff00ff00[Custom drop pool]|r\n`
            m += set.itemDrops.map(d => {
                if (d instanceof RandomItemGroupDrop) {
                    return `  |cff00ff00[${d.itemGroup.itemClass}, Level ${d.itemGroup.itemLevel}]|r\n` +
                        d.getDropItemIds()
                            .map(id => `  - ${getItemById(id).name}`)
                            .join("\n")
                } else {
                    return `  ${getItemById(d.getRawId()).name}`
                }
            }).join("\n")
        }

        return m;
    }).join("\n");
}
