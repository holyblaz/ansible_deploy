import sys
import os
import subprocess


def execute_command():
    """
    Выполняет команду `python3 /var/www/arsp/manage.py(c) showmigrations` и возвращает её вывод.
    """
    try:
        filename = "/var/www/arsp/manage.py"
        if not os.path.isfile(filename):
            filename += "c"
        print("Выполняется команда: python3", filename, "showmigrations")
        result = subprocess.Popen(
            ["python3", filename, "showmigrations"],  # Команда для выполнения
            stdout=subprocess.PIPE,  # Перехватываем вывод в stdout
            stderr=subprocess.PIPE  # Перехватываем вывод в stderr
        )
        stdout, stderr = result.communicate()  # Получаем stdout и stderr
        if result.returncode != 0:  # Проверяем код завершения
            print("Ошибка выполнения команды.")
            if stderr:
                print(stderr)  # Выводим stderr
            sys.exit(1)
        print("Команда выполнена успешно.")
        if stderr:
            print("Ошибки выполнения команды:")
            print(stderr)  # Выводим stderr, если есть
        return stdout.decode('utf-8')  # Преобразуем stdout из байтов в строку
    except Exception as e:
        print("Ошибка выполнения команды: %s" % e)
        sys.exit(1)


def process_console_output(input_data):
    """
    Обрабатывает входные данные и записывает результат в файл.
    """
    result = {}
    current_zone = None

    for line in input_data:
        line = line.strip()
        if not line:
            continue  # Пропускаем пустые строки

        # Если строка содержит только название зоны (без квадратных скобок)
        if " " not in line and "[" not in line:
            current_zone = line
            result[current_zone] = []
        elif current_zone and line.startswith("[X]"):
            # Извлекаем миграцию (текст после "[X] ")
            migration = line.split("[X] ")[1].strip()
            result[current_zone].append(migration)

    # Определяем путь к файлу last_migrations.txt
    output_file_path = os.path.expanduser("/home/sysadm/last_migrations.txt")

    # Проверяем, существует ли файл, и если да, то очищаем его содержимое
    if os.path.exists(output_file_path):
        if os.path.getsize(output_file_path) > 0:  # Если файл не пустой
            print("Файл существует и не пустой. Очищаем его содержимое.")
            open(output_file_path, "w").close()  # Очищаем содержимое файла
    else:
        print("Файл не существует. Создаем новый файл.")

    # Открываем файл для записи
    with open(output_file_path, "a") as output_file:  # Режим "a" для добавления данных
        # Выводим последний элемент для каждой зоны
        for zone, migrations in result.items():
            if migrations:
                output_line = "{}: {}\n".format(zone, migrations[-1])
                print(output_line, end="")  # Выводим в консоль без переноса строки
                output_file.write(output_line)  # Записываем в файл


# Основная часть программы
if __name__ == "__main__":
    # Выполняем команду для получения данных
    command_output = execute_command()

    # Преобразуем вывод команды в список строк
    input_lines = command_output.splitlines()

    # Обрабатываем данные
    process_console_output(input_lines)
