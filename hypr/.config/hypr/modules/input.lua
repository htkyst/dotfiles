
hl.config({
    input = {
        kb_layout  = "jp",
        kb_variant = "",
        kb_model   = "pc105",
        kb_options = "ctrl:nocaps",
        kb_rules   = "",

        follow_mouse = 1,

        sensitivity = 0.7, -- -1.0 - 1.0, 0 means no modification.

        touchpad = {
            natural_scroll = true,
            tap_to_click = true,
            disable_while_typing = true,
            scroll_factor = 0.5,
        },
    },
})

hl.gesture({
    fingers = 3,
    direction = "horizontal",
    action = "workspace"
})

-- Example per-device config
-- See https://wiki.hypr.land/configuring/core/devices/ for more
hl.device({
    name        = "epic-mouse-v1",
    sensitivity = -0.5,
})

