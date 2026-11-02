-- nvim split'leri ile tmux pane'leri arasinda ayni tuslarla (Ctrl-h/j/k/l) gezinme.
-- tmux tarafinin karsiligi tmux/.tmux.conf icinde. Eklentinin kendi tus atamalari kapali, bizimkiler desc'li.
vim.g.tmux_navigator_no_mappings = 1

local map = vim.keymap.set
map("n", "<C-h>", "<cmd>TmuxNavigateLeft<CR>", { desc = "Sola git (nvim split / tmux pane)" })
map("n", "<C-j>", "<cmd>TmuxNavigateDown<CR>", { desc = "Asagi git (nvim split / tmux pane)" })
map("n", "<C-k>", "<cmd>TmuxNavigateUp<CR>", { desc = "Yukari git (nvim split / tmux pane)" })
map("n", "<C-l>", "<cmd>TmuxNavigateRight<CR>", { desc = "Saga git (nvim split / tmux pane)" })

return {
  { "christoomey/vim-tmux-navigator",
    cmd = { "TmuxNavigateLeft", "TmuxNavigateDown", "TmuxNavigateUp", "TmuxNavigateRight" } },
}
