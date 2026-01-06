return {
  'nvimdev/dashboard-nvim',
  event = 'VimEnter',
  config = function()
    require('dashboard').setup {
      theme = 'doom',
      config = {
        header = {
          '',
          '',
          '  ███████╗████████╗██╗   ██╗██████╗ ██╗██████╗ ',
          '  ██╔════╝╚══██╔══╝██║   ██║██╔══██╗██║██╔══██╗',
          '  ███████╗   ██║   ██║   ██║██████╔╝██║██║  ██║',
          '  ╚════██║   ██║   ██║   ██║██╔═══╝ ██║██║  ██║',
          '  ███████║   ██║   ╚██████╔╝██║     ██║██████╔╝',
          '  ╚══════╝   ╚═╝    ╚═════╝ ╚═╝     ╚═╝╚═════╝ ',
          '                                                ',
          '   ██████╗ █████╗ ██████╗ ██████╗  █████╗  ██████╗ ███████╗',
          '  ██╔════╝██╔══██╗██╔══██╗██╔══██╗██╔══██╗██╔════╝ ██╔════╝',
          '  ██║     ███████║██████╔╝██████╔╝███████║██║  ███╗█████╗  ',
          '  ██║     ██╔══██║██╔══██╗██╔══██╗██╔══██║██║   ██║██╔══╝  ',
          '  ╚██████╗██║  ██║██████╔╝██████╔╝██║  ██║╚██████╔╝███████╗',
          '   ╚═════╝╚═╝  ╚═╝╚═════╝ ╚═════╝ ╚═╝  ╚═╝ ╚═════╝ ╚══════╝',
          '',
        },
        center = {
          { icon = '  ', desc = 'Find File       ', key = 'f', action = 'Telescope find_files' },
          { icon = '  ', desc = 'Recent Files    ', key = 'r', action = 'Telescope oldfiles' },
          { icon = '  ', desc = 'Live Grep       ', key = 'g', action = 'Telescope live_grep' },
          { icon = '  ', desc = 'File Browser    ', key = 'e', action = 'Telescope file_browser' },
          { icon = '  ', desc = 'Config          ', key = 'c', action = 'edit ~/.config/nvim/init.lua' },
          { icon = '󰒲  ', desc = 'Lazy            ', key = 'l', action = 'Lazy' },
          { icon = '  ', desc = 'Quit            ', key = 'q', action = 'quit' },
        },
        footer = function()
          local stats = require('lazy').stats()
          local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
          return {
            '',
            '⚡ ' .. stats.loaded .. '/' .. stats.count .. ' plugins in ' .. ms .. 'ms',
            '🥬 Stupid like a cabbage, smart like a code 🥬',
          }
        end,
      },
    }
  end,
  dependencies = { { 'nvim-tree/nvim-web-devicons' } },
}
