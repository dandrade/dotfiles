#!/bin/bash

# Paleta compartida del sistema. La consume ~/dotfiles/sketchybar/colors.sh, que
# mapea estas 14 variables a los colores de sketchybar asi:
#
#   color01 -> MAGENTA      color09 -> GREY
#   color02 -> GREEN        color10 -> BLACK / fondo de la barra
#   color03 -> BLUE         color11 -> RED
#   color04 -> ORANGE       color12 -> YELLOW
#   color07 -> BACKGROUND_2 color13 -> BACKGROUND_1
#                           color14 -> WHITE  (iconos y texto)
#
# color05, color06 y color08 no los usa sketchybar; quedan para otras herramientas.
# Para cambiar de tema, comenta un bloque y descomenta el otro.

### Tokyo Night (Night) - lo que usaba el config anterior
# export linkarzu_color01="#bb9af7" # magenta / purple
# export linkarzu_color02="#9ece6a" # green
# export linkarzu_color03="#7aa2f7" # blue
# export linkarzu_color04="#ff9e64" # orange
# export linkarzu_color05="#7dcfff" # cyan
# export linkarzu_color06="#73daca" # teal
# export linkarzu_color07="#414868" # terminal black -> BACKGROUND_2
# export linkarzu_color08="#a9b1d6" # fg dark
# export linkarzu_color09="#565f89" # comment -> GREY
# export linkarzu_color10="#1a1b26" # bg -> negro de la barra
# export linkarzu_color11="#f7768e" # red
# export linkarzu_color12="#e0af68" # yellow
# export linkarzu_color13="#292e42" # bg highlight -> BACKGROUND_1
# export linkarzu_color14="#c0caf5" # fg -> iconos y texto

### Kanagawa Wave
# export linkarzu_color01="#957fb8" # oniViolet
# export linkarzu_color02="#98bb6c" # springGreen
# export linkarzu_color03="#7e9cd8" # crystalBlue
# export linkarzu_color04="#ffa066" # surimiOrange
# export linkarzu_color05="#7aa89f" # waveAqua2
# export linkarzu_color06="#6a9589" # waveAqua1
# export linkarzu_color07="#54546d" # sumiInk6 -> BACKGROUND_2
# export linkarzu_color08="#c8c093" # fujiGray claro
# export linkarzu_color09="#727169" # fujiGray -> GREY
# export linkarzu_color10="#1f1f28" # sumiInk3 -> fondo de la barra
# export linkarzu_color11="#e82424" # samuraiRed
# export linkarzu_color12="#e6c384" # carpYellow
# export linkarzu_color13="#363646" # sumiInk4 -> BACKGROUND_1
# export linkarzu_color14="#dcd7ba" # fujiWhite -> iconos y texto

### Batman - ACTIVO (el esquema original, recuperado de colorscheme/list/batman.sh)
export linkarzu_color01="#c0b004" # amarillo oscuro -> MAGENTA
export linkarzu_color02="#666666" # gris medio     -> GREEN
export linkarzu_color03="#c2c2c2" # gris claro     -> BLUE
export linkarzu_color04="#667e83" # azul apagado   -> ORANGE
export linkarzu_color05="#877c03" # oliva
export linkarzu_color06="#c3f4fe" # cyan palido
export linkarzu_color07="#141414" # casi negro     -> BACKGROUND_2
export linkarzu_color08="#ffffff" # blanco
export linkarzu_color09="#8a96b1" # azul grisaceo  -> GREY
export linkarzu_color10="#000000" # negro puro     -> fondo de la barra
export linkarzu_color11="#f8b4b8" # rosa           -> RED
export linkarzu_color12="#fef9c6" # crema          -> YELLOW
export linkarzu_color13="#333333" # gris oscuro    -> BACKGROUND_1
export linkarzu_color14="#ffffff" # blanco         -> iconos y texto
