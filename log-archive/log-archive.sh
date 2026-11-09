#!/usr/bin/env bash

set -o nounset
set -o pipefail

# Resolve the directory containing this script.
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"

# Define archive storage locations.
ARCHIVE_DIR="${SCRIPT_DIR}/archives"
LOG_FILE="${ARCHIVE_DIR}/archive.log"

# Display an error message and exit.
error_exit() {
    local message="$1"
    local exit_code="${2:-1}"

    printf 'ERROR: %s\n' "$message" >&2
    exit "$exit_code"
}

# Validate command-line arguments.
if [[ "$#" -ne 1 ]]; then
    error_exit "Usage: $0 <log-directory>" 2
fi

# Store the source directory.
SOURCE_DIR="$1"

# Validate source directory.
if [[ ! -d "$SOURCE_DIR" ]]; then
    error_exit "Source directory does not exist: $SOURCE_DIR"
fi

if [[ ! -r "$SOURCE_DIR" || ! -x "$SOURCE_DIR" ]]; then
    error_exit "Insufficient permissions to access: $SOURCE_DIR"
fi

# Resolve the source directory to an absolute physical path.
SOURCE_DIR="$(cd -- "$SOURCE_DIR" && pwd -P)"

# Validate archive destination.
if [[ ! -d "$ARCHIVE_DIR" ]]; then
    error_exit "Archive directory does not exist: $ARCHIVE_DIR"
fi

if [[ ! -w "$ARCHIVE_DIR" || ! -x "$ARCHIVE_DIR" ]]; then
    error_exit "Insufficient permissions for archive directory: $ARCHIVE_DIR"
fi

# Resolve archive directory to an absolute physical path.
ARCHIVE_DIR="$(cd -- "$ARCHIVE_DIR" && pwd -P)"

# Prevent the archive destination from being the source or inside it.
if [[ "$ARCHIVE_DIR" == "$SOURCE_DIR" ]]; then
    error_exit "Archive destination must not be the source directory."
fi

case "${ARCHIVE_DIR}/" in
    "${SOURCE_DIR}/"*)
        error_exit "Archive destination must not be inside source directory."
        ;;
esac

# Generate archive timestamp.
if ! TIMESTAMP="$(date '+%Y%m%d_%H%M%S')"; then
    error_exit "Failed to generate archive timestamp."
fi

# Define archive filename and full path.
ARCHIVE_NAME="logs_archive_${TIMESTAMP}.tar.gz"
ARCHIVE_PATH="${ARCHIVE_DIR}/${ARCHIVE_NAME}"

# Prevent overwriting an existing archive.
if [[ -e "$ARCHIVE_PATH" ]]; then
    error_exit "Archive already exists: $ARCHIVE_PATH"
fi

printf 'Archive filename: %s\n' "$ARCHIVE_NAME"

# Restrict permissions for newly created files.
umask 077

# Create a temporary archive in the destination directory.
TEMP_ARCHIVE=""

cleanup() {
    if [[ -n "$TEMP_ARCHIVE" && -e "$TEMP_ARCHIVE" ]]; then
        rm -f -- "$TEMP_ARCHIVE"
    fi
}

trap cleanup EXIT

if ! TEMP_ARCHIVE="$(mktemp -- "${ARCHIVE_DIR}/.log-archive.XXXXXX")"; then
    error_exit "Failed to create temporary archive file."
fi

# Create the compressed archive.
if ! tar -czf "$TEMP_ARCHIVE" \
    -C "$(dirname -- "$SOURCE_DIR")" \
    "$(basename -- "$SOURCE_DIR")"; then
    error_exit "Archive creation failed."
fi

# Verify gzip integrity.
if ! gzip -t -- "$TEMP_ARCHIVE"; then
    error_exit "Archive integrity check failed."
fi

# Publish the archive without overwriting an existing file.
if ! ln -- "$TEMP_ARCHIVE" "$ARCHIVE_PATH"; then
    error_exit "Failed to publish archive. The destination may already exist."
fi

# Remove the temporary filename.
if ! rm -- "$TEMP_ARCHIVE"; then
    error_exit "Archive was created, but temporary file cleanup failed."
fi

TEMP_ARCHIVE=""


# Record successful archive creation.
if ! printf '%s | SOURCE: %s | ARCHIVE: %s | STATUS: SUCCESS\n' \
    "$(date '+%Y-%m-%d %H:%M:%S')" \
    "$SOURCE_DIR" \
    "$ARCHIVE_PATH" >> "$LOG_FILE"; then
    error_exit "Archive was created, but logging failed: $LOG_FILE"
fi

printf 'Archive created successfully: %s\n' "$ARCHIVE_PATH"
printf 'Archive details recorded in: %s\n' "$LOG_FILE"
