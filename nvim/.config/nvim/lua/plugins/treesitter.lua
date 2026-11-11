return {
    {
        "nvim-treesitter/nvim-treesitter",
        branch = "main",
        lazy = false,
        build = ":TSUpdate",
        -- dependencies = {
        --     "nvim-treesitter/nvim-treesitter-textobjects",
        -- },
        config = function()
            local treesitter = require("nvim-treesitter")

            treesitter.setup({})

            treesitter.install({
                "lua",
                "vim",
                "vimdoc",
                "bash",
            })
        end,
    },

    {
        "nvim-treesitter/nvim-treesitter-context",
        event = "BufReadPost",
        config = function()
            require("treesitter-context").setup()

            vim.keymap.set("n", "[c", function()
                require("treesitter-context").go_to_context(vim.v.count1)
            end, { silent = true })
        end,
    },
}
