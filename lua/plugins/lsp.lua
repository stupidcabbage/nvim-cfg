return {
  'neovim/nvim-lspconfig',
  event = { 'BufReadPre', 'BufNewFile' },
  dependencies = {
    { 'mason-org/mason.nvim', opts = {} },
    'mason-org/mason-lspconfig.nvim',
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    { 'j-hui/fidget.nvim', opts = {} },
    'hrsh7th/cmp-nvim-lsp', -- ЗАМЕНИЛ blink.cmp на cmp-nvim-lsp
  },
  config = function()
    -- Твои хоткеи и автокоманды остаются БЕЗ ИЗМЕНЕНИЙ
    vim.api.nvim_create_autocmd('LspAttach', {
      group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
      callback = function(event)
        local map = function(keys, func, desc, mode)
          mode = mode or 'n'
          vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
        end
        map('K', vim.lsp.buf.hover, 'Hover Documentation')
        map('<C-k>', vim.lsp.buf.signature_help, 'Signature Help') -- показывает сигнатуру функции при вводе параметров
        map('grn', vim.lsp.buf.rename, '[R]e[n]ame')
        map('gra', vim.lsp.buf.code_action, '[G]oto Code [A]ction', { 'n', 'x' })
        map('grr', function()
          require('telescope.builtin').lsp_references()
        end, '[G]oto [R]eferences')
        map('gri', function()
          require('telescope.builtin').lsp_implementations()
        end, '[G]oto [I]mplementation')
        map('grd', function()
          require('telescope.builtin').lsp_definitions()
        end, '[G]oto [D]efinition')
        map('grD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
        map('gO', function()
          require('telescope.builtin').lsp_document_symbols()
        end, 'Open Document Symbols')
        map('gW', function()
          require('telescope.builtin').lsp_dynamic_workspace_symbols()
        end, 'Open Workspace Symbols')
        map('grt', function()
          require('telescope.builtin').lsp_type_definitions()
        end, '[G]oto [T]ype Definition')

        local function client_supports_method(client, method, bufnr)
          if vim.fn.has 'nvim-0.11' == 1 then
            return client:supports_method(method, bufnr)
          else
            return client.supports_method(method, { bufnr = bufnr })
          end
        end

        local client = vim.lsp.get_client_by_id(event.data.client_id)
        if client and client.name == 'ruff' then
          -- Pyright provides richer hover information; keep Ruff focused on linting and code actions.
          client.server_capabilities.hoverProvider = false
        end

        if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf) then
          local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
          vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
            buffer = event.buf,
            group = highlight_augroup,
            callback = vim.lsp.buf.document_highlight,
          })
          vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
            buffer = event.buf,
            group = highlight_augroup,
            callback = vim.lsp.buf.clear_references,
          })
          vim.api.nvim_create_autocmd('LspDetach', {
            group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
            callback = function(event2)
              vim.lsp.buf.clear_references()
              vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
            end,
          })
        end

        if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
          map('<leader>th', function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
          end, '[T]oggle Inlay [H]ints')
        end
      end,
    })

    local function inline_diagnostic_message(diagnostic)
      local message = diagnostic.message:gsub('\n', ' ')
      local max_length = 80

      if vim.fn.strchars(message) > max_length then
        return vim.fn.strcharpart(message, 0, max_length - 1) .. '…'
      end

      return message
    end

    vim.diagnostic.config {
      severity_sort = true,
      float = { border = 'rounded', source = 'if_many' },
      underline = { severity = vim.diagnostic.severity.ERROR },
      signs = vim.g.have_nerd_font and {
        text = {
          [vim.diagnostic.severity.ERROR] = '󰅚 ',
          [vim.diagnostic.severity.WARN] = '󰀪 ',
          [vim.diagnostic.severity.INFO] = '󰋽 ',
          [vim.diagnostic.severity.HINT] = '󰌶 ',
        },
      } or {},
      virtual_text = {
        source = 'if_many',
        spacing = 2,
        format = inline_diagnostic_message,
      },
    }

    -- ЗДЕСЬ ГЛАВНОЕ ИЗМЕНЕНИЕ: меняем blink на cmp
    local capabilities = require('cmp_nvim_lsp').default_capabilities()

    -- ДОБАВЛЯЕМ YAML и SQL серверы
    local servers = {
      clangd = {
        cmd = { 'clangd', '--background-index', '--clang-tidy', '--completion-style=detailed', '--header-insertion=iwyu', '--std=c++26' },
        settings = {
          clangd = {
            fallbackFlags = { '-std=c++26' },
          },
        },
      },
      gopls = {},
      pyright = {
        settings = {
          pyright = {
            -- Ruff already owns the organize-imports code action.
            disableOrganizeImports = true,
          },
        },
      },
      ruff = {
        init_options = {
          settings = {
            -- Avoid routine startup messages in the Neovim LSP log.
            logLevel = 'warn',
          },
        },
      },

      -- ДОБАВИЛ для YAML/K8s
      yamlls = {
        settings = {
          yaml = {
            schemas = {
              kubernetes = '*.yaml',
              ['http://json.schemastore.org/github-workflow'] = '.github/workflows/*',
              ['http://json.schemastore.org/kustomization'] = 'kustomization.yaml',
            },
            format = { enable = true },
            validate = true,
            completion = true,
          },
        },
      },

      -- Helm Language Server
      helm_ls = {
        settings = {
          ['helm-ls'] = {
            yamlls = {
              path = 'yaml-language-server',
            },
          },
        },
      },

      -- ДОБАВИЛ для SQL
      sqlls = {},

      lua_ls = {
        settings = {
          Lua = {
            completion = {
              callSnippet = 'Replace',
            },
          },
        },
      },
    }

    local server_names = vim.tbl_keys(servers)
    local ensure_installed = vim.deepcopy(server_names)
    vim.list_extend(ensure_installed, {
      'stylua', -- Lua formatter
    })

    require('mason-tool-installer').setup { ensure_installed = ensure_installed }

    for server_name, server in pairs(servers) do
      server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
      vim.lsp.config(server_name, server)
    end

    require('mason-lspconfig').setup {
      ensure_installed = {},
      automatic_enable = false,
    }

    vim.lsp.enable(server_names)
  end,
}
