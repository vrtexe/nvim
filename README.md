# nvim

A Neovim 0.12 configuration in Lua that works as an IDE for Java, Go, Rust, TypeScript, Svelte and Python. It has language servers, debugging and test runners, and four keymap modes you can switch at runtime: classic, consistent, VS Code and IntelliJ.

## Install

```sh
git clone https://github.com/vrtexe/nvim ~/.config/nvim
brew install lazygit ripgrep fd stylua
nvim
```

On first start, lazy.nvim installs the plugins (versions pinned in `lazy-lock.json`). Mason then installs the language servers, debug adapters, formatters and linters. Two tools need a manual step:

- Rust: `rustup component add rust-analyzer`
- Java tests: run `:NeotestJava setup` once to download the JUnit runner.

Node.js must be on `PATH` for the npm-based servers.

## What it includes

| Area | Plugins |
|---|---|
| Plugin manager | lazy.nvim |
| Language servers | nvim-lspconfig, mason.nvim, nvim-jdtls (Java), rustaceanvim (Rust) |
| Completion | blink.cmp |
| Formatting and linting | conform.nvim, nvim-lint |
| Debugging | nvim-dap, nvim-dap-ui (codelldb, delve, java-debug, js-debug) |
| Tests and tasks | neotest (Jest, Go, Java, Rust), overseer.nvim |
| Finding and navigation | snacks.nvim picker, flash.nvim, harpoon, aerial.nvim, neo-tree.nvim |
| Git | gitsigns.nvim, lazygit.nvim, diffview.nvim |
| UI | github-nvim-theme, lualine, bufferline, which-key, barbecue |
| AI | claudecode.nvim (Copilot is configured but disabled) |

The plugin specs live in `lua/plugins/`, one file per job.

## Keymaps

`<leader>` is Space. Switch the keymap mode with `:KeymapMode <classic|consistent|vscode|intellij>`. The choice is saved and survives restarts; the default is `classic`. All four modes share one `<leader>` tree and one `g` family, so only the IDE-style shortcuts differ between them.

- [docs/keybindings.md](docs/keybindings.md): every binding, per mode.
- [WALKTHROUGH.md](WALKTHROUGH.md): a tour from opening a project to committing.
- [docs/ghostty-keybinds.md](docs/ghostty-keybinds.md): forwarding Cmd shortcuts from Ghostty.

## Use inside VS Code

With the vscode-neovim extension, `init.lua` loads only the options and autocommands from `lua/core/`; it skips the plugins and the keymap modes. [docs/vscode-keybindings.md](docs/vscode-keybindings.md) maps the same actions to VS Code commands.

## Checks

```sh
scripts/healthcheck.sh   # every plugin spec loads; plugins stay off under VS Code
scripts/keymaps_test.sh  # keymap modes apply, switch and contain no duplicate keys
scripts/smoke.sh         # full load, LSP, DAP adapters and per-language checks
```
