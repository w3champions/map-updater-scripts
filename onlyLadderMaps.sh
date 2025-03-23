#!/bin/bash
# This script deletes all files in the clean_maps folder that do not match
# any map name defined in src/shared/src/shared/game-mode-maps.ts.
#
# It assumes:
#   - The TS file is at src/shared/src/shared/game-mode-maps.ts
#   - The clean maps are located in maps/w3c_maps/clean_maps
#
# The matching logic:
#   - For each map constant EMap.NAME in the TS file, remove "EMap." and underscores.
#     e.g., "EMap.BLOODVENOM_FALLS_V2" becomes "BLOODVENOMFALLSV2".
#   - For each file in clean_maps, remove the .w3x extension, convert to uppercase, and remove underscores.
#   - If the processed filename does not contain any processed map name, delete the file.

echo "Running gameModeMaps.sh to set up the submodule..."
./gameModeMaps.sh || { echo "Error running gameModeMaps.sh"; exit 1; }

# Set paths (adjust if necessary)
TS_FILE="src/shared/src/shared/game-mode-maps.ts"
MAP_DIR="maps/w3c_maps/clean_maps"

# Create an empty array to hold valid map names
declare -a VALID_MAP_NAMES=()

echo "Extracting valid map names from $TS_FILE ..."

# Read the TS file line by line
while read -r line; do
    # Use grep to extract occurrences of EMap.<NAME> (all-caps and underscores)
    matches=$(echo "$line" | grep -oE 'EMap\.[A-Z0-9_]+' || true)
    for match in $matches; do
        # Remove the "EMap." prefix
        name="${match#EMap.}"
        # Remove underscores
        cleaned=$(echo "$name" | tr -d '_')
        # Add to array if not already in it
        if [[ ! " ${VALID_MAP_NAMES[@]} " =~ " ${cleaned} " ]]; then
            VALID_MAP_NAMES+=("$cleaned")
        fi
    done
done < "$TS_FILE"

echo "Valid map names (processed):"
for map in "${VALID_MAP_NAMES[@]}"; do
    echo "  $map"
done

echo "Processing files in $MAP_DIR ..."

# Iterate over each file in the clean maps directory
for file in "$MAP_DIR"/*; do
    # Only process if it's a file
    if [ ! -f "$file" ]; then
        continue
    fi

    filename=$(basename "$file")
    # Remove .w3x extension, convert to uppercase, and remove underscores
    processed=$(echo "$filename" | sed 's/\.w3x$//' | tr '[:lower:]' '[:upper:]' | tr -d '_')

    # Check if the processed filename contains any valid map name as substring
    keep_file=0
    for map in "${VALID_MAP_NAMES[@]}"; do
        if [[ "$processed" == *"$map"* ]]; then
            keep_file=1
            break
        fi
    done

    if [ $keep_file -eq 0 ]; then
        echo "Deleting $file (processed as $processed) because it doesn't match any valid map name."
        rm "$file"
    else
        echo "Keeping $file (processed as $processed)."
    fi
done

echo "Cleanup complete."
