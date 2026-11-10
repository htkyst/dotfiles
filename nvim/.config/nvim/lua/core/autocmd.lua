local flags = require("config.flags")

-- Highlight when yank
vim.api.nvim_create_autocmd("TextYankPost", {
	group = vim.api.nvim_create_augroup("hightlight_yank", { clear = true }),
	callback = function()
		vim.highlight.on_yank({ timeout = 1000 }) -- 1sec
	end,
})

-- Close window with 'q' key
vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("close_help_q", { clear = true }),
	pattern = {
		"qf",
		"help",
		"man",
		"lspinfo",
		"checkhealth",
		"startuptime",
	},
	callback = function(event)
		vim.bo[event.buf].buflisted = false
		vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = event.buf, silent = true })
	end,
})

-- Save cursor position when close file
vim.api.nvim_create_autocmd("BufWinLeave", {
	group = vim.api.nvim_create_augroup("save_cursor_position", { clear = true }),
	pattern = "*",
	callback = function()
		local buf = vim.api.nvim_get_current_buf()
		local pos = vim.api.nvim_win_get_cursor(0)
		vim.api.nvim_buf_set_var(buf, "last_cursor_pos", pos)
	end,
})

-- Restore cursor position when open file
vim.api.nvim_create_autocmd("BufReadPost", {
	group = vim.api.nvim_create_augroup("restore_cursor_position", { clear = true }),
	pattern = "*",
	callback = function()
		local buf = vim.api.nvim_get_current_buf()
		local has_pos, pos = pcall(vim.api.nvim_buf_get_var, buf, "last_cursor_pos")
		if has_pos and pos[1] <= vim.api.nvim_buf_line_count(buf) then
			vim.api.nvim_win_set_cursor(0, pos)
		end
	end,
})

-- Not create undo file if under the tmp folder
vim.api.nvim_create_autocmd("BufWritePre", {
	group = vim.api.nvim_create_augroup("do_not_create_undo", { clear = true }),
	pattern = { "/tmp/*" },
	command = "setlocal noundofile",
})

-- Auto create directory if not
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
	group = vim.api.nvim_create_augroup("auto_create_dir", { clear = true }),
	pattern = "*",
	callback = function(event)
		if event.match:match("^%w%w+://") then
			return
		end
		local uv = vim.uv or vim.loop
		local file = uv.fs_realpath(event.match) or event.match
		vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
	end,
})

-- Disable comment out when new line
vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("disable_comment", { clear = true }),
	pattern = "*",
	callback = function()
		vim.opt_local.formatoptions:remove({ "r", "o" })
		vim.opt_local.formatoptions:append({ "M", "j" })
	end,
})

-- Use LspAttach autocommand to only map the following keys
-- after the language server attaches to the current buffer
local lsp_group = vim.api.nvim_create_augroup("lsp_config", {})
vim.api.nvim_create_autocmd("LspAttach", {
	group = lsp_group,
	callback = function(args)
		-- Enable completion triggered by <c-x><c-o>
		vim.bo[args.buf].omnifunc = "v:lua.vim.lsp.omnifunc"

		-- LSP diagnostic
		local diag = vim.diagnostic
		vim.keymap.set("n", "ge", diag.open_float)
		vim.keymap.set("n", "g[", diag.goto_prev)
		vim.keymap.set("n", "g]", diag.goto_next)
		vim.keymap.set("n", "gl", diag.setloclist)

		-- Buffer local mappings
		-- See `:help vim.lsp.*` for documentation on any of the below functions
		local lsp_buf = vim.lsp.buf
		local opts = { buffer = args.buf }
		vim.keymap.set("n", "gD", lsp_buf.declaration, opts)
		vim.keymap.set("n", "gd", lsp_buf.definition, opts)
		vim.keymap.set("n", "gk", lsp_buf.hover, opts)
		vim.keymap.set("n", "gh", lsp_buf.signature_help, opts)
		vim.keymap.set({ "n", "v" }, "gra", lsp_buf.code_action, opts)
		vim.keymap.set("n", "gri", lsp_buf.implementation, opts)
		vim.keymap.set("n", "grn", lsp_buf.rename, opts)
		vim.keymap.set("n", "grr", lsp_buf.references, opts)
		vim.keymap.set("n", "grt", lsp_buf.type_definition, opts)
		vim.keymap.set("n", "grf", function()
			lsp_buf.format({ async = true })
		end, opts)
		-- workspace
		vim.keymap.set("n", "gwa", lsp_buf.add_workspace_folder, opts)
		vim.keymap.set("n", "gwr", lsp_buf.remove_workspace_folder, opts)
		vim.keymap.set("n", "gwl", function()
			print(vim.inspect(lsp_buf.list_workspace_folders()))
		end, opts)
	end,
})

-- Terminal
local term_group = vim.api.nvim_create_augroup("terminal", { clear = true })
vim.api.nvim_create_autocmd("TermOpen", {
	group = term_group,
	callback = function()
		vim.cmd("startinsert")
		vim.cmd("setlocal nonumber")
		vim.cmd("setlocal norelativenumber")
	end,
})

-- Related lazy
if flags.enable_lazy then
	-- Only update context when cursorHold event
	vim.api.nvim_create_autocmd("BufEnter", {
		group = vim.api.nvim_create_augroup("nvim-navic", {}),
		callback = function()
			if vim.api.nvim_buf_line_count(0) > 10000 then
				vim.b.navic_lazy_update_context = true
			end
		end,
	})
end
