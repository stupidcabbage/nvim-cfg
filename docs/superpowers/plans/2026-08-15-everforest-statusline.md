# Everforest Statusline Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a high-contrast green Lualine statusline with complete mode, Git, file, diagnostic, format, and cursor information.

**Architecture:** A new focused plugin module owns the Lualine dependency, Everforest-derived colors, layout, and components. The existing plugin aggregator imports that module; no colorscheme or Gitsigns behavior changes.

**Tech Stack:** Neovim Lua, lazy.nvim, nvim-lualine/lualine.nvim, nvim-tree/nvim-web-devicons, Everforest

## Global Constraints

- Preserve all unrelated working-tree changes.
- Do not alter the colorscheme or Gitsigns configuration.
- Use one global bottom statusline with high-contrast green active-mode styling.
- Include mode, Git branch and diff, filename and state, diagnostics, encoding, line endings, file type, progress, and cursor location.

---

### Task 1: Add and verify the Everforest statusline

**Files:**
- Create: `lua/plugins/statusline.lua`
- Modify: `lua/plugins/init.lua:10-19`

**Interfaces:**
- Consumes: lazy.nvim plugin specifications, Lualine's built-in Everforest theme, Neovim diagnostics, and Git state supplied through the existing Git integration.
- Produces: a global Lualine statusline configured through `require('lualine').setup(opts)`.

- [ ] **Step 1: Run the failing behavior check**

Run:

```bash
nvim --headless '+lua assert(package.loaded.lualine, "lualine is not loaded")' +qa
```

Expected: the assertion fails with `lualine is not loaded` because the plugin is not configured yet.

- [ ] **Step 2: Create the statusline plugin module**

Create `lua/plugins/statusline.lua` with:

```lua
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
```

- [ ] **Step 3: Register the plugin module without rewriting the aggregator**

Add this entry directly after `require 'plugins.colorscheme',` in `lua/plugins/init.lua`:

```lua
  require 'plugins.statusline',
```

- [ ] **Step 4: Run the passing behavior check**

Run:

```bash
nvim --headless \
  '+lua assert(package.loaded.lualine, "lualine is not loaded")' \
  '+lua assert(vim.o.laststatus == 3, "statusline is not global")' \
  '+lua local c = require("lualine").get_config(); assert(c.options.globalstatus, "globalstatus is disabled"); assert(#c.sections.lualine_a == 1 and #c.sections.lualine_b == 2 and #c.sections.lualine_c == 1 and #c.sections.lualine_x == 4 and #c.sections.lualine_y == 1 and #c.sections.lualine_z == 1, "required statusline components are missing")' \
  +qa
```

Expected: exit code 0 with no assertion or startup errors.

- [ ] **Step 5: Check formatting and change scope**

Run:

```bash
if command -v stylua >/dev/null 2>&1; then
  stylua --check lua/plugins/statusline.lua lua/plugins/init.lua
fi
git diff --check -- lua/plugins/statusline.lua lua/plugins/init.lua
git diff -- lua/plugins/statusline.lua lua/plugins/init.lua
```

Expected: formatting checks exit 0, the new module contains only the approved Lualine configuration, and the aggregator diff adds only the statusline import on top of its pre-existing user edits.
