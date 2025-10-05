import * as casclib from '@jamiephan/casclib'
import SlkFile from "mdx-m3-viewer-th/dist/cjs/parsers/slk/file"
import * as fs from 'fs-extra';
import {toArrayBuffer} from "../../utils";

const WC3_GAME_BASE_DIRECTORY = "D:\\Games\\Warcraft III";

interface ItemData {
    //Comment is roughly a name, used it here just to give a rough view of what the item actually is.
    //The actual in-game name is probably in _locales/enus.w3mod/itemstrings.txt
    comment: string;
    includeAsRandomChoice: boolean;
}

generateItemsData("extracted-items-data.json")

function generateItemsData(resultFilePath: string) {
    const storageHandle = casclib.openStorageSync(WC3_GAME_BASE_DIRECTORY)
    try {
        const unitDataBuffer = casclib.readFileSync(storageHandle, "war3.w3mod:units\\itemdata.slk")
        const itemDataSlk = new SlkFile();
        itemDataSlk.load(unitDataBuffer.toString("utf8"));

        let itemDataById = new Map<string, ItemData>()

        //Header row
        const headerRow = itemDataSlk.rows[0];
        const columnName2Idx = headerRow.reduce((map, name, idx) =>
            map.set(name, idx), new Map<string, number>())
        const valueRows = itemDataSlk.rows.slice(1);

        for (const row of valueRows) {
            const id = row[columnName2Idx.get("itemID")!];
            const comment = row[columnName2Idx.get("comment")!];
            const includeAsRandomChoice = row[columnName2Idx.get("pickRandom")!] === "1";

            itemDataById.set(id, {comment, includeAsRandomChoice});
        }

        fs.writeFileSync(resultFilePath, JSON.stringify(Object.fromEntries(itemDataById), null, 2))
        console.log("Total items extracted: " + itemDataById.size)
    } finally {
        casclib.closeStorage(storageHandle);
    }
}

function readFileFromCasc(storageHandle: any, filePath: string) {
    // Sometimes `readFileSync()` returns buffer bigger then the file size, so we slice it
    const buffer = casclib.readFileSync(storageHandle, filePath);
    const size = casclib.findFilesSync(storageHandle, filePath)[0].fileSize;
    return toArrayBuffer(buffer.subarray(0, size));
}