-- Used by bin/lc-help: prints the user's own Neovim keymaps (the ones with a desc that were set from files under
-- the config directory) as TSV: nvim<TAB>key<TAB>description<TAB>nvim (modes). Run: nvim --headless "+luafile <this>" +qa!
local cfg = vim.fn.stdpath("config")
local mine = {}
for _, i in ipairs(vim.fn.getscriptinfo()) do
  if i.name:find(cfg, 1, true) == 1 then mine[i.sid] = true end
end

local seen, order = {}, {}
for _, mode in ipairs({ "n", "x", "i", "o" }) do
  for _, m in ipairs(vim.api.nvim_get_keymap(mode)) do
    if mine[m.sid] and m.desc and m.desc ~= "" and not m.lhs:find("^<Plug>") then
      -- <leader> is a literal space in lhs; show it the way the keys are written in the config
      local key = m.lhs:gsub("^  ", "<leader><leader>"):gsub("^ ", "<leader>")
      local id = key .. "\t" .. m.desc
      if seen[id] then
        seen[id].modes = seen[id].modes .. "," .. mode
      else
        seen[id] = { key = key, desc = m.desc, modes = mode }
        order[#order + 1] = id
      end
    end
  end
end
for _, id in ipairs(order) do
  local e = seen[id]
  io.stdout:write(("nvim\t%s\t%s\tnvim (%s)\n"):format(e.key, e.desc, e.modes))
end
