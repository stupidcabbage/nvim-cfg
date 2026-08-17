# Python Ruff Diagnostics Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add project-configured Ruff diagnostics and a readable bottom diagnostics panel.

**Architecture:** The existing LSP module registers Mason-managed Ruff alongside Pyright without Ruff-specific settings, which preserves Ruff's nearest-project configuration discovery. A dedicated Trouble module owns the wrapped diagnostics and quickfix UI.

**Tech Stack:** Neovim Lua, nvim-lspconfig, Mason, Ruff, Pyright, Trouble.nvim

## Global Constraints

- Preserve unrelated working-tree changes.
- Do not modify project-level `pyproject.toml` files.
- Ruff must read the nearest project configuration without editor-provided overrides.
- Keep Pyright enabled alongside Ruff.
- Provide a bottom, multi-line diagnostics and quickfix panel with all four approved keymaps.

---

### Task 1: Register Ruff and compact inline diagnostics

**Files:**

- Modify: `lua/plugins/lsp.lua:70-154`

**Interfaces:**

- Consumes: Mason, nvim-lspconfig, and Neovim diagnostics.
- Produces: `ruff = {}`, Mason-managed Ruff, no Autoflake, and inline diagnostic text capped at 80 characters.

- [ ] **Step 1: Confirm the current configuration lacks Ruff**

Run `rg -n "ruff = \{\}|^\s*'ruff'" lua/plugins/lsp.lua`.

Expected: no output; existing configuration contains neither the LSP entry nor the Mason package.

- [ ] **Step 2: Add the inline-message formatter**

Insert before `vim.diagnostic.config`:

```lua
    local function inline_diagnostic_message(diagnostic)
      local message = diagnostic.message:gsub('\n', ' ')
      local max_length = 80

      if #message > max_length then
        return message:sub(1, max_length - 1) .. '…'
      end

      return message
    end
```

Replace the existing `virtual_text.format` function with `format = inline_diagnostic_message,`.

- [ ] **Step 3: Configure Ruff**

Directly after `pyright = {},` add `ruff = {},`. In the Mason installer list, replace `'autoflake',` with `'ruff',`. Do not set a command, settings, or initialization options for Ruff.

- [ ] **Step 4: Verify Ruff configuration**

Run:

```bash
nvim --headless '+lua local text = table.concat(vim.fn.readfile(vim.fn.stdpath("config") .. "/lua/plugins/lsp.lua"), "\\n"); assert(text:find("ruff = {}", 1, true)); assert(text:find("\'ruff\'", 1, true)); assert(not text:find("\'autoflake\'", 1, true)); assert(text:find("local max_length = 80", 1, true))' +qa
```

Expected: exit code 0.

### Task 2: Add Trouble diagnostics and navigation

**Files:**

- Create: `lua/plugins/trouble.lua`
- Modify: `lua/plugins/init.lua:10-20`
- Modify: `lua/plugins/whichkey.lua:40-48`

**Interfaces:**

- Consumes: Neovim diagnostics and quickfix entries.
- Produces: a bottom, multi-line Trouble split and `<leader>x` mappings.

- [ ] **Step 1: Confirm Trouble has no existing module**

Run `test ! -f lua/plugins/trouble.lua`.

Expected: exit code 0.

- [ ] **Step 2: Create `lua/plugins/trouble.lua`**

```lua
return {
  'folke/trouble.nvim',
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
```

- [ ] **Step 3: Register the module and group**

Add `require 'plugins.trouble',` immediately after `require 'plugins.statusline',` in the plugin aggregator. Add `{ '<leader>x', group = 'Diagnostics' },` immediately after the existing `<leader>t` group in Which-Key.

- [ ] **Step 4: Verify loading and mappings**

Run:

```bash
nvim --headless '+lua assert(package.loaded.trouble); local c = require("trouble.config").options; assert(c.multiline and c.win.position == "bottom" and c.win.size == 12); for _, k in ipairs({"<leader>xx", "<leader>xb", "<leader>xq", "<leader>xd"}) do assert(vim.fn.maparg(k, "n") ~= "", k) end' +qa
```

Expected: exit code 0.

- [ ] **Step 5: Check scope**

Run `git diff --check -- lua/plugins/lsp.lua lua/plugins/trouble.lua lua/plugins/init.lua lua/plugins/whichkey.lua` and inspect the diff.

Expected: no whitespace errors and only the approved Ruff, Trouble, importer, and Which-Key changes.
