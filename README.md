# AppsManager.sh

**Aplikasi Manager untuk Instalasi dan Manajemen Aplikasi di Debian/Ubuntu**

---

## 📋 Daftar Isi
- [Deskripsi](#deskripsi)
- [Fitur](#fitur)
- [Persyaratan Sistem](#persyaratan-sistem)
- [Instalasi](#instalasi)
- [Penggunaan](#penggunaan)
- [Kategori Aplikasi](#kategori-aplikasi)
- [Struktur Script](#struktur-script)
- [Troubleshooting](#troubleshooting)
- [Lisensi](#lisensi)

---

## 📖 Deskripsi

**AppsManager.sh** adalah script bash interaktif yang dirancang untuk memudahkan pengguna Debian/Ubuntu dalam mengunduh dan menginstal berbagai aplikasi populer. Script ini menyediakan antarmuka menu yang user-friendly dengan pengecekan status instalasi secara real-time dan dukungan untuk berbagai metode instalasi (APT, Flatpak, Snap, DEB).

**Pembuat:** Mr.exe

---

## ✨ Fitur

- ✅ **Antarmuka Menu Interaktif** - Navigasi mudah dengan menu berbasis terminal
- ✅ **Pengecekan Status Instalasi** - Menampilkan status instalasi setiap aplikasi
- ✅ **Informasi Sistem** - Banner yang menampilkan spesifikasi sistem pengguna
- ✅ **Warna-warni Output** - Menggunakan ANSI color codes untuk tampilan yang lebih menarik
- ✅ **Multi-metode Instalasi** - Mendukung APT, Snap, dan Flatpak
- ✅ **Pembersihan Otomatis** - Membersihkan file sementara setelah instalasi
- ✅ **5 Kategori Aplikasi** - Terorganisir berdasarkan fungsi

---

## 🖥️ Persyaratan Sistem

- **OS:** Debian 10+ atau Ubuntu 18.04+
- **Akses:** Akses sudo/root untuk instalasi
- **Internet:** Koneksi internet aktif untuk download
- **Tools:**
  - `bash` (biasanya sudah terinstal)
  - `wget` (untuk download file)
  - `curl` atau `wget` (untuk request HTTP)

---

## 🚀 Instalasi

### 1. Clone atau Download Script
```bash
cd /home/zora/Videos/Fix/AppsForDebian/
```

### 2. Berikan Izin Eksekusi
```bash
chmod +x AppsManager.sh
```

### 3. Jalankan Script
```bash
./AppsManager.sh
```

### Alternatif: Dengan Bash Directly
```bash
bash AppsManager.sh
```

---

## 📖 Penggunaan

### Menjalankan Script
```bash
./AppsManager.sh
```

### Navigasi Menu
1. Script akan menampilkan **Menu Utama** dengan 5 kategori
2. Pilih nomor kategori yang diinginkan
3. Di setiap sub-menu, pilih aplikasi yang ingin diinstal
4. Script akan secara otomatis mengunduh dan menginstal aplikasi
5. Tekan `5` untuk kembali ke menu utama atau `0` untuk keluar

### Contoh Workflow
```
┌─────────────────────────────────────┐
│   INFORMASI SISTEM ANDA             │
│   Create By: Mr.exe                 │
├─────────────────────────────────────┤
│   User      : user@hostname         │
│   OS        : Ubuntu 22.04 LTS      │
│   Kernel    : 5.15.0-56-generic     │
│   CPU       : Intel Core i7-8700K   │
│   Memory    : 8GB / 16GB            │
└─────────────────────────────────────┘

MENU UTAMA PENGINSTALAN
1. Kebutuhan Internet
2. Office & Produktivitas
3. Multimedia (Video & Audio)
4. Menggambar & Desain
5. Developer Tools
0. Keluar
```

---

## 🗂️ Kategori Aplikasi

### 1. 🌐 Kebutuhan Internet
| No | Aplikasi | Status Check | Metode |
|---|---|---|---|
| 1 | Google Chrome | `google-chrome-stable` | DEB Download |
| 2 | Discord | `discord` | DEB Download |
| 3 | Telegram Desktop | `telegram-desktop` | APT |
| 4 | WhatsApp Desktop (ZapZap) | `zapzap` | Flatpak |

### 2. 📊 Office & Produktivitas
| No | Aplikasi | Status Check | Metode |
|---|---|---|---|
| 1 | LibreOffice | `libreoffice` | APT |
| 2 | WPS Office | `wps-office` | DEB Download |

### 3. 🎬 Multimedia (Video & Audio)
| No | Aplikasi | Status Check | Metode |
|---|---|---|---|
| 1 | VLC Player | `vlc` | APT |
| 2 | OBS Studio | `obs-studio` | APT |
| 3 | Spotify | `spotify` | Snap |

### 4. 🎨 Menggambar & Desain
| No | Aplikasi | Status Check | Metode |
|---|---|---|---|
| 1 | GIMP (Photo Editor) | `gimp` | APT |
| 2 | Krita (Painting) | `krita` | APT |
| 3 | Inkscape (Vector Graphics) | `inkscape` | APT |

### 5. 💻 Developer Tools
| No | Aplikasi | Status Check | Metode |
|---|---|---|---|
| 1 | VS Code | `code` | DEB Download |
| 2 | Flatpak (System) | `flatpak` | APT |
| 3 | Git | `git` | APT |

---

## 🔧 Struktur Script

### Konfigurasi Warna
Script menggunakan ANSI color codes untuk output yang lebih menarik:
```bash
GREEN='\033[0;32m'      # Hijau - Sukses
RED='\033[0;31m'        # Merah - Error/Belum terinstal
BLUE='\033[0;34m'       # Biru - Kategori
YELLOW='\033[1;33m'     # Kuning - Proses
CYAN='\033[0;36m'       # Cyan - Info
MAGENTA='\033[0;35m'    # Magenta - Border
NC='\033[0m'            # No Color - Reset
```

### Fungsi-Fungsi Utama

#### `show_banner()`
Menampilkan informasi sistem pengguna:
- Username dan Hostname
- OS dan Versi Kernel
- Spesifikasi CPU dan Memory

#### `check_status()`
Mengecek status instalasi aplikasi:
- Mencari command di PATH
- Mengecek package di dpkg database
- Return: `[Terinstall]` atau `[Belum Terinstall]`

#### `download_and_install()`
Mengunduh dan menginstal file DEB:
1. Download file DEB ke `/tmp/`
2. Instalasi dengan `sudo apt install`
3. Membersihkan file sementara
4. Tampilkan pesan sukses

#### `menu_*()` Functions
Sub-menu untuk setiap kategori dengan loop interaktif:
- `menu_internet()` - Internet & Komunikasi
- `menu_office()` - Office & Produktivitas
- `menu_multimedia()` - Multimedia
- `menu_menggambar()` - Desain & Seni
- `menu_developer()` - Developer Tools

### Main Loop
Loop utama yang menampilkan menu dan merespons input pengguna.

---

## 🐛 Troubleshooting

### Masalah: Permission Denied
**Solusi:** Berikan izin eksekusi ke script
```bash
chmod +x AppsManager.sh
```

### Masalah: wget: command not found
**Solusi:** Install wget
```bash
sudo apt update && sudo apt install wget -y
```

### Masalah: Instalasi Gagal
**Solusi:** Update package list dan coba lagi
```bash
sudo apt update
```

### Masalah: Flatpak/Snap tidak tersedia
**Solusi:** Install terlebih dahulu
```bash
# Untuk Flatpak
sudo apt install flatpak -y

# Untuk Snap
sudo apt install snapd -y
```

### Masalah: Download Link Tidak Valid
**Catatan:** Link download mungkin berubah seiring waktu. Update URL jika diperlukan:
```bash
# Edit script dengan text editor
nano AppsManager.sh

# Ubah URL yang bermasalah pada fungsi download_and_install
```

### Masalah: Aplikasi Sudah Terinstall Tapi Status Menunjukkan "Belum Terinstall"
**Solusi:** Periksa nama command atau package
```bash
# Cari nama package yang tepat
apt search nama_aplikasi

# Atau gunakan dpkg
dpkg -s nama_package
```

---

## 💡 Tips & Trik

1. **Instalasi Multiple Aplikasi**
   - Anda dapat menginstal beberapa aplikasi sekaligus dengan menjalankan script berkali-kali

2. **Custom URL**
   - Edit URL download di script jika ingin menggunakan mirror atau versi berbeda

3. **Background Installation**
   - Untuk instalasi di background, gunakan:
   ```bash
   ./AppsManager.sh &
   ```

4. **Log Output**
   - Simpan output ke file:
   ```bash
   ./AppsManager.sh > installation.log 2>&1
   ```

---

## 📝 Lisensi

Script ini dibuat oleh **Mr.exe** dan tersedia untuk penggunaan bebas. Silakan modifikasi sesuai kebutuhan Anda.

---

## 🤝 Kontribusi

Untuk melaporkan bug atau memberikan saran:
1. Buat issue dengan deskripsi detail
2. Sertakan output error jika ada
3. Jelaskan langkah reproduksi

---

## 📞 Dukungan

Jika mengalami masalah:
1. Baca bagian **Troubleshooting** di atas
2. Periksa koneksi internet
3. Pastikan akses sudo tersedia
4. Coba update system: `sudo apt update && sudo apt upgrade -y`

---

**Terakhir Diupdate:** 15 Januari 2026

**Status:** ✅ Aktif & Fungsional
