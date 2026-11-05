-- Colours, icons, statusline, notifications, pickers, which-key

-- Oxocarbon draws float borders in the float's own background colour (invisible).
-- Make them the same blue as the active tmux pane border. Re-applied if the scheme reloads.
vim.api.nvim_create_autocmd("ColorScheme", {
  group = vim.api.nvim_create_augroup("anton_colors", { clear = true }),
  callback = function()
    local float_bg = vim.api.nvim_get_hl(0, { name = "NormalFloat", link = false }).bg
    vim.api.nvim_set_hl(0, "FloatBorder", { fg = "#78a9ff", bg = float_bg })
    vim.api.nvim_set_hl(0, "FloatTitle", { fg = "#78a9ff", bg = float_bg, bold = true })
    vim.api.nvim_set_hl(0, "BlinkCmpMenuBorder", { link = "FloatBorder" })
    vim.api.nvim_set_hl(0, "BlinkCmpDocBorder", { link = "FloatBorder" })
    vim.api.nvim_set_hl(0, "BlinkCmpSignatureHelpBorder", { link = "FloatBorder" })
  end,
})
vim.cmd.colorscheme("oxocarbon")

require("mini.icons").setup()
require("mini.icons").mock_nvim_web_devicons() -- for plugins that expect nvim-web-devicons

-- snacks.nvim: a bundle of small tools (picker, lazygit, dashboard, notifications, ...)
require("snacks").setup({
  picker = {
    sources = {
      files = { hidden = true },
      grep = { hidden = true },
      explorer = { hidden = true },
    },
  },
  dashboard = {
    preset = {
      keys = {
        { icon = " ", key = "f", desc = "Find file", action = ":lua Snacks.picker.files()" },
        { icon = " ", key = "w", desc = "Find word (grep)", action = ":lua Snacks.picker.grep()" },
        { icon = " ", key = "r", desc = "Recent files", action = ":lua Snacks.picker.recent()" },
        { icon = " ", key = "n", desc = "New file", action = ":ene | startinsert" },
        { icon = " ", key = "g", desc = "Lazygit", action = ":lua Snacks.lazygit()" },
        { icon = " ", key = "c", desc = "Nvim config", action = ":lua Snacks.picker.files({ cwd = vim.fn.stdpath('config') })" },
        { icon = " ", key = "?", desc = "All shortcuts", action = ":lua Snacks.picker.keymaps()" },
        { icon = " ", key = "q", desc = "Quit", action = ":qa" },
      },
    },
    sections = {
      { section = "header" },
      { section = "keys", gap = 1, padding = 1 },
      { text = { "Tip: press <Space> and wait to see every shortcut", hl = "Comment" }, align = "center" },
    },
  },
  notifier = { enabled = true },
  indent = { enabled = true, animate = { enabled = false } },
  input = { enabled = true },
  words = { enabled = true }, -- highlight other uses of the word under the cursor
  bigfile = { enabled = true },
  lazygit = { configure = true },
})

require("lualine").setup({
  options = {
    theme = "auto",
    globalstatus = true,
    component_separators = "",
    section_separators = "",
  },
})

-- `:` command line as a floating window in the middle of the screen (needs Neovim 0.12's ui2,
-- which also shows messages in small floats instead of the bottom line)
require("vim._core.ui2").enable({})
require("tiny-cmdline").setup({
  position = { y = "20%" },
  on_reposition = require("tiny-cmdline").adapters.blink, -- completion menu follows the float
})

require("which-key").setup({
  preset = "modern",
  spec = {
    { "<leader>b", group = "buffer" },
    { "<leader>c", group = "code" },
    { "<leader>d", group = "debug" },
    { "<leader>f", group = "find" },
    { "<leader>g", group = "git" },
    { "<leader>u", group = "toggle" },
    { "<leader>x", group = "diagnostics/lists" },
  },
})

require("trouble").setup()
require("todo-comments").setup({ signs = false })
require("fidget").setup() -- LSP progress in the corner
