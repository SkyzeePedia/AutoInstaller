#!/bin/bash

clear
echo "======================================"
echo "   PTERODACTYL THEME REVIACYTL"
echo "======================================"
echo "1. Install Theme Reviactyl"
echo "2. Uninstall Theme"
echo "3. Exit"
echo "======================================"
read -p "Pilih menu [1-3]: " menu

PANEL_DIR="/var/www/pterodactyl"
DOWNLOAD_URL="https://github.com/reviactyl/panel/releases/download/v2.1.2/panel.tar.gz"

install_theme() {
    echo "[INFO] Installing Reviactyl Theme..."

    if [ ! -d "$PANEL_DIR" ]; then
        echo "[ERROR] Folder $PANEL_DIR tidak ditemukan!"
        exit 1
    fi

    cd $PANEL_DIR || exit 1

    echo "[INFO] Membersihkan file lama..."
    rm -rf *

    echo "[INFO] Download Reviactyl panel..."
    curl -Lo panel.tar.gz $DOWNLOAD_URL || exit 1

    echo "[INFO] Extract file..."
    tar -xzvf panel.tar.gz
    rm -f panel.tar.gz

    echo "[INFO] Set permission storage & cache..."
    chmod -R 755 storage bootstrap/cache

    echo "[INFO] Install composer dependency..."
    COMPOSER_ALLOW_SUPERUSER=1 composer install --no-dev --optimize-autoloader

    echo "[INFO] Migrating database..."
    php artisan migrate --seed --force

    if id www-data >/dev/null 2>&1; then
        chown -R www-data:www-data $PANEL_DIR
    elif id nginx >/dev/null 2>&1; then
        chown -R nginx:nginx $PANEL_DIR
    elif id apache >/dev/null 2>&1; then
        chown -R apache:apache $PANEL_DIR
    else
        echo "[WARNING] User webserver tidak terdeteksi"
    fi

    echo "======================================"
    echo " INSTALL THEME REVIACYTL SELESAI"
    echo "======================================"
}

uninstall_theme() {
    echo "[INFO] Uninstall Theme Reviactyl..."
    cd $PANEL_DIR || exit 1
    rm -rf *
    echo "[INFO] Theme Reviactyl berhasil dihapus"
}

case $menu in
    1) install_theme ;;
    2) uninstall_theme ;;
    3) exit 0 ;;
    *) echo "Pilihan tidak valid!" ;;
esac
