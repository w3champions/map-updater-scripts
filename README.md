## W3Champions Map Triggers
This repo contains the scripts we use to inject the triggers into our ladder maps, -zoom, -workercount, etc.

## Prerequisites
* Node and npm
* Git and Git Bash

## How to use
* Run `npm install`
* Put the maps you want to add the triggers to into `./maps/w3c_maps/clean_maps`
* Run `./updateMaps.sh` with bash (Git Bash on Windows for example) to add triggers to all the maps
* The newly created maps will be saved into `./maps/w3c_maps/output`

## Optional arguments
You can pass arguments to control the source map folder and filtering:

1. **Custom base folder (argument 1)**  
   Example:
   ```bash
   ./updateMaps.sh ATR
   ```
   Processes maps from `./maps/w3c_maps/ATR` instead of `clean_maps`.

2. **Filter by game mode(s) (argument 2)**  
   Example:
   ```bash
   ./updateMaps.sh "" 2v2,4v4
   ```
   Processes only maps starting with `2v2_` or `4v4_` from the default `clean_maps` folder.

3. **Custom folder with filter**  
   Example:
   ```bash
   ./updateMaps.sh clean_maps/tournament 1v1
   ```
   Processes only maps starting with `1v1_` from `./maps/w3c_maps/clean_maps/tournament`.