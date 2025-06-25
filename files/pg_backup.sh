#!/bin/bash

# Скрипт для создания дампа базы данных PostgreSQL в формате tar
# Сохраняет дамп в /var/lib/postgresql с именем, содержащим текущую дату

# Переключаемся на пользователя postgres и выполняем команды
sudo -u postgres bash -c '
    # Переходим в рабочую директорию PostgreSQL
    cd /var/lib/postgresql || { echo "Не удалось перейти в /var/lib/postgresql"; exit 1; }

    # Формируем имя файла
    DUMP_FILE="arsp_db_$(date +%d_%m_%y).tar"

    # Создаем дамп базы данных
    echo "Начинаем создание дампа в файл: $DUMP_FILE"
    if pg_dump -U postgres -F c arsp3 > "$DUMP_FILE"; then
        echo "Дамп успешно создан: $(pwd)/$DUMP_FILE"
        echo "Размер файла: $(du -h "$DUMP_FILE" | cut -f1)"
    else
        echo "Ошибка при создании дампа"
        exit 1
    fi
'

# Проверяем результат выполнения
if [ $? -eq 0 ]; then
    echo "Скрипт завершился успешно"
else
    echo "Скрипт завершился с ошибкой" >&2
    exit 1
fi
