# Everforest Colorscheme Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace TokyoNight with the dark Everforest colorscheme in Neovim.

**Architecture:** Keep colorscheme ownership in the existing focused plugin module. Lazy.nvim installs Everforest at high priority, and the module explicitly selects a dark background before applying the colorscheme.

**Tech Stack:** Neovim Lua, lazy.nvim, sainnhe/everforest

## Global Constraints

- Change only `lua/plugins/colorscheme.lua`.
- Preserve unrelated working-tree changes.
- Use Everforest's default dark style without additional customization.

---

### Task 1: Replace and verify the colorscheme

**Files:**
- Modify: `lua/plugins/colorscheme.lua`

**Interfaces:**
- Consumes: lazy.nvim plugin specification format and Neovim's `vim.o.background` option.
- Produces: an active colorscheme whose `vim.g.colors_name` is `everforest`.

- [ ] **Step 1: Verify the current configuration does not select Everforest**

Run:

```bash
nvim --headless '+lua assert(vim.g.colors_name == "everforest", "expected everforest, got " .. tostring(vim.g.colors_name))' +qa
```

Expected: non-zero exit with `expected everforest, got tokyonight-day`.

- [ ] **Step 2: Replace the plugin specification**

Set `lua/plugins/colorscheme.lua` to:

```lua
return {
  'sainnhe/everforest',
  priority = 1000,
  config = function()
    vim.o.background = 'dark'
    vim.cmd.colorscheme 'everforest'
  end,
}
```

- [ ] **Step 3: Verify Everforest loads**

Run:

```bash
nvim --headless '+lua assert(vim.o.background == "dark")' '+lua assert(vim.g.colors_name == "everforest", "expected everforest, got " .. tostring(vim.g.colors_name))' +qa
```

Expected: exit code 0 with no assertion or startup errors.

- [ ] **Step 4: Check formatting and scope**

Run:

```bash
stylua --check lua/plugins/colorscheme.lua
git diff --check -- lua/plugins/colorscheme.lua
git diff -- lua/plugins/colorscheme.lua
```

Expected: both checks exit 0, and the diff shows only the intended TokyoNight-to-Everforest replacement.
