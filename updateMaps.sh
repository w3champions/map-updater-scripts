#!/bin/bash
mapExtractionPath=".\\maps\\map.w3x"
cleanMapPath=".\\maps\\w3c_maps\\clean_maps"
outputMapPath=".\\maps\\w3c_maps\\output"
outputTournamentMapPath="$outputMapPath\\tournaments"
    
rm -rfv "$outputMapPath" && mkdir "$outputMapPath" && mkdir "$outputTournamentMapPath"
for filename in "$cleanMapPath"/*.w3*; do
    echo "$filename"
    basename "$filename"
    f="$(basename -- $filename)"
    rm -rfv "$mapExtractionPath" && mkdir "$mapExtractionPath"
    echo "$cleanMapPath"/MPQEditor.exe extract "$filename" "*" "$mapExtractionPath" "/fp"
    "$cleanMapPath"/MPQEditor.exe extract "$filename" "*" "$mapExtractionPath" "/fp"
    rm -rf dist/ && npm run build
    
    outpath=$outputMapPath
    if [[ $f == *"tourney"* ]];then
        outpath=$outputTournamentMapPath
    fi
    echo "MOVING TO $outpath\\$f"
    mv ".\\maps\w3c_maps\\map.w3x" "$outpath\\$f"
done

echo "Map updates completed successfully"