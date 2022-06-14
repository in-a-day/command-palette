local strategy = require("command-palette.strategy")
local PaletteNode = {}
PaletteNode.__index = PaletteNode

local function is_emtpy(tbl)
  return tbl == nil or vim.tbl_isempty(tbl)
end

local function add_child(node, child)
  table.insert(node.children, child)
  node.label_to_child[child.label] = child
end

-- opt: see config.lua
--- create node recursively
local function create(opt, parent)
  -- TODO check opt
  opt = opt or {}
  local node = {
    label = opt.label,
    desc = opt.desc,
    parent = parent,
    cmd = opt.cmd,
    children = {},
    label_to_child = {},  -- used for function next()
  }
  -- populate children
  if not is_emtpy(opt.children) then
    for _, child_opt in ipairs(opt.children) do
      -- create child
      local child_node = PaletteNode.new(child_opt, node)
      add_child(node, child_node)
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

-- TODO myabe seperate this function to two function
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
  end
  if not self.cmd then
    vim.notify("No command is provided.")
  end
  if vim.is_callable(self.cmd) then
    self.cmd()
  end
  vim.api.nvim_exec(self.cmd, true)
end

--- find child node by specified desc
---@param desc string desc of child
---@return table: PaletteNode
function PaletteNode:next(desc)
  return self.label_to_child[desc]
end

return PaletteNode
