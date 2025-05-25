#!/bin/bash

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

# Loop over $PACMAN_PACKAGES_TO_INSTALL and $AUR_PACKAGES_TO_INSTALL
# and ask the user to confirm installation of each package.
install_packages() {
    echo -e "\n${GREEN}Installing essential packages...${NC}"

    local installed_count=0
    local skipped_count=0
    local already_installed_count=0

    # Loop through each package in the pacman list
    for package in "${PACMAN_PACKAGES_TO_INSTALL[@]}"; do
        # Check if package is already installed
        if is_package_installed "$package"; then
            echo -e "${BLUE}$package${NC} ${GREEN}is already installed.${NC}"
            already_installed_count=$((already_installed_count + 1))
            continue
        fi

        echo -e "${YELLOW}Installing ${package}...${NC}"

        # Ask user if they want to install this package
        read -p "$(echo -e ${CYAN}Do you want to install $package? [Y/n]:${NC} )" choice

        # Default to 'y' if user doesn't input anything
        choice=${choice:-y}

        # If user agrees (y or Y), proceed with installation
        if [[ $choice =~ ^[Yy]$ ]]; then
            sudo pacman -S --noconfirm "$package"

            # Verify installation was successful
            if is_package_installed "$package"; then
                echo -e "${GREEN}$package has been successfully installed!${NC}"
                installed_count=$((installed_count + 1))
            else
                echo -e "${RED}Failed to install $package. Please check for errors.${NC}"
            fi
        else
            echo -e "${YELLOW}Skipped installation of $package.${NC}"
            skipped_count=$((skipped_count + 1))
        fi
    done

    # Loop through each package in the AUR list
    for package in "${AUR_PACKAGES_TO_INSTALL[@]}"; do
        # Check if package is already installed
        if is_package_installed "$package"; then
            echo -e "${BLUE}$package${NC} ${GREEN}is already installed from AUR.${NC}"
            already_installed_count=$((already_installed_count + 1))
            continue
        fi

        echo -e "${YELLOW}Installing ${package} from AUR...${NC}"

        # Ask user if they want to install this package
        read -p "$(echo -e ${CYAN}Do you want to install $package from AUR? [Y/n]:${NC} )" choice

        # Default to 'y' if user doesn't input anything
        choice=${choice:-y}

        # If user agrees (y or Y), proceed with installation
        if [[ $choice =~ ^[Yy]$ ]]; then
            yay -S --noconfirm "$package"

            # Verify installation was successful
            if is_package_installed "$package"; then
                echo -e "${GREEN}$package has been successfully installed!${NC}"
                installed_count=$((installed_count + 1))
            else
                echo -e "${RED}Failed to install $package. Please check for errors.${NC}"
            fi
        else
            echo -e "${YELLOW}Skipped installation of $package.${NC}"
            skipped_count=$((skipped_count + 1))
        fi
    done

    # Summary of installations
    echo -e "\n${BOLD}${BLUE}======== Installation Summary ========${NC}"
    echo -e "${GREEN}Newly installed packages: $installed_count${NC}"
    echo -e "${YELLOW}Skipped packages: $skipped_count${NC}"
    echo -e "${BLUE}Already installed packages: $already_installed_count${NC}"
    echo -e "${BOLD}${BLUE}=====================================${NC}"

    echo -e "\n${GREEN}Package installation process completed!${NC}"
}
