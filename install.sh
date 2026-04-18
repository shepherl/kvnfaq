#!/bin/bash

# 1. Уведомление
osascript -e 'display notification "Начинаю проверку связи..." with title "KVN Тест" sound name "Glass"'

echo "--- Запуск пинга ---"

# 2. Начало блока IF
if ping -c 3 google.com; then
    echo "--- Успех! ---"
    
    # 3. Диалог (тут всё в одной строке, проверь кавычки)
    ANSWER=$(osascript -e 'display dialog "Связь есть! Открыть Google в браузере?" buttons {"Нет", "Да"} default button "Да" with title "Тест завершен"' -e 'button returned of result')

    if [ "$ANSWER" = "Да" ]; then
        echo "🌐 Открываю Google..."
        open "https://www.google.com"
    fi # Закрыли внутренний IF

else
    echo "--- Ошибка ---"
    osascript -e 'display dialog "Нет связи. Проверь интернет! ❌" buttons {"Понял"} default button "Понял" with icon stop'
fi # Закрыли внешний IF (СКОРЕЕ ВСЕГО, ТУТ БЫЛА ОШИБКА)
