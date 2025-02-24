# This script creates a secure encrypted archive of multiple files/folders
Uses tar for archiving and gpg for AES-256 encryption, with enhanced security features

## How to use:

### Encrypt
1. Save this script as 'encrypt_files.sh'
2. Make it executable: chmod +x encrypt_files.sh
3. Run it with files/folders as arguments
    Example: `./encrypt_files.sh docs/ photo.jpg notes.txt`
    This will create 'encrypted_data.tar.gpg' containing all specified files/folders

### To decrypt:
Run: `gpg -d encrypted_data.tar.gpg | tar -x`
You'll be prompted for the passphrase you set during encryption
