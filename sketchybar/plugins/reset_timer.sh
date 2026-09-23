#!/usr/bin/env bash

# `ps | cut` devolvia un campo vacio cuando el timer no corre, y `kill` sin
# argumentos escribia su uso al log en cada click. pgrep es exacto y silencioso.
pids=$(pgrep -f "$CONFIG_DIR/plugins/timer.py")
[ -n "$pids" ] && kill $pids

sketchybar --set timer label=""
