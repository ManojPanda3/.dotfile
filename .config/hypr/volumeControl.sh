!#/bin/bash

if [[ "$1" == "+" && "$2" =~ ^[0-9]+$ ]]; then
  pactl set-sink-volume 1 -- "+$2%"
elif [[ "$1" == "-" && "$2" =~ ^[0-9]+$ ]]; then
  pactl set-sink-volume 1 -- "-$2%"
elif [[ "$1" == "0" ]]; then
  pactl set-sink-mute 1 toggle
else
  echo "Invalid arguments. Use '+' or '-' followed by a number to adjust volume, '0' to mute, or '1' to unmute."
  exit 1
fi
