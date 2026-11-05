-- Debugging. Go works out of the box via delve (installed by Mason).
-- Shortcuts: F5 start/continue, <leader>d... (see keymaps.lua)
local dap, dapui = require("dap"), require("dapui")

dapui.setup()
require("nvim-dap-virtual-text").setup()
require("dap-go").setup()

dap.listeners.after.event_initialized["dapui"] = dapui.open
dap.listeners.before.event_terminated["dapui"] = dapui.close
dap.listeners.before.event_exited["dapui"] = dapui.close

vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DiagnosticError" })
vim.fn.sign_define("DapBreakpointCondition", { text = "◆", texthl = "DiagnosticWarn" })
vim.fn.sign_define("DapStopped", { text = "▶", texthl = "DiagnosticOk", linehl = "Visual" })
