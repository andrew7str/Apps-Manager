#!/bin/bash

# --- KONFIGURASI DIR ---
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
BACKUP_BASE_DIR="$SCRIPT_DIR/br"

# --- KONFIGURASI WARNA ---
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
WHITE='\033[1;37m'
NC='\033[0m'

# --- PENGECEKAN DISTRO & PACKAGE MANAGER ---
OS_NAME=""
PKG_MANAGER=""
PKG_INSTALL_CMD=""
PKG_UPDATE_CMD=""
PKG_CHECK_CMD=""

detect_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS_NAME=$ID
    elif type lsb_release >/dev/null 2>&1; then
        OS_NAME=$(lsb_release -si | tr '[:upper:]' '[:lower:]')
    elif [ -f /etc/lsb-release ]; then
        . /etc/lsb-release
        OS_NAME=$(echo $DISTRIB_ID | tr '[:upper:]' '[:lower:]')
    elif [ -f /etc/debian_version ]; then
        OS_NAME="debian"
    elif [ -f /etc/redhat-release ]; then
        OS_NAME="redhat"
    else
        OS_NAME="unknown"
    fi

    # Tentukan Package Manager berdasarkan OS
    case "$OS_NAME" in
        ubuntu|debian|linuxmint|pop|kali|parrot|raspbian)
            PKG_MANAGER="apt"
            PKG_INSTALL_CMD="sudo apt install -y"
            PKG_UPDATE_CMD="sudo apt update -y"
            PKG_CHECK_CMD="dpkg -s"
            ;;
        fedora|rhel|centos|almalinux|rocky)
            PKG_MANAGER="dnf"
            PKG_INSTALL_CMD="sudo dnf install -y"
            PKG_UPDATE_CMD="sudo dnf check-update"
            PKG_CHECK_CMD="rpm -q"
            ;;
        arch|manjaro|endeavouros|garuda)
            PKG_MANAGER="pacman"
            PKG_INSTALL_CMD="sudo pacman -S --noconfirm"
            PKG_UPDATE_CMD="sudo pacman -Sy --noconfirm"
            PKG_CHECK_CMD="pacman -Qs"
            ;;
        opensuse|suse|sles)
            PKG_MANAGER="zypper"
            PKG_INSTALL_CMD="sudo zypper install -y"
            PKG_UPDATE_CMD="sudo zypper refresh"
            PKG_CHECK_CMD="rpm -q"
            ;;
        gentoo)
            PKG_MANAGER="emerge"
            PKG_INSTALL_CMD="sudo emerge -a"
            PKG_UPDATE_CMD="sudo emerge --sync"
            PKG_CHECK_CMD="equery l"
            ;;
        slackware)
            PKG_MANAGER="slackpkg"
            PKG_INSTALL_CMD="sudo slackpkg install"
            PKG_UPDATE_CMD="sudo slackpkg update"
            PKG_CHECK_CMD="ls /var/log/packages/ | grep -i"
            ;;
        *)
            echo -e "${RED}OS / Distribusi tidak dikenali ($OS_NAME). Fitur instalasi mungkin tidak berjalan maksimal.${NC}"
            sleep 2
            ;;
    esac
}

# Jalankan deteksi OS saat script dimulai
detect_os

# --- FUNGSI INSTALL PAKET LINTAS DISTRO ---
pkg_install() {
    local package=$1
    if [ -n "$PKG_INSTALL_CMD" ]; then
        $PKG_INSTALL_CMD "$package"
    else
        echo -e "${RED}Package Manager tidak ditemukan untuk menginstal $package.${NC}"
    fi
}

pkg_update() {
    if [ -n "$PKG_UPDATE_CMD" ]; then
        $PKG_UPDATE_CMD
    fi
}

# --- FUNGSI TAMPILKAN SPESIFIKASI (BANNER) ---
show_banner() {
    echo -e "${MAGENTA}==================================================${NC}"
    echo -e "${CYAN}             INFORMASI SISTEM ANDA               ${NC}"
    echo -e "${CYAN}              Create By : Mr.exe               ${NC}"
    echo -e "${MAGENTA}==================================================${NC}"
    echo -e "${WHITE}  User      : $(whoami)@$(hostname)"
    echo -e "${WHITE}  Distro    : ${OS_NAME^^} ($PKG_MANAGER)"
    echo -e "${WHITE}  Kernel    : $(uname -r)"
    echo -e "${WHITE}  CPU       : $(lscpu | grep 'Model name' | cut -f 2 -d ":" | awk '{$1=$1}1')"
    echo -e "${WHITE}  DeskEnvi  : $XDG_SESSION_TYPE"
    echo -e "${WHITE}  Memory    : $(free -h | awk '/^Mem:/ {print $3 "/" $2}')"
    echo -e "${MAGENTA}==================================================${NC}"
}

# --- FUNGSI CEK STATUS INSTALASI ---
check_status() {
    if command -v "$1" &> /dev/null; then
        echo -e "${GREEN}[Terinstall]${NC}"
    elif [ -n "$PKG_CHECK_CMD" ] && $PKG_CHECK_CMD "$1" &> /dev/null 2>&1; then
        echo -e "${GREEN}[Terinstall]${NC}"
    else
        echo -e "${RED}[Belum Terinstall]${NC}"
    fi
}

# --- FUNGSI DOWNLOAD & INSTALL KHUSUS ---
download_and_install() {
    local name=$1
    local url=$2
    local filename=$3

    echo -e "${YELLOW}--> Mendownload $name...${NC}"
    wget -O "/tmp/$filename" "$url"
    
    echo -e "${YELLOW}--> Menginstall $name...${NC}"
    if [ "$PKG_MANAGER" == "apt" ] && [[ "$filename" == *.deb ]]; then
        sudo apt install "/tmp/$filename" -y
    elif [ "$PKG_MANAGER" == "dnf" ] || [ "$PKG_MANAGER" == "zypper" ] && [[ "$filename" == *.rpm ]]; then
        $PKG_INSTALL_CMD "/tmp/$filename"
    elif [ "$PKG_MANAGER" == "pacman" ]; then
        echo -e "${YELLOW}==> Untuk Arch Linux, disarankan menggunakan AUR (misal yay/paru) untuk paket pihak ketiga.${NC}"
        echo -e "${YELLOW}==> Contoh: yay -S ${name,,}${NC}"
        # Fallback jika ada .pkg.tar.zst disediakan local
        if [[ "$filename" == *.pkg.tar.zst ]]; then
            sudo pacman -U "/tmp/$filename" --noconfirm
        fi
    else
        echo -e "${RED}==> Format instalasi file belum didukung sepenuhnya di OS ini secara otomatis dari script.${NC}"
        echo -e "${CYAN}Silakan install secara manual atau gunakan Flatpak/Snap jika tersedia.${NC}"
    fi
    
    # Cek apakah instalasi berhasil
    if [ $? -eq 0 ]; then
        echo -e "${CYAN}--> Membersihkan sisa file download...${NC}"
        rm -f "/tmp/$filename"
        echo -e "${GREEN}==> $name Instalasi Selesai (atau status cek manual).${NC}"
    else
        echo -e "${RED}==> Proses instalasi $name selesai dengan error atau dilewati.${NC}"
    fi
    sleep 2
}

# --- FUNGSI INSTALL GOOGLE ANTIGRAVITY ---
install_antigravity() {
    if [ "$PKG_MANAGER" == "apt" ]; then
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
    else
        echo -e "${YELLOW}Antigravity installer via Script ini saat ini hanya mensupport base Debian/Ubuntu.${NC}"
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
        echo -n "5. Mozilla Firefox  "; check_status "firefox"
        echo -n "6. Thunderbird      "; check_status "thunderbird"
        echo "7. Kembali ke Menu Utama"
        read -p "Pilih aplikasi: " subchoice
        case $subchoice in
            1)
                if [ "$PKG_MANAGER" == "apt" ]; then
                    download_and_install "Google Chrome" "https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb" "chrome.deb"
                elif [ "$PKG_MANAGER" == "dnf" ] || [ "$PKG_MANAGER" == "zypper" ]; then
                    download_and_install "Google Chrome" "https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm" "chrome.rpm"
                elif [ "$PKG_MANAGER" == "pacman" ]; then
                    echo -e "${YELLOW}Gunakan AUR: yay -S google-chrome${NC}"; sleep 2
                fi
                ;;
            2)
                if [ "$PKG_MANAGER" == "apt" ]; then
                    download_and_install "Discord" "https://discord.com/api/download?platform=linux&format=deb" "discord.deb"
                else
                    echo -e "${YELLOW}Gunakan Flatpak untuk install Discord di Distro ini: flatpak install flathub com.discordapp.Discord${NC}"; sleep 2
                fi
                ;;
            3) pkg_update && pkg_install "telegram-desktop" ;;
            4) 
                if command -v flatpak &> /dev/null; then
                    flatpak install flathub com.rtosta.zapzap -y
                else
                    echo -e "${RED}Flatpak belum terinstall. Install via Menu Flatpak terlebih dahulu!${NC}"; sleep 2
                fi ;;
            5) pkg_update && pkg_install "firefox" ;;
            6) pkg_update && pkg_install "thunderbird" ;;
            7) break ;;
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
        echo -n "3. Evince/Okular"; check_status "evince"
        echo -n "4. Gedit/KWrite "; check_status "gedit"
        echo "5. Kembali ke Menu Utama"
        read -p "Pilih aplikasi: " subchoice
        case $subchoice in
            1) pkg_update && pkg_install "libreoffice" ;;
            2)
                if [ "$PKG_MANAGER" == "apt" ]; then
                    download_and_install "WPS Office" "https://wdl1.pcfg.softonic.com/linux/wps-office_11.1.0.11719.XA_amd64.deb" "wps.deb"
                elif [ "$PKG_MANAGER" == "dnf" ] || [ "$PKG_MANAGER" == "zypper" ]; then
                    echo -e "${YELLOW}WPS RPM bisa diunduh via website resmi. Merekomendasikan Flatpak: flatpak install flathub com.wps.Office${NC}"; sleep 2
                elif [ "$PKG_MANAGER" == "pacman" ]; then
                    echo -e "${YELLOW}Gunakan AUR: yay -S wps-office${NC}"; sleep 2
                fi
                ;;
            3) 
                if [ "$PKG_MANAGER" == "apt" ]; then pkg_update && pkg_install "evince"
                else pkg_update && pkg_install "okular evince"; fi
                ;;
            4) 
                if [ "$PKG_MANAGER" == "apt" ]; then pkg_update && pkg_install "gedit"
                else pkg_update && pkg_install "kwrite gedit"; fi
                ;;
            5) break ;;
        esac
    done
}

# --- SUB-MENU: MULTIMEDIA ---
menu_multimedia() {
    while true; do
        clear
        show_banner
        echo -e "${BLUE}>>> KATEGORI: MULTIMEDIyang A <<<${NC}"
        echo -n "1. VLC Player   "; check_status "vlc"
        echo -n "2. OBS Studio   "; check_status "obs-studio"
        echo -n "3. Spotify      "; check_status "spotify"
        echo -n "4. Audacity     "; check_status "audacity"
        echo -n "5. Rhythmbox    "; check_status "rhythmbox"
        echo "6. Kembali ke Menu Utama"
        read -p "Pilih aplikasi: " subchoice
        case $subchoice in
            1) pkg_update && pkg_install "vlc" ;;
            2) pkg_update && pkg_install "obs-studio" ;;
            3) 
                if command -v snap &> /dev/null; then
                    sudo snap install spotify
                elif command -v flatpak &> /dev/null; then
                    flatpak install flathub com.spotify.Client -y
                else
                    echo -e "${RED}Install Snap atau Flatpak terlebih dahulu!${NC}"; sleep 2
                fi ;;
            4) pkg_update && pkg_install "audacity" ;;
            5) 
                if [ "$PKG_MANAGER" == "apt" ]; then pkg_update && pkg_install "rhythmbox"
                else pkg_update && pkg_install "clementine"; fi
                ;;
            6) break ;;
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
        echo -n "4. Blender (3D)        "; check_status "blender"
        echo "5. Kembali ke Menu Utama"
        read -p "Pilih aplikasi: " subchoice
        case $subchoice in
            1) pkg_update && pkg_install "gimp" ;;
            2) pkg_update && pkg_install "krita" ;;
            3) pkg_update && pkg_install "inkscape" ;;
            4) pkg_update && pkg_install "blender" ;;
            5) break ;;
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
                pkg_update && pkg_install "flatpak"
                ;;
            2)
                sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
                ;;
            3)
                pkg_update && (pkg_install "gnome-software" || true) && (pkg_install "gnome-software-plugin-flatpak" || true)
                ;;
            4)
                pkg_update && (pkg_install "plasma-discover" || pkg_install "discover") || echo -e "${RED}Pastikan Anda di DE KDE Plasma${NC}"
                ;;
            5)
                flatpak install flathub com.github.tchx84.Flatseal -y
                ;;
            6)
                pkg_update && pkg_install "flatpak" && pkg_install "xdg-desktop-portal-gtk"
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
        echo -n "5. Docker & Compose "; check_status "docker"
        echo -n "6. PIP & Node.js    "; check_status "npm"
        echo "7. Kembali ke Menu Utama"
        read -p "Pilih aplikasi: " subchoice
        case $subchoice in
            1)
                if [ "$PKG_MANAGER" == "apt" ]; then
                    download_and_install "VS Code" "https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64" "vscode.deb"
                elif [ "$PKG_MANAGER" == "dnf" ] || [ "$PKG_MANAGER" == "zypper" ]; then
                    download_and_install "VS Code" "https://code.visualstudio.com/sha/download?build=stable&os=linux-rpm-x64" "vscode.rpm"
                elif [ "$PKG_MANAGER" == "pacman" ]; then
                    echo -e "${YELLOW}Gunakan AUR: yay -S visual-studio-code-bin${NC}"; sleep 2
                fi
                ;;
            2) menu_flatpak ;;
            3) pkg_update && pkg_install "git" ;;
            4) install_antigravity ;;
            5) 
                if [ "$PKG_MANAGER" == "apt" ]; then pkg_update && pkg_install "docker.io docker-compose"
                else pkg_update && pkg_install "docker docker-compose"; fi
                sudo systemctl enable docker && sudo systemctl start docker
                ;;
            6) pkg_update && pkg_install "python3-pip nodejs npm" ;;
            7) break ;;
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
                if [ "$PKG_MANAGER" == "apt" ]; then
                    echo -e "${YELLOW}--> Menambahkan Repository AnyDesk (DEB)...${NC}"
                    wget -qO - https://keys.anydesk.com/repos/DEB-GPG-KEY | sudo gpg --dearmor --yes -o /usr/share/keyrings/anydesk-archive-keyring.gpg
                    echo "deb [signed-by=/usr/share/keyrings/anydesk-archive-keyring.gpg] http://deb.anydesk.com/ all main" | sudo tee /etc/apt/sources.list.d/anydesk-stable.list
                    sudo apt update
                    sudo apt install anydesk -y
                else
                    echo -e "${YELLOW}Silakan gunakan Flatpak: flatpak install flathub com.anydesk.Anydesk${NC}"; sleep 2
                fi
                ;;
            2) 
                if [ "$PKG_MANAGER" == "apt" ]; then
                    download_and_install "TeamViewer" "https://download.teamviewer.com/download/linux/teamviewer_amd64.deb" "teamviewer.deb"
                elif [ "$PKG_MANAGER" == "dnf" ] || [ "$PKG_MANAGER" == "zypper" ]; then
                    download_and_install "TeamViewer" "https://download.teamviewer.com/download/linux/teamviewer.x86_64.rpm" "teamviewer.rpm"
                elif [ "$PKG_MANAGER" == "pacman" ]; then
                    echo -e "${YELLOW}Gunakan AUR: yay -S teamviewer${NC}"; sleep 2
                fi
                ;;
            3)
                if [ "$PKG_MANAGER" == "apt" ]; then
                    download_and_install "RustDesk" "https://github.com/rustdesk/rustdesk/releases/download/1.2.3/rustdesk-1.2.3-x86_64.deb" "rustdesk.deb"
                else
                    echo -e "${YELLOW}Mendukung via Flatpak: flatpak install flathub com.rustdesk.RustDesk${NC}"; sleep 2
                fi
                ;;
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
                read -p "Masukkan URL file instalasi (.deb, .rpm, atau lainnya): " package_url
                read -p "Masukkan nama file (contoh: app.deb): " package_file
                echo -e "${YELLOW}--> Mendownload paket...${NC}"
                wget -O "/tmp/$package_file" "$package_url"
                echo -e "${YELLOW}--> Menginstall paket...${NC}"
                if [[ "$package_file" == *.deb ]] && [ "$PKG_MANAGER" == "apt" ]; then
                    sudo apt install "/tmp/$package_file" -y
                elif [[ "$package_file" == *.rpm ]] && ([ "$PKG_MANAGER" == "dnf" ] || [ "$PKG_MANAGER" == "zypper" ]); then
                    $PKG_INSTALL_CMD "/tmp/$package_file"
                else
                    echo -e "${RED}==> Ekstensi atau Package Manager tidak cocok (ex: rpm di debian) !${NC}"
                fi
                echo -e "${CYAN}--> Membersihkan sisa file download...${NC}"
                rm "/tmp/$package_file"
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

# --- SUB-MENU: KONFIGURASI SISTEM ---
menu_konfigurasi() {
    while true; do
        clear
        show_banner
        echo -e "${BLUE}>>> KATEGORI: KONFIGURASI SISTEM <<<${NC}"
        echo "1. Update & Upgrade Sistem"
        echo "2. Konfigurasi Jaringan (Network)"
        echo "3. Konfigurasi Firewall (UFW)"
        echo "4. Konfigurasi Waktu/Timezone"
        echo "5. Tweak Performa Sistem (Clear Cache)"
        echo "6. Timeshift (System Restore Point)"
        echo "7. Stacer/BleachBit (System Cleaner GUI)"
        echo "8. Kembali ke Menu Utama"
        read -p "Pilih konfigurasi: " subchoice
        case $subchoice in
            1) 
                pkg_update
                if [ "$PKG_MANAGER" == "apt" ]; then sudo apt upgrade -y;
                elif [ "$PKG_MANAGER" == "dnf" ]; then sudo dnf upgrade -y;
                elif [ "$PKG_MANAGER" == "zypper" ]; then sudo zypper update -y;
                elif [ "$PKG_MANAGER" == "pacman" ]; then sudo pacman -Syu --noconfirm;
                fi
                read -p "Tekan Enter untuk melanjutkan..." ;;
            2) sudo nmtui ;;
            3) 
                pkg_update && pkg_install "ufw" && sudo ufw enable && sudo ufw status verbose
                read -p "Tekan Enter untuk melanjutkan..." ;;
            4) 
                if [ -f /etc/debian_version ]; then
                    sudo dpkg-reconfigure tzdata
                else
                    echo -e "${YELLOW}Gunakan: timedatectl set-timezone [Zone]${NC}"; sleep 2
                fi ;;
            5) 
                echo -e "${YELLOW}--> Membersihkan cache dan file sementara...${NC}"
                if [ "$PKG_MANAGER" == "apt" ]; then sudo apt autoremove -y; sudo apt clean;
                elif [ "$PKG_MANAGER" == "dnf" ]; then sudo dnf autoremove -y; sudo dnf clean all;
                elif [ "$PKG_MANAGER" == "pacman" ]; then sudo pacman -Rns $(pacman -Qtdq) 2>/dev/null; sudo pacman -Sc --noconfirm;
                fi
                echo 3 | sudo tee /proc/sys/vm/drop_caches
                read -p "Tekan Enter untuk melanjutkan..." ;;
            6) pkg_update && pkg_install "timeshift" ;;
            7) pkg_update && pkg_install "bleachbit stacer" ;;
            8) break ;;
            *) echo -e "${RED}Pilihan tidak valid!${NC}"; sleep 1 ;;
        esac
    done
}

# --- SUB-MENU: INSTALL TOOLS & UTILITIES ---
menu_tools() {
    while true; do
        clear
        show_banner
        echo -e "${BLUE}>>> KATEGORI: INSTALL TOOLS & UTILITIES <<<${NC}"
        echo -n "1. Htop (System Monitor)     "; check_status "htop"
        echo -n "2. Neofetch (System Info)    "; check_status "neofetch"
        echo -n "3. Tmux (Terminal Multiplexer) "; check_status "tmux"
        echo -n "4. Curl & Wget               "; check_status "curl"
        echo -n "5. Network Tools (net-tools) "; check_status "net-tools"
        echo -n "6. GParted (Partition GUI)   "; check_status "gparted"
        echo -n "7. Btop (Monitor Modern)     "; check_status "btop"
        echo "8. Kembali ke Menu Utama"
        read -p "Pilih tools: " subchoice
        case $subchoice in
            1) pkg_update && pkg_install "htop" ;;
            2) pkg_update && pkg_install "neofetch" ;;
            3) pkg_update && pkg_install "tmux" ;;
            4) pkg_update && pkg_install "curl" && pkg_install "wget" ;;
            5) pkg_update && pkg_install "net-tools" ;;
            6) 
                if [ "$PKG_MANAGER" == "apt" ]; then pkg_update && pkg_install "gparted"
                else pkg_update && pkg_install "gparted partitionmanager"; fi ;;
            7) pkg_update && pkg_install "btop bpytop" ;;
            8) break ;;
            *) echo -e "${RED}Pilihan tidak valid!${NC}"; sleep 1 ;;
        esac
    done
}

# --- FUNGSI SCAN HARDWARE & DRIVER ---
scan_hardware() {
    clear
    show_banner
    echo -e "${BLUE}>>> HASIL DETEKSI HARDWARE & DRIVER KELAS BERAT <<<${NC}"
    echo -e "${MAGENTA}--------------------------------------------------${NC}"

    echo -e "${YELLOW}1. Graphic / VGA:${NC}"
    lspci -nn | grep -i "vga\|3d\|display" | while read -r line; do
        echo -e "   - $line"
        vgadev=$(echo "$line" | grep -o '^....:....' | awk -F: '{print $1}')
        driver=$(lspci -nnk | grep -A 2 "$vgadev" | grep "Kernel driver in use" | cut -d: -f2 | xargs)
        if [ -n "$driver" ]; then echo -e "     ${GREEN}[Driver Aktif: $driver]${NC}"; else echo -e "     ${RED}[Tidak ada driver aktif]${NC}"; fi
    done
    
    echo -e "\n${YELLOW}2. WLAN / WiFi:${NC}"
    lspci -nn | grep -i "network\|wireless" | while read -r line; do
        echo -e "   - $line"
        wlandev=$(echo "$line" | grep -o '^....:....' | awk -F: '{print $1}')
        driver=$(lspci -nnk | grep -A 2 "$wlandev" | grep "Kernel driver in use" | cut -d: -f2 | xargs)
        if [ -n "$driver" ]; then echo -e "     ${GREEN}[Driver Aktif: $driver]${NC}"; else echo -e "     ${RED}[Tidak ada driver aktif]${NC}"; fi
    done
    lsusb | grep -i "wireless\|wlan\|wifi" | while read -r line; do
        echo -e "   - [USB] $line"
    done

    echo -e "\n${YELLOW}3. Bluetooth:${NC}"
    rfkill list bluetooth | grep -v "Bluetooth" | grep -v "Soft" | grep -v "Hard" | xargs -r echo "   - Terdeteksi via rfkill"
    lsusb | grep -i "bluetooth" | while read -r line; do
        echo -e "   - $line"
    done
    if systemctl is-active --quiet bluetooth; then echo -e "     ${GREEN}[Service Aktif]${NC}"; else echo -e "     ${RED}[Service Mati / Belum Diinstall]${NC}"; fi

    # Fingerprint detection (usually USB but sometimes on sysfs)
    echo -e "\n${YELLOW}4. FingerPrint Reader:${NC}"
    fplist=$(lsusb | grep -i "fingerprint\|biometric")
    if [ -n "$fplist" ]; then
        echo -e "   - $fplist"
    else
        echo -e "   - ${CYAN}Tidak terdeteksi di USB${NC}"
    fi

    # Printer detection
    echo -e "\n${YELLOW}5. Printer:${NC}"
    if command -v lpstat &> /dev/null; then
        lpstat -a | awk '{print "   - "$1" (CUPS)"}' || echo -e "   - ${CYAN}Tidak ada printer terkonfigurasi di CUPS${NC}"
    else
        echo -e "   - ${CYAN}Layanan CUPS belum terinstall${NC}"
    fi

    echo -e "${MAGENTA}--------------------------------------------------${NC}"
    read -p "Tekan Enter untuk kembali ke Menu Driver..."
}

# --- FUNGSI AUTO INSTALL & FIX WIFI DRIVER ---
auto_install_wifi() {
    clear
    show_banner
    echo -e "${BLUE}>>> AUTO INSTALL & FIX DRIVER WIFI <<<${NC}"
    echo -e "${MAGENTA}--------------------------------------------------${NC}"
    
    echo -e "${YELLOW}--> Mendeteksi Hardware WiFi...${NC}"
    WIFI_INFO=$(lspci -nn | grep -i "network\|wireless")
    
    if [ -z "$WIFI_INFO" ]; then
        WIFI_INFO=$(lsusb | grep -i "wireless\|wlan\|wifi")
    fi

    if [ -z "$WIFI_INFO" ]; then
        echo -e "${RED}==> Tidak ada perangkat WiFi yang terdeteksi di sistem ini.${NC}"
        read -p "Tekan Enter untuk kembali..."
        return
    fi
    
    echo -e "${CYAN}Perangkat Terdeteksi:${NC}"
    echo "$WIFI_INFO"
    echo ""
    
    echo -e "${YELLOW}--> Update repositori paket...${NC}"
    pkg_update
    
    # Deteksi vendor dan siapkan nama paket
    local PKG_TO_INSTALL=""
    local MODULE_NAME=""
    
    # 1. Broadcom
    if echo "$WIFI_INFO" | grep -qi "broadcom\|bcm43\|14e4:"; then
        echo -e "${CYAN}==> Chipset Broadcom terdeteksi.${NC}"
        PKG_TO_INSTALL="firmware-b43-installer b43-fwcutter"
        MODULE_NAME="b43"
        # Hapus konflik
        sudo apt-get remove --purge -y broadcom-sta-dkms broadcom-sta-common broadcom-sta-source 2>/dev/null
        sudo rmmod wl 2>/dev/null
        echo "blacklist wl" | sudo tee /etc/modprobe.d/blacklist-broadcom.conf > /dev/null
    
    # 2. Ralink / MediaTek
    elif echo "$WIFI_INFO" | grep -qi "ralink\|rt3290\|mediatek\|1814:\|02d0:"; then
        echo -e "${CYAN}==> Chipset Ralink/MediaTek terdeteksi.${NC}"
        PKG_TO_INSTALL="firmware-ralink firmware-mediatek firmware-misc-nonfree"
        MODULE_NAME="rt2800pci" # atau rt2800usb tergantung interface, tapi ini default aman
    
    # 3. Realtek
    elif echo "$WIFI_INFO" | grep -qi "realtek\|rtl\|10ec:"; then
        echo -e "${CYAN}==> Chipset Realtek terdeteksi.${NC}"
        PKG_TO_INSTALL="firmware-realtek"
        MODULE_NAME=$(echo "$WIFI_INFO" | grep -io "rtl[0-9]*[a-z]*" | head -1)
        [ -z "$MODULE_NAME" ] && MODULE_NAME="rtlwifi"
    
    # 4. Intel
    elif echo "$WIFI_INFO" | grep -qi "intel\|iwl\|8086:"; then
        echo -e "${CYAN}==> Chipset Intel terdeteksi.${NC}"
        PKG_TO_INSTALL="firmware-iwlwifi"
        MODULE_NAME="iwlwifi"
        
    # 5. Atheros / Qualcomm
    elif echo "$WIFI_INFO" | grep -qi "atheros\|ath\|qualcomm\|168c:"; then
        echo -e "${CYAN}==> Chipset Atheros/Qualcomm terdeteksi.${NC}"
        PKG_TO_INSTALL="firmware-atheros"
        MODULE_NAME="ath9k"
    
    # 6. Umum / General
    else
        echo -e "${YELLOW}==> Chipset spesifik tidak dikenali, memasang firmware generic...${NC}"
        PKG_TO_INSTALL="firmware-linux firmware-linux-nonfree firmware-misc-nonfree linux-firmware"
    fi
    
    # Install Paket (Fallback nama paket generic antar OS)
    if [ -n "$PKG_TO_INSTALL" ]; then
        echo -e "${YELLOW}--> Menginstal paket firmware: $PKG_TO_INSTALL ...${NC}"
        # Modifikasi nama firmware untuk RedHat/Arch jika perlu
        if [ "$PKG_MANAGER" == "dnf" ] || [ "$PKG_MANAGER" == "zypper" ]; then
            PKG_TO_INSTALL=$(echo $PKG_TO_INSTALL | sed 's/firmware-/linux-firmware-/g')
        elif [ "$PKG_MANAGER" == "pacman" ]; then
            PKG_TO_INSTALL="linux-firmware"
        fi
        pkg_install "$PKG_TO_INSTALL"
    fi
    
    # Reload modul & Network Manager
    echo -e "${YELLOW}--> Me-restart layanan jaringan dan memuat ulang modul...${NC}"
    sudo systemctl restart NetworkManager 2>/dev/null
    
    if [ -n "$MODULE_NAME" ]; then
        sudo modprobe "$MODULE_NAME" 2>/dev/null
    fi
    
    sleep 2
    
    # --- Fix Permanen (Auto-Load on Boot) ---
    echo -e "${CYAN}--> Memastikan konfigurasi tersimpan permanen...${NC}"
    # Cari kembali modul yang terpakai jika tadi pakai generic atau gak yakin
    local ACTIVE_MOD=$(lsmod | grep -E "^(b43|wl|rt2800pci|rt2x00pci|rt2800usb|ath9k|ath10k|iwlwifi|rtl8723be|rtl8192ce|rtl8822be|rtl8821ce|mt76)" | awk '{print $1}' | head -n 1)
    
    # Prioritaskan MODULE_NAME dari tebakan vendor jika ACTIVE_MOD gagal ketangkap
    [ -n "$ACTIVE_MOD" ] && MODULE_NAME="$ACTIVE_MOD"
    
    if [ -n "$MODULE_NAME" ]; then
        echo "$MODULE_NAME" | sudo tee /etc/modules-load.d/wifi-fix.conf > /dev/null
        echo -e "${GREEN}==> Driver '$MODULE_NAME' berhasil disimpan permanen saat booting!${NC}"
    else
        echo -e "${YELLOW}==> Tidak ada modul spesifik yang terdeteksi untuk autorun. Mungkin aman pakai driver bawaan kernel.${NC}"
    fi

    # Tampilkan Hasil
    echo ""
    echo -e "${MAGENTA}---------------- HASIL ----------------${NC}"
    if ip link show | grep -q "wlan"; then
        echo -e "${GREEN}[SUKSES] Interface WiFi (wlan) berhasil aktif!${NC}"
        ip link show | grep -A1 "wlan"
    else
        echo -e "${RED}[WARNING] Interface WiFi belum muncul. Cobalah merestart komputer Anda.${NC}"
    fi
    echo -e "${MAGENTA}-----------------------------------------${NC}"
    
    read -p "Tekan Enter untuk melanjutkan..."
}

# --- SUB-MENU: INSTALL DRIVERS ---
menu_drivers() {
    while true; do
        clear
        show_banner
        echo -e "${BLUE}>>> KATEGORI: INSTALL DRIVERS (ADVANCED) <<<${NC}"
        echo "1. 🔍 Scan Hardware & Status Driver Saat Ini"
        echo -e "${MAGENTA}--------------------------------------------------${NC}"
        echo "2. Install Driver Graphic (NVIDIA Auto-detect)"
        echo "3. Install Driver Graphic (AMD/Radeon OS Mesa)"
        echo "4. Auto Install & Fix Driver WLAN / WiFi"
        echo "5. Install Driver Bluetooth"
        echo "6. Install Driver FingerPrint Reader"
        echo "7. Install Driver Printer (CUPS)"
        echo "8. Install USB Tools & Network Firmware"
        echo "9. Kembali ke Menu Utama"
        read -p "Pilih aksi: " subchoice
        case $subchoice in
            1) scan_hardware ;;
            2) 
                if [ "$PKG_MANAGER" == "apt" ]; then
                    sudo ubuntu-drivers autoinstall || (sudo apt update && sudo apt install nvidia-driver-535 -y)
                elif [ "$PKG_MANAGER" == "dnf" ]; then
                    sudo dnf install akmod-nvidia xorg-x11-drv-nvidia-cuda -y
                elif [ "$PKG_MANAGER" == "pacman" ]; then
                    sudo pacman -S nvidia nvidia-utils --noconfirm
                fi
                read -p "Tekan Enter untuk melanjutkan..." ;;
            3) 
                pkg_update && pkg_install "mesa-utils"
                if [ "$PKG_MANAGER" == "apt" ]; then pkg_install "libgl1-mesa-dri"; fi
                read -p "Tekan Enter untuk melanjutkan..." ;;
            4) auto_install_wifi ;;
            5)
                echo -e "${CYAN}--> Menginstall dependensi Bluetooth...${NC}"
                pkg_update && pkg_install "bluez" && pkg_install "rfkill"
                if [ "$PKG_MANAGER" == "apt" ]; then pkg_install "bluetooth" && pkg_install "bluez-tools"; fi
                sudo systemctl enable bluetooth
                sudo systemctl start bluetooth
                echo -e "${GREEN}==> Bluetooth services telah dipasang & diaktifkan!${NC}"
                read -p "Tekan Enter untuk melanjutkan..."
                ;;
            6)
                echo -e "${CYAN}--> Menginstall dependensi FingerPrint (fprintd)...${NC}"
                pkg_update && pkg_install "fprintd"
                echo -e "${GREEN}==> Untuk mendaftarkan sidik jari gunakan perintah: fprintd-enroll${NC}"
                read -p "Tekan Enter untuk melanjutkan..."
                ;;
            7) 
                pkg_update && pkg_install "cups" && pkg_install "cups-client" && pkg_install "system-config-printer"
                sudo systemctl enable --now cups
                read -p "Tekan Enter untuk melanjutkan..." ;;
            8)
                echo -e "${CYAN}--> Menginstall dependensi USB & Network Drivers Dasar...${NC}"
                pkg_update && pkg_install "usbutils"
                if [ "$PKG_MANAGER" == "apt" ]; then pkg_install "build-essential dkms linux-headers-$(uname -r) linux-firmware"; fi
                read -p "Tekan Enter untuk melanjutkan..."
                ;;
            9) break ;;
            *) echo -e "${RED}Pilihan tidak valid!${NC}"; sleep 1 ;;
        esac
    done
}

# --- SUB-MENU: PERBAIKAN DISK (Harddisk, SSD, SD Card) ---
menu_repair() {
    while true; do
        clear
        show_banner
        echo -e "${BLUE}>>> KATEGORI: PERBAIKAN DISK <<<${NC}"
        echo "1. Cek Kesehatan Disk (SMART)"
        echo "2. Perbaiki Bad Sector (fsck)"
        echo "3. Format/Wipe Disk (Hati-hati!)"
        echo "4. Tampilkan Daftar Partisi (lsblk & fdisk)"
        echo "5. Mount/Unmount USB/SD Card/Partisi"
        echo "6. Kembali ke Menu Utama"
        read -p "Pilih perbaikan: " subchoice
        case $subchoice in
            1) 
                pkg_update && pkg_install "smartmontools"
                lsblk
                read -p "Masukkan nama disk (contoh: /dev/sda): " disk_name
                sudo smartctl -a $disk_name | less
                ;;
            2)
                lsblk
                read -p "Masukkan nama partisi (contoh: /dev/sda1): " part_name
                echo -e "${RED}Pastikan partisi tidak sedang di-mount!${NC}"
                sudo fsck -y $part_name
                read -p "Tekan Enter untuk melanjutkan..."
                ;;
            3)
                lsblk
                read -p "Masukkan nama disk/partisi untuk diformat ext4 (contoh: /dev/sdb1): " format_part
                echo -e "${RED}PERINGATAN: SEMUA DATA PADA $format_part AKAN HILANG!${NC}"
                read -p "Ketik 'YA' (tanpa tanda kutip) untuk melanjutkan: " konfirmasi
                if [ "$konfirmasi" == "YA" ]; then
                    sudo mkfs.ext4 $format_part
                    echo -e "${GREEN}Selesai diformat.${NC}"
                else
                    echo -e "${YELLOW}Dibatalkan.${NC}"
                fi
                read -p "Tekan Enter untuk melanjutkan..."
                ;;
            4)
                sudo fdisk -l
                echo ""
                lsblk
                read -p "Tekan Enter untuk melanjutkan..."
                ;;
            5)
                echo "1) Mount  2) Unmount"
                read -p "Pilih (1/2): " mt_choice
                lsblk
                if [ "$mt_choice" == "1" ]; then
                    read -p "Masukkan nama partisi (contoh: /dev/sdb1): " p_name
                    read -p "Folder tujuan mount (contoh: /mnt/usb): " f_name
                    sudo mkdir -p $f_name
                    sudo mount $p_name $f_name
                    echo -e "${GREEN}Berhasil mount $p_name ke $f_name${NC}"
                elif [ "$mt_choice" == "2" ]; then
                    read -p "Masukkan nama partisi atau folder mount (contoh: /dev/sdb1 atau /mnt/usb): " p_name
                    sudo umount $p_name
                    echo -e "${GREEN}Berhasil unmount $p_name${NC}"
                fi
                read -p "Tekan Enter untuk melanjutkan..."
                ;;
            6) break ;;
            *) echo -e "${RED}Pilihan tidak valid!${NC}"; sleep 1 ;;
        esac
    done
}

# --- SUB-MENU: RECOVERY DATA FULL FITUR ---
menu_recovery() {
    while true; do
        clear
        show_banner
        echo -e "${BLUE}>>> KATEGORI: RECOVERY DATA <<<${NC}"
        echo "1. Install TestDisk & PhotoRec"
        echo "2. Jalankan TestDisk (Recovery Partisi Hilang)"
        echo "3. Jalankan PhotoRec (Recovery File/Foto/Video)"
        echo "4. Install extundelete (Recovery Ext3/Ext4)"
        echo "5. Recovery File Terhapus (extundelete)"
        echo "6. Kembali ke Menu Utama"
        read -p "Pilih opsi: " subchoice
        case $subchoice in
            1) pkg_update && pkg_install "testdisk"; read -p "Tekan Enter untuk melanjutkan..." ;;
            2) sudo testdisk ;;
            3) sudo photorec ;;
            4) pkg_update && pkg_install "extundelete"; read -p "Tekan Enter untuk melanjutkan..." ;;
            5)
                lsblk
                read -p "Masukkan partisi asal (contoh: /dev/sda1): " part_name
                read -p "Masukkan folder tujuan map recovery (contoh: /mnt/recovery): " target_dir
                sudo mkdir -p $target_dir
                cd $target_dir
                sudo extundelete $part_name --restore-all
                echo -e "${GREEN}Proses selasai. Cek folder RECOVERED_FILES di $target_dir${NC}"
                read -p "Tekan Enter untuk melanjutkan..."
                ;;
            6) break ;;
            *) echo -e "${RED}Pilihan tidak valid!${NC}"; sleep 1 ;;
        esac
    done
}

# --- SUB-MENU: BACKUP & RESTORE KONFIGURASI ---
do_backup_restore_browser() {
    local b_name=$1
    local b_path=$2
    echo -e "${CYAN}--- $b_name ---${NC}"
    echo "1. Backup"
    echo "2. Restore"
    read -p "Pilih (1/2): " br_act
    local backup_dir="$BACKUP_BASE_DIR/Browser"
    mkdir -p "$backup_dir"
    local archive_name="$backup_dir/${b_name}_backup_$(date +%Y%m%d).tar.gz"
    
    if [ "$br_act" == "1" ]; then
        if [ -d "$b_path" ]; then
            echo -e "${YELLOW}--> Mem-backup $b_name...${NC}"
            tar -czf "$archive_name" -C "$(dirname "$b_path")" "$(basename "$b_path")"
            echo -e "${GREEN}==> Backup berhasil disimpan di $archive_name${NC}"
        else
            echo -e "${RED}==> Konfigurasi $b_name tidak ditemukan di $b_path${NC}"
        fi
        read -p "Tekan Enter untuk melanjutkan..."
    elif [ "$br_act" == "2" ]; then
        echo -e "${YELLOW}Daftar Backup $b_name yang tersedia:${NC}"
        ls -1 "$backup_dir/${b_name}"*.tar.gz 2>/dev/null || echo -e "${RED}Tidak ada file backup.${NC}"
        read -p "Masukkan path (lokasi) file backup lengkap: " f_backup
        if [ -f "$f_backup" ]; then
            echo -e "${YELLOW}--> Me-restore $b_name...${NC}"
            tar -xzf "$f_backup" -C "$(dirname "$b_path")"
            echo -e "${GREEN}==> Restore berhasil dilakukan!${NC}"
        else
            echo -e "${RED}==> File backup tidak ditemukan!${NC}"
        fi
        read -p "Tekan Enter untuk melanjutkan..."
    else
        echo -e "${RED}Pilihan tidak valid!${NC}"; sleep 1
    fi
}

menu_backup_browser() {
    while true; do
        clear
        show_banner
        echo -e "${BLUE}>>> SUB-MENU: BACKUP/RESTORE BROWSER <<<${NC}"
        echo "1. Mozilla Firefox"
        echo "2. Google Chrome"
        echo "3. Brave Browser"
        echo "4. Microsoft Edge"
        echo "5. Vivaldi"
        echo "6. Chromium"
        echo "7. Kembali"
        read -p "Pilih browser: " br_choice
        case $br_choice in
            1) do_backup_restore_browser "Firefox" "$HOME/.mozilla/firefox" ;;
            2) do_backup_restore_browser "Chrome" "$HOME/.config/google-chrome" ;;
            3) do_backup_restore_browser "Brave" "$HOME/.config/BraveSoftware/Brave-Browser" ;;
            4) do_backup_restore_browser "Edge" "$HOME/.config/microsoft-edge" ;;
            5) do_backup_restore_browser "Vivaldi" "$HOME/.config/vivaldi" ;;
            6) do_backup_restore_browser "Chromium" "$HOME/.config/chromium" ;;
            7) break ;;
            *) echo -e "${RED}Pilihan tidak valid!${NC}"; sleep 1 ;;
        esac
    done
}

backup_restore_wifi() {
    echo -e "${CYAN}--- WiFi (NetworkManager) ---${NC}"
    echo "1. Backup Konfigurasi WiFi"
    echo "2. Restore Konfigurasi WiFi"
    read -p "Pilih (1/2): " br_act
    local backup_dir="$BACKUP_BASE_DIR/WiFi"
    mkdir -p "$backup_dir"
    local archive_name="$backup_dir/wifi_backup_$(date +%Y%m%d).tar.gz"
    
    if [ "$br_act" == "1" ]; then
        echo -e "${YELLOW}--> Mem-backup Konfigurasi WiFi...${NC}"
        sudo tar -czf "$archive_name" -C /etc/NetworkManager/system-connections .
        sudo chown $(whoami):$(whoami) "$archive_name"
        echo -e "${GREEN}==> Backup berhasil disimpan di $archive_name${NC}"
        read -p "Tekan Enter untuk melanjutkan..."
    elif [ "$br_act" == "2" ]; then
        echo -e "${YELLOW}Daftar Backup WiFi yang tersedia:${NC}"
        ls -1 "$backup_dir/wifi_backup_"*.tar.gz 2>/dev/null || echo -e "${RED}Tidak ada file backup.${NC}"
        read -p "Masukkan path (lokasi) file backup lengkap: " f_backup
        if [ -f "$f_backup" ]; then
            echo -e "${YELLOW}--> Me-restore Konfigurasi WiFi...${NC}"
            sudo tar -xzf "$f_backup" -C /etc/NetworkManager/system-connections
            sudo chmod 600 /etc/NetworkManager/system-connections/*
            sudo systemctl restart NetworkManager
            echo -e "${GREEN}==> Restore berhasil dan NetworkManager direstart!${NC}"
        else
            echo -e "${RED}==> File backup tidak ditemukan!${NC}"
        fi
        read -p "Tekan Enter untuk melanjutkan..."
    else
        echo -e "${RED}Pilihan tidak valid!${NC}"; sleep 1
    fi
}

backup_restore_terminal() {
    echo -e "${CYAN}--- Terminal (.bashrc, .zshrc, .profile) ---${NC}"
    echo "1. Backup Terminal Configs"
    echo "2. Restore Terminal Configs"
    read -p "Pilih (1/2): " br_act
    local backup_dir="$BACKUP_BASE_DIR/Terminal"
    mkdir -p "$backup_dir"
    local archive_name="$backup_dir/terminal_backup_$(date +%Y%m%d).tar.gz"
    
    if [ "$br_act" == "1" ]; then
        echo -e "${YELLOW}--> Mem-backup Konfigurasi Terminal...${NC}"
        tar -czf "$archive_name" -C "$HOME" .bashrc .zshrc .profile .bash_aliases 2>/dev/null
        echo -e "${GREEN}==> Backup berhasil disimpan di $archive_name${NC}"
        read -p "Tekan Enter untuk melanjutkan..."
    elif [ "$br_act" == "2" ]; then
        echo -e "${YELLOW}Daftar Backup Terminal yang tersedia:${NC}"
        ls -1 "$backup_dir/terminal_backup_"*.tar.gz 2>/dev/null || echo -e "${RED}Tidak ada file backup.${NC}"
        read -p "Masukkan path (lokasi) file backup lengkap: " f_backup
        if [ -f "$f_backup" ]; then
            echo -e "${YELLOW}--> Me-restore Konfigurasi Terminal...${NC}"
            tar -xzf "$f_backup" -C "$HOME"
            echo -e "${GREEN}==> Restore berhasil dilakukan!${NC}"
        else
            echo -e "${RED}==> File backup tidak ditemukan!${NC}"
        fi
        read -p "Tekan Enter untuk melanjutkan..."
    else
        echo -e "${RED}Pilihan tidak valid!${NC}"; sleep 1
    fi
}

backup_restore_ssh_gpg() {
    echo -e "${CYAN}--- Kunci SSH & GPG ---${NC}"
    echo "1. Backup Kunci"
    echo "2. Restore Kunci"
    read -p "Pilih (1/2): " br_act
    local backup_dir="$BACKUP_BASE_DIR/Keys"
    mkdir -p "$backup_dir"
    local archive_name="$backup_dir/keys_backup_$(date +%Y%m%d).tar.gz"
    
    if [ "$br_act" == "1" ]; then
        echo -e "${YELLOW}--> Mem-backup Kunci SSH & GPG...${NC}"
        tar -czf "$archive_name" -C "$HOME" .ssh .gnupg 2>/dev/null
        echo -e "${GREEN}==> Backup berhasil disimpan di $archive_name${NC}"
        read -p "Tekan Enter untuk melanjutkan..."
    elif [ "$br_act" == "2" ]; then
        echo -e "${YELLOW}Daftar Backup Kunci yang tersedia:${NC}"
        ls -1 "$backup_dir/keys_backup_"*.tar.gz 2>/dev/null || echo -e "${RED}Tidak ada file backup.${NC}"
        read -p "Masukkan path (lokasi) file backup lengkap: " f_backup
        if [ -f "$f_backup" ]; then
            echo -e "${YELLOW}--> Me-restore Kunci SSH & GPG...${NC}"
            tar -xzf "$f_backup" -C "$HOME"
            chmod 700 "$HOME/.ssh" "$HOME/.gnupg" 2>/dev/null
            chmod 600 "$HOME/.ssh/"* 2>/dev/null
            echo -e "${GREEN}==> Restore berhasil dilakukan dan permission disesuaikan!${NC}"
        else
            echo -e "${RED}==> File backup tidak ditemukan!${NC}"
        fi
        read -p "Tekan Enter untuk melanjutkan..."
    else
        echo -e "${RED}Pilihan tidak valid!${NC}"; sleep 1
    fi
}

menu_backup_restore() {
    while true; do
        clear
        show_banner
        echo -e "${BLUE}>>> KATEGORI: BACKUP / RESTORE KONFIGURASI <<<${NC}"
        echo "1. Backup/Restore Browser (Sub Menu)"
        echo "2. Backup/Restore Konfigurasi WiFi (NetworkManager)"
        echo "3. Backup/Restore Terminal & Shell (.bashrc, .zshrc)"
        echo "4. Backup/Restore Kunci SSH & GPG"
        echo "5. Kembali ke Menu Utama"
        read -p "Pilih aksi: " subchoice
        case $subchoice in
            1) menu_backup_browser ;;
            2) backup_restore_wifi ;;
            3) backup_restore_terminal ;;
            4) backup_restore_ssh_gpg ;;
            5) break ;;
            *) echo -e "${RED}Pilihan tidak valid!${NC}"; sleep 1 ;;
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
    echo -e "${CYAN}------------------ FITUR ADVANCED ----------------${NC}"
    echo "8. Konfigurasi Sistem"
    echo "9. Install Tools & Utilities"
    echo "10. Install Drivers"
    echo "11. Perbaikan Disk (HDD/SSD/SD Card)"
    echo "12. Recovery Data Full Fitur"
    echo "13. Backup/Restore Konfigurasi"
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
        8) menu_konfigurasi ;;
        9) menu_tools ;;
        10) menu_drivers ;;
        11) menu_repair ;;
        12) menu_recovery ;;
        13) menu_backup_restore ;;
        0) exit 0 ;;
        *) echo -e "${RED}Pilihan tidak valid!${NC}"; sleep 1 ;;
    esac
done
