# 🚀 Ansible Deploy Project for ARSP

Автоматизирует развертывание веб-приложения ARSP на серверах Astra Linux

## 📥 Клонирование репозитория

```bash
git clone https://github.com/holyblaz/ansible_deploy.git
cd ansible_deploy/ansible

🛠 Требования
На контрольной ноде

    ОС: Ubuntu/Debian

    Ansible: версия ≥ 2.12

    SSH-клиент

    Python: версия ≥ 3.5

На управляемых нодах

    Python: версия ≥ 3.5

    SSH-доступ к целевым серверам

    Пользователь: sysadm (пароль указывается в /vars/main.yml)

    SSH-ключи или пароль для доступа

📂 Структура проекта

```bash
ansible_deploy/
├── deploy.yml                        # 🚀 Основной плейбук
├── files/                            # 📁 Файлы для копирования на серверы
│   ├── arsp_new_XX_XX_XX.zip         # 📦 Архив с новой версией проекта
│   ├── add_migrations.py             # 🐍 Скрипт для добавления миграций
│   ├── pg_backup.sh                  # 💾 Скрипт для бэкапа БД
│   ├── project_copy.sh               # 📄 Скрипт для копирования проекта
│   ├── python_scripts/               # 📜 Дополнительные скрипты разработчиков
│   ├── redeploy_no_db_no_compile.sh  # ⚡ Скрипт установки без БД и компиляции
│   └── write_showmigrations_info.py  # 🔍 Скрипт просмотра миграций
├── inventory/
│   └── hosts.yml                     # 🌐 Инвентаризация хостов
├── templates/
│   └── telegram.j2                   # ✉️ Шаблон для Telegram-уведомлений
└── vars/
    └── main.yml                      # ⚙️ Основные переменные окружения
```

⚙️ Настройка инвентаря

Отредактируйте inventory/hosts.yml:
```yaml
all:
  children:
    test_servers:        # 🖥️ Продуктивные серверы
      hosts:
        server1:
          ansible_host: 172.29.12.225
        server2:
          ansible_host: 172.29.12.231
        server3:
          ansible_host: 172.29.12.229
    
    hosts_for_developers: # 💻 Серверы разработчиков
      hosts:
        server4:
          ansible_host: 172.29.12.XX1
        server5:
          ansible_host: 172.29.12.XX2

🎯 Команды для работы
Команда	Описание	Пример
ansible-playbook -i hosts.yml deploy.yml --limit "test_servers"	Деплой на рабочих серверах	--limit "test_servers"
ansible-playbook -i hosts.yml deploy.yml --limit "hosts_for_developers"	Деплой на серверах разработчиков	--limit "server4"
ansible all -i hosts.yml -m ping	Проверка доступности всех нод	

### X. Запуск playbook

 # Проверка всех нод
    ansible all -i inventory.yml -m ping

Чтобы запустить деплой, выполните команду:
    ansible-playbook -i inventory/hosts.yml deploy.yml # Запуск всех серверов, указаныыз в host.yml -> в группе all

Чтобы запустить только на определенных хостах:
    ansible-playbook -i inventory/hosts.yml deploy.yml --limit "server1,server2.." # Запуск определенных серверов, указаныых в host.yml -> в группе all 



***Запуск Ansible на Windows***

1. Установите WSL2:
    wsl --install -d Ubuntu

2. Запустите Ubuntu и обновите пакеты:
    sudo apt update && sudo apt upgrade -y

3. Установите Ansible:
    sudo apt install ansible -y

4. Теперь можно работать с Ansible через WSL


***Docker (Ansible в контейнере)*** ТЕСТОВЫЙ ВАРИАНТ

- docker run --rm -v ${PWD}:/ansible ansible/ansible:latest ansible playbook playbook.yml


