#!/bin/bash

killall waybar
if [[ $USER = "manoj" ]]; then
  waybar -c /home/manoj/.config/waybar/config -s /home/manoj/.config/waybar/style.css &
else
  waybar &
fi
