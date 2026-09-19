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

# Maps are built in parallel. Transpiling is by far the largest part of a map's
# build time and is single threaded, so throughput scales with the number of
# jobs until the disk becomes the limit. Each job keeps every artifact it
# writes under its own ".jobs/<id>" folder (see getJobId in scripts/utils.ts):
# the build otherwise hardcodes one extraction folder, one dist folder, one
# tstl bundle and one output archive, which concurrent builds would silently
# overwrite for each other and produce maps carrying another map's script.
maxJobs="${JOBS:-$3}"
if [[ -z "$maxJobs" ]]; then
    maxJobs=$(nproc 2>/dev/null || echo 4)
    if (( maxJobs > 16 )); then
        maxJobs=16
    fi
fi
if ! [[ "$maxJobs" =~ ^[1-9][0-9]*$ ]]; then
    echo "Error: the parallel job count must be a positive integer (got '$maxJobs')."
    exit 1
fi

mpqPath="./MPQEditor.exe"
currentDateTime=$(date '+%y%m%d_%H%M')

jobRoot=".jobs"
jobStateDir="./dist/$jobRoot/state"

# The job folders are emptied on every run, so a base folder that resolves
# into one of them, for example ".jobs" or "../.jobs", would lose its maps
# before the batch even starts. "output" is rejected further up for the same
# reason. Both directions are checked, because a base folder that contains a
# job folder would have that part of its tree removed too.
sourceRealPath="$(realpath -m "$cleanMapPath")"
for scratchPath in "./maps/$jobRoot" "./dist/$jobRoot" "./maps/w3c_maps/$jobRoot"; do
    scratchRealPath="$(realpath -m "$scratchPath")"
    if [[ "$sourceRealPath" == "$scratchRealPath" || "$sourceRealPath" == "$scratchRealPath"/* || "$scratchRealPath" == "$sourceRealPath"/* ]]; then
        echo "Error: '$cleanMapPath' overlaps '$scratchPath', which this script deletes on every run. Move the maps out of that folder and re-run."
        exit 1
    fi
done

rm -rf "$outputMapPath" && mkdir -p "$outputMapPath"
rm -rf "./maps/$jobRoot" "./dist/$jobRoot" "./maps/w3c_maps/$jobRoot"
mkdir -p "$jobStateDir"

prefixList=("1v1_" "2v2_" "3v3_" "4v4_" "FFA_")

# Builds one map into its own job folder and copies the result to every output
# folder the map belongs to. Everything the build prints is captured, so
# parallel jobs cannot interleave their logs; only the one-line result reaches
# the terminal, and the captured log is replayed into project.log in map order
# once the batch finishes.
buildMap() {
    local index="$1" fullPath="$2" dirName="$3" newFileName="$4" targetDirs="$5" relFolder="$6"
    local jobId="$jobRoot/job-$index"
    local extractPath="./maps/$jobId/map.w3x"
    local builtMap="./maps/w3c_maps/$jobId/map.w3x"
    local log="$jobStateDir/$index.log"
    local started=$SECONDS
    local status=0

    # This job must always record a status for the dispatcher, so errexit is
    # off out here; the build steps below run in their own subshell that turns
    # it back on, which keeps a failing step from aborting the whole batch.
    #
    # That subshell is deliberately not the condition of an if, && or ||: bash
    # disables errexit inside a subshell used as a condition and an inner
    # "set -e" does not restore it, so a failing step would be masked by any
    # later successful one. A copy that fails for the first of several game
    # mode folders and then succeeds for the second is the case that matters
    # here, because it would publish an incomplete batch as a success.
    set +e
    (
        set -e
        printf "Processing %s from folder '%s'...\n\n" "$(basename "$fullPath")" "$relFolder"
        rm -rf "./maps/$jobId" "./dist/$jobId" "./maps/w3c_maps/$jobId"
        mkdir -p "$extractPath"
        printf 'Running: "%s" extract "%s" "*" "%s" "/fp" \n' "$mpqPath" "$fullPath" "$extractPath"
        "$mpqPath" extract "$fullPath" "*" "$extractPath" "/fp"
        W3C_JOB_ID="$jobId" npm run build "$dirName"
        if [[ ! -f "$builtMap" ]]; then
            echo "Error: the build did not produce '$builtMap'."
            exit 1
        fi
        while IFS= read -r targetDir; do
            [[ -z "$targetDir" ]] && continue
            mkdir -p "$targetDir"
            printf '\nMoving map to %s/%s\n\n' "$targetDir" "$newFileName"
            cp "$builtMap" "$targetDir/$newFileName"
        done <<< "$targetDirs"
    ) > "$log" 2>&1
    status=$?

    # Recorded before cleaning up, so a failing cleanup cannot leave the
    # dispatcher without a result for this map.
    echo "$status" > "$jobStateDir/$index.status"
    rm -rf "./maps/$jobId" "./dist/$jobId" "./maps/w3c_maps/$jobId"

    if (( status == 0 )); then
        printf '[%*s/%s] ok    %s (%ss)\n' "${#totalMaps}" "$index" "$totalMaps" "$newFileName" "$((SECONDS - started))"
    else
        printf '[%*s/%s] FAIL  %s (exit %s)\n' "${#totalMaps}" "$index" "$totalMaps" "$newFileName" "$status"
    fi
}

mapPaths=()
while IFS= read -r -d '' fullPath; do
    mapPaths+=("$fullPath")
done < <(find "$cleanMapPath" -type f \( -iname '*.w3m' -o -iname '*.w3x' \) -print0)

# Every map is planned before any of them is built, so a collision between
# two output names is reported before work starts instead of after some of
# it has already been published.
planPaths=()
planDirs=()
planNames=()
planTargets=()
planRelFolders=()

for fullPath in "${mapPaths[@]}"; do
    fileName="$(basename "$fullPath")"
    dirName="$(dirname "$fullPath")"
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
        printf "skip  %s from folder '%s'\n" "$fileName" "$relFolder"
        continue
    fi

    newFileName="${mapIdPrefix}w3c_${currentDateTime}_$strippedName"

    # Every folder this map belongs to, one per line. A map in several game
    # mode pools is written to each of them under the same name.
    targetDirs=""
    if [[ ${#matchedModes[@]} -gt 0 ]]; then
        for mode in "${matchedModes[@]}"; do
            targetDirs+="$outputMapPath/$mode"$'\n'
        done
    elif [[ -z "$relFolder" ]]; then
        targetDirs="$outputMapPath"$'\n'
    else
        targetDirs="$outputMapPath/$relFolder"$'\n'
    fi

    planPaths+=("$fullPath")
    planDirs+=("$dirName")
    planNames+=("$newFileName")
    planTargets+=("$targetDirs")
    planRelFolders+=("$relFolder")
done

totalMaps=${#planPaths[@]}

# Two source maps can reduce to the same output name in the same folder, for
# example 1v1_Foo@1.w3x and 1v1_2v2_Foo@1.w3x both becoming 1_w3c_<time>_Foo
# under output/1v1. Built one after another the second would quietly replace
# the first; built at the same time both jobs copy onto that one path and can
# leave a torn archive that still reports success. Refuse the batch instead.
declare -A claimedBy
collisions=0
for (( i = 0; i < totalMaps; i++ )); do
    while IFS= read -r targetDir; do
        [[ -z "$targetDir" ]] && continue
        targetPath="$targetDir/${planNames[$i]}"
        if [[ -n "${claimedBy[$targetPath]:-}" ]]; then
            echo "Error: '${planPaths[$i]}' and '${claimedBy[$targetPath]}' both produce '$targetPath'."
            collisions=$((collisions + 1))
        else
            claimedBy[$targetPath]="${planPaths[$i]}"
        fi
    done <<< "${planTargets[$i]}"
done

if (( collisions > 0 )); then
    echo "Rename the source maps so that each one produces its own output file, then re-run."
    exit 1
fi

echo "Building $totalMaps maps with up to $maxJobs parallel jobs..."
echo

running=0
launchedIndices=()
for (( i = 0; i < totalMaps; i++ )); do
    index=$((i + 1))
    newFileName="${planNames[$i]}"

    # Written before launching so a map that never reports back can still be
    # named in the failure summary.
    echo "$newFileName" > "$jobStateDir/$index.name"
    launchedIndices+=("$index")

    buildMap "$index" "${planPaths[$i]}" "${planDirs[$i]}" "$newFileName" "${planTargets[$i]}" "${planRelFolders[$i]}" &

    running=$((running + 1))
    if (( running >= maxJobs )); then
        # Reap one finished job before starting the next. Its exit code is
        # already recorded in the state folder, so it is ignored here.
        wait -n 2>/dev/null || true
        running=$((running - 1))
    fi
done

wait

# Each job empties its own scratch folders as it finishes, so only the now
# empty roots are left. Drop them whether or not the batch succeeded. The
# captured logs live under dist/ and are kept until the batch has succeeded.
rm -rf "./maps/$jobRoot" "./maps/w3c_maps/$jobRoot"

# Replay the captured per-map logs in map order, so project.log reads the same
# way it did when the maps were built one after another.
for (( i = 1; i <= totalMaps; i++ )); do
    if [[ -f "$jobStateDir/$i.log" ]]; then
        cat "$jobStateDir/$i.log" >> project.log
    fi
done

# A launched job that never wrote a status was killed or crashed before it
# could report. "wait" cannot tell us that, because it reports success once
# all children have been reaped, so a missing status counts as a failure and
# an incomplete batch is never collected for upload. Only launched maps are
# checked: a map skipped by the mode filter never writes a status either.
failedMaps=()
for i in "${launchedIndices[@]}"; do
    statusFile="$jobStateDir/$i.status"
    if [[ ! -f "$statusFile" || "$(cat "$statusFile")" != "0" ]]; then
        failedMaps+=("$i")
    fi
done

echo
if [[ ${#failedMaps[@]} -gt 0 ]]; then
    echo "${#failedMaps[@]} map(s) failed to build:"
    for i in "${failedMaps[@]}"; do
        echo
        echo "--- $(cat "$jobStateDir/$i.name" 2>/dev/null || echo "map $i") ---"
        if [[ ! -f "$jobStateDir/$i.status" ]]; then
            echo "The job did not report an exit status; it was killed or crashed."
        fi
        if [[ -f "$jobStateDir/$i.log" ]]; then
            tail -n 20 "$jobStateDir/$i.log"
        else
            echo "No log was captured for this map."
        fi
    done
    echo
    echo "No maps were collected for upload because the batch is incomplete."
    echo "Full build logs for this batch: $jobStateDir"
    exit 1
fi

rm -rf "./dist/$jobRoot"

cleanMapsCount=$(find "$cleanMapPath" -type f \( -iname '*.w3m' -o -iname '*.w3x' \) | wc -l)
completedMapsCount=$(find "$outputMapPath" -type f \( -iname '*.w3m' -o -iname '*.w3x' \) -printf "%f\n" | sort -u | wc -l)
echo "Processed $cleanMapsCount maps and output $completedMapsCount maps."

# A map that belongs to several game-mode pools ends up under the same file
# name in several mode subfolders above. Collect one copy of each distinct
# file into output/upload/ so the admin bulk-upload page never sees the
# same file name twice in one selection.
bash ./scripts/build-upload-folder.sh "$outputMapPath"

echo "Map updates completed successfully."
