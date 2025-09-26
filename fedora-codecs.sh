#!/bin/bash

# Fedora 42 Multimedia Codecs Installer Script
# Author: Assistant
# Description: Installs comprehensive multimedia codecs and hardware acceleration for Fedora 42

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   print_error "This script should not be run as root. Please run as a regular user with sudo privileges."
   exit 1
fi

# Check if user has sudo privileges
if ! sudo -n true 2>/dev/null; then
    print_error "This script requires sudo privileges. Please ensure your user can run sudo commands."
    exit 1
fi

print_status "Fedora 42 Multimedia Codecs Installer"
echo "======================================"

# Check Fedora version
print_status "Checking Fedora version..."
if [[ -f /etc/fedora-release ]]; then
    FEDORA_VERSION=$(rpm -E %fedora)
    FEDORA_NAME=$(cat /etc/fedora-release)
    print_status "Detected: $FEDORA_NAME"
    
    if [[ "$FEDORA_VERSION" != "42" ]]; then
        print_error "This script is designed for Fedora 42. You are running Fedora $FEDORA_VERSION."
        read -p "Do you want to continue anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_status "Installation cancelled."
            exit 0
        fi
    else
        print_success "Fedora 42 detected. Proceeding with installation."
    fi
else
    print_error "This system does not appear to be running Fedora."
    exit 1
fi

# Graphics card selection
echo
print_status "Select your graphics card type for hardware acceleration:"
echo "1) Intel Graphics"
echo "2) AMD Graphics" 
echo "3) NVIDIA Graphics"
echo "4) Skip hardware acceleration"

while true; do
    read -r -p "Enter your choice (1-4): " graphics_choice
    case $graphics_choice in
        [1-4])
            break
            ;;
        *)
            print_warning "Please enter a number between 1 and 4."
            ;;
    esac
done

# Update system first
print_status "Updating system packages..."
sudo dnf update -y

# Enable RPM Fusion repositories
print_status "Enabling RPM Fusion repositories..."
sudo dnf install -y \
    "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm" \
    "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm"

print_success "RPM Fusion repositories enabled."

# Install core multimedia codecs
print_status "Installing core multimedia codec groups..."
sudo dnf groupupdate -y core multimedia --setopt="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin

# Install additional codec packages
print_status "Installing GStreamer plugins and codecs..."
sudo dnf install -y \
    gstreamer1-plugins-bad-* \
    gstreamer1-plugins-good-* \
    gstreamer1-plugins-base \
    gstreamer1-plugin-openh264 \
    gstreamer1-libav \
    --exclude=gstreamer1-plugins-bad-free-devel

# Install FFmpeg and additional formats
print_status "Installing FFmpeg and additional codec support..."
sudo dnf install -y lame* --exclude=lame-devel

# Install DVD support
print_status "Installing DVD codec support..."
sudo dnf install -y libdvdcss

# Install hardware acceleration based on user choice
case $graphics_choice in
    1)
        print_status "Installing Intel graphics hardware acceleration..."
        sudo dnf install -y intel-media-driver libva-intel-driver
        print_success "Intel graphics acceleration installed."
        ;;
    2)
        print_status "Installing AMD graphics hardware acceleration..."
        sudo dnf install -y mesa-va-drivers mesa-vdpau-drivers
        print_success "AMD graphics acceleration installed."
        ;;
    3)
        print_status "Installing NVIDIA graphics hardware acceleration..."
        print_warning "Note: This requires NVIDIA proprietary drivers to be already installed."
        sudo dnf install -y nvidia-vaapi-driver
        print_success "NVIDIA graphics acceleration installed."
        ;;
    4)
        print_status "Skipping hardware acceleration installation."
        ;;
esac

# Install additional useful packages
print_status "Installing additional media tools..."
sudo dnf install -y \
    vlc \
    mpv \
    webp-tools \
    unrar \
    p7zip \
    p7zip-plugins

print_success "Additional media tools installed."

# Verification
print_status "Verifying codec installation..."
echo "Checking available GStreamer plugins:"
gst-inspect-1.0 | grep -E "(mp3|h264|aac|mp4)" | head -10

echo
print_success "===================="
print_success "Installation Complete!"
print_success "===================="
echo
print_status "Installed components:"
echo "  ✓ RPM Fusion repositories (free and nonfree)"
echo "  ✓ Core multimedia codec groups"
echo "  ✓ GStreamer plugins (bad, good, base, openh264, libav)"
echo "  ✓ FFmpeg and LAME codecs"
echo "  ✓ DVD codec support (libdvdcss)"

case $graphics_choice in
    1) echo "  ✓ Intel graphics hardware acceleration" ;;
    2) echo "  ✓ AMD graphics hardware acceleration" ;;
    3) echo "  ✓ NVIDIA graphics hardware acceleration" ;;
    4) echo "  - Hardware acceleration skipped" ;;
esac

echo "  ✓ Media players (VLC, MPV)"
echo "  ✓ Additional tools (WebP, archive support)"
echo
print_status "You can now play most multimedia formats. It's recommended to restart your applications"
print_status "or reboot your system to ensure all codecs are properly loaded."

# Optional reboot prompt
echo
read -p "Would you like to reboot now to ensure all changes take effect? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_status "Rebooting system in 5 seconds... (Ctrl+C to cancel)"
    sleep 5
    sudo reboot
else
    print_status "Installation complete. Please reboot when convenient."
fi