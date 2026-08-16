return {
  'folke/trouble.nvim',
  lazy = false,
  opts = {
    auto_close = false,
    auto_open = false,
    auto_preview = true,
    auto_refresh = true,
    focus = false,
    follow = true,
    multiline = true,
    win = { type = 'split', position = 'bottom', size = 12 },
  },
  keys = {
    { '<leader>xx', '<cmd>Trouble diagnostics toggle<cr>', desc = 'Workspace Diagnostics' },
    { '<leader>xb', '<cmd>Trouble diagnostics toggle filter.buf=0<cr>', desc = 'Buffer Diagnostics' },
    { '<leader>xq', '<cmd>Trouble qflist toggle<cr>', desc = 'Quickfix List' },
    {
      '<leader>xd',
      function()
        vim.diagnostic.open_float(nil, { border = 'rounded', focusable = true, scope = 'cursor', source = 'if_many' })
      end,
      desc = 'Diagnostic Details',
    },
  },
}
