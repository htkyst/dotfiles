return {

	{
		-- Auto pair
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		config = true,
	},

	{
		-- Smooth scrolling
		"karb94/neoscroll.nvim",
		config = true,
	},

	{
		-- Scroll bar
		"petertriho/nvim-scrollbar",
        branch = "v1",
		config = true,
	},

	{
		-- Show hightlight count
		"kevinhwang91/nvim-hlslens",
		config = function()
			require("scrollbar.handlers.search").setup()
		end,
	},

	{
		-- 日本語入力のままInsert modeに移行する
		"pepo-le/win-ime-con.nvim",
		event = "VeryLazy",
	},

	{
		-- Doxygen generater
		"danymat/neogen",
		event = "VeryLazy",
		version = "*",
		config = function()
			require("neogen").setup({
				enabled = true,
			})
		end,
	},

	{
		-- Automatically highlighting other uses of the word
		"RRethy/vim-illuminate",
	},
}
