#!/bin/bash

# Source the utils file
source ./utils.sh

# Function to check if a package is installed (works for both pacman and AUR packages)
is_package_installed() {
    # Use pacman -Qi to check if package exists
    # (both regular pacman packages and AUR packages are managed by pacman once installed)
    if pacman -Qi "$1" &> /dev/null; then
        return 0 # Package is installed
    else
        return 1 # Package is not installed
    fi
}

# Enhanced package installation prompt using the single keypress function
ask_install_package() {
    local package="$1"
    local source="$2"

    echo -e "${LIGHT_BLUE}╔═══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${LIGHT_BLUE}║  ${ICON_PACKAGE} ${WHITE}${BOLD}Package Installation${NC}                                                ${LIGHT_BLUE}║${NC}"
    echo -e "${LIGHT_BLUE}╠═══════════════════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${LIGHT_BLUE}║                                                                               ║${NC}"
    echo -e "${LIGHT_BLUE}║  ${YELLOW}Package:${NC} ${WHITE}${BOLD}$package${NC}                                                          ${LIGHT_BLUE}║${NC}"
    echo -e "${LIGHT_BLUE}║  ${YELLOW}Source:${NC} ${LIGHT_CYAN}$source${NC}                                                           ${LIGHT_BLUE}║${NC}"
    echo -e "${LIGHT_BLUE}║                                                                               ║${NC}"
    echo -e "${LIGHT_BLUE}╚═══════════════════════════════════════════════════════════════════════════════╝${NC}"

    # Use the confirm_yn function instead of manual read
    if confirm_yn "${LIGHT_CYAN}${ICON_ARROW} ${WHITE}Do you want to install ${BOLD}$package${NC}${WHITE}?${NC}" "y"; then
        return 0 # User selected yes
    else
        return 1 # User selected no
    fi
}

# Enhanced installation status display
show_package_status() {
    local package="$1"
    local status="$2"
    local icon=""
    local color=""

    case $status in
        "installed")
            icon="${ICON_CHECK}"
            color="${GREEN}"
            ;;
        "skipped")
            icon="${ICON_CROSS}"
            color="${YELLOW}"
            ;;
        "already")
            icon="${ICON_INFO}"
            color="${BLUE}"
            ;;
        "failed")
            icon="${ICON_CROSS}"
            color="${LIGHT_RED}"
            ;;
    esac

    echo -e "${color}  ${icon} ${WHITE}${package}${NC} ${color}${status}${NC}"
}

# Loop over $PACMAN_PACKAGES_TO_INSTALL and $AUR_PACKAGES_TO_INSTALL
# and ask the user to confirm installation of each package.
install_packages() {
    clear
    echo -e "${LIGHT_CYAN}"
    echo "    ██████╗  █████╗  ██████╗██╗  ██╗ █████╗  ██████╗ ███████╗"
    echo "    ██╔══██╗██╔══██╗██╔════╝██║ ██╔╝██╔══██╗██╔════╝ ██╔════╝"
    echo "    ██████╔╝███████║██║     █████╔╝ ███████║██║  ███╗█████╗  "
    echo "    ██╔═══╝ ██╔══██║██║     ██╔═██╗ ██╔══██║██║   ██║██╔══╝  "
    echo "    ██║     ██║  ██║╚██████╗██║  ██╗██║  ██║╚██████╔╝███████╗"
    echo "    ╚═╝     ╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝"
    echo -e "${NC}"
    echo -e "${LIGHT_BLUE}                 ══════════════════════════════════════════════════${NC}"
    echo -e "${WHITE}                      ${ICON_ROCKET} ${BOLD}ESSENTIAL PACKAGE INSTALLER${NC} ${ICON_ROCKET}"
    echo -e "${LIGHT_BLUE}                 ══════════════════════════════════════════════════${NC}"
    echo

    local installed_count=0
    local skipped_count=0
    local already_installed_count=0

    # Loop through each package in the pacman list
    echo -e "${LIGHT_YELLOW}${ICON_GEAR} ${BOLD}Checking Pacman Packages...${NC}\n"

    for package in "${PACMAN_PACKAGES_TO_INSTALL[@]}"; do
        # Check if package is already installed
        if is_package_installed "$package"; then
            show_package_status "$package" "already installed"
            already_installed_count=$((already_installed_count + 1))
            continue
        fi

        if ask_install_package "$package" "Official Repository"; then
            # Show spinner while installing
            echo -e "${LIGHT_YELLOW}${ICON_GEAR} Installing $package...${NC}"

            if sudo pacman -S --noconfirm "$package"; then
                # Verify installation was successful
                if is_package_installed "$package"; then
                    show_package_status "$package" "successfully installed"
                    installed_count=$((installed_count + 1))
                else
                    show_package_status "$package" "failed to install"
                fi
            else
                show_package_status "$package" "failed to install"
            fi
        else
            show_package_status "$package" "skipped by user"
            skipped_count=$((skipped_count + 1))
        fi
        echo
    done

    # Loop through each package in the AUR list
    echo -e "\n${LIGHT_YELLOW}${ICON_GEAR} ${BOLD}Checking AUR Packages...${NC}\n"

    for package in "${AUR_PACKAGES_TO_INSTALL[@]}"; do
        # Check if package is already installed
        if is_package_installed "$package"; then
            show_package_status "$package" "already installed (AUR)"
            already_installed_count=$((already_installed_count + 1))
            continue
        fi

        if ask_install_package "$package" "Arch User Repository (AUR)"; then
            echo -e "${LIGHT_YELLOW}${ICON_GEAR} Installing $package from AUR...${NC}"

            if yay -S --noconfirm "$package"; then
                # Verify installation was successful
                if is_package_installed "$package"; then
                    show_package_status "$package" "successfully installed (AUR)"
                    installed_count=$((installed_count + 1))
                else
                    show_package_status "$package" "failed to install (AUR)"
                fi
            else
                show_package_status "$package" "failed to install (AUR)"
            fi
        else
            show_package_status "$package" "skipped by user"
            skipped_count=$((skipped_count + 1))
        fi
        echo
    done

    # Enhanced Summary of installations using print_boxed_message
    print_boxed_message "Installation Complete!" "success"

    echo -e "\n${LIGHT_BLUE}╔═══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${LIGHT_BLUE}║                           ${WHITE}${BOLD}INSTALLATION SUMMARY${NC}${LIGHT_BLUE}                            ║${NC}"
    echo -e "${LIGHT_BLUE}╠═══════════════════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${LIGHT_BLUE}║                                                                               ║${NC}"
    echo -e "${LIGHT_BLUE}║  ${GREEN}${ICON_CHECK} ${WHITE}Newly installed packages:${NC} ${LIGHT_GREEN}${BOLD}$installed_count${NC}                                   ${LIGHT_BLUE}║${NC}"
    echo -e "${LIGHT_BLUE}║  ${YELLOW}${ICON_CROSS} ${WHITE}Skipped packages:${NC} ${LIGHT_YELLOW}${BOLD}$skipped_count${NC}                                          ${LIGHT_BLUE}║${NC}"
    echo -e "${LIGHT_BLUE}║  ${BLUE}${ICON_INFO} ${WHITE}Already installed packages:${NC} ${LIGHT_CYAN}${BOLD}$already_installed_count${NC}                              ${LIGHT_BLUE}║${NC}"
    echo -e "${LIGHT_BLUE}║                                                                               ║${NC}"
    echo -e "${LIGHT_BLUE}╚═══════════════════════════════════════════════════════════════════════════════╝${NC}"
}
