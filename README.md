# Fedora-42-MS-Setup

**Microsoft Development Stack Automated Installer for Fedora 42+ with KDE Plasma**

A comprehensive automation script that sets up a complete Microsoft development environment on Fedora Linux with KDE Plasma desktop. The script intelligently detects VMware environments and configures appropriate integrations with extensive logging and error handling.

## What This Script Installs

### 🏢 Microsoft Development Stack
- **Visual Studio Code** - Microsoft's flagship code editor
- **.NET 9 SDK** - Complete .NET development framework with runtime and ASP.NET Core
- **PowerShell Core** - Cross-platform PowerShell (from Microsoft repo or GitHub releases)
- **Microsoft Edge** - Chromium-based web browser for testing
- **Azure CLI** - Command-line interface for Azure services
- **Azure Functions Core Tools** - Local development and testing for Azure Functions (via npm)
- **Power Platform CLI** - Low-code development tools for Power Apps, Power Automate, and Power Pages

### 🛠️ Essential Development Tools
- **Git** - Version control with automatic user configuration
- **Node.js & npm** - JavaScript runtime with package manager
- **Python 3** - Complete Python development environment with pip, setuptools, and virtualenv
- **GitHub CLI** - Official GitHub command-line interface
- **Podman** - Container management with Docker compatibility aliases
- **Essential Build Tools** - gcc, g++, make, cmake, autoconf, automake, and development headers

### 📊 System Performance & Monitoring Tools
- **htop** - Interactive process viewer
- **iotop** - I/O monitoring utility
- **sysstat** - System performance statistics
- **net-tools** - Network configuration utilities
- **nethogs** - Network bandwidth monitoring per process
- **mesa-utils/glx-utils** - OpenGL utilities for graphics diagnostics

### 🖥️ VMware Integration (Auto-detected)
- **VMware Tools** - Guest integration for better performance and features
- **3D Acceleration Support** - Enhanced graphics for VMware environments
- **Clipboard Sharing** - Seamless copy/paste between host and guest
- **Automatic Service Configuration** - vmtoolsd service setup and monitoring

## Prerequisites

- **Operating System**: Fedora 42+ with KDE Plasma Desktop Environment
- **Network**: Active internet connection for package downloads
- **Permissions**: User account with sudo privileges
- **Storage**: Minimum 4GB free disk space
- **Memory**: At least 2GB RAM recommended for installation process

## Installation Methods

### Quick Install (Recommended)
```bash
# Download and execute directly
curl -sSL https://raw.githubusercontent.com/galactic-plane/fedora-42-ms-setup/main/ms-dev-setup-script.sh | bash
```

### Local Clone Method
```bash
# Clone repository and run locally
git clone https://github.com/galactic-plane/fedora-42-ms-setup.git
cd fedora-42-ms-setup
chmod +x ms-dev-setup-script.sh
./ms-dev-setup-script.sh
```

## Key Features

### 🔍 Intelligent System Detection
- **Automated VMware Detection** - Uses multiple methods (lspci, DMI, processes) to detect VMware environments
- **Fedora Version Validation** - Ensures compatibility with Fedora 42+ and DNF5 package manager
- **System Requirements Check** - Validates disk space, network connectivity, and permissions

### 🛡️ Safety & Reliability
- **Comprehensive Logging** - All actions logged to `/var/log/ms-dev-setup.log` with timestamps
- **Configuration Backups** - Automatic backup of modified system files to `/var/backups/ms-dev-setup/`
- **Error Handling** - Graceful failure recovery with detailed error messages
- **User Confirmation** - Interactive approval before making system changes
- **Rollback Safety** - Can be re-run safely; handles existing installations intelligently

### ⚙️ Automated Configuration

The script performs extensive post-installation configuration:

#### Shell Environment Setup
- **Development Aliases** - Convenient shortcuts for common tasks:
  - `sysmon` → `htop` (system monitoring)
  - `docker` → `podman` (container compatibility)
  - `dev` → `cd ~/Development` (quick navigation)
  - Git shortcuts (`gs`, `ga`, `gc`, `gp`, `gl`)
  - Azure shortcuts (`az-login`, `az-subs`)
- **PATH Configuration** - Adds .NET tools and npm global bins to user PATH
- **Development Directories** - Creates organized folder structure in `~/Development/`

#### Microsoft Services Integration
- **.NET HTTPS Certificates** - Automatic setup and trust for local development
- **Git Configuration** - Interactive setup of user.name and user.email if not configured
- **Podman Docker Compatibility** - Aliases and socket configuration for seamless Docker workflow
- **Power Platform CLI** - Automatic installation via .NET global tools

#### VMware Optimization (When Detected)
- **VMware Tools Service** - Automatic installation, enabling, and startup
- **3D Acceleration** - Detection and configuration of VMware SVGA drivers
- **Guest Integration** - Clipboard sharing, time synchronization, and display optimization

## Directory Structure Created

```
~/Development/
├── dotnet/          # .NET projects and tools
├── nodejs/          # Node.js applications
├── python/          # Python projects and virtual environments  
├── azure/           # Azure-related projects and scripts
├── scripts/         # Development and automation scripts
└── repos/           # Git repositories
```

## VS Code Extensions

A comprehensive collection of 70+ curated extensions for Microsoft and multi-language development is included in [`vscode-extensions.txt`](vscode-extensions.txt). Categories include:

- **Microsoft Stack**: C#, .NET, PowerShell, Azure tools
- **Power Platform**: Power Apps, Power Automate development tools
- **Cloud Development**: Azure Functions, Bicep, containers, GitHub integration
- **Multi-Language Support**: Python, Rust, Java, JavaScript/TypeScript
- **AI/ML Tools**: GitHub Copilot, Jupyter notebooks, AI Studio integration
- **Web Development**: HTML/CSS utilities, live server, debugging tools
- **DevOps**: Azure Pipelines, Docker, remote development

### Install Extensions
```bash
# Install all extensions from the curated list
cat vscode-extensions.txt | xargs -L 1 code --install-extension

# Or install selectively by editing the file first
```

## Verification Commands

After installation, verify your environment with these commands:

```bash
# Core Microsoft Stack
dotnet --info                    # .NET SDK information
az --version                     # Azure CLI version
code --version                   # VS Code version  
pwsh --version                   # PowerShell version
pac help                         # Power Platform CLI (if installed)

# Development Tools
node --version                   # Node.js version
npm --version                    # npm version
git --version                    # Git version
podman version                   # Container management
gh --version                     # GitHub CLI

# Azure Functions (if installed)
func --version                   # Azure Functions Core Tools

# System Monitoring
htop                            # Interactive process monitor
iostat -x 1                     # Disk I/O statistics  
nethogs                         # Network bandwidth per process

# Test aliases
sysmon                          # Should launch htop
docker ps                       # Should run podman ps
```

## Troubleshooting

### Common Installation Issues

**Permission Denied Errors**
```bash
# Ensure user has sudo access
sudo -v

# Check if user is in wheel group
groups $USER
```

**Network/Repository Issues**
```bash
# Update system packages first
sudo dnf update -y

# Clear DNF cache
sudo dnf clean all && sudo dnf makecache

# Check Microsoft repository status
sudo dnf repolist | grep -i microsoft
```

**VMware Detection Problems**
- Manual confirmation prompt appears if auto-detection fails
- VMware Tools can be installed separately: `sudo dnf install open-vm-tools open-vm-tools-desktop`
- Verify VMware environment: `lspci | grep -i vmware`

**PowerShell Installation Fallback**
- Script automatically tries GitHub releases if Microsoft repo fails
- Manual installation: Download RPM from [PowerShell GitHub releases](https://github.com/PowerShell/PowerShell/releases)

### Log Analysis
```bash
# View installation log
sudo tail -f /var/log/ms-dev-setup.log

# Search for errors
sudo grep -i error /var/log/ms-dev-setup.log

# Check backup files
ls -la /var/backups/ms-dev-setup/
```

### Recovery Options
- **Safe Re-run**: Script can be executed multiple times safely
- **Configuration Restore**: Backup files available in `/var/backups/ms-dev-setup/`
- **Selective Installation**: Comment out sections in script for partial installation
- **Manual Cleanup**: Remove Microsoft repositories from `/etc/yum.repos.d/` if needed

## Post-Installation Recommendations

### Additional Configuration
1. **Configure Azure CLI**: `az login` and set default subscription
2. **Setup GitHub CLI**: `gh auth login` for repository access  
3. **Initialize Git repositories**: Use aliases `dev` and `repos` for quick navigation
4. **Test .NET development**: Create sample project with `dotnet new console`
5. **Verify Podman Docker compatibility**: `docker run hello-world`

### VS Code Workspace Setup
1. Install extensions from `vscode-extensions.txt`
2. Configure integrated terminal to use bash
3. Setup workspace folders in `~/Development/`
4. Configure PowerShell debugging and Azure integration

### Power Platform Development
```bash
# Install Power Platform CLI (if not auto-installed)
dotnet tool install --global Microsoft.PowerApps.CLI.Tool

# Verify installation
pac help

# Login to your environment  
pac auth create
```

## System Requirements

| Component | Minimum | Recommended |
|-----------|---------|-------------|
| **Fedora Version** | 42+ | Latest stable |
| **Desktop Environment** | KDE Plasma | KDE Plasma 6+ |
| **RAM** | 2GB | 4GB+ |
| **Storage** | 4GB free | 8GB+ free |
| **Network** | Broadband | Reliable broadband |
| **CPU** | x86_64 | Multi-core x86_64 |

## Contributing

Contributions are welcome! Please feel free to submit issues, feature requests, or pull requests.

### Development Setup
1. Fork the repository
2. Test changes in a VM environment
3. Ensure compatibility with Fedora 42+ and DNF5
4. Update documentation for any new features
5. Submit pull request with detailed description

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Support

- **Issues**: [GitHub Issues](https://github.com/galactic-plane/fedora-42-ms-setup/issues)
- **Discussions**: [GitHub Discussions](https://github.com/galactic-plane/fedora-42-ms-setup/discussions)
- **Documentation**: This README and inline script comments
- **Logs**: Installation logs saved to `/var/log/ms-dev-setup.log`

---

**Estimated Installation Time**: 15-30 minutes (depending on internet speed)  
**Estimated Download Size**: 1-2 GB  
**Estimated Disk Usage**: 3-4 GB after installation
