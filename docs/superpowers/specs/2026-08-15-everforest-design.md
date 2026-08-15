# Everforest colorscheme design

## Goal

Replace the current TokyoNight colorscheme with the dark Everforest colorscheme.

## Configuration

- Change only `lua/plugins/colorscheme.lua`.
- Replace the `folke/tokyonight.nvim` plugin specification with `sainnhe/everforest`.
- Keep the existing high plugin priority so the colorscheme loads before normal UI plugins.
- Explicitly set `vim.o.background` to `dark` before applying `everforest`.
- Remove TokyoNight-specific setup.

## Scope

No other plugin modules or unrelated working-tree changes will be modified. Everforest's default dark style will be used without additional customization.

## Verification

Start Neovim headlessly with this configuration and confirm that initialization completes and `vim.g.colors_name` equals `everforest`.
