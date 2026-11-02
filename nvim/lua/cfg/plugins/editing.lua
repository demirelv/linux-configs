-- Biçimlendirme (conform) ve undo agaci.
local map = vim.keymap.set

-- clang-format kuruluysa onu, degilse clangd'nin LSP bicimlendirmesini kullanir.
-- Kaydederken otomatik bicimlendirme YOK: baskasinin kodunu toplu degistirmemek icin bilincli.
map({ "n", "x" }, "<leader>cf", function()
  require("conform").format({ async = true, lsp_format = "fallback" })
end, { desc = "Format (clang-format / LSP); only the selection in visual mode" })
map("n", "<leader>u", "<cmd>UndotreeToggle<CR>", { desc = "Undo tree" })

return {
  { "stevearc/conform.nvim", lazy = true, opts = {
    formatters_by_ft = { c = { "clang-format" }, cpp = { "clang-format" } },
    default_format_opts = { lsp_format = "fallback" },
  } },
  { "mbbill/undotree", cmd = "UndotreeToggle" },
}
