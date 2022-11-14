local settings = require('sibling-swap.settings')

local M = {}

M.swap_with_left = function()
  require('sibling-swap.swap').swap_with('left')
end

M.swap_with_right = function()
  require('sibling-swap.swap').swap_with('right')
end

M.setup = function(opts)
  settings._update_settings(opts)
end

return M
