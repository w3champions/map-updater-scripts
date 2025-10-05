import {Unit} from "w3ts";

export function groupBy<T, K>(
    values: Iterable<T>,
    keyFn: (value: T) => K
): Map<K, T[]> {
    const map = new Map<K, T[]>();
    for (const value of values) {
        const key = keyFn(value);
        let group = map.get(key);
        if (!group) {
            group = [];
            map.set(key, group);
        }
        group.push(value);
    }
    return map;
}

export function id2FourCC(id: number): string {
    const a = (id >>> 24) & 0xff;
    const b = (id >>> 16) & 0xff;
    const c = (id >>> 8) & 0xff;
    const d = id & 0xff;
    return string.char(a, b, c, d);
}

//This is the initial "Art - Scaling Value" parameter value
//Does not represent actual runtime scale (e.g., does not change when Bloodlusted/Hexed)
export function getUnitModelScale(unit: Unit): number {
    return unit.getField(UNIT_RF_SCALING_VALUE) as number
}

//https://lep.nrw/jassbot/doc/BlzTriggerRegisterPlayerKeyEvent
//Can combine them by just adding them (+) or by using bitwise OR (|)
export const METAKEY_NONE: number = 0;
export const METAKEY_SHIFT: number = 1;
export const METAKEY_CTRL: number = 2;
export const METAKEY_ALT: number = 4;
export const METAKEY_META: number = 8; //aka windows key