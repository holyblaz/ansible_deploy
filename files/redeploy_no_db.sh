#!/bin/bash

echo "=== Остановка печатного модуля ==="
sudo systemctl stop reporter-daemon.service

sudo sh /home/sysadm/pg_backup.sh
sudo sh /home/sysadm/project_copy.sh

echo '=== Копирование файлов миграций ==='
sudo mkdir /home/sysadm/migrations_temp
sudo mkdir /home/sysadm/migrations_temp/adminarea
sudo mkdir /home/sysadm/migrations_temp/docflow
sudo mkdir /home/sysadm/migrations_temp/dopuskwork
sudo mkdir /home/sysadm/migrations_temp/main
sudo mkdir /home/sysadm/migrations_temp/refwork
sudo mkdir /home/sysadm/migrations_temp/reporter
sudo mkdir /home/sysadm/migrations_temp/taskcontrol
sudo mkdir /home/sysadm/migrations_temp/logs_level

sudo cp -r /var/www/arsp/apps/adminarea/migrations/ /home/sysadm/migrations_temp/adminarea
sudo cp -r /var/www/arsp/apps/docflow/migrations/ /home/sysadm/migrations_temp/docflow
sudo cp -r /var/www/arsp/apps/dopuskwork/migrations/ /home/sysadm/migrations_temp/dopuskwork
sudo cp -r /var/www/arsp/apps/main/migrations/ /home/sysadm/migrations_temp/main
sudo cp -r /var/www/arsp/apps/refwork/migrations/ /home/sysadm/migrations_temp/refwork
sudo cp -r /var/www/arsp/apps/reporter/migrations/ /home/sysadm/migrations_temp/reporter
sudo cp -r /var/www/arsp/apps/taskcontrol/migrations/ /home/sysadm/migrations_temp/taskcontrol
sudo cp -r /var/www/arsp/apps/logs_level/migrations/ /home/sysadm/migrations_temp/logs_level

sudo python3 /home/sysadm/write_showmigrations_info.py

echo '=== Удаление директорий, содержащих файлы старой версии ==='
sudo rm -rf /var/www/arsp/version.txt
sudo rm -rf /var/www/arsp/changelog.md
sudo rm -rf /var/www/arsp/to_static/*
sudo rm -rf /var/www/arsp/apps/
sudo rm -rf /var/www/arsp/arsp/
sudo rm -rf /var/www/arsp/common/
sudo rm -rf /var/www/arsp/\!deploy/
sudo rm -rf /var/www/arsp/dumps/
sudo rm -rf /var/www/arsp/resources/

echo '=== Распаковка архива с обновлениями версии ==='
sudo unzip /home/sysadm/arsp_new.zip -d /var/www/arsp/ &> /dev/null

sudo python3 /home/sysadm/add_migrations.py

echo '=== Восстановление файлов миграций ==='
sudo cp -rT /home/sysadm/migrations_temp/adminarea/migrations /var/www/arsp/apps/adminarea/migrations
sudo cp -rT /home/sysadm/migrations_temp/docflow/migrations /var/www/arsp/apps/docflow/migrations
sudo cp -rT /home/sysadm/migrations_temp/dopuskwork/migrations /var/www/arsp/apps/dopuskwork/migrations
sudo cp -rT /home/sysadm/migrations_temp/main/migrations /var/www/arsp/apps/main/migrations
sudo cp -rT /home/sysadm/migrations_temp/refwork/migrations /var/www/arsp/apps/refwork/migrations
sudo cp -rT /home/sysadm/migrations_temp/reporter/migrations /var/www/arsp/apps/reporter/migrations
sudo cp -rT /home/sysadm/migrations_temp/taskcontrol/migrations /var/www/arsp/apps/taskcontrol/migrations
sudo cp -rT /home/sysadm/migrations_temp/logs_level/migrations /var/www/arsp/apps/logs_level/migrations

sudo rm -rf /home/sysadm/migrations_temp

echo "=== Копия gunicorn_config.py, чтобы потом восстановить ==="
sudo cp /var/www/arsp/arsp/gunicorn_config.py /var/www/arsp/arsp/gunicorn_config.origin

echo '=== Удаление старых и копирование новых файлов шаблонов ==='
sudo rm -rf /var/www/arsp/print_template/*.odt
sudo cp /var/www/arsp/dumps/files/print_template/*.odt /var/www/arsp/print_template/
sudo mkdir /var/www/arsp/dumps/generated_dumps/

echo "=== Создание новых миграций БД ==="
sudo python3 /var/www/arsp/manage.pyc check
sudo python3 /var/www/arsp/manage.pyc makemigrations main
sudo python3 /var/www/arsp/manage.pyc makemigrations refwork
sudo python3 /var/www/arsp/manage.pyc makemigrations adminarea
sudo python3 /var/www/arsp/manage.pyc makemigrations reporter
sudo python3 /var/www/arsp/manage.pyc makemigrations dopuskwork
sudo python3 /var/www/arsp/manage.pyc makemigrations docflow
sudo python3 /var/www/arsp/manage.pyc makemigrations taskcontrol
sudo python3 /var/www/arsp/manage.pyc makemigrations logs_level


echo '=== Сохранение файлов миграций БД ==='
sudo mkdir /home/sysadm/migrations_backup
sudo mkdir /home/sysadm/migrations_backup/adminarea
sudo mkdir /home/sysadm/migrations_backup/docflow
sudo mkdir /home/sysadm/migrations_backup/dopuskwork
sudo mkdir /home/sysadm/migrations_backup/main
sudo mkdir /home/sysadm/migrations_backup/refwork
sudo mkdir /home/sysadm/migrations_backup/reporter
sudo mkdir /home/sysadm/migrations_backup/taskcontrol
sudo mkdir /home/sysadm/migrations_backup/logs_level

sudo cp -r /var/www/arsp/apps/adminarea/migrations/ /home/sysadm/migrations_backup/adminarea
sudo cp -r /var/www/arsp/apps/docflow/migrations/ /home/sysadm/migrations_backup/docflow
sudo cp -r /var/www/arsp/apps/dopuskwork/migrations/ /home/sysadm/migrations_backup/dopuskwork
sudo cp -r /var/www/arsp/apps/main/migrations/ /home/sysadm/migrations_backup/main
sudo cp -r /var/www/arsp/apps/refwork/migrations/ /home/sysadm/migrations_backup/refwork
sudo cp -r /var/www/arsp/apps/reporter/migrations/ /home/sysadm/migrations_backup/reporter
sudo cp -r /var/www/arsp/apps/taskcontrol/migrations/ /home/sysadm/migrations_backup/taskcontrol
sudo cp -r /var/www/arsp/apps/logs_level/migrations/ /home/sysadm/migrations_backup/logs_level

echo '=== Применение миграций БД ==='
sudo python3 /var/www/arsp/manage.pyc migrate main
sudo python3 /var/www/arsp/manage.pyc migrate refwork
sudo python3 /var/www/arsp/manage.pyc migrate adminarea
sudo python3 /var/www/arsp/manage.pyc migrate reporter
sudo python3 /var/www/arsp/manage.pyc migrate dopuskwork
sudo python3 /var/www/arsp/manage.pyc migrate docflow
sudo python3 /var/www/arsp/manage.pyc migrate taskcontrol
sudo python3 /var/www/arsp/manage.pyc migrate logs_level

echo '=== Дампы данных ==='
sudo python3 /var/www/arsp/manage.pyc loaddata --database=reporter_db  /var/www/arsp/dumps/initial_templates.json
sudo python3 /var/www/arsp/manage.pyc loaddata  /var/www/arsp/dumps/print_templates.json
sudo python3 /var/www/arsp/manage.pyc loaddata  /var/www/arsp/dumps/print_forms.json

echo '=== Сбор статических файлов ==='
sudo python3 /var/www/arsp/manage.pyc collectstatic --clear --noinput > /dev/null

echo "=== Удаление pycache ==="
sudo find /var/www/arsp/ -name "__pycache__" -exec rm -rf {} \; &> /dev/null

echo "=== Компиляция всех файлов в pyc ==="
sudo python3 -m compileall -b /var/www/arsp/ &> /dev/null
sleep 5

echo "=== Удаление оригиналов ==="
sudo find /var/www/arsp/ -name "*.py" -exec rm -f {} \;

echo '=== Устанавливаем владельца файлов ==='
sudo chown www-data:root -R /var/www/arsp/

echo "=== Восстановление файла gunicorn_config.py ==="
sudo mv /var/www/arsp/arsp/gunicorn_config.origin /var/www/arsp/arsp/gunicorn_config.py

echo '=== Добавляем задачу для формирования уведомлений ==='
sudo crontab -u www-data -r
(sudo crontab -u www-data -l 2>/dev/null; echo "0 * * * * python3 /var/www/arsp/apps/main/notifications/checks/nt_checks.pyc") | sudo crontab -u www-data -
sudo chown www-data:root -R /var/www/arsp/cache
sudo chmod 775 -R /var/www/arsp/cache

echo '=== Активация авто-резервирования в 0:00 ==='
(sudo crontab -u www-data -l 2>/dev/null; echo "0 0 * * * python3 /var/www/arsp/apps/main/exportImport/checks.pyc") | sudo crontab -u www-data -

echo '=== Активация ежечасной проверки лицензионных кодов ==='
(sudo crontab -u www-data -l 2>/dev/null; echo "0 * * * * python3 /var/www/arsp/apps/main/license_keys/checks/lk_check.pyc") | sudo crontab -u www-data -
# Добавляем задачу в cron для запуска при каждой перезагрузке
(sudo crontab -u www-data -l 2>/dev/null; echo "@reboot python3 /var/www/arsp/apps/main/license_keys/checks/lk_check.pyc") | sudo crontab -u www-data -

echo '=== Активация авто-резервирования в 0:00 ==='
sudo crontab -u postgres -r
(sudo crontab -u postgres -l 2>/dev/null; echo "0 0 * * * sh /var/lib/postgresql/backup.sh") | sudo crontab -u postgres -
sudo cp /var/www/arsp/dumps/backup.sh /var/lib/postgresql/
sudo mkdir -p /var/lib/postgresql/bkp
sudo chown postgres -R /var/lib/postgresql/bkp/
sudo chmod 775 -R /var/lib/postgresql/bkp

echo "=== Запуск печатного модуля ==="
sudo systemctl start reporter-daemon.service
