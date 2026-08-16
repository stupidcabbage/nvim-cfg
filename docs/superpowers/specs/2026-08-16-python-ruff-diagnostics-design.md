# Python Ruff diagnostics design

## Goal

Provide Poetry-friendly Python lint diagnostics in Neovim and a readable, persistent place to inspect long messages.

## Linting architecture

Run Ruff's built-in language server from the Mason-managed `ruff` package alongside the existing Pyright language server. Ruff will be configured without editor-specific overrides, so it automatically discovers and applies the nearest project `pyproject.toml`, `ruff.toml`, or `.ruff.toml` file. This preserves each Poetry project's lint policy without requiring Neovim to start through `poetry run`.

Pyright continues to provide type checking, completion, navigation, and other Python language features. Ruff provides lint diagnostics, code actions, import organization, and formatting integration. Remove the obsolete `autoflake` Mason tool because it is neither an LSP server nor needed alongside Ruff.

## Diagnostics experience

Add `folke/trouble.nvim` as a bottom split for diagnostics and quickfix results. Configure diagnostic rows to wrap long messages and retain filename, position, severity, and source. The split should be wide enough for practical reading and remain easy to toggle.

Keep in-buffer diagnostic text compact: truncate only the inline rendering, not the diagnostic itself. Users can access the complete message through Trouble or a rounded diagnostic popup.

## Keymaps

- `<leader>xx`: toggle workspace diagnostics in Trouble.
- `<leader>xb`: toggle diagnostics for the current buffer in Trouble.
- `<leader>xq`: toggle quickfix results in Trouble.
- `<leader>xd`: show the diagnostic under the cursor in a rounded, focusable popup.

## Scope and safety

Modify `lua/plugins/lsp.lua`; create `lua/plugins/trouble.lua`; add the Trouble module to `lua/plugins/init.lua`; and extend the Which-Key grouping in `lua/plugins/whichkey.lua`. Preserve all unrelated working-tree changes. Do not modify project-level `pyproject.toml` files.

## Verification

Start Neovim headlessly and assert that Ruff and Pyright LSP configurations are registered, Mason is instructed to install Ruff but not Autoflake, Trouble loads, its diagnostic and quickfix modes are configured, the four keymaps exist, and the virtual-text formatter truncates long display text. Check whitespace and verify the final diff touches only the approved configuration files.
