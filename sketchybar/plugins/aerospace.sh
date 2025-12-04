#!/bin/bash

source "$CONFIG_DIR/colors.sh"

update_workspace() {
  local workspace="$1"
  local is_focused="$2"

  # Get windows in this workspace
  local windows=$(aerospace list-windows --workspace "$workspace" --format '%{app-name}' 2>/dev/null)

  local icon_strip=""
  if [ -n "$windows" ]; then
    while IFS= read -r app; do
      if [ -n "$app" ]; then
        icon_strip+=" $($CONFIG_DIR/plugins/icon_map.sh "$app")"
      fi
    done <<< "$windows"
  fi

  # Set highlight based on focus
  local border_color=$BACKGROUND_2
  local highlight="off"
  if [ "$is_focused" = "true" ]; then
    border_color=$GREY
    highlight="on"
  fi

  sketchybar --animate tanh 10 --set "space.$workspace" \
    label="$icon_strip" \
    icon.highlight=$highlight \
    background.border_color=$border_color
}

update_all() {
  local focused=$(aerospace list-workspaces --focused 2>/dev/null | tr -d '[:space:]')

  for sid in 1 2 3 4 5 6 7 8 9 10; do
    local is_focused="false"
    if [ "$sid" = "$focused" ]; then
      is_focused="true"
    fi
    update_workspace "$sid" "$is_focused"
  done
}

# Handle workspace change event
if [ "$SENDER" = "aerospace_workspace_change" ]; then
  update_all
elif [ "$1" = "update_all" ]; then
  update_all
else
  # Called from item subscription
  update_all
fi
