# Linux Manager V2 - Architecture Documentation

## Overview

Linux Manager V2 is a complete architectural overhaul of the original Linux Manager, featuring a modern modular system with advanced capabilities for managing Arch Linux installations. This document provides comprehensive information about the V2 architecture, installation, and migration from V1.

## Version Information

- **Version**: 2.0.0
- **Target OS**: Arch Linux (and derivatives)
- **Shell**: Bash 4.0+
- **Architecture**: Modular event-driven system
- **Language**: Vietnamese (Vietnamese interface)

## Key Features

### 🚀 New in V2

1. **Advanced Module System**
   - Module discovery and dependency resolution
   - Lazy loading for performance
   - Health monitoring and auto-recovery
   - Version management and compatibility checking

2. **Enhanced User Interface**
   - Modern terminal UI with themes and animations
   - Progress bars and notifications
   - Multi-language support (Vietnamese primary)
   - Responsive design for various terminal sizes

3. **Performance Optimizations**
   - Caching system for package information
   - Background tasks and async operations
   - Memory-efficient resource management
   - Configurable performance settings

4. **Developer Tools**
   - Module CLI for development and debugging
   - Comprehensive testing framework
   - Event system for inter-module communication
   - System diagnostics and health monitoring

5. **Extensibility**
   - Plugin architecture for custom modules
   - Event-driven communication system
   - Registry system for module metadata
   - API for third-party integration

## Architecture Components

### Core System Structure

```
linux-manager-v2/
├── bin/
│   ├── linux-manager-v2          # Main V2 executable
│   ├── linux-manager             # Symlink to V2 (replaces V1)
│   ├── module-cli                # Module management CLI
│   └── linux-manager-v1-backup   # V1 backup
├── src/
│   ├── core/
│   │   ├── v2/                   # V2 Core Components
│   │   │   ├── system_init.sh    # System initialization
│   │   │   ├── ui_system.sh      # Enhanced UI system
│   │   │   ├── module_system.sh  # Module management
│   │   │   ├── event_system.sh   # Event handling
│   │   │   └── perf_system.sh    # Performance monitoring
│   │   └── v1/                   # Legacy V1 components
│   ├── modules/
│   │   ├── v2/                   # V2 Enhanced modules
│   │   └── registry/             # Module registry
│   ├── data/                     # Static data and configs
│   └── utils/                    # Utility functions
├── tests/                        # Comprehensive test suite
├── logs/                         # Application logs
└── docs/                         # Documentation
```

### Core Modules

#### 1. System Initialization (`src/core/v2/system_init.sh`)
- **Purpose**: Orchestrates system startup and component initialization
- **Key Features**:
  - Dependency-ordered initialization
  - Health checks and validation
  - Graceful shutdown handling
  - Component reinitialization support

#### 2. Module System (`src/core/v2/module_system.sh`)
- **Purpose**: Advanced module management and lifecycle
- **Key Features**:
  - Dynamic module discovery
  - Dependency resolution
  - Lazy loading with performance optimization
  - Health monitoring and auto-recovery
  - Version compatibility checking

#### 3. Enhanced UI System (`src/core/v2/ui_system.sh`)
- **Purpose**: Modern terminal user interface
- **Key Features**:
  - Color themes and customization
  - Progress indicators and animations
  - Responsive menu system
  - Status notifications
  - Multi-language support

#### 4. Event System (`src/core/v2/event_system.sh`)
- **Purpose**: Inter-module communication and coordination
- **Key Features**:
  - Event-driven architecture
  - Publish-subscribe pattern
  - Event filtering and routing
  - Asynchronous event handling

#### 5. Performance System (`src/core/v2/perf_system.sh`)
- **Purpose**: System performance monitoring and optimization
- **Key Features**:
  - Resource usage tracking
  - Performance metrics collection
  - Caching system management
  - Memory optimization

### Module Architecture

Modules in V2 follow a standardized structure:

```bash
# Module structure example
src/modules/v2/example_module/
├── module.json           # Module metadata
├── manager.sh           # Main module logic
├── config.sh           # Module configuration
├── events.sh           # Event handlers
└── tests/              # Module tests
```

#### Module Metadata (`module.json`)
```json
{
    "name": "example_module",
    "version": "1.0.0",
    "description": "Example module for demonstration",
    "author": "Linux Manager Team",
    "dependencies": ["core", "ui"],
    "provides": ["example_service"],
    "api_version": "2.0",
    "health_check": "check_module_health",
    "events": {
        "subscribes": ["system.ready", "ui.theme_changed"],
        "publishes": ["module.status_changed"]
    }
}
```

## Installation Guide

### System Requirements

- **Operating System**: Arch Linux, Manjaro, EndeavourOS, or derivatives
- **Shell**: Bash 4.0 or later
- **Memory**: Minimum 512MB available RAM
- **Disk Space**: At least 100MB free space
- **Network**: Internet connection for package installation
- **Privileges**: sudo access required

### Installation Options

#### Option 1: Quick Installation (Recommended)
```bash
# Clone repository
git clone https://github.com/your-repo/linux-manager.git
cd linux-manager

# Run V2 installer
./install-v2.sh
```

#### Option 2: Custom Installation
```bash
# Interactive installation with options
./install-v2.sh

# Unattended installation with defaults
./install-v2.sh --unattended

# System-wide installation (requires root)
sudo ./install-v2.sh
```

#### Option 3: Manual Installation
```bash
# Make executable and run directly
chmod +x bin/linux-manager-v2
./bin/linux-manager-v2
```

### Installation Locations

- **System-wide** (root): `/opt/linux-manager/`
- **User-local**: `~/.local/share/linux-manager/`
- **Config**: `/etc/linux-manager/` or `~/.config/linux-manager/`
- **Logs**: `/var/log/linux-manager/` or `~/.local/share/linux-manager/logs/`

## Migration from V1 to V2

### Automatic Migration

The V2 installer automatically:
1. Backs up V1 executable as `linux-manager-v1-backup`
2. Creates symlink from `linux-manager` to `linux-manager-v2`
3. Preserves V1 configuration and data
4. Maintains compatibility with existing workflows

### Manual Migration Steps

If you need to manually migrate:

```bash
# 1. Backup V1 system
cp bin/linux-manager bin/linux-manager-v1-backup

# 2. Install V2 components
./install-v2.sh

# 3. Test V2 functionality
./bin/linux-manager-v2 --version

# 4. Switch default command
ln -sf bin/linux-manager-v2 bin/linux-manager
```

### Data Migration

V2 maintains compatibility with V1 data:
- Package lists: Automatically imported
- Configuration: Converted to V2 format
- Logs: Preserved and enhanced
- User settings: Migrated with improvements

## Configuration

### Main Configuration (`config.conf`)

```bash
# Linux Manager V2 Configuration

# Core Settings
APP_VERSION=2.0.0
INSTALLATION_PATH=/path/to/linux-manager
INSTALLATION_TYPE=system  # or 'user'

# UI Settings
UI_THEME=default          # default, dark, light, minimal
UI_ANIMATION_ENABLED=true
UI_LANGUAGE=vi           # Vietnamese primary

# Performance Settings
PERF_ENABLED=true
PERF_CACHE_ENABLED=true
CACHE_TTL=300           # seconds

# Module Settings
MODULE_LAZY_LOADING=true
MODULE_HEALTH_MONITORING=true
MODULE_AUTO_RECOVERY=true

# Logging Settings
LOG_LEVEL=INFO          # DEBUG, INFO, WARN, ERROR
LOG_ROTATION=true
MAX_LOG_SIZE=10M
```

### Module Configuration

Each module can have its own configuration:

```bash
# Module-specific configuration
EXAMPLE_MODULE_ENABLED=true
EXAMPLE_MODULE_DEBUG=false
EXAMPLE_MODULE_CACHE_SIZE=1000
```

## Usage Guide

### Basic Commands

```bash
# Run Linux Manager V2
linux-manager

# Show version information
linux-manager --version

# Run in debug mode
linux-manager --debug

# Show help
linux-manager --help
```

### Module Management CLI

```bash
# List available modules
module-cli list

# Show module information
module-cli info module_name

# Enable/disable modules
module-cli enable module_name
module-cli disable module_name

# Check module health
module-cli health
module-cli health module_name

# Development commands
module-cli develop module_name
module-cli test module_name
```

### Advanced Usage

```bash
# System diagnostics
linux-manager --diagnostics

# Performance monitoring
linux-manager --performance

# Export configuration
linux-manager --export-config > my-config.conf

# Import configuration
linux-manager --import-config my-config.conf
```

## Development Guide

### Module Development

#### 1. Create Module Structure
```bash
mkdir -p src/modules/v2/my_module
cd src/modules/v2/my_module
```

#### 2. Create Module Metadata
```bash
cat > module.json << 'EOF'
{
    "name": "my_module",
    "version": "1.0.0",
    "description": "My custom module",
    "author": "Your Name",
    "dependencies": ["core", "ui"],
    "provides": ["my_service"],
    "api_version": "2.0"
}
EOF
```

#### 3. Create Module Manager
```bash
cat > manager.sh << 'EOF'
#!/bin/bash
# My Module Manager

# Module initialization
init_my_module() {
    log_info "Initializing my module"
    # Initialization code here
}

# Module main function
manage_my_module() {
    show_module_menu "My Module" "my_module_menu_items"
}

# Module menu items
my_module_menu_items() {
    echo "1. Option 1"
    echo "2. Option 2"
    echo "0. Return"
}

# Health check function
check_my_module_health() {
    # Health check logic
    return 0  # 0 = healthy, 1 = unhealthy
}
EOF
```

#### 4. Register Module
```bash
module-cli register my_module
```

### Testing

```bash
# Run all tests
./tests/run_tests.sh

# Run specific test suite
./tests/run_tests.sh unit
./tests/run_tests.sh integration

# Test specific module
module-cli test my_module
```

### Debugging

```bash
# Enable debug mode
export LINUX_MANAGER_DEBUG=true

# Run with verbose logging
linux-manager --debug --verbose

# Check system health
module-cli health --detailed
```

## Performance Optimization

### Caching System

V2 includes an intelligent caching system:
- Package information caching
- Module metadata caching
- Configuration caching
- Network request caching

### Lazy Loading

Modules are loaded on-demand:
- Faster startup times
- Reduced memory usage
- Better resource management

### Background Tasks

Non-critical operations run in background:
- Package database updates
- Health monitoring
- Log rotation
- Cache cleanup

## Troubleshooting

### Common Issues

#### 1. Module Not Found
```bash
# Check module registry
module-cli list --all

# Re-scan modules
module-cli scan

# Register missing module
module-cli register module_name
```

#### 2. Performance Issues
```bash
# Check system health
module-cli health --detailed

# Clear caches
linux-manager --clear-cache

# Optimize performance
linux-manager --optimize
```

#### 3. Configuration Issues
```bash
# Validate configuration
linux-manager --validate-config

# Reset to defaults
linux-manager --reset-config

# Show effective configuration
linux-manager --show-config
```

### Debug Information

```bash
# System information
linux-manager --system-info

# Module diagnostics
module-cli diagnose

# Export debug logs
linux-manager --export-logs debug-$(date +%Y%m%d).tar.gz
```

## API Reference

### Core API Functions

```bash
# Module registration
register_module "module_name" "module_path"

# Event system
publish_event "event_name" "event_data"
subscribe_to_event "event_name" "callback_function"

# Configuration
get_config "key" "default_value"
set_config "key" "value"

# Logging
log_info "message"
log_error "message"
log_debug "message"

# UI functions
show_progress "message" progress_percentage
show_notification "message" "type"
```

### Module API

```bash
# Module lifecycle
init_module
start_module
stop_module
cleanup_module

# Health monitoring
check_module_health
report_module_status "status" "message"

# Inter-module communication
send_message "target_module" "message"
broadcast_message "message"
```

## Changelog

### Version 2.0.0 (Current)
- Complete architectural rewrite
- Advanced module system with dependency resolution
- Enhanced UI with themes and animations
- Performance monitoring and optimization
- Event-driven inter-module communication
- Comprehensive testing framework
- Developer tools and CLI

### Migration from V1
- Automatic backup and migration
- Preserved functionality and data
- Enhanced features and capabilities
- Maintained Vietnamese language interface

## Contributing

### Development Setup

```bash
# Clone and setup development environment
git clone https://github.com/your-repo/linux-manager.git
cd linux-manager

# Install development dependencies
./install-v2.sh --dev

# Run tests
./tests/run_tests.sh
```

### Contribution Guidelines

1. Follow existing code style and patterns
2. Write comprehensive tests for new features
3. Update documentation for changes
4. Maintain Vietnamese language interface
5. Ensure backward compatibility where possible

### Code Style

- Use meaningful variable names
- Comment complex logic
- Follow Bash best practices
- Maintain consistent formatting
- Use error handling and logging

## Support and Community

### Documentation
- **Architecture Guide**: This document
- **WARP.md**: Development guidelines
- **README.md**: Quick start guide
- **Tests Documentation**: `tests/README.md`

### Getting Help
- Check troubleshooting section
- Run system diagnostics
- Review logs and debug information
- Use module-cli for detailed information

### Reporting Issues
- Include system information (`linux-manager --system-info`)
- Provide debug logs
- Describe steps to reproduce
- Specify expected vs actual behavior

## License

Linux Manager V2 is released under the MIT License. See LICENSE file for details.

---

**Note**: This documentation covers Linux Manager V2 architecture and capabilities. For V1-specific information, refer to the legacy documentation in V1 backup files.
