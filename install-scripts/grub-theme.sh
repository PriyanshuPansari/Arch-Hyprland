#!/bin/bash

source "$(dirname "$(readlink -f "$0")")/Global_functions.sh"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'

# Helper functions
print_message() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

check_error() {
    if [ $? -ne 0 ]; then
        print_message "$RED" "$1"
        exit 1
    fi
}

detect_resolution() {
    if command -v xrandr >/dev/null 2>&1; then
        xrandr --current | grep '*' | awk '{print $1}' | head -n1
    else
        echo "1920x1080"  # Fallback resolution
    fi
}

setup_workspace() {
    # Ask user for git clone preference
    while true; do
        read -p "Do you want to clone using SSH (1) or HTTPS (2)? Enter 1 or 2: " clone_method
        case $clone_method in
            1)
                repo_url="git@github.com:PriyanshuPansari/yorha-grub-theme.git"
                break
                ;;
            2)
                repo_url="https://github.com/PriyanshuPansari/yorha-grub-theme.git"
                break
                ;;
            *)
                echo "Invalid input. Please enter 1 for SSH or 2 for HTTPS."
                ;;
        esac
    done

    print_message "$GREEN" "Cloning GRUB theme repository..."
    git clone "$repo_url"
    check_error "Failed to clone repository"
}

cleanup() {
    print_message "$GREEN" "Cleaning up..."
    rm -rf yorha-grub-theme
}

install_theme() {
    local resolution=$1
    local theme_folder
    
    print_message "$GREEN" "Installing Yorha GRUB theme for resolution $resolution..."
    
    # Create themes directory if it doesn't exist
    sudo mkdir -p /boot/grub/themes
    check_error "Failed to create GRUB themes directory"
    
    # Find matching theme folder
    theme_folder=$(find ./yorha-grub-theme -type d -name "*$resolution" | head -n 1)
    
    if [ -z "$theme_folder" ]; then
        print_message "$YELLOW" "No theme found for resolution $resolution. Using 1920x1080 as fallback."
        theme_folder=$(find ./yorha-grub-theme -type d -name "*1920x1080" | head -n 1)
    fi
    
    if [ -n "$theme_folder" ]; then
        # Copy theme to GRUB themes directory
        sudo cp -r "$theme_folder" /boot/grub/themes/
        check_error "Failed to copy theme files"
        
        # Get theme name and update GRUB configuration
        local theme_name=$(basename "$theme_folder")
        
        # Backup original GRUB configuration
        sudo cp /etc/default/grub /etc/default/grub.backup
        check_error "Failed to backup GRUB configuration"
        
        # Update GRUB configuration
        sudo sed -i "s|^#*GRUB_THEME=.*|GRUB_THEME=\"/boot/grub/themes/$theme_name/theme.txt\"|" /etc/default/grub
        check_error "Failed to update GRUB configuration"
        
        # Update GRUB
        if command -v update-grub >/dev/null 2>&1; then
            sudo update-grub
        else
            sudo grub-mkconfig -o /boot/grub/grub.cfg
        fi
        check_error "Failed to update GRUB"
        
        print_message "$GREEN" "GRUB theme installed successfully!"
        print_message "$YELLOW" "Original GRUB configuration backed up to /etc/default/grub.backup"
    else
        print_message "$RED" "Failed to find a suitable GRUB theme folder"
        exit 1
    fi
}

install_grub_theme() {
    local resolution=$(detect_resolution)
    print_message "$GREEN" "Detected screen resolution: $resolution"
    
    setup_workspace
    # Install theme
    install_theme "$resolution"
    
    # Cleanup
    cleanup
    
    print_message "$GREEN" "Installation completed successfully!"
    print_message "$YELLOW" "Please reboot your system to see the new GRUB theme."
}

# Main execution
install_grub_theme 