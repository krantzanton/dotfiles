-- Plain Neovim keymaps. Plugin keymaps are in lua/anton/plugins/keymaps.lua.
-- Ctrl-h/j/k/l window movement: vim-tmux-navigator (plugins/util.lua)

local map = vim.keymap.set

map("n", "<leader>w", "<cmd>write<cr>", { desc = "Write file" })
map("n", "<leader>q", "<cmd>quit<cr>", { desc = "Quit window" })
map("n", "<Esc>", "<cmd>nohlsearch<cr>")

-- Move selected lines up/down
map("v", "J", ":m '>+1<cr>gv=gv", { desc = "Move selection down", silent = true })
map("v", "K", ":m '<-2<cr>gv=gv", { desc = "Move selection up", silent = true })

-- Keep the cursor centered when jumping
map("n", "<C-d>", "<C-d>zz")
map("n", "<C-u>", "<C-u>zz")
map("n", "n", "nzzzv")
map("n", "N", "Nzzzv")

-- Stay in visual mode when indenting
map("v", "<", "<gv")
map("v", ">", ">gv")

-- Paste over a selection without losing what you yanked
map("x", "<leader>p", [["_dP]], { desc = "Paste without yanking" })

-- Buffers
map("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Previous buffer" })
map("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next buffer" })
map("n", "<leader>bd", "<cmd>bdelete<cr>", { desc = "Delete buffer" })

-- Diagnostics (]d / [d to jump are built in)
map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Line diagnostics" })

-- Quickfix list
map("n", "]q", "<cmd>cnext<cr>", { desc = "Next quickfix" })
map("n", "[q", "<cmd>cprev<cr>", { desc = "Previous quickfix" })
