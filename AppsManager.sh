#!/bin/bash

# --- KONFIGURASI WARNA ---
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

# --- FUNGSI TAMPILKAN SPESIFIKASI (BANNER) ---
show_banner() {
    echo -e "${MAGENTA}==================================================${NC}"
    echo -e "${CYAN}             INFORMASI SISTEM ANDA               ${NC}"
    echo -e "${CYAN}              Create By : Mr.exe               ${NC}"
    echo -e "${MAGENTA}==================================================${NC}"
    echo -e "${WHITE}  User      : $(whoami)@$(hostname)"
    echo -e "${WHITE}  OS        : $(lsb_release -ds)"
    echo -e "${WHITE}  Kernel    : $(uname -r)"
    echo -e "${WHITE}  CPU       : $(lscpu | grep 'Model name' | cut -f 2 -d ":" | awk '{$1=$1}1')"
    echo -e "${WHITE}  Memory    : $(free -h | awk '/^Mem:/ {print $3 "/" $2}')"
    echo -e "${MAGENTA}==================================================${NC}"
}

# --- FUNGSI CEK STATUS INSTALASI ---
check_status() {
    if command -v "$1" &> /dev/null || dpkg -s "$1" &> /dev/null 2>&1; then
        echo -e "${GREEN}[Terinstall]${NC}"
    else
        echo -e "${RED}[Belum Terinstall]${NC}"
    fi
}

# --- FUNGSI DOWNLOAD & INSTALL (.DEB) ---
download_and_install() {
    local name=$1
    local url=$2
    local filename=$3

    echo -e "${YELLOW}--> Mendownload $name...${NC}"
    wget -O "/tmp/$filename" "$url"
    
    echo -e "${YELLOW}--> Menginstall $name...${NC}"
    sudo apt install "/tmp/$filename" -y
    
    echo -e "${CYAN}--> Membersihkan sisa file download...${NC}"
    rm "/tmp/$filename"
    
    echo -e "${GREEN}==> $name Berhasil diinstal!${NC}"
    sleep 2
}

# --- SUB-MENU: INTERNET ---
menu_internet() {
    while true; do
        clear
        show_banner
        echo -e "${BLUE}>>> KATEGORI: INTERNET & KOMUNIKASI <<<${NC}"
        echo -n "1. Google Chrome     "; check_status "google-chrome-stable"
        echo -n "2. Discord          "; check_status "discord"
        echo -n "3. Telegram Desktop "; check_status "telegram-desktop"
        echo -n "4. WhatsApp Desktop "; check_status "zapzap"
        echo "5. Kembali ke Menu Utama"
        read -p "Pilih aplikasi: " subchoice
        case $subchoice in
            1) download_and_install "Google Chrome" "https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb" "chrome.deb" ;;
            2) download_and_install "Discord" "https://discord.com/api/download?platform=linux&format=deb" "discord.deb" ;;
            3) sudo apt update && sudo apt install telegram-desktop -y ;;
            4) flatpak install flathub com.rtosta.zapzap -y ;;
            5) break ;;
        esac
    done
}

# --- SUB-MENU: OFFICE ---
menu_office() {
    while true; do
        clear
        show_banner
        echo -e "${BLUE}>>> KATEGORI: OFFICE & PRODUKTIVITAS <<<${NC}"
        echo -n "1. LibreOffice  "; check_status "libreoffice"
        echo -n "2. WPS Office   "; check_status "wps-office"
        echo "3. Kembali ke Menu Utama"
        read -p "Pilih aplikasi: " subchoice
        case $subchoice in
            1) sudo apt update && sudo apt install libreoffice -y ;;
            2) download_and_install "WPS Office" "https://wdl1.pcfg.softonic.com/linux/wps-office_11.1.0.11719.XA_amd64.deb" "wps.deb" ;;
            3) break ;;
        esac
    done
}

# --- SUB-MENU: MULTIMEDIA ---
menu_multimedia() {
    while true; do
        clear
        show_banner
        echo -e "${BLUE}>>> KATEGORI: MULTIMEDIA <<<${NC}"
        echo -n "1. VLC Player   "; check_status "vlc"
        echo -n "2. OBS Studio   "; check_status "obs-studio"
        echo -n "3. Spotify      "; check_status "spotify"
        echo "4. Kembali ke Menu Utama"
        read -p "Pilih aplikasi: " subchoice
        case $subchoice in
            1) sudo apt update && sudo apt install vlc -y ;;
            2) sudo apt update && sudo apt install obs-studio -y ;;
            3) sudo snap install spotify ;;
            4) break ;;
        esac
    done
}

# --- SUB-MENU: MENGGAMBAR ---
menu_menggambar() {
    while true; do
        clear
        show_banner
        echo -e "${BLUE}>>> KATEGORI: MENGGAMBAR & DESAIN <<<${NC}"
        echo -n "1. GIMP (Photo Editor) "; check_status "gimp"
        echo -n "2. Krita (Painting)    "; check_status "krita"
        echo -n "3. Inkscape (Vector)   "; check_status "inkscape"
        echo "4. Kembali ke Menu Utama"
        read -p "Pilih aplikasi: " subchoice
        case $subchoice in
            1) sudo apt update && sudo apt install gimp -y ;;
            2) sudo apt update && sudo apt install krita -y ;;
            3) sudo apt update && sudo apt install inkscape -y ;;
            4) break ;;
        esac
    done
}

# --- SUB-MENU: DEVELOPER ---
menu_developer() {
    while true; do
        clear
        show_banner
        echo -e "${BLUE}>>> KATEGORI: DEVELOPER TOOLS <<<${NC}"
        echo -n "1. VS Code          "; check_status "code"
        echo -n "2. Flatpak (System) "; check_status "flatpak"
        echo -n "3. Git              "; check_status "git"
        echo "4. Kembali ke Menu Utama"
        read -p "Pilih aplikasi: " subchoice
        case $subchoice in
            1) download_and_install "VS Code" "https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64" "vscode.deb" ;;
            2) sudo apt update && sudo apt install flatpak -y ;;
            3) sudo apt update && sudo apt install git -y ;;
            4) break ;;
        esac
    done
}

# --- MENU UTAMA ---
while true; do
    clear
    show_banner
    echo -e "${YELLOW}           MENU UTAMA PENGINSTALAN               ${NC}"
    echo -e "${MAGENTA}--------------------------------------------------${NC}"
    echo "1. Kebutuhan Internet"
    echo "2. Office & Produktivitas"
    echo "3. Multimedia (Video & Audio)"
    echo "4. Menggambar & Desain"
    echo "5. Developer Tools"
    echo -e "${MAGENTA}--------------------------------------------------${NC}"
    echo "0. Keluar"
    read -p "Pilih Golongan: " mainchoice

    case $mainchoice in
        1) menu_internet ;;
        2) menu_office ;;
        3) menu_multimedia ;;
        4) menu_menggambar ;;
        5) menu_developer ;;
        0) exit 0 ;;
        *) echo -e "${RED}Pilihan tidak valid!${NC}"; sleep 1 ;;
    esac
done
