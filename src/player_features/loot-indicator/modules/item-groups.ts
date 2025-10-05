export class ItemGroup {
    id: string;
    itemClass: ItemClass;
    itemLevel: number;
    items: string[];

    constructor(id: string, itemClass: ItemClass, itemLevel: number, items: string[]) {
        this.id = id;
        this.itemClass = itemClass;
        this.itemLevel = itemLevel;
        this.items = items;
    }
}

export enum ItemClass {
    Permanent = "Permanent",
    Charged = "Charged",
    Power_Up = "PowerUp",
    Artifact = "Artifact",
    Purchasable = "Purchasable",
    Campaign = "Campaign",
    Misc = "Miscellaneous"
}

const ITEM_CLASS_TO_ENCODED_CLASS = new Map([
    [ItemClass.Permanent, "i"],
    [ItemClass.Charged, "j"],
    [ItemClass.Power_Up, "k"],
    [ItemClass.Artifact, "l"],
    [ItemClass.Purchasable, "m"],
    [ItemClass.Campaign, "n"],
    [ItemClass.Misc, "o"],
])

export const VALID_LEVELS = new Set([0, 1, 2, 3, 4, 5, 6, 7, 8]);

export function itemGroup2FourCC(itemClass: ItemClass, itemLevel: number): string | undefined {
    const encodedClass = ITEM_CLASS_TO_ENCODED_CLASS.get(itemClass);
    if (encodedClass === undefined) return;

    if (!VALID_LEVELS.has(itemLevel)) return;

    return 'Y' + encodedClass + 'I' + itemLevel.toString(10);
}


