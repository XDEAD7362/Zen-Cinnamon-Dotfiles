#!/usr/bin/env bash
# ==============================================================================
# Script de Post-Instalación y Migración a Linux Mint (Cinnamon)
# ==============================================================================
# Este script automatiza la instalación de paquetes, limpieza de software no
# deseado, configuración de temas, restauraciones de dotfiles y configuraciones
# del sistema.
# ==============================================================================

set -e

echo "🚀 Iniciando proceso de post-instalación en Linux Mint..."

# ------------------------------------------------------------------------------
# 1. Limpieza Profunda
# ------------------------------------------------------------------------------
echo "🧹 Eliminando Firefox y LibreOffice..."
sudo apt-get purge --auto-remove -y "firefox*" "libreoffice*"

# ------------------------------------------------------------------------------
# 2. Actualización de Repositorios
# ------------------------------------------------------------------------------
echo "🔄 Actualizando repositorios y el sistema..."
sudo apt-get update && sudo apt-get upgrade -y

# ------------------------------------------------------------------------------
# 3. Instalación de Paquetes APT y TLP UI
# ------------------------------------------------------------------------------
echo "📦 Instalando paquetes esenciales desde APT..."
sudo apt-get install -y zsh kitty git curl ufw cowsay fortune tlp tlp-rdw software-properties-common flatpak

echo "➕ Agregando PPA para tlp-ui..."
sudo add-apt-repository -y ppa:linuxuprising/apps
sudo apt-get update
sudo apt-get install -y tlp-ui

# ------------------------------------------------------------------------------
# 4. Instalación Personalizada: Brave Origin
# ------------------------------------------------------------------------------
echo "🦁 Instalando Brave Origin..."
curl -fsS https://dl.brave.com/install.sh | FLAVOR=origin sh

# ------------------------------------------------------------------------------
# 5. Instalación de Aplicaciones Flatpak
# ------------------------------------------------------------------------------
echo "📦 Configurando Flathub e instalando aplicaciones Flatpak..."
sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

FLATPAK_APPS=(
    "com.aristocratos.btop"
    "io.dbeaver.DBeaverCommunity"
    "com.github.tchx84.Flatseal"
    "it.miSuper.GearLever"
    "md.obsidian.Obsidian"
    "org.onlyoffice.desktopeditors"
    "org.videolan.VLC"
    "com.valvesoftware.Steam"
    "org.mozilla.Thunderbird"
)

for app in "${FLATPAK_APPS[@]}"; do
    echo "  -> Instalando $app..."
    flatpak install flathub -y "$app"
done

# ------------------------------------------------------------------------------
# 6. Restauración de Temas e Iconos, Respaldos y Symlinks
# ------------------------------------------------------------------------------
echo "🎨 Restaurando temas e iconos..."
mkdir -p ~/.themes ~/.icons
if [ -d "$HOME/dotfiles/themes" ]; then
    cp -r "$HOME/dotfiles/themes/"* ~/.themes/
fi
if [ -d "$HOME/dotfiles/icons" ]; then
    cp -r "$HOME/dotfiles/icons/"* ~/.icons/
fi

echo "🔗 Configurando dotfiles y enlaces simbólicos..."

# Respaldar configuraciones existentes
[ -f ~/.zshrc ] && [ ! -L ~/.zshrc ] && mv ~/.zshrc ~/.zshrc.backup
mkdir -p ~/.config ~/.local

[ -d ~/.config/kitty ] && [ ! -L ~/.config/kitty ] && mv ~/.config/kitty ~/.config/kitty.backup
[ -d ~/.local/bin ] && [ ! -L ~/.local/bin ] && mv ~/.local/bin ~/.local/bin.backup

# Crear enlaces simbólicos
ln -sf "$HOME/dotfiles/.zshrc" "$HOME/.zshrc"
ln -sf "$HOME/dotfiles/.config/kitty" "$HOME/.config/kitty"
ln -sf "$HOME/dotfiles/.local/bin" "$HOME/.local/bin"

# ------------------------------------------------------------------------------
# 7. Cambiar Shell por Defecto a Zsh
# ------------------------------------------------------------------------------
echo "🐚 Cambiando shell por defecto a Zsh..."
if [ "$SHELL" != "$(which zsh)" ]; then
    chsh -s "$(which zsh)" || sudo chsh -s "$(which zsh)" "$USER"
fi

# ------------------------------------------------------------------------------
# 8. Restaurar Configuración de Cinnamon
# ------------------------------------------------------------------------------
echo "🖥️ Restaurando configuración visual de Cinnamon..."
if [ -f "$HOME/dotfiles/cinnamon-settings.dconf" ]; then
    dconf load /org/cinnamon/ < "$HOME/dotfiles/cinnamon-settings.dconf"
fi

# ------------------------------------------------------------------------------
# 9. Copiar Script de UFW a NetworkManager Dispatcher
# ------------------------------------------------------------------------------
echo "🛡️ Configurando script de UFW en NetworkManager..."
if [ -f "$HOME/dotfiles/ufw-script/99-ufw-automount.sh" ]; then
    sudo cp "$HOME/dotfiles/ufw-script/99-ufw-automount.sh" /etc/NetworkManager/dispatcher.d/
    sudo chown root:root /etc/NetworkManager/dispatcher.d/99-ufw-automount.sh
    sudo chmod +x /etc/NetworkManager/dispatcher.d/99-ufw-automount.sh
fi

echo "✅ ¡Proceso de post-instalación completado con éxito! Reinicia tu sistema o sesión para aplicar todos los cambios."
