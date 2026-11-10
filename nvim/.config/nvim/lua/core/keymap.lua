local flags = require("config.flags")

-- Terminal
if flags.use_vscode then
	vim.keymap.set("t", "<ESC>", "<C-\\><C-n>", { silent = true })
	vim.keymap.set("n", "tt", "<cmd>belowright new<CR><cmd>terminal<CR>", { silent = true })
end

-- Move buffer
vim.keymap.set("n", "bn", ":bn<CR>", { silent = true })
vim.keymap.set("n", "bp", ":bp<CR>", { silent = true })

-- Move pane
vim.keymap.set("n", "<leader>h", "<C-w>h", { silent = true })
vim.keymap.set("n", "<leader>j", "<C-w>j", { silent = true })
vim.keymap.set("n", "<leader>k", "<C-w>k", { silent = true })
vim.keymap.set("n", "<leader>l", "<C-w>l", { silent = true })

-- Split pane
vim.keymap.set("n", "ss", ":split<Return><C-w>w")
vim.keymap.set("n", "vv", ":vsplit<Return><C-w>w")
