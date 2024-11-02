#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# Hyprland-Dots to download from main #

## WARNING: DO NOT EDIT BEYOND THIS LINE IF YOU DON'T KNOW WHAT YOU ARE DOING! ##

source "$(dirname "$(readlink -f "$0")")/Global_functions.sh"

# Ask user for git clone preference
while true; do
    read -p "Do you want to clone using SSH (1) or HTTPS (2)? Enter 1 or 2: " clone_method
    case $clone_method in
        1)
            repo_url="git@github.com:PriyanshuPansari/dotfiles.git"
            wallpaper_url="git@github.com:PriyanshuPansari/wallpapers.git"
            break
            ;;
        2)
            repo_url="https://github.com/PriyanshuPansari/dotfiles.git"
            wallpaper_url="https://github.com/PriyanshuPansari/wallpapers.git"
            break
            ;;
        *)
            echo "Invalid input. Please enter 1 for SSH or 2 for HTTPS."
            ;;
    esac
done

# Check if Hyprland-Dots exists
printf "${NOTE} Downloading KooL's Hyprland Dots....\n"

if [ -d Hyprland-Dots ]; then
  cd Hyprland-Dots
  git stash
  git pull
  git stash apply
  chmod +x copy.sh
  ./copy.sh 
else
  if git clone --depth 1 "$repo_url"; then
    mv download .dotfiles
    cd dotfiles || exit 1
    chmod +x stow.sh
    ./stow.sh 
  else
    echo -e "$ERROR Can't download Hyprland-Dots"
  fi
fi

# Update or install wallpapers
mkdir -p ~/Pictures
cd ~/Pictures || exit 1
 

clear
