#!/bin/bash

# 1. Подмигиваем в самом начале через уведомление macOS
osascript -e 'display notification "Начинаю проверку связи с Google..." with title "KVN Тест" sound name "Glass"'

echo "--- Запуск пинга ---"

# 2. Пингуем 3 раза
if ping -c 3 google.com; then
    # 3. Если пинг прошел — радостное сообщение
    echo "--- Успех! ---"
    osascript -e 'display dialog "Связь с Google установлена! ✅" buttons {"Отлично"} default button "Отлично" with title "Результат теста"'
else
    # 4. Если интернета нет — грустное сообщение
    echo "--- Ошибка ---"
    osascript -e 'display dialog "Нет связи. Проверь интернет! ❌" buttons {"Понял"} default button "Понял" with icon stop'
fi
