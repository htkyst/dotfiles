return {
	{
		-- Split window resizer
		"simeji/winresizer",
		keys = {
			{ "<leader>w", ":WinResizerStartResize<CR>", desc = "WinResizerStartResize" },
		},
	},

	{
		-- Zoom window
		"troydm/zoomwintab.vim",
		keys = {
			{ "<leader>wo", ":ZoomWinTabToggle<CR>", desc = "ZoomWinTabToggle" },
		},
	},
}
