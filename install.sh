#!/usr/bin/env bash
# ==============================================================================
# Script de Post-Instalación y Migración a Linux Mint (Cinnamon)
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
# 3. Instalación de Paquetes APT
# ------------------------------------------------------------------------------
echo "📦 Instalando paquetes esenciales desde APT..."
sudo apt-get install -y zsh kitty btop git curl ufw cowsay fortune-mod fortunes fortunes-es software-properties-common flatpak kdeconnect zsh-autosuggestions zsh-syntax-highlighting fonts-inter unzip

# ------------------------------------------------------------------------------
# 3.5 Instalación de Oh My Zsh
# ------------------------------------------------------------------------------
echo "🌟 Instalando Oh My Zsh..."
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
    echo "Oh My Zsh ya está instalado."
fi

# ------------------------------------------------------------------------------
# 4. Instalación de TLP y TLP UI
# ------------------------------------------------------------------------------
echo "📦 Instalando TLP y dependencias..."
sudo apt install -y tlp tlp-rdw python3-gi gir1.2-gtk-3.0 git

echo "⚡ Iniciando servicio TLP..."
sudo tlp start

echo "🔋 Instalando TLP UI..."
sudo rm -rf /opt/TLPUI
sudo git clone https://github.com/d4nj1/TLPUI.git /opt/TLPUI

echo "🚀 Configurando acceso directo a TLP UI..."
sudo tee /usr/share/applications/tlpui.desktop > /dev/null <<EOF
[Desktop Entry]
Name=TLP UI
Comment=Interfaz gráfica para TLP
Exec=python3 -m tlpui
Path=/opt/TLPUI
Icon=preferences-system
Terminal=false
Type=Application
Categories=Settings;System;
EOF
echo "✅ ¡TLP y TLP UI instalados correctamente!"

# -----------------------------------------------------
# 4.1 Instalación de Podman (Rootless)
# -----------------------------------------------------
echo "🐳 Reemplazando Docker por Podman (Rootless)..."
sudo apt-get install -y podman podman-docker dbus-user-session

# -----------------------------------------------------
# 4.2 Despliegue de MySQL con Podman y systemd (Quadlets)
# -----------------------------------------------------
echo "🐬 Configurando contenedor permanente de MySQL (Podman + systemd)..."

# 1. Crear el directorio para los Quadlets de usuario
mkdir -p ~/.config/containers/systemd/

# 2. Crear el archivo declarativo del contenedor
cat <<EOF > ~/.config/containers/systemd/mysql-docker.container
[Unit]
Description=Contenedor MySQL de Desarrollo (Podman)
After=network-online.target

[Container]
Image=docker.io/library/mysql:latest
ContainerName=mysql-docker
Environment=MYSQL_ROOT_PASSWORD=root_password
PublishPort=3306:3306

[Install]
WantedBy=default.target
EOF

# 3. Recargar systemd de usuario para que detecte el nuevo Quadlet
systemctl --user daemon-reload

# 4. Iniciar y habilitar el servicio para que arranque con el sistema
systemctl --user enable --now mysql-docker.service

# 5. Habilitar "lingering" para que el servicio inicie al bootear, 
# sin necesidad de que el usuario inicie sesión gráfica primero
sudo loginctl enable-linger $USER

# ------------------------------------------------------------------------------
# 5. Instalaciones Personalizadas
# ------------------------------------------------------------------------------
echo "🦁 Instalando Brave Origin..."
curl -fsS https://dl.brave.com/install.sh | FLAVOR=origin sh

echo "🚀 Descargando e instalando Fastfetch..."
wget -q --show-progress https://github.com/fastfetch-cli/fastfetch/releases/latest/download/fastfetch-linux-amd64.deb
sudo apt-get install -y ./fastfetch-linux-amd64.deb
rm fastfetch-linux-amd64.deb

echo "🛸 Instalando Antigravity CLI..."
curl -fsSL https://antigravity.google/cli/install.sh | bash

echo "🧹 Sanitizando variables tóxicas inyectadas por Antigravity..."
# Eliminamos cualquier inyección destructiva que el instalador haya hecho en el sistema
sudo sed -i '/QT_STYLE_OVERRIDE/d' /etc/environment || true
sudo sed -i '/GTK_MODULES/d' /etc/environment || true
sudo sed -i '/XDG_SESSION_TYPE/d' /etc/environment || true
sed -i '/QT_STYLE_OVERRIDE/d' ~/.profile 2>/dev/null || true

# ------------------------------------------------------------------------------
# 6. Instalación de Aplicaciones Flatpak
# ------------------------------------------------------------------------------
echo "📦 Configurando Flathub e instalando aplicaciones Flatpak..."
sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

FLATPAK_APPS=(
    "io.dbeaver.DBeaverCommunity"
    "com.github.tchx84.Flatseal"
    "it.mijorus.gearlever"
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
# 7. Restauración de Temas e Iconos, Respaldos y Symlinks
# ------------------------------------------------------------------------------
echo "🎨 Restaurando temas e iconos..."
mkdir -p ~/.themes ~/.icons
if [ -d "$HOME/dotfiles/themes" ]; then
    cp -r "$HOME/dotfiles/themes/"* ~/.themes/ || true
fi
if [ -d "$HOME/dotfiles/icons" ]; then
    cp -r "$HOME/dotfiles/icons/"* ~/.icons/ || true
fi

echo "🔗 Configurando dotfiles y enlaces simbólicos..."
[ -f ~/.zshrc ] && [ ! -L ~/.zshrc ] && mv ~/.zshrc ~/.zshrc.backup
mkdir -p ~/.config ~/.local ~/.local/share/cinnamon ~/.local/share/fonts

# Respaldos de configuraciones existentes
[ -d ~/.config/kitty ] && [ ! -L ~/.config/kitty ] && mv ~/.config/kitty ~/.config/kitty.backup
[ -d ~/.config/fastfetch ] && [ ! -L ~/.config/fastfetch ] && mv ~/.config/fastfetch ~/.config/fastfetch.backup
[ -d ~/.local/bin ] && [ ! -L ~/.local/bin ] && mv ~/.local/bin ~/.local/bin.backup

# Crear enlaces simbólicos
ln -sf "$HOME/dotfiles/.zshrc" "$HOME/.zshrc"
ln -sf "$HOME/dotfiles/.config/kitty" "$HOME/.config/kitty"
ln -sf "$HOME/dotfiles/.config/fastfetch" "$HOME/.config/fastfetch"
ln -sf "$HOME/dotfiles/.local/bin" "$HOME/.local/bin"

if [ -d "$HOME/dotfiles/.local/share/cinnamon/applets" ]; then
    ln -sf "$HOME/dotfiles/.local/share/cinnamon/applets" "$HOME/.local/share/cinnamon/applets"
fi
if [ -d "$HOME/dotfiles/.local/share/fonts" ]; then
    ln -sf "$HOME/dotfiles/.local/share/fonts" "$HOME/.local/share/fonts"
    fc-cache -f
fi

# ------------------------------------------------------------------------------
# 8. Cambiar Shell por Defecto a Zsh
# ------------------------------------------------------------------------------
echo "🐚 Cambiando shell por defecto a Zsh..."
if [ "$SHELL" != "$(which zsh)" ]; then
    chsh -s "$(which zsh)" || sudo chsh -s "$(which zsh)" "$USER"
fi

# ------------------------------------------------------------------------------
# 9. Restaurar Configuración de Cinnamon y Modo Oscuro
# ------------------------------------------------------------------------------
echo "🖥️ Restaurando configuración visual de Cinnamon..."
if [ -f "$HOME/dotfiles/cinnamon-settings.dconf" ]; then
    dconf load /org/cinnamon/ < "$HOME/dotfiles/cinnamon-settings.dconf"
fi

echo "🌙 Forzando modo oscuro nativo y configurando Flatpak de forma segura..."
gsettings set org.cinnamon.desktop.interface color-scheme 'prefer-dark' || true
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' || true

# Compartimos la config de temas con Flatpak usando portales XDG (sin variables --env)
sudo flatpak override --user --filesystem=xdg-config/gtk-3.0:ro
sudo flatpak override --user --filesystem=xdg-config/gtk-4.0:ro

# ------------------------------------------------------------------------------
# 10. Copiar Script de UFW a NetworkManager Dispatcher
# ------------------------------------------------------------------------------
echo "🛡️ Configurando script de UFW en NetworkManager..."
if [ -f "$HOME/dotfiles/ufw-script/99-ufw-automount.sh" ]; then
    sudo cp "$HOME/dotfiles/ufw-script/99-ufw-automount.sh" /etc/NetworkManager/dispatcher.d/
    sudo chown root:root /etc/NetworkManager/dispatcher.d/99-ufw-automount.sh
    sudo chmod +x /etc/NetworkManager/dispatcher.d/99-ufw-automount.sh
fi

echo "✅ ¡Proceso de post-instalación completado con éxito! Reinicia tu sistema o sesión."
