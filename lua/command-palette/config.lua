local M = {}

-- default node configs
local node_config = {
  label = nil,  -- string, must not nil or '', title of the node
  desc = nil,  -- string, optional, description of this node, if nil, use cmd as default
  cmd = nil, -- optional, lua fucntion or vim command, execute when node is selected, if node is a parent node, you should not provide this
  children = nil, -- array or nil, an array of node_config
  keymap = nil,  -- string, register cmd with keymap, current don't support
}

-- configs for this plugin
M.config = {
  nodes = {},  -- array of node config
  default_nodes = {  -- not support for now, default node add to nodes
    builtin = false,
  },
  back_key = "<C-b>",  -- go back to parent node key
  strategy = "default",  -- string, open node strategy, you can change this using strategy api
  telescope = {  -- configs for telescope, if you don't use telescope, just ignore it.
    strategy = {
      register = true,  -- add telescope
      as_default = true,  -- set telescope strategy as default
    },
  },
  default_keymap = false,  -- not support for now, true or false, use default keymap
  register_on_absent = false, -- not support for now, register keymap when node keymap is absent
  force_register_keymap = false,  -- not support for now, always register keymap using this plugin
}


return M

