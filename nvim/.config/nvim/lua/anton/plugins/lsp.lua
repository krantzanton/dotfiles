-- Language servers. Mason installs servers + tools into ~/.local/share/nvim/mason (:Mason).
-- clangd and glsl_analyzer come from the system, not Mason.
-- Shortcuts (gd, gr, K, <leader>c...) are in keymaps.lua.

require("mason").setup({ ui = { border = "rounded" } })
require("mason-tool-installer").setup({
  ensure_installed = {
    -- language servers
    "gopls",
    "vtsls", -- TypeScript / JavaScript / React
    "eslint-lsp",
    "tailwindcss-language-server",
    "emmet-language-server", -- div.flex>p expands to HTML/JSX
    "html-lsp",
    "css-lsp",
    "json-lsp",
    "lua-language-server",
    "bash-language-server",
    -- formatters, linters, debuggers
    "prettierd",
    "stylua",
    "goimports",
    "gofumpt",
    "shfmt",
    "shellcheck",
    "delve",
    -- compiles treesitter parsers
    "tree-sitter-cli",
  },
  run_on_start = true,
})

require("lazydev").setup({
  library = { { path = "${3rd}/luv/library", words = { "vim%.uv" } } },
})

vim.lsp.config("*", {
  capabilities = require("blink.cmp").get_lsp_capabilities(),
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
  parameterNames = { enabled = "literals" },
  parameterTypes = { enabled = true },
  variableTypes = { enabled = false },
  propertyDeclarationTypes = { enabled = true },
  functionLikeReturnTypes = { enabled = true },
  enumMemberValues = { enabled = true },
}
vim.lsp.config("vtsls", {
  settings = {
    typescript = { inlayHints = ts_hints },
    javascript = { inlayHints = ts_hints },
  },
})

-- Tailwind completion also inside class helper functions common in React projects
vim.lsp.config("tailwindcss", {
  settings = {
    tailwindCSS = {
      classFunctions = { "cn", "clsx", "cva", "tw", "twMerge" },
    },
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

vim.lsp.enable({
  "gopls",
  "vtsls",
  "eslint",
  "tailwindcss",
  "emmet_language_server",
  "html",
  "cssls",
  "jsonls",
  "lua_ls",
  "bashls",
})

-- System-installed servers, only if present
for _, name in ipairs({ "clangd", "glsl_analyzer" }) do
  if vim.fn.executable(vim.lsp.config[name].cmd[1]) == 1 then
    vim.lsp.enable(name)
  end
end
