# Neovim Keybindings & Usage Guide

This config has a **keybinding-mode system**: four complete, switchable keymap
schemes on top of a shared universal base. Switch live with `:KeymapMode` — no
restart — and your choice persists across sessions.

- **Sources:** Neovim 0.12 `:help` (lsp, diagnostic, motion, fold, windows,
  quickfix, spell, pattern, repeat), each plugin's official README, and the
  distilled reference in
  [`docs/superpowers/specs/2026-08-12-keybinding-capability-inventory.md`](superpowers/specs/2026-08-12-keybinding-capability-inventory.md).
- **Notation:** `<leader>` = <kbd>Space</kbd>, `<localleader>` = `\`.
  `<D-…>` = <kbd>Cmd</kbd> (macOS), `<A-…>` = <kbd>Option/Alt</kbd>,
  `<C-…>` = <kbd>Ctrl</kbd>, `<S-…>` = <kbd>Shift</kbd>, `<CR>` = <kbd>Enter</kbd>.
  For the IDE modes, macOS keys are shown with the Windows/Linux variant in
  parentheses where they differ.

---

## 1. How to drive Neovim (the model)

Neovim is **modal** — the same physical key does different things depending on
the mode. You spend most of your time in Normal mode issuing commands, dropping
into Insert only to type.

| Mode | Enter with | For |
|------|-----------|-----|
| **Normal** | `<Esc>` | navigation & operators (the home base) |
| **Insert** | `i` `a` `o` `I` `A` `O` | typing text |
| **Visual** | `v` `V` `<C-v>` | selecting text (char / line / block) |
| **Command** | `:` | ex commands (`:w`, `:KeymapMode`) |
| **Terminal** | `i` in a `:terminal` | typing into a shell; leave with `<C-\><C-n>` |

### The grammar: verb → motion/text-object

Normal-mode editing composes an **operator** with a **motion** or **text
object**. Learn a handful of each and they multiply:

```
d          w              →  dw   delete to next word
c          i"             →  ci"  change inside quotes
y          ap             →  yap  yank a paragraph
>          i{             →  >i{  indent inside braces
```

**Operators:** `d` delete · `c` change · `y` yank (copy) · `v` select ·
`>` `<` indent · `=` auto-indent · `gu`/`gU` lower/upper · `gc` comment.

**Motions:** `w`/`b`/`e` word · `0`/`^`/`$` line ends · `f{c}`/`t{c}` to char ·
`}`/`{` paragraph · `%` matching bracket · `gg`/`G` file top/bottom · `{n}G` line n.

**Text objects** (used after an operator or in Visual): `iw`/`aw` word ·
`i"`/`a"` quotes · `i(`/`a(` `ib` parens · `i{`/`aB` braces · `it`/`at` tag ·
`ip`/`ap` paragraph. `i` = inner (contents), `a` = around (incl. delimiters).
This config also adds `if`/`af` **function** and `ia`/`aa` **argument** (mini.ai),
and `ih` **git hunk** (gitsigns).

### Beyond editing

- **Repeat:** `.` repeats the last change. `;`/`,` repeat the last `f`/`t`.
- **Undo/redo:** `u` / `<C-r>`. Persistent across sessions (`undofile` is on).
- **Registers:** `"ay` yanks into register `a`; `"ap` pastes it. `"+` is the
  system clipboard (and `clipboard=unnamedplus` makes plain `y`/`p` use it).
- **Macros:** `qa` … `q` records into `a`; `@a` replays; `@@` repeats.
- **Marks & jumps:** `` m{a} `` sets a mark, `` `{a} `` jumps to it;
  `<C-o>`/`<C-i>` walk the jump list backward/forward.
- **Search:** `/pattern` then `n`/`N`; `*`/`#` search the word under the cursor.
  `<Esc>` clears the highlight (this config).
- **Windows/tabs:** `<C-w>s`/`<C-w>v` split; move between with `<C-h/j/k/l>`
  (this config, no prefix needed); `gt`/`gT` cycle tabs.
- **Folds:** `za` toggle · `zR`/`zM` open/close all · `zo`/`zc` open/close one.
- **Quickfix/location list:** results land here (`:copen`); `:cnext`/`:cprev` walk them.

> New to Vim motions? Run `:Tutor` once. Ten minutes there pays for itself.

---

## 2. The four modes

Run **`:KeymapMode`** (no argument) for a picker, or `:KeymapMode <name>` to
switch directly. The active mode is saved to
`stdpath("data")/keymap-mode` and restored on the next launch. Switching is
**live** — the old scheme's maps are torn down and the new ones applied
instantly.

| Mode | Philosophy | Reach for it if… |
|------|-----------|------------------|
| **`classic`** | Vim-native / LazyVim-canonical: short `g`-prefixed goto, leader groups. | you think in Vim idioms. **(default)** |
| **`consistent`** | One rule — `<leader>` + category + verb. Everything is a leader tree, fully discoverable via which-key. | you'd rather *discover* keys than memorize them. |
| **`vscode`** | VS Code default keymap (`F12`, `F2`, `Cmd+.`, `F5`…) on top of the `consistent` leader tree. | your muscle memory is VS Code. |
| **`intellij`** | IntelliJ IDEA default keymap (`Cmd+B`, `Alt+F7`, `Shift+F6`, tool windows) on top of the `consistent` leader tree. | your muscle memory is IntelliJ. |

`vscode` and `intellij` never share chords: VS Code mode has no IntelliJ keys and
the reverse. Both load the `consistent` leader tree underneath, so every feature
stays reachable through `<leader>` when the terminal cannot send a `Cmd` or
`Ctrl+Shift` chord. In `intellij`, the tool windows `<leader>1`–`8` replace the
harpoon slots `<leader>1`–`4`.

Code navigation is the same in all four modes, on the `g` keys Neovim itself
uses: `gd` definition, `gD` declaration, `grr` references (peek), `gri`
implementation, `grt` type definition, `grn` rename, `gra` code action, `gO`
document symbols, `K` hover. LSP keys exist only in buffers with a language
server attached.

> **which-key:** in every mode, pause after `<leader>` (or any group
> prefix like `<leader>g`) and a popup lists what follows. This is the fastest
> way to learn a mode.

> **vscode-neovim users:** the mode system loads only in **terminal** Neovim, not
> inside the VS Code embedded host (where these plugins don't load). In that host
> VS Code's own keybindings apply.

---

## 3. Base bindings (all modes)

These are universal — present in every mode. They are idiom-neutral (window/
buffer/terminal management, clipboard, save) and never change when you switch.

### Windows, buffers, panes

| Key | Action |
|-----|--------|
| `<C-h>` / `<C-j>` / `<C-k>` / `<C-l>` | Move to left / lower / upper / right pane (also from a terminal) |
| `<S-l>` / `<S-h>` | Next / previous buffer |
| `<leader>wv` / `<leader>ws` | Split vertical / horizontal |
| `<leader>wc` / `<leader>wo` / `<leader>w=` | Close window / only (close others) / equalize |
| `<leader>wt` / `<leader>wn` / `<leader>wp` | New tab / next tab / prev tab |

### Editing & clipboard

| Key | Action |
|-----|--------|
| `<C-s>` | Save file (normal & insert) |
| `<Esc>` | Clear search highlight |
| `<A-Up>` / `<A-Down>` | Move line/selection up / down |
| `<C-c>` (visual) | Copy to system clipboard |
| `<C-v>` (insert) | Paste from system clipboard (in visual, `p` already pastes it: `clipboard=unnamedplus`) |
| `gcc` / `gc` (+ `<C-_>`, `<D-/>`) | Toggle comment (line / motion) |
| `s` / `S` | Flash jump / Flash treesitter select |

### Terminal, UI & session

| Key | Action |
|-----|--------|
| `<C-\>` / `<M-t>` | Toggle terminal / float terminal |
| `<M-1>` / `<M-2>` / `<M-3>` / `<M-F12>` | Terminal 1 / 2 / 3 / Option+F12 toggle |
| `<leader>ut` | Toggle theme (dark/light) |
| `<leader>uh` | Toggle inlay hints |
| `<leader>um` | Toggle markdown rendering |
| `<leader>sn` / `<leader>un` | Notification history / dismiss notifications |
| `<leader>qs` / `<leader>ql` / `<leader>qd` | Restore session (cwd) / restore last / don't save |

---

## 4. Per-mode reference

Hover-doc (`K` in every mode, plus `Cmd+K Cmd+I` / `F1` in the IDE modes) and
`<leader>`-group popups mean you rarely need to memorize these — but here they are.

### 4a. `classic` — vim-native

**Goto & code (LSP):**

| Key | Action | Key | Action |
|-----|--------|-----|--------|
| `gd` | Definition | `<leader>cr` | Rename |
| `gD` | Declaration | `<leader>ca` | Code action |
| `gri` (`gI`) | Implementation | `<leader>cf` | Format |
| `grt` (`gy`) | Type definition | `<leader>co` | Organize imports |
| `grr` | References (peek) | `<leader>cs` | Symbols / outline |
| `K` | Hover / peek fold | `<leader>cd` | Line diagnostics |
| `gK` | Signature help | `<leader>ci` / `<leader>cO` | Incoming / outgoing calls |

**Find (`<leader>f` / `<leader>s`):** `<leader>ff` files · `<leader><leader>`
smart · `<leader>fg` grep · `<leader>fr` recent · `<leader>fb` buffers ·
`<leader>fp` projects · `<leader>/` grep · `<leader>sw` grep word ·
`<leader>ss` symbols · `<leader>sd` diagnostics · `<leader>sk` keymaps ·
`<leader>sh` help · `<leader>sR` resume · `<leader>sr` search & replace.

**Diagnostics:** `]d`/`[d` next/prev · `]e`/`[e` next/prev error ·
`<leader>xx` problems · `<leader>xX` buffer problems.

**Git:** `<leader>gg` LazyGit · `<leader>gd` diff view · `<leader>gF` file
history · `<leader>gs` status · `<leader>gl` log · `<leader>gb` toggle line
blame. **Hunks (`<leader>gh`):** `ghs` stage · `ghr` reset · `ghp` preview ·
`ghi` inline · `ghS` stage buffer · `ghb` blame line · `ghB` blame file ·
`ghd` diff · `]h`/`[h` next/prev hunk · `ih` hunk text-object.

**Run / test / debug:** `<leader>rr` run task · `<leader>rl` task list ·
`<leader>tt` test nearest · `<leader>tf` file · `<leader>ts` summary ·
`<leader>to` output · `<leader>td` debug nearest · `]f`/`[f` next/prev failed ·
`<leader>db` breakpoint · `<leader>dc` continue · `<leader>dO`/`di`/`do`
step over/into/out · `<leader>du` debug UI · `<leader>de` eval.

**Nav & misc:** `]t`/`[t` next/prev todo · `]r`/`[r` next/prev reference ·
`zR`/`zM`/`zK` open/close/peek folds · `<leader>1`–`4` harpoon slots ·
`<leader>ha`/`hh` harpoon add/menu · `<leader>a…` AI (see §6).

### 4b. `consistent` — one rule: `<leader>` + category + verb

Every action lives under a category prefix. Press the prefix, read the which-key
popup. Navigation (`gd`, `grr`, `gri`, `grt`, `K`) is not in the tree; it is the
same `g` family as in every mode. `<leader>c` uses the same letters as `classic`.

| Prefix | Category | Examples |
|--------|----------|----------|
| `<leader>c` | **code** | `ca` action · `cr` rename · `cf` format · `co` organize imports · `cs` symbols / outline · `cd` line diagnostics · `ci`/`cO` incoming/outgoing calls |
| `<leader>f` | **find** | `ff` files · `fg` grep · `fr` recent · `fb` buffers · `fp` projects · `fs` symbols · `fw` grep word · `fk` keymaps · `fh` help · `fe` explorer |
| `<leader>x` | **diagnostics** | `xx` problems · `xb` buffer · `xn`/`xp` next/prev · `xt` todos |
| `<leader>g` | **git** | `gs` stage · `gr` reset · `gp` preview · `gb` blame · `gB` toggle blame · `gn`/`gN` next/prev hunk · `gg` LazyGit · `gd` diff · `gh` history · `gl` log · `gt` status · `ih` hunk object |
| `<leader>r` | **run** | `rr` run · `rl` list · `rc` shell cmd |
| `<leader>t` | **test** | `tt` nearest · `tf` file · `ts` summary · `to` output · `td` debug · `tn`/`tp` next/prev failed |
| `<leader>d` | **debug** | `db` bp · `dB` cond bp · `dc` continue · `dC` to cursor · `dO`/`di`/`do` step · `dt` terminate · `dl` last · `du` UI · `de` eval |
| `<leader>s` | **search** | `sr` replace · `sg` grep · `sw` grep word · `sn` notifications |
| `<leader>a` | **AI** | see §6 |
| `<leader>1`–`4` | **harpoon** slots; `ha`/`hh` add/menu |

### 4c. `vscode` — VS Code keymap (macOS shown; Win/Linux in parens)

These chords sit on top of the `consistent` tree (§4b), which also works here.

| Key | Action | Key | Action |
|-----|--------|-----|--------|
| `F12` | Goto definition | `Cmd+P` (`Ctrl+P`) | Go to file |
| `Alt+F12` | Peek definition | `Cmd+Shift+P` | Command palette |
| `Cmd+F12` (`Ctrl+F12`) | Implementations | `Cmd+Shift+O` | Symbols in file |
| `Shift+F12` | References | `Cmd+Shift+F` | Find in files |
| `Cmd+K Cmd+I` | Hover | `Cmd+B` (`Ctrl+B`) | Toggle sidebar (explorer) |
| `F2` | Rename | `` Ctrl+` `` | Toggle terminal |
| `Cmd+.` (`Ctrl+.`) | Quick fix | `Ctrl+Shift+G` | Source control |
| `Shift+Alt+F` | Format document | `Cmd+1/2/3` | Editor group 1/2/3 |
| `Shift+Alt+O` | Organize imports | `F8` / `Shift+F8` | Next / prev problem |
| `Cmd+/` (`Ctrl+/`) | Comment line | `F5` | Start / continue debug |
| `F9` | Toggle breakpoint | `F10` / `F11` / `Shift+F11` | Step over / into / out |

### 4d. `intellij` — IntelliJ IDEA keymap (macOS shown; Win/Linux in parens)

These chords sit on top of the `consistent` tree (§4b), which also works here.

| Key | Action | Key | Action |
|-----|--------|-----|--------|
| `Cmd+B` (`Ctrl+B`) | Goto definition | `Cmd+O` (`Ctrl+N`) | Go to class/file |
| `Cmd+Alt+B` | Goto implementation | `Cmd+Alt+O` | Go to symbol |
| `Cmd+Shift+B` | Goto type declaration | `Cmd+E` (`Ctrl+E`) | Recent files |
| `Alt+F7` | Find usages | `Cmd+F12` | File structure |
| `Alt+Space` | Quick definition | `Shift+F6` | Rename |
| `F1` | Quick doc (hover) | `Alt+Enter` | Intention / quick fix |
| `Cmd+Alt+L` | Reformat code | `Ctrl+Alt+O` | Optimize imports |
| `Cmd+D` (`Ctrl+D`) | Duplicate line | `F2` / `Shift+F2` | Next / prev error |
| `Cmd+Shift+F` | Find in files | `Cmd+/` (`Ctrl+/`) | Comment line |
| `Shift+F10` | Run | `Shift+F9` | Debug |
| `F8` / `F7` / `Shift+F8` | Step over / into / out | `Cmd+F8` | Toggle breakpoint |
| `Cmd+K` (`Ctrl+K`) | Commit / git | `Alt+F12` | Terminal |

**Tool windows (`<leader>` + number — IntelliJ's signature):** `<leader>1`
project · `<leader>2` terminal · `<leader>3` editor · `<leader>4` run ·
`<leader>5` debug · `<leader>6` structure · `<leader>7` tests · `<leader>8`
version control.

### Java refactorings (every mode, `<localleader>` = `\`)

In Java buffers: `\o` organize imports · `\v` extract variable · `\V` extract
variable (all occurrences) · `\c` extract constant · `\m` extract method
(visual) · `\s` go to super implementation. `\v`, `\V` and `\c` also work on
a visual selection.

---

## 5. Plugins — what each does & how to drive it

Grouped by role. "Bindings" are the mode-agnostic capability; the exact key
depends on the active mode (see §4). Display-only plugins are noted without keys.

### Neovim core (no plugin)

- **LSP** — `vim.lsp.buf.*`: definition, references, hover, rename, code action,
  format, symbols, incoming/outgoing calls. Bound per mode (`gd`/`F12`/`Cmd+B`…).
  Toggle inferred-type **inlay hints** with `<leader>uh`.
- **Diagnostics** — `]d`/`[d` (classic) or `<leader>xn`/`xp` (consistent) or
  `F8`/`F2` (IDE modes). `<C-w>d` shows the float at the cursor (built-in).
- **Folds, quickfix, spell, marks, macros** — see §1.

### LSP & code intelligence

- **nvim-lspconfig** — wires the built-in LSP client; the verbs above come from it.
- **blink.cmp** (completion) — in the popup: `<C-y>` accept · `<C-n>`/`<C-p>` or
  arrows to move · `<Tab>`/`<S-Tab>` jump snippet fields · `<C-Space>` toggle
  docs · `<C-k>` signature.
- **conform.nvim** — formatting engine behind Format (`<leader>cf` / `Shift+Alt+F`
  / `Cmd+Alt+L`); also formats on save.
- **nvim-lint** — async linters, run automatically; feeds diagnostics.
- **aerial.nvim** — code outline. Open with Symbols/Structure (`<leader>cs`,
  `<leader>6`, IntelliJ `Cmd+F12`). Inside: `{`/`}` prev/next symbol.
- **glance.nvim** — VS Code-style peek window for references/definitions (the
  `grr`, `Shift+F12`, `Alt+F7` bindings). In the peek: `j`/`k` move, `<CR>` jump,
  `v`/`s`/`t` open in split/vsplit/tab, `<C-q>` → quickfix.
- **trouble.nvim** — the problems list (`<leader>xx` / `<leader>xb`). Also does
  symbols, LSP results, todos, quickfix. In-window: `<CR>` jump, `}`/`{` next/prev.
- **todo-comments.nvim** — highlights `TODO`/`FIX`/`HACK`. Jump `]t`/`[t`
  (classic) or `<leader>xt` (Trouble list, consistent).
- **nvim-navic + barbecue** — breadcrumb winbar (display-only).
- **lazydev.nvim** — better Lua LSP when editing this config (no keys).

### Finding & navigation

- **snacks.picker** (the fuzzy finder — replaces Telescope). Files, grep,
  buffers, recent, projects, symbols, diagnostics, keymaps, help, git status/log,
  incoming/outgoing calls, resume — all under `<leader>f`/`<leader>s` (classic),
  `<leader>f` (consistent), or `Cmd+P`/`Cmd+Shift+O` (IDE modes). Inside a picker:
  type to filter, `<CR>` open, `<C-v>`/`<C-s>` vsplit/split, `<C-t>` tab.
- **flash.nvim** — jump anywhere with `s` + a 1–2 char label; `S` selects
  expanding treesitter nodes. Works as a motion (`ds{label}` etc.).
- **harpoon** — pin a few files, jump instantly. `<leader>ha` add, `<leader>hh`
  menu, `<leader>1`–`4` jump to slots (classic/consistent).
- **neo-tree** — file explorer (`<leader>e` / `<leader>fe` / `Cmd+B` sidebar /
  `<leader>1` in intellij). Inside: `<CR>` open, `a`/`d`/`r` add/delete/rename,
  `?` help.

### Git

- **gitsigns** — hunk-level actions in the gutter: stage/reset/preview/blame per
  hunk, `]h`/`[h` navigate, `ih` hunk text-object (`dih`, `vih`). `<leader>gb`
  toggles inline line-blame.
- **diffview** — full-file / history diff UI. `<leader>gd` opens the working diff,
  `<leader>gF` (classic) / `<leader>gh` (consistent) shows current file history.
  Inside: `<Tab>`/`<S-Tab>` next/prev file, `<CR>` open, `s`/`u` stage/unstage.
- **lazygit** — full git TUI in a float (`<leader>gg` / `Cmd+K`). All keys inside
  are lazygit's own; `q` closes back to Neovim.

### Run · test · debug

- **overseer** — task runner. `<leader>rr` pick & run, `<leader>rl` task list,
  `<leader>rc` arbitrary shell command. Also `Shift+F10` (intellij) / part of
  `F5` flows.
- **neotest** — test runner (Jest, Go, Java/JUnit, Rust). `<leader>tt` nearest, `<leader>tf` file, `<leader>ts`
  summary panel, `<leader>to` output, `<leader>td` **debug** the nearest test (via
  dap), `]f`/`[f` jump between failures.
- **nvim-dap + dap-ui** — debugger. Breakpoint, continue, step over/into/out,
  run-to-cursor, run-last, terminate; `<leader>du` toggles the UI, `<leader>de`
  evaluates the expression under the cursor / selection. IDE modes map the
  familiar `F5`/`F8`-`F11` / `Shift+F9` keys.

### Editing power tools

- **nvim-surround** — `ys{motion}{char}` add, `ds{char}` delete, `cs{a}{b}`
  change surrounding pairs (`ysiw"` wraps a word in quotes). Dot-repeatable.
- **mini.ai** — richer text objects: `if`/`af` function, `ia`/`aa` argument,
  plus `an`/`in` (next) and `al`/`il` (last) variants.
- **mini.splitjoin** — `gS` toggles an argument list between one line and many.
- **mini.bufremove** — `<leader>bd` closes a buffer without wrecking your window layout.
- **nvim-ufo** — smarter folds: `zR`/`zM` open/close all, `zK` peeks a fold's
  contents in a float.
- **vim-visual-multi** — multiple cursors: `<C-n>` selects the next occurrence of
  the word, `<C-Down>`/`<C-Up>` add cursors, `\\A` selects all occurrences.
- **grug-far** — project-wide find & replace in a buffer (`<leader>sr`; visual
  `<leader>sr` seeds it with the selection). In-buffer actions use
  `<localleader>` (`\`): `\r` replace all, `\s` sync, `<CR>` jump to a match.
- **treesitter** — syntax-aware highlighting, indentation, and text objects that
  power flash/mini.ai. `nvim-autopairs` and `nvim-ts-autotag` close brackets/tags
  automatically (no keys).

### AI

- **Claude Code** (claudecode.nvim) — see §6.
- **copilot.lua** — inline ghost-text suggestions in Insert mode: `<C-l>` accept ·
  `<C-]>` next · `<C-e>` dismiss. (Insert-mode only, configured on the plugin —
  not part of the mode system.)

### UI (mostly display-only)

- **bufferline** — the buffer/tab strip; cycle with `<S-l>`/`<S-h>`, jump by
  ordinal with `Cmd+1/2/3` (vscode).
- **toggleterm** — the terminals behind `<C-\>`/`<M-t>`/`<M-1..3>`.
- **persistence** — auto-saves your session per-directory; restore with
  `<leader>qs`/`<leader>ql`.
- **which-key** — the popup that teaches you the leader trees (no keys of its own).
- **render-markdown** — pretty markdown in the buffer; `<leader>um` toggles it.
- **lualine** (statusline), **github-nvim-theme** (`<leader>ut` toggles
  dark/light), **indent-blankline**, **rainbow-delimiters**, **vim-illuminate**
  (reference highlight; `]r`/`[r` jump in classic), **neoscroll** (smooth
  scrolling), **smear-cursor**, **fidget** (LSP progress), **dashboard** (start
  screen) — all automatic.

---

## 6. AI: Claude Code

Same keys across `classic` and `consistent` (under `<leader>a`):

| Key | Action |
|-----|--------|
| `<leader>ac` | Toggle Claude terminal |
| `<leader>af` | Focus Claude |
| `<leader>ar` / `<leader>aC` | Resume / continue last session |
| `<leader>am` | Select model |
| `<leader>ab` | Add current buffer to context |
| `<leader>as` (visual) | Send selection to Claude |
| `<leader>aa` / `<leader>ad` | Accept / reject Claude's diff |

Diffs Claude proposes are native Neovim diffs — you can also accept with `:w`
and reject with `:q` inside the diff.

---

## 7. Workflows

**Understand a symbol → change it.**
`gd` jump to definition → `<C-o>` jump back → `grr` peek references →
`<leader>cr` rename across the project → `<leader>ca` apply a code action →
`<leader>cf` format. (In `vscode`: `F12` → `Shift+F12` → `F2` → `Cmd+.` →
`Shift+Alt+F`.)

**Review & commit a change.**
`]h`/`[h` walk the hunks → `<leader>ghp` preview one → `<leader>ghs` stage it (or
`vih` to select a hunk and `<leader>ghs`) → `<leader>gd` eyeball the full diff →
`<leader>gg` open LazyGit to commit.

**Debug a failing test.**
`<leader>tt` run the nearest test → `]f` jump to the first failure →
`<leader>db` set a breakpoint → `<leader>td` debug that test → `<leader>dO`/`di`
step → `<leader>de` evaluate a variable → `<leader>du` inspect scopes.

**Find and replace across the project.**
`<leader>ff` open a file, or `<leader>fg` grep to locate the code →
`<leader>sr` open grug-far → type search + replacement → `\r` apply everywhere.

**Pin your working set.**
`<leader>ha` on each of 3–4 key files → `<leader>1`…`<leader>4` to teleport
between them without touching the file tree.

---

*Generated for this config's keybinding-mode system. To change a binding, edit
the relevant module in `lua/keymaps/` (`base.lua` for universal keys, or the
per-mode overlay). The design rationale lives in
[`docs/superpowers/specs/2026-08-12-keybinding-modes-design.md`](superpowers/specs/2026-08-12-keybinding-modes-design.md).*
