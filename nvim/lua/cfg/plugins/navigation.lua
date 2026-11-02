-- Ekranda atlama (flash) ve sik kullanilan dosyalari sabitleme (harpoon).
local map = vim.keymap.set

-- `s` normalde "bir karakteri degistir"; yerine ekranda 2 tusla atla.
map({ "n", "x", "o" }, "s", function() require("flash").jump() end, { desc = "Jump on screen (flash)" })

local function list() return require("harpoon"):list() end
map("n", "<leader>aa", function() list():add() end, { desc = "Pin file (harpoon)" })
map("n", "<leader>am", function()
  local harpoon = require("harpoon")
  harpoon.ui:toggle_quick_menu(harpoon:list())
end, { desc = "Pinned files menu" })
for i = 1, 4 do
  map("n", "<leader>a" .. i, function() list():select(i) end, { desc = "Pinned file " .. i })
end

return {
  -- f/t/F/T davranisina dokunma; yalniz `s` ile atla
  { "folke/flash.nvim", lazy = true, opts = { modes = { char = { enabled = false } } } },
  -- harpoon2 dali bakimda olan surum (master eski harpoon1)
  { "ThePrimeagen/harpoon", branch = "harpoon2", lazy = true,
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function() require("harpoon"):setup() end },
}
