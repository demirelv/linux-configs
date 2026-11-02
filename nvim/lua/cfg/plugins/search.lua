-- Proje capinda bul-degistir (grug-far), sorun listesi (trouble), TODO yorumlari (todo-comments).
local map = vim.keymap.set

map("n", "<leader>fR", function() require("grug-far").open() end, { desc = "Bul ve degistir (grug-far, rg)" })
map("x", "<leader>fR", function() require("grug-far").with_visual_selection() end,
  { desc = "Secimi bul ve degistir (grug-far)" })

map("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<CR>", { desc = "Diagnostics (tum proje)" })
map("n", "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<CR>", { desc = "Diagnostics (bu dosya)" })
map("n", "<leader>xq", "<cmd>Trouble qflist toggle<CR>", { desc = "Quickfix listesi (Trouble)" })
map("n", "<leader>xl", "<cmd>Trouble lsp toggle focus=false win.position=right<CR>",
  { desc = "LSP tanim/referanslar paneli" })
map("n", "<leader>xt", "<cmd>Trouble todo toggle<CR>", { desc = "TODO listesi (Trouble)" })
map("n", "<leader>ft", "<cmd>TodoTelescope<CR>", { desc = "TODO/FIXME/HACK ara" })

return {
  { "MagicDuck/grug-far.nvim", cmd = "GrugFar", opts = {} },
  { "folke/trouble.nvim", cmd = "Trouble", dependencies = { "nvim-tree/nvim-web-devicons" }, opts = {} },
  -- signs kapali: sign sutununu gitsigns ile paylasmasin
  { "folke/todo-comments.nvim", event = { "BufReadPost", "BufNewFile" },
    dependencies = { "nvim-lua/plenary.nvim" }, opts = { signs = false } },
}
