#!/bin/bash
# SIGAP Environment Setup Script

echo "======================================"
echo "  SIGAP Workspace Environment Setup   "
echo "======================================"

# Deteksi OS
OS="$(uname -s)"
case "${OS}" in
    Linux*)     machine=Linux;;
    Darwin*)    machine=Mac;;
    *)          machine="UNKNOWN"
esac

echo "Sistem Terdeteksi: ${machine}"

# 1. arduino-cli (Untuk Kompilasi ESP32)
if ! command -v arduino-cli &> /dev/null; then
    echo "🛠️ arduino-cli tidak ditemukan. Mengunduh dan menginstal..."
    # Mengunduh langsung binary ke /usr/local/bin jika ada akses sudo, atau ke ~/.local/bin
    if [ -w /usr/local/bin ]; then
        curl -fsSL https://raw.githubusercontent.com/arduino/arduino-cli/master/install.sh | BINDIR=/usr/local/bin sh
        echo "✅ arduino-cli berhasil diinstal ke /usr/local/bin."
    else
        mkdir -p $HOME/.local/bin
        curl -fsSL https://raw.githubusercontent.com/arduino/arduino-cli/master/install.sh | BINDIR=$HOME/.local/bin sh
        echo "✅ arduino-cli berhasil diinstal ke ~/.local/bin."
        echo "⚠️ Pastikan untuk menambahkan ~/.local/bin ke dalam PATH Anda (di ~/.bashrc atau ~/.zshrc)."
        export PATH="$HOME/.local/bin:$PATH"
    fi
else
    echo "✅ arduino-cli sudah terinstal."
fi

# 2. Python3 & Pip (Untuk Vision API)
if ! command -v python3 &> /dev/null; then
    echo "❌ python3 tidak ditemukan. Harap instal Python 3."
else
    echo "✅ python3 sudah terinstal."
fi

if ! python3 -c "import venv" &> /dev/null; then
    echo "❌ python3-venv tidak ditemukan. Harap instal module venv (contoh Ubuntu: sudo apt install python3-venv)."
else
    echo "✅ python3 venv module tersedia."
fi

# 3. Node.js & npm (Untuk Dashboard)
if ! command -v npm &> /dev/null; then
    echo "❌ npm tidak ditemukan. Harap instal Node.js."
else
    echo "✅ Node.js (npm) sudah terinstal."
fi

# 4. Flutter (Untuk Mobile App)
if ! command -v flutter &> /dev/null; then
    echo "❌ flutter tidak ditemukan. Harap instal Flutter SDK dari https://docs.flutter.dev/get-started/install"
else
    echo "✅ flutter sudah terinstal."
fi

# 5. Make
if ! command -v make &> /dev/null; then
    echo "❌ make tidak ditemukan. Harap instal build-essential atau make."
else
    echo "✅ make sudah terinstal."
fi

echo "======================================"
echo "Setup environment selesai!"
echo "Jika arduino-cli baru saja diinstal, jalankan perintah berikut sekali lagi:"
echo "    make setup-arduino"
echo "Silakan jalankan 'make help' di direktori root untuk melihat perintah build."
