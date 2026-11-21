# Walkthrough

A tour of this configuration from opening a project to committing the work, using the default `classic` keymap mode. `<leader>` is Space. Every binding below comes from `lua/keymaps/base.lua` (shared by all modes) and `lua/keymaps/classic.lua`; the VS Code and IntelliJ modes replace the IDE-style shortcuts and are listed in [docs/keybindings.md](docs/keybindings.md). Switch modes with `:KeymapMode`.

Forgot a key? Press `<leader>` and wait: which-key shows every binding under it after 400 ms (`timeoutlen`). `<leader>sk` searches all keymaps.

## Cheatsheet

| Key | Action |
|---|---|
| `<leader><leader>` | Smart find (files, buffers, recent) |
| `<leader>ff` / `<leader>fg` / `<leader>fr` | Find files / grep / recent files |
| `<leader>fb` / `<leader>fp` | Buffers / projects |
| `<leader>e` | File explorer (Neo-tree) |
| `<leader>cs` | Symbol outline (Aerial) |
| `<leader>ha` / `<leader>hh` / `<leader>1`-`4` | Harpoon add / menu / jump to slot |
| `s` / `S` | Flash jump / Flash treesitter select |
| `<S-l>` / `<S-h>` | Next / previous buffer |
| `<leader>bd` / `<leader>bo` | Close buffer / close other buffers |
| `<C-h>` `<C-j>` `<C-k>` `<C-l>` | Move between windows |
| `<C-s>` | Save |
| `gd` / `gD` / `gI` / `gy` | Definition / declaration / implementation / type definition |
| `grr` | References (Glance peek) |
| `K` | Hover, or peek a closed fold |
| `<leader>ca` / `<leader>cr` / `<leader>co` | Code action / rename / organize imports |
| `<leader>cf` | Format |
| `<leader>cd` | Line diagnostics |
| `]d` `[d` / `]e` `[e` / `]w` `[w` | Next / previous diagnostic, error, warning |
| `<leader>xx` / `<leader>xX` | Problems: project / buffer (Trouble) |
| `<leader>sr` | Search and replace across the project (grug-far) |
| `<leader>tt` / `<leader>tf` / `<leader>td` | Test nearest / test file / debug nearest test |
| `<leader>ts` / `<leader>to` | Test summary / test output |
| `<leader>rr` / `<leader>rl` | Run task / task list (Overseer) |
| `<leader>db` / `<leader>dc` | Toggle breakpoint / start or continue debugging |
| `<leader>dO` / `<leader>di` / `<leader>do` | Step over / into / out |
| `<C-\>` / `<M-t>` | Toggle terminal / floating terminal |
| `]h` `[h` | Next / previous git hunk |
| `<leader>ghs` / `<leader>ghr` / `<leader>ghp` | Stage / reset / preview hunk |
| `<leader>gg` | LazyGit |
| `<leader>gF` / `<leader>gd` | File history / diff view (Diffview) |
| `<leader>ac` / `<leader>as` | Toggle Claude Code / send selection to Claude |
| `<leader>qs` | Restore the session for this directory |

## 1. Open a project

Run `nvim` in a project directory. Bare `nvim` opens the dashboard with recent projects and files. `<leader>fr` opens recent files and `<leader>fp` lists projects at any time.

## 2. Navigate

- `<leader><leader>` is the smart picker: files, open buffers and recent files in one list. `<leader>ff` finds files only, `<leader>fg` greps the project, `<leader>sw` greps the word under the cursor.
- `<leader>cs` toggles the Aerial outline. The winbar shows the breadcrumb of the current symbol.
- `<leader>ha` marks the current file in Harpoon, `<leader>hh` opens the list, `<leader>1` to `<leader>4` jump straight to a slot.
- `s` followed by two characters jumps anywhere on screen (Flash). `S` selects a treesitter node.
- `]t` `[t` jump between TODO comments, `]r` `[r` between highlighted references of the word under the cursor.

## 3. Buffers, windows and the file tree

- `<S-l>` and `<S-h>` cycle through buffers, shown as tabs in the bufferline.
- `<leader>e` toggles Neo-tree. It follows the current file.
- `<C-h>` `<C-j>` `<C-k>` `<C-l>` move between windows, also from a terminal. `<leader>wv` and `<leader>ws` split, `<leader>wc` closes, `<leader>wo` closes the others.

## 4. Edit

- Brackets and quotes close automatically (nvim-autopairs); HTML and JSX tags close too (nvim-ts-autotag).
- Completion (blink.cmp) opens as you type. `<C-Space>` opens it or toggles the documentation, `Tab` and `S-Tab` or the arrow keys move, `Enter` accepts.
- `<C-n>` starts multi-cursor on the word under the cursor (vim-visual-multi); press it again to add the next match.
- Surround (nvim-surround): `ysiw"` quotes a word, `cs"'` changes the quotes, `ds"` deletes them.
- Text objects from mini.ai: `af` / `if` for a function, `aa` / `ia` for an argument.
- `<A-Up>` and `<A-Down>` move the line or selection. `gcc` comments a line; `<C-/>` does the same.
- `<C-c>` in visual mode copies to the system clipboard; `<C-v>` in insert mode pastes from it.

## 5. Format and fix diagnostics

- `<leader>cf` formats with conform.nvim: stylua for Lua, prettierd or prettier for JS, TS, Svelte, CSS, HTML and JSON, gofmt for Go, rustfmt for Rust. Format on save is off.
- Diagnostics from the language servers and nvim-lint appear inline and in the sign column. `]d` `[d` move between them, `<leader>cd` shows the full message.
- `<leader>ca` opens code actions, `<leader>co` organizes imports, `<leader>cr` renames the symbol everywhere.
- `gd` goes to the definition, `grr` peeks the references in Glance, `K` shows hover documentation. `<leader>ci` and `<leader>cO` list incoming and outgoing calls.
- `<leader>xx` opens the Trouble problems panel for the project, `<leader>xX` for the current buffer.

## 6. Run, test and debug

- `<leader>tt` runs the nearest test with neotest (Jest, Go, Java and Rust adapters), `<leader>tf` the whole file, `<leader>td` the nearest test under the debugger. `]f` `[f` jump between failed tests.
- `<leader>rr` runs a task with Overseer, `<leader>rl` opens the task list.
- `<leader>db` sets a breakpoint, `<leader>dc` starts or continues a debug session. Adapters: codelldb (Rust, C), delve (Go), java-debug (Java), js-debug (JS, TS, Svelte). JS and TS offer "Launch file", "Attach to process" and "Chrome: localhost:5173 (Vite)". The DAP UI opens on start; `<leader>du` toggles it.
- While debugging: `<leader>dO` steps over, `<leader>di` into, `<leader>do` out, `<leader>dt` stops.

## 7. Terminal and sessions

- `<C-\>` toggles a terminal at the bottom (toggleterm). `<M-t>` opens a floating one, `<M-1>` to `<M-3>` pick a numbered terminal.
- `<leader>qs` restores the session for the current directory (persistence.nvim), `<leader>ql` the last session.

## 8. Git

- gitsigns marks changed lines in the sign column. `<leader>gb` toggles inline blame for the current line.
- `]h` `[h` move between hunks. `<leader>ghs` stages a hunk, `<leader>ghr` resets it, `<leader>ghp` previews it, `<leader>ghb` shows the full blame.
- `<leader>gg` opens LazyGit to stage, commit and push.
- `<leader>gF` shows the history of the current file in Diffview, `<leader>gd` the working tree diff. `<leader>gs` and `<leader>gl` pick from git status and git log.

## 9. First run

- lazy.nvim installs the plugins on first start. Run `:Lazy sync` if something looks incomplete.
- Mason installs the language servers when a matching file opens: `lua_ls`, `ts_ls`, `svelte`, `tailwindcss`, `html`, `cssls`, `jsonls`, `eslint`, `gopls`, `clangd`, `kotlin_language_server`, `dockerls`, `sqls`, `bashls` and `pyright`. `tailwindcss` attaches only in projects with a Tailwind config or `tailwindcss` in `package.json`. It also installs `jdtls`, `java-debug-adapter`, `java-test`, `js-debug-adapter`, `prettierd`, `prettier`, `hadolint`, `codelldb` and `delve`. Node.js must be on `PATH` for the npm packages. `:Mason` shows what is installed.
- Rust needs `rustup component add rust-analyzer`. Java tests need the JUnit runner once: `:NeotestJava setup`.
- External tools: `brew install lazygit ripgrep fd stylua`. Without them the related features do nothing, without errors.
- Copilot is configured but disabled in `lua/plugins/ai.lua`. To use it, set `enabled = true` there and run `:Copilot auth`.
- Cmd shortcuts in Ghostty need the terminal to forward them; see [docs/ghostty-keybinds.md](docs/ghostty-keybinds.md).
- Inside VS Code (vscode-neovim) the plugins and keymap modes do not load; see [docs/vscode-keybindings.md](docs/vscode-keybindings.md).
