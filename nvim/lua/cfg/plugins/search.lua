-- Proje capinda bul-degistir (grug-far), sorun listesi (trouble), TODO yorumlari (todo-comments).
local map = vim.keymap.set

map("n", "<leader>fR", function() require("grug-far").open() end, { desc = "Search and replace (grug-far, rg)" })
map("x", "<leader>fR", function() require("grug-far").with_visual_selection() end,
  { desc = "Search and replace the selection (grug-far)" })

map("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<CR>", { desc = "Diagnostics (whole project)" })
map("n", "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<CR>", { desc = "Diagnostics (this file)" })
map("n", "<leader>xq", "<cmd>Trouble qflist toggle<CR>", { desc = "Quickfix list (Trouble)" })
map("n", "<leader>xl", "<cmd>Trouble lsp toggle focus=false win.position=right<CR>",
  { desc = "LSP definitions/references panel" })
map("n", "<leader>xt", "<cmd>Trouble todo toggle<CR>", { desc = "TODO list (Trouble)" })
map("n", "<leader>fl", function() require("cfg.lc_help").open() end,
  { desc = "Search lc-help (commands, git aliases, tmux keys, tools)" })
map("n", "<leader>ft", "<cmd>TodoTelescope<CR>", { desc = "Search TODO/FIXME/HACK comments" })

return {
  { "MagicDuck/grug-far.nvim", cmd = "GrugFar", opts = {} },
  { "folke/trouble.nvim", cmd = "Trouble", dependencies = { "nvim-tree/nvim-web-devicons" }, opts = {} },
  -- signs kapali: sign sutununu gitsigns ile paylasmasin
  { "folke/todo-comments.nvim", event = { "BufReadPost", "BufNewFile" },
    dependencies = { "nvim-lua/plenary.nvim" }, opts = { signs = false } },
}
