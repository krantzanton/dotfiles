-- Language servers.
-- Mason installs servers + tools into ~/.local/share/nvim/mason; open it with :Mason.
-- clangd and glsl_analyzer come from the system, not Mason.

-- Servers Mason should install (lspconfig names)
local servers = {
  "gopls", -- Go
  "ts_ls", -- TypeScript / JavaScript / React
  "eslint", -- ESLint diagnostics + fixes
  "tailwindcss",
  "html",
  "cssls",
  "jsonls",
  "lua_ls",
  "bashls",
}

-- Formatters / debuggers (Mason package names)
local tools = {
  "prettierd",
  "stylua",
  "goimports",
  "gofumpt",
  "delve",
  "shfmt",
}

return {
  { "mason-org/mason.nvim", cmd = "Mason", opts = { ui = { border = "rounded" } } },

  -- Better Lua LSP for editing this config
  {
    "folke/lazydev.nvim",
    ft = "lua",
    opts = { library = { { path = "${3rd}/luv/library", words = { "vim%.uv" } } } },
  },

  -- LSP progress in the corner
  { "j-hui/fidget.nvim", event = "LspAttach", opts = {} },

  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "mason-org/mason.nvim",
      "mason-org/mason-lspconfig.nvim",
      "WhoIsSethDaniel/mason-tool-installer.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      vim.lsp.config("*", {
        capabilities = require("cmp_nvim_lsp").default_capabilities(),
      })

      vim.lsp.config("clangd", {
        init_options = { fallbackFlags = { "--std=c++23" } },
      })

      vim.lsp.config("glsl_analyzer", {
        cmd = { "glsl_analyzer" },
        filetypes = { "glsl" },
      })

      vim.lsp.config("gopls", {
        settings = {
          gopls = {
            gofumpt = true,
            staticcheck = true,
            completeUnimported = true,
            usePlaceholders = false,
            analyses = { unusedparams = true, unusedwrite = true, nilness = true, useany = true },
            hints = {
              assignVariableTypes = true,
              compositeLiteralFields = true,
              constantValues = true,
              functionTypeParameters = true,
              parameterNames = true,
              rangeVariableTypes = true,
            },
          },
        },
      })

      local ts_hints = {
        includeInlayParameterNameHints = "literals",
        includeInlayFunctionParameterTypeHints = true,
        includeInlayVariableTypeHints = false,
        includeInlayPropertyDeclarationTypeHints = true,
        includeInlayFunctionLikeReturnTypeHints = true,
        includeInlayEnumMemberValueHints = true,
      }
      vim.lsp.config("ts_ls", {
        settings = {
          typescript = { inlayHints = ts_hints },
          javascript = { inlayHints = ts_hints },
        },
      })

      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            workspace = { checkThirdParty = false },
            completion = { callSnippet = "Replace" },
            hint = { enable = true },
          },
        },
      })

      -- Installs the servers above and enables them automatically
      require("mason-lspconfig").setup({ ensure_installed = servers, automatic_enable = true })
      require("mason-tool-installer").setup({ ensure_installed = tools })

      -- System-installed servers
      for _, name in ipairs({ "clangd", "glsl_analyzer" }) do
        if vim.fn.executable(vim.lsp.config[name].cmd[1]) == 1 then
          vim.lsp.enable(name)
        end
      end

      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("user_lsp", { clear = true }),
        callback = function(args)
          local map = function(keys, fn, desc, mode)
            vim.keymap.set(mode or "n", keys, fn, { buffer = args.buf, desc = desc })
          end
          local tb = require("telescope.builtin")

          map("gd", tb.lsp_definitions, "Go to definition")
          map("gD", vim.lsp.buf.declaration, "Go to declaration")
          map("gr", tb.lsp_references, "References")
          map("gi", tb.lsp_implementations, "Go to implementation")
          map("gy", tb.lsp_type_definitions, "Go to type definition")
          map("K", function()
            vim.lsp.buf.hover({ border = "rounded" })
          end, "Hover docs")
          map("<C-k>", function()
            vim.lsp.buf.signature_help({ border = "rounded" })
          end, "Signature help", "i")
          map("<leader>rn", vim.lsp.buf.rename, "Rename symbol")
          map("<leader>ca", vim.lsp.buf.code_action, "Code action", { "n", "v" })
          map("<leader>fs", tb.lsp_document_symbols, "Document symbols")
          map("<leader>fS", tb.lsp_dynamic_workspace_symbols, "Workspace symbols")

          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if client and client:supports_method("textDocument/inlayHint") then
            map("<leader>ch", function()
              local on = vim.lsp.inlay_hint.is_enabled({ bufnr = args.buf })
              vim.lsp.inlay_hint.enable(not on, { bufnr = args.buf })
            end, "Toggle inlay hints")
          end

          -- Fix all ESLint problems
          if client and client.name == "eslint" then
            map("<leader>cl", "<cmd>LspEslintFixAll<cr>", "ESLint fix all")
          end
        end,
      })
    end,
  },
}
