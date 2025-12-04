#!/bin/bash

# Script para ajustar gaps según el monitor activo
# Se ejecuta cuando cambias de monitor

CONFIG_FILE="$HOME/.config/aerospace/aerospace.toml"

# Detectar si hay monitor externo conectado
EXTERNAL_MONITOR=$(system_profiler SPDisplaysDataType 2>/dev/null | grep -c "Resolution" | head -1)

# Detectar el monitor enfocado (built-in vs externo)
FOCUSED_MONITOR=$(aerospace list-monitors --focused --format '%{monitor-name}' 2>/dev/null)

if [[ "$FOCUSED_MONITOR" == *"Built-in"* ]] || [[ "$FOCUSED_MONITOR" == *"built-in"* ]]; then
  # Laptop - menos espacio
  NEW_TOP=15
else
  # Monitor externo - más espacio
  NEW_TOP=48
fi

# Actualizar el archivo de configuración
sed -i '' "s/outer.top =.*/outer.top =       $NEW_TOP/" "$CONFIG_FILE"

# Recargar aerospace
aerospace reload-config 2>/dev/null &
