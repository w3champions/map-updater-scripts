#!/bin/bash
mapExtractionPath=".\\maps\\map.w3x"
cleanMapPath=".\\maps\\w3c_maps\\clean_maps"
outputMapPath=".\\maps\\w3c_maps\\output"
    
rm -rfv "$outputMapPath" && mkdir "$outputMapPath"
for filename in "$cleanMapPath"/*.w3x; do
    echo "$filename"
    basename "$filename"
    f="$(basename -- $filename)"
    rm -rfv "$mapExtractionPath" && mkdir "$mapExtractionPath"
    "$cleanMapPath"/MPQEditor.exe extract "$filename" "*" "$mapExtractionPath" "/fp"
    rm -rf dist/ && npm run build
    echo "MOVING TO $outputMapPath\\$f"
    mv ".\\maps\w3c_maps\\map.w3x" "$outputMapPath\\$f"
done

echo "Map updates completed successfully"