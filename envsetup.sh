#!/bin/bash
# SIGAP Fully Automatic Environment Setup Script

echo "======================================"
echo "  SIGAP Fully Automatic Setup        "
echo "======================================"

# 1. Deteksi OS dan Distribusi
OS="$(uname -s)"
DISTRO="Unknown"
if [ "${OS}" = "Linux" ]; then
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        DISTRO=$ID
    fi
fi
echo "📍 Sistem Terdeteksi: ${OS} (${DISTRO})"

# Fungsi pembantu untuk eksekusi perintah dengan pengecekan
run_cmd() {
    echo "⚙️  Running: $1"
    eval $1
    if [ $? -ne 0 ]; then
        echo "❌ Gagal: $1"
        return 1
    fi
    return 0
}

# Fungsi instalasi paket sistem
install_sys_pkg() {
    local pkgs=$@
    case "${DISTRO}" in
        ubuntu|debian|kali|raspbian)
            sudo apt update && sudo apt install -y $pkgs ;;
        arch|manjaro)
            sudo pacman -Sy --noconfirm $pkgs ;;
        fedora)
            sudo dnf install -y $pkgs ;;
        *)
            echo "⚠️  Distro ${DISTRO} tidak didukung otomatis. Silakan instal: $pkgs"
            return 1 ;;
    esac
}

# 2. Pastikan Alat Dasar (git, curl, wget)
echo "🔍 Mengecek alat dasar..."
for tool in git curl wget; do
    if ! command -v $tool &> /dev/null; then
        install_sys_pkg $tool
    fi
done

# 3. Pastikan Snapd (untuk Flutter jika distro tidak punya package native yang mudah)
if ! command -v snap &> /dev/null; then
    echo "🛠️  Menginstal snapd..."
    case "${DISTRO}" in
        arch|manjaro)
            # Arch butuh manual AUR untuk snapd jika tidak ada, 
            # tapi kita coba gunakan pacman jika distro turunan menyediakannya
            sudo pacman -Sy --noconfirm snapd || echo "⚠️ Gagal instal snapd via pacman."
            sudo systemctl enable --now snapd.socket
            [ ! -L /var/lib/snapd/snap ] && sudo ln -s /var/lib/snapd/snap /snap
            ;;
        ubuntu|debian|kali)
            install_sys_pkg snapd ;;
        fedora)
            install_sys_pkg snapd
            sudo ln -s /var/lib/snapd/snap /snap ;;
    esac
fi

# 4. Instalasi Toolchain Utama
echo "🚀 Menginstal main toolchain..."

# Make & Build Tools
if ! command -v make &> /dev/null; then
    case "${DISTRO}" in
        arch|manjaro) install_sys_pkg base-devel ;;
        ubuntu|debian|kali) install_sys_pkg build-essential ;;
        fedora) install_sys_pkg "make automake gcc gcc-c++" ;;
        *) install_sys_pkg make ;;
    esac
fi

# Arduino CLI
if ! command -v arduino-cli &> /dev/null; then
    echo "📥 Mengunduh arduino-cli..."
    curl -fsSL https://raw.githubusercontent.com/arduino/arduino-cli/master/install.sh | BINDIR=$HOME/.local/bin sh
    export PATH="$HOME/.local/bin:$PATH"
    # Tambahkan ke bashrc jika belum ada
    grep -q 'export PATH="$HOME/.local/bin:$PATH"' ~/.bashrc || echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
fi

# Python 3
if ! command -v python3 &> /dev/null; then
    install_sys_pkg python3
fi
if [[ "${DISTRO}" == "ubuntu" || "${DISTRO}" == "debian" ]]; then
    python3 -c "import venv" &> /dev/null || install_sys_pkg python3-venv
fi

# Node.js & NPM
if ! command -v npm &> /dev/null; then
    case "${DISTRO}" in
        arch|manjaro) install_sys_pkg "nodejs npm" ;;
        *) install_sys_pkg "nodejs npm" ;;
    esac
fi

# Flutter
if ! command -v flutter &> /dev/null; then
    if command -v snap &> /dev/null; then
        echo "📥 Menginstal flutter via snap..."
        sudo snap install flutter --classic
        flutter sdk-path
    else
        echo "⚠️  Snap tidak ditemukan, silakan instal Flutter SDK manual."
    fi
fi

# 5. Konfigurasi Ekosistem SIGAP (Otomatis Penuh)
echo "🌟 Menyiapkan Ekosistem SIGAP..."

# Arduino Configuration
if command -v arduino-cli &> /dev/null; then
    make -f build/Makefile setup-arduino
fi

# Vision API (Python venv & deps)
if command -v python3 &> /dev/null; then
    make -f build/Makefile install-vision
fi

# Dashboard (Node modules)
if command -v npm &> /dev/null; then
    make -f build/Makefile install-dashboard
fi

# Mobile (Flutter pub get)
if command -v flutter &> /dev/null; then
    make -f build/Makefile install-mobile
fi

echo "======================================"
echo "✅ SEMUA TOOLS & DEPENDENSI TELAH SIAP!"
echo "======================================"
echo "Anda sekarang dapat menggunakan perintah berikut:"
echo " - make help      : Untuk melihat daftar perintah"
echo ""
echo "Catatan: Jika ini pertama kali instalasi, mungkin perlu restart terminal"
echo "atau jalankan 'source ~/.bashrc' agar PATH diperbarui."
