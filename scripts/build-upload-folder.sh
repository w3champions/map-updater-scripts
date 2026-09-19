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
findListPath="$outputMapPath/.upload-folder.filelist.$$"

# Remove any previous upload/ up front, same as before, so a run that fails
# never leaves the previous batch's folder around to be mistaken for a
# current one. Build the new contents into a scratch sibling directory
# instead of into upload/ directly, and only swap it into place once every
# file has been copied and verified - that way a failed run leaves NO
# upload/ at all (never a half-populated one). The trap cleans the scratch
# dir and file list on any exit path (success clears the trap itself after
# the swap).
rm -rf "$uploadPath"

# A previous invocation of this script can have been killed before its own
# EXIT trap ran (SIGKILL, power loss), leaving an orphaned
# upload.tmp.<old-pid>/ or .upload-folder.filelist.<old-pid> of its own
# behind. In the full pipeline this never actually lingers, since
# updateMaps.sh wipes output/ clean before every run - it only matters for
# a standalone invocation of this script. Sweep every leftover with our
# reserved names BEFORE creating our own (so we never sweep up our own
# scratch dir below), confined to direct children of $outputMapPath so
# this can never reach outside it.
find "$outputMapPath" -mindepth 1 -maxdepth 1 \( -iname 'upload.tmp.*' -o -iname '.upload-folder.filelist.*' \) -exec rm -rf {} +

trap 'rm -rf "$tmpUploadPath" "$findListPath"' EXIT
rm -rf "$tmpUploadPath" && mkdir -p "$tmpUploadPath"

# List every source map into a file first and check find's own exit status
# before trusting the list. Piping straight into `while read` (as this used
# to do via process substitution) hides a mid-traversal find failure - e.g.
# an unreadable subfolder - behind the while loop's own (successful) exit
# status, which would let a PARTIAL set get published as if it were
# complete. `-H` makes find follow $outputMapPath itself if it is a
# symlink (find's default never follows a command-line symlink, which
# would otherwise silently look like an empty, but "successful", output).
# The sweep above already removes every upload.tmp.*/.upload-folder.filelist.*
# leftover, but these -not -path exclusions cover the same ground as a
# second line of defence, same as $uploadPath/$tmpUploadPath below.
if ! find -H "$outputMapPath" -type f \( -iname '*.w3m' -o -iname '*.w3x' \) \
        -not -path "$uploadPath/*" \
        -not -path "$tmpUploadPath/*" \
        -not -path "$outputMapPath/upload.tmp.*" \
        -not -path "$outputMapPath/upload.tmp.*/*" \
        -not -path "$outputMapPath/.upload-folder.filelist.*" \
        -print0 > "$findListPath"; then
    echo "Error: failed to fully list the maps under '$outputMapPath' (see the find error above). Refusing to publish a possibly-incomplete upload folder." >&2
    exit 1
fi

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

    # `tr` only case-folds single-byte (ASCII) letters, so it treats an
    # accented pair like "É.w3x"/"é.w3x" as different names even though
    # they are NOT different names on this pipeline's case-insensitive
    # filesystem (Windows/macOS). Keep it only as a fast, portable guess.
    lowerName="$(printf '%s' "$fileName" | tr '[:upper:]' '[:lower:]')"
    idx=$(findSeenIndex "$lowerName")

    targetPath="$tmpUploadPath/$fileName"
    if [[ "$idx" -lt 0 && -e "$targetPath" ]]; then
        # tr's ASCII-only fold above didn't flag this as a duplicate, but
        # the destination filesystem's own case rules already collapse
        # "$fileName" onto a file collected earlier - trust the filesystem
        # over tr. Ask it (by inode, via -samefile, so this is correct
        # regardless of locale/encoding) which entry that actually is, and
        # resolve it back to our recorded index so it goes through the
        # exact same duplicate/conflict handling as an ASCII case match.
        priorOnDisk="$(find "$tmpUploadPath" -maxdepth 1 -samefile "$targetPath" -printf '%f\n' 2>/dev/null | head -n1)"
        for i in "${!seenNames[@]}"; do
            if [[ "${seenNames[$i]}" == "$priorOnDisk" ]]; then
                idx=$i
                break
            fi
        done

        if [[ "$idx" -lt 0 ]]; then
            # Should not happen - defensive fallback so we never fall
            # through to a `cp` that would silently overwrite this file.
            echo "Error: '$fileName' (in $relDir) collides with an already-collected file in $tmpUploadPath under the destination filesystem's case rules, but it could not be matched back to a known source file." >&2
            exit 1
        fi
    fi

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

    cp "$fullPath" "$targetPath"
    seenLowerNames+=("$lowerName")
    seenNames+=("$fileName")
    seenDirs+=("$relDir")
done < "$findListPath"

distinctFilesCount=${#seenNames[@]}

# Zero maps found is not treated as an error: updateMaps.sh's own game-mode
# filter (see its README section) can legitimately match nothing for a
# given base folder/filter combination, and updateMaps.sh itself already
# treats that as a non-fatal, completed run rather than a failure. Still
# call it out, since after a real full build it can only mean something
# upstream went wrong.
if [[ "$sourceFilesCount" -eq 0 ]]; then
    echo "Note: no source maps found under $outputMapPath; upload/ will be empty."
fi

# Everything checked out: swap the verified scratch dir into place. The
# EXIT trap stays armed - it only ever targets $tmpUploadPath (which no
# longer exists once moved, so removing it again is a harmless no-op) and
# $findListPath, which still needs cleaning up on this, the success path,
# too.
mv "$tmpUploadPath" "$uploadPath"

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
