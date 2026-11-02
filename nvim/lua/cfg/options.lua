-- Ek ayarlar: kalici undo, split yonleri, canli :s onizleme, gorunmez karakterler, inlay hint.
local opt = vim.opt

opt.undofile = true       -- undo gecmisi dosya kapansa da kalir
opt.splitright = true     -- dikey split sagda acilir
opt.splitbelow = true     -- yatay split altta acilir
opt.scrolloff = 8         -- imlecin ustunde/altinda 8 satir bosluk
opt.inccommand = "split"  -- :s komutunu yazarken canli onizleme
opt.cursorline = true
opt.list = true           -- tab ve satir sonu bosluklarini goster
opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

-- Proje klasorundeki .nvim.lua'yi calistirir (makeprg, clangd bayragi vb.). Guvenlik: ilk seferde
-- Neovim dosyayi calistirmaz, `:trust` ile onaylamani ister.
vim.o.exrc = true

vim.diagnostic.config({ severity_sort = true, float = { border = "rounded" } })
vim.lsp.inlay_hint.enable(true) -- clangd parametre adlarini satir ici gosterir

vim.keymap.set("n", "<leader>cl", function()
  vim.opt.list = not vim.opt.list:get()
end, { desc = "Toggle invisible characters" })
