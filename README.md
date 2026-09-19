## W3Champions Map Triggers
This repo contains the scripts we use to inject the triggers into our ladder maps, -zoom, -workercount, etc.

## Prerequisites
* Node and npm
* Git and Git Bash

## How to use
* Run `npm install`
* Put the maps you want to add the triggers to into `./maps/w3c_maps/clean_maps`
* Run `./updateMaps.sh` with bash (Git Bash on Windows for example) to add triggers to all the maps
* The newly created maps will be saved into `./maps/w3c_maps/output`, sorted into a subfolder per game mode
* Upload from `./maps/w3c_maps/output/upload` instead of the per-mode subfolders, since it holds one copy of each map (multi-mode maps repeat across subfolders and break a same-name bulk upload)

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

## Minimap icons
The assets in `./assets/main/UI/MiniMap` and `./assets/roc/UI/MiniMap` add the W3Champions-only neutral-building icons (Shop, Tavern, Mercenary Camp, Laboratory), which players can toggle with `-minimap`.  
Neither tree overrides the icon textures the game already ships (`MiniMap-Gold`, `MiniMap-NeutralBuilding`, `MiniMapIconCreepLoc`, `MiniMapIconCreepLoc2`); the game uses its own copies of those.  
Warcraft III 3.0's HD texture streaming can still be reading such an override when the map archive closes, at any point in a game with Reforged or Definitive Edition graphics, which crashes the game; that is why neither asset tree ships them.
