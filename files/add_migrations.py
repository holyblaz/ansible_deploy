import os
import re
import codecs
import sys


def process_files_with_keys():
    """
    Функция считывает ключи и значения из файла /home/sysadm/last_migrations.txt,
    переходит в директории, соответствующие ключам (/var/www/html/apps/<ключ>/migrations/),
    ищет файлы .py и вставляет значения ключей в определенное место этих файлов.
    """
    # Путь к файлу с ключами и значениями
    input_file = "/home/sysadm/last_migrations.txt"

    # Проверяем, существует ли файл с ключами и значениями
    if not os.path.isfile(input_file):
        print("Ошибка: Файл с ключами и значениями не найден: %s" % input_file)
        sys.exit(1)

    # Проверяем права доступа к файлу
    if not os.access(input_file, os.R_OK):
        print("Ошибка: Нет прав на чтение файла: %s" % input_file)
        sys.exit(1)

    # Шаг 1: Считываем ключи и значения из файла
    keys_values = {}
    try:
        with codecs.open(input_file, 'r', encoding='utf-8') as file:
            for line in file:
                line = line.strip()
                if line and ':' in line:  # Предполагаем формат "ключ: значение"
                    key, value = line.split(':', 1)
                    keys_values[key.strip()] = value.strip()
    except Exception as e:
        print("Ошибка при чтении файла %s: %s" % (input_file, str(e)))
        sys.exit(1)

    # Шаг 2: Обработка каждой директории по ключам
    base_directory = "/var/www/arsp/apps"  # Базовая директория
    for key, value in keys_values.items():
        directory_path = os.path.join(base_directory, key, "migrations")

        # Проверяем, существует ли директория
        if not os.path.isdir(directory_path):
            print("Ошибка: Директория для ключа '%s' не найдена: %s" % (key, directory_path))
            continue

        # Проверяем права доступа к директории
        if not os.access(directory_path, os.R_OK | os.W_OK):
            print("Ошибка: Нет прав на чтение/запись в директорию: %s" % directory_path)
            continue

        # Шаг 3: Поиск всех файлов .py в директории
        for filename in os.listdir(directory_path):
            if filename.endswith('.py'):
                file_path = os.path.join(directory_path, filename)

                # Проверяем права доступа к файлу
                if not os.access(file_path, os.R_OK | os.W_OK):
                    print("Ошибка: Нет прав на чтение/запись файла: %s" % file_path)
                    continue

                # Шаг 4: Вставка значения ключа в определенное место файла
                try:
                    with codecs.open(file_path, 'r', encoding='utf-8') as file:
                        lines = file.readlines()

                    # Определяем место для вставки (например, dependencies = [('ключ', ''),])
                    inside_dependencies_block = False
                    new_lines = []
                    for line in lines:
                        # Если начался блок dependencies
                        if re.search(r"^\s*dependencies\s*=\s*\[", line):
                            inside_dependencies_block = True
                            new_lines.append(line)  # Сохраняем начальную строку блока
                            continue

                        # Если закончился блок dependencies
                        if inside_dependencies_block and re.search(r"\s*\]\s*$", line):
                            inside_dependencies_block = False
                            new_lines.append(line)  # Сохраняем конечную строку блока
                            continue

                        # Если внутри блока dependencies
                        if inside_dependencies_block:
                            # Ищем строки вида ('ключ', '')
                            match = re.search(r"\(\s*'([^']*)'\s*,\s*''\s*\)", line)
                            if match:
                                # Заменяем строку на ('ключ', 'значение_ключа')
                                new_line = re.sub(
                                    r"\(\s*'([^']*)'\s*,\s*''\s*\)",
                                    u"('%s', '%s')" % (match.group(1), value),
                                    line
                                )
                                new_lines.append(new_line)
                                print("Значение '%s' успешно вставлено в файл: %s" % (value, file_path))
                                continue

                        # Если вне блока dependencies, просто добавляем строку без изменений
                        new_lines.append(line)

                    # Перезаписываем файл с новыми данными
                    with codecs.open(file_path, 'w', encoding='utf-8') as file:
                        file.writelines(new_lines)

                except Exception as e:
                    print("Ошибка при обработке файла %s: %s" % (file_path, str(e)))


# Пример использования
if __name__ == "__main__":
    process_files_with_keys()
