import customtkinter as ctk  # type: ignore
import subprocess
import os
import threading
from tkinter import filedialog, messagebox

# --- Konfigurasi Tema (Dark Tron Green) ---
ctk.set_appearance_mode("Dark")
ctk.set_default_color_theme("green")

# Warna Kustom Tron
BG_COLOR = "#050B06"
PANEL_COLOR = "#0D1A10"
ACCENT_COLOR = "#00FF41"
HOVER_COLOR = "#00B32C"
TEXT_COLOR = "#E0F5E3"

class AppsManagerProGUI(ctk.CTk):
    def __init__(self):
        super().__init__()
        
        # Deteksi OS
        self.os_name, self.pkg_manager, self.pkg_install_cmd = self.detect_os()

        # Window Setup
        self.title("Apps Manager Pro - By : Mr.exe")
        self.geometry("900x600")
        self.configure(fg_color=BG_COLOR)

        # Layout Utama: Grid 1x2 (Sidebar & Main Frame)
        self.grid_rowconfigure(0, weight=1)
        self.grid_columnconfigure(1, weight=1)

        # 1. Sidebar Kiri (Navigasi)
        self.sidebar_frame = ctk.CTkScrollableFrame(self, width=220, corner_radius=0, fg_color=PANEL_COLOR)
        self.sidebar_frame.grid(row=0, column=0, sticky="nsew")
        
        # Biarkan sidebar expand jika layar membesar
        self.sidebar_frame.grid_columnconfigure(0, weight=1)

        self.logo_label = ctk.CTkLabel(self.sidebar_frame, text="Apps Manager Pro", font=ctk.CTkFont(size=18, weight="bold"), text_color=ACCENT_COLOR)
        self.logo_label.grid(row=0, column=0, padx=10, pady=(20, 10))
        
        self.os_label = ctk.CTkLabel(self.sidebar_frame, text=f"OS: {self.os_name.capitalize()}\n({self.pkg_manager})", font=ctk.CTkFont(size=12), text_color=TEXT_COLOR)
        self.os_label.grid(row=1, column=0, padx=10, pady=(0, 20))

        # Tombol Navigasi 13 Kategori
        self.btn_internet = self.create_nav_button("1. Internet & Komunikasi", 2, self.show_internet_frame)
        self.btn_office = self.create_nav_button("2. Office & Produktivitas", 3, self.show_office_frame)
        self.btn_media = self.create_nav_button("3. Multimedia", 4, self.show_media_frame)
        self.btn_design = self.create_nav_button("4. Menggambar & Desain", 5, self.show_design_frame)
        self.btn_dev = self.create_nav_button("5. Developer Tools", 6, self.show_dev_frame)
        self.btn_remoteapps = self.create_nav_button("6. Instalasi Custom/Remote", 7, self.show_remoteapps_frame)
        self.btn_remote = self.create_nav_button("7. Remote Desktop", 8, self.show_remote_frame)
        self.btn_config = self.create_nav_button("8. System Konfigurasi", 9, self.show_config_frame)
        self.btn_tools = self.create_nav_button("9. Utilities & Tools", 10, self.show_tools_frame)
        self.btn_drivers = self.create_nav_button("10. Install Drivers", 11, self.show_drivers_frame)
        self.btn_repair = self.create_nav_button("11. Perbaikan Disk", 12, self.show_repair_frame)
        self.btn_recovery = self.create_nav_button("12. Recovery Data", 13, self.show_recovery_frame)
        self.btn_backup = self.create_nav_button("13. Backup & Restore", 14, self.show_backup_frame)
        
        # 2. Frame Utama Kanan (Konten)
        self.main_frame = ctk.CTkFrame(self, corner_radius=10, fg_color=BG_COLOR)
        self.main_frame.grid(row=0, column=1, padx=20, pady=20, sticky="nsew")
        self.main_frame.grid_rowconfigure(1, weight=1) # Konten area membesar
        self.main_frame.grid_columnconfigure(0, weight=1)

        # Header Frame Konten
        self.header_label = ctk.CTkLabel(self.main_frame, text="Welcome to Apps Manager Pro", font=ctk.CTkFont(size=24, weight="bold"), text_color=ACCENT_COLOR)
        self.header_label.grid(row=0, column=0, padx=20, pady=20, sticky="nw")

        # Area Konten Dinamis
        self.content_area = ctk.CTkScrollableFrame(self.main_frame, fg_color="transparent")
        self.content_area.grid(row=1, column=0, padx=20, pady=10, sticky="nsew")
        self.content_area.grid_columnconfigure(0, weight=1) # <-- FIX BUG AUTORESIZE KONTEN

        # 3. Terminal Output Bawah
        self.log_textbox = ctk.CTkTextbox(self.main_frame, height=120, fg_color=PANEL_COLOR, text_color=ACCENT_COLOR, font=ctk.CTkFont(family="monospace", size=12))
        self.log_textbox.grid(row=2, column=0, padx=20, pady=20, sticky="ew")
        self.log_textbox.insert("0.0", "[System Ready] Menunggu perintah...\n")
        self.log_textbox.configure(state="disabled")

        # Tampilkan Frame Default
        self.show_internet_frame()

    def create_nav_button(self, text, row, command):
        btn = ctk.CTkButton(self.sidebar_frame, text=text, command=command, fg_color="transparent", text_color=TEXT_COLOR, hover_color=HOVER_COLOR, anchor="w")
        btn.grid(row=row, column=0, padx=20, pady=10, sticky="ew")
        return btn

    def detect_os(self):
        os_name = "unknown"
        pkg_manager = "unknown"
        pkg_install_cmd = ""
        try:
            with open("/etc/os-release", "r") as f:
                for line in f:
                    if line.startswith("ID="):
                        os_name = line.strip().split("=")[1].replace('"', '')
                        break
        except Exception:
            pass
        
        if os_name in ["ubuntu", "debian", "linuxmint", "pop", "kali"]:
            pkg_manager = "apt"
            pkg_install_cmd = "apt install -y"
        elif os_name in ["fedora", "rhel", "centos", "almalinux"]:
            pkg_manager = "dnf"
            pkg_install_cmd = "dnf install -y"
        elif os_name in ["arch", "manjaro"]:
            pkg_manager = "pacman"
            pkg_install_cmd = "pacman -S --noconfirm"
        elif os_name in ["opensuse", "sles"]:
            pkg_manager = "zypper"
            pkg_install_cmd = "zypper install -y"
            
        return os_name, pkg_manager, pkg_install_cmd

    def log(self, text):
        self.log_textbox.configure(state="normal")
        self.log_textbox.insert("end", text + "\n")
        self.log_textbox.see("end")
        self.log_textbox.configure(state="disabled")

    def run_command_gui(self, command_str, as_root=True):
        """Menjalankan command. Jika butuh root, memanggil pkexec agar GUI gksudo muncul"""
        if as_root:
            # Gunakan pkexec (PolicyKit) untuk GUI prompt
            cmd_list = ["pkexec", "bash", "-c", command_str]
        else:
            cmd_list = ["bash", "-c", command_str]

        self.log(f"> {command_str}")
        
        def task():
            try:
                process = subprocess.Popen(cmd_list, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
                if process.stdout is not None:
                    for line in process.stdout:  # type: ignore
                        # Update GUI dari thread secara aman menggunakan after
                        self.after(0, self.log, line.strip())
                process.wait()
                if process.returncode == 0:
                    self.after(0, self.log, "[SUCCESS] Perintah selesai.")
                else:
                    self.after(0, self.log, f"[ERROR] Perintah gagal dengan kode {process.returncode}")
            except Exception as e:
                self.after(0, self.log, f"[EXCEPTION] {str(e)}")

        thread = threading.Thread(target=task)
        thread.start()

    def clear_content(self):
        for widget in self.content_area.winfo_children():
            widget.destroy()

    def create_app_row(self, name, check_cmd, install_cmd, root=True):
        frame = ctk.CTkFrame(self.content_area, fg_color=PANEL_COLOR, corner_radius=8)
        frame.grid(column=0, sticky="ew", pady=5, padx=5) # Menggunakan grid + sticky EW
        frame.grid_columnconfigure(0, weight=1)
        
        label = ctk.CTkLabel(frame, text=name, anchor="w", font=ctk.CTkFont(size=14, weight="bold"))
        label.grid(row=0, column=0, padx=15, pady=10, sticky="w")

        # Cek status terinstall
        status_text = "[Belum Aktif]"
        status_color = "gray"
        try:
            res = subprocess.run(["bash", "-c", f"command -v {check_cmd} >/dev/null 2>&1 || dpkg -s {check_cmd} >/dev/null 2>&1 || rpm -q {check_cmd} >/dev/null 2>&1 || pacman -Qs {check_cmd} >/dev/null 2>&1"], capture_output=True)
            if res.returncode == 0:
                status_text = "[Terinstall]"
                status_color = ACCENT_COLOR
        except:
            pass

        stat_label = ctk.CTkLabel(frame, text=status_text, text_color=status_color, width=120)
        stat_label.grid(row=0, column=1, padx=10, pady=10)

        # Hanya tombol Custom
        if "Install" in name or "Backup" in name or "Restore" in name:
            btn_txt = "Execute"
        else:
            btn_txt = "Install / Apply"

        btn = ctk.CTkButton(frame, text=btn_txt, fg_color=HOVER_COLOR, hover_color="#008020", width=120,
                            command=lambda: self.run_command_gui(install_cmd, as_root=root))
        btn.grid(row=0, column=2, padx=15, pady=10, sticky="e")

    # --- Kategori Menus ---
    def show_internet_frame(self):
        self.clear_content()
        self.header_label.configure(text="Internet & Komunikasi")
        
        # Contoh Chrome (Debian base)
        if self.pkg_manager == "apt":
            chrome_cmd = "wget -qO /tmp/chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && apt install /tmp/chrome.deb -y"
        else:
            chrome_cmd = "echo 'Chrome install for this OS is not fully automated via script yet.'"
            
        self.create_app_row("Google Chrome", "google-chrome", chrome_cmd)
        self.create_app_row("Telegram Desktop", "telegram-desktop", f"{self.pkg_install_cmd} telegram-desktop")
        
        if self.pkg_manager == "apt":
            self.create_app_row("Discord", "discord", "wget -qO /tmp/discord.deb https://discord.com/api/download?platform=linux&format=deb && apt install /tmp/discord.deb -y")
        
        # New Universal Apps
        self.create_app_row("Mozilla Firefox", "firefox", f"{self.pkg_install_cmd} firefox")
        self.create_app_row("Thunderbird (Email Client)", "thunderbird", f"{self.pkg_install_cmd} thunderbird")

    def show_office_frame(self):
        self.clear_content()
        self.header_label.configure(text="Office & Produktivitas")
        self.create_app_row("LibreOffice", "libreoffice", f"{self.pkg_install_cmd} libreoffice")
        
        # WPS Fallback
        wps_cmd = f"flatpak install flathub com.wps.Office -y"
        if self.pkg_manager == "apt": wps_cmd = "wget -qO /tmp/wps.deb https://wdl1.pcfg.cache.wpscdn.com/wpsdl/wpsoffice/download/linux/11698/wps-office_11.1.0.11698.XA_amd64.deb && apt install /tmp/wps.deb -y"
        self.create_app_row("WPS Office", "wps", wps_cmd)
        
        # Universal Office Tools
        evince_pkg = "evince" if self.pkg_manager == "apt" else "okular evince"
        self.create_app_row("Evince / Okular (PDF Reader)", "evince", f"{self.pkg_install_cmd} {evince_pkg}")
        
        gedit_pkg = "gedit" if self.pkg_manager == "apt" else "kwrite gedit"
        self.create_app_row("Gedit / KWrite (Text Editor)", "gedit", f"{self.pkg_install_cmd} {gedit_pkg}")
        
    def show_media_frame(self):
        self.clear_content()
        self.header_label.configure(text="Multimedia & Design")
        self.create_app_row("VLC Player", "vlc", f"{self.pkg_install_cmd} vlc")
        self.create_app_row("OBS Studio", "obs", f"{self.pkg_install_cmd} obs-studio")
        self.create_app_row("Spotify", "spotify", "snap install spotify || flatpak install flathub com.spotify.Client -y")
        self.create_app_row("Audacity (Audio Editor)", "audacity", f"{self.pkg_install_cmd} audacity")
        
        rhythm_pkg = "rhythmbox" if self.pkg_manager == "apt" else "clementine"
        self.create_app_row("Rhythmbox / Clementine", "rhythmbox", f"{self.pkg_install_cmd} {rhythm_pkg}")

    def show_design_frame(self):
        self.clear_content()
        self.header_label.configure(text="Menggambar & Desain Grafis")
        self.create_app_row("GIMP (Photo Editor)", "gimp", f"{self.pkg_install_cmd} gimp")
        self.create_app_row("Krita (Painting)", "krita", f"{self.pkg_install_cmd} krita")
        self.create_app_row("Inkscape (Vector)", "inkscape", f"{self.pkg_install_cmd} inkscape")
        self.create_app_row("Blender (3D Modeling)", "blender", f"{self.pkg_install_cmd} blender")

    def show_dev_frame(self):
        self.clear_content()
        self.header_label.configure(text="Developer Tools & Flatpak")
        
        # Flatpak Core
        self.create_app_row("Flatpak Engine", "flatpak", f"{self.pkg_install_cmd} flatpak && flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo")
        self.create_app_row("GNOME Software Plugins", "gnome-software", f"{self.pkg_install_cmd} gnome-software gnome-software-plugin-flatpak")

        self.create_app_row("Git", "git", f"{self.pkg_install_cmd} git")
        # Visual Studio Code
        vscode_cmd = ""
        if self.pkg_manager == "apt":
            vscode_cmd = "wget -qO /tmp/code.deb 'https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64' && apt install /tmp/code.deb -y"
        elif self.pkg_manager == "dnf":
            vscode_cmd = "wget -qO /tmp/code.rpm 'https://code.visualstudio.com/sha/download?build=stable&os=linux-rpm-x64' && dnf install /tmp/code.rpm -y"
        else:
            vscode_cmd = "echo 'Please use AUR/Flatpak for VS Code.'"
        self.create_app_row("VS Code", "code", vscode_cmd)
        
        # Antigravity
        if self.pkg_manager == "apt":
            ag_cmd = "mkdir -p /etc/apt/keyrings && curl -fsSL https://us-central1-apt.pkg.dev/doc/repo-signing-key.gpg | gpg --dearmor --yes -o /etc/apt/keyrings/antigravity-repo-key.gpg && echo 'deb [signed-by=/etc/apt/keyrings/antigravity-repo-key.gpg] https://us-central1-apt.pkg.dev/projects/antigravity-auto-updater-dev/ antigravity-debian main' | tee /etc/apt/sources.list.d/antigravity.list > /dev/null && apt update && apt install antigravity -y"
            self.create_app_row("Google Antigravity", "antigravity", ag_cmd)
            
        docker_pkg = "docker.io docker-compose" if self.pkg_manager == "apt" else "docker docker-compose"
        self.create_app_row("Docker & Docker-Compose", "docker", f"{self.pkg_install_cmd} {docker_pkg} && systemctl enable docker && systemctl start docker")
        self.create_app_row("Python3-PIP & Node.js", "npm", f"{self.pkg_install_cmd} python3-pip nodejs npm")

    def show_remoteapps_frame(self):
        self.clear_content()
        self.header_label.configure(text="Instalasi Custom / Remote")
        
        def install_appimage():
            dialog_url = ctk.CTkInputDialog(text="Masukkan URL Download AppImage:", title="AppImage Installer")
            url = dialog_url.get_input()
            if url:
                app_name = url.split('/')[-1]
                if not app_name.endswith(".AppImage"): app_name += ".AppImage"
                cmd = f"wget -O '/tmp/{app_name}' '{url}' && chmod +x '/tmp/{app_name}' && mv '/tmp/{app_name}' '/opt/{app_name}' && echo '[SUCCESS] AppImage saved to /opt/{app_name}'"
                self.run_command_gui(cmd, as_root=True)

        def install_snap():
            d = ctk.CTkInputDialog(text="Masukkan Nama Paket Snap (cth: vlc, spotify):", title="Snap Installer")
            pkg = d.get_input()
            if pkg:
                self.run_command_gui(f"snap install {pkg}", as_root=True)
                
        def install_url_pkg():
            d = ctk.CTkInputDialog(text="Masukkan URL .deb / .rpm:", title="URL Package")
            url = d.get_input()
            if url:
                fname = url.split('/')[-1]
                cmd = f"wget -O '/tmp/{fname}' '{url}' && if [[ '{fname}' == *.deb ]] && [ -x '$(command -v apt)' ]; then apt install '/tmp/{fname}' -y; elif [[ '{fname}' == *.rpm ]] && [ -x '$(command -v dnf)' ]; then dnf install '/tmp/{fname}' -y; fi"
                self.run_command_gui(cmd, as_root=True)
                
        def install_flatpak_remote():
            d = ctk.CTkInputDialog(text="Masukkan Flathub App ID (cth: com.spotify.Client):", title="Flatpak Installer")
            app_id = d.get_input()
            if app_id:
                self.run_command_gui(f"flatpak install flathub {app_id} -y", as_root=False)

        # Custom Buttons for this menu
        btn_ai = ctk.CTkButton(self.content_area, text="Install dari URL AppImage", command=install_appimage, fg_color=HOVER_COLOR, height=40)
        btn_ai.grid(column=0, sticky="ew", pady=10, padx=10)
        
        btn_sn = ctk.CTkButton(self.content_area, text="Install dari Nama Paket Snap", command=install_snap, height=40)
        btn_sn.grid(column=0, sticky="ew", pady=10, padx=10)

        btn_url = ctk.CTkButton(self.content_area, text="Install dari URL file (.deb/.rpm)", command=install_url_pkg, height=40)
        btn_url.grid(column=0, sticky="ew", pady=10, padx=10)

        btn_fl = ctk.CTkButton(self.content_area, text="Install Custom Flatpak AppID", command=install_flatpak_remote, height=40)
        btn_fl.grid(column=0, sticky="ew", pady=10, padx=10)

    def show_remote_frame(self):
        self.clear_content()
        self.header_label.configure(text="Aplikasi Remote Desktop")
        
        # AnyDesk
        anydesk_cmd = ""
        if self.pkg_manager == "apt":
            anydesk_cmd = "wget -qO - https://keys.anydesk.com/repos/DEB-GPG-KEY | gpg --dearmor --yes -o /usr/share/keyrings/anydesk-archive-keyring.gpg && echo 'deb [signed-by=/usr/share/keyrings/anydesk-archive-keyring.gpg] http://deb.anydesk.com/ all main' | tee /etc/apt/sources.list.d/anydesk-stable.list && apt update && apt install anydesk -y"
        else:
            anydesk_cmd = "flatpak install flathub com.anydesk.Anydesk -y"
        self.create_app_row("AnyDesk", "anydesk", anydesk_cmd)
        
        # TeamViewer
        tv_cmd = ""
        if self.pkg_manager == "apt":
            tv_cmd = "wget -qO /tmp/tv.deb 'https://download.teamviewer.com/download/linux/teamviewer_amd64.deb' && apt install /tmp/tv.deb -y"
        elif self.pkg_manager in ["dnf", "zypper"]:
            tv_cmd = "wget -qO /tmp/tv.rpm 'https://download.teamviewer.com/download/linux/teamviewer.x86_64.rpm' && dnf install /tmp/tv.rpm -y"
        else:
            tv_cmd = "echo 'Please use AUR for Teamviewer'"
        self.create_app_row("TeamViewer", "teamviewer", tv_cmd)
        
        # RustDesk
        rust_cmd = ""
        if self.pkg_manager == "apt":
            rust_cmd = "wget -qO /tmp/rust.deb 'https://github.com/rustdesk/rustdesk/releases/download/1.2.3/rustdesk-1.2.3-x86_64.deb' && apt install /tmp/rust.deb -y"
        else:
            rust_cmd = "flatpak install flathub com.rustdesk.RustDesk -y"
        self.create_app_row("RustDesk", "rustdesk", rust_cmd)

    def show_config_frame(self):
        self.clear_content()
        self.header_label.configure(text="Sistem & Konfigurasi")
        
        # Upgrade button
        upgrade_cmd = ""
        if self.pkg_manager == "apt": upgrade_cmd = "apt update && apt upgrade -y"
        elif self.pkg_manager == "dnf": upgrade_cmd = "dnf check-update; dnf upgrade -y"
        elif self.pkg_manager == "pacman": upgrade_cmd = "pacman -Syu --noconfirm"
        self.create_app_row("Update & Upgrade OS", "echo", upgrade_cmd)

        self.create_app_row("Network Config (nmtui)", "nmtui", "nmtui")
        self.create_app_row("Install & Enable UFW Firewall", "ufw", f"{self.pkg_install_cmd} ufw && ufw enable && ufw status verbose")
        
        clean_cmd = ""
        if self.pkg_manager == "apt": clean_cmd = "apt autoremove -y && apt clean && echo 3 > /proc/sys/vm/drop_caches"
        elif self.pkg_manager == "dnf": clean_cmd = "dnf autoremove -y && dnf clean all && echo 3 > /proc/sys/vm/drop_caches"
        self.create_app_row("Clear Cache & Optimize", "echo", clean_cmd)
        
        self.create_app_row("Timeshift (System Restore)", "timeshift", f"{self.pkg_install_cmd} timeshift")
        self.create_app_row("Stacer / BleachBit (Cleaner)", "bleachbit", f"{self.pkg_install_cmd} bleachbit stacer")

    def show_tools_frame(self):
        self.clear_content()
        self.header_label.configure(text="Utilities & CLI Tools")
        self.create_app_row("Htop (System Monitor)", "htop", f"{self.pkg_install_cmd} htop")
        self.create_app_row("Neofetch (Sys Info)", "neofetch", f"{self.pkg_install_cmd} neofetch")
        self.create_app_row("Tmux (Multiplexer)", "tmux", f"{self.pkg_install_cmd} tmux")
        self.create_app_row("Curl & Wget", "curl", f"{self.pkg_install_cmd} curl wget")
        self.create_app_row("Net-tools (ifconfig)", "ifconfig", f"{self.pkg_install_cmd} net-tools")
        self.create_app_row("USB Utils (lsusb)", "lsusb", f"{self.pkg_install_cmd} usbutils")
        
        gparted_pkg = "gparted" if self.pkg_manager == "apt" else "gparted partitionmanager"
        self.create_app_row("GParted (Partition GUI)", "gparted", f"{self.pkg_install_cmd} {gparted_pkg}")
        self.create_app_row("Btop (Modern Sys Monitor)", "btop", f"{self.pkg_install_cmd} btop bpytop")

    def show_drivers_frame(self):
        self.clear_content()
        self.header_label.configure(text="Install & Fix Drivers")
        
        # 1. Scan Hardware
        scan_cmd = "echo -e '\\033[0;34m>>> SCAN HARDWARE & DRIVER <<<\\033[0m' && echo '1. Graphic / VGA:' && lspci -nn | grep -i 'vga\\|3d\\|display' || echo 'No VGA detected' && echo '2. WLAN / WiFi:' && lspci -nn | grep -i 'network\\|wireless' || echo 'No WLAN PCI detected' && lsusb | grep -i 'wireless\\|wlan\\|wifi' || echo 'No WLAN USB detected' && echo '3. Bluetooth:' && lsusb | grep -i 'bluetooth' || echo 'No Bluetooth USB detected' && echo '4. FingerPrint:' && lsusb | grep -i 'fingerprint\\|biometric' || echo 'No Fingerprint detected' && echo '5. Printer:' && lpstat -a || echo 'CUPS not configured/installed'"
        self.create_app_row("1. 🔍 Scan Hardware & Status Driver", "lspci", scan_cmd, root=False)

        # 2. VGA NVIDIA
        nv_cmd = ""
        if self.pkg_manager == "apt": nv_cmd = "ubuntu-drivers autoinstall || apt install nvidia-driver-535 -y"
        elif self.pkg_manager == "dnf": nv_cmd = "dnf install akmod-nvidia xorg-x11-drv-nvidia-cuda -y"
        elif self.pkg_manager == "pacman": nv_cmd = "pacman -S nvidia nvidia-utils --noconfirm"
        self.create_app_row("2. Install Driver Graphic (NVIDIA Auto)", "nvidia-smi", nv_cmd)
        
        # 3. MESA AMD
        mesa_cmd = f"{self.pkg_install_cmd} mesa-utils "
        if self.pkg_manager == "apt": mesa_cmd += " libgl1-mesa-dri"
        self.create_app_row("3. Install Driver Graphic (AMD/OS Mesa)", "glxinfo", mesa_cmd)

        # 4. WLAN / WiFi AutoFix
        # Translating the complex wifi fix logic to a one-liner wrapper or calling it from the script
        wifi_cmd = "echo 'Mendeteksi WiFi...' && WIFI=$(lspci -nn | grep -i \"network\\|wireless\" || lsusb | grep -i \"wireless\\|wlan\\|wifi\") && echo \"$WIFI\" && "
        if self.pkg_manager == "apt":
            wifi_cmd += "apt update && apt install -y firmware-linux firmware-linux-nonfree firmware-misc-nonfree wireless-tools && systemctl restart NetworkManager"
        elif self.pkg_manager in ["dnf", "zypper"]:
            wifi_cmd += "dnf install -y linux-firmware wireless-tools && systemctl restart NetworkManager"
        else:
            wifi_cmd += "echo 'Instalasi firmware wifi otomatis hanya untuk APT/DNF base via GUI'"
        self.create_app_row("4. Auto Install & Fix Driver WLAN/WiFi", "iwconfig", wifi_cmd)

        # 5. Bluetooth
        bt_cmd = f"{self.pkg_install_cmd} bluez rfkill "
        if self.pkg_manager == "apt": bt_cmd += "bluetooth bluez-tools"
        bt_cmd += " && systemctl enable bluetooth && systemctl start bluetooth"
        self.create_app_row("5. Install Driver Bluetooth", "bluetoothctl", bt_cmd)

        # 6. Fingerprint
        fp_cmd = f"{self.pkg_install_cmd} fprintd "
        if self.pkg_manager == "apt": fp_cmd += "libpam-fprintd"
        self.create_app_row("6. Install Driver FingerPrint Reader", "fprintd-enroll", fp_cmd)

        # 7. Print / CUPS
        cups_cmd = f"{self.pkg_install_cmd} cups cups-client system-config-printer && systemctl enable --now cups"
        self.create_app_row("7. Install Driver Printer (CUPS)", "lpstat", cups_cmd)
        
        # 8. USB Tools & Network Firmware
        usb_cmd = f"{self.pkg_install_cmd} usbutils "
        if self.pkg_manager == "apt": usb_cmd += f"build-essential dkms linux-headers-$(uname -r) linux-firmware"
        self.create_app_row("8. Install USB Tools & Network FW", "lsusb", usb_cmd)

    def show_repair_frame(self):
        self.clear_content()
        self.header_label.configure(text="Disk Repair & Data Recovery")
        
        self.create_app_row("Smartmontools (Cek HDD/SSD)", "smartctl", f"{self.pkg_install_cmd} smartmontools")
        self.create_app_row("TestDisk (Recover Partisi)", "testdisk", f"{self.pkg_install_cmd} testdisk")
        self.create_app_row("Extundelete (Recover Files)", "extundelete", f"{self.pkg_install_cmd} extundelete")
        
        # Perbaikan Bad Sector fsck
        self.create_app_row("Cek File System (fsck) interact", "fsck", "echo 'Use terminal: sudo fsck -y /dev/sdX'", root=False)

    def show_recovery_frame(self):
        self.clear_content()
        self.header_label.configure(text="Recovery Data Full Fitur")
        self.create_app_row("TestDisk (Recover Partisi Hilang)", "testdisk", f"{self.pkg_install_cmd} testdisk")
        self.create_app_row("PhotoRec (Recover Media/Foto)", "photorec", "echo 'Jalankan sudo photorec di terminal murni'", root=False)
        self.create_app_row("Extundelete (Recover Ext3/4)", "extundelete", f"{self.pkg_install_cmd} extundelete")
        
        lbl = ctk.CTkLabel(self.content_area, text="⚠️ Note: Jalankan perintah recovery di terminal GUI eksternal untuk interaksi.", text_color="yellow", justify="left")
        lbl.grid(column=0, sticky="w", pady=(20, 0), padx=10)

    def show_backup_frame(self):
        self.clear_content()
        self.header_label.configure(text="Backup & Restore")
        
        # Info Direktori
        backup_dir = os.path.join(os.path.dirname(os.path.abspath(__file__)), "br")
        info_label = ctk.CTkLabel(self.content_area, text=f"Folder Backup Default:\n{backup_dir}", text_color="gray", justify="left")
        info_label.grid(column=0, sticky="w", pady=(0, 20), padx=10)

        # Helper Button Backup
        def create_br_row(title, path_target, is_root=False):
            frame = ctk.CTkFrame(self.content_area, fg_color=PANEL_COLOR, corner_radius=8)
            frame.grid(column=0, sticky="ew", pady=5, padx=5)
            frame.grid_columnconfigure(0, weight=1)
            
            label = ctk.CTkLabel(frame, text=title, anchor="w", font=ctk.CTkFont(size=14, weight="bold"))
            label.grid(row=0, column=0, padx=15, pady=10, sticky="w")

            def do_backup():
                b_dir = os.path.join(backup_dir, title.replace(" ", "_").replace("/", "").replace("(", "").replace(")", ""))
                os.makedirs(b_dir, exist_ok=True)
                # Tambahan support jika yg dibackup banyak item (seperti .bashrc .ssh) config
                target_paths = path_target.split(" ")
                b_name = os.path.join(b_dir, "backup.tar.gz")
                cmd = f"tar -czf '{b_name}' "
                parent_dir = os.path.dirname(target_paths[0])
                
                if "*" in path_target or len(target_paths) > 1:
                     cmd += f"-C {parent_dir} {os.path.basename(path_target)}" # rough fallback untuk bash
                else:
                     cmd = f"tar -czf '{b_name}' -C '{os.path.dirname(path_target)}' '{os.path.basename(path_target)}'"
                
                self.run_command_gui(cmd, as_root=is_root)

            def do_restore():
                filepath = filedialog.askopenfilename(initialdir=backup_dir, title="Pilih File Backup (tar.gz)", filetypes=(("Tar Gzip", "*.tar.gz"), ("All Files", "*.*")))
                if filepath:
                    if "*" in path_target or " " in path_target:
                         parent_dir = os.path.dirname(path_target.split(" ")[0])
                    else:
                         parent_dir = os.path.dirname(path_target)
                         
                    cmd = f"tar -xzf '{filepath}' -C '{parent_dir}'"
                    self.run_command_gui(cmd, as_root=is_root)

            btn_rest = ctk.CTkButton(frame, text="Restore", fg_color="#A30000", hover_color="#7A0000", width=100, command=do_restore)
            btn_rest.grid(row=0, column=2, padx=10, pady=10, sticky="e")

            btn_bak = ctk.CTkButton(frame, text="Backup", fg_color=HOVER_COLOR, hover_color="#008020", width=100, command=do_backup)
            btn_bak.grid(row=0, column=1, padx=10, pady=10, sticky="e")

        # 13+ Items for Backup
        create_br_row("Browser - Firefox Profil", os.path.expanduser("~/.mozilla/firefox"))
        create_br_row("Browser - Chrome Config", os.path.expanduser("~/.config/google-chrome"))
        create_br_row("Browser - Brave", os.path.expanduser("~/.config/BraveSoftware/Brave-Browser"))
        create_br_row("Browser - Edge", os.path.expanduser("~/.config/microsoft-edge"))
        create_br_row("Browser - Vivaldi", os.path.expanduser("~/.config/vivaldi"))
        create_br_row("Browser - Chromium", os.path.expanduser("~/.config/chromium"))
        
        create_br_row("WiFi / NetworkManager", "/etc/NetworkManager/system-connections", is_root=True)
        create_br_row("Terminal ENV (.bashrc .profile)", os.path.expanduser("~/.bashrc"))
        create_br_row("Kunci SSH & GPG (.ssh .gnupg)", os.path.expanduser("~/.ssh"))

if __name__ == "__main__":
    app = AppsManagerProGUI()
    app.mainloop()
