# 💻 Apps Manager Pro - By : Mr.exe
**The Ultimate Cross-Distro Linux System & Application Manager**

[![Bash Shell](https://img.shields.io/badge/Bash-Script-4EAA25?style=flat&logo=gnu-bash&logoColor=white)](https://www.gnu.org/software/bash/)
[![Python 3](https://img.shields.io/badge/Python-3-3776AB?style=flat&logo=python&logoColor=white)](https://www.python.org/)
[![GUI](https://img.shields.io/badge/GUI-CustomTkinter-1f538d?style=flat)](https://github.com/TomSchimansky/CustomTkinter)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Donation](https://img.shields.io/badge/Donate-Saweria-F2A145?style=flat&logo=saweria)](https://saweria.co/andrewsianturi)

---
*🌍 Choose your language / Pilih bahasa:* 
[**🇬🇧 English**](#english-version) | [**🇮🇩 Indonesia**](#versi-indonesia)
---

# 🇬🇧 English Version

**Apps Manager Pro** is a professional *All-in-One Toolkit* designed to simplify the management of your Linux operating system. Featuring both an interactive CLI interface and a modern GUI (Dark Tron Green theme), this tool works seamlessly across almost **all major Linux distribution families** (Debian/Ubuntu, RHEL/Fedora, Arch/Manjaro, and openSUSE).

## 🌟 Key Features
This application includes 13 massive feature categories, intelligently integrated (`auto-detects package manager` / `apt` / `dnf` / `pacman` / `zypper`):

1. 🌐 **Internet & Communication**: Automate Chrome, Firefox, Telegram, Discord, Thunderbird, WhatsApp/ZapZap installation.
2. 📎 **Office & Productivity**: LibreOffice, WPS Office, PDF Readers (Evince/Okular), Text Editors.
3. 🎵 **Multimedia**: VLC, OBS Studio, Spotify, Audacity, Rhythmbox/Clementine.
4. 🎨 **Drawing & Design**: GIMP, Krita, Inkscape, Blender (3D).
5. 🛠️ **Developer Tools**: VS Code (Official repo), Git, full Flatpak setup (GNOME Software plugin), Docker & Docker-Compose, Node.js + NPM, Antigravity.
6. 🌍 **Remote Apps (Custom)**: Bypass installation straight from *.deb/.rpm URLs*, *.AppImage files*, Snap Store, and Flatpak AppIDs.
7. 🖥️ **Remote Desktop**: AnyDesk, TeamViewer (Official DEB/RPM), RustDesk.
8. ⚙️ **System Configuration**: One-click OS Update & Upgrade, nmtui, UFW Firewall activation, Timezone Sync, Timeshift (Restore Point), Bleachbit/Stacer, and automatic RAM *Drop Caches* cleaning.
9. 🧰 **Utilities & Tools**: Htop, Btop, Neofetch, Tmux, Curl, Wget, net-tools, usbutils, GParted.
10. 🔌 **Install & Fix Drivers**:
    - 🔍 **Hardware Scanner**: Real-time PCI/USB vendor detection (VGA, WLAN, BT, etc).
    - 🎮 **Graphic**: NVIDIA Proprietary Auto-Installer & AMD OS Mesa.
    - 📡 **Auto WLAN/WiFi Fixer**: Script that detects Intel/Realtek/Broadcom/Ralink chips and auto-injects missing *firmware-linux-nonfree*.
    - 🖨️ **Peripheral**: Bluetooth setup, FingerPrint Reader (`fprintd`), CUPS Print Service.
11. 💽 **Disk Repair**: SMART Monitoring, bad sector check (`fsck`), Ext4 format, Partition management.
12. 🔎 **Data Recovery**: Recover deleted files/photos using *TestDisk, PhotoRec, and Extundelete*.
13. 💾 **Backup & Restore**: Automatically backup configurations to the `br/` directory (Browser Profiles, NetworkManager/WiFi, SSH, GPG, `.bashrc` Terminal ENV).

## 🚀 Installation & Usage
Just clone the repository:
```bash
git clone https://github.com/andrew7str/Apps-Manager.git
cd Apps-Manager
```

* **CLI Mode (Bash script)**: Ideal for servers and power-users.
   ```bash
   chmod +x AppsManagerPro.sh
   ./AppsManagerPro.sh
   ```
* **Modern GUI Mode (Python 3)**: Beautiful "Dark Tron Green" theme with integrated secure terminal output (`pkexec`). Needs `customtkinter` (e.g. `pip install customtkinter`).
   ```bash
   python3 AppsManagerProGUI.py
   ```

---
---

# 🇮🇩 Versi Indonesia

**Apps Manager Pro** adalah sebuah *All-in-One Toolkit* yang dirancang secara profesional untuk mempermudah manajemen sistem operasi Linux Anda. Menghadirkan antarmuka berbasis CLI interaktif dan GUI Modern (Dark Tron Green), tool ini berfungsi mulus di hampir **seluruh basis keluarga distribusi Linux** (Debian/Ubuntu, RHEL/Fedora, Arch/Manjaro, dan openSUSE).

## 🌟 Fitur Utama
Aplikasi ini memiliki 13 kategori fitur raksasa yang sudah terintegrasi secara cerdas (`auto-detect package manager` / `apt` / `dnf` / `pacman` / `zypper`):

1. 🌐 **Internet & Komunikasi**: Otomasi instalasi Chrome, Firefox, Telegram, Discord, Thunderbird, WhatsApp/ZapZap.
2. 📎 **Office & Produktivitas**: LibreOffice, WPS Office, PDF Reader (Evince/Okular), Text Editor.
3. 🎵 **Multimedia**: VLC, OBS Studio, Spotify, Audacity, Rhythmbox/Clementine.
4. 🎨 **Menggambar & Desain**: GIMP, Krita, Inkscape, Blender (3D).
5. 🛠️ **Developer Tools**: VS Code (Official repo), Git, setelan lengkap Flatpak (GNOME Software plugin), Docker & Docker-Compose, Node.js + NPM, Antigravity.
6. 🌍 **Aplikasi Remote (Custom)**: Support bypass instalasi langsung dari *URL .deb/.rpm*, file *.AppImage*, Snap Store, dan Flatpak AppIDs.
7. 🖥️ **Remote Desktop**: AnyDesk, TeamViewer (Official DEB/RPM), RustDesk.
8. ⚙️ **Konfigurasi Sistem**: Update & Upgrade sistem sekali klik, nmtui, aktivasi UFW Firewall, Sinkronisasi Timezone, Timeshift (Restore Point), Bleachbit/Stacer, dan pembersihan *Drop Caches* RAM otomatis.
9. 🧰 **Utilities & Tools**: Htop, Btop, Neofetch, Tmux, Curl, Wget, net-tools, usbutils, GParted.
10. 🔌 **Install & Fix Drivers (Lengkap)**:
    - 🔍 **Hardware Scanner**: Deteksi Vendor PCI/USB (VGA, WLAN, BT, dll) real-time.
    - 🎮 **Graphic**: NVIDIA Proprietary Auto-Installer & AMD OS Mesa.
    - 📡 **Auto WLAN/WiFi Fixer**: Script pendeteksi intel/realtek/broadcom/ralink yang secara otomatis menginjeksi *firmware-linux-nonfree*.
    - 🖨️ **Peripheral**: Setup Bluetooth, FingerPrint Reader (`fprintd`), Layanan Print CUPS.
11. 💽 **Perbaikan Disk (Disk Repair)**: SMART Monitoring, pengecekan bad sector (`fsck`), format Ext4, dan Manajemen partisi.
12. 🔎 **Recovery Data**: Mengembalikan file atau foto yang terhapus dengan *TestDisk, PhotoRec, dan Extundelete*.
13. 💾 **Backup & Restore**: Mencadangkan Konfigurasi secara otomatis ke folder `br/` (Browser Profil, NetworkManager/WiFi, SSH, GPG, Terminal ENV `.bashrc`).

## 🚀 Instalasi & Cara Menggunakan
Cukup *clone* repositorinya:
```bash
git clone https://github.com/andrew7str/Apps-Manager.git
cd Apps-Manager
```

* **Mode Terminal (Bash Script)**: Sangat cocok bagi Anda pengguna *server* atau *power-user*.
   ```bash
   chmod +x AppsManagerPro.sh
   ./AppsManagerPro.sh
   ```
* **Mode Modern GUI (Python)**: Menampilkan jendela grafis memukau bertema "Dark Tron Green" interaktif. *(Pastikan environment python3 terinstall `customtkinter`)*:
   ```bash
   python3 AppsManagerProGUI.py
   ```

---

## ☕ Support & Donation
Jika _toolkit_ *Apps Manager Pro* ini membantu menghemat waktu Anda, Anda bisa mendukung pengembangan proyek ini dengan memberikan donasi secangkir kopi! 

[![Saweria](https://img.shields.io/badge/Support_via-Saweria-F2A145?style=for-the-badge&logo=saweria)](https://saweria.co/andrewsianturi)

---
> *"Be Lazy, Write Scripts, and Automate Everything!"* - **Mr.exe**
