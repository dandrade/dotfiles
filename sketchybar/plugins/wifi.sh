#!/bin/bash

# Filename: ~/github/dotfiles-latest/sketchybar/felixkratz-linkarzu/plugins/wifi.sh

update() {
  source "$CONFIG_DIR/icons.sh"
  INTERFACE="$(route get default | grep interface | awk '{print $2}')"

  # `airport` se elimino en macOS 14+, y desde entonces el SSID sale "<redacted>"
  # para cualquier proceso sin autorizacion de Localizacion. El helper ssid si la
  # pide, asi que basta autorizarlo una vez. Si no esta compilado o no se ha
  # autorizado, caemos a los metodos del sistema y por ultimo a un literal.
  SSID="$("$CONFIG_DIR/helper/SSID.app/Contents/MacOS/ssid" 2>/dev/null)"
  if [ -z "$SSID" ]; then
    SSID="$(ipconfig getsummary "$INTERFACE" 2>/dev/null | awk -F ' SSID : ' '/ SSID : / {print $2}' | head -n 1)"
  fi
  if [ -z "$SSID" ] || [ "$SSID" = "<redacted>" ]; then
    SSID="$(networksetup -getairportnetwork "$INTERFACE" 2>/dev/null | sed -n 's/^Current Wi-Fi Network: //p')"
  fi
  [ -z "$SSID" ] && SSID="Wi-Fi"

  # Determine the hardware type (WiFi or Ethernet) of the active interface
  HARDWARE_TYPE="$(networksetup -listnetworkserviceorder | grep -B 1 "Device: $INTERFACE" | head -n 1 | awk '{print $2}')"

  # Adjust IP and icon assignment based on the hardware type of the active interface
  IP="$(ipconfig getifaddr "$INTERFACE")"

  if [[ "$HARDWARE_TYPE" == "Wi-Fi" ]]; then
    ICON="$([ -n "$IP" ] && echo "$WIFI_CONNECTED" || echo "$WIFI_DISCONNECTED")"
  else
    ICON="$([ -n "$IP" ] && echo "$ETHERNET_CONNECTED" || echo "$WIFI_DISCONNECTED")"
  fi

  LABEL="$([ -n "$IP" ] && echo "$SSID ($IP)" || echo "Disconnected")"

  sketchybar --set $NAME icon="$ICON" label="$LABEL"
}

click() {
  CURRENT_WIDTH="$(sketchybar --query $NAME | jq -r .label.width)"

  WIDTH=0
  if [ "$CURRENT_WIDTH" -eq "0" ]; then
    WIDTH=dynamic
  fi

  sketchybar --animate sin 20 --set $NAME label.width="$WIDTH"
}

case "$SENDER" in
"wifi_change")
  update
  ;;
"mouse.clicked")
  click
  ;;
esac
