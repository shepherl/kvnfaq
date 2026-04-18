#!/bin/bash

# 1. Уведомление в углу экрана
osascript -e 'display notification "Начинаю проверку связи..." with title "KVN Тест" sound name "Glass"'

echo "--- Запуск пинга ---"

# 2. Пингуем Google 3 раза
if ping -c 3 google.com; then
    echo "--- Успех! ---"
    
    # 3. Диалоговое окно с вопросом
    # Мы сохраняем ответ пользователя в переменную
    ANSWER=$(osascript -e 'display dialog "Связь есть! Открыть Google в браузере?" buttons {"Нет", "Да"} default button "Да" with title "Тест завершен"' -e 'button returned of result')

    if [ "$ANSWER" = "Да" ]; then
        echo "🌐 Открываю Google..."
        open "https://www.google.com"
    else
        echo "👌 Ок, браузер не трогаем."
    fi

else
    echo "--- Ошибка ---"
    osascript -e 'display dialog "Нет связи. Проверь интернет! ❌" buttons {"Понял"} default button "Понял" with icon stop'
fi.sh
