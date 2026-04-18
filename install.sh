#!/bin/bash

# 1. Уведомление в углу экрана
osascript -e 'display notification "Начинаю проверку связи..." with title "KVN Тест" sound name "Glass"'

echo "--- Запуск пинга ---"

# 2. Пингуем Google 3 раза
if ping -c 3 google.com; then
    echo "--- Успех! ---"
    
    # 3. Диалоговое окно
    ANSWER=$(osascript -e 'display dialog "Связь есть! Открыть Google в Chrome?" buttons {"Нет", "Да"} default button "Да" with title "Тест завершен"' -e 'button returned of result')

    if [ "$ANSWER" = "Да" ]; then
        echo "🌐 Пытаюсь открыть Google в Chrome..."
        
        # Пытаемся открыть в Chrome. Если его нет (||), открываем в обычном браузере.
        open -a "Google Chrome" "https://www.google.com" || open "https://www.google.com"
    else
        echo "👌 Ок, браузер не трогаем."
    fi

else
    echo "--- Ошибка ---"
    # Окно ошибки, если пинг не прошел
    osascript -e 'display dialog "Нет связи. Проверь интернет! ❌" buttons {"Понял"} default button "Понял" with icon stop'
fi
