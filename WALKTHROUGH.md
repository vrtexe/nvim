# WALKTHROUGH

An end-to-end tour of this Neovim IDE config, from first launch to committing your work. `<leader>` is **Space**. Every binding below was read directly out of the committed Lua files (`lua/core/keymaps.lua`, `lua/plugins/*.lua`) — nothing here is guessed.

This config has two homes:
- **Terminal Neovim** (Ghostty, iTerm, etc.) — the full IDE: 49 plugins, theme, LSP, DAP, git UI, everything below.
- **VS Code** (via the `vscode-neovim` extension) — a guard in `init.lua` (`if not vim.g.vscode then require("config.lazy") end`) skips *all* plugins here. You only get `core/options.lua` + `core/keymaps.lua`: clipboard, line-move, search-clear. VS Code's own keybindings.json (see `docs/vscode-keybindings.md`) covers the rest in that context.

Everything from here down describes the **terminal** home.

---

## Keybinding cheatsheet

| Key | Action |
|---|---|
| `<leader>fr` | Recent files (open a project) |
| `<leader>ff` | Find files |
| `<leader><leader>` | Find files ("search everywhere") |
| `<leader>fg` | Live grep |
| `<leader>o` | Outline (Aerial) |
| `<leader>ha` / `<leader>hh` | Harpoon add / menu |
| `s` | Flash jump (normal/visual/operator) |
| `<S-l>` / `<S-h>` | Next / prev buffer-tab |
| `<leader>e` | File explorer (Neo-tree) |
| `Ctrl+Space` | Trigger/show completion + docs |
| `↑` / `↓` in completion menu | Select prev / next item |
| `Enter` | Accept completion (else normal Enter) |
| `Tab` / `Shift+Tab` | Select next / prev item |
| `Ctrl+N` | Multi-cursor (vim-visual-multi) |
| `ys`/`cs`/`ds` + motion, `S` (visual) | Surround add / change / delete |
| `Alt+↑` / `Alt+↓` | Move line/selection up / down |
| `Ctrl+C` / `Ctrl+V` | System clipboard copy (visual) / paste (insert & visual) |
| `Ctrl+Alt+L` | Reformat (conform.nvim) |
| `Alt+Enter` | Code action (quick fix) |
| `Ctrl+Alt+O` | Organize imports |
| `gd` / `F4` | Go to definition |
| `gi` | Go to implementation |
| `gr` / `Alt+F7` | Find references |
| `K` | Hover docs |
| `Shift+F6` | Rename symbol |
| `<leader>xx` / `<leader>xX` | Problems: all / current buffer |
| `<leader>tt` / `<leader>tf` / `<leader>ts` | Test nearest / test file / test summary |
| `<leader>rr` / `<leader>rl` | Run task (build) / task list |
| `<leader>db` / `<leader>dc` | Toggle breakpoint / continue |
| `F7` / `F8` / `Shift+F8` | Step into / step over / step out |
| `Ctrl+\` | Toggle terminal (normal & terminal mode) |
| `<leader>qs` | Restore last session |
| `]c` / `[c` | Next / prev git hunk |
| `<leader>gb` | Blame current line |
| `<leader>gs` | Stage hunk |
| `<leader>gg` | LazyGit (stage/commit/push UI) |
| `<leader>gh` | File history (Diffview) |
| `Ctrl+L` / `Ctrl+]` / `Ctrl+E` | Copilot: accept / next suggestion / dismiss (insert mode ghost text) |
| `Esc` | Clear search highlight |

Forgot a key? Press `<leader>` and pause — **which-key** pops up a live menu of everything available from there (it's bound to fire after `timeoutlen = 400`ms).

---

## 1. Open a project

Launch `nvim` in a project directory (or bare `nvim`, then pick from the dashboard). If you launched bare, the dashboard (`dashboard-nvim`, "hyper" theme) lists recent projects and recent files — pick one, or press `<leader>fr` any time to open the recent-files picker (snacks.nvim) instead.

## 2. Navigate

- `<leader>ff` — fuzzy find files by name (snacks.picker).
- `<leader><leader>` — same find-files picker, "search everywhere" muscle memory.
- `<leader>fg` — live grep across the project.
- `<leader>o` — toggle the Aerial symbol outline for the current file (functions, classes, etc. — also feeds the winbar breadcrumb via barbecue/navic).
- `<leader>ha` — Harpoon: mark the current file. `<leader>hh` — open the Harpoon quick-menu to jump between marked files.
- `s` (normal, visual, or operator-pending) — Flash: type a couple of characters to jump anywhere on screen.

## 3. Buffers, tabs, and the file tree

- `<S-l>` / `<S-h>` — cycle to the next / previous buffer (shown as tabs in the bufferline, complete with LSP diagnostic icons).
- `<leader>e` — toggle the Neo-tree file explorer sidebar (it follows the current file automatically).

## 4. Edit

- Start typing; `nvim-autopairs` closes brackets/quotes for you.
- `Ctrl+Space` opens (or shows docs for) the completion menu (blink.cmp), sourced from LSP, paths, snippets, and buffer words. Use `↑`/`↓` or `Tab`/`Shift+Tab` to move the selection, `Enter` to accept.
- Copilot ghost-text suggestions appear automatically as you type; `Ctrl+L` accepts, `Ctrl+]` cycles to the next suggestion, `Ctrl+E` dismisses.
- `Ctrl+N` starts vim-visual-multi's multi-cursor mode on the word under the cursor — keep pressing it to add the next matching occurrence, then edit all cursors at once.
- Surround text objects courtesy of nvim-surround: `ys{motion}{char}` adds a surround (e.g. `ysiw"` to quote a word), `cs{old}{new}` changes one, `ds{char}` deletes one, and `S{char}` wraps a visual selection.
- `Alt+↑` / `Alt+↓` move the current line (or visual selection) up/down, re-indenting as it goes.
- `Ctrl+C` (visual) copies to the system clipboard; `Ctrl+V` pastes from it in insert or visual mode — these deliberately don't clobber vim's normal-mode `c`/`v`/`p` motions.
- Rainbow-delimiters, indent guides, and vim-illuminate light up matching brackets/scopes/word references as you move around — no keys needed, just visual aids.

## 5. Reformat and fix diagnostics

- `Ctrl+Alt+L` (normal or visual) reformats the buffer/selection via conform.nvim — stylua for Lua, prettier/prettierd for JS/TS/web, gofmt, rustfmt, etc. (Format-on-save is intentionally off — this is a deliberate keypress.)
- Diagnostics show inline (virtual text + gutter signs) as `nvim-lint` and your LSP servers report issues.
- Put the cursor on a squiggly and press `Alt+Enter` for a code action / quick fix menu; `Ctrl+Alt+O` organizes imports specifically.
- `gd`/`F4` go to definition, `gi` go to implementation, `gr`/`Alt+F7` find references, `K` shows hover docs, `Shift+F6` renames the symbol project-wide.
- `<leader>xx` opens the Trouble "Problems" panel for the whole project; `<leader>xX` scopes it to the current buffer.

## 6. Run, test, build, debug

- `<leader>tt` runs the nearest test (neotest, with Jest/Go/Rust adapters wired in); `<leader>tf` runs every test in the current file; `<leader>ts` toggles the test summary/tree panel.
- `<leader>rr` runs a task via Overseer (build/lint/whatever task you pick); `<leader>rl` opens the task list to watch/rerun past tasks.
- `<leader>db` toggles a breakpoint on the current line; `<leader>dc` starts/continues a debug session (DAP, via codelldb/delve depending on language). The DAP UI opens automatically when a session launches or attaches.
- While debugging: `F7` steps into, `F8` steps over, `Shift+F8` steps out.

## 7. Layout

- Split windows the usual vim way (`:split`, `:vsplit`, `Ctrl+w` + direction) — nothing custom is bound here, vanilla vim window management applies.
- `Ctrl+\` toggles an embedded terminal (horizontal split, works from normal or terminal mode) via toggleterm.
- `<leader>qs` restores your last session (open buffers/layout) for the current directory, via persistence.nvim — handy after quitting and coming back.

## 8. Git

- Gitsigns shows added/changed/removed markers in the gutter and inline current-line blame automatically (no key needed to see it).
- `]c` / `[c` jump to the next / previous hunk; `<leader>gs` stages the hunk under the cursor; `<leader>gb` shows a full blame popup for the current line.
- `<leader>gg` opens LazyGit — a full terminal UI for staging, committing, and pushing (requires the `lazygit` binary, see below).
- `<leader>gh` opens Diffview's file history for the current file, so you can browse and diff past revisions.

## 9. First-run notes

- **Plugins**: on the very first `nvim` launch, lazy.nvim bootstraps itself and installs all 49 plugins automatically. If anything looks incomplete afterward, run `:Lazy sync`.
- **LSP servers/formatters/linters**: run `:Mason` to open the manager UI and see what's installed. `mason-lspconfig` auto-installs the configured servers (`lua_ls`, `ts_ls`, `svelte`, `tailwindcss`, `html`, `cssls`, `jsonls`, `eslint`, `gopls`, `clangd`, `kotlin_language_server`, `dockerls`, `sqls`) the first time you open a matching filetype — this can take a minute on first use, so don't panic if `gd`/`K` don't respond instantly on a brand new file type.
- **Copilot**: run `:Copilot auth` once to sign in before ghost-text suggestions start appearing.
- **External CLIs** (not bundled — install via Homebrew):
  ```
  brew install lazygit ripgrep fd stylua
  ```
  - `lazygit` powers `<leader>gg`.
  - `ripgrep` and `fd` make the find/grep pickers (snacks.nvim) fast (and are used by some pickers directly).
  - `stylua` is the Lua formatter behind `Ctrl+Alt+L` for `.lua` files.
  - Node.js is assumed already present for `prettier`/`prettierd`/`eslint_d`.
  - The config degrades gracefully if any of these are missing — it just won't error, those specific features simply won't work until installed.
- **Cmd-key IDE shortcuts** (optional, terminal-only): bindings like `Cmd+Shift+N` for file lookup need Ghostty configured to forward the Cmd combo as an escape sequence, *and* the corresponding decode snippet added to `lua/core/keymaps.lua` — see `docs/ghostty-keybinds.md` for both halves. Until you wire that up, the `<leader>`-based equivalents (`<leader>ff`, etc.) always work with zero terminal configuration, so there's no rush.
- **VS Code users**: if you also use this repo through the `vscode-neovim` extension, see `docs/vscode-keybindings.md` for the IntelliJ-style verb-to-VS Code-command mapping (rename, references, code action, go-to-def, run test) to wire into VS Code's `keybindings.json`.
