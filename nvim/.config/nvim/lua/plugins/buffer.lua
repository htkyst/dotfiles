return {
	"psjay/buffer-closer.nvim",
	event = { "BufEnter" },
	config = function()
		require("buffer-closer").setup({
			close_key = "q",
		})
	end,
}
