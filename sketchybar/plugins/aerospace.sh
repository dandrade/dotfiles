#!/bin/bash

# Source colors - use absolute path as fallback
if [ -n "$CONFIG_DIR" ]; then
  source "$CONFIG_DIR/colors.sh"
else
  source "$HOME/.config/sketchybar/colors.sh"
fi

# Colors for highlight states (hardcoded fallback)
HIGHLIGHT_BORDER=${GREY:-0xff939ab7}
NORMAL_BORDER=${BACKGROUND_2:-0x60494d64}
ICON_SCRIPT="${CONFIG_DIR:-$HOME/.config/sketchybar}/plugins/icon_map.sh"

# Update icons for a workspace
get_workspace_icons() {
  local workspace="$1"
  local windows=$(timeout 1 aerospace list-windows --workspace "$workspace" --format '%{app-name}' 2>/dev/null)
  local icon_strip=""

  if [ -n "$windows" ]; then
    while IFS= read -r app; do
      [ -n "$app" ] && icon_strip+=" $($ICON_SCRIPT "$app")"
    done <<< "$windows"
  fi
  echo "$icon_strip"
}

# Fast update - only update changed workspaces
update_changed() {
  local focused="$FOCUSED_WORKSPACE"
  local prev="$PREV_WORKSPACE"

  # Update previous workspace (remove highlight)
  if [ -n "$prev" ]; then
    sketchybar --set "space.$prev" icon.highlight=off background.border_color="$NORMAL_BORDER"
  fi

  # Update focused workspace (add highlight)
  if [ -n "$focused" ]; then
    local icons=$(get_workspace_icons "$focused")
    sketchybar --set "space.$focused" label="$icons" icon.highlight=on background.border_color="$HIGHLIGHT_BORDER"
  fi
}

# Full update - update all workspaces
update_all() {
  local focused="$FOCUSED_WORKSPACE"
  [ -z "$focused" ] && focused=$(timeout 1 aerospace list-workspaces --focused 2>/dev/null | tr -d '[:space:]')

  for sid in 1 2 3 4 5 6 7 8 9 10; do
    local icons=$(get_workspace_icons "$sid")
    if [ "$sid" = "$focused" ]; then
      sketchybar --set "space.$sid" label="$icons" icon.highlight=on background.border_color="$HIGHLIGHT_BORDER"
    else
      sketchybar --set "space.$sid" label="$icons" icon.highlight=off background.border_color="$NORMAL_BORDER"
    fi
  done
}

# Use fast update if we have both workspaces, otherwise full update
if [ -n "$FOCUSED_WORKSPACE" ] && [ -n "$PREV_WORKSPACE" ]; then
  update_changed
else
  update_all
fi
