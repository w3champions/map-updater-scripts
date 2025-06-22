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
To process only maps belonging to specific game modes, you can pass an optional comma-separated list as an argument to the script.
For example, `./updateMaps.sh 1v1,4v4` will process only maps that start with `1v1_` or `4v4_`.
