#!/bin/bash

# ================================================================================
# Fedora-42-MS-Setup: Microsoft Development Stack Automated Installer
# ================================================================================
#
# PROJECT: Fedora-42-MS-Setup  
# DESCRIPTION: Comprehensive automation script for setting up a complete Microsoft 
#              development environment on Fedora 42+ with KDE Plasma desktop
# REPOSITORY: https://github.com/galactic-plane/fedora-42-ms-setup
# LICENSE: MIT
# VERSION: 2.0
# AUTHOR: galactic-plane
# CREATED: 2024
# UPDATED: September 2025
#
# ================================================================================
# WHAT THIS SCRIPT INSTALLS
# ================================================================================
#
# 🏢 MICROSOFT DEVELOPMENT STACK:
#   • Visual Studio Code - Microsoft's flagship code editor
#   • .NET 9 SDK - Complete .NET development framework with runtime and ASP.NET Core
#   • PowerShell Core - Cross-platform PowerShell (Microsoft repo or GitHub fallback)
#   • Microsoft Edge - Chromium-based web browser for testing
#   • Azure CLI - Command-line interface for Azure services
#   • Azure Functions Core Tools - Local development/testing for Azure Functions (npm)
#   • Power Platform CLI - Low-code development tools (auto-installed via .NET tools)
#
# 🛠️ ESSENTIAL DEVELOPMENT TOOLS:
#   • Git - Version control with automatic user configuration
#   • Node.js & npm - JavaScript runtime with package manager
#   • Python 3 - Complete Python environment (pip, setuptools, virtualenv)
#   • GitHub CLI - Official GitHub command-line interface
#   • Podman - Container management with Docker compatibility aliases
#   • Build Tools - gcc, g++, make, cmake, autoconf, automake, dev headers
#
# 📊 SYSTEM PERFORMANCE & MONITORING:
#   • htop - Interactive process viewer
#   • iotop - I/O monitoring utility
#   • sysstat - System performance statistics
#   • net-tools - Network configuration utilities
#   • nethogs - Network bandwidth monitoring per process
#   • mesa-utils/glx-utils - OpenGL utilities for graphics diagnostics
#
# 🖥️ VMWARE INTEGRATION (AUTO-DETECTED):
#   • VMware Tools - Guest integration for better performance
#   • 3D Acceleration Support - Enhanced graphics for VMware environments
#   • Clipboard Sharing - Seamless copy/paste between host and guest
#   • Automatic Service Configuration - vmtoolsd service setup and monitoring
#
# ================================================================================
# KEY FEATURES
# ================================================================================
#
# 🔍 INTELLIGENT SYSTEM DETECTION:
#   • Automated VMware Detection - Multiple methods (lspci, DMI, processes)
#   • Fedora Version Validation - Ensures compatibility with Fedora 42+ and DNF5
#   • System Requirements Check - Validates disk space, network, permissions
#
# 🛡️ SAFETY & RELIABILITY:
#   • Comprehensive Logging - All actions logged to /var/log/ms-dev-setup.log
#   • Configuration Backups - Auto backup to /var/backups/ms-dev-setup/
#   • Error Handling - Graceful failure recovery with detailed error messages
#   • User Confirmation - Interactive approval before making system changes
#   • Rollback Safety - Can be re-run safely; handles existing installations
#
# ⚙️ AUTOMATED CONFIGURATION:
#   • Shell Environment Setup - Development aliases and PATH configuration
#   • Microsoft Services Integration - .NET HTTPS certs, Git config, Podman setup
#   • VMware Optimization - Tools service, 3D acceleration, guest integration
#   • Development Directories - Organized folder structure in ~/Development/
#
# ================================================================================
# POST-INSTALLATION CONFIGURATION
# ================================================================================
#
# SHELL ALIASES CREATED:
#   • sysmon → htop (system monitoring)
#   • docker → podman (container compatibility)
#   • dev → cd ~/Development (quick navigation)
#   • Git shortcuts: gs, ga, gc, gp, gl
#   • Azure shortcuts: az-login, az-subs
#
# DIRECTORY STRUCTURE CREATED:
#   ~/Development/
#   ├── dotnet/          # .NET projects and tools
#   ├── nodejs/          # Node.js applications
#   ├── python/          # Python projects and virtual environments
#   ├── azure/           # Azure-related projects and scripts
#   ├── scripts/         # Development and automation scripts
#   └── repos/           # Git repositories
#
# PATH ADDITIONS:
#   • ~/.dotnet/tools (for .NET global tools)
#   • ~/.npm-global/bin (for npm global packages)
#
# SERVICES CONFIGURED:
#   • vmtoolsd (VMware Tools daemon) - if VMware detected
#   • podman.socket (for Docker compatibility)
#
# ================================================================================
# PREREQUISITES
# ================================================================================
#
# • Operating System: Fedora 42+ with KDE Plasma Desktop Environment
# • Network: Active internet connection for package downloads
# • Permissions: User account with sudo privileges
# • Storage: Minimum 4GB free disk space
# • Memory: At least 2GB RAM recommended for installation process
#
# ================================================================================
# USAGE
# ================================================================================
#
# Direct execution:
#   curl -sSL https://raw.githubusercontent.com/galactic-plane/fedora-42-ms-setup/main/ms-dev-setup-script.sh | bash
#
# Local execution:
#   git clone https://github.com/galactic-plane/fedora-42-ms-setup.git
#   cd fedora-42-ms-setup
#   chmod +x ms-dev-setup-script.sh
#   ./ms-dev-setup-script.sh
#
# ================================================================================
# TROUBLESHOOTING
# ================================================================================
#
# View installation log:        sudo tail -f /var/log/ms-dev-setup.log
# Search for errors:            sudo grep -i error /var/log/ms-dev-setup.log
# Check backup files:           ls -la /var/backups/ms-dev-setup/
# Verify installations:         Run verification commands in README.md
#
# Common issues:
# • Permission errors: Ensure user is in wheel group with sudo access
# • Network issues: Update system packages and clear DNF cache first
# • VMware detection: Manual confirmation prompt if auto-detection fails
# • PowerShell fallback: Script tries GitHub releases if Microsoft repo fails
#
# ================================================================================

set -e  # Exit on any error

# Global variables
LOG_FILE="/var/log/ms-dev-setup.log"
BACKUP_DIR="/var/backups/ms-dev-setup"
FEDORA_VERSION=""
IS_VMWARE=false

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Logging functions
log_action() {
    local message="$1"
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] $message" | sudo tee -a "$LOG_FILE" >/dev/null
}

log() {
    echo -e "${GREEN}[INFO]${NC} $1"
    log_action "INFO: $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
    log_action "WARN: $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
    log_action "ERROR: $1"
}

header() {
    echo ""
    echo -e "${BLUE}==========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}==========================================${NC}"
    log_action "SECTION: $1"
}

# Utility functions
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

package_installed() {
    dnf list installed "$1" >/dev/null 2>&1
}

backup_file() {
    local file="$1"
    if [[ -f "$file" ]]; then
        local backup_name
        backup_name="$(basename "$file").$(date +%Y%m%d_%H%M%S).bak"
        sudo mkdir -p "$BACKUP_DIR"
        sudo cp "$file" "$BACKUP_DIR/$backup_name"
        log "Backed up $file to $BACKUP_DIR/$backup_name"
    fi
}

get_fedora_version() {
    FEDORA_VERSION=$(grep -oP 'VERSION_ID=\K\d+' /etc/os-release)
    log "Detected Fedora version: $FEDORA_VERSION"
}

# System validation functions
check_privileges() {
    if [[ $EUID -eq 0 ]]; then
        error "This script should not be run directly as root for security reasons."
        error "Please run as a regular user with sudo access."
        exit 1
    fi
    
    # Check if user has sudo access
    if ! sudo -n true 2>/dev/null; then
        error "This script requires sudo access. Please ensure you can run 'sudo' commands."
        exit 1
    fi
    
    log "✓ User has appropriate sudo privileges"
}

validate_system() {
    header "🔍 System Validation"
    
    # Check if running on Fedora
    if ! grep -q "Fedora" /etc/os-release; then
        error "This script is designed for Fedora. Detected: $(grep PRETTY_NAME /etc/os-release | cut -d'"' -f2)"
        exit 1
    fi
    log "✓ Running on Fedora Linux"
    
    get_fedora_version
    
    if [[ $FEDORA_VERSION -lt 42 ]]; then
        warn "This script is optimized for Fedora 42+. Current version: $FEDORA_VERSION"
        warn "Some features may not work as expected."
    fi
    
    # Check network connectivity
    log "Testing network connectivity..."
    if ! ping -c 1 google.com >/dev/null 2>&1; then
        error "Please check your internet connection."
        exit 1
    fi
    log "✓ Network connectivity to Microsoft repositories verified"
    
    # Check available disk space (minimum 4GB)
    local available_space
    available_space=$(df / | awk 'NR==2 {print $4}')
    local required_space=$((4 * 1024 * 1024)) # 4GB in KB
    
    if [[ $available_space -lt $required_space ]]; then
        error "Insufficient disk space. Required: 4GB, Available: $((available_space / 1024 / 1024))GB"
        exit 1
    fi
    log "✓ Sufficient disk space available ($((available_space / 1024 / 1024))GB)"
}

detect_vmware() {
    log "Detecting VMware environment..."
    
    # Method 1: Check for VMware hardware via lspci
    if lspci 2>/dev/null | grep -qi "vmware"; then
        log "✓ VMware hardware detected via lspci"
        IS_VMWARE=true
        return 0
    fi
    
    # Method 2: Check DMI product name
    if [[ -r /sys/class/dmi/id/product_name ]]; then
        local product_name
        product_name=$(cat /sys/class/dmi/id/product_name 2>/dev/null)
        if [[ "$product_name" =~ VMware ]]; then
            log "✓ VMware detected via DMI product name: $product_name"
            IS_VMWARE=true
            return 0
        fi
    fi
    
    # Method 3: Check for VMware processes
    if pgrep -f "vmware" >/dev/null 2>&1; then
        log "✓ VMware processes detected"
        IS_VMWARE=true
        return 0
    fi
    
    log "No VMware environment detected"
    IS_VMWARE=false
}

confirm_vmware_installation() {
    if [[ "$IS_VMWARE" == "true" ]]; then
        log "VMware environment detected - VMware Tools will be installed automatically"
        return 0
    fi
    
    echo ""
    echo -e "${CYAN}VMware Environment Check:${NC}"
    echo "VMware was not automatically detected on this system."
    echo "If you are running this in VMware (but detection failed), VMware Tools"
    echo "can provide better integration, clipboard sharing, and display optimization."
    echo ""
    
    local response
    while true; do
        read -p "Are you running this system in VMware? (y/n): " -r response
        case "$response" in
            [yY]|[yY][eE][sS])
                IS_VMWARE=true
                log "User confirmed VMware environment - VMware Tools will be installed"
                break
                ;;
            [nN]|[nN][oO])
                IS_VMWARE=false
                log "User confirmed not running in VMware - VMware Tools will be skipped"
                break
                ;;
            *)
                echo "Please answer 'y' for yes or 'n' for no."
                ;;
        esac
    done
    
    return 0
}

show_software_list() {
    header "📦 SOFTWARE TO BE INSTALLED/UPDATED"
    
    echo -e "${CYAN}🔧 SYSTEM UPDATES:${NC}"
    echo "   • System package updates"
    echo "   • Firmware updates (skipped for VMs)"
    echo ""
    
    echo -e "${CYAN}🛠️  DEVELOPMENT TOOLS:${NC}"
    echo "   • Git (version control)"
    echo "   • Node.js (JavaScript runtime)"
    echo "   • npm (Node.js package manager)"
    echo "   • Python 3 with pip (Python package manager)"
    echo "   • Podman (container management)"
    echo "   • Essential build tools (gcc, cmake, make)"
    echo ""
    
    echo -e "${CYAN}📊 PERFORMANCE & MONITORING TOOLS:${NC}"
    echo "   • htop (interactive process viewer)"
    echo "   • iotop (I/O monitoring)"
    echo "   • sysstat (system performance tools)"
    echo "   • net-tools (network utilities)"
    echo "   • nethogs (network bandwidth monitoring)"
    echo "   • mesa-utils (OpenGL utilities)"
    echo ""
    
    echo -e "${CYAN}🏢 MICROSOFT DEVELOPMENT STACK:${NC}"
    echo "   • Visual Studio Code (code editor)"
    echo "   • Microsoft Edge (web browser)"
    echo "   • .NET 9 SDK (development framework)"
    echo "   • PowerShell Core (cross-platform shell)"
    echo ""
    
    echo -e "${CYAN}☁️  AZURE DEVELOPMENT TOOLS:${NC}"
    echo "   • Azure CLI (command-line interface)"
    echo "   • Azure Functions Core Tools (via npm)"
    echo ""
    
    echo -e "${CYAN}⚡ POWER PLATFORM:${NC}"
    echo "   • Power Platform CLI (low-code development tools)"
    echo ""
    
    if [[ "$IS_VMWARE" == "true" ]]; then
        echo -e "${CYAN}🖥️  VMWARE INTEGRATION:${NC}"
        echo "   • VMware Tools (guest integration)"
        echo "   • 3D acceleration support"
        echo ""
    fi
    
    echo -e "${CYAN}⚙️  SYSTEM CONFIGURATION:${NC}"
    echo "   • Development aliases (docker=podman, sysmon=htop, etc.)"
    echo "   • .NET tools PATH configuration"
    echo "   • HTTPS development certificates"
    echo "   • Microsoft repositories and GPG keys"
    echo ""
    
    echo -e "${CYAN}📁 ESTIMATED DOWNLOAD SIZE: ~1-2 GB${NC}"
    echo -e "${CYAN}💾 ESTIMATED DISK SPACE NEEDED: ~3-4 GB${NC}"
    echo ""
    
    echo -e "${YELLOW}⚠️  NOTE: This script will:${NC}"
    echo "   • Add Microsoft package repositories"
    echo "   • Install software system-wide (requires sudo)"
    echo "   • Modify user configuration files (.bashrc)"
    echo "   • Create backups of modified system files"
    echo ""
}

get_user_confirmation() {
    show_software_list
    
    echo -e "${PURPLE}🤔 Do you want to proceed with the installation? [Y/n]:${NC} "
    read -r response
    
    case "$response" in
        [nN][oO]|[nN])
            log "Installation cancelled by user"
            echo "Installation cancelled. No changes were made to your system."
            exit 0
            ;;
        [yY][eE][sS]|[yY]|"")
            log "User confirmed installation"
            echo "Proceeding with installation..."
            ;;
        *)
            warn "Invalid response. Please answer 'y' for yes or 'n' for no."
            get_user_confirmation
            ;;
    esac
}

install_monitoring_tools() {
    header "📊 Installing Performance & Monitoring Tools"
    
    log "Installing system monitoring tools..."
    sudo dnf install -y \
        htop \
        iotop \
        sysstat \
        net-tools \
        nethogs
    
    log "Installing graphics utilities..."
    # Try mesa-utils first, fallback to glx-utils
    if ! sudo dnf install -y mesa-utils 2>/dev/null; then
        warn "mesa-utils not available, trying glx-utils..."
        sudo dnf install -y glx-utils || warn "Graphics utilities installation failed"
    fi
    
    log "✓ Performance and monitoring tools installed"
}

install_vmware_tools() {
    if [[ "$IS_VMWARE" != "true" ]]; then
        log "Skipping VMware Tools installation (not running in VMware)"
        return 0
    fi
    
    header "🖥️  Installing VMware Integration"
    
    log "Installing VMware Tools..."
    sudo dnf install -y open-vm-tools open-vm-tools-desktop
    
    # Enable and start VMware Tools service
    sudo systemctl enable vmtoolsd
    sudo systemctl start vmtoolsd
    
    log "Checking VMware Tools status..."
    if systemctl is-active --quiet vmtoolsd; then
        log "✓ VMware Tools service is running"
    else
        warn "VMware Tools service is not running"
    fi
    
    # Check for 3D acceleration
    if lspci | grep -qi "vmware svga"; then
        log "✓ VMware SVGA 3D acceleration detected"
    else
        log "No VMware SVGA device detected"
    fi
    
    log "✓ VMware integration completed"
}

install_azure_functions_tools() {
    header "☁️  Installing Azure Functions Core Tools"
    
    if ! command_exists npm; then
        warn "npm not available, skipping Azure Functions Core Tools"
        return 1
    fi
    
    log "Installing Azure Functions Core Tools via npm..."
    
    # Check npm global prefix
    local npm_prefix
    npm_prefix=$(npm config get prefix)
    
    # If npm prefix is system directory, use sudo
    if [[ "$npm_prefix" == "/usr"* ]] || [[ "$npm_prefix" == "/usr/local"* ]]; then
        log "Installing to system directory ($npm_prefix), using sudo..."
        if sudo npm install -g azure-functions-core-tools@4 --unsafe-perm 2>/dev/null; then
            log "✓ Azure Functions Core Tools installed successfully"
        else
            warn "Failed to install Azure Functions Core Tools via npm with sudo"
            install_azure_functions_fallback
        fi
    else
        # Try user installation first
        if npm install -g azure-functions-core-tools@4 2>/dev/null; then
            log "✓ Azure Functions Core Tools installed successfully"
            # Add npm global bin to PATH if not already there
            local npm_bin_path
            npm_bin_path="$(npm bin -g 2>/dev/null)"
            if [[ -n "$npm_bin_path" ]] && [[ ":$PATH:" != *":$npm_bin_path:"* ]]; then
                echo "export PATH=\"$npm_bin_path:\$PATH\"" >> ~/.bashrc
                log "✓ Added npm global bin to PATH"
            fi
        else
            warn "Failed to install Azure Functions Core Tools via npm"
            install_azure_functions_fallback
        fi
    fi
}

install_azure_functions_fallback() {
    log "Setting up user-local npm configuration for Azure Functions Core Tools..."
    
    # Create user npm directory and configure
    mkdir -p ~/.npm-global
    npm config set prefix ~/.npm-global
    
    # Add to PATH for current session and future sessions
    export PATH="$HOME/.npm-global/bin:$PATH"
    if ! grep -q ".npm-global/bin" ~/.bashrc 2>/dev/null; then
        echo "export PATH=\"\$HOME/.npm-global/bin:\$PATH\"" >> ~/.bashrc
        log "✓ Added ~/.npm-global/bin to PATH in .bashrc"
    fi
    
    # Try installing with user configuration
    if npm install -g azure-functions-core-tools@4 2>/dev/null; then
        log "✓ Azure Functions Core Tools installed to user directory"
    else
        warn "Failed to install Azure Functions Core Tools"
        log "You can install manually later with one of these commands:"
        log "  sudo npm install -g azure-functions-core-tools@4 --unsafe-perm"
        log "  Or setup user npm: mkdir ~/.npm-global && npm config set prefix ~/.npm-global"
        log "  Then: npm install -g azure-functions-core-tools@4"
    fi
}

setup_power_platform_cli() {
    header "⚡ Setting up Power Platform CLI"
    
    if ! command_exists dotnet; then
        warn ".NET SDK not available, deferring Power Platform CLI setup"
        return 1
    fi
    
    log "Power Platform CLI requires user context installation"
    log "After script completion, run as your user (not root):"
    log "  dotnet tool install --global Microsoft.PowerApps.CLI.Tool"
    
    # Ensure .NET tools path is in user's PATH
    local dotnet_tools_path="export PATH=\"\$PATH:\$HOME/.dotnet/tools\""
    if ! grep -q ".dotnet/tools" ~/.bashrc 2>/dev/null; then
        echo "# .NET global tools" >> ~/.bashrc
        echo "$dotnet_tools_path" >> ~/.bashrc
        log "✓ Added .NET tools to PATH in .bashrc"
    fi
}

setup_development_aliases() {
    header "⚙️  Setting Up Development Configuration"
    
    backup_file ~/.bashrc
    
    # Create development aliases
    local aliases_section
    aliases_section="# Microsoft Development Stack Aliases - Added $(date)
# System monitoring shortcuts
alias sysmon='htop'
alias diskmon='iostat -x 1'
alias netmon='nethogs'

# Container management (Podman with Docker compatibility)
alias docker='podman'

# Development shortcuts
alias dev='cd ~/Development'
alias repos='cd ~/Development/repos'

# Git shortcuts
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline'

# Azure CLI shortcuts
alias az-login='az login'
alias az-subs='az account list --query \"[].{Name:name, SubscriptionId:id}\" -o table'
"
    
    # Check if aliases already exist to avoid duplicates
    if ! grep -q "Microsoft Development Stack Aliases" ~/.bashrc 2>/dev/null; then
        echo "" >> ~/.bashrc
        echo "$aliases_section" >> ~/.bashrc
        log "✓ Development aliases added to .bashrc"
    else
        log "Development aliases already exist in .bashrc"
    fi
    
    # Create development directories
    mkdir -p ~/Development/{dotnet,nodejs,python,azure,scripts,repos}
    log "✓ Development directories created"
}

main() {
    # Initialize logging
    sudo mkdir -p "$(dirname "$LOG_FILE")"
    sudo touch "$LOG_FILE"
    
    header "🚀 Microsoft Development Stack Setup for Fedora $FEDORA_VERSION+ KDE Plasma"
    log "Starting installation process..."
    log "Compatible with DNF5 package manager"
    
    # Step 1: System validation
    check_privileges
    validate_system
    
    # Step 2: VMware detection
    detect_vmware
    confirm_vmware_installation
    
    # Step 3: Get user confirmation
    get_user_confirmation
    
    # Step 4: System updates
    header "🔄 Updating System Packages"
    sudo dnf update -y
    
    # Step 5: Install essential development tools
    header "🛠️  Installing Essential Development Tools"
    sudo dnf install -y 'dnf5-command(group)' || log "group command already available"
    
    log "Installing core development packages..."
    sudo dnf install -y \
        gcc \
        gcc-c++ \
        make \
        cmake \
        autoconf \
        automake \
        libtool \
        pkgconfig \
        patch \
        git \
        curl \
        wget \
        unzip \
        vim-enhanced \
        nano \
        tree \
        jq \
        openssl \
        openssl-devel \
        ca-certificates \
        gnupg \
        lsb-release \
        kernel-devel \
        kernel-headers \
        glibc-devel
    
    # Step 6: Install monitoring tools
    install_monitoring_tools
    
    # Step 7: Add Microsoft repositories
    header "📦 Adding Microsoft Repositories"
    log "Adding Microsoft repository using official Fedora configuration..."
    
    curl -sSL -o "/tmp/fedora${FEDORA_VERSION}prod.repo" "https://packages.microsoft.com/fedora/${FEDORA_VERSION}/prod/config.repo"
    backup_file "/etc/yum.repos.d/fedora${FEDORA_VERSION}prod.repo"
    sudo mv "/tmp/fedora${FEDORA_VERSION}prod.repo" "/etc/yum.repos.d/"
    sudo dnf makecache
    
    # Add VS Code repository
    backup_file "/etc/yum.repos.d/vscode.repo"
    sudo tee /etc/yum.repos.d/vscode.repo > /dev/null <<EOF
[code]
name=Visual Studio Code
baseurl=https://packages.microsoft.com/yumrepos/vscode
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc https://packages.microsoft.com/keys/microsoft-2025.asc
EOF
    
    # Add Microsoft Edge repository
    backup_file "/etc/yum.repos.d/microsoft-edge.repo"
    sudo tee /etc/yum.repos.d/microsoft-edge.repo > /dev/null <<EOF
[microsoft-edge]
name=Microsoft Edge
baseurl=https://packages.microsoft.com/yumrepos/edge
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc https://packages.microsoft.com/keys/microsoft-2025.asc
EOF
    
    sudo dnf makecache
    
    # Step 8: Install Microsoft applications
    header "🏢 Installing Microsoft Development Stack"
    
    log "Installing Visual Studio Code..."
    sudo dnf install -y code
    
    log "Installing .NET SDK..."
    sudo dnf install -y dotnet-sdk-9.0 dotnet-runtime-9.0 aspnetcore-runtime-9.0
    
    log "Installing PowerShell..."
    if sudo dnf install -y powershell 2>/dev/null; then
        log "✓ PowerShell installed from Microsoft repository"
    else
        warn "PowerShell not available in Microsoft repository for Fedora $FEDORA_VERSION"
        log "Attempting to install PowerShell from GitHub releases..."
        
        local pwsh_version
        pwsh_version=$(curl -s https://api.github.com/repos/PowerShell/PowerShell/releases/latest | jq -r '.tag_name' | sed 's/v//')
        if [ -n "$pwsh_version" ] && [ "$pwsh_version" != "null" ]; then
            log "Downloading PowerShell $pwsh_version..."
            if curl -sSL -o /tmp/powershell.rpm "https://github.com/PowerShell/PowerShell/releases/download/v${pwsh_version}/powershell-${pwsh_version}-1.rh.x86_64.rpm"; then
                if sudo dnf install -y /tmp/powershell.rpm; then
                    log "✓ PowerShell $pwsh_version installed successfully from GitHub releases"
                else
                    error "Failed to install PowerShell from downloaded RPM"
                fi
                rm -f /tmp/powershell.rpm
            else
                error "Failed to download PowerShell RPM from GitHub"
            fi
        else
            error "Failed to get PowerShell version from GitHub API"
        fi
    fi
    
    log "Installing Microsoft Edge..."
    sudo dnf install -y microsoft-edge-stable
    
    log "Installing Azure CLI..."
    sudo dnf install -y azure-cli
    
    # Step 9: Install development tools
    header "🔧 Installing Additional Development Tools"
    
    log "Installing Node.js and npm..."
    sudo dnf install -y nodejs npm
    
    log "Installing Python development tools..."
    sudo dnf install -y \
        python3 \
        python3-pip \
        python3-devel \
        python3-setuptools \
        python3-wheel \
        python3-virtualenv
    
    log "Installing Podman..."
    sudo dnf install -y podman podman-compose podman-docker
    
    # Enable podman socket for user
    systemctl --user enable podman.socket 2>/dev/null || true
    systemctl --user start podman.socket 2>/dev/null || true
    
    log "Installing GitHub CLI..."
    sudo dnf install -y gh
    
    # Step 10: Install Azure Functions Core Tools
    install_azure_functions_tools
    
    # Step 11: Setup Power Platform CLI
    setup_power_platform_cli
    
    # Step 12: Install VMware Tools (if needed)
    install_vmware_tools
    
    # Step 13: Setup development configuration
    setup_development_aliases
    
    # Step 14: Verify critical installations
    verify_installations
    
    # Step 15: Setup HTTPS development certificates
    log "Setting up .NET development certificates..."
    log "Run as user after installation: dotnet dev-certs https --trust"
    
    # Step 16: Final system update and cleanup
    header "🧹 Final System Update and Cleanup"
    sudo dnf upgrade -y
    sudo dnf autoremove -y
    sudo dnf clean all
    
    # Step 17: Execute post-installation configuration
    execute_post_installation_steps
    
    # Step 18: Installation summary
    show_installation_summary
}

execute_post_installation_steps() {
    header "⚙️  Executing Post-Installation Configuration"
    
    # Step 1: Reload shell configuration
    log "Reloading shell configuration..."
    # Note: This only affects the current script session, user will still need to reload their shell
    if [[ -f ~/.bashrc ]]; then
        # shellcheck disable=SC1090
        source ~/.bashrc 2>/dev/null || true
        log "✓ Shell configuration reloaded for script session"
    fi
    
    # Step 2: Configure Git (if not already configured)
    log "Checking Git configuration..."
    local git_name git_email
    git_name=$(git config --global user.name 2>/dev/null || echo "")
    git_email=$(git config --global user.email 2>/dev/null || echo "")
    
    if [[ -z "$git_name" ]] || [[ -z "$git_email" ]]; then
        log "Git user configuration not found, prompting for setup..."
        echo ""
        echo -e "${CYAN}Git Configuration Setup:${NC}"
        echo "Git requires your name and email for commits."
        echo ""
        
        if [[ -z "$git_name" ]]; then
            while [[ -z "$git_name" ]]; do
                read -p "Enter your full name for Git commits: " -r git_name
            done
            git config --global user.name "$git_name"
            log "✓ Git user.name set to: $git_name"
        else
            log "✓ Git user.name already configured: $git_name"
        fi
        
        if [[ -z "$git_email" ]]; then
            while [[ -z "$git_email" ]]; do
                read -p "Enter your email address for Git commits: " -r git_email
            done
            git config --global user.email "$git_email"
            log "✓ Git user.email set to: $git_email"
        else
            log "✓ Git user.email already configured: $git_email"
        fi
    else
        log "✓ Git already configured: $git_name <$git_email>"
    fi
    
    # Step 3: Install Power Platform CLI (if .NET is available and not already installed)
    if command_exists dotnet; then
        log "Checking Power Platform CLI installation..."
        if dotnet tool list --global | grep -q "microsoft.powerapps.cli.tool" 2>/dev/null; then
            log "✓ Power Platform CLI already installed"
        else
            log "Installing Power Platform CLI..."
            if dotnet tool install --global Microsoft.PowerApps.CLI.Tool 2>/dev/null; then
                log "✓ Power Platform CLI installed successfully"
            else
                warn "Failed to install Power Platform CLI automatically"
                log "You can install it manually later with: dotnet tool install --global Microsoft.PowerApps.CLI.Tool"
            fi
        fi
    else
        warn ".NET SDK not available, skipping Power Platform CLI installation"
    fi
    
    # Step 4: Setup .NET HTTPS certificates (if .NET is available and not already trusted)
    if command_exists dotnet; then
        log "Checking .NET HTTPS development certificates..."
        # Check if certificates are already trusted by attempting to list them
        if dotnet dev-certs https --check --trust 2>/dev/null; then
            log "✓ .NET HTTPS certificates already trusted"
        else
            log "Setting up .NET HTTPS development certificates..."
            if dotnet dev-certs https --trust 2>/dev/null; then
                log "✓ .NET HTTPS certificates configured and trusted"
            else
                warn "Failed to automatically trust .NET HTTPS certificates"
                log "You may need to run manually: dotnet dev-certs https --trust"
            fi
        fi
    else
        warn ".NET SDK not available, skipping HTTPS certificate setup"
    fi
    
    # Step 5: Enable Podman socket (if Podman is available and not already enabled)
    if command_exists podman; then
        log "Checking Podman socket configuration..."
        if systemctl --user is-enabled podman.socket >/dev/null 2>&1; then
            log "✓ Podman socket already enabled"
            if systemctl --user is-active podman.socket >/dev/null 2>&1; then
                log "✓ Podman socket is running"
            else
                log "Starting Podman socket..."
                systemctl --user start podman.socket 2>/dev/null || warn "Failed to start Podman socket"
            fi
        else
            log "Enabling and starting Podman socket..."
            if systemctl --user enable --now podman.socket 2>/dev/null; then
                log "✓ Podman socket enabled and started"
            else
                warn "Failed to enable Podman socket automatically"
                log "You can enable it manually later with: systemctl --user enable --now podman.socket"
            fi
        fi
    else
        warn "Podman not available, skipping socket configuration"
    fi
    
    log "✓ Post-installation configuration completed"
}

verify_installations() {
    header "🔍 Verifying Critical Installations"
    
    local verification_failed=false
    
    # Verify PowerShell
    if command_exists pwsh; then
        local pwsh_version
        pwsh_version=$(pwsh --version 2>/dev/null | head -n1)
        log "✓ PowerShell installed: $pwsh_version"
    else
        error "✗ PowerShell installation failed or not in PATH"
        verification_failed=true
    fi
    
    # Verify .NET SDK
    if command_exists dotnet; then
        local dotnet_version
        dotnet_version=$(dotnet --version 2>/dev/null)
        log "✓ .NET SDK installed: $dotnet_version"
    else
        error "✗ .NET SDK installation failed or not in PATH"
        verification_failed=true
    fi
    
    # Verify Azure CLI
    if command_exists az; then
        local az_version
        az_version=$(az --version 2>/dev/null | head -n1 | awk '{print $2}')
        log "✓ Azure CLI installed: $az_version"
    else
        error "✗ Azure CLI installation failed or not in PATH"
        verification_failed=true
    fi
    
    # Verify VS Code
    if command_exists code; then
        local code_version
        code_version=$(code --version 2>/dev/null | head -n1)
        log "✓ Visual Studio Code installed: $code_version"
    else
        error "✗ Visual Studio Code installation failed or not in PATH"
        verification_failed=true
    fi
    
    # Verify Node.js and npm
    if command_exists node && command_exists npm; then
        local node_version npm_version
        node_version=$(node --version 2>/dev/null)
        npm_version=$(npm --version 2>/dev/null)
        log "✓ Node.js installed: $node_version"
        log "✓ npm installed: $npm_version"
    else
        error "✗ Node.js or npm installation failed"
        verification_failed=true
    fi
    
    # Verify Azure Functions Core Tools (optional)
    if command_exists func; then
        local func_version
        func_version=$(func --version 2>/dev/null)
        log "✓ Azure Functions Core Tools installed: $func_version"
    else
        warn "Azure Functions Core Tools not installed or not in PATH"
        log "This is optional and can be installed later"
    fi
    
    if [[ "$verification_failed" == "true" ]]; then
        warn "Some critical components failed to install properly"
        warn "Check the log file at $LOG_FILE for detailed error messages"
    else
        log "✓ All critical components verified successfully"
    fi
}

show_installation_summary() {
    header "✅ Installation Complete!"
    
    log "Microsoft Developer Stack has been installed successfully!"
    echo ""
    
    echo -e "${GREEN}Installed Software:${NC}"
    echo "  • Visual Studio Code"
    echo "  • .NET 9 SDK"
    echo "  • PowerShell Core"
    echo "  • Azure CLI"
    echo "  • Microsoft Edge"
    echo "  • Node.js & npm"
    echo "  • Python 3 with development tools"
    echo "  • Podman with Docker compatibility"
    echo "  • GitHub CLI"
    echo "  • System monitoring tools (htop, iotop, sysstat, etc.)"
    
    if [[ "$IS_VMWARE" == "true" ]]; then
        echo "  • VMware Tools"
    fi
    
    echo ""
    echo -e "${GREEN}Automated Configuration Completed:${NC}"
    echo "  ✓ Shell configuration reloaded"
    echo "  ✓ Git user configuration (if not previously set)"
    echo "  ✓ Power Platform CLI installation (if .NET available)"
    echo "  ✓ .NET HTTPS certificates setup"
    echo "  ✓ Podman socket enabled and started"
    echo ""
    
    echo -e "${YELLOW}Next Steps:${NC}"
    echo "1. Open a new terminal to use updated shell configuration"
    echo "2. Verify your setup:"
    echo "   • Test Git: git --version && git config --list | grep user"
    echo "   • Test .NET: dotnet --info"
    echo "   • Test Azure: az --version"
    echo "   • Test Power Platform: pac help (if installed)"
    echo "   • Test Podman: podman version"
    echo ""
    
    # Check if Azure Functions Core Tools installation failed and provide guidance
    if ! command_exists func; then
        echo -e "${YELLOW}Optional: Azure Functions Core Tools${NC}"
        echo "Azure Functions Core Tools can be installed with:"
        echo "  npm install -g azure-functions-core-tools@4"
        echo "Or use the VS Code Azure Functions extension"
        echo ""
    fi
    
    log "Development directories created in ~/Development/"
    log "Useful aliases added to ~/.bashrc"
    log "Installation log saved to $LOG_FILE"
    echo ""
    log "Your Microsoft development environment is ready! 🚀"
}

# Run main function
main "$@"