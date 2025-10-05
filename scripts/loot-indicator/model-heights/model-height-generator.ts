import * as casclib from '@jamiephan/casclib'
import {IniFile} from "mdx-m3-viewer-th/dist/cjs/parsers/ini/file"
import {parseMDX} from 'war3-model';
import * as fs from 'fs-extra';
import {toArrayBuffer} from "../../utils";
import {UnitModelHeight} from "../../../src/player_features/loot-indicator/modules/unit-hp-bar-position-calculator";

const WC3_GAME_BASE_DIRECTORY = "D:\\Games\\Warcraft III";

generateModelHeights("unit-model-height-data.json")

function generateModelHeights(resultFilePath: string) {
    const storageHandle = casclib.openStorageSync(WC3_GAME_BASE_DIRECTORY)
    try {
        const unitSkinBuffer = casclib.readFileSync(storageHandle, "war3.w3mod:units\\unitskin.txt")

        const unitSkinIni: IniFile = new IniFile();
        unitSkinIni.load(unitSkinBuffer.toString("utf8"));

        let modelHeights = new Map<string, UnitModelHeight>()

        unitSkinIni.sections.forEach((section, unitType) => {
            console.log(section)
            let sdHeight: number, hdHeight: number;

            const file = section.get("file")!;
            if (file != undefined) {
                const modelHeight = getModelHeightFromFile(storageHandle, file, false);
                sdHeight = modelHeight;
                hdHeight = modelHeight;
            } else {
                sdHeight = getModelHeightFromFile(storageHandle, section.get("file:sd")!, false);
                hdHeight = getModelHeightFromFile(storageHandle, section.get("file:hd")!, true);
            }

            modelHeights.set(unitType, {sdHeight, hdHeight})
        })

        fs.writeFileSync(resultFilePath, JSON.stringify(Object.fromEntries(modelHeights), null, 2))
    } finally {
        casclib.closeStorage(storageHandle);
    }
}

function getModelHeightFromFile(storageHandle: any, filePath: string, isHd: boolean = false) {
    try {
        const fullPath = isHd ?
            `war3.w3mod:_hd.w3mod:${filePath}.mdx` :
            `war3.w3mod:${filePath}.mdx`;

        console.log(fullPath)
        const arrayBuffer = readFileFromCasc(storageHandle, fullPath);
        const model = parseMDX(arrayBuffer);

        // This is a guess, but it works for most models
        const standSeq = model.Sequences.filter(seq => /^stand[ \-\d]*$/.test(seq.Name.toLowerCase()))[0] ?? model.Sequences[0];
        return standSeq.MaximumExtent[2];
    } catch (e: any) {
        console.log(e)
        return -1;
    }

}

function readFileFromCasc(storageHandle: any, filePath: string) {
    // Sometimes `readFileSync()` returns buffer bigger then the file size, so we slice it
    const buffer = casclib.readFileSync(storageHandle, filePath);
    const size = casclib.findFilesSync(storageHandle, filePath)[0].fileSize;
    return toArrayBuffer(buffer.subarray(0, size));
}