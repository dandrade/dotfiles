#!/bin/bash

# Script para ajustar gaps según el monitor activo
# Se ejecuta cuando cambias de monitor

CONFIG_FILE="$HOME/.config/aerospace/aerospace.toml"

# `sed -i` de macOS se niega a editar symlinks ("in-place editing only works for
# regular files") y ~/.config/aerospace/aerospace.toml apunta a ~/dotfiles.
# Resolvemos la cadena de symlinks para editar el archivo real.
while [ -L "$CONFIG_FILE" ]; do
  target="$(readlink "$CONFIG_FILE")"
  case "$target" in
    /*) CONFIG_FILE="$target" ;;
    *)  CONFIG_FILE="$(dirname "$CONFIG_FILE")/$target" ;;
  esac
done

# Detectar el monitor enfocado (built-in vs externo) con timeout
FOCUSED_MONITOR=$(timeout 2 aerospace list-monitors --focused --format '%{monitor-name}' 2>/dev/null)

# Si timeout falla, intentar método alternativo
if [ -z "$FOCUSED_MONITOR" ]; then
  # Usar system_profiler como fallback
  DISPLAY_COUNT=$(system_profiler SPDisplaysDataType 2>/dev/null | grep -c "Resolution")
  if [ "$DISPLAY_COUNT" -gt 1 ]; then
    # Hay monitor externo, asumir que está en uso
    FOCUSED_MONITOR="External"
  else
    FOCUSED_MONITOR="Built-in"
  fi
fi

if [[ "$FOCUSED_MONITOR" == *"Built-in"* ]] || [[ "$FOCUSED_MONITOR" == *"built-in"* ]]; then
  # Laptop - menos espacio
  NEW_TOP=15
else
  # Monitor externo - más espacio
  NEW_TOP=48
fi

# Leer el valor actual para evitar recargas innecesarias
CURRENT_TOP=$(grep "outer.top" "$CONFIG_FILE" | grep -o '[0-9]*')

if [ "$CURRENT_TOP" != "$NEW_TOP" ]; then
  # Actualizar el archivo de configuración
  sed -i '' "s/outer.top =.*/outer.top =       $NEW_TOP/" "$CONFIG_FILE"

  # Recargar aerospace (con timeout y en background)
  (timeout 2 aerospace reload-config 2>/dev/null) &
fi
