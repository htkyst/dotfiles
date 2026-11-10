return {
	"nvim-lualine/lualine.nvim",
	dependencies = {
		"lewis6991/gitsigns.nvim",
		"neovim/nvim-lspconfig",
		"SmiteshP/nvim-navic",
	},
	config = function()
		local config = {

			options = {
				icons_enabled = true,
				theme = "auto",
				-- component_separators = { left = '', right = ''},
				-- section_separators = { left = '', right = '' },
				section_separators = { left = "", right = "" },
				component_separators = { left = "", right = "" },
				disabled_filetypes = {
					statusline = {},
					winbar = {},
				},
				igonore_focus = {},
				always_divide_middle = true,
				globalstatus = true,
				refres = {
					statusline = 1000,
					tabline = 1000,
					winbar = 1000,
				},
			},
			sections = {
				lualine_a = { "mode" },
				lualine_b = {
					{
						"filename",
						newfile_status = true,
						path = 1,
						shorting_target = 24,
						symbols = { modified = "󰷥", readonly = "", newfile = "✙" },
					},
				},
				lualine_c = {
					{
						"diagnostics",
						sources = { "nvim_diagnostic", "nvim_lsp" },
						sections = { "error", "warn", "info", "hint" },
						symbols = { error = " ", warn = " ", info = " ", hint = " " },
					},
					{ "navic" },
				},
				lualine_x = { "encoding", "fileformat", "filetype" },
				lualine_y = { "progress" },
				lualine_z = { "location" },
			},
			inactive_sections = {
				lualine_a = {},
				lualine_b = {},
				lualine_c = { "filename" },
				lualine_x = { "location" },
				lualine_y = {},
				lualine_z = {},
			},
			tabline = {
				lualine_a = {
					{
						"buffers",
						symbols = { modified = "_󰷥", alternate_file = " ", directory = " " },
					},
				},
				lualine_b = {},
				lualine_c = {},
				lualine_x = {
					{
						"diff",
						symbols = { added = " ", modified = " ", removed = " " },
					},
				},
				lualine_y = {
					{ "branch", icon = { "" } },
				},
				lualine_z = {
					"tabs",
				},
			},
			winbar = {},
			inactive_winbar = {},
			extensions = {},
		}

		require("lualine").setup(config)
	end,
}
