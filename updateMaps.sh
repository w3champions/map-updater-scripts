#!/bin/bash
mapExtractionPath=".\\maps\\map.w3x"
mapPath=".\\maps\\w3c_maps"
for filename in "$mapPath"/*.w3x; do
    echo "$filename"
    rm -rfv "$mapExtractionPath" && mkdir "$mapExtractionPath"
    "$mapPath"/MPQEditor.exe extract "$filename" "*" "$mapExtractionPath" "/fp"
    rm -rf dist/ && npm run build
    mv "$mapPath"/map.w3x "$filename"
done

echo "Map updates completed successfully"