local M = {}

local a = vim.api

local function open_ang_get_buf(path)
  vim.cmd(':e ' .. path)
  return a.nvim_get_current_buf()
end

function M._test(v, opts)
  local swaper = require('sibling-swap')
  swaper.setup(opts)
  local desc = v.desc:format(v.lang, v.func)

  it(desc, function()
    local bufnf = open_ang_get_buf(v.path)
    local expected =
      a.nvim_buf_get_lines(bufnf, v.expected[1], v.expected[2], true)
    a.nvim_win_set_cursor(0, v.cursor)

    swaper[v.func]()

    local result = a.nvim_buf_get_lines(bufnf, v.result[1], v.result[2], true)
    a.nvim_buf_delete(bufnf, { force = true })
    assert.are.same(expected, result)
  end)
end

return M
