local u = require('tests.utils')

local PATH_JS = './tests/langs/index.js'
local PATH_HTML = './tests/langs/index.html'

local opts = {
  interline_swaps_without_separator = true,
}

local test_data = {
  {
    desc = 'lang "%s", func "%s", arguments should moved down',
    path = PATH_JS,
    func = 'swap_with_right',
    lang = 'javascript',
    cursor = { 38, 4 },
    expected = { 40, 44 },
    result = { 36, 40 },
  },
  {
    desc = 'lang "%s", func "%s", arguments should moved up',
    path = PATH_JS,
    func = 'swap_with_left',
    lang = 'javascript',
    cursor = { 43, 4 },
    expected = { 36, 40 },
    result = { 40, 44 },
  },
  {
    desc = 'lang "%s", func "%s", pair should moved down',
    path = PATH_JS,
    func = 'swap_with_right',
    lang = 'javascript',
    cursor = { 47, 8 },
    expected = { 49, 53 },
    result = { 45, 49 },
  },
  {
    desc = 'lang "%s", func "%s", pair should moved up',
    path = PATH_JS,
    func = 'swap_with_left',
    lang = 'javascript',
    cursor = { 52, 8 },
    expected = { 45, 49 },
    result = { 49, 53 },
  },
  {
    desc = 'lang "%s", func "%s", on attribute, should moved down',
    path = PATH_HTML,
    func = 'swap_with_right',
    lang = 'html',
    cursor = { 5, 4 },
    expected = { 8, 13 },
    result = { 3, 8 },
  },
  {
    desc = 'lang "%s", func "%s", on expression_statement, should do nothing',
    path = PATH_HTML,
    func = 'swap_with_left',
    lang = 'html',
    cursor = { 11, 3 },
    expected = { 3, 8 },
    result = { 8, 13 },
  },
}

describe('Sibling-swap: ', function()
  for _, value in ipairs(test_data) do
    u._test(value, opts)
  end
end)
