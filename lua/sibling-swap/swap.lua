local u = require('sibling-swap.utils')
local settings = require('sibling-swap.settings').settings
local ts_ok, ts_utils = pcall(require, 'nvim-treesitter.ts_utils')

if not ts_ok then
  return
end

local M = {}

---Swaps the node under the cursor with the (left/right) sibling
---@param side string left/right
function M.swap_with(side)
  local node = ts_utils.get_node_at_cursor(0, settings.ignore_injected_langs)
  local siblings = u.get_suitable_siblings(node, side)
  if siblings then
    local replacement = u.swap_siblings_ranges(siblings)
    local cursor = u.calc_cursor(replacement, side)
    for i = #replacement, 1, -1 do
      local sr, sc, er, ec = unpack(replacement[i].range)
      vim.api.nvim_buf_set_text(0, sr, sc, er, ec, replacement[i].text)
    end
    vim.api.nvim_win_set_cursor(0, cursor)
  end
end

return M
