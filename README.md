# 🚀 Ansible deploy project for ARSP

Автоматизирует развертывание веб-приложения ARSP на серверах Astra-linux

# Клонируйте репозиторий

``` bash
git clone https://github.com/holyblaz/ansible_deploy.git
cd ваш репозиторий/ansible
``` 

### 1. Требования

1. **На контрольной ноде**
    - Ubuntu 
    - Ansible >= 2.12
    - SSH-клиент на контрольной ноде

2. **На управляемых нодах**
    - [Python 3.5+]
    - SSH-доступ к целевым серверам
    - Пароль пользователя `sysadm` (указывается в переменных в /var/main.yml)
    - Пароль пользователя SSH (указывается в переменных в /var/main.yml)

### 2. Структура проекта:

ansible-playbook/
├── files/                            # 📁 Файлы, которые будут скопированы на серверы
│   ├── arsp_new.zip                  # 📦 Архив с новой версией проекта (zip-файл)
│   ├── redeploy_no_db_no_compile.sh  # 🛠 Скрипт установки без компиляции и БД
│   ├── add_migrations.py             # 🐍 Python-скрипт для добавления миграций
│   ├── show_migrations.py            # 📋 Python-скрипт для просмотра миграций
│   ├── project_copy.sh               # 📄 Bash-скрипт для копирования проекта
│   └── pg_backup.sh                  # 💾 Bash-скрипт для бэкапа PostgreSQL
├── inventory/
│   └── hosts.yml                     # 🌐 Инвентарь хостов (список серверов)
├── vars/
│   └── main.yml                      # 🔧 Переменные окружения: Telegram, проект, т.д.
├── deploy.yml                        # 🚀 Основной Ansible плейбук

### 3. Настройте инвентари

Отредактируйте файл `inventory\hosts.yml`:
```yaml
all:
  hosts:
    server1:
      ansible_host: 172.29.12.225
    server2:
      ansible_host: 172.29.12.235
    .
    .
    server10:
      ansible_host: 172.29.12.XXX
  vars:
    ansible_user: sysadm
    ansible_password: *******
```


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


