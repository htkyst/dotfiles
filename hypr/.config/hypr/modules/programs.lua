local M = {}

-- Apps
M.terminal      = "kitty"
M.fileManager   = "dolphin"
M.menu          = "rofi -show drun"
M.menu_window   = "rofi -show window -theme $HOME/.config/rofi/window-switcher.rasi"
M.browser       = "firefox"
M.lock          = "hyprlock"
M.logout        = "wlogout -b 5 -c 0 -r 0 -p layer-shell"
M.status_bar    = "waybar"
M.wallpaper     = "awww-daemon"
M.jp_input      = "fcitx5-remote -r & fcitx5 -d --replace"

-- quickshell
M.qs_sidebar = "qs -c sidebar"
M.qs_notice = "qs -c notice"

-- Scripts
local scripts = "$HOME/.config/hypr/scripts/"
M.change_wallpaper = scripts .. "change_wallpaper.sh"
M.show_keys = scripts .. "show_keys.sh"

-- Others
local wallpaper_path = "$HOME/dotfiles/assets/wallpaper/"
M.init_wallpaper = wallpaper_path .. "Alchemist-4k.png"

return M
