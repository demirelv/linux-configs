-- Telescope picker over the lc-help index (shell commands, git aliases, tmux keys, tools, local notes).
-- <leader>fl. Enter copies the text to type (example or command) to the clipboard and the unnamed register.
-- The index comes from `lc-help --tsv` (bin/lc-help), so nothing is defined twice.
local M = {}

-- "kind\tkey\tdesc\tsource\texample" lines -> list of entries
function M.parse(lines)
  local out = {}
  for _, line in ipairs(lines) do
    local f = vim.split(line, "\t", { plain = true })
    if #f >= 3 then
      out[#out + 1] = { kind = f[1], key = f[2], desc = f[3], src = f[4] or "", example = f[5] or "" }
    end
  end
  return out
end

-- What to copy for an entry: the example, else the command (first word for shell commands), else the key itself.
function M.text_of(e)
  if e.example ~= "" then return e.example end
  if e.kind == "cmd" or e.kind == "local" then return (e.key:match("^(%S+)")) or e.key end
  return e.key
end

function M.open()
  local exe = vim.fn.exepath("lc-help")
  if exe == "" then
    vim.notify("lc-help is not installed (run ./install.sh)", vim.log.levels.ERROR)
    return
  end
  local lines = vim.fn.systemlist({ exe, "--tsv" })
  if vim.v.shell_error ~= 0 then
    vim.notify("lc-help --tsv failed", vim.log.levels.ERROR)
    return
  end
  local entries = M.parse(lines)
  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local actions = require("telescope.actions")
  local state = require("telescope.actions.state")
  pickers.new({}, {
    prompt_title = "lc-help (Enter copies the text)",
    finder = finders.new_table({
      results = entries,
      entry_maker = function(e)
        return {
          value = e,
          display = string.format("%-5s %-30s %s", e.kind, e.key, e.desc),
          ordinal = e.kind .. " " .. e.key .. " " .. e.desc .. " " .. e.example,
        }
      end,
    }),
    sorter = conf.generic_sorter({}),
    attach_mappings = function(bufnr)
      actions.select_default:replace(function()
        local sel = state.get_selected_entry()
        actions.close(bufnr)
        if not sel then return end
        local text = M.text_of(sel.value)
        vim.fn.setreg('"', text)
        pcall(vim.fn.setreg, "+", text)
        vim.notify(text .. "  (copied)")
      end)
      return true
    end,
  }):find()
end

return M
