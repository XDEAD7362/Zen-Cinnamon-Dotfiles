# 🛠️ Personal Dotfiles & Post-Installation Setup (Linux Mint Cinnamon)

Este repositorio contiene mi configuración personal (*dotfiles*), temas visuales, atajos y un script de **post-instalación 100% automatizado** diseñado para desplegar un entorno de trabajo optimizado en **Linux Mint (Cinnamon)**.

---

## 🚀 ¿Qué incluye este repositorio?

### 💻 Entorno de Terminal y Shell
* **Shell principal:** Zsh (con `.zshrc` personalizado y alias de productividad).
* **Terminal:** [Kitty](https://sw.kovidgoyal.net/kitty/) con configuración de fuentes, transparencias y atajos.
* **Extras:** Scripts locales en `~/.local/bin/`, Fastfetch, y utilidades visuales (`cowsay` / `fortune`).

### 🎨 Apariencia y Escritorio (Cinnamon)
* **Tema de aplicaciones:** `Orchis-Grey-Dark`
* **Tema de escritorio:** `WhiteSur-Dark-solid-grey`
* **Tema de íconos:** `Mint-Y-Yaru`
* **Configuración de Cinnamon:** Respaldo y restauración completa mediante exportación `dconf`.

### 📦 Software y Aplicaciones
El script `install.sh` prioriza paquetes en formato **Flatpak** y repositorios oficiales:
* **Limpieza inicial:** Purga automática de Firefox y LibreOffice preinstalados.
* **Navegador:** Brave Origin (instalado mediante script oficial).
* **Ofimática y Gestión:** ONLYOFFICE, Obsidian, Thunderbird.
* **Desarrollo y Sistema:** DBeaver CE, Flatseal, Gear Lever, btop, Fastfetch.
* **Entretenimiento / Multimedia:** VLC, Steam.
* **Optimización de Batería:** TLP + TLP-UI.

### 🛡️ Red y Seguridad
* Integra un script de automatización para **UFW** vinculado a NetworkManager (`dispatcher.d`).

---

## 📂 Estructura del Repositorio

```text
dotfiles/
├── bin/                       # Scripts ejecutables personales (~/.local/bin)
├── kitty/                     # Configuración de Kitty Terminal
├── themes/                    # Temas visuales (Orchis, WhiteSur)
├── icons/                     # Temas de íconos (Mint-Y-Yaru)
├── ufw-script/                # Script de reglas automáticas de UFW
├── .zshrc                     # Configuración y alias de Zsh
├── cinnamon-settings.dconf    # Volcado dconf de la interfaz gráfica
├── install.sh                 # Script maestro de post-instalación
├── .gitignore                 # Reglas de exclusión para credenciales y datos sensibles
└── README.md                  # Documentación del proyecto text
```

## ⚡ Instalación en un Sistema Nuevo (Linux Mint)
​Para aplicar todas las configuraciones y desplegar el software en una instalación limpia de Linux Mint, abre una terminal y ejecuta:

* **1. Clonar el repositorio en tu carpeta personal**
git clone https://github.com/XDEAD7362/Zen-Cinnamon-Dotfiles.git ~/dotfiles

* **2. Navegar al directorio**
cd ~/dotfiles

* **3. Dar permisos de ejecución e iniciar la instalación**
chmod +x install.sh
./install.sh
​
## ⚠️ Nota de seguridad 
El script install.sh renombrará automáticamente tus archivos de configuración existentes (.zshrc, etc.) agregándoles la extensión .backup antes de crear los enlaces simbólicos (symlinks), evitando así la pérdida accidental de datos.

## 📜 Licencia
​Libre para uso personal y modificación (MIT License). Adaptado para flujos de trabajo sobre Linux Mint Cinnamon.
