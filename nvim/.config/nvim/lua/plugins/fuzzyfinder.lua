return {
	"nvim-telescope/telescope.nvim",
    branch = "master",

	dependencies = {
		{
			"nvim-telescope/telescope-fzf-native.nvim",
			cond = function()
				return vim.fn.executable("cmake") == 1
			end,
			build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release"
				.. "&& cmake --build build --config Release"
				.. "&& cmake --install build --prefix build",
		},
		"tsakirist/telescope-lazy.nvim",
		"nvim-telescope/telescope-media-files.nvim",
		"rcarriga/nvim-notify",
	},

	config = function()
		local telescope = require("telescope")
		local builtin = require("telescope.builtin")
		local themes = require("telescope.themes")
		local actions = require("telescope.actions")

		telescope.setup({
			defaults = {
				mappings = {
					i = {
						["<ESC>"] = actions.close,
					},
					n = {},
				},
				winblend = 20,
			},
			extensions = {
				fzf = {
					fuzzy = true,
					override_generic_sorter = true,
					override_file_sorter = true,
					case_mode = "smart_case",
				},
				media_files = {
					filetypes = { "png", "webp", "jpg", "jpeg", "bmp" },
				},
			},
            pickers = {
                find_files = {
                    hidden = true,
                    no_ignore = true,
                }
            }
		})

		telescope.load_extension("fzf")
		telescope.load_extension("notify")
		telescope.load_extension("lazy")
		telescope.load_extension("media_files")

		-- Key map
		vim.keymap.set("n", "<leader>ff", builtin.find_files)
		vim.keymap.set("n", "<leader>fg", builtin.live_grep)
		vim.keymap.set("n", "<leader>fb", builtin.buffers)
		vim.keymap.set("n", "<leader>fh", function()
			builtin.help_tags(themes.get_ivy())
		end)
		vim.keymap.set("n", "<leader>fn", function()
			telescope.extensions.notify.notify()
		end)
		vim.keymap.set("n", "<leader>fp", function()
			telescope.extensions.lazy.lazy()
		end)
		vim.keymap.set("n", "<leader>fi", function()
			telescope.extensions.media_files.media_files()
		end)
	end,
}
