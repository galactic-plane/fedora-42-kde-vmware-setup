# Fedora 42+ KDE Microsoft Development Stack Setup

Automated installation script for Microsoft development tools on Fedora Linux with KDE Plasma.

## What it installs

**Microsoft Stack:**
- Visual Studio Code
- .NET 9 SDK 
- PowerShell Core
- Azure CLI
- Microsoft Edge
- Azure Functions Core Tools
- Power Platform CLI

**Development Tools:**
- Node.js and npm
- Python 3 with development packages
- Podman (with Docker compatibility aliases)
- GitHub CLI
- Git and build tools (gcc, cmake, make)

**System Tools:**
- Performance monitoring (htop, iotop, sysstat, nethogs)
- VMware Tools (if running in VMware)

## Prerequisites

- Fedora 42+ with KDE Plasma
- Internet connection
- User account with sudo access
- ~4GB free disk space

## Usage

```bash
# Download and run
curl -sSL https://raw.githubusercontent.com/galactic-plane/fedora-42-kde-vmware-setup/main/ms-dev-setup-script.sh | bash

# Or clone and run locally
git clone https://github.com/galactic-plane/fedora-42-kde-vmware-setup.git
cd fedora-42-kde-vmware-setup
chmod +x ms-dev-setup-script.sh
./ms-dev-setup-script.sh
```

## Features

- **VMware Detection**: Automatically detects VMware environments and installs appropriate tools
- **Interactive Confirmation**: Shows what will be installed before proceeding
- **Comprehensive Logging**: All actions logged to `/var/log/ms-dev-setup.log`
- **Backup System**: Creates backups of modified configuration files
- **Error Handling**: Validates system requirements and handles installation failures
- **Shell Configuration**: Adds development aliases and PATH updates

## Post-Installation

The script automatically configures:
- Git user settings (prompts if not set)
- .NET HTTPS development certificates
- Podman Docker compatibility
- Development directory structure in `~/Development/`
- Shell aliases for common tasks

## Verification

After installation, verify components:
```bash
# Core tools
dotnet --version
az --version
code --version
pwsh --version

# Development tools
node --version
podman version
func --version  # Azure Functions Core Tools
pac help        # Power Platform CLI
```

## VS Code Extensions

A curated list of Microsoft and development-focused extensions is provided in `vscode-extensions.txt`. Install with:
```bash
cat vscode-extensions.txt | xargs -L 1 code --install-extension
```

## Troubleshooting

**Common Issues:**
- **Permission errors**: Ensure user has sudo access
- **Network timeouts**: Check internet connection and firewall settings
- **Package conflicts**: Update system first with `sudo dnf update`
- **VMware detection fails**: Manual confirmation prompt will appear

**Logs and Recovery:**
- Installation log: `/var/log/ms-dev-setup.log`
- Configuration backups: `/var/backups/ms-dev-setup/`
- Re-run script safely - it handles existing installations

## Supported Versions

- Fedora 42+ (optimized for DNF5)
- Works with both x86_64 physical and virtual machines
- Tested on VMware Workstation/ESXi environments

## License

MIT License - see LICENSE file for details.
