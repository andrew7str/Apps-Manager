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
    echo -e "${WHITE}  DeskEnvi  : $XDG_SESSION_TYPE"
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
    
    # Cek apakah instalasi berhasil
    if [ $? -eq 0 ]; then
        echo -e "${CYAN}--> Membersihkan sisa file download...${NC}"
        rm -f "/tmp/$filename"
        echo -e "${GREEN}==> $name Berhasil diinstal!${NC}"
    else
        echo -e "${RED}==> Gagal menginstal $name. Silakan cek error di atas.${NC}"
    fi
    sleep 2
}

# --- FUNGSI INSTALL GOOGLE ANTIGRAVITY ---
install_antigravity() {
    echo -e "${YELLOW}--> Menambahkan GPG Key dan Repository Google Antigravity...${NC}"
    sudo mkdir -p /etc/apt/keyrings
    
    # Mengunduh key dan menambahkannya ke keyring
    curl -fsSL https://us-central1-apt.pkg.dev/doc/repo-signing-key.gpg | sudo gpg --dearmor --yes -o /etc/apt/keyrings/antigravity-repo-key.gpg
    
    # Menambahkan source list
    echo "deb [signed-by=/etc/apt/keyrings/antigravity-repo-key.gpg] https://us-central1-apt.pkg.dev/projects/antigravity-auto-updater-dev/ antigravity-debian main" | sudo tee /etc/apt/sources.list.d/antigravity.list > /dev/null
    
    echo -e "${YELLOW}--> Mengupdate APT cache...${NC}"
    sudo apt update
    
    echo -e "${YELLOW}--> Menginstall Antigravity...${NC}"
    sudo apt install antigravity -y
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}==> Antigravity Berhasil diinstal!${NC}"
    else
        echo -e "${RED}==> Gagal menginstal Antigravity. Silakan cek error di atas.${NC}"
    fi
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

# --- SUB-MENU: FLATPAK ---
menu_flatpak() {
    while true; do
        clear
        show_banner
        echo -e "${BLUE}>>> KATEGORI: FLATPAK & MANAGER GUI <<<${NC}"
        echo -n "1. Flatpak (system)               "; check_status "flatpak"
        echo -n "2. Flathub (remote)               "; check_status "flathub"
        echo -n "3. GNOME Software + Flatpak plugin"; check_status "gnome-software"
        echo -n "4. KDE Discover + Flatpak backend"; check_status "plasma-discover"
        echo -n "5. Flatseal (GUI permission tool)"; check_status "flatseal"
        echo -n "6. XFCE (Debian) - Flatpak GUI integrasi"; check_status "xdg-desktop-portal-gtk"
        echo "7. Kembali ke Menu Developer"
        read -p "Pilih opsi Flatpak: " flatchoice
        case $flatchoice in
            1)
                sudo apt update && sudo apt install flatpak -y
                ;;
            2)
                sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
                ;;
            3)
                sudo apt update && sudo apt install gnome-software gnome-software-plugin-flatpak -y
                ;;
            4)
                sudo apt update && sudo apt install plasma-discover plasma-discover-flatpak-backend -y
                ;;
            5)
                flatpak install flathub com.github.tchx84.Flatseal -y
                ;;
            6)
                sudo apt update && sudo apt install flatpak gnome-software gnome-software-plugin-flatpak xdg-desktop-portal-gtk -y
                sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
                ;;
            7)
                break
                ;;
            *) echo -e "${RED}Pilihan tidak valid!${NC}"; sleep 1 ;;
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
        echo -n "4. Antigravity      "; check_status "antigravity"
        echo "5. Kembali ke Menu Utama"
        read -p "Pilih aplikasi: " subchoice
        case $subchoice in
            1) download_and_install "VS Code" "https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64" "vscode.deb" ;;
            2) menu_flatpak ;;
            3) sudo apt update && sudo apt install git -y ;;
            4) install_antigravity ;;
            5) break ;;
        esac
    done
}

# --- SUB-MENU: APLIKASI REMOTE DESKTOP ---
menu_remote_desktop() {
    while true; do
        clear
        show_banner
        echo -e "${BLUE}>>> KATEGORI: APLIKASI REMOTE DESKTOP <<<${NC}"
        echo -n "1. AnyDesk          "; check_status "anydesk"
        echo -n "2. TeamViewer       "; check_status "teamviewer"
        echo -n "3. RustDesk         "; check_status "rustdesk"
        echo "4. Kembali ke Menu Utama"
        read -p "Pilih aplikasi: " subchoice
        case $subchoice in
            1) 
                echo -e "${YELLOW}--> Menambahkan Repository AnyDesk...${NC}"
                wget -qO - https://keys.anydesk.com/repos/DEB-GPG-KEY | sudo apt-key add -
                echo "deb http://deb.anydesk.com/ all main" | sudo tee /etc/apt/sources.list.d/anydesk-stable.list
                sudo apt update
                sudo apt install anydesk -y
                ;;
            2) download_and_install "TeamViewer" "https://download.teamviewer.com/download/linux/teamviewer_amd64.deb" "teamviewer.deb" ;;
            3) download_and_install "RustDesk" "https://github.com/rustdesk/rustdesk/releases/download/1.2.3/rustdesk-1.2.3-x86_64.deb" "rustdesk.deb" ;;
            4) break ;;
            *) echo -e "${RED}Pilihan tidak valid!${NC}"; sleep 1 ;;
        esac
    done
}

# --- SUB-MENU: APLIKASI REMOTE ---
menu_remote_apps() {
    while true; do
        clear
        show_banner
        echo -e "${BLUE}>>> KATEGORI: INSTALASI APLIKASI REMOTE <<<${NC}"
        echo "1. Install dari AppImage"
        echo "2. Install dari Snap Store"
        echo "3. Install dari URL (.deb, .rpm)"
        echo "4. Install dari Flatpak Remote"
        echo "5. Kembali ke Menu Utama"
        read -p "Pilih metode instalasi: " remotechoice
        case $remotechoice in
            1)
                read -p "Masukkan URL AppImage: " appimage_url
                read -p "Masukkan nama file (contoh: app.AppImage): " appimage_file
                echo -e "${YELLOW}--> Mendownload AppImage...${NC}"
                wget -O "/tmp/$appimage_file" "$appimage_url"
                echo -e "${YELLOW}--> Memberikan izin eksekusi...${NC}"
                chmod +x "/tmp/$appimage_file"
                echo -e "${CYAN}--> Memindahkan ke /opt...${NC}"
                sudo mv "/tmp/$appimage_file" "/opt/$appimage_file"
                echo -e "${GREEN}==> AppImage berhasil diinstall di /opt/$appimage_file${NC}"
                sleep 2
                ;;
            2)
                read -p "Masukkan nama paket Snap (contoh: vlc, spotify): " snap_name
                sudo snap install "$snap_name"
                ;;
            3)
                read -p "Masukkan URL file instalasi (.deb atau .rpm): " package_url
                read -p "Masukkan nama file (contoh: app.deb): " package_file
                echo -e "${YELLOW}--> Mendownload paket...${NC}"
                wget -O "/tmp/$package_file" "$package_url"
                echo -e "${YELLOW}--> Menginstall paket...${NC}"
                sudo apt install "/tmp/$package_file" -y
                echo -e "${CYAN}--> Membersihkan sisa file download...${NC}"
                rm "/tmp/$package_file"
                echo -e "${GREEN}==> Paket berhasil diinstall!${NC}"
                sleep 2
                ;;
            4)
                read -p "Masukkan nama aplikasi Flatpak (contoh: com.spotify.Client): " flatpak_name
                flatpak install flathub "$flatpak_name" -y
                ;;
            5)
                break
                ;;
            *) 
                echo -e "${RED}Pilihan tidak valid!${NC}"
                sleep 1
                ;;
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
    echo "6. Instalasi Aplikasi Remote"
    echo "7. Aplikasi Remote Desktop"
    echo -e "${MAGENTA}--------------------------------------------------${NC}"
    echo "0. Keluar"
    read -p "Pilih Golongan: " mainchoice

    case $mainchoice in
        1) menu_internet ;;
        2) menu_office ;;
        3) menu_multimedia ;;
        4) menu_menggambar ;;
        5) menu_developer ;;
        6) menu_remote_apps ;;
        7) menu_remote_desktop ;;
        0) exit 0 ;;
        *) echo -e "${RED}Pilihan tidak valid!${NC}"; sleep 1 ;;
    esac
done