#!/bin/bash

# Microsoft Development Stack Setup Script for Fedora
# This script installs or updates the complete Microsoft development environment
# Created for Fedora 42 KDE in VMware Workstation
#
# Usage: sudo ./ms-dev-setup-script.sh (for unattended installation)
#    or: ./ms-dev-setup-script.sh (will prompt for password when needed)

set -e  # Exit on any error

# Check if running with proper privileges
check_privileges() {
    if [ "$EUID" -ne 0 ]; then
        echo "Error: This script must be run as root or with sudo"
        echo "Usage: sudo $0"
        exit 1
    fi
}

# Validate system before starting
validate_system() {
    # Check if running on Fedora
    if ! grep -q "Fedora" /etc/os-release; then
        echo "Error: This script is designed for Fedora Linux"
        exit 1
    fi
    
    # Check internet connectivity
    if ! ping -c 1 packages.microsoft.com >/dev/null 2>&1; then
        echo "Error: Cannot reach Microsoft package repositories"
        exit 1
    fi
}

# Get Fedora version dynamically
get_fedora_version() {
    grep -oP 'VERSION_ID=\K\d+' /etc/os-release || echo "42"
}

# Backup function for modified files
backup_file() {
    if [ -f "$1" ]; then
        cp "$1" "$1.backup.$(date +%s)"
    fi
}

# Logging function
log_action() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "/var/log/ms-dev-setup.log"
}

# Check privileges and validate system
check_privileges
validate_system

# Get the actual user (in case script is run with sudo)
if [ "$SUDO_USER" ]; then
    ACTUAL_USER="$SUDO_USER"
    ACTUAL_HOME="/home/$SUDO_USER"
else
    ACTUAL_USER="$USER"
    ACTUAL_HOME="$HOME"
fi

FEDORA_VERSION=$(get_fedora_version)

log_action "Microsoft Development Stack Setup started by user: $ACTUAL_USER"
log_action "Detected Fedora version: $FEDORA_VERSION"

echo "=========================================="
echo "Microsoft Development Stack Setup"
echo "=========================================="
echo ""

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check if a package is installed via dnf
package_installed() {
    if ! dnf list installed "$1" &>/dev/null; then
        return 1
    fi
    return 0
}

# Function to add repository safely
add_microsoft_repo() {
    local repo_name="$1"
    local repo_file="$2"
    local repo_content="$3"
    
    if [ ! -f "/etc/yum.repos.d/$repo_file" ]; then
        print_installing "$repo_name repository"
        backup_file "/etc/yum.repos.d/$repo_file"
        echo -e "$repo_content" > "/etc/yum.repos.d/$repo_file"
        chmod 644 "/etc/yum.repos.d/$repo_file"
    else
        print_status "$repo_name repository already configured"
    fi
}

# Function to print status
print_status() {
    echo "✓ $1"
}

print_installing() {
    echo "→ Installing $1..."
}

print_updating() {
    echo "→ Updating $1..."
}

echo "Step 1: System Updates"
echo "======================"
log_action "Starting system updates"
print_updating "system packages"
dnf update -y

print_status "firmware update skipped (not needed in VMs)"

print_status "System updated"
log_action "System updates completed"
echo ""

echo "Step 2: Essential Development Tools"
echo "==================================="
ESSENTIAL_TOOLS="git nodejs npm python3-pip htop iotop sysstat net-tools nethogs"

for tool in $ESSENTIAL_TOOLS; do
    if ! package_installed "$tool"; then
        print_installing "$tool"
        dnf install -y "$tool"
    else
        print_status "$tool already installed"
    fi
done

# Install mesa-utils separately (different package name on some systems)
if ! command_exists glxinfo; then
    print_installing "mesa-utils (OpenGL utilities)"
    dnf install -y glx-utils || dnf install -y mesa-utils || echo "  (OpenGL utilities not available - this is optional)"
else
    print_status "mesa-utils already installed"
fi

# Install/update Podman (container development)
if ! command_exists podman; then
    print_installing "podman"
    dnf install -y podman
else
    print_status "podman already installed"
fi

# Enable Podman socket for development (as actual user, not root)
if ! runuser -l "$ACTUAL_USER" -c 'systemctl --user is-enabled podman.socket' >/dev/null 2>&1; then
    print_installing "podman socket configuration"
    # Skip podman socket configuration when running as root - user can do this later
    echo "  (Podman socket configuration skipped - run 'systemctl --user enable --now podman.socket' as user after login)"
else
    print_status "podman socket already configured"
fi
echo ""

echo "Step 3: Microsoft Repositories and Keys"
echo "======================================="
# Import Microsoft GPG key
if ! rpm -q gpg-pubkey-eb3e94ad >/dev/null 2>&1; then
    print_installing "Microsoft GPG key"
    rpm --import https://packages.microsoft.com/keys/microsoft.asc
else
    print_status "Microsoft GPG key already imported"
fi

# Add VS Code repository
VS_CODE_REPO="[code]
name=Visual Studio Code
baseurl=https://packages.microsoft.com/yumrepos/vscode
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc"

add_microsoft_repo "VS Code" "vscode.repo" "$VS_CODE_REPO"

# Add Microsoft Edge repository
EDGE_REPO="[microsoft-edge]
name=Microsoft Edge
baseurl=https://packages.microsoft.com/yumrepos/edge
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc"

add_microsoft_repo "Microsoft Edge" "microsoft-edge.repo" "$EDGE_REPO"

# Add .NET repository with dynamic Fedora version
if [ ! -f /etc/yum.repos.d/microsoft-prod.repo ]; then
    print_installing ".NET repository"
    DOTNET_REPO_URL="https://packages.microsoft.com/config/fedora/${FEDORA_VERSION}/prod.repo"
    if wget -q -O /tmp/microsoft-prod.repo "$DOTNET_REPO_URL"; then
        # Validate the file contains expected content
        if grep -q "microsoft" /tmp/microsoft-prod.repo; then
            backup_file "/etc/yum.repos.d/microsoft-prod.repo"
            mv /tmp/microsoft-prod.repo /etc/yum.repos.d/
            chmod 644 /etc/yum.repos.d/microsoft-prod.repo
        else
            echo "Error: Downloaded repository file appears invalid"
            rm -f /tmp/microsoft-prod.repo
            exit 1
        fi
    else
        echo "Error: Failed to download .NET repository configuration"
        exit 1
    fi
else
    print_status ".NET repository already configured"
fi

# Update package cache after adding repositories
print_updating "package cache"
dnf check-update -y || true
echo ""

echo "Step 4: Microsoft Applications"
echo "=============================="
# Install/update VS Code
if ! command_exists code; then
    print_installing "Visual Studio Code"
    dnf install -y code
else
    print_updating "Visual Studio Code"
    dnf update -y code || print_status "VS Code already up to date"
fi

# Install/update Microsoft Edge
if ! command_exists microsoft-edge; then
    print_installing "Microsoft Edge"
    dnf install -y microsoft-edge-stable
else
    print_updating "Microsoft Edge"
    dnf update -y microsoft-edge-stable || print_status "Microsoft Edge already up to date"
fi

# Install/update .NET 9 SDK
if ! command_exists dotnet || ! dotnet --version | grep -q "^9\."; then
    print_installing ".NET 9 SDK"
    dnf install -y dotnet-sdk-9.0
else
    print_updating ".NET 9 SDK"
    dnf update -y dotnet-sdk-9.0 || print_status ".NET 9 SDK already up to date"
fi
echo ""

echo ""

echo "Step 5: Azure Development Tools"
echo "==============================="
# Install Azure CLI if not present
if ! command_exists az; then
    print_installing "Azure CLI"
    dnf install -y azure-cli || echo "  (Azure CLI installation failed - may not be available for this Fedora version)"
else
    print_updating "Azure CLI"
    dnf update -y azure-cli || print_status "Azure CLI already up to date"
fi

# Note: Azure Functions Core Tools can be installed via npm if needed
if command_exists npm; then
    if ! npm list -g azure-functions-core-tools >/dev/null 2>&1; then
        print_installing "Azure Functions Core Tools (optional)"
        # Try the current package name first, fall back to legacy name
        if ! runuser -l "$ACTUAL_USER" -c 'npm install -g azure-functions-core-tools@4 --unsafe-perm true' 2>/dev/null; then
            if ! runuser -l "$ACTUAL_USER" -c 'npm install -g @azure/functions-core-tools@4 --unsafe-perm true' 2>/dev/null; then
                echo "  (Azure Functions Core Tools installation skipped - package not found. Install manually if needed)"
            fi
        fi
    else
        print_status "Azure Functions Core Tools already installed"
    fi
fi
echo ""

echo "Step 6: Power Platform CLI"
echo "=========================="
# Install/update Power Platform CLI
if ! runuser -l "$ACTUAL_USER" -c 'command -v pac' >/dev/null 2>&1; then
    print_installing "Power Platform CLI"
    # Skip Power Platform CLI installation when running as root - user can do this later
    echo "  (Power Platform CLI installation skipped - run 'dotnet tool install --global Microsoft.PowerApps.CLI.Tool' as user after login)"
else
    print_status "Power Platform CLI already installed"
fi

# Ensure .NET tools are in PATH
if ! runuser -l "$ACTUAL_USER" -c 'test -f ~/.bashrc && grep -q "/.dotnet/tools" ~/.bashrc' >/dev/null 2>&1; then
    print_installing "PATH configuration for .NET tools"
    runuser -l "$ACTUAL_USER" -c 'echo "export PATH=\"\$PATH:\$HOME/.dotnet/tools\"" >> ~/.bashrc'
else
    print_status "PATH already configured for .NET tools"
fi
echo ""

echo "Step 7: System Configuration"
echo "============================"
# Set Microsoft Edge as default browser
if command_exists microsoft-edge; then
    print_installing "default browser configuration"
    # Skip default browser setting when running as root - user can do this later
    echo "  (Default browser configuration skipped - user can set Edge as default in Settings)"
    print_status "Microsoft Edge available for configuration"
fi

# Configure HTTPS development certificate
if command_exists dotnet; then
    print_installing "HTTPS development certificate"
    # Skip certificate configuration when running as root - user can do this later
    echo "  (HTTPS certificate configuration skipped - run 'dotnet dev-certs https --trust' as user after login)"
    print_status "HTTPS certificate available for configuration"
fi

# Add useful aliases
if ! runuser -l "$ACTUAL_USER" -c 'grep -q "alias docker=podman" ~/.bashrc'; then
    print_installing "development aliases"
    runuser -l "$ACTUAL_USER" -c 'echo "alias docker=podman" >> ~/.bashrc'
    runuser -l "$ACTUAL_USER" -c 'echo "alias sysmon=\"htop\"" >> ~/.bashrc'
    runuser -l "$ACTUAL_USER" -c 'echo "alias diskmon=\"iostat -x 1\"" >> ~/.bashrc'
    runuser -l "$ACTUAL_USER" -c 'echo "alias netmon=\"nethogs\"" >> ~/.bashrc'
else
    print_status "development aliases already configured"
fi

# Clean package cache
print_status "cleaning package cache"
dnf clean all >/dev/null
echo ""

echo "Step 8: VMware Tools Verification"
echo "================================="
if systemctl is-active --quiet vmtoolsd; then
    print_status "VMware Tools service running"
else
    echo "⚠ VMware Tools not running - checking installation"
    if ! package_installed "open-vm-tools"; then
        print_installing "VMware Tools"
        dnf install -y open-vm-tools open-vm-tools-desktop
        systemctl enable --now vmtoolsd
    else
        systemctl start vmtoolsd || echo "  (Could not start VMware Tools service)"
    fi
fi
echo ""

echo "=========================================="
echo "INSTALLATION COMPLETE!"
echo "=========================================="
echo ""
echo "Installed Software Versions:"
echo "============================="

# System Info
echo "Operating System: $(cat /etc/fedora-release 2>/dev/null || echo 'Unknown')"
echo "Kernel: $(uname -r)"
echo ""

# Development Tools
echo "Development Tools:"
echo "------------------"
if command_exists git; then
    GIT_VERSION=$(git --version 2>/dev/null | cut -d' ' -f3 || echo "Unknown")
    echo "Git: $GIT_VERSION"
fi

if command_exists node; then
    NODE_VERSION=$(node --version 2>/dev/null || echo "Unknown")
    echo "Node.js: $NODE_VERSION"
fi

if command_exists npm; then
    NPM_VERSION=$(npm --version 2>/dev/null || echo "Unknown")
    echo "npm: $NPM_VERSION"
fi

if command_exists python3; then
    PYTHON_VERSION=$(python3 --version 2>/dev/null | cut -d' ' -f2 || echo "Unknown")
    echo "Python: $PYTHON_VERSION"
fi

if command_exists podman; then
    PODMAN_VERSION=$(podman --version 2>/dev/null | cut -d' ' -f3 || echo "Unknown")
    echo "Podman: $PODMAN_VERSION"
fi
echo ""

# Microsoft Stack
echo "Microsoft Development Stack:"
echo "----------------------------"
if command_exists code; then
    VS_CODE_VERSION=$(code --version 2>/dev/null | head -1 2>/dev/null || echo "installed")
    if [ -z "$VS_CODE_VERSION" ] || [ "$VS_CODE_VERSION" = "installed" ]; then
        # Try alternative method to get version
        VS_CODE_VERSION=$(code --help 2>/dev/null | grep -i "visual studio code" | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1 2>/dev/null || echo "installed")
    fi
    echo "VS Code: $VS_CODE_VERSION"
fi

if command_exists microsoft-edge; then
    EDGE_VERSION=$(microsoft-edge --version 2>/dev/null | cut -d' ' -f3 || echo "Unknown")
    echo "Microsoft Edge: $EDGE_VERSION"
fi

if command_exists dotnet; then
    DOTNET_VERSION=$(dotnet --version 2>/dev/null || echo "Unknown")
    echo ".NET SDK: $DOTNET_VERSION"
fi

if runuser -l "$ACTUAL_USER" -c 'command -v pac' >/dev/null 2>&1; then
    PAC_VERSION=$(runuser -l "$ACTUAL_USER" -c 'pac help 2>&1 | grep -E "^Version:" | cut -d" " -f2' 2>/dev/null || echo "Unknown")
    echo "Power Platform CLI: $PAC_VERSION"
fi
echo ""

# Performance Tools
echo "Performance & Monitoring Tools:"
echo "-------------------------------"
if command_exists htop; then
    HTOP_VERSION=$(htop --version 2>&1 | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1 2>/dev/null || echo "installed")
    echo "htop: $HTOP_VERSION"
fi

if command_exists iostat; then
    IOSTAT_VERSION=$(iostat -V 2>&1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1 2>/dev/null || echo "installed")
    echo "iostat: $IOSTAT_VERSION"
fi

if command_exists nethogs; then
    echo "nethogs: installed"
fi
echo ""

# System Resources
echo "System Resources:"
echo "-----------------"
echo "CPU: $(lscpu | grep 'Model name:' | cut -d':' -f2 | xargs)"
echo "CPU Cores: $(nproc)"
echo "Total RAM: $(free -h | grep '^Mem:' | awk '{print $2}')"
echo "Available RAM: $(free -h | grep '^Mem:' | awk '{print $7}')"
echo "Disk Space: $(df -h / | tail -1 | awk '{print $4}') available on /"
echo ""

# VMware Status
echo "VMware Integration:"
echo "-------------------"
if systemctl is-active --quiet vmtoolsd; then
    echo "VMware Tools: Active"
    if command_exists vmware-toolbox-cmd; then
        echo "Guest API: $(vmware-toolbox-cmd stat balloon 2>/dev/null || echo 'Not available')"
        echo "CPU Speed: $(vmware-toolbox-cmd stat speed 2>/dev/null || echo 'Not available')"
    fi
else
    echo "VMware Tools: Not active"
fi

if lspci | grep -q "VMware SVGA"; then
    echo "3D Acceleration: Enabled (SVGA3D detected)"
else
    echo "3D Acceleration: Unknown"
fi
echo ""

echo "=========================================="
echo "Setup complete! Please restart your terminal"
echo "or run 'source ~/.bashrc' to load new aliases."
echo ""
echo "To get started:"
echo "- Open VS Code: code"
echo "- Launch Microsoft Edge: microsoft-edge"
echo "- Create .NET project: dotnet new console"
echo ""
echo "OPTIONAL: Install Azure Functions Core Tools manually if needed:"
echo "npm install -g azure-functions-core-tools@4"
echo ""

# Only show post-install commands if they're actually needed
NEEDS_SETUP=""
if ! runuser -l "$ACTUAL_USER" -c 'systemctl --user is-enabled podman.socket' >/dev/null 2>&1; then
    NEEDS_SETUP="$NEEDS_SETUP\nsystemctl --user enable --now podman.socket"
fi
if ! runuser -l "$ACTUAL_USER" -c 'command -v pac' >/dev/null 2>&1; then
    NEEDS_SETUP="$NEEDS_SETUP\ndotnet tool install --global Microsoft.PowerApps.CLI.Tool"
fi
if ! runuser -l "$ACTUAL_USER" -c 'dotnet dev-certs https --check' >/dev/null 2>&1; then
    NEEDS_SETUP="$NEEDS_SETUP\ndotnet dev-certs https --trust"
fi

if [ -n "$NEEDS_SETUP" ]; then
    echo "IMPORTANT: Complete setup by running these as your user (not root):"
    echo "----------------------------------------"
    echo "1. First, check if you're still in root mode:"
    echo "   Look at your prompt - if it shows # you're root, if it shows $ you're a regular user"
    echo ""
    echo "2. If you see # (root prompt):"
    echo "   Type: exit"
    echo "   (This will return you to regular user mode)"
    echo ""
    echo "3. If you see $ (user prompt) OR if 'exit' closed your terminal:"
    echo "   You're already a regular user! Open a new terminal and run:"
    echo -e "$NEEDS_SETUP"
    echo ""
    echo "4. To confirm you're the right user, type: whoami"
    echo "   (Should show: $ACTUAL_USER)"
    echo "----------------------------------------"
    echo ""
fi

echo "Note: The VS Code version warning above is harmless and can be ignored."
echo "=========================================="
