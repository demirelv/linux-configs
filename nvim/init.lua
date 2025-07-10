-- === Basic options ===
vim.opt.number = true
vim.opt.relativenumber = false
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.wrap = false
vim.opt.termguicolors = true
vim.o.grepprg = "rg --vimgrep --smart-case"
vim.g.mapleader = " "

local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Otomatik session yolu
local session_path = vim.fn.getcwd() .. "/Session.vim"

-- === Install Lazy.nvim if needed ===
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- === Load plugins ===
require("lazy").setup({
  { "junegunn/fzf", build = "./install --all" },
  { "junegunn/fzf.vim" },
  { "dhananjaylatkar/cscope_maps.nvim",
     dependencies = {
       "nvim-telescope/telescope.nvim", -- optional [for picker="telescope"]
       "ibhagwan/fzf-lua", -- optional [for picker="fzf-lua"]
       "echasnovski/mini.pick", -- optional [for picker="mini-pick"]
       "folke/snacks.nvim", -- optional [for picker="snacks"]
  },
  opts = {
	db_build_cmd = {
		script = "default",
		args = { "-bqkvR" },
      },
  },
},

-- Colorscheme
  { "ellisonleao/gruvbox.nvim", priority = 1000, config = function()
    vim.cmd("colorscheme gruvbox")
  end },

  -- Treesitter
  { "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
    require'nvim-treesitter.configs'.setup {
      ensure_installed = { "c", "cpp", "lua", "bash", "python" }, -- örnek
      highlight = { enable = true },
      indent = { enable = true },
    }
  end
 },
  -- LSP config
  { "neovim/nvim-lspconfig", config = function()
    local lspconfig = require("lspconfig")
    lspconfig.clangd.setup {}
  end },

  -- Telescope
  { "nvim-telescope/telescope.nvim", dependencies = { "nvim-lua/plenary.nvim" } },

  -- neo-tree
  {"nvim-neo-tree/neo-tree.nvim", branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons", -- dosya ikonları için
      "MunifTanjim/nui.nvim",
    },
    config = function()
      require("neo-tree").setup({
        filesystem = {
          filtered_items = {
            visible = true,
            hide_dotfiles = true,
            hide_gitignored = false,
          },
        },
      })
      vim.keymap.set("n", "<leader>t", ":Neotree toggle<CR>", { desc = "Toggle Neo-tree" })
    end,
  },
  {
  "lewis6991/gitsigns.nvim",
  opts = {
    signs = {
      add          = { text = "+" },
      change       = { text = "~" },
      delete       = { text = "_" },
      topdelete    = { text = "‾" },
      changedelete = { text = "~" },
    },
    current_line_blame = true,
  },
  },
  {
    "NeogitOrg/neogit",
     dependencies = {
              "nvim-lua/plenary.nvim",
              "sindrets/diffview.nvim", -- opsiyonel ama tavsiye edilir
    },
    config = function()
    require("neogit").setup {}
    end,
  },
})

map("n", "]h", function()
      require("gitsigns").next_hunk()
end, { desc = "Next Git hunk" })

map("n", "[h", function()
  require("gitsigns").prev_hunk()
end, { desc = "Previous Git hunk" })

-- LSP kısa yolları
map({ 'n', 'v' }, 'gd', vim.lsp.buf.definition)
map({ 'n', 'v' }, 'gD', vim.lsp.buf.declaration)
map({ 'n', 'v' }, 'gi', vim.lsp.buf.implementation)
map({ 'n', 'v' }, 'gr', vim.lsp.buf.references)
map({ 'n', 'v' }, 'K', vim.lsp.buf.hover)

-- Telescope LSP
map({ 'n', 'v' }, '<leader>gd', '<cmd>Telescope lsp_definitions<CR>')
map({ 'n', 'v' }, '<leader>gr', '<cmd>Telescope lsp_references<CR>')
map({ 'n', 'v' }, '<leader>gi', '<cmd>Telescope lsp_implementations<CR>')
map({ 'n', 'v' }, '<leader>ds', '<cmd>Telescope lsp_document_symbols<CR>')
map({ 'n', 'v' }, '<leader>ws', '<cmd>Telescope lsp_workspace_symbols<CR>')
map({ 'n', 'v' }, '<leader>ld', '<cmd>Telescope diagnostics<CR>')

vim.api.nvim_create_user_command("C", function(opts)
  local args = vim.split(opts.args, " ")
  local key = args[1]
  table.remove(args, 1)

  local map = {
    ["0"] = "Cs find s",
    ["1"] = "Cs find g",
    ["2"] = "Cs find d",
    ["3"] = "Cs find c",
    ["4"] = "Cs find t",
    ["5"] = "Cs find e",
    ["6"] = "Cs find f",
    ["7"] = "Cs find i",
    ["8"] = "Cs find a",
    ["9"] = "Cs db build",
    ["init"] = "Cs db build",
    ["add"] = "Cs db add",
  }

  if map[key] then
    local full_cmd = map[key] .. " " .. table.concat(args, " ")
    vim.cmd(full_cmd)
  else
    print("Geçersiz komut: " .. key)
  end
end, { nargs = "+", 
       complete = "file",
    })

-- CSCOPE shortcuts. Creating cscope file: cscope -q -R
map({ 'n', 'v' }, '<leader>0', "<cmd>CsPrompt s<CR><CR>")
map({ 'n', 'v' }, '<leader>1', "<cmd>CsPrompt g<CR><CR>")
map({ 'n', 'v' }, '<leader>2', "<cmd>CsPrompt d<CR><CR>")
map({ 'n', 'v' }, '<leader>3', "<cmd>CsPrompt c<CR><CR>")
map({ 'n', 'v' }, '<leader>4', "<cmd>CsPrompt t<CR><CR>")
map({ 'n', 'v' }, '<leader>5', "<cmd>CsPrompt e<CR><CR>")
map({ 'n', 'v' }, '<leader>6', "<cmd>CsPrompt f<CR><CR>")
map({ 'n', 'v' }, '<leader>7', "<cmd>CsPrompt i<CR><CR>")
map({ 'n', 'v' }, '<leader>8', "<cmd>CsPrompt a<CR><CR>")
map({ 'n', 'v' }, '<leader>9', "<cmd>Cs db build<CR><CR>")

map({"n", "v"}, "<F2>", function()
  local num = vim.wo.number
  local rel = vim.wo.relativenumber

  if not num and not rel then
    vim.wo.number = true
    vim.wo.relativenumber = false
  elseif num and not rel then
    vim.wo.number = true
    vim.wo.relativenumber = true
  else
    vim.wo.number = false
    vim.wo.relativenumber = false
  end
end, { desc = "Cycle line number display modes" })

map("n", "<F3>", ":Files<CR>", { desc = "Find files with fzf" })
map("n", "<leader>bl", ":Buffers<CR>", { desc = "List buffers with fzf" })
map("n", "<leader>gf", ":GFiles<CR>", { desc = "Git files with fzf" })

-- 🔍 Dosya bul (find_files)
map('n', '<F4>', ':Telescope find_files<CR>', opts)
-- 🔍 Projede canlı grep (kelime ara)
map('n', '<F5>', ':Telescope live_grep<CR>', opts)
-- 📑 Buffer listesi
map('n', '<F6>', ':Telescope buffers<CR>', opts)
-- 📂 Yardım etiketleri (help tags)
-- map('n', '<F6>', ':Telescope help_tags<CR>', opts)
-- 🧩 Git tracked files
map('n', '<F7>', ':Telescope git_files<CR>', opts)
-- 🗂️ Dosya tarayıcı (isteğe bağlı)
map('n', '<F8>', ':Telescope file_browser<CR>', opts)
-- 🔁 Son komutlar (komut geçmişi)
map('n', '<F9>', ':Telescope command_history<CR>', opts)
-- 🧭 LSP Sembolleri
map('n', '<F10>', ':Telescope lsp_document_symbols<CR>', opts)

-- === Telescope keymaps ===
map("n", "<leader>ff", ":Telescope find_files<CR>")
map("n", "<leader>fg", ":Telescope live_grep<CR>")
map("n", "<leader>fb", ":Telescope buffers<CR>")
map("n", "<leader>fh", ":Telescope help_tags<CR>")

-- Sembol (workspace symbols)
map("n", "<leader><leader>0", "<cmd>Telescope lsp_workspace_symbols<CR>", { desc = "Workspace Symbols" })
-- map("n", "<leader><leader>0", ":Telescope lsp_document_symbols<CR>", { desc = "Document Symbols" })

-- Tanım (definition)
-- map("n", "<leader><leader>1", vim.lsp.buf.definition, { desc = "Goto Definition" })
map("n", "<leader><leader>1", '<cmd>Telescope lsp_definitions<CR>', { desc = "Goto Definition" })

-- Outgoing Calls
map("n", "<leader><leader>2", vim.lsp.buf.outgoing_calls, { desc = "Outgoing Calls" })
-- Incoming Calls
map("n", "<leader><leader>3", vim.lsp.buf.incoming_calls, { desc = "Incoming Calls" })

-- Text Search
-- map("n", "<leader>4", ":Telescope live_grep<CR>", { desc = "Live Grep" })

map({ 'v', 'n' }, "<leader><leader>4", function()
  local word = vim.fn.expand('<cword>') -- fallback
  local selection = vim.fn.getreg('v')
  if selection ~= '' then word = selection end
  require('telescope.builtin').live_grep({ default_text = word })
end, opts)

-- Regex Search (aynı komut)
map("n", "<leader><leader>5", ":Telescope live_grep<CR>", { desc = "Live Grep Regex" })
-- Dosya Arama
map("n", "<leader><leader>6", ":Telescope find_files<CR>", { desc = "Find Files" })
-- #include eden dosyaları aramak için basit grep
map("n", "<leader><leader>7", ":Telescope grep_string<CR>", { desc = "Grep String" })
-- Atama yapılan yerler: references
map("n", "<leader><leader>8", '<cmd>Telescope lsp_references<CR>', { desc = "Find References" })
map("n", "<leader><leader>9", '<cmd>Telescope diagnostics<CR>', { desc = "Incoming Calls" })

-- Geri (previous jump)
map("n", "<C-Left>", "<C-o>", { desc = "Previous jump" })

-- İleri (next jump)
map("n", "<C-Right>", "<C-i>", { desc = "Next jump" })

-- Yeni yatay split
map("n", "<leader>sh", "<C-w>s", { desc = "Split horizontal" })

-- Yeni dikey split
map("n", "<leader>sv", "<C-w>v", { desc = "Split vertical" })

-- Splitler arası geçiş
map("n", "<leader>h", "<C-w>h", { desc = "Move to left split" })
map("n", "<leader>j", "<C-w>j", { desc = "Move to bottom split" })
map("n", "<leader>k", "<C-w>k", { desc = "Move to top split" })
map("n", "<leader>l", "<C-w>l", { desc = "Move to right split" })
-- Saat yönünde split değiştir
map("n", "<leader>w", "<C-w>w", { desc = "Next split clockwise" })

-- Split boyut ayarlama
map("n", "<leader>+", "<C-w>+", { desc = "Increase split height" })
map("n", "<leader>-", "<C-w>-", { desc = "Decrease split height" })
map("n", "<leader><", "<C-w><", { desc = "Decrease split width" })
map("n", "<leader>>", "<C-w>>", { desc = "Increase split width" })

-- Yeni sekme aç
map("n", "<leader>tn", ":tabnew<CR>", { desc = "New tab" })

-- Sekmeyi kapat
map("n", "<leader>tc", ":tabclose<CR>", { desc = "Close tab" })

-- Sekmeler arası geçiş
map("n", "<Tab>", "gt", { desc = "Next tab" })
map("n", "<S-Tab>", "gT", { desc = "Previous tab" })
-- Bir önceki buffer
map("n", "<leader>bp", ":bprevious<CR>", { desc = "Previous buffer" })
-- Bir sonraki buffer
map("n", "<leader>bn", ":bnext<CR>", { desc = "Next buffer" })
-- Buffer kapat
map("n", "<leader>bd", ":bd<CR>", { desc = "Delete buffer" })
map("n", "<C-n>", ":cnext<CR>", { desc = "Next quickfix" })
map("n", "<C-j>", ":cprevious<CR>", { desc = "Previous quickfix" })

-- Normal mod: Ctrl+v → clipboard paste
vim.keymap.set("n", "<C-v>", '"+p', { desc = "Paste clipboard" })
-- Insert mod: Ctrl+v → clipboard paste
vim.keymap.set("i", "<C-v>", '<C-r>+', { desc = "Paste clipboard in insert" })
-- Visual mod: Ctrl+v → clipboard paste (üzerine yapıştır)
vim.keymap.set("v", "<C-v>", '"+p', { desc = "Paste clipboard visual" })

-- Normal modda satırı clipboard’a kopyala
vim.keymap.set("n", "<leader>y", '"+yy', { desc = "Yank line to clipboard" })

-- Visual modda seçiliyi clipboard’a kopyala
vim.keymap.set("v", "<leader>y", '"+y', { desc = "Yank selection to clipboard" })

vim.keymap.set("n", "<leader>g", function()
  vim.cmd([[%s/\s\+$//e]])
  vim.cmd("normal! gg=G")
  print("Trailing whitespace removed and file indented!")
end, { desc = "Clean whitespace and auto-indent" })

-- Visual Mode: Move lines up
map({"n", "v"}, "<C-S-Up>", ":m .-2<CR>==", { noremap = true, silent = true, desc = "Move line up" })

-- Visual Mode: Move lines down

map({"n", "v"}, "<C-S-Down>", ":m .+1<CR>==", { noremap = true, silent = true, desc = "Move line down" })
-- if vim.fn.filereadable(session_path) == 1 then
--   vim.cmd("source " .. session_path)
-- end

vim.api.nvim_create_user_command("Srg", function(opts)
  local args = opts.fargs
  local search = args[1] or ""
  local folder = args[2] or vim.fn.getcwd()

  if vim.fn.isdirectory(folder) == 0 then
    folder = vim.fn.getcwd()
  end

  -- ag veya rg komutu
  -- local cmd = string.format("ag --vimgrep -- %s %s", vim.fn.shellescape(search), vim.fn.shellescape(folder))
  local cmd = string.format("rg --vimgrep --smart-case -- %s %s", vim.fn.shellescape(search), vim.fn.shellescape(folder)) -- istersen rg de kullanabilirsin

  -- Quickfix listesini doldur ve copen yap
  vim.fn.setqflist({}, ' ', {
    title = 'Search results for "' .. search .. '"',
    efm = '%f:%l:%c:%m',
    lines = vim.fn.systemlist(cmd)
  })

  vim.cmd("copen")
  vim.cmd("wincmd p")  -- Quickfix açıldıktan sonra imleci önceki pencereye geri alır
end, {
  nargs = "*",
  complete = "file",
  desc = "Search in folder or current directory and open quickfix"
})

map("n", "<C-q>", function()
      local wininfo = vim.fn.getwininfo()
  for _, win in ipairs(wininfo) do
        if win.quickfix == 1 then
              vim.cmd("cclose")
          return
        end
  end
  vim.cmd("copen")
end, { desc = "Toggle Quickfix", silent = true })

