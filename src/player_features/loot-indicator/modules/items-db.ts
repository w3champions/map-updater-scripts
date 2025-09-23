import {ItemClass, ItemGroup, itemGroup2FourCC, VALID_LEVELS} from "./item-groups";
import {File, Item, Rectangle, Timer} from "w3ts";
import {Items} from "@objectdata/items";

interface CompiletimeItem {
    includeAsRandomChoice: boolean;
}

const COMPILETIME_ITEM_DATA = compiletime(() => {
    const fs = require("fs-extra");
    return JSON.parse(fs.readFileSync("./scripts/loot-indicator/items-db/extracted-items-data.json", "utf8"));
}) as Record<string, CompiletimeItem>;

class ItemInfo {
    id: string;
    name: string;
    classification: ItemClass;
    level: number;
    extendedTooltip: string;
    interfaceIcon: string;
    includeAsRandomChoice: boolean;

    constructor(id: string, name: string, level: number, extendedTooltip: string, interfaceIcon: string, classification: ItemClass, includeAsRandomChoice: boolean) {
        this.id = id;
        this.name = name;
        this.classification = classification;
        this.level = level;
        this.extendedTooltip = extendedTooltip;
        this.interfaceIcon = interfaceIcon;
        this.includeAsRandomChoice = includeAsRandomChoice;
    }
}

const ITEMS_BY_ID = new Map<string, ItemInfo>();

const ITEM_GROUPS_BY_ID = new Map<string, ItemGroup>();

export function initItemsDB() {
    createAllItemsDB();
    createItemGroupsDB();
}

function createAllItemsDB() {
    for (const itemId of Object.keys(COMPILETIME_ITEM_DATA)) {
        const item = Item.create(FourCC(itemId), 0, 0)!;
        if(item == undefined) {
            print(`Failed to create an item with id: ${itemId}`)
            continue;
        }

        const itemClass = inferItemClass(item);
        if(itemClass == undefined) {
            item.destroy();
            continue;
        }

        const itemInfo = new ItemInfo(
            itemId,
            item.name,
            item.level,
            item.extendedTooltip,
            item.icon,
            itemClass,
            COMPILETIME_ITEM_DATA[itemId].includeAsRandomChoice);

        ITEMS_BY_ID.set(itemId, itemInfo);

        item.destroy();
    }

    const expectedItemsCount = Object.keys(COMPILETIME_ITEM_DATA).length;
    const actualItemCount = ITEMS_BY_ID.size;
    if (actualItemCount != expectedItemsCount) {
        print(`Failed to initialize items database. Expected ${expectedItemsCount} items, but got ${actualItemCount}`)
    }
}

function createItemGroupsDB() {
    for (const item of ITEMS_BY_ID.values()) {
        //ChooseRandomItemEx filters out items that have `Stats - Include As Random Choice` field set to false
        if(!item.includeAsRandomChoice) {
            continue;
        }

        const itemGroupId = itemGroup2FourCC(item.classification, item.level);
        if (itemGroupId === undefined) {
            print(`Failed to create item group id for ${item.id}: ${item.classification} ${item.level}`)
            continue;
        }

        let itemGroup = ITEM_GROUPS_BY_ID.get(itemGroupId);
        if (itemGroup === undefined) {
            itemGroup = new ItemGroup(itemGroupId, item.classification, item.level, [])
            ITEM_GROUPS_BY_ID.set(itemGroupId, itemGroup);
        }

        itemGroup.items.push(item.id);
    }

    //Some groups have no items - but we still need to create EMPTY groups for them (ItemGroup that has 0 items),
    //so that `getItemGroupById()` could be used to check if the ID is an ItemGroup id instead of a specific item id
    for (const iClass of Object.values(ItemClass)) {
        for (const iLevel of Array.from(VALID_LEVELS.values())) {
            const groupId = itemGroup2FourCC(iClass, iLevel)!;
            const group = ITEM_GROUPS_BY_ID.get(groupId);
            if (group === undefined) {
                ITEM_GROUPS_BY_ID.set(groupId, new ItemGroup(groupId, iClass, iLevel, []))
            } else {
                //Sort items in a group alphabetically by name
                //Lua's `<` operator does lexicographical comparison
                group.items.sort((a, b) => (ITEMS_BY_ID.get(a)!.name < ITEMS_BY_ID.get(b)!.name) ? -1 : 1);
            }
        }
    }

    const actualGroupsCount = ITEM_GROUPS_BY_ID.size;
    const expectedGroupsCount = Object.values(ItemClass).length * VALID_LEVELS.size;
    if (actualGroupsCount !== expectedGroupsCount) {
        print(`Failed to create correct amount of item groups. Expected ${expectedGroupsCount} groups, but got ${actualGroupsCount}`)
    }
}

function inferItemClass(item: Item) {
    const itemType = item.type!;
    switch (itemType) {
        case ITEM_TYPE_ANY: {
            //Including for completeness, should never happen
            print(`Item ${item.name} (${item.typeId}) is of type ANY`)
            return;
        }
        case ITEM_TYPE_ARTIFACT:
            return ItemClass.Artifact;
        case ITEM_TYPE_CAMPAIGN:
            return ItemClass.Campaign;
        case ITEM_TYPE_CHARGED:
            return ItemClass.Charged;
        case ITEM_TYPE_MISCELLANEOUS:
            return ItemClass.Misc;
        case ITEM_TYPE_PERMANENT:
            return ItemClass.Permanent;
        case ITEM_TYPE_POWERUP:
            return ItemClass.Power_Up;
        case ITEM_TYPE_PURCHASABLE:
            return ItemClass.Purchasable;
        //What is this? You can't select this group in WE, there is no such item class in the game
        // https://github.com/lep/jassdoc/blob/master/common.j says: "Deprecated, should use ITEM_TYPE_POWERUP"
        case ITEM_TYPE_TOME: {
            print(`Item ${item.name} (${item.typeId}) is of type TOME`)
            return ItemClass.Power_Up;
        }
        //Don't know why some items are of type UNKNOWN (but their actual class in WE Object Data is "Misc")
        // None of those items are selectable by ChooseRandomItemEx (IncludeAsRandomChoice is false)
        case ITEM_TYPE_UNKNOWN: return ItemClass.Misc;
        default: {
            print(`Item ${item.name} (${item.typeId}) has unexpected type!`);
            return;
        }
    }
}

export function getItemById(fourCCid: string): ItemInfo | undefined {
    return ITEMS_BY_ID.get(fourCCid);
}

//Group such as "YiI1" - which includes items of class "Permanent", level 1.
export function getItemGroupById(fourCCid: string): ItemGroup | undefined {
    return ITEM_GROUPS_BY_ID.get(fourCCid);
}
