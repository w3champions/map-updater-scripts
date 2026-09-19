#!/bin/bash
# Builds maps/w3c_maps/output/upload/: a flat copy of every DISTINCT map
# produced by updateMaps.sh, so the website's bulk-upload page never has
# to deal with two files sharing the same name in one selection.
#
# Background: a map that belongs to several game-mode pools (e.g. 1v1 and
# 2v2) is written once per mode subfolder under the same file name with
# byte-identical content. Selecting the whole per-mode tree at once in the
# admin upload page silently drops all but one of those same-named files.
#
# This script is called by updateMaps.sh after the per-mode outputs are
# produced, but it can also be run standalone against any output folder
# to test the dedupe step without running the whole map build, e.g.:
#   bash ./scripts/build-upload-folder.sh ./maps/w3c_maps/output
set -e

outputMapPath="${1%/}"

if [[ -z "$outputMapPath" ]]; then
    echo "Usage: $0 <outputMapPath>" >&2
    exit 1
fi

if [[ ! -d "$outputMapPath" ]]; then
    echo "Error: '$outputMapPath' is not a directory." >&2
    exit 1
fi

uploadPath="$outputMapPath/upload"
tmpUploadPath="$outputMapPath/upload.tmp.$$"

# Remove any previous upload/ up front, same as before, so a run that fails
# never leaves the previous batch's folder around to be mistaken for a
# current one. Build the new contents into a scratch sibling directory
# instead of into upload/ directly, and only swap it into place once every
# file has been copied and verified - that way a failed run leaves NO
# upload/ at all (never a half-populated one). The trap cleans the scratch
# dir on any exit path (success clears the trap itself after the swap).
rm -rf "$uploadPath"
trap 'rm -rf "$tmpUploadPath"' EXIT
rm -rf "$tmpUploadPath" && mkdir -p "$tmpUploadPath"

sourceFilesCount=0

# Parallel indexed arrays (kept bash 3.2 compatible - no associative
# arrays) recording, per distinct file collected so far: its lower-cased
# name (for case-insensitive lookup), its canonical (first-seen) name, and
# the comma-separated list of subfolders it has been seen in.
seenLowerNames=()
seenNames=()
seenDirs=()

findSeenIndex() {
    local lowerName="$1"
    local i
    for i in "${!seenLowerNames[@]}"; do
        if [[ "${seenLowerNames[$i]}" == "$lowerName" ]]; then
            echo "$i"
            return
        fi
    done
    echo "-1"
}

while IFS= read -r -d '' fullPath; do
    fileName="$(basename "$fullPath")"
    dirName="$(dirname "$fullPath")"
    relDir="${dirName#$outputMapPath/}"
    [[ "$relDir" == "$dirName" ]] && relDir="."
    sourceFilesCount=$((sourceFilesCount + 1))

    lowerName="$(printf '%s' "$fileName" | tr '[:upper:]' '[:lower:]')"
    idx=$(findSeenIndex "$lowerName")

    if [[ "$idx" -ge 0 ]]; then
        priorName="${seenNames[$idx]}"

        # Two names that only differ by case collapse into one file on a
        # case-insensitive filesystem (Windows/macOS, i.e. this pipeline)
        # but would stay two separate files on the case-sensitive Linux
        # server - that mismatch can only be a mistake in the source maps.
        if [[ "$fileName" != "$priorName" ]]; then
            echo "Error: '$priorName' (in ${seenDirs[$idx]}) and '$fileName' (in $relDir) differ only by letter case." >&2
            echo "That collapses into one file here but would stay two files on the case-sensitive server. Rename one of the source maps so the names match exactly, then re-run." >&2
            exit 1
        fi

        existing="$tmpUploadPath/$priorName"
        if cmp -s "$existing" "$fullPath"; then
            seenDirs[$idx]="${seenDirs[$idx]},$relDir"
            continue
        fi

        echo "Error: '$fileName' exists in more than one output subfolder with DIFFERENT content." >&2
        echo "  Conflicting file: $fullPath" >&2
        echo "  Already collected from ${seenDirs[$idx]} into: $existing" >&2
        echo "Fix the source maps so every mode pool shares byte-identical output for this file, then re-run." >&2
        exit 1
    fi

    cp "$fullPath" "$tmpUploadPath/$fileName"
    seenLowerNames+=("$lowerName")
    seenNames+=("$fileName")
    seenDirs+=("$relDir")
done < <(find "$outputMapPath" -type f \( -iname '*.w3m' -o -iname '*.w3x' \) -not -path "$uploadPath/*" -not -path "$tmpUploadPath/*" -print0)

distinctFilesCount=${#seenNames[@]}

# Everything checked out: swap the verified scratch dir into place and
# disarm the cleanup trap so the finished folder survives.
mv "$tmpUploadPath" "$uploadPath"
trap - EXIT

echo "Built upload folder from $sourceFilesCount source maps: $distinctFilesCount distinct files in $uploadPath."

dupHeaderPrinted=false
for i in "${!seenNames[@]}"; do
    if [[ "${seenDirs[$i]}" == *,* ]]; then
        if [[ "$dupHeaderPrinted" == false ]]; then
            echo "Found in more than one mode subfolder (identical content, copied once):"
            dupHeaderPrinted=true
        fi
        echo "  - ${seenNames[$i]} (in: ${seenDirs[$i]})"
    fi
done
