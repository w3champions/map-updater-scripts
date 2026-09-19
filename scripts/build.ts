import * as fs from "fs-extra";
import * as path from "path";
import { execSync } from "child_process";
import { compileMap, getFilesInDirectory, getJobId, getMapFolder, loadJsonFile, logger, toArrayBuffer, IProjectConfig } from "./utils";

function main() {
  const config: IProjectConfig = loadJsonFile("config.json");
  const dirName = process.argv[2];
  
  if (!dirName) {
    logger.error("No directory name provided. Usage: npm run build <directory>");
    return;
  }
  
  const assetsPath = dirName.includes("reign-of-chaos") ? `./assets/roc` : `./assets/main`;
  const mapFolder = getMapFolder(config);

  // Gets overwritten if the map has it
  fs.copySync(`./defaults`, `./dist/${mapFolder}`)
  const result = compileMap(config);

  if (!result) {
    logger.error(`Failed to compile map.`);
    return;
  }

  // Overwrites map files with our assets
  fs.copySync(assetsPath, `./dist/${mapFolder}`);

  logger.info(`Creating w3x archive...`);
  // mapFolder is nested in a job folder when building in parallel, so the
  // parent of the archive may be more than one level below the output folder.
  const outputPath = `${config.outputFolder}/${mapFolder}`;
  fs.mkdirpSync(path.dirname(outputPath));
  console.log(`Output: ${outputPath}`);
  console.log(`Directory to create archive from: ./dist/${mapFolder}`);

  createMapFromDir(outputPath, `./dist/${mapFolder}`);
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

  // Create a temporary script file for MPQEditor with better formatting and compression
  const scriptContent = `new "${output}" 0x2000
add "${output}" "${dir}\\*.*" /r /auto /c
close
exit`;
  // One script file per job: concurrent builds must not share this path.
  const jobSuffix = getJobId().replace(/[^A-Za-z0-9_-]/g, "_");
  const scriptPath = `./temp_mpq_script${jobSuffix ? `_${jobSuffix}` : ""}.txt`;
  
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