local function nvim_tree_on_attach(bufnr)
	local api = require("nvim-tree.api")
	local function opts(desc)
		return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
	end
	-- default mappings
	api.config.mappings.default_on_attach(bufnr)
	-- custom mappings
	vim.keymap.set("n", "l", api.node.open.edit, opts("Open"))
	vim.keymap.set("n", "h", api.node.navigate.parent_close, opts("Close Directory"))
	vim.keymap.set("n", "?", api.tree.toggle_help, opts("Help"))
end

return {
	"nvim-tree/nvim-tree.lua",
	keys = {
		{
			"<Leader>n",
			"<cmd>NvimTreeToggle<CR>",
			{ silent = true, desc = "NvimTreeToggle" },
		},
	},
	opts = {
		sort_by = "extension",
		view = {
			width = 30,
			side = "right",
			signcolumn = "no",
		},
		renderer = {
			highlight_git = true,
			highlight_opened_files = "name",
			icons = {
				glyphs = {
					git = {
						unstaged = "!",
						renamed = "»",
						untracked = "?",
						deleted = "✘",
						staged = "✓",
						unmerged = "",
						ignored = "◌",
					},
				},
			},
		},
		filters = {
			git_ignored = true,
			dotfiles = false,
			custom = { "^.git$", "node_modules" },
		},
		actions = {
			expand_all = {
				max_folder_discovery = 100,
				exclude = { ".git", "target", "build" },
			},
		},
		on_attach = nvim_tree_on_attach,
	},
}
