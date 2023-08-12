#!/bin/bash
#      _       _    __ _ _           
#   __| | ___ | |_ / _(_) | ___  ___ 
#  / _` |/ _ \| __| |_| | |/ _ \/ __|
# | (_| | (_) | |_|  _| | |  __/\__ \
#  \__,_|\___/ \__|_| |_|_|\___||___/
#                                    
# by Stephan Raabe (2023)
# ------------------------------------------------------
# Install Script for dotfiles and configuration
# yay must be installed
# ------------------------------------------------------

# ------------------------------------------------------
# Confirm Start
# ------------------------------------------------------
clear
echo "     _       _    __ _ _            "
echo "  __| | ___ | |_ / _(_) | ___  ___  "
echo " / _' |/ _ \| __| |_| | |/ _ \/ __| "
echo "| (_| | (_) | |_|  _| | |  __/\__ \ "
echo " \__,_|\___/ \__|_| |_|_|\___||___/ "
echo "                                    "
echo "by Stephan Raabe (2023)"
echo "-------------------------------------"
echo ""

while true; do
    read -p "DO YOU WANT TO START THE INSTALLATION NOW? (Yy/Nn): " yn
    case $yn in
        [Yy]* )
            echo "Installation started."
        break;;
        [Nn]* ) 
            exit;
        break;;
        * ) echo "Please answer yes or no.";;
    esac
done

# ------------------------------------------------------
# Install required packages
# ------------------------------------------------------
echo ""
echo "-> Install main packages"

packagesPacman=("alacritty" "scrot" "nitrogen" "picom" "starship" "slock" "neovim" "rofi" "dunst" "mpv" "freerdp" "xfce4-power-manager" "thunar" "mousepad" "ttf-font-awesome" "ttf-fira-sans" "ttf-fira-code" "ttf-firacode-nerd" "figlet" "lxappearance" "polybar" "breeze" "breeze-gtk" "rofi-calc" "vlc");

packagesYay=("brave-bin" "pfetch" "bibata-cursor-theme");
# pywal installation below 
  
# ------------------------------------------------------
# Function: Is package installed
# ------------------------------------------------------
_isInstalledPacman() {
    package="$1";
    check="$(sudo pacman -Qs --color always "${package}" | grep "local" | grep "${package} ")";
    if [ -n "${check}" ] ; then
        echo 0; #'0' means 'true' in Bash
        return; #true
    fi;
    echo 1; #'1' means 'false' in Bash
    return; #false
}

_isInstalledYay() {
    package="$1";
    check="$(yay -Qs --color always "${package}" | grep "local" | grep "${package} ")";
    if [ -n "${check}" ] ; then
        echo 0; #'0' means 'true' in Bash
        return; #true
    fi;
    echo 1; #'1' means 'false' in Bash
    return; #false
}

# ------------------------------------------------------
# Function Install all package if not installed
# ------------------------------------------------------
_installPackagesPacman() {
    toInstall=();

    for pkg; do
        if [[ $(_isInstalledPacman "${pkg}") == 0 ]]; then
            echo "${pkg} is already installed.";
            continue;
        fi;

        toInstall+=("${pkg}");
    done;

    if [[ "${toInstall[*]}" == "" ]] ; then
        # echo "All pacman packages are already installed.";
        return;
    fi;

    printf "Packages not installed:\n%s\n" "${toInstall[@]}";
    sudo pacman --noconfirm -S "${toInstall[@]}";
}

_installPackagesYay() {
    toInstall=();

    for pkg; do
        if [[ $(_isInstalledYay "${pkg}") == 0 ]]; then
            echo "${pkg} is already installed.";
            continue;
        fi;

        toInstall+=("${pkg}");
    done;

    if [[ "${toInstall[*]}" == "" ]] ; then
        # echo "All packages are already installed.";
        return;
    fi;

    printf "AUR ackages not installed:\n%s\n" "${toInstall[@]}";
    yay --noconfirm -S "${toInstall[@]}";
}

# ------------------------------------------------------
# Install required packages
# ------------------------------------------------------
_installPackagesPacman "${packagesPacman[@]}";
_installPackagesYay "${packagesYay[@]}";

# pywal requires dedicated installation
if [ -f /usr/bin/wal ]; then
    echo "pywal already installed."
else
    yay --noconfirm -S pywal
fi

# ------------------------------------------------------
# Create .config folder
# ------------------------------------------------------
echo ""
echo "-> Install .config folder"

if [ -d ~/.config ]; then
    echo ".config folder already exists."
else
    mkdir ~/.config
    echo ".config folder created."
fi

# ------------------------------------------------------
# Create symbolic links
# ------------------------------------------------------
echo ""
echo "-> Install symbolic links"

_createSymLink() {
    symlink="$1";
    linksource="$2";
    linktarget="$3";
    if [ -L "${symlink}" ]; then
        _handleExistingLink "${symlink}"
    else
        if [ -d ${symlink} ]; then
            _handleExistingDirectory "${symlink}"
        else
            if [ -f ${symlink} ]; then
                _handleExistingFile "${symlink}"
            else
                _createLink "${linksource}" "${linktarget}"
            fi
        fi
    fi
}

_handleExistingLink() {
    echo "Link ${symlink} exists already."
    rm -f "${symlink}" && echo "Link ${symlink} removed."
}

_handleExistingDirectory() {
    echo "Directory ${symlink}/ exists."
    mv -v -r "${symlink}" "${symlink}".bak && echo "Directory ${symlink}/ renamed to ${symlink}.bak"
}

_handleExistingFile() {
    echo "File ${symlink} exists."
    mv -v "${symlink}" "${symlink}".bak && echo "File ${symlink} renamed to ${symlink}.bak"
}

_createLink() {
    ln -s -p "${linksource}" "${linktarget}" 
    echo "Link ${linksource} -> ${linktarget} created."
}
_createSymLink ~/.config/qtile ~/arch-qtile/dotfiles/qtile/ ~/.config
_createSymLink ~/.config/alacritty ~/arch-qtile/dotfiles/alacritty/ ~/.config
_createSymLink ~/.config/picom ~/arch-qtile/dotfiles/picom/ ~/.config
_createSymLink ~/.config/rofi ~/arch-qtile/dotfiles/rofi/ ~/.config
_createSymLink ~/.config/vim ~/arch-qtile/dotfiles/vim/ ~/.config
_createSymLink ~/.config/nvim ~/arch-qtile/dotfiles/nvim/ ~/.config
_createSymLink ~/.config/polybar ~/arch-qtile/dotfiles/polybar/ ~/.config
_createSymLink ~/.config/dunst ~/arch-qtile/dotfiles/dunst/ ~/.config
_createSymLink ~/.config/starship.toml ~/arch-qtile/dotfiles/starship/starship.toml ~/.config/starship.toml

# ------------------------------------------------------
# Install .bashrc
# ------------------------------------------------------
echo ""
echo "-> Install .bashrc"
while true; do
    read -p "Do you want to replace the existing .bashrc file? (Yy/Nn): " yn
    case $yn in
        [Yy]* )
            rm ~/.bashrc
            echo ".bashrc removed"
        break;;
        [Nn]* ) 
            echo "Replacement of .bashrc skipped."
        break;;
        * ) echo "Please answer yes or no.";;
    esac
done
_installSymLink ~/.bashrc ~/dotfiles/.bashrc ~/.bashrc

# ------------------------------------------------------
# Install Theme, Icons and Cursor
# ------------------------------------------------------
echo ""
echo "-> Install Theme"
while true; do
    read -p "Do you want to replace the existing theme configuration? (Yy/Nn): " yn
    case $yn in
        [Yy]* )
            if [ -d ~/.config/gtk-3.0 ]; then
                rm -r ~/.config/gtk-3.0
                echo "gtk-3.0 removed"
            fi

            if [ -f ~/.gtkrc-2.0 ]; then
                rm ~/.gtkrc-2.0
                echo ".gtkrc-2.0"
            fi

            if [ -f ~/.Xresources ]; then
                rm ~/.Xresources
                echo ".Xresources removed"
            fi
            
            if [ -d ~/.icons ]; then
                rm -r ~/.icons
                echo ".icons removed"
            fi
            
            _installSymLink ~/.gtkrc-2.0 ~/dotfiles/.gtkrc-2.0 ~/.gtkrc-2.0
            _installSymLink ~/.config/gtk-3.0 ~/dotfiles/gtk-3.0/ ~/.config/
            _installSymLink ~/.Xresources ~/dotfiles/.Xresources ~/.Xresources
            _installSymLink ~/.icons ~/dotfiles/.icons/ ~/

            echo "Existing theme removed"
        break;;
        [Nn]* ) 
            echo "Replacement of theme skipped."
        break;;
        * ) echo "Please answer yes or no.";;
    esac
done

# ------------------------------------------------------
# Install custom issue (login prompt)
# ------------------------------------------------------
echo ""
echo "-> Install login screen"
while true; do
    read -p "Do you want to install the custom login promt? (Yy/Nn): " yn
    case $yn in
        [Yy]* )
            sudo cp ~/dotfiles/issue /etc/issue
            echo "Login promt installed."
        break;;
        [Nn]* ) 
            echo "Custom login promt skipped."
        break;;
        * ) echo "Please answer yes or no.";;
    esac
done

# ------------------------------------------------------
# Install wallpapers
# ------------------------------------------------------
echo ""
echo "-> Install wallapers"
while true; do
    read -p "Do you want to clone the wallpapers? (Yy/Nn): " yn
    case $yn in
        [Yy]* )
            if [ -d ~/wallpaper/ ]; then
                echo "wallpaper folder already exists."
            else
                git clone https://gitlab.com/stephan-raabe/wallpaper.git ~/wallpaper
                echo "wallpaper installed."
            fi
            echo "Wallpaper installed."
        break;;
        [Nn]* ) 
            if [ -d ~/wallpaper/ ]; then
                echo "wallpaper folder already exists."
            else
                mkdir ~/wallpaper
            fi
            cp ~/dotfiles/default.jpg ~/wallpaper
            echo "Default wallpaper installed."
        break;;
        * ) echo "Please answer yes or no.";;
    esac
done

# ------------------------------------------------------
# Init pywal
# ------------------------------------------------------
echo ""
echo "-> Init pywal"
wal -i ~/dotfiles/default.jpg
echo "pywal initiated."

# ------------------------------------------------------
# DONE
# ------------------------------------------------------
clear
echo "DONE!"
