#!/bin/bash
clear

BLUE='\033[0;34m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

PANEL_DIR="/var/www/pterodactyl"

display_welcome() {
echo -e "${BLUE}==============================================${NC}"
echo -e "${BLUE}        AUTO INSTALLER THEME PTERODACTYL       ${NC}"
echo -e "${BLUE}               © SKYZEE SHOP                ${NC}"
echo -e "${BLUE}==============================================${NC}"
sleep 2
clear
}

install_jq() {
echo -e "${YELLOW}[+] Installing jq...${NC}"
apt update -y && apt install -y jq
}

install_depend() {
echo -e "${BLUE}[+] INSTALL DEPENDENCY${NC}"

apt update -y
apt install -y curl wget unzip git ca-certificates gnupg

curl -fsSL https://deb.nodesource.com/setup_16.x | bash -
apt install -y nodejs
npm i -g yarn

install_jq

cd $PANEL_DIR || exit
yarn
echo -e "${GREEN}[✓] Dependency Installed${NC}"
sleep 2
}

install_theme() {
clear
echo -e "${BLUE}Pilih Theme:${NC}"
echo "1. Reviactyl"
echo "2. Nebula"
echo "3. Stellar"
read -p "Pilih [1-3]: " THEME

cd $PANEL_DIR || exit
rm -rf resources views public/build

case $THEME in
1)
echo -e "${YELLOW}[+] Install Reviactyl${NC}"
curl -Lo panel.tar.gz https://github.com/reviactyl/panel/releases/latest/download/panel.tar.gz
tar -xzf panel.tar.gz
rm -f panel.tar.gz
;;

2)
echo -e "${YELLOW}[+] Install Nebula${NC}"
wget -O nebula.zip https://raw.githubusercontent.com/SkyzeePedia/AutoInstaller/main/nebulaptero.zip
unzip -o nebula.zip
rm -f nebula.zip
;;

3)
echo -e "${YELLOW}[+] Install Stellar${NC}"
wget -O stellar.zip https://raw.githubusercontent.com/SkyzeePedia/AutoInstaller/main/stellar.zip
unzip -o stellar.zip
rm -f stellar.zip
;;

*)
echo -e "${RED}Pilihan tidak valid${NC}"
sleep 2
return
;;
esac

chmod -R 755 storage bootstrap/cache
COMPOSER_ALLOW_SUPERUSER=1 composer install --no-dev --optimize-autoloader
php artisan migrate --force
yarn install
yarn build:production
php artisan view:clear
php artisan config:clear
php artisan cache:clear

chown -R www-data:www-data $PANEL_DIR

echo -e "${GREEN}[✓] Theme berhasil di install${NC}"
sleep 3
}

uninstall_theme() {
echo -e "${RED}[+] UNINSTALL ALL THEME${NC}"
bash <(curl -s https://raw.githubusercontent.com/VallzHost/installer-theme/main/repair.sh)
echo -e "${GREEN}[✓] Theme Berhasil Dihapus${NC}"
sleep 3
}

display_welcome
while true; do
clear
echo -e "${BLUE}========== MENU ==========${NC}"
echo "1. Install Theme"
echo "2. Uninstall Theme"
echo "3. Install Depend"
echo "4. Exit"
read -p "Pilih [1-4]: " MENU

case $MENU in
1) install_theme ;;
2) uninstall_theme ;;
3) install_depend ;;
4) exit 0 ;;
*) echo "Pilihan salah"; sleep 1 ;;
esac
done
