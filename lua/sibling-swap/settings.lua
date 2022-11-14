local M = {}

local DEFAUTL_SETTINGS = {
  ignore_injected_langs = false,
  allowed_separators = { ',', ';' },
  use_default_keymaps = true,
  keymaps = {
    ['<C-.>'] = 'swap_with_right',
    ['<C-,>'] = 'swap_with_left',
  }
}

M.settings = DEFAUTL_SETTINGS

M._set_keymaps = function()
  for keymap, action in pairs(M.settings.keymaps) do
    vim.keymap.set('n', keymap, require('sibling-swap')[action])
  end
end

M._update_settings = function(opts)
  opts = opts or {}
  M.settings = vim.tbl_deep_extend('force', DEFAUTL_SETTINGS, opts)
  if M.settings.use_default_keymaps then
    M._set_keymaps()
  end
end

return M
