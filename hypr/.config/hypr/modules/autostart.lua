-- See https://wiki.hypr.land/configuring/core/autostart/

local app = require("modules.programs")

-- Autostart necessary processes (like notifications daemons, status bars, etc.)
-- Or execute your favorite apps at launch like this:
--
hl.on("hyprland.start", function () 
--   hl.exec_cmd("nm-applet")
    hl.exec_cmd(app.prostatus_bar)
    hl.exec_cmd(app.wallpaper)
    hl.exec_cmd(app.jp_input)
--  hl.exec_cmd(app.notification)
--  Initial wallpaper
    hl.exec_cmd(
        "sleep 1 && awww img" .. app.init_wallpaper
    )
--  Quickshell
    hl.exec_cmd("qs -c bookshelf")
end)

