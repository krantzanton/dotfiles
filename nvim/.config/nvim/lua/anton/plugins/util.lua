-- File managers and tmux navigation

-- oil: edit the file system like a buffer. `-` opens the parent folder, <leader>e a float.
require("oil").setup({
  columns = { "icon" },
  keymaps = {
    ["q"] = { "actions.close", mode = "n" },
  },
  view_options = { show_hidden = true },
  float = { border = "rounded", max_width = 120 },
  lsp_file_methods = { enabled = true, autosave_changes = true }, -- renames update imports
})

-- yazi: full terminal file manager, <leader>-
require("yazi").setup({
  open_for_directories = false,
  keymaps = { show_help = "<f1>" },
})

-- vim-tmux-navigator needs no setup: Ctrl-h/j/k/l move between nvim splits and tmux panes
