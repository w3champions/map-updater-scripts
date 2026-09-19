#!/bin/bash
set -e

outputMapPath="./maps/w3c_maps/output"

# Whatever happens below, a previous batch must not stay at the path operators
# upload from. Only the collected folder goes here: the rest of output/ is
# emptied once the arguments are accepted, so a rejected run keeps the last
# build, and the guard below still protects an output/ given as the source.
rm -rf "$outputMapPath/upload"

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

# An unprefixed map keeps its subfolder relative to the base folder, which is
# how clean_maps/tournament reaches output/tournament. A direct child named
# "upload" (in any letter case on Windows) would therefore be written to
# output/upload, which build-upload-folder.sh replaces on every run. Deeper
# folders and the base folder's own name do not map onto it.
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
