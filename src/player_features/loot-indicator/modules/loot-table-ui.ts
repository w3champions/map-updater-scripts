import {Frame} from "w3ts";
import {getItemById} from "./items-db";

export class LootTableUI {
    static INSTANCE: LootTableUI;
    static readonly MAX_ITEMS = 4 * 3;

    private readonly mainParent!: Frame;
    private readonly itemBtnList: ItemBtn[] = [];

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

        this.mainParent = Frame.createType("LI_Main_Parent", Frame.fromOrigin(ORIGIN_FRAME_SIMPLE_UI_PARENT, 0)!, 0, "SIMPLEFRAME", "")!;
        for (let i = 0; i < LootTableUI.MAX_ITEMS; i++) {
            const itemBtn = new ItemBtn(this.mainParent, i);
            //ORIGIN_FRAME_COMMAND_BUTTON is available even in Replays (where commandbar is hidden by replay controls)
            itemBtn.btn.setPoint(FRAMEPOINT_CENTER, Frame.fromOrigin(ORIGIN_FRAME_COMMAND_BUTTON, i)!, FRAMEPOINT_CENTER, 0, 0)
            this.itemBtnList.push(itemBtn)
        }

        this.hide()
    }

    show(itemIds: string[]) {
        this.mainParent.setVisible(true)

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
        this.tooltipDescription.setAbsPoint(FRAMEPOINT_BOTTOMRIGHT, 0.79, 0.168)

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