local u = require('tests.utils')

local PATH_JS = './tests/langs/index.js'
local PATH_HTML = './tests/langs/index.html'

local test_data = {
  {
    desc = 'lang "%s", func "%s", arguments should moved to left',
    path = PATH_JS,
    func = 'swap_with_left',
    lang = 'javascript',
    cursor = { 1, 18 },
    expected = { 1, 2 },
    result = { 0, 1 },
  },
  {
    desc = 'lang "%s", func "%s", arguments should moved to right',
    path = PATH_JS,
    func = 'swap_with_right',
    lang = 'javascript',
    cursor = { 2, 13 },
    expected = { 0, 1 },
    result = { 1, 2 },
  },
  {
    desc = 'lang "%s", func "%s", pair should moved to left',
    path = PATH_JS,
    func = 'swap_with_left',
    lang = 'javascript',
    cursor = { 4, 28 },
    expected = { 4, 5 },
    result = { 3, 4 },
  },
  {
    desc = 'lang "%s", func "%s", pair should moved to right',
    path = PATH_JS,
    func = 'swap_with_right',
    lang = 'javascript',
    cursor = { 5, 16 },
    expected = { 3, 4 },
    result = { 4, 5 },
  },
  {
    desc = 'lang "%s", func "%s", formal_parameters should moved to left',
    path = PATH_JS,
    func = 'swap_with_left',
    lang = 'javascript',
    cursor = { 10, 27 },
    expected = { 16, 22 },
    result = { 9, 15 },
  },
  {
    desc = 'lang "%s", func "%s", formal_parameters should moved to right',
    path = PATH_JS,
    func = 'swap_with_right',
    lang = 'javascript',
    cursor = { 17, 21 },
    expected = { 9, 15 },
    result = { 16, 22 },
  },
  {
    desc = 'lang "%s", func "%s", operand in binary_expression should moved to right',
    path = PATH_JS,
    func = 'swap_with_left',
    lang = 'javascript',
    cursor = { 27, 20 },
    expected = { 27, 28 },
    result = { 26, 27 },
  },
  {
    desc = 'lang "%s", func "%s", operand in binary_expression should moved to right',
    path = PATH_JS,
    func = 'swap_with_right',
    lang = 'javascript',
    cursor = { 28, 15 },
    expected = { 26, 27 },
    result = { 27, 28 },
  },
  {
    desc = 'lang "%s", func "%s", operand in binary_expression should moved to right and change operator to opposite',
    path = PATH_JS,
    func = 'swap_with_left_with_opp',
    lang = 'javascript',
    cursor = { 30, 19 },
    expected = { 30, 31 },
    result = { 29, 30 },
  },
  {
    desc = 'lang "%s", func "%s", operand in binary_expression should moved to right and change operator to opposite',
    path = PATH_JS,
    func = 'swap_with_right_with_opp',
    lang = 'javascript',
    cursor = { 31, 14 },
    expected = { 29, 30 },
    result = { 30, 31 },
  },
  -- {
  --   desc = 'lang "%s", func "%s", on lexical_declaration identifier, should do nothing',
  --   path = PATH_JS,
  --   func = 'swap_with_left',
  --   lang = 'javascript',
  --   cursor = { 33, 5 },
  --   expected = { 32, 33 },
  --   result = { 32, 33 },
  -- },
  -- {
  --   desc = 'lang "%s", func "%s", on lexical_declaration value, should do nothing',
  --   path = PATH_JS,
  --   func = 'swap_with_left',
  --   lang = 'javascript',
  --   cursor = { 33, 12 },
  --   expected = { 32, 33 },
  --   result = { 32, 33 },
  -- },
  -- {
  --   desc = 'lang "%s", func "%s", on expression_statement, should do nothing',
  --   path = PATH_JS,
  --   func = 'swap_with_left',
  --   lang = 'javascript',
  --   cursor = { 35, 10 },
  --   expected = { 34, 35 },
  --   result = { 34, 35 },
  -- },
  {
    desc = 'lang "%s", func "%s", on expression_statement, should do nothing',
    path = PATH_JS,
    func = 'swap_with_right',
    lang = 'javascript',
    cursor = { 35, 10 },
    expected = { 34, 35 },
    result = { 34, 35 },
  },
  {
    desc = 'lang "%s", func "%s", on expression_statement, should do nothing',
    path = PATH_HTML,
    func = 'swap_with_right',
    lang = 'html',
    cursor = { 1, 15 },
    expected = { 1, 2 },
    result = { 0, 1 },
  },
  {
    desc = 'lang "%s", func "%s", on expression_statement, should do nothing',
    path = PATH_HTML,
    func = 'swap_with_left',
    lang = 'html',
    cursor = { 2, 23 },
    expected = { 0, 1 },
    result = { 1, 2 },
  },
}

describe('Sibling-swap: ', function()
  for _, value in ipairs(test_data) do
    u._test(value)
  end
end)
