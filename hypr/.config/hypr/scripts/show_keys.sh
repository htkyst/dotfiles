#!/bin/bash

hyprctl binds | \
sed 's/^[ \t]*//' | \
column -t -s ',' | \
rofi -dmenu -i -p "Keybinds"
