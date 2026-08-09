# Ghostty Keybindings for Neovim

This document provides a snippet for configuring Ghostty to forward Cmd key combinations to Neovim, enabling IDE-like keybindings in the terminal.

## Ghostty Configuration

Add the following lines to `~/.config/ghostty/config`:

```
macos-option-as-alt = true
keybind = cmd+shift+n=text:\x1b[110;9u
keybind = cmd+e=text:\x1b[101;9u
```

## Neovim Keymaps

The corresponding Neovim keymaps are configured to decode the CSI-u sequences that Ghostty forwards for Cmd combinations. These maps should be added to `lua/core/keymaps.lua` behind `if not vim.g.vscode` or in a terminal-only configuration file:

```lua
-- decode the CSI-u sequences Ghostty forwards for Cmd combos
vim.keymap.set("n", "<C-S-n>", "<cmd>Telescope find_files<cr>", { desc = "File lookup (Cmd+Shift+N)" })
vim.keymap.set("n", "<C-e>", "<cmd>Telescope find_files<cr>", { desc = "File lookup (Cmd+E)" })
```

## Important Notes

- **Escape Mapping Variation**: The exact escape sequence (`\x1b[110;9u` for Cmd+Shift+N) depends on your Ghostty version. If the keybinding doesn't work as expected, check your Ghostty version documentation or test with alternatives.
- **Fallback**: If terminal-based Cmd forwarding doesn't work reliably, the `<leader>ff` (fzf.lua or Telescope fallback) keybinding always works within Neovim regardless of terminal configuration.
