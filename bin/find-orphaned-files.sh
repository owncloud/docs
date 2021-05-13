#!/usr/bin/env bash

#
# This script checks the three core ownCloud documentation manuals to 
# see if any of the example files are orphaned.
#

AVAILABLE_MANUALS=( admin developer user )

list=$(echo ${AVAILABLE_MANUALS[@]} | sed -r 's/[ ]+/, /g')

echo
echo "Checking for orphaned EXAMPLE files in manual: ${list}."
echo "Please run this scrip from your docs root"
echo

for manual in "${AVAILABLE_MANUALS[@]}"; do
    [[ ! -e "./modules/${manual}_manual/" ]] && echo "Cannot find ${manual} manual." && continue

    echo "Checking the ${manual} manual"
    find "./modules/${manual}_manual/examples/" \
        \( -path "**/.DS_Store" -o -path "**/vendor" -o -path "**/.gitkeep" \) -prune -o \
        -type f \
        -exec bash -c 'grep -rnq -E "^include.*$(basename $0 | sed "s/\./\\./")" ./modules/$1_manual/pages || echo "Detected orphan file: $0"' {} "${manual}" \;
    echo
done

echo "Check completed."
echo
echo "Please consider that files may have been added intentionally but have currently not been included in the documentation."
echo
echo "You may want to check the orphan history via:"
echo
echo "git log --full-history -- full_path_file_from_above"
echo
