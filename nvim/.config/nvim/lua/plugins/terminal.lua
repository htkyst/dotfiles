return {
	"akinsho/toggleterm.nvim",
	event = { "BufEnter" },
	version = "*",
	opts = {},
	config = function()
		require("toggleterm").setup({
			size = function(term)
				if term.direction == "horizontal" then
					return 20
				elseif term.direction == "vertical" then
					return vim.o.columns * 0.4
				end
			end,
			direction = "float",
			float_opts = {
				border = "double",
			},
		})

		local Terminal = require("toggleterm.terminal").Terminal

		local default = Terminal:new({
			cmd = vim.o.shell,
			direction = "float",
			float_opts = {
				border = "double",
			},
			hidden = true,
		})

		local lazygit = Terminal:new({
			cmd = "lazygit",
			direction = "float",
			float_opts = {
				border = "double",
			},
			hidden = true,
		})

		function default_toggle()
			default:toggle()
		end

		function lazygit_toggle()
			lazygit:toggle()
		end

		vim.api.nvim_set_keymap("n", "<leader>t", "<cmd>lua default_toggle()<CR>", { noremap = true, silent = true })
		vim.api.nvim_set_keymap("n", "<leader>g", "<cmd>lua lazygit_toggle()<CR>", { noremap = true, silent = true })
	end,
}
