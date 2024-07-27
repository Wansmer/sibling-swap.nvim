local M = {}

---Convert list-like table to dict-like table
---@param tbl table
---@return table
local function convert_to_dict(tbl)
  local result = {}
  for key, value in pairs(tbl) do
    if type(key) == 'number' then
      result[value] = value
    else
      result[key] = value
    end
  end
  return result
end

---Remove disabled separators from 'allowed_separators'
---@param seps table Dict with allowed separators
---@return table
local function skip_disabled(seps)
  local result = {}
  for key, val in pairs(seps) do
    if val then
      result[key] = val
    end
  end
  return result
end

---@class FallbackItem
---@field enable boolean|function(node: TSNode): boolean
---@field action function(node: TSNode, side: string): void

---User options to `sibling-swap.nvim`
---@class UserOpts
---@field use_default_keymaps boolean
---@field allowed_separators table<string, string>
---@field ignore_injected_langs boolean
---@field allow_interline_swaps boolean
---@field interline_swaps_without_separator boolean
---@field highlight_node_at_cursor boolean
---@field keymaps table<string, string>
---@field fallback table<string, table<string, FallbackItem>>
local DEFAUTL_SETTINGS = {
  use_default_keymaps = true,
  allowed_separators = convert_to_dict({
    ',',
    ';',
    'and',
    'or',
    '&&',
    '&',
    '||',
    '|',
    '==',
    '===',
    '!=',
    '!==',
    '-',
    '+',
    '..',
    ['<'] = '>',
    ['<='] = '>=',
    ['>'] = '<',
    ['>='] = '<=',
  }),
  ignore_injected_langs = false,
  allow_interline_swaps = true,
  interline_swaps_without_separator = false,
  highlight_node_at_cursor = false,
  keymaps = {
    ['<C-.>'] = 'swap_with_right',
    ['<C-,>'] = 'swap_with_left',
    ['<space>.'] = 'swap_with_right_with_opp',
    ['<space>,'] = 'swap_with_left_with_opp',
  },
  fallback = {},
}

---@type UserOpts
M.settings = DEFAUTL_SETTINGS

M._set_keymaps = function()
  for keymap, action in pairs(M.settings.keymaps) do
    vim.keymap.set(
      'n',
      keymap,
      require('sibling-swap')[action],
      { desc = 'sibling-swap: ' .. action }
    )
  end
end

---Merge user options with default
---@param opts UserOpts
M._update_settings = function(opts)
  opts = opts or {}

  if opts.interline_swaps_witout_separator ~= nil then
    opts.interline_swaps_without_separator =
      opts.interline_swaps_witout_separator
    opts.interline_swaps_witout_separator = nil

    vim.schedule(function()
      vim.notify_once(
        'Option `interline_swaps_witout_separator` is deprecated (typo). Use `interline_swaps_without_separator` instead',
        vim.log.levels.WARN,
        { title = 'sibling-swap.nvim' }
      )
    end)
  end

  local seps = opts.allowed_separators
  if seps and not vim.tbl_isempty(seps) then
    opts.allowed_separators = convert_to_dict(seps)
  end

  M.settings = vim.tbl_deep_extend('force', DEFAUTL_SETTINGS, opts)

  M.settings.allowed_separators = skip_disabled(M.settings.allowed_separators)

  if M.settings.use_default_keymaps then
    M._set_keymaps()
  end
end

return M
