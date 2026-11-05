-- All plugin shortcuts in one place. Every one has a `desc`, so it shows up in the
-- which-key menu (<Space> and wait) and in the searchable list (<Space>?).

local map = function(mode, lhs, rhs, desc, opts)
  vim.keymap.set(mode, lhs, rhs, vim.tbl_extend("force", { desc = desc, silent = true }, opts or {}))
end

-- Help yourself ---------------------------------------------------------------
map("n", "<leader>?", function() Snacks.picker.keymaps() end, "Search all shortcuts")
map("n", "<leader>fk", function() Snacks.picker.keymaps() end, "Shortcuts")

-- Find (snacks picker) --------------------------------------------------------
map("n", "<leader>ff", function() Snacks.picker.files() end, "Files")
map("n", "<leader>fw", function() Snacks.picker.grep() end, "Word (grep project)")
map({ "n", "x" }, "<leader>fc", function() Snacks.picker.grep_word() end, "Word under cursor / selection")
map("n", "<leader>fr", function() Snacks.picker.recent() end, "Recent files")
map("n", "<leader>fb", function() Snacks.picker.buffers() end, "Buffers")
map("n", "<leader><leader>", function() Snacks.picker.buffers() end, "Buffers")
map("n", "<leader>f/", function() Snacks.picker.lines() end, "Search in buffer")
map("n", "<leader>f.", function() Snacks.picker.resume() end, "Resume last search")
map("n", "<leader>fh", function() Snacks.picker.help() end, "Help pages")
map("n", "<leader>fd", function() Snacks.picker.diagnostics() end, "Diagnostics")
map("n", "<leader>ft", function() Snacks.picker.todo_comments() end, "TODOs")
map("n", "<leader>fn", function() Snacks.picker.files({ cwd = vim.fn.stdpath("config") }) end, "Nvim config file")
map("n", "<leader>fN", function() Snacks.picker.notifications() end, "Notification history")

-- Files -----------------------------------------------------------------------
map("n", "-", "<cmd>Oil<cr>", "Open parent folder (oil)")
map("n", "<leader>e", function() require("oil").open_float() end, "File explorer (oil float)")
map({ "n", "v" }, "<leader>-", "<cmd>Yazi<cr>", "Yazi at current file")

-- Buffers ---------------------------------------------------------------------
map("n", "<leader>bd", function() Snacks.bufdelete() end, "Delete buffer")
map("n", "<leader>bo", function() Snacks.bufdelete.other() end, "Delete other buffers")

-- LSP (only in buffers with a language server) -----------------------------------
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("anton_lsp_keys", { clear = true }),
  callback = function(args)
    local buf = { buffer = args.buf }
    local nowait = { buffer = args.buf, nowait = true }
    map("n", "gd", function() Snacks.picker.lsp_definitions() end, "Go to definition", buf)
    map("n", "gD", function() Snacks.picker.lsp_declarations() end, "Go to declaration", buf)
    map("n", "gr", function() Snacks.picker.lsp_references() end, "References", nowait)
    map("n", "gi", function() Snacks.picker.lsp_implementations() end, "Go to implementation", buf)
    map("n", "gy", function() Snacks.picker.lsp_type_definitions() end, "Go to type definition", buf)
    map("n", "K", function() vim.lsp.buf.hover({ border = "rounded" }) end, "Hover docs", buf)
    map("i", "<C-k>", function() vim.lsp.buf.signature_help({ border = "rounded" }) end, "Signature help", buf)
    map({ "n", "x" }, "<leader>ca", vim.lsp.buf.code_action, "Code action", buf)
    map("n", "<leader>cr", vim.lsp.buf.rename, "Rename symbol", buf)
    map("n", "<leader>cR", function() Snacks.rename.rename_file() end, "Rename file (updates imports)", buf)
    map("n", "<leader>cl", function() Snacks.picker.lsp_config() end, "LSP info", buf)
    map("n", "<leader>fs", function() Snacks.picker.lsp_symbols() end, "Symbols (file)", buf)
    map("n", "<leader>fS", function() Snacks.picker.lsp_workspace_symbols() end, "Symbols (project)", buf)
    map("n", "]]", function() Snacks.words.jump(vim.v.count1) end, "Next use of word", buf)
    map("n", "[[", function() Snacks.words.jump(-vim.v.count1) end, "Previous use of word", buf)

    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client and client.name == "eslint" then
      map("n", "<leader>ce", "<cmd>LspEslintFixAll<cr>", "ESLint fix all", buf)
    end
  end,
})

-- Code ------------------------------------------------------------------------
map({ "n", "v" }, "<leader>cf", function() require("conform").format({ async = true, lsp_format = "fallback" }) end, "Format")
map("n", "<leader>cd", vim.diagnostic.open_float, "Line diagnostics")

-- Toggles (which-key shows whether each is on or off) ----------------------------
Snacks.toggle.new({
  id = "format_on_save",
  name = "Format on save",
  get = function() return not vim.g.disable_autoformat end,
  set = function(on) vim.g.disable_autoformat = not on end,
}):map("<leader>uf")
Snacks.toggle.inlay_hints():map("<leader>uh")
Snacks.toggle.diagnostics():map("<leader>ud")
Snacks.toggle.option("wrap", { name = "Line wrap" }):map("<leader>uw")
Snacks.toggle.option("relativenumber", { name = "Relative numbers" }):map("<leader>ur")
Snacks.toggle.option("spell", { name = "Spell check" }):map("<leader>us")

-- Git -------------------------------------------------------------------------
local gs = require("gitsigns")
map("n", "<leader>gg", function() Snacks.lazygit() end, "Lazygit")
map("n", "<leader>gl", function() Snacks.lazygit.log_file() end, "Log of this file (lazygit)")
map("n", "<leader>gc", function() Snacks.picker.git_log() end, "Commits")
map("n", "<leader>gS", function() Snacks.picker.git_status() end, "Changed files")
map("n", "]h", function() gs.nav_hunk("next") end, "Next git hunk")
map("n", "[h", function() gs.nav_hunk("prev") end, "Previous git hunk")
map("n", "<leader>gp", gs.preview_hunk, "Preview hunk")
map("n", "<leader>gs", gs.stage_hunk, "Stage/unstage hunk")
map("n", "<leader>gr", gs.reset_hunk, "Reset hunk")
map("v", "<leader>gs", function() gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "Stage selected lines")
map("v", "<leader>gr", function() gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "Reset selected lines")
map("n", "<leader>gR", gs.reset_buffer, "Reset whole file")
map("n", "<leader>gb", function() gs.blame_line({ full = true }) end, "Blame line")
map("n", "<leader>gB", gs.toggle_current_line_blame, "Toggle inline blame")
map("n", "<leader>gd", gs.diffthis, "Diff against index")
map("n", "<leader>go", function() Snacks.gitbrowse() end, "Open in browser (GitHub)")
map({ "o", "x" }, "ih", gs.select_hunk, "Inside hunk")

-- Diagnostics / lists (Trouble) ------------------------------------------------
map("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", "Diagnostics (project)")
map("n", "<leader>xb", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", "Diagnostics (buffer)")
map("n", "<leader>xs", "<cmd>Trouble symbols toggle focus=false<cr>", "Symbols outline")
map("n", "<leader>xq", "<cmd>Trouble qflist toggle<cr>", "Quickfix list")
map("n", "<leader>xt", "<cmd>Trouble todo toggle<cr>", "TODOs")

-- Debugging -------------------------------------------------------------------
local dap = require("dap")
map("n", "<F5>", dap.continue, "Debug: start/continue")
map("n", "<F10>", dap.step_over, "Debug: step over")
map("n", "<F11>", dap.step_into, "Debug: step into")
map("n", "<S-F11>", dap.step_out, "Debug: step out")
map("n", "<leader>db", dap.toggle_breakpoint, "Toggle breakpoint")
map("n", "<leader>dB", function() dap.set_breakpoint(vim.fn.input("Condition: ")) end, "Conditional breakpoint")
map("n", "<leader>dc", dap.continue, "Start/continue")
map("n", "<leader>dr", dap.restart, "Restart")
map("n", "<leader>dq", dap.terminate, "Stop")
map("n", "<leader>du", function() require("dapui").toggle() end, "Toggle debug UI")
map({ "n", "v" }, "<leader>de", function() require("dapui").eval() end, "Evaluate")
map("n", "<leader>dt", function() require("dap-go").debug_test() end, "Debug Go test")
map("n", "<leader>dl", function() require("dap-go").debug_last_test() end, "Debug last Go test")
