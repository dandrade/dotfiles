#!/bin/bash

# Aerospace workspaces for sketchybar
# Shows all 10 workspaces with app icons

source "$CONFIG_DIR/colors.sh"

sketchybar --add event aerospace_workspace_change

SPACE_ICONS=("1" "2" "3" "4" "5" "6" "7" "8" "9" "10")

for i in "${!SPACE_ICONS[@]}"; do
  sid="${SPACE_ICONS[i]}"

  space=(
    icon="$sid"
    icon.padding_left=10
    icon.padding_right=5
    padding_left=2
    padding_right=2
    label.padding_right=10
    icon.color=$WHITE
    icon.highlight_color=$RED
    label.color=$GREY
    label.highlight_color=$WHITE
    label.font="sketchybar-app-font:Regular:16.0"
    label.y_offset=-1
    background.color=$BACKGROUND_1
    background.border_color=$BACKGROUND_2
    background.corner_radius=5
    background.height=24
    click_script="aerospace workspace $sid"
    script="$CONFIG_DIR/plugins/aerospace.sh"
  )

  sketchybar --add item space.$sid left \
             --set space.$sid "${space[@]}" \
             --subscribe space.$sid aerospace_workspace_change
done

# Initial update - get focused workspace and update (with timeout to prevent blocking)
FOCUSED=$(timeout 2 aerospace list-workspaces --focused 2>/dev/null | tr -d '[:space:]')
if [ -n "$FOCUSED" ]; then
  sketchybar --set space.$FOCUSED icon.highlight=on background.border_color=$GREY
fi

# Update all workspaces with their window icons (run in background to not block startup)
"$CONFIG_DIR/plugins/aerospace.sh" update_all &
