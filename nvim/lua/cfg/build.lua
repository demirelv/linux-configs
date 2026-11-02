-- :Make [arguman] -> makeprg'yi ASENKRON calistirir (arayuz donmaz), ciktiyi quickfix'e yazar.
-- gcc/clang/make hatalari errorformat ile ayristirilir; nvim-bqf onizleme verir.
local M = {}

-- args: makeprg'ye eklenecek metin. on_done(res, qf_hata_sayisi): bittiginde (testler icin).
function M.run(args, on_done)
  args = args or ""
  local prg = vim.fn.expandcmd(vim.o.makeprg)
  local cmd
  if prg:find("$*", 1, true) then
    -- makeprg icindeki `$*` argumanlarla degisir (gsub sonucu ve sayisini ayri tut)
    local escaped = args:gsub("%%", "%%%%")
    cmd = prg:gsub("%$%*", escaped)
  else
    cmd = prg .. " " .. args
  end
  cmd = vim.trim(cmd)
  vim.notify("Make: " .. cmd)
  vim.system({ "sh", "-c", cmd .. " 2>&1" }, { text = true }, vim.schedule_wrap(function(res)
    local lines = vim.split(res.stdout or "", "\n", { trimempty = true })
    vim.fn.setqflist({}, " ", { title = cmd, lines = lines, efm = vim.o.errorformat })
    local errors = #vim.tbl_filter(function(item) return item.valid == 1 end, vim.fn.getqflist())
    if res.code ~= 0 or errors > 0 then
      vim.cmd("copen")
      vim.notify(("Make basarisiz (cikis %d, %d hata/uyari)"):format(res.code, errors), vim.log.levels.WARN)
    else
      vim.cmd("cclose")
      vim.notify("Make tamam")
    end
    if on_done then on_done(res, errors) end
  end))
end

vim.api.nvim_create_user_command("Make", function(o) M.run(o.args) end,
  { nargs = "*", desc = "Run makeprg asynchronously and fill quickfix" })

vim.keymap.set("n", "<leader>mm", function() M.run("") end, { desc = "Build (makeprg, async)" })
vim.keymap.set("n", "<leader>mc", function() M.run("clean") end, { desc = "Clean build outputs (make clean)" })

return M
