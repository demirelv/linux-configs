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
opt.completeopt = { "menu", "menuone", "noselect", "popup" } -- yerlesik tamamlama: liste + dokuman popup
vim.o.grepprg = "rg --vimgrep --smart-case"
vim.cmd("syntax on")
require("cfg.options") -- undofile, split yonleri, inlay hint, exrc ... (lua/cfg/options.lua)

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
    -- C/C++ projelerinde clangd icin compile_commands.json gerekir (ornek: bear -- make).
    vim.lsp.config("clangd", { cmd = { "clangd", "--background-index" } })
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
      { "<leader>f", group = "Search (Telescope)" },
      { "<leader>b", group = "Buffer" },
      { "<leader>c", group = "Code" },
      { "<leader>g", group = "LSP / Git (Telescope)" },
      { "<leader>s", group = "Split" },
      { "<leader>t", group = "Tab" },
      { "<leader><leader>", group = "Quick search (LSP / grep)" },
      { "<leader>a", group = "Pinned files (harpoon)" },
      { "<leader>d", group = "Debug (dap) / symbols" },
      { "<leader>m", group = "Build (make)" },
      { "<leader>q", group = "Session" },
      { "<leader>x", group = "Problem lists (Trouble)" },
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

  -- Ek eklentiler: her biri lua/cfg/plugins/<konu>.lua icinde, kendi kisayollariyla
  { import = "cfg.plugins" },
}, { performance = { rtp = { paths = extra_rtp } } })

-- LSP tamamlama: eklentisiz, Neovim'in yerlesik ozelligi. Yazdikca liste acilir;
-- <C-n>/<C-p> gez, <C-y> kabul et, <C-e> kapat, <C-Space> elle tetikle.
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if client and client:supports_method("textDocument/completion", ev.buf) then
      vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
    end
  end,
})

-- === Kisayollar ===
-- Her kisayolun desc'i var: <F1> veya <leader>fk ile aranabilir, which-key'de gorunur.
-- Bir kisayol baska bir kisayolun on eki olmamali (tests/check.lua bunu dener).

-- Kisayol / komut arama
map("n", "<F1>", tb("keymaps"), { desc = "Search keymaps" })
map("n", "<leader>fk", tb("keymaps"), { desc = "Search keymaps" })
map("n", "<leader>fc", tb("commands"), { desc = "Search commands" })
map("n", "<leader>?", function() require("which-key").show({ global = false }) end, { desc = "Keymaps of this buffer" })

-- Popup ile dosya / metin arama
map("n", "<leader>ff", tb("find_files"), { desc = "Find files" })
map("n", "<leader>fg", grep_args, { desc = "Project grep (with rg arguments)" })
map({ "n", "x" }, "<leader>fw", function()
  require("telescope.builtin").live_grep({ default_text = word_or_selection() })
end, { desc = "Grep the word or selection" })
map("n", "<leader>fs", tb("current_buffer_fuzzy_find"), { desc = "Search in this file" })
map("n", "<leader>fb", tb("buffers"), { desc = "Find buffer" })
map("n", "<leader>fo", tb("oldfiles"), { desc = "Recent files" })
map("n", "<leader>fr", tb("resume"), { desc = "Resume the last search" })
map("n", "<leader>fh", tb("help_tags"), { desc = "Search help tags" })
map("n", "<leader>fd", tb("diagnostics"), { desc = "Diagnostics" })

map("i", "<C-Space>", function() vim.lsp.completion.get() end, { desc = "Trigger completion manually" })

-- Git sinyalleri
map("n", "<leader>gn", "<cmd>Neogit<CR>", { desc = "Neogit (git UI)" })
map("n", "]h", function() require("gitsigns").next_hunk() end, { desc = "Next git hunk" })
map("n", "[h", function() require("gitsigns").prev_hunk() end, { desc = "Previous git hunk" })

-- LSP kisa yollari
map({ "n", "x" }, "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
map({ "n", "x" }, "gD", vim.lsp.buf.declaration, { desc = "Go to declaration" })
map({ "n", "x" }, "gi", vim.lsp.buf.implementation, { desc = "Go to implementation" })
-- "gr" bilerek yok: Neovim 0.11+ varsayilanlari grr (referanslar), grn (yeniden adlandir), gra (code action),
-- gri, grt ile cakisir. Referanslar icin grr kullan.
map({ "n", "x" }, "K", vim.lsp.buf.hover, { desc = "Hover" })

-- Telescope LSP
map({ "n", "x" }, "<leader>gd", "<cmd>Telescope lsp_definitions<CR>", { desc = "LSP definitions" })
map({ "n", "x" }, "<leader>gr", "<cmd>Telescope lsp_references<CR>", { desc = "LSP references" })
map({ "n", "x" }, "<leader>gi", "<cmd>Telescope lsp_implementations<CR>", { desc = "LSP implementations" })
map({ "n", "x" }, "<leader>ds", "<cmd>Telescope lsp_document_symbols<CR>", { desc = "Document symbols" })
map({ "n", "x" }, "<leader>ws", "<cmd>Telescope lsp_workspace_symbols<CR>", { desc = "Workspace symbols" })

map({ "n", "x" }, "<F2>", function()
  local num, rel = vim.wo.number, vim.wo.relativenumber
  if not num and not rel then
    vim.wo.number, vim.wo.relativenumber = true, false
  elseif num and not rel then
    vim.wo.number, vim.wo.relativenumber = true, true
  else
    vim.wo.number, vim.wo.relativenumber = false, false
  end
end, { desc = "Cycle line-number mode" })

-- fzf.vim ve Telescope F tuslari
map("n", "<F3>", ":Files<CR>", { desc = "fzf: find files" })
map("n", "<leader>bl", ":Buffers<CR>", { desc = "fzf: list buffers" })
map("n", "<leader>gf", ":GFiles<CR>", { desc = "fzf: git files" })
map("n", "<F4>", tb("find_files"), { desc = "Find files", silent = true })
map("n", "<F5>", grep_args, { desc = "Project grep (with rg arguments)", silent = true })
map("n", "<F6>", tb("buffers"), { desc = "List buffers", silent = true })
map("n", "<F7>", tb("git_files"), { desc = "Git files", silent = true })
map("n", "<F8>", ":Telescope find_files cwd=%:p:h<CR>", { desc = "Find files in this file's directory", silent = true })
map("n", "<F9>", tb("command_history"), { desc = "Command history", silent = true })
map("n", "<F10>", tb("lsp_document_symbols"), { desc = "Document symbols", silent = true })

-- Hizli arama (<leader><leader>N)
map("n", "<leader><leader>0", "<cmd>Telescope lsp_workspace_symbols<CR>", { desc = "Workspace symbols" })
map("n", "<leader><leader>1", "<cmd>Telescope lsp_definitions<CR>", { desc = "Go to definition" })
map("n", "<leader><leader>2", vim.lsp.buf.outgoing_calls, { desc = "Outgoing calls" })
map("n", "<leader><leader>3", vim.lsp.buf.incoming_calls, { desc = "Incoming calls" })
map({ "n", "x" }, "<leader><leader>4", function()
  require("telescope.builtin").live_grep({ default_text = word_or_selection() })
end, { desc = "Grep the word or selection", silent = true })
map("n", "<leader><leader>5", tb("live_grep"), { desc = "Grep (regex)" })
map("n", "<leader><leader>6", tb("find_files"), { desc = "Find files" })
map("n", "<leader><leader>7", tb("grep_string"), { desc = "Grep the word under the cursor" })
map("n", "<leader><leader>8", "<cmd>Telescope lsp_references<CR>", { desc = "References" })
map("n", "<leader><leader>9", "<cmd>Telescope diagnostics<CR>", { desc = "Diagnostics" })

-- Ziplama gecmisi
map("n", "<C-Left>", "<C-o>", { desc = "Previous jump position" })
map("n", "<C-Right>", "<C-i>", { desc = "Next jump position" })

-- Neo-tree
map("n", "<leader>e", ":Neotree toggle<CR>", { desc = "File tree" })

-- Split'ler
map("n", "<leader>sh", "<C-w>s", { desc = "Horizontal split" })
map("n", "<leader>sv", "<C-w>v", { desc = "Vertical split" })
map("n", "<leader>h", "<C-w>h", { desc = "Go to the left split" })
map("n", "<leader>j", "<C-w>j", { desc = "Go to the split below" })
map("n", "<leader>k", "<C-w>k", { desc = "Go to the split above" })
map("n", "<leader>l", "<C-w>l", { desc = "Go to the right split" })
map("n", "<leader>ww", "<C-w>w", { desc = "Go to the next split" })
map("n", "<leader>+", "<C-w>+", { desc = "Increase split height" })
map("n", "<leader>-", "<C-w>-", { desc = "Decrease split height" })
map("n", "<leader><", "<C-w><", { desc = "Decrease split width" })
map("n", "<leader>>", "<C-w>>", { desc = "Increase split width" })

-- Sekmeler ve buffer'lar
map("n", "<leader>tn", ":tabnew<CR>", { desc = "New tab" })
map("n", "<leader>tc", ":tabclose<CR>", { desc = "Close tab" })
map("n", "<Tab>", "gt", { desc = "Next tab" })
map("n", "<S-Tab>", "gT", { desc = "Previous tab" })
map("n", "<leader>bp", ":bprevious<CR>", { desc = "Previous buffer" })
map("n", "<leader>bn", ":bnext<CR>", { desc = "Next buffer" })
map("n", "<leader>bd", ":bd<CR>", { desc = "Close buffer" })
-- Quickfix gezinme: Neovim varsayilani ]q / [q. (<C-j>/<C-n> artik vim-tmux-navigator ve baska islere ayrildi.)

-- Pano (<C-v> blok secimi icin birakildi; terminalin kendi yapistirmasi da calisir)
map({ "n", "x" }, "<leader>p", '"+p', { desc = "Paste from the clipboard" })
map("n", "<leader>y", '"+yy', { desc = "Copy line to the clipboard" })
map("x", "<leader>y", '"+y', { desc = "Copy selection to the clipboard" })

-- Kod bicimleme (ayri ayri, bilincli)
map("n", "<leader>cw", function()
  local view = vim.fn.winsaveview()
  vim.cmd([[keeppatterns %s/\s\+$//e]])
  vim.fn.winrestview(view)
  print("Satir sonu bosluklari silindi")
end, { desc = "Remove trailing whitespace" })
map("n", "<leader>ci", function()
  local view = vim.fn.winsaveview()
  vim.cmd("normal! gg=G")
  vim.fn.winrestview(view)
  print("Dosya yeniden girintilendi")
end, { desc = "Re-indent the whole file" })

-- Satir tasima
map("x", "<C-S-Up>", ":move '<-2<CR>gv=gv", { silent = true, desc = "Move selected lines up" })
map("x", "<C-S-Down>", ":move '>+1<CR>gv=gv", { silent = true, desc = "Move selected lines down" })
map("n", "<C-S-Up>", ":m .-2<CR>==", { silent = true, desc = "Move line up" })
map("n", "<C-S-Down>", ":m .+1<CR>==", { silent = true, desc = "Move line down" })

require("cfg.build") -- :Make ve <leader>mm / <leader>mc (lua/cfg/build.lua)

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
end, { nargs = "*", complete = "file", desc = "Search a directory and open results in quickfix" })

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
end, { desc = "Rebuild the cscope database" })

map("n", "<C-q>", function()
  for _, win in ipairs(vim.fn.getwininfo()) do
    if win.quickfix == 1 then
      vim.cmd("cclose")
      return
    end
  end
  vim.cmd("copen")
end, { desc = "Toggle quickfix", silent = true })
