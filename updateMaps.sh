#!/bin/bash
set -e

IFS=',' read -r -a filterPrefixes <<< "$1"
filterEnabled=false
if [[ -n "$1" ]]; then
    filterEnabled=true
fi

mapExtractionPath="./maps/map.w3x"
cleanMapPath="./maps/w3c_maps/clean_maps"
outputMapPath="./maps/w3c_maps/output"
mpqPath="./MPQEditor.exe"
currentDate=$(date '+%Y%m%d')
buildMapPath="./maps/w3c_maps/map.w3x"

rm -rf "$outputMapPath" && mkdir "$outputMapPath"

prefixList=("1v1_" "2v2_" "3v3_" "4v4_" "FFA_")

while IFS= read -r -d '' fullPath; do
    fileName="$(basename $fullPath)"
    baseName="${fileName%.*}"
    extension="${fileName##*.}"
    newFileName="${baseName}_${currentDate}.${extension}"
    dirName="$(dirname $fullPath)"
    relFolder="${dirName#${cleanMapPath}}"

    matchedModes=()
    strippedName="$fileName"

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

    if [[ ${#matchedModes[@]} -gt 0 ]]; then
        for mode in "${matchedModes[@]}"; do
            targetDir="$outputMapPath/$mode"
            mkdir -p "$targetDir"
			printf "\nMoving map to $targetDir/$newFileName\n\n"
			         cp "$buildMapPath" "$targetDir/$newFileName"
        done
    else
        # Handle case where relFolder might be empty to avoid double slashes
        if [[ -z "$relFolder" ]]; then
            targetDir="$outputMapPath"
        else
            targetDir="$outputMapPath/$relFolder"
        fi
        mkdir -p "$targetDir"
  printf "\nMoving map to $targetDir/$newFileName\n\n"
        mv "$buildMapPath" "$targetDir/$newFileName"
    fi

done < <(find "$cleanMapPath" -type f \( -iname '*.w3m' -o -iname '*.w3x' \) -print0)

rm -rf "$buildMapPath" 2>/dev/null

cleanMapsCount=$(find $cleanMapPath -name '*.w3m' -or -name '*.w3x' | wc -l)
completedMapsCount=$(find $outputMapPath -name '*.w3m' -or -name '*.w3x' | wc -l)
echo "Processed $cleanMapsCount maps and output $completedMapsCount maps."

echo "Map updates completed successfully."
