## W3Champions Map Triggers
This repo contains the scripts we use to inject the triggers into our ladder maps, -zoom, -workercount, etc.

## Prerequisites
* Node and npm
* Git and Git Bash

## How to use
* Run `npm install`
* Put the maps you want to add the triggers to into `./maps/w3c_maps/clean_maps/current`
* Run `./updateMaps.sh` with bash (Git Bash on Windows for example) to add triggers to all the maps
* The newly created maps will be saved into `./maps/w3c_maps/output`

## Additional info
When maps are removed from the W3Champions map pool, they should be moved from the `current` directory to `unused`. This way they won't be processed by the script, but the clean maps are still preserved for later use.
