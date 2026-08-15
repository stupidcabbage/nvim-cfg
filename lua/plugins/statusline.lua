return {
  'nvim-lualine/lualine.nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  opts = function()
    local theme = require 'lualine.themes.everforest'
    local green = { bg = '#a7c080', fg = '#2d353b', gui = 'bold' }

    for _, mode in ipairs { 'normal', 'insert', 'visual', 'replace', 'command', 'terminal' } do
      if theme[mode] then
        theme[mode].a = green
      end
    end

    return {
      options = {
        theme = theme,
        globalstatus = true,
        section_separators = { left = '', right = '' },
        component_separators = { left = '', right = '' },
      },
      sections = {
        lualine_a = { 'mode' },
        lualine_b = { 'branch', 'diff' },
        lualine_c = {
          {
            'filename',
            path = 1,
            symbols = {
              modified = ' ●',
              readonly = ' ',
              unnamed = '[No Name]',
              newfile = '[New]',
            },
          },
        },
        lualine_x = { 'diagnostics', 'encoding', 'fileformat', 'filetype' },
        lualine_y = { 'progress' },
        lualine_z = { 'location' },
      },
    }
  end,
}
