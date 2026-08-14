# 🛠️ Personal Dotfiles & Post-Installation Setup (Linux Mint Cinnamon)

Este repositorio contiene mi configuración personal (*dotfiles*), temas visuales, atajos y un script de **post-instalación 100% automatizado** diseñado para desplegar un entorno de trabajo optimizado en **Linux Mint (Cinnamon)**[span_0](start_span)[span_0](end_span).

---

## 🚀 ¿Qué incluye este repositorio?

### 💻 Entorno de Terminal y Shell
* **Shell principal:** Zsh (con `.zshrc` personalizado y alias de productividad)[span_1](start_span)[span_1](end_span).
* **Terminal:** [Kitty](https://sw.kovidgoyal.net/kitty/) con configuración de fuentes, transparencias y atajos[span_2](start_span)[span_2](end_span).
* **Extras:** Scripts locales en `~/.local/bin/`, Fastfetch, y utilidades visuales (`cowsay` / `fortune`)[span_3](start_span)[span_3](end_span).

### 🎨 Apariencia y Escritorio (Cinnamon)
* **Tema de aplicaciones:** `Orchis-Grey-Dark`[span_4](start_span)[span_4](end_span)
* **Tema de escritorio:** `WhiteSur-Dark-solid-grey`[span_5](start_span)[span_5](end_span)
* **Tema de íconos:** `Mint-Y-Yaru`[span_6](start_span)[span_6](end_span)
* **Tema Oscuro Global Seguro:** Aplicación nativa a nivel sistema (`GTK3 / GTK4 / Libadwaita`) y a través de portales XDG para `Flatpak` (evitando variables de entorno globales destructivas)[span_7](start_span)[span_7](end_span).
* **Configuración de Cinnamon:** Respaldo y restauración completa mediante exportación `dconf`[span_8](start_span)[span_8](end_span).

### ⚙️ Hardware y Rendimiento (ASUS TUF & NVIDIA)
* **Controladores Gráficos:** Autoinstalación de drivers propietarios de NVIDIA.
* **Gestión ASUS:** Compilación automatizada desde código fuente (vía Rustup) de `supergfxctl` (gestión de GPU híbrida) y `asusctl` (control de ventiladores y hardware ASUS).
* **Optimización de Batería:** Resolución de conflictos deshabilitando `power-profiles-daemon` para dar paso a **TLP + TLP-UI**. Se complementa con alias en Zsh (`bat-viaje`, `bat-mixto`, `bat-escritorio`) para rotar límites de carga de hardware directamente desde la terminal[span_9](start_span)[span_9](end_span).

### 📦 Software y Aplicaciones
El script `install.sh` prioriza paquetes en formato **Flatpak**, repositorios oficiales y despliegue de contenedores[span_10](start_span)[span_10](end_span):
* **Limpieza inicial:** Purga automática de Firefox y LibreOffice preinstalados[span_11](start_span)[span_11](end_span).
* **Navegador:** Brave Origin (instalado mediante script oficial)[span_12](start_span)[span_12](end_span).
* **Ofimática y Gestión:** ONLYOFFICE, Obsidian, Thunderbird[span_13](start_span)[span_13](end_span).
* **Desarrollo y Sistema:** DBeaver CE, Flatseal, Gear Lever, btop, Fastfetch, KDE Connect, Google Antigravity CLI (con sanitización automática de variables inyectadas)[span_14](start_span)[span_14](end_span).
* **Virtualización y Contenedores:** Migración total a **Podman** (*rootless*). Incluye alias para compatibilidad con Docker sin requerir privilegios `sudo`[span_15](start_span)[span_15](end_span).
* **Bases de Datos:** Contenedor persistente de **MySQL** desplegado automáticamente mediante **systemd Quadlets** (`~/.config/containers/systemd/`), ejecutándose en el puerto `3306` como un servicio de usuario gestionado de forma segura[span_16](start_span)[span_16](end_span).
* **Entretenimiento / Multimedia:** VLC, Steam[span_17](start_span)[span_17](end_span).
* **Gaming y Aislamiento:** Implementación de **Bottles** (Flatpak) para ejecutar y aislar de forma segura videojuegos de Windows mediante Wine/Proton.

### 🛡️ Red y Seguridad
* Integra un script de automatización para **UFW** vinculado a NetworkManager (`dispatcher.d`)[span_18](start_span)[span_18](end_span).

---

## 📂 Estructura del Repositorio

```
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
└── README.md                  # Documentación del proyecto
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
