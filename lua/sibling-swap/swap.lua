local u = require('sibling-swap.utils')
local settings = require('sibling-swap.settings').settings

local M = {}

---Swaps the node under the cursor with the (left/right) sibling
---@param side string left/right
---@param swap_unnamed? boolean Swap operator to opposite
function M.swap_with(side, swap_unnamed)
  swap_unnamed = swap_unnamed or false

  local parser = vim.treesitter.get_parser(0)
  if not parser then
    return
  end

  parser:parse(true)

  local node = vim.treesitter.get_node()
  if not node then
    return
  end
  local lang = u.get_node_lang(node)
  local fb = settings.fallback[lang] and settings.fallback[lang][node:type()]
    or nil
  local is_fb = fb
      and (type(fb.enable) == 'function' and fb.enable(node) or fb.enable)
    or false

  if fb and is_fb then
    fb.action(node, side, swap_unnamed)
    return
  end

  local siblings = u.get_suitable_siblings(node, side)
  if siblings then
    local replacement = u.swap_siblings_ranges(siblings, swap_unnamed)
    local cursor = u.calc_cursor(replacement, side)

    for i = #replacement, 1, -1 do
      local sr, sc, er, ec = unpack(replacement[i].range)
      vim.api.nvim_buf_set_text(0, sr, sc, er, ec, replacement[i].text)
    end

    pcall(vim.api.nvim_win_set_cursor, 0, cursor)

    u.highlight_node_at_cursor(replacement, side)
  end
end

return M
