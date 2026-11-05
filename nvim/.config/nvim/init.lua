-- Neovim config. Structure inspired by craftzdog/dotfiles:
--   lua/anton/config/   plain Neovim settings (options, keymaps, autocmds)
--   lua/anton/plugins/  init.lua lists every plugin (vim.pack), the other files set them up
-- Press <Space> and wait to see all shortcuts, or <Space>? to search them.

if vim.fn.has("nvim-0.12") == 0 then
  vim.api.nvim_echo({ { "This config needs Neovim 0.12+ (run ./bootstrap.sh --update)", "ErrorMsg" } }, true, {})
  return
end

vim.loader.enable()

vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_netrw = 1 -- oil and yazi replace netrw
vim.g.loaded_netrwPlugin = 1

require("anton.config.options")
require("anton.config.keymaps")
require("anton.config.autocmds")
require("anton.plugins")
