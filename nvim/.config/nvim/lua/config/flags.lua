local M = {}

M.use_vscode = (vim.g.vscode == nil)
M.enable_lazy = M.use_vscode

return M
