local query = require('vim.treesitter.query')
local ts = require('vim.treesitter')
-- `ts.get_node_text` for NVIM v0.9.0-dev-1275+gcbbf8bd66-dirty and newer
-- see: https://github.com/neovim/neovim/pull/22761
local get_node_text = ts.get_node_text or query.get_node_text
local settings = require('sibling-swap.settings').settings

local ALLOWED_SEPARATORS = settings.allowed_separators
local ALLOW_INTERLINE_SWAPS = settings.allow_interline_swaps
local INTERLINE_SWAPS_NO_SEP = settings.interline_swaps_without_separator
local LEFT = 'left'
local M = {}

---Checking if siblings placed on same line
---@param node userdata TSNode instance
---@param sibling userdata TSNode instance
---@return boolean
local function is_on_same_line(node, sibling)
  local range = { node:range() }
  local s_range = { sibling:range() }
  return range[1] == range[3]
    and s_range[1] == s_range[3]
    and range[1] == s_range[1]
    and range[3] == s_range[3]
end

---Checking if both siblings are named
---@param node userdata TSNode instance
---@param sibling userdata TSNode instance
---@return boolean
local function is_both_named(node, sibling)
  return node:named() and sibling:named()
end

local function check_siblings(node, sibling)
  return (ALLOW_INTERLINE_SWAPS or is_on_same_line(node, sibling))
    and is_both_named(node, sibling)
end

local function is_allowed_sep(sibling)
  return vim.tbl_contains(vim.tbl_keys(ALLOWED_SEPARATORS), sibling:type())
end

---Sorting two nodes to determine their order
---@param node TSNode
---@param sibling TSNode
---@return TSNode, TSNode
local function sort_siblings(node, sibling)
  local nr = { node:range() }
  local sr = { sibling:range() }

  if nr[1] < sr[1] then
    return node, sibling
  elseif sr[1] < nr[1] then
    return sibling, node
  else
    if nr[2] < sr[2] then
      return node, sibling
    end
    return sibling, node
  end
end

---Checking if siblings have one or more whitespace chars (\s, \n) between each other
---@param node userdata TSNode instance
---@param sibling userdata TSNode instance
---@return boolean
local function has_whitespace_between(node, sibling)
  node, sibling = sort_siblings(node, sibling)
  local nr = { node:range() }
  local sr = { sibling:range() }
  local has_space = sr[2] - nr[4] >= 1

  if is_on_same_line(node, sibling) then
    return has_space
  elseif ALLOW_INTERLINE_SWAPS and INTERLINE_SWAPS_NO_SEP then
    return not (nr[1] == sr[1]) or has_space
  end

  return false
end

local function has_unnamed(named_sibling, sibling)
  return named_sibling ~= sibling
end

---Checking if siblings match the conditions
---@param node userdata TSNode instance
---@param named_sibling userdata|nil TSNode instance
---@param sibling userdata|nil TSNode instance
local function is_suitable_nodes(node, named_sibling, sibling)
  if not named_sibling then
    return false
  end

  if check_siblings(node, named_sibling) then
    return (
      not has_unnamed(named_sibling, sibling)
      and has_whitespace_between(node, named_sibling)
    ) or is_allowed_sep(sibling)
  end
end

---Get candidates to swapping
---@param node userdata TSNode instance
---@param side userdata TSNode instance
---@return userdata|nil, userdata|nil
local function get_candidates(node, side)
  if side == LEFT then
    return node:prev_sibling(), node:prev_named_sibling()
  end
  return node:next_sibling(), node:next_named_sibling()
end

function M.get_suitable_siblings(node, side)
  if not node then
    return
  end

  local sibling, named_sibling = get_candidates(node, side)
  local suited = is_suitable_nodes(node, named_sibling, sibling)

  if suited then
    if has_unnamed(named_sibling, sibling) then
      return side == LEFT and { named_sibling, sibling, node }
        or { node, sibling, named_sibling }
    end
    return side == LEFT and { named_sibling, node } or { node, named_sibling }
  else
    return M.get_suitable_siblings(node:parent(), side)
  end
end

---Swapping ranges of nodes and return a table `{ { text: of right node, range: of left node }, { text: of left node, range: of right node } }`
---@param siblings userdata[] TSNode instances
---@param swap_unnamed boolean
---@return table
function M.swap_siblings_ranges(siblings, swap_unnamed)
  local swapped = {}
  for idx = #siblings, 1, -1 do
    local node = siblings[idx]
    local text = get_node_text(siblings[idx], 0)

    if type(text) == 'string' then
      text = vim.split(text, '\n')
    end

    if swap_unnamed and is_allowed_sep(siblings[idx]) then
      text = { ALLOWED_SEPARATORS[text[1]] }
    end

    local reversed_idx = #siblings - idx + 1

    local range = { siblings[reversed_idx]:range() }
    table.insert(swapped, { text = text, range = range, node = node })
  end
  return swapped
end

---Calculate new position for cursor
---@param repl table
---@param side string
---@param cursor? integer[]
---@return table
function M.calc_cursor(repl, side, cursor)
  cursor = cursor or vim.api.nvim_win_get_cursor(0)
  local right_range = repl[#repl].range
  local left_range = repl[1].range

  if side == LEFT then
    local pos_in_node =
      { cursor[1] - right_range[1], cursor[2] - right_range[2] }
    cursor[2] = pos_in_node[2] + left_range[2]
    cursor[1] = pos_in_node[1] + left_range[1]
  else
    if right_range[3] == left_range[3] then -- Ignore change in X when swapping vertically
      cursor[2] = cursor[2] + (right_range[4] - left_range[4])
    end
    cursor[1] = cursor[1] + (right_range[3] - left_range[3])
  end
  return cursor
end

---Calculate new range where node will be placed after swapping
---@param repl table
---@param side string
---@return table
local function calc_new_range(repl, side)
  local range = side == LEFT and repl[#repl].range or repl[1].range
  local sr, sc = range[1] + 1, range[2]
  local er, ec = range[3] + 1, range[4]
  return vim.tbl_flatten({
    -- Need same logic like when new cursor calculating
    M.calc_cursor(repl, side, { sr, sc }),
    M.calc_cursor(repl, side, { er, ec }),
  })
end

local function to_hl(repl, side)
  local sr, sc, er, ec = unpack(calc_new_range(repl, side))
  return { { sr - 1, sc }, { er - 1, ec } }
end

function M.highlight_node_at_cursor(repl, side)
  local opts = settings.highlight_node_at_cursor

  if opts then
    local hl_group = 'SiblingSwapHL'
    local hl_opts = { link = 'IncSearch' }
    local ms = 500

    if type(opts) == 'table' then
      hl_opts = opts.hl_opts or hl_opts
      ms = opts.ms or ms
    end

    vim.api.nvim_set_hl(0, hl_group, hl_opts)

    -- Uses anonymous namespace to avoid conflict with defer_fn
    local ns = vim.api.nvim_create_namespace('')
    local range = to_hl(repl, side)
    vim.highlight.range(0, ns, hl_group, range[1], range[2])

    vim.defer_fn(function()
      vim.api.nvim_buf_clear_namespace(0, ns, 1, -1)
    end, ms)
  end
end

---Get language for node
---@param node TSNode TSNode instance
---@return string
function M.get_node_lang(node)
  local range = { node:range() }
  local buf = vim.api.nvim_get_current_buf()
  local ok, parser = pcall(
    vim.treesitter.get_parser,
    buf,
    vim.treesitter.language.get_lang(vim.bo[buf].ft)
  )
  if not ok then
    return ''
  end
  local current_tree = parser:language_for_range(range)
  return current_tree:lang()
end

return M
