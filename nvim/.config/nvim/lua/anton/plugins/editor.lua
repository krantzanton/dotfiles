-- Completion, pairs, text objects, git signs, formatting

-- Completion. Enter accepts, Tab / Shift-Tab move, Ctrl-Space opens the menu.
require("blink.cmp").setup({
  keymap = {
    preset = "enter",
    ["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
    ["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
  },
  completion = {
    list = { selection = { preselect = false } },
    documentation = { auto_show = true, auto_show_delay_ms = 200, window = { border = "rounded" } },
    menu = { border = "rounded" },
  },
  sources = {
    default = { "lazydev", "lsp", "path", "snippets", "buffer" },
    providers = {
      lazydev = { name = "LazyDev", module = "lazydev.integrations.blink", score_offset = 100 },
    },
  },
  signature = { enabled = true, window = { border = "rounded" } },

  -- `:` command line: suggestions pop up as you type (like craftzdog's setup).
  -- Tab / Shift-Tab move through them, Enter runs the command, Ctrl-e closes the list.
  cmdline = {
    enabled = true,
    keymap = {
      preset = "cmdline",
      ["<Right>"] = false, -- keep arrow keys for moving the cursor
      ["<Left>"] = false,
    },
    completion = {
      list = { selection = { preselect = false } },
      menu = {
        auto_show = function()
          return vim.fn.getcmdtype() == ":" -- not for / searches
        end,
      },
      ghost_text = { enabled = true },
    },
  },
})

require("mini.pairs").setup()
require("mini.surround").setup() -- sa / sd / sr: add, delete, replace surroundings

-- Better text objects: va), cif (function call), ciq (quote), cia (argument)...
local ai = require("mini.ai")
ai.setup({
  n_lines = 500,
  custom_textobjects = { f = ai.gen_spec.function_call() },
})

require("gitsigns").setup()

-- Formatting: on save, toggle with <leader>uf. Unlisted filetypes use the LSP formatter
-- (e.g. clangd for C/C++).
local web = { "prettierd", "prettier", stop_after_first = true }
require("conform").setup({
  formatters_by_ft = {
    lua = { "stylua" },
    go = { "goimports", "gofumpt" },
    javascript = web,
    javascriptreact = web,
    typescript = web,
    typescriptreact = web,
    json = web,
    jsonc = web,
    css = web,
    scss = web,
    html = web,
    yaml = web,
    markdown = web,
    graphql = web,
    sh = { "shfmt" },
    bash = { "shfmt" },
    fish = { "fish_indent" },
  },
  format_on_save = function(bufnr)
    if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
      return
    end
    return { timeout_ms = 1000, lsp_format = "fallback" }
  end,
})
