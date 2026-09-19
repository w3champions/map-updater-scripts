import { execSync } from "child_process";
import * as fs from "fs-extra";
import * as path from "path";
import { createLogger, format, transports } from "winston";
const { combine, timestamp, printf } = format;
const luamin = require('luamin');

export interface IProjectConfig {
  mapFolder: string;
  minifyScript: string;
  gameExecutable: string;
  outputFolder: string;
  launchArgs: string[];
}

/**
 * Identifies the build job when updateMaps.sh builds maps in parallel. Every
 * mutable artifact (extracted map, dist staging folder, tstl bundle, MPQ
 * script and output archive) is nested under it, so concurrent builds of
 * different maps cannot read or overwrite each other's files. Empty for a
 * serial build, which keeps the original flat paths.
 */
export function getJobId(): string {
  return process.env.W3C_JOB_ID || "";
}

/**
 * Path segment that nests a job's artifacts, e.g. ".jobs/job-007/", or ""
 * when building serially.
 */
export function getJobDir(): string {
  const jobId = getJobId();
  return jobId ? `${jobId}/` : "";
}

/**
 * The map folder for this job, used relative to ./maps, ./dist and the
 * configured output folder.
 */
export function getMapFolder(config: IProjectConfig): string {
  return `${getJobDir()}${config.mapFolder}`;
}

/**
 * Load an object from a JSON file.
 * @param fname The JSON file
 */
export function loadJsonFile(fname: string) {
  try {
    return JSON.parse(fs.readFileSync(fname).toString());
  } catch (e) {
    logger.error(e.toString());
    return {};
  }
}

/**
 * Convert a Buffer to ArrayBuffer
 * @param buf 
 */
export function toArrayBuffer(b: Buffer): ArrayBuffer {
  var ab = new ArrayBuffer(b.length);
  var view = new Uint8Array(ab);
  for (var i = 0; i < b.length; ++i) {
    view[i] = b[i];
  }
  return ab;
}

/**
 * Convert a ArrayBuffer to Buffer
 * @param ab 
 */
export function toBuffer(ab: ArrayBuffer) {
  var buf = Buffer.alloc(ab.byteLength);
  var view = new Uint8Array(ab);
  for (var i = 0; i < buf.length; ++i) {
    buf[i] = view[i];
  }
  return buf;
}

/**
 * Recursively retrieve a list of files in a directory.
 * @param dir The path of the directory
 */
export function getFilesInDirectory(dir: string) {
  const files: string[] = [];
  fs.readdirSync(dir).forEach(file => {
    let fullPath = path.join(dir, file);
    if (fs.lstatSync(fullPath).isDirectory()) {
      const d = getFilesInDirectory(fullPath);
      for (const n of d) {
        files.push(n);
      }
    } else {
      files.push(fullPath);
    }
  });
  return files;
};

/**
 * Replaces all instances of the include directive with the contents of the specified file.
 * @param contents war3map.lua
 */
export function processScriptIncludes(contents: string) {
  const regex = /include\(([^)]+)\)/gm;
  let matches;
  while ((matches = regex.exec(contents)) !== null) {
    const filename = matches[1].replace(/"/g, "").replace(/'/g, "");
    const fileContents = fs.readFileSync(filename);
    contents = contents.substr(0, regex.lastIndex - matches[0].length) + "\n" + fileContents + "\n" + contents.substr(regex.lastIndex);
  }
  return contents;
}

/**
 * 
 */
export function compileMap(config: IProjectConfig) {
  if (!config.mapFolder) {
    logger.error(`Could not find key "mapFolder" in config.json`);
    return false;
  }

  const mapFolder = getMapFolder(config);
  const tsLua = `./dist/${getJobDir()}tstl_output.lua`;

  if (fs.existsSync(tsLua)) {
    fs.unlinkSync(tsLua);
  }

  fs.mkdirpSync(path.dirname(tsLua));

  logger.info("Transpiling TypeScript to Lua...");
  // tsconfig.json bundles to ./dist/tstl_output.lua. A parallel job needs its
  // own bundle, so point tstl at this job's folder instead.
  execSync(
    getJobId() ? `tstl -p tsconfig.json --luaBundle "${tsLua}"` : 'tstl -p tsconfig.json',
    { stdio: 'inherit' }
  );

  if (!fs.existsSync(tsLua)) {
    logger.error(`Could not find "${tsLua}"`);
    return false;
  }

  logger.info(`Building "${mapFolder}"...`);
  fs.copySync(`./maps/${mapFolder}`, `./dist/${mapFolder}`);

  const mapLua = `./dist/${mapFolder}/war3map.lua`;
  const mapJass = `./dist/${mapFolder}/war3map.j`;

  if (fs.existsSync(mapJass) && !fs.existsSync(mapLua)) {
    logger.error(`Found "${mapJass}" instead of "${mapLua}". Please check that the map script language is set to Lua.`);
    throw new Error();
  }

  if (!fs.existsSync(mapLua)) {
    logger.error(`Could not find "${mapLua}"`);
    throw new Error();
  }

  // Merge the TSTL output with war3map.lua
  try {
    let contents = fs.readFileSync(mapLua).toString() + fs.readFileSync(tsLua).toString();
    contents = processScriptIncludes(contents);

    if (config.minifyScript) {
      logger.info(`Minifying script...`);
      contents = luamin.minify(contents.toString());
    }
    //contents = luamin.minify(contents);
    fs.writeFileSync(mapLua, contents);
  } catch (err) {
    logger.error(err.toString());
    return false;
  }

  return true;
}

/**
 * Formatter for log messages.
 */
const loggerFormatFunc = printf(({ level, message, timestamp }) => {
  return `[${(timestamp as string).replace("T", " ").split(".")[0]}] ${level}: ${message}`;
});

/**
 * The logger object.
 */
export const logger = createLogger({
  transports: [
    new transports.Console({
      format: combine(
        format.colorize(),
        timestamp(),
        loggerFormatFunc
      ),
    }),
    // Parallel jobs would interleave their writes into one project.log, so a
    // job logs to the console only and updateMaps.sh appends the captured
    // output to project.log one finished map at a time.
    ...(getJobId() ? [] : [
      new transports.File({
        filename: "project.log",
        format: combine(
          timestamp(),
          loggerFormatFunc
        ),
      }),
    ]),
  ]
});