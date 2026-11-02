-- Klasor basina oturum: nvim kapanirken kaydeder, istedigin zaman geri yukler.
local map = vim.keymap.set

map("n", "<leader>qs", function() require("persistence").load() end, { desc = "Bu klasorun oturumunu yukle" })
map("n", "<leader>ql", function() require("persistence").load({ last = true }) end, { desc = "Son oturumu yukle" })
map("n", "<leader>qd", function() require("persistence").stop() end, { desc = "Bu oturumu kaydetme" })

return {
  { "folke/persistence.nvim", event = "BufReadPre", opts = {} },
}
