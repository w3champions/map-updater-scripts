#!/bin/bash
set -e

customBaseFolder="$1"
filterArg="$2"

if [[ "$customBaseFolder" == "output" ]]; then
    echo "Error: 'output' cannot be used as the custom base folder."
    exit 1
fi

if [[ -n "$customBaseFolder" ]]; then
    cleanMapPath="./maps/w3c_maps/$customBaseFolder"
else
    cleanMapPath="./maps/w3c_maps/clean_maps"
fi

# An un-prefixed map is mirrored into output/ under its subfolder's name
# RELATIVE TO $cleanMapPath (that's how e.g. clean_maps/tournament ends up
# in output/tournament). Only a DIRECT child of $cleanMapPath named
# "upload" (any letter case - Windows folder names are case-insensitive)
# collides with output/upload, the folder build-upload-folder.sh
# (re)creates and deletes on every run: a deeper one like clean_maps/foo/
# upload lands in output/foo/upload instead, and $cleanMapPath itself
# being named "upload" (a custom base folder argument) doesn't matter
# either, since the base folder's own name never appears in relFolder.
# There's no other route onto output/upload - mode subfolders only ever
# come from the fixed prefixList below, which doesn't include "upload".
# Catch the real case early, before any expensive map building starts.
if [[ -n "$(find "$cleanMapPath" -mindepth 1 -maxdepth 1 -type d -iname upload -print -quit 2>/dev/null)" ]]; then
    echo "Error: '$cleanMapPath' has a subfolder named 'upload'. That name is reserved for the generated output/upload folder; rename the source subfolder and re-run."
    exit 1
fi

IFS=',' read -r -a filterPrefixes <<< "$filterArg"
filterEnabled=false
if [[ -n "$filterArg" ]]; then
    filterEnabled=true
fi

mapExtractionPath="./maps/map.w3x"
outputMapPath="./maps/w3c_maps/output"
mpqPath="./MPQEditor.exe"
currentDateTime=$(date '+%y%m%d_%H%M')
buildMapPath="./maps/w3c_maps/tmp.w3x"

rm -rf "$outputMapPath" && mkdir "$outputMapPath"

prefixList=("1v1_" "2v2_" "3v3_" "4v4_" "FFA_")

while IFS= read -r -d '' fullPath; do
    fileName="$(basename $fullPath)"
    dirName="$(dirname $fullPath)"
    relFolder="${dirName#${cleanMapPath}}"

    matchedModes=()
    strippedName="$fileName"

    # If filename contains @, e.g. {name}@{mapId}.w3x
    # then transform it to {mapId}_{name}.w3x
    mapIdPrefix=
    if [[ "$fileName" == *@* ]]; then
        fileExtension="${fileName##*.}"
        noExtensionFileName="${fileName%.*}"

        mapIdPrefix="${noExtensionFileName#*@}_"
        strippedName="${fileName%@*}.${fileExtension}"
    fi

    while :; do
        matched=false
        for prefix in "${prefixList[@]}"; do
            if [[ "$strippedName" == "$prefix"* ]]; then
                mode="${prefix%_}"
                if [[ "$filterEnabled" = false || " ${filterPrefixes[*]} " == *" $mode "* ]]; then
                    matchedModes+=("$mode")
                fi
                strippedName="${strippedName#${prefix}}"
                matched=true
                break
            fi
        done
        [[ "$matched" = false ]] && break
    done

    if [[ "$filterEnabled" = true && ${#matchedModes[@]} -eq 0 ]]; then
        printf "\nSkipping $fileName from folder '$relFolder'...\n\n"
        continue
    else
        printf "\nProcessing $fileName from folder '$relFolder'...\n\n"
    fi

    rm -rf "$mapExtractionPath" && mkdir "$mapExtractionPath"

    printf "Running: \"$mpqPath\" extract \"$fullPath\" \"*\" \"$mapExtractionPath\" \"/fp\" \n"
    "$mpqPath" extract "$fullPath" "*" "$mapExtractionPath" "/fp"

    rm -rf dist/ && npm run build "$dirName"
    mv ./maps/w3c_maps/map.w3x "$buildMapPath"

    newFileName="${mapIdPrefix}w3c_${currentDateTime}_$strippedName"

    if [[ ${#matchedModes[@]} -gt 0 ]]; then
        for mode in "${matchedModes[@]}"; do
            targetDir="$outputMapPath/$mode"
            mkdir -p "$targetDir"
            printf "\nMoving map to $targetDir/$newFileName\n\n"
            cp "$buildMapPath" "$targetDir/$newFileName"
        done
    else
        if [[ -z "$relFolder" ]]; then
            targetDir="$outputMapPath"
        else
            targetDir="$outputMapPath/$relFolder"
        fi
        mkdir -p "$targetDir"
        printf "\nMoving map to $targetDir/$newFileName\n\n"
        mv "$buildMapPath" "$targetDir/$newFileName"
    fi

    rm -rf "$buildMapPath"

done < <(find "$cleanMapPath" -type f \( -iname '*.w3m' -o -iname '*.w3x' \) -print0)

rm -f "$buildMapPath"

cleanMapsCount=$(find "$cleanMapPath" -type f \( -iname '*.w3m' -o -iname '*.w3x' \) | wc -l)
completedMapsCount=$(find "$outputMapPath" -type f \( -iname '*.w3m' -o -iname '*.w3x' \) -printf "%f\n" | sort -u | wc -l)
echo "Processed $cleanMapsCount maps and output $completedMapsCount maps."

# A map that belongs to several game-mode pools ends up under the same file
# name in several mode subfolders above. Collect one copy of each distinct
# file into output/upload/ so the admin bulk-upload page never sees the
# same file name twice in one selection.
bash ./scripts/build-upload-folder.sh "$outputMapPath"

echo "Map updates completed successfully."
