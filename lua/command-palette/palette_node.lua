local strategy = require("command-palette.strategy")
local utils = require("command-palette.utils")
local PaletteNode = {}
PaletteNode.__index = PaletteNode

local function is_emtpy(tbl)
  return tbl == nil or vim.tbl_isempty(tbl)
end

local function add_child(node, child)
  table.insert(node.children, child)
  node.label_to_child[child.label] = child
end

-- do not change the original opt
local function format_opt(opt)
  opt = opt or {}
  opt = vim.deepcopy(opt)
  if not opt.children then
    opt.children = {}
  end

  if opt.auto_detect then
    local user_commands = utils.find_user_commands(opt.label)
    for _, val in ipairs(user_commands) do
      table.insert(opt.children, { label = val, cmd = val })
    end
  end
  return opt
end

-- opt: see config.lua
--- create node recursively
local function create(opt, parent)
  local conf = format_opt(opt)
  local node = {
    label = conf.label,
    desc = conf.desc,
    parent = parent,
    cmd = conf.cmd,
    children = {},
    label_to_child = {},
  }
  -- populate children
  if not is_emtpy(conf.children) then
    for _, child_opt in ipairs(conf.children) do
      -- create only when child do not exist
      if not node.label_to_child[child_opt.label] then
        -- create child
        local child_node = PaletteNode.new(child_opt, node)
        add_child(node, child_node)
      end
    end
  end

  return node
end

--- create new node from given config and parent
---@param opt table is user def config
---@param parent table: PaletteNode the parent node of the new node
---@return table: PaletteNode
function PaletteNode.new(opt, parent)
  local obj = create(opt, parent)
  local ret = setmetatable(obj, PaletteNode)
  return ret
end

function PaletteNode:is_leaf()
  return self.children == nil or vim.tbl_count(self.children) == 0
end

function PaletteNode:runnable()
  return not self:is_leaf()
end

--- add node to its children, return itself
---@param child table: PaletteNode a node or configs of this node
---@return table: PaletteNode
function PaletteNode:add_child(child)
  child.parent = self
  add_child(self, child)
  return self
end

--- add sibling
---@param sibling table: PaletteNode
---@return table: PaletteNode
function PaletteNode:add_sibling(sibling)
  return self.parent:add_child(sibling)
end

-- implement the open method to open node.
-- using strategy to open
--- open the node, create panel show node's children
function PaletteNode:open(strategy_name)
  strategy.fn(strategy_name)({}, self)
end

-- implement the close method to close node.
-- using strategy to close
--- close the node
function PaletteNode:close(strategy_name)
  -- TODO close
end

--- run the node command
function PaletteNode:run()
  if not self:is_leaf() then
    vim.notify("Cannot run on this node.")
    return
  end
  if not self.cmd then
    vim.notify("No command is provided.")
    return
  end
  if vim.is_callable(self.cmd) then
    self.cmd()
    return
  end
  vim.api.nvim_exec(self.cmd, true)
end

--- find child node by specified label
---@param label string label of child
---@return table: PaletteNode
function PaletteNode:next(label)
  return self.label_to_child[label]
end

return PaletteNode
