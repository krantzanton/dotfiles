local opt = vim.opt

opt.cmdheight = 0 -- command line floats in the middle instead (tiny-cmdline, plugins/ui.lua)
opt.winborder = "rounded" -- borders on all floating windows (hover, diagnostics, ...)
opt.number = true
opt.relativenumber = true
opt.mouse = "a"
opt.clipboard = "unnamedplus"
opt.ignorecase = true
opt.smartcase = true
opt.splitright = true
opt.splitbelow = true
opt.splitkeep = "screen"
opt.termguicolors = true
opt.signcolumn = "yes"
opt.updatetime = 250
opt.timeoutlen = 300
opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.smartindent = true
opt.breakindent = true
opt.wrap = false
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.cursorline = true
opt.undofile = true -- undo history survives closing the file
opt.inccommand = "split" -- live preview of :s substitutions
opt.confirm = true -- ask instead of failing on :q with unsaved changes
opt.completeopt = { "menu", "menuone", "noselect" }
opt.list = true
opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
opt.fillchars = { eob = " ", fold = " " }

-- Folding by code structure (treesitter). Files open unfolded; za toggles the fold under
-- the cursor, zR / zM open / close all. Press z and wait to see the rest.
opt.foldmethod = "expr"
opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
opt.foldlevel = 99
opt.foldtext = "" -- folded line keeps its syntax colours

-- Go uses real tabs; show them 4 wide
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "go", "gomod", "gowork", "make" },
  callback = function()
    vim.opt_local.expandtab = false
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.listchars = { tab = "  ", trail = "·", nbsp = "␣" }
  end,
})

vim.diagnostic.config({
  severity_sort = true,
  virtual_text = { spacing = 2, prefix = "●" },
  float = { border = "rounded", source = "if_many" },
  underline = true,
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = " ",
      [vim.diagnostic.severity.WARN] = " ",
      [vim.diagnostic.severity.INFO] = " ",
      [vim.diagnostic.severity.HINT] = "󰌵 ",
    },
  },
})
