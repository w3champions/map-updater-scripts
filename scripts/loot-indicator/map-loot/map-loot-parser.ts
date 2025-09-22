import UnitsDoo from "mdx-m3-viewer-th/dist/cjs/parsers/w3x/unitsdoo/file.js";
import Unit from "mdx-m3-viewer-th/dist/cjs/parsers/w3x/unitsdoo/unit.js";
import War3MapW3i from "mdx-m3-viewer-th/dist/cjs/parsers/w3x/w3i/file.js";
import * as fs from "fs-extra";
import type {RawItemDropSet, RawUnitItemDrop} from "../../../src/loot-indicator/modules/unit-item-drops";
import DroppedItemSet from "mdx-m3-viewer-th/dist/cjs/parsers/w3x/unitsdoo/droppeditemset";

// getMapItemDrops('../../../maps/itemdroptable-testbench.w3x')

export function getMapItemDrops(mapPath: string): RawUnitItemDrop[] {
    const {unitsDoo, war3MapW3i} = loadUnitsDoo(mapPath);
    // writeAsJson(`${mapPath}/raw-unit.json`, unitsDoo.units);
    let rawDrops = [] as RawUnitItemDrop[];
    for (const unit of unitsDoo.units) {
        let sets: DroppedItemSet[] = []
        //Use Custom Item Table sets
        sets.push(...unit.droppedItemSets)
        //Use Item Table from Map sets (used in "(8)WellspringTemple..." map for a set of 2 runes)
        if(unit.droppedItemTable >= 0) {
            const itemTable = war3MapW3i.randomItemTables[unit.droppedItemTable];
            if(itemTable !== undefined) {
                sets.push(...itemTable.sets)
            } else {
                console.warn(`Item Table idx ${unit.droppedItemTable} is not found in map file`)
            }
        }

        //Filter out sets that use "ANY LEVEL" and "ANY CLASS" Random Groups (they cause issues)
        // In real Melee map, nobody practically should use it
        sets = sets.filter(set => !set.items.some(item => (item.id[1] === "Y") || (item.id[3] === "/")));

        if(sets.length > 0) {
            const itemSets = sets.map(set => {
                return ({itemTypes: set.items.map(item => item.id)});
            })
            const unitLocation = { x: unit.location[0], y: unit.location[1] }
            rawDrops.push({unitLocation, itemSets});
        }
    }

    return rawDrops;
}

function loadUnitsDoo(mapPath: string) {
        const war3MapW3i = new War3MapW3i();
        war3MapW3i.load(fs.readFileSync(`${mapPath}/war3map.w3i`))
        // writeAsJson(`${mapPath}/war3map.w3i.json`, war3MapW3i);

        const unitsDoo = new UnitsDoo();
        unitsDoo.load(fs.readFileSync(`${mapPath}/war3mapUnits.doo`), war3MapW3i.getBuildVersion())
        return {unitsDoo, war3MapW3i};
}

function writeAsJson(path: string, data: any) {
    fs.writeFileSync(path, JSON.stringify(data, null, 2));
}