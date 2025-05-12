import * as fs from "fs-extra";
import * as path from "path";
import War3Map from "mdx-m3-viewer/dist/cjs/parsers/w3x/map";
import { compileMap, getFilesInDirectory, loadJsonFile, logger, toArrayBuffer, IProjectConfig } from "./utils";

function main() {
  const config: IProjectConfig = loadJsonFile("config.json");
  const dirName = process.argv[2];
  const assetsPath = dirName.includes("reign-of-chaos") ? `./assets/roc` : `./assets/main`;

  // Gets overwritten if the map has it
  fs.copySync(`./defaults`, `./dist/${config.mapFolder}`)
  const result = compileMap(config);

  if (!result) {
    logger.error(`Failed to compile map.`);
    return;
  }

  // Overwrites map files with our assets
  fs.copySync(assetsPath, `./dist/${config.mapFolder}`);

  logger.info(`Creating w3x archive...`);
  if (!fs.existsSync(config.outputFolder)) {
    fs.mkdirSync(config.outputFolder);
  }
  console.log(`Output: ${config.outputFolder}/${config.mapFolder}`);
  console.log(`Directory to create archive from: ./dist/${config.mapFolder}`);

  createMapFromDir(`${config.outputFolder}/${config.mapFolder}`, `./dist/${config.mapFolder}`);
}

/**
 * Creates a w3x archive from a directory
 * @param output The output filename
 * @param dir The directory to create the archive from
 */
export function createMapFromDir(output: string, dir: string) {
  const map = new War3Map();
  const files = getFilesInDirectory(dir);

  map.archive.resizeHashtable(files.length);

  for (const fileName of files) {
    const contents = toArrayBuffer(fs.readFileSync(fileName));
    const archivePath = path.relative(dir, fileName);
    const imported = map.import(archivePath, contents);

    if (!imported) {
      logger.warn("Failed to import " + archivePath);
      continue;
    }
  }

  const result = map.save();

  if (!result) {
    logger.error("Failed to save archive.");
    return;
  }

  fs.writeFileSync(output, new Uint8Array(result));

  logger.info("Finished!");
}

main();