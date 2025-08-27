import * as fs from "fs-extra";
import * as path from "path";
import { execSync } from "child_process";
import { compileMap, getFilesInDirectory, loadJsonFile, logger, toArrayBuffer, IProjectConfig } from "./utils";

function main() {
  const config: IProjectConfig = loadJsonFile("config.json");
  const dirName = process.argv[2];
  
  if (!dirName) {
    logger.error("No directory name provided. Usage: npm run build <directory>");
    return;
  }
  
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
  const mpqEditorPath = "./MPQEditor.exe";
  
  if (!fs.existsSync(mpqEditorPath)) {
    logger.error(`MPQEditor.exe not found at ${mpqEditorPath}`);
    return;
  }

  // Create a temporary script file for MPQEditor
  const scriptContent = `new "${output}" 0x2000\nadd "${output}" "${dir}\\*.*" /r /auto\nclose\nexit`;
  const scriptPath = "./temp_mpq_script.txt";
  
  fs.writeFileSync(scriptPath, scriptContent);
  
  try {
    logger.info(`Creating MPQ archive using MPQEditor...`);
    execSync(`"${mpqEditorPath}" script "${scriptPath}"`, { stdio: 'inherit' });
    logger.info("Finished creating MPQ archive!");
  } catch (error) {
    logger.error(`Failed to create MPQ archive: ${error}`);
  } finally {
    // Clean up temporary script file
    if (fs.existsSync(scriptPath)) {
      fs.unlinkSync(scriptPath);
    }
  }
}

main();