#!/bin/bash

# This script creates a secure encrypted archive of multiple files/folders
# Uses tar for archiving and gpg for AES-256 encryption, with enhanced security features
#
# How to use:
# 1. Save this script as 'encrypt_files.sh'
# 2. Make it executable: chmod +x encrypt_files.sh
# 3. Run it with files/folders as arguments
#    Example: ./encrypt_files.sh docs/ photo.jpg notes.txt
#    This will create 'encrypted_data.tar.gpg' containing all specified files/folders
#
# To decrypt:
# Run: gpg -d encrypted_data.tar.gpg | tar -x
# You'll be prompted for the passphrase you set during encryption

# Check if required tools (tar, gpg, and shred) are installed
command -v tar >/dev/null && command -v gpg >/dev/null || {
    echo "Error: Please install tar and gpg"
    exit 1  # Exit if tar or gpg is missing
}
command -v shred >/dev/null || {
    echo "Error: Install shred for secure deletion"
    exit 1  # Exit if shred is missing
}

# Check if user provided at least one file/folder as input
[ $# -eq 0 ] && {
    echo "Usage: $0 file1 [file2 ...]"  # $0 is the script name
    echo "Example: $0 docs/ photo.jpg notes.txt"
    exit 1  # Exit if no arguments
}

# Define output file name (no timestamp for less metadata leakage)
OUTPUT_FILE="encrypted_data.tar.gpg"
TEMP_FILE="/dev/shm/temp_archive.tar"  # Use RAM disk (/dev/shm) for temporary file

# Cleanup function to securely delete temporary files
cleanup() {
    # Check if temp file exists and securely delete it with shred
    [ -f "$TEMP_FILE" ] && shred -u "$TEMP_FILE" 2>/dev/null  # -u removes file after shredding
}

# Set trap to run cleanup on script exit, interruption, or termination
trap cleanup EXIT INT TERM

# Inform user what files/folders are being processed
echo "Creating encrypted archive of: $@"

# Create tar archive in RAM disk to avoid disk writes of unencrypted data
tar -cf "$TEMP_FILE" "$@" || {  # -c creates, -f specifies file
    echo "Error: Tar failed"
    exit 1  # Exit on tar failure
}

# Encrypt the archive with GPG using AES-256 and a user-provided passphrase
gpg --symmetric --cipher-algo AES256 -o "$OUTPUT_FILE" "$TEMP_FILE" || {
    echo "Error: Encryption failed"
    exit 1  # Exit on encryption failure
}

# Notify user of success and provide decryption instructions
echo "Success! Created: $OUTPUT_FILE"
echo "To decrypt and extract, use:"
echo "gpg -d $OUTPUT_FILE | tar -x"
