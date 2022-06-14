local telescope = require("telescope")
local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local conf = require("telescope.config").values
local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"
local entry_display = require "telescope.pickers.entry_display"


local cp = require("command-palette")
local cp_conf = require("command-palette.config").config
local cp_strategy = require("command-palette.strategy")

local function is_empty(tbl)
  return tbl == nil or vim.tbl_isempty(tbl)
end

local function hide_desc(tbl)
  local icon = is_empty(tbl.value.children) and ' ' or 'פּ '
  return icon .. tbl.value.label
end

local function finder_maker(tbl)
  if not cp_conf.telescope.show_desc then
    return hide_desc(tbl)
  end

  local icon = is_empty(tbl.value.children) and ' ' or 'פּ '
  local desc = tbl.value.desc or tbl.value.cmd
  desc = vim.is_callable(desc) and "Function..." or desc
  local displayer = entry_display.create({
    separator = " ",
    items = {
      { width = 32 },
      { remaining = true },
    },
  })
  return displayer({
    { icon .. tbl.value.label },
    { desc },
  })
end

--- open node
---@param opts table configs
---@param node table: PaletteNode
local function open(opts, node)
  if not node then
    vim.notify("Cannot open, node is nil.")
    return
  end
  opts = opts or {}
  pickers.new(opts, {
    prompt_title = node.label,
    finder = finders.new_table {
      results = node.children,
      entry_maker = function(entry)
        return {
          value = entry,
          display = finder_maker,
          ordinal = entry.label,
        }
      end
    },
    sorter = conf.generic_sorter(opts),
    attach_mappings = function(prompt_bufnr, map)
      local back_key = cp_conf.back_key or "<C-b>"
      map("i", back_key, function() open(opts, node.parent) end)
      map("n", back_key, function() open(opts, node.parent) end)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selected = action_state.get_selected_entry()
        if not selected then
          vim.notify("Nothing selected.")
          return
        end
        local selected_node = selected.value
        if not selected_node then
          vim.notify("Selected node is nil.")
          return
        end
        if selected_node:is_leaf() then
          selected_node:run()
        else
          open(opts, selected_node)
        end
      end)
      return true
    end,
  }):find()
end

-- before register to telescope, you must ensure this plugin has been setuped.
local function cp_run(opts)
  local palette = cp.palette
  open(opts, palette)
end

-- add telescope strategy
if cp_conf.telescope.strategy.register then
  local strategy_name = "telescope"
  cp_strategy.add_strategy(strategy_name, open)
  if cp_conf.telescope.strategy.as_default then
    cp_strategy.change_strategy(strategy_name)
  end
end


return telescope.register_extension({
  exports = {
    command_palette = cp_run,
  }
})
