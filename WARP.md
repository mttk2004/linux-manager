# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Project Overview

Linux Manager is a powerful Arch Linux system management tool written in Bash that automates system setup tasks. It features a modular architecture with a CLI interface specifically designed for Vietnamese users setting up new Arch Linux installations.

**Core Purpose**: Automate installation of essential packages, system configuration, and development environment setup (PHP/Composer/Laravel, NodeJS/NPM) through an interactive terminal interface.

## Architecture

### Modular Structure
The project follows a clean modular architecture:

- **Core System** (`src/core/`): Foundation modules that provide configuration, UI components, and utility functions
- **Feature Modules** (`src/modules/`): Self-contained functionality modules organized by domain
- **Data Management** (`src/data/`): Static configuration files and package lists
- **Entry Point** (`bin/linux-manager`): Main executable that orchestrates the entire system

### Key Components

**Core Modules**:
- `src/core/config.sh`: Global configuration, logging, package list management
- `src/core/ui.sh`: Terminal UI components with ASCII art, colors, animations  
- `src/core/utils.sh`: Utility functions for user input, confirmations, messaging

**Feature Modules**:
- `src/modules/packages/`: Package management (Pacman, AUR, Flatpak)
- `src/modules/dev/php/`: PHP environment management (build from source, Composer, Laravel)
- `src/modules/dev/nodejs/`: NodeJS environment management (NVM, NPM)  
- `src/modules/system/`: System configuration management

**Data Files**:
- `src/data/packages/*.list`: Package lists organized by category (pacman.list, aur.list, dev.list, multimedia.list)
- `src/data/configs/`: Sample configuration templates for bash, fish, vim

## Common Development Commands

### Running the Application
```bash
# Make executable and run
chmod +x bin/linux-manager
./bin/linux-manager

# Alternative: Run setup first (creates directory structure)  
chmod +x setup.sh
./setup.sh
./bin/linux-manager

# For system-wide access (optional)
sudo ln -s /path/to/linux-manager/bin/linux-manager /usr/local/bin/linux-manager
```

### Development and Testing
```bash
# Test specific modules (source and call functions)
source src/core/config.sh
source src/core/ui.sh  
source src/modules/packages/manager.sh

# Check syntax of shell scripts
bash -n bin/linux-manager
bash -n src/core/*.sh
find src/ -name "*.sh" -exec bash -n {} \;

# View logs
tail -f logs/manager_$(date +%Y%m%d).log

# Clean logs
rm -f logs/*.log
```

### Project Management
```bash
# Install/Setup with new directory structure
./install.sh

# Uninstall (removes src/, bin/, logs/ but keeps original files)
./uninstall.sh

# Create symbolic link for global access
sudo ln -s $(pwd)/bin/linux-manager /usr/local/bin/linux-manager
```

## Development Guidelines

### Module Creation
When adding new modules:

1. **Create module directory**: `src/modules/your-module/`
2. **Create manager.sh**: Main entry point with menu and orchestration functions
3. **Implement required functions**: Follow existing patterns for UI consistency
4. **Update main script**: Add module loading and menu integration in `bin/linux-manager`
5. **Follow naming**: Use `manage_*_environment()` for main module functions

### Code Patterns

**Module Loading Pattern**:
```bash
load_module() {
    local module_path="$MODULES_DIR/$1"
    if [ -f "$module_path" ]; then
        source "$module_path"
        return 0
    else
        echo "Lỗi: Không tìm thấy module $1"
        return 1
    fi
}
```

**Menu Display Pattern**:
All modules follow consistent menu styling using core UI functions from `src/core/ui.sh`. Menus use:
- ASCII art headers with `LIGHT_CYAN` color  
- Numbered options with icons and descriptions
- Consistent spacing and visual separators

**User Input Pattern**:
```bash
# Single key input without Enter
choice=$(read_single_key)

# Confirmation dialogs
if confirm_yn "Do you want to proceed?"; then
    # proceed
fi
```

### Package Management
Package lists are stored as plain text files in `src/data/packages/`:
- One package name per line
- No comments or extra formatting  
- Loaded dynamically by config.sh using `mapfile -t` arrays

### Logging
All actions are logged via functions in `src/core/config.sh`:
```bash
log_info "User selected: Install packages"
log_error "Failed to install package"  
log_warning "Package not found"
```

Logs are stored in `logs/manager_YYYYMMDD.log` format.

## File Organization

```
linux-manager/
├── bin/linux-manager          # Main executable entry point
├── src/
│   ├── core/                  # Core system modules
│   │   ├── config.sh         # Configuration and logging
│   │   ├── ui.sh             # Terminal UI components  
│   │   └── utils.sh          # Utility functions
│   ├── modules/              # Feature modules
│   │   ├── packages/         # Package management
│   │   ├── system/           # System configuration
│   │   └── dev/              # Development environments
│   └── data/                 # Static data
│       ├── packages/         # Package lists (*.list files)
│       └── configs/          # Configuration templates
├── logs/                     # Application logs
├── config.sh                # Legacy configuration (for compatibility)
├── setup.sh                 # Enhanced setup with UI
├── install.sh               # Basic directory structure setup
└── uninstall.sh             # Cleanup script
```

## Vietnamese Language Support

The entire interface is in Vietnamese - maintain this when making modifications:
- All user-facing messages should be in Vietnamese
- Menu options and confirmations use Vietnamese text
- Log messages can be in Vietnamese for consistency  
- ASCII art headers are part of the brand identity

## Target Environment

- **OS**: Arch Linux (and derivatives: Manjaro, EndeavourOS, CachyOS)
- **Shell**: Bash (not compatible with other shells)
- **Package Managers**: Pacman (official), AUR helpers (yay/paru), Flatpak
- **Privileges**: Requires sudo access for package installation
- **Terminal**: Designed for modern terminals with Unicode and color support

## Testing Considerations

When testing modules:
- Test on clean Arch Linux installations 
- Verify package manager detection (pacman, AUR helpers, flatpak)
- Test module loading and unloading
- Verify log file creation and permissions
- Test user input handling and menu navigation
- Check directory structure requirements are met
