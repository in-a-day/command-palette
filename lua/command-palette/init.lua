local M = {}

local config = require("command-palette.config")
local strategy = require("command-palette.strategy")
local PaletteNode = require("command-palette.palette_node")
local create_user_cmd = vim.api.nvim_create_user_command

local function create_cmd()
  create_user_cmd("CommandPaletteOpen", function()
    M.palette:open()
  end, { desc = "Open Command Palette" })
  create_user_cmd("CommandPaletteRefresh", function()
    M.refresh()
  end, { desc = "Refesh Command Palette" })

  -- refresh on buffer enter
  vim.api.nvim_create_autocmd("BufEnter", {
    desc = "CommandPalette Refresh",
    callback = function ()
      M.refresh()
    end
    -- callback = M.refresh,
  })
end

function M.setup(opts)
  local palette = M.init(opts, false)
  create_cmd()

  return palette
end

function M.init(opts, refresh)
  opts = opts or {}
  config.config = vim.tbl_deep_extend("force", config.config, opts)
  if not refresh then
    strategy.change_strategy(config.config.strategy)
  end
  local fake_node = {
    label = "Command Palette",
    children = config.config.nodes,
  }

  M.palette = PaletteNode.new(fake_node, nil)
  return M.palette
end

function M.refresh()
  return M.init({}, true)
end

return M
