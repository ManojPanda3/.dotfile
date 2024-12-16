# some command to run for intractive sessions
if not set -q WAYLAND_DISPLAY
    set -gx WAYLAND_DISPLAY wayland-0
end
set XDG_CONFIG_HOME "$HOME/.config"
set XDG_CONFIG_DIRS /etc/xdg
set WINDOW_MANAGER_STARTUP "$HOME/.config/window_manager/startup.sh"
set PATH "$PATH:$HOME/.bun/bin"

if test (tty) = /dev/tty1
    bash $WINDOW_MANAGER_STARTUP
end
if status is-interactive

    set fish_greeting ''
    # setup wayland
    # intro screens
    # clear
    fastfetch

    # seting up alias
    alias la='ls -lah --color'
    alias hostname="hostnamectl hostname"

    # set the keybinding to vim
    fish_vi_key_bindings
else
    function fish_right_prompt
    end
end
