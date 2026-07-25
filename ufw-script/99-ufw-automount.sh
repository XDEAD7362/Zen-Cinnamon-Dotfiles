#!/bin/bash
# ==============================================================================
# SCRIPT DE AUTOMATIZACIÓN DE UFW PARA NETWORKMANAGER DISPATCHER
# Sistema operativo: Pop!_OS / Cinnamon
# Ubicación de instalación: /etc/NetworkManager/dispatcher.d/99-ufw-automount.sh
# Permisos del archivo: sudo chmod 755 /etc/NetworkManager/dispatcher.d/99-ufw-automount.sh
# Propietario requerido: sudo chown root:root /etc/NetworkManager/dispatcher.d/99-ufw-automount.sh
# ==============================================================================

# Asegurar el PATH del sistema para los binarios requeridos
PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

# ------------------------------------------------------------------------------
# CONFIGURACIÓN: LISTA DE REDES WI-FI DE CONFIANZA (SSIDs)
# ------------------------------------------------------------------------------
# INSTRUCCIONES DE CONFIGURACIÓN:
# Modifica el siguiente array sustituyendo los nombres entre comillas por los
# SSIDs (nombres) exactos de tus redes Wi-Fi seguras o de confianza (ejemplo: hogar, oficina).
#
# Cuando te conectes a cualquiera de estos SSIDs, el script DESACTIVARÁ UFW.
# Si te conectas a un Wi-Fi que NO esté en esta lista, UFW se ACTIVARÁ automáticamente.
#
# Para agregar más redes, simplemente añade una nueva línea con la red entre comillas:
# REDES_CONFIABLES=(
#     "MiCasa_WiFi"
#     "Oficina_Piso2"
#     "Red_Invitados_Segura"
# )
# ------------------------------------------------------------------------------
REDES_CONFIABLES=(
    "Villegas_SaltaC"
    "Villegas-5G_SaltaC"
    "MERCUSYS_B785"
    "GuaymasRoberto"
    "AdministracionIFZ"
    "AdministracionIFZ5.0GHz"
    "ColegioZuviria"
    "ColegioZuviria_5G_EXT"
    "LaboratorioIFZ"
    "TEMPLE"
    "TEMPLE_Ext"
    "ipolita22"
    "motorola edge 70_8996"
)

# ------------------------------------------------------------------------------
# FUNCIÓN: Notificaciones de escritorio desde root al usuario gráfico activo
# ------------------------------------------------------------------------------
# NetworkManager Dispatcher se ejecuta bajo el usuario privilegiado 'root'.
# Para enviar notificaciones con notify-send a la sesión de Cinnamon, debemos:
# 1. Identificar el UID del usuario gráfico (ej. UID 1000).
# 2. Conectarnos a su bus de sesión D-Bus (unix:path=/run/user/$UID/bus).
# 3. Ejecutar notify-send en el contexto del usuario usando 'sudo -u' o 'runuser'.
# ------------------------------------------------------------------------------
enviar_notificacion() {
    local titulo="$1"
    local mensaje="$2"
    local icono="$3"

    # 1. Obtener el UID del usuario principal activo (UID >= 1000 con directorio en /run/user/)
    local user_uid
    user_uid=$(ls /run/user/ 2>/dev/null | grep -E '^[0-9]+$' | sort -n | while read -r uid; do
        if [ "$uid" -ge 1000 ] && [ -d "/run/user/$uid" ]; then
            echo "$uid"
            break
        fi
    done)

    # Si no se encontró por directorio, intentar vía loginctl
    if [ -z "$user_uid" ]; then
        user_uid=$(loginctl list-sessions --no-legend 2>/dev/null | awk '$2 >= 1000 {print $2; exit}')
    fi

    # 2. Si se encuentra un usuario activo, lanzar notify-send en su sesión
    if [ -n "$user_uid" ]; then
        local user_name
        user_name=$(id -nu "$user_uid" 2>/dev/null)
        local dbus_bus="unix:path=/run/user/$user_uid/bus"

        if command -v notify-send >/dev/null 2>&1; then
            sudo -u "$user_name" DBUS_SESSION_BUS_ADDRESS="$dbus_bus" \
                notify-send -i "$icono" -a "Gestor de Cortafuegos UFW" "$titulo" "$mensaje" 2>/dev/null
        fi
    fi
}

# ------------------------------------------------------------------------------
# RECEPCIÓN Y FILTRADO DE EVENTOS DE NETWORKMANAGER DISPATCHER
# ------------------------------------------------------------------------------
# NetworkManager pasa 2 argumentos principales al dispatcher:
# $1: Nombre de la interfaz (ej: wlo1, enp45s0, docker0)
# $2: Acción realizada (ej: up, down, dhcp4-change)
# ------------------------------------------------------------------------------
IFACE="$1"
ACTION="$2"

# EXCEPCIÓN CRÍTICA: Ignorar completamente interfaces de Docker y Loopback
# docker0, veth*, br-* no deben ser consideradas como redes válidas ni disparar cambios en UFW.
if [[ "$IFACE" =~ ^(docker0|veth|br-)|^lo$ ]]; then
    exit 0
fi

# Filtrar acciones irrelevantes (ej. hostname)
case "$ACTION" in
    up|down|dhcp4-change|dhcp6-change|connectivity-change|"")
        ;;
    *)
        exit 0
        ;;
esac

# ------------------------------------------------------------------------------
# EVALUACIÓN DE ESTADO DE CONEXIONES DE RED FÍSICAS
# ------------------------------------------------------------------------------
DESACTIVAR_UFW=false
MOTIVO=""

# Leer dispositivos de red usando nmcli en formato delimitado por ':' con LC_ALL=C para estándar neutral de idioma
while IFS=':' read -r dev type state conn; do
    # Omitir dispositivos no conectados
    if [ "$state" != "conectado" ] && [ "$state" != "connected" ]; then
        continue
    fi

    # Omitir interfaces de contenedores y virtuales
    if [[ "$dev" =~ ^(docker0|veth|br-)|^lo$ ]]; then
        continue
    fi

    # 1. EVALUAR CONEXIÓN LAN (ETHERNET) O USB TETHERING
    if [ "$type" = "ethernet" ]; then
        # Verificar si la conexión es por USB Tethering
        if [[ "$dev" =~ ^usb|^rndis || "$conn" =~ [Uu][Ss][Bb] ]]; then
            DESACTIVAR_UFW=true
            MOTIVO="Conexión activa por USB ($conn)"
            break
        else
            DESACTIVAR_UFW=true
            MOTIVO="Conexión activa por cable LAN Ethernet ($conn)"
            break
        fi
    fi

    # 2. EVALUAR CONEXIÓN WI-FI CONTRA LISTA BLANCA DE SSIDs
    if [ "$type" = "wifi" ]; then
        # 1. Obtener el SSID activo directamente usando nmcli con LC_ALL=C (garantiza 'yes' independientemente del idioma del sistema)
        SSID_ACTUAL=$(LC_ALL=C nmcli -t -f active,ssid dev wifi 2>/dev/null | awk -F':' 'tolower($1) ~ /^(yes|sí|si)$/ {print $2; exit}')

        # 2. Si no se obtiene vía dev wifi, consultar el SSID directo del dispositivo wlan vía iwgetid
        if [ -z "$SSID_ACTUAL" ] && command -v iwgetid >/dev/null 2>&1; then
            SSID_ACTUAL=$(iwgetid -r "$dev" 2>/dev/null || iwgetid -r 2>/dev/null)
        fi

        # 3. En caso de no obtener SSID directo, usar el nombre de la conexión activa
        if [ -z "$SSID_ACTUAL" ]; then
            SSID_ACTUAL="$conn"
        fi

        # 4. Limpiar cualquier sufijo de configuración local ("automática", "automatic", "auto", etc.)
        SSID_ACTUAL=$(echo "$SSID_ACTUAL" | sed -E 's/ (automática|automatica|automatic|auto)$//i')

        # Comprobar el SSID contra el array de redes de confianza
        for ssid_confianza in "${REDES_CONFIABLES[@]}"; do
            if [ "$SSID_ACTUAL" = "$ssid_confianza" ]; then
                DESACTIVAR_UFW=true
                MOTIVO="Conectado a Wi-Fi de confianza ($SSID_ACTUAL)"
                break 2
            fi
        done
    fi
done < <(LC_ALL=C nmcli -t -f DEVICE,TYPE,STATE,CONNECTION device 2>/dev/null)

# ------------------------------------------------------------------------------
# GESTIÓN DEL ESTADO DE UFW Y EMISIÓN DE NOTIFICACIÓN
# ------------------------------------------------------------------------------
ESTADO_ACTUAL_UFW=$(ufw status 2>/dev/null | grep -i "Status:" | awk '{print $2}')

if [ "$DESACTIVAR_UFW" = true ]; then
    # Desactivar UFW si actualmente está activo
    if [ "$ESTADO_ACTUAL_UFW" != "inactive" ]; then
        ufw disable >/dev/null 2>&1
        enviar_notificacion \
            "Cortafuegos Desactivado" \
            "$MOTIVO. UFW se ha desactivado." \
            "security-low"
    fi
else
    # Activar UFW si actualmente está inactivo (red no confiable o desconectado)
    if [ "$ESTADO_ACTUAL_UFW" != "active" ]; then
        ufw enable >/dev/null 2>&1
        enviar_notificacion \
            "Cortafuegos Activado" \
            "Conectado a una red no confiable o sin conexión. UFW activado por protección." \
            "security-high"
    fi
fi

exit 0
