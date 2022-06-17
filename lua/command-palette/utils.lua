local M = {}

function M.all_user_commands()
  local ret = {}
  if vim.tbl_isempty(ret) then
    local cmds = vim.api.nvim_get_commands({ builtin = false })
    for key, _ in pairs(cmds) do
      table.insert(ret, key)
    end
    table.sort(ret, function(a, b) return a < b end)
  end
  return ret
end

function M.find_user_commands(prefix)
  local cmds = M.all_user_commands()
  local ret = {}
  for idx, val in ipairs(cmds) do
    local position, _ = string.find(val, prefix)
    if position == 1 then
      table.insert(ret, val)
    end
  end
  return ret
end

return M
