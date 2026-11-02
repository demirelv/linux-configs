-- init.lua kontrolleri. nvim/tests/run.sh icinden, eklentiler kurulduktan sonra calisir.
io.stdout:setvbuf("no")
local failed = 0
local function check(ok, msg)
  io.stdout:write((ok and "PASS " or "FAIL ") .. msg .. "\n")
  if not ok then failed = failed + 1 end
end

-- 1. Baslangicta hata yok
local msgs = vim.fn.execute("messages")
check(vim.v.errmsg == "", "v:errmsg bos (" .. vim.v.errmsg .. ")")
check(not msgs:find("E%d+:") and not msgs:find("Error"), "baslangic mesajlarinda hata yok")

-- 2. Tus kisayollari: on ek cakismasi ve desc
-- Calisma zamaninin kendi varsayilanlari (gc, grr, % ...) da hesaba katilir, ama desc yalniz bizim
-- kisayollarimizdan (sid = init.lua) beklenir.
local init_sid
for _, i in ipairs(vim.fn.getscriptinfo({ name = "init.lua" })) do
  if i.name:find("nvim/init.lua", 1, true) then init_sid = i.sid end
end
check(init_sid ~= nil, "init.lua script id bulundu")

local function all_maps(mode)
  local out = {}
  for _, m in ipairs(vim.api.nvim_get_keymap(mode)) do
    if not m.lhs:find("^<Plug>") and not m.lhs:find("^<SNR>") then
      out[#out + 1] = { raw = m.lhsraw or m.lhs, lhs = m.lhs, desc = m.desc, mine = (m.sid == init_sid) }
    end
  end
  return out
end

for _, mode in ipairs({ "n", "x", "i" }) do
  local maps = all_maps(mode)
  local conflicts = {}
  for _, a in ipairs(maps) do
    for _, b in ipairs(maps) do
      -- ozel tus kodlari (F1, C-Left ...) 0x80 ile baslar; bayt on eki anlamsiz
      if (a.mine or b.mine) and not a.raw:find("\128") and not b.raw:find("\128")
        and #a.raw < #b.raw and b.raw:sub(1, #a.raw) == a.raw then
        conflicts[#conflicts + 1] = a.lhs .. " (on ek) <-> " .. b.lhs
      end
    end
  end
  check(#conflicts == 0, "mod " .. mode .. ": on ek cakismasi yok " .. table.concat(conflicts, "; "))

  local nodesc, count = {}, 0
  for _, m in ipairs(maps) do
    if m.mine then
      count = count + 1
      if not m.desc or m.desc == "" then nodesc[#nodesc + 1] = m.lhs end
    end
  end
  check(count > 0, "mod " .. mode .. ": init.lua kisayollari bulundu (" .. count .. ")")
  check(#nodesc == 0, "mod " .. mode .. ": tum kisayollarin desc'i var " .. table.concat(nodesc, ", "))
end

-- 3. Eklentiler ve eklentiler arasi baglanti
local ok_t, telescope = pcall(require, "telescope")
check(ok_t, "telescope yuklenir")
if ok_t then
  check(telescope.extensions.fzf ~= nil, "telescope-fzf-native yuklu")
  check(telescope.extensions.live_grep_args ~= nil, "telescope-live-grep-args yuklu")
end
check((pcall(require, "which-key")), "which-key yuklenir")
check(vim.g.colors_name == "tokyonight-night", "renk temasi tokyonight-night (" .. tostring(vim.g.colors_name) .. ")")

-- 4. LSP: clangd yapilandirmasi var ve etkin
local cfg = vim.lsp.config["clangd"]
check(cfg ~= nil and cfg.cmd ~= nil and cfg.cmd[1] == "clangd", "vim.lsp.config.clangd komutu clangd")
check(vim.lsp.is_enabled == nil or vim.lsp.is_enabled("clangd"), "clangd etkin")
check(vim.tbl_contains(cfg.cmd, "--background-index"), "clangd --background-index ile calisir")
check(#vim.api.nvim_get_autocmds({ event = "LspAttach" }) > 0, "LspAttach (yerlesik tamamlama) autocmd'i var")
check(vim.tbl_contains(vim.opt.completeopt:get(), "popup"), "completeopt popup iceriyor")

-- clangd varsa gercek bir C dosyasi ac: client baglanmali ve tamamlama etkin olmali
if vim.fn.executable("clangd") == 1 then
  local dir = vim.fn.tempname()
  vim.fn.mkdir(dir, "p")
  vim.fn.writefile({ "int main(void) { return 0; }" }, dir .. "/main.c")
  vim.cmd("edit " .. dir .. "/main.c")
  local attached = vim.wait(15000, function() return #vim.lsp.get_clients({ bufnr = 0, name = "clangd" }) > 0 end, 200)
  check(attached, "clangd C dosyasina baglandi")
  vim.cmd("bwipeout!")
else
  io.stdout:write("SKIP clangd baglanti testi (clangd yok)\n")
end

-- 5. Vurgular: uc kalip bir kez eklenmis
-- (-c komutlari VimEnter'dan once calisir; autocmd'i elle tetikle, iki kez tetiklemek de tekrar eklememeli)
vim.api.nvim_exec_autocmds("BufWinEnter", {})
vim.api.nvim_exec_autocmds("BufWinEnter", {})
local patterns = {}
for _, m in ipairs(vim.fn.getmatches()) do patterns[m.group] = (patterns[m.group] or 0) + 1 end
check(patterns.ExtraWhitespace == 1 and patterns.EmptyLine == 1 and patterns.TodoSpace == 1,
  "vurgular tekrarsiz (ExtraWhitespace/EmptyLine/TodoSpace)")
check(vim.api.nvim_get_hl(0, { name = "ExtraWhitespace" }).bg == 0xFF0000, "ExtraWhitespace kirmizi")

-- 6. <C-v> blok secimine geri verildi, panoya <leader>p bagli
check(vim.fn.maparg("<C-v>", "n") == "", "<C-v> normal modda remap edilmemis")
check(vim.fn.maparg("<leader>p", "n") ~= "", "<leader>p panoya yapistirma bagli")

-- 7. word_or_selection: kelime ve secim grep'e aktarilir
local function prompt_after(keys)
  vim.cmd("enew")
  vim.api.nvim_buf_set_lines(0, 0, -1, false, { "hello world" })
  vim.cmd([[execute "normal! 0]] .. keys .. [[\<Cmd>lua _CHK_FW()\<CR>"]])
  local state = require("telescope.actions.state")
  local picker = state.get_current_picker(vim.api.nvim_get_current_buf())
  local text = picker and picker:_get_prompt() or nil
  if picker then require("telescope.actions").close(vim.api.nvim_get_current_buf()) end
  return text
end
local fw = vim.fn.maparg("<leader>fw", "n", false, true)
_G._CHK_FW = function() fw.callback() end
if ok_t and fw.callback then
  vim.cmd("enew")
  check(prompt_after("") == "hello", "<leader>fw: imlecteki kelime (hello)")
  check(prompt_after("viw") == "hello", "<leader>fw: secim (viw -> hello)")
  check(prompt_after("vee") == "hello world", "<leader>fw: coklu kelime secimi")
end

-- 8. Treesitter: CLI varsa c parser'i kurulur ve vurgu baslar
if vim.fn.executable("tree-sitter") == 1 then
  require("nvim-treesitter").install({ "c" }):wait(300000)
  vim.cmd("enew")
  vim.bo.filetype = "c"
  check(vim.treesitter.highlighter.active[vim.api.nvim_get_current_buf()] ~= nil, "treesitter: c dosyasinda vurgu aktif")
else
  io.stdout:write("SKIP treesitter parser testi (tree-sitter CLI yok)\n")
end

io.stdout:write(failed == 0 and "TUMU GECTI\n" or (failed .. " KONTROL BASARISIZ\n"))
-- test kaydedilmemis buffer birakir; zorla cik, yoksa headless nvim E37 ile bekler
if failed > 0 then vim.cmd("cquit 1") else vim.cmd("qa!") end
