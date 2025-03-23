#!/bin/bash

echo "Updating submodules..."
git submodule update --init --recursive
git submodule sync

# Navigate to submodule
cd src/shared || { echo "Error: src/shared does not exist"; exit 1; }

# Check if branch 'game-mode-maps' exists locally
if git rev-parse --verify game-mode-maps >/dev/null 2>&1; then
    echo "Branch 'game-mode-maps' already exists, checking it out..."
    git checkout game-mode-maps
else
    echo "Fetching and creating branch 'game-mode-maps'..."
    git fetch origin game-mode-maps:refs/remotes/origin/game-mode-maps
    git checkout -b game-mode-maps origin/game-mode-maps
fi

# Enable sparse-checkout only if not already enabled
if [[ "$(git config --get core.sparseCheckout)" != "true" ]]; then
    echo "Enabling sparse-checkout..."
    git config core.sparseCheckout true
fi

# Go back to root directory
cd ../..

# Set sparse-checkout pattern only if not already set
SPARSE_FILE=".git/modules/src/shared/info/sparse-checkout"
PATTERN="src/shared/game-mode-maps.ts"

if ! grep -Fxq "$PATTERN" "$SPARSE_FILE"; then
    echo "Adding sparse-checkout pattern..."
    echo "$PATTERN" > "$SPARSE_FILE"
fi

# Apply sparse-checkout
cd src/shared || exit 1
git read-tree -mu HEAD

# Go back to root
cd ../..

echo "Submodule setup complete!"
