vim.g.mapleader = " "
vim.g.maplocalleader = " "

local keymap = vim.keymap.set

keymap("n", "<leader>w", "<cmd>write<cr>", { desc = "Write file" })
keymap("n", "<leader>q", "<cmd>quit<cr>", { desc = "Quit window" })
keymap("n", "<Esc>", "<cmd>nohlsearch<cr>")

keymap("n", "<leader>e", "<cmd>Ex<cr>", { desc = "File explorer" })

keymap("n", "<C-h>", "<C-w>h")
keymap("n", "<C-j>", "<C-w>j")
keymap("n", "<C-k>", "<C-w>k")
keymap("n", "<C-l>", "<C-w>l")

vim.keymap.set("n", "gd", vim.lsp.buf.definition)
vim.keymap.set("n", "gr", vim.lsp.buf.references)
vim.keymap.set("n", "K", vim.lsp.buf.hover)
vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename)

config = function()
  local gs = require("gitsigns")

  gs.setup()

  vim.keymap.set("n", "<leader>gp", gs.preview_hunk)
end
