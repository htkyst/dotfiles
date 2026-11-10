return {
	-- Neovim notification manager
	"rcarriga/nvim-notify",
	config = function()
		local notify = require("notify")
		notify.setup({
			fps = 60,
			render = "compact",
			stages = "static",
			timeout = 3000,
		})
		vim.notify = notify
	end,
}
