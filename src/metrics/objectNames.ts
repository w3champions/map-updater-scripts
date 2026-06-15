const ENGLISH_NAMES = compiletime(() => {
    const fs = require("fs-extra");
    return JSON.parse(fs.readFileSync("./scripts/metrics/object-names.json", "utf8"));
}) as Record<string, string>;

function id2FourCC(id: number): string {
    const a = (id >>> 24) & 0xff;
    const b = (id >>> 16) & 0xff;
    const c = (id >>> 8) & 0xff;
    const d = id & 0xff;
    return string.char(a, b, c, d);
}

function englishName(typeId: number): string {
    const fourcc = id2FourCC(typeId);
    return ENGLISH_NAMES[fourcc] ?? fourcc;
}

export function getUnitName(typeId: number): string {
    return englishName(typeId);
}

export function getItemName(typeId: number): string {
    return englishName(typeId);
}

export function getAbilityName(abilityId: number): string {
    return englishName(abilityId);
}
