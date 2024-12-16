#!/bin/bash
thunar --daemon &
pgrep hyprland || hyprland &
