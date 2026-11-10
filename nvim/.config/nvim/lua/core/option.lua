local function nvim_set_option_value(name, value, opts)
	vim.api.nvim_set_option_value(name, value, opts or {})
end

nvim_set_option_value("number", true)
nvim_set_option_value("relativenumber", true)
nvim_set_option_value("encoding", "utf-8")
nvim_set_option_value("fileencoding", "utf-8")
nvim_set_option_value("showcmd", true)
nvim_set_option_value("splitbelow", true)
nvim_set_option_value("splitright", true)
nvim_set_option_value("wildmenu", true)
nvim_set_option_value("smartindent", true)
nvim_set_option_value("ruler", true)
nvim_set_option_value("cursorline", true)
nvim_set_option_value("hidden", true)
nvim_set_option_value("expandtab", true)
nvim_set_option_value("tabstop", 4)
nvim_set_option_value("shiftwidth", 4)
nvim_set_option_value("wrap", false)
nvim_set_option_value("undofile", false)
nvim_set_option_value("swapfile", false)
nvim_set_option_value("termguicolors", true, { scope = "global" })
nvim_set_option_value("modifiable", true)
nvim_set_option_value("showmode", false)
nvim_set_option_value("shellquote", '"')
nvim_set_option_value("shellxquote", "")
nvim_set_option_value("scrolloff", 4)
nvim_set_option_value("inccommand", "split")
nvim_set_option_value("incsearch", true)
nvim_set_option_value("clipboard", "unnamed")
nvim_set_option_value("clipboard", "unnamedplus")
nvim_set_option_value("winblend", 20, { win = 0 })
nvim_set_option_value("pumblend", 10)
nvim_set_option_value("spell", true)

if os.getenv("OS") then
	-- Windows
	nvim_set_option_value("shellcmdflag", "-command")
	nvim_set_option_value("shell", "pwsh.exe")
elseif os.getenv("HOME") then
	-- Unix
	nvim_set_option_value("shell", "bash")
end
