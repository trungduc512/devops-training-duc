#!/usr/bin/env bash

set -euo pipefail

# Display usage/help message
show_help() {
    cat << EOF
Usage: $0 [OPTIONS] <directory>

Backup a directory into ~/backups

Options:
  --exclude=PATTERN   Exclude files matching PATTERN
  -h, --help          Show this help message
EOF
}

# Pattern to exclude from the archive (optional)
exclude_pattern=""
# Target directory to back up (required)
dir=""

# Parse arguments: support --exclude=PATTERN and a single directory argument
for arg in "$@"; do
    case "$arg" in
        -h|--help)
            show_help
            exit 0
            ;;
        --exclude=*)
            # extract the pattern after the '='
            exclude_pattern="${arg#*=}"
            ;;
        *)
            # accept only one directory argument; error on extras
            if [[ -z "$dir" ]]; then
                dir="$arg"
            else
                echo "Error: Too many arguments."
                exit 1
            fi
            ;;
    esac
done

# Ensure a directory argument was provided
if [[ -z "$dir" ]]; then
    echo "Error: Directory is required."
    show_help
    exit 1
fi

# Verify the provided path exists and is a directory
if [[ ! -d "$dir" ]]; then
    echo "Error: '$dir' does not exist."
    exit 1
fi

# Destination folder for backups in the user's home
backup_dir="$HOME/backups"
mkdir -p "$backup_dir"

# Compute base name and timestamp for the archive filename
dirname_only="$(basename "$dir")"
timestamp="$(date +%Y%m%d-%H%M%S)"
archive="$backup_dir/${dirname_only}-${timestamp}.tar.gz"

# Create the tar.gz archive. If an exclude pattern was given, pass it to tar.
create_backup() {
    if [[ -n "$exclude_pattern" ]]; then
        # Use tar's --exclude to skip matching files/paths
        tar --exclude="$exclude_pattern" -czf "$archive" -C "$(dirname "$dir")" "$dirname_only"
    else
        tar -czf "$archive" -C "$(dirname "$dir")" "$dirname_only"
    fi
}

create_backup

# Compute simple statistics for user feedback.
# Note: the file_count excludes paths matching the exclude pattern when given.
if [[ -n "$exclude_pattern" ]]; then
    # Use find with a negative path match to approximate excluded files
    file_count=$(find "$dir" -type f ! -path "*$exclude_pattern*" | wc -l)
else
    file_count=$(find "$dir" -type f | wc -l)
fi

# Human-readable total size of the directory
total_size=$(du -sh "$dir" | cut -f1)

# Final messages to the user
echo "Backup created: $archive"
echo "Files backed up : $file_count"
echo "Total size      : $total_size"