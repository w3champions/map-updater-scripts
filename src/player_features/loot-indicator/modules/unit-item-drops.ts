import {Group, Point, Unit} from "w3ts";
import {ItemGroup} from "./item-groups";
import {getItemById, getItemGroupById} from "./items-db";

// Raw data from map file
export interface RawUnitItemDrop {
    unitLocation: Point2D;
    itemSets: RawItemDropSet[];
}

export interface Point2D {
    x: number;
    y: number;
}

export interface RawItemDropSet {
    itemTypes: string[]
}

// Enhanced raw data with data from runtime

export interface UnitItemDrop {
    unit: Unit;
    dropSets: ItemDropSet[];
}

export interface ItemDropSet {
    itemDrops: ItemDrop[]
}

export interface ItemDrop {
    getRawId(): string;

    getDropItemIds(): string[];
}

export class SpecificItemDrop implements ItemDrop {
    itemId: string;

    constructor(itemId: string) {
        this.itemId = itemId;
    }

    getRawId() {
        return this.itemId;
    }

    getDropItemIds() {
        return [this.itemId];
    }
}

export class RandomItemGroupDrop implements ItemDrop {
    itemGroup: ItemGroup

    constructor(itemGroup: ItemGroup) {
        this.itemGroup = itemGroup;
    }

    getRawId(): string {
        return this.itemGroup.id;
    }

    getDropItemIds(): string[] {
        return this.itemGroup.items;
    }
}

const RAW_UNIT_ITEM_DROPS = compiletime(() => {
    //TODO: How to properly import? Relative to project root. Bonus: no proper code completions for "require"d modules
    const {getMapItemDrops} = require("../../../scripts/loot-indicator/map-loot/map-loot-parser.ts");

    const fs = require("fs-extra");
    const mapFolder = JSON.parse(fs.readFileSync("./config.json", "utf8")).mapFolder;

    return getMapItemDrops(`./maps/${mapFolder}`);
}) as RawUnitItemDrop[]

function findUnitAtPoint(p: Point): Unit | undefined {
    const g = Group.create()!;
    g.enumUnitsInRangeOfPoint(p, 1, () => Unit.fromFilter().getOwner().id === PLAYER_NEUTRAL_AGGRESSIVE);
    if (g.size == 0) {
        //Try a bigger search radius. The data for position is not always precise.
        //Example is "Elder Jungle Stalker" on 1v1_WarHail_v1.1.w3x
        //Parsed map position: 2338, 3121
        //Actual     position: 2384, 3088
        g.enumUnitsInRangeOfPoint(p, 200, () => Unit.fromFilter().getOwner().id === PLAYER_NEUTRAL_AGGRESSIVE)
    }

    //size=0 can happen when player spawn is at a camp (e.g., on 4 player map, like LostTemple)
    if (g.size == 0) {
        // print(`P(${p.x}, ${p.y}) should point to 1 unit, but found ${g.size}.`)
        //TODO: remove/disable print statements in production
        // Idea: add a "-debug" command (locally persisted flag - same approach as feature flags).
        // When enabled, print statements are enabled.
        // When something goes wrong, we can ask for a replay file. Then replay it with "debug" flag enabled - and we can see what happened.
        g.destroy();
        return;
    }

    let u: Unit;
    if (g.size == 1) {
        u = g.getUnitAt(0);
    } else if (g.size > 1) {
        // print(`P(${p.x}, ${p.y}) should point to 1 unit, but found ${g.size}.`)
        u = getClosestUnit(g, p);
    }

    g.destroy();
    return u;
}

function getClosestUnit(g: Group, p: Point) {
    let closestUnit = g.getUnitAt(0);
    let closestDist = calcDistance(closestUnit, p);

    for (let i = 1; i < g.size; i++) {
        const u = g.getUnitAt(i);
        const dist = calcDistance(u, p)
        if (dist < closestDist) {
            closestDist = dist;
            closestUnit = u;
        }
    }

    return closestUnit;
}

function calcDistance(u: Unit, p: Point) {
    const dx = u.x - p.x;
    const dy = u.y - p.y;

    return dx * dx + dy * dy;
}

export function getAllItemIds(dropSets: ItemDropSet[]) {
    return dropSets.flatMap(s => s.itemDrops.flatMap(d => d.getDropItemIds()));
}

export function findMapInitialCreepsWithDrops(): UnitItemDrop[] {
    const unitItemDrops: UnitItemDrop[] = [];
    for (const rawDrop of RAW_UNIT_ITEM_DROPS) {
        const unit = findUnitAtPoint(Point.create(rawDrop.unitLocation.x, rawDrop.unitLocation.y));
        if (!unit) continue;

        const dropSets: ItemDropSet[] = rawDrop.itemSets.flatMap(itemSet => {
            const itemDrops: ItemDrop[] = itemSet.itemTypes.flatMap((itemOrGroupId) => {
                const itemGroup = getItemGroupById(itemOrGroupId);
                if (itemGroup !== undefined) {
                    return [new RandomItemGroupDrop(itemGroup)]
                } else if (getItemById(itemOrGroupId) !== undefined) {
                    return [new SpecificItemDrop(itemOrGroupId)]
                } else {
                    print(`Unknown item drop id "${itemOrGroupId}" for unit "${unit.name}" at (${unit.x}, ${unit.y}).`);
                    return [] as ItemDrop[];
                }
            });
            return itemDrops.length > 0 ? [{itemDrops}] : [];
        })

        //Skip unit, if effectively it has no drops.
        //This could be mapmaker's mistake, blizzard changing drop tables, or we filtered it out (unknown item drop id)
        if (getAllItemIds(dropSets).length === 0) continue;

        unitItemDrops.push({unit, dropSets});
    }

    return unitItemDrops;
}
