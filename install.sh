#!/bin/bash

# ╔══════════════════════════════════════════════════════════════════╗
# ║     XRARY VPN BOT - Professional Installer                        ║
# ║     Author: thetemirbolatov                                       ║
# ║     GitHub: thetemirbolatov-official                              ║
# ║     Version: 2.0.0                                                ║
# ╚═══════════════════════════════════════════════════════════════════╝

set -e  # Остановка при любой ошибке

# ═══════════════════════════════════════════════════════════════════
# КОНФИГУРАЦИЯ
# ═══════════════════════════════════════════════════════════════════
INSTALL_DIR="/opt/xrary-vpn-bot"
SERVICE_NAME="xrary-bot"
BOT_SCRIPT="vpn.py"
GITHUB_REPO="https://github.com/thetemirbolatov-official/Telegram-Bot-VPN.git"
AUTHOR="thetemirbolatov"
VERSION="2.0.0"

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# ═══════════════════════════════════════════════════════════════════
# ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ
# ═══════════════════════════════════════════════════════════════════

print_banner() {
    clear
    echo -e "${CYAN}"
    echo "╔══════════════════════════════════════════════════════════════════╗"
    echo "║                                                                  ║"
    echo "║     ██╗  ██╗██████╗  █████╗ ██████╗ ██╗   ██╗                    ║"
    echo "║     ╚██╗██╔╝██╔══██╗██╔══██╗██╔══██╗╚██╗ ██╔╝                    ║"
    echo "║      ╚███╔╝ ██████╔╝███████║██████╔╝ ╚████╔╝                     ║"
    echo "║      ██╔██╗ ██╔══██╗██╔══██║██╔══██╗  ╚██╔╝                      ║"
    echo "║     ██╔╝ ██╗██║  ██║██║  ██║██║  ██║   ██║                       ║"
    echo "║     ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝                       ║"
    echo "║                                                                  ║"
    echo "║                    VPN TELEGRAM BOT                              ║"
    echo "║                   Professional Installer                         ║"
    echo "║                                                                  ║"
    echo "║              Author: ${AUTHOR}                               ║"
    echo "║              Version: ${VERSION}                                   ║"
    echo "║                                                                  ║"
    echo "╚══════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

print_status() {
    echo -e "${BLUE}[*]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[+]${NC} $1"
}

print_error() {
    echo -e "${RED}[-]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

print_info() {
    echo -e "${CYAN}[i]${NC} $1"
}

print_step() {
    echo -e "\n${PURPLE}${BOLD}▶ $1${NC}"
}

# Проверка прав root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        print_error "Этот скрипт должен запускаться с правами root (sudo)"
        print_info "Используйте: sudo ./install.sh"
        exit 1
    fi
}

# Проверка интернет-соединения
check_internet() {
    print_status "Проверка интернет-соединения..."
    if ping -c 1 google.com &> /dev/null; then
        print_success "Интернет-соединение активно"
    else
        print_error "Нет интернет-соединения"
        exit 1
    fi
}

# Проверка версии Ubuntu/Debian
check_os() {
    print_status "Проверка операционной системы..."
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        if [[ "$ID" == "ubuntu" ]] || [[ "$ID" == "debian" ]]; then
            print_success "ОС: $NAME $VERSION"
        else
            print_warning "Рекомендуется Ubuntu/Debian. Текущая ОС: $NAME"
        fi
    else
        print_warning "Не удалось определить ОС"
    fi
}

# ═══════════════════════════════════════════════════════════════════
# ОСНОВНЫЕ ФУНКЦИИ УСТАНОВКИ
# ═══════════════════════════════════════════════════════════════════

# Установка системных зависимостей
install_system_dependencies() {
    print_step "Шаг 1/8: Установка системных зависимостей"
    
    print_status "Обновление списка пакетов..."
    apt-get update -qq
    
    print_status "Установка необходимых пакетов..."
    apt-get install -y \
        python3 \
        python3-pip \
        python3-venv \
        python3-dev \
        git \
        wget \
        curl \
        nano \
        htop \
        ufw \
        build-essential \
        libssl-dev \
        libffi-dev \
        libjpeg-dev \
        zlib1g-dev \
        libpng-dev \
        libfreetype6-dev \
        liblcms2-dev \
        libwebp-dev \
        libharfbuzz-dev \
        libfribidi-dev \
        libxcb1-dev \
        libx11-dev \
        libxext-dev \
        libxrender-dev \
        libxrandr-dev \
        libxi-dev \
        libxtst-dev \
        libatlas-base-dev \
        gfortran \
        libopenblas-dev \
        liblapack-dev 2>&1 | grep -v "does not exist"
    
    if [ $? -eq 0 ]; then
        print_success "Системные зависимости установлены"
    else
        print_error "Ошибка установки системных зависимостей"
        exit 1
    fi
}

# Клонирование репозитория
clone_repository() {
    print_step "Шаг 2/8: Клонирование репозитория"
    
    if [ -d "$INSTALL_DIR" ]; then
        print_warning "Директория $INSTALL_DIR уже существует"
        read -p "Хотите перезаписать? (y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            print_status "Удаление старой версии..."
            systemctl stop ${SERVICE_NAME} 2>/dev/null || true
            rm -rf "$INSTALL_DIR"
            print_success "Старая версия удалена"
        else
            print_error "Установка отменена"
            exit 1
        fi
    fi
    
    print_status "Клонирование из GitHub..."
    git clone --depth 1 "$GITHUB_REPO" "$INSTALL_DIR"
    
    if [ $? -eq 0 ]; then
        print_success "Репозиторий успешно склонирован в $INSTALL_DIR"
    else
        print_error "Ошибка клонирования репозитория"
        print_info "Проверьте доступ к: $GITHUB_REPO"
        exit 1
    fi
}

# Создание виртуального окружения Python
setup_python_env() {
    print_step "Шаг 3/8: Настройка Python окружения"
    
    cd "$INSTALL_DIR"
    
    print_status "Создание виртуального окружения..."
    python3 -m venv venv
    
    print_status "Активация виртуального окружения..."
    source venv/bin/activate
    
    print_status "Обновление pip..."
    pip install --upgrade pip setuptools wheel
    
    print_success "Виртуальное окружение создано"
}

# Установка Python библиотек
install_python_packages() {
    print_step "Шаг 4/8: Установка Python библиотек"
    
    cd "$INSTALL_DIR"
    source venv/bin/activate
    
    print_status "Установка основных библиотек..."
    
    # Основные библиотеки бота
    pip install --no-cache-dir pyTelegramBotAPI==4.14.0
    pip install --no-cache-dir requests==2.31.0
    pip install --no-cache-dir urllib3==2.0.7
    
    # Библиотеки для QR-кодов и изображений
    pip install --no-cache-dir qrcode==7.4.2
    pip install --no-cache-dir Pillow==10.1.0
    pip install --no-cache-dir pillow-heif==0.13.1
    
    # Работа с Excel и данными
    pip install --no-cache-dir openpyxl==3.1.2
    pip install --no-cache-dir pandas==2.1.3
    pip install --no-cache-dir numpy==1.26.2
    
    # Платежная система
    pip install --no-cache-dir yookassa==2.2.0
    
    # Дополнительные библиотеки
    pip install --no-cache-dir python-dotenv==1.0.0
    pip install --no-cache-dir colorama==0.4.6
    pip install --no-cache-dir tqdm==4.66.1
    
    # Проверка установки критических библиотек
    print_status "Проверка установки критических библиотек..."
    
    local failed=0
    for lib in "telebot" "requests" "qrcode" "PIL" "openpyxl" "pandas" "numpy" "yookassa"; do
        if python -c "import $lib" 2>/dev/null; then
            echo -e "  ${GREEN}✓${NC} $lib"
        else
            echo -e "  ${RED}✗${NC} $lib"
            failed=1
        fi
    done
    
    if [ $failed -eq 0 ]; then
        print_success "Все Python библиотеки успешно установлены"
    else
        print_error "Некоторые библиотеки не установлены"
        print_info "Попробуйте установить вручную: pip install -r requirements.txt"
    fi
    
    deactivate
}

# Создание requirements.txt
create_requirements_file() {
    print_step "Шаг 5/8: Создание requirements.txt"
    
    cat > "$INSTALL_DIR/requirements.txt" << 'EOF'
# ╔══════════════════════════════════════════════════════════════════╗
# ║     XRARY VPN BOT - Requirements                                  ║
# ║     Author: thetemirbolatov                                       ║
# ║     GitHub: thetemirbolatov-official                              ║
# ╚═══════════════════════════════════════════════════════════════════╝

# Core Telegram Bot
telebot

# HTTP Requests
urllib3==2.0.7

# QR Code Generation
qrcode==7.4.2

# Image Processing
Pillow==10.1.0
pillow-heif==0.13.1

# Excel & Data Processing
openpyxl==3.1.2
pandas==2.1.3
numpy==1.26.2

# Payment Integration
yookassa==2.2.0

# Additional Utilities
python-dotenv==1.0.0
colorama==0.4.6
tqdm==4.66.1
EOF

    print_success "Файл requirements.txt создан"
}

# Создание рабочих директорий
create_working_directories() {
    print_step "Шаг 6/8: Создание рабочих директорий"
    
    cd "$INSTALL_DIR"
    
    mkdir -p backups exports qrcodes temp_restore
    
    # Установка прав
    chmod 755 backups exports qrcodes temp_restore
    chown -R root:root "$INSTALL_DIR"
    
    print_success "Рабочие директории созданы"
}

# Создание systemd сервиса
create_systemd_service() {
    print_step "Шаг 7/8: Создание systemd сервиса"
    
    cat > "/etc/systemd/system/${SERVICE_NAME}.service" << EOF
[Unit]
Description=Xrary VPN Telegram Bot
Documentation=https://github.com/thetemirbolatov-official/Telegram-Bot-VPN
After=network.target network-online.target
Wants=network-online.target

[Service]
Type=simple
User=root
Group=root
WorkingDirectory=${INSTALL_DIR}
Environment="PATH=${INSTALL_DIR}/venv/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
Environment="PYTHONUNBUFFERED=1"
Environment="PYTHONDONTWRITEBYTECODE=1"
ExecStart=${INSTALL_DIR}/venv/bin/python3 ${INSTALL_DIR}/${BOT_SCRIPT}
Restart=always
RestartSec=10
StartLimitInterval=60
StartLimitBurst=3
StandardOutput=append:${INSTALL_DIR}/bot.log
StandardError=append:${INSTALL_DIR}/bot_error.log
SyslogIdentifier=${SERVICE_NAME}

# Security
PrivateTmp=true
NoNewPrivileges=false

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    
    if [ -f "/etc/systemd/system/${SERVICE_NAME}.service" ]; then
        print_success "Systemd сервис создан"
    else
        print_error "Ошибка создания systemd сервиса"
        exit 1
    fi
}

# Создание глобальных команд
create_global_commands() {
    print_step "Шаг 8/8: Создание глобальных команд"
    
    cat > "/usr/local/bin/xrary" << 'EOF'
#!/bin/bash

# ╔══════════════════════════════════════════════════════════════════╗
# ║     XRARY VPN BOT - Command Line Interface                        ║
# ║     Author: thetemirbolatov                                       ║
# ╚═══════════════════════════════════════════════════════════════════╝

INSTALL_DIR="/opt/xrary-vpn-bot"
SERVICE_NAME="xrary-bot"

# Цвета
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

show_banner() {
    echo -e "${CYAN}"
    echo "╔══════════════════════════════════════════════════════════════════╗"
    echo "║                    XRARY VPN BOT MANAGER                          ║"
    echo "╚═══════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

case "$1" in
    start)
        echo -e "${BLUE}▶ Запуск Xrary VPN Bot...${NC}"
        systemctl start ${SERVICE_NAME}
        if [ $? -eq 0 ]; then
            sleep 2
            if systemctl is-active --quiet ${SERVICE_NAME}; then
                echo -e "${GREEN}✅ Бот успешно запущен!${NC}"
                echo -e "${CYAN}📊 Статус:${NC} systemctl status ${SERVICE_NAME}"
                echo -e "${CYAN}📝 Логи:${NC} journalctl -u ${SERVICE_NAME} -f"
            else
                echo -e "${RED}❌ Ошибка запуска бота${NC}"
            fi
        else
            echo -e "${RED}❌ Ошибка запуска бота${NC}"
        fi
        ;;
    
    stop)
        echo -e "${YELLOW}■ Остановка Xrary VPN Bot...${NC}"
        if systemctl is-active --quiet ${SERVICE_NAME}; then
            systemctl stop ${SERVICE_NAME}
            echo -e "${GREEN}✅ Бот остановлен${NC}"
        else
            echo -e "${YELLOW}⚠️  Бот уже остановлен${NC}"
        fi
        ;;
    
    restart)
        echo -e "${BLUE}↻ Перезапуск Xrary VPN Bot...${NC}"
        systemctl restart ${SERVICE_NAME}
        if [ $? -eq 0 ]; then
            sleep 2
            if systemctl is-active --quiet ${SERVICE_NAME}; then
                echo -e "${GREEN}✅ Бот успешно перезапущен!${NC}"
            else
                echo -e "${RED}❌ Ошибка перезапуска бота${NC}"
            fi
        else
            echo -e "${RED}❌ Ошибка перезапуска бота${NC}"
        fi
        ;;
    
    status)
        show_banner
        systemctl status ${SERVICE_NAME}
        ;;
    
    logs)
        echo -e "${CYAN}📝 Логи в реальном времени (Ctrl+C для выхода)...${NC}"
        journalctl -u ${SERVICE_NAME} -f
        ;;
    
    info)
        show_banner
        echo -e "${CYAN}📊 Информация о боте:${NC}\n"
        echo -e "${BLUE}Автор:${NC}        thetemirbolatov"
        echo -e "${BLUE}GitHub:${NC}       thetemirbolatov-official"
        echo -e "${BLUE}Версия:${NC}       2.0.0"
        echo -e "${BLUE}Директория:${NC}   ${INSTALL_DIR}"
        echo -e "${BLUE}Сервис:${NC}       ${SERVICE_NAME}"
        echo ""
        
        if systemctl is-active --quiet ${SERVICE_NAME}; then
            echo -e "${GREEN}✅ Статус:${NC}      Активен"
            PID=$(systemctl show --property=MainPID --value ${SERVICE_NAME})
            echo -e "${GREEN}🔢 PID:${NC}         ${PID}"
            MEM=$(ps -o rss= -p ${PID} 2>/dev/null | awk '{print $1/1024}')
            if [ -n "$MEM" ]; then
                echo -e "${GREEN}💾 Память:${NC}      ${MEM:0:5} MB"
            fi
        else
            echo -e "${RED}❌ Статус:${NC}      Остановлен"
        fi
        echo ""
        ;;
    
    uninstall)
        echo -e "${RED}"
        echo "╔══════════════════════════════════════════════════════════════════╗"
        echo "║                      ВНИМАНИЕ! УДАЛЕНИЕ!                          ║"
        echo "╚══════════════════════════════════════════════════════════════════╝"
        echo -e "${NC}"
        echo -e "${YELLOW}Это действие полностью удалит Xrary VPN Bot!${NC}"
        echo -e "${YELLOW}Будут удалены все файлы и настройки.${NC}"
        echo ""
        read -p "Введите 'YES' для подтверждения: " confirm
        
        if [ "$confirm" = "YES" ]; then
            echo -e "${YELLOW}■ Остановка бота...${NC}"
            systemctl stop ${SERVICE_NAME} 2>/dev/null
            systemctl disable ${SERVICE_NAME} 2>/dev/null
            
            echo -e "${YELLOW}■ Удаление сервиса...${NC}"
            rm -f /etc/systemd/system/${SERVICE_NAME}.service
            systemctl daemon-reload
            
            echo -e "${YELLOW}■ Удаление команды...${NC}"
            rm -f /usr/local/bin/xrary
            
            echo -e "${YELLOW}■ Удаление файлов...${NC}"
            rm -rf ${INSTALL_DIR}
            
            echo -e "${GREEN}✅ Xrary VPN Bot полностью удален!${NC}"
        else
            echo -e "${CYAN}❌ Удаление отменено${NC}"
        fi
        ;;
    
    *)
        show_banner
        echo -e "${CYAN}Использование:${NC} xrary {command}\n"
        echo -e "${GREEN}Команды управления:${NC}"
        echo -e "  ${BLUE}start${NC}      - Запустить бота"
        echo -e "  ${BLUE}stop${NC}       - Остановить бота"
        echo -e "  ${BLUE}restart${NC}    - Перезапустить бота"
        echo -e "  ${BLUE}status${NC}     - Проверить статус"
        echo ""
        echo -e "${GREEN}Информация:${NC}"
        echo -e "  ${BLUE}logs${NC}       - Показать логи в реальном времени"
        echo -e "  ${BLUE}info${NC}       - Информация о боте"
        echo ""
        echo -e "${GREEN}Система:${NC}"
        echo -e "  ${BLUE}uninstall${NC}  - Полностью удалить бота"
        echo ""
        echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${CYAN}Автор:${NC} thetemirbolatov | GitHub: thetemirbolatov-official"
        echo -e "${CYAN}Контакты:${NC} VK: thetemirbolatov | Inst: thetemirbolatov | TG: thetemirbolatov"
        echo ""
        ;;
esac
EOF

    chmod +x /usr/local/bin/xrary
    
    if [ -f "/usr/local/bin/xrary" ]; then
        print_success "Глобальная команда 'xrary' создана"
    else
        print_error "Ошибка создания глобальной команды"
        exit 1
    fi
}

# Запуск бота
start_bot_service() {
    print_status "Запуск бота..."
    
    systemctl enable ${SERVICE_NAME}
    systemctl start ${SERVICE_NAME}
    
    sleep 3
    
    if systemctl is-active --quiet ${SERVICE_NAME}; then
        print_success "Бот успешно запущен и добавлен в автозагрузку!"
        return 0
    else
        print_error "Ошибка запуска бота"
        print_info "Проверьте логи: journalctl -u ${SERVICE_NAME} -n 50"
        return 1
    fi
}

# Показать информацию о завершении
show_completion_info() {
    echo ""
    echo -e "${GREEN}${BOLD}"
    echo "╔══════════════════════════════════════════════════════════════════╗"
    echo "║                  УСТАНОВКА УСПЕШНО ЗАВЕРШЕНА!                      ║"
    echo "╚══════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo ""
    echo -e "${CYAN}${BOLD}📋 ИНФОРМАЦИЯ О БОТЕ:${NC}"
    echo -e "  ${BLUE}Автор:${NC}        thetemirbolatov"
    echo -e "  ${BLUE}GitHub:${NC}       https://github.com/thetemirbolatov-official"
    echo -e "  ${BLUE}Версия:${NC}       2.0.0"
    echo -e "  ${BLUE}Директория:${NC}   ${INSTALL_DIR}"
    echo ""
    echo -e "${CYAN}${BOLD}📱 КОНТАКТЫ:${NC}"
    echo -e "  ${BLUE}Telegram:${NC}     @thetemirbolatov"
    echo -e "  ${BLUE}VK:${NC}           vk.com/thetemirbolatov"
    echo -e "  ${BLUE}Instagram:${NC}    @thetemirbolatov"
    echo ""
    echo -e "${CYAN}${BOLD}🚀 КОМАНДЫ УПРАВЛЕНИЯ:${NC}"
    echo -e "  ${GREEN}xrary start${NC}      - Запустить бота"
    echo -e "  ${GREEN}xrary stop${NC}       - Остановить бота"
    echo -e "  ${GREEN}xrary restart${NC}    - Перезапустить бота"
    echo -e "  ${GREEN}xrary status${NC}     - Проверить статус"
    echo -e "  ${GREEN}xrary logs${NC}       - Показать логи"
    echo -e "  ${GREEN}xrary info${NC}       - Информация о боте"
    echo -e "  ${GREEN}xrary uninstall${NC}  - Удалить бота"
    echo ""
    echo -e "${CYAN}${BOLD}📊 ПОЛЕЗНЫЕ КОМАНДЫ:${NC}"
    echo -e "  ${BLUE}systemctl status ${SERVICE_NAME}${NC}  - Статус сервиса"
    echo -e "  ${BLUE}journalctl -u ${SERVICE_NAME} -f${NC}  - Логи в реальном времени"
    echo -e "  ${BLUE}tail -f ${INSTALL_DIR}/bot.log${NC}     - Просмотр лог-файла"
    echo ""
    echo -e "${GREEN}${BOLD}Спасибо за установку Xrary VPN Bot!${NC}"
    echo ""
}

# ═══════════════════════════════════════════════════════════════════
# ГЛАВНАЯ ФУНКЦИЯ УСТАНОВКИ
# ═══════════════════════════════════════════════════════════════════

main_install() {
    print_banner
    
    # Проверки
    check_root
    check_internet
    check_os
    
    # Установка
    install_system_dependencies
    clone_repository
    setup_python_env
    install_python_packages
    create_requirements_file
    create_working_directories
    create_systemd_service
    create_global_commands
    
    # Запуск
    start_bot_service
    
    # Завершение
    show_completion_info
}

# ═══════════════════════════════════════════════════════════════════
# ЗАПУСК
# ═══════════════════════════════════════════════════════════════════

main_install "$@"
