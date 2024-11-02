#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# Hyprland Packages #

# edit your packages desired here. 
# WARNING! If you remove packages here, dotfiles may not work properly.
# and also, ensure that packages are present in AUR and official Arch Repo

# add packages wanted here
Extra=(

)

hypr_package=( 
  aylurs-gtk-shell
  cliphist
  curl 
  grim 
  gvfs 
  gvfs-mtp
  imagemagick
  inxi 
  jq
  kitty
  kvantum
  matugen 
  nano 
  neovim
  network-manager-applet 
  pamixer 
  pavucontrol
  pipewire-alsa 
  playerctl
  polkit-gnome
  python-requests
  python-pyquery
  qt5ct
  qt6ct
  qt5-graphicaleffects
  qt6-svg
  rofi-wayland
  slurp
  stow
  swappy 
  swaync 
  swww
  waybar
  wget
  wl-clipboard
  wlogout
  xdg-user-dirs
  xdg-utils 
  yad
  yazi
)

# the following packages can be deleted. however, dotfiles may not work properly
hypr_package_2=(
  brightnessctl 
  btop
  cargo
  cava
  eog
  fastfetch
  gnome-system-monitor
  just
  lutris
  mousepad 
  mpv
  mpv-mpris 
  nvtop
  nwg-look
  pacman-contrib
  qalculate-gtk
  vim
  yt-dlp
)

# List of packages to uninstall as it conflicts with swaync and rofi-wayland
uninstall=(
  dunst
  mako
  rofi
  wallust-git
)

## WARNING: DO NOT EDIT BEYOND THIS LINE IF YOU DON'T KNOW WHAT YOU ARE DOING! ##
# Determine the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Change the working directory to the parent directory of the script
PARENT_DIR="$SCRIPT_DIR/.."
cd "$PARENT_DIR" || exit 1

source "$(dirname "$(readlink -f "$0")")/Global_functions.sh"

# Set the name of the log file to include the current date and time
LOG="Install-Logs/install-$(date +%d-%H%M%S)_hypr-pkgs.log"

# uninstalling conflicting packages
# Initialize a variable to track overall errors
overall_failed=0

printf "\n%s - Removing Mako, Dunst, and rofi as they conflict with swaync and rofi-wayland \n" "${NOTE}"
for PKG in "${uninstall[@]}"; do
  uninstall_package "$PKG" 2>&1 | tee -a "$LOG"
  if [ $? -ne 0 ]; then
    # Track if any uninstallation failed
    overall_failed=1
  fi
done

if [ $overall_failed -ne 0 ]; then
  echo -e "${ERROR} Some packages failed to uninstall. Please check the log."
fi

# Ask user for git clone preference
while true; do
    read -p "Do you want to clone using SSH (1) or HTTPS (2)? Enter 1 or 2: " clone_method
    case $clone_method in
        1)
            rofi_games_url="git@github.com:PriyanshuPansari/rofi-games.git"
            lib_game_url="git@github.com:PriyanshuPansari/lib_game_detector.git"
            break
            ;;
        2)
            rofi_games_url="https://github.com/PriyanshuPansari/rofi-games.git"
            lib_game_url="https://github.com/PriyanshuPansari/lib_game_detector.git"
            break
            ;;
        *)
            echo "Invalid input. Please enter 1 for SSH or 2 for HTTPS."
            ;;
    esac
done

printf "\n%s - Installing rofi-games"
cd ~
mkdir -p clone
cd clone
git clone "$rofi_games_url"
git clone "$lib_game_url"

cd ~/clone/rofi-games || exit 1
sudo just install
 
cd "$PARENT_DIR" || exit 1

# Installation of main components
printf "\n%s - Installing hyprland packages.... \n" "${NOTE}"

for PKG1 in "${hypr_package[@]}" "${hypr_package_2[@]}" "${Extra[@]}"; do
  install_package "$PKG1" 2>&1 | tee -a "$LOG"
  if [ $? -ne 0 ]; then
    echo -e "\e[1A\e[K${ERROR} - $PKG1 Package installation failed, Please check the installation logs"
    exit 1
  fi
done

clear

