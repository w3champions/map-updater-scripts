import { Players } from "w3ts/globals";
import * as W3CEvents from "../lua/w3cEvents";
import { getUnitName } from "./objectNames";

interface MinePosition {
    typeId: string; // 4-char FourCC string e.g. "ngol"
    x: number;
    y: number;
}

// Gold mine positions extracted from the map file at compile time.
// Includes standard gold mines ("ngol") and haunted gold mines ("ugol").
const MAP_MINES = compiletime(() => {
    const fs = require("fs-extra");
    const config = JSON.parse(fs.readFileSync("./config.json", "utf8"));
    const mapPath = `./dist/${config.mapFolder}`;

    if (!fs.existsSync(`${mapPath}/war3mapUnits.doo`)) {
        return [];
    }

    const UnitsDoo = require("mdx-m3-viewer-th/dist/cjs/parsers/w3x/unitsdoo/file.js").default;
    const War3MapW3i = require("mdx-m3-viewer-th/dist/cjs/parsers/w3x/w3i/file.js").default;

    const war3MapW3i = new War3MapW3i();
    war3MapW3i.load(fs.readFileSync(`${mapPath}/war3map.w3i`));

    const unitsDoo = new UnitsDoo();
    unitsDoo.load(fs.readFileSync(`${mapPath}/war3mapUnits.doo`), war3MapW3i.getBuildVersion());

    const MINE_IDS = new Set(["ngol", "ugol"]);
    return unitsDoo.units
        .filter((u: any) => MINE_IDS.has(u.id))
        .map((u: any) => ({ typeId: u.id, x: u.location[0], y: u.location[1] }));
}) as MinePosition[];

// Radius within which workers are counted as "at this mine"
const WORKER_RADIUS = 500;
// Radius used to locate the mine unit handle at its known map position
const MINE_SEARCH_RADIUS = 100;

const MINE_TYPE_IDS: number[] = [FourCC("ngol"), FourCC("ugol")];

function isGoldMine(u: unit): boolean {
    const typeId = GetUnitTypeId(u);
    for (let i = 0; i < MINE_TYPE_IDS.length; i++) {
        if (typeId === MINE_TYPE_IDS[i]) return true;
    }
    return false;
}

// Cached mine unit handles — indexed parallel to MAP_MINES
const mineHandles: Array<unit | null> = [];

// Locate the gold mine unit at a known map position using a filter callback.
// The filter always returns false (group stays empty) — it captures the handle
// as a side effect. This avoids FirstOfGroup and produces a deterministic result
// because there is exactly one gold mine unit at each known position.
function findMineUnit(x: number, y: number): unit | null {
    let found: unit | null = null;
    const group = CreateGroup();
    GroupEnumUnitsInRange(group, x, y, MINE_SEARCH_RADIUS, Condition(() => {
        const u = GetFilterUnit();
        if (found == null && isGoldMine(u)) {
            found = u;
        }
        return false;
    }));
    DestroyGroup(group);
    return found;
}

// Count workers per player near a mine using a filter callback.
// The count is deterministic: synchronized unit positions guarantee the same
// set of workers is in range on every client, so the count is identical
// even if the internal enumeration order differs between clients.
function countWorkersNearMine(x: number, y: number): Record<number, number> {
    const counts: Record<number, number> = {};
    const neutral = Players[PLAYER_NEUTRAL_AGGRESSIVE].handle;
    const group = CreateGroup();
    GroupEnumUnitsInRange(group, x, y, WORKER_RADIUS, Condition(() => {
        const u = GetFilterUnit();
        if (!IsUnitType(u, UNIT_TYPE_PEON)) return false;
        const owner = GetOwningPlayer(u);
        if (owner === neutral) return false;
        const pid = GetPlayerId(owner);
        counts[pid] = (counts[pid] ?? 0) + 1;
        return false;
    }));
    DestroyGroup(group);
    return counts;
}

export function trackWorkerMineSnapshot() {
    if (MAP_MINES.length === 0) return;

    for (let i = 0; i < MAP_MINES.length; i++) {
        mineHandles[i] = findMineUnit(MAP_MINES[i].x, MAP_MINES[i].y);
    }

    W3CEvents.track("WorkerMineSnapshot", getWorkerMineSnapshots, 1);
}

function getWorkerMineSnapshots(): W3CEvents.EventPayload[] {
    const events: W3CEvents.EventPayload[] = [];

    for (let i = 0; i < MAP_MINES.length; i++) {
        const mine = MAP_MINES[i];

        // Re-discover if the mine was haunted by undead (ngol replaced by ugol)
        let mineUnit = mineHandles[i];
        if (mineUnit == null || GetUnitState(mineUnit, UNIT_STATE_LIFE) <= 0) {
            mineUnit = findMineUnit(mine.x, mine.y);
            mineHandles[i] = mineUnit;
        }

        const runtimeTypeId = mineUnit != null ? GetUnitTypeId(mineUnit) : FourCC(mine.typeId);
        // GetResourceAmount reads synchronized game state — deterministic across all clients
        const resourceAmount = mineUnit != null ? GetResourceAmount(mineUnit) : 0;

        const workersByPlayer = countWorkersNearMine(mine.x, mine.y);

        for (const pid in workersByPlayer) {
            const playerId = tonumber(pid) as number;
            events.push({
                player: playerId,
                mineTypeId: runtimeTypeId,
                mineName: getUnitName(runtimeTypeId),
                mineX: mine.x,
                mineY: mine.y,
                resourceAmount,
                workerCount: workersByPlayer[pid as unknown as number],
            });
        }
    }

    return events;
}
