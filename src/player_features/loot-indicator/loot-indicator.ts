import {Effect, MapPlayer, Trigger, Unit, File, Timer} from "w3ts";
import {
    findMapInitialCreepsWithDrops,
    getAllItemIds,
    ItemDrop,
    ItemDropSet,
    RandomItemGroupDrop,
    UnitItemDrop
} from "./modules/unit-item-drops";
import {ItemClass} from "./modules/item-groups";
import {initItemsDB} from "./modules/items-db";
import {
    calcUnitHpBarPosition,
    initIsReforgedUnitModelsEnabledLocal,
} from "./modules/unit-hp-bar-position-calculator";
import {LootTableUI} from "./modules/loot-table-ui";

//For local player. Veriest per player.
let IS_INDICATOR_ENABLED_LOCAL = false;
let IS_PREVIEW_ENABLED_LOCAL = false;

let ACTIVE_INDICATORS = new Map<unit, UnitLootIndicator>();

export function enableCreepLootIndicator() {
    initItemsDB();
    initIsReforgedUnitModelsEnabledLocal();

    IS_INDICATOR_ENABLED_LOCAL = loadIsIndicatorEnabled();
    const unitsWithDrops = findMapInitialCreepsWithDrops();
    createIndicators(unitsWithDrops);
    enableIndicatorFeatureToggleChatCommand()

    IS_PREVIEW_ENABLED_LOCAL = loadIsPreviewEnabled();
    enableLootTablePreviewUI();
    enablePreviewFeatureToggleChatCommand()
}

function loadIsIndicatorEnabled(): boolean {
    return (File.read("w3cCreepLootIndicator.txt") ?? "on") === "on";
}

function saveIsIndicatorEnabled(isEnabled: boolean) {
    File.write("w3cCreepLootIndicator.txt", isEnabled ? "on" : "off");
}

function loadIsPreviewEnabled(): boolean {
    return (File.read("w3cCreepLootPreview.txt") ?? "on") === "on";
}

function saveIsPreviewEnabled(isEnabled: boolean) {
    File.write("w3cCreepLootPreview.txt", isEnabled ? "on" : "off");
}

function createIndicators(unitsWithDrops: UnitItemDrop[]) {
    for (const unitWithDrop of unitsWithDrops) {
        const indicator = UnitLootIndicator.create(unitWithDrop);
        IS_INDICATOR_ENABLED_LOCAL ? indicator.enable() : indicator.disable();

        ACTIVE_INDICATORS.set(indicator.unit.handle, indicator);

        registerUnitItemDroppedEvent(indicator.unit, () => {
            indicator.destroy();
            ACTIVE_INDICATORS.delete(indicator.unit.handle);
        });
    }
}

function registerUnitItemDroppedEvent(unit: Unit, action: () => void) {
    const t = Trigger.create();
    t.registerUnitEvent(unit, EVENT_UNIT_DEATH)
    t.registerUnitEvent(unit, EVENT_UNIT_CHANGE_OWNER)
    t.addAction(() => {
        action();
        t.destroy();
    });
}

function enableIndicatorFeatureToggleChatCommand() {
    const t = Trigger.create();
    for (let i = 0; i < bj_MAX_PLAYERS; i++) {
        t.registerPlayerChatEvent(MapPlayer.fromIndex(i)!, "-looticon", true);
    }
    t.addAction(() => {
        const player = MapPlayer.fromEvent()!;
        if (player.isLocal()) {
            IS_INDICATOR_ENABLED_LOCAL = !IS_INDICATOR_ENABLED_LOCAL;
            saveIsIndicatorEnabled(IS_INDICATOR_ENABLED_LOCAL);

            ACTIVE_INDICATORS.forEach(indicator => {
                IS_INDICATOR_ENABLED_LOCAL ? indicator.enable() : indicator.disable()
            });
            DisplayTextToPlayer(player.handle, 0, 0, `|cff00ff00[W3C]:|r Creep loot indicator is now |cffffff00 ` + (IS_INDICATOR_ENABLED_LOCAL ? `ENABLED` : `DISABLED`) + `|r.`)
        }
    })
}

function enablePreviewFeatureToggleChatCommand() {
    const t = Trigger.create();
    for (let i = 0; i < bj_MAX_PLAYERS; i++) {
        t.registerPlayerChatEvent(MapPlayer.fromIndex(i)!, "-lootpreview", true);
    }
    t.addAction(() => {
        const player = MapPlayer.fromEvent()!;
        if (player.isLocal()) {
            IS_PREVIEW_ENABLED_LOCAL = !IS_PREVIEW_ENABLED_LOCAL;
            saveIsPreviewEnabled(IS_PREVIEW_ENABLED_LOCAL);

            if (!IS_PREVIEW_ENABLED_LOCAL) {
                LootTableUI.INSTANCE.hide();
            }
            DisplayTextToPlayer(player.handle, 0, 0, `|cff00ff00[W3C]:|r Creep loot preview is now |cffffff00 ` + (IS_PREVIEW_ENABLED_LOCAL ? `ENABLED` : `DISABLED`) + `|r.`)
        }
    })
}

function getSingleGroupDrop(itemDropSets: ItemDropSet[]): RandomItemGroupDrop | undefined {
    if (itemDropSets.length === 1 && itemDropSets[0].itemDrops.length === 1
        && itemDropSets[0].itemDrops[0] instanceof RandomItemGroupDrop) {
        return itemDropSets[0].itemDrops[0];
    }
}

function isTomeDrop(itemDrop: ItemDrop): boolean {
    if (itemDrop instanceof RandomItemGroupDrop) {
        const group = itemDrop.itemGroup;
        return group.itemClass === ItemClass.Power_Up &&
            (group.itemLevel === 1 || group.itemLevel === 2)
    }

    return false;
}

function enableLootTablePreviewUI() {
    LootTableUI.init();

    const t = Trigger.create();
    t.registerAnyUnitEvent(EVENT_PLAYER_UNIT_SELECTED);
    t.addAction(() => {
        const player = MapPlayer.fromEvent()!;
        if (player.isLocal() && IS_PREVIEW_ENABLED_LOCAL) {
            const indicator = ACTIVE_INDICATORS.get(Unit.fromEvent()!.handle);
            if (indicator !== undefined) {
                LootTableUI.INSTANCE.show(getAllItemIds(indicator.itemDropSets));
            } else {
                LootTableUI.INSTANCE.hide();
            }
        }
    })
}

class UnitLootIndicator {
    readonly unit: Unit;
    readonly itemDropSets: ItemDropSet[];

    private readonly indicatorEffect: Effect;
    private readonly indicatorScale: number;
    private isEnabled: boolean;
    private updateUnitTimer?: Timer;

    constructor(unit: Unit, itemDropSets: ItemDropSet[], indicatorEffect: Effect) {
        this.unit = unit;
        this.itemDropSets = itemDropSets;
        this.indicatorEffect = indicatorEffect;
        this.indicatorScale = indicatorEffect.scale;
        this.isEnabled = true;
    }

    static create(unitItemDrop: UnitItemDrop): UnitLootIndicator {
        const unit = unitItemDrop.unit;
        const itemDropSets = unitItemDrop.dropSets;
        let e: Effect;

        //In 99% of cases a unit has a single set (drops 1 item) with a single group item drop (can drop any item from that group)
        const groupDrop = getSingleGroupDrop(itemDropSets);
        if (groupDrop && isTomeDrop(groupDrop)) {
            e = Effect.create("loot-indicator\\loot-indicator-tome.mdx", 0, 0)!;
        } else {
            e = Effect.create("loot-indicator\\loot-indicator-generic.mdx", 0, 0)!;
        }

        //For units with mana bar, we adjust the position of the effect model with animation
        //We don't use Z offset for effect in the world, because that will affect "billboarding",
        //and will lead to the effect slightly shifting relative to HP bar depending on the camera angle
        if (unit.maxMana > 0) {
            e.playAnimation(ANIM_TYPE_STAND)
        } else {
            e.playAnimation(ANIM_TYPE_WALK)
        }

        const indicator = new UnitLootIndicator(unit, itemDropSets, e);
        indicator.enableUpdateUnit();
        return indicator;
    }

    disable() {
        if (!this.isEnabled) return;
        this.isEnabled = false;

        this.hide();
    }

    enable() {
        if (this.isEnabled) return;
        this.isEnabled = true;

        this.show();
    }

    private hide() {
        this.indicatorEffect.scale = 0;
    }

    private show() {
        this.indicatorEffect.scale = this.indicatorScale;
    }

    destroy() {
        this.updateUnitTimer?.destroy();
        this.indicatorEffect.destroy();
    }

    private enableUpdateUnit() {
        this.updateUnitTimer = Timer.create()!;
        this.updateUnitTimer.start(0.01, true, () => {
            if (!this.isEnabled) return;

            //Handle invisible units (Murloc Nightcrawler)
            if (!this.unit.isVisible(MapPlayer.fromLocal())) {
                this.hide();
                return;
            } else {
                this.show();
            }

            const hpBarPos = calcUnitHpBarPosition(this.unit);
            this.indicatorEffect.setPosition(hpBarPos.x, hpBarPos.y, hpBarPos.z);
        })
    }
}