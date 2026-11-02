-- C/C++ hata ayiklama: nvim-dap + gdb'nin yerlesik DAP modu (gdb >= 14, `gdb --interpreter=dap`).
local map = vim.keymap.set
local function dap() return require("dap") end

map("n", "<leader>db", function() dap().toggle_breakpoint() end, { desc = "Breakpoint ac/kapat" })
map("n", "<leader>dc", function() dap().continue() end, { desc = "Debug baslat / devam et" })
map("n", "<leader>do", function() dap().step_over() end, { desc = "Debug: ustunden gec" })
map("n", "<leader>di", function() dap().step_into() end, { desc = "Debug: icine gir" })
map("n", "<leader>dO", function() dap().step_out() end, { desc = "Debug: disina cik" })
map("n", "<leader>dx", function() dap().terminate() end, { desc = "Debug oturumunu sonlandir" })
map("n", "<leader>dr", function() dap().repl.toggle() end, { desc = "Debug REPL ac/kapat" })
map({ "n", "x" }, "<leader>dv", function() require("dap.ui.widgets").hover() end,
  { desc = "Degiskenin degerini goster" })

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
