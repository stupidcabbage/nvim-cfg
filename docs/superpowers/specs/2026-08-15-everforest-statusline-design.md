# Everforest statusline design

## Goal

Add a high-contrast bottom statusline that presents editing, Git, file, diagnostic, and cursor information while matching the dark Everforest colorscheme.

## Architecture

Use `nvim-lualine/lualine.nvim` in a dedicated `lua/plugins/statusline.lua` plugin module. Register the module through the existing `lua/plugins/init.lua` aggregator. Lualine will consume Neovim state and Git information exposed by its built-in components; the existing Gitsigns plugin remains responsible for buffer Git status.

## Layout

The left side contains:

- Current Vim mode.
- Current Git branch, including branches used with GitLab repositories.
- Git additions, modifications, and deletions.
- Current file path, modified state, and read-only state.

The right side contains:

- Error, warning, information, and hint diagnostic counts.
- File encoding.
- Line-ending format.
- File type.
- Buffer progress.
- Cursor line and column.

## Appearance

- Use the dark Everforest theme as the color foundation.
- Give the active mode segment a high-contrast green background.
- Use section separators compatible with the configured Nerd Font.
- Keep inactive windows visually subdued.
- Display one global statusline at the bottom to avoid duplicated bars in split windows.

## Scope and safety

Create `lua/plugins/statusline.lua` and add one corresponding import to `lua/plugins/init.lua`. Preserve all unrelated working-tree changes, including existing edits in the plugin aggregator. Do not alter the colorscheme or Gitsigns configuration.

## Verification

Start Neovim headlessly and assert that Lualine loads, the global statusline setting is active, and the statusline configuration contains the required mode, branch, diff, filename, diagnostics, encoding, file-format, file-type, progress, and location components. Run formatting and diff checks for the two affected Lua files.
