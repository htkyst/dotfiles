-- Enable lua module loader
if vim.loader then
	vim.loader.enable()
end

-- Global flags
local flags = require("config.flags")

-- Common settings
require("core.global")
require("core.option")

-- Lazy
if flags.enable_lazy then
	require("core.lazy")

	-- Color scheme (in Lazy plugin)
	vim.cmd("colorscheme tokyonight")
end

-- After loading lazy
vim.api.nvim_create_autocmd("User", {
	pattern = "VeryLazy",
	callback = function()
		require("core.autocmd")
		require("core.keymap")
	end,
})
