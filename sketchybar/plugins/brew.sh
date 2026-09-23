#!/bin/bash

# Filename: ~/github/dotfiles-latest/sketchybar/felixkratz-linkarzu/plugins/brew.sh

source "$CONFIG_DIR/colors.sh"

# sketchybar corre con SIGCHLD ignorado, y esa disposicion se hereda a traves de
# exec: los hijos no pueden recoger su estado de salida. Homebrew (Ruby) revienta
# con "undefined method 'success?' for nil" al refrescar su cache de API.
# Reseteamos SIGCHLD a SIG_DFL solo para esta llamada.
nosigchld() {
  perl -e '$SIG{CHLD} = "DEFAULT"; exec @ARGV' "$@"
}

COUNT="$(nosigchld brew outdated | wc -l | tr -d ' ')"

COLOR=$RED

# El label normalmente es un numero y va en la fuente por defecto (Meslo).
# Solo el caso "0 pendientes" usa un check de SF Symbols, que exige pedir
# SF Pro explicitamente: sketchybar no hace fallback de fuente.
LABEL_FONT="MesloLGM Nerd Font:Semibold:13.0"

case "$COUNT" in
[3-5][0-9])
	COLOR=$ORANGE
	;;
[1-2][0-9])
	COLOR=$YELLOW
	;;
[1-9])
	COLOR=$WHITE
	;;
0)
	COLOR=$GREEN
	COUNT=􀆅
    LABEL_FONT="SF Pro:Bold:13.0"
	;;
esac

sketchybar --set $NAME label=$COUNT label.font="$LABEL_FONT" icon.color=$COLOR
