#!/bin/bash

#Скрипт на копирование проекта из папки /var/www/ -> /home/sysadm/project_XX_XX_XX/

source_dir="/var/www/"
backup_base="/home/sysadm/project_$(date +'%d_%m_%Y')"

# Создаем базовую директорию с датой
sudo mkdir -p "$backup_base"

# Цикл, проверяющий существует ли папка с текущей копией, если нет, создает новую копию copy_X
# (где Х - порядковый номер)

copy_num=1
while [ -d "${backup_base}/copy_${copy_num}" ]; do
	((copy_num++))
done

# Создаем директорию для новой копии
current_backup="${backup_base}/copy_${copy_num}"
sudo mkdir -p "$current_backup"

# Копируем содержимое проекта
sudo cp -a "${source_dir}/." "$current_backup/"

echo "Резервная копия создана в $current_backup"
echo "Номер копии: $copy_num"
echo "Размер: $(du -sh "$current_backup" | cut -f1)" 
