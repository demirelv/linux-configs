-- Klasor basina oturum: nvim kapanirken kaydeder, istedigin zaman geri yukler.
local map = vim.keymap.set

map("n", "<leader>qs", function() require("persistence").load() end, { desc = "Load this directory's session" })
map("n", "<leader>ql", function() require("persistence").load({ last = true }) end, { desc = "Load the last session" })
map("n", "<leader>qd", function() require("persistence").stop() end, { desc = "Do not save this session" })

return {
  { "folke/persistence.nvim", event = "BufReadPre", opts = {} },
}
