#!/bin/bash

# Do not enter the for-loop if no files were found
shopt -s nullglob

mapExtractionPath="./maps/map.w3x"
cleanMapPath="./maps/w3c_maps/clean_maps/current"
outputMapPath="./maps/w3c_maps/output"
mpqPath="./MPQEditor.exe"

rm -rf "$outputMapPath" && mkdir "$outputMapPath"

for fullPath in $(find $cleanMapPath -name '*.w3m' -or -name '*.w3x'); do
    fileName="$(basename $fullPath)"
    dirName="$(dirname $fullPath)"

    printf "\nProcessing $fileName... \n\n"
    rm -rf "$mapExtractionPath" && mkdir "$mapExtractionPath"
    printf "Running command: $mpqPath extract $fullPath * $mapExtractionPath /fp \n"
    "$mpqPath" extract "$fullPath" "*" "$mapExtractionPath" "/fp"
    rm -rf dist/ && npm run build

    outpath=$outputMapPath

    if [[ $dirName == *"tournament" ]]; then
        outpath="${outputMapPath}/tournament"
    elif [[ $dirName == *"all-the-randoms" ]]; then
        outpath="${outputMapPath}/all-the-randoms"
    elif [[ $dirName == *"reign-of-chaos" ]]; then
        outpath="${outputMapPath}/reign-of-chaos"
    fi

    # Create the directory if it doesn't exist
    if [[ ! -e $outpath ]]; then
        mkdir "$outpath"
    fi

    printf "\nMoving map to $outpath/$fileName \n"
    mv "./maps/w3c_maps/map.w3x" "$outpath/$fileName"
done

echo "Map updates completed successfully"
