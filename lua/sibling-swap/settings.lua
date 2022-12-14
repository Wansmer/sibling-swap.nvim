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

local DEFAUTL_SETTINGS = {
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
    ['<'] = '>',
    ['<='] = '>=',
    ['>'] = '<',
    ['>='] = '<=',
  }),
  use_default_keymaps = true,
  keymaps = {
    ['<C-.>'] = 'swap_with_right',
    ['<C-,>'] = 'swap_with_left',
    ['<space>.'] = 'swap_with_right_with_opp',
    ['<space>,'] = 'swap_with_left_with_opp',
  },
  ignore_injected_langs = false,
}

M.settings = DEFAUTL_SETTINGS

M._set_keymaps = function()
  for keymap, action in pairs(M.settings.keymaps) do
    vim.keymap.set('n', keymap, require('sibling-swap')[action])
  end
end

M._update_settings = function(opts)
  opts = opts or {}

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
