# Neovim IDE-style Config — Design

**Date:** 2026-08-09
**Author:** vatrajko
**Status:** Approved, ready for implementation planning

## Goal

Turn a bare Neovim skeleton into an IDE-like editor that keeps vanilla vim
motions but gives friendly, IntelliJ-matching bindings for "editor features"
(navigation, refactor, completion, debugging). Must work in **two homes**:

1. **Ghostty** (standalone terminal) — the full IDE experience.
2. **VS Code** via the `asvetliakov.vscode-neovim` extension — nvim is *only*
   the modal editing engine; VS Code owns all UI.

## Core constraint: the two-home split

`vscode-neovim` sets `vim.g.vscode = true` at startup. The config branches on it:

- **Shared everywhere** (`lua/core/*`): options (clipboard, indent, diagnostics
  data), and vim-motion-safe keymaps. Never touches theming or UI. This is what
  previously broke rendering inside VS Code — all visual/UI code is gated out.
- **Terminal-only** (`not vim.g.vscode`): lazy.nvim + every plugin, theme,
  statusline, completion popup, file tree, telescope, LSP UI, debugging.
- **VS Code-only**: the same IntelliJ *verbs* are mapped to VS Code's own
  commands (in the user's VS Code `keybindings.json`, documented separately),
  so the keys feel identical while VS Code provides the engine.

## Target environment / preferences (from the user's VS Code + IntelliJ config)

- **Muscle memory = IntelliJ "IDEA Classic" keymap** (active in IntelliJ, and
  mirrored in VS Code via `intellij-idea-keybindings`). nvim mirrors IntelliJ.
- **Theme:** `github-nvim-theme` → `github_dark`, **softened**: warm/soften the
  default palette and override treesitter identifier groups (`@variable`,
  `@property`, `@field`, `@parameter`) toward the neutral foreground so most text
  reads near-white and color is reserved for keywords/strings/types — a
  Darcula/Dracula-style restrained-color look on a familiar GitHub Dark base.
  Overrides live in `lua/plugins/ui.lua`; theme is swappable in one line.
- **Font:** FiraCode Nerd Font Mono, ligatures on → Nerd Font icons available.
- **Indent:** 2 spaces (`expandtab`), Python 4. `tabSize`/`shiftwidth` = 2.
- **Line numbers:** absolute (user does not use relative).
- **Minimap:** none.
- **Format on save:** OFF. Formatting is manual via `Ctrl+Alt+L`.
- **Inline diagnostics:** REQUIRED (user runs 3 Error-Lens-type extensions) —
  gutter signs **and** end-of-line virtual text.

## Directory layout

```
init.lua                     -- require core; if not vim.g.vscode -> require config.lazy
lua/core/
  init.lua                   -- requires options + keymaps (always)
  options.lua                -- clipboard=unnamedplus, indent, numbers, diagnostics config
  keymaps.lua                -- shared keymaps (safe in VS Code)
lua/config/
  lazy.lua                   -- bootstraps lazy.nvim, loads lua/plugins/
lua/plugins/                 -- one file per concern; terminal-only
  ui.lua           theme, lualine, bufferline, neo-tree, which-key, barbecue, devicons
  treesitter.lua   parsers + rainbow-delimiters + indent-blankline
  completion.lua   blink.cmp (Ctrl+Space), autopairs
  lsp.lua          mason + vim.lsp.enable, keymaps, conform, nvim-lint, fidget
  lang.lua         nvim-jdtls (Java), rustaceanvim (Rust)
  diagnostics.lua  trouble.nvim
  debug.lua        nvim-dap + dap-ui + mason-nvim-dap
  navigation.lua   telescope, aerial, harpoon, flash, project.nvim, dashboard
  git.lua          gitsigns, lazygit, diffview
  editor.lua       toggleterm, todo-comments, vim-illuminate, persistence,
                   nvim-surround, vim-visual-multi
  run.lua          neotest (+ adapters), overseer
  ai.lua           copilot.lua
```

## Plugin set (terminal-only)

- **Manager/UI:** lazy.nvim · github-nvim-theme · lualine · bufferline · neo-tree
  · nvim-web-devicons · which-key · barbecue + nvim-navic (breadcrumbs)
- **Editing intel:** nvim-treesitter (parsers: lua, tsx, typescript, javascript,
  svelte, css, html, json, sql, dockerfile, go, rust, c, bash, markdown) ·
  blink.cmp · nvim-autopairs · rainbow-delimiters · indent-blankline · vim-illuminate
- **LSP:** mason + native `vim.lsp.enable` → lua_ls, ts_ls, svelte,
  tailwindcss, html, cssls, jsonls, eslint, gopls, clangd, kotlin_language_server,
  sqls, dockerfile-language-server. Java via **nvim-jdtls**, Rust via **rustaceanvim**.
- **Formatting/linting:** conform.nvim (manual, `Ctrl+Alt+L`, uses project prettier
  config) · nvim-lint (for linters LSP doesn't provide)
- **Diagnostics UX:** native gutter signs + inline virtual text · trouble.nvim · fidget
- **Debug:** nvim-dap + nvim-dap-ui + mason-nvim-dap (F7/F8/Shift+F8, breakpoints)
- **Nav/outline:** telescope · aerial · harpoon · flash · **project.nvim**
  (recent-projects picker + root detection) · **dashboard/start screen**
  (recent projects + files on launch)
- **Run/test:** **neotest** (+ language adapters: jest/vitest, go, rust, jdtls) ·
  **overseer.nvim** (build/run "configurations", dap-integrated)
- **Editing extras:** **nvim-surround** (surround verbs) · **vim-visual-multi**
  (multi-cursor, `Ctrl+N`)
- **Git:** gitsigns (signs + inline blame) · lazygit · diffview
- **Shell/QoL:** toggleterm · todo-comments · persistence.nvim (session/project restore)
- **AI:** copilot.lua (Copilot inline suggestions)

### "Tabs"/panels the user expects (all built-in to the above)
- Plugin manager → `:Lazy` (search/install/update).
- LSP/tool manager → `:Mason` (search/install servers, formatters, linters, DAP).
- Projects → telescope picker via `project.nvim` + `persistence.nvim` restore.
- Keybinding discovery popup → `which-key.nvim` (press `<leader>`, pause).
- File tabs → `bufferline`; nvim tabpages remain whole-window layouts.

Explicitly NOT included (YAGNI / native / declined): coc.nvim, ALE, syntastic,
vim-airline, vim-gitgutter, vim-sensible, AsyncRun (Neovim is async-native),
commenting plugin (built-in `gc`), editorconfig plugin (built-in since 0.9),
database client, REST client.

## Keybindings

### Shared (both homes)
- System clipboard via `clipboard=unnamedplus` — `y`/`p` use the macOS clipboard.
- Optional `Ctrl+C`/`Ctrl+V` in visual/insert for reflex (does not shadow vim).
- Vim motions untouched: `ggvG` select-all, `u` undo, `:w` save.

### Terminal (IntelliJ verbs → nvim, each with a `<leader>` fallback that always works)
| Action | IntelliJ key | nvim target |
|---|---|---|
| Go to definition | `F4` / `gd` | `vim.lsp.buf.definition` |
| Go to implementation | `Cmd+Alt+B` / `gi` | `vim.lsp.buf.implementation` |
| Find usages/references | `Alt+F7` / `gr` | `vim.lsp.buf.references` (telescope) |
| Rename | `Shift+F6` | `vim.lsp.buf.rename` |
| Code action / quick-fix | `Alt+Enter` | `vim.lsp.buf.code_action` |
| Reformat | `Ctrl+Alt+L` | `conform.format` |
| Organize imports | `Ctrl+Alt+O` | LSP code-action `source.organizeImports` |
| Hover docs | `K` | `vim.lsp.buf.hover` |
| Type hierarchy | `Ctrl+H` | LSP type hierarchy |
| File lookup | `Cmd+Shift+N` / `<leader>ff` | telescope find_files |
| Search everywhere | `Shift Shift` / `<leader><leader>` | telescope |
| Recent files | `Cmd+E` | telescope oldfiles |
| Completion | `Ctrl+Space` | blink.cmp |
| Debug step over/into/out | `F8`/`F7`/`Shift+F8` | nvim-dap |
| Run nearest test | `<leader>tt` | neotest run nearest |
| Run test file | `<leader>tf` | neotest run file |
| Run build/task | `<leader>rr` | overseer run template |
| Add cursor at next match | `Ctrl+N` | vim-visual-multi |

`Cmd`-based bindings require a Ghostty `keybind` snippet (provided separately) to
forward the combo to nvim; F-keys and `Alt` combos work with Ghostty's
`macos-option-as-alt` + kitty keyboard protocol. Every `Cmd` action also has a
`<leader>` binding that works with zero terminal config.

### VS Code layer
The same verbs (rename, references, code-action, go-to-def, debug steps) are
bound in the user's VS Code `keybindings.json` to native VS Code commands so the
keys match. Delivered as a documented snippet, not part of the nvim repo.

## Error handling / edge cases

- **VS Code guard:** if `vim.g.vscode`, `init.lua` returns before loading lazy or
  any UI. A regression here reproduces the "unreadable text" bug — this is the
  single most important invariant and should be verified in both homes.
- **Missing external tools:** LSP servers/formatters install via mason; the config
  must not error when a server binary is absent (guard `vim.lsp.enable` per
  available server). Java/Rust special plugins no-op if their toolchain is missing.
- **Ghostty key forwarding is optional:** all Cmd bindings degrade to `<leader>`
  equivalents, so the config is fully usable before Ghostty is configured.
- **First launch:** lazy.nvim bootstraps itself; mason installs on first run.
  Document the expected one-time install on first `nvim` launch.

## Testing / verification

- Launch terminal nvim: theme loads, `:Lazy` clean, `:checkhealth` sane,
  `:Mason` shows servers, completion on `Ctrl+Space`, LSP attaches to a sample
  file per language, diagnostics show inline + gutter, `Alt+Enter`/`Shift+F6`
  work, debugger sets a breakpoint.
- Launch nvim inside VS Code (`vscode-neovim`): NO theme/UI loads, motions work,
  clipboard works, no rendering corruption.
- Keep `lazy-lock.json` committed for reproducibility.

## Deliverables (beyond the config itself)

- **`WALKTHROUGH.md`** at repo root, written *after* the build and *after*
  verifying bindings actually work. End-to-end flow: change a file → open a
  project (project picker / dashboard) → open buffers/tabs → edit with
  completion → run a build/test config (overseer/neotest) → debug → set up the
  window layout → stage/commit/push (gitsigns + lazygit). Reflects real
  behavior, not planned behavior.
- **Ghostty `keybind` snippet** — forwards `Cmd+Shift+N` etc. to nvim; includes
  `macos-option-as-alt` and kitty-keyboard-protocol notes. Delivered as a doc.
- **VS Code `keybindings.json` snippet** — maps the same IntelliJ verbs to native
  VS Code commands so both homes match. Delivered as a doc.
- **which-key** groups act as an in-editor cheatsheet.

## Out of scope (future)

Database client (vim-dadbod-ui), REST client (kulala.nvim), avante AI chat,
per-language DAP adapter tuning beyond defaults, non-stated languages
(Vue/Angular/C#/PHP/Python beyond basic) — all addable later per the same pattern.
