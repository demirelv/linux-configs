-- C/C++ hata ayiklama: nvim-dap + gdb'nin yerlesik DAP modu (gdb >= 14, `gdb --interpreter=dap`).
local map = vim.keymap.set
local function dap() return require("dap") end

map("n", "<leader>db", function() dap().toggle_breakpoint() end, { desc = "Toggle breakpoint" })
map("n", "<leader>dc", function() dap().continue() end, { desc = "Start / continue debugging" })
map("n", "<leader>do", function() dap().step_over() end, { desc = "Debug: step over" })
map("n", "<leader>di", function() dap().step_into() end, { desc = "Debug: step into" })
map("n", "<leader>dO", function() dap().step_out() end, { desc = "Debug: step out" })
map("n", "<leader>dx", function() dap().terminate() end, { desc = "Terminate the debug session" })
map("n", "<leader>dr", function() dap().repl.toggle() end, { desc = "Toggle the debug REPL" })
map({ "n", "x" }, "<leader>dv", function() require("dap.ui.widgets").hover() end,
  { desc = "Show the value of the variable" })

return {
  { "mfussenegger/nvim-dap", lazy = true, config = function()
    local d = require("dap")
    d.adapters.gdb = {
      type = "executable",
      command = "gdb",
      args = { "--interpreter=dap", "--eval-command", "set print pretty on" },
    }
    d.configurations.c = {
      { name = "Calistirilabilir dosyayi baslat", type = "gdb", request = "launch",
        program = function() return vim.fn.input("Calistirilabilir: ", vim.fn.getcwd() .. "/", "file") end,
        cwd = "${workspaceFolder}" },
    }
    d.configurations.cpp = d.configurations.c
  end },
}
