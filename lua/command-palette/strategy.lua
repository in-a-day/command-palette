-- Open strategy
-- strategy function has two param:
-- 1. opts: opts provided by user
-- 2. node: the node executes the open operation

local M = {
  _strategy = 'default',
  _fn = {
    default = function(opts, node)
      -- current do nothing
      print("default callback of open")
    end,
  },
}

--- default strategy name
function M.strategy()
  return M._strategy
end

--- strategy function, if name is nil, return default function
function M.fn(name)
  name = name ~= '' and name or M._strategy
  return M._fn[name]
end

function M.change_strategy(name)
  M._strategy = name
end

function M.add_strategy(name, callback)
  M._fn[name] = callback
end

return M
