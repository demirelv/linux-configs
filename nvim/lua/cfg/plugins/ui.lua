-- Durum cubugu: mod, git branch, diagnostics, dosya, LSP.
return {
  { "nvim-lualine/lualine.nvim", event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = { options = { theme = "auto", globalstatus = true } } },
}
