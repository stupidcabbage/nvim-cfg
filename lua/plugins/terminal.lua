return {
  'akinsho/toggleterm.nvim',
  version = '*',
  cmd = 'ToggleTerm',
  keys = {
    { '<leader>tn', '<cmd>ToggleTerm<cr>', desc = '[T]erminal [N]ew' },
    { '<leader>tv', '<C-\\><C-n>vh', mode = 't', desc = '[T]erminal [V]isual mode' },
  },
  config = function()
    require('toggleterm').setup {
      size = 20,
      hide_numbers = true,
      shade_filetypes = {},
      shade_terminals = true,
      shading_factor = 2,
      start_in_insert = true,
      insert_mappings = true,
      terminal_mappings = true,
      persist_size = true,
      close_on_exit = true,

      -- Убираем дефолтные маппинги, чтобы не мешали
      keymaps = {},
    }
  end,
}
