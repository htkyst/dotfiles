return {
  {
    "williamboman/mason-lspconfig.nvim",
    version = "^1.0.0",
    dependencies = {
      "neovim/nvim-lspconfig",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      local mason_lspconfig = require("mason-lspconfig")
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      local servers = {
        "lua_ls",
        "rust_analyzer",
        "clangd",
      }

      mason_lspconfig.setup({
        ensure_installed = servers,
        automatic_installation = true,
      })

      -- lua_ls
      vim.lsp.config.lua_ls = {
        capabilities = capabilities,
        settings = {
          Lua = {
            runtime = {
              version = "LuaJIT",
            },
            workspace = {
              checkThirdParty = false,
              library = {
                vim.env.VIMRUNTIME,
              },
            },
            diagnostics = {
              globals = { "vim" },
            },
          },
        },
      }

      -- rust_analyzer
      vim.lsp.config.rust_analyzer = {
        capabilities = capabilities,
        settings = {
          ["rust-analyzer"] = {
            cargo = {
              allFeatures = true,
            },
            checkOnSave = {
              command = "clippy",
            },
          },
        },
      }

      -- clangd
      vim.lsp.config.clangd = {
        capabilities = capabilities,
      }

      vim.lsp.enable(servers)
    end,
  },
}

