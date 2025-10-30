return {
  'akinsho/toggleterm.nvim',
  version = '*',
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

    -- Маппинг: <leader>tn — создать новый терминал
    vim.api.nvim_set_keymap('n', '<leader>tn', '<cmd>ToggleTerm<cr>', { noremap = true, silent = true })

    -- Маппинг в терминальном режиме: <leader>tv — выйти и перейти в визуальный режим
    vim.api.nvim_set_keymap('t', '<leader>tv', '<C-\\><C-n>vh', { noremap = true, silent = true })
  end,
}
