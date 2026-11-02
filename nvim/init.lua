-- Neovim >= 0.11 gerekir (vim.lsp.enable, vim.fn.getregion).
if vim.fn.has("nvim-0.11") == 0 then
  vim.notify("init.lua icin Neovim >= 0.11 gerekli (simdiki: " .. tostring(vim.version()) .. ")", vim.log.levels.ERROR)
  return
end

-- === Temel ayarlar ===
vim.g.mapleader = " "
local opt = vim.opt
opt.number = true
opt.relativenumber = false
opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.smartindent = true
opt.wrap = false
opt.termguicolors = true
opt.ignorecase = true -- "/" aramasi buyuk/kucuk harf duyarsiz...
opt.smartcase = true  -- ...ama buyuk harf yazarsan duyarli
opt.updatetime = 300  -- gitsigns blame / LSP hover icin daha akici
vim.o.grepprg = "rg --vimgrep --smart-case"
vim.cmd("syntax on")

local map = vim.keymap.set

-- === lazy.nvim kurulumu ===
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- === Vurgular: satir sonu boslugu, bos satir, "TODO   " ===
local function set_highlights()
  vim.api.nvim_set_hl(0, "ExtraWhitespace", { bg = "#FF0000" })
  vim.api.nvim_set_hl(0, "EmptyLine", { bg = "#333344" })
  vim.api.nvim_set_hl(0, "TodoSpace", { bg = "#FFFF00", fg = "#000000" })
end

-- matchadd pencereye ozeldir: her normal pencerede bir kez eklenir.
local function add_matches()
  if vim.w.cfg_matches or vim.bo.buftype ~= "" then return end
  vim.w.cfg_matches = true
  vim.fn.matchadd("EmptyLine", [[^\s*$]], 5)
  vim.fn.matchadd("ExtraWhitespace", [[\s\+$]], 10)
  vim.fn.matchadd("TodoSpace", [[TODO\s\+]], 10)
end

vim.api.nvim_create_autocmd("ColorScheme", { callback = set_highlights })
vim.api.nvim_create_autocmd({ "VimEnter", "WinEnter", "BufWinEnter" }, { callback = add_matches })
set_highlights()

-- Secili metin (visual modda) ya da imlecin altindaki kelime
local function word_or_selection()
  local m = vim.fn.mode()
  if m == "v" or m == "V" then
    return table.concat(vim.fn.getregion(vim.fn.getpos("v"), vim.fn.getpos("."), { type = m }), " ")
  end
  return vim.fn.expand("<cword>")
end

-- Telescope picker'i tembel cagir (eklenti ilk kullanimda yuklenir)
local function tb(name, o)
  return function() require("telescope.builtin")[name](o) end
end

local function grep_args()
  require("telescope").extensions.live_grep_args.live_grep_args()
end

-- Debian/Ubuntu paketli nvim hazir parser'lari (c, lua, vimdoc ...) $VIMRUNTIME disinda tasir.
-- lazy.nvim runtimepath'i sifirlayinca kaybolurlar; once yerini bulup lazy'ye bildir.
local extra_rtp = {}
local bundled = vim.api.nvim_get_runtime_file("parser/vimdoc.*", false)[1]
if bundled then extra_rtp[1] = vim.fn.fnamemodify(bundled, ":h:h") end

-- === Eklentiler ===
require("lazy").setup({
  { "junegunn/fzf", build = "./install --all" },
  { "junegunn/fzf.vim" },

  { "demirelv/cscope_maps.nvim",
    dependencies = { "nvim-telescope/telescope.nvim" },
    opts = {
      db_build_cmd = { script = "default", args = { "-bqkvR" } },
    },
  },

  -- Renk temalari: tokyonight acik, digerleri :colorscheme ile yuklenir
  { "folke/tokyonight.nvim", lazy = false, priority = 1000, config = function()
    vim.cmd("colorscheme tokyonight-night")
  end },
  { "ellisonleao/gruvbox.nvim", lazy = true },
  { "catppuccin/nvim", name = "catppuccin", lazy = true },

  -- Treesitter (main dali): parser kurulumu icin `tree-sitter` CLI gerekir
  { "nvim-treesitter/nvim-treesitter", lazy = false, build = ":TSUpdate", config = function()
    local ts = require("nvim-treesitter")
    ts.setup({})
    if vim.fn.executable("tree-sitter") == 1 then
      ts.install({ "c", "cpp", "lua", "bash", "python", "vim", "vimdoc", "query", "markdown", "markdown_inline" })
    end
    vim.api.nvim_create_autocmd("FileType", {
      callback = function(args)
        -- parser yoksa sessizce atla; normal syntax calismaya devam eder
        if pcall(vim.treesitter.start, args.buf) then
          vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end
      end,
    })
  end },

  -- LSP: nvim-lspconfig sadece lsp/*.lua varsayilanlarini saglar
  { "neovim/nvim-lspconfig", config = function()
    vim.lsp.enable("clangd")
  end },

  -- Telescope: ortada acilan popup, onizlemeli
  { "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
      "nvim-telescope/telescope-live-grep-args.nvim",
    },
    config = function()
      local telescope = require("telescope")
      local lga_actions = require("telescope-live-grep-args.actions")
      telescope.setup({
        defaults = {
          layout_strategy = "horizontal",
          layout_config = { width = 0.9, height = 0.85, preview_width = 0.55, prompt_position = "top" },
          sorting_strategy = "ascending",
          border = true,
          path_display = { "truncate" },
        },
        extensions = {
          live_grep_args = {
            auto_quoting = true,
            mappings = {
              i = {
                ["<C-k>"] = lga_actions.quote_prompt(),                       -- yaz: foo, <C-k> -> "foo"
                ["<C-i>"] = lga_actions.quote_prompt({ postfix = " --iglob " }), -- dosya filtresi: "foo" --iglob *.c
              },
            },
          },
        },
      })
      telescope.load_extension("fzf")
      telescope.load_extension("live_grep_args")
    end,
  },

  -- Quickfix listesi icin onizleme (:Rg, cscope, LSP referanslari)
  { "kevinhwang91/nvim-bqf", ft = "qf" },

  -- Tus kisayolu popup'i: <leader> a basinca secenekleri gosterir
  { "folke/which-key.nvim", event = "VeryLazy", opts = {
    delay = 300,
    spec = {
      { "<leader>f", group = "Ara (Telescope)" },
      { "<leader>b", group = "Buffer" },
      { "<leader>c", group = "Kod" },
      { "<leader>g", group = "LSP / Git (Telescope)" },
      { "<leader>s", group = "Split" },
      { "<leader>t", group = "Sekme" },
      { "<leader><leader>", group = "Hizli arama (LSP / grep)" },
    },
  } },

  { "nvim-neo-tree/neo-tree.nvim", branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons", -- dosya ikonlari icin
      "MunifTanjim/nui.nvim",
    },
    config = function()
      require("neo-tree").setup({
        filesystem = {
          filtered_items = { visible = true, hide_dotfiles = true, hide_gitignored = false },
        },
      })
    end,
  },
  { "lewis6991/gitsigns.nvim", opts = {
    signs = {
      add          = { text = "+" },
      change       = { text = "~" },
      delete       = { text = "_" },
      topdelete    = { text = "‾" },
      changedelete = { text = "~" },
    },
    current_line_blame = true,
  } },
  { "NeogitOrg/neogit",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "sindrets/diffview.nvim", -- opsiyonel ama tavsiye edilir
    },
    config = function() require("neogit").setup({}) end,
  },
}, { performance = { rtp = { paths = extra_rtp } } })

-- === Kisayollar ===
-- Her kisayolun desc'i var: <F1> veya <leader>fk ile aranabilir, which-key'de gorunur.
-- Bir kisayol baska bir kisayolun on eki olmamali (tests/check.lua bunu dener).

-- Kisayol / komut arama
map("n", "<F1>", tb("keymaps"), { desc = "Kisayol ara" })
map("n", "<leader>fk", tb("keymaps"), { desc = "Kisayol ara" })
map("n", "<leader>fc", tb("commands"), { desc = "Komut ara" })
map("n", "<leader>?", function() require("which-key").show({ global = false }) end, { desc = "Bu buffer'in kisayollari" })

-- Popup ile dosya / metin arama
map("n", "<leader>ff", tb("find_files"), { desc = "Dosya ara" })
map("n", "<leader>fg", grep_args, { desc = "Proje ici grep (rg argumanli)" })
map({ "n", "x" }, "<leader>fw", function()
  require("telescope.builtin").live_grep({ default_text = word_or_selection() })
end, { desc = "Kelime/secimi grep'le" })
map("n", "<leader>fs", tb("current_buffer_fuzzy_find"), { desc = "Bu dosyada ara" })
map("n", "<leader>fb", tb("buffers"), { desc = "Buffer ara" })
map("n", "<leader>fo", tb("oldfiles"), { desc = "Son dosyalar" })
map("n", "<leader>fr", tb("resume"), { desc = "Son aramaya don" })
map("n", "<leader>fh", tb("help_tags"), { desc = "Yardim ara" })
map("n", "<leader>fd", tb("diagnostics"), { desc = "Diagnostics" })

-- Git sinyalleri
map("n", "]h", function() require("gitsigns").next_hunk() end, { desc = "Sonraki git hunk" })
map("n", "[h", function() require("gitsigns").prev_hunk() end, { desc = "Onceki git hunk" })

-- LSP kisa yollari
map({ "n", "x" }, "gd", vim.lsp.buf.definition, { desc = "Tanima git" })
map({ "n", "x" }, "gD", vim.lsp.buf.declaration, { desc = "Bildirime git" })
map({ "n", "x" }, "gi", vim.lsp.buf.implementation, { desc = "Implementasyona git" })
-- "gr" bilerek yok: Neovim 0.11+ varsayilanlari grr (referanslar), grn (yeniden adlandir), gra (code action),
-- gri, grt ile cakisir. Referanslar icin grr kullan.
map({ "n", "x" }, "K", vim.lsp.buf.hover, { desc = "Hover" })

-- Telescope LSP
map({ "n", "x" }, "<leader>gd", "<cmd>Telescope lsp_definitions<CR>", { desc = "LSP tanimlar" })
map({ "n", "x" }, "<leader>gr", "<cmd>Telescope lsp_references<CR>", { desc = "LSP referanslar" })
map({ "n", "x" }, "<leader>gi", "<cmd>Telescope lsp_implementations<CR>", { desc = "LSP implementasyonlar" })
map({ "n", "x" }, "<leader>ds", "<cmd>Telescope lsp_document_symbols<CR>", { desc = "Dosya sembolleri" })
map({ "n", "x" }, "<leader>ws", "<cmd>Telescope lsp_workspace_symbols<CR>", { desc = "Workspace sembolleri" })

map({ "n", "x" }, "<F2>", function()
  local num, rel = vim.wo.number, vim.wo.relativenumber
  if not num and not rel then
    vim.wo.number, vim.wo.relativenumber = true, false
  elseif num and not rel then
    vim.wo.number, vim.wo.relativenumber = true, true
  else
    vim.wo.number, vim.wo.relativenumber = false, false
  end
end, { desc = "Satir numarasi modu degistir" })

-- fzf.vim ve Telescope F tuslari
map("n", "<F3>", ":Files<CR>", { desc = "fzf: dosya bul" })
map("n", "<leader>bl", ":Buffers<CR>", { desc = "fzf: buffer listesi" })
map("n", "<leader>gf", ":GFiles<CR>", { desc = "fzf: git dosyalari" })
map("n", "<F4>", tb("find_files"), { desc = "Dosya ara", silent = true })
map("n", "<F5>", grep_args, { desc = "Proje ici grep (rg argumanli)", silent = true })
map("n", "<F6>", tb("buffers"), { desc = "Buffer listesi", silent = true })
map("n", "<F7>", tb("git_files"), { desc = "Git dosyalari", silent = true })
map("n", "<F8>", ":Telescope find_files cwd=%:p:h<CR>", { desc = "Bu klasorde dosya ara", silent = true })
map("n", "<F9>", tb("command_history"), { desc = "Komut gecmisi", silent = true })
map("n", "<F10>", tb("lsp_document_symbols"), { desc = "Dosya sembolleri", silent = true })

-- Hizli arama (<leader><leader>N)
map("n", "<leader><leader>0", "<cmd>Telescope lsp_workspace_symbols<CR>", { desc = "Workspace sembolleri" })
map("n", "<leader><leader>1", "<cmd>Telescope lsp_definitions<CR>", { desc = "Tanima git" })
map("n", "<leader><leader>2", vim.lsp.buf.outgoing_calls, { desc = "Giden cagrilar" })
map("n", "<leader><leader>3", vim.lsp.buf.incoming_calls, { desc = "Gelen cagrilar" })
map({ "n", "x" }, "<leader><leader>4", function()
  require("telescope.builtin").live_grep({ default_text = word_or_selection() })
end, { desc = "Kelime/secimi grep'le", silent = true })
map("n", "<leader><leader>5", tb("live_grep"), { desc = "Grep (regex)" })
map("n", "<leader><leader>6", tb("find_files"), { desc = "Dosya ara" })
map("n", "<leader><leader>7", tb("grep_string"), { desc = "Kelimeyi grep'le" })
map("n", "<leader><leader>8", "<cmd>Telescope lsp_references<CR>", { desc = "Referanslar" })
map("n", "<leader><leader>9", "<cmd>Telescope diagnostics<CR>", { desc = "Diagnostics" })

-- Ziplama gecmisi
map("n", "<C-Left>", "<C-o>", { desc = "Onceki konum" })
map("n", "<C-Right>", "<C-i>", { desc = "Sonraki konum" })

-- Neo-tree
map("n", "<leader>e", ":Neotree toggle<CR>", { desc = "Dosya agaci" })

-- Split'ler
map("n", "<leader>sh", "<C-w>s", { desc = "Yatay split" })
map("n", "<leader>sv", "<C-w>v", { desc = "Dikey split" })
map("n", "<leader>h", "<C-w>h", { desc = "Sol split" })
map("n", "<leader>j", "<C-w>j", { desc = "Alt split" })
map("n", "<leader>k", "<C-w>k", { desc = "Ust split" })
map("n", "<leader>l", "<C-w>l", { desc = "Sag split" })
map("n", "<leader>ww", "<C-w>w", { desc = "Siradaki split" })
map("n", "<leader>+", "<C-w>+", { desc = "Split yuksekligi artir" })
map("n", "<leader>-", "<C-w>-", { desc = "Split yuksekligi azalt" })
map("n", "<leader><", "<C-w><", { desc = "Split genisligi azalt" })
map("n", "<leader>>", "<C-w>>", { desc = "Split genisligi artir" })

-- Sekmeler ve buffer'lar
map("n", "<leader>tn", ":tabnew<CR>", { desc = "Yeni sekme" })
map("n", "<leader>tc", ":tabclose<CR>", { desc = "Sekmeyi kapat" })
map("n", "<Tab>", "gt", { desc = "Sonraki sekme" })
map("n", "<S-Tab>", "gT", { desc = "Onceki sekme" })
map("n", "<leader>bp", ":bprevious<CR>", { desc = "Onceki buffer" })
map("n", "<leader>bn", ":bnext<CR>", { desc = "Sonraki buffer" })
map("n", "<leader>bd", ":bd<CR>", { desc = "Buffer'i kapat" })
map("n", "<C-n>", ":cnext<CR>", { desc = "Sonraki quickfix" })
map("n", "<C-j>", ":cprevious<CR>", { desc = "Onceki quickfix" })

-- Pano (<C-v> blok secimi icin birakildi; terminalin kendi yapistirmasi da calisir)
map({ "n", "x" }, "<leader>p", '"+p', { desc = "Panodan yapistir" })
map("n", "<leader>y", '"+yy', { desc = "Satiri panoya kopyala" })
map("x", "<leader>y", '"+y', { desc = "Seciliyi panoya kopyala" })

-- Kod bicimleme (ayri ayri, bilincli)
map("n", "<leader>cw", function()
  local view = vim.fn.winsaveview()
  vim.cmd([[keeppatterns %s/\s\+$//e]])
  vim.fn.winrestview(view)
  print("Satir sonu bosluklari silindi")
end, { desc = "Satir sonu bosluklarini sil" })
map("n", "<leader>ci", function()
  local view = vim.fn.winsaveview()
  vim.cmd("normal! gg=G")
  vim.fn.winrestview(view)
  print("Dosya yeniden girintilendi")
end, { desc = "Tum dosyayi yeniden girintile" })

-- Satir tasima
map("x", "<C-S-Up>", ":move '<-2<CR>gv=gv", { silent = true, desc = "Secili satirlari yukari tasi" })
map("x", "<C-S-Down>", ":move '>+1<CR>gv=gv", { silent = true, desc = "Secili satirlari asagi tasi" })
map("n", "<C-S-Up>", ":m .-2<CR>==", { silent = true, desc = "Satiri yukari tasi" })
map("n", "<C-S-Down>", ":m .+1<CR>==", { silent = true, desc = "Satiri asagi tasi" })

-- :Rg <aranan> [klasor] -> sonuclar quickfix'te (nvim-bqf onizleme verir)
vim.api.nvim_create_user_command("Rg", function(o)
  local search = o.fargs[1] or ""
  local folder = o.fargs[2] or vim.fn.getcwd()
  if vim.fn.isdirectory(folder) == 0 then folder = vim.fn.getcwd() end

  local cmd = string.format("rg --vimgrep --smart-case -- %s %s", vim.fn.shellescape(search), vim.fn.shellescape(folder))
  vim.fn.setqflist({}, " ", {
    title = 'Search results for "' .. search .. '"',
    efm = "%f:%l:%c:%m",
    lines = vim.fn.systemlist(cmd),
  })
  vim.cmd("copen")
  vim.cmd("wincmd p") -- imleci onceki pencereye geri al
end, { nargs = "*", complete = "file", desc = "Klasorde ara, sonuclari quickfix'te ac" })

map("n", "<leader>9", function()
  local cwd = vim.fn.getcwd()
  print("Cscope DB build basladi (" .. cwd .. ")...")
  vim.fn.jobstart({ "cscope", "-bqkvR" }, {
    cwd = cwd,
    on_exit = function(_, code)
      vim.schedule(function()
        if code == 0 then
          -- Eski DB baglantilarini temizle, sadece tazeyi ekle
          pcall(function() require("cscope.db").reset() end)
          vim.cmd("Cs db add " .. cwd .. "/cscope.out")
          print("Cscope DB hazir ve eklendi: " .. cwd .. "/cscope.out")
        else
          print("Cscope build basarisiz! (exit code: " .. code .. ")")
        end
      end)
    end,
  })
end, { desc = "Cscope DB yeniden olustur" })

map("n", "<C-q>", function()
  for _, win in ipairs(vim.fn.getwininfo()) do
    if win.quickfix == 1 then
      vim.cmd("cclose")
      return
    end
  end
  vim.cmd("copen")
end, { desc = "Quickfix ac/kapat", silent = true })
