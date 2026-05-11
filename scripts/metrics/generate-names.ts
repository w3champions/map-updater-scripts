import * as fs from "fs-extra";
import * as path from "path";

const CONSTANTS_DIR = path.join(__dirname, "../../node_modules/war3-objectdata-th/dist/cjs/generated/constants");
const OUTPUT = path.join(__dirname, "object-names.json");

function pascalToReadable(name: string): string {
    return name
        .replace(/([A-Z])/g, " $1")
        .replace(/([0-9]+)/g, " $1")
        .trim()
        .replace(/\s+/g, " ");
}

function extractFromDts(filePath: string): Record<string, string> {
    const content = fs.readFileSync(filePath, "utf8");
    const result: Record<string, string> = {};
    const pattern = /(\w+)\s*=\s*"([^"]+)"/g;
    let match: RegExpExecArray | null;
    while ((match = pattern.exec(content)) !== null) {
        const [, key, fourcc] = match;
        if (fourcc.length === 4) {
            result[fourcc] = pascalToReadable(key);
        }
    }
    return result;
}

const categories = ["units", "items", "abilities", "upgrades", "buffs", "destructables"] as const;

const merged: Record<string, string> = {};

for (const category of categories) {
    const filePath = path.join(CONSTANTS_DIR, `${category}.d.ts`);
    if (!fs.existsSync(filePath)) {
        console.warn(`Skipping missing file: ${filePath}`);
        continue;
    }
    const entries = extractFromDts(filePath);
    for (const [fourcc, name] of Object.entries(entries)) {
        if (!merged[fourcc]) {
            merged[fourcc] = name;
        }
    }
}

fs.writeFileSync(OUTPUT, JSON.stringify(merged, null, 2), "utf8");
console.log(`Generated ${Object.keys(merged).length} FourCC → name entries → ${OUTPUT}`);
