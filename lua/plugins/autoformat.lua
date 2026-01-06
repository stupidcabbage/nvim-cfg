return {
  'stevearc/conform.nvim',
  event = { 'BufWritePre' },
  cmd = { 'ConformInfo' },
  keys = {
    {
      '<leader>f',
      function()
        require('conform').format { async = true, lsp_format = 'fallback' }
      end,
      mode = '',
      desc = '[F]ormat buffer',
    },
  },
  opts = {
    notify_on_error = false,

    -- Автоформат при сохранении
    format_on_save = function(bufnr)
      -- Отключаем автоформат для C/C++ (можно добавить другие языки)
      local disable_filetypes = { c = true, cpp = true }

      if disable_filetypes[vim.bo[bufnr].filetype] then
        return nil
      else
        return {
          timeout_ms = 500,
          lsp_format = 'fallback',
        }
      end
    end,

    formatters_by_ft = {
      lua = { 'stylua' },
      cpp = { 'clang-format' },
      python = { 'ruff_format', 'ruff_organize_imports' },
      yaml = { 'prettier' },
      sql = { 'sql_formatter' },
      go = { 'gofmt', 'goimports' },

      javascript = { 'prettier', stop_after_first = true },
      typescript = { 'prettier', stop_after_first = true },
    },

    -- Дополнительная настройка для ruff
    formatters = {
      ruff_format = {
        command = 'ruff',
        args = { 'format', '--force-exclude', '--stdin-filename', '$FILENAME', '-' },
      },
      ruff_organize_imports = {
        command = 'ruff',
        args = { 'check', '--select', 'I', '--fix', '--force-exclude', '--stdin-filename', '$FILENAME', '-' },
      },
    },
  },
}
