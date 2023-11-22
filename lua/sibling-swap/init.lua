local settings = require('sibling-swap.settings')

local M = {}

---Swap node with left-side sibling
M.swap_with_left = function()
  require('sibling-swap.swap').swap_with('left')
end

---Swap node with right-side sibling
M.swap_with_right = function()
  require('sibling-swap.swap').swap_with('right')
end

---Swap node with left-side sibling and replace operator to opposite
M.swap_with_left_with_opp = function()
  require('sibling-swap.swap').swap_with('left', true)
end

---Swap node with right-side sibling and replace operator to opposite
M.swap_with_right_with_opp = function()
  require('sibling-swap.swap').swap_with('right', true)
end

---Setup `sibling-swap.nvim`
---@param opts UserOpts
M.setup = function(opts)
  settings._update_settings(opts)
end

return M
