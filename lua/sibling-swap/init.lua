local settings = require('sibling-swap.settings')

local M = {}

local function with_dot_repeat(side, swap_unnamed)
  _G.__sibling_swap = function()
    for _ = 1, vim.v.count1 do
      require('sibling-swap.swap').swap_with(side, swap_unnamed)
    end
  end
  vim.opt.operatorfunc = 'v:lua.__sibling_swap'
  vim.api.nvim_feedkeys(vim.v.count1 .. 'g@l', 'nix', true)
end

---Swap node with left-side sibling
M.swap_with_left = function()
  with_dot_repeat('left')
end

---Swap node with right-side sibling
M.swap_with_right = function()
  with_dot_repeat('right')
end

---Swap node with left-side sibling and replace operator to opposite
M.swap_with_left_with_opp = function()
  with_dot_repeat('left', true)
end

---Swap node with right-side sibling and replace operator to opposite
M.swap_with_right_with_opp = function()
  with_dot_repeat('right', true)
end

---Setup `sibling-swap.nvim`
---@param opts UserOpts
M.setup = function(opts)
  settings._update_settings(opts)
end

return M
