# Microsoft Development Stack Setup for Fedora 42+ KDE Plasma

A comprehensive automation script that sets up a complete Microsoft development environment on Fedora Linux with KDE Plasma desktop. The script intelligently detects VMware environments and configures appropriate integrations while providing a robust development stack for modern Microsoft technologies.

## 🖥️ Target System

![Fedora 42 KDE Plasma VMware Setup](box.png)

*Fedora 42 KDE Plasma running under VMware with fastfetch system information*

## 🚀 Quick Start

```bash
# Clone the repository
git clone https://github.com/galactic-plane/fedora-42-kde-vmware-setup.git
cd fedora-42-kde-vmware-setup

# Make the script executable
chmod +x ms-dev-setup-script.sh

# Run the setup (requires sudo)
sudo ./ms-dev-setup-script.sh
```

## 📋 Complete Software Inventory

### 🔧 System Updates & Base Components
- **System Package Updates** - All Fedora packages updated to latest versions
- **Firmware Updates** - Automatically skipped for virtual machines
- **Package Cache Management** - DNF cache cleaning and optimization

### 🛠️ Essential Development Tools
- **Git** - Distributed version control system
- **Node.js** - JavaScript runtime environment (latest LTS)
- **npm** - Node.js package manager
- **Python 3** - Modern Python interpreter
- **pip** - Python package installer
- **Podman** - Daemonless container engine (Docker alternative)
  - *Condition*: Podman socket configuration requires user setup post-installation

### 📊 Performance & Monitoring Tools
- **htop** - Interactive process viewer with enhanced UI
- **iotop** - Real-time I/O usage monitoring
- **sysstat** - System performance utilities (iostat, sar, etc.)
- **net-tools** - Network configuration utilities
- **nethogs** - Per-process network bandwidth monitor
- **mesa-utils (glx-utils)** - OpenGL utilities for graphics testing
  - *Condition*: Installation varies by system, fallback handling included

### 🏢 Microsoft Development Stack
- **Visual Studio Code** - Feature-rich code editor with extension ecosystem
- **Microsoft Edge** - Chromium-based web browser with Microsoft services integration
- **.NET 9 SDK** - Latest .NET development framework
  - *Includes*: Runtime, ASP.NET Core, and development tools
- **Azure CLI** - Command-line interface for Azure cloud services
  - *Condition*: May not be available for all Fedora versions
- **Azure Functions Core Tools** - Local development tools for Azure Functions
  - *Condition*: Installed via npm as optional component, requires manual user setup

### ⚡ Power Platform Development
- **Power Platform CLI (pac)** - Command-line tools for Power Apps, Power Automate, and Power BI
  - *Condition*: Requires post-installation user setup via .NET global tools

### 🖥️ VMware Integration (Conditional)
- **VMware Tools (open-vm-tools)** - Guest OS integration and optimization
  - *Auto-detection*: System automatically detects VMware environment via:
    - `lspci` hardware detection for VMware devices
    - DMI product name checking for VMware signatures
  - *User Prompt*: If VMware not detected, user prompted for manual confirmation
  - *Components*: Includes desktop integration packages for optimal KDE experience
- **VMware 3D Acceleration Support** - Graphics drivers for 3D acceleration
- **VMware Guest Services** - Automatic service enablement and startup

### 🔐 Security & Repository Configuration
- **Microsoft GPG Keys** - Official Microsoft package signing keys
- **Microsoft Package Repositories**:
  - Visual Studio Code repository
  - Microsoft Edge repository
  - .NET SDK repository (dynamically configured for detected Fedora version)
- **HTTPS Development Certificates** - .NET development SSL certificates
  - *Condition*: Requires user setup post-installation

### ⚙️ System Configuration & Aliases
- **Development Aliases**:
  - `docker=podman` - Container compatibility
  - `sysmon=htop` - System monitoring shortcut
  - `diskmon="iostat -x 1"` - Disk monitoring shortcut
  - `netmon=nethogs` - Network monitoring shortcut
- **.NET Tools PATH Configuration** - Adds `~/.dotnet/tools` to user PATH
- **Default Browser Configuration** - Microsoft Edge integration (user configurable)

### 📁 Storage & Backup Management
- **Automatic File Backups** - Timestamped backups of all modified system files
- **Configuration Validation** - Integrity checking of downloaded repository files
- **Log Management** - Comprehensive activity logging to `/var/log/ms-dev-setup.log`

## 📊 Resource Requirements & Estimates

### 💾 Disk Space Requirements
- **Minimum Available Space**: 4GB free
- **Recommended Available Space**: 6GB free
- **Estimated Download Size**: 1-2GB
- **Post-Installation Size**: 3-4GB

### 🌐 Network Requirements
- **Internet Connectivity**: Required for package downloads
- **Microsoft Repositories Access**: packages.microsoft.com must be reachable
- **DNS Resolution**: Functional DNS for repository lookups

### ⚡ Performance Impact
- **Installation Time**: 15-30 minutes (depending on network speed)
- **CPU Usage**: Moderate during installation, minimal post-installation
- **Memory Usage**: ~2GB recommended during installation

## 🏗️ Installation Process & Conditions

### 🔍 Pre-Installation Validation
1. **Privilege Check**: Ensures script runs with root/sudo permissions
2. **Fedora Compatibility**: Validates running on Fedora Linux
3. **Network Connectivity**: Tests access to Microsoft repositories
4. **Version Detection**: Automatically detects Fedora version for repository configuration

### 🎯 Smart Installation Logic
- **Idempotent Operations**: Safe to run multiple times
- **Existing Software Detection**: Skips installation if already present
- **Update vs Install**: Updates existing software or installs if missing
- **Fallback Handling**: Graceful failure recovery for optional components

### 🔐 VMware Environment Handling
The script includes intelligent VMware detection:

1. **Automatic Detection Methods**:
   - Hardware detection via `lspci` for VMware SVGA devices
   - System identification via DMI product name
   
2. **User Interaction for Unknown Systems**:
   - If VMware not detected, prompts user: "Are you running this system in VMware? (y/n)"
   - Allows manual confirmation for edge cases
   - Skips VMware Tools if user answers "no"

3. **VMware Tools Installation**:
   - **If VMware Detected/Confirmed**: Installs `open-vm-tools` and `open-vm-tools-desktop`
   - **Service Management**: Enables and starts `vmtoolsd` service
   - **Integration**: Configures KDE Plasma desktop integration
   - **3D Acceleration**: Verifies and reports 3D acceleration status

### 🔄 Conditional Installations

#### Azure Functions Core Tools
- **Primary Method**: npm global installation as user
- **Fallback**: Alternative package name attempts
- **Condition**: Only installs if npm is available
- **User Setup**: Requires post-installation configuration

#### Power Platform CLI
- **Installation Method**: .NET global tool
- **Condition**: Deferred to user post-installation
- **Reason**: Requires user context, not system-wide installation

#### Development Certificates
- **Component**: .NET HTTPS development certificates
- **Condition**: Requires user execution post-installation
- **Command**: `dotnet dev-certs https --trust`

#### Container Management
- **Podman Socket**: User-specific systemd service
- **Condition**: Must be enabled by user post-installation
- **Command**: `systemctl --user enable --now podman.socket`

## ✨ Enhanced Features

### 🔒 Security & Reliability
- **Privilege Validation** - Ensures script runs with proper permissions
- **System Validation** - Verifies Fedora compatibility and network connectivity
- **Interactive Confirmation** - Shows complete software list before installation
- **User Consent** - Allows users to review and approve before making changes
- **File Backups** - Automatically backs up modified system files with timestamps
- **Input Validation** - Validates downloaded repository files before installation
- **Error Handling** - Comprehensive error recovery with detailed messaging

### 🧠 Smart Configuration
- **Dynamic Version Detection** - Automatically detects Fedora version for optimal repository configuration
- **KDE Plasma Integration** - Configures tools for optimal KDE desktop experience
- **VMware Auto-Detection** - Intelligent VMware environment detection with user fallback
- **Idempotent Execution** - Safe to run multiple times without duplicating configurations
- **Duplicate Prevention** - Prevents duplicate PATH entries and aliases
- **Repository Management** - Safely manages Microsoft package repositories with conflict resolution

### 📊 Comprehensive Monitoring
- **Activity Logging** - All actions logged to `/var/log/ms-dev-setup.log` with timestamps
- **Progress Indicators** - Clear visual feedback with emoji indicators during installation
- **Version Reporting** - Detailed summary of installed software versions
- **System Information** - Hardware and system configuration reporting
- **Performance Metrics** - CPU, memory, and disk space reporting

## 🛠️ System Requirements

- **Operating System**: Fedora 42+ (automatically detects version)
- **Desktop Environment**: KDE Plasma (optimized for, works with others)
- **Virtualization**: 
  - ✅ **VMware Workstation/Player** (auto-detected with full integration)
  - ✅ **VirtualBox** (works but without VMware-specific optimizations)
  - ✅ **Physical Hardware** (works without virtualization features)
- **Architecture**: x86_64 (64-bit Intel/AMD)
- **Privileges**: Root access via sudo
- **Network**: 
  - Internet connectivity to Microsoft repositories
  - Access to packages.microsoft.com
  - Functional DNS resolution
- **Disk Space**: 4GB minimum, 6GB recommended
- **Memory**: 2GB RAM recommended during installation

## 📖 Usage

### Basic Usage
```bash
sudo ./ms-dev-setup-script.sh
```

The script will:
1. **Validate system requirements** (Fedora compatibility, network connectivity)
2. **Display comprehensive software list** with categories and estimated sizes
3. **Request user confirmation** before making any changes
4. **Proceed with installation** only after user approval
5. **Provide detailed progress updates** throughout the process
6. **Generate final summary** with all installed software versions

### Post-Installation Steps
After the script completes, you'll need to run these commands as your regular user (not root):

```bash
# 1. Enable Podman socket for container management (if not already configured)
systemctl --user enable --now podman.socket

# 2. Install Power Platform CLI (if needed for Power Platform development)
dotnet tool install --global Microsoft.PowerApps.CLI.Tool

# 3. Trust .NET HTTPS development certificate (for web development)
dotnet dev-certs https --trust

# 4. Optional: Install Azure Functions Core Tools (if needed for Azure development)
npm install -g azure-functions-core-tools@4

# 5. Reload shell configuration to activate new aliases
source ~/.bashrc
```

### User Context Requirements
The script handles privilege management intelligently:
- **System Components**: Installed as root/sudo (repositories, system packages)
- **User Configuration**: Deferred to post-installation user setup
- **Reasoning**: Security best practices prevent root from modifying user dotfiles directly

### Interactive Experience
The script provides a comprehensive pre-installation review:

```
==========================================
📦 SOFTWARE TO BE INSTALLED/UPDATED
==========================================

🔧 SYSTEM UPDATES:
   • System package updates
   • Firmware updates (skipped for VMs)

🛠️  DEVELOPMENT TOOLS:
   • Git (version control)
   • Node.js (JavaScript runtime)
   • npm (Node.js package manager)
   • Python 3 with pip (Python package manager)
   • Podman (container management)

📊 PERFORMANCE & MONITORING TOOLS:
   • htop (interactive process viewer)
   • iotop (I/O monitoring)
   • sysstat (system performance tools)
   • net-tools (network utilities)
   • nethogs (network bandwidth monitoring)
   • mesa-utils (OpenGL utilities)

🏢 MICROSOFT DEVELOPMENT STACK:
   • Visual Studio Code (code editor)
   • Microsoft Edge (web browser)
   • .NET 9 SDK (development framework)

☁️  AZURE DEVELOPMENT TOOLS:
   • Azure CLI (command-line interface)
   • Azure Functions Core Tools (optional, via npm)

⚡ POWER PLATFORM:
   • Power Platform CLI (low-code development tools)

🖥️  VMWARE INTEGRATION:
   • VMware Tools (guest integration)
   • 3D acceleration support

⚙️  SYSTEM CONFIGURATION:
   • Development aliases (docker=podman, sysmon=htop, etc.)
   • .NET tools PATH configuration
   • HTTPS development certificates
   • Microsoft repositories and GPG keys

📁 ESTIMATED DOWNLOAD SIZE: ~1-2 GB
💾 ESTIMATED DISK SPACE NEEDED: ~3-4 GB

⚠️  NOTE: This script will:
   • Add Microsoft package repositories
   • Install software system-wide (requires root/sudo)
   • Modify user configuration files (.bashrc)
   • Create backups of modified system files

🤔 Do you want to proceed with the installation? [Y/n]:
```

### Verification
Check that everything is working:
```bash
# Test installed tools
code --version
microsoft-edge --version
dotnet --version
az --version
pac help

# Test development workflow
dotnet new console -n TestApp
cd TestApp
dotnet run
```

### What You'll See
When you run the script, you'll get an interactive experience with full transparency:

```
==========================================
Microsoft Development Stack Setup
==========================================

Step 1: System Updates
======================
→ Updating system packages...
✓ firmware update skipped (not needed in VMs)
✓ System updated

Step 2: Essential Development Tools
===================================
→ Installing git...
✓ nodejs already installed
→ Installing python3-pip...
...

Step 8: VMware Tools Verification
=================================
This step is only needed if you are running under VMware.
Are you running this system in VMware? (y/n): y
✓ VMware Tools service running

==========================================
INSTALLATION COMPLETE!
==========================================

Installed Software Versions:
=============================
Operating System: Fedora release 42 (Forty Two)
Kernel: 6.8.5-301.fc42.x86_64

Development Tools:
------------------
Git: 2.44.0
Node.js: v20.11.1
npm: 10.2.4
Python: 3.12.2
Podman: 4.9.3

Microsoft Development Stack:
----------------------------
VS Code: 1.87.2
Microsoft Edge: 122.0.2365.92
.NET SDK: 9.0.100

Performance & Monitoring Tools:
-------------------------------
htop: 3.3.0
iostat: 12.7.0
nethogs: installed

System Resources:
-----------------
CPU: Intel(R) Core(TM) i7-10700K CPU @ 3.80GHz
CPU Cores: 8
Total RAM: 16Gi
Available RAM: 12Gi
Disk Space: 45G available on /

VMware Integration:
-------------------
VMware Tools: Active
Guest API: Available
3D Acceleration: Enabled (SVGA3D detected)
```

## 📁 Project Structure

```
fedora-setup/
├── ms-dev-setup-script.sh     # Main installation script
├── README.md                  # This documentation
└── .git/                      # Git repository data
```

## 🔍 Script Architecture

### Function Overview
- `check_privileges()` - Validates root permissions
- `validate_system()` - Checks Fedora compatibility and connectivity
- `get_fedora_version()` - Dynamically detects Fedora version
- `backup_file()` - Creates timestamped backups
- `log_action()` - Logs activities with timestamps
- `add_microsoft_repo()` - Safely adds Microsoft repositories
- `command_exists()` - Checks if commands are available
- `package_installed()` - Verifies package installation

### Installation Steps (Detailed)
1. **System Updates** - Updates all Fedora packages and components
2. **Essential Development Tools** - Installs Git, Node.js, Python, Podman, and monitoring tools
3. **Microsoft Repositories** - Configures Microsoft package sources with GPG key validation
4. **Microsoft Applications** - Installs VS Code, Edge, and .NET SDK with version verification
5. **Azure Development Tools** - Installs Azure CLI and optionally Azure Functions Core Tools
6. **Power Platform CLI** - Configures .NET global tools path for Power Platform development
7. **System Configuration** - Sets up aliases, PATH variables, and development certificates
8. **VMware Integration** - Auto-detects VMware environment and installs appropriate tools

### Conditional Logic Summary
- **VMware Tools**: Only installed if VMware detected or user confirms VMware usage
- **Azure Functions Core Tools**: Optional npm package, graceful fallback if installation fails
- **Power Platform CLI**: Deferred to user post-installation due to privilege requirements
- **Podman Socket**: User-specific service, configured post-installation
- **Development Certificates**: User-specific trust configuration, handled post-installation
- **Firmware Updates**: Automatically skipped in virtual machine environments

## � Support & Troubleshooting

### 🔧 Common Issues & Solutions

**Permission Denied**
```bash
# Ensure script is executable
chmod +x ms-dev-setup-script.sh

# Run with sudo for system-wide installation
sudo ./ms-dev-setup-script.sh
```

**Network Issues**
```bash
# Check internet connectivity
ping packages.microsoft.com

# Check DNS resolution
nslookup packages.microsoft.com

# Test network adapter (common VMware interface)
ip addr show ens33
```

**Repository Conflicts**
```bash
# Clear DNF cache and rebuild
sudo dnf clean all && sudo dnf makecache

# Check repository status
sudo dnf repolist enabled
```

**VMware Detection Issues**
```bash
# Manual VMware hardware check
lspci | grep -i vmware

# Check VMware Tools status
systemctl status vmtoolsd

# Manual VMware Tools installation if needed
sudo dnf install open-vm-tools open-vm-tools-desktop
```

### 📋 Diagnostic Information
Check the detailed installation log:
```bash
# View complete installation log
sudo tail -f /var/log/ms-dev-setup.log

# Check for errors in log
sudo grep -i error /var/log/ms-dev-setup.log
```

### 🔄 Manual Component Installation
If specific components fail during automated installation:

```bash
# Core Microsoft packages
sudo dnf install code microsoft-edge-stable dotnet-sdk-9.0

# Azure tools
sudo dnf install azure-cli
npm install -g azure-functions-core-tools@4

# Development tools
sudo dnf install git nodejs npm python3-pip podman

# Performance tools
sudo dnf install htop iotop sysstat net-tools nethogs

# Graphics utilities
sudo dnf install mesa-utils || sudo dnf install glx-utils
```

### 🎯 Support Channels
- **Issues**: Report bugs and request features via [GitHub Issues](https://github.com/galactic-plane/fedora-42-kde-vmware-setup/issues)
- **Documentation**: Check this README and inline script comments
- **Community**: Join discussions in [GitHub Discussions](https://github.com/galactic-plane/fedora-42-kde-vmware-setup/discussions)
- **VMware-specific**: Check VMware Tools status and 3D acceleration configuration

### 🔍 Environment Validation
Verify your system meets requirements:
```bash
# Check Fedora version
cat /etc/fedora-release

# Check available disk space
df -h /

# Check memory
free -h

# Test Microsoft repository access
ping -c 3 packages.microsoft.com
```

## 🔄 Updates and Maintenance

### Updating the Script
```bash
git pull origin main
sudo ./ms-dev-setup-script.sh
```

### Keeping Software Updated
```bash
# Update system packages
sudo dnf update

# Update .NET tools
dotnet tool update -g --all

# Update npm packages
npm update -g
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Development Guidelines
- Test on clean Fedora 42 KDE Plasma installations
- Verify VMware Tools compatibility
- Follow bash best practices
- Add logging for new features
- Update documentation
- Ensure idempotent operations
- Test KDE integration features

## 📝 Changelog

### v2.2.0 (Current)
- ✅ **VMware Auto-Detection**: Intelligent VMware environment detection
- ✅ **Conditional VMware Setup**: User prompt for non-VMware systems with skip option
- ✅ **Enhanced Hardware Detection**: Multiple VMware detection methods (lspci, DMI)
- ✅ **Improved User Experience**: Clear prompts and conditional execution
- ✅ **Better Error Handling**: Graceful fallbacks for optional components
- ✅ Added interactive software list with user confirmation
- ✅ Enhanced user experience with detailed software breakdown
- ✅ Added estimated download sizes and disk space requirements
- ✅ Improved cancellation handling with graceful exit
- ✅ Added comprehensive pre-installation review process

### v2.1.0 (Previous)
- ✅ Added comprehensive security validations
- ✅ Implemented dynamic Fedora version detection
- ✅ Enhanced error handling and logging
- ✅ Fixed privilege escalation issues
- ✅ Added file backup functionality
- ✅ Improved repository management
- ✅ Enhanced version detection

### v2.0.0 (Legacy)
### v1.0.0 (Original)
- Basic installation script
- Manual configuration required
- Limited error handling
- VMware Tools always installed

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Microsoft for providing excellent development tools on Linux
- Fedora Project for the robust Linux distribution and KDE Plasma integration
- VMware for excellent Linux virtualization support
- KDE Community for the outstanding Plasma desktop environment
- Contributors and testers who helped improve this script

## 📞 Support

- **Issues**: Report bugs and request features via GitHub Issues
- **Documentation**: Check this README and inline script comments
- **Community**: Join discussions in GitHub Discussions
- **VMware-specific issues**: Check VMware Tools status and 3D acceleration

---

**Made with ❤️ for the Fedora 42 KDE Plasma and Microsoft development community**
