# Microsoft Development Stack Setup for Fedora Linux

A comprehensive, production-ready script to set up a complete Microsoft development environment on Fedora Linux. This script installs and configures all essential tools for modern development with Microsoft technologies.

## 🚀 Quick Start

```bash
# Clone the repository
git clone https://github.com/yourusername/fedora-setup.git
cd fedora-setup

# Make the script executable
chmod +x ms-dev-setup-script.sh

# Run the setup (requires sudo)
sudo ./ms-dev-setup-script.sh
```

## 📋 What Gets Installed

### Core Microsoft Stack
- **Visual Studio Code** - Premier code editor with extensions ecosystem
- **Microsoft Edge** - Modern web browser with developer tools
- **.NET 9 SDK** - Latest .NET development platform
- **Azure CLI** - Command-line tools for Azure cloud services
- **Power Platform CLI** - Tools for Power Platform development

### Development Tools
- **Git** - Version control system
- **Node.js & npm** - JavaScript runtime and package manager
- **Python 3 & pip** - Python development environment
- **Podman** - Container management (Docker alternative)

### System Tools
- **htop** - Interactive process viewer
- **iotop** - I/O monitoring tool
- **sysstat** - System performance tools
- **net-tools** - Network utilities
- **nethogs** - Network bandwidth monitor
- **mesa-utils** - Graphics utilities

## ✨ Features

### 🔒 Security & Reliability
- **Privilege validation** - Ensures script runs with proper permissions
- **System validation** - Verifies Fedora compatibility and network connectivity
- **File backups** - Automatically backs up modified system files
- **Input validation** - Validates downloaded files before installation
- **Error handling** - Graceful failure handling with detailed error messages

### 🔧 Smart Configuration
- **Dynamic version detection** - Automatically detects Fedora version
- **Idempotent execution** - Safe to run multiple times
- **Duplicate prevention** - Prevents duplicate PATH entries and aliases
- **Repository management** - Safely manages Microsoft package repositories

### 📊 Comprehensive Logging
- **Activity logging** - All actions logged to `/var/log/ms-dev-setup.log`
- **Progress indicators** - Clear visual feedback during installation
- **Version reporting** - Detailed summary of installed software versions
- **System information** - Hardware and system configuration report

## 🛠️ System Requirements

- **Operating System**: Fedora Linux (any supported version)
- **Architecture**: x86_64
- **Privileges**: Root access (sudo)
- **Network**: Internet connectivity to Microsoft repositories
- **Disk Space**: ~2GB free space for installations

## 📖 Usage

### Basic Usage
```bash
sudo ./ms-dev-setup-script.sh
```

### Post-Installation Steps
After the script completes, run these commands as your regular user (not root):

```bash
# Enable Podman socket for container management
systemctl --user enable --now podman.socket

# Trust .NET HTTPS development certificate
dotnet dev-certs https --trust

# Reload shell configuration
source ~/.bashrc
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

### Installation Steps
1. **System Updates** - Updates all system packages
2. **Development Tools** - Installs essential development utilities
3. **Microsoft Repositories** - Configures Microsoft package sources
4. **Microsoft Applications** - Installs VS Code, Edge, and .NET
5. **Azure Tools** - Installs Azure CLI and Functions Core Tools
6. **Power Platform** - Installs Power Platform CLI
7. **System Configuration** - Configures PATH, aliases, and certificates
8. **VMware Integration** - Verifies VMware Tools (if applicable)

## 🚨 Troubleshooting

### Common Issues

**Permission Denied**
```bash
# Ensure script is executable
chmod +x ms-dev-setup-script.sh

# Run with sudo
sudo ./ms-dev-setup-script.sh
```

**Network Issues**
```bash
# Check internet connectivity
ping packages.microsoft.com

# Check DNS resolution
nslookup packages.microsoft.com
```

**Repository Conflicts**
```bash
# Clear DNF cache
sudo dnf clean all

# Rebuild cache
sudo dnf makecache
```

### Log Analysis
Check the detailed log for troubleshooting:
```bash
sudo tail -f /var/log/ms-dev-setup.log
```

### Manual Package Installation
If any package fails to install automatically:
```bash
# Azure Functions Core Tools
npm install -g azure-functions-core-tools@4

# Individual Microsoft packages
sudo dnf install code
sudo dnf install microsoft-edge-stable
sudo dnf install dotnet-sdk-9.0
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
- Test on clean Fedora installations
- Follow bash best practices
- Add logging for new features
- Update documentation
- Ensure idempotent operations

## 📝 Changelog

### v2.0.0 (Current)
- ✅ Added comprehensive security validations
- ✅ Implemented dynamic Fedora version detection
- ✅ Enhanced error handling and logging
- ✅ Fixed privilege escalation issues
- ✅ Added file backup functionality
- ✅ Improved repository management
- ✅ Enhanced version detection

### v1.0.0 (Legacy)
- Basic installation script
- Manual configuration required
- Limited error handling

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Microsoft for providing excellent development tools on Linux
- Fedora Project for the robust Linux distribution
- Contributors and testers who helped improve this script

## 📞 Support

- **Issues**: Report bugs and request features via GitHub Issues
- **Documentation**: Check this README and inline script comments
- **Community**: Join discussions in GitHub Discussions

---

**Made with ❤️ for the Fedora and Microsoft development community**
