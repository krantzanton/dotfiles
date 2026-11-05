-- Every plugin, in one list. vim.pack (built into Neovim 0.12) installs anything missing on
-- startup and pins versions in nvim-pack-lock.json (commit that file).
-- Update:  :lua vim.pack.update()      Remove: delete it here, then :lua vim.pack.del({ "name" })
local gh = function(repo)
  return "https://github.com/" .. repo
end

vim.pack.add({
  -- UI
  { src = gh("nyoom-engineering/oxocarbon.nvim") },
  { src = gh("nvim-mini/mini.icons") },
  { src = gh("folke/snacks.nvim") },
  { src = gh("folke/which-key.nvim") },
  { src = gh("nvim-lualine/lualine.nvim") },
  { src = gh("folke/trouble.nvim") },
  { src = gh("folke/todo-comments.nvim") },
  { src = gh("j-hui/fidget.nvim") },
  { src = gh("rachartier/tiny-cmdline.nvim") },
  -- Editor
  { src = gh("saghen/blink.cmp"), version = vim.version.range("^1") },
  { src = gh("rafamadriz/friendly-snippets") },
  { src = gh("nvim-mini/mini.pairs") },
  { src = gh("nvim-mini/mini.surround") },
  { src = gh("nvim-mini/mini.ai") },
  { src = gh("lewis6991/gitsigns.nvim") },
  { src = gh("stevearc/conform.nvim") },
  -- Treesitter
  { src = gh("nvim-treesitter/nvim-treesitter"), version = "main" },
  { src = gh("nvim-treesitter/nvim-treesitter-context") },
  { src = gh("windwp/nvim-ts-autotag") },
  -- LSP
  { src = gh("neovim/nvim-lspconfig") },
  { src = gh("mason-org/mason.nvim") },
  { src = gh("WhoIsSethDaniel/mason-tool-installer.nvim") },
  { src = gh("folke/lazydev.nvim") },
  -- Debugging
  { src = gh("mfussenegger/nvim-dap") },
  { src = gh("nvim-neotest/nvim-nio") },
  { src = gh("rcarriga/nvim-dap-ui") },
  { src = gh("theHamsta/nvim-dap-virtual-text") },
  { src = gh("leoluz/nvim-dap-go") },
  -- Util
  { src = gh("stevearc/oil.nvim") },
  { src = gh("mikavilpas/yazi.nvim") },
  { src = gh("nvim-lua/plenary.nvim") }, -- needed by yazi.nvim and todo-comments
  { src = gh("christoomey/vim-tmux-navigator") },
})

require("anton.plugins.ui")
require("anton.plugins.treesitter")
require("anton.plugins.editor")
require("anton.plugins.lsp")
require("anton.plugins.debug")
require("anton.plugins.util")
require("anton.plugins.keymaps")
