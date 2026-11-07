
------------------
---- MONITORS ----
------------------

require("modules.monitors")

---------------------
---- MY PROGRAMS ----
---------------------

-- require("modules.programs")

-------------------
---- AUTOSTART ----
-------------------

require("modules.autostart")

-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

require("modules.env")

-----------------------
----- PERMISSIONS -----
-----------------------

require("modules.permissions")

-----------------------
---- LOOK AND FEEL ----
-----------------------

require("modules.animation")

----------------
----  MISC  ----
----------------

hl.config({
    misc = {
        force_default_wallpaper = -1,    -- Set to 0 or 1 to disable the anime mascot wallpapers
        disable_hyprland_logo   = false, -- If true disables the random hyprland logo / anime girl background. :(
    },
})


----------------
---- LAYERS ----
----------------

hl.config({
    layers = {
        allow_new_top_layers_over_existing_fullscreen = true, -- Set to false to make newly mapped top layers render below existing covering fullscreen window
    },
})


---------------
---- INPUT ----
---------------

require("modules.input")

---------------------
---- KEYBINDINGS ----
---------------------

require("modules.keybind")

--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

require("modules.window")

