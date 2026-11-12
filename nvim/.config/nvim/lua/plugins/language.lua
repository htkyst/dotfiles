return {
	{
		-- Need: TSInstall
		"windwp/nvim-ts-autotag",
		event = "InsertEnter",
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
		},
		config = function()
			require("nvim-ts-autotag").setup({
				per_filetype = {
					["html"] = {
						enable_close = true,
					},
					["tsx"] = {
						enable_close = true,
					},
				},
			})
		end,
	},
}
