# Keybinding Modes — Design Spec

**Date:** 2026-08-12
**Status:** Draft for review
**Author:** Vangel + Claude

> **Amendment (2026-11-20).** Three rules below changed after a review of how
> LazyVim, AstroNvim, kickstart and others structure keymaps:
>
> 1. **The IDE modes extend the consistent tree.** `vscode` and `intellij`
>    declare `extends = "consistent"`, so the manager applies base, then the
>    consistent tree, then the chord overlay. The chords stay pure (no IntelliJ
>    keys in VS Code mode and the reverse); the tree is the fallback for chords
>    a terminal without the kitty keyboard protocol cannot send, and it makes
>    tests, git hunks, grep, harpoon and AI reachable in those modes. The
>    IntelliJ tool windows `<leader>1`–`8` replace the harpoon slots there.
> 2. **Navigation is shared, not per mode.** `gd`, `gD`, `grr` (Glance) and `K`
>    live in `base.lsp`; Neovim's own `grn`, `gra`, `gri`, `grt`, `grx` and `gO`
>    defaults stay. The consistent tree no longer holds `cd` definition, `cD`,
>    `ci` implementation, `cy`, `cr` references, `cn` rename or `ck` hover;
>    `<leader>c` uses the same action letters as classic (`ca`, `cr` rename,
>    `cf`, `co`, `cs`, `cd` line diagnostics, `ci`/`cO` calls).
> 3. **LSP-dependent keys go in each layer's `lsp` list**, applied buffer-local
>    on attach, including the IDE chords (`F12`, `F2`, `Alt+F7`, `Shift+F6`…).
>    `tests/keymaps_spec.lua` fails on a duplicate `{mode, lhs}` within a layer
>    and on any key that is a prefix of another live key.
>
> Sections 2, 3, 6.2–6.4 and 7 below describe the original design.

## 1. Problem

The current keymaps feel inconsistent because three idioms are interleaved with
no rule for which wins:

- **Vim-native** — `gd`, `gr`, `K`, `]c`/`[c`, `s` (flash), `zR`/`zM`
- **IntelliJ function-keys** — `<F4>` def, `<S-F6>` rename, `<A-CR>` action,
  `<C-A-l>` format, `<A-F7>` usages, `<F7>`/`<F8>` step
- **Leader groups** — `<leader>f…` find, `<leader>g…` git, `<leader>1-8` tool windows

Plus macOS `<D-N>` sprinkled in, and **duplicate entry points** for the same
action (`<leader>e` *and* `<leader>1` open the explorer; `<leader>o` *and*
`<leader>6` outline; three ways to toggle a terminal). Telescope
(`navigation.lua`) is `enabled = false` yet still declares `<leader>ff` etc. —
dead bindings adding noise.

## 2. Goal

Replace the ad-hoc keymap layer with **four coherent, switchable schemes**:

1. **Classic** — traditional vim-native / LazyVim-canonical.
2. **Consistent** — one mnemonic rule: `<leader>` + category + verb, fully
   discoverable via which-key.
3. **VS Code** — pure emulation of VS Code's default keymap.
4. **IntelliJ** — pure emulation of IntelliJ IDEA's default keymap.

(VS Code and IntelliJ are separate modes, not one combined "editor" mode — each
is self-contained, so their keys never collide.)

Schemes are **switchable live inside the editor** (`:KeymapMode`), with the
choice persisted across restarts. A comprehensive `docs/keybindings.md` teaches
how to drive Neovim and documents every binding and plugin.

## 3. Non-goals (YAGNI)

- No per-language or per-project scheme overrides. One global active mode.
- No GUI/settings panel beyond the `:KeymapMode` command + picker.
- No combined IDE mode — VS Code and IntelliJ are separate, self-contained
  modes, so their keys never coexist and no precedence rule is needed.
- Not touching option/plugin *behavior* — only where keybindings are declared.

## 4. Architecture

### 4.1 Module layout

```
lua/keymaps/
  init.lua        -- manager: state, :KeymapMode cmd + picker, apply/teardown,
                     persistence, which-key group registration, LSP routing
  base.lua        -- universal bindings present in ALL modes
  classic.lua     -- vim-native overlay
  consistent.lua  -- mnemonic leader-tree overlay
  vscode.lua      -- VS Code emulation overlay
  intellij.lua    -- IntelliJ emulation overlay
```

`lua/core/keymaps.lua` is deleted; `lua/core/init.lua` requires
`keymaps` (the manager) instead.

### 4.2 Scheme data shape

Each scheme module returns a table of **data**, not side effects:

```lua
return {
  name = "classic",
  desc = "Vim-native / LazyVim-canonical",
  -- global maps: { mode(s), lhs, rhs, desc, opts? }
  maps = {
    { "n", "gd", vim.lsp.buf.definition, "Goto definition" },
    { "n", "<leader>ff", function() Snacks.picker.files() end, "Find files" },
    ...
  },
  -- buffer-local maps applied on LspAttach (and re-applied on mode switch)
  lsp = {
    { "n", "gr", "<cmd>Glance references<cr>", "References" },
    ...
  },
  -- which-key group labels for this scheme
  groups = { { "<leader>c", group = "code" }, ... },
}
```

`base.lua` has the same shape and is always applied first; overlays layer on top
and may override base entries (last-write-wins by `{mode, lhs}`).

### 4.3 The manager (`init.lua`)

Responsibilities:

- **State** — holds the active mode name; reads persisted choice on startup from
  `vim.fn.stdpath("data") .. "/keymap-mode"` (outside the repo — nothing to
  gitignore). Defaults to `classic` if absent/invalid.
- **apply(mode)** — apply `base.maps` then `overlay.maps`; record every
  `{mode, lhs}` pair set into a registry; register which-key groups; store LSP
  spec for on-attach; re-apply LSP maps to all currently-attached buffers.
- **teardown()** — `pcall(vim.keymap.del, ...)` every recorded global pair, clear
  which-key groups, delete buffer-local LSP maps from attached buffers.
- **switch(mode)** — `teardown()` → `apply(mode)` → persist → `vim.notify`.
- **`:KeymapMode [name]`** — with arg, switch; without, open a `Snacks.picker`
  (or `vim.ui.select`) listing the three modes + current one.
- **LSP routing** — a single `LspAttach` autocmd (in the manager) applies the
  active scheme's `lsp` maps buffer-local. On `switch`, the manager iterates
  `vim.lsp.get_buffers`/attached buffers and re-applies. This replaces the
  hardcoded on-attach block in `lsp.lua`.

### 4.4 Plugin centralization (Approach A)

Plugins stop declaring `keys = {}`. Each plugin keeps only its **lazy-load
trigger** and becomes a pure capability provider:

- Command-driven plugins (neo-tree, toggleterm, overseer, diffview, lazygit,
  trouble, aerial, grug-far, glance) → `cmd = { ... }`.
- Event/ft plugins (gitsigns, treesitter, mini.*, ufo) → keep `event`/`ft`.
- Cheap always-on (flash, which-key, snacks) → as today.

All bindings that previously lived in those `keys` blocks move into the scheme
modules (base or an overlay). The scheme's `rhs` calls the plugin command
(`<cmd>Neotree toggle<cr>`) or `require()`s it (`function() require("neotest")… end`),
which triggers the lazy load exactly as `keys` did.

Files touched: `navigation.lua` (delete dead Telescope block entirely), `ai.lua`,
`git.lua`, `snacks.lua`, `shell.lua`, `run.lua`, `coding.lua`, `debug.lua`,
`lsp.lua`, `diagnostics.lua`, `ui_extra.lua`, `ui.lua`, `tree.lua`.

## 5. Base scheme (all modes)

Universal, idiom-neutral bindings that don't define a scheme's personality:

| Action | Key | Modes |
|---|---|---|
| Go to left/down/up/right pane | `<C-h>` / `<C-j>` / `<C-k>` / `<C-l>` | n, t |
| Copy to system clipboard | `<C-c>` | v |
| Paste from system clipboard | `<C-v>` | i, v |
| Clear search highlight | `<Esc>` | n |
| Save file | `<C-s>` | n, i |
| Move line up / down | `<A-Up>` / `<A-Down>` | n, v |
| Next / prev buffer | `<S-l>` / `<S-h>` | n |
| Toggle terminal | `<C-\>` | n, t |
| Float / numbered terminals | `<M-t>`, `<M-1..3>` | n, t |
| Flash jump | `s` | n, x, o |
| Theme toggle | `<leader>ut` | n |
| Inlay hints toggle | `<leader>uh` | n |
| Switch keymap mode | `:KeymapMode` | cmd |

Window/split management (`<leader>w…`) and session restore (`<leader>qs`) also
live in base. Comment toggle stays `gcc`/`gc` (native) in base, with terminal
`<C-_>`/`<C-/>`/`<D-/>` reflex added.

> Note: `<S-h>`/`<S-l>` (buffer cycle) is a base default; **classic** additionally
> honors `]b`/`[b`. If `<S-h>`/`<S-l>` conflicts with a future need it can move to
> an overlay.

## 6. The four schemes

### 6.1 Classic (vim-native)

LazyVim-canonical short-`g` navigation, leader-grouped everything else.

| Action | Key |
|---|---|
| Goto definition | `gd` |
| Goto declaration | `gD` |
| Goto implementation | `gI` |
| Goto type definition | `gy` |
| References (Glance) | `gr` |
| Hover | `K` |
| Signature help | `gK` |
| Rename | `<leader>cr` |
| Code action | `<leader>ca` |
| Format | `<leader>cf` |
| Organize imports | `<leader>co` |
| Document symbols / outline | `<leader>cs` (aerial) |
| Next / prev diagnostic | `]d` / `[d` |
| Next / prev error | `]e` / `[e` |
| Line diagnostics | `<leader>cd` |
| Problems (all / buffer) | `<leader>xx` / `<leader>xX` |
| Find files | `<leader>ff` / `<leader><space>` |
| Grep | `<leader>sg` / `<leader>/` |
| Buffers | `<leader>fb` |
| Recent | `<leader>fr` |
| Projects | `<leader>fp` |
| Explorer toggle | `<leader>e` |
| Close buffer | `<leader>bd` |
| Stage / reset / preview hunk | `<leader>ghs` / `<leader>ghr` / `<leader>ghp` |
| Blame line | `<leader>ghb` |
| Next / prev hunk | `]h` / `[h` |
| Lazygit | `<leader>gg` |
| Diff view | `<leader>gd` |
| File history | `<leader>gh` |
| Run task | `<leader>rr` |
| Test nearest / file / summary | `<leader>tt` / `<leader>tf` / `<leader>ts` |
| Breakpoint / continue | `<leader>db` / `<leader>dc` |
| Step over / into / out | `<leader>dO` / `<leader>di` / `<leader>do` |
| Search & replace (project) | `<leader>sr` |
| Fold open / close all | `zR` / `zM` |

### 6.2 Consistent (mnemonic leader-trees)

**One rule: `<leader>` + category + verb.** Every action is discoverable by
pressing the category prefix and reading the which-key menu.

Category prefixes:

| Prefix | Category |
|---|---|
| `<leader>c` | **code** (LSP: definition, references, rename, action, format, impl…) |
| `<leader>g` | **goto / git** |
| `<leader>f` | **find** (files, grep, buffers, recent, symbols) |
| `<leader>b` | **buffer** |
| `<leader>w` | **window** |
| `<leader>t` | **test** |
| `<leader>d` | **debug** |
| `<leader>x` | **diagnostics** |
| `<leader>r` | **run** |
| `<leader>s` | **search / replace** |
| `<leader>a` | **AI** |
| `<leader>u` | **UI toggles** |

Code tree (the heart of the scheme):

| Action | Key |
|---|---|
| Definition | `<leader>cd` |
| Declaration | `<leader>cD` |
| Implementation | `<leader>ci` |
| Type definition | `<leader>cy` |
| References | `<leader>cr` |
| Rename | `<leader>cn` (re**n**ame — `cr` is taken by references) |
| Code action | `<leader>ca` |
| Format | `<leader>cf` |
| Organize imports | `<leader>co` |
| Hover | `<leader>ck` |
| Symbols / outline | `<leader>cs` |
| Line diagnostics | `<leader>ce` |

> Design note: `references` vs `rename` both want `r`/`n`. Resolution:
> `cr` = references (read-heavy, used more), `cn` = rename. Hover stays `K` too
> (base) but is *also* reachable at `<leader>ck` for the pure-tree promise.

Diagnostics/test/debug/run/find trees mirror the classic actions but always
under their category prefix (`<leader>xn`/`<leader>xp` next/prev, `<leader>tt`
test-nearest, `<leader>db` breakpoint, `<leader>ff` find-files, etc.). Full table
in implementation.

### 6.3 VS Code (`vscode` mode)

A pure emulation of VS Code's default keymap — no IntelliJ keys. Each mode is
self-contained, so there are **no cross-IDE conflicts** to resolve. mac + win/
linux literals are picked at load via `vim.fn.has("mac")`; the table shows mac,
with the win/linux variant in parentheses where it differs structurally.

| Action | VS Code (mac / win-linux) |
|---|---|
| Goto definition | `<F12>` |
| Peek definition | `<A-F12>` |
| Goto implementations | `<D-F12>` / `<C-F12>` |
| References | `<S-F12>` |
| Hover | `<D-k><D-i>` / `<C-k><C-i>` |
| Rename | `<F2>` |
| Quick fix (code action) | `<D-.>` / `<C-.>` |
| Format document | `<S-A-f>` |
| Organize imports | `<S-A-o>` |
| Go to file (quick open) | `<D-p>` / `<C-p>` |
| Command palette | `<D-S-p>` / `<C-S-p>` |
| Symbols in file | `<D-S-o>` / `<C-S-o>` |
| Find in files | `<D-S-f>` / `<C-S-f>` |
| Next / prev problem | `<F8>` / `<S-F8>` |
| Toggle sidebar (explorer) | `<D-b>` / `<C-b>` |
| Toggle terminal | `` <C-`> `` |
| Toggle source control | `<C-S-g>` |
| Start / continue debug | `<F5>` |
| Toggle breakpoint | `<F9>` |
| Step over / into / out | `<F10>` / `<F11>` / `<S-F11>` |
| Comment line | `<D-/>` / `<C-/>` |
| Focus editor group 1/2/3 | `<D-1>`/`<D-2>`/`<D-3>` (mac), `<C-1..3>` (win/linux) |

### 6.4 IntelliJ (`intellij` mode)

A pure emulation of IntelliJ IDEA's default keymap — no VS Code keys. Signature
IntelliJ concepts (tool-window numbers, find-usages, intentions) bind directly.

| Action | IntelliJ (mac / win-linux) |
|---|---|
| Goto definition | `<D-b>` / `<C-b>` |
| Goto implementation | `<D-A-b>` / `<C-A-b>` |
| Goto type declaration | `<D-S-b>` / `<C-S-b>` |
| Find usages | `<A-F7>` |
| Quick definition (peek) | `<A-Space>` |
| Quick doc (hover) | `<F1>` |
| Rename | `<S-F6>` |
| Intention / quick fix | `<A-CR>` |
| Reformat code | `<D-A-l>` / `<C-A-l>` |
| Optimize imports | `<C-A-o>` |
| Next / prev error | `<F2>` / `<S-F2>` |
| Go to class / file | `<D-o>` / `<C-n>`, `<D-S-o>` / `<C-S-N>` |
| Symbols | `<D-A-o>` / `<C-A-S-N>` |
| Recent files | `<D-e>` / `<C-e>` |
| File structure | `<D-F12>` / `<C-F12>` |
| Find in files | `<D-S-f>` / `<C-S-f>` |
| Run | `<S-F10>` |
| Debug | `<S-F9>` |
| Step over / into / out | `<F8>` / `<F7>` / `<S-F8>` |
| Toggle breakpoint | `<D-F8>` / `<C-F8>` |
| Tool windows 1–8 | `<leader>1`–`<leader>8` (project/…/version-control) |
| Terminal | `<A-F12>` |
| Comment line | `<D-/>` / `<C-/>` |
| Duplicate line | `<D-d>` / `<C-d>` |
| Commit / git | `<D-k>` / `<C-k>` |

> IntelliJ Run/Debug on mac are `⌃R`/`⌃D`, which shadow vim redo / half-page-down.
> This mode uses the win/linux `<S-F10>`/`<S-F9>` on **both** platforms to avoid
> shadowing vim keys — the one deliberate deviation from mac-literal fidelity.
> Tool-window number focus (`<leader>1-8`) is IntelliJ's signature and lives only
> in this mode (classic/consistent use `<leader>1-4` for harpoon; §12).

## 7. Mode independence (no cross-IDE conflicts)

`vscode` and `intellij` are **separate, self-contained modes**. Because only one
overlay is ever active, IntelliJ and VS Code keys never coexist, so the earlier
"IntelliJ-wins" precedence rule is unnecessary and removed. The only conflicts
left to manage are between an overlay and the shared base / vim built-ins, and
between plugin defaults — handled in §12.

## 8. Documentation deliverable — `docs/keybindings.md`

### 8.1 Research-first (per user requirement)

Before writing, research each source and cite it:

1. **Neovim base** — official docs (`:help`, neovim.io/doc) for modal editing,
   motions, operators, text objects, registers, marks, windows/tabs, folds,
   quickfix, the leader concept, LSP defaults (`grr`/`gra`/`K`/`]d`).
2. **Each plugin** — read the plugin's own README/docs (official repo + online)
   for its real capabilities and canonical commands, not just what we bind.
3. Online sources for idiom/workflow context where helpful.

### 8.2 Structure

1. **How to drive Neovim** — modal editing primer: normal/insert/visual, motions
   + operators + text objects, the "verb-noun" grammar, registers/marks/macros,
   windows/splits/tabs, folds, quickfix/location list. *The main way to use nvim.*
2. **The four modes** — what each is for, how to switch (`:KeymapMode`), how
   persistence works, how to pick one.
3. **Base bindings** — the always-on universal set (§5), explained.
4. **Per-mode reference** — full binding tables for classic / consistent /
   vscode / intellij, each with a one-line "what it's for".
5. **Per-plugin sections** — one section **per plugin plus the Neovim base**,
   each covering: what the plugin does, its bindings in each mode, and a short
   workflow. Plugins to document (all of them):
   - Neovim core (LSP, diagnostics, folds, quickfix)
   - snacks.nvim (picker, notifier, terminal, input)
   - neo-tree, aerial, harpoon, flash
   - gitsigns, diffview, lazygit
   - nvim-dap + dap-ui, neotest, overseer
   - conform / LSP formatting, trouble, glance, grug-far
   - nvim-surround, mini.ai / mini.splitjoin / mini.bufremove, nvim-ufo
   - blink.cmp (completion), treesitter, which-key
   - bufferline, lualine/ui, github-theme, render-markdown
   - Claude Code + copilot (AI), toggleterm, persistence, lazydev
6. **Workflows & examples** — end-to-end flows: *jump to a symbol → peek → find
   references → rename → code-action → format*; *stage a hunk → review diff →
   blame → lazygit*; *set breakpoint → run debug → step → inspect*; *find file →
   grep → search-and-replace across project*.

## 9. Testing / verification

- **Smoke test** (`scripts/smoke.sh`): headless-load each mode
  (`:KeymapMode classic|consistent|vscode|intellij`) and assert no Lua errors, key maps
  present via `nvim_get_keymap`, and clean teardown (a signature key from mode A
  is gone after switching to mode B).
- **LSP re-apply**: with a buffer attached, switch modes and assert buffer-local
  LSP maps reflect the new mode.
- **Manual**: drive one full workflow per mode in a real file.

## 10. Migration / risk

- Largest risk is the plugin `keys → cmd/event/ft` conversion breaking lazy
  loading. Mitigation: convert one plugin at a time, verify it still lazy-loads
  on first keypress, keep `scripts/smoke.sh` green throughout.
- `lua/core/keymaps.lua` deletion is the point of no return; done last, after the
  scheme modules fully cover its contents.
- Buffer-local LSP teardown must `pcall` — some maps may not exist on every
  buffer/mode.

## 11. Capability grounding

The full bindable surface (Neovim 0.12 core + every plugin, docs-sourced) is
enumerated in the companion **`2026-08-12-keybinding-capability-inventory.md`**.
That inventory is the coverage checklist: each scheme must bind every capability
the current config already binds, and should expose the high-value actions we
don't bind today — the snacks git/lsp picker family, gitsigns toggles + the `ih`
hunk text-object, dap `hover`/`eval`, neotest debug-nearest + output-panel +
jump-to-failed, ufo `peek`, todo-comments nav, illuminate reference-nav,
vim-visual-multi multicursor, LSP incoming/outgoing calls, and workspace symbols.

Baseline is Neovim **0.12.4**, which ships the `gr*` LSP defaults
(`grr`/`gra`/`grn`/`gri`/`grt`/`gO`/`grx`) and `]d`/`[d`/`]D`/`[D` diagnostics. The
manager's scheme maps override or complement these deliberately (e.g. classic
rebinds to short `gd`/`gr`; consistent routes everything through `<leader>` trees;
vscode/intellij bind their native IDE keys). The four modes are `classic`,
`consistent`, `vscode`, `intellij`.

## 12. Binding conflicts & resolutions

Resolutions for collisions the capability research surfaced:

| Conflict | Resolution |
|---|---|
| harpoon default slot keys `<C-h/j/k/l>` vs **base pane-nav** `<C-h/j/k/l>` | Pane-nav wins (base). Harpoon slots → `<leader>1`–`<leader>4` in **classic**/**consistent**. |
| `<leader>1`–`<leader>8` tool-window focus (IntelliJ-style) vs harpoon slots | Tool-window-number focus is IntelliJ's signature → lives in **intellij** mode only. classic/consistent use `<leader>1`–`4` for harpoon; vscode uses its native `<D-1..3>` editor groups. |
| vim-illuminate suggests `]]`/`[[` (collides with native section / aerial parent motion) | Bind reference-nav to **`]r`/`[r`** instead; leave `]]`/`[[` native. |
| treesitter incremental-selection README keys `grn`/`grc`/`grm` collide with LSP `grn` | Not configured today. If added: **`<C-space>`** init/expand, **`<BS>`** shrink — off the `gr*` namespace. |
| aerial `{`/`}` symbol motion vs default `{`/`}` paragraph motion | Bind aerial motion **buffer-local in code buffers only** (via LspAttach-adjacent autocmd), preserving `{`/`}` elsewhere. |
| grug-far in-buffer keys need `<localleader>` | Ensure a `localleader` is set (e.g. `,`) in `options.lua`; document it. |
| copilot `<C-l>` (insert) vs pane-nav `<C-l>` (normal/term) | **No conflict** — different modes. Left as-is. |

These resolutions are folded into the scheme tables during implementation
(writing-plans).
