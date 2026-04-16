#!/bin/bash
# SIGAP Environment Setup Script

echo "======================================"
echo "  SIGAP Workspace Environment Setup   "
echo "======================================"

# Deteksi OS dan Distribusi
OS="$(uname -s)"
DISTRO="Unknown"

if [ "${OS}" = "Linux" ]; then
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        DISTRO=$ID
    fi
fi

echo "Sistem Terdeteksi: ${OS} (${DISTRO})"

# Fungsi untuk instalasi paket berdasarkan distro
install_package() {
    local package=$1
    echo "🛠️ Menginstal ${package}..."
    case "${DISTRO}" in
        ubuntu|debian|kali|raspbian)
            sudo apt update && sudo apt install -y $package
            ;;
        arch|manjaro)
            sudo pacman -Sy --noconfirm $package
            ;;
        fedora)
            sudo dnf install -y $package
            ;;
        *)
            echo "⚠️ Distribusi ${DISTRO} tidak didukung otomatis. Harap instal ${package} secara manual."
            return 1
            ;;
    esac
}

# 1. Make
if ! command -v make &> /dev/null; then
    case "${DISTRO}" in
        arch|manjaro) install_package "base-devel" ;;
        ubuntu|debian|kali) install_package "build-essential" ;;
        fedora) install_package "make automake gcc gcc-c++" ;;
        *) install_package "make" ;;
    esac
else
    echo "✅ make sudah terinstal."
fi

# 2. arduino-cli
if ! command -v arduino-cli &> /dev/null; then
    echo "🛠️ arduino-cli tidak ditemukan. Mengunduh dan menginstal..."
    if [ -w /usr/local/bin ]; then
        curl -fsSL https://raw.githubusercontent.com/arduino/arduino-cli/master/install.sh | BINDIR=/usr/local/bin sh
    else
        mkdir -p $HOME/.local/bin
        curl -fsSL https://raw.githubusercontent.com/arduino/arduino-cli/master/install.sh | BINDIR=$HOME/.local/bin sh
        export PATH="$HOME/.local/bin:$PATH"
    fi
else
    echo "✅ arduino-cli sudah terinstal."
fi

# Setup ESP32 Core & Libraries
if command -v arduino-cli &> /dev/null; then
    echo "🛠️ Menyiapkan ESP32 core dan libraries..."
    make -f build/Makefile setup-arduino
fi

# 3. Python3
if ! command -v python3 &> /dev/null; then
    install_package "python3"
else
    echo "✅ python3 sudah terinstal."
fi

# Python venv (khusus Debian/Ubuntu perlu paket terpisah)
if [[ "${DISTRO}" == "ubuntu" || "${DISTRO}" == "debian" ]]; then
    if ! python3 -c "import venv" &> /dev/null; then
        install_package "python3-venv"
    fi
fi

echo "🛠️ Menyiapkan virtual environment Vision API..."
make -f build/Makefile install-vision

# 4. Node.js & npm
if ! command -v npm &> /dev/null; then
    case "${DISTRO}" in
        arch|manjaro) install_package "nodejs npm" ;;
        *) install_package "nodejs npm" ;;
    esac
else
    echo "✅ Node.js (npm) sudah terinstal."
fi

echo "🛠️ Menginstal dependensi Dashboard..."
make -f build/Makefile install-dashboard

# 5. Flutter
if ! command -v flutter &> /dev/null; then
    echo "🛠️ flutter tidak ditemukan."
    case "${DISTRO}" in
        arch|manjaro)
            echo "💡 Di Arch Linux, disarankan menginstal flutter dari AUR (misal: yay -S flutter)."
            echo "Mencoba menginstal via snap sebagai alternatif..."
            ;;
    esac
    
    if command -v snap &> /dev/null; then
        sudo snap install flutter --classic
        flutter sdk-path
    else
        echo "⚠️ snap tidak ditemukan. Harap instal Flutter SDK secara manual."
    fi
else
    echo "✅ flutter sudah terinstal."
fi

if command -v flutter &> /dev/null; then
    echo "🛠️ Menyiapkan dependensi Mobile..."
    make -f build/Makefile install-mobile
fi

echo "======================================"
echo "Setup environment dan instalasi dependensi selesai!"
echo "Silakan jalankan 'make help' di direktori root untuk melihat perintah build."
