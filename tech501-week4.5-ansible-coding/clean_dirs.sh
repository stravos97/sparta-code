#!/bin/bash
set -euo pipefail

# Enable extended globbing so that globs that match no files result in an empty list.
shopt -s nullglob dotglob

# Defaults
DRY_RUN=false
VERBOSE=false
ROOT_DIR="/Volumes/Multimedia/Music/new music 2025/new music-2023/new music-2023"

usage() {
    echo "Usage: $0 [-n] [-v] [directory]"
    echo "  -n   Dry run: show what would be deleted without deleting anything."
    echo "  -v   Verbose: print messages about each directory processed."
    exit 1
}

# Process command-line options
while getopts "nvh" opt; do
    case "$opt" in
        n) DRY_RUN=true ;;
        v) VERBOSE=true ;;
        h) usage ;;
        *) usage ;;
    esac
done
shift $((OPTIND - 1))

# If a directory is provided as an argument, use it instead of the default.
if [ "$#" -ge 1 ]; then
    ROOT_DIR="$1"
fi

# Check the root directory exists.
if [ ! -d "$ROOT_DIR" ]; then
    echo "Error: $ROOT_DIR is not a directory or does not exist."
    exit 1
fi

# Define allowed image extensions (in lowercase)
IMAGE_EXTENSIONS=("jpg" "jpeg" "png" "gif" "bmp" "tiff" "webp")

# Function: is_image
# Returns 0 (true) if the file has one of the allowed image extensions.
is_image() {
    local file="$1"
    local ext="${file##*.}"
    # Convert the extension to lowercase using tr (for compatibility with older Bash versions)
    ext=$(echo "$ext" | tr '[:upper:]' '[:lower:]')
    for img_ext in "${IMAGE_EXTENSIONS[@]}"; do
        if [[ "$ext" == "$img_ext" ]]; then
            return 0
        fi
    done
    return 1
}

# Process directories in depth-first order.
# The -depth flag makes sure we process subdirectories before their parent directories.
find "$ROOT_DIR" -depth -type d | while IFS= read -r dir; do
    # Get a list of all immediate children (files and directories, including hidden ones)
    entries=( "$dir"/* "$dir"/.* )
    count=0
    should_delete=true

    for entry in "${entries[@]}"; do
        # If there’s no match for the glob, skip
        if [ ! -e "$entry" ]; then
            continue
        fi
        # Skip the special directories '.' and '..'
        base=$(basename "$entry")
        if [ "$base" = "." ] || [ "$base" = ".." ]; then
            continue
        fi

        count=$((count+1))
        if [ -d "$entry" ]; then
            # If there's any subdirectory present, then this directory is not eligible
            should_delete=false
            break
        elif [ -f "$entry" ]; then
            # If it's a file, check if it’s an image.
            if ! is_image "$entry"; then
                should_delete=false
                break
            fi
        else
            # For any other type (symlink, etc.), assume it disqualifies deletion.
            should_delete=false
            break
        fi
    done

    # If there were no entries at all, the directory is empty.
    if [ "$count" -eq 0 ]; then
        should_delete=true
    fi

    if $should_delete; then
        if $VERBOSE || $DRY_RUN; then
            echo "Deleting directory: $dir"
        fi
        if ! $DRY_RUN; then
            # Attempt deletion; if it fails, log a warning but do not exit the script.
            if ! rm -rf "$dir"; then
                echo "Warning: Failed to remove $dir"
            fi
        fi
    else
        if $VERBOSE; then
            echo "Keeping directory: $dir"
        fi
    fi
done

